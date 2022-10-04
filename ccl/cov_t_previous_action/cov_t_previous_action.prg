/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           Perioperative
  Source file name:   cov_t_previous_action.prg
  Object name:        cov_t_previous_action
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			translated eks_t_previous_action
******************************************************************************/
drop program cov_t_previous_action:dba go
create program cov_t_previous_action:dba
 
%i cclsource:eks_tell_ekscommon.inc
 
;parameter ACTION_NAME, SCOPE, OPT_LINK, PERSONNEL, OPT_TIME_NUM, OPT_TIME_UNIT
 
declare tempStartTime = f8
set tempStartTime = curtime3
 
call echo(concat(format(curdate, "dd-mmm-yyyy;;d")," ", format(curtime3, "hh:mm:ss.cc;3;m"),
	"  *******    Beginning of Program EKS_T_PREVIOUS_ACTION     *********"),1,0)
 
declare PersonId = f8 with protect, noconstant(0.0)
declare EncntrId = f8 with protect, noconstant(0.0)
declare AccessionId = f8 with protect, noconstant(0.0)
declare OrderId = f8 with protect, noconstant(0.0)
 
set PersonId = event->qual[eks_common->event_repeat_index].person_id
set EncntrId = event->qual[eks_common->event_repeat_index].encntr_id
set AccessionId = event->qual[eks_common->event_repeat_index].accession_id
set OrderId = event->qual[eks_common->event_repeat_index].order_id
 
call echo(concat("Triggering by ", trim(tname)," in ", trim(eks_common->event_name), " EVENT with person_id - ",
	build(PersonId), ", and encntr_id - ", build(EncntrId)))
 
declare msg = vc
declare tmpMsg = vc with protect
 
call echo(concat(format(curdate, "dd-mmm-yyyy;;d")," ", format(curtime3, "hh:mm:ss.cc;3;m"),
	"... Checking existence and validity of template parameters ..."),1,0)
 
call echo("Parameter - ACTION_NAME")
record ACTION_NAMElist
(
	1 cnt = i4
	1 qual[*]
		2 value = vc
		2 display = vc
)
 
if (validate(ACTION_NAME, "Z") = "Z" and validate(ACTION_NAME, "Y") = "Y")
	set msg = "parameter ACTION_NAME does not exist."
	set retVal = -1
	go to EndProgram
else
	set orig_param = ACTION_NAME
	execute eks_t_parse_list with replace(reply, ACTION_NAMElist)
	free set orig_param
/*
	declare i = i4 with protect, noconstant(0)
	for (i = 1 to ACTION_NAMElist->cnt)
		if (trim(ACTION_NAMElist->qual[i].value) = "\0")
			set ACTION_NAMElist->qual[i].value = cnvtupper(trim(ACTION_NAMElist->qual[i].display))
		endif
	endfor
*/
endif ; end of validate(ACTION_NAME)
 
declare intScopeIndx = i2 with protect, noconstant(0)
call echo(concat("Parameter - SCOPE: ", build(SCOPE)))
if (validate(SCOPE, "Z") = "Z" and validate(SCOPE, "Y") = "Y")
	set msg = "parameter SCOPE does not exist."
	set retVal = -1
	go to EndProgram
else
	if (trim(cnvtlower(SCOPE)) in ("same person", "same encounter", "any person"))
		if (trim(cnvtlower(SCOPE)) = "same person")
			set intScopeIndx = 1
		elseif (trim(cnvtlower(SCOPE)) = "same encounter")
			set intScopeIndx = 2
		elseif (trim(cnvtlower(SCOPE)) = "any person")
			set intScopeIndx = 3
		endif
	else
		set msg = concat(trim(SCOPE), " is not a valid option")
		set retval = -1
		go to EndProgram
	endif ; end of cnvtlower
endif ; end of validate(ACTION_NAME)
 
declare bOptLinkInd = i2 with protect, noconstant(0)
declare intOptLinkIndx = i2 with protect, noconstant(0)
call echo(concat("Parameter - OPT_LINK: ", build(OPT_LINK)))
 
if (validate(OPT_LINK,"Z") = "Z" or validate(OPT_LINK,"Y") = "Y" )
	set msg = "OPT_LINK variable does not exist"
	set retval = -1
	go to EndProgram
else
	;check the link value is validate or not
	set intOptLinkIndx = cnvtint(OPT_LINK)
   	set num_logic_temps = size(eksdata->tqual[tinx].qual,5)
 
   	if (intOptLinkIndx < 0 or intOptLinkIndx > num_logic_temps or intOptLinkIndx = curindex)
		set msg = concat("OPT_LINK value of ",trim(OPT_LINK)," is invalid.")
		set retval = -1
		go to EndProgram
	else
		if (isnumeric(trim(OPT_LINK)) = 0)
			call echo("template is running without parameter OPT_LINK")
			set bOptLinkInd = 0
			if (intScopeIndx = 1 or intScopeIndx = 2)
				set msg = concat("OPT_LINK can not be empty because SCOPE is ", trim(SCOPE))
				set retval = -1
				go to EndProgram
			endif
		else
			set bOptLinkInd = 1
			;002 begin
			set PersonId = eksdata->tqual[tinx]->qual[intOptLinkIndx].person_id
			set EncntrId = eksdata->tqual[tinx]->qual[intOptLinkIndx].encntr_id
			set OrderId = eksdata->tqual[tinx]->qual[intOptLinkIndx].order_id
			set AccessionId = eksdata->tqual[tinx]->qual[intOptLinkIndx].accession_id
			;002 end
			if (intScopeIndx = 1)
				set PersonId = eksdata->tqual[tinx]->qual[intOptLinkIndx].person_id
			elseif (intScopeIndx = 2)
				set EncntrId = eksdata->tqual[tinx]->qual[intOptLinkIndx].encntr_id
			elseif (intScopeIndx = 3)
				set msg = concat("OPT_LINK should be empty because SCOPE is ", trim(SCOPE))
				set retval = -1
				go to EndProgram
			endif
		endif ; end of if (isnumeric(trim(OPT_LINK)) = 0)
	endif ; end of if (intOptLinkIndx < 0 or intOptLinkIndx > num_logic_temps or intOptLinkIndx = curindex)
endif ; end of validate(OPT_LINK)
 
;parameter - PERSONNEL, OPT_TIME_NUM, OPT_TIME_UNIT
declare intPersonnelIndx = i2 with protect, noconstant(0)
call echo(concat("Parameter - PERSONNEL: ", build(PERSONNEL)))
if (validate(PERSONNEL, "Z") = "Z" and validate(PERSONNEL, "Y") = "Y")
	set msg = "parameter PERSONNEL does not exist."
	set retVal = -1
	go to EndProgram
else
	if (trim(cnvtlower(PERSONNEL)) in ("current", "<default>", "any"))
		if (trim(cnvtlower(PERSONNEL)) in ("current", "<default>"))
			set intPersonnelIndx = 1
			set eks_discern_person_id = 0.00
			execute eks_t_get_discern_person_id
			set msg = ""
		elseif (trim(cnvtlower(PERSONNEL)) = "any")
			set intPersonnelIndx = 2
		endif
	else
		set msg = concat(trim(SCOPE), " is not a valid option")
		set retval = -1
		go to EndProgram
	endif ; end of cnvtlower
endif ; end of validate(ACTION_NAME)
 
declare douOptTimeNum = f8 with protect, noconstant(0.00)
declare bOptTimeNumInd = i2 with protect, noconstant(0)
call echo(concat("Parameter - OPT_TIME_NUM: ", build(OPT_TIME_NUM)))
if (validate(OPT_TIME_NUM,"Z") = "Z" and validate(OPT_TIME_NUM,"Y") = "Y" )
	set msg = "OPT_TIME_NUM variable does not exist"
	set retval = -1
	go to EndProgram
else
	if (size(trim(OPT_TIME_NUM), 1) = 0  or (trim(OPT_TIME_NUM) = "<undefined>")  )
		set bOptTimeNumInd = 0
	else
		if (isnumeric(OPT_TIME_NUM)= 0 )
			set msg = concat("Invalid entry of ",trim(OPT_TIME_NUM)," in OPT_TIME_NUM parameter. It's numeric")
			set retval = -1
			go to EndProgram
		else
			set bOptTimeNumInd = 1
			set douOptTimeNum = cnvtreal(trim(OPT_TIME_NUM,3))
			;set msg = concat(msg, " ", trim(OPT_TIME_NUM))
		endif
	endif ; end for checking OPT_TIME_NUM
endif ; end of validate OPT_TIME_NUM
 
call echo(concat("Parameter - OPT_TIME_UNIT: ", build(OPT_TIME_UNIT)))
declare bOptTimeUnitInd = i2 with protect, noconstant(0)
declare intOptTimeUnitIndx = i2 with protect, noconstant(0)
declare strPosInterval = vc with protect
declare strInterval = vc with protect
if (validate(OPT_TIME_UNIT,"Z") = "Z" and validate(OPT_TIME_UNIT,"Y") = "Y" )
	set msg = "OPT_TIME_UNIT variable does not exist"
	set retval = -1
	go to EndProgram
else
	if (size(trim(OPT_TIME_UNIT), 1) = 0  or (trim(OPT_TIME_UNIT) = "<undefined>")  )
		set bOptTimeUnitInd = 0
		if (bOptTimeNumInd > 0)
			set msg = "OPT_TIME_UNIT can not be empty because OPT_TIME_NUM is not empty"
			set retval = -1
			go to EndProgram
		endif
	else
		if (cnvtlower(trim(OPT_TIME_UNIT)) not in ("minutes", "hours", "days"))
			set msg = concat("Invalid entry of ",trim(OPT_TIME_UNIT)," in OPT_QAUL parameter.")
			set retval = -1
			go to EndProgram
		else
			set bOptTimeUnitInd = 1
			if (bOptTimeNumInd = 0)
				set msg = "OPT_TIME_UNIT should be empty because OPT_TIME_NUM is empty"
				set retval = -1
				go to EndProgram
			endif
 
			if (cnvtlower(trim(OPT_TIME_UNIT)) = "minutes")
				set intOptTimeUnitIndx = 1
				set strPosInterval = "MIN"
			elseif (cnvtlower(trim(OPT_TIME_UNIT)) = "hours")
				set intOptTimeUnitIndx = 2
				set strPosInterval = "H"
			else ; (cnvtlower(trim(OPT_TIME_UNIT)) = "days")
				set intOptTimeUnitIndx = 3
				set strPosInterval = "D"
			endif
			set strInterval = concat(trim(OPT_TIME_NUM,3), strPosInterval)
			;set msg = concat(msg, " ", trim(OPT_TIME_UNIT))
		endif  ; end for setting opt_time_unit_ind
	endif ; end for checking OPT_TIME_UNIT
endif ; end for validation of OPT_TIME_UNIT
 
 
declare cnt = i4 with protect, noconstant(0)
;intPersonnelIndx = 1 & 2
;intScopeIndx = 1 & 2 & 3
;bOptTimeNumInd = 0 & 1
declare num = i4 with protect, noconstant(0)
 
record recDlgEventId(
	1 cnt = i4
	1 qual[*]
		2 dlg_event_id = f8
		2 dlg_name = vc
		2 modify_dlg_name = vc
		2 dlg_dt_tm = dq8
		2 person_id = f8
		2 encntr_id = f8
		2 updt_id = f8
	)
 
declare d1seq = i4 with protect, noconstant(0)
 
call echo(concat("intPersonnelIndx: ", build(intPersonnelIndx), "  intScopeIndx: ", build(intScopeIndx),
	"  bOptTimeNumInd: ", build(bOptTimeNumInd)))
/*
declare tmpMsg = vc with protect
if (ACTION_NAMElist->cnt = 1)
	set tmpMsg = concat("If previous action of '", build(trim(ACTION_NAMElist->qual[1].value)), "' was executed for")
else
	set tmpMsg = "If previous action of ACTION_NAME was executed for"
endif
if (intScopeIndx = 1)
	set tmpMsg = concat(trim(tmpMsg), " same person as linked template ", build(trim(OPT_LINK)))
elseif (intScopeIndx = 2)
	set tmpMsg = concat(trim(tmpMsg), " same encounter as linked template ", build(trim(OPT_LINK)))
elseif (intScopeIndx = 3)
	set tmpMsg = concat(trim(tmpMsg), " any person")
endif
set tmpMsg = concat(trim(tmpMsg), " and initiated by")
if (intPersonnelIndx = 1)
	set tmpMsg = concat(trim(tmpMsg), " current")
elseif (intPersonnelIndx = 2)
	set tmpMsg = concat(trim(tmpMsg), " any")
endif
set tmpMsg = concat(trim(tmpMsg), " user")
if (bOptTimeNumInd = 1)
	set tmpMsg = concat(trim(tmpMsg), " in last ", build(trim(OPT_TIME_NUM)), " ", build(trim(OPT_TIME_UNIT)))
endif
*/
 
call echo(concat("---begin of statement - ", format(curdate, "dd-mmm-yyyy;;d")," ", format(curtime3, "hh:mm:ss.cc;3;m")))
;call echo(concat("searching to see... ", build(tmpMsg)))
 
declare tmpDateTime = vc with protect
set tmpDateTime = format(cnvtlookbehind(strInterval, cnvtdatetime(curdate, curtime3)), ";;q")
call echo(concat("check date time since: ", build(tmpDateTime), " to ",
	build(format(cnvtdatetime(curdate, curtime3), ";;q"))))
 
	select
	if (intPersonnelIndx = 1 and intScopeIndx = 1 and bOptTimeNumInd = 0)
		;(1)current user, same person, no time set up
		from eks_dlg_event ede, (dummyt d1 with seq = value(ACTION_NAMElist->cnt))
		plan d1 where initarray(d1seq, d1.seq)
		join ede where ede.active_ind = 1 and ede.person_id + 0 = PersonId
			and ede.dlg_prsnl_id = eks_discern_person_id
			and operator(ede.modify_dlg_name,"LIKE",trim(patstring(cnvtupper(ACTION_NAMElist->qual[d1seq].value), 1)))
	elseif (intPersonnelIndx = 1 and intScopeIndx = 1 and bOptTimeNumInd = 1)
		;(2)current user, same person, time set up
		from eks_dlg_event ede, (dummyt d1 with seq = value(ACTION_NAMElist->cnt))
		plan d1 where initarray(d1seq, d1.seq)
		join ede where ede.active_ind = 1 and ede.person_id = PersonId
			and ede.dlg_prsnl_id + 0 = eks_discern_person_id
			and operator(ede.modify_dlg_name,"LIKE",trim(patstring(cnvtupper(ACTION_NAMElist->qual[d1seq].value), 1)))
			and ede.dlg_dt_tm >= cnvtlookbehind(strInterval, cnvtdatetime(curdate, curtime3))
	elseif (intPersonnelIndx = 1 and intScopeIndx = 2 and bOptTimeNumInd = 0)
		;(3)current user, same encounter, no time set up
		from eks_dlg_event ede, (dummyt d1 with seq = value(ACTION_NAMElist->cnt))
		plan d1 where initarray(d1seq, d1.seq)
		join ede where ede.active_ind = 1 and ede.encntr_id = EncntrId
			and ede.dlg_prsnl_id + 0 = eks_discern_person_id
			and operator(ede.modify_dlg_name,"LIKE",trim(patstring(cnvtupper(ACTION_NAMElist->qual[d1seq].value), 1)))
	elseif (intPersonnelIndx = 1 and intScopeIndx = 2 and bOptTimeNumInd = 1)
		;(4)current user, same encounter, time set up
		from eks_dlg_event ede, (dummyt d1 with seq = value(ACTION_NAMElist->cnt))
		plan d1 where initarray(d1seq, d1.seq)
		join ede where ede.active_ind = 1 and ede.encntr_id = EncntrId
			and ede.dlg_prsnl_id + 0 = eks_discern_person_id
			and operator(ede.modify_dlg_name,"LIKE",trim(patstring(cnvtupper(ACTION_NAMElist->qual[d1seq].value), 1)))
			and ede.dlg_dt_tm >= cnvtlookbehind(strInterval, cnvtdatetime(curdate, curtime3))
	elseif (intPersonnelIndx = 1 and intScopeIndx = 3 and bOptTimeNumInd = 0)
		;(5)current user, any person, no time set up
		from eks_dlg_event ede, (dummyt d1 with seq = value(ACTION_NAMElist->cnt))
		plan d1 where initarray(d1seq, d1.seq)
		join ede where ede.active_ind = 1 and ede.dlg_prsnl_id = eks_discern_person_id
			and operator(ede.modify_dlg_name,"LIKE",trim(patstring(cnvtupper(ACTION_NAMElist->qual[d1seq].value), 1)))
	elseif (intPersonnelIndx = 1 and intScopeIndx = 3 and bOptTimeNumInd = 1)
		;(6)current user, any person, time set up
		from eks_dlg_event ede, (dummyt d1 with seq = value(ACTION_NAMElist->cnt))
		plan d1 where initarray(d1seq, d1.seq)
		join ede where ede.active_ind = 1 and ede.dlg_prsnl_id = eks_discern_person_id
			and operator(ede.modify_dlg_name,"LIKE",trim(patstring(cnvtupper(ACTION_NAMElist->qual[d1seq].value), 1)))
			and ede.dlg_dt_tm >= cnvtlookbehind(strInterval, cnvtdatetime(curdate, curtime3))
	elseif (intPersonnelIndx = 2 and intScopeIndx = 1 and bOptTimeNumInd = 0)
		;(7)any user, same person, no time set up
		from eks_dlg_event ede, (dummyt d1 with seq = value(ACTION_NAMElist->cnt))
		plan d1 where initarray(d1seq, d1.seq)
		join ede where ede.active_ind = 1 and ede.person_id = PersonId
			and operator(ede.modify_dlg_name,"LIKE",trim(patstring(cnvtupper(ACTION_NAMElist->qual[d1seq].value), 1)))
	elseif (intPersonnelIndx = 2 and intScopeIndx = 1 and bOptTimeNumInd = 1)
		;(8)any user, same person, time set up
		from eks_dlg_event ede, (dummyt d1 with seq = value(ACTION_NAMElist->cnt))
		plan d1 where initarray(d1seq, d1.seq)
		join ede where ede.active_ind = 1 and ede.person_id = PersonId
			and operator(ede.modify_dlg_name,"LIKE",trim(patstring(cnvtupper(ACTION_NAMElist->qual[d1seq].value), 1)))
			and ede.dlg_dt_tm >= cnvtlookbehind(strInterval, cnvtdatetime(curdate, curtime3))
	elseif (intPersonnelIndx = 2 and intScopeIndx = 2 and bOptTimeNumInd = 0)
		;(9)any user, same encounter, no time set up
		from eks_dlg_event ede, (dummyt d1 with seq = value(ACTION_NAMElist->cnt))
		plan d1 where initarray(d1seq, d1.seq)
		join ede where ede.active_ind = 1 and ede.encntr_id = EncntrId
			and operator(ede.modify_dlg_name,"LIKE",trim(patstring(cnvtupper(ACTION_NAMElist->qual[d1seq].value), 1)))
	elseif (intPersonnelIndx = 2 and intScopeIndx = 2 and bOptTimeNumInd = 1)
		;(10)any user, same encounter, time set up
		from eks_dlg_event ede, (dummyt d1 with seq = value(ACTION_NAMElist->cnt))
		plan d1 where initarray(d1seq, d1.seq)
		join ede where ede.active_ind = 1 and ede.encntr_id = EncntrId
			and operator(ede.modify_dlg_name,"LIKE",trim(patstring(cnvtupper(ACTION_NAMElist->qual[d1seq].value), 1)))
			and ede.dlg_dt_tm >= cnvtlookbehind(strInterval, cnvtdatetime(curdate, curtime3))
	elseif (intPersonnelIndx = 2 and intScopeIndx = 3 and bOptTimeNumInd = 0)
		;(11)any user, any person, no time set up
		from eks_dlg_event ede, (dummyt d1 with seq = value(ACTION_NAMElist->cnt))
		plan d1 where initarray(d1seq, d1.seq)
		join ede where ede.active_ind = 1
			and operator(ede.modify_dlg_name,"LIKE",trim(patstring(cnvtupper(ACTION_NAMElist->qual[d1seq].value), 1)))
	elseif (intPersonnelIndx = 2 and intScopeIndx = 3 and bOptTimeNumInd = 1)
		;(12)any user, any person, time set up
		from eks_dlg_event ede, (dummyt d1 with seq = value(ACTION_NAMElist->cnt))
		plan d1 where initarray(d1seq, d1.seq)
		join ede where ede.active_ind = 1
			and operator(ede.modify_dlg_name,"LIKE",trim(patstring(cnvtupper(ACTION_NAMElist->qual[d1seq].value), 1)))
			and ede.dlg_dt_tm >= cnvtlookbehind(strInterval, cnvtdatetime(curdate, curtime3))
	endif
	order by ede.dlg_dt_tm desc
	detail
		cnt = cnt + 1
		recDlgEventId->cnt = cnt
		stat = alterlist(recDlgEventId->qual, recDlgEventId->cnt)
		recDlgEventId->qual[cnt].dlg_event_id = ede.dlg_event_id
		recDlgEventId->qual[cnt].dlg_name = trim(ede.dlg_name)
		recDlgEventId->qual[cnt].modify_dlg_name = trim(ede.modify_dlg_name)
		recDlgEventId->qual[cnt].dlg_dt_tm = ede.dlg_dt_tm
		recDlgEventId->qual[cnt].person_id = ede.person_id
		recDlgEventId->qual[cnt].encntr_id = ede.encntr_id
		recDlgEventId->qual[cnt].updt_id = ede.dlg_prsnl_id
	with nocounter
 
;	call echorecord(recDlgEventId)
call echo(concat("---end of statement   - ",format(curdate, "dd-mmm-yyyy;;d")," ", format(curtime3, "hh:mm:ss.cc;3;m")))
 
if (recDlgEventId->cnt > 0)
 
	set Msg = concat(build(recDlgEventId->cnt), " qualifying actions found for '")
 
	set i = 0
	call echo(concat("  num   dlg_event_id      person_id      encntr_id   dlg_prsnl_id   ",
		"modify_dlg_name                  dlg_dt_tm"))
	call echo(concat("-----   ------------   ------------   ------------   ------------   ",
		"------------------------------   -----------------------"))
	for (i=1 to recDlgEventId->cnt)
		call echo(concat(format(i, "#####"), "   ",
			format(recDlgEventId->qual[i].dlg_event_id, "#########.##"), "   ",
			;format(recDlgEventId->qual[i].dlg_name, "##############################"), "     ",
			format(recDlgEventId->qual[i].person_id, "#########.##"), "   ",
			format(recDlgEventId->qual[i].encntr_id, "#########.##"), "   ",
			format(recDlgEventId->qual[i].updt_id, "#########.##"), "   ",
			format(recDlgEventId->qual[i].modify_dlg_name, "##############################"), "   ",
			format(recDlgEventId->qual[i].dlg_dt_tm, ";;q") ))
	endfor
 
	for (i=1 to recDlgEventId->cnt)
		if (i = 1)
			set tmpMsg = trim(recDlgEventId->qual[i].modify_dlg_name)
		else
			if ( (size(trim(tmpMsg)) + size(trim(recDlgEventId->qual[i].modify_dlg_name))) <= 45)
				set tmpMsg = concat(trim(tmpMsg), ", ", trim(recDlgEventId->qual[i].modify_dlg_name))
			else
				set tmpMsg = concat(trim(tmpMsg), "...'")
				set i = recDlgEventId->cnt + 1
			endif
		endif
		if (i = recDlgEventId->cnt)
			set tmpMsg = concat(trim(tmpMsg), "'")
		endif
	endfor
 
	if (bOptTimeNumInd = 1)
		set tmpMsg = concat(trim(tmpMsg), " since ", build(tmpDateTime))
	endif
 
 	set retval = 100
;	set msg = concat("*** Found ", trim(cnvtstring(recDlgEventId->cnt)),
;		" data in EKS_DLG_EVENT table that match sepciaifed criteria.")
else
 
	if (size(trim(Msg)) = 0)
 
		set Msg = "No qualifying actions found for '"
 
		for (i=1 to ACTION_NAMElist->cnt)
			if (i = 1)
				set tmpMsg = trim(ACTION_NAMElist->qual[i].value)
			else
				if ( (size(trim(tmpMsg)) + size(trim(ACTION_NAMElist->qual[i].value))) <= 45)
					set tmpMsg = concat(trim(tmpMsg), ", ", trim(ACTION_NAMElist->qual[i].value))
				else
					set tmpMsg = concat(trim(tmpMsg), "...'")
					SET i = ACTION_NAMElist->cnt + 1
				endif
			endif
			if (i = ACTION_NAMElist->cnt)
				set tmpMsg = concat(trim(tmpMsg), "'")
			endif
		endfor
 
		if (bOptTimeNumInd = 1)
			set tmpMsg = concat(trim(tmpMsg), " since ", build(tmpDateTime))
		endif
	endif
 
	set retval = 0
	;set msg = "No qualifying data found in EKS_DLG_EVENT table."
	go to EndProgram
endif
 
 
#EndProgram
 
set msg = concat(trim(msg), trim(tmpMsg), ". ", "(",
	trim(format(maxval(0,(curtime3-tempStartTime))/100.0, "######.##"),3), "s)")
 
call echo(msg)
 
if (tcurindex > 0 and curindex > 0)
   	set eksdata->tqual[tcurindex].qual[curindex].logging = msg
	set eksdata->tqual[tcurindex].qual[curindex].encntr_id = EncntrId
	set eksdata->tqual[tcurindex].qual[curindex].person_id = PersonId
	set eksdata->tqual[tcurindex].qual[curindex].accession_id = AccessionId
	set eksdata->tqual[tcurindex].qual[curindex].order_id = OrderId
%I CCLSOURCE:EKS_SET_EKSDATA.INC
endif
 
if (retval = -1)
	;set retval = 0
%I CCLSOURCE:EKS_SET_EKSDATA.INC
endif
 
call echo(concat(format(curdate, "dd-mmm-yyyy;;d")," ", format(curtime3, "hh:mm:ss.cc;3;m"),
          "  *********  End of Program EKS_T_PREVIOUS_ACTION ", "  *********"),1,0)
 
end
go
 