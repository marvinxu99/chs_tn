/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:
	Solution:
	Source file name:	cov_st_insurance.prg
	Object name:		cov_st_insurance
	Request #:
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:		Called by ccl program(s).
 					    use cov_st_ccl_template.tst test
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/
 
drop program cov_st_insurance:dba go
create program cov_st_insurance:dba
 
 
call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))
 
execute cov_std_routines
 
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
call set_rtf_commands(null)
 
;free set t_rec
record t_rec
(
	1 cnt			= i4
	1 encntr_id		= f8
)
 
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Set Encounter ID ***********************************"))
 
if (validate(request->visit[1].encntr_id))
	set t_rec->encntr_id = request->visit[1].encntr_id
endif
 
if (t_rec->encntr_id = 0.0)
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "ENCNTR_ID"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "ENCNTR_ID"
	set reply->status_data.subeventstatus.targetobjectvalue = "Encoutner ID not found or set in request"
	go to exit_script
endif
 
call writeLog(build2("* END   Set Encounter ID ***********************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Getting Insurance   ********************************"))
 
set stat = cnvtjsontorec(sGetInsuranceByEncntrID(t_rec->encntr_id))
 
if (stat = TRUE)
	call echorecord(insurance_list)
else
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "INSURANCE_LIST"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "INSURANCE_LIST"
	set reply->status_data.subeventstatus.targetobjectvalue = "Standard Insurance List routine failed"
	go to exit_script
endif
 
call writeLog(build2("* END   Getting Insurance   ********************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
 
call RTFReply(rtf_commands->st.rhead)
 
call RTFReply(rtf_commands->st.wr)
 
call RTFReply(build2(" ",trim(curprog)," ran successfully"))
 
call RTFReply(rtf_commands->st.rtfeof)
set rtf_commands->end_ind = 1
call RTFReply(reply)	;echo reply
 
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))
 
#exit_script
 
 
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
 
 
end
go
 
