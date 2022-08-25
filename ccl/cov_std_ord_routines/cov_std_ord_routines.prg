/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_std_ord_routines.prg
  Object name:        cov_std_ord_routines
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
drop program cov_std_ord_routines:dba go
create program cov_std_ord_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))

execute cov_std_log_routines
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Subroutines */
/**********************************************************************************************************************
** Function ()
** ---------------------------------------------------------------------------------------
** Return a record structure named  
**********************************************************************************************************************/

declare GetOrderSynonymbyMnemonic(vMnemonic=vc) = f8 with copy, persist
subroutine GetOrderSynonymbyMnemonic(vMnemonic)
	declare vReturnSynonymId = f8 with noconstant(0.0), protect
 
	select into "nl:"
	from
		 order_catalog oc
		,order_catalog_synonym ocs
	plan ocs
		where ocs.mnemonic = vMnemonic
	join oc
		where oc.catalog_cd = ocs.catalog_cd
	detail
		vReturnSynonymId = ocs.synonym_id
	with nocounter
 
	return (vReturnSynonymId)
end ;GetOrderSynonymbyOrderID

declare SetupOrder(vEncntrID=f8) = i2 with copy, persist
subroutine SetupOrder(vEncntrID)

	declare vReturnSuccess = i2 with noconstant(FALSE), protect
	declare vPersonID = f8 with noconstant(0.0), protect
	declare ordrequest_template = vc with constant("cust_script:ordrequest.json")
	declare ordrequest_line_in = vc with noconstant(" ")
    
    select into "nl:"
    from
    	encounter e
    plan e
    	where e.encntr_id = vEncntrID
    detail
    	vPersonID = e.person_id
    with nocounter
    
	free define rtl3
	define rtl3 is ordrequest_template
 
	select into "nl:"
	from rtl3t r
	detail
		ordrequest_line_in = concat(ordrequest_line_in,r.line)
	with nocounter
 
	free record ordrequest
	set stat = cnvtjsontorec(ordrequest_line_in,2)
 
	if (validate(ordrequest) = FALSE)
		set vReturnSuccess = FALSE
	else
		set ordrequest->personid = vPersonID
		set ordrequest->encntrid = vEncntrID
		set ordrequest->orderlist[1].encntrid = vEncntrID
 
		set vReturnSuccess = TRUE
	endif
	return (vReturnSuccess)
end ;SetupOrder


declare SetupProcOrder(vEncntrID=f8,vSynonymID=f8,vOrderingProv=f8(VALUE,1.0)) = i2 with copy, persist
subroutine SetupProcOrder(vEncntrID,vSynonymID,vOrderingProv)
	
	call SubroutineLog(build2('start SetupProcOrder(',vEncntrID,')'))
	
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
	declare vPersonID = f8 with noconstant(0.0), protect
	declare vOrderID = f8 with noconstant(0.0), protect
	
    select into "nl:"
    from
    	encounter e
    plan e
    	where e.encntr_id = vEncntrID
    detail
    	vPersonID = e.person_id
    with nocounter
	
	record 500698request (
	  1 seq_name = vc  
	  1 number = i2   
	) 
	
	record procrequest (
	  1 productId = f8   
	  1 personId = f8   
	  1 encntrId = f8   
	  1 actionPersonnelId = f8   
	  1 contributorSystemCd = f8   
	  1 orderLocnCd = f8   
	  1 replyInfoFlag = i2   
	  1 commitGroupInd = i2   
	  1 needsATLDupCheckInd = i2   
	  1 orderSheetInd = i2   
	  1 orderSheetPrinterName = vc  
	  1 logLevelOverride = i2   
	  1 unlockProfileInd = i2   
	  1 lockKeyId = i4   
	  1 orderList [*]   
	    2 orderId = f8   
	    2 actionTypeCd = f8   
	    2 communicationTypeCd = f8   
	    2 orderProviderId = f8   
	    2 orderDtTm = dq8   
	    2 currentStartDtTm = dq8   
	    2 oeFormatId = f8   
	    2 catalogTypeCd = f8   
	    2 accessionNbr = vc  
	    2 accessionId = f8   
	    2 noChargeInd = i2   
	    2 billOnlyInd = i2   
	    2 lastUpdtCnt = i4   
	    2 detailList [*]   
	      3 oeFieldId = f8   
	      3 oeFieldValue = f8   
	      3 oeFieldDisplayValue = vc  
	      3 oeFieldDtTmValue = dq8   
	      3 oeFieldMeaning = vc  
	      3 oeFieldMeaningId = f8   
	      3 valueRequiredInd = i2   
	      3 groupSeq = i4   
	      3 fieldSeq = i4   
	      3 modifiedInd = i2   
	      3 detailHistoryList [*]   
	        4 oeFieldValue = f8   
	        4 oeFieldDisplayValue = vc  
	        4 oeFieldDtTmValue = dq8   
	        4 detailAlterFlag = i2   
	        4 detailAlterTriggerCd = f8   
	    2 miscList [*]   
	      3 fieldMeaning = vc  
	      3 fieldMeaningId = f8   
	      3 fieldValue = f8   
	      3 fieldDisplayValue = vc  
	      3 fieldDtTmValue = dq8   
	      3 modifiedInd = i2   
	      3 groups [*]   
	        4 groupIdentifier = i2   
	      3 fieldSerializedValue  
	        4 contentType = vc  
	        4 encoding = vc  
	        4 data = gvc   
	    2 promptTestList [*]   
	      3 fieldValue = f8   
	      3 fieldDisplayValue = vc  
	      3 fieldDtTmValue = dq8   
	      3 promptEntityName = vc  
	      3 promptEntityId = f8   
	      3 modifiedInd = i2   
	      3 fieldTypeFlag = i2   
	      3 oeFieldId = f8   
	    2 commentList [*]   
	      3 commentType = f8   
	      3 commentText = vc  
	    2 reviewList [*]   
	      3 reviewTypeFlag = i2   
	      3 providerId = f8   
	      3 locationCd = f8   
	      3 rejectedInd = i2   
	      3 reviewPersonnelId = f8   
	      3 proxyPersonnelId = f8   
	      3 proxyReasonCd = f8   
	      3 catalogTypeCd = f8   
	      3 actionSequence = i2   
	    2 deptMiscLine = vc  
	    2 catalogCd = f8   
	    2 synonymId = f8   
	    2 orderMnemonic = vc  
	    2 needsIntervalCalcInd = i2   
	    2 templateOrderFlag = i2   
	    2 templateOrderId = f8   
	    2 groupOrderFlag = i2   
	    2 groupCompCount = i4   
	    2 linkOrderFlag = i2   
	    2 linkCompCount = i4   
	    2 linkTypeCd = f8   
	    2 linkElementFlag = i2   
	    2 linkElementCd = f8   
	    2 processingFlag = i2   
	    2 origOrdAsFlag = i2   
	    2 orderStatusCd = f8   
	    2 deptStatusCd = f8   
	    2 schStateCd = f8   
	    2 discontinueTypeCd = f8   
	    2 rxMask = i4   
	    2 schEventId = f8   
	    2 encntrId = f8   
	    2 medOrderTypeCd = f8   
	    2 undoActionTypeCd = f8   
	    2 orderedAsMnemonic = vc  
	    2 getLatestDetailsInd = i2   
	    2 studentActionTypeCd = f8   
	    2 aliasList [*]   
	      3 alias = vc  
	      3 orderAliasTypeCd = f8   
	      3 orderAliasSubtypeCd = f8   
	      3 aliasPoolCd = f8   
	      3 checkDigit = i4   
	      3 checkDigitMethodCd = f8   
	      3 begEffectiveDtTm = dq8   
	      3 endEffectiveDtTm = dq8   
	      3 dataStatusCd = f8   
	      3 activeStatusCd = f8   
	      3 activeInd = i2   
	      3 billOrdNbrInd = i2   
	      3 primaryDisplayInd = i2   
	    2 subComponentList [*]   
	      3 scCatalogCd = f8   
	      3 scSynonymId = f8   
	      3 scOrderMnemonic = vc  
	      3 scOeFormatId = f8   
	      3 scStrengthDose = f8   
	      3 scStrengthDoseDisp = vc  
	      3 scStrengthUnit = f8   
	      3 scStrengthUnitDisp = vc  
	      3 scVolumeDose = f8   
	      3 scVolumeDoseDisp = vc  
	      3 scVolumeUnit = f8   
	      3 scVolumeUnitDisp = vc  
	      3 scFreetextDose = vc  
	      3 scFrequency = f8   
	      3 scFrequencyDisp = vc  
	      3 scIVSeq = i4   
	      3 scDoseQuantity = f8   
	      3 scDoseQuantityDisp = vc  
	      3 scDoseQuantityUnit = f8   
	      3 scDoseQuantityUnitDisp = vc  
	      3 scOrderedAsMnemonic = vc  
	      3 scHnaOrderMnemonic = vc  
	      3 scDetailList [*]   
	        4 oeFieldId = f8   
	        4 oeFieldValue = f8   
	        4 oeFieldDisplayValue = vc  
	        4 oeFieldDtTmValue = dq8   
	        4 oeFieldMeaning = vc  
	        4 oeFieldMeaningId = f8   
	        4 valueRequiredInd = i2   
	        4 groupSeq = i4   
	        4 fieldSeq = i4   
	        4 modifiedInd = i2   
	      3 scProductList [*]   
	        4 item_id = f8   
	        4 dose_quantity = f8   
	        4 dose_quantity_unit_cd = f8   
	        4 tnf_id = f8   
	        4 tnf_description = vc  
	        4 tnf_cost = f8   
	        4 tnf_ndc = vc  
	        4 tnfLegalStatusCd = f8   
	        4 packageTypeId = f8   
	        4 medProductId = f8   
	        4 manfItemId = f8   
	        4 dispQty = f8   
	        4 dispQtyUnitCd = f8   
	        4 ignoreInd = i2   
	        4 compoundFlag = i2   
	        4 cmpdBaseInd = i2   
	        4 premanfInd = i2   
	        4 productSeq = i2   
	        4 parentProductSeq = i2   
	        4 labelDesc = vc  
	        4 brandDesc = vc  
	        4 genericDesc = vc  
	        4 drugIdentifier = vc  
	        4 pkg_qty_per_pkg = f8   
	        4 pkg_disp_more_ind = i2   
	        4 unrounded_dose_quantity = f8   
	        4 overfillStrengthDose = f8   
	        4 overfillStrengthUnitCd = f8   
	        4 overfillStrengthUnitDisp = vc  
	        4 overfillVolumeDose = f8   
	        4 overfillVolumeUnitCd = f8   
	        4 overfillVolumeUnitDisp = vc  
	        4 doseList [*]   
	          5 scheduleSequence = i2   
	          5 doseQuantity = f8   
	          5 doseQuantityUnitCd = f8   
	          5 unroundedDoseQuantity = f8   
	      3 scIngredientTypeFlag = i2   
	      3 scPrevIngredientSeq = i4   
	      3 scModifiedFlag = i2   
	      3 scIncludeInTotalVolumeFlag = i2   
	      3 scClinicallySignificantFlag = i2   
	      3 scAutoAssignFlag = i2   
	      3 scOrderedDose = f8   
	      3 scOrderedDoseDisp = vc  
	      3 scOrderedDoseUnitCd = f8   
	      3 scOrderedDoseUnitDisp = vc  
	      3 scDoseCalculatorLongText = c32000  
	      3 scIngredientSourceFlag = i2   
	      3 scNormalizedRate = f8   
	      3 scNormalizedRateDisp = vc  
	      3 scNormalizedRateUnitCd = f8   
	      3 scNormalizedRateUnitDisp = vc  
	      3 scConcentration = f8   
	      3 scConcentrationDisp = vc  
	      3 scConcentrationUnitCd = f8   
	      3 scConcentrationUnitDisp = vc  
	      3 scTherapeuticSbsttnList [*]   
	        4 therapSbsttnId = f8   
	        4 acceptFlag = i2   
	        4 overrideReasonCd = f8   
	        4 itemId = f8   
	      3 scHistoryList [*]   
	        4 scAlterTriggerCd = f8   
	        4 scSynonymId = f8   
	        4 scStrengthDose = f8   
	        4 scStrengthUnit = f8   
	        4 scVolumeDose = f8   
	        4 scVolumeUnit = f8   
	        4 scFreetextDose = vc  
	        4 scModifiedFlag = i2   
	      3 scDosingInfo [*]   
	        4 dosingCapacity = i2   
	        4 daysOfAdministrationDisplay = vc  
	        4 doseList [*]   
	          5 scheduleInfo  
	            6 doseSequence = i2   
	            6 scheduleSequence = i2   
	          5 strengthDose [*]   
	            6 value = f8   
	            6 valueDisplay = vc  
	            6 unitOfMeasureCd = f8   
	          5 volumeDose [*]   
	            6 value = f8   
	            6 valueDisplay = vc  
	            6 unitOfMeasureCd = f8   
	          5 orderedDose [*]   
	            6 value = f8   
	            6 valueDisplay = vc  
	            6 unitOfMeasureCd = f8   
	            6 doseType  
	              7 strengthInd = i2   
	              7 volumeInd = i2   
	      3 scDoseAdjustmentInfo [*]   
	        4 doseAdjustmentDisplay = vc  
	      3 scOrderedAsSynonymId = f8   
	    2 resourceList [*]   
	      3 serviceResourceCd = f8   
	      3 csLoginLocCd = f8   
	      3 serviceAreaCd = f8   
	      3 assayList [*]   
	        4 taskAssayCd = f8   
	    2 relationshipList [*]   
	      3 relationshipMeaning = vc  
	      3 valueList [*]   
	        4 entityId = f8   
	        4 entityDisplay = vc  
	        4 rankSequence = i4   
	      3 inactivateAllInd = i2   
	    2 miscLongTextList [*]   
	      3 textId = f8   
	      3 textTypeCd = f8   
	      3 text = vc  
	      3 textModifier1 = i4   
	      3 textModified2 = i4   
	    2 deptCommentList [*]   
	      3 commentTypeCd = f8   
	      3 commentSeq = i4   
	      3 commentId = f8   
	      3 longTextId = f8   
	      3 deptCommentMisc = i4   
	      3 deptCommentText = vc  
	    2 adHocFreqTimeList [*]   
	      3 adHocTime = i4   
	    2 ingredientReviewInd = i2   
	    2 badOrderInd = i2   
	    2 origOrderDtTm = dq8   
	    2 validDoseDtTm = dq8   
	    2 userOverrideTZ = i4   
	    2 linkNbr = f8   
	    2 linkTypeFlag = i2   
	    2 digitalSignatureIdent = c64  
	    2 bypassPrescriptionReqPrinting = i2   
	    2 pathwayCatalogId = f8   
	    2 acceptProposalId = f8   
	    2 addOrderReltnList [*]   
	      3 relatedFromOrderId = f8   
	      3 relatedFromActionSeq = i4   
	      3 relationTypeCd = f8   
	    2 scheduleExceptionList [*]   
	      3 scheduleExceptionTypeCd = f8   
	      3 origInstanceDtTm = dq8   
	      3 newInstanceDtTm = dq8   
	      3 scheduleExceptionOrderId = f8   
	    2 inactiveScheduleExceptionList [*]   
	      3 orderScheduleExceptionId = f8   
	      3 scheduleExceptionOrderId = f8   
	    2 actionInitiatedDtTm = dq8   
	    2 ivSetSynonymId = f8   
	    2 futureInfo [*]   
	      3 scheduleNewOrderAsEstimated [*]   
	        4 startDateTimeInd = i2   
	        4 stopDateTimeInd = i2   
	      3 changeScheduleToPrecise [*]   
	        4 startDateTimeInd = i2   
	        4 stopDateTimeInd = i2   
	      3 location [*]   
	        4 facilityCd = f8   
	        4 nurseUnitCd = f8   
	        4 sourceModifiers  
	          5 scheduledAppointmentLocationInd = i2   
	      3 applyStartRange [*]   
	        4 value = i4   
	        4 unit  
	          5 daysInd = i2   
	          5 weeksInd = i2   
	          5 monthsInd = i2   
	        4 rangeAnchorPoint  
	          5 startInd = i2   
	          5 centerInd = i2   
	      3 encounterTypeCd = f8   
	    2 addToPrescriptionGroup [*]   
	      3 relatedOrderId = f8   
	    2 dayOfTreatmentInfo [*]   
	      3 protocolOrderId = f8   
	      3 dayOfTreatmentSequence = i4   
	      3 protocolVersionCheck [*]   
	        4 protocolVersion = i4   
	      3 applyProtocolUpdate [*]   
	        4 treatmentPeriodDisplay = vc  
	    2 supervisingProviderId = f8   
	    2 billingProviderInfo [*]   
	      3 orderProviderInd = i2   
	      3 supervisingProviderInd = i2   
	    2 actionQualifierCd = f8   
	    2 lastUpdateActionSequence = i4   
	    2 protocolInfo [*]   
	      3 protocolType = i2   
	    2 incompleteToPharmacy [*]   
	      3 newOrder [*]   
	        4 noSynonymMatchInd = i2   
	        4 missingOrderDetailsInd = i2   
	      3 resolveOrder [*]   
	        4 resolvedInd = i2   
	    2 originatingEncounterId = f8   
	    2 backfillOrderServerRequest  
	      3 backfillExistingDetails  
	        4 coreInd = i2   
	      3 backfillExistingIngredients  
	        4 coreInd = i2   
	  1 errorLogOverrideFlag = i2   
	  1 actionPersonnelGroupId = f8   
	) with persist
	   	
	if (validate(procrequest) = FALSE)
		set vReturnSuccess = FALSE
	else
		set 500698request->seq_name = "order_seq"
		set 500698request->number = 1
		
		set stat = tdbexecute(600005,500195,500698,"REC",500698request,"REC",500698reply)

		call SubroutineLog('500698reply','record')
		
		set vOrderID = 500698reply->qual[1].seq_value
	
		set procrequest->personid = vPersonID
		set procrequest->encntrid = vEncntrID
 		set procrequest->replyInfoFlag = 1
 		set procrequest->errorLogOverrideFlag = 1
 		set procrequest->actionPersonnelId = vOrderingProv
 		
 		select into "nl:"
 		from
 			 order_catalog oc
 			,order_catalog_synonym ocs
 		plan ocs
 			where ocs.synonym_id = vSynonymID
 		join oc
 			where oc.catalog_cd = ocs.catalog_cd
 		order by
 			oc.catalog_cd
 		head oc.catalog_cd
 			stat = alterlist(procrequest->orderList,1)
 			procrequest->orderlist[1].orderId = vOrderID
			procrequest->orderlist[1].encntrid = vEncntrID
 			procrequest->orderList[1].actionTypeCd = uar_get_code_by("MEANING",6003,"ORDER")
 			procrequest->orderList[1].communicationTypeCd = uar_get_code_by("MEANING",6006,"NOCOSIGN")
 			procrequest->orderList[1].orderProviderId =  vOrderingProv
 			procrequest->orderList[1].origOrderDtTm = cnvtdatetime(sysdate)
 			procrequest->orderList[1].orderDtTm = cnvtdatetime(sysdate)
 			procrequest->orderList[1].oeFormatId = ocs.oe_format_id
 			procrequest->orderList[1].catalogTypeCd = oc.catalog_type_cd
 			procrequest->orderList[1].catalogCd = oc.catalog_cd
 			procrequest->orderList[1].synonymId = ocs.synonym_id
 			procrequest->orderList[1].rxMask = 2
 			procrequest->orderList[1].medOrderTypeCd = uar_get_code_by("MEANING",18309,"INTERMITTENT")
 			procrequest->orderList[1].orderedAsMnemonic = concat(trim(oc.primary_mnemonic)," (",trim(ocs.mnemonic),")")
 			procrequest->orderList[1].validDoseDtTm = cnvtdatetime(sysdate)
 			procrequest->orderList[1].actionInitiatedDtTm = cnvtdatetime(sysdate)
 			procrequest->orderList[1].originatingEncounterId = vEncntrID
 			
 			/*
	 		  <fieldMeaning>COMPLEXINTERMITTENTFLAG</fieldMeaning>
	          <fieldMeaningId>2453</fieldMeaningId>
	          <fieldValue>1</fieldValue>
	          <fieldDisplayValue>1</fieldDisplayValue>
	          <fieldDtTmValue>2022-07-26T15:23:11.00</fieldDtTmValue>
	          <modifiedInd>1</modifiedInd>
	          <fieldSerializedValue>
	             <contentType></contentType>
	             <encoding></encoding>
	             <data></data>
	          </fieldSerializedValue>
          	*/
          	
 			stat = alterlist(procrequest->orderList[1].miscList,1)
 			procrequest->orderList[1].miscList[1].fieldMeaning		= "COMPLEXINTERMITTENTFLAG"
 			procrequest->orderList[1].miscList[1].fieldMeaningId	= 2453
 			procrequest->orderList[1].miscList[1].fieldValue		= 1
 			procrequest->orderList[1].miscList[1].fieldDisplayValue	= "1"
 			procrequest->orderList[1].miscList[1].fieldDtTmValue	= cnvtdatetime(sysdate)
 			procrequest->orderList[1].miscList[1].modifiedInd		= 1
 			
 			stat = alterlist(procrequest->orderList[1].subComponentList,1)
 			
 			/*
 			<subComponentList>
		          <scCatalogCd>2778917</scCatalogCd>
		          <scSynonymId>3908819253</scSynonymId>
		          <scOrderMnemonic></scOrderMnemonic>
		          <scOeFormatId>0</scOeFormatId>
		          <scStrengthDose>0</scStrengthDose>
		          <scStrengthDoseDisp></scStrengthDoseDisp>
		          <scStrengthUnit>0</scStrengthUnit>
		          <scStrengthUnitDisp></scStrengthUnitDisp>
		          <scVolumeDose>30</scVolumeDose>
		          <scVolumeDoseDisp>30</scVolumeDoseDisp>
		          <scVolumeUnit>293</scVolumeUnit>
		          <scVolumeUnitDisp>mL</scVolumeUnitDisp>
		          <scFreetextDose></scFreetextDose>
		          <scFrequency>0</scFrequency>
		          <scFrequencyDisp></scFrequencyDisp>
		          <scIVSeq>0</scIVSeq>
		          <scDoseQuantity>0</scDoseQuantity>
		          <scDoseQuantityDisp></scDoseQuantityDisp>
		          <scDoseQuantityUnit>0</scDoseQuantityUnit>
		          <scDoseQuantityUnitDisp></scDoseQuantityUnitDisp>
		          <scOrderedAsMnemonic>NS Chaser</scOrderedAsMnemonic>
		          <scHnaOrderMnemonic>sodium chloride 0.9%</scHnaOrderMnemonic>
		          <scIngredientTypeFlag>3</scIngredientTypeFlag>
		          <scPrevIngredientSeq>0</scPrevIngredientSeq>
		          <scModifiedFlag>1</scModifiedFlag>
		          <scIncludeInTotalVolumeFlag>0</scIncludeInTotalVolumeFlag>
		          <scClinicallySignificantFlag>2</scClinicallySignificantFlag>
		          <scAutoAssignFlag>0</scAutoAssignFlag>
		          <scOrderedDose>0</scOrderedDose>
		          <scOrderedDoseDisp></scOrderedDoseDisp>
		          <scOrderedDoseUnitCd>0</scOrderedDoseUnitCd>
		          <scOrderedDoseUnitDisp></scOrderedDoseUnitDisp>
		          <scDoseCalculatorLongText></scDoseCalculatorLongText>
		          <scIngredientSourceFlag>0</scIngredientSourceFlag>
		          <scNormalizedRate>0</scNormalizedRate>
		          <scNormalizedRateDisp></scNormalizedRateDisp>
		          <scNormalizedRateUnitCd>0</scNormalizedRateUnitCd>
		          <scNormalizedRateUnitDisp></scNormalizedRateUnitDisp>
		          <scConcentration>0</scConcentration>
		          <scConcentrationDisp></scConcentrationDisp>
		          <scConcentrationUnitCd>0</scConcentrationUnitCd>
		          <scConcentrationUnitDisp></scConcentrationUnitDisp>
		          <scOrderedAsSynonymId>3908819253</scOrderedAsSynonymId>
       		*/
 			procrequest->orderList[1].subComponentList[1].scCatalogCd = oc.catalog_cd
 			procrequest->orderList[1].subComponentList[1].scSynonymId = ocs.synonym_id
 			procrequest->orderList[1].subComponentList[1].scVolumeDose = 30.0
 			procrequest->orderList[1].subComponentList[1].scVolumeDoseDisp = "30"
 			procrequest->orderList[1].subComponentList[1].scVolumeUnit = 293
 			procrequest->orderList[1].subComponentList[1].scVolumeUnitDisp = 
 									uar_get_code_display(procrequest->orderList[1].subComponentList[1].scVolumeUnit)
 			procrequest->orderList[1].subComponentList[1].scOrderedAsMnemonic = ocs.mnemonic
 			procrequest->orderList[1].subComponentList[1].scHnaOrderMnemonic = oc.primary_mnemonic
 			procrequest->orderList[1].subComponentList[1].scIngredientTypeFlag = 3
 			procrequest->orderList[1].subComponentList[1].scModifiedFlag = 1
 			procrequest->orderList[1].subComponentList[1].scClinicallySignificantFlag = 2
 			procrequest->orderList[1].subComponentList[1].scOrderedAsSynonymId = ocs.synonym_id
 			
 		with nocounter
 		
		set vReturnSuccess = TRUE
	endif
	
	call SubroutineLog(build2('vPersonID=',vPersonID,''))
	call SubroutineLog(build2('vEncntrID=',vEncntrID,''))

	call SubroutineLog(build2('end SetupProcOrder(',vReturnSuccess,')'))
	
	return (vReturnSuccess)
end ;SetupProcOrder

declare SetProcOrderDetailDTTm(vOEFieldDesc=vc,vDateTime=dq8,vModified=i2(VALUE,0),vGroup=i2(VALUE,0),vField=i2(VALUE,0)) = i2 
	with copy, persist
subroutine SetProcOrderDetailDTTm(vOEFieldDesc,vDateTime,vModified,vGroup,vField)

	call SubroutineLog(build2('start SetProcOrderDetailDTTm(',vOEFieldDesc,',',format(vDateTime,";;q"),')'))
	
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
	declare oe_field_id = f8 with noconstant(0.0), protect
	declare oe_field_meaning_id = f8 with noconstant(0.0), protect 
	declare oe_field_meaning = vc with noconstant(" "), protect
	declare idx=i4 with noconstant(0), protect

	select into "nl:"
	from
		order_entry_fields oef
		,oe_field_meaning ofm
	plan oef
		where oef.description = vOEFieldDesc
	join ofm
		where ofm.oe_field_meaning_id = oef.oe_field_meaning_id
	detail
		oe_field_id = oef.oe_field_id
		oe_field_meaning_id = oef.oe_field_meaning_id
		oe_field_meaning = ofm.oe_field_meaning
	with nocounter

	call SubroutineLog(build2('oe_field_id=',oe_field_id))
	call SubroutineLog(build2('oe_field_meaning_id=',oe_field_meaning_id))
	call SubroutineLog(build2('oe_field_meaning=',oe_field_meaning))

	if ((oe_field_id > 0.0) and (oe_field_meaning_id > 0.0))
		set idx = locateval(i,1,size(procrequest->orderList[1].detailList,5)
			,oe_field_id,procrequest->orderList[1].detailList[i].oeFieldId)
	endif
	
	/*
	 <oeFieldId>633594</oeFieldId>
          <oeFieldValue>0</oeFieldValue>
          <oeFieldDisplayValue>07/26/22 11:22 EDT</oeFieldDisplayValue>
          <oeFieldDtTmValue>2022-07-26T15:22:00.00</oeFieldDtTmValue>
          <oeFieldMeaning>NEXTDOSEDTTM</oeFieldMeaning>
          <oeFieldMeaningId>2096</oeFieldMeaningId>
          <valueRequiredInd>0</valueRequiredInd>
          <groupSeq>85</groupSeq>
          <fieldSeq>0</fieldSeq>
          <modifiedInd>1</modifiedInd>
    */
    
    call SubroutineLog(build2('idx=',idx))
    
	if (idx = 0)
		set j=(size(procrequest->orderList[1].detailList,5) + 1)
		call SubroutineLog(build2('j=',j))
		set stat = alterlist(procrequest->orderList[1].detailList,j)
		set procrequest->orderList[1].detailList[j].oeFieldId = oe_field_id
		set procrequest->orderList[1].detailList[j].oeFieldMeaningId = oe_field_meaning_id
		set procrequest->orderList[1].detailList[j].oeFieldMeaning = oe_field_meaning
		set procrequest->orderlist[1].detaillist[j].oefielddttmvalue = cnvtdatetime(vDateTime)
		set procrequest->orderlist[1].detaillist[j].oefielddisplayvalue = format(vDateTime,";;q")
	else
		set procrequest->orderList[1].detailList[idx].oeFieldId = oe_field_id
		set procrequest->orderList[1].detailList[idx].oeFieldMeaningId = oe_field_meaning_id
		set procrequest->orderList[1].detailList[idx].oeFieldMeaning = oe_field_meaning
		set procrequest->orderlist[1].detaillist[idx].oefielddttmvalue = cnvtdatetime(vDateTime)
		set procrequest->orderlist[1].detaillist[idx].oefielddisplayvalue = format(vDateTime,";;q")
	endif
	
	if (j=0)
		set j=idx
	endif
	
	set procrequest->orderlist[1].detaillist[j].modifiedInd = vModified
	set procrequest->orderlist[1].detaillist[j].groupSeq = vGroup
	set procrequest->orderlist[1].detaillist[j].fieldSeq = vField
	
	call SubroutineLog('procrequest->orderlist[1].detaillist[j]','RECORD')
	
	set vReturnSuccess = TRUE
	
	call SubroutineLog(build2('end SetProcOrderDetailDTTm(',vReturnSuccess,')'))
	
	return (vReturnSuccess)
	
end ;SetProcOrderDetailDTTm

declare SetProcOrderDetailValueCd(vOEFieldDesc=vc,vValueCd=f8,vModified=i2(VALUE,0),vGroup=i2(VALUE,0),vField=i2(VALUE,0)) 
	= i2 with copy, persist
subroutine SetProcOrderDetailValueCd(vOEFieldDesc,vValueCd,vModified,vGroup,vField)	

	call SubroutineLog(build2('start SetProcOrderDetailValueCd(',vOEFieldDesc,',',uar_get_code_display(vValueCd),')'))
	
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
	declare oe_field_id = f8 with noconstant(0.0), protect
	declare oe_field_meaning_id = f8 with noconstant(0.0), protect 
	declare oe_field_meaning = vc with noconstant(" "), protect
	declare idx=i4 with noconstant(0), protect

	select into "nl:"
	from
		order_entry_fields oef
		,oe_field_meaning ofm
	plan oef
		where oef.description = vOEFieldDesc
	join ofm
		where ofm.oe_field_meaning_id = oef.oe_field_meaning_id
	detail
		oe_field_id = oef.oe_field_id
		oe_field_meaning_id = oef.oe_field_meaning_id
		oe_field_meaning = ofm.oe_field_meaning
	with nocounter
	
	call SubroutineLog(build2('oe_field_id=',oe_field_id))
	call SubroutineLog(build2('oe_field_meaning_id=',oe_field_meaning_id))
	call SubroutineLog(build2('oe_field_meaning=',oe_field_meaning))

	if ((oe_field_id > 0.0) and (oe_field_meaning_id > 0.0))
		set idx = locateval(i,1,size(procrequest->orderList[1].detailList,5)
			,oe_field_id,procrequest->orderList[1].detailList[i].oeFieldId)
	
	/*
	  <oeFieldId>12711</oeFieldId>
          <oeFieldValue>318173</oeFieldValue>
          <oeFieldDisplayValue>IV Piggyback</oeFieldDisplayValue>
          <oeFieldDtTmValue>0000-00-00T00:00:00.00</oeFieldDtTmValue>
          <oeFieldMeaning>RXROUTE</oeFieldMeaning>
          <oeFieldMeaningId>2050</oeFieldMeaningId>
          <valueRequiredInd>1</valueRequiredInd>
          <groupSeq>20</groupSeq>
          <fieldSeq>0</fieldSeq>
          <modifiedInd>1</modifiedInd>
         */
         
        call SubroutineLog(build2('idx=',idx))
        
		if (idx = 0)
			set j=(size(procrequest->orderList[1].detailList,5) + 1)
			call SubroutineLog(build2('j=',j))
			set stat = alterlist(procrequest->orderList[1].detailList,j)
			set procrequest->orderList[1].detailList[j].oeFieldId = oe_field_id
			set procrequest->orderList[1].detailList[j].oeFieldMeaningId = oe_field_meaning_id
			set procrequest->orderList[1].detailList[j].oeFieldMeaning = oe_field_meaning
			set procrequest->orderlist[1].detaillist[j].oefieldvalue = vValueCd
			set procrequest->orderlist[1].detaillist[j].oefielddisplayvalue = uar_get_code_display(vValueCd)
		else
			set procrequest->orderList[1].detailList[idx].oeFieldId = oe_field_id
			set procrequest->orderList[1].detailList[idx].oeFieldMeaningId = oe_field_meaning_id
			set procrequest->orderList[1].detailList[idx].oeFieldMeaning = oe_field_meaning
			set procrequest->orderlist[1].detaillist[idx].oefieldvalue = vValueCd
			set procrequest->orderlist[1].detaillist[idx].oefielddisplayvalue = uar_get_code_display(vValueCd)
		endif
		
		if (j=0)
			set j=idx
		endif
		
		set procrequest->orderlist[1].detaillist[j].modifiedInd = vModified
		set procrequest->orderlist[1].detaillist[j].groupSeq = vGroup
		set procrequest->orderlist[1].detaillist[j].fieldSeq = vField
		
		call SubroutineLog('procrequest->orderlist[1].detaillist[j]','RECORD')
		
	endif
	
	set vReturnSuccess = TRUE
	
	call SubroutineLog(build2('end SetProcOrderDetailValueCd(',vReturnSuccess,')'))
	
	return (vReturnSuccess)
end ;SetProcOrderDetailValueCd


declare SetProcOrderDetailValue(
									 vOEFieldDesc=vc
									,vValue=f8
									,vModified=i2(VALUE,0)
									,vGroup=i2(VALUE,0)
									,vField=i2(VALUE,0)
									,vEmpty=i2(VALUE,0)) 
	= i2 with copy, persist
subroutine SetProcOrderDetailValue(vOEFieldDesc,vValue,vModified,vGroup,vField,vEmpty)	

	call SubroutineLog(build2('start SetProcOrderDetailValue(',vOEFieldDesc,',',vValue,',',vGroup,',',vField,',',vEmpty,')'))
	
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
	declare oe_field_id = f8 with noconstant(0.0), protect
	declare oe_field_meaning_id = f8 with noconstant(0.0), protect 
	declare oe_field_meaning = vc with noconstant(" "), protect
	declare idx=i4 with noconstant(0), protect

	select into "nl:"
	from
		order_entry_fields oef
		,oe_field_meaning ofm
	plan oef
		where oef.description = vOEFieldDesc
	join ofm
		where ofm.oe_field_meaning_id = oef.oe_field_meaning_id
	detail
		oe_field_id = oef.oe_field_id
		oe_field_meaning_id = oef.oe_field_meaning_id
		oe_field_meaning = ofm.oe_field_meaning
	with nocounter
	
	call SubroutineLog(build2('oe_field_id=',oe_field_id))
	call SubroutineLog(build2('oe_field_meaning_id=',oe_field_meaning_id))
	call SubroutineLog(build2('oe_field_meaning=',oe_field_meaning))

	if ((oe_field_id > 0.0) and (oe_field_meaning_id > 0.0))
		set idx = locateval(i,1,size(procrequest->orderList[1].detailList,5)
			,oe_field_id,procrequest->orderList[1].detailList[i].oeFieldId)
	
	/*
	  <oeFieldId>12711</oeFieldId>
          <oeFieldValue>318173</oeFieldValue>
          <oeFieldDisplayValue>IV Piggyback</oeFieldDisplayValue>
          <oeFieldDtTmValue>0000-00-00T00:00:00.00</oeFieldDtTmValue>
          <oeFieldMeaning>RXROUTE</oeFieldMeaning>
          <oeFieldMeaningId>2050</oeFieldMeaningId>
          <valueRequiredInd>1</valueRequiredInd>
          <groupSeq>20</groupSeq>
          <fieldSeq>0</fieldSeq>
          <modifiedInd>1</modifiedInd>
         */
         
        call SubroutineLog(build2('idx=',idx))
        
		if (idx = 0)
			set j=(size(procrequest->orderList[1].detailList,5) + 1)
			call SubroutineLog(build2('j=',j))
			set stat = alterlist(procrequest->orderList[1].detailList,j)
			set procrequest->orderList[1].detailList[j].oeFieldId = oe_field_id
			set procrequest->orderList[1].detailList[j].oeFieldMeaningId = oe_field_meaning_id
			set procrequest->orderList[1].detailList[j].oeFieldMeaning = oe_field_meaning
			set procrequest->orderlist[1].detaillist[j].oefieldvalue = vValue
			set procrequest->orderlist[1].detaillist[j].oefielddisplayvalue = cnvtstring(vValue)
		else
			set procrequest->orderList[1].detailList[idx].oeFieldId = oe_field_id
			set procrequest->orderList[1].detailList[idx].oeFieldMeaningId = oe_field_meaning_id
			set procrequest->orderList[1].detailList[idx].oeFieldMeaning = oe_field_meaning
			set procrequest->orderlist[1].detaillist[idx].oefieldvalue = vValue
			set procrequest->orderlist[1].detaillist[idx].oefielddisplayvalue = cnvtstring(vValue)
		endif
		
		if (j=0)
			set j=idx
		endif
		
		if (vEmpty = 1)
			set procrequest->orderlist[1].detaillist[j].oefieldvalue = 0.0
			set procrequest->orderlist[1].detaillist[j].oefielddisplayvalue = ""
		endif
		
		set procrequest->orderlist[1].detaillist[j].modifiedInd = vModified
		set procrequest->orderlist[1].detaillist[j].groupSeq = vGroup
		set procrequest->orderlist[1].detaillist[j].fieldSeq = vField
		
		if (vOEFieldDesc = "Scheduled / PRN")
			if (vValue = 1)
				set procrequest->orderlist[1].detaillist[j].oefielddisplayvalue = "Yes"
			else
				set procrequest->orderlist[1].detaillist[j].oefielddisplayvalue = "No"
			endif
		endif
		
		call SubroutineLog('procrequest->orderlist[1].detaillist[j]','RECORD')
		
	endif
	
	set vReturnSuccess = TRUE
	
	call SubroutineLog(build2('end SetProcOrderDetailValue(',vReturnSuccess,')'))
	
	return (vReturnSuccess)
end ;SetProcOrderDetailValue

declare UpdateOrderDetailDtTm(vOEFieldMeaning=vc,vDateTime=dq8) = i2 with copy, persist
subroutine UpdateOrderDetailDtTm(vOEFieldMeaning,vDateTime)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
 
	if (validate(ordrequest) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	endif
 
	for (j=1 to size(ordrequest->orderlist,5))
		for (i=1 to size(ordrequest->orderlist[j].detaillist,5))
			if (ordrequest->orderlist[j].detaillist[i].oefieldmeaning=trim(cnvtupper(vOEFieldMeaning)))
				set ordrequest->orderlist[j].detaillist[i].oefielddttmvalue = cnvtdatetime(vDateTime)
				set ordrequest->orderlist[j].detaillist[i].oefielddisplayvalue = format(vDateTime,";;q")
				set vReturnSuccess = TRUE
			endif
		endfor
	endfor
 
	return (vReturnSuccess)
end ;UpdateOrderDetailDtTm


declare UpdateOrderDetailValueCd(vOEFieldMeaning=vc,vValueCd=f8) = i2 with copy, persist
subroutine UpdateOrderDetailValueCd(vOEFieldMeaning,vValueCd)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
 
	if (validate(ordrequest) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	endif
 
	for (j=1 to size(ordrequest->orderlist,5))
		for (i=1 to size(ordrequest->orderlist[j].detaillist,5))
			if (ordrequest->orderlist[j].detaillist[i].oefieldmeaning=trim(cnvtupper(vOEFieldMeaning)))
				set ordrequest->orderlist[j].detaillist[i].oefieldvalue = vValueCd
				set ordrequest->orderlist[j].detaillist[i].oefielddisplayvalue = uar_get_code_display(vValueCd)
				set vReturnSuccess = TRUE
			endif
		endfor
	endfor
 
	return (vReturnSuccess)
end ;UpdateOrderDetailValueCd



declare AddOrderComment(vComment=vc) = i2 with copy, persist
subroutine AddOrderComment(vComment)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
 
	if (validate(ordrequest) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	endif
 
	for (j=1 to size(ordrequest->orderlist,5))
		;set i = size(hstrop_ordrequest->orderlist[j].commentlist,5)
		;set i = (i + 1)
		;set stat = alterlist(hstrop_ordrequest->orderlist[j].commentlist,i)
		set i = 1
		set ordrequest->orderlist[j].commentlist[i].commenttype = uar_get_code_by("MEANING",14,"ORD COMMENT")
		set ordrequest->orderlist[j].commentlist[i].commenttext = trim(vComment)
		set vReturnSuccess = TRUE
	endfor
 
	return (vReturnSuccess)
end ;AddOrderComment

declare CallOrderServer(null) = f8 with copy, persist
subroutine CallOrderServer(null)
	declare vNewOrderID = f8 with noconstant(0.0), protect
 
 	free record ordreply
	set stat = tdbexecute(560210,500210,560201,"REC",ordrequest,"REC",ordreply)
 	call echo(build2("stat=",stat))
 	
	for (i=1 to size(ordreply->orderlist,5))
		set vNewOrderID = ordreply->orderlist[i].orderid
	endfor
 
 	call echorecord(ordreply)
 	
	return (vNewOrderID)
end ;CallOrderServer

declare CallProcServer(null) = f8 with copy, persist
subroutine CallProcServer(null)
	declare vNewOrderID = f8 with noconstant(0.0), protect
 
 	free record procreply
	set stat = tdbexecute(600005,500196,560251,"REC",procrequest,"REC",procreply)
 	call echo(build2("stat=",stat))
 	
 	if (validate(procreply))
		for (i=1 to size(procreply->orderlist,5))
			set vNewOrderID = procreply->orderlist[i].orderid
		endfor
 	endif
 	call echorecord(procreply)
 	
	return (vNewOrderID)
end ;CallOrderServer

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
