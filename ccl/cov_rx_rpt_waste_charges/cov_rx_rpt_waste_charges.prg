DROP PROGRAM cov_rx_rpt_waste_charges :dba GO
CREATE PROGRAM cov_rx_rpt_waste_charges :dba
 PROMPT
  "Output to file/printer/MINE:" = "MINE" ,
  "Enter the date range (mmddyyyy hhmm) FROM :" = "SYSDATE" ,
  "Enter the date range (mmddyyyy hhmm)   TO :" = "SYSDATE" ,
  "Enter the facility (* for all):" = ""
  WITH outdev ,startdate ,enddate ,facility
 IF ((reqinfo->updt_applctx <= 0 ) )
  CALL echo ("Report must be ran from Discern Explorer: Explorer Menu" )
  GO TO exit_script
 ENDIF
 SET modify = predeclare
 IF (NOT (validate (reply ,0 ) ) )
  RECORD reply (
    1 elapsed_time = f8
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF (NOT (validate (errorrec ,0 ) ) )
  RECORD errorrec (
    1 err_cnt = i4
    1 err [* ]
      2 err_code = i4
      2 err_msg = vc
  )
 ENDIF
 DECLARE lretval = i2 WITH private ,noconstant (0 )
 DECLARE i18nhandle = i4 WITH public ,noconstant (0 )
 IF ((validate (i18nuar_def ,999 ) = 999 ) )
  CALL echo ("Declaring i18nuar_def" )
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ,(p4 = f8 ) ) = i4 WITH
  persist
  DECLARE uar_i18ngetmessage ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ) = vc WITH persist
  DECLARE uar_i18nbuildmessage () = vc WITH persist
  DECLARE uar_i18ngethijridate ((imonth = i2 (val ) ) ,(iday = i2 (val ) ) ,(iyear = i2 (val ) ) ,(
   sdateformattype = vc (ref ) ) ) = c50 WITH image_axp = "shri18nuar" ,image_aix =
  "libi18n_locale.a(libi18n_locale.o)" ,uar = "uar_i18nGetHijriDate" ,persist
  DECLARE uar_i18nbuildfullformatname ((sfirst = vc (ref ) ) ,(slast = vc (ref ) ) ,(smiddle = vc (
    ref ) ) ,(sdegree = vc (ref ) ) ,(stitle = vc (ref ) ) ,(sprefix = vc (ref ) ) ,(ssuffix = vc (
    ref ) ) ,(sinitials = vc (ref ) ) ,(soriginal = vc (ref ) ) ) = c250 WITH image_axp =
  "shri18nuar" ,image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18nBuildFullFormatName" ,
  persist
  DECLARE uar_i18ngetarabictime ((ctime = vc (ref ) ) ) = c20 WITH image_axp = "shri18nuar" ,
  image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18n_GetArabicTime" ,persist
 ENDIF
 SET lretval = uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
 DECLARE nowaste = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"noWaste" ,"NO WASTE"
   ) )
 DECLARE errcode = i4 WITH protect ,noconstant (0 )
 DECLARE errcnt = i4 WITH protect ,noconstant (0 )
 DECLARE errmsg = c132 WITH protect ,noconstant (fillstring (132 ," " ) )
 RECORD temp_dh (
   1 elapsed_time = f8
   1 disp_cnt = i4
   1 dhlist [* ]
     2 dispense_hx_id = f8
     2 disp_event_type_cd = f8
     2 dispense_dt_tm = dq8
     2 dispense_tz = i4
     2 order_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 loc_nurse_unit_cd = f8
     2 skip_flag = i2
     2 prod_cnt = i4
     2 event_id = f8
     2 rn_waste_amount = vc
     2 prodlist [* ]
       3 prod_dispense_hx_id = f8
       3 item_id = f8
       3 charge_qty = f8
       3 rxs_waste_qty = f8
       3 available_waste_qty = f8
       3 available_waste_charge_qty = f8
       3 manf_item_id = f8
       3 dispense_qty_uom_cd = f8
       3 cms_waste_billing_unit_amt = f8
       3 cms_waste_billing_unit_uom_cd = f8
       3 catalog_cd = f8
       3 current_waste_ind = i2
 ) WITH protect
 RECORD temp_rpt (
   1 qual [* ]
     2 waste_status_flag = i2
     2 person_id = f8
     2 name_full_formatted = vc
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 mrn = vc
     2 encntr_id = f8
     2 fin_nbr = vc
     2 facility_cd = f8
     2 nurse_unit_cd = f8
     2 dept_misc_line = vc
     2 order_id = f8
     2 order_status_cd = f8
     2 disp_event_type_cd = f8
     2 dispense_dt_tm = dq8
     2 dispense_tz = i4
     2 dispense_dt_tm_str = vc
     2 dispense_hx_id = f8
     2 item_id = f8
     2 label_desc = vc
     2 manf_item_id = f8
     2 drug_identifier = vc
     2 cms_waste_billing_unit_amt = f8
     2 cms_waste_billing_unit_uom_cd = f8
     2 product_qty = f8
     2 available_waste_qty = f8
     2 available_waste_charge_qty = f8
     2 dispense_qty_uom_cd = f8
     2 rxs_waste_qty = f8
     2 event_id = f8
     2 rn_waste_amount = vc
 ) WITH protect
 RECORD bscrequest (
   1 med_event_qual [* ]
     2 parent_event_id = f8
   1 facility_cd = f8
   1 begin_search_date_tm = dq8
   1 end_search_date_tm = dq8
 )
 RECORD bscreply (
   1 qual [* ]
     2 encntr_id = f8
     2 parent_event_id = f8
     2 related_med_event_id = f8
     2 person_id = f8
     2 nurse_unit_cd = f8
     2 order_id = f8
     2 bag_nbr = vc
     2 dta_waste_string = vc
     2 vol_waste_val = f8
     2 vol_waste_unit_cd = f8
     2 ingred_qual [* ]
       3 waste_val = f8
       3 waste_unit_cd = f8
       3 catalog_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD configrequest (
   1 qual [* ]
     2 encounter_id = f8
     2 facility_cd = f8
     2 nurse_unit_cd = f8
 )
 RECORD configreply (
   1 qual [* ]
     2 encounter_id = f8
     2 facility_cd = f8
     2 nurse_unit_cd = f8
     2 waste_enabled_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ddesc = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,11000 ,"DESC" ) )
 DECLARE dndc = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,11000 ,"NDC" ) )
 DECLARE dinpatient = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4500 ,"INPATIENT" ) )
 DECLARE dcoa = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4032 ,"CHGONADMIN" ) )
 DECLARE ddevicewaste = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4032 ,"DEVICEWASTE" )
  )
 DECLARE dfin = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,319 ,"FIN NBR" ) )
 DECLARE dmrn = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,319 ,"MRN" ) )
 DECLARE csuccess = i2 WITH private ,constant (0 )
 DECLARE cfailed_ccl_error = i2 WITH private ,constant (1 )
 DECLARE dprecision = f8 WITH protect ,constant (0.000001 )
 DECLARE dhidx = i2 WITH protect ,noconstant (0 )
 DECLARE dperson_mrn_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4 ,"MRN" ) )
 DECLARE dsyspack = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4062 ,"SYSPKGTYP" ) )
 DECLARE dwastecharge = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4032 ,"WASTECHARGE" )
  )
 DECLARE dfacility = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4062 ,"FACILITY" ) )
 DECLARE dmeddisp = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4063 ,"DISPENSE" ) )
 DECLARE dstarttime = dq8 WITH private ,noconstant (curtime3 )
 DECLARE delapsedtime = f8 WITH private ,noconstant (0.0 )
 DECLARE nprodcount = i4 WITH private ,noconstant (0 )
 DECLARE ndhcount = i4 WITH private ,noconstant (0 )
 DECLARE nconfigreqcount = i4 WITH private ,noconstant (0 )
 DECLARE stat = i4 WITH private ,noconstant (0 )
 DECLARE nscriptstatus = i2 WITH private ,noconstant (csuccess )
 DECLARE nzeroresults = i2 WITH private ,noconstant (0 )
 DECLARE lidx = i4 WITH protect ,noconstant (0 )
 DECLARE lingidx = i4 WITH protect ,noconstant (0 )
 DECLARE lprodcnt = i4 WITH protect ,noconstant (0 )
 DECLARE lpidx = i4 WITH protect ,noconstant (0 )
 DECLARE lrptidx = i4 WITH protect ,noconstant (0 )
 DECLARE lrptidx2 = i4 WITH protect ,noconstant (0 )
 DECLARE nrptcount = i4 WITH protect ,noconstant (0 )
 DECLARE eventcnt = i4 WITH protect ,noconstant (0 )
 DECLARE eventidx = i4 WITH protect ,noconstant (0 )
 DECLARE nfacilitycounter = i2 WITH protect ,noconstant (0 )
 DECLARE nactualsize = i4 WITH protect ,noconstant (0 )
 DECLARE nexpandsize = i2 WITH protect ,constant (50 )
 DECLARE nexpandtotal = i4 WITH protect ,noconstant (0 )
 DECLARE nexpandstart = i4 WITH protect ,noconstant (0 )
 DECLARE nexpandstop = i4 WITH protect ,noconstant (0 )
 DECLARE nexpand = i2 WITH protect ,noconstant (0 )
 DECLARE cformat = c50 WITH protect ,constant (fillstring (50 ,"#" ) )
 DECLARE num = i4 WITH noconstant (0 )
 DECLARE start = i4 WITH noconstant (1 )
 DECLARE configreplysize = i4 WITH noconstant (0 )
 DECLARE sutcdatetime = vc WITH protect ,noconstant (" " )
 DECLARE dutcdatetime = f8 WITH protect ,noconstant (0.0 )
 DECLARE cutc = i2 WITH protect ,constant (curutc )
 SUBROUTINE  (utcdatetime (sdatetime =vc ,lindex =i4 ,bshowtz =i2 ,sformat =vc ) =vc )
  DECLARE offset = i2 WITH protect ,noconstant (0 )
  DECLARE daylight = i2 WITH protect ,noconstant (0 )
  DECLARE lnewindex = i4 WITH protect ,noconstant (curtimezoneapp )
  DECLARE snewdatetime = vc WITH protect ,noconstant (" " )
  DECLARE ctime_zone_format = vc WITH protect ,constant ("ZZZ" )
  IF ((lindex > 0 ) )
   SET lnewindex = lindex
  ENDIF
  SET snewdatetime = datetimezoneformat (sdatetime ,lnewindex ,sformat )
  IF ((cutc = 1 )
  AND (bshowtz = 1 ) )
   IF ((size (trim (snewdatetime ) ) > 0 ) )
    SET snewdatetime = concat (snewdatetime ," " ,datetimezoneformat (sdatetime ,lnewindex ,
      ctime_zone_format ) )
   ENDIF
  ENDIF
  SET snewdatetime = trim (snewdatetime )
  RETURN (snewdatetime )
 END ;Subroutine
 SUBROUTINE  (utcshorttz (lindex =i4 ) =vc )
  DECLARE offset = i2 WITH protect ,noconstant (0 )
  DECLARE daylight = i2 WITH protect ,noconstant (0 )
  DECLARE lnewindex = i4 WITH protect ,noconstant (curtimezoneapp )
  DECLARE snewshorttz = vc WITH protect ,noconstant (" " )
  DECLARE ctime_zone_format = i2 WITH protect ,constant (7 )
  IF ((cutc = 1 ) )
   IF ((lindex > 0 ) )
    SET lnewindex = lindex
   ENDIF
   SET snewshorttz = datetimezonebyindex (lnewindex ,offset ,daylight ,ctime_zone_format )
  ENDIF
  SET snewshorttz = trim (snewshorttz )
  RETURN (snewshorttz )
 END ;Subroutine
 CALL echo ("********** BEGIN RX_RPT_WASTE_CHARGES **********" )
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1 ].operationname = "GET"
 SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
 SET reply->status_data.subeventstatus[1 ].targetobjectname = "RX_RPT_WASTE_CHARGES"
 SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "RX_RPT_WASTE_CHARGES FAILED"
 EXECUTE rx_get_facs_for_prsnl_rr_incl WITH replace ("REQUEST" ,"PRSNL_FACS_REQ" ) ,
 replace ("REPLY" ,"PRSNL_FACS_REPLY" )
 SET stat = alterlist (prsnl_facs_req->qual ,1 )
 CALL echo (build ("Reqinfo->updt_id --" ,reqinfo->updt_id ) )
 CALL echo (build ("curuser --" ,curuser ) )
 SET prsnl_facs_req->qual[1 ].username = trim (curuser )
 SET prsnl_facs_req->qual[1 ].person_id = reqinfo->updt_id
 EXECUTE rx_get_facs_for_prsnl WITH replace ("REQUEST" ,"PRSNL_FACS_REQ" ) ,
 replace ("REPLY" ,"PRSNL_FACS_REPLY" )
 CALL echo (build ("Size of facility list in prg--" ,size (prsnl_facs_reply->qual[1 ].facility_list ,
    5 ) ) )
 FREE RECORD facility_list
 RECORD facility_list (
   1 qual [* ]
     2 facility_cd = f8
 )
 SET stat = alterlist (facility_list->qual ,value (size (prsnl_facs_reply->qual[1 ].facility_list ,5
    ) ) )
 FOR (x = 1 TO size (prsnl_facs_reply->qual[1 ].facility_list ,5 ) )
  CALL echo (build ("Checking facility --" ,trim (format (prsnl_facs_reply->qual[1 ].facility_list[x
      ].facility_cd ,cformat ) ,3 ) ) )
  CALL echo (build ("against --" , $FACILITY ) )
  IF ((trim (format (prsnl_facs_reply->qual[1 ].facility_list[x ].facility_cd ,cformat ) ,3 ) =
   $FACILITY ) )
   SET nfacilitycounter +=1
   SET facility_list->qual[nfacilitycounter ].facility_cd = prsnl_facs_reply->qual[1 ].facility_list[
   x ].facility_cd
  ENDIF
 ENDFOR
 SET stat = alterlist (facility_list->qual ,nfacilitycounter )
 SET nactualsize = size (facility_list->qual ,5 )
 CALL echo (build ("nActualSize --" ,nactualsize ) )
 IF ((nactualsize = 0 ) )
  CALL echo ("*** User does not have access to facility selection ***" )
  GO TO exit_script
 ENDIF
 SET nexpandtotal = (nactualsize + (nexpandsize - mod (nactualsize ,nexpandsize ) ) )
 SET nexpandstart = 1
 SET nexpandstop = 50
 SET stat = alterlist (facility_list->qual ,nexpandtotal )
 FOR (x = (nactualsize + 1 ) TO nexpandtotal )
  SET facility_list->qual[x ].facility_cd = facility_list->qual[nactualsize ].facility_cd
 ENDFOR
 SUBROUTINE  (getstring (dfieldvalue =f8 ) =vc )
  DECLARE sreturnstring = vc WITH protect ,noconstant ("0" )
  IF ((dfieldvalue > 0 ) )
   SET sreturnstring = trim (format (dfieldvalue ,"############.####;,ILT(1);F" ) )
  ENDIF
  RETURN (sreturnstring )
 END ;Subroutine
 SELECT INTO "nl:"
  FROM (dispense_hx dh ),
   (prod_dispense_hx pdh ),
   (order_dispense od ),
   (encounter e ),
   (med_def_flex mdf ),
   (med_flex_object_idx mfoi ),
   (med_dispense md ),
   (med_package_type mpt ),
   (order_catalog_item_r ocir ),
   (dummyt d WITH seq = value ((nexpandtotal / nexpandsize ) ) )
  PLAN (d
   WHERE assign (nexpandstart ,evaluate (d.seq ,1 ,1 ,(nexpandstart + nexpandsize ) ) )
   AND assign (nexpandstop ,(nexpandstart + (nexpandsize - 1 ) ) ) )
   JOIN (dh
   WHERE (dh.dispense_dt_tm BETWEEN cnvtdatetime ( $STARTDATE ) AND cnvtdatetime ( $ENDDATE ) )
   AND (dh.pharm_type_cd = dinpatient )
   AND (dh.waste_flag = 1 )
   and  dh.disp_event_type_cd != 638938.00)
   JOIN (pdh
   WHERE (pdh.dispense_hx_id = dh.dispense_hx_id )
   AND (pdh.available_waste_charge_qty > 0 )
   AND (pdh.available_waste_charge_qty = pdh.max_waste_charge_qty )
   AND (pdh.item_id > 0 )
   AND (pdh.waste_flag = 1 ) )
   JOIN (ocir
   WHERE (ocir.item_id = pdh.item_id ) )
   JOIN (od
   WHERE (dh.order_id = od.order_id )
   AND (((od.encntr_id = 0 )
   AND expand (nexpand ,nexpandstart ,nexpandstop ,od.future_loc_facility_cd ,facility_list->qual[
    nexpand ].facility_cd ) ) OR ((od.encntr_id > 0 ) )) )
   JOIN (e
   WHERE (od.encntr_id = e.encntr_id )
   AND (((e.encntr_id > 0 )
   AND expand (nexpand ,nexpandstart ,nexpandstop ,e.loc_facility_cd ,facility_list->qual[nexpand ].
    facility_cd ) ) OR ((e.encntr_id = 0 ) )) )
   JOIN (mdf
   WHERE (mdf.pharmacy_type_cd = dinpatient )
   AND (mdf.item_id = pdh.item_id )
   AND (((mdf.sequence = 0 )
   AND (mdf.flex_type_cd = dsyspack ) ) OR ((((mdf.parent_entity_id = e.loc_facility_cd )
   AND (mdf.flex_type_cd = dfacility ) ) OR ((mdf.parent_entity_id = od.future_loc_facility_cd )
   AND (mdf.flex_type_cd = dfacility ) )) )) )
   JOIN (mfoi
   WHERE (mfoi.med_def_flex_id = mdf.med_def_flex_id )
   AND (mfoi.flex_object_type_cd = dmeddisp )
   AND (mfoi.sequence = 1 ) )
   JOIN (md
   WHERE (md.med_dispense_id = mfoi.parent_entity_id ) )
   JOIN (mpt
   WHERE (mpt.med_package_type_id = mdf.med_package_type_id ) )
  ORDER BY dh.dispense_hx_id ,
   pdh.prod_dispense_hx_id ,
   md.parent_entity_id
  HEAD REPORT
   ndhcount = 0 ,
   nprodcount = 0 ,
   nconfigreqcount = 0
  HEAD dh.dispense_hx_id
   ndhcount +=1 ,
   IF ((mod (ndhcount ,10 ) = 1 ) ) stat = alterlist (temp_dh->dhlist ,(ndhcount + 9 ) ) ,stat2 =
    alterlist (configrequest->qual ,(ndhcount + 9 ) )
   ENDIF
   ,temp_dh->dhlist[ndhcount ].dispense_hx_id = dh.dispense_hx_id ,temp_dh->dhlist[ndhcount ].
   disp_event_type_cd = dh.disp_event_type_cd ,temp_dh->dhlist[ndhcount ].dispense_dt_tm =
   cnvtdatetime (dh.dispense_dt_tm ) ,temp_dh->dhlist[ndhcount ].dispense_tz = dh.dispense_tz ,
   temp_dh->dhlist[ndhcount ].order_id = od.order_id ,temp_dh->dhlist[ndhcount ].person_id = od
   .person_id ,temp_dh->dhlist[ndhcount ].encntr_id = od.encntr_id ,temp_dh->dhlist[ndhcount ].
   skip_flag = 0 ,
   IF ((e.encntr_id > 0 ) ) temp_dh->dhlist[ndhcount ].loc_facility_cd = e.loc_facility_cd ,temp_dh->
    dhlist[ndhcount ].loc_nurse_unit_cd = e.loc_nurse_unit_cd
   ENDIF
   ,
   IF ((e.encntr_id = 0 ) ) temp_dh->dhlist[ndhcount ].loc_facility_cd = od.future_loc_facility_cd ,
    temp_dh->dhlist[ndhcount ].loc_nurse_unit_cd = od.future_loc_nurse_unit_cd
   ENDIF
   ,temp_dh->dhlist[ndhcount ].skip_flag = 0 ,
   IF ((dh.disp_event_type_cd = dcoa ) ) temp_dh->dhlist[ndhcount ].event_id = dh.event_id
   ENDIF
   ,temp_dh->dhlist[ndhcount ].rn_waste_amount = " " ,nprodcount = 0 ,
   IF ((e.encntr_id > 0 ) ) num = 0 ,start = 1 ,pos = locateval (num ,start ,size (configrequest->
      qual ,5 ) ,e.encntr_id ,configrequest->qual[num ].encounter_id ,e.loc_facility_cd ,
     configrequest->qual[num ].facility_cd ,e.loc_nurse_unit_cd ,configrequest->qual[num ].
     nurse_unit_cd ) ,
    IF ((pos <= 0 ) ) nconfigreqcount +=1 ,configrequest->qual[nconfigreqcount ].encounter_id = e
     .encntr_id ,configrequest->qual[nconfigreqcount ].facility_cd = e.loc_facility_cd ,configrequest
     ->qual[nconfigreqcount ].nurse_unit_cd = e.loc_nurse_unit_cd
    ENDIF
   ENDIF
   ,
   IF ((e.encntr_id = 0 ) ) num = 0 ,start = 1 ,pos = locateval (num ,start ,size (configrequest->
      qual ,5 ) ,e.encntr_id ,configrequest->qual[num ].encounter_id ,od.future_loc_facility_cd ,
     configrequest->qual[num ].facility_cd ,od.future_loc_nurse_unit_cd ,configrequest->qual[num ].
     nurse_unit_cd ) ,
    IF ((pos <= 0 ) ) nconfigreqcount +=1 ,configrequest->qual[nconfigreqcount ].encounter_id = e
     .encntr_id ,configrequest->qual[nconfigreqcount ].facility_cd = od.future_loc_facility_cd ,
     configrequest->qual[nconfigreqcount ].nurse_unit_cd = od.future_loc_nurse_unit_cd
    ENDIF
   ENDIF
  HEAD pdh.prod_dispense_hx_id
   nprodcount +=1 ,stat = alterlist (temp_dh->dhlist[ndhcount ].prodlist ,nprodcount ) ,temp_dh->
   dhlist[ndhcount ].prodlist[nprodcount ].prod_dispense_hx_id = pdh.prod_dispense_hx_id ,temp_dh->
   dhlist[ndhcount ].prodlist[nprodcount ].item_id = pdh.item_id ,temp_dh->dhlist[ndhcount ].
   prodlist[nprodcount ].charge_qty = pdh.charge_qty ,temp_dh->dhlist[ndhcount ].prodlist[nprodcount
   ].available_waste_qty = pdh.available_waste_qty ,temp_dh->dhlist[ndhcount ].prodlist[nprodcount ].
   available_waste_charge_qty = pdh.available_waste_charge_qty ,temp_dh->dhlist[ndhcount ].prodlist[
   nprodcount ].manf_item_id = pdh.manf_item_id ,temp_dh->dhlist[ndhcount ].prodlist[nprodcount ].
   dispense_qty_uom_cd = mpt.uom_cd ,temp_dh->dhlist[ndhcount ].prodlist[nprodcount ].
   cms_waste_billing_unit_amt = md.cms_waste_billing_unit_amt ,temp_dh->dhlist[ndhcount ].prodlist[
   nprodcount ].cms_waste_billing_unit_uom_cd = md.cms_waste_billing_unit_uom_cd ,temp_dh->dhlist[
   ndhcount ].prodlist[nprodcount ].catalog_cd = ocir.catalog_cd ,temp_dh->dhlist[ndhcount ].
   prodlist[nprodcount ].current_waste_ind = pdh.waste_flag ,temp_dh->dhlist[ndhcount ].prod_cnt =
   nprodcount
  DETAIL
   IF ((((md.parent_entity_id = 0 ) ) OR ((md.parent_entity_id = temp_dh->dhlist[ndhcount ].
   loc_facility_cd ) )) ) temp_dh->dhlist[ndhcount ].prodlist[nprodcount ].current_waste_ind = md
    .waste_charge_ind
   ENDIF
  FOOT REPORT
   temp_dh->disp_cnt = ndhcount ,
   stat = alterlist (temp_dh->dhlist ,ndhcount ) ,
   stat = alterlist (configrequest->qual ,nconfigreqcount )
  WITH nocounter
 ;end select
 IF ((curqual = 0 ) )
  SET nzeroresults = 1
  CALL echo ("****** No items qualified in the main select...exiting ******" )
  SET reply->status_data.subeventstatus[1 ].targetobjectvalue =
  "NO WASTE DISPENSE EVENTS QUALIFIED IN THE MAIN SELECT"
  GO TO exit_script
 ENDIF
 CALL echorecord (configrequest )
 EXECUTE rx_get_waste_config WITH replace (request ,configrequest ) ,
 replace (reply ,configreply )
 CALL echorecord (configreply )
 SET num = 0
 SET start = 1
 DECLARE nzero = i4 WITH private ,constant (0 )
 FOR (lrptidx = 1 TO temp_dh->disp_cnt )
  SET configreplysize = size (configreply->qual ,5 )
  SET pos = locateval (num ,start ,configreplysize ,temp_dh->dhlist[lrptidx ].encntr_id ,configreply
   ->qual[num ].encounter_id ,temp_dh->dhlist[lrptidx ].loc_facility_cd ,configreply->qual[num ].
   facility_cd ,temp_dh->dhlist[lrptidx ].loc_nurse_unit_cd ,configreply->qual[num ].nurse_unit_cd ,
   nzero ,configreply->qual[num ].waste_enabled_ind )
  IF ((pos > 0 )
  AND (pos <= temp_dh->disp_cnt ) )
   SET temp_dh->dhlist[lrptidx ].skip_flag = 1
  ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = value (temp_dh->disp_cnt ) ),
   (dispense_hx dh ),
   (prod_dispense_hx pdh )
  PLAN (d
   WHERE (temp_dh->dhlist[d.seq ].skip_flag = 0 ) )
   JOIN (dh
   WHERE (temp_dh->dhlist[d.seq ].dispense_hx_id = dh.chrg_dispense_hx_id )
   AND (((((dh.charge_ind = 1 ) ) OR ((dh.future_charge_ind = 1 ) ))
   AND (dh.disp_event_type_cd != ddevicewaste ) ) OR ((dh.disp_event_type_cd = ddevicewaste ) )) )
   JOIN (pdh
   WHERE (pdh.dispense_hx_id = dh.dispense_hx_id )
   AND (pdh.item_id > 0 ) )
  ORDER BY d.seq
  HEAD d.seq
   lprodcnt = temp_dh->dhlist[d.seq ].prod_cnt
  DETAIL
   lpidx = locateval (lidx ,1 ,lprodcnt ,pdh.item_id ,temp_dh->dhlist[d.seq ].prodlist[lidx ].item_id
     ) ,
   IF ((lpidx > 0 ) )
    IF ((temp_dh->dhlist[d.seq ].prodlist[lpidx ].current_waste_ind = 1 ) )
     IF ((((dh.charge_ind = 1 ) ) OR ((dh.future_charge_ind = 1 ) )) ) temp_dh->dhlist[d.seq ].
      prodlist[lpidx ].charge_qty -=pdh.credit_qty ,
      IF ((dh.disp_event_type_cd = ddevicewaste ) ) temp_dh->dhlist[d.seq ].prodlist[lpidx ].
       rxs_waste_qty +=pdh.credit_qty
      ENDIF
     ELSEIF ((dh.disp_event_type_cd = ddevicewaste ) ) temp_dh->dhlist[d.seq ].prodlist[lpidx ].
      rxs_waste_qty +=pdh.charge_qty
     ENDIF
    ENDIF
   ENDIF
  FOOT  d.seq
   temp_dh->dhlist[d.seq ].skip_flag = 1 ,
   FOR (lidx = 1 TO temp_dh->dhlist[d.seq ].prod_cnt )
    IF ((temp_dh->dhlist[d.seq ].prodlist[lidx ].charge_qty > 0 ) ) temp_dh->dhlist[d.seq ].skip_flag
      = 0
    ENDIF
   ENDFOR
  WITH nocounter ,expand = 1
 ;end select
 CALL echo ("****** TEMP_DH RECORD ******" )
 CALL echorecord (temp_dh )
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = value (temp_dh->disp_cnt ) ),
   (dispense_hx dh )
  PLAN (d
   WHERE (temp_dh->dhlist[d.seq ].skip_flag = 0 ) )
   JOIN (dh
   WHERE (temp_dh->dhlist[d.seq ].dispense_hx_id = dh.waste_dispense_hx_id )
   AND (dh.disp_event_type_cd = dwastecharge )
   AND (((dh.charge_ind = 1 ) ) OR ((dh.future_charge_ind = 1 ) )) )
  ORDER BY d.seq
  HEAD d.seq
   temp_dh->dhlist[d.seq ].skip_flag = 1
  WITH nocounter
 ;end select
 CALL echo ("****** TEMP_DH RECORD ******" )
 CALL echorecord (temp_dh )
 CALL echo (build2 ("disp_cnt:" ,temp_dh->disp_cnt ) )
 SET stat = alterlist (bscrequest->med_event_qual ,temp_dh->disp_cnt )
 FOR (dhidx = 1 TO temp_dh->disp_cnt )
  CALL echo (build2 ("eventCnt:" ,eventcnt ) )
  IF ((temp_dh->dhlist[dhidx ].skip_flag = 0 )
  AND (temp_dh->dhlist[dhidx ].event_id > 0 ) )
   SET eventcnt +=1
   CALL echo (build2 ("eventCnt:" ,eventcnt ) )
   SET bscrequest->med_event_qual[eventcnt ].parent_event_id = temp_dh->dhlist[dhidx ].event_id
  ENDIF
 ENDFOR
 SET stat = alterlist (bscrequest->med_event_qual ,eventcnt )
 IF ((eventcnt > 0 ) )
  CALL echorecord (bscrequest )
  EXECUTE bsc_retrieve_waste_results WITH replace ("REQUEST" ,"BSCREQUEST" ) ,
  replace ("REPLY" ,"BSCREPLY" )
  CALL echorecord (bscreply )
  FOR (eventidx = 1 TO size (bscreply->qual ,5 ) )
   SET dhidx = locateval (lidx ,1 ,temp_dh->disp_cnt ,bscreply->qual[eventidx ].related_med_event_id
    ,temp_dh->dhlist[lidx ].event_id )
   IF ((dhidx > 0 ) )
    IF ((size (trim (bscreply->qual[eventidx ].dta_waste_string ) ,1 ) > 1 ) )
     SET temp_dh->dhlist[dhidx ].rn_waste_amount = bscreply->qual[eventidx ].dta_waste_string
    ELSE
     FOR (lingidx = 1 TO value (size (bscreply->qual[eventidx ].ingred_qual ,5 ) ) )
      IF ((temp_dh->dhlist[dhidx ].prodlist[1 ].catalog_cd = bscreply->qual[eventidx ].ingred_qual[
      lingidx ].catalog_cd ) )
       SET temp_dh->dhlist[dhidx ].rn_waste_amount = substring (1 ,80 ,concat (trim (substring (1 ,
           40 ,getstring (bscreply->qual[eventidx ].ingred_qual[lingidx ].waste_val ) ) ) ," " ,trim
         (substring (1 ,40 ,uar_get_code_display (bscreply->qual[eventidx ].ingred_qual[lingidx ].
            waste_unit_cd ) ) ) ) )
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
 CALL echorecord (temp_dh )
 FOR (lrptidx = 1 TO temp_dh->disp_cnt )
  FOR (lrptidx2 = 1 TO temp_dh->dhlist[lrptidx ].prod_cnt )
   IF ((temp_dh->dhlist[lrptidx ].skip_flag = 0 ) )
    IF ((temp_dh->dhlist[lrptidx ].prodlist[lrptidx2 ].charge_qty > 0 )
    AND (temp_dh->dhlist[lrptidx ].prodlist[lrptidx2 ].current_waste_ind = 1 ) )
     SET nrptcount +=1
     IF ((mod (nrptcount ,10 ) = 1 ) )
      SET stat = alterlist (temp_rpt->qual ,(nrptcount + 9 ) )
     ENDIF
     SET temp_rpt->qual[nrptcount ].waste_status_flag = 0
     SET temp_rpt->qual[nrptcount ].person_id = temp_dh->dhlist[lrptidx ].person_id
     SET temp_rpt->qual[nrptcount ].name_full_formatted = " "
     SET temp_rpt->qual[nrptcount ].birth_dt_tm = 0
     SET temp_rpt->qual[nrptcount ].birth_tz = 0
     SET temp_rpt->qual[nrptcount ].mrn = " "
     SET temp_rpt->qual[nrptcount ].encntr_id = temp_dh->dhlist[lrptidx ].encntr_id
     SET temp_rpt->qual[nrptcount ].fin_nbr = " "
     IF ((temp_dh->dhlist[lrptidx ].encntr_id > 0 ) )
      SET temp_rpt->qual[nrptcount ].facility_cd = temp_dh->dhlist[lrptidx ].loc_facility_cd
      SET temp_rpt->qual[nrptcount ].nurse_unit_cd = temp_dh->dhlist[lrptidx ].loc_nurse_unit_cd
     ELSE
      SET temp_rpt->qual[nrptcount ].facility_cd = " "
      SET temp_rpt->qual[nrptcount ].nurse_unit_cd = " "
     ENDIF
     SET temp_rpt->qual[nrptcount ].dept_misc_line = " "
     SET temp_rpt->qual[nrptcount ].order_id = temp_dh->dhlist[lrptidx ].order_id
     SET temp_rpt->qual[nrptcount ].order_status_cd = 0
     SET temp_rpt->qual[nrptcount ].disp_event_type_cd = temp_dh->dhlist[lrptidx ].disp_event_type_cd
     SET temp_rpt->qual[nrptcount ].dispense_dt_tm = cnvtdatetime (temp_dh->dhlist[lrptidx ].
      dispense_dt_tm )
     SET temp_rpt->qual[nrptcount ].dispense_tz = temp_dh->dhlist[lrptidx ].dispense_tz
     SET temp_rpt->qual[nrptcount ].dispense_dt_tm_str = concat (utcdatetime (cnvtdatetime (temp_rpt
        ->qual[nrptcount ].dispense_dt_tm ) ,temp_rpt->qual[nrptcount ].dispense_tz ,0 ,
       "@SHORTDATETIME" ) ," " ,utcshorttz (temp_rpt->qual[nrptcount ].dispense_tz ) )
     SET temp_rpt->qual[nrptcount ].dispense_hx_id = temp_dh->dhlist[lrptidx ].dispense_hx_id
     SET temp_rpt->qual[nrptcount ].item_id = temp_dh->dhlist[lrptidx ].prodlist[lrptidx2 ].item_id
     SET temp_rpt->qual[nrptcount ].label_desc = " "
     SET temp_rpt->qual[nrptcount ].manf_item_id = temp_dh->dhlist[lrptidx ].prodlist[lrptidx2 ].
     manf_item_id
     SET temp_rpt->qual[nrptcount ].drug_identifier = " "
     SET temp_rpt->qual[nrptcount ].cms_waste_billing_unit_amt = temp_dh->dhlist[lrptidx ].prodlist[
     lrptidx2 ].cms_waste_billing_unit_amt
     SET temp_rpt->qual[nrptcount ].cms_waste_billing_unit_uom_cd = temp_dh->dhlist[lrptidx ].
     prodlist[lrptidx2 ].cms_waste_billing_unit_uom_cd
     SET temp_rpt->qual[nrptcount ].product_qty = temp_dh->dhlist[lrptidx ].prodlist[lrptidx2 ].
     charge_qty
     SET temp_rpt->qual[nrptcount ].available_waste_qty = temp_dh->dhlist[lrptidx ].prodlist[
     lrptidx2 ].available_waste_qty
     SET temp_rpt->qual[nrptcount ].available_waste_charge_qty = temp_dh->dhlist[lrptidx ].prodlist[
     lrptidx2 ].available_waste_charge_qty
     SET temp_rpt->qual[nrptcount ].dispense_qty_uom_cd = temp_dh->dhlist[lrptidx ].prodlist[
     lrptidx2 ].dispense_qty_uom_cd
     SET temp_rpt->qual[nrptcount ].rxs_waste_qty = temp_dh->dhlist[lrptidx ].prodlist[lrptidx2 ].
     rxs_waste_qty
     SET temp_rpt->qual[nrptcount ].event_id = temp_dh->dhlist[lrptidx ].event_id
     SET temp_rpt->qual[nrptcount ].rn_waste_amount = temp_dh->dhlist[lrptidx ].rn_waste_amount
    ENDIF
   ENDIF
  ENDFOR
 ENDFOR
 SET stat = alterlist (temp_rpt->qual ,nrptcount )
 CALL echo ("****** TEMP_RPT RECORD ******" )
 CALL echorecord (temp_rpt )
 IF ((nrptcount > 0 ) )
  SELECT INTO "nl:"
   FROM (dummyt d WITH seq = value (nrptcount ) ),
    (person p ),
    (orders o ),
    (med_identifier mi ),
    (med_product mp ),
    (med_identifier mi2 ),
    (person_alias pa ),
    (encounter e ),
    (encntr_alias ea ),
    (encntr_alias ea2 )
   PLAN (d )
    JOIN (p
    WHERE (temp_rpt->qual[d.seq ].person_id = p.person_id ) )
    JOIN (o
    WHERE (temp_rpt->qual[d.seq ].order_id = o.order_id ) )
    JOIN (mp
    WHERE (temp_rpt->qual[d.seq ].manf_item_id = mp.manf_item_id ) )
    JOIN (mi2
    WHERE (temp_rpt->qual[d.seq ].item_id = mi2.item_id )
    AND (mi2.active_ind = 1 )
    AND (mi2.primary_ind = 1 )
    AND (mi2.med_product_id = mp.med_product_id )
    AND (mi2.med_identifier_type_cd = dndc )
    AND (mi2.pharmacy_type_cd = dinpatient ) )
    JOIN (mi
    WHERE (mi2.item_id = mi.item_id )
    AND (mi.active_ind = 1 )
    AND (mi.primary_ind = 1 )
    AND (mi.med_product_id = 0 )
    AND (mi.med_identifier_type_cd = ddesc )
    AND (mi.pharmacy_type_cd = dinpatient ) )
    JOIN (pa
    WHERE (pa.person_id = Outerjoin(p.person_id ))
    AND (pa.person_alias_type_cd = Outerjoin(dperson_mrn_cd ))
    AND (pa.active_ind = Outerjoin(1 ))
    AND (pa.beg_effective_dt_tm <= Outerjoin(cnvtdatetime (sysdate ) ))
    AND (pa.end_effective_dt_tm > Outerjoin(cnvtdatetime (sysdate ) )) )
    JOIN (e
    WHERE (e.encntr_id = Outerjoin(temp_rpt->qual[d.seq ].encntr_id )) )
    JOIN (ea
    WHERE (ea.encntr_id = Outerjoin(e.encntr_id ))
    AND (ea.encntr_alias_type_cd = Outerjoin(dfin ))
    AND (ea.active_ind = Outerjoin(1 ))
    AND (ea.beg_effective_dt_tm <= Outerjoin(cnvtdatetime (sysdate ) ))
    AND (ea.end_effective_dt_tm >= Outerjoin(cnvtdatetime (sysdate ) )) )
    JOIN (ea2
    WHERE (ea2.encntr_id = Outerjoin(e.encntr_id ))
    AND ((ea2.encntr_alias_type_cd + 0 ) = Outerjoin(dmrn ))
    AND ((ea2.active_ind + 0 ) = Outerjoin(1 ))
    AND ((ea2.beg_effective_dt_tm + 0 ) <= Outerjoin(cnvtdatetime (sysdate ) ))
    AND ((ea2.end_effective_dt_tm + 0 ) >= Outerjoin(cnvtdatetime (sysdate ) )) )
   ORDER BY d.seq
   HEAD REPORT
    x = 0
   DETAIL
    temp_rpt->qual[d.seq ].name_full_formatted = trim (p.name_full_formatted ) ,
    temp_rpt->qual[d.seq ].birth_dt_tm = cnvtdatetime (p.birth_dt_tm ) ,
    temp_rpt->qual[d.seq ].birth_tz = p.birth_tz ,
    IF ((ea2.alias != null )
    AND (ea2.alias != "" ) ) temp_rpt->qual[d.seq ].mrn = ea2.alias
    ELSE temp_rpt->qual[d.seq ].mrn = pa.alias
    ENDIF
    ,temp_rpt->qual[d.seq ].mrn = ea2.alias ,
    temp_rpt->qual[d.seq ].fin_nbr = ea.alias ,
    temp_rpt->qual[d.seq ].dept_misc_line = trim (o.dept_misc_line ) ,
    temp_rpt->qual[d.seq ].order_status_cd = o.order_status_cd ,
    temp_rpt->qual[d.seq ].label_desc = trim (mi.value ) ,
    temp_rpt->qual[d.seq ].drug_identifier = trim (mi2.value )
   WITH nocounter
  ;end select
  CALL echo ("****** TEMP_RPT RECORD ******" )
  CALL echorecord (temp_rpt )
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->status_data.subeventstatus[1 ].operationstatus = "S"
 SET reply->status_data.subeventstatus[1 ].targetobjectvalue = "RX_RPT_WASTE_CHARGES SUCCEEDED"
#exit_script
 IF ((size (temp_rpt->qual ,5 ) = 0 ) )
  SELECT INTO  $OUTDEV
   "There is no data to output. Consider changing the prompt selections."
   FROM (dummyt )
   WITH nocounter ,format ,separator = " " ,maxcol = 5000 ,append ,formfeed = none
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   status = nowaste ,
   patient_name = substring (1 ,100 ,temp_rpt->qual[d.seq ].name_full_formatted ) ,
   dob = substring (1 ,20 ,format (cnvtdatetimeutc (datetimezone (temp_rpt->qual[d.seq ].birth_dt_tm
       ,temp_rpt->qual[d.seq ].birth_tz ) ,1 ) ,"@SHORTDATE" ) ) ,
   mrn = substring (1 ,200 ,temp_rpt->qual[d.seq ].mrn ) ,
   fin_nbr = substring (1 ,200 ,temp_rpt->qual[d.seq ].fin_nbr ) ,
   facility = substring (1 ,40 ,uar_get_code_display (temp_rpt->qual[d.seq ].facility_cd ) ) ,
   location = substring (1 ,40 ,uar_get_code_display (temp_rpt->qual[d.seq ].nurse_unit_cd ) ) ,
   order_sentence = substring (1 ,100 ,temp_rpt->qual[d.seq ].dept_misc_line ) ,
   order_id = substring (1 ,40 ,cnvtstring (temp_rpt->qual[d.seq ].order_id ) ) ,
   order_status = substring (1 ,40 ,uar_get_code_display (temp_rpt->qual[d.seq ].order_status_cd ) )
   ,dispense_event = substring (1 ,40 ,uar_get_code_display (temp_rpt->qual[d.seq ].
     disp_event_type_cd ) ) ,
   dispense_dt_tm = substring (1 ,60 ,temp_rpt->qual[d.seq ].dispense_dt_tm_str ) ,
   dispense_hx_id = substring (1 ,40 ,cnvtstring (temp_rpt->qual[d.seq ].dispense_hx_id ) ) ,
   label_description = substring (1 ,200 ,temp_rpt->qual[d.seq ].label_desc ) ,
   ndc = substring (1 ,255 ,temp_rpt->qual[d.seq ].drug_identifier ) ,
   cms_bill_units = substring (1 ,80 ,concat (trim (substring (1 ,40 ,getstring (temp_rpt->qual[d
        .seq ].cms_waste_billing_unit_amt ) ) ) ," " ,trim (substring (1 ,40 ,uar_get_code_display (
        temp_rpt->qual[d.seq ].cms_waste_billing_unit_uom_cd ) ) ) ) ) ,
   charge_qty = substring (1 ,40 ,getstring (temp_rpt->qual[d.seq ].product_qty ) ) ,
   device_waste_qty = substring (1 ,40 ,getstring (temp_rpt->qual[d.seq ].rxs_waste_qty ) ) ,
   nurse_waste = substring (1 ,40 ,temp_rpt->qual[d.seq ].rn_waste_amount ) ,
   avail_waste_qty = substring (1 ,40 ,getstring (temp_rpt->qual[d.seq ].available_waste_qty ) ) ,
   avail_waste_chrg_qty = substring (1 ,40 ,getstring (temp_rpt->qual[d.seq ].
     available_waste_charge_qty ) ) ,
   dispense_qty_uom = substring (1 ,40 ,uar_get_code_display (temp_rpt->qual[d.seq ].
     dispense_qty_uom_cd ) )
   FROM (dummyt d WITH seq = size (temp_rpt->qual ,5 ) )
   ORDER BY facility ,
    location
   WITH nocounter ,format ,separator = " " ,maxcol = 5000 ,append ,formfeed = none
  ;end select
 ENDIF
 CALL echo ("******************************" )
 CALL echo ("Checking for errors..." )
 CALL echo ("******************************" )
 SET errcode = error (errmsg ,0 )
 WHILE ((errcode != 0 )
 AND (errcnt < 6 ) )
  SET errcnt +=1
  IF ((errcnt > size (errorrec->err ,5 ) ) )
   SET stat = alterlist (errorrec->err ,(errcnt + 5 ) )
  ENDIF
  SET errorrec->err[errcnt ].err_code = errcode
  SET errorrec->err[errcnt ].err_msg = errmsg
  SET errorrec->err_cnt = errcnt
  SET errcode = error (errmsg ,0 )
 ENDWHILE
 SET stat = alterlist (errorrec->err ,errcnt )
 IF ((errcnt > 0 ) )
  SET nscriptstatus = cfailed_ccl_error
  CALL echorecord (errorrec )
 ENDIF
 IF ((nscriptstatus != csuccess ) )
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1 ].operationstatus = "F"
  CASE (nscriptstatus )
   OF cfailed_ccl_error :
    SET reply->status_data.subeventstatus[1 ].operationname = "CCL ERROR"
    SET reply->status_data.subeventstatus[1 ].targetobjectname = "RX_RPT_WASTE_CHARGES"
    SET reply->status_data.subeventstatus[1 ].targetobjectvalue = errorrec->err[1 ].err_msg
  ENDCASE
 ELSEIF ((nzeroresults > 0 ) )
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1 ].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1 ].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1 ].targetobjectname = "TABLE"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD errorrec
 SET delapsedtime = ((curtime3 - dstarttime ) / 100 )
 CALL echo (build2 ("RX_GET_WASTE_CHARGES - Elapsed time in seconds: " ,delapsedtime ) )
 SET reply->elapsed_time = delapsedtime
 CALL echo ("****** REPLY RECORD ******" )
 CALL echorecord (reply )
 CALL echo ("********** END RX_RPT_WASTE_CHARGES **********" )
 SET modify = nopredeclare
 CALL echo ("LastMod = 008" )
 CALL echo ("ModDate = 03/10/2020" )
END GO
 
