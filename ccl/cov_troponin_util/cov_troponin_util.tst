drop program cov_troponin_util_tst go
create program cov_troponin_util_tst
 
declare event_id = f8 with noconstant(0.0)
declare new_event_id = f8 with noconstant(0.0)
execute cov_troponin_util
/* 
set stat = cnvtjsontorec(GethsTropAlgDataByEventID(FindOrderInhsTrop(4725818247.0)))
call echorecord(hsTroponin_data)
 
set ce_event_id = GethsTropCEEventIDbyEventID(hsTroponin_data->three_hour.result_event_id)
call echo(build2("ce_event_id=",ce_event_id))
 
call echo(AddAlgorithmCEResult(ce_event_id))
call AddAlgorithmCEDeltaResult(ce_event_id)
call AddAlgorithmCETimeResult(ce_event_id)

*/
/*
call echo(SetupNewhsTropOrder(16255025.0,125238218.0))
call echo(UpdateOrderDetailValueCd("COLLPRI",value(uar_get_code_by("MEANING",2054,"STAT"))))
call echo(UpdateOrderDetailDtTm("REQSTARTDTTM",cnvtlookahead("56,MIN",cnvtdatetime(curdate,curtime3))))
call echo(AddhsTropOrderComment(build2("Ordered automatically per rapid screening protocols. "
													,"Initiated from accession "
													,trim("01-01-01-01-01")
													," ["
													,">= 3 hour symptoms"
													,"]")))
call echorecord(hstrop_ordrequest)
call echo(CallNewhsTropOrderServer(null))
*/

call echo( GetOrderDeptStatus (4733787147.00 )) 
end go
 
execute cov_troponin_util_tst go
 
/*
declare event_id = f8 with noconstant(0.0) go
declare new_event_id = f8 with noconstant(0.0) go
execute cov_troponin_util go
 
;declare hsTropInterpEC = f8 with constant(GethsTropInterpEC(null)) go
 
;call echo(hsTropInterpEC) go
 
;call echo(GetPatientTypebyEncntrID(125231316.0)) go
;call echo(isPatientOutpatient(125231316.0)) go
 
 
;call echo(GetResultTextbyEventID(3654118363)) go
;call echo(GetOrderPowerPlanbyOrderID(4670782037.0)) go
;call addhsTropDataRec(1) go
;call echo(DeterminehsTropAlg(4670782037.0)) go ;4670782157 ;4670782037
 
;set stat = cnvtjsontorec(GethsTropAlgDataByEventID(FindOrderInhsTrop(3654082569.0))) go
;call echorecord(hsTroponin_data) go
 
;call echo(AddAlgorithmCEResult(  3654082353)) go
;call echo(hsTroponin_data->algorithm_info.type) go
;call echo(hsTroponin_data->algorithm_info.subtype) go
;call echo(GetOrderLocationbyOrderID(4663851923.0)) go
 
;call echo(build2("GethsTropCEEventIDbyEventID=",GethsTropCEEventIDbyEventID(3654082709.00))) go
 
;set stat = cnvtjsontorec(GethsTropAlgDataByEventID(FindOrderInhsTrop(4658951585.0))) go
 
;call echo(cnvtjsontorec(GethsTropAlgDataByEventID(3654054318.00))) go
 
;call echorecord(hsTroponin_data) go
 
 
;call echo(GetOrderSynonymbyOrderID(4619060555.00)) go
;call echo(GetOrderSynonymbyOrderID(4619060621.00)) go
;call echo(GetOrderSynonymbyOrderID(4642343767.00)) go
 
;call echo(addhsTropDataRec(1)) go
;call echo(DeterminehsTropAlg(4619060621.00)) go
 
;call echo(GetOrderLocationbyOrderID(4619060621.00)) go
 
;call echorecord(hsTroponin_data) go
 
;call echo(SethsTropAlgNextTimes(4658951585.0)) go
 
 
;*******************************************************************
;Add new hsTroponin Order for Testing
;*******************************************************************
;125238218	16255025
 
call echo(SetupNewhsTropOrder(16255025.0,125238218.0)) go
call echo(UpdateOrderDetailValueCd("COLLPRI",value(uar_get_code_by("MEANING",2054,"STAT")))) go
call echo(UpdateOrderDetailDtTm("REQSTARTDTTM",cnvtlookahead("56,MIN",cnvtdatetime(curdate,curtime3)))) go
call echo(AddhsTropOrderComment(build2("Ordered automatically per rapid screening protocols. "
													,"Initiated from accession "
													,trim("01-01-01-01-01")
													," ["
													,">= 3 hour symptoms"
													,"]"))) go
call echorecord(hstrop_ordrequest) go
call echo(CallNewhsTropOrderServer(null)) go
 
;*******************************************************************
;Add new ECG Order for Testing
;*******************************************************************
/*
;20743831.0,125332102.0 FSR TCU	ZZZREGRESSION, LTCTWO	 08/15/1938	2122300486	1672744;
;19920147.0,125370972.000000 MMC	ZZZTEST, EDBOARDONE	 03/12/1945	2125900102	739502	21496560
call echo(SetupNewECGOrder(20743831.0,125332102.0)) go
;call echo(SetupNewECGOrder(19920147.0,125370972.000000)) go
 
call echo(UpdateECGOrderDetailValueCd("COLLPRI",value(uar_get_code_by("MEANING",2054,"ROUTINE")))) go
call echo(UpdateECGOrderDetailValueCd("PRIORITY",value(uar_get_code_by("MEANING",1304,"STAT")))) go
call echo(AddECGOrderComment(concat("adding a comment to see if this works"
									,"how long can the comment be"
									,"i was running into a limit i think when adding one through"
									,"ordering process. It should be much longer than that"))) go
call echorecord(ecg_ordrequest) go
call echo(CallNewECGOrderServer(null)) go
*/
 
 
;call echorecord(hstrop_ordrequest) go
;call echo(RemovehsTropAlgData(20743831.0,125332102.0, 3654049786.0)) go
;call echo(RemovehsTropAlgData(19920147.0,125370972.0,3654051978.0)) go
;call echo(GetResultTextbyCEventID(GethsTropCEEventIDbyEventID(3654001619.00))) go
 
;call echo(GetResultbyCEventID( 3653849978.00)) go
;call echo(GetResultTextbyCEventID(3653849978.00)) go
 
/*
call echo(IsSystemOrder(4658219683.00)) go
call echo(format(GetCollectDtTmbyOrderID(4658219683.00),";;q")) go
/*
 GetOrderIDbyCEventID ( vCEventID = f8 ) = f8
call echo(addhsTropDataRec(1)) go
call echo(GethsTropAlgEC(null)) go¬
 
set new_event_id =   3654049737.00 go
 
call echo(build2("first_event_id=",new_event_id)) go
;call echo(RemovehsTropAlgData(19920147.0,125370972.0,new_event_id)) go
 
set hsTroponin_data->algorithm_info.process_dt_tm = cnvtdatetime(curdate,curtime3) go
select into "nl:"
from
	orders o
plan o
	where o.order_id =4654573343.0
detail
	hsTroponin_data->encntr_id = o.encntr_id
	 hsTroponin_data->person_id = o.person_id
	 hsTroponin_data->order_cnt = (hsTroponin_data->order_cnt+ 1)
	stat = alterlist(hsTroponin_data->order_list,hsTroponin_data->order_cnt)
	hsTroponin_data->order_list[hsTroponin_data->order_cnt].order_id = o.order_id
with nocounter go
 
;set event_id = EnsurehsTropAlgData(hsTroponin_data->person_id,hsTroponin_data->encntr_id,0.0,cnvtrectojson(hsTroponin_data)) go
call echo(build2("event_id=",event_id)) go
;set stat = cnvtjsontorec(GethsTropAlgDataByEventID(event_id)) go
 
;set new_event_id = EnsurehsTropAlgData(19920147.0,125370972.0,event_id,cnvtrectojson(hsTroponin_data)) go
 
call echo(build2("new_event_id=",new_event_id)) go
;call echo(RemovehsTropAlgData(19920147.0,125370972.0,new_event_id)) go
 
;call echo(GetOrderIDbyCEventID(3654043723.00)) go
;call echo(GethsTropAlgListByEncntrID(hsTroponin_data->encntr_id)) go
 
call echo(FindOrderInhsTrop(4654573343.0)) go
