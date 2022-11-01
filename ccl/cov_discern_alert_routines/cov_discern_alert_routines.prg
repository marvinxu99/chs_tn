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
	
		set vRuleTrigger = "COV_EE_ADD_DISCERN_ALERT"
		
		set vFreeTextParam = concat(
										^"<P>VALUE1=306356034.0<6>Patient Custody"^
										;vAlertType
										;,"@@@"
										;,vAlertText
									)
									
		set stat = sPopulateEKSOPSRequest(vEncntrID,1)
		set stat = sSetEKSOPSRequestTrigger(vRuleTrigger)
		set stat = sAddEKSOPSRequestData(sGetNomenIDforDTAReponse("D-Covenant Discern Alert",vAlertType))
		set stat = sCallEKSOPSRequest(null)
		
		call echorecord(EKSOPSRequest)
		
		set vReturnSuccess = TRUE
	endif
	
	return (vReturnSuccess)
end

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
