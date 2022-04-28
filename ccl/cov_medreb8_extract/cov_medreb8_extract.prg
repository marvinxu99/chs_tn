 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Geetha Saravanan
	Date Written:		Nov'2018
	Solution:			Pharmacy
	Source file name:	cov_pha_scorecard_extract.prg
	Object name:		cov_pha_scorecard_extract
 
	Request#:			3487
	Program purpose:	Pharmacy Score card extract.
	Executing from:		Ops
 	Special Notes:      Cerner object : chs_tn_pha_scorecard_rpt
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
  Mod Nbr	Mod Date	Developer			Comment
  -------	-------		------------------	----------------------------------
  001		02/18/2020	Dan Herren			Added Admin_Dose & Unit to output.
 
******************************************************************************/
 
DROP PROGRAM cov_medreb8_extract :dba go
CREATE PROGRAM cov_medreb8_extract :dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Generate File:" = 1
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "FacilityListBox" = 0
 
with OUTDEV, to_file, start_datetime, end_datetime, facility_list
 
/***************************************************************************
	DECLARED VARIABLES
***************************************************************************/
declare oe_freq 			= f8 with protect, constant (12690.00)
declare oe_strengthdose 	= f8 with protect, constant (12715.00)
declare oe_strengthdoseunit = f8 with protect, constant (12716.00)
declare oe_volumedose 		= f8 with protect, constant (12718.00)
declare oe_volumedoseunit 	= f8 with protect, constant (12719.00)
declare oe_drugform 		= f8 with protect, constant (12693.00)
declare oe_duration 		= f8 with protect, constant (12721.00)
declare oe_durationunit 	= f8 with protect, constant (12723.00)
declare oe_rxroute 			= f8 with protect, constant (12711.00)
declare oe_rate 			= f8 with protect, constant (12704.00)
declare oe_rate_unit 		= f8 with protect, constant (633585.00)
;
;declare frequency_code 		= f8 with protect, noconstant (0.0)
declare frequency 			= vc with protect, noconstant ("")
declare strength_dose 		= vc with protect, noconstant ("")
declare strength_dose_unit	= vc with protect, noconstant ("")
declare volume_dose 		= vc with protect, noconstant ("")
declare volume_dose_unit 	= vc with protect, noconstant ("")
declare drug_form 			= vc with protect, noconstant ("")
declare duration 			= vc with protect, noconstant ("")
declare duration_unit 		= vc with protect, noconstant ("")
declare rate 				= vc with protect, noconstant ("")
declare rate_unit 			= vc with protect, noconstant ("")
declare route 				= vc with protect, noconstant ("")
;
declare mcnt 				= i4 with protect, noconstant (0)
declare cnt 				= i4 with protect, noconstant (0)
declare idx 				= i4 with protect, noconstant (0)
;declare expand_idx 			= i4 with protect, noconstant (0)
;
declare drug_brand_name		= vc with protect, noconstant ("")
declare drug_generic_name 	= vc with protect, noconstant ("")
declare item_number 		= vc with protect, noconstant ("")
declare brandname_var 		= f8 with constant(uar_get_code_by("DISPLAY", 11000, "Brand Name")),protect
declare chargenumber_var 	= f8 with constant(uar_get_code_by("DISPLAY", 11000, "Charge Number")),protect
declare genericname_var 	= f8 with constant(uar_get_code_by("DISPLAY", 11000, "Generic Name")),protect
declare ndc_var 				= f8 with constant(uar_get_code_by("DISPLAY", 11000, "NDC")),protect
;
declare star_var        	= f8 with constant(uar_get_code_by("DISPLAY", 263, 'STAR Doctor Number')), protect
declare org_doc_var     	= f8 with constant(uar_get_code_by("DISPLAY", 320, 'ORGANIZATION DOCTOR')), protect
declare phys_attend_var 	= f8 with constant(uar_get_code_by("DISPLAY", 333, 'Attending Physician')), protect
;
declare output_orders 		= vc
;declare filename_var  		= vc with constant('cer_temp:testing_scorecard_medadmin.txt'), protect
 
;Ops setup
declare cmd  				= vc with noconstant ("")
declare len  				= i4 with noconstant (0)
declare stat 				= i4 with noconstant (0)
declare iOpsInd				= i2 with protect, noconstant (0)
 
;=================
;TESTING
;=================
;declare filename_var = vc WITH noconstant(CONCAT('cer_temp:'
;	,TRIM(cnvtlower(uar_get_displaykey($facility_list))),'_test_scorecard_medadmin.txt')), PROTECT
;
;declare ccl_filepath_var = vc WITH noconstant(CONCAT('$cer_temp/'
;	,TRIM(cnvtlower(uar_get_displaykey($facility_list))),'_test_scorecard_medadmin.txt')), PROTECT
;
;set iOpsInd = 1  ;for producing file, otherwise comment out
 
;=================
;PROD
;=================
declare filename_var = vc WITH noconstant(CONCAT('cer_temp:pha_medreb8_medadmin.txt')), PROTECT
 
declare ccl_filepath_var = vc WITH noconstant(CONCAT('$cer_temp/pha_medreb8_medadmin.txt')), PROTECT
 
declare astream_filepath_var = vc with noconstant(
				build("/nfs/middle_fs/to_client_site/",trim(cnvtlower(curdomain)),"/CernerCCL/"))
			;build("/nfs/middle_fs/to_client_site/",trim(cnvtlower(curdomain)),"/CernerCCL/")
 
;request from Ops?
if(validate(request->batch_selection) = 1)
 	set iOpsInd = 1
endif
 
 
/***************************************************************************
	RECORD STRUCTURE
***************************************************************************/
Record med_admin(
	1 med_rec_cnt 					= i4
	1 mlist[*]
		2 facility_cd 				= f8
		2 strata_facility_cd 		= vc
		2 fin 						= vc
		2 mrn 						= vc
		2 cmrn 						= vc
		2 personid 					= f8
		2 encntrid 					= f8
		2 encntr_class 				= vc
		2 encntr_type 				= vc
		2 pat_type 					= vc
		2 admit_dt 					= vc
		2 disch_dt 					= vc
		2 perform_prsnl_id 			= f8
		2 perform_username 			= vc
		2 atend_prsnl_number 		= vc
		2 ordering_phys_number 		= vc
		2 ordering_physician_name	= vc
		2 orderid 					= f8
		2 orig_orderid 				= f8
		2 action_sequence 			= i4
		2 freq_id 					= f8
		2 template_ord_id 			= f8
		2 template_ord_flag 		= i4
		2 action_type 				= vc
		2 event_id 					= f8
		2 parent_event_id 			= f8
		2 rate_event_id 			= f8
		2 item_id 					= f8
		2 event_class 				= vc
		2 event_relation 			= vc
		2 med_admin_dt 				= vc
		2 medication 				= vc
		2 ordered_mnemonic 			= vc
		2 med_status 				= vc
		2 detail_display 			= vc
		2 diluent_type 				= vc
		2 med_admin_status 			= vc
		2 admin_dose 				= f8  ;001
		2 admin_dose_unit 			= vc  ;001
		2 strength_dose 			= vc
		2 strength_dose_unit 		= vc
		2 route_of_admin_tmp 		= vc
		2 route_of_admin 			= vc
		2 synonym_id 				= f8
		2 volume_dose 				= vc
		2 volume_dose_unit 			= vc
		2 rate 						= vc
		2 rate_unit 				= vc
		2 drug_form 				= vc
		2 frequency 				= vc
		2 duration 					= vc
		2 duration_unit 			= vc
		2 quantity 					= f8
		2 quantity_unit 			= vc
		2 order_cki 				= vc
		2 drug_class_code1 			= vc
		2 drug_class_description1 	= vc
		2 drug_class_code2 			= vc
		2 drug_class_description2 	= vc
		2 drug_class_code3 			= vc
		2 drug_class_description3 	= vc
		2 drug_generic_name 		= vc
		2 drug_brand_name 			= vc
		2 item_number 				= vc
		2 med_product_id 			= f8
		2 med_admin_barcode 		= vc
		2 admin_barcode_source 		= vc
 		2 gender = i2
 		2 relationship_code = i2
 		2 state = vc
 		2 relationship_vc = vc
 		2 ndc = vc
 		2 cost = f8
)
 
/***************************************************************************
	DVDEV SOURCE CODE
***************************************************************************/
;Med administration - Clinical events
call echo("*** Med administration - Clinical events ***")
 
select distinct into 'nl:'
	 ce.encntr_id
	,ce.order_id
	,ce.event_id
	,class = uar_get_code_display(ce.event_class_cd)
	,event_reltn = uar_get_code_description(ce.event_reltn_cd)
	,med_admin_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	,Medication = ce.event_title_text
	,med_admin_status = uar_get_code_display(mae.event_type_cd)
	,admin_dose = cmr.admin_dosage
	,admin_dose_unit = uar_get_code_display(cmr.dosage_unit_cd)
	,admin_route = uar_get_code_display(cmr.admin_route_cd)
	,cmr.synonym_id
 
from
	 encounter e
	,clinical_event ce
	,med_admin_event mae
	,ce_med_result cmr
	,orders o
 
plan e where e.loc_facility_cd = $facility_list
	and e.encntr_id != 0.00
	and (
		( e.encntr_type_cd =      309308.00)
	 or ( e.financial_class_cd = 684153.00)					;Self Pay	SELFPAY
	 	)
 
 
join ce where ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
;	and e.encntr_id =   117886908.00 ;for testing
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
    and ce.view_level = 1 ;active
    and ce.publish_flag = 1 ;active
    and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
    and ce.task_assay_cd = 0
    and ce.event_reltn_cd = 132 ;child
    and ce.catalog_cd != 29285845.00 ;premix
    and ce.event_title_text != "IVPARENT"
    and ce.result_status_cd in (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
    and ce.event_class_cd in(228, 232) ;Immunization, MED
 
join mae where mae.order_id = outerjoin(ce.order_id)
 
join cmr where cmr.event_id = outerjoin(ce.event_id)
    and cmr.event_id != outerjoin(0.0)
    and cmr.valid_until_dt_tm = outerjoin(cnvtdatetime ("31-DEC-2100 00:00:00"))
    and cmr.synonym_id != outerjoin(0.0)
    and not (cmr.iv_event_cd in (736.00, 738.00)) ;rate change, waste
 
join o where o.order_id = ce.order_id
;	and o.order_id = 2445266849 ;;for testing
 
order by e.loc_facility_cd, ce.encntr_id, ce.order_id, ce.parent_event_id, ce.event_id
 
Head report
	mcnt = 0
	call alterlist(med_admin->mlist, 100)
 
Head ce.event_id
	mcnt += 1
	med_admin->med_rec_cnt = mcnt
 	call alterlist(med_admin->mlist, mcnt)
 
Detail
	med_admin->mlist[mcnt].facility_cd = e.loc_facility_cd
;	med_admin->mlist[mcnt].strata_facility_cd =
;		if(e.loc_facility_cd = 21250403.00) '20' ;FSR
;		 	elseif(e.loc_facility_cd = 2552503613.00) '24' ;MMC
;		 	elseif(e.loc_facility_cd = 2553765579.00) '65' ;G
;		 	elseif(e.loc_facility_cd = 2552503635.00) '28' ;FLMC
;		 	elseif(e.loc_facility_cd = 2552503639.00) '25' ;MHHS
;			elseif(e.loc_facility_cd = 2552503645.00) '22' ;PW
;		 	elseif(e.loc_facility_cd = 2552503649.00) '27' ;RMC
;		 	elseif(e.loc_facility_cd = 2552503653.00) '26' ;LCMC
;		endif ;002
	med_admin->mlist[mcnt].strata_facility_cd =
		if(e.loc_facility_cd = 2552503635.00) '28' ;FLMC
			elseif(e.loc_facility_cd = 21250403.00)   '20' ;FSR
		 	elseif(e.loc_facility_cd = 2553765571.00) '20' ;FSR PAT NEAL
		 	elseif(e.loc_facility_cd = 2553455025.00) '20' ;FSR SLEEP CTR
		 	elseif(e.loc_facility_cd = 2553765707.00) '20' ;FSR TCU
		 	elseif(e.loc_facility_cd = 2555024777.00) '20' ;FSR WOUND CTR
		 	elseif(e.loc_facility_cd = 2552503653.00) '26' ;LCMC
		 	elseif(e.loc_facility_cd = 2553765635.00) '26' ;LCMC SLEEP
		 	elseif(e.loc_facility_cd = 2553454905.00) '26' ;LCMC SLEEP CTR
		 	elseif(e.loc_facility_cd = 2719834165.00) '26' ;LCMC DIALYSIS CLINIC
		 	elseif(e.loc_facility_cd = 2552503639.00) '25' ;MHHS
		 	elseif(e.loc_facility_cd = 2553765467.00) '25' ;MHHS ASC
		 	elseif(e.loc_facility_cd = 2553765475.00) '25' ;MHHS BEHAV HLTH
		 	elseif(e.loc_facility_cd = 2553765483.00) '25' ;MHHS SLEEP
		 	elseif(e.loc_facility_cd = 2918486997.00) '25' ;MHHS WOUND CTR
		 	elseif(e.loc_facility_cd = 2764879815.00) '25' ;MHHS FMC DIALYSIS
		 	elseif(e.loc_facility_cd = 2552503613.00) '24' ;MMC
		 	elseif(e.loc_facility_cd = 2555024801.00) '24' ;MMC ENDO
		 	elseif(e.loc_facility_cd = 2553455257.00) '24' ;MMC SLEEP CTR
		 	elseif(e.loc_facility_cd = 2555024785.00) '24' ;MMC WOUND
		 	elseif(e.loc_facility_cd = 2553765579.00) '65' ;PBH (G)
			elseif(e.loc_facility_cd = 2552503645.00) '22' ;PW
			elseif(e.loc_facility_cd = 2553765531.00) '22' ;PW SENIOR BEHAV
			elseif(e.loc_facility_cd = 2553765539.00) '22' ;PW SLEEP CTR
		 	elseif(e.loc_facility_cd = 2552503649.00) '27' ;RMC
		endif ;002
	med_admin->mlist[mcnt].personid = ce.person_id
	med_admin->mlist[mcnt].encntrid = ce.encntr_id
	med_admin->mlist[mcnt].encntr_class = uar_get_code_display(e.encntr_class_cd)
	med_admin->mlist[mcnt].encntr_type = uar_get_code_display(e.encntr_type_cd)
 
	if (uar_get_code_display(e.encntr_type_class_cd) IN ('Inpatient','Preadmit','Skilled Nursing'))
		med_admin->mlist[mcnt].pat_type = 'I'
	else
		med_admin->mlist[mcnt].pat_type = 'O'
	endif
 
	med_admin->mlist[mcnt].orderid = ce.order_id
	med_admin->mlist[mcnt].orig_orderid = ce.order_id
	med_admin->mlist[mcnt].event_id = ce.event_id
	med_admin->mlist[mcnt].parent_event_id = ce.parent_event_id
	med_admin->mlist[mcnt].event_class = class
	med_admin->mlist[mcnt].event_relation = event_reltn
	med_admin->mlist[mcnt].med_admin_dt = med_admin_dt
	med_admin->mlist[mcnt].med_admin_status = med_admin_status
	med_admin->mlist[mcnt].medication = uar_get_code_display(ce.event_cd)
	med_admin->mlist[mcnt].detail_display = trim(o.order_detail_display_line,3)
	med_admin->mlist[mcnt].route_of_admin_tmp = admin_route
	med_admin->mlist[mcnt].synonym_id = cmr.synonym_id
	med_admin->mlist[mcnt].perform_prsnl_id = ce.performed_prsnl_id
	med_admin->mlist[mcnt].med_status = uar_get_code_display(o.order_status_cd)
	med_admin->mlist[mcnt].template_ord_flag = o.template_order_flag
	med_admin->mlist[mcnt].template_ord_id = o.template_order_id
	med_admin->mlist[mcnt].admin_dose = cmr.admin_dosage
	med_admin->mlist[mcnt].admin_dose_unit = uar_get_code_display(cmr.dosage_unit_cd)
 
	if(med_admin->mlist[mcnt].template_ord_flag = 4);child orders
		if(o.template_order_id != 0)
			med_admin->mlist[mcnt].orderid = o.template_order_id
		endif
	endif
 
Foot ce.event_id
 	call alterlist(med_admin->mlist, mcnt)
 
with nocounter
 
IF(med_admin->med_rec_cnt > 0)
;--------------------------------------- RATE CHANGE ---------------------------------------------------------
;get rate change
 
call echo("*** get rate change ***")
 /*
select distinct into 'nl:'
 
	ce.order_id, ce.parent_event_id, ce.event_id, cmr.infusion_rate, cmr.iv_event_cd
 
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
	,clinical_event ce
	,ce_med_result cmr
 
plan d
 
join ce where ce.order_id = med_admin->mlist[d.seq].orig_orderid
	and ce.parent_event_id = med_admin->mlist[d.seq].parent_event_id
      and ce.event_title_text = "IVPARENT"
 
join cmr where cmr.event_id = ce.event_id
    and cmr.event_id != 0.00
   ; and cmr.iv_event_cd = 736.00 ;rate change
 
order by ce.order_id, ce.parent_event_id, ce.event_id
 
Head ce.parent_event_id
	idx = 0
	cnt = 0
    idx = locateval(cnt ,1 ,med_admin->med_rec_cnt ,ce.parent_event_id ,med_admin->mlist[cnt].parent_event_id)
 
    while(idx > 0)
		med_admin->mlist[idx].rate_event_id = ce.event_id
		med_admin->mlist[idx].rate = cnvtstring(cmr.infusion_rate, 15,2)
		med_admin->mlist[idx].rate_unit = uar_get_code_display(cmr.infusion_unit_cd)
	    idx = locateval(cnt,(idx+1) ,med_admin->med_rec_cnt ,ce.parent_event_id ,med_admin->mlist[cnt].parent_event_id)
    endwhile
 
Foot ce.parent_event_id
    null
 
With nocounter ,expand = 1
*/
;----------------------------  FREQUENCY - START -------------------------------------------------------------
;get frequency_id for all orders
call echo("*** get frequency_id for all orders ***")
/*
select distinct into 'nl:'
 
	 od.order_id, od.action_sequence, med_admin->mlist[d.seq].medication
	,med_admin_dt = med_admin->mlist[d.seq].med_admin_dt, event_id = med_admin->mlist[d.seq].event_id
	,od.oe_field_display_value
 
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
	,order_detail od
 
plan d
 
join od where od.order_id = med_admin->mlist[d.seq].orig_orderid
	and od.oe_field_id = 2553779337.00 ;FREQSCHEDID
 
order by od.order_id, od.oe_field_id, med_admin_dt
 
Head od.order_id
	idx = 0
	cnt = 0
    idx = locateval(cnt ,1 ,med_admin->med_rec_cnt ,od.order_id ,med_admin->mlist[cnt].orig_orderid)
 
    while(idx > 0)
		med_admin->mlist[idx].freq_id = od.oe_field_value
	    idx = locateval(cnt,(idx+1) ,med_admin->med_rec_cnt ,od.order_id ,med_admin->mlist[cnt].orig_orderid)
    endwhile
 
Foot od.order_id
    null
 
With nocounter ,expand = 1
*/
;-------------------------------------------------------------------------------------------------------------
;get action sequence from parent (parent order_id)
call echo("*** get action sequence from parent (parent order_id) ***")
/*
select distinct into 'nl:'
 
	 parent = med_admin->mlist[d.seq].orderid
	,child = med_admin->mlist[d.seq].orig_orderid, od.oe_field_display_value, od.action_sequence
 
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
	,order_detail od
 
plan d
 
join od where od.order_id = med_admin->mlist[d.seq].orderid
	and od.oe_field_id =  2553779337.00 ;FREQSCHEDID
	and od.oe_field_value = med_admin->mlist[d.seq].freq_id
 
order by parent, child, od.oe_field_value, od.action_sequence
 
Head child
	idx = 0
	cnt = 0
    idx = locateval(cnt ,1 ,med_admin->med_rec_cnt ,child ,med_admin->mlist[cnt].orig_orderid)
 
    while(idx > 0)
		med_admin->mlist[idx].action_sequence = od.action_sequence
	    idx = locateval(cnt,(idx+1) ,med_admin->med_rec_cnt ,child ,med_admin->mlist[cnt].orig_orderid)
    endwhile
 
Foot  child
    null
 
With nocounter ,expand = 1
*/
;-------------------------------------------------------------------------------------------------------------
;get FREQ from order detail (parent order_id)
call echo("*** get FREQ from order detail (parent order_id) ***")
 
/*
select distinct into 'nl:'
 
	 parent_oid = med_admin->mlist[d.seq].orderid
	,child_oid = med_admin->mlist[d.seq].orig_orderid
	,action = med_admin->mlist[d.seq].action_sequence
	,freq_id = med_admin->mlist[d.seq].freq_id
	,od.oe_field_display_value
 
from
 	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
 	,order_detail od
 	,order_action oa
 
plan d
 
join od where od.order_id = med_admin->mlist[d.seq].orderid
	and od.action_sequence = med_admin->mlist[d.seq].action_sequence
	and od.oe_field_id = 12690.00 ;FREQ
	;and od.order_id = 556583049
 
join oa where oa.order_id = med_admin->mlist[d.seq].orderid
	and oa.action_sequence = med_admin->mlist[d.seq].action_sequence
 
order by parent_oid, child_oid, od.oe_field_display_value
 
Head parent_oid
	null
 
Head child_oid
	idx = 0
	cnt = 0
    idx = locateval(cnt ,1 ,med_admin->med_rec_cnt ,child_oid ,med_admin->mlist[cnt].orig_orderid)
 
    while(idx > 0)
		med_admin->mlist[idx].frequency = od.oe_field_display_value
		med_admin->mlist[idx].detail_display = trim(oa.clinical_display_line,3)
	    idx = locateval(cnt,(idx+1) ,med_admin->med_rec_cnt ,child_oid ,med_admin->mlist[cnt].orig_orderid)
    endwhile
 
Foot  child_oid
    null
 
With nocounter ,expand = 1
 
;call echorecord(med_admin)
*/
;----------------------------  FREQUENCY - END --------------------------------------------------------------
 
 
;-------------------------------------------------------------------------------------------------------------
;get Patient Demographic
call echo("*** get Patient Demographic ***")
 
select distinct into 'NL:'
 
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
	,encounter e
	,person p
	,encntr_alias ea
	,encntr_alias ea1
 
plan d
 
join e where e.person_id = med_admin->mlist[d.seq].personid
	and e.encntr_id = med_admin->mlist[d.seq].encntrid
	and e.encntr_id != 0.00
join p
	where p.person_id = e.person_id
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1079 ;MRN
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.active_ind = 1
	and ea1.encntr_alias_type_cd = 1077 ;FIN
 
 
 
detail
 
		med_admin->mlist[d.seq].fin = ea1.alias
		med_admin->mlist[d.seq].mrn = ea.alias
		med_admin->mlist[d.seq].admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		med_admin->mlist[d.seq].disch_dt = format(e.disch_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 
 		if (cnvtupper(substring(1,1,uar_get_code_display(p.sex_cd))) = "F")
			med_admin->mlist[d.seq].gender = 2
		elseif (cnvtupper(substring(1,1,uar_get_code_display(p.sex_cd))) = "M")
			med_admin->mlist[d.seq].gender = 1
		else
			med_admin->mlist[d.seq].gender = 0
		endif
 
 
With nocounter
 
 
;-------------------------------------------------------------------------------------------------------------
;get prsnl id and CKI from orders
call echo("*** get prsnl id and CKI from orders ***")
/*
select distinct into 'NL:'
 
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
	,orders o
 
plan d
 
join o where o.order_id = med_admin->mlist[d.seq].orderid
	and o.active_ind = 1
 
order by o.order_id
 
Head o.order_id
	cnt = 0
	idx = 0
    idx = locateval(cnt,1,size(med_admin->mlist,5),o.order_id, med_admin->mlist[cnt].orderid)
    cki_pos = findstring("!" ,o.cki)
    cki_len = textlen(o.cki)
	cki_val = trim(substring((cki_pos + 1) ,cki_len ,o.cki))
 
    while(idx > 0)
		med_admin->mlist[idx].order_cki = cki_val
		med_admin->mlist[idx].ordered_mnemonic = trim(o.ordered_as_mnemonic,3)
 		idx = locateval(cnt,(idx+1),size(med_admin->mlist,5),o.order_id, med_admin->mlist[cnt].orderid)
	endwhile
 
Foot o.order_id
	null
With nocounter
*/
;--------------------------------------------------------------------------------------------------------------
; get Attending-prsnl info
call echo("*** get Attending-prsnl info ***")
/*
select into "nl:"
 
from
	 (dummyt d WITH seq = value(size(med_admin->mlist,5)))
   	,encntr_prsnl_reltn epr
    ,prsnl_alias pa
 
plan d
 
join epr where epr.encntr_id = med_admin->mlist[d.seq].encntrid
    and epr.encntr_prsnl_r_cd = phys_attend_var
 
join pa where pa.person_id = epr.prsnl_person_id
    and pa.alias_pool_cd = star_var
    and pa.prsnl_alias_type_cd = org_doc_var
 
order by epr.encntr_id
 
Head epr.encntr_id
	cnt = 0
	idx = 0
    idx = locateval(cnt,1,size(med_admin->mlist,5),epr.encntr_id, med_admin->mlist[cnt].encntrid)
    while(idx > 0)
		med_admin->mlist[idx].atend_prsnl_number = trim(pa.alias,3)
 		idx = locateval(cnt,(idx+1),size(med_admin->mlist,5),epr.encntr_id, med_admin->mlist[cnt].encntrid)
	endwhile
 
Foot  epr.encntr_id
	  null
 
with nocounter
*/
;--------------------------------------------------------------------------------------------------------------
; get order-provider info
call echo("*** get order-provider info ***")
/*
select into "nl:"
 
from
      (dummyt d WITH seq = value(size(med_admin->mlist,5)))
	  ,prsnl pr
plan d
 
join pr where pr.person_id = med_admin->mlist[d.seq].perform_prsnl_id
 
order by pr.person_id
 
Head pr.person_id
	cnt = 0
	idx = 0
    idx = locateval(cnt,1,size(med_admin->mlist,5),pr.person_id, med_admin->mlist[cnt].perform_prsnl_id)
    while(idx > 0)
		med_admin->mlist[idx].perform_username = pr.username
 		idx = locateval(cnt,(idx+1),size(med_admin->mlist,5),pr.person_id, med_admin->mlist[cnt].perform_prsnl_id)
	endwhile
 
Foot pr.person_id
	  null
 
with nocounter
*/
;----------------------------------------- ORDER DETAILS ---------------------------------------------------------
;Order Details (look up with child /original order)
call echo("*** Order Details (look up with child /original order) ***")
/*
select distinct into "NL:"
 	ord = max(od.oe_field_display_value) keep (dense_rank last order by od.action_sequence ASC)
		over (partition by med_admin->mlist[d.seq].encntrid, od.order_id, od.oe_field_id)
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
	,order_detail od
 
plan d
 
join od where od.order_id = med_admin->mlist[d.seq].orig_orderid
    and od.oe_field_id IN (oe_freq, oe_strengthdose,oe_strengthdoseunit ,oe_volumedose ,oe_volumedoseunit ,oe_drugform ,
    	oe_duration ,oe_durationunit ,oe_rate ,oe_rate_unit ,oe_rxroute)
 
order by od.order_id , od.oe_field_id
 
Head od.order_id
	frequency = '',	volume_dose = '',	volume_dose_unit = '',	drug_form = '',	duration = '',	duration_unit = ''
	rate = '',	rate_unit = '',	route = '',	strength_dose = '',	strength_dose_unit = ''
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(med_admin->mlist,5),od.order_id, med_admin->mlist[cnt].orig_orderid)
 
Head od.oe_field_id
	CASE (od.oe_field_id)
	     OF oe_freq :
			frequency = trim(ord,3)
	     OF oe_volumedose :
	     		volume_dose = trim(ord,3)
	     OF oe_volumedoseunit :
	      	volume_dose_unit = trim(ord,3)
	     OF oe_drugform :
	      	drug_form = trim(ord,3)
	     OF oe_duration :
	      	duration = trim(ord,3)
	     OF oe_durationunit :
	     		duration_unit = trim(ord,3)
	     OF oe_rate :
	            rate = trim(ord,3)
	     OF oe_rate_unit :
	      	rate_unit = trim(ord,3)
	     OF oe_rxroute :
	     		 route = trim(ord,3)
	     OF oe_strengthdose :
	      	strength_dose = trim(ord ,3)
	     OF oe_strengthdoseunit :
	     		 strength_dose_unit = trim(ord ,3)
	ENDCASE
 
Foot  od.order_id
 
	while(idx > 0)
		if(med_admin->mlist[idx].drug_form = '') med_admin->mlist[idx].drug_form = drug_form endif
 
		if(med_admin->mlist[idx].duration = '')
			med_admin->mlist[idx].duration = duration
			med_admin->mlist[idx].duration_unit = duration_unit
		endif
 
		if(med_admin->mlist[idx].rate = '')
			med_admin->mlist[idx].rate = rate
		 	med_admin->mlist[idx].rate_unit = rate_unit
		 endif
 
		if(med_admin->mlist[idx].frequency = '') med_admin->mlist[idx].frequency = frequency endif
 
		if(route != '')
			if(med_admin->mlist[idx].route_of_admin = '')
				med_admin->mlist[idx].route_of_admin = route
			endif
		endif
 
		if(strength_dose != '')
			if(med_admin->mlist[idx].strength_dose = '')
				med_admin->mlist[idx].strength_dose = strength_dose ;cnvtstring(cnvtreal(strength_dose), 15,3)
				med_admin->mlist[idx].strength_dose_unit = strength_dose_unit
			endif
		endif
 
		if(med_admin->mlist[idx].volume_dose = '')
			med_admin->mlist[idx].volume_dose = volume_dose
			med_admin->mlist[idx].volume_dose_unit = volume_dose_unit
		endif
		idx = locateval(cnt,(idx+1),size(med_admin->mlist,5),od.order_id, med_admin->mlist[cnt].orig_orderid)
	endwhile
 
with nocounter
 
*/
;------------------------------------------------------------------------------------------
;Order Details (look up with parent_order)
call echo("*** Order Details (look up with parent_order) ***")
 
/*
select distinct into "NL:"
 	ord = max(od.oe_field_display_value) keep (dense_rank last order by od.action_sequence ASC)
		over (partition by med_admin->mlist[d.seq].encntrid, od.order_id, od.oe_field_id)
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
	,order_detail od
 
plan d
 
join od where od.order_id = med_admin->mlist[d.seq].orderid
    and od.oe_field_id IN (oe_freq, oe_strengthdose,oe_strengthdoseunit ,oe_volumedose ,oe_volumedoseunit ,oe_drugform ,
    	oe_duration ,oe_durationunit ,oe_rate ,oe_rate_unit ,oe_rxroute)
 
order by od.order_id , od.oe_field_id
 
Head od.order_id
	frequency = '',	volume_dose = '',	volume_dose_unit = '',	drug_form = '',	duration = '',	duration_unit = ''
	rate = '',	rate_unit = '',	route = '',	strength_dose = '',	strength_dose_unit = ''
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(med_admin->mlist,5),od.order_id, med_admin->mlist[cnt].orderid)
 
Head od.oe_field_id
	CASE (od.oe_field_id)
	     OF oe_freq :
			frequency = trim(ord,3)
	     OF oe_volumedose :
	     		volume_dose = trim(ord,3)
	     OF oe_volumedoseunit :
	      	volume_dose_unit = trim(ord,3)
	     OF oe_drugform :
	      	drug_form = trim(ord,3)
	     OF oe_duration :
	      	duration = trim(ord,3)
	     OF oe_durationunit :
	     		duration_unit = trim(ord,3)
	     OF oe_rate :
	            rate = trim(ord,3)
	     OF oe_rate_unit :
	      	rate_unit = trim(ord,3)
	     OF oe_rxroute :
	     		 route = trim(ord,3)
	     OF oe_strengthdose :
	      	strength_dose = trim(ord ,3)
	     OF oe_strengthdoseunit :
	     		 strength_dose_unit = trim(ord ,3)
	ENDCASE
 
Foot  od.order_id
 
	while(idx > 0)
		if(med_admin->mlist[idx].drug_form = '') med_admin->mlist[idx].drug_form = drug_form endif
 
		if(med_admin->mlist[idx].duration = '')
			med_admin->mlist[idx].duration = duration
			med_admin->mlist[idx].duration_unit = duration_unit
		endif
 
		if(med_admin->mlist[idx].rate = '')
			med_admin->mlist[idx].rate = rate
		 	med_admin->mlist[idx].rate_unit = rate_unit
		 endif
 
		if(med_admin->mlist[idx].frequency = '') med_admin->mlist[idx].frequency = frequency endif
 
		if(route != '')
			if(med_admin->mlist[idx].route_of_admin = '')
				med_admin->mlist[idx].route_of_admin = route
			endif
		elseif(route = '')
			 	med_admin->mlist[idx].route_of_admin = med_admin->mlist[idx].route_of_admin_tmp
		endif
 
 
		if(strength_dose != '')
			if(med_admin->mlist[idx].strength_dose = '')
				med_admin->mlist[idx].strength_dose = strength_dose ;cnvtstring(cnvtreal(strength_dose), 15,3)
				med_admin->mlist[idx].strength_dose_unit = strength_dose_unit
			endif
		elseif(strength_dose = '')
			med_admin->mlist[idx].strength_dose = format(0.000, "#.###;p0");need to show 3 decimal places if strength is 0
		endif
 
		if(med_admin->mlist[idx].volume_dose = '')
			med_admin->mlist[idx].volume_dose = volume_dose
			med_admin->mlist[idx].volume_dose_unit = volume_dose_unit
		endif
		idx = locateval(cnt,(idx+1),size(med_admin->mlist,5),od.order_id, med_admin->mlist[cnt].orderid)
	endwhile
 
with nocounter
*/
 
;----------------------------------------------- Details end -------------------------------------------
;Medication Strength & Volume details(parent)
call echo("*** Medication Strength & Volume details(parent) ***")
/*
select distinct into 'nl:' ;$outdev
 
	qty_unit = uar_get_code_display(oi.dose_quantity_unit)
 
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
	,order_ingredient oi
 
plan d
 
join oi where oi.order_id = med_admin->mlist[d.seq].orderid
	and oi.synonym_id = med_admin->mlist[d.seq].synonym_id
	and oi.action_sequence = (select max(oi2.action_sequence) from order_ingredient oi2
		where oi2.order_id = oi.order_id)
 
order by oi.order_id
 
Head oi.order_id
	idx = 0
	vcnt = 0
	idx = locateval(vcnt,1,size(med_admin->mlist,5),oi.order_id, med_admin->mlist[vcnt].orderid)
 
	while(idx > 0)
		if(med_admin->mlist[idx].strength_dose = '0.000' or med_admin->mlist[idx].strength_dose = '')
			if(oi.strength = 0)
			 	med_admin->mlist[idx].strength_dose = cnvtstring(oi.strength, 15,3);to have three 0's after decimal
			 else
				med_admin->mlist[idx].strength_dose = cnvtstring(oi.strength)
			endif
			med_admin->mlist[idx].strength_dose_unit = uar_get_code_display(oi.strength_unit)
		endif
		if(med_admin->mlist[idx].volume_dose = '')
			med_admin->mlist[idx].volume_dose = cnvtstring(oi.volume)
			med_admin->mlist[idx].volume_dose_unit = uar_get_code_display(oi.volume_unit)
		endif
		if(med_admin->mlist[idx].quantity = 0)
			med_admin->mlist[idx].quantity = oi.dose_quantity
			med_admin->mlist[idx].quantity_unit = qty_unit
		endif
 
		idx = locateval(vcnt,(idx+1),size(med_admin->mlist,5),oi.order_id, med_admin->mlist[vcnt].orderid)
 	endwhile
 
Foot oi.order_id
	Null
 
with nocounter
*/
;--------------------------------------------------------------------------------------------------------------
;look if we have strength as dosage from ce_med_result(Insulin units stored in this table most of the time - ex.insulin lispro)
call echo("*** look if we have strength as dosage from ce_med_result ***")
/*
select distinct into 'nl:'
 
from  (dummyt d WITH seq = value(size(med_admin->mlist,5)))
	,ce_med_result cmr
 
plan d
 
join cmr where cmr.event_id = med_admin->mlist[d.seq].event_id
	and cmr.admin_dosage != 0
 
order by cmr.event_id
 
Head cmr.event_id
	idx = 0
	vcnt = 0
	idx = locateval(vcnt,1,size(med_admin->mlist,5),cmr.event_id, med_admin->mlist[vcnt].event_id)
	while(idx > 0)
		if(med_admin->mlist[idx].strength_dose = '0.000' or med_admin->mlist[idx].strength_dose = '')
			med_admin->mlist[idx].strength_dose = cnvtstring(cmr.admin_dosage, 15,3)
			med_admin->mlist[idx].strength_dose_unit = uar_get_code_display(cmr.dosage_unit_cd)
		endif
		idx = locateval(vcnt,(idx+1),size(med_admin->mlist,5),cmr.event_id, med_admin->mlist[vcnt].event_id)
 	endwhile
 
Foot cmr.event_id
	Null
 
with nocounter
*/
;--------------------------------------------------------------------------------------------------------------
;Get item_id for all Pharmacy orders & Scanned floor orders
call echo("*** Get item_id for all Pharmacy orders & Scanned floor orders ***")
/*
select distinct into 'nl:' ; into $outdev
 
     mair.event_id, mai.item_id, mai.med_product_id
    ,admin_barcode = trim(mai.med_admin_barcode)
    ,barcode_source = uar_get_code_display(mai.barcode_source_cd)
    ,fill_location = uar_get_code_display(mai.inv_fill_location_cd)
    ,mai.scan_qty
 
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
    ,ce_med_admin_ident_reltn mair
	,ce_med_admin_ident mai
 
plan d
 
join mair where mair.event_id = med_admin->mlist[d.seq].event_id
 
join mai where mai.ce_med_admin_ident_id = outerjoin(mair.ce_med_admin_ident_id)
 
Head mair.event_id
	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(med_admin->mlist,5), mair.event_id, med_admin->mlist[cnt].event_id)
	while(idx > 0)
		if(med_admin->mlist[idx].item_id = 0)
			if(mai.item_id != 0)
				med_admin->mlist[idx].item_id = mai.item_id
				if(med_admin->mlist[idx].quantity = 0)
					med_admin->mlist[idx].quantity = mai.scan_qty
				endif
				med_admin->mlist[idx].med_product_id = mai.med_product_id
				med_admin->mlist[idx].med_admin_barcode = admin_barcode
				med_admin->mlist[idx].admin_barcode_source = barcode_source
			endif
		elseif(med_admin->mlist[idx].item_id != 0)
			if(med_admin->mlist[idx].quantity = 0)
				med_admin->mlist[idx].quantity = mai.scan_qty
			endif
			med_admin->mlist[idx].med_product_id = mai.med_product_id
			med_admin->mlist[idx].med_admin_barcode = admin_barcode
			med_admin->mlist[idx].admin_barcode_source = barcode_source
		endif
		idx = locateval(cnt,(idx+1),size(med_admin->mlist,5),mair.event_id, med_admin->mlist[cnt].event_id)
	endwhile
Foot mair.event_id
	null
 
With nocounter
*/
;------------------------------------------------------------------------------------------
;Dispense Qty
call echo("*** Dispense Qty ***")
/*
select distinct into 'NL:'
 
	op.order_id, mpt.dispense_qty, dispn_unit = uar_get_code_display(mpt.base_uom_cd)
 
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
	,order_product op
	,med_def_flex mdf
	,med_package_type mpt
 
plan d
 
join op where op.order_id = med_admin->mlist[d.seq].orderid
 
join mdf where mdf.item_id = op.item_id
	and mdf.active_ind = 1
	;and mdf.flex_sort_flag = 100.00 ;Pharmacy
	;and mdf.flex_type_cd = 665856.00 ;Pharmacy
	and mdf.pharmacy_type_cd = 638952.00 ;Inpatient
 
join mpt where mpt.med_package_type_id = mdf.med_package_type_id
	and mpt.active_ind = 1
 
order by op.order_id
 
Head op.order_id
	idx = 0
	cnt = 0
	idx = locateval(cnt,1,size(med_admin->mlist,5),op.order_id, med_admin->mlist[cnt].orderid)
	while(idx > 0)
		if(med_admin->mlist[idx].item_id = 0)
			med_admin->mlist[idx].item_id = op.item_id
		endif
		if(med_admin->mlist[idx].quantity = 0)
			med_admin->mlist[idx].quantity = mpt.dispense_qty
			med_admin->mlist[idx].quantity_unit = dispn_unit
		endif
		idx = locateval(cnt,(idx+1),size(med_admin->mlist,5),op.order_id, med_admin->mlist[cnt].orderid)
	endwhile
 
Foot op.order_id
	null
 
With nocounter
*/
 
;----------------------------------------------------------------------------------------------------
;Drug Class data
call echo("*** Drug Class data ***")
/*
select distinct into 'NL:'
 
	mcdx.drug_identifier ,
   	dc1.multum_category_id ,
   	parent_category = substring (1 ,50 ,dc1.category_name) ,
   	dc2.multum_category_id ,
   	sub_category = substring (1 ,50 ,dc2.category_name) ,
   	dc3.multum_category_id ,
   	sub_sub_category = substring (1 ,50 ,dc3.category_name)
 
from
	 mltm_category_drug_xref mcdx
	,mltm_drug_categories dc1
    ,mltm_category_sub_xref dcs1
    ,mltm_drug_categories dc2
	,mltm_category_sub_xref dcs2
    ,mltm_drug_categories dc3
 
plan dc1 where not(exists(
	(select mcsx.multum_category_id from mltm_category_sub_xref mcsx where mcsx.sub_category_id = dc1.multum_category_id)))
 
join dcs1 where dcs1.multum_category_id = dc1.multum_category_id
 
join dc2 where dc2.multum_category_id = dcs1.sub_category_id
 
join dcs2 where dcs2.multum_category_id = outerjoin(dc2.multum_category_id)
 
join dc3 where dc3.multum_category_id = outerjoin(dcs2.sub_category_id)
 
join mcdx where mcdx.multum_category_id = dc1.multum_category_id
	OR mcdx.multum_category_id = dc2.multum_category_id
	OR mcdx.multum_category_id = dc3.multum_category_id
      and expand(cnt ,1 ,med_admin->med_rec_cnt, mcdx.drug_identifier ,med_admin->mlist[cnt].order_cki)
 
order by mcdx.drug_identifier
 
Head mcdx.drug_identifier
	idx = 0
	cnt = 0
    idx = locateval(cnt ,1 ,med_admin->med_rec_cnt ,mcdx.drug_identifier ,med_admin->mlist[cnt].order_cki)
 
    while(idx > 0)
		if(dc1.multum_category_id != 0)
			med_admin->mlist[idx].drug_class_code1 = trim(cnvtstring(dc1.multum_category_id) ,3)
			med_admin->mlist[idx].drug_class_description1 = dc1.category_name
	     endif
	     if(dc2.multum_category_id != 0)
			med_admin->mlist[idx].drug_class_code2 = trim(cnvtstring(dc2.multum_category_id) ,3)
			med_admin->mlist[idx].drug_class_description2 = dc2.category_name
	     endif
	     if(dc3.multum_category_id != 0)
			med_admin->mlist[idx].drug_class_code3 = trim(cnvtstring(dc3.multum_category_id) ,3)
			med_admin->mlist[idx].drug_class_description3 = dc3.category_name
	     endif
 
         idx = locateval(cnt,(idx+1) ,med_admin->med_rec_cnt ,mcdx.drug_identifier ,med_admin->mlist[cnt].order_cki)
    endwhile
 
Foot  mcdx.drug_identifier
    null
 
With nocounter ,expand = 1
*/
;----------------------------------------------------------------------------------------------------
;Get Drug brand and RX numbers
call echo("*** Get NDCs ***")
 
select distinct into 'NL:'
 
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
	,med_identifier mi
 
plan d
 
join mi where mi.item_id = med_admin->mlist[d.seq].item_id
    and mi.primary_ind = 1
    and mi.med_product_id = 0
    and mi.med_identifier_type_cd in(ndc_var) ;brandname_var, chargenumber_var , genericname_var)
    and mi.active_ind = 1
 
order by mi.item_id, mi.med_identifier_type_cd
 
detail
med_admin->mlist[idx].ndc = mi.value
 
With nocounter ,expand = 1
 
;---------------------------------------------------------------------------------------------------------------------
;Get ordering physician details
 
/*
select into "nl:"
from
		  prsnl pr
		, prsnl_alias pa
		,(dummyt d1 with seq=output->cnt)
plan d1
join pr
	where pr.person_id = output->qual[d1.seq].prescriber_id
join pa where pa.person_id = pr.person_id
	and pa.alias_pool_cd = value(uar_get_code_by("DISPLAY", 263,"National Provider Identifier"))
	and pa.prsnl_alias_type_cd = value(uar_get_code_by("DISPLAY", 320, "National Provider Identifier"))
detail
	output->qual[d1.seq].prescriber_ident = pa.alias
with nocounter
*/
 
call echo("*** Get ordering physician details ***")
select into 'nl:'
 
	fin = med_admin->mlist[d.seq].fin, oa.order_id, order_mnemonic = med_admin->mlist[d.seq].ordered_mnemonic
	,ord_date = med_admin->mlist[d.seq].med_admin_dt
	,pr.name_full_formatted, pa.alias
 
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
	,order_action oa
	,prsnl pr
	,prsnl_alias pa
	,(dummyt d2)
 
plan d
 
join oa where oa.order_id = med_admin->mlist[d.seq].orderid
	and oa.action_sequence = 1
 
join pr where pr.person_id = oa.order_provider_id
join d2
join pa where pa.person_id = pr.person_id
	and pa.alias_pool_cd = value(uar_get_code_by("DISPLAY", 263,"National Provider Identifier"))
	and pa.prsnl_alias_type_cd = value(uar_get_code_by("DISPLAY", 320, "National Provider Identifier"))
 
detail
		med_admin->mlist[d.seq].ordering_phys_number = trim(pa.alias,3)
		med_admin->mlist[d.seq].ordering_physician_name = trim(pr.name_full_formatted)
 
with nocounter, outerjoin=d2
 
call echo("*** Get insurance relationship ***")
select into "nl:"
	from
		 encounter e
		,person_plan_reltn ppr1
		,person_person_reltn ppr2
	 	,(dummyt d1 WITH seq = value(size(med_admin->mlist,5)))
	plan d1
	join e
		where e.encntr_id = med_admin->mlist[d1.seq].encntrid
	join ppr1
		where ppr1.person_id = e.person_id
		and   ppr1.active_ind = 1
		and   cnvtdatetime(sysdate) between ppr1.beg_effective_dt_tm and ppr1.end_effective_dt_tm
	join ppr2
		where ppr2.related_person_id = ppr1.subscriber_person_id
	head report
		i = 0
	detail
		if (ppr2.person_reltn_cd = value(uar_get_code_by("MEANING",40,"SPOUSE")))
			med_admin->mlist[d1.seq].relationship_code = 2
		elseif ((ppr2.person_reltn_cd != value(uar_get_code_by("MEANING",40,"SELF"))) and (ppr2.person_reltn_cd > 0.0))
			med_admin->mlist[d1.seq].relationship_code = 3
		else
			med_admin->mlist[d1.seq].relationship_code = 1
		endif
		med_admin->mlist[d1.seq].relationship_vc = uar_get_code_display(ppr2.person_reltn_cd)
	with nocounter
 
 
call echo("*** Get Patient State ***")
 
select into "nl:"
from
		  person p
		, address a
		, encounter e
		,(dummyt d1 WITH seq = value(size(med_admin->mlist,5)))
plan d1
join e
	where e.encntr_id = med_admin->mlist[d1.seq].encntrid
join p
	where p.person_id = e.person_id
join a
	where a.parent_entity_id = p.person_id
	and   a.address_type_cd = value(uar_get_code_by("MEANING",212,"HOME"))
	and   a.active_ind = 1
	and   cnvtdatetime(sysdate) between a.beg_effective_dt_tm and a.end_effective_dt_tm
order by
	 p.person_id
	,a.beg_effective_dt_tm
detail
	med_admin->mlist[d1.seq].state = substring(1,2,cnvtupper(uar_get_code_display(a.state_cd)))
with nocounter
 
;call echorecord(med_admin)
 
;---------------------------------------------------------------------------------------------------------------------
if(iOpsInd = 1) ;Ops
 call echo("**** in ops mode ***")
 
	if($to_file = 0)  ;To File
 		call echo("**** creating output***")
 
	   	Select into value(filename_var)
 
		from (dummyt d WITH seq = value(size(med_admin->mlist,5)))
		order by d.seq
 
		;build output
		Head report
		/*QUAL_PHARMACY_IDENTIFIER = SUBSTRING(1, 30, OUTPUT->qual[D1.SEQ].pharmacy_identifier)
	, QUAL_DATE_OF_SERVICE = SUBSTRING(1, 30, OUTPUT->qual[D1.SEQ].date_of_service)
	, QUAL_PRESCRIBER_IDENT = SUBSTRING(1, 30, OUTPUT->qual[D1.SEQ].prescriber_ident)
	;, QUAL_PRESCRIBER_ID = OUTPUT->qual[D1.SEQ].prescriber_id
	, QUAL_NDC = SUBSTRING(1, 30, OUTPUT->qual[D1.SEQ].ndc)
	, QUAL_QUANTITY_DISPENSED = OUTPUT->qual[D1.SEQ].quantity_dispensed
	, QUAL_UNIT_OF_MEASURE = SUBSTRING(1, 30, OUTPUT->qual[D1.SEQ].unit_of_measure)
	, QUAL_INGREDIENT_COST = OUTPUT->qual[D1.SEQ].ingredient_cost
	, QUAL_ENCNTR_ID = OUTPUT->qual[D1.SEQ].encntr_id
	, QUAL_GENDER = OUTPUT->qual[D1.SEQ].gender
	, QUAL_STATE = SUBSTRING(1, 30, OUTPUT->qual[D1.SEQ].state)
	, QUAL_REALATIONSHIP = OUTPUT->qual[D1.SEQ].realationship
	;, QUAL_ENCNTR_ID = OUTPUT->qual[D1.SEQ].encntr_id
	;, QUAL_ITEM_ID = OUTPUT->qual[D1.SEQ].item_id
	;, QUAL_DISPENSES = OUTPUT->qual[D1.SEQ].dispenses
	*/
			file_header_var = build(
				 wrap3("Pharmacy ID")
				,wrap3("Date of Service")
				,wrap3("Prescriber ID Number")
				,wrap3("NDC Number")
				,wrap3("Quantity Dispensed")
				,wrap3("Unit of Measure")
				,wrap3("Ingredient Cost")
				,wrap3("Encounter ID")
				,wrap3("Patient Gender Code")
				,wrap3("Patient State")
				,wrap3("Relationship Code"))
 
		col 0 file_header_var
		row + 1
 
		Head d.seq
			output_orders = ""
			output_orders = build(output_orders
				,wrap3(med_admin->mlist[d.seq].strata_facility_cd)
				,wrap3(med_admin->mlist[d.seq].med_admin_dt)
				,wrap3(med_admin->mlist[d.seq].ordering_phys_number)
				,wrap3(med_admin->mlist[d.seq].ndc)
 
				,wrap3(cnvtstring(med_admin->mlist[d.seq].admin_dose,11,3))
				,wrap3(med_admin->mlist[d.seq].admin_dose_unit)
				,wrap3(cnvtstring(med_admin->mlist[d.seq].cost,11,3))
				,wrap3(cnvtstring(med_admin->mlist[d.seq].encntrid,11,2))
				,wrap3(cnvtstring(med_admin->mlist[d.seq].gender,1,1))
				,wrap3(med_admin->mlist[d.seq].state)
				,wrap3(cnvtstring(med_admin->mlist[d.seq].relationship_code,1,1)))
 
	 		output_orders = trim(output_orders, 3)
 
		Foot d.seq
		 	col 0 output_orders
		 	row + 1
 
		with time = 30, nocounter, maxcol = 32000, format = stream, formfeed = none
 
		;Move file to Astream folder
	;	set cmd = build2("cp ", ccl_filepath_var, " ", astream_filepath_var) ;copy file TESTING
	  	set cmd = build2("mv ", ccl_filepath_var, " ", astream_filepath_var) ;move file
		set len = size(trim(cmd))
	 	call dcl(cmd, len, stat)
		call echo(build2(cmd, " : ", stat))
 
	endif ;To File
 
endif ;ops
 
 
;---------------------------------------------------------------------------------------------------------------------
If($to_file = 1) ;Screen Display
 
	SELECT DISTINCT INTO value($outdev)
 
		 FACILITY 						= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].strata_facility_cd)
		,FIN 							= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].fin)
		,MRN 							= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].mrn)
		,CMRN 							= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].cmrn)
		,ENC_CLASS 						= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].encntr_class)
		,ENC_TYPE 						= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].encntr_type)
		,PAT_TYPE 						= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].pat_type)
		,ITEM_NUMBER 					= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].item_number)
	   	,event_id 						= MED_ADMIN->mlist[D1.SEQ].event_id
		,parent_event_id 				= MED_ADMIN->mlist[D1.SEQ].parent_event_id
		,ori_order_id 					= MED_ADMIN->mlist[D1.SEQ].orig_orderid
	; 	,rate_event_id 					= MED_ADMIN->mlist[D1.SEQ].rate_event_id
	; 	,charge_item_id 				= MED_ADMIN->mlist[D1.SEQ].item_id
	; 	,cki 							= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].order_cki)
	;	,synonym_id 					= MED_ADMIN->mlist[D1.SEQ].synonym_id
	; 	,action_seq 					= MED_ADMIN->mlist[D1.SEQ].action_sequence
	; 	,freq_id 						= MED_ADMIN->mlist[D1.SEQ].freq_id
		,PRESCRIPTION_NUMBER 			= MED_ADMIN->mlist[D1.SEQ].orderid
		,MED_ADMIN_DT 					= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].med_admin_dt)
		,MEDICATION_NAME 				= SUBSTRING(1, 100, MED_ADMIN->mlist[D1.SEQ].medication)
		,ORDERED_AS_MNEMONIC 			= SUBSTRING(1, 100, MED_ADMIN->mlist[D1.SEQ].ordered_mnemonic)
		,DRUG_GENERIC_NAME 				= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].drug_generic_name)
		,DRUG_BRAND_NAME 				= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].drug_brand_name)
		,MED_DETAIL_DISPLAY 			= TRIM(SUBSTRING(1, 300, MED_ADMIN->mlist[D1.SEQ].detail_display))
		,STATUS 						= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].med_status)
		,STRENGTH_DOSE 					= MED_ADMIN->mlist[D1.SEQ].admin_dose  ;001
		,STRENGTH_DOSE_UNIT 			= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].admin_dose_unit)  ;001
	;	,STRENGTH_DOSE 					= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].strength_dose)
	;	,STRENGTH_DOSE_UNIT 			= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].strength_dose_unit)
		,VOLUME_DOSE 					= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].volume_dose)
		,VOLUME_DOSE_UNIT 				= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].volume_dose_unit)
		,RATE 							= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].rate)
		,RATE_UNIT 						= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].rate_unit)
		,QUANTITY 						= MED_ADMIN->mlist[D1.SEQ].quantity
		,QUANTITY_UNIT 					= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].quantity_unit)
		,ROUTE_OF_ADMIN 				= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].route_of_admin)
		,DRUG_FORM 						= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].drug_form)
		,FREQUENCY 						= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].frequency)
		,DURATION 						= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].duration)
		,DURATION_UNIT 					= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].duration_unit)
		,MED_BARCODE_SOURCE 			= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].admin_barcode_source)
		,DRUG_CLASS_CODE1 				= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].drug_class_code1)
		,DRUG_CLASS_DESCRIPTION1 		= SUBSTRING(1, 100, MED_ADMIN->mlist[D1.SEQ].drug_class_description1)
		,DRUG_CLASS_CODE2 				= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].drug_class_code2)
		,DRUG_CLASS_DESCRIPTION2 		= SUBSTRING(1, 100, MED_ADMIN->mlist[D1.SEQ].drug_class_description2)
		,DRUG_CLASS_CODE3 				= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].drug_class_code3)
		,DRUG_CLASS_DESCRIPTION3 		= SUBSTRING(1, 100, MED_ADMIN->mlist[D1.SEQ].drug_class_description3)
		,ADMIT_DT 						= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].admit_dt)
		,DISCH_DT 						= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].disch_dt)
		,ATTENDING_PHYSICIAN_NUMBER 	= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].atend_prsnl_number)
		,ORDERING_PHYSICIAN_NUMBER 		= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].ordering_phys_number)
		,PERFORMED_PERSON_USERNAME 		= SUBSTRING(1, 30, MED_ADMIN->mlist[D1.SEQ].perform_username)
 
	FROM
		(DUMMYT   D1  WITH SEQ = VALUE(SIZE(MED_ADMIN->mlist, 5)))
 
	PLAN D1
 
	ORDER BY FACILITY, FIN, ORDERED_AS_MNEMONIC, MED_ADMIN_DT, PRESCRIPTION_NUMBER
 
	WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
endif ;Screen Display
 
 
ENDIF ;med_rec_cnt
 
 
/*****************************************************************************
	;Subroutins
/*****************************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
 
end go
 
/********
 
;-------------------------------------------------------------------------------------------------
 
;Strength_dose missing data - Tommy is validating as of 5/17/19
;5/24 As per Tommy - no need to fix the existing data but fixed in the code.
select distinct into $outdev
 patient_account_number = ea.alias, prescription_number = ce.order_id, event_id = cmr.event_id
 ,o.order_mnemonic, strength_dose = cnvtstring(cmr.admin_dosage, 15,3), strength_unit = uar_get_code_display(cmr.dosage_unit_cd)
 ,med_admin_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 from ce_med_result cmr, clinical_event ce, encntr_alias ea, orders o
 where ea.encntr_id = ce.encntr_id and ce.event_id = cmr.event_id and o.order_id = ce.order_id
 and ea.encntr_alias_type_cd = 1077
 and cmr.event_id in
 
 
********/
 
 
;*********************************************************************************************************************************
 
 
 
/*
 
/*Map facility codes to Strata code
 21250403.00     -20    ;FSR
 2552503613.00,  -24	;MMC - excluded as per Jeff Nedrow
 2553765579.00   -65    ;G
 2552503635.00,  -28	;FLMC
 2552503639.00,  -25	;MHHS
 2552503645.00,  -22 	;PW
 2552503649.00,  -27	;RMC - excluded as per Jeff Nedrow
 2552503653.00,  -26	;LCMC
 ;2552503657.00	;CMC
*/
 
 
 
/*** Knowledge Base
 
The child orders should all have the same template_order_id.
The template_order_id of the "child" orders equals the order_id of the "parent."
 
Home Med having a Template Order Flag != 0 is slim to none.
Template order flag of 1 means it has a parent order.
 
if template_order_flag = 1 then 'there will be child orders'
 
template_order_id = order_id(parent - having template_order_flag = 1)
 
***/
 
 
 
