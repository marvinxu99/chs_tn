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

declare EKSOPSREQUESTSrvRequest(dparam=i4) = i4 with copy, persist 
subroutine EKSOPSREQUESTSrvRequest(dparam)
 	
 	call SubroutineLog(build2(^start EKSOPSREQUESTSrvRequest(^,dparam,^)^))
 	
	if ( (Validate(recdate, "Y")="Y") and (Validate(recdate, "N")="N"))
		record recdate (
			1 datetime 	= dq8
		)
	endif
 
	declare	req = i4
	declare	hApp = i4
	declare	hTask = i4
	declare	hReq = i4
	declare	hReply = i4
	declare	CrmStatus = i4
	set eCrmOk = 0
	;set NULL = 0
 
 
	set req = 3091001
	set hApp = 0
	set app = 3055000
	set task = 4801
 
	set endApp = 0     ;001
	set endTask = 0    ;001
	set endReq = 0     ;001
 
	call echo(concat("curenv = ",build(curenv)))
 
	if (curenv = 0)   ; if interactive, use Expert Server as the Application.
	   execute srvrtl
	   execute crmrtl
	   execute cclseclogin
 	   set crmStatus = uar_crmbeginapp( app, hApp )
       call echo(concat("beginapp status = ",build(crmstatus)))
       if (hApp)          ;001
       	  set endApp = 1  ;001
       endif              ;001
    else  ;  If not interactive CCL, get current App handle
	   set hApp = uar_crmgetapphandle()
	endif
 
	if (hApp > 0)
		call echo("uar_crmbegintask")
		set crmStatus = uar_crmbegintask( hApp, task, hTask )
    	if (crmStatus != eCrmOk)
       		call echo("Invalid CrmBeginTask return status")
       		set retval = -1
       	else
 
;----------------------------------------
; Begin EKSOPSREQUEST REQUEST
;----------------------------------------
 
		 	set endTask = 1    ;001
		    set crmStatus = uar_CrmBeginReq(hTask, 0, req, hReq)
		    if (crmStatus != eCrmOk)
		       set retval = -1
		       call echo(concat("Invalid CrmBeginReq return status of ", build(crmStatus)))
		    elseif (hReq = NULL)
		    	set retval = -1
		        call echo("Invalid hReq handle")
		    else
		    	 set endReq = 1    ;001
		    	 set request_handle = hReq
 
		         set hEKSOPSRequest = uar_CrmGetRequest(hReq)
		         if (hEKSOPSRequest = NULL)
		            set retval = -1
		            call echo("Invalid request handle return from CrmGetRequest")
		         else
 					call echo("setting expert trigger level")
		        	set stat =  uar_SrvSetString(hEKSOPSRequest,
		                      "EXPERT_TRIGGER",
		                      NullTerm(EKSOPSRequest->EXPERT_TRIGGER))
 
 
;----------------------------------------
; Begin QUAL
;----------------------------------------
		            for (ndx1= 1 to Size(EKSOPSRequest->QUAL, 5))
 					  call echo("setting person level")
		               set hQUAL = uar_SrvAddItem(hEKSOPSRequest, "QUAL")
		               if (hQUAL = NULL) call echo("QUAL", "Invalid handle")
		               else
 
		                    set stat =  uar_SrvSetDouble(hQUAL,
		                              "PERSON_ID",
		                              EKSOPSRequest->QUAL[ndx1]
		                                            .PERSON_ID)
		            		set stat =  uar_SrvSetDouble(hQUAL,
		                              "SEX_CD",
		                              EKSOPSRequest->QUAL[ndx1]
		                                            .SEX_CD)
 
							set recdate->datetime = EKSOPSRequest->QUAL[ndx1].birth_dt_tm
		         			set stat =  uar_SrvSetDate2(hQUAL,
		                      			"BIRTH_DT_TM",
		                      			recdate)
 
		                   	set stat =  uar_SrvSetDouble(hQUAL,
		                              "ENCNTR_ID",
		                              EKSOPSRequest->QUAL[ndx1]
		                                            .ENCNTR_ID)
 
		                   	set stat =  uar_SrvSetDouble(hQUAL,
		                              "ACCESSION_ID",
		                              EKSOPSRequest->QUAL[ndx1]
		                                            .ACCESSION_ID)
 
		                   	set stat =  uar_SrvSetDouble(hQUAL,
		                              "ORDER_ID",
		                              EKSOPSRequest->QUAL[ndx1]
		                                            .ORDER_ID)
 
		                    for (ndx2= 1 to Size(EKSOPSRequest->QUAL[ndx1]->DATA, 5))
 								call echo("setting data level")
		               			set hDATA = uar_SrvAddItem(hQUAL, "DATA")
		               			if (hDATA = NULL) call echo("DATA", "Invalid handle")
		               			else
 
		                    		set stat =  uar_SrvSetString(hDATA,
		                    					"VC_VAR",
		                    					NullTerm(EKSOPSRequest->QUAL[ndx1]->DATA[ndx2]
		                    										.VC_VAR))
 
		                   			set stat =  uar_SrvSetDouble(hDATA,
		                              			"DOUBLE_VAR",
		                              			EKSOPSRequest->QUAL[ndx1]->DATA[ndx2]
		                                            		.DOUBLE_VAR)
 
		                   			set stat =  uar_SrvSetLong(hDATA,
		                              			"LONG_VAR",
		                              			EKSOPSRequest->QUAL[ndx1]->DATA[ndx2]
		                                            		.LONG_VAR)
 
		                   			set stat =  uar_SrvSetShort(hDATA,
		                              			"SHORT_VAR",
		                              			EKSOPSRequest->QUAL[ndx1]->DATA[ndx2]
		                                            		.SHORT_VAR)
		                        endif  /* hDATA */
							endfor /* hDATA */
							set retval = 100
		               endif /* hQUAL */
		            endfor /* hQUAL */
				endif /*hEKSOPSRequest*/
			endif  /*BeginReq*/
         endif   /*BeginTask*/
    endif /* hApp */
    if (crmStatus = eCrmOk)
       call Echo(ConCat("**** Begin perform request #", CnvtString(req),
            " -EKS Event @",
           format(CurDate, "dd-mmm-yyyy;;d"), " ",
           format(CurTime3, "hh:mm:ss.cc;3;m")))
       set crmStatus = uar_CrmPerform(hReq)
       call Echo(ConCat("**** End perform request #", CnvtString(req),
           " -EKS Event @",
           format(CurDate, "dd-mmm-yyyy;;d"), " ",
           format(CurTime3, "hh:mm:ss.cc;3;m")))
       if (crmStatus != eCrmOk)
          set retval = -1
          call echo("Invalid CrmPerform return status")
	   else
	      set retval = 100
	   	  call echo("CrmPerform was successful")
       endif
    else
       set retval = -1
       call Echo("CrmPerform not executed do to begin request error")
    endif
;001 Clean up CRM if necessary
	if (endReq)    ;001
	    call Echo("Ending CRM Request") ;001
	    call uar_CrmEndReq(hReq)        ;001
	endif          ;001
 
	if (endTask)   ;001
	    call Echo("Ending CRM Task")    ;001
	    call uar_CrmEndTask(hTask)       ;001
	endif          ;001
 
	if (endApp)   ;001
	    call Echo("Ending CRM App")    ;001
	    call uar_CrmEndApp(hApp)       ;001
	endif          ;001
 
  return(crmStatus)
end /* SrvRequest() */


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
		set vReturnValue = EKSOPSREQUESTSrvRequest(0)
	endif
	
	return (vReturnValue)
end

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
