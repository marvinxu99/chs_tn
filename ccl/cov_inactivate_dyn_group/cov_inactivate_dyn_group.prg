/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       
  Solution:           
  Source file name:   cov_inactivate_dyn_group.prg
  Object name:        cov_inactivate_dyn_group
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
drop program cov_inactivate_dyn_group:dba go
create program cov_inactivate_dyn_group:dba

execute cov_std_log_routines

call SubroutineLog(build2("starting ",trim(curprog)))

set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 clinical_event_id = f8
	1 data
	 2 ce_dynamic_label_id = f8
	 2 inactive_status_cd = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
)

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
set t_rec->patient.clinical_event_id 		= link_clineventid 

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

if (t_rec->patient.clinical_event_id <= 0.0)
	set t_rec->log_message = concat("link_eventid not found")
	go to exit_script
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

set code_set    = 4002015				
set code_value  = 0.0				
set cdf_meaning = fillstring(12," ")			
 
set cdf_meaning = "INACTIVE"				
execute cpm_get_cd_for_cdf				
set t_rec->data.inactive_status_cd = code_value	
   
set t_rec->return_value = "FALSE"

select into "nl:"
from
	clinical_event ce
plan ce
	where ce.clinical_event_id = t_rec->patient.clinical_event_id
detail
	t_rec->data.ce_dynamic_label_id = ce.ce_dynamic_label_id
with nocounter

if (t_rec->data.ce_dynamic_label_id <= 0.0)
	set t_rec->log_message = concat("ce_dynamic_label_id not found")
	go to exit_script
endif

update into 
	ce_dynamic_label t
set
		t.valid_from_dt_tm	= cnvtdatetime(curdate,curtime3),
		t.label_status_cd   = t_rec->data.inactive_status_cd,
		t.label_prsnl_id    = ReqInfo->updt_id,
		t.updt_dt_tm		= cnvtdatetime(curdate,curtime3),
		t.updt_task			= ReqInfo->updt_task,
		t.updt_id			= ReqInfo->updt_id,
		t.updt_applctx		= ReqInfo->updt_applctx,
		t.updt_cnt			= t.updt_cnt + 1
where 
	t.ce_dynamic_label_id = t_rec->data.ce_dynamic_label_id
		
set t_rec->return_value = "TRUE"

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
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end 
go
