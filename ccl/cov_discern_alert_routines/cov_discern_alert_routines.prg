/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_discern_alert_routines.prg
  Object name:        cov_discern_alert_routines
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
drop program cov_discern_alert_routines:dba go
create program cov_discern_alert_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))

execute cov_std_log_routines
execute cov_std_eks_routines
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Subroutines */
/**********************************************************************************************************************
** Function sAddCovDiscernAlert(vPersonID,vEncntrID,vOrderID,vAlertType,vAlertText)
** ---------------------------------------------------------------------------------------
** Create a new Message to be used in EKS. N=Name of Message. T=Text of Message
**********************************************************************************************************************/
declare sAddCovDiscernAlert(
								 vEncntrID=f8
								,vOrderID=f8(VALUE,0.0)
								,vAlertType=vc(VALUE,"")
								,vAlertText=vc(VALUE,"")) = f8 with copy, persist
subroutine  sAddCovDiscernAlert (vEncntrID,vOrderID,vAlertType,vAlertText )
	
	call SubroutineLog(build2('start sAddCovDiscernAlert(',vEncntrID,',',vAlertType,',',vAlertText,')'))	

	declare vRuleTrigger = vc with noconstant("")
	declare vAlertTypeFinal = vc with noconstant("")
	declare vAlertTextFinal = vc with noconstant("")
	
	declare vReturnSuccess = f8 with noconstant(FALSE)

	if ((vEncntrID > 0.0) and (vAlertType > "") and (vAlertText > ""))
									
		set stat = sPopulateEKSOPSRequest(vEncntrID,TRUE)
		set stat = sSetEKSOPSRequestTrigger("COV_EE_ADD_DISCERN_ALERT")
		set stat = sAddEKSOPSRequestData(sGetNomenIDforDTAReponse(sGetCovDiscernAlertMnemonic(null),vAlertType),0,0)
		set stat = sAddEKSOPSRequestData(vAlertType,0,0)
		
		set stat = sAddEKSOPSRequestData(vAlertText,0,1)
		
		set vReturnSuccess = sCallEKSOPSRequest(null)
		
	endif
	
	return (vReturnSuccess)
end


/**********************************************************************************************************************
** Function sGetCovDiscernAlert(vEncntrID,vOrderID,vAlertType,vPersonLevel)
** ---------------------------------------------------------------------------------------
** Create a new Message to be used in EKS. N=Name of Message. T=Text of Message
**********************************************************************************************************************/
declare sGetCovDiscernAlert(
								 vEncntrID=f8
								,vOrderID=f8(VALUE,0.0)
								,vAlertType=vc(VALUE,"")
								,vPersonLevel=i2(VALUE,0)) = vc with copy, persist
subroutine  sGetCovDiscernAlert (vEncntrID,vOrderID,vAlertType,vPersonLevel )
	
	call SubroutineLog(build2('start sGetCovDiscernAlert(',vEncntrID,',',vOrderID,',',vAlertType,',',vPersonLevel,')'))	
	
	declare vReturnComment = vc with noconstant("")
	declare vScopeParam = vc with noconstant("ce.encntr_id = vEncntrID")
	
	if (vPersonLevel = 1)
	    set vScopeParam = ""
	endif

	
	
	return (vReturnComment)
end




/**********************************************************************************************************************
** Function sGetAllCovDiscernAlert(vEncntrID,vOrderID,vAlertType,vPersonLevel)
** ---------------------------------------------------------------------------------------
** Create a new Message to be used in EKS. N=Name of Message. T=Text of Message
**********************************************************************************************************************/
declare sGetAllCovDiscernAlert(
								 vEncntrID=f8
								,vPersonLevel=i2(VALUE,0)) = vc with copy, persist
subroutine  sGetAllCovDiscernAlert (vEncntrID,vPersonLevel )
	
	call SubroutineLog(build2('start sGetAllCovDiscernAlert(',vEncntrID,',',vPersonLevel,')'))	
	
	declare vReturnAlerts = vc with noconstant("")
	declare vScopeParam = vc with noconstant("ce.encntr_id = vEncntrID")
	
	if (vPersonLevel = 1)
	    set vScopeParam = ""
	endif

	free record discern_alerts
	record discern_alerts
	(
		1 scope = c1
		1 cnt = i4
		1 qual[*]
		 2 alert_type = vc
		 2 alert_text = vc
		 2 event_id = f8
		 2 ce_event_note_id = f8
		 2 long_blob_id = f8
		 2 alert_dt_tm = dq8
	)
	
	return (vReturnAlerts)
end


/**********************************************************************************************************************
** Function sGetCovDiscernAlertCode(null)
** ---------------------------------------------------------------------------------------
** 
**********************************************************************************************************************/
declare sGetCovDiscernAlertCode(null) = f8 with copy, persist
subroutine  sGetCovDiscernAlertCode (null)
	
	call SubroutineLog(build2('start sGetCovDiscernAlertCode()'))	
	
	set stat = cnvtjsontorec(sGetFullDTAInfo(sGetCovDiscernAlertMnemonic(null)))
	call echorecord(dta_reply)
	declare vReturnCode = f8 with noconstant(0.0)
	
	if (validate(dta_reply,0))
	     set vReturnCode = dta_reply->dta[1].task_assay_cd
	endif
	
	return (vReturnCode)
end

/**********************************************************************************************************************
** Function sGetCovDiscernAlertMnemonic(null)
** ---------------------------------------------------------------------------------------
** 
**********************************************************************************************************************/
declare sGetCovDiscernAlertMnemonic(null) = vc with copy, persist
subroutine  sGetCovDiscernAlertMnemonic (null)
	
	call SubroutineLog(build2('start sGetCovDiscernAlertMnemonic()'))	
	
	declare vReturnMnemonic = vc with constant("D-Covenant Discern Alert")
	
	return (vReturnMnemonic)
end

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
