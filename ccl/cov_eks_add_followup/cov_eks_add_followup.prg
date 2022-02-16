/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_eks_add_followup.prg
  Object name:        cov_eks_add_followup
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
drop program cov_eks_add_followup:dba go
create program cov_eks_add_followup:dba

set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 order_id = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
	1 order_info
	 2 pcp_provider_id = f8
	 2 pcp_provider_name = vc
	 2 pcp_follow_up_within = vc
	 2 specialist_provider_id = f8
	 2 specialist_provider_name = vc
	 2 specialist_follow_up_within = vc
	 2 emergency_follow_up = vc
	1 followup
	 2 pcp_ind = i2
	 2 specialist_ind = i2
	 2 emergency = i2
)

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
set t_rec->patient.order_id 				= link_orderid

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

if (t_rec->patient.order_id <= 0.0)
	set t_rec->log_message = concat("link_orderid not found")
	go to exit_script
endif

record 4250785_request (
  1 pat_ed_doc_id = f8   
  1 encntr_id = f8   
  1 person_id = f8   
  1 event_id = f8   
  1 pat_ed_domain_cd = f8   
  1 sign_flag = i2   
  1 task_flag = i2   
  1 provider_id = f8   
  1 provider_name = vc  
  1 cmt_long_text_id = f8   
  1 long_text = vc  
  1 followup_dt_tm = dq8   
  1 add_long_text_id = f8   
  1 add_long_text = vc  
  1 fol_within_range = vc  
  1 fol_days = i2   
  1 day_or_week = i2   
  1 active_ind = i2   
  1 organization_id = f8   
  1 location_cd = f8   
  1 address_type_cd = f8   
  1 pat_ed_followup_id = f8   
  1 quick_pick_cd = f8   
  1 followup_range_cd = f8   
  1 address_id = f8   
  1 phone_id = f8   
  1 followup_needed_ind = i2   
  1 recipient_long_text_id = f8   
  1 recipient_long_text = vc  
) 


/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

set t_rec->return_value = "FALSE"

select into "nl:"
from
	orders o
	,order_detail od
	,order_entry_fields oef
plan o
	where o.order_id = t_rec->patient.order_id
join od
	where od.order_id = o.order_id
join oef
	where oef.oe_field_id = od.oe_field_id
order by
	 o.order_id
	,od.oe_field_id
	,od.detail_sequence desc
head report
	null
head o.order_id
	null
head od.oe_field_id
	case (oef.description)
		of "Provider":		t_rec->order_info.specialist_provider_id = od.oe_field_value
							t_rec->order_info.specialist_provider_name = od.oe_field_display_value
		of "PCP Provider":	t_rec->order_info.pcp_provider_id = od.oe_field_value
							t_rec->order_info.pcp_provider_name = od.oe_field_display_value
		of "Follow-up within": t_rec->order_info.pcp_follow_up_within = od.oe_field_display_value
		of "Follow up with Specialist within": t_rec->order_info.specialist_follow_up_within = od.oe_field_display_value
		of "Follow up with Emergency Dept Within": t_rec->order_info.emergency_follow_up = od.oe_field_display_value
	endcase
with nocounter


if (
		
		(t_rec->order_info.specialist_follow_up_within > " ")
	)
	set t_rec->followup.specialist_ind = 1
endif

if (
		
		(t_rec->order_info.pcp_follow_up_within > " ")
	)
	set t_rec->followup.pcp_ind = 1
endif

if (
		(t_rec->order_info.emergency_follow_up > " ")
	)
	set t_rec->followup.emergency = 1
endif

if (
			(t_rec->followup.emergency = 0)
	 and	(t_rec->followup.pcp_ind = 0)
	 and	(t_rec->followup.specialist_ind = 0)
	)
	set stat = initrec(4250785_request)
	set 4250785_request->encntr_id = t_rec->patient.encntr_id
	set 4250785_request->person_id = t_rec->patient.person_id
	set 4250785_request->task_flag = 1
	set 4250785_request->provider_id = 0
	set 4250785_request->provider_name = "Follow-up Ordering Provider"
	set 4250785_request->fol_within_range = t_rec->order_info.emergency_follow_up
	set 4250785_request->day_or_week = -1
	set 4250785_request->active_ind = 1
	set 4250785_request->quick_pick_cd = uar_get_code_by("DISPLAY",20701,"Follow-up in Emergency Department")
	set 4250785_request->followup_range_cd = uar_get_code_by("DISPLAY",27980,t_rec->order_info.emergency_follow_up)
	call echorecord(4250785_request)
	set stat = tdbexecute(600005,4250705,4250785,"REC",4250785_request,"REC",4250785_reply)
	call echorecord(4250785_reply)
endif

if (t_rec->followup.emergency = 1)
	set stat = initrec(4250785_request)
	set 4250785_request->encntr_id = t_rec->patient.encntr_id
	set 4250785_request->person_id = t_rec->patient.person_id
	set 4250785_request->task_flag = 1
	set 4250785_request->provider_id = 0
	set 4250785_request->provider_name = "Follow-up in Emergency Department"
	set 4250785_request->fol_within_range = t_rec->order_info.emergency_follow_up
	set 4250785_request->day_or_week = -1
	set 4250785_request->active_ind = 1
	set 4250785_request->quick_pick_cd = uar_get_code_by("DISPLAY",20701,"Follow-up in Emergency Department")
	set 4250785_request->followup_range_cd = uar_get_code_by("DISPLAY",27980,t_rec->order_info.emergency_follow_up)
	call echorecord(4250785_request)
	set stat = tdbexecute(600005,4250705,4250785,"REC",4250785_request,"REC",4250785_reply)
	call echorecord(4250785_reply)
endif

if (t_rec->followup.pcp_ind = 1)
	set stat = initrec(4250785_request)
	set 4250785_request->encntr_id = t_rec->patient.encntr_id
	set 4250785_request->person_id = t_rec->patient.person_id
	set 4250785_request->task_flag = 1
	set 4250785_request->provider_id = t_rec->order_info.pcp_provider_id
	set 4250785_request->provider_name = t_rec->order_info.pcp_provider_name
	if (t_rec->order_info.pcp_provider_name = "")
		set 4250785_request->provider_name = "Follow up with primary care provider"	
	endif
	set 4250785_request->fol_within_range = t_rec->order_info.pcp_follow_up_within
	set 4250785_request->day_or_week = -1
	set 4250785_request->active_ind = 1
	set 4250785_request->followup_range_cd = uar_get_code_by("DISPLAY",27980,t_rec->order_info.pcp_follow_up_within)
	call echorecord(4250785_request)
	set stat = tdbexecute(600005,4250705,4250785,"REC",4250785_request,"REC",4250785_reply)
	call echorecord(4250785_reply)
endif

if (t_rec->followup.specialist_ind = 1)
	set stat = initrec(4250785_request)
	set 4250785_request->encntr_id = t_rec->patient.encntr_id
	set 4250785_request->person_id = t_rec->patient.person_id
	set 4250785_request->task_flag = 1
	set 4250785_request->provider_id = t_rec->order_info.specialist_provider_id
	set 4250785_request->provider_name = t_rec->order_info.specialist_provider_name
	if (t_rec->order_info.specialist_provider_name= "")
		set 4250785_request->provider_name = "Follow up with specialist"
	endif
	set 4250785_request->fol_within_range = t_rec->order_info.specialist_follow_up_within
	set 4250785_request->day_or_week = -1
	set 4250785_request->active_ind = 1
	set 4250785_request->followup_range_cd = uar_get_code_by("DISPLAY",27980,t_rec->order_info.specialist_follow_up_within)
	call echorecord(4250785_request)
	set stat = tdbexecute(600005,4250705,4250785,"REC",4250785_request,"REC",4250785_reply)
	call echorecord(4250785_reply)
endif	
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
