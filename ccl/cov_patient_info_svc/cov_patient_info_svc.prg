/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_imo_add_dx_audit.prg
	Object name:		cov_imo_add_dx_audit
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

drop program cov_patient_info_svc:dba go
create program cov_patient_info_svc:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "ALIAS" = ""
	, "ALIAS_TYPE" = "CMRN" 

with OUTDEV, ALIAS, ALIAS_TYPE

execute cov_std_encntr_routines

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
	 2 outdev		= vc
	 2 alias	= vc
	 2 alias_type	= vc
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 run_dt_tm 	= dq8
	 2 person_id	= f8
	 2 encntr_id	= f8
	1 dates
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
	1 qual[*]
	 2 person_id	= f8
	 2 encntr_id	= f8
	 2 mrn			= vc
	 2 fin			= vc
	 2 name_full_formatted = vc
)

;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.alias = $ALIAS
set t_rec->prompts.alias_type = cnvtupper($ALIAS_TYPE)

set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Validating Alias   *******************************************"))

if (t_rec->prompts.alias_type = "CMRN")
	set t_rec->cons.person_id = sGetPersonID_ByCMRN(t_rec->prompts.alias) 
elseif (t_rec->prompts.alias_type = "FIN")
	set t_rec->cons.person_id = sGetPersonID_ByFIN(t_rec->prompts.alias) 
	set t_rec->cons.encntr_id = sGetEncntrID_ByFIN(t_rec->prompts.alias) 
endif   
    
call writeLog(build2("* END   Validating Alias   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

set stat = cnvtjsontorec(sGetPatientDemo(t_rec->cons.person_id,t_rec->cons.encntr_id))

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


#exit_script


;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)


call exitScript(null)
call echorecord(t_rec)
call echorecord(cov_patient_info)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
