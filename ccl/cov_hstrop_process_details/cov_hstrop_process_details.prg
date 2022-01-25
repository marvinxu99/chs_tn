/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:
	Solution:
	Source file name:	cov_hstrop_process_details.prg
	Object name:		cov_hstrop_process_details
	Request #:
 
	Program purpose:
 
	Executing from:		CCL
 
  Special Notes:      Additional Scripts:
  						cov_eks_trigger_by_o
  						cov_troponin_util
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
001   	12/11/2021  Chad Cummings			initial build
******************************************************************************/
 
drop program cov_hstrop_process_details:dba go
create program cov_hstrop_process_details:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "EVENT_ID" = 0
 
with OUTDEV, EVENT_ID
 
 
call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))
 
if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
) with protect
endif
 
call set_codevalues(null)
call check_ops(null)
 
execute cov_troponin_util
 
;free set t_rec
record t_rec
(
	1 cnt			= i4
	1 prompts
	 2 outdev		= vc
	 2 event_id		= f8
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 run_dt_tm 				= dq8
	 2 hsTrop_cd				= f8
	 2 order_dt_tm_margin_min	= i4
	1 dates
	 2 start_dt_tm	= dq8
	 2 stop_dt_tm	= dq8
	1 ord_process_ind = i2
 
	1 info
 
	 2 algorithm
	  	3 type 			= vc
	  	3 subtype		= vc
	  	3 current_phase	= vc
	  	3 current_normalcy = vc
	  	3 current_full_normalcy = vc
	  	3 event_id		= f8
	  	3 parent_event_id = f8
	  	3 event_end_dt_tm = dq8
	 2 initial
	 	3 order_id		= f8
	 	3 collect_dt_tm = dq8
	 	3 result_val	= f8
	 	3 normalcy     = vc
	 	3 order_name   = vc
	 	3 powerplan_name = vc
	 	3 accession 	= vc
	 2 one_hour
	    3 needed_ind 	= i4
	 	3 order_id 		= f8
		3 collect_dt_tm = dq8
		3 target_dt_tm 	= dq8
		3 cancel_ind	= i4
		3 run_dt_tm_diff = i4
		3 order_now_ind = i4
		3 result_val	= f8
		3 delta			= f8
	 	3 normalcy      = vc
	 	3 accession 	= vc
	 2 three_hour
	    3 needed_ind 	= i4
	 	3 order_id 		= f8
		3 collect_dt_tm = dq8
		3 target_dt_tm 	= dq8
		3 cancel_ind    = i4
		3 run_dt_tm_diff = i4
		3 order_now_ind	= i4
		3 result_val	= f8
		3 delta			= f8
	 	3 normalcy      = vc
	 	3 accession		= vc
) with protect
 
declare html_output = gvc with noconstant("")
declare patient_table = vc with noconstant("")
 
set t_rec->prompts.event_id = $EVENT_ID
set t_rec->prompts.outdev = $OUTDEV
set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
 
set t_rec->cons.run_dt_tm		= cnvtdatetime(curdate,curtime3)
 
set t_rec->cons.hsTrop_cd = GethsTropAlgEC(null)
set t_rec->cons.order_dt_tm_margin_min = GethsTropAlgOrderMargin(null)
 
 
call addhsTropDataRec(1)
call writeLog(build2("->getting event_id=",t_rec->cons.hsTrop_cd))
set stat = cnvtjsontorec(GethsTropAlgDataByEventID(t_rec->prompts.event_id))
 
set t_rec->info.initial.order_id				= hsTroponin_data->initial.order_id
set t_rec->info.initial.collect_dt_tm			= hsTroponin_data->initial.collect_dt_tm
set t_rec->info.one_hour.collect_dt_tm			= hsTroponin_data->one_hour.collect_dt_tm
set t_rec->info.one_hour.needed_ind				= hsTroponin_data->one_hour.needed_ind
set t_rec->info.one_hour.order_id				= hsTroponin_data->one_hour.order_id
set t_rec->info.one_hour.target_dt_tm			= hsTroponin_data->one_hour.target_dt_tm
set t_rec->info.three_hour.collect_dt_tm		= hsTroponin_data->three_hour.collect_dt_tm
set t_rec->info.three_hour.needed_ind			= hsTroponin_data->three_hour.needed_ind
set t_rec->info.three_hour.order_id				= hsTroponin_data->three_hour.order_id
set t_rec->info.three_hour.target_dt_tm			= hsTroponin_data->three_hour.target_dt_tm
 
set t_rec->info.algorithm.type					= hsTroponin_data->algorithm_info.type
set t_rec->info.algorithm.subtype				= hsTroponin_data->algorithm_info.subtype
set t_rec->info.algorithm.current_phase			= hsTroponin_data->algorithm_info.current_phase
set t_rec->info.algorithm.current_normalcy		= hsTroponin_data->algorithm_info.current_normalcy
set t_rec->info.algorithm.current_full_normalcy= hsTroponin_data->algorithm_info.current_full_normalcy
 
set t_rec->info.initial.result_val				= hsTroponin_data->initial.result_val
set t_rec->info.initial.normalcy				= hsTroponin_data->initial.normalcy
set t_rec->info.initial.order_name				= GetOrderSynonymbyOrderID(hsTroponin_data->initial.order_id)
set t_rec->info.initial.powerplan_name			= GetOrderPowerPlanbyOrderID(hsTroponin_data->initial.order_id)
set t_rec->info.initial.accession				= GetOrderAccessionbyOrderID(hsTroponin_data->initial.order_id)
 
set t_rec->info.one_hour.result_val				= hsTroponin_data->one_hour.result_val
set t_rec->info.one_hour.delta					= hsTroponin_data->one_hour.delta
set t_rec->info.one_hour.normalcy				= hsTroponin_data->one_hour.normalcy
set t_rec->info.one_hour.accession				= GetOrderAccessionbyOrderID(hsTroponin_data->one_hour.order_id)
 
 
set t_rec->info.three_hour.result_val			= hsTroponin_data->three_hour.result_val
set t_rec->info.three_hour.delta				= hsTroponin_data->three_hour.delta
set t_rec->info.three_hour.normalcy				= hsTroponin_data->three_hour.normalcy
set t_rec->info.three_hour.accession			= GetOrderAccessionbyOrderID(hsTroponin_data->three_hour.order_id)
 
 
 
record 3011001_request (
  1 module_dir = vc
  1 module_name = vc
  1 basblob = i2
)
 
set 3011001_request->module_dir = "cust_script:"
set 3011001_request->module_name = "cov_hstrop_process_details.html" ;
set 3011001_request->basblob = 1
 
free record 3011001_reply
 
call writeLog(build2(cnvtrectojson(3011001_request)))
 
set stat = tdbexecute(3010000,3011002,3011001,"REC",3011001_request,"REC",3011001_reply)
 
if (validate(3011001_reply))
	call writeLog(build2(cnvtrectojson(3011001_reply)))
	if (3011001_reply->status_data.status = "S")
		set html_output = 3011001_reply->data_blob
	else
		call writeLog(build2("HTML Template not found, exiting"))
		go to exit_script
	endif
else
	call writeLog(build2("HTML Template not found, exiting"))
	go to exit_script
endif
 
set html_output = replace(html_output,^%%REPLACE_JSON%%^,cnvtrectojson(t_rec))
set html_output = replace(html_output,^%%HSTROPONIN_DATA_JSON%%^,cnvtrectojson(hsTroponin_data))
 
 
free record putrequest
record putrequest (
 
     1 source_dir = vc
     1 source_filename = vc
     1 nbrlines = i4
     1 line [* ]
       2 linedata = vc
     1 overflowpage [* ]
       2 ofr_qual [* ]
         3 ofr_line = vc
     1 isblob = c1
     1 document_size = i4
     1 document = gvc
)
 
set putrequest->source_dir =  t_rec->prompts.outdev
set putrequest->isblob = "1"
set putrequest->document = html_output
set putrequest->document_size = size (html_output )
execute eks_put_source with replace ("REQUEST" ,putrequest ) , replace ("REPLY" ,putreply )
 
 
 
set reply->status_data.status = "S"
#exit_script
 
 
call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"","CP"
 
call writeLog(build2("_v1"))
 
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
 
 
end
go
 
