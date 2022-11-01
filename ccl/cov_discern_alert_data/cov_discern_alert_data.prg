/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:
	Solution:
	Source file name:	cov_discern_alert_data.prg
	Object name:		cov_discern_alert_data
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
 
drop program cov_discern_alert_data:dba go
create program cov_discern_alert_data:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "ENCNTR_ID" = 0
 
with OUTDEV, ENCNTR_ID
 
execute cov_discern_alert_routines
 
call echo(build2("$ENCNTR_ID=",$ENCNTR_ID))
 
record t_rec
(
	1 prompts
	 2 outdev = vc
	 2 encntr_id = f8
) with protect
 
 
set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.encntr_id = $ENCNTR_ID
 
set _memory_reply_string = sGetAllPatientDiscernAlert(t_rec->prompts.encntr_id)
 
 
#exit_script
 
call echorecord(t_rec)
 
end
go
