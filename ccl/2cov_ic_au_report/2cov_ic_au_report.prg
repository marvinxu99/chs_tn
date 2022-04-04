DROP PROGRAM 2cov_ic_au_report :dba GO
CREATE PROGRAM 2cov_ic_au_report :dba
 prompt
	"Output to File/Printer/MINE" = "MINE"
	, "From Date/Time" = ""
	, "To Date/Time" = ""
	, "Collect Facility Name" = 0
	, "Facility Wide Reporting" = 0
	, "NHSN Location" = 0
	, "Collect Unit Name" = 0
	, "Medication" = 0
	, "Route" = 0
	, "Output:" = 0
	, "File Location:" = "C:\"
	, "Called From Ind:" = 0
	, "ADMISSIONS" = 0
 
with OUTDEV, FROMDATE, THRUDATE, FACILITY, FACWIDE, NHSNLOC, UNIT, MEDICATION, ROUTE,
	OUTPUT, FILE, REPORTTYPEIND, ADMISSIONS
 DECLARE log_program_name = vc WITH protect ,noconstant ("" )
 DECLARE log_override_ind = i2 WITH protect ,noconstant (0 )
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect ,noconstant (0 )
 DECLARE log_level_warning = i2 WITH protect ,noconstant (1 )
 DECLARE log_level_audit = i2 WITH protect ,noconstant (2 )
 DECLARE log_level_info = i2 WITH protect ,noconstant (3 )
 DECLARE log_level_debug = i2 WITH protect ,noconstant (4 )
 DECLARE hsys = i4 WITH protect ,noconstant (0 )
 DECLARE sysstat = i4 WITH protect ,noconstant (0 )
 DECLARE serrmsg = c132 WITH protect ,noconstant (" " )
 DECLARE ierrcode = i4 WITH protect ,noconstant (error (serrmsg ,1 ) )
 DECLARE crsl_msg_default = i4 WITH protect ,noconstant (0 )
 DECLARE crsl_msg_level = i4 WITH protect ,noconstant (0 )
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle ()
 SET crsl_msg_level = uar_msggetlevel (crsl_msg_default )
 DECLARE lcrslsubeventcnt = i4 WITH protect ,noconstant (0 )
 DECLARE icrslloggingstat = i2 WITH protect ,noconstant (0 )
 DECLARE lcrslsubeventsize = i4 WITH protect ,noconstant (0 )
 DECLARE icrslloglvloverrideind = i2 WITH protect ,noconstant (0 )
 DECLARE scrsllogtext = vc WITH protect ,noconstant ("" )
 DECLARE scrsllogevent = vc WITH protect ,noconstant ("" )
 DECLARE icrslholdloglevel = i2 WITH protect ,noconstant (0 )
 DECLARE icrslerroroccured = i2 WITH protect ,noconstant (0 )
 DECLARE lcrsluarmsgwritestat = i4 WITH protect ,noconstant (0 )
 DECLARE crsl_info_domain = vc WITH protect ,constant ("DISCERNABU SCRIPT LOGGING" )
 DECLARE crsl_logging_on = c1 WITH protect ,constant ("L" )
 IF ((((logical ("MP_LOGGING_ALL" ) > " " ) ) OR ((logical (concat ("MP_LOGGING_" ,log_program_name
   ) ) > " " ) )) )
  SET log_override_ind = 1
 ENDIF
 DECLARE log_message ((logmsg = vc ) ,(loglvl = i4 ) ) = null
 SUBROUTINE  log_message (logmsg ,loglvl )
  SET icrslloglvloverrideind = 0
  SET scrsllogtext = ""
  SET scrsllogevent = ""
  SET scrsllogtext = concat ("{{Script::" ,value (log_program_name ) ,"}} " ,logmsg )
  IF ((log_override_ind = 0 ) )
   SET icrslholdloglevel = loglvl
  ELSE
   IF ((crsl_msg_level < loglvl ) )
    SET icrslholdloglevel = crsl_msg_level
    SET icrslloglvloverrideind = 1
   ELSE
    SET icrslholdloglevel = loglvl
   ENDIF
  ENDIF
  IF ((icrslloglvloverrideind = 1 ) )
   SET scrsllogevent = "Script_Override"
  ELSE
   CASE (icrslholdloglevel )
    OF log_level_error :
     SET scrsllogevent = "Script_Error"
    OF log_level_warning :
     SET scrsllogevent = "Script_Warning"
    OF log_level_audit :
     SET scrsllogevent = "Script_Audit"
    OF log_level_info :
     SET scrsllogevent = "Script_Info"
    OF log_level_debug :
     SET scrsllogevent = "Script_Debug"
   ENDCASE
  ENDIF
  SET lcrsluarmsgwritestat = uar_msgwrite (crsl_msg_default ,0 ,nullterm (scrsllogevent ) ,
   icrslholdloglevel ,nullterm (scrsllogtext ) )
  CALL echo (logmsg )
  set html_denom_log = concat(html_denom_log,"<br>",logmsg)
 END ;Subroutine
 DECLARE error_message ((logstatusblockind = i2 ) ) = i2
 SUBROUTINE  error_message (logstatusblockind )
  SET icrslerroroccured = 0
  SET ierrcode = error (serrmsg ,0 )
  WHILE ((ierrcode > 0 ) )
   SET icrslerroroccured = 1
   IF (validate (reply ) )
    SET reply->status_data.status = "F"
   ENDIF
   CALL log_message (serrmsg ,log_level_audit )
   IF ((logstatusblockind = 1 ) )
    IF (validate (reply ) )
     CALL populate_subeventstatus ("EXECUTE" ,"F" ,"CCL SCRIPT" ,serrmsg )
    ENDIF
   ENDIF
   SET ierrcode = error (serrmsg ,0 )
  ENDWHILE
  RETURN (icrslerroroccured )
 END ;Subroutine
 DECLARE error_and_zero_check_rec ((qualnum = i4 ) ,(opname = vc ) ,(logmsg = vc ) ,(errorforceexit
  = i2 ) ,(zeroforceexit = i2 ) ,(recorddata = vc (ref ) ) ) = i2
 SUBROUTINE  error_and_zero_check_rec (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit ,
  recorddata )
  SET icrslerroroccured = 0
  SET ierrcode = error (serrmsg ,0 )
  WHILE ((ierrcode > 0 ) )
   SET icrslerroroccured = 1
   CALL log_message (serrmsg ,log_level_audit )
   CALL populate_subeventstatus_rec (opname ,"F" ,serrmsg ,logmsg ,recorddata )
   SET ierrcode = error (serrmsg ,0 )
  ENDWHILE
  IF ((icrslerroroccured = 1 )
  AND (errorforceexit = 1 ) )
   SET recorddata->status_data.status = "F"
   GO TO exit_script
  ENDIF
  IF ((qualnum = 0 )
  AND (zeroforceexit = 1 ) )
   SET recorddata->status_data.status = "Z"
   CALL populate_subeventstatus_rec (opname ,"Z" ,"No records qualified" ,logmsg ,recorddata )
   GO TO exit_script
  ENDIF
  RETURN (icrslerroroccured )
 END ;Subroutine
 DECLARE error_and_zero_check ((qualnum = i4 ) ,(opname = vc ) ,(logmsg = vc ) ,(errorforceexit = i2
  ) ,(zeroforceexit = i2 ) ) = i2
 SUBROUTINE  error_and_zero_check (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit )
  RETURN (error_and_zero_check_rec (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit ,reply ) )
 END ;Subroutine
 DECLARE populate_subeventstatus_rec ((operationname = vc (value ) ) ,(operationstatus = vc (value )
  ) ,(targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ,(recorddata = vc (ref )
  ) ) = i2
 SUBROUTINE  populate_subeventstatus_rec (operationname ,operationstatus ,targetobjectname ,
  targetobjectvalue ,recorddata )
  IF ((validate (recorddata->status_data.status ,"-1" ) != "-1" ) )
   SET lcrslsubeventcnt = size (recorddata->status_data.subeventstatus ,5 )
   SET lcrslsubeventsize = size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     operationname ) )
   SET lcrslsubeventsize = (lcrslsubeventsize + size (trim (recorddata->status_data.subeventstatus[
     lcrslsubeventcnt ].operationstatus ) ) )
   SET lcrslsubeventsize = (lcrslsubeventsize + size (trim (recorddata->status_data.subeventstatus[
     lcrslsubeventcnt ].targetobjectname ) ) )
   SET lcrslsubeventsize = (lcrslsubeventsize + size (trim (recorddata->status_data.subeventstatus[
     lcrslsubeventcnt ].targetobjectvalue ) ) )
   IF ((lcrslsubeventsize > 0 ) )
    SET lcrslsubeventcnt = (lcrslsubeventcnt + 1 )
    SET icrslloggingstat = alter (recorddata->status_data.subeventstatus ,lcrslsubeventcnt )
   ENDIF
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].operationname = substring (1 ,25 ,
    operationname )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].operationstatus = substring (1 ,1 ,
    operationstatus )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].targetobjectname = substring (1 ,25
    ,targetobjectname )
   SET recorddata->status_data.subeventstatus[lcrslsubeventcnt ].targetobjectvalue =
   targetobjectvalue
  ENDIF
 END ;Subroutine
 DECLARE populate_subeventstatus ((operationname = vc (value ) ) ,(operationstatus = vc (value ) ) ,(
  targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ) = i2
 SUBROUTINE  populate_subeventstatus (operationname ,operationstatus ,targetobjectname ,
  targetobjectvalue )
  CALL populate_subeventstatus_rec (operationname ,operationstatus ,targetobjectname ,
   targetobjectvalue ,reply )
 END ;Subroutine
 DECLARE populate_subeventstatus_msg ((operationname = vc (value ) ) ,(operationstatus = vc (value )
  ) ,(targetobjectname = vc (value ) ) ,(targetobjectvalue = vc (value ) ) ,(loglevel = i2 (value )
  ) ) = i2
 SUBROUTINE  populate_subeventstatus_msg (operationname ,operationstatus ,targetobjectname ,
  targetobjectvalue ,loglevel )
  CALL populate_subeventstatus (operationname ,operationstatus ,targetobjectname ,targetobjectvalue
   )
  CALL log_message (targetobjectvalue ,loglevel )
 END ;Subroutine
 DECLARE check_log_level ((arg_log_level = i4 ) ) = i2
 SUBROUTINE  check_log_level (arg_log_level )
  IF ((((crsl_msg_level >= arg_log_level ) ) OR ((log_override_ind = 1 ) )) )
   RETURN (1 )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 DECLARE errmsg = vc WITH noconstant ("" )
 DECLARE errorcode = i4 WITH noconstant (0 )
 DECLARE sub_start_time = dq8 WITH protect ,noconstant (0.0 )
 DECLARE execute_start_time = dq8 WITH protect ,constant (cnvtdatetime (curdate ,curtime ) )
 DECLARE debug_ind = i4 WITH protect ,noconstant (0 )
 DECLARE nhsn_xml_iv_code = vc WITH protect ,noconstant ("" )
 DECLARE nhsn_xml_im_code = vc WITH protect ,noconstant ("" )
 DECLARE nhsn_xml_resp_code = vc WITH protect ,noconstant ("" )
 DECLARE nhsn_xml_digest_code = vc WITH protect ,noconstant ("" )
 DECLARE inerror = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"INERROR" ) ) ,protect
 DECLARE deleterow = f8 WITH constant (uar_get_code_by ("MEANING" ,48 ,"DELETED" ) ) ,protect
 DECLARE audit_solution_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE audit_event_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE iv_route = vc WITH protect ,constant ("Intravenous" )
 DECLARE im_route = vc WITH protect ,constant ("Intramuscular" )
 DECLARE digest_route = vc WITH protect ,constant ("Digestive Tract" )
 DECLARE respiratory_route = vc WITH protect ,constant ("Respiratory Tract" )
 DECLARE increment_total = i4 WITH protect ,constant (1 )
 DECLARE not_available = i4 WITH protect ,constant (1 )
 DECLARE available = i4 WITH protect ,constant (0 )
 DECLARE facwidein = i4 WITH protect ,constant (0 )
 DECLARE not_facwidein = i4 WITH protect ,constant (1 )
 DECLARE true = i4 WITH protect ,constant (1 )
 DECLARE false = i4 WITH protect ,constant (0 )
 DECLARE non_nhsn_med_cdf_meaning = vc WITH protect ,constant ("NON_NHSN_MED" )
 DECLARE dot_report = i2 WITH protect ,constant (1 )
 DECLARE au_report = i2 WITH protect ,constant (0 )
 DECLARE stop_iv_cnt_ind = i4 WITH protect ,noconstant (0 )
 DECLARE stop_respiratory_cnt_ind = i4 WITH protect ,noconstant (0 )
 DECLARE stop_digest_cnt_ind = i4 WITH protect ,noconstant (0 )
 DECLARE stop_im_cnt_ind = i4 WITH protect ,noconstant (0 )
 FREE RECORD medication_list
 RECORD medication_list (
   1 med_cnt = i4
   1 med_cds [* ]
     2 nhsnmed_cd = f8
     2 medication_cd = f8
     2 medication_disp = vc
     2 nhsnmed_disp = vc
     2 not_applicable = i4
     2 facility_cd = f8
     2 nhsnmed_ind = i2
 )
 FREE RECORD temproute_list
 RECORD temproute_list (
   1 route_cnt = i4
   1 route_cd_list [* ]
     2 route_cd = f8
 )
 FREE RECORD route_list
 RECORD route_list (
   1 nhsnroute_cds [* ]
     2 nhsnroute_cd = f8
     2 nhsnroute_disp = vc
     2 catroute_list [* ]
       3 catroute_cd = f8
       3 catroute_disp = vc
 )
 FREE RECORD loc_list
 RECORD loc_list (
   1 loc_cnt = i4
   1 location [* ]
     2 loc_cd = f8
     2 loc_disp = vc
     2 cdc_cd = f8
     2 nhsn_your_code = vc
 )
 FREE RECORD temp_reply
 RECORD temp_reply (
   1 admin_date [* ]
     2 admin_dt_tm = dq8
     2 units [* ]
       3 unit_cds = f8
       3 unit_disp = vc
       3 person [* ]
         4 person_id = f8
         4 meds [* ]
           5 temp_med_cd = f8
           5 temp_med_disp = vc
           5 nhsn_med_cd = f8
           5 med_disp = vc
           5 med_total = i4
           5 nhsn_med_ind = i2
           5 routes [* ]
             6 nhsn_route_cd = f8
             6 temp_route_cd = f8
             6 routes_count = i4
             6 route_disp = vc
 )
 FREE RECORD facwidein_reply
 RECORD facwidein_reply (
   1 admin_date [* ]
     2 admin_dt_tm = dq8
     2 person [* ]
       3 person_id = f8
       3 meds [* ]
         4 temp_med_cd = f8
         4 temp_med_disp = vc
         4 nhsn_med_cd = f8
         4 med_disp = vc
         4 nhsn_med_ind = i2
         4 routes [* ]
           5 nhsn_route_cd = f8
           5 temp_route_cd = f8
           5 routes_count = i4
           5 route_disp = vc
 )
 FREE RECORD temp_agent_counts
 RECORD temp_agent_counts (
   1 agents [* ]
     2 agent_name = vc
     2 agent_cd = f8
     2 not_available_flag = i2
     2 total = i4
     2 iv = i4
     2 im = i4
     2 digestive = i4
     2 respiratory = i4
     2 nhsn_med_ind = i2
 )
 free record reply
 RECORD reply (
   1 facility_name = vc
   1 facility_oid = vc
   1 from_date = dq8
   1 to_date = dq8
   1 rpt_type_flag = i2
   1 no_nhsn_flag = i2
   1 empty_reply_ind = i2
   1 months [* ]
     2 month_year = vc
     2 month_dt_tm = dq8
     2 locations [* ]
       3 location_cd = f8
       3 location_name = vc
       3 days_present = i4
       3 admissions = i4
       3 xml_string = vc
       3 agents [* ]
         4 agent_name = vc
         4 agent_cd = f8
         4 not_available_flag = i2
         4 total = i4
         4 iv = i4
         4 im = i4
         4 digestive = i4
         4 respiratory = i4
         4 nhsn_med_ind = i2
 ) with PERSISTSCRIPT
 
 RECORD bsc_rai_req (
   1 audit_events [* ]
     2 audit_solution_cd = f8
     2 audit_event_cd = f8
     2 audit_event_dt_tm = dq8
     2 audit_facility_cd = f8
     2 audit_patient_id = f8
     2 audit_info_text = vc
   1 debug_ind = i2
 ) WITH protect
 RECORD bsc_rai_rep (
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE getheaderdata (null ) = null
 DECLARE getmedicationlist (null ) = null
 DECLARE getroutelist (null ) = null
 DECLARE getlocationlist (null ) = null
 DECLARE getunitsadminevents (null ) = null
 DECLARE getfacwideinadminevents = null
 DECLARE storenhsnxmlroutecode ((route_name = vc ) ,(route_nhsn_code = vc ) ) = null
 DECLARE fillunitsreply (null ) = null
 DECLARE fillfacwideinreply (null ) = null
 DECLARE notapplicablemedsreply (null ) = null
 DECLARE populatedenomdata (null ) = null
 DECLARE generatefullxml (null ) = vc
 DECLARE createheaderxml ((rpt_type_flag = i2 ) ,(fac_oid = vc ) ,(month_start = f8 ) ,(month_end =
  f8 ) ,(cdc_loc_cd = f8 ) ,(nhsn_your_code = vc ) ,(days_present = i4 ) ,(admissions = i4 ) ) = vc
 DECLARE createsinglemedxml ((rpt_type_flag = i2 ) ,(not_available_flag = i2 ) ,(cdc_loc_cd = f8 ) ,(
  nhsn_your_code = vc ) ,(med_name = vc ) ,(rx_norm = vc ) ,(total_val = i4 ) ,(resp_val = i4 ) ,(
  digestive_val = i4 ) ,(iv_val = i4 ) ,(im_val = i4 ) ) = vc
 DECLARE createfooterxml (null ) = vc
 DECLARE writeauditinfo (null ) = null
 CALL log_message ("Begin - Script IC_AU_REPORT" ,log_level_debug )
 SET script_timer = cnvtdatetime (curdate ,curtime3 )
 CALL writeauditinfo (null )
 SELECT INTO "nl:"
  FROM (dm_info di )
  PLAN (di
   WHERE (di.info_domain = "LIGHTHOUSE CONTENT" )
   AND (di.info_name = "SCRIPT_LOGGING" )
   AND (di.info_char = "T" ) )
  DETAIL
   debug_ind = 1
  WITH nocounter
 ;end select
 IF ((datetimediff (cnvtdatetime ( $FROMDATE ) ,cnvtdatetime ( $THRUDATE ) ) <= 0 ) )
  CALL getheaderdata (null )
  CALL getmedicationlist (null )
  CALL getroutelist (null )
  CALL getlocationlist (null )
  IF (((( $FACWIDE = "0" ) ) OR (( $FACWIDE = "" ) )) )
   SET reply->rpt_type_flag = not_facwidein
   CALL getunitsadminevents (null )
  ELSE
   SET reply->rpt_type_flag = 0
   IF (( $NHSNLOC <= 0 ) )
    SET reply->no_nhsn_flag = 1
    SET stat = alterlist (reply->months ,1 )
    SET stat = alterlist (reply->months[1 ].locations ,1 )
    SET stat = alterlist (reply->months[1 ].locations[1 ].agents ,1 )
    GO TO exit_script
   ENDIF
   CALL getfacwideinadminevents (null )
  ENDIF
  CALL populatedenomdata (null )
  CALL notapplicablemedsreply (null )
  IF (( $OUTPUT = 2 ) )
   CALL generatefullxml (null )
  ENDIF
 ENDIF
 SUBROUTINE  getheaderdata (null )
  CALL log_message ("Begin - Subroutine GetHeaderData" ,log_level_debug )
  CALL log_message (build ("->$REPORTTYPEIND=" , $REPORTTYPEIND ) ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  IF (( $REPORTTYPEIND = au_report ) )
   SELECT INTO "nl:"
    FROM (lh_cnt_nhsn_location_map lm )
    PLAN (lm
     WHERE (lm.facility_cd =  $FACILITY ) )
    DETAIL
     reply->facility_name = uar_get_code_description (lm.facility_cd ) ,
     reply->facility_oid = trim (lm.facility_oid ,3 )
     CALL log_message (build ("->lm.facility_cd=" , lm.facility_cd ) ,log_level_debug )
     CALL log_message (build ("->lm.facility_oid=" , lm.facility_oid ) ,log_level_debug )
    WITH nocounter
   ;end select
   SET errorcode = error (errmsg ,0 )
   IF ((errorcode != 0 ) )
    CALL log_message (concat ("Subroutine GetHeaderData failed in fac data: " ,errmsg ) ,log_level_debug )
    GO TO exit_script
   ENDIF
  ELSEIF (( $REPORTTYPEIND = dot_report ) )
   SET reply->facility_name = uar_get_code_description ( $FACILITY )
  ENDIF
  SET reply->from_date = cnvtdatetime ( $FROMDATE )
  SET reply->to_date = cnvtdatetime ( $THRUDATE )
  CALL log_message (build ("End - Subroutine GetHeaderData. Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  getmedicationlist (null )
  CALL log_message ("Begin - Subroutine GetMedicationList" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  DECLARE med_cnt = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (code_value cv ),
    (code_value_group cvg )
   PLAN (cv
    WHERE (cv.code_value =  $MEDICATION ) )
    JOIN (cvg
    WHERE (cvg.parent_code_value = outerjoin (cv.code_value ) ) )
   ORDER BY cv.description
   HEAD REPORT
    med_cnt = 0
   DETAIL
    IF ((cv.code_value > 0 ) ) med_cnt = (med_cnt + 1 ) ,
     IF ((mod (med_cnt ,90 ) = 1 ) ) stat = alterlist (medication_list->med_cds ,(med_cnt + 89 ) )
     ENDIF
     ,medication_list->med_cds[med_cnt ].nhsnmed_cd = cv.code_value ,medication_list->med_cds[
     med_cnt ].nhsnmed_disp = cv.description ,medication_list->med_cds[med_cnt ].medication_cd = cvg
     .child_code_value ,medication_list->med_cds[med_cnt ].medication_disp = uar_get_code_display (
      cvg.child_code_value ) ,
     IF ((cv.cdf_meaning != non_nhsn_med_cdf_meaning ) ) medication_list->med_cds[med_cnt ].
      nhsnmed_ind = true
     ENDIF
     ,
     IF ((cvg.child_code_value != null ) ) medication_list->med_cds[med_cnt ].not_applicable = 0
     ELSE medication_list->med_cds[med_cnt ].not_applicable = 1
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (medication_list->med_cds ,med_cnt ) ,
    medication_list->med_cnt = med_cnt
   WITH nocounter
  ;end select
  SET errorcode = error (errmsg ,0 )
  IF ((errorcode != 0 ) )
   CALL log_message (concat ("Subroutine GetMedicationList failed in med data: " ,errmsg ) ,
    log_level_debug )
   GO TO exit_script
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echorecord (medication_list )
  ENDIF
  CALL log_message (build ("End - Subroutine GetMedicationList. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  getroutelist (null )
  CALL log_message ("Begin - Subroutine GetRouteList" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  DECLARE nhsnroute_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE route_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE temp_route_cnt = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (code_value cv ),
    (code_value_group cvg )
   PLAN (cv
    WHERE (cv.code_value =  $ROUTE ) )
    JOIN (cvg
    WHERE (cvg.parent_code_value = outerjoin (cv.code_value ) ) )
   ORDER BY cv.code_value
   HEAD REPORT
    nhsnroute_cnt = 0 ,
    temp_route_cnt = 0
   HEAD cv.code_value
    route_cnt = 0 ,nhsnroute_cnt = (nhsnroute_cnt + 1 ) ,
    IF ((mod (nhsnroute_cnt ,10 ) = 1 ) ) stat = alterlist (route_list->nhsnroute_cds ,(
      nhsnroute_cnt + 9 ) )
    ENDIF
    ,route_list->nhsnroute_cds[nhsnroute_cnt ].nhsnroute_cd = cv.code_value ,route_list->
    nhsnroute_cds[nhsnroute_cnt ].nhsnroute_disp = cv.description ,
    IF (( $OUTPUT = 2 ) )
     CALL storenhsnxmlroutecode (cv.description ,cv.display )
    ENDIF
   DETAIL
    route_cnt = (route_cnt + 1 ) ,
    IF ((mod (route_cnt ,50 ) = 1 ) ) stat = alterlist (route_list->nhsnroute_cds[nhsnroute_cnt ].
      catroute_list ,(route_cnt + 49 ) )
    ENDIF
    ,route_list->nhsnroute_cds[nhsnroute_cnt ].catroute_list[route_cnt ].catroute_cd = cvg
    .child_code_value ,
    route_list->nhsnroute_cds[nhsnroute_cnt ].catroute_list[route_cnt ].catroute_disp =
    uar_get_code_description (cvg.child_code_value ) ,
    IF ((cvg.child_code_value != null ) ) temp_route_cnt = (temp_route_cnt + 1 ) ,
     IF ((mod (temp_route_cnt ,50 ) = 1 ) ) stat = alterlist (temproute_list->route_cd_list ,(
       temp_route_cnt + 49 ) )
     ENDIF
     ,temproute_list->route_cd_list[temp_route_cnt ].route_cd = cvg.child_code_value
    ENDIF
   FOOT  cv.code_value
    stat = alterlist (route_list->nhsnroute_cds[nhsnroute_cnt ].catroute_list ,route_cnt )
   FOOT REPORT
    stat = alterlist (temproute_list->route_cd_list ,temp_route_cnt ) ,
    temproute_list->route_cnt = temp_route_cnt ,
    stat = alterlist (route_list->nhsnroute_cds ,nhsnroute_cnt )
   WITH nocounter
  ;end select
  SET errorcode = error (errmsg ,0 )
  IF ((errorcode != 0 ) )
   CALL log_message (concat ("Subroutine GetRouteList failed in route data: " ,errmsg ) ,
    log_level_debug )
   GO TO exit_script
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echorecord (route_list )
   CALL echorecord (temproute_list )
  ENDIF
  CALL log_message (build ("End - Subroutine GetRouteList. Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  getlocationlist (null )
  CALL log_message ("Begin - Subroutine GetLocationList" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  DECLARE location_cnt = i4 WITH protect ,noconstant (0 )
  IF (( $NHSNLOC > 0 ) )
   SELECT INTO "nl:"
    location = uar_get_code_display (l.location_cd ) ,
    l.location_cd
    FROM (lh_cnt_nhsn_location_map lh ),
     (location l )
    PLAN (lh
     WHERE (lh.facility_cd =  $FACILITY )
     AND (lh.cdc_location_label_cd =  $NHSNLOC )
     AND (lh.end_effective_dt_tm > cnvtdatetime (curdate ,curtime ) )
     AND (lh.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime ) ) )
     JOIN (l
     WHERE (lh.nurse_loc_cd = l.location_cd )
     AND (l.active_ind = 1 )
     AND (l.location_cd > 0 ) )
    ORDER BY l.location_cd
    HEAD REPORT
     location_cnt = 0
    HEAD l.location_cd
     location_cnt = (location_cnt + 1 ) ,
     IF ((mod (location_cnt ,10 ) = 1 ) ) stat = alterlist (loc_list->location ,(location_cnt + 9 )
       )
     ENDIF
     ,loc_list->location[location_cnt ].loc_disp = location
     ,loc_list->location[location_cnt ].loc_cd= l.location_cd
      ,loc_list->location[location_cnt ].cdc_cd = lh.cdc_location_label_cd
      ,loc_list->location[location_cnt ].nhsn_your_code = lh.nhsn_unit_disp_name
    FOOT REPORT
     stat = alterlist (loc_list->location ,location_cnt ) ,
     loc_list->loc_cnt = location_cnt
    WITH nocounter
 
     SELECT INTO "nl:"
    location = uar_get_code_display (l.location_cd ) ,
    l.location_cd
    FROM (lh_cnt_nhsn_location_map lh ),
     (location l )
    PLAN (lh
     WHERE (lh.facility_cd =  $FACILITY ))
     JOIN (l
     WHERE (lh.nurse_loc_cd = l.location_cd )
     AND (l.location_cd in( 2552509989.00) ) ) ;PW 4R
    ORDER BY l.location_cd
    ,lh.end_effective_dt_tm desc
    HEAD REPORT
     location_cnt = loc_list->loc_cnt
    HEAD l.location_cd
 
     location_cnt = (location_cnt + 1 ) ,
     stat = alterlist (loc_list->location ,location_cnt  )
 
     ,loc_list->location[location_cnt ].loc_disp = location ,loc_list->location[location_cnt ].loc_cd
      = l.location_cd ,loc_list->location[location_cnt ].cdc_cd = lh.cdc_location_label_cd ,loc_list
     ->location[location_cnt ].nhsn_your_code = lh.nhsn_unit_disp_name
    FOOT REPORT
     stat = alterlist (loc_list->location ,location_cnt ) ,
     loc_list->loc_cnt = location_cnt
    WITH nocounter
   ;end select
   SET errorcode = error (errmsg ,0 )
   IF ((errorcode != 0 ) )
    CALL log_message (concat ("Subroutine GetLocationList failed in NHSN loc: " ,errmsg ) ,
     log_level_debug )
    GO TO exit_script
   ENDIF
  ELSE
   IF (((( $OUTPUT = 0 ) ) OR (( $OUTPUT = 1 ) )) )
    SELECT INTO "nl:"
     location = uar_get_code_display (l.location_cd )
     FROM (location l )
     WHERE (l.location_cd =  $UNIT )
     AND (l.active_ind = 1 )
     AND (l.location_cd > 0 )
     ORDER BY l.location_cd
     HEAD REPORT
      location_cnt = 0
     HEAD l.location_cd
      location_cnt = (location_cnt + 1 ) ,
      IF ((mod (location_cnt ,10 ) = 1 ) ) stat = alterlist (loc_list->location ,(location_cnt + 9 )
        )
      ENDIF
      ,loc_list->location[location_cnt ].loc_disp = location ,loc_list->location[location_cnt ].
      loc_cd = l.location_cd
     FOOT REPORT
      stat = alterlist (loc_list->location ,location_cnt ) ,
      loc_list->loc_cnt = location_cnt
     WITH nocounter
    ;end select
    SET errorcode = error (errmsg ,0 )
    IF ((errorcode != 0 ) )
     CALL log_message (concat ("Subroutine GetLocationList failed in units: " ,errmsg ) ,
      log_level_debug )
     GO TO exit_script
    ENDIF
   ELSEIF (( $OUTPUT = 2 ) )
    SELECT INTO "nl:"
     location = uar_get_code_display (l.location_cd )
     FROM (location l ),
      (lh_cnt_nhsn_location_map lm )
     PLAN (l
      WHERE (l.location_cd =  $UNIT )
      AND (l.active_ind = 1 )
      AND (l.location_cd > 0 ) )
      JOIN (lm
      WHERE (lm.facility_cd =  $FACILITY )
      AND (lm.nurse_loc_cd = l.location_cd )
      AND (lm.end_effective_dt_tm > cnvtdatetime (curdate ,curtime ) )
      AND (lm.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime ) )
      AND (lm.active_ind = 1 ) )
     ORDER BY l.location_cd
     HEAD REPORT
      location_cnt = 0
     HEAD l.location_cd
      location_cnt = (location_cnt + 1 ) ,
      IF ((mod (location_cnt ,10 ) = 1 ) ) stat = alterlist (loc_list->location ,(location_cnt + 9 )
        )
      ENDIF
      ,loc_list->location[location_cnt ].loc_disp = location ,loc_list->location[location_cnt ].
      loc_cd = l.location_cd ,loc_list->location[location_cnt ].cdc_cd = lm.cdc_location_label_cd ,
      loc_list->location[location_cnt ].nhsn_your_code = lm.nhsn_unit_disp_name
     FOOT REPORT
      stat = alterlist (loc_list->location ,location_cnt ) ,
      loc_list->loc_cnt = location_cnt
     WITH nocounter
    ;end select
    SET errorcode = error (errmsg ,0 )
    IF ((errorcode != 0 ) )
     CALL log_message (concat ("Subroutine GetlocationList failed in units: " ,errmsg ) ,
      log_level_debug )
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echorecord (loc_list )
  ENDIF
  CALL log_message (build ("End - Subroutine GetLocationList. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  getunitsadminevents (null )
  CALL log_message ("Begin - Subroutine GetUnitsAdminEvents" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  DECLARE location_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE medication_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE temp_route_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE admin_dt_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE unit_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE med_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE person_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE route_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE admin_route_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE exist_route_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE admin_med_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE med_size = i4 WITH protect ,noconstant (0 )
  DECLARE route_size = i4 WITH protect ,noconstant (0 )
  DECLARE temp_route_size = i4 WITH protect ,noconstant (0 )
  DECLARE nhsn_route_size = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   admin_date = cnvtdatetime (cnvtdate (mae.verification_dt_tm ) ,000000 )
   FROM (lh_cnt_ic_med_admin_event mae ),
    (clinical_event ce )
   PLAN (mae
    WHERE expand (location_cnt ,1 ,loc_list->loc_cnt ,mae.nurse_unit_cd ,loc_list->location[
     location_cnt ].loc_cd )
    AND (mae.facility_cd = cnvtreal ( $FACILITY ) )
    AND expand (medication_cnt ,1 ,medication_list->med_cnt ,mae.catalog_cd ,medication_list->
     med_cds[medication_cnt ].medication_cd )
    AND expand (temp_route_cnt ,1 ,temproute_list->route_cnt ,mae.route_cd ,temproute_list->
     route_cd_list[temp_route_cnt ].route_cd )
    AND (mae.active_ind = 1 )
    AND (mae.verification_dt_tm BETWEEN cnvtdatetime ( $FROMDATE ) AND cnvtdatetime ( $THRUDATE ) )
    )
    JOIN (ce
    WHERE (ce.event_id = mae.event_id )
    AND (ce.result_status_cd != inerror )
    AND (ce.record_status_cd != deleterow )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime ) ) )
   ORDER BY admin_date ,
    mae.nurse_unit_cd ,
    ce.person_id ,
    mae.catalog_cd ,
    mae.route_cd
   HEAD REPORT
    nhsn_route_size = size (route_list->nhsnroute_cds ,5 ) ,
    admin_dt_cnt = 0
   HEAD admin_date
    unit_cnt = 0 ,admin_dt_cnt = (admin_dt_cnt + 1 ) ,
    IF ((mod (admin_dt_cnt ,100 ) = 1 ) ) stat = alterlist (temp_reply->admin_date ,(admin_dt_cnt +
      99 ) )
    ENDIF
    ,temp_reply->admin_date[admin_dt_cnt ].admin_dt_tm = mae.verification_dt_tm
   HEAD mae.nurse_unit_cd
    person_cnt = 0 ,unit_cnt = (unit_cnt + 1 ) ,
    IF ((mod (unit_cnt ,10 ) = 1 ) ) stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units ,(
      unit_cnt + 9 ) )
    ENDIF
    ,temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].unit_cds = mae.nurse_unit_cd ,temp_reply
    ->admin_date[admin_dt_cnt ].units[unit_cnt ].unit_disp = uar_get_code_display (mae.nurse_unit_cd
     )
   HEAD ce.person_id
    med_cnt = 0 ,med_pos = 0 ,admin_med_cnt = 0 ,person_cnt = (person_cnt + 1 ) ,
    IF ((mod (person_cnt ,10 ) = 1 ) ) stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units[
      unit_cnt ].person ,(person_cnt + 9 ) )
    ENDIF
    ,temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].person_id = ce
    .person_id
   HEAD mae.catalog_cd
    route_cnt = 0 ,admin_route_cnt = 0 ,exist_route_cnt = 0 ,med_cnt = (med_cnt + 1 ) ,
    IF ((mod (med_cnt ,90 ) = 1 ) ) stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units[
      unit_cnt ].person[person_cnt ].meds ,(med_cnt + 89 ) )
    ENDIF
    ,temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].
    temp_med_cd = mae.catalog_cd ,temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[
    person_cnt ].meds[med_cnt ].temp_med_disp = uar_get_code_display (mae.catalog_cd ) ,med_size =
    medication_list->med_cnt ,med_pos = locateval (admin_med_cnt ,1 ,med_size ,mae.catalog_cd ,
     medication_list->med_cds[admin_med_cnt ].medication_cd ) ,
    IF ((med_pos > 0 ) ) temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].
     meds[med_cnt ].med_disp = medication_list->med_cds[med_pos ].nhsnmed_disp ,temp_reply->
     admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].nhsn_med_cd =
     medication_list->med_cds[med_pos ].nhsnmed_cd ,temp_reply->admin_date[admin_dt_cnt ].units[
     unit_cnt ].person[person_cnt ].meds[med_cnt ].nhsn_med_ind = medication_list->med_cds[med_pos ].
     nhsnmed_ind
    ENDIF
   HEAD mae.route_cd
    route_pos = 0
   DETAIL
    IF ((route_pos = 0 ) )
     FOR (route_index = 1 TO nhsn_route_size )
      route_size = size (route_list->nhsnroute_cds[route_index ].catroute_list ,5 ) ,route_pos =
      locateval (admin_route_cnt ,1 ,route_size ,mae.route_cd ,route_list->nhsnroute_cds[route_index
       ].catroute_list[admin_route_cnt ].catroute_cd ) ,
      IF ((route_pos > 0 ) ) temp_route_size = size (temp_reply->admin_date[admin_dt_cnt ].units[
        unit_cnt ].person[person_cnt ].meds[med_cnt ].routes ,5 ) ,
       IF ((locateval (exist_route_cnt ,1 ,temp_route_size ,route_list->nhsnroute_cds[route_index ].
        nhsnroute_cd ,temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].
        meds[med_cnt ].routes[exist_route_cnt ].nhsn_route_cd ) = 0 ) ) route_cnt = (route_cnt + 1 )
       ,
        IF ((mod (route_cnt ,10 ) = 1 ) ) stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].
          units[unit_cnt ].person[person_cnt ].meds[med_cnt ].routes ,(route_cnt + 9 ) )
        ENDIF
        ,temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].
        routes[route_cnt ].route_disp = route_list->nhsnroute_cds[route_index ].nhsnroute_disp ,
        temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].
        routes[route_cnt ].routes_count = 1 ,temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].
        person[person_cnt ].meds[med_cnt ].routes[route_cnt ].nhsn_route_cd = route_list->
        nhsnroute_cds[route_index ].nhsnroute_cd ,temp_reply->admin_date[admin_dt_cnt ].units[
        unit_cnt ].person[person_cnt ].meds[med_cnt ].routes[route_cnt ].temp_route_cd = mae
        .route_cd ,route_index = (nhsn_route_size + 1 )
       ELSE route_index = (nhsn_route_size + 1 )
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   FOOT  mae.route_cd
    donothing = 0
   FOOT  mae.catalog_cd
    stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].
     meds[med_cnt ].routes ,route_cnt )
   FOOT  ce.person_id
    stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds
      ,med_cnt )
   FOOT  mae.nurse_unit_cd
    stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person ,person_cnt )
   FOOT  admin_date
    stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units ,unit_cnt )
   FOOT REPORT
    stat = alterlist (temp_reply->admin_date ,admin_dt_cnt )
   WITH nocounter ,expand = 1
  ;end select
  SET errorcode = error (errmsg ,0 )
  IF ((errorcode != 0 ) )
   CALL log_message (concat ("Subroutine GetUnitsAdminEvents failed: " ,errmsg ) ,log_level_debug )
   GO TO exit_script
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echorecord (temp_reply )
  ENDIF
  CALL log_message (build ("End - Subroutine GetUnitsAdminEvents. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
  IF ((size (temp_reply->admin_date ,5 ) > 0 ) )
   CALL fillunitsreply (null )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getfacwideinadminevents (null )
  CALL log_message ("Begin - Subroutine GetFacwideInadminEvents" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  DECLARE location_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE medication_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE temp_route_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE facwide_admin_dt_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE facwide_med_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE facwide_prsn_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE facwide_route_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE admin_route_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE facwide_exst_route_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE admin_med_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE facewide_route_size = i4 WITH protect ,noconstant (0 )
  DECLARE med_size = i4 WITH protect ,noconstant (0 )
  DECLARE route_size = i4 WITH protect ,noconstant (0 )
  DECLARE facwideroute_index = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   admin_date = cnvtdatetime (cnvtdate (mae.verification_dt_tm ) ,0 )
   FROM (lh_cnt_ic_med_admin_event mae ),
    (clinical_event ce )
   PLAN (mae
    WHERE expand (location_cnt ,1 ,loc_list->loc_cnt ,mae.nurse_unit_cd ,loc_list->location[
     location_cnt ].loc_cd )
    AND (mae.facility_cd = cnvtreal ( $FACILITY ) )
    AND expand (medication_cnt ,1 ,medication_list->med_cnt ,mae.catalog_cd ,medication_list->
     med_cds[medication_cnt ].medication_cd )
    AND expand (temp_route_cnt ,1 ,temproute_list->route_cnt ,mae.route_cd ,temproute_list->
     route_cd_list[temp_route_cnt ].route_cd )
    AND (mae.active_ind = 1 )
    AND (mae.verification_dt_tm BETWEEN cnvtdatetime ( $FROMDATE ) AND cnvtdatetime ( $THRUDATE ) )
    )
    JOIN (ce
    WHERE (ce.event_id = mae.event_id )
    AND (ce.result_status_cd != inerror )
    AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime ) )
    AND (ce.record_status_cd != deleterow ) )
   ORDER BY admin_date ,
    ce.person_id ,
    mae.catalog_cd ,
    mae.route_cd
   HEAD REPORT
    nhsn_route_size = size (route_list->nhsnroute_cds ,5 ) ,
    facwide_admin_dt_cnt = 0
   HEAD admin_date
    facwide_prsn_cnt = 0 ,facwide_admin_dt_cnt = (facwide_admin_dt_cnt + 1 ) ,
    IF ((mod (facwide_admin_dt_cnt ,10 ) = 1 ) ) stat = alterlist (facwidein_reply->admin_date ,(
      facwide_admin_dt_cnt + 9 ) )
    ENDIF
    ,facwidein_reply->admin_date[facwide_admin_dt_cnt ].admin_dt_tm = mae.verification_dt_tm
   HEAD ce.person_id
    facwide_med_cnt = 0 ,facewidemed_pos = 0 ,admin_med_cnt = 0 ,facwide_prsn_cnt = (
    facwide_prsn_cnt + 1 ) ,
    IF ((mod (facwide_prsn_cnt ,10 ) = 1 ) ) stat = alterlist (facwidein_reply->admin_date[
      facwide_admin_dt_cnt ].person ,(facwide_prsn_cnt + 9 ) )
    ENDIF
    ,facwidein_reply->admin_date[facwide_admin_dt_cnt ].person[facwide_prsn_cnt ].person_id = ce
    .person_id
   HEAD mae.catalog_cd
    facwide_route_cnt = 0 ,facwide_exst_route_cnt = 0 ,admin_route_cnt = 0 ,facwide_med_cnt = (
    facwide_med_cnt + 1 ) ,
    IF ((mod (facwide_med_cnt ,100 ) = 1 ) ) stat = alterlist (facwidein_reply->admin_date[
      facwide_admin_dt_cnt ].person[facwide_prsn_cnt ].meds ,(facwide_med_cnt + 99 ) )
    ENDIF
    ,facwidein_reply->admin_date[facwide_admin_dt_cnt ].person[facwide_prsn_cnt ].meds[
    facwide_med_cnt ].temp_med_cd = mae.catalog_cd ,facwidein_reply->admin_date[facwide_admin_dt_cnt
    ].person[facwide_prsn_cnt ].meds[facwide_med_cnt ].temp_med_disp = uar_get_code_display (mae
     .catalog_cd ) ,med_size = medication_list->med_cnt ,facewidemed_pos = locateval (admin_med_cnt ,
     1 ,med_size ,mae.catalog_cd ,medication_list->med_cds[admin_med_cnt ].medication_cd ) ,
    IF ((facewidemed_pos > 0 ) ) facwidein_reply->admin_date[facwide_admin_dt_cnt ].person[
     facwide_prsn_cnt ].meds[facwide_med_cnt ].med_disp = medication_list->med_cds[facewidemed_pos ].
     nhsnmed_disp ,facwidein_reply->admin_date[facwide_admin_dt_cnt ].person[facwide_prsn_cnt ].meds[
     facwide_med_cnt ].nhsn_med_cd = medication_list->med_cds[facewidemed_pos ].nhsnmed_cd ,
     facwidein_reply->admin_date[facwide_admin_dt_cnt ].person[facwide_prsn_cnt ].meds[
     facwide_med_cnt ].nhsn_med_ind = medication_list->med_cds[facewidemed_pos ].nhsnmed_ind
    ENDIF
   HEAD mae.route_cd
    facewideroute_pos = 0
   DETAIL
    IF ((facewideroute_pos = 0 ) )
     FOR (facwideroute_index = 1 TO nhsn_route_size )
      route_size = size (route_list->nhsnroute_cds[facwideroute_index ].catroute_list ,5 ) ,
      facewideroute_pos = locateval (admin_route_cnt ,1 ,route_size ,mae.route_cd ,route_list->
       nhsnroute_cds[facwideroute_index ].catroute_list[admin_route_cnt ].catroute_cd ) ,
      IF ((facewideroute_pos > 0 ) ) facewide_route_size = size (facwidein_reply->admin_date[
        facwide_admin_dt_cnt ].person[facwide_prsn_cnt ].meds[facwide_med_cnt ].routes ,5 ) ,
       IF ((locateval (facwide_exst_route_cnt ,1 ,facewide_route_size ,route_list->nhsnroute_cds[
        facwideroute_index ].nhsnroute_cd ,facwidein_reply->admin_date[facwide_admin_dt_cnt ].person[
        facwide_prsn_cnt ].meds[facwide_med_cnt ].routes[facwide_exst_route_cnt ].nhsn_route_cd ) =
       0 ) ) facwide_route_cnt = (facwide_route_cnt + 1 ) ,
        IF ((mod (facwide_route_cnt ,10 ) = 1 ) ) stat = alterlist (facwidein_reply->admin_date[
          facwide_admin_dt_cnt ].person[facwide_prsn_cnt ].meds[facwide_med_cnt ].routes ,(
          facwide_route_cnt + 9 ) )
        ENDIF
        ,facwidein_reply->admin_date[facwide_admin_dt_cnt ].person[facwide_prsn_cnt ].meds[
        facwide_med_cnt ].routes[facwide_route_cnt ].route_disp = route_list->nhsnroute_cds[
        facwideroute_index ].nhsnroute_disp ,facwidein_reply->admin_date[facwide_admin_dt_cnt ].
        person[facwide_prsn_cnt ].meds[facwide_med_cnt ].routes[facwide_route_cnt ].routes_count = 1
       ,facwidein_reply->admin_date[facwide_admin_dt_cnt ].person[facwide_prsn_cnt ].meds[
        facwide_med_cnt ].routes[facwide_route_cnt ].nhsn_route_cd = route_list->nhsnroute_cds[
        facwideroute_index ].nhsnroute_cd ,facwidein_reply->admin_date[facwide_admin_dt_cnt ].person[
        facwide_prsn_cnt ].meds[facwide_med_cnt ].routes[facwide_route_cnt ].temp_route_cd = mae
        .route_cd ,facwideroute_index = (nhsn_route_size + 1 )
       ELSE facwideroute_index = (nhsn_route_size + 1 )
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   FOOT  mae.route_cd
    donothing = 0
   FOOT  mae.catalog_cd
    stat = alterlist (facwidein_reply->admin_date[facwide_admin_dt_cnt ].person[facwide_prsn_cnt ].
     meds[facwide_med_cnt ].routes ,facwide_route_cnt )
   FOOT  ce.person_id
    stat = alterlist (facwidein_reply->admin_date[facwide_admin_dt_cnt ].person[facwide_prsn_cnt ].
     meds ,facwide_med_cnt )
   FOOT  admin_date
    stat = alterlist (facwidein_reply->admin_date[facwide_admin_dt_cnt ].person ,facwide_prsn_cnt )
   FOOT REPORT
    stat = alterlist (facwidein_reply->admin_date ,facwide_admin_dt_cnt )
   WITH nocounter ,expand = 1
  ;end select
  SET errorcode = error (errmsg ,0 )
  IF ((errorcode != 0 ) )
   CALL log_message (concat ("Subroutine getFacwideInadminEvents failed: " ,errmsg ) ,
    log_level_debug )
   GO TO exit_script
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echorecord (facwidein_reply )
  ENDIF
  CALL log_message (build ("End - Subroutine GetFacwideInadminEvents. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
  IF ((size (facwidein_reply->admin_date ,5 ) > 0 ) )
   CALL fillfacwideinreply (null )
  ENDIF
 END ;Subroutine
 SUBROUTINE  fillunitsreply (null )
  CALL log_message ("Begin - Subroutine FillUnitsReply" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  DECLARE month_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE unit_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE agent_cnt = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   admin_month = datetimepart (cnvtdatetime (temp_reply->admin_date[d1.seq ].admin_dt_tm ) ,2 ) ,
   admin_date = cnvtdatetime (cnvtdate (temp_reply->admin_date[d1.seq ].admin_dt_tm ) ,0 ) ,
   admin_unit = temp_reply->admin_date[d1.seq ].units[d2.seq ].unit_cds ,
   admin_person = temp_reply->admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].person_id ,
   admin_med = temp_reply->admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].meds[d4.seq ].
   nhsn_med_cd ,
   admin_route = temp_reply->admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].meds[d4.seq ].routes[
   d5.seq ].nhsn_route_cd
   FROM (dummyt d1 WITH seq = value (size (temp_reply->admin_date ,5 ) ) ),
    (dummyt d2 WITH seq = 1 ),
    (dummyt d3 WITH seq = 1 ),
    (dummyt d4 WITH seq = 1 ),
    (dummyt d5 WITH seq = 1 )
   PLAN (d1
    WHERE maxrec (d2 ,size (temp_reply->admin_date[d1.seq ].units ,5 ) ) )
    JOIN (d2
    WHERE maxrec (d3 ,size (temp_reply->admin_date[d1.seq ].units[d2.seq ].person ,5 ) ) )
    JOIN (d3
    WHERE maxrec (d4 ,size (temp_reply->admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].meds ,5 )
     ) )
    JOIN (d4
    WHERE maxrec (d5 ,size (temp_reply->admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].meds[d4
      .seq ].routes ,5 ) ) )
    JOIN (d5 )
   ORDER BY admin_month ,
    admin_unit ,
    admin_med ,
    admin_person ,
    admin_date ,
    admin_route
   HEAD REPORT
    month_cnt = 0
   HEAD admin_month
    unit_cnt = 0 ,month_cnt = (month_cnt + 1 ) ,
    IF ((mod (month_cnt ,10 ) = 1 ) ) stat = alterlist (reply->months ,(month_cnt + 9 ) )
    ENDIF
    ,reply->months[month_cnt ].month_year = build2 (trim (format (cnvtdatetime (temp_reply->
        admin_date[d1.seq ].admin_dt_tm ) ,"MMMMMMMMM;;d" ) ,3 ) ," " ,cnvtstring (datetimepart (
       cnvtdatetime (temp_reply->admin_date[d1.seq ].admin_dt_tm ) ,1 ) ,4 ) ) ,reply->months[
    month_cnt ].month_dt_tm = cnvtdatetime (temp_reply->admin_date[d1.seq ].admin_dt_tm )
   HEAD admin_unit
    agent_cnt = 0 ,unit_cnt = (unit_cnt + 1 ) ,
    IF ((mod (unit_cnt ,10 ) = 1 ) ) stat = alterlist (reply->months[month_cnt ].locations ,(
      unit_cnt + 9 ) )
    ENDIF
    ,reply->months[month_cnt ].locations[unit_cnt ].location_name = temp_reply->admin_date[d1.seq ].
    units[d2.seq ].unit_disp ,reply->months[month_cnt ].locations[unit_cnt ].location_cd = temp_reply
    ->admin_date[d1.seq ].units[d2.seq ].unit_cds
   HEAD admin_med
    agent_cnt = (agent_cnt + 1 ) ,
    IF ((mod (agent_cnt ,100 ) = 1 ) ) stat = alterlist (reply->months[month_cnt ].locations[
      unit_cnt ].agents ,(agent_cnt + 99 ) )
    ENDIF
    ,reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].agent_name = temp_reply->
    admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].meds[d4.seq ].med_disp ,reply->months[
    month_cnt ].locations[unit_cnt ].agents[agent_cnt ].agent_cd = temp_reply->admin_date[d1.seq ].
    units[d2.seq ].person[d3.seq ].meds[d4.seq ].nhsn_med_cd ,reply->months[month_cnt ].locations[
    unit_cnt ].agents[agent_cnt ].nhsn_med_ind = temp_reply->admin_date[d1.seq ].units[d2.seq ].
    person[d3.seq ].meds[d4.seq ].nhsn_med_ind
   HEAD admin_person
    donothing = 0
   HEAD admin_date
    setroute = 0 ,stop_iv_cnt_ind = false ,stop_respiratory_cnt_ind = false ,stop_digest_cnt_ind =
    false ,stop_im_cnt_ind = false
   HEAD admin_route
    donothing = 0
   DETAIL
    CASE (temp_reply->admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].meds[d4.seq ].routes[d5.seq
    ].route_disp )
     OF iv_route :
      IF ((stop_iv_cnt_ind = 0 ) ) reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].
       iv = (reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].iv + 1 ) ,
       stop_iv_cnt_ind = true
      ENDIF
      ,
      setroute = increment_total
     OF respiratory_route :
      IF ((stop_respiratory_cnt_ind = 0 ) ) reply->months[month_cnt ].locations[unit_cnt ].agents[
       agent_cnt ].respiratory = (reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].
       respiratory + 1 ) ,stop_respiratory_cnt_ind = true
      ENDIF
      ,
      setroute = increment_total
     OF digest_route :
      IF ((stop_digest_cnt_ind = 0 ) ) reply->months[month_cnt ].locations[unit_cnt ].agents[
       agent_cnt ].digestive = (reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].
       digestive + 1 ) ,stop_digest_cnt_ind = true
      ENDIF
      ,
      setroute = increment_total
     OF im_route :
      IF ((stop_im_cnt_ind = 0 ) ) reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].
       im = (reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].im + 1 ) ,
       stop_im_cnt_ind = true
      ENDIF
      ,
      setroute = increment_total
    ENDCASE
   FOOT  admin_route
    donothing = 0
   FOOT  admin_date
    IF ((setroute > 0 ) ) reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].total = (
     reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].total + 1 )
    ENDIF
   FOOT  admin_person
    donothing = 0
   FOOT  admin_med
    donothing = 0
   FOOT  admin_unit
    stat = alterlist (reply->months[month_cnt ].locations[unit_cnt ].agents ,agent_cnt )
   FOOT  admin_month
    stat = alterlist (reply->months[month_cnt ].locations ,unit_cnt )
   FOOT REPORT
    stat = alterlist (reply->months ,month_cnt )
   WITH nocounter
  ;end select
  SET errorcode = error (errmsg ,0 )
  IF ((errorcode != 0 ) )
   CALL log_message (concat ("Subroutine FillUnitsReply failed: " ,errmsg ) ,log_level_debug )
   GO TO exit_script
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echorecord (reply )
  ENDIF
  CALL log_message (build ("End - Subroutine FillUnitsReply. Elapsed time in seconds:" ,datetimediff
    (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  fillfacwideinreply (null )
  CALL log_message ("Begin - Subroutine FillFacWideInReply" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  DECLARE facwide_month_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE facwide_agent_cnt = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   admin_month = datetimepart (cnvtdatetime (facwidein_reply->admin_date[d1.seq ].admin_dt_tm ) ,2 )
   ,admin_med = facwidein_reply->admin_date[d1.seq ].person[d2.seq ].meds[d3.seq ].nhsn_med_cd ,
   admin_route = facwidein_reply->admin_date[d1.seq ].person[d2.seq ].meds[d3.seq ].routes[d4.seq ].
   nhsn_route_cd ,
   admin_person = facwidein_reply->admin_date[d1.seq ].person[d2.seq ].person_id ,
   admin_date = cnvtdatetime (cnvtdate (facwidein_reply->admin_date[d1.seq ].admin_dt_tm ) ,0 )
   FROM (dummyt d1 WITH seq = value (size (facwidein_reply->admin_date ,5 ) ) ),
    (dummyt d2 WITH seq = 1 ),
    (dummyt d3 WITH seq = 1 ),
    (dummyt d4 WITH seq = 1 )
   PLAN (d1
    WHERE maxrec (d2 ,size (facwidein_reply->admin_date[d1.seq ].person ,5 ) ) )
    JOIN (d2
    WHERE maxrec (d3 ,size (facwidein_reply->admin_date[d1.seq ].person[d2.seq ].meds ,5 ) ) )
    JOIN (d3
    WHERE maxrec (d4 ,size (facwidein_reply->admin_date[d1.seq ].person[d2.seq ].meds[d3.seq ].routes
       ,5 ) ) )
    JOIN (d4 )
   ORDER BY admin_month ,
    admin_med ,
    admin_person ,
    admin_date ,
    admin_route
   HEAD REPORT
    facwide_month_cnt = 0
   HEAD admin_month
    facwide_agent_cnt = 0 ,facwide_month_cnt = (facwide_month_cnt + 1 ) ,
    IF ((mod (facwide_month_cnt ,10 ) = 1 ) ) stat = alterlist (reply->months ,(facwide_month_cnt +
      9 ) )
    ENDIF
    ,stat = alterlist (reply->months[facwide_month_cnt ].locations ,1 ) ,reply->months[
    facwide_month_cnt ].locations[1 ].location_name = "FACWIDEIN" ,reply->months[facwide_month_cnt ].
    month_year = build2 (trim (format (cnvtdatetime (facwidein_reply->admin_date[d1.seq ].admin_dt_tm
         ) ,"MMMMMMMMM;;d" ) ,3 ) ," " ,cnvtstring (datetimepart (cnvtdatetime (facwidein_reply->
        admin_date[d1.seq ].admin_dt_tm ) ,1 ) ,4 ) ) ,reply->months[facwide_month_cnt ].month_dt_tm
    = cnvtdatetime (facwidein_reply->admin_date[d1.seq ].admin_dt_tm )
   HEAD admin_med
    facwide_agent_cnt = (facwide_agent_cnt + 1 ) ,
    IF ((mod (facwide_agent_cnt ,90 ) = 1 ) ) stat = alterlist (reply->months[facwide_month_cnt ].
      locations[1 ].agents ,(facwide_agent_cnt + 89 ) )
    ENDIF
    ,reply->months[facwide_month_cnt ].locations[1 ].agents[facwide_agent_cnt ].agent_name =
    facwidein_reply->admin_date[d1.seq ].person[d2.seq ].meds[d3.seq ].med_disp ,reply->months[
    facwide_month_cnt ].locations[1 ].agents[facwide_agent_cnt ].agent_cd = facwidein_reply->
    admin_date[d1.seq ].person[d2.seq ].meds[d3.seq ].nhsn_med_cd ,reply->months[facwide_month_cnt ].
    locations[1 ].agents[facwide_agent_cnt ].nhsn_med_ind = facwidein_reply->admin_date[d1.seq ].
    person[d2.seq ].meds[d3.seq ].nhsn_med_ind
   HEAD admin_person
    donothing = 0
   HEAD admin_date
    setroute = 0 ,stop_iv_cnt_ind = false ,stop_respiratory_cnt_ind = false ,stop_digest_cnt_ind =
    false ,stop_im_cnt_ind = false
   HEAD admin_route
    donothing = 0
   DETAIL
    CASE (facwidein_reply->admin_date[d1.seq ].person[d2.seq ].meds[d3.seq ].routes[d4.seq ].
    route_disp )
     OF iv_route :
      setroute = increment_total ,
      IF ((stop_iv_cnt_ind = 0 ) ) reply->months[facwide_month_cnt ].locations[1 ].agents[
       facwide_agent_cnt ].iv = (reply->months[facwide_month_cnt ].locations[1 ].agents[
       facwide_agent_cnt ].iv + 1 ) ,stop_iv_cnt_ind = true
      ENDIF
     OF respiratory_route :
      setroute = increment_total ,
      IF ((stop_respiratory_cnt_ind = 0 ) ) reply->months[facwide_month_cnt ].locations[1 ].agents[
       facwide_agent_cnt ].respiratory = (reply->months[facwide_month_cnt ].locations[1 ].agents[
       facwide_agent_cnt ].respiratory + 1 ) ,stop_respiratory_cnt_ind = true
      ENDIF
     OF digest_route :
      setroute = increment_total ,
      IF ((stop_digest_cnt_ind = 0 ) ) reply->months[facwide_month_cnt ].locations[1 ].agents[
       facwide_agent_cnt ].digestive = (reply->months[facwide_month_cnt ].locations[1 ].agents[
       facwide_agent_cnt ].digestive + 1 ) ,stop_digest_cnt_ind = true
      ENDIF
     OF im_route :
      setroute = increment_total ,
      IF ((stop_im_cnt_ind = 0 ) ) reply->months[facwide_month_cnt ].locations[1 ].agents[
       facwide_agent_cnt ].im = (reply->months[facwide_month_cnt ].locations[1 ].agents[
       facwide_agent_cnt ].im + 1 ) ,stop_im_cnt_ind = true
      ENDIF
    ENDCASE
   FOOT  admin_route
    donothing = 0
   FOOT  admin_date
    IF ((setroute > 0 ) ) reply->months[facwide_month_cnt ].locations[1 ].agents[facwide_agent_cnt ].
     total = (reply->months[facwide_month_cnt ].locations[1 ].agents[facwide_agent_cnt ].total + 1 )
    ENDIF
   FOOT  admin_person
    donothing = 0
   FOOT  admin_med
    donothing = 0
   FOOT  admin_month
    stat = alterlist (reply->months[facwide_month_cnt ].locations[1 ].agents ,facwide_agent_cnt )
   FOOT REPORT
    stat = alterlist (reply->months ,facwide_month_cnt )
   WITH nocounter
  ;end select
  SET errorcode = error (errmsg ,0 )
  IF ((errorcode != 0 ) )
   CALL log_message (concat ("Subroutine FillFacWideInReply failed: " ,errmsg ) ,log_level_debug )
   GO TO exit_script
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echorecord (reply )
  ENDIF
  CALL log_message (build ("End - Subroutine FillFacWideInReply. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  notapplicablemedsreply (null )
  CALL log_message ("Begin - Subroutine NotapplicableMedsReply" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  DECLARE na_month = i4 WITH noconstant (0 )
  DECLARE na_loc = i4 WITH noconstant (0 )
  DECLARE agent_cnt = i4 WITH noconstant (0 )
  DECLARE na_index = i4 WITH noconstant (0 )
  DECLARE med_pos = i4 WITH noconstant (0 )
  DECLARE agent_idx = i4 WITH noconstant (0 )
  DECLARE idx = i4 WITH noconstant (0 )
  DECLARE temp_agent_idx = i4 WITH noconstant (0 )
  DECLARE unique_agent_cnt = i4 WITH noconstant (0 )
  DECLARE is_reply_empty = i2 WITH noconstant (1 )
  FOR (na_month = 1 TO size (reply->months ,5 ) )
   FOR (na_loc = 1 TO size (reply->months[na_month ].locations ,5 ) )
    IF ((size (reply->months[na_month ].locations[na_loc ].agents ,5 ) > 0 ) )
     call echo("starting moverec")
     SET stat = alterlist (temp_agent_counts->agents ,size (reply->months[na_month ].locations[na_loc ].agents ,5 ) )
     call echo("past step 1")
     call echorecord(reply)
     SET stat = movereclist (reply->months[na_month ].locations[na_loc ].agents
 
     	,temp_agent_counts->agents ,1 ,1 ,size (reply->months[na_month ].locations[na_loc ].agents ,5 ) ,false )
     call echo("past step 2")
     SET stat = alterlist (reply->months[na_month ].locations[na_loc ].agents ,0 )
     call echo("past step 3")
     SET unique_agent_cnt = 0
     FOR (agent_idx = 1 TO medication_list->med_cnt )
      IF ((locateval (idx ,1 ,size (reply->months[na_month ].locations[na_loc ].agents ,5 ) ,
       medication_list->med_cds[agent_idx ].nhsnmed_cd ,reply->months[na_month ].locations[na_loc ].
       agents[idx ].agent_cd ) = 0 ) )
       SET unique_agent_cnt = (unique_agent_cnt + 1 )
       IF ((mod (unique_agent_cnt ,10 ) = 1 ) )
        SET stat = alterlist (reply->months[na_month ].locations[na_loc ].agents ,(unique_agent_cnt
         + 9 ) )
       ENDIF
       SET reply->months[na_month ].locations[na_loc ].agents[unique_agent_cnt ].agent_name =
       medication_list->med_cds[agent_idx ].nhsnmed_disp
       SET reply->months[na_month ].locations[na_loc ].agents[unique_agent_cnt ].agent_cd =
       medication_list->med_cds[agent_idx ].nhsnmed_cd
       SET reply->months[na_month ].locations[na_loc ].agents[unique_agent_cnt ].nhsn_med_ind =
       medication_list->med_cds[agent_idx ].nhsnmed_ind
       SET reply->months[na_month ].locations[na_loc ].agents[unique_agent_cnt ].total = 0
       SET reply->months[na_month ].locations[na_loc ].agents[unique_agent_cnt ].iv = 0
       SET reply->months[na_month ].locations[na_loc ].agents[unique_agent_cnt ].im = 0
       SET reply->months[na_month ].locations[na_loc ].agents[unique_agent_cnt ].respiratory = 0
       SET reply->months[na_month ].locations[na_loc ].agents[unique_agent_cnt ].digestive = 0
       IF ((medication_list->med_cds[agent_idx ].not_applicable = 1 ) )
        SET reply->months[na_month ].locations[na_loc ].agents[unique_agent_cnt ].not_available_flag
        = not_available
       ELSE
        SET reply->months[na_month ].locations[na_loc ].agents[unique_agent_cnt ].not_available_flag
        = 0
       ENDIF
      ENDIF
     ENDFOR
     SET stat = alterlist (reply->months[na_month ].locations[na_loc ].agents ,unique_agent_cnt )
     FOR (agent_idx = 1 TO size (temp_agent_counts->agents ,5 ) )
      SET agent_size = size (reply->months[na_month ].locations[na_loc ].agents ,5 )
      SET temp_agent_idx = locateval (idx ,1 ,agent_size ,temp_agent_counts->agents[agent_idx ].
       agent_cd ,reply->months[na_month ].locations[na_loc ].agents[idx ].agent_cd )
      SET reply->months[na_month ].locations[na_loc ].agents[temp_agent_idx ].total =
      temp_agent_counts->agents[agent_idx ].total
      SET reply->months[na_month ].locations[na_loc ].agents[temp_agent_idx ].iv = temp_agent_counts
      ->agents[agent_idx ].iv
      SET reply->months[na_month ].locations[na_loc ].agents[temp_agent_idx ].im = temp_agent_counts
      ->agents[agent_idx ].im
      SET reply->months[na_month ].locations[na_loc ].agents[temp_agent_idx ].digestive =
      temp_agent_counts->agents[agent_idx ].digestive
      SET reply->months[na_month ].locations[na_loc ].agents[temp_agent_idx ].respiratory =
      temp_agent_counts->agents[agent_idx ].respiratory
     ENDFOR
     IF (((( $OUTPUT = 0 ) ) OR (( $OUTPUT = 1 ) )) )
      SET num_agents = size (reply->months[na_month ].locations[na_loc ].agents ,5 )
      SET stat = alterlist (temp_agent_counts->agents ,num_agents )
      SET stat = movereclist (reply->months[na_month ].locations[na_loc ].agents ,temp_agent_counts->
       agents ,1 ,1 ,num_agents ,false )
      SELECT INTO "nl:"
       agent_name = substring (1 ,60 ,temp_agent_counts->agents[d1.seq ].agent_name ) ,
       agent_cd = temp_agent_counts->agents[d1.seq ].agent_cd ,
       not_available_flag = temp_agent_counts->agents[d1.seq ].not_available_flag ,
       total = temp_agent_counts->agents[d1.seq ].total ,
       iv = temp_agent_counts->agents[d1.seq ].iv ,
       im = temp_agent_counts->agents[d1.seq ].im ,
       digestive = temp_agent_counts->agents[d1.seq ].digestive ,
       respiratory = temp_agent_counts->agents[d1.seq ].respiratory ,
       nhsn_med_ind = temp_agent_counts->agents[d1.seq ].nhsn_med_ind
       FROM (dummyt d1 WITH seq = num_agents )
       PLAN (d1
        WHERE (temp_agent_counts->agents[d1.seq ].not_available_flag = 0 ) )
       HEAD REPORT
        agent_idx = 0 ,
        is_reply_empty = 0
       DETAIL
        agent_idx = (agent_idx + 1 ) ,
        reply->months[na_month ].locations[na_loc ].agents[agent_idx ].agent_name = agent_name ,
        reply->months[na_month ].locations[na_loc ].agents[agent_idx ].agent_cd = agent_cd ,
        reply->months[na_month ].locations[na_loc ].agents[agent_idx ].not_available_flag =
        not_available_flag ,
        reply->months[na_month ].locations[na_loc ].agents[agent_idx ].total = total ,
        reply->months[na_month ].locations[na_loc ].agents[agent_idx ].iv = iv ,
        reply->months[na_month ].locations[na_loc ].agents[agent_idx ].im = im ,
        reply->months[na_month ].locations[na_loc ].agents[agent_idx ].digestive = digestive ,
        reply->months[na_month ].locations[na_loc ].agents[agent_idx ].respiratory = respiratory ,
        reply->months[na_month ].locations[na_loc ].agents[agent_idx ].nhsn_med_ind = nhsn_med_ind
       FOOT REPORT
        stat = alterlist (reply->months[na_month ].locations[na_loc ].agents ,agent_idx )
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDFOR
  ENDFOR
  IF ((is_reply_empty = 1 )
  AND ( $OUTPUT != 2 ) )
   SET reply->empty_reply_ind = true
   SET stat = alterlist (reply->months ,0 )
   SET stat = alterlist (reply->months ,1 )
   SET stat = alterlist (reply->months[1 ].locations ,1 )
   SET stat = alterlist (reply->months[1 ].locations[1 ].agents ,1 )
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echorecord (reply )
  ENDIF
  CALL log_message (build ("End - Subroutine NotapplicableMedsReply. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  populatedenomdata (null )
  CALL log_message ("Begin - Subroutine PopulateDenomData" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  EXECUTE lhc_ic_get_denom_data_rr WITH replace ("REQUEST" ,denom_req ) ,
  replace ("REPLY" ,denom_reply )
  SET denom_req->from_dt_tm = cnvtdatetime ( $FROMDATE )
  SET denom_req->to_dt_tm = cnvtdatetime ( $THRUDATE )
  SET denom_req->facility_cd =  $FACILITY
  IF (((( $FACWIDE = "0" ) ) OR (( $FACWIDE = "" ) )) )
   SET denom_req->rpt_type_flag = not_facwidein
  ELSE
   SET denom_req->rpt_type_flag = facwidein
  ENDIF
  SET stat = alterlist (denom_req->units ,loc_list->loc_cnt )
  FOR (loccnt = 1 TO loc_list->loc_cnt )
   SET denom_req->units[loccnt ].loc_nurse_unit_cd = loc_list->location[loccnt ].loc_cd
  ENDFOR
  ;EXECUTE lhc_ic_get_denom_data WITH replace ("REQUEST" ,denom_req ) ,
 ; EXECUTE cov_ic_get_denom_data WITH replace ("REQUEST" ,denom_req ) ,
  EXECUTE 2cov_ic_get_denom_data WITH replace ("REQUEST" ,denom_req ) ,replace ("REPLY" ,denom_reply )
  IF ((denom_reply->status_data.status = "S" ) )
   SELECT INTO "nl:"
    FROM (dummyt d1 WITH seq = value (size (denom_reply->months ,5 ) ) ),
     (dummyt d2 WITH seq = 1 )
    PLAN (d1
     WHERE maxrec (d2 ,size (denom_reply->months[d1.seq ].locations ,5 ) ) )
     JOIN (d2 )
    ORDER BY d1.seq ,
     d2.seq
    HEAD REPORT
     month_pos = 0 ,
     month_idx = 0 ,
     mon_denom_cnt = 0 ,
     loc_idx = 0
    HEAD d1.seq
     loc_pos = 0 ,month_pos = locateval (month_idx ,1 ,value (size (reply->months ,5 ) ) ,denom_reply
      ->months[d1.seq ].month_name ,reply->months[month_idx ].month_year ) ,
     IF ((month_pos <= 0 ) ) mon_denom_cnt = (size (reply->months ,5 ) + 1 ) ,stat = alterlist (reply
       ->months ,mon_denom_cnt ) ,reply->months[mon_denom_cnt ].month_year = denom_reply->months[d1
      .seq ].month_name ,reply->months[mon_denom_cnt ].month_dt_tm = cnvtdatetime (build2 ("01 " ,
        denom_reply->months[d1.seq ].month_name ," 00:00:00" ) ) ,month_pos = mon_denom_cnt
     ENDIF
    HEAD d2.seq
     loc_pos = locateval (loc_idx ,1 ,size (reply->months[month_pos ].locations ,5 ) ,denom_reply->
      months[d1.seq ].locations[d2.seq ].loc_nurse_unit_cd ,reply->months[month_pos ].locations[
      loc_idx ].location_cd ) ,
     IF ((loc_pos > 0 ) )
      IF ((denom_reply->rpt_type_flag = not_facwidein ) ) reply->months[month_pos ].locations[
       loc_pos ].days_present = denom_reply->months[d1.seq ].locations[d2.seq ].days_present
      ELSE reply->months[month_pos ].locations[1 ].days_present = denom_reply->months[d1.seq ].
       locations[d2.seq ].days_present ,reply->months[month_pos ].locations[1 ].admissions =
       denom_reply->months[d1.seq ].locations[d2.seq ].admissions
      ENDIF
     ELSE
      IF ((denom_reply->rpt_type_flag = not_facwidein ) ) loc_denom_cnt = (size (reply->months[
        month_pos ].locations ,5 ) + 1 ) ,stat = alterlist (reply->months[month_pos ].locations ,
        loc_denom_cnt ) ,reply->months[month_pos ].locations[loc_denom_cnt ].location_name =
       uar_get_code_display (denom_reply->months[d1.seq ].locations[d2.seq ].loc_nurse_unit_cd ) ,
       reply->months[month_pos ].locations[loc_denom_cnt ].location_cd = denom_reply->months[d1.seq ]
       .locations[d2.seq ].loc_nurse_unit_cd ,reply->months[month_pos ].locations[loc_denom_cnt ].
       days_present = denom_reply->months[d1.seq ].locations[d2.seq ].days_present ,stat = alterlist
       (reply->months[month_pos ].locations[loc_denom_cnt ].agents ,1 )
      ELSE stat = alterlist (reply->months[month_pos ].locations ,1 ) ,reply->months[month_pos ].
       locations[1 ].location_name = "FACWIDEIN" ,reply->months[month_pos ].locations[1 ].
       days_present = denom_reply->months[d1.seq ].locations[d2.seq ].days_present ,reply->months[
       month_pos ].locations[1 ].admissions = denom_reply->months[d1.seq ].locations[d2.seq ].
       admissions ,stat = alterlist (reply->months[month_pos ].locations[loc_denom_cnt ].agents ,1 )
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   CALL log_message (concat ("Subroutine PopulateDenomData failed: " ,errmsg ) ,log_level_debug )
   GO TO exit_script
  ENDIF
  CALL log_message (build ("End - Subroutine PopulateDenomData. Elapsed time in seconds:" ,
    datetimediff (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  generatefullxml (null )
  DECLARE xml_string = vc WITH noconstant ("" ) ,protect
  DECLARE month_start = dq8 WITH noconstant (0 ) ,protect
  DECLARE month_end = dq8 WITH noconstant (0 ) ,protect
  DECLARE rx_norm = vc WITH noconstant ("" ) ,protect
  DECLARE cdc_location_cd = f8 WITH noconstant (0 ) ,protect
  DECLARE nhsn_your_code = vc WITH noconstant ("" ) ,protect
  DECLARE month_idx = i4 WITH noconstant (0 ) ,protect
  DECLARE loc_idx = i4 WITH noconstant (0 ) ,protect
  DECLARE med_idx = i4 WITH noconstant (0 ) ,protect
  DECLARE loclist_idx = i4 WITH noconstant (0 ) ,protect
  DECLARE idx = i4 WITH noconstant (0 ) ,protect
  FOR (month_idx = 1 TO size (reply->months ,5 ) )
   IF ((datetimepart (reply->from_date ,2 ) = datetimepart (reply->months[month_idx ].month_dt_tm ,2) )
   AND (datetimepart (reply->from_date ,1 ) = datetimepart (reply->months[month_idx ].month_dt_tm ,1) ) )
    SET month_start = reply->from_date
   ELSE
    SET month_start = datetimefind (reply->months[month_idx ].month_dt_tm ,"M" ,"B" ,"B" )
   ENDIF
   IF ((datetimepart (reply->to_date ,2 ) = datetimepart (reply->months[month_idx ].month_dt_tm ,2 )  )
   AND (datetimepart (reply->to_date ,1 ) = datetimepart (reply->months[month_idx ].month_dt_tm ,1 )) )
    SET month_end = reply->to_date
   ELSE
    SET month_end = datetimefind (reply->months[month_idx ].month_dt_tm ,"M" ,"E" ,"E" )
   ENDIF
   FOR (loc_idx = 1 TO size (reply->months[month_idx ].locations ,5 ) )
    SET loclist_idx = locateval (idx ,1 ,value (size (loc_list->location ,5 ) )
    	,reply->months[month_idx ].locations[loc_idx ].location_cd ,loc_list->location[idx ].loc_cd )
 
    SET cdc_location_cd = loc_list->location[loclist_idx ].cdc_cd
 
    SET nhsn_your_code = loc_list->location[loclist_idx ].nhsn_your_code
 
 
    CALL log_message ("--createheaderxml(" ,log_level_debug )
    CALL log_message (build2("--reply->rpt_type_flag=",reply->rpt_type_flag) ,log_level_debug )
    CALL log_message (build2("--reply->facility_oid=",reply->facility_oid) ,log_level_debug )
    CALL log_message (build2("--month_start=",month_start) ,log_level_debug )
    CALL log_message (build2("--month_end=",month_end) ,log_level_debug )
    CALL log_message (build2("--cdc_location_cd=",cdc_location_cd) ,log_level_debug )
    CALL log_message (build2("--nhsn_your_code=",nhsn_your_code) ,log_level_debug )
    CALL log_message (build2("--reply->months[month_idx ].locations[loc_idx ].days_present="
    	,reply->months[month_idx ].locations[loc_idx ].days_present) ,log_level_debug )
    CALL log_message (build2("--reply->months[month_idx ].locations[loc_idx ].admissions="
    	,reply->months[month_idx ].locations[loc_idx ].admissions) ,log_level_debug )
 
 	IF ($ADMISSIONS > 0)
 		set reply->months[month_idx ].locations[loc_idx ].admissions = $ADMISSIONS
 	ENDIF
    SET xml_string = createheaderxml (
    									reply->rpt_type_flag
    									,reply->facility_oid
    									,month_start
    									,month_end
    									,cdc_location_cd
    									,nhsn_your_code
    									,reply->months[month_idx ].locations[loc_idx ].days_present
    									,reply->months[month_idx ].locations[loc_idx ].admissions )
 
    FOR (med_idx = 1 TO size (reply->months[month_idx ].locations[loc_idx ].agents ,5 ) )
     IF ((reply->months[month_idx ].locations[loc_idx ].agents[med_idx ].nhsn_med_ind = true ) )
      SET rx_norm = uar_get_code_display (reply->months[month_idx ].locations[loc_idx ].agents[med_idx ].agent_cd )
      SET xml_string = build (
      							xml_string
      							,createsinglemedxml (	 reply->rpt_type_flag
      													,reply->months[month_idx ].locations[loc_idx ].agents[med_idx ].not_available_flag
      													,cdc_location_cd
      													,nhsn_your_code
      													,reply->months[month_idx ].locations[loc_idx ].agents[med_idx ].agent_name
      													,rx_norm
      													,reply->months[month_idx ].locations[loc_idx ].agents[med_idx ].total
      													,reply->months[month_idx ].locations[loc_idx ].agents[med_idx ].respiratory
      													,reply->months[month_idx ].locations[loc_idx ].agents[med_idx ].digestive
      													,reply->months[month_idx ].locations[loc_idx ].agents[med_idx ].iv
      													,reply->months[month_idx ].locations[loc_idx ].agents[med_idx ].im ) )
     ENDIF
    ENDFOR
    SET xml_string = build (xml_string ,createfooterxml (null ) )
    SET reply->months[month_idx ].locations[loc_idx ].xml_string = xml_string
   ENDFOR
  ENDFOR
 END ;Subroutine
 
 SUBROUTINE  createheaderxml (rpt_type_flag ,fac_oid ,month_start ,month_end ,cdc_loc_cd ,
  nhsn_your_code ,days_present ,admissions )
  DECLARE start_date = vc WITH constant (trim (format (month_start ,"YYYYMMDD ;;D" ) ,3 ) ) ,protect
  DECLARE end_date = vc WITH constant (trim (format (month_end ,"YYYYMMDD ;;D" ) ,3 ) ) ,protect
  DECLARE cur_date = vc WITH constant (trim (format (execute_start_time ,"YYYYMMDD ;;D" ) ,3 ) ) ,
  protect
  DECLARE hl7_code = vc WITH constant (uar_get_code_display (cdc_loc_cd ) ) ,protect
  DECLARE nhsn_loc_name = vc WITH constant (uar_get_code_description (cdc_loc_cd ) ) ,protect
  DECLARE days_present_msg = vc WITH constant ("Number of Patient-present Days" ) ,protect
  DECLARE header_xml_string = vc WITH noconstant ("" ) ,protect
  DECLARE sequence_num = vc WITH noconstant ("" ) ,protect
  DECLARE sequence_num2 = f8 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   next = seq (lh_seq ,nextval )
   FROM (dual )
   DETAIL
    sequence_num2 = next
    CALL log_message (build2 ("--next=" ,next ) ,log_level_debug )
   WITH format ,counter
 
   set sequence_num = cnvtstringchk(sequence_num2,20,0)
 
   CALL log_message (build2 ("--sequence_num2=" ,sequence_num2 ) ,log_level_debug )
   CALL log_message (build2 ("--sequence_num=" ,sequence_num ) ,log_level_debug )
 
  ;end select
  IF ((rpt_type_flag = facwidein ) )
   IF ((days_present > 99999 ) )
    SET days_present = 99999
   ENDIF
   IF ((admissions > 99999 ) )
    SET admissions = 99999
   ENDIF
  ELSE
   IF ((days_present > 10000 ) )
    SET days_present = 10000
   ENDIF
  ENDIF
 
SET header_xml_string = build (
		 ^<?xml version="1.0" encoding="UTF-8"?>^
		,^<?xml-stylesheet type="text/xsl" href="hai-display.xsl"?>^
		)
 
	CALL log_message (build2 ("--fac_oid=" ,fac_oid ) ,log_level_debug )
	CALL log_message (build2 ("--sequence_num=" ,sequence_num ) ,log_level_debug )
	CALL log_message (build2 ("--cdc_loc_cd=" ,cdc_loc_cd ) ,log_level_debug )
 
SET header_xml_string = build (
    header_xml_string
	,"<ClinicalDocument xmlns=",'"urn:hl7-org:v3"' ," xmlns:xsi=",'"http://www.w3.org/2001/XMLSchema-instance"',">"
	,"<realmCode code=" ,'"US"' ,"/>"
	,"<typeId root=" ,'"2.16.840.1.113883.1.3"' ," extension=" ,'"POCD_HD000040"' ,"/>"
	,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.4.25"' ,"/>"
	,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.4.28"' ,"/>"
	,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.44"' , "/>"
	,"<id root=" ,'"' ,fac_oid ,"." ,sequence_num ,"." ,cnvtstring (cdc_loc_cd ) ,'"' ," extension=" ,'"' ,sequence_num ,'"' ,"/>"
	,"<code codeSystem="
						,'"2.16.840.1.113883.6.1"'
						," codeSystemName="
						,'"LOINC"'
						," code="
						,'"51897-7"'
						," displayName="
						,'"Healthcare Associated Infection Report"' ,"/>"
	,"<title>Antimicrobial Use, Pharmacy Option (AUP) Summary Report</title>"
	,"<effectiveTime value=",'"' ,cur_date ,'"' ,"/>"
	,"<confidentialityCode codeSystem=" ,'"2.16.840.1.113883.5.25"' ," code=" ,'"N"' ,"/>"
	,"<languageCode code=" ,'"en-US"' ,"/>"
	,"<setId root=" ,'"' ,fac_oid ,"." , sequence_num ,"." ,cnvtstring (cdc_loc_cd ) ,'"' ," extension=" ,'"' ,sequence_num ,'"' ,"/>"
	,"<versionNumber value=" ,'"' ,sequence_num ,'"' ,"/>"
	,"<recordTarget>"
	,"<patientRole>"
		,"<id nullFlavor=" ,'"NA"' ,"/>"
	,"</patientRole>" ,"</recordTarget>"
 
	/*
	"<author>", "<time value=", ^"^, CUR_DATE, ^"^, "/>"
 
,"<assignedAuthor>", "<id root=", ^"2.16.840.1.114222.4.3.19.10"^, " extension="
 
, ^"AU_2020"^, "/>","<assignedAuthoringDevice>","<manufacturerModelName>"
 
, "Antimicrobial Use Report" ,"</manufacturerModelName>"
 
, "<softwareName>", "Antimicrobial Usage and Resistance 2020.08.01", "</softwareName>"
 
, "</assignedAuthoringDevice>", "<representedOrganization>", "<name>"
 
, "Cerner", "</name>", "</representedOrganization>"
 
, "</assignedAuthor>", " </author>"
*/
	,"<author>"
		,"<time value=" ,'"' ,cur_date ,'"' ,"/>"
		,"<assignedAuthor>"
			;,"<id root=" ,'"2.16.840.1.113883.3.117.1.1.5.2.1.1"' ," extension=" ,'"CERNER"' ,"/>"
			,"<id root=" ,'"2.16.840.1.114222.4.3.19.10"' ," extension=" ,'"AU_2020"' ,"/>"
			,"<assignedAuthoringDevice>","<manufacturerModelName>"
			, "Antimicrobial Use Report" ,"</manufacturerModelName>"
			, "<softwareName>", "Antimicrobial Usage and Resistance 2020.08.01", "</softwareName>"
			, "</assignedAuthoringDevice>", "<representedOrganization>", "<name>"
			, "Cerner", "</name>", "</representedOrganization>"
		,"</assignedAuthor>"
	," </author>"
	,"<custodian>"
		,"<assignedCustodian>"
		,"<representedCustodianOrganization>"
		,"<id root=" ,'"2.16.840.1.114222.4.3.2.11"' ,"/>"
		,"</representedCustodianOrganization>"
		,"</assignedCustodian>"
	,"</custodian>"
	,"<legalAuthenticator>"
	,"<time value=" ,'"' ,cur_date , '"' ,"/>"
	,"<signatureCode code=" ,'"S"' ,"/>"
	,"<assignedEntity>"
	,"<id root=" ,'"2.16.840.1.113883.3.117.1.1.5.1.1.2"' ," extension=" ,'"CERNER"' ,"/>"
	,"</assignedEntity>"
	,"</legalAuthenticator>"
	,"<participant typeCode=" ,'"SBJ"' ," contextControlCode=" ,'"OP"' ,">"
		,"<associatedEntity classCode=" ,'"PRS"' ,">"
			,"<code codeSystem=" ,'"2.16.840.1.113883.6.96"' ," code=" ,'"389109008"' ," displayName=" ,'"group"' ,"/>"
		,"</associatedEntity>"
	,"</participant>"
	,"<participant typeCode=" ,'"LOC"' ," contextControlCode=" ,'"OP"' ,">"
	,"<associatedEntity classCode=" ,'"SDLOC"' ,">"
	,"<id root=" ,'"' ,fac_oid ,'"' ,"/>"
	,"</associatedEntity>"
	,"</participant>"
	,"<documentationOf>"
	,"<serviceEvent classCode=" , '"CASE"' ,">"
		,"<code codeSystem="
			,'"2.16.840.1.113883.6.277"'
			," codeSystemName="
			,'"cdcNHSN"'
			," code="
			,'"1887-9"'
			," displayName="
			,'"Summary data reporting antimicrobial usage"' ,"/>"
		,"<effectiveTime>"
			,"<low value=" ,'"' ,start_date ,'"' ,"/>"
			,"<high value=" ,'"' ,end_date ,'"' , "/>"
		,"</effectiveTime>"
	,"</serviceEvent>"
	,"</documentationOf>"
	,"<relatedDocument typeCode=" , '"RPLC"' ,">"
	,"<parentDocument>"
	,"<id root=" ,'"' ,fac_oid ,"." ,sequence_num ,"." ,cnvtstring (cdc_loc_cd ) ,'"' ," extension=" ,'"' ,sequence_num ,'"' ,"/>"
	,"<setId root=" ,'"' ,fac_oid , "." ,sequence_num ,"." ,cnvtstring (cdc_loc_cd ) ,'"' ," extension=" ,'"' ,sequence_num ,'"' , "/>"
	,"<versionNumber value=" ,'"1"' ,"/>"
	,"</parentDocument>"
	,"</relatedDocument>"
	,"<component>"
	,"<structuredBody>"
	,"<component>"
	,"<section>"
	,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.4.26"' ,"/>"
	,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.5.51"' ,"/>"
	,"<code codeSystem=" ,'"2.16.840.1.113883.6.1"'
		," codeSystemName=" ,'"LOINC"'
		," code=" , '"51900-9"'
		," displayName="
		,'"Summary Section"' ,"/>"
	,"<title xmlns:cda=" ,'"urn:hl7-org:v3"' ," xmlns:voc=" ,'"http://www.lantanagroup.com/voc"' ,">"
	,"Summary Data</title>"
	,"<text> </text>"
   ,"<entry typeCode=" ,'"DRIV"' ,">"
   ,"<encounter classCode=" ,'"ENC"' ," moodCode=" ,'"EVN"' ,">"
   ,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.6.197"' ,"/>"
   ,"<participant typeCode=" ,'"LOC"' ,">"
   ,"<participantRole classCode=" ,'"SDLOC"' ,">" )
 
  IF ((rpt_type_flag = facwidein ) )
   SET header_xml_string = build (
	header_xml_string
	,"<id root=" ,'"' ,fac_oid ,'"' ," extension=" ,'"FACWIDEIN"' ,"/>"
	,"<code codeSystem=" ,'"2.16.840.1.113883.6.259"'
		," codeSystemName=" , '"HL7 Healthcare Service Location Code"'
		," code=" ,'"1250-0"'
		," displayName=" ,'"FACWIDEIN"' ,"/>"
	,"</participantRole>"
	,"</participant>"
	,"<entryRelationship typeCode=" ,'"COMP"' ,">" ,
    "<observation classCode=" ,'"OBS"' ," moodCode=" ,'"EVN"' ,">"
	,"<templateId root=" , '"2.16.840.1.113883.10.20.5.6.185"' ,"/>"
	,"<code codeSystem=" ,'"2.16.840.1.113883.6.277"'
		," codeSystemName=" ,'"cdcNHSN"'
		," code=" ,'"2525-4"'
		," displayName=" ,'"'
		,days_present_msg ,'"' ,"/>"
	,"<statusCode code=" ,'"completed"' ,"/>"
	,"<value xsi:type=" ,'"PQ"' ," unit=" ,'"d"'," value=" ,'"' ,days_present ,'"' ,"/>"
	,"</observation>"
	,"</entryRelationship>"
	,"<entryRelationship typeCode=" ,'"COMP"' ,">"
	,"<observation classCode=" ,'"OBS"' ," moodCode=" ,'"EVN"' ,">"
	,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.6.185"' ,"/>"
	,"<code codeSystem=" ,'"2.16.840.1.113883.6.277"'
		," codeSystemName=" ,'"cdcNHSN"'
		," code=" ,'"1862-2"'
		," displayName=" ,'"Number of admissions"' ,"/>"
	,"<statusCode code=" ,'"completed"' , "/>"
	,"<value xsi:type=" ,'"PQ"' ," unit=" ,'"d"' ," value=" ,'"' ,admissions ,'"' ,"/>"
	,"</observation>"
	,"</entryRelationship>"
	,"</encounter>"
	,"</entry>"
	)
  ELSE
   SET header_xml_string = build (
	header_xml_string
	,"<id root=" ,'"' ,fac_oid ,'"' ," extension=" ,'"' ,nhsn_your_code ,'"' ,"/>"
	,"<code codeSystem=" ,'"2.16.840.1.113883.6.259"'
		," codeSystemName=" ,'"HL7 Healthcare Service Location Code"'
		," code=" ,'"' ,hl7_code ,'"'
		," displayName=" ,'"' ,nhsn_loc_name ,'"' ,"/>"
	,"</participantRole>" ,"</participant>"
	,"<entryRelationship typeCode=" ,'"COMP"' ,">"
	,"<observation classCode=" ,'"OBS"' ," moodCode=" ,'"EVN"' ,">"
	,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.6.185"' ,"/>"
	,"<code codeSystem=" ,'"2.16.840.1.113883.6.277"'
	," codeSystemName=" ,'"cdcNHSN"'
	," code=" ,'"2525-4"'
	," displayName=" ,'"' ,days_present_msg ,'"' ,"/>"
	,"<statusCode code=" ,'"completed"' ,"/>"
	,"<value xsi:type=" ,'"PQ"' ," unit=" ,'"d"' ," value=" ,'"' ,days_present ,'"' ,"/>"
	,"</observation>"
	,"</entryRelationship>"
	,"</encounter>"
	,"</entry>"
	)
  ENDIF
  RETURN (header_xml_string )
 END ;Subroutine
 SUBROUTINE  createsinglemedxml (rpt_type_flag ,not_available_flag ,cdc_loc_cd ,nhsn_your_code ,
  med_name ,rx_norm ,total_val ,resp_val ,digestive_val ,iv_val ,im_val )
  DECLARE hl7_code = vc WITH constant (uar_get_code_display (cdc_loc_cd ) ) ,protect
  DECLARE nhsn_loc_name = vc WITH constant (uar_get_code_description (cdc_loc_cd ) ) ,protect
  DECLARE therapy_days_msg = vc WITH constant ("Number of Therapy Days" ) ,protect
  DECLARE hl7_location_msg = vc WITH constant ("HL7 Healthcare Service Location Code" ) ,protect
  DECLARE antimicrobial_xml_string = vc WITH noconstant ("" ) ,protect
  SET antimicrobial_xml_string = build (
	 "<entry typeCode=" ,'"DRIV"' ,">"
	,"<encounter classCode=" ,'"ENC"' ," moodCode=" ,'"EVN"' ,">"
	,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.6.198"' ,"/>"
	,"<participant typeCode=" ,'"LOC"' ,">" ,"<participantRole classCode=" ,'"SDLOC"' ,">" )
 
  IF ((rpt_type_flag = facwidein ) )
   SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<id root=" ,'"2.16.840.1.113883.3.117.1.1.5.1.1"' ," extension=" ,'"FACWIDEIN"' ,"/>"
	,"<code codeSystem=" ,'"2.16.840.1.113883.6.259"'
		," codeSystemName=" ,'"' ,hl7_location_msg ,'"'
		," code=" ,'"1250-0"' ," displayName=" ,'"FACWIDEIN"' ,"/>" )
  ELSE
   SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<id root=" ,'"2.16.840.1.113883.3.117.1.1.5.1.1"' ," extension=" ,'"' ,nhsn_your_code ,'"' ,"/>" ,
    "<code codeSystem=" ,'"2.16.840.1.113883.6.259"'
		," codeSystemName=" ,'"' ,hl7_location_msg ,'"'
		," code=" ,'"' ,hl7_code ,'"'
		," displayName=" ,'"' ,nhsn_loc_name ,'"' ,"/>" )
  ENDIF
 
  SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"</participantRole>"
	,"</participant>"
	,"<participant typeCode=" ,'"CSM"' ,">"
	,"<participantRole classCode=" ,'"MANU"',">"
	,"<code codeSystem=" ,'"2.16.840.1.113883.6.88"'
		," codeSystemName=" ,'"RxNorm"'
		," code=" ,'"' ,rx_norm ,'"'
		," displayName=" ,'"' ,med_name ,'"' ,"/>"
	,"</participantRole>"
	,"</participant>"
	,"<entryRelationship typeCode=" ,'"COMP"' ,">"
	,"<observation classCode=" ,'"OBS"' ," moodCode=" ,'"EVN"' ,">"
	,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.6.185"' ,"/>"
	,"<code codeSystem=" ,'"2.16.840.1.113883.6.277"'
		," codeSystemName=" ,'"cdcNHSN"'
		," code=",'"2524-7"'
		," displayName=" ,'"' ,therapy_days_msg ,'"' ,"/>"
	,"<statusCode code=" ,'"completed"' ,"/>" )
 
  IF ((not_available_flag = available ) )
   SET antimicrobial_xml_string = build (
	 antimicrobial_xml_string
	,"<value xsi:type=" ,'"PQ"' ," unit=" ,'"d"' ," value=" ,'"' ,total_val ,'"' ,"/>" )
  ELSE
   SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<value xsi:type=" ,'"PQ"' ," unit=" ,'"d"' ," nullFlavor=" ,'"NA"' ,"/>" )
  ENDIF
 
 
  SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"</observation>"
	,"</entryRelationship>"
	,"<entryRelationship typeCode=" ,'"COMP"' ,">"
	,"<observation classCode=" ,'"OBS"' ," moodCode=" ,'"EVN"' ,">"
	,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.6.194"' ,"/>"
	,"<code codeSystem=" ,'"2.16.840.1.113883.6.277"' ," codeSystemName=" ,'"cdcNHSN"'
	," code=",'"2524-7"' ," displayName=" ,'"' ,therapy_days_msg ,'"' ,"/>"
	,"<statusCode code="
	,'"completed"' ,"/>" )
 
  IF ((not_available_flag = available ) )
   SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<value xsi:type=" ,'"PQ"' ," unit=" ,'"d"' ," value=" ,'"' ,resp_val ,'"' ,"/>" )
  ELSE
   SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<value xsi:type=" ,'"PQ"' ," unit=" ,'"d"' ," nullFlavor=" ,'"NA"' ,"/>" )
  ENDIF
 
  SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<methodCode codeSystem=" ,'"2.16.840.1.113883.6.277"' ," codeSystemName=" ,'"cdcNHSN"'
	," code=" ,'"' ,nhsn_xml_resp_code ,'"' ," displayName=" ,'"Respiratory tract route"' ,"/>"
	,"</observation>"
	,"</entryRelationship>"
   ,"<entryRelationship typeCode=" ,'"COMP"' ,">"
   ,"<observation classCode=" ,'"OBS"' ," moodCode=" ,'"EVN"' ,">"
   ,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.6.194"' ,"/>"
   ,"<code codeSystem=",'"2.16.840.1.113883.6.277"' ," codeSystemName=" ,'"cdcNHSN"'
   ," code=" ,'"2524-7"' ," displayName=" ,'"' ,therapy_days_msg ,'"' ,"/>"
   ,"<statusCode code=" ,'"completed"' ,"/>" )
 
  IF ((not_available_flag = available ) )
   SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<value xsi:type=" ,'"PQ"' ," unit=" ,'"d"' ," value=" ,'"' ,digestive_val ,'"' ,"/>" )
  ELSE
   SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<value xsi:type=" ,'"PQ"' ," unit=" ,'"d"' ," nullFlavor=" ,'"NA"' ,"/>" )
  ENDIF
 
  SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<methodCode codeSystem=" ,'"2.16.840.1.113883.6.277"' ," codeSystemName="
	,'"cdcNHSN"' ," code=" ,'"' ,nhsn_xml_digest_code,'"'
	," displayName=" ,'"Digestive tract route"' ,"/>"
	,"</observation>"
	,"</entryRelationship>"
	,"<entryRelationship typeCode=" ,'"COMP"' ,">"
	,"<observation classCode=" ,'"OBS"' ," moodCode=" ,'"EVN"' ,">"
	,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.6.194"' ,"/>"
	,"<code codeSystem=",'"2.16.840.1.113883.6.277"' ," codeSystemName=" ,'"cdcNHSN"'
	," code=" ,'"2524-7"' ," displayName=" ,'"' ,therapy_days_msg ,'"' ,"/>"
	,"<statusCode code=" ,'"completed"' ,"/>" )
 
  IF ((not_available_flag = available ) )
   SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<value xsi:type=" ,'"PQ"' ," unit=" ,'"d"' ," value=" ,'"' ,iv_val ,'"' ,"/>" )
  ELSE
   SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<value xsi:type=" ,'"PQ"' ," unit=" ,'"d"' ," nullFlavor=" ,'"NA"' ,"/>" )
  ENDIF
 
  SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<methodCode codeSystem=" ,'"2.16.840.1.113883.6.96"' ," codeSystemName=" ,'"SNOMED"'
	," code=" ,'"' ,nhsn_xml_iv_code ,'"'
	," displayName=" ,'"Intravenous route"' ,"/>"
	,"</observation>"
	,"</entryRelationship>"
	,"<entryRelationship typeCode=" ,'"COMP"' ,">"
	,"<observation classCode=" ,'"OBS"' ," moodCode=" ,'"EVN"' ,">"
	,"<templateId root=" ,'"2.16.840.1.113883.10.20.5.6.194"' ,"/>"
	,"<code codeSystem=",'"2.16.840.1.113883.6.277"' ," codeSystemName=" ,'"cdcNHSN"'
	," code=" ,'"2524-7"'
	," displayName=" ,'"' ,therapy_days_msg ,'"' ,"/>"
	,"<statusCode code=" ,'"completed"' ,"/>" )
 
  IF ((not_available_flag = available ) )
   SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<value xsi:type=" ,'"PQ"' ," unit=" ,'"d"' ," value=" ,'"' ,im_val ,'"' ,"/>" )
  ELSE
   SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<value xsi:type=" ,'"PQ"' ," unit=" ,'"d"' ," nullFlavor=" ,'"NA"' ,"/>" )
  ENDIF
 
  SET antimicrobial_xml_string = build (
	antimicrobial_xml_string
	,"<methodCode codeSystem=" ,'"2.16.840.1.113883.6.96"' ," codeSystemName=" ,'"SNOMED"'
	," code=" ,'"' ,nhsn_xml_im_code ,'"'
	," displayName=" ,'"Intramuscular route"' ,"/>"
	,"</observation>"
	,"</entryRelationship>"
	,"</encounter>"
	,"</entry>" )
  RETURN (antimicrobial_xml_string )
 END ;Subroutine
 SUBROUTINE  createfooterxml (null )
  DECLARE footer_xml_string = vc WITH noconstant ("" ) ,protect
  SET footer_xml_string = build ("</section>" ,"</component>" ,"</structuredBody>" ,"</component>" ,
   "</ClinicalDocument>" )
  RETURN (footer_xml_string )
 END ;Subroutine
 SUBROUTINE  storenhsnxmlroutecode (route_name ,route_nhsn_code )
  IF ((trim (route_name ,3 ) = iv_route ) )
   SET nhsn_xml_iv_code = trim (route_nhsn_code ,3 )
  ELSEIF ((trim (route_name ,3 ) = im_route ) )
   SET nhsn_xml_im_code = trim (route_nhsn_code ,3 )
  ELSEIF ((trim (route_name ,3 ) = respiratory_route ) )
   SET nhsn_xml_resp_code = trim (route_nhsn_code ,3 )
  ELSEIF ((trim (route_name ,3 ) = digest_route ) )
   SET nhsn_xml_digest_code = trim (route_nhsn_code ,3 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  writeauditinfo (null )
  CALL log_message ("Begin - Subroutine WriteAuditInfo" ,log_level_debug )
  CASE ( $REPORTTYPEIND )
   OF au_report :
    SET audit_solution_cd = uar_get_code_by ("MEANING" ,4002138 ,"ICAU" )
    SET audit_event_cd = uar_get_code_by ("MEANING" ,4002139 ,"ICAUARREPORT" )
   OF dot_report :
    SET audit_solution_cd = uar_get_code_by ("MEANING" ,4002138 ,"ICDOT" )
    SET audit_event_cd = uar_get_code_by ("MEANING" ,4002139 ,"ICDOTREPORT" )
  ENDCASE
  SET stat = alterlist (bsc_rai_req->audit_events ,1 )
  SET bsc_rai_req->audit_events[1 ].audit_facility_cd =  $FACILITY
  SET bsc_rai_req->audit_events[1 ].audit_event_cd = audit_event_cd
  SET bsc_rai_req->audit_events[1 ].audit_solution_cd = audit_solution_cd
  SET bsc_rai_req->debug_ind = 1
  IF ((checkprg ("BSC_REC_AUDIT_INFO" ) = 0 ) )
   CALL log_message ("Missing script object - bsc_rec_audit_info" ,log_level_debug )
  ELSE
   EXECUTE bsc_rec_audit_info WITH replace ("REQUEST" ,"BSC_RAI_REQ" ) ,
   replace ("REPLY" ,"BSC_RAI_REP" )
   FREE RECORD bsc_rai_req
   IF ((bsc_rai_rep->status_data.status = "F" ) )
    CALL log_message ("bsc_rec_audit_info failure" ,log_level_debug )
   ENDIF
   FREE RECORD bsc_rai_rep
  ENDIF
  CALL log_message ("End - Subroutine WriteAuditInfo" ,log_level_debug )
 END ;Subroutine
 CALL log_message (build ("End - Subroutine IC_AU_REPORT. Elapsed time in seconds:" ,datetimediff (
    cnvtdatetime (curdate ,curtime3 ) ,script_timer ,5 ) ) ,log_level_debug )
 
 set html_output = replace(html_output,"%%cov_ic_au_report_medication_list%%",cnvtrectojson(medication_list))
 set html_output = replace(html_output,"%%cov_ic_au_report_temproute_list%%",cnvtrectojson(temproute_list))
 set html_output = replace(html_output,"%%cov_ic_au_report_route_list%%",cnvtrectojson(route_list))
 set html_output = replace(html_output,"%%cov_ic_au_report_loc_list%%",cnvtrectojson(loc_list))
 
 set html_output = replace(html_output,"%%cov_ic_au_report_facwidein_reply%%",cnvtrectojson(facwidein_reply))
 
#exit_script
END GO
