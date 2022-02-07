/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:
  Source file name:   cov_eks_ldct_diag.prg
  Object name:        cov_eks_ldct_diag
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
drop program cov_eks_ldct_diag:dba go
create program cov_eks_ldct_diag:dba
 
set retval = -1
 
free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 clinical_event_id = f8
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
 
/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */
 
set t_rec->return_value = "FALSE"
 
/*
select into "nl:"
from
	 dcp_forms_activity dfa
	,dcp_forms_activity_comp dfac
	,clinical_event ce1
	,clinical_event ce2
plan
*/
 
select
	 ce3.event_cd
	,ce3.result_val
from
	 dcp_forms_activity dfa
	,dcp_forms_activity_comp dfac
	,dcp_forms_activity_comp dfac2
	,clinical_event ce1
	,clinical_event ce2
	,clinical_event ce3
	,code_value cv1
plan ce1
	where ce1.clinical_event_id = t_rec->patient.clinical_event_id
join dfac
	where dfac.parent_entity_id = ce1.parent_event_id
join dfac2
	where dfac2.dcp_forms_activity_id = dfac.dcp_forms_activity_id
join dfa
	where dfa.dcp_forms_activity_id = dfac.dcp_forms_activity_id
join ce2
	where ce2.parent_event_id = dfac2.parent_entity_id
	and   ce2.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce2.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce2.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce2.event_tag        != "Date\Time Correction"
 
join ce3
	where ce3.parent_event_id = ce2.event_id
	and   ce3.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce3.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce3.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce3.event_tag        != "Date\Time Correction"
 
join cv1
	where cv1.code_value = ce3.event_cd
	and   cv1.display = "Diagnosis Associated to Patient's visit"
order by
	 ce3.event_id
	,ce3.event_end_dt_tm desc
head ce3.event_id
	t_rec->return_value = "TRUE"
	t_rec->log_misc1 = trim(ce3.result_val)
with nocounter
 
 
 
#exit_script
 
if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif
 
set t_rec->log_message = cnvtrectojson(t_rec)
 
call echorecord(t_rec)
 
set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1
 
end
go
 
