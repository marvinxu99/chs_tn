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
** Function sGetAllPatientDiscernAlert(vEncntrID,vOrderID,vAlertType,vPersonLevel)
** ---------------------------------------------------------------------------------------
** Create a new Message to be used in EKS. N=Name of Message. T=Text of Message
**********************************************************************************************************************/
declare sGetAllPatientDiscernAlert(
								 vEncntrID=f8
								,vPersonLevel=i2(VALUE,0)) = vc with copy, persist
subroutine  sGetAllPatientDiscernAlert (vEncntrID,vPersonLevel )
	
	call SubroutineLog(build2('start sGetAllCovDiscernAlert(',vEncntrID,',',vPersonLevel,')'))	
	
	declare vReturnAlerts = vc with noconstant("")
	declare vScopeParam = vc with noconstant("ce.encntr_id = e.encntr_id")
	declare vCovAlertEC = f8 with constant(sGetCovDiscernAlertCode(null))
	
	declare OCFCOMP_VAR = f8 with Constant(uar_get_code_by("MEANING",120,"OCFCOMP")),protect
    declare NOCOMP_VAR = f8 with Constant(uar_get_code_by("MEANING",120,"NOCOMP")),protect
    declare BlobOut = vc
    declare BlobNoRTF =  vc
    declare bsize = i4
	
	if (vPersonLevel = 1)
	    set vScopeParam = "1=1"
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
	
	select into "nl:"
	from
	     person p
	     ,encounter e
	     ,clinical_event ce
	     ,ce_coded_result ccr
	     ,ce_event_note cen
	     ,long_blob lb
	plan e 
	     where e.encntr_id = vEncntrID
	join p
	     where p.person_id = e.person_id
	join ce
	     where ce.person_id = p.person_id
	     and parser(vScopeParam)
	     and   ce.event_cd = vCovAlertEC
	     and   ce.valid_from_dt_tm <= cnvtdatetime(sysdate)
	     and   ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
	     and   ce.result_status_cd in(value(uar_get_code_by("MEANING",8,"AUTH")))
	join ccr
	     where ccr.event_id = ce.event_id
	     and   ccr.valid_from_dt_tm <= cnvtdatetime(sysdate)
	     and   ccr.valid_until_dt_tm >= cnvtdatetime(sysdate)
	join cen
	     where cen.event_id = ce.event_id	     
	     and   cen.valid_from_dt_tm <= cnvtdatetime(sysdate)
	     and   cen.valid_until_dt_tm >= cnvtdatetime(sysdate)	     
	join lb
	     where lb.parent_entity_id = cen.ce_event_note_id
	     and   lb.parent_entity_name = "CE_EVENT_NOTE"
	order by
	      ce.event_end_dt_tm desc
	     ,ce.event_id
	head report
	     i = 0
	     if (vPersonLevel = 1)
	          discern_alerts->scope = "P"
	     else
	          discern_alerts->scope = "E"
	     endif
	head ce.event_id
	     i += 1
	     stat = alterlist(discern_alerts->qual,i)
	     discern_alerts->qual[i].alert_dt_tm = ce.event_end_dt_tm
	     discern_alerts->qual[i].alert_type = ccr.descriptor
	     discern_alerts->qual[i].ce_event_note_id = cen.ce_event_note_id
	     discern_alerts->qual[i].event_id = ce.event_id
	     discern_alerts->qual[i].long_blob_id = lb.long_blob_id
	     
	
	blobout = notrim(fillstring(32768," "))
	blobnortf = notrim(fillstring(32768," "))

	if(cen.compression_cd = ocfcomp_var)
	  ;use a variable to get the actual uncompressed size
	  uncompsize = 0
	  ;use uar_ocf_uncompress to uncompress the blob
	  ;the uncompressed blob is assigned to the variable blobout
	   blob_un = UAR_OCF_UNCOMPRESS
					(lb.long_blob, size( Lb.LONG_BLOB ), ;;; lenblob, change for 64bit  (2018) domains
					 BLOBOUT, SIZE( BLOBOUT ), uncompsize)

					 ;In 64bit environments using the select expression lenblob in the above uar_ocf_uncompress call

					 ;can cause programs to crash.  Changing it to use the Size() function seems to prevent the crash.

	  ;use uar_rtf2 to strip the rtf from the blob
			stat = uar_rtf2(blobout,uncompsize,
							blobnortf,size(blobnortf),bsize,0)
	  ;set blobnortf to actual size
	   blobnortf = substring(1,bsize,blobnortf)
	 else
	   blobnortf = lb.long_blob
	endif
	
	discern_alerts->qual[i].alert_text = blobnortf
	
	foot report
	     discern_alerts->cnt = i
	with nocounter
	
	
	set vReturnAlerts = cnvtrectojson(discern_alerts)
	free record discern_alerts
	
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
	
	declare vReturnCode = f8 with noconstant(0.0)
	;call echorecord(dta_reply)
	if (validate(dta_reply,0))
	     set vReturnCode = dta_reply->dta[1].event_cd
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
