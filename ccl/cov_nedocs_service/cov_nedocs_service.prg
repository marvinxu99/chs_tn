/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_nedocs_service.prg
	Object name:		cov_nedocs_service
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_nedocs_service:dba go
create program cov_nedocs_service:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Lookback Hours" = 0 

with OUTDEV, LOOKBACK_HOURS


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
)
endif

call set_codevalues(null)
call check_ops(null)

;free set t_rec
record t_rec
(
	1 cnt			= i4
	1 prompts
	 2 outdev			= vc
	 2 lookback_hours 	= i4
	1 files
	 2 records_attachment		= vc
	1 cons
	 2 run_dt_tm 	= dq8
	 2 lookbehind_param = vc
	1 dates
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
	1 qual[*]
		2 fn_dash_nedocs_info_id = f8
		2 performed_dt_tm = dq8
		2 tracking_group_display = vc
		2 tracking_group_cd = f8
		2 location_view_display = vc
		2 location_view_cd = f8
		2 location_view_desc = vc
		2 patient_cnt = i4
		2 ed_bed_cnt = i4
		2 inpatient_bed_cnt = i4
		2 admit_patient_cnt = i4
		2 critical_patient_cnt = i4
		2 score_val = i4
		2 longest_admit_minutes = i4
		2 last_bed_minutes = i4
		2 modified_score_val = i4
		2 scaling_factor_value = i4
)


;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.lookback_hours = $LOOKBACK_HOURS

if (t_rec->prompts.lookback_hours = 0)
	set t_rec->prompts.lookback_hours = 24
endif
set t_rec->cons.lookbehind_param = build(^"^,t_rec->prompts.lookback_hours,^,H"^)

set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)
set t_rec->dates.end_dt_tm 		= cnvtdatetime(curdate,curtime3)
set t_rec->dates.start_dt_tm	= cnvtdatetime(cnvtlookbehind(t_rec->cons.lookbehind_param,cnvtdatetime(curdate,curtime3)))

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Tracking Groups   *******************************************"))

select
from
	fn_dash_nedocs_info fdni
plan fdni
	where fdni.performed_dt_tm between cnvtdatetime(t_rec->dates.start_dt_tm) and cnvtdatetime(t_rec->dates.end_dt_tm)
order by
	fdni.performed_dt_tm
head report
	cnt = 0
detail
	cnt += 1
	stat = alterlist(t_rec->qual,cnt)
	t_rec->qual[cnt].admit_patient_cnt			= fdni.admit_patient_cnt
	t_rec->qual[cnt].ed_bed_cnt					= fdni.ed_bed_cnt
	t_rec->qual[cnt].critical_patient_cnt		= fdni.critical_patient_cnt
	t_rec->qual[cnt].fn_dash_nedocs_info_id		= fdni.fn_dash_nedocs_info_id
	t_rec->qual[cnt].inpatient_bed_cnt			= fdni.inpatient_bed_cnt
	t_rec->qual[cnt].last_bed_minutes			= fdni.last_bed_minutes
	t_rec->qual[cnt].location_view_cd			= fdni.location_view_cd
	t_rec->qual[cnt].location_view_desc			= fdni.location_view_desc
	t_rec->qual[cnt].location_view_display		= uar_get_code_display(fdni.location_view_cd)
	t_rec->qual[cnt].longest_admit_minutes		= fdni.longest_admit_minutes
	t_rec->qual[cnt].modified_score_val			= fdni.modified_score_val
	t_rec->qual[cnt].patient_cnt				= fdni.patient_cnt
	t_rec->qual[cnt].performed_dt_tm			= fdni.performed_dt_tm
	t_rec->qual[cnt].scaling_factor_value		= fdni.scaling_factor_value
	t_rec->qual[cnt].score_val					= fdni.score_val
	t_rec->qual[cnt].tracking_group_cd			= fdni.tracking_group_cd
	t_rec->qual[cnt].tracking_group_display		= uar_get_code_display(fdni.tracking_group_cd)
foot report
	t_rec->cnt = cnt
with nocounter
	    
    
call writeLog(build2("* END   Finding Tracking Groups   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

/*
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit *************************************"))
	call writeAudit(build2(
							char(34),^ITEM^,char(34),char(44),
							char(34),^DESC^,char(34)
						))
for (i=1 to t_rec->cnt)
		call writeAudit(build2(
							char(34),t_rec->qual[i].a											,char(34),char(44),
							char(34),t_rec->qual[i].b											,char(34)
						))

endfor
call writeLog(build2("* END   Creating Audit *************************************"))
call writeLog(build2("************************************************************"))
*/

#exit_script

set _memory_reply_string = cnvtrectojson(t_rec,0,1,0)


;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)


call exitScript(null)

call echo(build("_memory_reply_string=",_memory_reply_string))
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
