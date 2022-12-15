/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			Perioperative
	Source file name:	cov_remove_sch_lock.prg
	Object name:		cov_remove_sch_lock
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_remove_checkin:dba go
create program cov_remove_checkin:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	;<<hidden>>"FIN" = ""
	, "Select Active Check-in To Remove" = 0   ;* The selected Check-in event for the associated tracking group will be removed 

with OUTDEV, CHECKIN_ID


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

free set t_rec
record t_rec
(
	1 cnt				= i4
	1 prompts
	 2 outdev			= vc
	 2 checkin_id		= f8
	1 files
	 2 records_attachment = vc
	1 cons
	 2 checkin_id	 	= f8
	1 errors
	 2 message			= vc
	1 lock
	 2 username 		= vc
	 2 user				= vc
	 2 appointment		= vc
	 2 lock_dt_tm_vc	= vc
	 2 locking_app		= vc
	 2 entity_name		= vc
	 2 message			= vc
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.checkin_id = $CHECKIN_ID

set t_rec->prompts.updt_id = reqinfo->updt_id

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

select into "nl:"
from 
	prsnl p
plan p
	where p.person_id = t_rec->prompts.updt_id
detail
	t_rec->prompts.updt_user	 = p.name_full_formatted
	t_rec->prompts.updt_username = p.username
with nocounter

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Validatating Input *********************************"))

set t_rec->cons.checkin_id = t_rec->prompts.checkin_id

call writeLog(build2("* END Validatating Input ***********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Removing Lock **************************************"))

if (t_rec->cons.checkin_id > 0.0)
	update into tracking_checkin set active_ind = 0 where tracking_checkin_id = t_rec->cons.checkin_id
	commit
	set t_rec->lock.message = concat("Check-in Removed")
else
	set t_rec->errors.message = "No tracking check-in selected for removal"
endif


call writeLog(build2("* END   Removing Lock **************************************"))
call writeLog(build2("************************************************************"))


#exit_script

if (validate(t_rec))
	call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
	call addAttachment(program_log->files.file_path, replace(t_rec->files.records_attachment,"cclscratch:",""))
	execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"","MV"
endif

if (t_rec->errors.message > " ")
	select into t_rec->prompts.outdev
	from
		(dummyt with seq = 1)
	head report
		col 0 "ERROR: " t_rec->errors.message
	with nocounter,maxcol=2000
else
	select into t_rec->prompts.outdev
	from
		(dummyt with seq = 1)
	head report
		col 0 "SUCCESS: " t_rec->lock.message
	with nocounter, maxcol=2000
endif

call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go
