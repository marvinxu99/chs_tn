/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_eso_resend_tool_prompts.prg
	Object name:		cov_eso_resend_tool_prompts
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

drop program cov_eso_resend_tool_prompts:dba go
create program cov_eso_resend_tool_prompts:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "ENCNTR_ID" = 0
	, "EVENT_ID" = 0 

with OUTDEV, ENCNTR_ID, EVENT_ID


call echo(build2("$ENCNTR_ID=",$ENCNTR_ID))

record t_rec
(
	1 prompts
	 2 outdev = vc
	 2 encntr_id = f8
	 2 event_id = f8
) with protect


set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.encntr_id = $ENCNTR_ID
set t_rec->prompts.event_id = $EVENT_ID

	
;Initialize variable to reference rows in the data set
declare RecNum = i4 with NoConstant(0),Protect

;Initialize variable to the number of people in the record structure list
;declare tcnt = i4 with NoConstant(size(discern_alerts->qual,5)),Protect
;Initialize variable to use in a for loop
declare lcnt = i4 with NoConstant(0),Protect

if (t_rec->prompts.event_id > 0.0)

	call echo("placeholder for if the event id is populated")

elseif (t_rec->prompts.encntr_id > 0.0)
	
	execute ccl_prompt_api_dataset "dataset"
	
	;Initialize the data set
	set stat = MakeDataSet(10)
	
	;Define fields in the data set
	set vEventID		= AddRealField("Event ID","Event ID", 1)
	set vServiceDate 	= AddStringField("ServiceDate","Service Date", 1, 255)
	set vEventCode 		= AddStringField("EventCode","Event Code", 1, 255)
	set vEventTitle 	= AddStringField("EventTitle","Event Title", 1, 255)
	set vEventStatus 	= AddStringField("EventStatus","Status", 1, 255)
	;set vAlertText	= AddStringField("AlertText", "Alert Text:", 1, 20)
	
	select into "nl:"
	from
		clinical_event ce
	plan ce
		where ce.encntr_id = t_rec->prompts.encntr_id
	    and   ce.event_class_cd in(value(uar_get_code_by("MEANING",53,"DOC")))
	    and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	order by
		ce.event_end_dt_tm
		,ce.event_id
	head report
	;Populate the data set
		lcnt = 0
	head ce.event_id
		/*Set RecNum equal to the next available row in the data set and add positions to the data set buffer if needed. */
		RecNum = GetNextRecord(0)
		/*Move information from the Person record structure into the data set */
		stat = SetRealField  (RecNum, vEventID, 	ce.event_id)
		stat = SetStringField(RecNum, vServiceDate,	format(ce.event_end_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d") )
		stat = SetStringField(RecNum, vEventCode,	uar_get_code_display(ce.event_cd))
		stat = SetStringField(RecNum, vEventTitle,	ce.event_title_text)
		stat = SetStringField(RecNum, vEventStatus,	uar_get_code_display(ce.result_status_cd))
		;set stat = SetStringField(RecNum, vAlertText, 	discern_alerts->qual[lcnt].ALERT_TEXT )
	with nocounter	
	    
	
	;Close the data set
	set stat = CloseDataSet(0)

elseif ((t_rec->prompts.encntr_id = 0.0) and (t_rec->prompts.event_id = 0.0))    
	
	call echo("placeholder if both prompts are empty")
	
endif


#exit_script

call echorecord(t_rec)

end
go
