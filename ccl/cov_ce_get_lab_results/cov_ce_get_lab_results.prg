/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           Perioperative
  Source file name:   cov_ce_get_lab_results.prg
  Object name:        cov_ce_get_lab_results
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			initial build
******************************************************************************/
drop program cov_ce_get_lab_results:dba go
create program cov_ce_get_lab_results:dba

set retval = -1

free record r_rec
record r_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	1 link_template_id = f8
	1 incoming_ce_cnt = i2
	1 incoming_ce_qual[*]
	 2 clinical_event_id = f8
	 2 event_cd = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
	1 result_cnt = i2
	1 result_qual[*]
	 2 clinical_event_id = f8
	 2 trigger_name = vc
)


set r_rec->retval							= -1
set r_rec->return_value						= "FAILED"
set r_rec->patient.encntr_id 				= link_encntrid
set r_rec->patient.person_id				= link_personid
set r_rec->link_template_id					= link_template

declare i = i2 with noconstant(0)

if (r_rec->patient.encntr_id <= 0.0)
	set r_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (r_rec->patient.person_id <= 0.0)
	set r_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

if (r_rec->link_template_id <= 0.0)
	set r_rec->log_message = concat("link_template not found")
	go to exit_script
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set r_rec->log_message = value(parameter(1,0))
endif 
*/

;looking for logic template IncomingResult
for (i=1 to (eksdata->tqual[3].qual[r_rec->link_template_id].cnt + 1))
	if (i >= 2)
		set r_rec->incoming_ce_cnt = (r_rec->incoming_ce_cnt + 1)
		set stat = alterlist(r_rec->incoming_ce_qual,r_rec->incoming_ce_cnt)
		set r_rec->incoming_ce_qual[r_rec->incoming_ce_cnt].clinical_event_id 
			= cnvtreal(eksdata->tqual[3].qual[r_rec->link_template_id].data[i].misc)
	endif
endfor

select into "nl:"
from
	clinical_event ce
plan ce	
	where ce.person_id = r_rec->patient.person_id
	and   ce.encntr_id = r_rec->patient.encntr_id
	and   expand(i,1,r_rec->incoming_ce_cnt,ce.clinical_event_id,r_rec->incoming_ce_qual[i].clinical_event_id)
	and   ce.view_level = 1
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
detail
	r_rec->result_cnt = (r_rec->result_cnt + 1)
	stat = alterlist(r_rec->result_qual,r_rec->result_cnt)
	r_rec->result_qual[r_rec->result_cnt].clinical_event_id = ce.clinical_event_id
	r_rec->result_qual[r_rec->result_cnt].trigger_name = "COV_UPDT_SERVICE_RESOURCE"
with nocounter

if (r_rec->result_cnt = 0)
	set r_rec->return_value = "FALSE"
	set r_rec->log_message = "No Results found for order"
	go to exit_script
endif
call echo("executing cov_eks_trigger_by_ce")
for (x= 1 to r_rec->result_cnt)
	call echo(build2(^execute cov_eks_trigger_by_ce "MINE",^
		,trim(r_rec->result_qual[x].trigger_name),^,^
		,trim(cnvtstring(r_rec->result_qual[x].clinical_event_id))
		))
	execute cov_eks_trigger_by_ce 	"MINE",
									r_rec->result_qual[x].trigger_name,
									r_rec->result_qual[x].clinical_event_id
	set r_rec->return_value = "TRUE"
	set r_rec->log_message = concat(r_rec->log_message,"CID:",
		trim(cnvtstring(r_rec->result_qual[x].clinical_event_id)),";")
endfor

#exit_script

if (trim(cnvtupper(r_rec->return_value)) = "TRUE")
	set r_rec->retval = 100
	set r_rec->log_misc1 = ""
elseif (trim(cnvtupper(r_rec->return_value)) = "FALSE")
	set r_rec->retval = 0
else
	set r_rec->retval = 0
endif

set r_rec->log_message = concat(
										trim(r_rec->log_message),";",
										trim(cnvtupper(r_rec->return_value)),":",
										"PID:",trim(cnvtstring(r_rec->patient.person_id)),"|",
										"EID:",trim(cnvtstring(r_rec->patient.encntr_id)),"|"
									)

set r_rec->log_message = cnvtrectojson(r_rec)

set retval									= r_rec->retval
set log_message 							= r_rec->log_message
set log_misc1 								= r_rec->log_misc1

end 
go
