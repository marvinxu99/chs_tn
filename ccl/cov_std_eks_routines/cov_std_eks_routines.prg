/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_std_eks_routines.prg
  Object name:        cov_std_eks_routines
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Additional Required Scripts:
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   12/02/2021  Chad Cummings			initial build
******************************************************************************/
drop program cov_std_eks_routines:dba go
create program cov_std_eks_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))

execute cov_std_log_routines
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Subroutines */
/**********************************************************************************************************************
** Function SetBldMsg(N,T)
** ---------------------------------------------------------------------------------------
** Create a new Message to be used in EKS. N=Name of Message. T=Text of Message
**********************************************************************************************************************/
declare SetBldMsg ((n = vc ) ,(t = vc ) ) = i4 with copy, persist
subroutine  SetBldMsg (n ,t )
	call SubroutineLog(build2('start SetBldMsg(',n,',',t,')'))	
  	declare vReturnStatus = i2 with noconstant(FALSE), protect
  	declare dqbegin_date_time = dq8 with private ,constant (cnvtdatetime (curdate ,curtime3 ) )
  	set idx = getbldmsgindex (n )
  	if ((idx > 0 ) )
   		set eksdata->bldmsg[idx ].text = t
  	else
   		set eksdata->bldmsg_cnt = (eksdata->bldmsg_cnt + 1 )
   		set stat = alterlist (eksdata->bldmsg ,eksdata->bldmsg_cnt )
   		set eksdata->bldmsg[eksdata->bldmsg_cnt ].name = n
   		set eksdata->bldmsg[eksdata->bldmsg_cnt ].text = t
  	endif
  	
  	call SubroutineLog(build2('exit SetBldMsg(',n,',',t,')'
  						," Elapsed time in seconds:"
    					,datetimediff(cnvtdatetime(curdate,curtime3),dqbegin_date_time,5)
    					))
  	return (vReturnStatus)
end ;SetBldMsg																	

/**********************************************************************************************************************
** Function GetBldMsgIndex(N)
** ---------------------------------------------------------------------------------------
** Get the index number of the message name. N=Name of Message
**********************************************************************************************************************/
declare GetBldMsgIndex ((n = vc )) = i4 with copy, persist
subroutine  GetBldMsgIndex (n )
	call SubroutineLog(build2('start GetBldMsgIndex(',n,')'))	
  	
  	declare dqbegin_date_time = dq8 with private ,constant (cnvtdatetime (curdate ,curtime3 ) )
  	declare ndx = i4 with private ,noconstant (0 )
  	set idx = locateval (ndx ,1 ,eksdata->bldmsg_cnt ,n ,eksdata->bldmsg[ndx ].name )
  	
	call SubroutineLog(build2('exit GetBldMsgIndex(',n,')'
  						," Elapsed time in seconds:"
    					,datetimediff(cnvtdatetime(curdate,curtime3),dqbegin_date_time,5)
    					))
  	return (idx )
end ;GetBldMsgIndex



/**********************************************************************************************************************
** Function GetBldMsgText(N)
** ---------------------------------------------------------------------------------------
** Returns the of the message name. N=Name of Message
**********************************************************************************************************************/
declare GetBldMsgText ((n = vc ) ) = vc with copy, persist
subroutine  GetBldMsgText (n )

 	call SubroutineLog(build2('start GetBldMsgText(',n,')'))
 	
	declare dqbegin_date_time = dq8 with private ,constant (cnvtdatetime (curdate ,curtime3 ) )
	declare ndx = i4 with private ,noconstant (0 )
	declare msg_text = vc with private
 
	set idx = locateval (ndx ,1 ,eksdata->bldmsg_cnt ,n ,eksdata->bldmsg[ndx ].name )
 
	IF (idx > 0)
		set msg_text = eksdata->bldmsg[idx ].text
		call SubroutineLog(build2("text:",msg_text))
	else
		call SubroutineLog(build2("idx:",idx))
	endif

	call SubroutineLog(build2('exit GetBldMsgText(',n,')'
  						," Elapsed time in seconds:"
    					,datetimediff(cnvtdatetime(curdate,curtime3),dqbegin_date_time,5)
    					)) 
	return (msg_text )
end ;Subroutine

/**********************************************************************************************************************
** Function Setup EKSOPSRequest
** ---------------------------------------------------------------------------------------
** Pull in standard EKSOPSRequest requests and routines
**********************************************************************************************************************/
declare sCreateEKSOPSRequest(null) = i4 with copy, persist
subroutine  sCreateEKSOPSRequest(null)
	record EKSOPSRequest (
	   1 expert_trigger	= vc
	   1 qual[*]
		2 person_id	= f8
		2 sex_cd	= f8
		2 birth_dt_tm	= dq8
		2 encntr_id	= f8
		2 accession_id	= f8
		2 order_id	= f8
		2 data[*]
		     3 vc_var		= vc
		     3 double_var	= f8
		     3 long_var		= i4
		     3 short_var	= i2
	) with persistscript

	if (not(validate(EKSOPSRequest,0)))
		return(FALSE)
	endif

	return(TRUE)

end

/**********************************************************************************************************************
** Function Setup sPopulateEKSOPSRequest
** ---------------------------------------------------------------------------------------
** Pull in standard fields for EKSOPSRequest
**********************************************************************************************************************/
declare sPopulateEKSOPSRequest(vEncntrID=f8,vReset=i4(VALUE,0)) = i4 with copy, persist
subroutine  sPopulateEKSOPSRequest (vEncntrID,vReset)

	if (not(validate(EKSOPSRequest,0)))
		set stat = sCreateEKSOPSRequest(null)
	endif

	if (vReset = 1)
		set stat = initrec(EKSOPSRequest)
	endif
	
	declare vReturnValue = i4 with noconstant(0)
	
	select into "NL:"
		e.encntr_id,
		e.person_id,
		e.reg_dt_tm,
		p.birth_dt_tm,
		p.sex_cd
	from
		person p,
		encounter e
	plan e where e.encntr_id = vEncntrID
	join p where p.person_id= e.person_id
	head report
		cnt = size(EKSOPSRequest->qual,5)
	detail
		cnt = cnt +1
		stat = alterlist(EKSOPSRequest->qual, cnt)
		EKSOPSRequest->qual[cnt].person_id = p.person_id
		EKSOPSRequest->qual[cnt].sex_cd  = p.sex_cd
		EKSOPSRequest->qual[cnt].birth_dt_tm  = p.birth_dt_tm
		EKSOPSRequest->qual[cnt].encntr_id  = e.encntr_id
	foot report
		vReturnValue = cnt
	with nocounter
	
	return (vReturnValue)
end

/**********************************************************************************************************************
** Function Setup sAddEKSOPSRequestData
** ---------------------------------------------------------------------------------------
** Add in data[*] fields for EKSOPSRequest
**********************************************************************************************************************/
declare sAddEKSOPSRequestData(vValue=vc,vPosition=i4(VALUE,0),vNewDataElement=i2(VALUE,0)) = i4 with copy, persist
subroutine  sAddEKSOPSRequestData (vValue,vPosition,vNewDataElement)
	
	call SubroutineLog(build2(^start sAddEKSOPSRequestData(^,vValue,^,^,vPosition,^,^,vNewDataElement,^)^))
	
	declare vReturnValue = i4 with noconstant(FALSE)
	
	declare vCurPos = i4 with noconstant(0)
	declare vCurDataPos = i4 with noconstant(0)
	declare vCurDataType = vc with noconstant("")
	
	if (not(validate(EKSOPSRequest,0)))
		return (vReturnValue)
	endif
	
	if (vPosition = 0)
		set vCurPos = size(EKSOPSRequest->qual,5)
	else
		set vCurPos = vPosition
	endif
	
	call SubroutineLog(build2(^vCurPos=^,vCurPos))
	
	if (vCurPos = 0)
		return (vReturnValue)
	else
		set vCurDataPos = size(EKSOPSRequest->qual[vCurPos].data,5)
		call SubroutineLog(build2(^vCurDataPos=^,vCurDataPos))
		
		if ((vNewDataElement = 1) or (vCurDataPos = 0))
			set vCurDataPos += 1 
			set stat = alterlist(EKSOPSRequest->qual[vCurPos].data,vCurDataPos)
		endif
	endif
	
	if (isnumeric(vValue) = 0)
		set vCurDataType = "vc"
	elseif (isnumeric(vValue) = 1)
		if (cnvtint(vValue) between -32767 and 32767)
			set vCurDataType = "i2"
		else
			set vCurDataType = "i4"
		endif
	elseif (isnumeric(vValue) = 2)
		set vCurDataType = "f8"
	endif
	
	case (vCurDataType)
	 of "vc":	set EKSOPSRequest->qual[vCurPos].data[vCurDataPos].vc_var = vValue
	 of "i4":	set EKSOPSRequest->qual[vCurPos].data[vCurDataPos].long_var = cnvtint(vValue)
	 of "i2":	set EKSOPSRequest->qual[vCurPos].data[vCurDataPos].short_var = cnvtint(vValue)
	 of "f8":	set EKSOPSRequest->qual[vCurPos].data[vCurDataPos].double_var = cnvtreal(vValue)
	endcase
	
	set vReturnValue = TRUE
	
	return (vReturnValue)
end


/**********************************************************************************************************************
** Function Setup sSetEKSOPSRequestTrigger
** ---------------------------------------------------------------------------------------
** Set the Trigger for EKSOPSRequest
**********************************************************************************************************************/
declare sSetEKSOPSRequestTrigger(vValue=vc) = i4 with copy, persist
subroutine  sSetEKSOPSRequestTrigger(vValue)
	
	call SubroutineLog(build2(^start sSetEKSOPSRequestTrigger(^,vValue,^)^))
	
	declare vReturnValue = i4 with noconstant(FALSE)

	
	if (not(validate(EKSOPSRequest,0)))
		return (vReturnValue)
	else
		set EKSOPSRequest->expert_trigger = vValue
		set vReturnValue = TRUE
	endif
	
	return (vReturnValue)
end


/**********************************************************************************************************************
** Function Setup sCallEKSOPSRequest
** ---------------------------------------------------------------------------------------
** Call the Request for EKSOPSRequest
**********************************************************************************************************************/
declare sCallEKSOPSRequest(null) = i4 with copy, persist
subroutine  sCallEKSOPSRequest(null)
	
	call SubroutineLog(build2(^start sCallEKSOPSRequest()^))
	
	declare vReturnValue = i4 with noconstant(FALSE)
	
	if (not(validate(EKSOPSRequest,0)))
		return (vReturnValue)
	else
		free record EKSOPSReply
		set stat = tdbexecute(3055000,4801,3091001,"REC",EKSOPSRequest,"REC",EKSOPSReply) 
		
		if (validate(EKSOPSReply,0))
		     if (EKSOPSReply->status_data.status = "S")
		          set vReturnValue = TRUE
		     endif
		endif
		
	endif
	
	return (vReturnValue)
end

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
