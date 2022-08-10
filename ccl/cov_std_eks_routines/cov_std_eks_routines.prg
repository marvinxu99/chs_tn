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


call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
