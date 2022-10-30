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
	 2 outdev = vc
	 2 encntr_id = f8
	 2 event_id = f8
) with protect


set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.encntr_id = $ENCNTR_ID
set t_rec->prompts.event_id = $EVENT_ID

set stat = cnvtjsontorec(sGetAllPatientDiscernAlert(t_rec->prompts.encntr_id)) 

if (validate(discern_alerts,0))
	call echorecord(discern_alerts)
endif
	
;Initialize variable to reference rows in the data set
declare RecNum = i4 with NoConstant(0),Protect

;Initialize variable to the number of people in the record structure list
declare tcnt = i4 with NoConstant(size(discern_alerts->qual,5)),Protect
;Initialize variable to use in a for loop
declare lcnt = i4 with NoConstant(0),Protect

if (t_rec->prompts.event_id > 0.0)

	for (lcnt = 1 to tcnt)	
		if (discern_alerts->qual[lcnt].event_id = t_rec->prompts.event_id)
			select into t_rec->prompts.outdev
			from
				dummyt d1
			plan d1
			head report
				col 0 "<html><body>"
				row +1
				col 0 "<font size=-1 family=arial>"
				row +1
				col 0 discern_alerts->qual[lcnt].alert_text
				row +1
				col 0 "</body></html>"
			with nocounter,maxcol=32000
		endif
	endfor

elseif (t_rec->prompts.encntr_id > 0.0)
	
	execute ccl_prompt_api_dataset "dataset"
	
	;Initialize the data set
	set stat = MakeDataSet(10)
	
	;Define fields in the data set
	set vEventID	= AddRealField("Event ID","Event ID:", 1)
	set vAlertType 	= AddStringField("AlertType","Alert Type:", 1, 25)
	;set vAlertText	= AddStringField("AlertText", "Alert Text:", 1, 20)
	
	;Populate the data set
	for (lcnt = 1 to tcnt)	
		/*Set RecNum equal to the next available row in the data set and add positions to the data set buffer if needed. */
		set RecNum = GetNextRecord(0)
		/*Move information from the Person record structure into the data set */
		set stat = SetRealField  (RecNum, vEventID, 	discern_alerts->qual[lcnt].EVENT_ID )
		set stat = SetStringField(RecNum, vAlertType,	discern_alerts->qual[lcnt].ALERT_TYPE )
		;set stat = SetStringField(RecNum, vAlertText, 	discern_alerts->qual[lcnt].ALERT_TEXT )
	endfor
	    
	
	;Close the data set
	set stat = CloseDataSet(0)

elseif ((t_rec->prompts.encntr_id = 0.0) and (t_rec->prompts.event_id = 0.0))    
	
	declare pAlertType = vc with noconstant("")
	
	set stat = cnvtjsontorec(sGetFullDTAInfo(sGetCovDiscernAlertMnemonic(null)))
	;call echorecord(dta_reply)
	
	free record temp_list
	record temp_list
	(
		1 cnt = i2
		1 qual[*]
		 2 mnemonic = vc
	)
	
	for (i=1 to size(dta_reply->dta,5))
		
		for (j=1 to size(dta_reply->dta[i].ref_range_factor,5))
			
			for (k=1 to size(dta_reply->dta[i].ref_range_factor[j].alpha_responses,5))
				
				set pAlertType = dta_reply->dta[i].ref_range_factor[j].alpha_responses[k].mnemonic
				call SubroutineLog(build2('pAlertType=',pAlertType))
				
				set temp_list->cnt += 1
				set stat = alterlist(temp_list->qual,temp_list->cnt)
				set temp_list->qual[temp_list->cnt].mnemonic = pAlertType
				
			endfor
		endfor
	endfor
	
	set tcnt = temp_list->cnt
	
	execute ccl_prompt_api_dataset "dataset"
	
	;Initialize the data set
	set stat = MakeDataSet(10)
	
	;Define fields in the data set
	set vAlertType 	= AddStringField("AlertType","Alert Type:", 1,25)
	
	for (lcnt = 1 to tcnt)
		set RecNum = GetNextRecord(0)
		set stat = SetStringField(RecNum, vAlertType, temp_list->qual[lcnt].mnemonic)
	endfor
	
	;Close the data set
	set stat = CloseDataSet(0)
	
endif


#exit_script

call echorecord(t_rec)

end
go
