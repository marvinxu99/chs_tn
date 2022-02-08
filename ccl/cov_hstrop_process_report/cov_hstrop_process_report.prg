/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:
	Solution:
	Source file name:	cov_hstrop_process_audit.prg
	Object name:		cov_hstrop_process_audit
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
 
drop program cov_hstrop_process_report:dba go
create program cov_hstrop_process_report:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date Time" = "SYSDATE"
	, "End Date and Time" = "SYSDATE"
	, "FIN" = "" 

with OUTDEV, BEG_DT_TM, END_DT_TM, FIN
 
 
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
	 2 beg_dt_tm	= dq8
	 2 end_dt_tm	= dq8
	 2 fin = vc
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 run_dt_tm 				= dq8
	 2 hsTrop_cd				= f8
	 2 order_dt_tm_margin_min	= i4
	 2 fin						= vc
	 2 encntr_id 				= f8
	 2 encntr_operator			= vc
	1 dates
	 2 start_dt_tm	= dq8
	 2 stop_dt_tm	= dq8
	 2 last_ops_date = dq8
	 2 last_ops_date_vc = vc
	1 ord_process_ind = i2
	1 event_cnt     = i4
	1 event_list[*]
	 2 event_id		= f8
	 2 new_event_id = f8
	 2 encntr_id	= f8
	 2 person_id    = f8
	 2 result_cnt 	= i2
	 2 name_full_formatted = vc
	 2 json = vc
	 2 algorithm
	  	3 type 			= vc
	  	3 subtype		= vc
	  	3 current_phase	= vc
	  	3 current_normalcy = vc
	  	3 current_full_normalcy = vc
	 2 initial
	 	3 order_id		= f8
	 	3 collect_dt_tm = dq8
	 	3 result_val	= f8
	 	3 result_val2 = vc
	 	3 result_event_id = f8
	 	3 normalcy     = vc
	 	3 order_name   = vc
	 	3 powerplan_name = vc
	 	3 accession = vc
	 	3 order_status = vc
	 	3 order_update_prsnl = vc
	 	3 ecg_order_id = f8
	 	3 ecg_order_table = vc
	 2 one_hour
	    3 needed_ind 	= i4
	 	3 order_id 		= f8
		3 collect_dt_tm = dq8
		3 target_dt_tm 	= dq8
		3 cancel_ind	= i4
		3 run_dt_tm_diff = i4
		3 order_now_ind = i4
		3 result_val	= f8
		3 result_event_id = f8
		3 delta			= f8
	 	3 normalcy      = vc
	 	3 accession = vc
	 	3 order_status = vc
	 	3 order_update_prsnl = vc
	 	3 ecg_order_id = f8
	 	3 ecg_order_table = vc
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
		3 result_event_id = f8
	 	3 normalcy      = vc
	 	3 accession = vc
	 	3 order_update_prsnl = vc
	 	3 order_status = vc
	 	3 ecg_order_id = f8
	 	3 ecg_order_table = vc
) with protect
 
declare html_output = gvc with noconstant("")
declare patient_table = vc with noconstant("")
 
set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
 
set t_rec->prompts.outdev    = $OUTDEV
set t_rec->prompts.beg_dt_tm = cnvtdatetime($BEG_DT_TM)
set t_rec->prompts.end_dt_tm = cnvtdatetime($END_DT_TM)
set t_rec->prompts.fin 		 = $FIN
 
set t_rec->cons.run_dt_tm		= cnvtdatetime(curdate,curtime3)
 
set t_rec->cons.hsTrop_cd = GethsTropAlgEC(null)
set t_rec->cons.order_dt_tm_margin_min = GethsTropAlgOrderMargin(null)
 
set t_rec->dates.start_dt_tm = t_rec->prompts.beg_dt_tm
set t_rec->dates.stop_dt_tm = t_rec->prompts.end_dt_tm
 
set t_rec->dates.last_ops_date = GethsTropOpsDate(concat(trim(cnvtupper("cov_hstrop_process_ops")),":","start_dt_tm"))
set t_rec->dates.last_ops_date_vc = format(t_rec->dates.last_ops_date,";;q")

if (t_rec->prompts.fin > " ")
	select into "nl:"
	from encntr_alias ea
	plan ea
		where ea.alias = t_rec->prompts.fin
		and   ea.active_ind = 1
		and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
		and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	detail
		t_rec->cons.fin = ea.alias
		t_rec->cons.encntr_id = ea.encntr_id
	with nocounter
endif

if (t_rec->cons.encntr_id > 0.0)
	set t_rec->cons.encntr_operator = "="
else
	set t_rec->cons.encntr_operator = "!="
endif

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Getting hsTroponin Algorithms on active patients ***"))
 
select into "nl:"
from
	 encounter e
	,person p
	,clinical_event ce
	,ce_blob ceb
plan ce
	where ce.event_cd =  t_rec->cons.hsTrop_cd
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ce.event_end_dt_tm between cnvtdatetime(t_rec->dates.start_dt_tm) and cnvtdatetime(t_rec->dates.stop_dt_tm)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
join e
	where e.encntr_id = ce.encntr_id
	and operator(e.encntr_id, 	t_rec->cons.encntr_operator, 	t_rec->cons.encntr_id)
join p
	where p.person_id = e.person_id
join ceb
	where ceb.event_id = ce.event_id
order by
	 ce.encntr_id
	,ce.parent_event_id
head report
	i = 0
head ce.encntr_id
	i = 0
head ce.parent_event_id
	call writeLog(build2("->found ce.parent_event_id=",ce.parent_event_id))
	call writeLog(build2("->found p.name_full_formatted=",p.name_full_formatted))
	call writeLog(build2("->found e.encntr_id=",e.encntr_id))
	call writeLog(build2("->found p.person_id=",p.person_id))
 
 	i = (i + 1)
	t_rec->event_cnt = (t_rec->event_cnt + 1)
	stat = alterlist(t_rec->event_list,t_rec->event_cnt)
	t_rec->event_list[t_rec->event_cnt].encntr_id = e.encntr_id
	t_rec->event_list[t_rec->event_cnt].event_id = ce.parent_event_id
	t_rec->event_list[t_rec->event_cnt].person_id = p.person_id
	t_rec->event_list[t_rec->event_cnt].name_full_formatted = p.name_full_formatted
foot ce.encntr_id
	t_rec->event_list[t_rec->event_cnt].result_cnt = i
with nocounter
 
if (t_rec->event_cnt = 0)
	set reply->status_data.status = "Z"
	go to exit_script
endif
 
call writeLog(build2("-------------------------------------------------------------"))
call writeLog(build2("- Getting individual algorithm results"))
for (i=1 to t_rec->event_cnt)
 
	call addhsTropDataRec(1)
	call writeLog(build2("->getting event_id=",t_rec->event_list[i].event_id))
	set stat = cnvtjsontorec(GethsTropAlgDataByEventID(t_rec->event_list[i].event_id))
	if (validate(hsTroponin_data))
		set t_rec->event_list[i].json 							= GethsTropAlgDataByEventID(t_rec->event_list[i].event_id)
		set t_rec->event_list[i].initial.order_id				= hsTroponin_data->initial.order_id
		set t_rec->event_list[i].initial.collect_dt_tm			= hsTroponin_data->initial.collect_dt_tm
		set t_rec->event_list[i].one_hour.collect_dt_tm			= hsTroponin_data->one_hour.collect_dt_tm
		set t_rec->event_list[i].one_hour.needed_ind			= hsTroponin_data->one_hour.needed_ind
		set t_rec->event_list[i].one_hour.order_id				= hsTroponin_data->one_hour.order_id
		set t_rec->event_list[i].one_hour.target_dt_tm			= hsTroponin_data->one_hour.target_dt_tm
		set t_rec->event_list[i].three_hour.collect_dt_tm		= hsTroponin_data->three_hour.collect_dt_tm
		set t_rec->event_list[i].three_hour.needed_ind			= hsTroponin_data->three_hour.needed_ind
		set t_rec->event_list[i].three_hour.order_id			= hsTroponin_data->three_hour.order_id
		set t_rec->event_list[i].three_hour.target_dt_tm		= hsTroponin_data->three_hour.target_dt_tm
 
		set t_rec->event_list[i].algorithm.type					= hsTroponin_data->algorithm_info.type
		set t_rec->event_list[i].algorithm.subtype				= hsTroponin_data->algorithm_info.subtype
		set t_rec->event_list[i].algorithm.current_phase		= hsTroponin_data->algorithm_info.current_phase
		set t_rec->event_list[i].algorithm.current_normalcy		= hsTroponin_data->algorithm_info.current_normalcy
		set t_rec->event_list[i].algorithm.current_full_normalcy= hsTroponin_data->algorithm_info.current_full_normalcy
 
		set t_rec->event_list[i].initial.result_val				= hsTroponin_data->initial.result_val
		set t_rec->event_list[i].initial.normalcy				= hsTroponin_data->initial.normalcy
		set t_rec->event_list[i].initial.order_name				= GetOrderSynonymbyOrderID(hsTroponin_data->initial.order_id)
		set t_rec->event_list[i].initial.powerplan_name			= GetOrderPowerPlanbyOrderID(hsTroponin_data->initial.order_id)
 		set t_rec->event_list[i].initial.result_event_id		= hsTroponin_data->initial.result_event_id
 		set t_rec->event_list[i].initial.ecg_order_id			= hsTroponin_data->initial.ecg_order_id
 
		set t_rec->event_list[i].one_hour.result_val			= hsTroponin_data->one_hour.result_val
		set t_rec->event_list[i].one_hour.delta					= hsTroponin_data->one_hour.delta
		set t_rec->event_list[i].one_hour.normalcy				= hsTroponin_data->one_hour.normalcy
 		set t_rec->event_list[i].one_hour.result_event_id		= hsTroponin_data->one_hour.result_event_id
 		set t_rec->event_list[i].one_hour.ecg_order_id			= hsTroponin_data->one_hour.ecg_order_id
 
		set t_rec->event_list[i].three_hour.result_val			= hsTroponin_data->three_hour.result_val
		set t_rec->event_list[i].three_hour.delta				= hsTroponin_data->three_hour.delta
		set t_rec->event_list[i].three_hour.normalcy			= hsTroponin_data->three_hour.normalcy
		set t_rec->event_list[i].three_hour.result_event_id		= hsTroponin_data->three_hour.result_event_id
		set t_rec->event_list[i].three_hour.ecg_order_id		= hsTroponin_data->initial.ecg_order_id
	endif
 
	select into "nl:"
	from
		accession_order_r aor
		,accession a
		,orders o
	plan aor
		where aor.order_id in( t_rec->event_list[i].initial.order_id,t_rec->event_list[i].one_hour.order_id,
								t_rec->event_list[i].three_hour.order_id)
	join a
		where a.accession_id = aor.accession_id
	join o
		where o.order_id = aor.order_id
	detail
		case (aor.order_id)
			of t_rec->event_list[i].initial.order_id: 		t_rec->event_list[i].initial.accession = cnvtacc(a.accession)
															t_rec->event_list[i].initial.order_status = concat(
																uar_get_code_display(o.order_status_cd)," (",
																uar_get_code_display(o.dept_status_cd),")")
			of t_rec->event_list[i].one_hour.order_id:		t_rec->event_list[i].one_hour.accession = cnvtacc(a.accession)
															t_rec->event_list[i].one_hour.order_status = concat(
																uar_get_code_display(o.order_status_cd)," (",
																uar_get_code_display(o.dept_status_cd),")")
			of t_rec->event_list[i].three_hour.order_id:	t_rec->event_list[i].three_hour.accession = cnvtacc(a.accession)
															t_rec->event_list[i].three_hour.order_status = concat(
																uar_get_code_display(o.order_status_cd)," (",
																uar_get_code_display(o.dept_status_cd),")")
		endcase
endfor
 
call writeLog(build2("* END   Getting hsTroponin Algorithms on active patients ***"))
call writeLog(build2("************************************************************"))

for (i=1 to t_rec->event_cnt)
	set t_rec->event_list[i].initial.result_val2 = GetResultTextbyEventID(t_rec->event_list[i].initial.result_event_id)
endfor
 
select into t_rec->prompts.outdev 
	 location = uar_get_code_display(e.loc_nurse_unit_cd)
	,fin = ea.alias
	,name = p.name_full_formatted
	,initial_oid = t_rec->event_list[d1.seq].initial.order_id
	,initial_status = uar_get_code_display(o1.order_status_cd)
	,onehour_oid = t_rec->event_list[d1.seq].one_hour.order_id
	,onehour_status = uar_get_code_display(o2.order_status_cd)
	,threehour_oid = t_rec->event_list[d1.seq].three_hour.order_id
	,threehour_status = uar_get_code_display(o3.order_status_cd)
	,person_id = t_rec->event_list[d1.seq].person_id
	,encntr_id = t_rec->event_list[d1.seq].encntr_id
from
	(dummyt d1 with seq=t_rec->event_cnt)
	,person p
	,encounter e
	,encntr_alias ea
	,clinical_event ce
	,orders o1
	,orders o2
	,orders o3

	,(dummyt d2)
plan d1
	;where t_rec->event_list[d1.seq].algorithm.subtype = "GREATER"
	;and t_rec->event_list[d1.seq].initial.result_val2 = "<6"
	;and t_rec->event_list[d1.seq].initial.normalcy = "INDETERMINATE"
join e
	where e.encntr_id = t_rec->event_list[d1.seq].encntr_id
join p
	where p.person_id = e.person_id
join ce
	where ce.event_id = t_rec->event_list[d1.seq].event_id
join o1
	where o1.order_id = t_rec->event_list[d1.seq].initial.order_id
join o2
	where o2.order_id = t_rec->event_list[d1.seq].one_hour.order_id
join o3
	where o3.order_id = t_rec->event_list[d1.seq].three_hour.order_id

join d2
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
order by
	 ce.event_end_dt_tm desc
	,p.name_full_formatted
	,p.person_id
	,e.encntr_id
	,ce.event_end_dt_tm desc

with nocounter,nullreport,format,seperator=" ",outerjoin=d2
 
 
set reply->status_data.status = "S"
#exit_script
 
 
call writeLog(build2("_v1"))
 
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
 
 
end
go
 
