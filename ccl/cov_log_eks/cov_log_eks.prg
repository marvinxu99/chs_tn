/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:		03/01/2019
	Solution:			Perioperative
	Source file name:	cov_log_eks.prg
	Object name:		cov_log_eks
	Request #:
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:		Called by ccl program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	03/01/2019  Chad Cummings
******************************************************************************/
 
drop program cov_log_eks:dba go
create program cov_log_eks:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
call echo(build("loading script:",curprog))
 
set modify maxvarlen 268435456 ;increases max file size
 
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
 
record t_rec
(
	1 cnt				= i4
	1 filename      	= vc
	1 filename_a      	= vc
	1 filename_b    	= vc
	1 filename_c 		= vc
	1 filename_d 		= vc
	1 filename_e 		= vc
	1 filename_f 		= vc
	1 filename_g		= vc
	1 filename_h		= vc
	1 filename_i		= vc
	1 filename_j		= vc
	1 filename_k		= vc
	1 audit_cnt 		= i4
	1 audit[*]
	 2 section = vc
	 2 title = vc
	 2 alias = vc
	 2 misc = vc
) with protect
 
 
;call addEmailLog("chad.cummings@covhlth.com")
if (($OUTDEV != "MINE") and ($OUTDEV > " "))
	set i = 1
		while (str != notfnd)
			set str = piece($OUTDEV,';',i,notfnd)
			if (str != notfnd)
				call writeLog(build2(^calling addEmailLog for "^,str,^"^))
				call addEmailLog(str)
			endif
			set i = i+1
		endwhile
	;call addEmailLog($OUTDEV)
endif
 
set program_log->email.subject = concat(
											 program_log->curdomain
											," "
											,program_log->curprog
											," "
											,format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")
										)
 
if (validate(eks_common->cur_module_name))
	set t_rec->filename   = concat(	 "cclscratch:eks_",trim(cnvtlower(eks_common->cur_module_name))
									,"_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
	set program_log->email.subject = concat(
											 program_log->curdomain
											," "
											,trim(check(cnvtlower(eks_common->cur_module_name)))
											," "
											,format(sysdate,"yyyy-mm-dd hh:mm:ss;;d")
										)
 
else
	set t_rec->filename   = concat("cclscratch:eks_eksdata_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
endif
 
 
set t_rec->filename_a = concat("cclscratch:eks_eksdata_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_b = concat("cclscratch:eks_request_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_c = concat("cclscratch:eks_audit_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_d = concat("cclscratch:eks_problem_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_e = concat("cclscratch:eks_reqinfo_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_f = concat("cclscratch:eks_ekscommon_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_g = concat("cclscratch:eks_ekssub_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_h = concat("cclscratch:eks_ordrequest_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_i = concat("cclscratch:eks_ordreply_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_j = concat("cclscratch:eks_cerequest_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
 set t_rec->filename_k = concat("cclscratch:eks_event_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
/*
record eksdata(
1 tqual[4] ;data, evoke, logic and action
2 temptype = c10
2 qual[*]
3 accession_id = f8
3 order_id = f8
3 encntr_id = f8
3 person_id = f8
3 task_assay_cd = f8
3 clinical_event_id = f8
3 logging = vc
3 template_name = c30
3 cnt = i4
3 data[*]
4 misc = vc
)
*/
if (validate(eksdata))
	call echojson(eksdata, t_rec->filename_a , 0)
	call echojson(eksdata, t_rec->filename , 1)
	for (ii=1 to size(eksdata->tqual,5))
		for (i=1 to size(eksdata->tqual[ii].qual,5))
			set t_rec->audit_cnt = (t_rec->audit_cnt + 1 )
			set stat = alterlist(t_rec->audit,t_rec->audit_cnt)
			set t_rec->audit[t_rec->audit_cnt].section = eksdata->tqual[ii].temptype
			set t_rec->audit[t_rec->audit_cnt].title = eksdata->tqual[ii].qual[i].template_name
			set t_rec->audit[t_rec->audit_cnt].alias = eksdata->tqual[ii].qual[i].template_alias
			if (eksdata->tqual[ii].qual[i].cnt > 0)
				for (jj=1 to size(eksdata->tqual[ii].qual[i].data,5))
					set t_rec->audit[t_rec->audit_cnt].misc = concat(	t_rec->audit[t_rec->audit_cnt].misc,
																		eksdata->tqual[ii].qual[i].data[jj].misc,
																		"<|>"
																	)
				endfor
			endif
		endfor
	endfor
	call writeLog(build2(cnvtrectojson(eksdata)))
	call addAttachment(program_log->files.file_path, replace(t_rec->filename_a,"cclscratch:",""))
endif
 
if (validate(request))
	call echojson(request, t_rec->filename_b , 0)
	call echojson(request, t_rec->filename , 1)
	call writeLog(build2(cnvtrectojson(request)))
	call addAttachment(program_log->files.file_path, replace(t_rec->filename_b,"cclscratch:",""))
endif
if (validate(ProblemRequest))
	call echojson(ProblemRequest, t_rec->filename_d , 0)
	call echojson(ProblemRequest, t_rec->filename , 1)
	call writeLog(build2(cnvtrectojson(ProblemRequest)))
	call addAttachment(program_log->files.file_path, replace(t_rec->filename_d,"cclscratch:",""))
endif
if (validate(reqinfo))
	call echojson(reqinfo,t_rec->filename_e, 0)
	call echojson(reqinfo, t_rec->filename , 1)
	call writeLog(build2(cnvtrectojson(reqinfo)))
	call addAttachment(program_log->files.file_path, replace(t_rec->filename_e,"cclscratch:",""))
endif
if (validate(eks_common))
	call echojson(eks_common,t_rec->filename_f, 0)
	call echojson(eks_common, t_rec->filename , 1)
	call writeLog(build2(cnvtrectojson(eks_common)))
	call addAttachment(program_log->files.file_path, replace(t_rec->filename_f,"cclscratch:",""))
endif
if (validate(t_rec))
	call echojson(t_rec, t_rec->filename_c , 0)
	call echojson(t_rec, t_rec->filename , 1)
	call writeLog(build2(cnvtrectojson(t_rec)))
	call addAttachment(program_log->files.file_path, replace(t_rec->filename_c,"cclscratch:",""))
endif
if (validate(ekssub))
	call echojson(ekssub,t_rec->filename_g, 0)
	call echojson(ekssub, t_rec->filename , 1)
	call writeLog(build2(cnvtrectojson(ekssub)))
	call addAttachment(program_log->files.file_path, replace(t_rec->filename_g,"cclscratch:",""))
endif
 
if (validate(ordrequest))
	call echojson(ordrequest,t_rec->filename_h, 0)
	call echojson(ordrequest, t_rec->filename , 1)
	call writeLog(build2(cnvtrectojson(ordrequest)))
	call addAttachment(program_log->files.file_path, replace(t_rec->filename_h,"cclscratch:",""))
endif
if (validate(ordreply))
	call echojson(ordreply,t_rec->filename_i, 0)
	call echojson(ordreply, t_rec->filename , 1)
	call writeLog(build2(cnvtrectojson(ordreply)))
	call addAttachment(program_log->files.file_path, replace(t_rec->filename_i,"cclscratch:",""))
endif
if (validate(cerequest))
	call echojson(cerequest,t_rec->filename_j, 0)
	call echojson(cerequest, t_rec->filename , 1)
	call writeLog(build2(cnvtrectojson(cerequest)))
	call addAttachment(program_log->files.file_path, replace(t_rec->filename_j,"cclscratch:",""))
endif
if (validate(event))
	call echojson(event,t_rec->filename_k, 0)
	call echojson(event, t_rec->filename , 1)
	call writeLog(build2(cnvtrectojson(event)))
	call addAttachment(program_log->files.file_path, replace(t_rec->filename_k,"cclscratch:",""))
endif
 
 
 
set retval = 100
set log_message = cnvtrectojson(program_log)
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Adding Attachments *********************************"))
 
call writeLog(build2("->program_log->files.file_path=",trim(program_log->files.file_path)))
call writeLog(build2(^->replace(t_rec->filename,"cclscratch:","")=^,trim(replace(t_rec->filename,"cclscratch:",""))))
call addAttachment(program_log->files.file_path, replace(t_rec->filename,"cclscratch:",""))
;execute cov_astream_file_transfer "cclscratch",replace(t_rec->filename,"cclscratch:",""),"","MV"
call writeLog(build2(cnvtrectojson(program_log)))
 
call writeLog(build2("* END   Custom v1 ************************************"))
call writeLog(build2("*****************************************************"))
 
#exit_script
call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
 
 
end
go
 
