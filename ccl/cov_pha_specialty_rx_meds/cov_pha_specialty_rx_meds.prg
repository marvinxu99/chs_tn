 
 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Feb'2019
	Solution:			Pharmacy
	Source file name:	      cov_pha_discharge_rx_meds.prg
	Object name:		cov_pha_discharge_rx_meds
 
	Request#:			3512 & 4105 combined
	Program purpose:	      Prescribed medications at patient discharge
	Executing from:		Ops
 	Special Notes:          Data feed and DA2 (Astream - Jerry Inman)
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
12/11/19    Geetha                  CR 6820 - add few more columns and setup the feed/historical data upload.
******************************************************************************/
 
drop program cov_pha_specialty_rx_meds:DBA go
create program cov_pha_specialty_rx_meds:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"      ;* Enter or select the printer or file name to send this report to.
	, "Start Discharge Date/Time" = "SYSDATE"
	, "End Discharge  Date/Time" = "SYSDATE"
	, "Drug Class Code" = 0
	, "Search Code" = ""
	, "Location" = 0
	, "Generate File:" = 1
 
with OUTDEV, start_datetime, end_datetime, class_code, code_value,
	all_cov_facilities, to_file
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
*************************************************************/
 
declare super_phys_var   = f8 with constant(uar_get_code_by('DISPLAY', 333, 'Supervising Physician')), protect
declare star_var         = f8 with constant(uar_get_code_by("DISPLAY", 263, 'STAR Doctor Number')), protect
declare org_doc_var      = f8 with constant(uar_get_code_by("DISPLAY", 320, 'ORGANIZATION DOCTOR')), protect
 
declare oe_freq             = f8 with protect ,constant (12690.00)
declare oe_strengthdose     = f8 with protect ,constant (12715.00)
declare oe_strengthdoseunit = f8 with protect ,constant (12716.00)
declare oe_volumedose       = f8 with protect ,constant (12718.00)
declare oe_volumedoseunit   = f8 with protect ,constant (12719.00)
declare oe_drugform         = f8 with protect ,constant (12693.00)
declare oe_duration         = f8 with protect ,constant (12721.00)
declare oe_durationunit     = f8 with protect ,constant (12723.00)
declare oe_rxroute          = f8 with protect ,constant (12711.00)
declare oe_rate             = f8 with protect ,constant (12704.00)
declare oe_rate_unit        = f8 with protect ,constant (633585.00)
declare oe_disp_qty         = f8 with protect ,constant (12694.00)
declare oe_disp_unit        = f8 with protect ,constant (633598.00)
declare oe_no_refill        = f8 with protect ,constant (12628.00)
declare oe_tot_refill       = f8 with protect ,constant (634309.00)
declare oe_start_dt         = f8 with protect ,constant (12620.00)
declare oe_stop_dt          = f8 with protect ,constant (12731.00)
declare oe_prn_inst         = f8 with protect ,constant (633597.00)
declare oe_indicat          = f8 with protect ,constant (12590.00)
declare oe_pharm_route      = f8 with protect ,constant (4056695.00)
declare oe_pharmacy         = f8 with protect ,constant (4376093.00)
declare oe_eRx_note         = f8 with protect ,constant (19908153.00)
 
declare frequency_code      = f8 with protect ,noconstant (0.0 )
declare frequency           = vc with protect ,noconstant ("" )
declare strength_dose       = vc with protect ,noconstant ("" )
declare strength_dose_unit  = vc with protect ,noconstant ("" )
declare volume_dose         = vc with protect ,noconstant ("" )
declare volume_dose_unit    = vc with protect ,noconstant ("" )
declare drug_form           = vc with protect ,noconstant ("" )
declare duration            = vc with protect ,noconstant ("" )
declare duration_unit       = vc with protect ,noconstant ("" )
declare rate                = vc with protect ,noconstant ("" )
declare rate_unit           = vc with protect ,noconstant ("" )
declare route               = vc with protect ,noconstant ("" )
declare disp_qty            = vc with protect ,noconstant ("" )
declare disp_unit           = vc with protect ,noconstant ("" )
declare no_refill           = vc with protect ,noconstant ("" )
declare tot_refill          = vc with protect ,noconstant ("" )
declare start_dt            = vc with protect ,noconstant ("" )
declare stop_dt             = vc with protect ,noconstant ("" )
declare prn_inst            = vc with protect ,noconstant ("" )
declare indicat             = vc with protect ,noconstant ("" )
declare pharm_route         = vc with protect ,noconstant ("" )
declare pharmacy            = vc with protect ,noconstant ("" )
declare eRx_note            = vc with protect ,noconstant ("" )
 
declare mcnt = i4 with noconstant(0), protect
declare cnt  = i4 with noconstant(0),protect
declare idx  = i4 with protect ,noconstant (0 )
declare expand_idx = i4 with protect ,noconstant (0 )
declare j = i4 with noconstant(0), protect
declare i = i4 with noconstant(0), protect
declare k = i4 with noconstant(0), protect
 
 
;Ops setup
declare output_orders = vc
declare cmd  = vc with noconstant("")
declare len  = i4 with noconstant(0)
declare stat = i4 with noconstant(0)
declare iOpsInd      = i2 WITH NOCONSTANT(0), PROTECT
 
;declare filename_var = vc WITH constant('cer_temp:pha_rx_test1.txt'), PROTECT
;declare ccl_filepath_var = vc WITH constant('$cer_temp/pha_rx_test1.txt'), PROTECT
 
declare filename_var = vc WITH constant(concat('cer_temp:pha_specialty',format(sysdate,"yyyymmdd_hhmmss;;q"),'_rx.txt')), PROTECT
 
declare ccl_filepath_var = vc WITH constant(
		concat('$cer_temp/pha_specialty',format(sysdate,"yyyymmdd_hhmmss;;q"),'_rx.txt')), PROTECT
declare astream_filepath_var = vc
	with noconstant("/cerner/w_custom/p0665_cust/to_client_site/CernerCCL/")
 
;request from Ops?
if(validate(request->batch_selection) = 1)
 	set iOpsInd = 1
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
RECORD rx(
	1 rx_rec_cnt = i4
	1 olist[*]
		2 facility = vc
		2 facility_cd = f8
		2 federal_tax_id = vc
		2 nurse_unit = vc
		2 fin = vc
		2 mrn = vc
		2 personid = f8
		2 encntrid = f8
		2 patient_name = vc
		2 orderid = f8
		2 medication_name = vc
		2 order_date = vc
		2 synonymid = f8
		2 charge_number = vc
		2 status = vc
		2 strength_dose = vc
		2 strength_dose_unit = vc
		2 route_of_admin_tmp = vc
		2 route_of_admin = vc
		2 volume_dose = vc
		2 volume_dose_unit = vc
		2 rate = vc
		2 rate_unit = vc
		2 drug_form = vc
		2 frequency = vc
		2 duration = vc
		2 duration_unit = vc
		2 quantity = f8
		2 quantity_unit = vc
		2 disp_qty = vc
		2 disp_unit = vc
		2 no_refil = vc
		2 tot_refil = vc
		2 prescriber = vc
		2 prescriber_id = f8
		2 prescriber_number = vc
		2 supervising_phys = vc
		2 supervising_phys_id = f8
		2 supervising_phys_number = vc
		2 order_cki = vc
		2 drug_class_code1 = vc
		2 drug_class_description1 = vc
		2 drug_class_code2 = vc
		2 drug_class_description2 = vc
		2 drug_class_code3 = vc
		2 drug_class_description3 = vc
		2 drug_generic_name = vc
		2 drug_brand_name = vc
		2 item_number = vc
		2 special_instruction = vc
 		2 med_start_date = vc
 		2 med_stop_date = vc
 		2 prn_instruction = vc
 		2 indication = vc
 		2 pharmacy_route = vc
 		2 pharmacy_name = vc
 		2 eRx_note_pharmacy = vc
 		2 ROUTINGPHARMACYID = vc
 		2 NCPDP = vc
 		2 NPI = vc
 		2 Address = vc
 		2 state = vc
 		2 zipcode = vc
 		2 city = vc
)
 
free record 3202501_request
record 3202501_request (
  1 active_status_flag = i2
  1 transmit_capability_flag = i2
  1 ids [*]
    2 id = vc
)
;--------------------------------------------------------------------------------------------------------------
;Order qualification - changes need to be in both section(if statement)
 
select if($all_cov_facilities = 0)
 
Facility = uar_get_code_display(e.loc_facility_cd)
, fin = ea.alias
, pat_name = p.name_full_formatted
, order_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
, med = o.ordered_as_mnemonic
, status = uar_get_code_display(o.order_status_cd)
, o.order_id
 
from
	encounter e
	, orders o
	, order_action oa
	, encntr_alias ea
	, encntr_alias ea1
	, person p
	, prsnl pr
	, prsnl pr1
 
plan e where e.loc_facility_cd != 0.00
	and e.active_ind = 1
	and e.encntr_id != 0
 
join o where o.encntr_id = e.encntr_id ;grab all rx orders regardless of order status
	and o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and o.orig_ord_as_flag = 1 ;Prescription/Discharge Order
	and o.active_ind = 1
	and o.activity_type_cd = 705.00 ;Pharmacy
 
join oa where oa.order_id = o.order_id
	and oa.action_sequence = o.last_action_sequence
 
join ea where ea.encntr_id = e.encntr_id
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.active_ind = 1
	and ea1.encntr_alias_type_cd = 1079
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join pr where pr.person_id = oa.order_provider_id
	and pr.active_ind = 1
 
join pr1 where pr1.person_id = outerjoin(oa.supervising_provider_id)
	and pr1.active_ind = outerjoin(1)
 
order by facility, fin, order_dt, o.order_id
 
else ; only for selected facility thru prompt
 
Facility = uar_get_code_display(e.loc_facility_cd)
, fin = ea.alias
, pat_name = p.name_full_formatted
, order_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
, med = o.ordered_as_mnemonic
, status = uar_get_code_display(o.order_status_cd)
, o.order_id
 
from
	encounter e
	, orders o
	, order_action oa
	, encntr_alias ea
	, encntr_alias ea1
	, person p
	, prsnl pr
	, prsnl pr1
 
plan e where e.loc_facility_cd = $all_cov_facilities
	and e.active_ind = 1
	and e.encntr_id != 0
 
join o where o.encntr_id = e.encntr_id ;grab all rx orders regardless of order status
	and o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and o.orig_ord_as_flag = 1 ;Prescription/Discharge Order
	and o.active_ind = 1
	and o.activity_type_cd = 705.00 ;Pharmacy
 
join oa where oa.order_id = o.order_id
	and oa.action_sequence = o.last_action_sequence
 
join ea where ea.encntr_id = e.encntr_id
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.active_ind = 1
	and ea1.encntr_alias_type_cd = 1079
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join pr where pr.person_id = oa.order_provider_id
	and pr.active_ind = 1
 
join pr1 where pr1.person_id = outerjoin(oa.supervising_provider_id)
	and pr1.active_ind = outerjoin(1)
 
order by facility, fin, order_dt, o.order_id
 
endif ;facility prompt
 
distinct into 'nl:'
 
Head report
 	cnt = 0
	call alterlist(rx->olist, 100)
 
Head o.order_id
 	cnt += 1
 	rx->rx_rec_cnt = cnt
	call alterlist(rx->olist, cnt)
 
Detail
      cki_pos = findstring("!" ,o.cki )
      cki_len = textlen(o.cki)
	cki_val = trim(substring((cki_pos + 1 ) ,cki_len ,o.cki))
 	rx->olist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
 	rx->olist[cnt].facility_cd = e.loc_facility_cd
 	rx->olist[cnt].nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
 	rx->olist[cnt].personid = e.person_id
 	rx->olist[cnt].encntrid = e.encntr_id
 	rx->olist[cnt].fin = ea.alias
 	rx->olist[cnt].mrn = ea1.alias
 	rx->olist[cnt].patient_name = p.name_full_formatted
 	rx->olist[cnt].orderid = o.order_id
 	rx->olist[cnt].synonymid = o.synonym_id
 	rx->olist[cnt].medication_name = o.ordered_as_mnemonic
 	rx->olist[cnt].order_date = order_dt
 	rx->olist[cnt].status = uar_get_code_display(o.order_status_cd)
 	rx->olist[cnt].prescriber = pr.name_full_formatted
 	rx->olist[cnt].prescriber_id = oa.order_provider_id
 	rx->olist[cnt].supervising_phys = pr1.name_full_formatted
 	rx->olist[cnt].supervising_phys_id = oa.supervising_provider_id
	rx->olist[cnt].order_cki = cki_val
	rx->olist[cnt].special_instruction = o.simplified_display_line
 
Foot o.order_id
	call alterlist(rx->olist, cnt)
 
with nocounter
 
;call echorecord(rx->olist)
 
;-------------------------------------------------------------------------------------------------
;Get organization and Federal_tax_id
select into 'nl:'
from
	(dummyt d WITH seq = value(size(rx->olist,5)))
	,location l
	,organization org
 
plan d
 
join l where l.location_cd = rx->olist[d.seq].facility_cd
 
join org where org.organization_id = l.organization_id
 
Head l.location_cd
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,rx->rx_rec_cnt ,l.location_cd ,rx->olist[cnt].facility_cd)
 
	while(idx > 0 )
		rx->olist[idx].federal_tax_id = org.federal_tax_id_nbr
		idx = locateval(cnt,(idx+1) ,rx->rx_rec_cnt ,l.location_cd ,rx->olist[cnt].facility_cd)
	endwhile
 
with nocounter
 
;go to exitscript
 
;-------------------------------------------------------------------------------------------------
 
;Order Details
 
select distinct into "NL:"
 ord = max(od.oe_field_display_value) keep (dense_rank last order by od.action_sequence ASC)
		over (partition by rx->olist[d.seq].encntrid, od.order_id, od.oe_field_id)
from
	(dummyt d WITH seq = value(size(rx->olist,5)))
	,order_detail od
 
plan d
 
join od where od.order_id = rx->olist[d.seq].orderid
    and od.oe_field_id IN (oe_freq, oe_strengthdose,oe_strengthdoseunit ,oe_volumedose ,oe_volumedoseunit ,oe_drugform ,
    	oe_duration ,oe_durationunit ,oe_rate ,oe_rate_unit ,oe_rxroute, oe_disp_qty, oe_disp_unit, oe_no_refill,
    	oe_tot_refill, oe_start_dt, oe_stop_dt, oe_prn_inst, oe_indicat, oe_pharm_route, oe_pharmacy, oe_eRx_note)
 
order by od.order_id , od.oe_field_id
 
Head od.order_id
 
	frequency = '',volume_dose = '',volume_dose_unit = '',drug_form = '',duration = '',	duration_unit = '', rate = '',
	rate_unit = '',route = '',strength_dose = '',strength_dose_unit = '', disp_qty = '', disp_unit= '', no_refill = '',
	tot_refill = '', start_dt = '', stop_dt = '', prn_inst = '', indicat = '', pharm_route = '', pharmacy = '', eRx_note = ''
 	cnt = 0
	idx = 0
	idx = locateval(cnt,1,size(rx->olist,5),od.order_id, rx->olist[cnt].orderid)
 
Head od.oe_field_id
	CASE (od.oe_field_id )
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
	      	strength_dose = trim(ord ,3 )
	     OF oe_strengthdoseunit :
	     		 strength_dose_unit = trim(ord ,3 )
	     OF oe_disp_qty :
     		 	disp_qty = trim(ord,3)
 	     OF oe_disp_unit :
     		 	disp_unit = trim(ord,3)
	     OF oe_no_refill :
     		 	no_refill = trim(ord,3)
	     OF oe_tot_refill :
     		 	tot_refill = trim(ord,3)
	     OF oe_start_dt :
    		 	start_dt = trim(ord,3)
    	     OF oe_stop_dt :
    		 	stop_dt = trim(ord,3)
	     OF oe_prn_inst :
     		 	prn_inst = trim(ord,3)
	     OF oe_indicat :
     		 	indicat = trim(ord,3)
     	     OF oe_pharm_route:
     	     		pharm_route = trim(ord,3)
	     OF oe_pharmacy :
     		 	pharmacy = trim(ord,3)
     	     OF oe_eRx_note :
     		 	eRx_note = trim(ord,3)
	ENDCASE
 
Foot  od.order_id
 
	while(idx > 0)
		rx->olist[idx].drug_form = drug_form
 		rx->olist[idx].duration = duration
		rx->olist[idx].duration_unit = duration_unit
		rx->olist[idx].rate = rate
	 	rx->olist[idx].rate_unit = rate_unit
		rx->olist[idx].frequency = frequency
		rx->olist[idx].route_of_admin = route
		rx->olist[idx].strength_dose = strength_dose ;cnvtstring(cnvtreal(strength_dose), 15,3)
		rx->olist[idx].strength_dose_unit = strength_dose_unit
		rx->olist[idx].volume_dose = volume_dose
		rx->olist[idx].volume_dose_unit = volume_dose_unit
		rx->olist[idx].disp_qty = disp_qty
		rx->olist[idx].disp_unit = disp_unit
		rx->olist[idx].no_refil = no_refill
		rx->olist[idx].tot_refil = tot_refill
		rx->olist[idx].med_start_date = start_dt
		rx->olist[idx].med_stop_date = stop_dt
		rx->olist[idx].prn_instruction = prn_inst
		rx->olist[idx].indication = indicat
		rx->olist[idx].pharmacy_route = pharm_route
		rx->olist[idx].pharmacy_name = pharmacy
		rx->olist[idx].eRx_note_pharmacy = eRx_note
		idx = locateval(cnt,(idx+1),size(rx->olist,5),od.order_id, rx->olist[cnt].orderid)
	endwhile
 
with nocounter
 
;----------------------------------------------------------------------------------------------------
;Get physicians details
 
select into 'nl:'
 
orderid = rx->olist[d.seq].orderid
 
from	(dummyt d WITH seq = value(size(rx->olist,5)))
	, prsnl pr
	, prsnl_alias pa
 	, prsnl pr1
	, prsnl_alias pa1
 
plan d
 
join pr where pr.person_id = outerjoin(rx->olist[d.seq].prescriber_id)
 
join pa where pa.person_id = outerjoin(pr.person_id)
	and pa.alias_pool_cd = outerjoin(star_var)
	and pa.prsnl_alias_type_cd = outerjoin(org_doc_var)
 
join pr1 where pr1.person_id = outerjoin(rx->olist[d.seq].supervising_phys_id)
 
join pa1 where pa1.person_id = outerjoin(pr1.person_id)
	and pa1.alias_pool_cd = outerjoin(star_var)
	and pa1.prsnl_alias_type_cd = outerjoin(org_doc_var)
 
order by orderid
 
Head orderid
	cnt = 0
	idx = 0
      idx = locateval(cnt,1,size(rx->olist,5),orderid, rx->olist[cnt].orderid)
      if(idx > 0)
		rx->olist[idx].prescriber_number = trim(pa.alias,3)
		rx->olist[idx].supervising_phys_number = trim(pa1.alias,3)
	endif
 
with nocounter
 
;----------------------------------------------------------------------------------------------------
;Get charge/RX number (CDM) ***** not used as it contains multiple manufacturer id's
 
/*
select distinct mi.*
from orders o, order_catalog_item_r oci, med_identifier mi
where o.order_id = 1739171865.00
and oci.catalog_cd = o.catalog_cd
and mi.item_id = oci.item_id
and mi.med_identifier_type_cd = 3096.00 ;Charge Number CDM
and mi.active_ind = 1
*/
 
/*
select into 'nl:'
 
from  (dummyt d WITH seq = value(size(rx->olist,5)))
	, order_product op
	, med_identifier mi
 
plan d
 
join op where op.order_id = rx->olist[d.seq].orderid
 
join mi where mi.item_id = op.item_id
	and mi.med_identifier_type_cd = 3096.00 ;Charge Number CDM
	and mi.active_ind = 1
 
order	by op.order_id
 
Head op.order_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,rx->rx_rec_cnt ,op.order_id ,rx->olist[cnt].orderid)
 
	while(idx > 0 )
		rx->olist[idx].charge_number = trim(mi.value ,3)
		idx = locateval(cnt,(idx+1) ,rx->rx_rec_cnt ,op.order_id ,rx->olist[cnt].orderid)
	endwhile
 
with nocounter
 */
;----------------------------------------------------------------------------------------------------
;Get Pharmacy info for missing pharmacy name(patient level if it is not available in order level)
 /* 7/9/19 as of today all info exist in order_detail table so commenting this off
 
select into 'nl:'
 
pp.person_id, gmc.pharmacy_name, gmc.prescriber_name
 
from 	(dummyt d WITH seq = value(size(rx->olist,5)))
	,person_preferred_pharmacy pp
	,gs_med_claim gmc
 
plan d
 
join pp where pp.person_id = rx->olist[d.seq].personid
	and pp.active_ind = 1
 
join gmc where gmc.person_id = pp.person_id
	and gmc.pharmacy_identifier = pp.preferred_pharmacy_uid
	and gmc.active_ind = 1
 
Head pp.person_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,rx->rx_rec_cnt ,pp.person_id ,rx->olist[cnt].personid)
 
	while(idx > 0 )
		if(trim(rx->olist[idx].pharmacy_name) = ' ' and trim(rx->olist[idx].pharmacy_route) != 'Print Requisition'
			and trim(rx->olist[idx].pharmacy_route) != 'Do Not Route' )
			rx->olist[idx].pharmacy_name = trim(gmc.pharmacy_name)
		endif
		idx = locateval(cnt,(idx+1) ,rx->rx_rec_cnt ,pp.person_id ,rx->olist[cnt].personid)
	endwhile
 
with nocounter
 */
;----------------------------------------------------------------------------------------------------
;Drug Class data
select distinct into 'NL:'
 
  mcdx.drug_identifier ,
   dc1.multum_category_id ,
   parent_category = substring (1 ,50 ,dc1.category_name ) ,
   dc2.multum_category_id ,
   sub_category = substring (1 ,50 ,dc2.category_name ) ,
   dc3.multum_category_id ,
   sub_sub_category = substring (1 ,50 ,dc3.category_name )
 
from
	 mltm_category_drug_xref mcdx
	, mltm_drug_categories dc1
      , mltm_category_sub_xref dcs1
      , mltm_drug_categories dc2
	, mltm_category_sub_xref dcs2
      , mltm_drug_categories dc3
 
plan dc1 where not(exists(
	(select mcsx.multum_category_id from mltm_category_sub_xref mcsx where mcsx.sub_category_id = dc1.multum_category_id )))
 
join dcs1 where dcs1.multum_category_id = dc1.multum_category_id
 
join dc2 where dc2.multum_category_id = dcs1.sub_category_id
 
join dcs2 where dcs2.multum_category_id = outerjoin(dc2.multum_category_id )
 
join dc3 where dc3.multum_category_id = outerjoin(dcs2.sub_category_id )
 
join mcdx where mcdx.multum_category_id = dc1.multum_category_id
	OR mcdx.multum_category_id = dc2.multum_category_id
	OR mcdx.multum_category_id = dc3.multum_category_id
      and expand(cnt ,1 ,rx->rx_rec_cnt, mcdx.drug_identifier ,rx->olist[cnt].order_cki )
 
order by mcdx.drug_identifier
 
Head mcdx.drug_identifier
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,rx->rx_rec_cnt ,mcdx.drug_identifier ,rx->olist[cnt].order_cki)
 
      while(idx > 0)
		if(dc1.multum_category_id != 0)
			rx->olist[idx].drug_class_code1 = trim(cnvtstring(dc1.multum_category_id ) ,3 )
			rx->olist[idx].drug_class_description1 = dc1.category_name
	     endif
	     if(dc2.multum_category_id != 0)
			rx->olist[idx].drug_class_code2 = trim(cnvtstring(dc2.multum_category_id ) ,3 )
			rx->olist[idx].drug_class_description2 = dc2.category_name
	     endif
	     if(dc3.multum_category_id != 0)
			rx->olist[idx].drug_class_code3 = trim(cnvtstring(dc3.multum_category_id ) ,3 )
			rx->olist[idx].drug_class_description3 = dc3.category_name
	     endif
 
           idx = locateval(cnt,(idx+1) ,rx->rx_rec_cnt ,mcdx.drug_identifier ,rx->olist[cnt].order_cki)
    endwhile
 
Foot  mcdx.drug_identifier
    null
 
With nocounter ,expand = 1
 
select into 'nl:'
 
orderid = rx->olist[d.seq].orderid
 
from	(dummyt d WITH seq = value(size(rx->olist,5)))
		,order_Detail od
plan d
join od
	where od.order_id = rx->olist[d.seq].orderid
	and   od.oe_field_meaning = "ROUTINGPHARMACYID"
order by
	 od.order_id
	,od.action_sequence desc
head od.order_id
	rx->olist[d.seq].ROUTINGPHARMACYID = od.oe_field_display_value
with nocounter
 
set cnt = 0
set stat = initrec(3202501_request)
set 3202501_request->active_status_flag = 1
for (i=1 to rx->rx_rec_cnt)
	if (rx->olist[i].ROUTINGPHARMACYID > " ")
		set cnt = (cnt + 1)
		set stat = alterlist(3202501_request->ids,cnt)
		set 3202501_request->ids[cnt].id = rx->olist[i].ROUTINGPHARMACYID
	endif
endfor
 
free record 3202501_reply
 
set stat = tdbexecute(3202004,3202004,3202501,"REC",3202501_request,"REC",3202501_reply)
 
for (i=1 to rx->rx_rec_cnt)
	for (j=1 to size(3202501_reply->PHARMACIES,5))
		if (rx->olist[i].ROUTINGPHARMACYID = 3202501_reply->PHARMACIES[j].ID)
			for (k=1 to size(3202501_reply->PHARMACIES[j].PHARMACYALIASES,5))
				if (3202501_reply->PHARMACIES[j].PHARMACYALIASES[k].TYPE.NCPDP_IND = 1)
					set rx->olist[i].NCPDP = 3202501_reply->PHARMACIES[j].PHARMACYALIASES[k].VALUE
				endif
				if (3202501_reply->PHARMACIES[j].PHARMACYALIASES[k].TYPE.NPI_IND = 1)
					set rx->olist[i].NPI = 3202501_reply->PHARMACIES[j].PHARMACYALIASES[k].VALUE
				endif
			endfor
			set rx->olist[i].Address = build2(
							3202501_reply->PHARMACIES[j].PRIMARY_BUSINESS_ADDRESS.STREET_ADDRESS_LINES[1].STREET_ADDRESS_LINE
							," ",
							3202501_reply->PHARMACIES[j].PRIMARY_BUSINESS_ADDRESS.CITY
							,", ",3202501_reply->PHARMACIES[j].PRIMARY_BUSINESS_ADDRESS.STATE
							," ",3202501_reply->PHARMACIES[j].PRIMARY_BUSINESS_ADDRESS.POSTAL_CODE
						)
				set rx->olist[i].zipcode = 3202501_reply->PHARMACIES[j].PRIMARY_BUSINESS_ADDRESS.POSTAL_CODE
				set rx->olist[i].city = 3202501_reply->PHARMACIES[j].PRIMARY_BUSINESS_ADDRESS.CITY
				set rx->olist[i].state = 3202501_reply->PHARMACIES[j].PRIMARY_BUSINESS_ADDRESS.STATE
		endif
	endfor
endfor
 
 
 
 
;call echorecord( 3202501_request)
;call echorecord( 3202501_reply)
;call echorecord(rx)
 
;--------------------------------------------------------------------------------------------------------------
 
if(iOpsInd = 1) ;Ops
  if($to_file = 0)  ;To File
 
   Select into value($OUTDEV)
	from (dummyt d WITH seq = value(size(rx->olist,5)))
	 where rx->olist[d.seq].pharmacy_route not in("Print Requisition","Do Not Route")
	order by d.seq
 
	;build output
	Head report
		file_header_var = build(
			wrap2("Start Date")
			,wrap2("End date")
			,wrap2("Location")
			,wrap2("Facility_cd")
			,wrap2("Federal_tax_id")
			,wrap2("Nurse unit")
			,wrap2("Hospital Account Number")
			,wrap2("mrn")
			,wrap2("order_id")
			,wrap2("synonym_id")
			,wrap2("Patient Name")
			,wrap2("Medication Name")
			,wrap2("Order Date")
			,wrap2("Ordering Phys Number");Ordering Physician
			,wrap2("Supervising Phys Number")
			,wrap2("Pharmacy_routing_type")
			,wrap2("Pharmacy_ID")
			,wrap2("Pharmacy_name")
			,wrap2("Pharmacy_Address")
			,wrap2("Pharmacy_State")
			,wrap2("Pharmacy_City")
			,wrap2("Pharmacy_Zip")
			,wrap2("Pharmacy_NPI")
			,wrap2("Pharmacy_NCPDP")
			,wrap2("status")
  			,wrap2("Strength Dose")
  			,wrap2("Strength Dose Unit")
		  	,wrap2("Route of Admin")
		  	,wrap2("Volume Dose")
		  	,wrap2("Volume Dose Unit")
		  	,wrap2("Drug Form")
		  	,wrap2("Frequency")
		  	,wrap2("Duration")
		  	,wrap2("Duration Unit")
		  	,wrap2("Dispense Qty")
		  	,wrap2("Dispense unit")
			,wrap2("number_of_refill")
			,wrap2("total_refill")
			,wrap2("special_instruction")
			,wrap2("med_start_date")
			,wrap2("med_stop_date")
			,wrap2("prn_instruction")
			,wrap2("indication")
			,wrap2("eRx_note_pharmacy")
			,wrap2("Drug Class Level 1")
			,wrap2("Drug Class Description 1")
			,wrap2("Drug Class Level 2")
			,wrap2("Drug Class Description 2")
			,wrap2("Drug Class Level 3")
			,wrap2("Drug Class Description 3")
			)
 
	col 0 file_header_var
	row + 1
 
	Head d.seq
		output_orders = ""
		output_orders = build(output_orders
			,wrap2(format(cnvtdatetime($start_datetime), 'mm/dd/yyyy hh:mm;;q'))
			,wrap2(format(cnvtdatetime($end_datetime), 'mm/dd/yyyy hh:mm;;q'))
			,wrap2(rx->olist[d.seq].facility)
			,wrap2(cnvtstring(rx->olist[d.seq].facility_cd))
			,wrap2(rx->olist[d.seq].federal_tax_id)
			,wrap2(rx->olist[d.seq].nurse_unit)
			,wrap2(rx->olist[d.seq].fin)
			,wrap2(rx->olist[d.seq].mrn)
			,wrap2(cnvtstring(rx->olist[d.seq].orderid))
			,wrap2(cnvtstring(rx->olist[d.seq].synonymid))
			,wrap2(rx->olist[d.seq].patient_name)
			,wrap2(rx->olist[d.seq].medication_name)
			,wrap2(rx->olist[d.seq].order_date)
			,wrap2(rx->olist[d.seq].prescriber_number)
			,wrap2(rx->olist[d.seq].supervising_phys_number)
			,wrap2(rx->olist[d.seq].pharmacy_route)
			,wrap2(rx->olist[d.seq].ROUTINGPHARMACYID)
			,wrap2(rx->olist[d.seq].pharmacy_name)
			,wrap2(rx->olist[d.seq].Address)
			,wrap2(rx->olist[d.seq].state)
			,wrap2(rx->olist[d.seq].city)
			,wrap2(rx->olist[d.seq].zipcode)
			,wrap2(rx->olist[d.seq].npi)
			,wrap2(rx->olist[d.seq].NCPDP)
			,wrap2(rx->olist[d.seq].status)
			,wrap2(rx->olist[d.seq].strength_dose)
			,wrap2(rx->olist[d.seq].strength_dose_unit)
			,wrap2(rx->olist[d.seq].route_of_admin)
			,wrap2(rx->olist[d.seq].volume_dose)
			,wrap2(rx->olist[d.seq].volume_dose_unit)
			,wrap2(rx->olist[d.seq].drug_form)
			,wrap2(rx->olist[d.seq].frequency)
			,wrap2(rx->olist[d.seq].duration)
			,wrap2(rx->olist[d.seq].duration_unit)
			,wrap2(rx->olist[d.seq].disp_qty)
			,wrap2(rx->olist[d.seq].disp_unit)
			,wrap2(rx->olist[d.seq].no_refil)
			,wrap2(rx->olist[d.seq].tot_refil)
			,wrap2(rx->olist[d.seq].special_instruction)
			,wrap2(rx->olist[d.seq].med_start_date)
			,wrap2(rx->olist[d.seq].med_stop_date)
			,wrap2(rx->olist[d.seq].prn_instruction)
			,wrap2(rx->olist[d.seq].indication)
			,wrap2(rx->olist[d.seq].eRx_note_pharmacy)
			,wrap2(rx->olist[d.seq].drug_class_code1)
			,wrap2(rx->olist[d.seq].drug_class_description1)
			,wrap2(rx->olist[d.seq].drug_class_code2)
			,wrap2(rx->olist[d.seq].drug_class_description2)
			,wrap2(rx->olist[d.seq].drug_class_code3)
			,wrap2(rx->olist[d.seq].drug_class_description3)
			)
 
 		output_orders = trim(output_orders, 3)
 
	 Foot d.seq
	 	col 0 output_orders
	 	row + 1
 
	with time = 30, nocounter, maxcol = 32000, format = stream, formfeed = none
 
	;Copy file to Astream folder
  	;set cmd = build2("mv ", ccl_filepath_var, " ", astream_filepath_var)
  	set cmd = build2("cp ", ccl_filepath_var, " ", astream_filepath_var)
	set len = size(trim(cmd))
 	;call dcl(cmd, len, stat)
	;call echo(build2(cmd, " : ", stat))
 
  endif ;To File
endif ;ops
 
;--------------------------------------------------------------------------------------------------------------
 
If($to_file = 1) ;Screen Display
 
if($class_code = 1)
 
	SELECT DISTINCT INTO ($OUTDEV)
	  FACILITY = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].facility))
	, NURSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].nurse_unit))
	, FIN = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].fin))
	, ORDER_CKI = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].order_cki))
	, ORDERID = RX->olist[D1.SEQ].orderid
	, SYNONYM_ID = RX->olist[D1.SEQ].synonymid
	, CHARGE_NUMBER = trim(SUBSTRING(1, 10, RX->olist[D1.SEQ].charge_number))
	, PATIENT_NAME = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].patient_name))
	, MEDICATION_NAME = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].medication_name))
	, ORDER_DATE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].order_date))
	, PRESCRIBER = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].prescriber))
	, Pharmacy_routing_type = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].pharmacy_route))
	, Pharmacy_ID = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].ROUTINGPHARMACYID))
	, Pharmacy_name = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].pharmacy_name))
	, Pharmacy_Address = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].Address))
	, Pharmacy_NPI = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].npi))
	, Pharmacy_NCPDP = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].NCPDP))
	, STATUS = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].status))
	, STRENGTH_DOSE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].strength_dose))
	, STRENGTH_DOSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].strength_dose_unit))
	, ROUTE_OF_ADMIN = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].route_of_admin))
	, VOLUME_DOSE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].volume_dose))
	, VOLUME_DOSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].volume_dose_unit))
	, DRUG_FORM = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_form))
	, FREQUENCY = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].frequency))
	, DURATION = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].duration))
	, DURATION_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].duration_unit))
	, DISPENSE_QTY = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].disp_qty))
	, DISPENSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].disp_unit))
	, NUMBER_OF_REFILL = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].no_refil))
	, TOTAL_REFILL = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].tot_refil))
	, SPECIAL_INSTRUCTION = trim(SUBSTRING(1, 300, RX->olist[D1.SEQ].special_instruction))
	, MED_START_DATE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].med_start_date))
	, MED_STOP_DATE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].med_stop_date))
	, PRN_INSTRUCTION = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].prn_instruction))
	, INDICATION = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].indication))
	, eRx_note_pharmacy = trim(SUBSTRING(1, 300, RX->olist[D1.SEQ].eRx_note_pharmacy))
	, supervising_physician = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].supervising_phys))
	, DRUG_CLASS_CODE1 = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code1))
	, DRUG_CLASS_DESCRIPTION1 = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description1))
	, DRUG_CLASS_CODE2 = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code2))
	, DRUG_CLASS_DESCRIPTION2 = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description2))
	, DRUG_CLASS_CODE3 = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code3))
	, DRUG_CLASS_DESCRIPTION3 = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description3))
 
	FROM
		(DUMMYT   D1  WITH SEQ = SIZE(RX->olist, 5))
 
	PLAN D1 where rx->olist[D1.SEQ].drug_class_code1 = $code_value
 
	ORDER BY FACILITY, ORDER_DATE, PATIENT_NAME, FIN, MEDICATION_NAME
 
	WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
elseif($class_code = 2)
 
	SELECT DISTINCT INTO ($OUTDEV)
	  FACILITY = SUBSTRING(1, 30, RX->olist[D1.SEQ].facility)
	, NURSE_UNIT = SUBSTRING(1, 30, RX->olist[D1.SEQ].nurse_unit)
	, FIN = SUBSTRING(1, 30, RX->olist[D1.SEQ].fin)
	, ORDER_CKI = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].order_cki))
	, ORDERID = RX->olist[D1.SEQ].orderid
	, SYNONYM_ID = RX->olist[D1.SEQ].synonymid
	, CHARGE_NUMBER = trim(SUBSTRING(1, 10, RX->olist[D1.SEQ].charge_number))
	, PATIENT_NAME = SUBSTRING(1, 50, RX->olist[D1.SEQ].patient_name)
	, MEDICATION_NAME = SUBSTRING(1, 200, RX->olist[D1.SEQ].medication_name)
	, ORDER_DATE = SUBSTRING(1, 30, RX->olist[D1.SEQ].order_date)
	, PRESCRIBER = SUBSTRING(1, 50, RX->olist[D1.SEQ].prescriber)
	, Pharmacy_routing_type = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].pharmacy_route))
	, Pharmacy_ID = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].ROUTINGPHARMACYID))
	, Pharmacy_name = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].pharmacy_name))
	, Pharmacy_Address = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].Address))
	, Pharmacy_NPI = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].npi))
	, Pharmacy_NCPDP = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].NCPDP))
	, STATUS = SUBSTRING(1, 30, RX->olist[D1.SEQ].status)
	, STRENGTH_DOSE = SUBSTRING(1, 30, RX->olist[D1.SEQ].strength_dose)
	, STRENGTH_DOSE_UNIT = SUBSTRING(1, 30, RX->olist[D1.SEQ].strength_dose_unit)
	, ROUTE_OF_ADMIN = SUBSTRING(1, 30, RX->olist[D1.SEQ].route_of_admin)
	, VOLUME_DOSE = SUBSTRING(1, 30, RX->olist[D1.SEQ].volume_dose)
	, VOLUME_DOSE_UNIT = SUBSTRING(1, 30, RX->olist[D1.SEQ].volume_dose_unit)
	, DRUG_FORM = SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_form)
	, FREQUENCY = SUBSTRING(1, 30, RX->olist[D1.SEQ].frequency)
	, DURATION = SUBSTRING(1, 30, RX->olist[D1.SEQ].duration)
	, DURATION_UNIT = SUBSTRING(1, 30, RX->olist[D1.SEQ].duration_unit)
	, DISPENSE_QTY = SUBSTRING(1, 30, RX->olist[D1.SEQ].disp_qty)
	, DISPENSE_UNIT = SUBSTRING(1, 30, RX->olist[D1.SEQ].disp_unit)
	, NUMBER_OF_REFILL = SUBSTRING(1, 30, RX->olist[D1.SEQ].no_refil)
	, TOTAL_REFILL = SUBSTRING(1, 30, RX->olist[D1.SEQ].tot_refil)
	, SPECIAL_INSTRUCTION = SUBSTRING(1, 300, RX->olist[D1.SEQ].special_instruction)
	, MED_START_DATE = SUBSTRING(1, 30, RX->olist[D1.SEQ].med_start_date)
	, MED_STOP_DATE = SUBSTRING(1, 30, RX->olist[D1.SEQ].med_stop_date)
	, PRN_INSTRUCTION = SUBSTRING(1, 100, RX->olist[D1.SEQ].prn_instruction)
	, INDICATION = SUBSTRING(1, 50, RX->olist[D1.SEQ].indication)
	, eRx_note_pharmacy = trim(SUBSTRING(1, 300, RX->olist[D1.SEQ].eRx_note_pharmacy))
	, supervising_physician = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].supervising_phys))
	, DRUG_CLASS_CODE1 = SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code1)
	, DRUG_CLASS_DESCRIPTION1 = SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description1)
	, DRUG_CLASS_CODE2 = SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code2)
	, DRUG_CLASS_DESCRIPTION2 = SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description2)
	, DRUG_CLASS_CODE3 = SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code3)
	, DRUG_CLASS_DESCRIPTION3 = SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description3)
 
	FROM
		(DUMMYT   D1  WITH SEQ = SIZE(RX->olist, 5))
 
	PLAN D1 where rx->olist[D1.SEQ].drug_class_code2 = $code_value
 
	ORDER BY FACILITY, ORDER_DATE, PATIENT_NAME, FIN, MEDICATION_NAME
 
	WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
elseif($class_code = 3)
 
	SELECT DISTINCT INTO ($OUTDEV)
	  FACILITY = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].facility))
	, NURSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].nurse_unit))
	, FIN = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].fin))
	, ORDER_CKI = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].order_cki))
	, ORDERID = RX->olist[D1.SEQ].orderid
	, SYNONYM_ID = RX->olist[D1.SEQ].synonymid
	, CHARGE_NUMBER = trim(SUBSTRING(1, 10, RX->olist[D1.SEQ].charge_number))
	, PATIENT_NAME = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].patient_name))
	, MEDICATION_NAME = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].medication_name))
	, ORDER_DATE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].order_date))
	, PRESCRIBER = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].prescriber))
	, Pharmacy_routing_type = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].pharmacy_route))
	, Pharmacy_ID = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].ROUTINGPHARMACYID))
	, Pharmacy_name = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].pharmacy_name))
	, Pharmacy_Address = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].Address))
	, Pharmacy_NPI = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].npi))
	, Pharmacy_NCPDP = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].NCPDP))
	, STATUS = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].status))
	, STRENGTH_DOSE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].strength_dose))
	, STRENGTH_DOSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].strength_dose_unit))
	, ROUTE_OF_ADMIN = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].route_of_admin))
	, VOLUME_DOSE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].volume_dose))
	, VOLUME_DOSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].volume_dose_unit))
	, DRUG_FORM = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_form))
	, FREQUENCY = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].frequency))
	, DURATION = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].duration))
	, DURATION_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].duration_unit))
	, DISPENSE_QTY = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].disp_qty))
	, DISPENSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].disp_unit))
	, NUMBER_OF_REFILL = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].no_refil))
	, TOTAL_REFILL = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].tot_refil))
	, SPECIAL_INSTRUCTION = trim(SUBSTRING(1, 300, RX->olist[D1.SEQ].special_instruction))
	, MED_START_DATE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].med_start_date))
	, MED_STOP_DATE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].med_stop_date))
	, PRN_INSTRUCTION = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].prn_instruction))
	, INDICATION = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].indication))
	, eRx_note_pharmacy = trim(SUBSTRING(1, 300, RX->olist[D1.SEQ].eRx_note_pharmacy))
	, supervising_physician = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].supervising_phys))
	, DRUG_CLASS_CODE1 = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code1))
	, DRUG_CLASS_DESCRIPTION1 = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description1))
	, DRUG_CLASS_CODE2 = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code2))
	, DRUG_CLASS_DESCRIPTION2 = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description2))
	, DRUG_CLASS_CODE3 = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code3))
	, DRUG_CLASS_DESCRIPTION3 = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description3))
 
	FROM
		(DUMMYT   D1  WITH SEQ = SIZE(RX->olist, 5))
 
	PLAN D1 where rx->olist[D1.SEQ].drug_class_code3 = $code_value
 
	ORDER BY FACILITY, ORDER_DATE, PATIENT_NAME, FIN, MEDICATION_NAME
 
	WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
elseif($class_code != 1 or $class_code != 2 or $class_code != 3)
 
	SELECT DISTINCT INTO ($OUTDEV)
	  FACILITY = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].facility))
	, NURSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].nurse_unit))
	, FIN = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].fin))
	, PERSONID = RX->olist[D1.SEQ].personid
	, ENCNTRID = RX->olist[D1.SEQ].encntrid
	, ORDER_CKI = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].order_cki))
	, ORDERID = RX->olist[D1.SEQ].orderid
	, SYNONYM_ID = RX->olist[D1.SEQ].synonymid
	, CHARGE_NUMBER = trim(SUBSTRING(1, 10, RX->olist[D1.SEQ].charge_number))
	, PATIENT_NAME = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].patient_name))
	, MEDICATION_NAME = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].medication_name))
	, ORDER_DATE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].order_date))
	, PRESCRIBER = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].prescriber))
	, Pharmacy_routing_type = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].pharmacy_route))
	, Pharmacy_ID = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].ROUTINGPHARMACYID))
	, Pharmacy_name = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].pharmacy_name))
	, Pharmacy_Address = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].Address))
	, Pharmacy_NPI = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].npi))
	, Pharmacy_NCPDP = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].NCPDP))
	, STATUS = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].status))
	, STRENGTH_DOSE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].strength_dose))
	, STRENGTH_DOSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].strength_dose_unit))
	, ROUTE_OF_ADMIN = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].route_of_admin))
	, VOLUME_DOSE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].volume_dose))
	, VOLUME_DOSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].volume_dose_unit))
	, DRUG_FORM = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_form))
	, FREQUENCY = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].frequency))
	, DURATION = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].duration))
	, DURATION_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].duration_unit))
	, DISPENSE_QTY = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].disp_qty))
	, DISPENSE_UNIT = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].disp_unit))
	, NUMBER_OF_REFILL = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].no_refil))
	, TOTAL_REFILL = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].tot_refil))
	, SPECIAL_INSTRUCTION = trim(SUBSTRING(1, 300, RX->olist[D1.SEQ].special_instruction))
	, MED_START_DATE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].med_start_date))
	, MED_STOP_DATE = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].med_stop_date))
	, PRN_INSTRUCTION = trim(SUBSTRING(1, 100, RX->olist[D1.SEQ].prn_instruction))
	, INDICATION = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].indication))
	, eRx_note_pharmacy = trim(SUBSTRING(1, 300, RX->olist[D1.SEQ].eRx_note_pharmacy))
	, supervising_physician = trim(SUBSTRING(1, 50, RX->olist[D1.SEQ].supervising_phys))
	, prescriber_number = trim(SUBSTRING(1, 10,RX->olist[D1.SEQ].prescriber_number))
	, supervising_phy_number = trim(SUBSTRING(1, 10,RX->olist[D1.SEQ].supervising_phys_number))
	, DRUG_CLASS_CODE1 = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code1))
	, DRUG_CLASS_DESCRIPTION1 = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description1))
	, DRUG_CLASS_CODE2 = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code2))
	, DRUG_CLASS_DESCRIPTION2 = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description2))
	, DRUG_CLASS_CODE3 = trim(SUBSTRING(1, 30, RX->olist[D1.SEQ].drug_class_code3))
	, DRUG_CLASS_DESCRIPTION3 = trim(SUBSTRING(1, 200, RX->olist[D1.SEQ].drug_class_description3))
 
	FROM
		(DUMMYT   D1  WITH SEQ = SIZE(RX->olist, 5))
 
	PLAN D1
 
	ORDER BY FACILITY, PATIENT_NAME, FIN, ORDER_DATE, MEDICATION_NAME
 
	WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
endif	;class code
 
endif ;Screen Display
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
 
end
go
 
