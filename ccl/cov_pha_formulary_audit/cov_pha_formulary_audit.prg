/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		09/08/2021
	Solution:			
	Source file name:	cov_pha_formulary_audit.prg
	Object name:		cov_pha_formulary_audit
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	09/08/2021  Chad Cummings			Initial Release (copy from ctp_pha_formulary_audit)
001     09/08/2021  Chad Cummings			added gpo
002		09/08/2021  Chad Cummings			added multum drug classes
003		09/08/2021  Chad Cummings			removed COST1 and COST2 from output
004		09/22/2021  Chad Cummings			changed tab char to comma (44)
******************************************************************************/
DROP PROGRAM cov_pha_formulary_audit :dba GO
CREATE PROGRAM cov_pha_formulary_audit :dba
 prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Primary NDCs Only (Y/N)" = "Y"
	, "Show Facility Flexing?" = 0
	, "Facility (Blank, Valid Display or Code Value)" = ""
	, "Include Multum Drug Class" = 0
	, "Advanced Options" = 0
	, "Active Products Only (Y/N)" = "Y"
	, "Active NDCS Only (Y/N)" = "Y" 

with OUTDEV, PRIMARYONLY, FACILITY_FLEX_IND, FACIILTYCODE, MULTUM_CLASS_IND, 
	ADVANCED_OPTIONS, ACTIVEPROD, ACTIVENDC
 RECORD promptdata (
   1 facilities [* ]
     2 facility_cd = f8
 ) WITH protect
 RECORD grid (
   1 row_cnt = i4
   1 row [* ]
     2 col_cnt = i4
     2 col [* ]
       3 txt = vc
       3 code_value = f8
 ) WITH protect
 RECORD data (
   1 cnt = i4
   1 qual [* ]
     2 general
       3 item_id = f8
       3 active_ind = i2
       3 ref_dose = vc
       3 legal_status = vc
       3 form = vc
     2 oe_defaults
       3 dose = vc
       3 route = vc
       3 frequency = vc
       3 infuse_over = f8
       3 infuse_over_unit = vc
       3 rate = f8
       3 rate_unit = vc
       3 normalized_rate = f8
       3 normalized_rate_unit = vc
       3 freetext_rate = vc
       3 duration = f8
       3 duration_unit = vc
       3 stop_type = vc
       3 prn = i2
       3 prn_reason = vc
       3 order_as_synonym = vc
       3 sig = vc
       3 notes1 = vc
       3 notes1_appliesto_fill = vc
       3 notes1_appliesto_label = vc
       3 notes1_appliesto_mar = vc
       3 notes2 = vc
       3 notes2_appliesto_fill = vc
       3 notes2_appliesto_label = vc
       3 notes2_appliesto_mar = vc
       3 def_format = vc
       3 medication = i2
       3 continuous = i2
       3 tpn = i2
       3 intermittent = i2
     2 dispense
       3 strength = f8
       3 strength_unit = vc
       3 volume = f8
       3 volume_unit = vc
       3 dispense_qty = f8
       3 dispense_qty_unit = vc
       3 dispense_category = vc
       3 dispense_factor = f8
       3 used_in_tot_volume = vc
       3 workflow_sequence = vc
       3 divisible = i2
       3 divisible_factor = f8
       3 infinite_divisible = i2
       3 per_pkg = f8
       3 allow_pkg_broken = i2
       3 formulary_status = vc
       3 price_schedule = vc
       3 billing_factor = f8
       3 billing_factor_unit = vc
       3 default_par_doses = i4
       3 max_par_supply = i4
       3 poc_charge_setting = vc
     2 inventory
       3 dispense_from = i2
       3 reusable = i2
       3 track_lot_numbers = i2
       3 disable_apa_aps = i2
       3 skip_dispense = i2
     2 clinical
       3 suppress_multum_ind = vc
       3 generic_formulation = vc
       3 drug_formulation = vc
       3 therapeutic_class = vc
       ;Need to add in other drug classes (1,2,3)
       3 dc_inter_days = i4
       3 dc_display_days = i4
     2 supply
       3 ndc_cnt = i4
       3 ndc_qual [* ]
         4 med_product_id = f8
         4 non_ref_ind = i2
         4 ndc = vc
         4 inner_ndc = vc
         4 primary_ind = i2
         4 manufacturer = vc
         4 manf_brand = vc
         4 manf_label_desc = vc
         4 manf_generic = vc
         4 manf_mnemonic = vc
         4 manf_pyxis = vc
         4 manf_ub92 = vc
         4 manf_rx_uniqueid = vc
         4 manf_active_ind = i2
         4 manf_formulary_status = vc
         4 base_pkg_unit = vc
         4 pkg_size = f8
         4 pkg_unit = vc
         4 outer_pkg_size = f8
         4 outer_pkg_unit = vc
         4 unit_dose_ind = i2
         4 bio_ind = i2
         4 brand_ind = i2
         4 cost_awp = vc
         4 cost_gpo = vc ;001
         4 cost_cost1 = vc
         4 cost_cost2 = vc
         4 cost_factor = f8
         4 inv_factor = f8
         4 ndc_sequence = i4
     2 identifiers
       3 brand_name = vc
       3 brand_primary_ind = vc
       3 brand_name2 = vc
       3 brand2_primary_ind = vc
       3 brand_name3 = vc
       3 brand3_primary_ind = vc
       3 charge_nbr = vc
       3 label_desc = vc
       3 generic_name = vc
       3 hcpcs = vc
       3 mnemonic = vc
       3 pyxis = vc
       3 rxdevice1 = vc
       3 rxdevice2 = vc
       3 rxdevice3 = vc
       3 rxdevice4 = vc
       3 rxdevice5 = vc
       3 rxmisc1 = vc
       3 rxmisc2 = vc
       3 rxmisc3 = vc
       3 rxmisc4 = vc
       3 rxmisc5 = vc
       3 rx_uniqueid = vc
       3 ub92 = vc
     2 misc
       3 system_number = vc
       3 inv_base_pkg_unit = vc
       3 group_rx_mnem = vc
     2 inventoryfacil
       3 facil_cnt = i4
       3 all_facilities_ind = i2
       3 facility_qual [* ]
         4 facility_cd = f8
         4 facility = vc
     2 clinicaloa
       3 oa_cnt = i4
       3 order_alert_qual [* ]
         4 order_alert_display = vc
 ) WITH protect
 RECORD locationdata (
   1 cnt = i4
   1 qual [* ]
     2 facility_cd = f8
     2 facility = vc
 ) WITH protect
 RECORD file (
   1 file_desc = i4
   1 file_name = vc
   1 file_buf = vc
   1 file_dir = i4
   1 file_offset = i4
 ) WITH protect
 
 DECLARE loaditemid ((index = i4 ) ) = null WITH protect
 DECLARE loaditemidoed ((index = i4 ) ) = null WITH protect
 DECLARE loaditemiddispense ((index = i4 ) ) = null WITH protect
 DECLARE loaditemidinventory ((index = i4 ) ) = null WITH protect
 DECLARE loaditemididentifiers ((index = i4 ) ) = null WITH protect
 DECLARE loaditemidsupply ((index = i4 ) ) = null WITH protect
 DECLARE loaditemidordalert ((index = i4 ) ) = null WITH protect
 DECLARE addvaluetxt ((r = i4 ) ,(c = i4 (ref ) ) ,(txt = vc ) ) = null WITH protect
 DECLARE addvaluetxtpivot ((r = i4 ) ,(c = i4 (ref ) ) ,(txt = vc ) ) = null WITH protect
 DECLARE addvaluereal ((r = i4 ) ,(c = i4 (ref ) ) ,(real = f8 ) ) = null WITH protect
 DECLARE addvalueint ((r = i4 ) ,(c = i4 (ref ) ) ,(int = i4 ) ) = null WITH protect
 DECLARE addcolumnheader ((c = i4 (ref ) ) ,(txt = vc ) ) = null WITH protect
 DECLARE addcolumnheaderfacil ((c = i4 (ref ) ) ,(codevalue = f8 ) ) = null WITH protect
 DECLARE addcolumnheaderoa ((c = i4 (ref ) ) ,(txt = vc ) ) = null WITH protect
 DECLARE checkreplace ((txt = vc ) ,(qualifier = vc ) ) = vc WITH protect
 DECLARE primaryonly_parser = vc WITH noconstant ("1 = 1" ) ,protect
 DECLARE activeprod_parser = vc WITH noconstant ("1 = 1" ) ,protect
 DECLARE activendc_parser = vc WITH noconstant ("1 = 1" ) ,protect
 DECLARE facility_prompt = f8 WITH noconstant (0 ) ,protect
 DECLARE 11000_brand_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3303" ) )
 DECLARE 11000_cdm_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3304" ) )
 DECLARE 11000_desc_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3290" ) )
 DECLARE 11000_desc_short_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3293") )
 DECLARE 11000_gen_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3294" ) )
 DECLARE 11000_hcpcs_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!67861" ) )
 DECLARE 11000_inner_ndc_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!4104840776" ) )
 DECLARE 11000_item_nbr_sys_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3743" ) )
 DECLARE 11000_ndc_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3295" ) )
 DECLARE 11000_pyxis_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!17120" ) )
 DECLARE 11000_rx_uniqueid_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!12198292" ) )
 DECLARE 11000_rxdevice1_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2160040" ) )
 DECLARE 11000_rxdevice2_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2160041" ) )
 DECLARE 11000_rxdevice3_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2160042" ) )
 DECLARE 11000_rxdevice4_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2160043" ) )
 DECLARE 11000_rxdevice5_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2160044" ) )
 DECLARE 11000_rxmisc1_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2160033") )
 DECLARE 11000_rxmisc2_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2160034") )
 DECLARE 11000_rxmisc3_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2160035") )
 DECLARE 11000_rxmisc4_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2160036") )
 DECLARE 11000_rxmisc5_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2160037") )
 DECLARE 11000_ub92_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!17121" ) )
 DECLARE 222_facility_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2844" ) )
 DECLARE 4050_awp_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!8940" ) )
 DECLARE 4050_gpo_cd = f8 WITH protect ,constant (uar_get_code_by("DISPLAY",4050,"GPO")) ;001
 DECLARE 4050_cost1_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!8941" ) )
 DECLARE 4050_cost2_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!8942" ) )
 DECLARE 4062_sys_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2548614" ) )
 DECLARE 4062_sysp_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2548615" ) )
 DECLARE 4063_disp_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2553256" ) )
 DECLARE 4063_medprod_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2553258" ))
 DECLARE 4063_oedef_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2553255" ) )
 DECLARE 4063_ordalert_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2553257") )
 DECLARE 4063_orderable_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2553254") )
 DECLARE 4500_inpt_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!101131" ) )
 DECLARE 48_active_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!2669" ) )
 DECLARE 6000_pharm_cd = f8 WITH protect ,constant (uar_get_code_by_cki ("CKI.CODEVALUE!3079" ) )
 
 ;004 DECLARE tab = c1 WITH protect ,constant (char (9 ) )
 DECLARE tab = c1 WITH protect ,constant (char (44 ) )	;004
 
 DECLARE lf = c1 WITH protect ,constant (char (10 ) )
 DECLARE q = c1 WITH protect ,constant ('"' )
 DECLARE clean_txt = vc WITH protect ,noconstant (" " )
 DECLARE line = vc WITH protect ,noconstant (" " )
 DECLARE index = i4 WITH protect ,noconstant (0 )
 DECLARE i = i4 WITH protect ,noconstant (0 )
 DECLARE static_col = i4 WITH protect ,constant (122 )
 DECLARE expand_cnt = i4 WITH protect ,noconstant (0 )
 DECLARE itemid_index = i4 WITH protect ,noconstant (0 )
 DECLARE facility_index = i4 WITH protect ,noconstant (0 )
 DECLARE column_index = i4 WITH protect ,noconstant (0 )
 DECLARE search_facility = f8 WITH protect ,noconstant (0 )
 DECLARE tot_oa_col = i4 WITH protect ,noconstant (0 )
 DECLARE oa_index = i4 WITH protect ,noconstant (0 )
 
 IF ((cnvtupper (trim ( $PRIMARYONLY ,3 ) ) IN ("YES" ,"Y" ,"1" ) ) )
  SET primaryonly_parser = build ("mfoi.sequence = 1" )
 ELSEIF ((cnvtupper (trim ( $PRIMARYONLY ,3 ) ) IN ("NO" ,"N" ,"0" ) ) )
  SET primaryonly_parser = build ("1 = 1" )
 ELSE
  SELECT INTO  $OUTDEV
   FROM (dummyt )
   HEAD REPORT
    col 0 ,
    "'Primary NDCs Only' prompt not valid. Must be set to 'Y' or 'N'"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF ((cnvtupper (trim ( $ACTIVEPROD ,3 ) ) IN ("YES" ,
 "Y" ,
 "1" ) ) )
  SET activeprod_parser = build ("mdf.active_ind = 1" )
 ELSEIF ((cnvtupper (trim ( $ACTIVEPROD ,3 ) ) IN ("NO" ,
 "N" ,
 "0" ) ) )
  SET activeprod_parser = build ("1 = 1" )
 ELSE
  SELECT INTO  $OUTDEV
   FROM (dummyt )
   HEAD REPORT
    col 0 ,
    "'Active Products Only' prompt not valid. Must be set to 'Y' or 'N'"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF ((cnvtupper (trim ( $ACTIVENDC ,3 ) ) IN ("YES" ,
 "Y" ,
 "1" ) ) )
  SET activendc_parser = build ("mfoi.active_ind = 1" )
 ELSEIF ((cnvtupper (trim ( $ACTIVENDC ,3 ) ) IN ("NO" ,
 "N" ,
 "0" ) ) )
  SET activendc_parser = build ("1 = 1" )
 ELSE
  SELECT INTO  $OUTDEV
   FROM (dummyt )
   HEAD REPORT
    col 0 ,
    "'Active NDCs Only' prompt not valid. Must be set to 'Y' or 'N'"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF ((size (trim (check ( $FACIILTYCODE ) ,3 ) ) > 0 ) )
  SELECT INTO "nl:"
   FROM (code_value cv )
   WHERE (cv.code_set = 220 )
   AND (cv.cdf_meaning = "FACILITY" )
   AND (((trim (cv.display ,3 ) = trim ( $FACIILTYCODE ,3 ) ) ) OR ((cv.code_value = cnvtreal (trim (
      $FACIILTYCODE ,3 ) ) ) ))
   AND (cv.code_value != 0 )
   HEAD REPORT
    i = size (promptdata->facilities ,5 ) ,
    stat = alterlist (promptdata->facilities ,(i + 1000 ) )
   DETAIL
    i = (i + 1 ) ,
    IF ((i > size (promptdata->facilities ,5 ) ) ) stat = alterlist (promptdata->facilities ,(i +
      100 ) )
    ENDIF
    ,promptdata->facilities[i ].facility_cd = cv.code_value
   FOOT REPORT
    stat = alterlist (promptdata->facilities ,i )
   WITH nocounter
  ;end select
  IF ((size (promptdata->facilities ,5 ) = 0 ) )
   SELECT INTO  $OUTDEV
    code_value = cnvtstring (cv.code_value ,17 ) ,
    display = cv.display
    FROM (code_value cv )
    WHERE (cv.code_set = 220 )
    AND (cv.cdf_meaning = "FACILITY" )
    AND (cv.active_ind = 1 )
    ORDER BY display
    HEAD REPORT
     col 0 ,
     "Facility Display or Code Value entered is not valid." ,
     row + 2 ,
     "See below for valid facilities:" ,
     row + 2 ,
     col + 3 ,
     "FACILITY_CD" ,
     col + 5 ,
     "FACILITY_DISPLAY" ,
     row + 1
    DETAIL
     col + 3 ,
     code_value ,
     col + 5 ,
     display ,
     row + 1
    WITH nocounter
   ;end select
   GO TO exit_script
  ELSE
   SET facility_prompt = promptdata->facilities[1 ].facility_cd
  ENDIF
 ENDIF
 CALL loaditemid (null )
 CALL loaditemidoed (null )
 CALL loaditemiddispense (null )
 CALL loaditemidinventory (null )
 CALL loaditemididentifiers (null )
 CALL loaditemidsupply (null )
 CALL loaditemidordalert (null )
 SET grid->row_cnt = (data->cnt + 1 )
 SET stat = alterlist (grid->row ,grid->row_cnt )
 SELECT INTO "nl:"
  label_desc = cnvtupper (substring (1 ,100 ,data->qual[d1.seq ].identifiers.label_desc ) ) ,
  item_id = data->qual[d1.seq ].general.item_id ,
  sequence = data->qual[d1.seq ].supply.ndc_qual[d2.seq ].ndc_sequence
  FROM (dummyt d1 WITH seq = value (size (data->qual ,5 ) ) ),
   (dummyt d2 WITH seq = 1 )
  PLAN (d1
   WHERE maxrec (d2 ,size (data->qual[d1.seq ].supply.ndc_qual ,5 ) ) )
   JOIN (d2 )
  ORDER BY label_desc ,
   item_id ,
   sequence
  HEAD REPORT
   stat = alterlist (grid->row[1 ].col ,((static_col + locationdata->cnt ) + tot_oa_col ) ) ,
   curcol = 0 ,
   CALL addcolumnheader (curcol ,"ITEM_ID" ) ,
   CALL addcolumnheader (curcol ,"NDC" ) ,
   CALL addcolumnheader (curcol ,"INNER_NDC" ) ,
   CALL addcolumnheader (curcol ,"LABEL_DESC" ) ,
   CALL addcolumnheader (curcol ,"BRAND_NAME" ) ,
   CALL addcolumnheader (curcol ,"BRAND_PRIMARY_IND" ) ,
   CALL addcolumnheader (curcol ,"BRAND_NAME2" ) ,
   CALL addcolumnheader (curcol ,"BRAND2_PRIMARY_IND" ) ,
   CALL addcolumnheader (curcol ,"BRAND_NAME3" ) ,
   CALL addcolumnheader (curcol ,"BRAND3_PRIMARY_IND" ) ,
   CALL addcolumnheader (curcol ,"CHARGE_NBR" ) ,
   CALL addcolumnheader (curcol ,"GENERIC_NAME" ) ,
   CALL addcolumnheader (curcol ,"HCPCS" ) ,
   CALL addcolumnheader (curcol ,"MNEMONIC" ) ,
   CALL addcolumnheader (curcol ,"ADM_ID" ) ,
   CALL addcolumnheader (curcol ,"RXDEVICE1" ) ,
   CALL addcolumnheader (curcol ,"RXDEVICE2" ) ,
   CALL addcolumnheader (curcol ,"RXDEVICE3" ) ,
   CALL addcolumnheader (curcol ,"RXDEVICE4" ) ,
   CALL addcolumnheader (curcol ,"RXDEVICE5" ) ,
   CALL addcolumnheader (curcol ,"RXMISC1" ) ,
   CALL addcolumnheader (curcol ,"RXMISC2" ) ,
   CALL addcolumnheader (curcol ,"RXMISC3" ) ,
   CALL addcolumnheader (curcol ,"RXMISC4" ) ,
   CALL addcolumnheader (curcol ,"RXMISC5" ) ,
   CALL addcolumnheader (curcol ,"RX UNIQUEID" ) ,
   CALL addcolumnheader (curcol ,"UB92" ) ,
   CALL addcolumnheader (curcol ,"ACTIVE_IND" ) ,
   CALL addcolumnheader (curcol ,"REF_DOSE" ) ,
   CALL addcolumnheader (curcol ,"LEGAL_STATUS" ) ,
   CALL addcolumnheader (curcol ,"FORM" ) ,
   CALL addcolumnheader (curcol ,"DOSE" ) ,
   CALL addcolumnheader (curcol ,"ROUTE" ) ,
   CALL addcolumnheader (curcol ,"FREQUENCY" ) ,
   CALL addcolumnheader (curcol ,"INFUSE_OVER" ) ,
   CALL addcolumnheader (curcol ,"INFUSE_OVER_UNIT" ) ,
   CALL addcolumnheader (curcol ,"RATE" ) ,
   CALL addcolumnheader (curcol ,"RATE_UNIT" ) ,
   CALL addcolumnheader (curcol ,"NORMALIZED_RATE" ) ,
   CALL addcolumnheader (curcol ,"NORMALIZED_RATE_UNIT" ) ,
   CALL addcolumnheader (curcol ,"FREETEXT_RATE" ) ,
   CALL addcolumnheader (curcol ,"DURATION" ) ,
   CALL addcolumnheader (curcol ,"DURATION_UNIT" ) ,
   CALL addcolumnheader (curcol ,"STOP_TYPE" ) ,
   CALL addcolumnheader (curcol ,"PRN" ) ,
   CALL addcolumnheader (curcol ,"PRN_REASON" ) ,
   CALL addcolumnheader (curcol ,"ORDERED_AS_SYNONYM" ) ,
   CALL addcolumnheader (curcol ,"SIG" ) ,
   CALL addcolumnheader (curcol ,"NOTES1" ) ,
   CALL addcolumnheader (curcol ,"NOTES1_APPLIESTO_FILL" ) ,
   CALL addcolumnheader (curcol ,"NOTES1_APPLIESTO_LABEL" ) ,
   CALL addcolumnheader (curcol ,"NOTES1_APPLIESTO_MAR" ) ,
   CALL addcolumnheader (curcol ,"NOTES2" ) ,
   CALL addcolumnheader (curcol ,"NOTES2_APPLIESTO_FILL" ) ,
   CALL addcolumnheader (curcol ,"NOTES2_APPLIESTO_LABEL" ) ,
   CALL addcolumnheader (curcol ,"NOTES2_APPLIESTO_MAR" ) ,
   CALL addcolumnheader (curcol ,"DEF_FORMAT" ) ,
   CALL addcolumnheader (curcol ,"SEARCH_MED" ) ,
   CALL addcolumnheader (curcol ,"SEARCH_CONT" ) ,
   CALL addcolumnheader (curcol ,"SEARCH_INTERMIT" ) ,
   CALL addcolumnheader (curcol ,"TPN" ) ,
   CALL addcolumnheader (curcol ,"STRENGTH" ) ,
   CALL addcolumnheader (curcol ,"STRENGTH_UNIT" ) ,
   CALL addcolumnheader (curcol ,"VOLUME" ) ,
   CALL addcolumnheader (curcol ,"VOLUME_UNIT" ) ,
   CALL addcolumnheader (curcol ,"DISPENSE_QTY" ) ,
   CALL addcolumnheader (curcol ,"DISPENSE_QTY_UNIT" ) ,
   CALL addcolumnheader (curcol ,"DISPENSE_CATEGORY" ) ,
   CALL addcolumnheader (curcol ,"DISPENSE_FACTOR" ) ,
   CALL addcolumnheader (curcol ,"USED_IN_TOTAL_VOLUME_CALCULATION" ) ,
   CALL addcolumnheader (curcol ,"WORKFLOW_SEQUENCE" ) ,
   CALL addcolumnheader (curcol ,"DIVISIBLE_IND" ) ,
   CALL addcolumnheader (curcol ,"MINIMUM_DOSE_QTY" ) ,
   CALL addcolumnheader (curcol ,"INFINITE_DIV_IND" ) ,
   CALL addcolumnheader (curcol ,"PKG_DISP_QTY" ) ,
   CALL addcolumnheader (curcol ,"PKG_DISP_ONLY_QTY_NEED" ) ,
   CALL addcolumnheader (curcol ,"FORMULARY_STATUS" ) ,
   CALL addcolumnheader (curcol ,"PRICE_SCHEDULE" ) ,
   CALL addcolumnheader (curcol ,"DEFAULT_PAR_DOSES" ) ,
   CALL addcolumnheader (curcol ,"MAX_PAR_QTY" ) ,
   CALL addcolumnheader (curcol ,"POC_CHARGE_SETTING" ) ,
   CALL addcolumnheader (curcol ,"BILLING_FACTOR" ) ,
   CALL addcolumnheader (curcol ,"BILLING_FACTOR_UNIT" ) ,
   CALL addcolumnheader (curcol ,"DISPENSE_FROM" ) ,
   CALL addcolumnheader (curcol ,"REUSABLE_IND" ) ,
   CALL addcolumnheader (curcol ,"TRACK_LOT_NUMBERS" ) ,
   CALL addcolumnheader (curcol ,"DISABLE_APA_APS" ) ,
   CALL addcolumnheader (curcol ,"SKIP_DISPENSE" ) ,
   CALL addcolumnheader (curcol ,"SUPPRESS_MULTUM_IND" ) ,
   CALL addcolumnheader (curcol ,"GENERIC_FORMULATION_CODE" ) ,
   CALL addcolumnheader (curcol ,"DRUG_FORMULATION_CODE" ) ,
   CALL addcolumnheader (curcol ,"THERAPEUTIC_CLASS" ) ,
   CALL addcolumnheader (curcol ,"DC_INTER_DAYS" ) ,
   CALL addcolumnheader (curcol ,"DC_DISPLAY_DAYS" ) ,
   CALL addcolumnheader (curcol ,"NON_REF_IND" ) ,
   CALL addcolumnheader (curcol ,"PRIMARY_IND" ) ,
   CALL addcolumnheader (curcol ,"MANUFACTURER" ) ,
   CALL addcolumnheader (curcol ,"MANF_BRAND" ) ,
   CALL addcolumnheader (curcol ,"MANF_LABEL_DESC" ) ,
   CALL addcolumnheader (curcol ,"MANF_GENERIC" ) ,
   CALL addcolumnheader (curcol ,"MANF_MNEMONIC" ) ,
   CALL addcolumnheader (curcol ,"MANF_ADM" ) ,
   CALL addcolumnheader (curcol ,"MANF_UB92" ) ,
   CALL addcolumnheader (curcol ,"MANF_RX_UNIQUEID" ) ,
   CALL addcolumnheader (curcol ,"MANF_ACTIVE_IND" ) ,
   CALL addcolumnheader (curcol ,"MANF_FORMULARY_STATUS" ) ,
   CALL addcolumnheader (curcol ,"BASE_PKG_UNIT" ) ,
   CALL addcolumnheader (curcol ,"PKG_SIZE" ) ,
   CALL addcolumnheader (curcol ,"PKG_UNIT" ) ,
   CALL addcolumnheader (curcol ,"OUTER_PKG_SIZE" ) ,
   CALL addcolumnheader (curcol ,"OUTER_PKG_UNIT" ) ,
   CALL addcolumnheader (curcol ,"UNIT_DOSE_IND" ) ,
   CALL addcolumnheader (curcol ,"BIO_IND" ) ,
   CALL addcolumnheader (curcol ,"BRAND_IND" ) ,
   CALL addcolumnheader (curcol ,"AWP" ) ,
   CALL addcolumnheader (curcol ,"GPO" ) ,				;001
   ;003 CALL addcolumnheader (curcol ,"COST:COST1" ) ,
   ;003 CALL addcolumnheader (curcol ,"COST:COST2" ) ,
   CALL addcolumnheader (curcol ,"SYSTEM_NBR" ) ,
   CALL addcolumnheader (curcol ,"INV_FACTOR" ) ,
   CALL addcolumnheader (curcol ,"INV_BASE_PKG_UNIT" ) ,
   CALL addcolumnheader (curcol ,"GROUP_RX_MNEM" ) ,
   CALL addcolumnheader (curcol ,"ALL_FAC" ) ,
   FOR (i = 1 TO locationdata->cnt )
    CALL addcolumnheaderfacil (curcol ,locationdata->qual[i ].facility_cd )
   ENDFOR
   ,oa_start_col = curcol ,
   FOR (i = 1 TO tot_oa_col )
    CALL addcolumnheaderoa (curcol ,build ("ORDER_ALERT_" ,((curcol - oa_start_col ) + 1 ) ) )
   ENDFOR
   ,max_columns = curcol ,
   grid->row[1 ].col_cnt = max_columns ,
   stat = alterlist (grid->row[1 ].col ,max_columns ) ,
   currow = 1
  DETAIL
   curcol = 0 ,
   currow = (currow + 1 ) ,
   stat = alterlist (grid->row ,currow ) ,
   IF ((currow > grid->row_cnt )
   AND (mod (currow ,1000 ) = 1 ) ) stat = alterlist (grid->row ,(currow + 999 ) )
   ENDIF
   ,grid->row[currow ].col_cnt = max_columns ,
   stat = alterlist (grid->row[currow ].col ,max_columns ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].general.item_id ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].ndc ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].inner_ndc ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.label_desc ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.brand_name ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.brand_primary_ind ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.brand_name2 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.brand2_primary_ind ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.brand_name3 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.brand3_primary_ind ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.charge_nbr ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.generic_name ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.hcpcs ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.mnemonic ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.pyxis ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.rxdevice1 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.rxdevice2 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.rxdevice3 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.rxdevice4 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.rxdevice5 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.rxmisc1 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.rxmisc2 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.rxmisc3 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.rxmisc4 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.rxmisc5 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.rx_uniqueid ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].identifiers.ub92 ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].general.active_ind ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].general.ref_dose ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].general.legal_status ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].general.form ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.dose ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.route ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.frequency ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].oe_defaults.infuse_over ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.infuse_over_unit ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].oe_defaults.rate ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.rate_unit ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].oe_defaults.normalized_rate ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.normalized_rate_unit ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.freetext_rate ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].oe_defaults.duration ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.duration_unit ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.stop_type ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].oe_defaults.prn ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.prn_reason ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.order_as_synonym ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.sig ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.notes1 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.notes1_appliesto_fill ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.notes1_appliesto_label ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.notes1_appliesto_mar ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.notes2 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.notes2_appliesto_fill ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.notes2_appliesto_label ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.notes2_appliesto_mar ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].oe_defaults.def_format ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].oe_defaults.medication ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].oe_defaults.continuous ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].oe_defaults.intermittent ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].oe_defaults.tpn ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].dispense.strength ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].dispense.strength_unit ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].dispense.volume ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].dispense.volume_unit ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].dispense.dispense_qty ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].dispense.dispense_qty_unit ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].dispense.dispense_category ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].dispense.dispense_factor ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].dispense.used_in_tot_volume ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].dispense.workflow_sequence ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].dispense.divisible ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].dispense.divisible_factor ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].dispense.infinite_divisible ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].dispense.per_pkg ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].dispense.allow_pkg_broken ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].dispense.formulary_status ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].dispense.price_schedule ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].dispense.default_par_doses ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].dispense.max_par_supply ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].dispense.poc_charge_setting ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].dispense.billing_factor ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].dispense.billing_factor_unit ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].inventory.dispense_from ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].inventory.reusable ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].inventory.track_lot_numbers ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].inventory.disable_apa_aps ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].inventory.skip_dispense ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].clinical.suppress_multum_ind ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].clinical.generic_formulation ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].clinical.drug_formulation ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].clinical.therapeutic_class ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].clinical.dc_inter_days ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].clinical.dc_display_days ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].non_ref_ind ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].primary_ind ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].manufacturer ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].manf_brand ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].manf_label_desc ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].manf_generic ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].manf_mnemonic ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].manf_pyxis ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].manf_ub92 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].manf_rx_uniqueid )
   ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].manf_active_ind ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].
   manf_formulary_status ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].base_pkg_unit ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].pkg_size ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].pkg_unit ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].outer_pkg_size ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].outer_pkg_unit ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].unit_dose_ind ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].bio_ind ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].brand_ind ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].cost_awp ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].cost_gpo ) , ;001
   ;003 CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].cost_cost1 ) ,
   ;003 CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].cost_cost2 ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].misc.system_number ) ,
   CALL addvaluereal (currow ,curcol ,data->qual[d1.seq ].supply.ndc_qual[d2.seq ].inv_factor ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].misc.inv_base_pkg_unit ) ,
   CALL addvaluetxt (currow ,curcol ,data->qual[d1.seq ].misc.group_rx_mnem ) ,
   CALL addvalueint (currow ,curcol ,data->qual[d1.seq ].inventoryfacil.all_facilities_ind ) ,
   itemid_index = locatevalsort (expand_cnt ,1 ,data->cnt ,item_id ,data->qual[expand_cnt ].general.
    item_id ) ,
   IF ((itemid_index > 0 ) )
    FOR (facility_index = 1 TO data->qual[itemid_index ].inventoryfacil.facil_cnt )
     search_facility = data->qual[itemid_index ].inventoryfacil.facility_qual[facility_index ].
     facility_cd ,column_index = locateval (expand_cnt ,1 ,size (grid->row[1 ].col ,5 ) ,
      search_facility ,grid->row[1 ].col[expand_cnt ].code_value ) ,
     IF ((column_index > static_col ) )
      CALL addvaluetxtpivot (currow ,column_index ,"1" )
     ENDIF
    ENDFOR
    ,oacnt = 0 ,
    FOR (oa_index = 1 TO data->qual[itemid_index ].clinicaloa.oa_cnt )
     oacnt = (oacnt + 1 ) ,
     IF ((data->qual[itemid_index ].clinicaloa.oa_cnt > 0 ) ) oacol = (oacnt + oa_start_col ) ,
      CALL addvaluetxtpivot (currow ,oacol ,data->qual[itemid_index ].clinicaloa.order_alert_qual[
      oacnt ].order_alert_display )
     ENDIF
    ENDFOR
   ENDIF
  FOOT REPORT
   grid->row_cnt = currow ,
   stat = alterlist (grid->row ,currow )
  WITH nocounter ,nullreport ,format ,separator = " "
 ;end select
 SET file->file_name =  $OUTDEV
 SET file->file_buf = "w"
 SET stat = cclio ("OPEN" ,file )
 CALL echo (">>> Opening file..." )
 CALL echo (build ("Stat:" ,stat ) )
 CALL echo (build ("Row Count:" ,grid->row_cnt ) )
 IF ((stat = 1 ) )
  FOR (r = 1 TO grid->row_cnt )
   SET line = " "
   FOR (c = 1 TO grid->row[r ].col_cnt )
    SET clean_txt = checkreplace (grid->row[r ].col[c ].txt ,q )
    IF ((((findstring ("," ,clean_txt ) > 0 ) ) OR ((findstring (q ,clean_txt ) > 0 ) )) )
     IF ((c = 1 ) )
      SET line = build (q ,clean_txt ,q )
     ELSE
      SET line = build (line ,tab ,q ,clean_txt ,q )
     ENDIF
    ELSE
     IF ((c = 1 ) )
      SET line = clean_txt
     ELSE
      SET line = build (line ,tab ,clean_txt )
     ENDIF
    ENDIF
   ENDFOR
   SET file->file_buf = concat (trim (line ) ,lf )
   SET stat = cclio ("WRITE" ,file )
   IF ((stat = 0 ) )
    CALL cclexception (900 ,"E" ,"CCLIO:Could not write to the file!" )
   ENDIF
  ENDFOR
 ELSE
  CALL cclexception (900 ,"E" ,"CCLIO:Could not open file!" )
 ENDIF
 SET stat = cclio ("CLOSE" ,file )
 SUBROUTINE  loaditemid (null )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  IF ((size (trim (check ( $FACIILTYCODE ) ,3 ) ) > 0 ) )
   SELECT INTO "nl:"
    FROM (medication_definition md ),
     (med_def_flex mdf ),
     (med_def_flex mdf2 ),
     (med_flex_object_idx mfoi ),
     (order_catalog_item_r ocir ),
     (order_catalog oc ),
     (alt_sel_list al ),
     (alt_sel_cat ac ),
     (nomenclature ng ),
     (nomenclature nd ),
     (package_type pt ),
     (identifier id )
    PLAN (md
     WHERE (md.med_type_flag = 0 ) )
     JOIN (mdf
     WHERE (mdf.item_id = md.item_id )
     AND (mdf.pharmacy_type_cd = 4500_inpt_cd )
     AND (mdf.flex_type_cd = 4062_sys_cd )
     AND parser (activeprod_parser ) )
     JOIN (mdf2
     WHERE (mdf2.item_id = md.item_id )
     AND (mdf2.flex_type_cd = 4062_sysp_cd )
     AND (mdf2.pharmacy_type_cd = 4500_inpt_cd )
     AND (mdf2.med_package_type_id != 0 ) )
     JOIN (mfoi
     WHERE (mfoi.med_def_flex_id = mdf2.med_def_flex_id )
     AND (mfoi.flex_object_type_cd = 4063_orderable_cd )
     AND (((mfoi.parent_entity_id = facility_prompt ) ) OR ((mfoi.parent_entity_id = 0 ) )) )
     JOIN (ocir
     WHERE (ocir.item_id = md.item_id ) )
     JOIN (oc
     WHERE (oc.catalog_cd = ocir.catalog_cd ) )
     JOIN (al
     WHERE (al.synonym_id = outerjoin (ocir.synonym_id ) )
     AND (al.list_type = outerjoin (2 ) ) )
     JOIN (ac
     WHERE (ac.alt_sel_category_id = outerjoin (al.alt_sel_category_id ) )
     AND (ac.ahfs_ind = outerjoin (1 ) ) )
     JOIN (ng
     WHERE (ng.concept_identifier = outerjoin (substring (9 ,20 ,oc.cki ) ) )
     AND (ng.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
     AND (ng.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
     AND (ng.primary_vterm_ind = outerjoin (1 ) ) )
     JOIN (nd
     WHERE (nd.nomenclature_id = outerjoin (md.mdx_gfc_nomen_id ) ) )
     JOIN (pt
     WHERE (pt.item_id = outerjoin (md.item_id ) )
     AND (pt.active_ind = outerjoin (1 ) )
     AND (pt.base_package_type_ind = outerjoin (1 ) ) )
     JOIN (id
     WHERE (id.parent_entity_id = outerjoin (md.item_id ) )
     AND (id.parent_entity_name = outerjoin ("ITEM_DEFINITION" ) )
     AND (id.identifier_type_cd = outerjoin (11000_item_nbr_sys_cd ) ) )
    ORDER BY md.item_id
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt + 1 ) ,
     IF ((mod (cnt ,2000 ) = 1 ) ) stat = alterlist (data->qual ,(cnt + 1999 ) )
     ENDIF
     ,data->qual[cnt ].general.item_id = md.item_id ,
     data->qual[cnt ].general.active_ind = mdf.active_ind ,
     data->qual[cnt ].general.ref_dose = md.given_strength ,
     data->qual[cnt ].general.form = uar_get_code_display (md.form_cd ) ,
     data->qual[cnt ].clinical.generic_formulation = ng.source_string ,
     data->qual[cnt ].clinical.drug_formulation = nd.source_string ,
     IF ((oc.cki = "IGNORE" ) ) data->qual[cnt ].clinical.suppress_multum_ind = "1"
     ELSE data->qual[cnt ].clinical.suppress_multum_ind = null
     ENDIF
     ,data->qual[cnt ].clinical.therapeutic_class = ac.long_description ,
     data->qual[cnt ].clinical.dc_inter_days = oc.dc_interaction_days ,
     data->qual[cnt ].clinical.dc_display_days = oc.dc_display_days ,
     data->qual[cnt ].misc.group_rx_mnem = "NEW" ,
     data->qual[cnt ].misc.inv_base_pkg_unit = uar_get_code_display (pt.uom_cd ) ,
     data->qual[cnt ].misc.system_number = id.value
    FOOT REPORT
     data->cnt = cnt ,
     stat = alterlist (data->qual ,cnt )
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (medication_definition md ),
     (med_def_flex mdf ),
     (order_catalog_item_r ocir ),
     (order_catalog oc ),
     (alt_sel_list al ),
     (alt_sel_cat ac ),
     (nomenclature ng ),
     (nomenclature nd ),
     (package_type pt ),
     (identifier id )
    PLAN (md
     WHERE (md.med_type_flag = 0 ) )
     JOIN (mdf
     WHERE (mdf.item_id = md.item_id )
     AND (mdf.pharmacy_type_cd = 4500_inpt_cd )
     AND (mdf.flex_type_cd = 4062_sys_cd )
     AND parser (activeprod_parser ) )
     JOIN (ocir
     WHERE (ocir.item_id = md.item_id ) )
     JOIN (oc
     WHERE (oc.catalog_cd = ocir.catalog_cd ) )
     JOIN (al
     WHERE (al.synonym_id = outerjoin (ocir.synonym_id ) )
     AND (al.list_type = outerjoin (2 ) ) )
     JOIN (ac
     WHERE (ac.alt_sel_category_id = outerjoin (al.alt_sel_category_id ) )
     AND (ac.ahfs_ind = outerjoin (1 ) ) )
     JOIN (ng
     WHERE (ng.concept_identifier = outerjoin (substring (9 ,20 ,oc.cki ) ) )
     AND (ng.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
     AND (ng.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
     AND (ng.primary_vterm_ind = outerjoin (1 ) ) )
     JOIN (nd
     WHERE (nd.nomenclature_id = outerjoin (md.mdx_gfc_nomen_id ) ) )
     JOIN (pt
     WHERE (pt.item_id = outerjoin (md.item_id ) )
     AND (pt.active_ind = outerjoin (1 ) )
     AND (pt.base_package_type_ind = outerjoin (1 ) ) )
     JOIN (id
     WHERE (id.parent_entity_id = outerjoin (md.item_id ) )
     AND (id.parent_entity_name = outerjoin ("ITEM_DEFINITION" ) )
     AND (id.identifier_type_cd = outerjoin (11000_item_nbr_sys_cd ) ) )
    ORDER BY md.item_id
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt + 1 ) ,
     IF ((mod (cnt ,2000 ) = 1 ) ) stat = alterlist (data->qual ,(cnt + 1999 ) )
     ENDIF
     ,data->qual[cnt ].general.item_id = md.item_id ,
     data->qual[cnt ].general.active_ind = mdf.active_ind ,
     data->qual[cnt ].general.ref_dose = md.given_strength ,
     data->qual[cnt ].general.form = uar_get_code_display (md.form_cd ) ,
     data->qual[cnt ].clinical.generic_formulation = ng.source_string ,
     data->qual[cnt ].clinical.drug_formulation = nd.source_string ,
     IF ((oc.cki = "IGNORE" ) ) data->qual[cnt ].clinical.suppress_multum_ind = "1"
     ELSE data->qual[cnt ].clinical.suppress_multum_ind = null
     ENDIF
     ,data->qual[cnt ].clinical.therapeutic_class = ac.long_description ,
     data->qual[cnt ].clinical.dc_inter_days = oc.dc_interaction_days ,
     data->qual[cnt ].clinical.dc_display_days = oc.dc_display_days ,
     data->qual[cnt ].misc.group_rx_mnem = "NEW" ,
     data->qual[cnt ].misc.inv_base_pkg_unit = uar_get_code_display (pt.uom_cd ) ,
     data->qual[cnt ].misc.system_number = id.value
    FOOT REPORT
     data->cnt = cnt ,
     stat = alterlist (data->qual ,cnt )
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE  loaditemidoed (null )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (medication_definition md ),
    (med_def_flex mdf ),
    (med_flex_object_idx mfoi ),
    (med_oe_defaults mod ),
    (price_sched ps ),
    (order_catalog_synonym ocs ),
    (long_text lt ),
    (long_text lt2 )
   PLAN (md
    WHERE (md.med_type_flag = 0 )
    AND expand (index ,1 ,data->cnt ,md.item_id ,data->qual[index ].general.item_id ) )
    JOIN (mdf
    WHERE (mdf.item_id = md.item_id )
    AND (mdf.flex_type_cd = 4062_sys_cd )
    AND (mdf.pharmacy_type_cd = 4500_inpt_cd ) )
    JOIN (mfoi
    WHERE (mfoi.med_def_flex_id = mdf.med_def_flex_id )
    AND (mfoi.flex_object_type_cd = 4063_oedef_cd ) )
    JOIN (mod
    WHERE (mod.med_oe_defaults_id = mfoi.parent_entity_id ) )
    JOIN (ps
    WHERE (ps.price_sched_id = outerjoin (mod.price_sched_id ) ) )
    JOIN (ocs
    WHERE (ocs.synonym_id = outerjoin (mod.ord_as_synonym_id ) ) )
    JOIN (lt
    WHERE (lt.long_text_id = outerjoin (mod.comment1_id ) ) )
    JOIN (lt2
    WHERE (lt2.long_text_id = outerjoin (mod.comment2_id ) ) )
   ORDER BY md.item_id
   HEAD REPORT
    stat = alterlist (data->qual ,data->cnt )
   DETAIL
    pos = locatevalsort (index ,1 ,data->cnt ,md.item_id ,data->qual[index ].general.item_id ) ,
    IF ((pos > 0 ) )
     IF ((mod.strength_unit_cd != 0 ) ) data->qual[pos ].oe_defaults.dose = concat (trim (format (mod
         .strength ,"##########.######;RT(1);F" ) ,3 ) ," " ,uar_get_code_display (mod
        .strength_unit_cd ) )
     ELSEIF ((mod.volume_unit_cd != 0 ) ) data->qual[pos ].oe_defaults.dose = concat (trim (format (
         mod.volume ,"##########.######;RT(1);F" ) ,3 ) ," " ,uar_get_code_display (mod
        .volume_unit_cd ) )
     ELSE data->qual[pos ].oe_defaults.dose = mod.freetext_dose
     ENDIF
     ,data->qual[pos ].oe_defaults.route = uar_get_code_display (mod.route_cd ) ,data->qual[pos ].
     oe_defaults.frequency = uar_get_code_display (mod.frequency_cd ) ,data->qual[pos ].oe_defaults.
     infuse_over = mod.infuse_over ,data->qual[pos ].oe_defaults.infuse_over_unit =
     uar_get_code_display (mod.infuse_over_cd ) ,data->qual[pos ].oe_defaults.rate = mod.rate_nbr ,
     data->qual[pos ].oe_defaults.rate_unit = uar_get_code_display (mod.rate_unit_cd ) ,data->qual[
     pos ].oe_defaults.normalized_rate = mod.normalized_rate_nbr ,data->qual[pos ].oe_defaults.
     normalized_rate_unit = uar_get_code_display (mod.normalized_rate_unit_cd ) ,data->qual[pos ].
     oe_defaults.freetext_rate = mod.freetext_rate_txt ,data->qual[pos ].oe_defaults.duration = mod
     .duration ,data->qual[pos ].oe_defaults.duration_unit = uar_get_code_display (mod
      .duration_unit_cd ) ,data->qual[pos ].oe_defaults.stop_type = uar_get_code_display (mod
      .stop_type_cd ) ,data->qual[pos ].oe_defaults.prn = mod.prn_ind ,data->qual[pos ].oe_defaults.
     prn_reason = uar_get_code_display (mod.prn_reason_cd ) ,data->qual[pos ].oe_defaults.
     order_as_synonym = ocs.mnemonic ,data->qual[pos ].oe_defaults.sig = mod.sig_codes ,data->qual[
     pos ].oe_defaults.notes1 = lt.long_text ,data->qual[pos ].oe_defaults.notes1_appliesto_fill =
     evaluate (mod.comment1_type ,1 ,"1" ,3 ,"1" ,5 ,"1" ,7 ,"1" ,null ) ,data->qual[pos ].
     oe_defaults.notes1_appliesto_mar = evaluate (mod.comment1_type ,2 ,"1" ,3 ,"1" ,6 ,"1" ,7 ,"1" ,
      null ) ,data->qual[pos ].oe_defaults.notes1_appliesto_label = evaluate (mod.comment1_type ,4 ,
      "1" ,4 ,"1" ,6 ,"1" ,7 ,"1" ,null ) ,data->qual[pos ].oe_defaults.notes2 = lt2.long_text ,data
     ->qual[pos ].oe_defaults.notes2_appliesto_fill = evaluate (mod.comment2_type ,1 ,"1" ,3 ,"1" ,5
      ,"1" ,7 ,"1" ,null ) ,data->qual[pos ].oe_defaults.notes2_appliesto_mar = evaluate (mod
      .comment2_type ,2 ,"1" ,3 ,"1" ,6 ,"1" ,7 ,"1" ,null ) ,data->qual[pos ].oe_defaults.
     notes1_appliesto_label = evaluate (mod.comment2_type ,4 ,"1" ,4 ,"1" ,6 ,"1" ,7 ,"1" ,null ) ,
     data->qual[pos ].dispense.dispense_category = uar_get_code_display (mod.dispense_category_cd ) ,
     data->qual[pos ].dispense.price_schedule = ps.price_sched_short_desc ,data->qual[pos ].dispense.
     default_par_doses = mod.default_par_doses ,data->qual[pos ].dispense.max_par_supply = mod
     .max_par_supply
    ENDIF
   WITH nocounter ,expand = 2
  ;end select
 END ;Subroutine
 SUBROUTINE  loaditemiddispense (null )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (medication_definition md ),
    (med_def_flex mdf ),
    (med_flex_object_idx mfoi ),
    (med_dispense mdisp ),
    (med_package_type mpt )
   PLAN (md
    WHERE (md.med_type_flag = 0 )
    AND expand (index ,1 ,data->cnt ,md.item_id ,data->qual[index ].general.item_id ) )
    JOIN (mdf
    WHERE (mdf.item_id = md.item_id )
    AND (mdf.pharmacy_type_cd = 4500_inpt_cd )
    AND (mdf.flex_type_cd = 4062_sysp_cd ) )
    JOIN (mfoi
    WHERE (mfoi.med_def_flex_id = mdf.med_def_flex_id )
    AND (mfoi.flex_object_type_cd = 4063_disp_cd ) )
    JOIN (mdisp
    WHERE (mdisp.med_dispense_id = mfoi.parent_entity_id )
    AND (mdisp.pharmacy_type_cd = 4500_inpt_cd ) )
    JOIN (mpt
    WHERE (mpt.med_package_type_id = mdf.med_package_type_id ) )
   ORDER BY md.item_id
   HEAD REPORT
    stat = alterlist (data->qual ,data->cnt )
   DETAIL
    pos = locatevalsort (index ,1 ,data->cnt ,md.item_id ,data->qual[index ].general.item_id ) ,
    IF ((pos > 0 ) ) data->qual[pos ].general.legal_status = uar_get_code_display (mdisp
      .legal_status_cd ) ,data->qual[pos ].oe_defaults.def_format = evaluate (mdisp.oe_format_flag ,
      0 ,"No Default" ,1 ,"Medication" ,2 ,"Continuous" ,3 ,"Intermittent" ,null ) ,data->qual[pos ].
     oe_defaults.medication = mdisp.med_filter_ind ,data->qual[pos ].oe_defaults.continuous = mdisp
     .continuous_filter_ind ,data->qual[pos ].oe_defaults.tpn = mdisp.tpn_filter_ind ,data->qual[pos
     ].oe_defaults.intermittent = mdisp.intermittent_filter_ind ,data->qual[pos ].dispense.strength
     = mdisp.strength ,data->qual[pos ].dispense.strength_unit = uar_get_code_display (mdisp
      .strength_unit_cd ) ,data->qual[pos ].dispense.volume = mdisp.volume ,data->qual[pos ].dispense
     .volume_unit = uar_get_code_display (mdisp.volume_unit_cd ) ,data->qual[pos ].dispense.
     dispense_qty = mpt.dispense_qty ,data->qual[pos ].dispense.dispense_qty_unit =
     uar_get_code_display (mpt.uom_cd ) ,data->qual[pos ].dispense.dispense_factor = mdisp
     .dispense_factor ,data->qual[pos ].dispense.used_in_tot_volume = evaluate (mdisp
      .used_as_base_ind ,0 ,"Never" ,1 ,"Sometimes" ,2 ,"Always" ,"" ) ,data->qual[pos ].dispense.
     workflow_sequence = uar_get_code_display (mdisp.workflow_cd ) ,data->qual[pos ].dispense.
     divisible = mdisp.divisible_ind ,data->qual[pos ].dispense.divisible_factor = mdisp
     .base_issue_factor ,data->qual[pos ].dispense.infinite_divisible = mdisp.infinite_div_ind ,data
     ->qual[pos ].dispense.per_pkg = mdisp.pkg_qty_per_pkg ,data->qual[pos ].dispense.
     allow_pkg_broken = mdisp.pkg_disp_more_ind ,data->qual[pos ].dispense.formulary_status =
     uar_get_code_display (mdisp.formulary_status_cd ) ,data->qual[pos ].dispense.billing_factor =
     mdisp.billing_factor_nbr ,data->qual[pos ].dispense.billing_factor_unit = uar_get_code_display (
      mdisp.billing_uom_cd ) ,data->qual[pos ].dispense.poc_charge_setting = evaluate (mdisp
      .poc_charge_flag ,1 ,"ORDERED" ,"SCANNED" ) ,data->qual[pos ].inventory.dispense_from = mdisp
     .always_dispense_from_flag ,data->qual[pos ].inventory.reusable = mdisp.reusable_ind ,data->
     qual[pos ].inventory.track_lot_numbers = mdisp.lot_tracking_ind ,data->qual[pos ].inventory.
     disable_apa_aps = mdisp.prod_assign_flag ,data->qual[pos ].inventory.skip_dispense = mdisp
     .skip_dispense_flag
    ENDIF
   WITH nocounter ,expand = 2
  ;end select
 END ;Subroutine
 SUBROUTINE  loaditemidinventory (null )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (medication_definition md ),
    (med_def_flex mdf ),
    (med_flex_object_idx mfoi )
   PLAN (md
    WHERE (md.med_type_flag = 0 )
    AND expand (index ,1 ,data->cnt ,md.item_id ,data->qual[index ].general.item_id ) )
    JOIN (mdf
    WHERE (mdf.item_id = md.item_id )
    AND (mdf.flex_type_cd = 4062_sysp_cd )
    AND (mdf.pharmacy_type_cd = 4500_inpt_cd )
    AND (mdf.med_package_type_id != 0 ) )
    JOIN (mfoi
    WHERE (mfoi.med_def_flex_id = outerjoin (mdf.med_def_flex_id ) )
    AND (mfoi.flex_object_type_cd = outerjoin (4063_orderable_cd ) ) )
   ORDER BY md.item_id
   HEAD md.item_id
    pos = locatevalsort (index ,1 ,data->cnt ,md.item_id ,data->qual[index ].general.item_id ) ,fcnt
    = 0
   DETAIL
    IF ((pos > 0 ) ) fcnt = (fcnt + 1 ) ,
     IF ((mod (fcnt ,10 ) = 1 ) ) stat = alterlist (data->qual[pos ].inventoryfacil.facility_qual ,(
       fcnt + 9 ) )
     ENDIF
     ,
     IF ((mfoi.parent_entity_id > 0 ) ) data->qual[pos ].inventoryfacil.facility_qual[fcnt ].
      facility_cd = mfoi.parent_entity_id ,data->qual[pos ].inventoryfacil.facility_qual[fcnt ].
      facility = uar_get_code_display (mfoi.parent_entity_id )
     ELSEIF ((mfoi.parent_entity_id = 0 )
     AND (mfoi.med_flex_object_id > 0 ) ) data->qual[pos ].inventoryfacil.all_facilities_ind = 1
     ELSE data->qual[pos ].inventoryfacil.all_facilities_ind = 0
     ENDIF
    ENDIF
   FOOT  md.item_id
    stat = alterlist (data->qual[pos ].inventoryfacil.facility_qual ,fcnt ) ,data->qual[pos ].
    inventoryfacil.facil_cnt = fcnt
   WITH nocounter ,expand = 2
  ;end select
  SELECT INTO "nl:"
   facility = cnvtupper (uar_get_code_display (l.location_cd ) )
   FROM (location l )
   WHERE (l.active_ind = 1 )
   AND (l.location_type_cd = 222_facility_cd )
   ORDER BY facility
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt + 1 ) ,
    IF ((mod (cnt ,100 ) = 1 ) ) stat = alterlist (locationdata->qual ,(cnt + 99 ) )
    ENDIF
    ,locationdata->qual[cnt ].facility = cnvtupper (uar_get_code_display (l.location_cd ) ) ,
    locationdata->qual[cnt ].facility_cd = l.location_cd
   FOOT REPORT
    locationdata->cnt = cnt ,
    stat = alterlist (locationdata->qual ,cnt )
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  loaditemididentifiers (null )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (medication_definition md ),
    (med_identifier mi )
   PLAN (md
    WHERE (md.med_type_flag = 0 )
    AND expand (index ,1 ,data->cnt ,md.item_id ,data->qual[index ].general.item_id ) )
    JOIN (mi
    WHERE (mi.item_id = md.item_id )
    AND (mi.med_product_id = 0 )
    AND (mi.pharmacy_type_cd = 4500_inpt_cd )
    AND (((mi.primary_ind = 1 ) ) OR ((mi.primary_ind = 0 )
    AND (mi.med_identifier_type_cd = 11000_brand_cd ) )) )
   ORDER BY md.item_id ,
    mi.med_identifier_id DESC
   HEAD md.item_id
    icnt = 0
   HEAD mi.med_identifier_id
    pos = locatevalsort (index ,1 ,data->cnt ,md.item_id ,data->qual[index ].general.item_id ) ,
    IF ((pos > 0 ) )
     IF ((mi.primary_ind = 1 ) )
      IF ((mi.med_identifier_type_cd = 11000_cdm_cd ) ) data->qual[pos ].identifiers.charge_nbr = mi
       .value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_desc_cd ) ) data->qual[pos ].identifiers.label_desc = mi
       .value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_gen_cd ) ) data->qual[pos ].identifiers.generic_name =
       mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_hcpcs_cd ) ) data->qual[pos ].identifiers.hcpcs = mi
       .value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_desc_short_cd ) ) data->qual[pos ].identifiers.mnemonic
       = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_pyxis_cd ) ) data->qual[pos ].identifiers.pyxis = mi
       .value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_rxdevice1_cd ) ) data->qual[pos ].identifiers.rxdevice1
       = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_rxdevice2_cd ) ) data->qual[pos ].identifiers.rxdevice2
       = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_rxdevice3_cd ) ) data->qual[pos ].identifiers.rxdevice3
       = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_rxdevice4_cd ) ) data->qual[pos ].identifiers.rxdevice4
       = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_rxdevice5_cd ) ) data->qual[pos ].identifiers.rxdevice5
       = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_rxmisc1_cd ) ) data->qual[pos ].identifiers.rxmisc1 = mi
       .value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_rxmisc2_cd ) ) data->qual[pos ].identifiers.rxmisc2 = mi
       .value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_rxmisc3_cd ) ) data->qual[pos ].identifiers.rxmisc3 = mi
       .value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_rxmisc4_cd ) ) data->qual[pos ].identifiers.rxmisc4 = mi
       .value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_rxmisc5_cd ) ) data->qual[pos ].identifiers.rxmisc5 = mi
       .value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_rx_uniqueid_cd ) ) data->qual[pos ].identifiers.
       rx_uniqueid = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_ub92_cd ) ) data->qual[pos ].identifiers.ub92 = mi
       .value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_brand_cd ) ) data->qual[pos ].identifiers.brand_name =
       mi.value ,data->qual[pos ].identifiers.brand_primary_ind = "1"
      ENDIF
     ELSEIF ((mi.primary_ind = 0 )
     AND (mi.active_ind = 1 )
     AND (mi.med_identifier_type_cd = 11000_brand_cd ) ) icnt = (icnt + 1 ) ,
      IF ((icnt = 1 ) ) data->qual[pos ].identifiers.brand_name2 = mi.value ,data->qual[pos ].
       identifiers.brand2_primary_ind = "0"
      ELSEIF ((icnt = 2 ) ) data->qual[pos ].identifiers.brand_name3 = mi.value ,data->qual[pos ].
       identifiers.brand3_primary_ind = "0"
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter ,expand = 2
  ;end select
 END ;Subroutine
 SUBROUTINE  loaditemidsupply (null )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  DECLARE tablenamevar = vc WITH protect ,noconstant ("" )
  DECLARE itemid_index = i4 WITH protect ,noconstant (0 )
  DECLARE ndc_index = i4 WITH protect ,noconstant (0 )
  DECLARE ndc_core = i2 WITH protect ,noconstant (0 )
  DECLARE mltm_ndc_core = i2 WITH protect ,noconstant (0 )
  SET ndc_core = checkdic ("NDC_CORE_DESCRIPTION" ,"T" ,0 )
  SET mltm_ndc_core = checkdic ("MLTM_NDC_CORE_DESCRIPTION" ,"T" ,0 )
  SELECT INTO "nl:"
   FROM (medication_definition md ),
    (med_def_flex mdf ),
    (med_flex_object_idx mfoi ),
    (med_product mp ),
    (med_identifier mi ),
    (manufacturer_item mfi ),
    (package_type ptb ),
    (package_type pti ),
    (package_type pto ),
    (med_cost_hx mch )
   PLAN (md
    WHERE (md.med_type_flag = 0 )
    AND expand (index ,1 ,data->cnt ,md.item_id ,data->qual[index ].general.item_id ) )
    JOIN (mdf
    WHERE (mdf.item_id = md.item_id )
    AND (mdf.flex_type_cd = 4062_sys_cd )
    AND (mdf.pharmacy_type_cd = 4500_inpt_cd ) )
    JOIN (mfoi
    WHERE (mfoi.med_def_flex_id = mdf.med_def_flex_id )
    AND (mfoi.flex_object_type_cd = 4063_medprod_cd )
    AND parser (primaryonly_parser )
    AND parser (activendc_parser ) )
    JOIN (mp
    WHERE (mp.med_product_id = mfoi.parent_entity_id )
    AND (mp.active_ind = 1 ) )
    JOIN (mi
    WHERE (mi.med_product_id = mp.med_product_id ) )
    JOIN (mfi
    WHERE (mfi.item_id = mp.manf_item_id ) )
    JOIN (ptb
    WHERE (ptb.item_id = mfi.item_id )
    AND (ptb.base_package_type_ind = 1 ) )
    JOIN (pti
    WHERE (pti.package_type_id = mp.inner_pkg_type_id ) )
    JOIN (pto
    WHERE (pto.package_type_id = mp.outer_pkg_type_id ) )
    JOIN (mch
    WHERE (mch.med_product_id = outerjoin (mp.med_product_id ) )
    AND (mch.active_ind = 1 )
    AND (mch.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
    AND (mch.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) ) )
   ORDER BY md.item_id ,
    mp.med_product_id ,
    mi.med_identifier_id ,
    mch.med_cost_hx_id
   HEAD md.item_id
    ndc_cnt = 0
   HEAD mp.med_product_id
    pos = locatevalsort (index ,1 ,data->cnt ,md.item_id ,data->qual[index ].general.item_id ) ,
    IF ((pos > 0 ) ) ndc_cnt = (ndc_cnt + 1 ) ,
     IF ((mod (ndc_cnt ,10 ) = 1 ) ) stat = alterlist (data->qual[pos ].supply.ndc_qual ,(ndc_cnt +
       9 ) )
     ENDIF
     ,data->qual[pos ].supply.ndc_qual[ndc_cnt ].med_product_id = mp.med_product_id ,data->qual[pos ]
     .supply.ndc_qual[ndc_cnt ].manf_active_ind = mfoi.active_ind ,data->qual[pos ].supply.ndc_qual[
     ndc_cnt ].primary_ind =
     IF ((mfoi.sequence = 1 ) ) 1
     ELSE 0
     ENDIF
     ,data->qual[pos ].supply.ndc_qual[ndc_cnt ].manufacturer = uar_get_code_display (mfi
      .manufacturer_cd ) ,data->qual[pos ].supply.ndc_qual[ndc_cnt ].base_pkg_unit =
     uar_get_code_display (ptb.uom_cd ) ,data->qual[pos ].supply.ndc_qual[ndc_cnt ].pkg_size = pti
     .qty ,data->qual[pos ].supply.ndc_qual[ndc_cnt ].pkg_unit = uar_get_code_display (pti.uom_cd ) ,
     data->qual[pos ].supply.ndc_qual[ndc_cnt ].outer_pkg_size = pto.qty ,data->qual[pos ].supply.
     ndc_qual[ndc_cnt ].outer_pkg_unit = uar_get_code_display (pto.uom_cd ) ,data->qual[pos ].supply.
     ndc_qual[ndc_cnt ].unit_dose_ind = mp.unit_dose_ind ,data->qual[pos ].supply.ndc_qual[ndc_cnt ].
     bio_ind = mp.bio_equiv_ind ,data->qual[pos ].supply.ndc_qual[ndc_cnt ].brand_ind = mp.brand_ind
    ,data->qual[pos ].supply.ndc_qual[ndc_cnt ].manf_formulary_status = uar_get_code_display (mp
      .formulary_status_cd ) ,data->qual[pos ].supply.ndc_qual[ndc_cnt ].ndc_sequence = mfoi
     .sequence ,data->qual[pos ].supply.ndc_qual[ndc_cnt ].inv_factor = mp.inv_factor_nbr
    ENDIF
   HEAD mi.med_identifier_id
    IF ((pos > 0 ) )
     IF ((mi.primary_ind = 1 ) )
      IF ((mi.med_identifier_type_cd = 11000_ndc_cd ) ) data->qual[pos ].supply.ndc_qual[ndc_cnt ].
       ndc = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_inner_ndc_cd ) ) data->qual[pos ].supply.ndc_qual[
       ndc_cnt ].inner_ndc = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_brand_cd ) ) data->qual[pos ].supply.ndc_qual[ndc_cnt ].
       manf_brand = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_gen_cd ) ) data->qual[pos ].supply.ndc_qual[ndc_cnt ].
       manf_generic = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_desc_cd ) ) data->qual[pos ].supply.ndc_qual[ndc_cnt ].
       manf_label_desc = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_desc_short_cd ) ) data->qual[pos ].supply.ndc_qual[
       ndc_cnt ].manf_mnemonic = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_pyxis_cd ) ) data->qual[pos ].supply.ndc_qual[ndc_cnt ].
       manf_pyxis = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_rx_uniqueid_cd ) ) data->qual[pos ].supply.ndc_qual[
       ndc_cnt ].manf_rx_uniqueid = mi.value
      ENDIF
      ,
      IF ((mi.med_identifier_type_cd = 11000_ub92_cd ) ) data->qual[pos ].supply.ndc_qual[ndc_cnt ].
       manf_ub92 = mi.value
      ENDIF
     ENDIF
    ENDIF
   HEAD mch.med_cost_hx_id
    IF ((pos > 0 ) )
     IF ((mch.cost_type_cd = 4050_awp_cd ) ) data->qual[pos ].supply.ndc_qual[ndc_cnt ].cost_awp =
      trim (format (mch.cost ,"##########.#####;;F" ) ,3 )
     ENDIF
     ,
     IF ((mch.cost_type_cd = 4050_cost1_cd ) ) data->qual[pos ].supply.ndc_qual[ndc_cnt ].cost_cost1
      = trim (format (mch.cost ,"##########.#####;;F" ) ,3 )
     ENDIF
     ,
     IF ((mch.cost_type_cd = 4050_cost2_cd ) ) data->qual[pos ].supply.ndc_qual[ndc_cnt ].cost_cost2
      = trim (format (mch.cost ,"##########.#####;;F" ) ,3 )
     ENDIF
     ;start 001
     IF ((mch.cost_type_cd = 4050_gpo_cd ) ) data->qual[pos ].supply.ndc_qual[ndc_cnt ].cost_gpo
      = trim (format (mch.cost ,"##########.#####;;F" ) ,3 )
     ENDIF
     ;end 001
    ENDIF
   FOOT  mch.med_cost_hx_id
    null
   FOOT  mi.med_identifier_id
    null
   FOOT  mp.med_product_id
    null
   FOOT  md.item_id
    data->qual[pos ].supply.ndc_cnt = ndc_cnt ,stat = alterlist (data->qual[pos ].supply.ndc_qual ,
     ndc_cnt )
   WITH nocounter ,expand = 2
  ;end select
  FOR (itemid_index = 1 TO data->cnt )
   FOR (ndc_index = 1 TO data->qual[itemid_index ].supply.ndc_cnt )
    IF ((mltm_ndc_core = 2 ) )
     SELECT INTO "nl:"
      FROM (v500.mltm_ndc_core_description ndc )
      WHERE (ndc.ndc_formatted = data->qual[itemid_index ].supply.ndc_qual[ndc_index ].ndc )
      WITH nocounter
     ;end select
     IF ((curqual > 0 ) )
      SET data->qual[itemid_index ].supply.ndc_qual[ndc_index ].non_ref_ind = 0
     ELSE
      SET data->qual[itemid_index ].supply.ndc_qual[ndc_index ].non_ref_ind = 1
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM (v500.ndc_core_description ndc )
      WHERE (ndc.ndc_formatted = data->qual[itemid_index ].supply.ndc_qual[ndc_index ].ndc )
      WITH nocounter
     ;end select
     IF ((curqual > 0 ) )
      SET data->qual[itemid_index ].supply.ndc_qual[ndc_index ].non_ref_ind = 0
     ELSE
      SET data->qual[itemid_index ].supply.ndc_qual[ndc_index ].non_ref_ind = 1
     ENDIF
    ENDIF
   ENDFOR
  ENDFOR
 END ;Subroutine
 SUBROUTINE  loaditemidordalert (null )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (medication_definition md ),
    (med_def_flex mdf ),
    (med_flex_object_idx mfoi )
   PLAN (md
    WHERE (md.med_type_flag = 0 )
    AND expand (index ,1 ,data->cnt ,md.item_id ,data->qual[index ].general.item_id ) )
    JOIN (mdf
    WHERE (mdf.item_id = md.item_id )
    AND (mdf.flex_type_cd = 4062_sys_cd )
    AND (mdf.pharmacy_type_cd = 4500_inpt_cd ) )
    JOIN (mfoi
    WHERE (mfoi.med_def_flex_id = mdf.med_def_flex_id )
    AND (mfoi.flex_object_type_cd = 4063_ordalert_cd ) )
   ORDER BY md.item_id
   HEAD md.item_id
    pos = locatevalsort (index ,1 ,data->cnt ,md.item_id ,data->qual[index ].general.item_id ) ,ocnt
    = 0
   DETAIL
    IF ((pos > 0 ) ) ocnt = (ocnt + 1 ) ,
     IF ((mod (ocnt ,10 ) = 1 ) ) stat = alterlist (data->qual[pos ].clinicaloa.order_alert_qual ,(
       ocnt + 9 ) )
     ENDIF
     ,data->qual[pos ].clinicaloa.order_alert_qual[ocnt ].order_alert_display = trim (
      uar_get_code_display (mfoi.parent_entity_id ) ,3 )
    ENDIF
   FOOT  md.item_id
    data->qual[pos ].clinicaloa.oa_cnt = ocnt ,stat = alterlist (data->qual[pos ].clinicaloa.
     order_alert_qual ,ocnt ) ,
    IF ((data->qual[pos ].clinicaloa.oa_cnt > tot_oa_col ) ) tot_oa_col = data->qual[pos ].clinicaloa
     .oa_cnt
    ENDIF
   WITH nocounter ,expand = 2
  ;end select
 END ;Subroutine
 SUBROUTINE  checkreplace (txt ,qualifier )
  DECLARE return_val = vc WITH protect ,noconstant (txt )
  SET return_val = replace (return_val ,qualifier ,fillstring (2 ,qualifier ) ,0 )
  IF ((check (return_val ) != return_val ) )
   SET return_val = concat ("***SpecCharRmvd " ,check (return_val ) )
  ENDIF
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  addcolumnheader (c ,txt )
  SET c = (c + 1 )
  SET grid->row[1 ].col[c ].txt = txt
 END ;Subroutine
 SUBROUTINE  addcolumnheaderfacil (c ,codevalue )
  SET c = (c + 1 )
  SET grid->row[1 ].col[c ].code_value = codevalue
  SET grid->row[1 ].col[c ].txt = build ("FAC:" ,cnvtupper (uar_get_code_display (codevalue ) ) )
 END ;Subroutine
 SUBROUTINE  addcolumnheaderoa (c ,txt )
  SET c = (c + 1 )
  SET grid->row[1 ].col[c ].txt = txt
 END ;Subroutine
 SUBROUTINE  addvaluetxt (r ,c ,txt )
  SET c = (c + 1 )
  SET grid->row[r ].col[c ].txt = txt
 END ;Subroutine
 SUBROUTINE  addvaluetxtpivot (r ,c ,txt )
  SET grid->row[r ].col[c ].txt = txt
 END ;Subroutine
 SUBROUTINE  addvaluereal (r ,c ,real )
  SET c = (c + 1 )
  IF ((((real = - (1 ) ) ) OR ((real = 0 ) )) )
   SET grid->row[r ].col[c ].txt = " "
  ELSE
   SET grid->row[r ].col[c ].txt = format (real ,"##########.######;RT(1);F" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  addvalueint (r ,c ,int )
  SET c = (c + 1 )
  IF ((int = - (1 ) ) )
   SET grid->row[r ].col[c ].txt = " "
  ELSE
   SET grid->row[r ].col[c ].txt = cnvtstring (int ,17 )
  ENDIF
 END ;Subroutine
#exit_script
 SET last_mod = "000 09/08/16 SG021717 Initial Release"
END GO

