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
		set stat = sAddEKSOPSRequestData(sGetNomenIDforDTAReponse("D-Covenant Discern Alert",vAlertType),0,0)
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

	
	
	return (vReturnAlerts)
end
call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
