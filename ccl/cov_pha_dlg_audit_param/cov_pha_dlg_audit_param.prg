/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		02/12/2020
	Solution:			Perioperative
	Source file name:	cov_pha_dlg_audit_param.prg
	Object name:		cov_pha_dlg_audit_param
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	02/12/2020  Chad Cummings
******************************************************************************/

drop program cov_pha_dlg_audit_param:dba go
create program cov_pha_dlg_audit_param:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Months Back" = "" 

with OUTDEV, MONTH_BACK


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

/*
cov_pha_eks_dlg_audit
                "MINE",
                "120119",
                "0000",
                "120119",
                "2359",
                "*MUL_MED!DRUGDUP*",
                "B ",
                "S ",
                "M "
go
*/

free set t_rec
record t_rec
(
	1 cnt			= i4
	1 start_date	= c6
	1 start_time	= c4
	1 end_date		= c6
	1 end_time		= c4
	1 module_name	= vc
	1 outtype		= c1
	1 details		= c1
	1 sort			= c1
	1 filename		= vc
	1 full_path		= vc
	1 file_path		= vc
	1 astream_path	= vc
	1 astream_path2	= vc
	1 astream_mv	= vc
	1 astream_mv2	= vc
	1 month_param   = vc
	1 lookback_param = vc
)

set t_rec->module_name  = "*MUL_MED!DRUGDUP*"
set t_rec->outtype		= "B"
set t_rec->details		= "S"
set t_rec->sort			= "M"
set t_rec->month_param	= trim(cnvtstring($MONTH_BACK))

if ((t_rec->month_param = "0") or (t_rec->month_param = "" ))
	set t_rec->month_param = "1"
	call writeLog(build2("->MONTH_BACK parameter missing or invalid, setting to 1 (previous month)"))
endif

set t_rec->lookback_param = build(^"^,t_rec->month_param,^,M"^)

set t_rec->start_date 	= format(
	datetimefind(cnvtlookbehind(t_rec->lookback_param,cnvtdatetime(curdate,curtime3)), 'M', 'B', 'B')
	,"mmddyy;;d")
	
set t_rec->end_date 	= format(
	datetimefind(cnvtlookbehind(t_rec->lookback_param,cnvtdatetime(curdate,curtime3)), 'M', 'E', 'E')
	,"mmddyy;;d")

set t_rec->start_time 	= "0000"
set t_rec->end_time		= "2359"

set t_rec->file_path 	= build("/cerner/d_",cnvtlower(trim(curdomain)),"/temp/")
set t_rec->filename		= build(
										 cnvtlower(trim(curdomain))
										,"_",cnvtlower(trim("eks_dlg_audit"))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".csv"
										)
										
set t_rec->astream_path = build("/nfs/middle_fs/to_client_site/",trim(cnvtlower(curdomain)),"/Export/") 
set t_rec->astream_path2 = build("/nfs/middle_fs/to_client_site/",trim(cnvtlower(curdomain)),"/CernerCCL/") 
 
/*set t_rec->filename		= build(
										 cnvtlower(trim(curdomain))
										,"_",cnvtlower(trim("eks_dlg_audit"))
										,"_"
										,trim(t_rec->start_date)
										,".csv"
										)
										*/
																				
set t_rec->full_path	= concat(t_rec->file_path,t_rec->filename)
set t_rec->astream_mv = build2("cp ",t_rec->full_path," ",t_rec->astream_path,t_rec->filename)
set t_rec->astream_mv2 = build2("cp ",t_rec->full_path," ",t_rec->astream_path2,t_rec->filename)
										
call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Running Report ************************************"))

execute	cov_pha_eks_dlg_audit
	 t_rec->full_path
	,t_rec->start_date
	,t_rec->start_time
	,t_rec->end_date
	,t_rec->end_time
	,t_rec->module_name
	,t_rec->outtype
	,t_rec->details
	,t_rec->sort

;call addAttachment("",t_rec->full_path)

call writeLog(build2("* END   Running Report ***********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Moving File ****************************************"))
call writeLog(build2("-->",trim(t_rec->astream_mv)))
call writeLog(build2("-->",trim(t_rec->astream_mv2)))

set dclstat = 0 
call dcl(t_rec->astream_mv, size(trim(t_rec->astream_mv)), dclstat) 
call dcl(t_rec->astream_mv2, size(trim(t_rec->astream_mv2)), dclstat) 

call writeLog(build2("* END   Moving File ****************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2(cnvtrectojson(t_rec)))

set reply->status_data.status = "S"

#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go


