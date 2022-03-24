DROP PROGRAM cov_rx_rpt_drug_utilization :dba GO
CREATE PROGRAM cov_rx_rpt_drug_utilization :dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE" ,
  "Search by Drug or Therapeutic Class:" = "" ,
  "Enter the search string (* for all):" = "*" ,
  "Enter Facility (* for all):" = "" ,
  "Enter the START date range (mmddyyyy hhmm)  FROM :" = "SYSDATE" ,
  "(mmddyyyy hhmm)    TO :" = "SYSDATE" ,
  "Include Pyxis Orders:" = ""
  WITH outdev ,searchtype ,searchstring ,facility ,startdate ,stopdate ,pyxis
 SUBROUTINE  (formattolength (drugname =vc ,length =i4 ) =vc )
  SET return_string = drugname
  IF ((size (drugname ,1 ) > length ) )
   SET return_string = concat (substring (1 ,(length - 3 ) ,drugname ) ,"..." )
  ENDIF
  RETURN (return_string )
 END ;Subroutine
 DECLARE start_dt = q8
 DECLARE nstart_tm = i2 WITH protect ,noconstant (0 )
 DECLARE stop_dt = q8
 DECLARE nstop_tm = i2 WITH protect ,noconstant (0 )
 DECLARE nhit_report = i2 WITH protect ,noconstant (0 )
 DECLARE ssearch_string = vc WITH protect ,noconstant (" " )
 DECLARE medcnt = i4 WITH protect ,noconstant (0 )
 DECLARE itemcnt = i4 WITH protect ,noconstant (0 )
 DECLARE nindex = i4 WITH protect ,noconstant (0 )
 DECLARE nactual_size = i4 WITH protect ,noconstant (0 )
 DECLARE nexpand_size = i2 WITH protect ,constant (50 )
 DECLARE nexpand_total = i4 WITH protect ,noconstant (0 )
 DECLARE nexpand_start = i4 WITH protect ,noconstant (0 )
 DECLARE nexpand_stop = i4 WITH protect ,noconstant (0 )
 DECLARE nexpand = i4 WITH protect ,noconstant (0 )
 DECLARE nfacilitycounter = i2 WITH protect ,noconstant (0 )
 DECLARE med_cnt = i4 WITH protect ,noconstant (0 )
 DECLARE ord_cnt = i4 WITH protect ,noconstant (0 )
 DECLARE new_model_check = i2 WITH protect ,noconstant (0 )
 DECLARE total_dispenses = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_cost = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_charges = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_orders = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_dispenses_ther = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_dispenses_ther_facility = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_cost_ther = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_charges_ther = f8 WITH protect ,noconstant (0.0 )
 DECLARE total_orders_ther = f8 WITH protect ,noconstant (0.0 )
 DECLARE dlastprotocolorderid = f8 WITH protect ,noconstant (0.0 )
 DECLARE cmeddef = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,11001 ,"MED_DEF" ) )
 DECLARE citemgroup = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,11001 ,"ITEM_GROUP" ) )
 DECLARE clabel = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,11000 ,"DESC" ) )
 DECLARE cgeneric = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,11000 ,"GENERIC_NAME" ) )
 DECLARE ccatalogcd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,6000 ,"PHARMACY" ) )
 DECLARE activity_type = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,106 ,"PHARMACY" ) )
 DECLARE csystem = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4062 ,"SYSTEM" ) )
 DECLARE csyspkgtyp = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4062 ,"SYSPKGTYP" ) )
 DECLARE cinpatient = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4500 ,"INPATIENT" ) )
 DECLARE cformat = c50 WITH protect ,constant (fillstring (50 ,"#" ) )
 DECLARE ctempstock = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4032 ,"TEMPSTOCK" ) )
 DECLARE nprotocolorder = i2 WITH protect ,constant (7 )
 DECLARE cwaste_charge = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4032 ,"WASTECHARGE"
   ) )
 DECLARE cwaste_credit = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,4032 ,"WASTECREDIT"
   ) )
 DECLARE ccompound_parent_flag = i2 WITH protect ,constant (4 )
 DECLARE ccompound_child_flag = i2 WITH protect ,constant (5 )
 DECLARE swastedispensehxidcolname = vc WITH protect ,noconstant ("" )
 IF ((checkdic ("DISPENSE_HX.WASTE_DISPENSE_HX_ID" ,"A" ,0 ) > 0 ) )
  SET swastedispensehxidcolname = "dh.waste_dispense_hx_id"
 ELSE
  SET swastedispensehxidcolname = "0"
 ENDIF
 SET start_dt = cnvtdate (trim (substring (1 ,8 , $STARTDATE ) ) )
 SET nstart_tm = cnvtint (trim (substring (10 ,4 , $STARTDATE ) ) )
 SET stop_dt = cnvtdate (trim (substring (1 ,8 , $STOPDATE ) ) )
 SET nstop_tm = cnvtint (trim (substring (10 ,4 , $STOPDATE ) ) )
 IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "DRUG" ) )
  SET ssearch_string = trim ( $SEARCHSTRING ,4 )
 ELSE
  SET ssearch_string = trim ( $SEARCHSTRING )
 ENDIF
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
 IF (NOT (validate (reply ,0 ) ) )
  ;CALL echo ("Defining record structure" )
  RECORD reply (
    1 status_data
      2 status = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET dispenses_table[1000 ] = 0.0
 SET facility_table[1000 ] = 0.0
 SET errcode = 1
 SET errmsg = fillstring (132 ," " )
 SET errcnt = 0
 SET count1 = 0
 SET error = script_failure
 SET firsttime = 1
 SET did_break = 0
 SET qualified = 0
 SET med_rec = fillstring (30 ," " )
 SET fin_nbr = fillstring (30 ," " )
 SET i = 0
 SET first_real = 1
 SET total_thers = 0
 EXECUTE rx_get_facs_for_prsnl_rr_incl WITH replace ("REQUEST" ,"PRSNL_FACS_REQ" ) ,
 replace ("REPLY" ,"PRSNL_FACS_REPLY" )
 SET stat = alterlist (prsnl_facs_req->qual ,1 )
 ;CALL echo (build ("Reqinfo->updt_id --" ,reqinfo->updt_id ) )
 ;CALL echo (build ("curuser --" ,curuser ) )
 SET prsnl_facs_req->qual[1 ].username = trim (curuser )
 SET prsnl_facs_req->qual[1 ].person_id = reqinfo->updt_id
 EXECUTE rx_get_facs_for_prsnl WITH replace ("REQUEST" ,"PRSNL_FACS_REQ" ) ,
 replace ("REPLY" ,"PRSNL_FACS_REPLY" )
 ;CALL echo (build ("Size of facility list in prg--" ,size (prsnl_facs_reply->qual[1 ].facility_list ,5 ) ) )
 FREE RECORD facility_list
 RECORD facility_list (
   1 qual [* ]
     2 facility_cd = f8
 )
 SET stat = alterlist (facility_list->qual ,value (size (prsnl_facs_reply->qual[1 ].facility_list ,5
    ) ) )
 FOR (x = 1 TO size (prsnl_facs_reply->qual[1 ].facility_list ,5 ) )
  ;CALL echo (build ("Checking facility --" ,
  ;trim (format (prsnl_facs_reply->qual[1 ].facility_list[x].facility_cd ,cformat ) ,3 ) ) )
  ;CALL echo (build ("against --" , $FACILITY ) )
  IF ((trim (format (prsnl_facs_reply->qual[1 ].facility_list[x ].facility_cd ,cformat ) ,3 ) =
   $FACILITY ) )
   SET nfacilitycounter +=1
   SET facility_list->qual[nfacilitycounter ].facility_cd = prsnl_facs_reply->qual[1 ].facility_list[
   x ].facility_cd
  ENDIF
 ENDFOR
 SET stat = alterlist (facility_list->qual ,nfacilitycounter )
 ;CALL echo (build ("Facility list size --" ,value (size (facility_list->qual ,5 ) ) ) )
 IF ((size (facility_list->qual ,5 ) = 0 ) )
  ;CALL echo ("*** User does not have access to selected facility ***" )
  GO TO exit_script
 ENDIF
 RECORD errors (
   1 err_cnt = i4
   1 err [* ]
     2 err_code = i4
     2 err_msg = vc
 )
 RECORD internal (
   1 select_desc = c30
   1 begin_dt_tm = dq8
   1 end_dt_tm = dq8
   1 output_device_s = c30
   1 orderid = f8
   1 personid = f8
   1 encntrid = f8
   1 alt_sel_cat_id = f8
   1 item_id = f8
 )
 SET internal->begin_dt_tm = cnvtdatetime (start_dt ,nstart_tm )
 SET internal->end_dt_tm = cnvtdatetime (stop_dt ,nstop_tm )
 SELECT INTO "nl:"
  dmp.pref_nbr
  FROM (dm_prefs dmp )
  WHERE (dmp.application_nbr = 300000 )
  AND (dmp.person_id = 0 )
  AND (dmp.pref_domain = "PHARMNET-INPATIENT" )
  AND (dmp.pref_section = "FRMLRYMGMT" )
  AND (dmp.pref_name = "NEW MODEL" )
  DETAIL
   IF ((dmp.pref_nbr = 1 ) ) new_model_check = 1
   ENDIF
  WITH nocounter
 ;end select
 RECORD orderrec (
   1 qual [* ]
     2 item_id = f8
     2 identifier_id = f8
     2 synonym_id = f8
     2 class_description = c35
     2 generic_name = c100
   1 orderlist [* ]
     2 sort_generic_name = vc
     2 sort_label_desc = c35
     2 class_total_dispensed = f8
     2 orderid = f8
     2 cost = f8
     2 price = f8
     2 deptmiscline = c255
     2 name = c30
     2 med_rec = c30
     2 fin_nbr = c30
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 encntr_id = f8
     2 loc_s = c30
     2 loc_room_s = c10
     2 loc_bed_s = c10
     2 facility = c30
     2 order_status = f8
     2 all_unverified_ind = i2
     2 qualified = c1
     2 generic_name = vc
     2 ingredient [* ]
       3 generic_name = c100
       3 cost = f8
       3 price = f8
       3 dispenses = f8
       3 ingredient_type_flag = i2
       3 compound_parent = c50
       3 compound_ingred_add = i2
       3 item_id = f8
       3 class_description = c35
     2 skip_dup_dot_order_ind = i2
 )
 SET ccost = 2004.00
 SET ccomponentcost = 2005.00
 SET cdispensefromloc = 2006.00
 SET cdispensecategory = 2007.00
 SET ccomponentdispensecategory = 2008.00
 SET cfreq = 2011.00
 SET ccomponentfreq = 2012.00
 SET civfreq = 2013.00
 SET cdrugform = 2014.00
 SET cdispenseqty = 2015.00
 SET crefillqty = 2016.00
 SET cdaw = 2017.00
 SET csamplesgiven = 2018.00
 SET csampleqty = 2019.00
 SET cnextdispensedttm = 2024.00
 SET cpharmnotes = 2028.00
 SET cnotetype = 2029.00
 SET cparvalue = 2032.00
 SET cphysician = 2033.00
 SET cprinter = 2039.00
 SET crate = 2043.00
 SET ccomponentrate = 2044.00
 SET ccollroute = 2045.00
 SET croute = 2050.00
 SET ccomponentroute = 2046.00
 SET cstartbag = 2047.00
 SET ccomponentstartbag = 2048.00
 SET cstopbag = 2053.00
 SET cstoptype = 2055.00
 SET cstrengthdose = 2056.00
 SET cstrengthdoseunit = 2057.00
 SET cvolumedose = 2058.00
 SET cvolumedoseunit = 2059.00
 SET ctotalvolume = 2060.00
 SET cduration = 2061.00
 SET cdurationunit = 2062.00
 SET cfreetxtdose = 2063.00
 SET cinfuseoverunit = 2064.00
 SET cinfuseover = 118.00
 SET cstopdttm = 2073.00
 SET cdiluentid = 2065.00
 SET cdiluentvol = 2066.00
 SET cschprn = 2037.00
 SET ctreatmentperiod = 3524.00
 ;CALL echo ("Last Mod = 001" )
 ;CALL echo ("Mod Date = 12/01/2009" )
 ;CALL echo ("---END PHA_OE_FIELD_CONST.INC---" )
 SET count = 0
 SET prev_dseq = 1
 SET fac_dseq = 1
 SET crepl = 2068.00
 SET creplunit = 2069.00
 SET cordertype = 2070.00
 SET ctitrate = 2078.00
 ;CALL echo (build ("Search string ===" ,ssearch_string ) )
 IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "DRUG" ) )
  IF ((new_model_check = 0 ) )
   SELECT INTO "NL:"
    oii2.object_id
    FROM (object_identifier_index oii ),
     (object_identifier_index oii2 )
    PLAN (oii
     WHERE (oii.value_key = patstring (value (cnvtupper (trim (ssearch_string ,4 ) ) ) ) )
     AND (oii.identifier_type_cd IN (clabel ,
     cgeneric ) )
     AND (oii.object_type_cd IN (cmeddef ,
     citemgroup ) )
     AND (oii.generic_object = 0 ) )
     JOIN (oii2
     WHERE (oii2.object_id = oii.object_id )
     AND ((oii2.identifier_type_cd + 0 ) = clabel )
     AND (oii2.primary_ind = 1 )
     AND ((oii2.generic_object + 0 ) = 0 )
     AND ((oii2.object_type_cd + 0 ) IN (cmeddef ,
     citemgroup ) ) )
    ORDER BY oii2.object_id
    HEAD REPORT
     medcnt = 0
    DETAIL
     medcnt +=1 ,
     IF ((medcnt > size (orderrec->qual ,5 ) ) ) stat = alterlist (orderrec->qual ,(medcnt + 10 ) )
     ENDIF
     ,orderrec->qual[medcnt ].item_id = oii2.object_id ,
     orderrec->qual[medcnt ].identifier_id = oii2.identifier_id ,
     orderrec->qual[medcnt ].generic_name = oii2.value 
     ;CALL echo (build ("Gen name --" ,orderrec->qual[medcnt ].generic_name ) ) ,
     ;CALL echo (build ("item id ---" ,orderrec->qual[medcnt ].item_id ) )
    WITH nocounter
   ;end select
  ELSE
   SELECT DISTINCT INTO "NL:"
    mi2.item_id
    FROM (med_identifier mi ),
     (med_identifier mi2 )
    PLAN (mi
     WHERE (mi.value_key = patstring (value (cnvtupper (trim (ssearch_string ,4 ) ) ) ) )
     AND (mi.med_identifier_type_cd IN (cgeneric ,
     clabel ) )
     AND (mi.flex_type_cd = csystem )
     AND (mi.pharmacy_type_cd = cinpatient )
     AND (mi.med_product_id = 0 ) )
     JOIN (mi2
     WHERE (mi2.item_id = mi.item_id )
     AND (mi2.med_identifier_type_cd = clabel )
     AND (mi2.primary_ind = 1 )
     AND (mi2.flex_type_cd = csystem )
     AND (mi2.pharmacy_type_cd = cinpatient )
     AND (mi2.med_product_id = 0 ) )
    HEAD REPORT
     medcnt = 0
    DETAIL
     medcnt +=1 ,
     IF ((medcnt > size (orderrec->qual ,5 ) ) ) stat = alterlist (orderrec->qual ,(medcnt + 10 ) )
     ENDIF
     ,orderrec->qual[medcnt ].item_id = mi2.item_id ,
     orderrec->qual[medcnt ].generic_name = mi2.value 
     ;CALL echo (build ("Gen name --" ,orderrec->qual[medcnt ].generic_name ) ) ,
     ;CALL echo (build ("item id ---" ,orderrec->qual[medcnt ].item_id ) )
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist (orderrec->qual ,medcnt )
 ELSEIF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "THERAPEUTIC CLASS" ) )
  RECORD ther (
    1 qual [* ]
      2 alt_sel_cat_id = f8
      2 long_description = c35
  )
  SELECT DISTINCT INTO "NL:"
   FROM (alt_sel_cat a )
   WHERE (a.long_description_key_cap = patstring (value (cnvtupper (trim (ssearch_string ) ) ) ) )
   ORDER BY a.long_description
   DETAIL
    IF ((first_real = 1 )
    AND (a.alt_sel_category_id > 0 ) ) first_real = 0 ,internal->alt_sel_cat_id = a
     .alt_sel_category_id
    ENDIF
    ,
    IF ((first_real = 0 )
    AND (count > 0 )
    AND (a.alt_sel_category_id != ther->qual[count ].alt_sel_cat_id ) ) total_thers = 2
    ENDIF
    ,count +=1 ,
    IF ((count > size (ther->qual ,5 ) ) ) stat = alterlist (ther->qual ,(count + 10 ) )
    ENDIF
    ,ther->qual[count ].alt_sel_cat_id = a.alt_sel_category_id ,
    ther->qual[count ].long_description = a.long_description
   WITH nocounter
  ;end select
  SET stat = alterlist (ther->qual ,count )
 ENDIF
 IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "THERAPEUTIC CLASS" )
 AND (internal->alt_sel_cat_id > 0 ) )
  SET nactual_size = size (ther->qual ,5 )
  SET nexpand_total = (nactual_size + (nexpand_size - mod (nactual_size ,nexpand_size ) ) )
  SET nexpand_start = 1
  SET nexpand_stop = 50
  SET stat = alterlist (ther->qual ,nexpand_total )
  FOR (x = (nactual_size + 1 ) TO nexpand_total )
   SET ther->qual[x ].alt_sel_cat_id = ther->qual[nactual_size ].alt_sel_cat_id
  ENDFOR
  SET tclass = 0.0
  SET rec_cnt = 0
  RECORD class (
    1 qual [* ]
      2 code = f8
      2 long_description = c35
  )
  SELECT INTO "NL:"
   a2_hit = decode (a2.seq ,1 ,0 ) ,
   a3_hit = decode (a3.seq ,1 ,0 ) ,
   a4_hit = decode (a4.seq ,1 ,0 ) ,
   a5_hit = decode (a5.seq ,1 ,0 )
   FROM (dummyt d WITH seq = value ((nexpand_total / nexpand_size ) ) ),
    (alt_sel_cat a1 ),
    (dummyt d1 ),
    (alt_sel_list a2 ),
    (alt_sel_cat a3 ),
    (dummyt d2 ),
    (alt_sel_list a4 ),
    (alt_sel_cat a5 )
   PLAN (d
    WHERE assign (nexpand_start ,evaluate (d.seq ,1 ,1 ,(nexpand_start + nexpand_size ) ) )
    AND assign (nexpand_stop ,(nexpand_start + (nexpand_size - 1 ) ) ) )
    JOIN (a1
    WHERE expand (nexpand ,nexpand_start ,nexpand_stop ,a1.alt_sel_category_id ,ther->qual[nexpand ].
     alt_sel_cat_id )
    AND ((a1.alt_sel_category_id + 0 ) > 0 ) )
    JOIN (d1 )
    JOIN (a2
    WHERE (a1.alt_sel_category_id = a2.alt_sel_category_id )
    AND (a2.list_type != 2 ) )
    JOIN (a3
    WHERE (a2.child_alt_sel_cat_id = a3.alt_sel_category_id ) )
    JOIN (d2 )
    JOIN (a4
    WHERE (a3.alt_sel_category_id = a4.alt_sel_category_id )
    AND ((a4.alt_sel_category_id + 0 ) > 0 ) )
    JOIN (a5
    WHERE (a4.child_alt_sel_cat_id = a5.alt_sel_category_id )
    AND ((a5.alt_sel_category_id + 0 ) > 0 ) )
   HEAD REPORT
    rec_cnt = 0
   HEAD a1.alt_sel_category_id
    nindex = locateval (x ,1 ,nactual_size ,a1.alt_sel_category_id ,ther->qual[x ].alt_sel_cat_id ) ,
    IF ((nindex > 0 ) ) rec_cnt +=1 ,
     IF ((rec_cnt > size (class->qual ,5 ) ) ) stat = alterlist (class->qual ,rec_cnt )
     ENDIF
     ,class->qual[rec_cnt ].code = a1.alt_sel_category_id ,class->qual[rec_cnt ].long_description =
     ther->qual[nindex ].long_description
    ENDIF
   HEAD a3.alt_sel_category_id
    IF ((a2_hit = 1 ) ) nindex = locateval (x ,1 ,nactual_size ,a3.alt_sel_category_id ,ther->qual[x
      ].alt_sel_cat_id ) ,
     IF ((nindex > 0 ) ) rec_cnt +=1 ,
      IF ((rec_cnt > size (class->qual ,5 ) ) ) stat = alterlist (class->qual ,rec_cnt )
      ENDIF
      ,class->qual[rec_cnt ].code = a3.alt_sel_category_id ,class->qual[rec_cnt ].long_description =
      ther->qual[nindex ].long_description
     ENDIF
    ENDIF
   DETAIL
    IF ((a4_hit = 1 ) ) nindex = locateval (x ,1 ,nactual_size ,a5.alt_sel_category_id ,ther->qual[x
      ].alt_sel_cat_id ) ,
     IF ((nindex > 0 ) ) rec_cnt +=1 ,
      IF ((rec_cnt > size (class->qual ,5 ) ) ) stat = alterlist (class->qual ,(rec_cnt + 10 ) )
      ENDIF
      ,class->qual[rec_cnt ].code = a5.alt_sel_category_id ,class->qual[rec_cnt ].long_description =
      ther->qual[nindex ].long_description
     ENDIF
    ENDIF
   WITH outerjoin = d1 ,outerjoin = d2, expand=1
  ;end select
  SET stat = alterlist (class->qual ,rec_cnt )
  SET rec_cnt = size (class->qual ,5 )
  SET nactual_size = size (class->qual ,5 )
  SET nexpand_total = (nactual_size + (nexpand_size - mod (nactual_size ,nexpand_size ) ) )
  SET nexpand_start = 1
  SET nexpand_stop = 50
  SET stat = alterlist (class->qual ,nexpand_total )
  FOR (x = (nactual_size + 1 ) TO nexpand_total )
   SET class->qual[x ].code = class->qual[nactual_size ].code
  ENDFOR
  IF ((new_model_check = 0 ) )
   ;CALL echo ("Old Model" )
   SELECT INTO "NL:"
    oci.synonym_id
    FROM (alt_sel_list a ),
     (order_catalog_item_r oci ),
     (object_identifier_index oii ),
     (dummyt d WITH seq = value ((nexpand_total / nexpand_size ) ) )
    PLAN (d
     WHERE assign (nexpand_start ,evaluate (d.seq ,1 ,1 ,(nexpand_start + nexpand_size ) ) )
     AND assign (nexpand_stop ,(nexpand_start + (nexpand_size - 1 ) ) ) )
     JOIN (a
     WHERE expand (nexpand ,nexpand_start ,nexpand_stop ,a.alt_sel_category_id ,class->qual[nexpand ]
      .code )
     AND ((a.alt_sel_category_id + 0 ) > 0 ) )
     JOIN (oci
     WHERE (a.synonym_id = oci.synonym_id )
     AND ((oci.catalog_cd + 0 ) > 0 )
     AND ((oci.synonym_id + 0 ) > 0 ) )
     JOIN (oii
     WHERE (oci.item_id = oii.object_id )
     AND ((oii.identifier_type_cd + 0 ) = clabel )
     AND ((oii.object_type_cd + 0 ) IN (cmeddef ,
     citemgroup ) )
     AND ((oii.generic_object + 0 ) = 0 )
     AND (oii.primary_ind = 1 ) )
    ORDER BY oci.synonym_id
    HEAD REPORT
     itemcnt = 0
    DETAIL
     IF ((oci.item_id > 0 ) ) itemcnt +=1 ,
      IF ((itemcnt > size (orderrec->qual ,5 ) ) ) stat = alterlist (orderrec->qual ,(itemcnt + 10 )
        )
      ENDIF
      ,orderrec->qual[itemcnt ].item_id = oci.item_id ,orderrec->qual[itemcnt ].synonym_id = oci
      .synonym_id ,nindex = locateval (x ,1 ,nactual_size ,a.alt_sel_category_id ,class->qual[x ].
       code ) ,orderrec->qual[itemcnt ].class_description = class->qual[nindex ].long_description ,
      orderrec->qual[itemcnt ].generic_name = oii.value
     ENDIF
    WITH nocounter ,outerjoin = d1 ,outerjoin = d2, expand = 1
   ;end select
  ELSE
   SELECT INTO "NL:"
    oci.synonym_id
    FROM (alt_sel_list a ),
     (order_catalog_item_r oci ),
     (med_identifier mi ),
     (dummyt d WITH seq = value ((nexpand_total / nexpand_size ) ) )
    PLAN (d
     WHERE assign (nexpand_start ,evaluate (d.seq ,1 ,1 ,(nexpand_start + nexpand_size ) ) )
     AND assign (nexpand_stop ,(nexpand_start + (nexpand_size - 1 ) ) ) )
     JOIN (a
     WHERE expand (nexpand ,nexpand_start ,nexpand_stop ,a.alt_sel_category_id ,class->qual[nexpand ]
      .code )
     AND ((a.alt_sel_category_id + 0 ) > 0 ) )
     JOIN (oci
     WHERE (a.synonym_id = oci.synonym_id )
     AND ((oci.catalog_cd + 0 ) > 0 )
     AND ((oci.synonym_id + 0 ) > 0 ) )
     JOIN (mi
     WHERE (mi.item_id = oci.item_id )
     AND (mi.med_identifier_type_cd = clabel )
     AND (mi.flex_type_cd = csystem )
     AND (mi.pharmacy_type_cd = cinpatient )
     AND (mi.med_product_id = 0 )
     AND (mi.primary_ind = 1 ) )
    ORDER BY oci.synonym_id
    HEAD REPORT
     itemcnt = 0
    DETAIL
     IF ((oci.item_id > 0 ) ) nindex = locateval (x ,1 ,nactual_size ,a.alt_sel_category_id ,class->
       qual[x ].code ) ,
      IF ((nindex > 0 ) ) itemcnt +=1 ,
       IF ((itemcnt > size (orderrec->qual ,5 ) ) ) stat = alterlist (orderrec->qual ,(itemcnt + 10
         ) )
       ENDIF
       ,orderrec->qual[itemcnt ].item_id = oci.item_id ,orderrec->qual[itemcnt ].synonym_id = oci
       .synonym_id ,orderrec->qual[itemcnt ].class_description = class->qual[nindex ].
       long_description ,orderrec->qual[itemcnt ].generic_name = mi.value
      ENDIF
     ENDIF
    WITH nocounter ,outerjoin = d1 ,outerjoin = d2, expand = 1
   ;end select
  ENDIF
  SET stat = alterlist (orderrec->qual ,itemcnt )
 ENDIF
 RECORD orderlist (
   1 data [* ]
     2 order_id = f8
     2 item_id = f8
     2 charge_qty = f8
     2 credit_qty = f8
     2 dispense_hx_id = f8
     2 cost = f8
     2 price = f8
 )
 SET idx = 0
 SET cntr = 0
 SET cntr = size (orderrec->qual ,5 )
 ;CALL echo (build ("cntr ---" ,cntr ) )
 SET nactual_size = size (orderrec->qual ,5 )
 SET nexpand_total = (nactual_size + (nexpand_size - mod (nactual_size ,nexpand_size ) ) )
 SET stat = alterlist (orderrec->qual ,nexpand_total )
 FOR (x = (nactual_size + 1 ) TO nexpand_total )
  SET orderrec->qual[x ].item_id = orderrec->qual[nactual_size ].item_id
 ENDFOR
 ;CALL echo (build ("Facility ==========" , $FACILITY ) )
 ;CALL echo (build ("start date ---" ,format (cnvtdatetime (internal->begin_dt_tm ) , "MM/dd/yy hh:mm;;d" ) ) )
 ;CALL echo (build ("end date ---" ,format (cnvtdatetime (internal->end_dt_tm ) ,"MM/dd/yy hh:mm;;d") ) )
 SELECT DISTINCT INTO "NL:"
  o.order_id ,
  dfacilityareacd =
  IF ((o.encntr_id > 0 ) ) eh.loc_facility_cd
  ELSE od.future_loc_facility_cd
  ENDIF
  FROM (dispense_hx dh ),
   (orders o ),
   (order_dispense od ),
   (encounter eh ),
   (prod_dispense_hx pdh ),
   (dispense_category dc )
  PLAN (dh
   WHERE (dh.updt_dt_tm <= cnvtdatetime (internal->end_dt_tm ) )
   AND (dh.updt_dt_tm >= cnvtdatetime (internal->begin_dt_tm ) )
   AND NOT ((dh.disp_event_type_cd IN (ctempstock ,
   cwaste_charge ,
   cwaste_credit ) ) )
   AND (parser (swastedispensehxidcolname ) IN (0 ,
   null ) ) )
   JOIN (pdh
   WHERE expand (nexpand ,1 ,nexpand_total ,pdh.item_id ,orderrec->qual[nexpand ].item_id )
   AND (pdh.dispense_hx_id = dh.dispense_hx_id ) )
   JOIN (o
   WHERE (o.order_id = dh.order_id )
   AND (o.catalog_type_cd = ccatalogcd )
   AND ((((o.orig_ord_as_flag + 0 ) = 0 ) ) OR ((cnvtupper ( $PYXIS ) = "YES" )
   AND ((o.orig_ord_as_flag + 0 ) = 4 ) ))
   AND ((o.template_order_flag + 0 ) != nprotocolorder ) )
   JOIN (od
   WHERE (od.order_id = o.order_id ) )
   JOIN (dc
   WHERE (dc.dispense_category_cd = od.dispense_category_cd )
   AND (((dc.charge_pt_sch_ind != 2 ) ) OR ((((dc.charge_pt_sch_ind = 2 )
   AND (dh.charge_ind = 1 ) ) OR ((dc.charge_pt_prn_ind = 2 )
   AND (dh.charge_ind = 1 )
   AND (o.prn_ind = 1 ) )) )) )
   JOIN (eh
   WHERE (eh.encntr_id = o.encntr_id ) )
  ORDER BY o.protocol_order_id ,
   dh.order_id ,
   pdh.item_id ,
   pdh.dispense_hx_id
  HEAD REPORT
   idx = 0 ,
   ningred_cnt = 0 ,
   ordcnt = 0
  HEAD dh.order_id
   ;CALL echo (build ("Order id --" ,o.order_id ) ) ,
   ;CALL echo (build ("dFacilityAreaCD --" ,dfacilityareacd ) ) ,
   IF ((locateval (x ,1 ,size (facility_list->qual ,5 ) ,dfacilityareacd ,facility_list->qual[x ].
    facility_cd ) > 0 ) )
    ;CALL echo ("Storing order id" ) ,
    IF ((dfacilityareacd > 0 ) ) facility_area = uar_get_code_display (dfacilityareacd )
    ENDIF
    ,ordcnt +=1 ,stat = alterlist (orderrec->orderlist ,ordcnt ) ,stat = alterlist (orderrec->
     orderlist[ordcnt ].ingredient ,0 ) ,orderrec->orderlist[ordcnt ].orderid = o.order_id ,orderrec
    ->orderlist[ordcnt ].facility = substring (1 ,30 ,facility_area ) ,ningred_cnt = 0 ,
    IF ((o.protocol_order_id > 0 )
    AND (dlastprotocolorderid = o.protocol_order_id ) ) orderrec->orderlist[ordcnt ].
     skip_dup_dot_order_ind = 1
    ENDIF
    ,dlastprotocolorderid = o.protocol_order_id
   ENDIF
  HEAD pdh.item_id
   IF ((locateval (x ,1 ,size (facility_list->qual ,5 ) ,dfacilityareacd ,facility_list->qual[x ].
    facility_cd ) > 0 ) )
    ;CALL echo (build ("pdh item id ---" ,pdh.item_id ) ) ,
    IF ((dh.order_id > 0 ) ) ningred_cnt +=1 ,stat = alterlist (orderrec->orderlist[ordcnt ].
      ingredient ,ningred_cnt ) ,
     IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "DRUG" ) ) orderrec->orderlist[ordcnt ].ingredient[
      ningred_cnt ].class_description = fillstring (35 ," " )
     ENDIF
     ,nindex = locateval (x ,1 ,nactual_size ,pdh.item_id ,orderrec->qual[x ].item_id ) ,
     IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "THERAPEUTIC CLASS" ) ) orderrec->orderlist[ordcnt ].
      ingredient[ningred_cnt ].class_description = orderrec->qual[nindex ].class_description 
      ;CALL echo (build ("Class desc --" ,orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].      class_description ) )
     ENDIF
     ,orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].generic_name = orderrec->qual[nindex ].
     generic_name ,orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].item_id = orderrec->qual[
     nindex ].item_id 
     ;CALL echo (build ("Label desc ===" ,orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].generic_name ) )
    ENDIF
   ENDIF
  HEAD pdh.dispense_hx_id
   IF ((locateval (x ,1 ,size (facility_list->qual ,5 ) ,dfacilityareacd ,facility_list->qual[x ].
    facility_cd ) > 0 ) )
    ;CALL echo (build ("dispense_hx id --" ,pdh.dispense_hx_id ) ) ,
    IF ((dh.order_id > 0 ) )
     IF ((pdh.charge_qty > 0 ) )
      ;CALL echo (build ("doses ==" ,dh.doses ) ) ,
      orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].dispenses +=dh.doses ,
      orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].cost
      +=(pdh.cost * pdh.charge_qty ) ,orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].price +=
      pdh.price
     ELSE orderrec->orderlist[ordcnt ].ingredient[ningred_cnt ].dispenses -=dh.doses ,orderrec->
      orderlist[ordcnt ].ingredient[ningred_cnt ].cost -=(pdh.cost * pdh.credit_qty ) ,orderrec->
      orderlist[ordcnt ].ingredient[ningred_cnt ].price -=pdh.price
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter ,expand = 1
 ;end select
 IF ((curqual > 0 ) )
  DECLARE icnt = i4 WITH protect ,noconstant (0 )
  SET nactual_size = size (orderrec->orderlist ,5 )
  SELECT
   dh.doses ,
   pdh.cost ,
   pdh.price ,
   pdh.charge_qty
   FROM (order_ingredient oi ),
    (dispense_hx dh ),
    (prod_dispense_hx pdh ),
    (med_identifier mi )
   PLAN (dh
    WHERE expand (nexpand ,1 ,nactual_size ,dh.order_id ,orderrec->orderlist[nexpand ].orderid ) )
    JOIN (oi
    WHERE (oi.order_id = dh.order_id )
    AND (((oi.ingredient_type_flag = ccompound_parent_flag ) ) OR ((oi.ingredient_type_flag =
    ccompound_child_flag ) ))
    AND (dh.order_id = oi.order_id )
    AND (dh.action_sequence = oi.action_sequence ) )
    JOIN (pdh
    WHERE (dh.dispense_hx_id = pdh.dispense_hx_id )
    AND (pdh.ingred_sequence = oi.comp_sequence ) )
    JOIN (mi
    WHERE (pdh.item_id = mi.item_id )
    AND (mi.med_identifier_type_cd = clabel )
    AND (mi.med_product_id = 0 ) )
   DETAIL
    nindex = locateval (icnt ,1 ,size (orderrec->orderlist ,5 ) ,dh.order_id ,orderrec->orderlist[
     icnt ].orderid ) ,
    IF ((nindex > 0 ) ) norderingredlistsize = size (orderrec->orderlist[nindex ].ingredient ,5 ) ,
     ningred = locateval (icnt ,1 ,norderingredlistsize ,pdh.item_id ,orderrec->orderlist[nindex ].
      ingredient[icnt ].item_id ) ,
     IF ((ningred > 0 ) ) orderrec->orderlist[nindex ].ingredient[ningred ].ingredient_type_flag = oi
      .ingredient_type_flag
     ELSEIF ((ningred = 0 )
     AND (cnvtupper (trim ( $SEARCHTYPE ) ) = "DRUG" ) ) norderingredlistsize +=1 ,stat = alterlist (
       orderrec->orderlist[nindex ].ingredient ,norderingredlistsize ) ,orderrec->orderlist[nindex ].
      ingredient[norderingredlistsize ].generic_name = substring (1 ,50 ,mi.value ) ,orderrec->
      orderlist[nindex ].ingredient[norderingredlistsize ].item_id = pdh.item_id ,orderrec->
      orderlist[nindex ].ingredient[norderingredlistsize ].ingredient_type_flag = oi
      .ingredient_type_flag ,orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].
      class_description = fillstring (35 ," " ) ,orderrec->orderlist[nindex ].ingredient[
      norderingredlistsize ].compound_ingred_add = 1
     ENDIF
     ,
     IF ((orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].item_id = pdh.item_id )
     AND (orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].compound_ingred_add = 1 ) )
      IF ((pdh.charge_qty > 0 ) ) orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].
       dispenses +=dh.doses ,orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].cost +=(
       pdh.cost * pdh.charge_qty ) ,orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].
       price +=pdh.price
      ELSE orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].dispenses -=dh.doses ,
       orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].cost -=(pdh.cost * pdh
       .credit_qty ) ,orderrec->orderlist[nindex ].ingredient[norderingredlistsize ].price -=pdh
       .price
      ENDIF
     ELSEIF ((orderrec->orderlist[nindex ].ingredient[ningred ].compound_ingred_add = 1 ) )
      IF ((pdh.charge_qty > 0 ) ) orderrec->orderlist[nindex ].ingredient[ningred ].dispenses +=dh
       .doses ,orderrec->orderlist[nindex ].ingredient[ningred ].cost +=(pdh.cost * pdh.charge_qty )
      ,orderrec->orderlist[nindex ].ingredient[ningred ].price +=pdh.price
      ELSE orderrec->orderlist[nindex ].ingredient[ningred ].dispenses -=dh.doses ,orderrec->
       orderlist[nindex ].ingredient[ningred ].cost -=(pdh.cost * pdh.credit_qty ) ,orderrec->
       orderlist[nindex ].ingredient[ningred ].price -=pdh.price
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter, expand =1
  ;end select
 ENDIF
 SET printfile = "cer_print:rxadi.dat"
 DECLARE nmax_ingred = i2 WITH protect ,noconstant (0 )
 ;CALL echo ("*** Finding max number of ingredients ***" )
 SELECT INTO "NL:"
  order_id = orderrec->orderlist[d.seq ].orderid
  FROM (dummyt d WITH seq = value (size (orderrec->orderlist ,5 ) ) )
  HEAD order_id
   ningred_cnt = 0 ,
   ;CALL echo (build ("# of ingredients ---" ,size (orderrec->orderlist[d.seq ].ingredient ,5 ) ) ) ,
   IF ((size (orderrec->orderlist[d.seq ].ingredient ,5 ) > nmax_ingred ) ) nmax_ingred = size (
     orderrec->orderlist[d.seq ].ingredient ,5 )
   ENDIF
  WITH nocounter
 ;end select
 ;CALL echo (build ("Max ingredients ---" ,nmax_ingred ) )
 IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "THERAPEUTIC CLASS" ) )
  SELECT INTO "NL:"
   gen_name = orderrec->orderlist[d.seq ].ingredient[d2.seq ].generic_name ,
   class_description = orderrec->orderlist[d.seq ].ingredient[d2.seq ].class_description ,
   order_id = orderrec->orderlist[d.seq ].orderid ,
   facility_area = orderrec->orderlist[d.seq ].facility ,
   encntr = orderrec->orderlist[d.seq ].encntr_id ,
   ingredient_type_flag = orderrec->orderlist[d.seq ].ingredient[d2.seq ].ingredient_type_flag
   FROM (dummyt d WITH seq = value (size (orderrec->orderlist ,5 ) ) ),
    (dummyt d2 WITH seq = nmax_ingred )
   PLAN (d
    WHERE (orderrec->orderlist[d.seq ].qualified != "x" ) )
    JOIN (d2
    WHERE (d2.seq <= size (orderrec->orderlist[d.seq ].ingredient ,5 ) )
    AND (orderrec->orderlist[d.seq ].ingredient[d2.seq ].ingredient_type_flag !=
    ccompound_child_flag ) )
   ORDER BY facility_area ,
    class_description ,
    gen_name
   HEAD REPORT
    total_dispenses = 0
   HEAD facility_area
    ;CALL echo (build ("Head facility area ---" ,facility_area ) ) ,
    x = 1
   HEAD class_description
    ;CALL echo (build ("Head class desc ---" ,class_description ) ) ,
    x = 1
   HEAD gen_name
    ;CALL echo (build ("Head gen_name ---" ,gen_name ) ) ,
    x = 1
   DETAIL
    ;CALL echo ("Detail" ) ,
    total_dispenses +=orderrec->orderlist[d.seq ].ingredient[d2.seq ].dispenses 
    ;CALL echo (build ("Dispenses for dispense--" ,total_dispenses ) )
   FOOT  gen_name
    total_dispenses_ther +=total_dispenses ,
    ;CALL echo (build ("Dispenses for ingred --" ,total_dispenses_ther ) ) ,
    total_dispenses = 0
   FOOT  class_description
    IF ((cnvtupper (trim ( $SEARCHTYPE ) ) != "DRUG" ) ) dispenses_table[prev_dseq ] =
     total_dispenses_ther ,facility_table[fac_dseq ] +=total_dispenses_ther
    ENDIF
    ,
    ;CALL echo (build ("Dispenses for class ---" ,dispenses_table[prev_dseq ] ) ) ,
    prev_dseq +=1 ,
    total_dispenses_ther = 0
   FOOT  facility_area
    ;CALL echo (build ("Total Dispenses for facility --" ,facility_table[fac_dseq ] ) ) ,
    fac_dseq +=1
   WITH nocounter
  ;end select
 ENDIF
 SET total_dispenses = 0
 SET total_cost = 0
 SET total_charges = 0
 SET total_orders = 0
 SET total_dispenses_ther = 0
 SET total_cost_ther = 0
 SET total_charges_ther = 0
 SET total_orders_ther = 0
 SET total_dispenses_ther_facility = 0
 SET prev_dseq = 1
 SET fac_dseq = 1
 SET norderlistsize = size (orderrec->orderlist ,5 )
 FOR (nordercnt = 1 TO norderlistsize )
  SET ningredsize = size (orderrec->orderlist[nordercnt ].ingredient ,5 )
  SET nindex = locateval (x ,1 ,ningredsize ,4 ,orderrec->orderlist[nordercnt ].ingredient[x ].
   ingredient_type_flag )
  IF ((nindex > 0 ) )
   FOR (ningredcnt = 1 TO ningredsize )
    IF ((orderrec->orderlist[nordercnt ].ingredient[ningredcnt ].ingredient_type_flag =
    ccompound_child_flag ) )
     SET orderrec->orderlist[nordercnt ].ingredient[ningredcnt ].compound_parent = trim (orderrec->
      orderlist[nordercnt ].ingredient[nindex ].generic_name )
     SET orderrec->orderlist[nordercnt ].ingredient[ningredcnt ].generic_name = concat (trim (
       orderrec->orderlist[nordercnt ].ingredient[nindex ].generic_name ) ," " ,trim (orderrec->
       orderlist[nordercnt ].ingredient[ningredcnt ].generic_name ) )
    ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 ;CALL echo ("Entering output join" )
 SELECT
  IF ((cnvtupper (trim ( $OUTDEV ) ) != "MINE" ) )
   WITH dio = postscript ,maxrow = 55 ,maxcol = 110 ,counter ,nullreport ,format ,format = variable
  ELSE
  ENDIF
  INTO  $OUTDEV
  gen_name = orderrec->orderlist[d.seq ].ingredient[d2.seq ].generic_name ,
  class_description = orderrec->orderlist[d.seq ].ingredient[d2.seq ].class_description ,
  order_id = orderrec->orderlist[d.seq ].orderid ,
  facility_area = orderrec->orderlist[d.seq ].facility ,
  dispenses = orderrec->orderlist[d.seq ].ingredient[d2.seq ].dispenses ,
  cost = orderrec->orderlist[d.seq ].ingredient[d2.seq ].cost ,
  price = orderrec->orderlist[d.seq ].ingredient[d2.seq ].price ,
  compound_parent = orderrec->orderlist[d.seq ].ingredient[d2.seq ].compound_parent ,
  ingredient_type_flag = orderrec->orderlist[d.seq ].ingredient[d2.seq ].ingredient_type_flag
  FROM (dummyt d WITH seq = value (size (orderrec->orderlist ,5 ) ) ),
   (dummyt d2 WITH seq = nmax_ingred )
  PLAN (d
   WHERE (orderrec->orderlist[d.seq ].qualified != "x" ) )
   JOIN (d2
   WHERE (d2.seq <= size (orderrec->orderlist[d.seq ].ingredient ,5 ) )
   AND (((orderrec->orderlist[d.seq ].ingredient[d2.seq ].ingredient_type_flag !=
   ccompound_child_flag )
   AND (cnvtupper (trim ( $SEARCHTYPE ) ) = "THERAPEUTIC CLASS" ) ) OR ((cnvtupper (trim (
      $SEARCHTYPE ) ) = "DRUG" ) )) )
  ORDER BY facility_area ,
   class_description ,
   gen_name
  HEAD REPORT
   idx = 0 ,
   disp_percent = 0.0 ,
   dept_stat = fillstring (16 ," " ) ,
   rpt_line = fillstring (94 ,"=" ) ,
   label_name = fillstring (25 ," " ) ,
   do_it = 1 ,
   ord_mnem = fillstring (25 ," " ) ,
   name_save = fillstring (30 ," " ) ,
   pagebreak = 0 ,
   pagenum = 0 ,
   report_nbr = "RX_RPT_DRUG_UTILIZATION" ,
   rpt_title = "DRUG UTILIZATION REPORT" ,
   cdisplay = fillstring (18 ," " ) ,
   demoprint = 0 ,
   nhit_report = 0
  HEAD PAGE
   IF ((cnvtupper (trim ( $OUTDEV ) ) != "MINE" ) ) col 0 ,"{lpi/6}{cpi/12}" ,row + 1
   ENDIF
   ,demoprint = 0 ,
   IF ((firsttime = 0 )
   AND (did_break != 1 ) ) pagenum +=1 ,col 00 ,report_nbr ,
    CALL center (rpt_title ,0 ,90 ) ,col 86 ,"Page: " ,pagenum "###;r" ,row + 1 ,sutcdatetime =
    utcdatetime (cnvtdatetime (curdate ,curtime ) ,0 ,0 ,"MM/DD/YYYY HH:mm" ) ,col 60 ,"Run Date: " ,
    sutcdatetime ,row + 1 ,
    IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "THERAPEUTIC CLASS" )
    AND (internal->alt_sel_cat_id > 0 ) ) col 00 ,"Therapuetic Class: " ,col 19 , $SEARCHSTRING
    ELSE
     IF ((trim ( $SEARCHSTRING ) != "*" ) ) col 00 ,"Formulary Item...: " ,col 19 , $SEARCHSTRING
     ELSE col 00 ,"Formulary Item...: ALL"
     ENDIF
    ENDIF
    ,row + 1 ,col 00 ,"Facility: " ,facility_area ,row + 1 ,col 00 ,"Date Range.......: " ,
    IF ((internal->begin_dt_tm > 0 ) ) sutcdatetime = concat (format (internal->begin_dt_tm ,
       "MM/DD/YY HH:MM;;D" ) ," " ,utcshorttz (0 ) ) ,col 19 ,sutcdatetime
    ENDIF
    ,
    IF ((internal->end_dt_tm > 0 ) ) sutcdatetime = concat (format (internal->end_dt_tm ,
       "MM/DD/YY HH:MM;;D" ) ," " ,utcshorttz (0 ) ) ,col 43 ," TO " ,sutcdatetime
    ENDIF
    ,row + 2 ,col 5 ,"  Label Description " ,col 36 ,"# of" ,col 45 ,"  Doses" ,col 59 ,"Total" ,col
    69 ,"Total" ,
    IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "THERAPEUTIC CLASS" ) ) col 79 ,"% of" ,col 86 ,
     "% of"
    ENDIF
    ,row + 1 ,col 36 ,"Orders" ,col 45 ,"Dispensed" ,col 59 ,"Cost" ,col 69 ,"Charge" ,
    IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "THERAPEUTIC CLASS" ) ) col 79 ,"Ther" ,col 86 ,
     "Facility"
    ENDIF
    ,row + 1 ,col 00 ,rpt_line ,row + 2 ,did_break = 0 ,firsttime = 0 ,pagebreak = 0
   ENDIF
  HEAD facility_area
   nhit_report = 1 ,pagenum +=1 ,col 00 ,report_nbr ,
   CALL center (rpt_title ,0 ,90 ) ,col 86 ,"Page: " ,pagenum "###;r" ,row + 1 ,sutcdatetime =
   utcdatetime (cnvtdatetime (curdate ,curtime ) ,0 ,0 ,"MM/DD/YYYY HH:mm" ) ,col 60 ,"Run Date: " ,
   sutcdatetime ,row + 1 ,
   IF ((internal->alt_sel_cat_id > 0 ) ) col 00 ,"Therapuetic Class: " ,col 19 , $SEARCHSTRING
   ELSE
    IF ((trim ( $SEARCHSTRING ) != "*" ) ) col 00 ,"Formulary Item...: " ,col 19 , $SEARCHSTRING
    ELSE col 00 ,"Formulary Item...: ALL"
    ENDIF
   ENDIF
   ,row + 1 ,col 00 ,"Facility: " ,facility_area ,row + 1 ,col 00 ,"Date Range.......: " ,
   IF ((internal->begin_dt_tm > 0 ) ) sutcdatetime = concat (format (internal->begin_dt_tm ,
      "MM/DD/YY HH:MM;;D" ) ," " ,utcshorttz (0 ) ) ,col 19 ,sutcdatetime
   ENDIF
   ,
   IF ((internal->end_dt_tm > 0 ) ) sutcdatetime = concat (format (internal->end_dt_tm ,
      "MM/DD/YY HH:MM;;D" ) ," " ,utcshorttz (0 ) ) ,col 43 ," TO " ,sutcdatetime
   ENDIF
   ,row + 2 ,col 5 ,"  Label Description " ,col 33 ,"# of" ,col 41 ,"  Doses" ,col 58 ,"Total" ,col
   73 ,"Total" ,
   IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "THERAPEUTIC CLASS" ) ) col 80 ,"% of" ,col 86 ,"% of"
   ENDIF
   ,row + 1 ,col 33 ,"Orders" ,col 41 ,"Dispensed" ,col 58 ,"Cost" ,col 73 ,"Charge" ,
   IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "THERAPEUTIC CLASS" ) ) col 80 ,"Ther" ,col 86 ,
    "Facility"
   ENDIF
   ,row + 1 ,col 00 ,rpt_line ,row + 2 ,did_break = 1 ,firsttime = 0 ,pagebreak = 0
  HEAD class_description
   IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "THERAPEUTIC CLASS" ) ) row + 1 ,col 1 ,
    class_description ,row + 1
   ENDIF
  HEAD gen_name
   ;CALL echo (build ("Head gen_name --" ,gen_name ) ) ,
   IF ((row > 55 ) ) pagebreak = 1 ,
    BREAK
   ENDIF
  DETAIL
   ;CALL echo ("Detail" ) ,
   pagebreak = 1 ,
   IF ((ingredient_type_flag != ccompound_child_flag ) ) total_dispenses +=dispenses ,total_cost +=
    cost ,total_charges +=price
   ENDIF
   ,
   IF ((orderrec->orderlist[d.seq ].skip_dup_dot_order_ind = 0 ) ) total_orders +=1
   ENDIF
  FOOT  gen_name
   IF ((total_orders > 0 ) ) test_generic_name = replace (gen_name ,trim (compound_parent ) ,"" ,0 )
   ,short_generic_name = formattolength (trim (test_generic_name ) ,27 ) ,col 05 ,short_generic_name
   ,
    IF ((ingredient_type_flag != ccompound_child_flag ) ) col 32 ,total_orders "#######;," ,col 40 ,
     total_dispenses "#######;," ,col 48 ,total_cost "############.##;," ,col 64 ,total_charges
     "############.##;,"
    ENDIF
    ,
    IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "THERAPEUTIC CLASS" ) )
     IF ((dispenses_table[prev_dseq ] > 0 ) ) disp_percent = ((total_dispenses / dispenses_table[
      prev_dseq ] ) * 100 )
     ELSE disp_percent = 0.0
     ENDIF
     ,col 80 ,disp_percent "###.#" ,"%"
    ENDIF
    ,
    IF ((ingredient_type_flag != ccompound_child_flag ) ) total_orders_ther +=total_orders ,
     total_dispenses_ther +=total_dispenses ,total_cost_ther +=total_cost ,total_charges_ther +=
     total_charges
    ENDIF
    ,row + 1
   ENDIF
   ,total_dispenses = 0 ,total_cost = 0 ,total_charges = 0 ,total_orders = 0
  FOOT  class_description
   col 32 ,"-------" ,col 40 ,"-------" ,col 48 ,"---------------" ,col 64 ,"---------------" ,row +
   1 ,col 32 ,total_orders_ther "#######;," ,col 40 ,total_dispenses_ther "#######;," ,col 48 ,
   total_cost_ther "############.##;," ,col 64 ,total_charges_ther "############.##;," ,
   IF ((cnvtupper (trim ( $SEARCHTYPE ) ) = "THERAPEUTIC CLASS" ) )
    IF ((facility_table[fac_dseq ] > 0 ) ) disp_percent = ((dispenses_table[prev_dseq ] /
     facility_table[fac_dseq ] ) * 100 )
    ELSE disp_percent = 0.0
    ENDIF
    ,col 88 ,disp_percent "###.#" ,"%"
   ENDIF
   ,prev_dseq +=1 ,total_dispenses_ther = 0 ,total_cost_ther = 0 ,total_charges_ther = 0 ,
   total_orders_ther = 0 ,row + 1
  FOOT  facility_area
   fac_dseq +=1 ,did_break = 1 ,row + 56
  FOOT REPORT
   row + 1 ,
   IF ((nhit_report = 1 ) ) end_of_report = "* * * End of Report * * *" ,
    CALL center (end_of_report ,0 ,80 )
   ELSE "No data qualified for selection"
   ENDIF
   
   ;CALL echo ("*** End of Report ***" )
  WITH nocounter ,maxrow = 55 ,maxcol = 100 ,nullreport ,format ,format = variable
 ;end select
 IF ((curqual = 0 ) )
  SET reply->status_data.status = "Z"
  ;CALL echo ("No Qualifications" )
 ELSE
  SET reply->status_data.status = "S"
  ;CALL echo ("Success" )
 ENDIF
#exit_script
SELECT into $OUTDEV
	ORDERLIST_SORT_GENERIC_NAME = SUBSTRING(1, 30, ORDERREC->orderlist[D1.SEQ].sort_generic_name)
	, ORDERLIST_SORT_LABEL_DESC = ORDERREC->orderlist[D1.SEQ].sort_label_desc
	, ORDERLIST_CLASS_TOTAL_DISPENSED = ORDERREC->orderlist[D1.SEQ].class_total_dispensed
	, ORDERLIST_ORDERID = ORDERREC->orderlist[D1.SEQ].orderid
	, ORDERLIST_COST = ORDERREC->orderlist[D1.SEQ].cost
	, ORDERLIST_PRICE = ORDERREC->orderlist[D1.SEQ].price
	, ORDERLIST_DEPTMISCLINE = ORDERREC->orderlist[D1.SEQ].deptmiscline
	, ORDERLIST_NAME = ORDERREC->orderlist[D1.SEQ].name
	, ORDERLIST_MED_REC = ORDERREC->orderlist[D1.SEQ].med_rec
	, ORDERLIST_FIN_NBR = ORDERREC->orderlist[D1.SEQ].fin_nbr
	, ORDERLIST_PROJECTED_STOP_DT_TM = ORDERREC->orderlist[D1.SEQ].projected_stop_dt_tm
	, ORDERLIST_PROJECTED_STOP_TZ = ORDERREC->orderlist[D1.SEQ].projected_stop_tz
	, ORDERLIST_CURRENT_START_DT_TM = ORDERREC->orderlist[D1.SEQ].current_start_dt_tm
	, ORDERLIST_CURRENT_START_TZ = ORDERREC->orderlist[D1.SEQ].current_start_tz
	, ORDERLIST_ENCNTR_ID = ORDERREC->orderlist[D1.SEQ].encntr_id
	, ORDERLIST_LOC_S = ORDERREC->orderlist[D1.SEQ].loc_s
	, ORDERLIST_LOC_ROOM_S = ORDERREC->orderlist[D1.SEQ].loc_room_s
	, ORDERLIST_LOC_BED_S = ORDERREC->orderlist[D1.SEQ].loc_bed_s
	, ORDERLIST_FACILITY = ORDERREC->orderlist[D1.SEQ].facility
	, ORDERLIST_ORDER_STATUS = ORDERREC->orderlist[D1.SEQ].order_status
	, ORDERLIST_ALL_UNVERIFIED_IND = ORDERREC->orderlist[D1.SEQ].all_unverified_ind
	, ORDERLIST_QUALIFIED = ORDERREC->orderlist[D1.SEQ].qualified
	, ORDERLIST_GENERIC_NAME = SUBSTRING(1, 30, ORDERREC->orderlist[D1.SEQ].generic_name)
	, INGREDIENT_GENERIC_NAME = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].generic_name
	, ORDERLIST_INGREDIENT_GENERIC_NAME = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].generic_name
	, INGREDIENT_COST = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].cost
	, INGREDIENT_PRICE = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].price
	, INGREDIENT_DISPENSES = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].dispenses
	, INGREDIENT_INGREDIENT_TYPE_FLAG = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].ingredient_type_flag
	, INGREDIENT_COMPOUND_PARENT = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].compound_parent
	, INGREDIENT_COMPOUND_INGRED_ADD = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].compound_ingred_add
	, INGREDIENT_ITEM_ID = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].item_id
	, INGREDIENT_CLASS_DESCRIPTION = ORDERREC->orderlist[D1.SEQ].ingredient[D2.SEQ].class_description
	, ORDERLIST_SKIP_DUP_DOT_ORDER_IND = ORDERREC->orderlist[D1.SEQ].skip_dup_dot_order_ind

FROM
	(DUMMYT   D1  WITH SEQ = SIZE(ORDERREC->orderlist, 5))
	, (DUMMYT   D2  WITH SEQ = 1)

PLAN D1 WHERE MAXREC(D2, SIZE(ORDERREC->orderlist[D1.SEQ].ingredient, 5))
JOIN D2

WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 ;CALL echo ("Last Mod = 021" )
 ;CALL echo ("Mod Date = 29/06/2018" )
 ;CALL echo ("Last Mod = 022" )
 ;CALL echo ("Mod Date = 06/04/2020" )
 ;CALL echo ("Last Mod = 023" )
 ;CALL echo ("Mod Date = 08/27/2020" )
 ;CALL echo ("Last Mod = 024" )
 ;CALL echo ("Mod Date = 12/15/2020" )
 ;CALL echo ("Last Mod = 025" )
 ;CALL echo ("Mod Date = 03/24/2021" )
 
 call echorecord(orderrec)
 
END GO
