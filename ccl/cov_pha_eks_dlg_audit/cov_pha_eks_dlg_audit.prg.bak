/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				   Chad Cummings
	Date Written:		   03/01/2019
	Solution:			   
	Source file name:	   cov_pha_eks_dlg_audit.prg
	Object name:		   cov_pha_eks_dlg_audit
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	12/12/2019  Chad Cummings			Initial Release
001     02/05/2020  Chad Cummings			Removed "mCDS" alerts
******************************************************************************/
drop program cov_pha_eks_dlg_audit:dba go
create program cov_pha_eks_dlg_audit:dba
prompt
	"Output to File/Printer/MINE (MINE):" = "MINE"                            ;* Enter or select the printer or file name to send
	, "Begin Date, mmddyy (today):" = "CURDATE"                               ;* Enter the begin date for this report
	, "BeginTime, hhmm (0000):" = "0000"                                      ;* Enter the begin time for this report
	, "End Date, mmddyy (today):" = "CURDATE"                                 ;* Enter the end date for this report
	, "End Time, hhmm (2359):" = "2359"                                       ;* Enter the end time for this report
	, "Module Name, pattern match OK (*):" = "*"                              ;* Enter a module name to query by
	, "Output Type - (B)ackend CSV, (F)rontend CSV, or (R)eport (R):" = "R"   ;* Select an output type for this report
	, "Show (S)ummary or (D)etails (D):" = "D"                                ;* Select if the report should display a summary or
	, "Sort by (A)lert Recipient or (M)odule (M):" = "M"                      ;* Select the sort type for the report
 
with OUTPUTTYPE, BEGINDATE, BEGINTIME, ENDDATE, ENDTIME, MODULENAME, OUTTYPE,
	DETAILS, SORT
 
;003 begin
declare strMsg1 = vc
declare strMsg2 = vc
declare strMsg3 = vc
declare strMsg4 = vc
declare strMsg5 = vc
declare strMsg6 = vc
declare strMsg7 = vc
declare strMsg8 = vc
declare strMsg9 = vc
declare strMsg10 = vc
declare strMsg11 = vc
declare strMsg12 = vc
declare strMsg13 = vc
declare strMsg14 = vc
declare strMsg5_1 = vc
declare strMsg5_2 = vc
declare strMsg6_1 = vc
declare strMsg6_2 = vc
declare strMsg6_3 = vc
declare strMsg7_1 = vc
declare strMsg8_1 = vc
declare strMsg9_1 = vc
 
declare strMsgRange = vc
declare strMsgReportDtTm = vc
declare strMsgModuleName = vc
declare strMsgTrigger = vc
declare strMsgAlertDtTm = vc
declare strMsgPatient = vc
declare strMsgAlertRec = vc
declare strMsgLocation = vc
declare strMsgOverRide = vc
declare strMsgFreeTextOver = vc
declare strMsgSeverity = vc
declare strMsgIntDrug = vc
declare strMsgIntAllergy = vc
declare strMsgAlertRecUpper = vc
declare strMsgRecLocation = vc
declare strMsgModuleNameLow = vc
declare strMsgAllModules = vc
declare strMsgAllRecs = vc
declare strTriggerAction = vc
declare strMsgNone = vc
declare strMsgMessage = vc
declare strMsgCancel = vc
declare strMsgProceed = vc
declare strMsgModify = vc
declare strMsgAynch = vc
declare strMsgDC = vc	
 
%i cclsource:i18n_uar.inc
set i18nHandle = 0
set lRetVal = uar_i18nlocalizationinit(i18nHandle, curprog, "",curcclrev)
 
set strMsg1 = uar_i18nBuildMessage(i18nHandle, "KeyBuild1",
	"***  Expert Summary Audit for Module(s) %1 Sorted By Module Name ***", "s", $6)
set strMsg2 = uar_i18nBuildMessage(i18nHandle, "KeyBuild2",
	"***  Expert Detail Audit for Module(s) %1 Sorted By Module Name ***","s", $6)
set strMsg3 = uar_i18nBuildMessage(i18nHandle, "KeyBuild3",
	"***  Expert Summary Audit for Module(s) %1 Sorted By Alert Recipient ***","s", $6)
set strMsg4 = uar_i18nBuildMessage(i18nHandle, "KeyBuild4",
	"***  Expert Detail Audit for Module(s) %1 Sorted By Alert Recipient ***","s", $6)
 
set strMsg5_1 = uar_i18nGetMessage(i18nHandle, "KeyBuild5_1", "Trigger (")
set strMsg5_2 = uar_i18nGetMessage(i18nHandle, "KeyBuild5_2", ")")
set strMsg6_1 = uar_i18nGetMessage(i18nHandle, "KeyBuild6_1", "Total:  ")
set strMsg6_2 = uar_i18nGetMessage(i18nHandle, "KeyBuild6_2", " Alert(s)     ")
set strMsg6_3 = uar_i18nGetMessage(i18nHandle, "KeyBuild6_3", " Override(s)")
set strMsg7_1 = uar_i18nGetMessage(i18nHandle, "KeyBuild7_1", "Module (")
set strMsg8_1 = uar_i18nGetMessage(i18nHandle, "KeyBuild8_1", "Module Name (")
set strMsg9_1 = uar_i18nGetMessage(i18nHandle, "KeyBuild9_1", "Recipient (")
 
set strMsgRange = uar_i18nGetMessage(i18nHandle,        "KeyGet01", "Audit Date/Time Range:")
set strMsgReportDtTm = uar_i18nGetMessage(i18nHandle,   "KeyGet02", "Report Date/Time:")
set strMsgModuleName = uar_i18nGetMessage(i18nHandle,   "KeyGet03", "MODULE NAME")
set strMsgTrigger = uar_i18nGetMessage(i18nHandle,      "KeyGet04", "Trigger")
set strMsgAlertDtTm = uar_i18nGetMessage(i18nHandle,    "KeyGet05", "Alert Date/Time")
set strMsgPatient = uar_i18nGetMessage(i18nHandle,      "KeyGet06", "Patient")
set strMsgAlertRec = uar_i18nGetMessage(i18nHandle,     "KeyGet07", "Alert Recipient")
set strMsgLocation = uar_i18nGetMessage(i18nHandle,     "KeyGet08", "Location")
set strMsgOverRide = uar_i18nGetMessage(i18nHandle,     "KeyGet09", "Override Reason")
set strMsgFreeTextOver = uar_i18nGetMessage(i18nHandle, "KeyGet10", "*Freetext Override Reason")
set strMsgSeverity = uar_i18nGetMessage(i18nHandle,     "KeyGet11", "Severity")
set strMsgIntDrug = uar_i18nGetMessage(i18nHandle,      "KeyGet12", "Interacting Drug")
set strMsgIntAllergy = uar_i18nGetMessage(i18nHandle,   "KeyGet13", "Interacting Allergy")
set strMsgAlertRecUpper = uar_i18nGetMessage(i18nHandle,"KeyGet14", "ALERT RECIPIENT")
set strMsgRecLocation = uar_i18nGetMessage(i18nHandle,  "KeyGet15", "Recipient Position")
set strMsgModuleNameLow = uar_i18nGetMessage(i18nHandle,"KeyGet16", "Module Name")
set strMsgAllModules = uar_i18nGetMessage(i18nHandle,   "KeyGet17", "All Modules:")
set strMsgAllRecs = uar_i18nGetMessage(i18nHandle,      "KeyGet18", "All Recipients:")
set strMsgTriggerAction = uar_i18nGetMessage(i18nHandle,"KeyGet19", "Trigger Action")
set strMsgNone = uar_i18nGetMessage(i18nHandle,         "KeyGet20", "None")
set strMsgMessage = uar_i18nGetMessage(i18nHandle,      "KeyGet21", "Message")
set strMsgCancel = uar_i18nGetMessage(i18nHandle,       "KeyGet22", "Cancel")
set strMsgProceed = uar_i18nGetMessage(i18nHandle,      "KeyGet23", "Proceed")
set strMsgModify = uar_i18nGetMessage(i18nHandle,       "KeyGet24", "Modify")
set strMsgAynch = uar_i18nGetMessage(i18nHandle,        "KeyGet25", "Asynch")
set strMsgDC = uar_i18nGetMessage(i18nHandle,           "KeyGet26", " (D/C)")
;002 end
 
declare outFile = vc
declare startDt = vc
declare endDt   = vc
declare startTm = c4
declare endTm   = c4
declare moduleName = vc
;declare outputType = c1
declare parseString = vc
declare validString = vc
declare nxtChr = c1
declare asterisk = c1
declare asterPos = i4
declare underPos = i4
declare msg = vc
declare showDetails = c1
declare sortType = c1
;declare dlgName = vc
;declare recipient = vc
 
set asterisk = char(ichar("*"))
 
declare tmpCatDisp = vc ;005

;set outFile = $1
set moduleName = trim(cnvtupper($6))
set sortType = trim(cnvtupper($9))
 
; Validate startDt
set startDt = $2
if (trim(cnvtupper(startDt)) = "CURDATE")
	set startDt = format(curdate,"mmddyy;;d")
elseif (size(startDt) != 6 or not isnumeric(startDt))
	call echo("Start date must be in mmddyy format")
	go to EndProgram
elseif (cnvtint(substring(1,2,startDt)) > 12 or
	cnvtint(substring(1,2,startDt)) <= 0)
	call echo("Start month must be 01 through 12")
	go to EndProgram
elseif (cnvtint(substring(3,2,startDt)) > 31 or
	cnvtint(substring(3,2,startDt)) <= 0)
	call echo("Start day must be 01 through 31")
	go to EndProgram
endif
;call echo(concat("startDt = ",startDt))
 
; Validate StartTm
set startTm = $3
if (size(startTm) != 4 or not isnumeric(startTm))
	call echo("Start time must be in hhmm format")
	go to EndProgram
elseif (cnvtint(substring(1,2,startTm)) > 23)
	call echo("Start hour must be < 24")
	go to EndProgram
elseif (cnvtint(substring(3,2,startTm)) > 59)
	call echo("Start minute must be < 60")
	go to EndProgram
endif
;call echo(concat("startTm = ",startTm))
 
; Validate endDt
set endDt = $4
if (trim(cnvtupper(endDt)) = "CURDATE")
	set endDt = format(curdate,"mmddyy;;d")
elseif (size(endDt) != 6 or not isnumeric(endDt))
	call echo("End date must be in mmddyy format")
	go to EndProgram
elseif (cnvtint(substring(1,2,endDt)) > 12 or
	cnvtint(substring(1,2,endDt)) <= 0)
	call echo("End month must be 01 through 12")
	go to EndProgram
elseif (cnvtint(substring(3,2,endDt)) > 31 or
	cnvtint(substring(3,2,endDt)) <= 0)
	call echo("End day must be 01 through 31")
	go to EndProgram
endif
;call echo(concat("endDt = ",endDt))
 
; Validate endTm
set endTm = $5
if (size(endTm) != 4 or not isnumeric(endTm))
	call echo("End time must be in hhmm format")
	go to EndProgram
elseif (cnvtint(substring(1,2,endTm)) > 23)
	call echo("End hour must be < 24")
	go to EndProgram
elseif (cnvtint(substring(3,2,endTm)) > 59)
	call echo("End minute must be < 60")
	go to EndProgram
endif
;call echo(concat("endTm = ",endTm))
 
; Validate outType
;set outputType = substring(1,1,trim(cnvtupper($7)))
if ($outType not in ("R","B","F"))
	call echo("Output Type must be either 'R' or 'B' or 'F'")
	go to EndProgram
endif
 
; Validate showDetails
 
set showDetails = trim(cnvtupper($8))
if (showDetails not in ("D","S"))
	call echo("Show Details must be either 'D' or 'S'")
	go to EndProgram
endif
 
set startDtTm = cnvtdatetime(cnvtdate2(startDt,"MMDDYY"),cnvtint(startTm))
set endDtTm = cnvtdatetime(cnvtdate2(endDt,"MMDDYY"), cnvtint(endTm))
call echo(concat("startDtTm = ", format(startDtTm,";;q"), "  endDtTm = ", format(endDtTm,";;q")))
set asterPos = findstring(asterisk,moduleName)
set underPos = findstring("_", moduleName)
 
if (asterPos > 1)  ; Asterisk found but not in first position
	set moduleName = concat(asterisk,moduleName)
elseif (not asterPos)  ; No Asterisk found
	if (underPos)	; If underline found build the dlg_name
		set moduleName = concat(substring(1,underPos,moduleName),"EKM!",moduleName)
	else	; If no asterisk and no underline, see if it might be a multum dlg_name
		if(findstring("DRUG", moduleName))
			set moduleName = concat("MUL_MED!",moduleName)
		else  ;No asterisk and no underline, we don't know the prefix so use an asterisk
			set moduleName = concat(asterisk,moduleName)
		endif
	endif
endif
 
call echo(concat("dlg_name = ", moduleName))
 
%i cclsource:eks_eksdlgevent.inc
 
set eksdlg_input->module_name = moduleName
set eksdlg_input->start_dt_tm = startDtTm
set eksdlg_input->end_dt_tm = endDtTm
 
execute eks_get_dlg_event
call echo(concat("Number found = ", build(eksdlgevent->qual_cnt)))
 
if (eksdlgevent->qual_cnt)
	select into "nl:"
		;dlgName = trim(eksdlgevent->qual[d1.seq].dlg_name)
		;,dlgDtTm = eksdlgevent->qual[d1.seq].updt_dt_tm
		;,DtTm = eksdlgevent->qual[d1.seq].updt_dt_tm ";;q"
		;,attrName = eksdlgevent->qual[d1.seq]->attr[d2.seq].attr_name
		;,attrId = eksdlgevent->qual[d1.seq]->attr[d2.seq].attr_id
		;,srcString = n.source_string
	from
		(dummyt d1 with seq=eksdlgevent->qual_cnt)
		,(dummyt d2 with seq=eksdlgevent->qual[d1.seq].attr_cnt)
		,nomenclature n
	;plan d1 where MAXREC(d2, maxval(1,eksdlgevent->qual[d1.seq].attr_cnt))
	plan d1 where MAXREC(d2, eksdlgevent->qual[d1.seq].attr_cnt)
	join d2 where eksdlgevent->qual[d1.seq]->attr[d2.seq].attr_name = "NOMENCLATURE_ID"
		and eksdlgevent->qual[d1.seq]->attr[d2.seq].attr_id > 0
	join n where eksdlgevent->qual[d1.seq]->attr[d2.seq].attr_id = n.nomenclature_id
	detail
		;if (eksdlgevent->qual[d1.seq]->attr[d2.seq].attr_name = "NOMENCLATURE_ID")
		;	call echo(concat("Setting allergy of ", trim(n.source_string), " for position ", build(d1.seq),
		;	" attr number ", build(d2.seq)))
			eksdlgevent->qual[d1.seq].srcString = n.source_string
		;	call echo(concat("d1.seq = ",  build(d1.seq), "   d2.seq = ", build(d2.seq), "  srcString = ",
		;	eksdlgevent->qual[d1.seq].srcString))
		;elseif (eksdlgevent->qual[d1.seq]->attr[d2.seq].attr_name in ("CATALOG_CD","ORDER_CATALOG")
		;	and eksdlgevent->qual[d1.seq]->attr[d2.seq].attr_id > 0)
		;	eksdlgevent->qual[d1.seq].catDisp =
		;	uar_get_code_display(eksdlgevent->qual[d1.seq]->attr[d2.seq].attr_id)
		;	call echo(concat("Setting catDisp of ", eksdlgevent->qual[d1.seq].catDisp,
		;	" for position ", build(d1.seq)))
		;elseif(eksdlgevent->qual[d1.seq]->attr[d2.seq].attr_name = "SEVERITY*")
		;	eksdlgevent->qual[d1.seq].severity =
		;	eksdlgevent->qual[d1.seq]->attr[d2.seq].attr_value
		;	call echo(concat("Setting severity of ", eksdlgevent->qual[d1.seq].severity,
		;	" for position ", build(d1.seq)))
		;endif
	with nocounter
 
;endif
;go to EndProgram
 
	if ($outType in ("B", "F"))
		call echo(concat("Creating CSV for ", moduleName, " that fired between"))
		call echo(concat(format(startDtTm,";;q")," and ", format(endDtTm,";;q")))
		call echo(concat("Number found = ", build(eksdlgevent->qual_cnt), "  sortType = ", sortType))
 
		select
	        ; 001 added sortType
			if ($outType = "B" and sortType = "M")
				order dlgName, dlgDtTm, eksdlgevent->qual[d1.seq].encntr_id, eksdlgevent->qual[d1.seq].dlg_event_id,0
				;with format, pcformat('"',","), nocounter, separator=" "
				with format=stream, pcformat('"',",",1), nocounter ;002 , separator=" "
			elseif ($outType = "B" and sortType != "M")
				order recipient, dlgName, dlgDtTm, eksdlgevent->qual[d1.seq].encntr_id,
				eksdlgevent->qual[d1.seq].dlg_event_id,0
				with format=stream, pcformat('"',",",1), nocounter ;002 , separator=" "
			elseif ($outType != "B" and sortType = "M")
				order dlgName, dlgDtTm, eksdlgevent->qual[d1.seq].encntr_id, eksdlgevent->qual[d1.seq].dlg_event_id,0
				with format, nocounter, separator=" "
			else
				order recipient, dlgName, dlgDtTm, eksdlgevent->qual[d1.seq].encntr_id,
				eksdlgevent->qual[d1.seq].dlg_event_id,0
				with format, nocounter, separator=" "
			endif
		distinct
		into value($outputType)
			dlgDtTm = format(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm), "yyyy/mm/dd hh:mm:ss;;d"),
			trigger = trim(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id)),
			recipient = trim(p.name_full_formatted),
			dlgName = substring(1,255,eksdlgevent->qual[d1.seq].dlg_name),
			reason = trim(uar_get_code_display(eksdlgevent->qual[d1.seq].override_reason_cd)),
			facility = trim(uar_get_code_display(eh.loc_facility_cd)),
			building = trim(uar_get_code_display(eh.loc_building_cd)),
			nurseUnit = trim(uar_get_code_display(eh.loc_nurse_unit_cd)),
			room = trim(uar_get_code_display(eh.loc_room_cd)),
			bed = trim(uar_get_code_display(eh.loc_bed_cd))
			,ft_reason = if(lt.long_text_id > 0)
					;003 substring(1,75, lt.long_text)
					substring(1,55, lt.long_text) ;003
				else
					" "
				endif
			,allergy = substring(1,50,eksdlgevent->qual[d1.seq].srcString),
			interaction = trim(eksdlgevent->qual[d1.seq].catDisp),
			severity = eksdlgevent->qual[d1.seq].severity
			, recipientposn = trim(uar_get_code_display(p.position_cd))		;001
	 		, actionFlag = cnvtstring(eksdlgevent->qual[d1.seq].action_Flag) ;003
	 		, patientName = substring(1,30,pn.name_full_formatted) ;003
	 		, DCStatusInd = cnvtstring(eksdlgevent->qual[d1.seq].DCStatus_ind) ;005
		from
			(dummyt d1 with seq=eksdlgevent->qual_cnt)
			;001 ,person p
			,prsnl p		;001
			,person pn      ;003
			,encounter e
			,encntr_loc_hist eh
			,long_text lt
		plan d1
			where trim(uar_get_code_display(eksdlgevent->qual[d1.seq].override_reason_cd)) != "mCDS*"
		join lt where eksdlgevent->qual[d1.seq].long_text_id = lt.long_text_id
		join p where eksdlgevent->qual[d1.seq].dlg_prsnl_id = p.person_id
		join pn where eksdlgevent->qual[d1.seq].person_id = pn.person_id ;003
		join e  where eksdlgevent->qual[d1.seq].encntr_id = e.encntr_id
		join eh where outerjoin(e.encntr_id) = eh.encntr_id
			and outerjoin(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm)) > eh.beg_effective_dt_tm
			and outerjoin(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm)) < eh.end_effective_dt_tm
			;001 order dlgName, dlgDtTm, eksdlgevent->qual[d1.seq].encntr_id, eksdlgevent->qual[d1.seq].dlg_event_id,0
	else
		;go to EndProgram  ;kyh
		;003 set equalLine = fillstring(125, "=")
		set equalLine = fillstring(130, "=") ;003
		;003 set dashLine = fillstring(117, "-")
		set dashLine = fillstring(122, "-") ;003
		declare modName = vc
 
		if (sortType = "M")    ; Sort by ModuleName
			select into $1
				dlgDtTm = format(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm), "yyyy/mm/dd hh:mm:ss;;d"),
				Utrigger = trim(cnvtupper(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id))),
				trigger = trim(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id)),
				recipient = trim(p.name_full_formatted),
				dlgName = substring(1,255,eksdlgevent->qual[d1.seq].module_name),
				dlgEventId = eksdlgevent->qual[d1.seq].dlg_event_id,
				reason = trim(substring(1,30,uar_get_code_display(eksdlgevent->qual[d1.seq].override_reason_cd))),
				facility = trim(uar_get_code_display(eh.loc_facility_cd)),
				building = trim(uar_get_code_display(eh.loc_building_cd)),
				nurseUnit = trim(uar_get_code_display(eh.loc_nurse_unit_cd)),
				room = trim(uar_get_code_display(eh.loc_room_cd)),
				bed = trim(uar_get_code_display(eh.loc_bed_cd)),
				;003 ft_reason = substring(1,75, lt.long_text)
				ft_reason = substring(1,55, lt.long_text) ;003
				,allergy = eksdlgevent->qual[d1.seq].srcString,
				interaction = trim(eksdlgevent->qual[d1.seq].catDisp),
				severity = eksdlgevent->qual[d1.seq].severity
	 			,actionFlag = cnvtstring(eksdlgevent->qual[d1.seq].action_Flag) ;003
	 			,DCStatusInd = cnvtstring(eksdlgevent->qual[d1.seq].DCStatus_ind) ;005
			from
				(dummyt d1 with seq=eksdlgevent->qual_cnt)
				;001 ,person p
				,prsnl p		;001
				,person p2
				,encounter e
				,encntr_loc_hist eh
				,long_text lt
			plan d1
			join p where eksdlgevent->qual[d1.seq].dlg_prsnl_id = p.person_id
			join p2 where eksdlgevent->qual[d1.seq].person_id = p2.person_id
			join lt where eksdlgevent->qual[d1.seq].long_text_id = lt.long_text_id
			join e  where eksdlgevent->qual[d1.seq].encntr_id = e.encntr_id
			join eh where outerjoin(e.encntr_id) = eh.encntr_id
				and outerjoin(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm)) > eh.beg_effective_dt_tm
				and outerjoin(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm)) < eh.end_effective_dt_tm
			;order dlgName, dlgDtTm, eksdlgevent->qual[d1.seq].encntr_id, eksdlgevent->qual[d1.seq].dlg_event_id,0
			order dlgName, Utrigger, dlgDtTm, dlgEventId  ;eksdlgevent->qual[d1.seq].dlg_event_id
			head report
				totalAlerts = 0
				totalOverrides = 0
				row + 2
				if (showDetails = "S")
					;003 msg = concat("***  Expert Summary Audit for Module(s) ", $6,
					;003	" Sorted By Module Name ***")
					msg = strMsg1 ;003
				else
					;003 msg = concat("***  Expert Detail Audit for Module(s) ", $6,
					;003	" Sorted By Module Name ***")
					msg = strMsg2 ;003
				endif
				cc = 66 - (size(msg)/2)
				col cc, msg
 
				row + 2
				;003 col 9, "Audit Date/Time Range:"
				col 9, strMsgRange ;003
				;003 col 88, "Report Date/Time:"
				col 88, strMsgReportDtTm ;003
				row + 1
				col 11, startDtTm ";;q"
				msg = format(cnvtdatetime(curdate,curtime3), ";;q")
				col 90, msg
				row + 1
				col 13, endDtTm ";;q"
				row + 2
				col 1, equalLine
				row + 1
				;003 col 1, "MODULE NAME"
				col 1, strMsgModuleName ;003
				row + 1
				;003 col 9, "Trigger"
				col 9, strMsgTrigger ;003
				if (showDetails = "D")
					row + 1
					;003 col 13, "Alert Date/Time"
					col 13, strMsgAlertDtTm ;003
					;003 col 34, "Patient"
					col 34, strMsgPatient ;003
					;003 col 64, "Alert Recipient"
					col 64, strMsgAlertRec ;003
					;003 col 97, "Override Reason"
					col 97, strMsgOverRide ;003
					row + 1
					;col 20, "Patient Location (Registration Date/Time)"
					;003 col 20, "Location"
					;003 col 20, strMsgLocation ;003
					col 15, strMsgLocation ;003
					;003 col 55, "*Freetext Override Reason"
					col 55, strMsgFreeTextOver ;003
					col 115, strMsgTriggerAction ;003
					row + 1
				endif
				col 1, equalLine
			head dlgName
				row + 1
				;exclPtr = findstring("!",dlgName)
				;if (exclPtr)
				;	modName = substring(exclPtr+1, size(dlgName)-exclPtr, dlgName)
				;else
					modName = dlgName
				;endif
 
				col 1, modName
				if (modName = "DRUGDRUG")
					;003 col 70, "Severity"
					col 70, strMsgSeverity ;003
					;003 col 80, "Interacting Drug"
					col 80, strMsgIntDrug ;003
				elseif (modName = "DRUGALLERGY")
					col 70, "Severity"
					;003 col 80, "Interacting Allergy"
					col 80, strMsgIntAllergy ;003
				endif
				if (showDetails = "S")
					row + 1
					col 9, dashLine
				endif
				moduleCnt = 0
				moduleOver = 0
			head trigger
				if (showDetails = "D")
					row + 1
					col 9, trigger
				endif
				triggerCnt = 0
				triggerOver = 0
			head dlgEventId
			;detail
				triggerCnt = triggerCnt + 1
				;003 if (reason > " ")
				;if (trim(actionFlag) = "3") ;003
				;005 if ( (trim(actionFlag) = "3") or
				if ( (trim(actionFlag) = "3" and eksdlgevent->qual[d1.seq].DCStatus_ind = 0) or ;005
				     (trim(actionFlag) = "0" and ( textlen(trim(reason)) or textlen(trim(ft_reason)) )) ) ;003
					triggerOver = triggerOver + 1
				endif
				if (showDetails = "D")
					row + 1
					;col 1, dlgEventId "##########"
					col 13, dlgDtTm   ;eksdlgevent->qual[d1.seq].updt_dt_tm "dd-mmm-yyyy hh:mm:ss"
					;003 msg = substring(1,30,p2.name_full_formatted)
					msg = substring(1,29,p2.name_full_formatted) ;003
					col 34, msg
					;003 msg = substring(1,30,p.name_full_formatted)
					msg = substring(1,29,p.name_full_formatted) ;003
					col 64, msg
					if (trim(ft_reason) > " " and lt.long_text_id > 0)
						col 96, "*"
					endif
					col 97, reason
					row + 1
					msg = " "
					if (facility > " ")
						msg = trim(facility)
					endif
					if (building > " ")
						msg = concat(msg,"=>",trim(building))
					endif
					if (nurseUnit > " ")
						msg = concat(msg,"=>",trim(nurseUnit))
					endif
					if (room > " ")
						msg = concat(msg,"=>",trim(room))
					endif
					if (bed > " ")
						msg = concat(msg,"=>",trim(bed))
					endif
					msg = substring(1,55,msg) ;003
					;003 col 20, msg
					col 15, msg
				endif
			detail
				;row + 1
				;col 55, ed.dlg_event_id
				;col 75, ea.attr_id
				;row + 1
				msg = " "
				;call echo(concat("severity = ", trim(eksdlgevent->qual[d1.seq].severity)))
				;005 if (showDetails = "D" and modName in ("DRUGDRUG", "DRUGALLERGY"))
				if (showDetails = "D" and modName in ("DRUGDRUG", "DRUGALLERGY", "DRUGDUP","ALLERGYDRUG")) ;005
 
					if (trim(eksdlgevent->qual[d1.seq].catDisp) > " ")
						;003 msg = trim(substring(1,50,eksdlgevent->qual[d1.seq].catDisp))
						;003 begin
 
						;005 begin
						if (modName = "DRUGDUP")
							tmpCatDisp = eksdlgevent->qual[d1.seq].catDisp
							eksdlgevent->qual[d1.seq].catDisp = ""
						endif
						;005 end
 
						if (eksdlgevent->qual[d1.seq].DCStatus_ind)
							msg = concat(trim(substring(1,30,eksdlgevent->qual[d1.seq].catDisp)), strMsgDC)
						else
							msg = trim(substring(1,30,eksdlgevent->qual[d1.seq].catDisp))
						endif
 
						;005 begin
						if (modName = "DRUGDUP")
							eksdlgevent->qual[d1.seq].catDisp = tmpCatDisp
						endif
						;005 end
 
						;msg = trim(substring(1,35,eksdlgevent->qual[d1.seq].catDisp)) ;003
						;003 end
						col 80, msg
					elseif (trim(eksdlgevent->qual[d1.seq].srcString) > " ")
						;003 msg = trim(substring(1,50, eksdlgevent->qual[d1.seq].srcString))
						;003 begin
						if (eksdlgevent->qual[d1.seq].DCStatus_ind)
							msg = concat(trim(substring(1,30,eksdlgevent->qual[d1.seq].srcString)), strMsgDC)
						else
							msg = trim(substring(1,30,eksdlgevent->qual[d1.seq].srcString))
						endif
						;msg = trim(substring(1,35, eksdlgevent->qual[d1.seq].srcString)) ;003
						;003 end
						col 80, msg
					endif
 
					if (trim(eksdlgevent->qual[d1.seq].severity) > " ")  ;= "SEVERITY*")
						msg = trim(eksdlgevent->qual[d1.seq].severity)
						col 74, msg
						;call echo(concat("severity = ", msg))
					endif
				endif
				if (trim(ft_reason) > " " and lt.long_text_id > 0)
					row + 1
					;003 msg = substring(1,75,ft_reason)
					msg = substring(1,55,ft_reason) ;003
					col 55, "*"
					col 56, msg
				endif
 
				;003 begin
				if (showDetails = "D")
					msg = ""
					if (trim(actionFlag)="0")
						msg = strMsgNone
					elseif (trim(actionFlag)="1")
						msg = strMsgMessage
					elseif (trim(actionFlag)="2")
						msg = strMsgCancel
					elseif (trim(actionFlag)="3")
						msg = strMsgProceed
					elseif (trim(actionFlag)="4")
						msg = strMsgModify
					elseif (trim(actionFlag)="5")
						msg = strMsgAynch
					endif
					col 120, msg
				endif
				;003 end
 
			foot trigger
				row + 1
				if (showDetails = "D")
					col 9, dashLine
					row + 1
				endif
 
				;003 msg = concat("Trigger (", trim(trigger), ")")
				msg = concat(strMsg5_1, trim(trigger), strMsg5_2) ;003
				col 9, msg
				;003 msg = concat("Total:  ", format(triggerCnt,"#######"), " Alert(s)     ",
				;003	format(triggerOver,"#######"), " Override(s)")
				msg = concat(strMsg6_1, format(triggerCnt,"#######"), strMsg6_2, format(triggerOver,"#######"), strMsg6_3);003
				col 61, msg
				if (showDetails = "D")
					row + 1
					col 9, dashLine
				endif
				moduleCnt = moduleCnt + triggerCnt
				moduleOver = moduleOver + triggerOver
			foot dlgname
				if (showDetails = "S")
					row + 1
					col 9, dashLine
				endif
				row + 1
				;003 msg = concat("Module (", modName, ")")
				;004 msg = concat(strMsg7_1, trim(trigger), strMsg5_2) ;003
				msg = concat(strMsg7_1, trim(modName), strMsg5_2) ;004
				col 1, msg
				;003 msg = concat("Total:  ", format(moduleCnt,"#######"), " Alert(s)     ",
				;003 	format(moduleOver,"#######"), " Override(s)")
				msg = concat(strMsg6_1, format(moduleCnt,"#######"), strMsg6_2, format(moduleOver,"#######"),strMsg6_3) ;003
				col 61, msg
				row + 1
				col 1, equalLine
				totalAlerts = totalAlerts + moduleCnt
				totalOverrides = totalOverrides + moduleOver
			foot report
				row + 1
				col 1, equalLine
				row + 1
				;003 col 1, "All Modules:"
				col 1, strMsgAllModules ;003
				;003 msg = concat("Total:  ",format(totalAlerts,"#######"), " Alert(s)     ",
				;003 	format(totalOverrides,"#######"), " Override(s)")
				msg = concat(strMsg6_1,format(totalAlerts,"#######"),strMsg6_2,format(totalOverrides,"#######"),strMsg6_3);003
				col 61, msg
				row + 1
				col 1, equalLine
			with nocounter;, maxcol=1000
 
		else ;if (sortType = "A")    ; Sort by Recipient
 
			select into $1
				dlgDtTm = format(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm), "yyyy/mm/dd hh:mm:ss;;d"),
				Utrigger = trim(cnvtupper(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id))),
				trigger = trim(uar_get_code_display(eksdlgevent->qual[d1.seq].trigger_entity_id)),
				recipient = trim(p.name_full_formatted),
				dlgName = substring(1,255,eksdlgevent->qual[d1.seq].module_name),
				dlgEventId = eksdlgevent->qual[d1.seq].dlg_event_id,
				reason = trim(substring(1,30,uar_get_code_display(eksdlgevent->qual[d1.seq].override_reason_cd))),
				facility = trim(uar_get_code_display(eh.loc_facility_cd)),
				building = trim(uar_get_code_display(eh.loc_building_cd)),
				nurseUnit = trim(uar_get_code_display(eh.loc_nurse_unit_cd)),
				room = trim(uar_get_code_display(eh.loc_room_cd)),
				bed = trim(uar_get_code_display(eh.loc_bed_cd))
				;003 ,ft_reason = substring(1,75, lt.long_text)
				,ft_reason = substring(1,55, lt.long_text) ;003
				,allergy = eksdlgevent->qual[d1.seq].srcString,
				interaction = trim(eksdlgevent->qual[d1.seq].catDisp),
				severity = eksdlgevent->qual[d1.seq].severity
				, recipientposn = trim(uar_get_code_display(p.position_cd))		;001
	 			,actionFlag = cnvtstring(eksdlgevent->qual[d1.seq].action_Flag)  ;003
	 			,DCStatusInd = cnvtstring(eksdlgevent->qual[d1.seq].DCStatus_ind) ;005
			from
				(dummyt d1 with seq=eksdlgevent->qual_cnt)
				;001 ,person p
				,prsnl p		;001
				,person p2
				,encounter e
				,encntr_loc_hist eh
				,long_text lt
			plan d1
			join p where eksdlgevent->qual[d1.seq].dlg_prsnl_id = p.person_id
			join p2 where eksdlgevent->qual[d1.seq].person_id = p2.person_id
			join lt where eksdlgevent->qual[d1.seq].long_text_id = lt.long_text_id
			join e  where eksdlgevent->qual[d1.seq].encntr_id = e.encntr_id
			join eh where outerjoin(e.encntr_id) = eh.encntr_id
				and outerjoin(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm)) > eh.beg_effective_dt_tm
				and outerjoin(cnvtdatetime(eksdlgevent->qual[d1.seq].updt_dt_tm)) < eh.end_effective_dt_tm
			;order ed.dlg_prsnl_id, dlgName, Utrigger, dlgDtTm, ed.dlg_event_id
			order recipient, dlgName, Utrigger, dlgDtTm, dlgEventId
			head report
				totalAlerts = 0
				totalOverrides = 0
				row + 2
				if (showDetails = "S")
					;003 msg = concat("***  Expert Summary Audit for Module(s) ", $6,
					;003 	" Sorted By Alert Recipient ***")
					msg = strMsg3
				else
					;003 msg = concat("***  Expert Detail Audit for Module(s) ", $6,
					;003	" Sorted By Alert Recipient ***")
					msg = strMsg4
				endif
				cc = 66 - (size(msg)/2)
				col cc, msg
 
				row + 2
				;003 col 9, "Audit Date/Time Range:"
				col 9, strMsgRange ;003
				;003 col 88, "Report Date/Time:"
				col 88, strMsgReportDtTm
				row + 1
				col 11, startDtTm ";;q"
				msg = format(cnvtdatetime(curdate,curtime3), ";;q")
				col 90, msg
				row + 1
				col 13, endDtTm ";;q"
				row + 2
				col 1, equalLine
				row + 1
				;003 col 1, "ALERT RECIPIENT"
				col 1, strMsgAlertRecUpper ;003
				;003 col 64,"Recipient Position"		;001
				col 64,strMsgRecLocation ;003
				row + 1
				;003 col 9, "Module Name"
				col 9, strMsgModuleNameLow ;003
				if (showDetails = "D")
					row + 1
					;003 col 13, "Alert Date/Time"
					col 13, strMsgAlertDtTm ;003
					;003 col 34, "Patient"
					col 34, strMsgPatient ;003
					;col 64, "Trigger"
					col 64, strMsgTrigger ;003
					;003 col 97, "Override Reason"
					col 97, strMsgOverRide ;003
					row + 1
					;col 20, "Patient Location (Registration Date/Time)"
					;003 col 20, "Location"
					;003 col 20, strMsgLocation ;003
					col 15, strMsgLocation ;003
					;003 col 55, "*Freetext Override Reason"
					col 55, strMsgFreeTextOver ;003
					col 115, strMsgTriggerAction ;003
					row + 1
				endif
				col 1, equalLine
			head recipient;   dlg_prsnl_id;  recipient
				row + 1
				;msg = substring(1,30,p.name_full_formatted)
				msg = substring(1,30,recipient)
				col 1, msg
				col 64, recipientposn
				if (showDetails = "S")
					row + 1
					col 9, dashLine
				endif
				moduleCnt = 0
				moduleOver = 0
			head dlgName
				;exclPtr = findstring("!",dlgName)
				;if (exclPtr)
				;	modName = substring(exclPtr+1, size(dlgName)-exclPtr, dlgName)
				;else
					modName = dlgName
				;endif
				if (showDetails = "D")
					row + 1
					col 9, modName
 
					if (modName = "DRUGDRUG")
						;003 col 70, "Severity"
						col 70, strMsgSeverity ;003
						;003 col 80, "Interacting Drug"
						col 80, strMsgIntDrug ;003
					elseif (modName = "DRUGALLERGY")
						;003 col 70, "Severity"
						col 70, strMsgSeverity ;003
						;003 col 80, "Interacting Allergy"
						col 80, strMsgIntAllergy ;003
					endif
				endif
 
				triggerCnt = 0
				triggerOver = 0
			head dlgEventId
				triggerCnt = triggerCnt + 1
				;003 if (reason > " ")
				;if (trim(actionFlag = "3")) ;003
				;005 if ( (trim(actionFlag) = "3") or
				if ( (trim(actionFlag) = "3" and eksdlgevent->qual[d1.seq].DCStatus_ind = 0) or ;005
				     (trim(actionFlag) = "0" and ( textlen(trim(reason)) or textlen(trim(ft_reason)) )) ) ;003
 
					triggerOver = triggerOver + 1
				endif
				if (showDetails = "D")
					row + 1
					col 13, dlgDtTm   ;ed.dlg_dt_tm "dd-mmm-yyyy hh:mm:ss"
					;003 msg = substring(1,30,p2.name_full_formatted)
					msg = substring(1,29,p2.name_full_formatted) ;003
					;msg = concat("recipient=*",trim(substring(1,10,recipient)),"*")
					col 34, msg
					;msg = substring(1,30,p.name_full_formatted)
					;003 col 64, trigger
					col 64, trigger ;003
					;msg = concat("modName=*",modName,"*")
					if (trim(ft_reason) > " " and lt.long_text_id > 0)
						col 96, "*"
					endif
					col 97, reason
					row + 1
					msg = " "
					if (facility > " ")
						msg = trim(facility)
					endif
					if (building > " ")
						msg = concat(msg,"=>",trim(building))
					endif
					if (nurseUnit > " ")
						msg = concat(msg,"=>",trim(nurseUnit))
					endif
					if (room > " ")
						msg = concat(msg,"=>",trim(room))
					endif
					if (bed > " ")
						msg = concat(msg,"=>",trim(bed))
					endif
					msg = substring(1,55,msg) ;003
					;if (en.reg_dt_tm > 0)
					;	msg = concat(msg, " (", format(cnvtdatetime(en.reg_dt_tm), ";;q"), ")")
					;endif
					;003 col 20, msg
					col 15, msg ;003
				endif
			detail
				;row + 1
				;col 55, ed.dlg_event_id
				;col 75, ea.attr_id
				;row + 1
				;005 if (showDetails = "D" and modName in ("DRUGDRUG", "DRUGALLERGY"))
				if (showDetails = "D" and modName in ("DRUGDRUG", "DRUGALLERGY", "DRUGDUP","ALLERGYDRUG")) ;005
 
					if (trim(eksdlgevent->qual[d1.seq].catDisp) > " ")
						;003 msg = trim(substring(1,50,eksdlgevent->qual[d1.seq].catDisp))
 
						;005 begin
						if (modName = "DRUGDUP")
							tmpCatDisp = eksdlgevent->qual[d1.seq].catDisp
							eksdlgevent->qual[d1.seq].catDisp = ""
						endif
						;005 end
 
						;003 begin
						if (eksdlgevent->qual[d1.seq].DCStatus_ind)
							msg = concat(trim(substring(1,30,eksdlgevent->qual[d1.seq].catDisp)), strMsgDC)
						else
							msg = trim(substring(1,30,eksdlgevent->qual[d1.seq].catDisp))
						endif
 
						;005 begin
						if (modName = "DRUGDUP")
							eksdlgevent->qual[d1.seq].catDisp = tmpCatDisp
						endif
						;005 end
 
						;msg = trim(substring(1,35,eksdlgevent->qual[d1.seq].catDisp)) ;003
						;003 end
					   	col 80, msg
					elseif (trim(eksdlgevent->qual[d1.seq].srcString) > " ")
						;003 msg = trim(substring(1,50, eksdlgevent->qual[d1.seq].srcString))
						;003 begin
						if (eksdlgevent->qual[d1.seq].DCStatus_ind)
							msg = concat(trim(substring(1,30,eksdlgevent->qual[d1.seq].srcString)), strMsgDC)
						else
							msg = trim(substring(1,30,eksdlgevent->qual[d1.seq].srcString)) ;003
						endif
						;003 msg = trim(substring(1,35, eksdlgevent->qual[d1.seq].srcString)) ;003
						;003 end
					   	col 80, msg
					endif
 
					if (trim(eksdlgevent->qual[d1.seq].severity) > " ")  ;= "SEVERITY*")
						msg = trim(eksdlgevent->qual[d1.seq].severity)
						col 74, msg
						;call echo(concat("severity = ", msg))
					endif
				endif
 
				if (trim(ft_reason) > " " and lt.long_text_id > 0)
					row + 1
					;003 msg = substring(1,75,ft_reason)
					msg = substring(1,55,ft_reason) ;003
					col 55, "*"
					col 56, msg
				endif
 
 				;003 begin
				if (showDetails = "D")
					msg = ""
					if (trim(actionFlag)="0")
						msg = strMsgNone
					elseif (trim(actionFlag)="1")
						msg = strMsgMessage
					elseif (trim(actionFlag)="2")
						msg = strMsgCancel
					elseif (trim(actionFlag)="3")
						msg = strMsgProceed
					elseif (trim(actionFlag)="4")
						msg = strMsgModify
					elseif (trim(actionFlag)="5")
						msg = strMsgAynch
					endif
					col 120, msg
				endif
				;003 end
 
			foot dlgName
				row + 1
				if (showDetails = "D")
					col 9, dashLine
					row + 1
				endif
 
				row+1
				;003 msg = concat("Module Name (", trim(modName), ")")
				msg = concat(strMsg8_1, trim(modName),strMsg5_2) ;003
				col 9, msg
 
				;003 msg = concat("Total:  ", format(triggerCnt,"#######"), " Alert(s)     ",
				;003 	format(triggerOver,"#######"), " Override(s)")
				msg = concat(strMsg6_1, format(triggerCnt,"#######"), strMsg6_2, format(triggerOver,"#######"), strMsg6_3);003
				col 61, msg
 
				if (showDetails = "D")
					row + 1
					col 9, dashLine
				endif
				moduleCnt = moduleCnt + triggerCnt
				moduleOver = moduleOver + triggerOver
			foot recipient
				if (showDetails = "S")
					row + 1
					col 9, dashLine
				endif
				row + 1
 
				;003 msg = concat("Recipient (", trim(recipient), ")")
				msg = concat(strMsg9_1, trim(recipient), strMsg5_2) ;003
				col 1, msg
 
				;003 msg = concat("Total:  ", format(moduleCnt,"#######"), " Alert(s)     ",
				;003 	format(moduleOver,"#######"), " Override(s)")
				msg = concat(strMsg6_1,format(moduleCnt,"#######"),strMsg6_2,format(moduleOver,"#######"),strMsg6_3);003
				col 61, msg
 
				row + 1
				col 1, equalLine
				totalAlerts = totalAlerts + moduleCnt
				totalOverrides = totalOverrides + moduleOver
			foot report
				row + 1
				col 1, equalLine
				row + 1
				;003 col 1, "All Recipients:"
				col 1, strMsgAllRecs ;003
 
				;003 msg = concat("Total:  ",format(totalAlerts,"#######"), " Alert(s)     ",
				;003 	format(totalOverrides,"#######"), " Override(s)")
				msg = concat(strMsg6_1,format(totalAlerts,"#######"),strMsg6_2,format(totalOverrides,"#######"),strMsg6_3);003
				col 61, msg
				row + 1
				col 1, equalLine
			with nocounter
		endif
	endif
endif
#EndProgram
end go
