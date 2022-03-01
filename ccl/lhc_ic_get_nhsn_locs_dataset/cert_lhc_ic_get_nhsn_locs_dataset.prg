DROP PROGRAM lhc_ic_get_nhsn_locs_dataset :dba GO
CREATE PROGRAM lhc_ic_get_nhsn_locs_dataset :dba
 PROMPT
  "Facwide Option" = "" ,
  "Facility Code" = 0
  WITH facwide ,facility
 DECLARE stat = i4 WITH noconstant (0 ) ,protect
 DECLARE code_set = i4 WITH constant (4002971 ) ,protect
 DECLARE facwideyes = c6 WITH constant ("1250-0" ) ,protect
 DECLARE facwideno = c1 WITH constant ("0" ) ,protect
 DECLARE facility_cd = f8 WITH constant ( $FACILITY ) ,protect
 DECLARE error_msg = vc WITH noconstant ("" ) ,protect
 DECLARE error_cd = i4 WITH noconstant (0 ) ,protect
 DECLARE createdataset (null ) = null WITH private
 EXECUTE ccl_prompt_api_dataset "autoset"
 IF (((( $FACWIDE = facwideyes ) ) OR (( $FACWIDE = facwideno ) )) )
  CALL createdataset (null )
 ENDIF
 SUBROUTINE  createdataset (null )
  SET stat = makedataset (20 )
  SELECT
   IF (( $FACWIDE = facwideyes ) )
    PLAN (l
     WHERE (l.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
     AND (l.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (l.facility_cd = facility_cd ) )
     JOIN (cv
     WHERE (l.cdc_location_label_cd = cv.code_value )
     AND (cv.code_set = code_set )
     AND (substring (1 ,2 ,cv.definition ) = "IN" ) )
   ELSE
   ENDIF
   l.cdc_location_label_cd ,
   l_cdc_location_label_disp = concat (trim (uar_get_code_description (l.cdc_location_label_cd ) ,3
     ) ,"   " ,uar_get_code_display (l.cdc_location_label_cd ) ) ,
   facility_name = cnvtupper (uar_get_code_description (l.cdc_location_label_cd ) )
   FROM (lh_cnt_nhsn_location_map l ),
    (code_value cv )
   PLAN (l
    WHERE (l.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (l.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (l.facility_cd = facility_cd ) )
    JOIN (cv
    WHERE (l.cdc_location_label_cd = cv.code_value )
    AND (cv.code_set = code_set ) )
   ORDER BY facility_name
   HEAD l.cdc_location_label_cd
    stat = writerecord (0 )
   WITH reporthelp ,check ,nocounter
  ;end select
  SET stat = closedataset (0 )
  SET error_cd = error (error_msg ,0 )
  IF ((error_cd != 0 ) )
   EXECUTE ccl_prompt_write_log concat ("Retrieving mapped NHSN locations failed: " ,error_msg )
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
END GO