/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       
  Solution:           
  Source file name:   cov_rad_auto_exam_report.prg
  Object name:        cov_rad_auto_exam_report
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).
  
       <appid>455002</appid>
       <taskid>455004</taskid>
       <stepid>455014</stepid>
       <cpmprocess>0</cpmprocess>
       <origstepid>455014</origstepid>
       <deststepid>455014</deststepid>
    </input>
    <properties>
       <propList>
          <propName>Crm.LogLevel</propName>
          <propValue>4</propValue>
       </propList>
       <propList>
          <propName>Cpm.RequestName</propName>
          <propValue>rad_add_report_info</propValue>
       </propList>
       
<dtl>
       <task_assay_cd>690507</task_assay_cd>
       <required_ind>1</required_ind>
       <template_id>0</template_id>
       <section_sequence>1</section_sequence>
       <acr_code_ind>0</acr_code_ind>
       <detail_reference_nbr>RAD2624447738</detail_reference_nbr>
       <detail_event_id>3654313032</detail_event_id>
   <ord_rad>
       <order_id>4735127481</order_id>
       <report_status_meaning>TRANS</report_status_meaning>
       <updt_cnt>0</updt_cnt>
       <parent_order_id>4735127481</parent_order_id>
       <group_event_id>3654312316</group_event_id>
       <contributor_system_cd>469</contributor_system_cd>
    </ord_rad>
    <rad_report_id>2624447737</rad_report_id>
    <order_id>4735127481</order_id>
    <no_proxy_ind>0</no_proxy_ind>
    <rad_rpt_reference_nbr>RAD2624447737</rad_rpt_reference_nbr>
    <dictated_dt_tm>0000-00-00T00:00:00.00</dictated_dt_tm>
    <redictate_ind>0</redictate_ind>
    <classification_cd>0</classification_cd>
    <modified_ind>0</modified_ind>
    <res_queue_ind>0</res_queue_ind>
    <addendum_ind>0</addendum_ind>
    <dictated_by_id>0</dictated_by_id>
    <report_event_id>3654313030</report_event_id>
    <sequence>1</sequence>
    <prsnl_add>
       <report_prsnl_id>16908168</report_prsnl_id>
       <prsnl_relation_flag>0</prsnl_relation_flag>
       <proxied_for_id>0</proxied_for_id>
       <queue_ind>0</queue_ind>
       <action_dt_tm>0000-00-00T00:00:00.00</action_dt_tm>
    </prsnl_add>
    <prsnl_add>
       <report_prsnl_id>12399134</report_prsnl_id>
       <prsnl_relation_flag>2</prsnl_relation_flag>
       <proxied_for_id>0</proxied_for_id>
       <queue_ind>0</queue_ind>
       <action_dt_tm>0000-00-00T00:00:00.00</action_dt_tm>
    </prsnl_add>
    <dtl>
       <task_assay_cd>690507</task_assay_cd>
       <required_ind>1</required_ind>
       <template_id>0</template_id>
       <section_sequence>1</section_sequence>
       <acr_code_ind>0</acr_code_ind>
       <detail_reference_nbr>RAD2624447738</detail_reference_nbr>
       <detail_event_id>3654313032</detail_event_id>
    </dtl>
    <trans_stats>
       <sequence>0</sequence>
       <trans_prsnl_id>16908168</trans_prsnl_id>
       <line_cnt>0</line_cnt>
       <word_cnt>0</word_cnt>
       <char_cnt>7</char_cnt>
    </trans_stats>
    <reporting_priority_cd>0</reporting_priority_cd>
    <dictation_seconds>0</dictation_seconds>
    <report_creation_mthd_cd>686262</report_creation_mthd_cd>
    <hide_prelim_action>0</hide_prelim_action>
    <hide_prelim_report_ind>0</hide_prelim_report_ind>
    <dStoryId>0</dStoryId>
 </srvdata>

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   			  Chad Cummings			initial build
******************************************************************************/
drop program cov_rad_auto_exam_report:dba go
create program cov_rad_auto_exam_report:dba

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

if (t_rec->patient.order_id <= 0.0)
	set t_rec->log_message = concat("link_orderid not found")
	go to exit_script
endif

;if (t_rec->patient.person_id <= 0.0)
;	set t_rec->log_message = concat("link_personid not found")
;	go to exit_script
;endif

record 455014request (
  1 ord_rad [*]
    2 order_id = f8
    2 report_status_meaning = c12
    2 updt_cnt = i4
    2 parent_order_id = f8
    2 group_event_id = f8
    2 contributor_system_cd = f8
  1 rad_report_id = f8
  1 order_id = f8
  1 no_proxy_ind = i2
  1 rad_rpt_reference_nbr = c40
  1 dictated_dt_tm = dq8
  1 redictate_ind = i2
  1 classification_cd = f8
  1 modified_ind = i2
  1 res_queue_ind = i2
  1 addendum_ind = i2
  1 dictated_by_id = f8
  1 report_event_id = f8
  1 sequence = i4
  1 prsnl_add [*]
    2 report_prsnl_id = f8
    2 prsnl_relation_flag = i2
    2 proxied_for_id = f8
    2 queue_ind = i2
    2 action_dt_tm = dq8
  1 dtl [*]
    2 task_assay_cd = f8
    2 required_ind = i2
    2 template_id = f8
    2 section_sequence = i4
    2 acr_code_ind = i2
    2 detail_reference_nbr = c40
    2 detail_event_id = f8
  1 trans_stats [*]
    2 sequence = i4
    2 trans_prsnl_id = f8
    2 line_cnt = i4
    2 word_cnt = i4
    2 char_cnt = i4
  1 reporting_priority_cd = f8
  1 dictation_seconds = i4
  1 report_creation_mthd_cd = f8
  1 hide_prelim_action = i2
  1 hide_prelim_report_ind = i2
  1 dStoryId = f8
) 

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */


declare event_id = f8 with protect, noconstant(0.0)
declare order_id = f8 with protect, noconstant(0.0)

set t_rec->return_value = "FALSE"

select into "nl:"
from
	clinical_event ce
plan ce
	where ce.order_id = t_rec->patient.order_id
detail
	stat = alterlist(455014REQUEST->ord_rad,1) 
	455014REQUEST->ord_rad[1].order_id = ce.order_id 
	455014REQUEST->ord_rad[1].report_status_meaning = "FINAL" 
	455014REQUEST->ord_rad[1].parent_order_id = ce.order_id 
	455014REQUEST->ord_rad[1].group_event_id =  ce.event_id 
	455014REQUEST->ord_rad[1].contributor_system_cd = 469
	455014REQUEST->order_id =ce.order_id
	
	455014REQUEST->rad_report_id =cnvtreal(substring(4,100,ce.reference_nbr))
	
	stat = alterlist(455014REQUEST->dtl,1) 
	455014REQUEST->dtl[1].task_assay_cd = 690507 
	455014REQUEST->dtl[1].required_ind = 1 
	455014REQUEST->dtl[1].section_sequence = 1 
	455014REQUEST->dtl[1].detail_reference_nbr = ce.reference_nbr 
	455014REQUEST->dtl[1].detail_event_id = ce.event_id 
	455014REQUEST->report_creation_mthd_cd = 686262 
with nocounter 

call echorecord(455014request) 
 
set stat = tdbexecute(455002,455004,455014,"REC",455014REQUEST,"REC",455014REPLY) 
 
call echorecord(455014REPLY) 

set event_id = 455014REQUEST->ord_rad[1].group_event_id 
set order_id  = 455014REQUEST->ord_rad[1].order_id 

execute cov_him_auth_by_event ^MINE^,event_id 
execute cov_eks_trigger_by_o "NOFORMS","COV_EE_COMPLETE_ORD",order_id 

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

 
 
