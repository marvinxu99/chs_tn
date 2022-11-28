set debug_ind = 1 go
execute cov_std_encntr_routines go

record eksdata(
;define data elements set and referenced in templates
;first 132 bytes used for logging to eks_module_audit
1 tqual[4] ;data, evoke, logic and action
2 temptype = c10
2 qual[*]
3 accession_id = f8
3 order_id = f8
3 encntr_id = f8
3 person_id = f8
3 task_assay_cd = f8
3 clinical_event_id = f8; <== Additional Data 
3 logging = vc
3 template_name = c30 ;7.9
3 template_alias = c100 ; <== Additional Data 
3 template_return = i4
3 cnt = i4 ; <== Additional Data 
3 data[*]
4 misc = vc  ;<== Additional Data 
; bldMsg structure added for user defined messages to be
; used in templates with @MESSAGE substitution values.
; paramInd designates if any of the messages are dynamically built parameters.
1 bldMsg_cnt = i4
1 bldMsg_paramInd = i2
1 bldMsg[*]
2 name = vc
2 text = vc
) go

declare trigger_personid = f8 with protect go
declare trigger_encntrid = f8 with protect go
declare trigger_orderid = f8 with protect go

declare link_personid = f8 with protect go
declare link_encntrid = f8 with protect go
declare link_orderid = f8 with protect go

declare FIN = vc with constant("1922000001") go
		
set trigger_encntrid = sGetEncntrID_ByFIN(FIN) go
set trigger_personid = sGetPersonID_ByFIN(FIN) go

set link_personid = trigger_personid go
set link_encntrid = trigger_encntrid go

set tcurindex = 3 go
set curindex = 1 go

call echo(build2("trigger_personid=",trigger_encntrid)) go
call echo(build2("trigger_encntrid=",trigger_personid)) go

execute cov_juxly_service go
;execute mp_get_visit_detail_data "mine",trigger_personid,0.0,0.0,0 go
;execute mp_get_patient_info_wf ^nl:^,trigger_personid,trigger_encntrid,1,1,1,1,0,0.0 go
