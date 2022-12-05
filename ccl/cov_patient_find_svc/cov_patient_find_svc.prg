/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_patient_find_svc.prg
	Object name:		cov_patient_find_svc
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

drop program cov_patient_find_svc:dba go
create program cov_patient_find_svc:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "REQUEST" = "" 

with OUTDEV, REQUEST

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

;free set t_rec
record t_rec
(
	1 cnt			= i4
	1 prompts
	 2 outdev		= vc
	 2 request		= vc
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
	 2 valid_ind	= i2
	 2 dob			= vc
	 2 sex			= vc
	1 pass_cnt		= i2
	1 pass[*]
	 2 person_id	= f8
	 2 encntr_id	= f8
)



;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->prompts.outdev 		= $OUTDEV
set t_rec->prompts.request 		= $REQUEST

set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Validating Alias   *******************************************"))

set stat = cnvtjsontorec(t_rec->prompts.request)
call echorecord(patient_request)

if (not (validate(patient_request->criteria)))
	set stat = sSet_ErrorReply("Invalid or Missing Request")
	go to exit_script
endif

if (validate(patient_request->criteria[1].type))
	if (patient_request->criteria[1].type in("SSN"))
		set stat = cnvtjsontorec(sGetPersonID_ByAlias(patient_request->criteria[1].value,patient_request->criteria[1].type))
		if (validate(cov_person_alias))
			for (i=1 to cov_person_alias->cnt)
				set t_rec->cnt = i
				set stat = alterlist(t_rec->qual,t_rec->cnt)
				set t_rec->qual[t_rec->cnt].person_id = cov_person_alias->qual[i].person_id
				set t_rec->qual[t_rec->cnt].valid_ind = 1
			endfor
		endif
	else
		set stat = sSet_ErrorReply("First search parameter type invalid")
		go to exit_script
	endif
else
	set stat = sSet_ErrorReply("Invalid or Missing Request")
	go to exit_script
endif

if (t_rec->cnt > 0)
	;process other criteria for each patient
	for (j=2 to size(patient_request->criteria,5))
		for (i=1 to t_rec->cnt)
			if (t_rec->qual[i].valid_ind = 1)
				if (patient_request->criteria[j].type = "DOB")
					set t_rec->qual[i].valid_ind = sValidate_DOB(t_rec->qual[i].person_id,patient_request->criteria[j].value)
				endif
				if (patient_request->criteria[j].type = "SEX")
					set t_rec->qual[i].valid_ind = sValidate_Sex(t_rec->qual[i].person_id,patient_request->criteria[j].value)
				endif
			endif
		endfor		
	endfor
endif
    
call writeLog(build2("* END   Validating Alias   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

for (i=1 to t_rec->cnt)
	if (t_rec->qual[i].valid_ind = 1)
		set t_rec->pass_cnt += 1
		set stat = alterlist(t_rec->pass,t_rec->pass_cnt)
		set t_rec->pass[t_rec->pass_cnt].person_id = t_rec->qual[i].person_id
	endif
endfor	

if (t_rec->pass_cnt > 1)
	set stat = sSet_ErrorReply("Multiple patient matches for provided criteria")
	go to exit_script
elseif (t_rec->pass_cnt = 0)
	set stat = sSet_ErrorReply("No patients matching supplied criteria were found")
	set reply->status_data.status = "Z"
	go to exit_script
else
	set _MEMORY_REPLY_STRING = sGetPatientDemo(t_rec->pass[1].person_id,t_rec->pass[1].encntr_id)
	set reply->status_data.status = "S"
endif

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


#exit_script

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

if (reply->status_data != "S")
	set _MEMORY_REPLY_STRING = cnvtrectojson(reply)
endif

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))



;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)


call exitScript(null)
call echorecord(t_rec)
call echo(build2("_MEMORY_REPLY_STRING=",_MEMORY_REPLY_STRING))
;call echorecord(cov_patient_info)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
