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

drop program cov_remove_sch_lock:dba go
create program cov_remove_sch_lock:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Lock Type" = 0
	, "Scheduling Locks" = 0
	, "Person Level Locks" = 0 

with OUTDEV, LOCK_TYPE, LOCK_ID, OTHER_LOCK_ID


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
	 2 lock_type		= i2
	 2 other_lock_id 	= f8
	 2 sch_lock_id		= f8
	 2 updt_id			= f8
	 2 updt_username	= vc
	 2 updt_user		= vc
	1 files
	 2 records_attachment = vc
	1 cons
	 2 sch_lock_id	 	= f8
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
set t_rec->prompts.sch_lock_id = $LOCK_ID
set t_rec->prompts.other_lock_id = $OTHER_LOCK_ID
set t_rec->prompts.lock_type = $LOCK_TYPE

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

if (t_rec->prompts.lock_type = 0)			;Scheduling was selected
	if (t_rec->prompts.sch_lock_id <= 0.0)	;Missing Scheduling Lock Information
		set t_rec->errors.message = "A valid locked appointment was not selected.  Select a locked appointment from the provided list"
		go to exit_script
	else
		select 
		     p.username
		    ,sl.sch_lock_id
		    ,se.appt_synonym_free
		from 
		     sch_lock sl
		    ,prsnl p
		    ,sch_event se
		plan sl
		    where sl.sch_lock_id = t_rec->prompts.sch_lock_id
		join p
		    where p.person_id = sl.granted_prsnl_id
		join se
		    where se.sch_event_id = sl.parent_id
		detail
			t_rec->lock.appointment		= se.appt_synonym_free
			t_rec->lock.lock_dt_tm_vc	= format(sl.granted_dt_tm,";;q")
			t_rec->lock.user			= p.name_full_formatted
			t_rec->lock.username		= p.username
			
			t_rec->lock.message			= build2("The ",trim(t_rec->lock.appointment)," that was locked by ",
												 trim(t_rec->lock.user)," (",trim(t_rec->lock.username),") ",
												 "has been removed.")
		with nocounter
		
		if (curqual = 0)
			set t_rec->errors.message = build2( "The selected appointment is no longer locked or the lock "
											   ,"could not be found (",t_rec->prompts.sch_lock_id,")")
		endif	
	endif
elseif (t_rec->prompts.lock_type = 1)			;Person Level Locks
	if (t_rec->prompts.other_lock_id <= 0.0)	;Missing Person Level Lock Information
		set t_rec->errors.message = "A person level lock was not selected.  Select a locked patient element from the provided list"
		go to exit_script
	else
		select 
		    p.username
		    ,el.lock_seq_id
		    ,el.lock_dt_tm ";;q"
		    ,el.expire_dt_tm ";;q"
		    ,el.entity_name
		    ,el.locking_application_name
		    ,el.entity_id
		    ,p1.name_full_formatted
		from 
		    entity_lock el
		    ,prsnl p
		    ,person p1
		plan el
		    where el.entity_name != "LOCK KEY"
		    and   el.lock_seq_id = t_rec->prompts.other_lock_id
		    and   el.lock_dt_tm <= cnvtdatetime(curdate,curtime3)
		    and   el.expire_dt_tm >= cnvtdatetime(curdate,curtime3)
		join p
		    where p.person_id = el.lock_prsnl_id
		join p1
		    where p1.person_id =el.entity_id
		order by
		    p1.name_full_formatted
		detail
			t_rec->lock.entity_name		= el.entity_name
			t_rec->lock.locking_app		= el.locking_application_name
			t_rec->lock.lock_dt_tm_vc	= format(el.lock_dt_tm,";;q")
			t_rec->lock.user			= p.name_full_formatted
			t_rec->lock.username		= p.username
			
			t_rec->lock.message			= build2("The ",trim(t_rec->lock.entity_name)," that was locked by ",
												 trim(t_rec->lock.user)," (",trim(t_rec->lock.username),") ",
												 "has been removed.")
		with nocounter
		
		if (curqual = 0)
			set t_rec->errors.message = build2( "The selected person lock is no longer locked or the lock "
											   ,"could not be found (",t_rec->prompts.other_lock_id,")")
		endif
	endif
else
	set stat = 0
endif



call writeLog(build2("* END Validatating Input ***********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Removing Lock **************************************"))

if ((t_rec->prompts.lock_type = 0) and (t_rec->prompts.sch_lock_id > 0.0))
	delete from sch_lock where sch_lock_id = t_rec->prompts.sch_lock_id
	commit
elseif ((t_rec->prompts.lock_type = 1) and (t_rec->prompts.other_lock_id > 0.0))
	delete from entity_lock where lock_seq_id = t_rec->prompts.other_lock_id
	commit
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
