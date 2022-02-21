/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           Perioperative
  Source file name:   cov_oe_get_lab_results.prg
  Object name:        cov_oe_get_lab_results
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
drop program cov_oe_get_lab_results:dba go
create program cov_oe_get_lab_results:dba

set retval = -1

free record r_rec
record r_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 order_id  = f8
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
set r_rec->patient.order_id					= link_orderid

if (r_rec->patient.encntr_id <= 0.0)
	set r_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (r_rec->patient.person_id <= 0.0)
	set r_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

if (r_rec->patient.order_id <= 0.0)
	set r_rec->log_message = concat("link_orderid not found")
	go to exit_script
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set r_rec->log_message = value(parameter(1,0))
endif 

free set 1000001_request
record 1000001_request (
  1 query_mode  = i4   
  1 query_mode_ind = i2   
  1 event_set_cd = f8   
  1 person_id = f8   
  1 order_id = f8   
  1 encntr_id = f8   
  1 encntr_financial_id = f8   
  1 contributor_system_cd = f8   
  1 accession_nbr = vc  
  1 compress_flag = i2   
  1 subtable_bit_map = i4   
  1 subtable_bit_map_ind = i2   
  1 small_subtable_bit_map = i4   
  1 small_subtable_bit_map_ind = i2   
  1 search_anchor_dt_tm = dq8   
  1 search_anchor_dt_tm_ind = i2   
  1 seconds_duration = f8   
  1 direction_flag = i2   
  1 events_to_fetch = i4   
  1 date_flag = i2   
  1 view_level = i4   
  1 non_publish_flag = i2   
  1 valid_from_dt_tm = dq8   
  1 valid_from_dt_tm_ind = i2   
  1 decode_flag = i2   
  1 encntr_list [*]   
    2 encntr_id = f8   
  1 event_set_list [*]   
    2 event_set_name = vc  
  1 encntr_type_class_list [*]   
    2 encntr_type_class_cd = f8   
  1 order_id_list_ext [*]   
    2 order_id = f8   
  1 event_set_cd_list_ext [*]   
    2 event_set_cd = f8   
    2 event_set_name = vc  
    2 fall_off_seconds_dur = f8   
  1 ordering_provider_id = f8   
  1 action_prsnl_id = f8   
  1 query_mode2  = i4   
  1 encntr_type_list [*]   
    2 encntr_type_cd = f8   
  1 end_of_day_tz = i4   
  1 perform_prsnl_list [*]   
    2 perform_prsnl_id = f8   
  1 result_status_list [*]   
    2 result_status_cd = f8   
  1 search_begin_dt_tm = dq8   
  1 search_end_dt_tm = dq8   
  1 action_prsnl_group_id = f8   
) 

free set 1000001_reply
record 1000001_reply
(
	1 sb
	    2 severityCd = i4   
	    2 statusCd = i4   
	    2 statusText = vc  
	    2 subStatusList [*]   
	      3 subStatusCd = i4   
	  1 rb_list[*]
	    2 event_set_list[*]
	      3 self_name = vc
	      3 self_cd = f8
	      3 primitive_ind = i2
	      3 parent_event_set_cd = f8
	    2 event_list[*]
	      3 clinical_event_id = f8
	      3 event_id = f8
	      3 event_cd = f8
	      3 event_class_cd = f8
	      3 event_tag = vc
	      3 result_val = vc
	      3 event_tag_set_flag = i2
	      3 result_units_cd_disp = vc
	      3 event_end_dt_tm = dq8
	      3 clinsig_updt_dt_tm = dq8
	      3 valid_from_dt_tm = dq8
	      3 valid_until_dt_tm = dq8
	      3 normalcy_cd = f8
	      3 ce_dynamic_label_id = f8
	      3 dynamic_label_list[*]
	        4 ce_dynamic_label_id = f8
	        4 label_name = vc
	        4 label_status_cd = f8
	        4 label_seq_nbr = i4
	        4 valid_from_dt_tm = dq8
	      3 date_result[*]
	        4 event_id = f8
	        4 valid_until_dt_tm = dq8
	        4 valid_from_dt_tm = dq8
	        4 result_dt_tm = dq8
	        4 date_type_flag = i2
	      3 string_result[*]
	        4 event_id = f8
	        4 valid_from_dt_tm = dq8
	        4 valid_until_dt_tm = dq8
	        4 string_result_text = vc
	        4 string_long_text_id = f8
	      3 coded_result_list[*]
	        4 event_id = f8
	        4 sequence_nbr = i4
	        4 valid_from_dt_tm = dq8
	        4 valid_until_dt_tm = dq8
	        4 result_cd = f8
	        4 group_nbr = i4
	        4 source_string = vc
	      3 src_clinsig_updt_dt_tm = dq8
	      3 src_event_id = f8
%i cclsource:status_block.inc
)

/*
<srvdata lang="C">
   <query_mode>8388609</query_mode>
   <query_mode_ind>0</query_mode_ind>
   <event_set_cd>0</event_set_cd>
   <person_id>18010366</person_id>
   <order_id>1281775077</order_id>
   <encntr_id>0</encntr_id>
   <encntr_financial_id>0</encntr_financial_id>
   <contributor_system_cd>0</contributor_system_cd>
   <accession_nbr></accession_nbr>
   <compress_flag>1</compress_flag>
   <subtable_bit_map>4</subtable_bit_map>
   <subtable_bit_map_ind>0</subtable_bit_map_ind>
   <small_subtable_bit_map>4</small_subtable_bit_map>
   <small_subtable_bit_map_ind>0</small_subtable_bit_map_ind>
   <search_anchor_dt_tm>0000-00-00T00:00:00.00</search_anchor_dt_tm>
   <search_anchor_dt_tm_ind>1</search_anchor_dt_tm_ind>
   <seconds_duration>0</seconds_duration>
   <direction_flag>0</direction_flag>
   <events_to_fetch>0</events_to_fetch>
   <date_flag>0</date_flag>
   <view_level>0</view_level>
   <non_publish_flag>0</non_publish_flag>
   <valid_from_dt_tm>0000-00-00T00:00:00.00</valid_from_dt_tm>
   <valid_from_dt_tm_ind>1</valid_from_dt_tm_ind>
   <decode_flag>0</decode_flag>
   <ordering_provider_id>0</ordering_provider_id>
   <action_prsnl_id>0</action_prsnl_id>
   <query_mode2>0</query_mode2>
   <end_of_day_tz>54</end_of_day_tz>
   <search_begin_dt_tm>0000-00-00T00:00:00.00</search_begin_dt_tm>
   <search_end_dt_tm>0000-00-00T00:00:00.00</search_end_dt_tm>
   <action_prsnl_group_id>0</action_prsnl_group_id>
</srvdata>


set 1000001_REQUEST->person_id = r_rec->patient.person_id
set 1000001_REQUEST->order_id = r_rec->patient.order_id
set 1000001_REQUEST->compress_flag = 1
set 1000001_REQUEST->subtable_bit_map = 4
set 1000001_REQUEST->small_subtable_bit_map = 4
set 1000001_REQUEST->search_anchor_dt_tm_ind = 1
set 1000001_REQUEST->end_of_day_tz = 54
set 1000001_request->query_mode = 8388609 

set stat = tdbexecute(600005, 600107, 1000001, "REC", 1000001_request, "REC", 1000001_reply)

call echorecord(1000001_reply)
*/

select into "nl:"
from
	clinical_event ce
plan ce	
	where ce.order_id = r_rec->patient.order_id
	and   ce.person_id = r_rec->patient.person_id
	and   ce.encntr_id = r_rec->patient.encntr_id
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
										"EID:",trim(cnvtstring(r_rec->patient.encntr_id)),"|",
										"OID:",trim(cnvtstring(r_rec->patient.order_id)),"|"
									)
call echorecord(r_rec)

set retval									= r_rec->retval
set log_message 							= r_rec->log_message
set log_misc1 								= r_rec->log_misc1

end 
go
