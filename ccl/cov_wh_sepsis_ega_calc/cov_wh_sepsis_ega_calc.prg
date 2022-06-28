/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       
  Solution:           
  Source file name:   cov_wh_sepsis_ega_calc.prg
  Object name:        cov_wh_sepsis_ega_calc
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   			  Chad Cummings			initial build
******************************************************************************/
drop program cov_wh_sepsis_ega_calc:dba go
create program cov_wh_sepsis_ega_calc:dba

execute cov_std_log_routines

call SubroutineLog(build2("starting ",trim(curprog)))

set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 order_id = f8
	1 result_codes
	 2 birth_date_time = f8
	1 recent_birth_dt_tm = dq8
	1 qualify_dt_tm = dq8
	1 current_gest_age = i4
	1 est_gest_age = i4
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
)

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
set t_rec->patient.order_id 				= link_orderid


set t_rec->result_codes.birth_date_time = uar_get_code_by("DISPLAY",72,"Date, Time of Birth:")

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

set t_rec->return_value = "FALSE"

free record 640003Request 
record 640003REQUEST (
  1 patient_list [*]   
    2 patient_id = f8   
    2 encntr_id = f8   
  1 pregnancy_list [*]   
    2 pregnancy_id = f8   
  1 multiple_egas = i2   
  1 provider_list [*]   
    2 patient_id = f8   
    2 encntr_id = f8   
    2 provider_patient_reltn_cd = f8   
  1 provider_id = f8   
  1 position_cd = f8   
  1 cal_ega_multiple_gest = i2   
) 

free record 640003Reply 

set stat = alterlist(640003Request->patient_list,1) 
set 640003Request->patient_list[1].patient_id = t_rec->patient.person_id

set stat = tdbexecute(600005,640000,640003,"REC",640003Request,"REC",640003Reply) 

call echorecord(640003Reply) 

if (validate(640003Reply->status_data->status))
	if (640003Reply->status_data->status = "S")
		for (i=1 to size(640003Reply->gestation_info,5))
			set t_rec->current_gest_age = 640003Reply->gestation_info[i].current_gest_age
			set t_rec->est_gest_age = 640003Reply->gestation_info[i].est_gest_age
			if (640003Reply->gestation_info[i].current_gest_age > 140)		
				set t_rec->return_value = "TRUE"			
			endif
		endfor	
	endif 
endif

select into "nl:"
from
	person p
	,clinical_event ce
	,ce_date_result cdr
plan p
	where p.person_id = t_rec->patient.person_id
join ce
	where ce.person_id = p.person_id
	and	  ce.event_cd = t_rec->result_codes.birth_date_time
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
join cdr
	where cdr.event_id = ce.event_id
	and   cdr.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3)
order by
	 ce.event_cd
	,cdr.result_dt_tm desc
head ce.event_cd
	t_rec->recent_birth_dt_tm = cdr.result_dt_tm
	t_rec->qualify_dt_tm = cnvtlookahead("3,D",t_rec->recent_birth_dt_tm)
with nocounter

if (cnvtdatetime(sysdate) <= t_rec->qualify_dt_tm)
	set t_rec->return_value = "TRUE"
endif


#exit_script

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
	set t_rec->log_misc1 = ""
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtrectojson(t_rec))
								)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end 
go
