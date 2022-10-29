/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_discern_alert_manager.prg
	Object name:		cov_discern_alert_manager
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

drop program cov_discern_alert_prompts:dba go
create program cov_discern_alert_prompts:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "ENCNTR_ID" = 0
	, "EVENT_ID" = 0 

with OUTDEV, ENCNTR_ID, EVENT_ID

execute cov_discern_alert_routines

call echo(build2("$ENCNTR_ID=",$ENCNTR_ID))

record t_rec
(
	1 prompts
	 2 encntr_id = f8
	 2 event_id = f8
) with protect

set t_rec->prompts.encntr_id = $ENCNTR_ID
set t_rec->prompts.event_id = $EVENT_ID

set stat = cnvtjsontorec(sGetAllPatientDiscernAlert(t_rec->prompts.encntr_id)) 

if (validate(discern_alerts,0))
	call echorecord(discern_alerts)
endif

#exit_script

call echorecord(t_rec)

end
go
