DROP PROGRAM cov_mp_unchart_result :dba GO
CREATE PROGRAM cov_mp_unchart_result :dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Person Id:" = 0.0 ,
  "Personnel Id:" = 0.0 ,
  "Encounter Id:" = 0.0 ,
  "Event Code:" = 0.0 ,
  "Event Ids:" = 0.0 ,
  "Provide Patient Relationship Code:" = 0.0
  WITH outdev ,inputpersonid ,inputproviderid ,inputencounterid ,inputeventcd ,inputeventid ,
  inputppr
 RECORD report_data (
   1 rep [* ]
     2 sb
       3 severitycd = i4
       3 statuscd = i4
       3 statustext = vc
       3 substatuslist [* ]
         4 substatuscd = i4
     2 rb_list [* ]
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 event_cd = f8
       3 result_status_cd = f8
       3 contributor_system_cd = f8
       3 reference_nbr = vc
       3 collating_seq = vc
       3 parent_event_id = f8
       3 prsnl_list [* ]
         4 event_prsnl_id = f8
         4 action_prsnl_id = f8
         4 action_type_cd = f8
         4 action_dt_tm = dq8
         4 action_dt_tm_ind = i2
         4 action_tz = i4
         4 updt_cnt = i4
       3 clinical_event_id = f8
       3 updt_cnt = i4
       3 result_set_link_list [* ]
         4 result_set_id = f8
         4 entry_type_cd = f8
         4 updt_cnt = i4
       3 ce_dynamic_label_id = f8
   1 dynamic_label_list [* ]
     2 ce_dynamic_label_id = f8
     2 label_name = vc
     2 label_prsnl_id = f8
     2 label_status_cd = f8
     2 result_set_id = f8
     2 label_seq_nbr = i4
     2 valid_from_dt_tm = dq8
   1 sb
     2 severitycd = i4
     2 statuscd = i4
     2 statustext = vc
     2 substatuslist [* ]
       3 substatuscd = i4
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SUBROUTINE  (log_message (logmsg =vc ,loglvl =i4 ) =null )
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
 END ;Subroutine
 SUBROUTINE  (error_message (logstatusblockind =i2 ) =i2 )
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
 SUBROUTINE  (error_and_zero_check_rec (qualnum =i4 ,opname =vc ,logmsg =vc ,errorforceexit =i2 ,
  zeroforceexit =i2 ,recorddata =vc (ref ) ) =i2 )
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
 SUBROUTINE  (error_and_zero_check (qualnum =i4 ,opname =vc ,logmsg =vc ,errorforceexit =i2 ,
  zeroforceexit =i2 ) =i2 )
  RETURN (error_and_zero_check_rec (qualnum ,opname ,logmsg ,errorforceexit ,zeroforceexit ,reply ) )
 END ;Subroutine
 SUBROUTINE  (populate_subeventstatus_rec (operationname =vc (value ) ,operationstatus =vc (value ) ,
  targetobjectname =vc (value ) ,targetobjectvalue =vc (value ) ,recorddata =vc (ref ) ) =i2 )
  IF ((validate (recorddata->status_data.status ,"-1" ) != "-1" ) )
   SET lcrslsubeventcnt = size (recorddata->status_data.subeventstatus ,5 )
   SET lcrslsubeventsize = size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     operationname ) )
   SET lcrslsubeventsize +=size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     operationstatus ) )
   SET lcrslsubeventsize +=size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     targetobjectname ) )
   SET lcrslsubeventsize +=size (trim (recorddata->status_data.subeventstatus[lcrslsubeventcnt ].
     targetobjectvalue ) )
   IF ((lcrslsubeventsize > 0 ) )
    SET lcrslsubeventcnt +=1
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
 SUBROUTINE  (populate_subeventstatus (operationname =vc (value ) ,operationstatus =vc (value ) ,
  targetobjectname =vc (value ) ,targetobjectvalue =vc (value ) ) =i2 )
  CALL populate_subeventstatus_rec (operationname ,operationstatus ,targetobjectname ,
   targetobjectvalue ,reply )
 END ;Subroutine
 SUBROUTINE  (populate_subeventstatus_msg (operationname =vc (value ) ,operationstatus =vc (value ) ,
  targetobjectname =vc (value ) ,targetobjectvalue =vc (value ) ,loglevel =i2 (value ) ) =i2 )
  CALL populate_subeventstatus (operationname ,operationstatus ,targetobjectname ,targetobjectvalue
   )
  CALL log_message (targetobjectvalue ,loglevel )
 END ;Subroutine
 SUBROUTINE  (check_log_level (arg_log_level =i4 ) =i2 )
  IF ((((crsl_msg_level >= arg_log_level ) ) OR ((log_override_ind = 1 ) )) )
   RETURN (1 )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 DECLARE current_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,protect
 DECLARE current_time_zone = i4 WITH constant (datetimezonebyname (curtimezone ) ) ,protect
 DECLARE ending_date_time = dq8 WITH constant (cnvtdatetime ("31-DEC-2100" ) ) ,protect
 DECLARE bind_cnt = i4 WITH constant (50 ) ,protect
 DECLARE lower_bound_date = vc WITH constant ("01-JAN-1800 00:00:00.00" ) ,protect
 DECLARE upper_bound_date = vc WITH constant ("31-DEC-2100 23:59:59.99" ) ,protect
 DECLARE codelistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnllistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE phonelistcnt = i4 WITH noconstant (0 ) ,protect
 DECLARE code_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnl_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE phone_idx = i4 WITH noconstant (0 ) ,protect
 DECLARE prsnl_cnt = i4 WITH noconstant (0 ) ,protect
 DECLARE mpc_ap_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_doc_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_mdoc_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_rad_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_txt_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_num_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_immun_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_med_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_date_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_done_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_mbo_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_procedure_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_grp_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE mpc_hlatyping_type_cd = f8 WITH protect ,noconstant (0.0 )
 DECLARE eventclasscdpopulated = i2 WITH protect ,noconstant (0 )
 DECLARE getorgsecurityflag (null ) = i2 WITH protect
 DECLARE cclimpersonation (null ) = null WITH protect
 SUBROUTINE  (addcodetolist (code_value =f8 (val ) ,record_data =vc (ref ) ) =null WITH protect )
  IF ((code_value != 0 ) )
   IF ((((codelistcnt = 0 ) ) OR ((locateval (code_idx ,1 ,codelistcnt ,code_value ,record_data->
    codes[code_idx ].code ) <= 0 ) )) )
    SET codelistcnt +=1
    SET stat = alterlist (record_data->codes ,codelistcnt )
    SET record_data->codes[codelistcnt ].code = code_value
    SET record_data->codes[codelistcnt ].sequence = uar_get_collation_seq (code_value )
    SET record_data->codes[codelistcnt ].meaning = uar_get_code_meaning (code_value )
    SET record_data->codes[codelistcnt ].display = uar_get_code_display (code_value )
    SET record_data->codes[codelistcnt ].description = uar_get_code_description (code_value )
    SET record_data->codes[codelistcnt ].code_set = uar_get_code_set (code_value )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (outputcodelist (record_data =vc (ref ) ) =null WITH protect )
  CALL log_message ("In OutputCodeList() @deprecated" ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (addpersonneltolist (prsnl_id =f8 (val ) ,record_data =vc (ref ) ) =null WITH protect )
  CALL addpersonneltolistwithdate (prsnl_id ,record_data ,current_date_time )
 END ;Subroutine
 SUBROUTINE  (addpersonneltolistwithdate (prsnl_id =f8 (val ) ,record_data =vc (ref ) ,active_date =
  f8 (val ) ) =null WITH protect )
  DECLARE personnel_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,213 ,"PRSNL" ) )
  IF ((((active_date = null ) ) OR ((active_date = 0.0 ) )) )
   SET active_date = current_date_time
  ENDIF
  IF ((prsnl_id != 0 ) )
   IF ((((prsnllistcnt = 0 ) ) OR ((locateval (prsnl_idx ,1 ,prsnllistcnt ,prsnl_id ,record_data->
    prsnl[prsnl_idx ].id ,active_date ,record_data->prsnl[prsnl_idx ].active_date ) <= 0 ) )) )
    SET prsnllistcnt +=1
    IF ((prsnllistcnt > size (record_data->prsnl ,5 ) ) )
     SET stat = alterlist (record_data->prsnl ,(prsnllistcnt + 9 ) )
    ENDIF
    SET record_data->prsnl[prsnllistcnt ].id = prsnl_id
    IF ((validate (record_data->prsnl[prsnllistcnt ].active_date ) != 0 ) )
     SET record_data->prsnl[prsnllistcnt ].active_date = active_date
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (outputpersonnellist (report_data =vc (ref ) ) =null WITH protect )
  CALL log_message ("In OutputPersonnelList()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  DECLARE prsnl_name_type_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,213 ,"PRSNL" ) ) ,
  protect
  DECLARE active_date_ind = i2 WITH protect ,noconstant (0 )
  DECLARE filteredcnt = i4 WITH protect ,noconstant (0 )
  DECLARE prsnl_seq = i4 WITH protect ,noconstant (0 )
  DECLARE idx = i4 WITH protect ,noconstant (0 )
  IF ((prsnllistcnt > 0 ) )
   SELECT INTO "nl:"
    FROM (prsnl p ),
     (left
     JOIN person_name pn ON (pn.person_id = p.person_id )
     AND (pn.name_type_cd = prsnl_name_type_cd )
     AND (pn.active_ind = 1 ) )
    PLAN (p
     WHERE expand (idx ,1 ,size (report_data->prsnl ,5 ) ,p.person_id ,report_data->prsnl[idx ].id )
     )
     JOIN (pn )
    ORDER BY p.person_id ,
     pn.end_effective_dt_tm DESC
    HEAD REPORT
     prsnl_seq = 0 ,
     active_date_ind = validate (report_data->prsnl[1 ].active_date ,0 )
    HEAD p.person_id
     IF ((active_date_ind = 0 ) ) prsnl_seq = locateval (idx ,1 ,prsnllistcnt ,p.person_id ,
       report_data->prsnl[idx ].id ) ,
      IF ((pn.person_id > 0 ) ) report_data->prsnl[prsnl_seq ].provider_name.name_full = trim (pn
        .name_full ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.name_first = trim (pn
        .name_first ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.name_middle = trim (pn
        .name_middle ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.name_last = trim (pn
        .name_last ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.username = trim (p.username ,3
        ) ,report_data->prsnl[prsnl_seq ].provider_name.initials = trim (pn.name_initials ,3 ) ,
       report_data->prsnl[prsnl_seq ].provider_name.title = trim (pn.name_initials ,3 )
      ELSE report_data->prsnl[prsnl_seq ].provider_name.name_full = trim (p.name_full_formatted ,3 )
      ,report_data->prsnl[prsnl_seq ].provider_name.name_first = trim (p.name_first ,3 ) ,report_data
       ->prsnl[prsnl_seq ].provider_name.name_last = trim (p.name_last ,3 ) ,report_data->prsnl[
       prsnl_seq ].provider_name.username = trim (p.username ,3 )
      ENDIF
     ENDIF
    DETAIL
     IF ((active_date_ind != 0 ) ) prsnl_seq = locateval (idx ,1 ,prsnllistcnt ,p.person_id ,
       report_data->prsnl[idx ].id ) ,
      WHILE ((prsnl_seq > 0 ) )
       IF ((report_data->prsnl[prsnl_seq ].active_date BETWEEN pn.beg_effective_dt_tm AND pn
       .end_effective_dt_tm ) )
        IF ((pn.person_id > 0 ) ) report_data->prsnl[prsnl_seq ].person_name_id = pn.person_name_id ,
         report_data->prsnl[prsnl_seq ].beg_effective_dt_tm = pn.beg_effective_dt_tm ,report_data->
         prsnl[prsnl_seq ].end_effective_dt_tm = pn.end_effective_dt_tm ,report_data->prsnl[
         prsnl_seq ].provider_name.name_full = trim (pn.name_full ,3 ) ,report_data->prsnl[prsnl_seq
         ].provider_name.name_first = trim (pn.name_first ,3 ) ,report_data->prsnl[prsnl_seq ].
         provider_name.name_middle = trim (pn.name_middle ,3 ) ,report_data->prsnl[prsnl_seq ].
         provider_name.name_last = trim (pn.name_last ,3 ) ,report_data->prsnl[prsnl_seq ].
         provider_name.username = trim (p.username ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name
         .initials = trim (pn.name_initials ,3 ) ,report_data->prsnl[prsnl_seq ].provider_name.title
         = trim (pn.name_initials ,3 )
        ELSE report_data->prsnl[prsnl_seq ].provider_name.name_full = trim (p.name_full_formatted ,3
          ) ,report_data->prsnl[prsnl_seq ].provider_name.name_first = trim (p.name_first ,3 ) ,
         report_data->prsnl[prsnl_seq ].provider_name.name_last = trim (pn.name_last ,3 ) ,
         report_data->prsnl[prsnl_seq ].provider_name.username = trim (p.username ,3 )
        ENDIF
        ,
        IF ((report_data->prsnl[prsnl_seq ].active_date = current_date_time ) ) report_data->prsnl[
         prsnl_seq ].active_date = 0
        ENDIF
       ENDIF
       ,prsnl_seq = locateval (idx ,(prsnl_seq + 1 ) ,prsnllistcnt ,p.person_id ,report_data->prsnl[
        idx ].id )
      ENDWHILE
     ENDIF
    FOOT REPORT
     stat = alterlist (report_data->prsnl ,prsnllistcnt )
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec (curqual ,"PRSNL" ,"OutputPersonnelList" ,1 ,0 ,report_data )
   IF ((active_date_ind != 0 ) )
    SELECT INTO "nl:"
     end_effective_dt_tm = report_data->prsnl[d.seq ].end_effective_dt_tm ,
     person_name_id = report_data->prsnl[d.seq ].person_name_id ,
     prsnl_id = report_data->prsnl[d.seq ].id
     FROM (dummyt d WITH seq = size (report_data->prsnl ,5 ) )
     ORDER BY end_effective_dt_tm DESC ,
      person_name_id ,
      prsnl_id
     HEAD REPORT
      filteredcnt = 0 ,
      idx = size (report_data->prsnl ,5 ) ,
      stat = alterlist (report_data->prsnl ,(idx * 2 ) )
     HEAD end_effective_dt_tm
      donothing = 0
     HEAD prsnl_id
      idx +=1 ,filteredcnt +=1 ,report_data->prsnl[idx ].id = report_data->prsnl[d.seq ].id ,
      report_data->prsnl[idx ].person_name_id = report_data->prsnl[d.seq ].person_name_id ,
      IF ((report_data->prsnl[d.seq ].person_name_id > 0.0 ) ) report_data->prsnl[idx ].
       beg_effective_dt_tm = report_data->prsnl[d.seq ].beg_effective_dt_tm ,report_data->prsnl[idx ]
       .end_effective_dt_tm = report_data->prsnl[d.seq ].end_effective_dt_tm
      ELSE report_data->prsnl[idx ].beg_effective_dt_tm = cnvtdatetime ("01-JAN-1900" ) ,report_data
       ->prsnl[idx ].end_effective_dt_tm = cnvtdatetime ("31-DEC-2100" )
      ENDIF
      ,report_data->prsnl[idx ].provider_name.name_full = report_data->prsnl[d.seq ].provider_name.
      name_full ,report_data->prsnl[idx ].provider_name.name_first = report_data->prsnl[d.seq ].
      provider_name.name_first ,report_data->prsnl[idx ].provider_name.name_middle = report_data->
      prsnl[d.seq ].provider_name.name_middle ,report_data->prsnl[idx ].provider_name.name_last =
      report_data->prsnl[d.seq ].provider_name.name_last ,report_data->prsnl[idx ].provider_name.
      username = report_data->prsnl[d.seq ].provider_name.username ,report_data->prsnl[idx ].
      provider_name.initials = report_data->prsnl[d.seq ].provider_name.initials ,report_data->prsnl[
      idx ].provider_name.title = report_data->prsnl[d.seq ].provider_name.title
     FOOT REPORT
      stat = alterlist (report_data->prsnl ,idx ) ,
      stat = alterlist (report_data->prsnl ,filteredcnt ,0 )
     WITH nocounter
    ;end select
    CALL error_and_zero_check_rec (curqual ,"PRSNL" ,"FilterPersonnelList" ,1 ,0 ,report_data )
   ENDIF
  ENDIF
  CALL log_message (build ("Exit OutputPersonnelList(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (addphonestolist (prsnl_id =f8 (val ) ,record_data =vc (ref ) ) =null WITH protect )
  IF ((prsnl_id != 0 ) )
   IF ((((phonelistcnt = 0 ) ) OR ((locateval (phone_idx ,1 ,phonelistcnt ,prsnl_id ,record_data->
    phone_list[prsnl_idx ].person_id ) <= 0 ) )) )
    SET phonelistcnt +=1
    IF ((phonelistcnt > size (record_data->phone_list ,5 ) ) )
     SET stat = alterlist (record_data->phone_list ,(phonelistcnt + 9 ) )
    ENDIF
    SET record_data->phone_list[phonelistcnt ].person_id = prsnl_id
    SET prsnl_cnt +=1
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (outputphonelist (report_data =vc (ref ) ,phone_types =vc (ref ) ) =null WITH protect )
  CALL log_message ("In OutputPhoneList()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  DECLARE personcnt = i4 WITH protect ,constant (size (report_data->phone_list ,5 ) )
  DECLARE idx = i4 WITH protect ,noconstant (0 )
  DECLARE idx2 = i4 WITH protect ,noconstant (0 )
  DECLARE idx3 = i4 WITH protect ,noconstant (0 )
  DECLARE phonecnt = i4 WITH protect ,noconstant (0 )
  DECLARE prsnlidx = i4 WITH protect ,noconstant (0 )
  IF ((phonelistcnt > 0 ) )
   SELECT
    IF ((size (phone_types->phone_codes ,5 ) = 0 ) )
     phone_sorter = ph.phone_id
     FROM (phone ph )
     WHERE expand (idx ,1 ,personcnt ,ph.parent_entity_id ,report_data->phone_list[idx ].person_id )
     AND (ph.parent_entity_name = "PERSON" )
     AND (ph.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
     AND (ph.end_effective_dt_tm >= cnvtdatetime (sysdate ) )
     AND (ph.active_ind = 1 )
     AND (ph.phone_type_seq = 1 )
     ORDER BY ph.parent_entity_id ,
      phone_sorter
    ELSE
     phone_sorter = locateval (idx2 ,1 ,size (phone_types->phone_codes ,5 ) ,ph.phone_type_cd ,
      phone_types->phone_codes[idx2 ].phone_cd )
     FROM (phone ph )
     WHERE expand (idx ,1 ,personcnt ,ph.parent_entity_id ,report_data->phone_list[idx ].person_id )
     AND (ph.parent_entity_name = "PERSON" )
     AND (ph.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
     AND (ph.end_effective_dt_tm >= cnvtdatetime (sysdate ) )
     AND (ph.active_ind = 1 )
     AND expand (idx2 ,1 ,size (phone_types->phone_codes ,5 ) ,ph.phone_type_cd ,phone_types->
      phone_codes[idx2 ].phone_cd )
     AND (ph.phone_type_seq = 1 )
     ORDER BY ph.parent_entity_id ,
      phone_sorter
    ENDIF
    INTO "nl:"
    HEAD ph.parent_entity_id
     phonecnt = 0 ,prsnlidx = locateval (idx3 ,1 ,personcnt ,ph.parent_entity_id ,report_data->
      phone_list[idx3 ].person_id )
    HEAD phone_sorter
     phonecnt +=1 ,
     IF ((size (report_data->phone_list[prsnlidx ].phones ,5 ) < phonecnt ) ) stat = alterlist (
       report_data->phone_list[prsnlidx ].phones ,(phonecnt + 5 ) )
     ENDIF
     ,report_data->phone_list[prsnlidx ].phones[phonecnt ].phone_id = ph.phone_id ,report_data->
     phone_list[prsnlidx ].phones[phonecnt ].phone_type_cd = ph.phone_type_cd ,report_data->
     phone_list[prsnlidx ].phones[phonecnt ].phone_type = uar_get_code_display (ph.phone_type_cd ) ,
     report_data->phone_list[prsnlidx ].phones[phonecnt ].phone_num = formatphonenumber (ph
      .phone_num ,ph.phone_format_cd ,ph.extension )
    FOOT  ph.parent_entity_id
     stat = alterlist (report_data->phone_list[prsnlidx ].phones ,phonecnt )
    WITH nocounter ,expand = value (evaluate (floor (((personcnt - 1 ) / 30 ) ) ,0 ,0 ,1 ) )
   ;end select
   SET stat = alterlist (report_data->phone_list ,prsnl_cnt )
   CALL error_and_zero_check_rec (curqual ,"PHONE" ,"OutputPhoneList" ,1 ,0 ,report_data )
  ENDIF
  CALL log_message (build ("Exit OutputPhoneList(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (putstringtofile (svalue =vc (val ) ) =null WITH protect )
  CALL log_message ("In PutStringToFile()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  IF ((validate (_memory_reply_string ) = 1 ) )
   SET _memory_reply_string = svalue
  ELSE
   FREE RECORD putrequest
   RECORD putrequest (
     1 source_dir = vc
     1 source_filename = vc
     1 nbrlines = i4
     1 line [* ]
       2 linedata = vc
     1 overflowpage [* ]
       2 ofr_qual [* ]
         3 ofr_line = vc
     1 isblob = c1
     1 document_size = i4
     1 document = gvc
   )
   SET putrequest->source_dir =  $OUTDEV
   SET putrequest->isblob = "1"
   SET putrequest->document = svalue
   SET putrequest->document_size = size (putrequest->document )
   EXECUTE eks_put_source WITH replace ("REQUEST" ,putrequest ) ,
   replace ("REPLY" ,putreply )
  ENDIF
  CALL log_message (build ("Exit PutStringToFile(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (putunboundedstringtofile (trec =vc (ref ) ) =null WITH protect )
  CALL log_message ("In PutUnboundedStringToFile()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  DECLARE curstringlength = i4 WITH noconstant (textlen (trec->val ) )
  DECLARE newmaxvarlen = i4 WITH noconstant (0 )
  DECLARE origcurmaxvarlen = i4 WITH noconstant (0 )
  IF ((curstringlength > curmaxvarlen ) )
   SET origcurmaxvarlen = curmaxvarlen
   SET newmaxvarlen = (curstringlength + 10000 )
   SET modify maxvarlen newmaxvarlen
  ENDIF
  CALL putstringtofile (trec->val )
  IF ((newmaxvarlen > 0 ) )
   SET modify maxvarlen origcurmaxvarlen
  ENDIF
  CALL log_message (build ("Exit PutUnboundedStringToFile(), Elapsed time in seconds:" ,datetimediff
    (cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (putjsonrecordtofile (record_data =vc (ref ) ) =null WITH protect )
  CALL log_message ("In PutJSONRecordToFile()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  RECORD _tempjson (
    1 val = gvc
  )
  SET _tempjson->val = cnvtrectojson (record_data )
  CALL putunboundedstringtofile (_tempjson )
  CALL log_message (build ("Exit PutJSONRecordToFile(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (getparametervalues (index =i4 (val ) ,value_rec =vc (ref ) ) =null WITH protect )
  DECLARE par = vc WITH noconstant ("" ) ,protect
  DECLARE lnum = i4 WITH noconstant (0 ) ,protect
  DECLARE num = i4 WITH noconstant (1 ) ,protect
  DECLARE cnt = i4 WITH noconstant (0 ) ,protect
  DECLARE cnt2 = i4 WITH noconstant (0 ) ,protect
  DECLARE param_value = f8 WITH noconstant (0.0 ) ,protect
  DECLARE param_value_str = vc WITH noconstant ("" ) ,protect
  SET par = reflect (parameter (index ,0 ) )
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echo (par )
  ENDIF
  IF ((((par = "F8" ) ) OR ((par = "I4" ) )) )
   SET param_value = parameter (index ,0 )
   IF ((param_value > 0 ) )
    SET value_rec->cnt +=1
    SET stat = alterlist (value_rec->qual ,value_rec->cnt )
    SET value_rec->qual[value_rec->cnt ].value = param_value
   ENDIF
  ELSEIF ((substring (1 ,1 ,par ) = "C" ) )
   SET param_value_str = parameter (index ,0 )
   IF ((trim (param_value_str ,3 ) != "" ) )
    SET value_rec->cnt +=1
    SET stat = alterlist (value_rec->qual ,value_rec->cnt )
    SET value_rec->qual[value_rec->cnt ].value = trim (param_value_str ,3 )
   ENDIF
  ELSEIF ((substring (1 ,1 ,par ) = "L" ) )
   SET lnum = 1
   WHILE ((lnum > 0 ) )
    SET par = reflect (parameter (index ,lnum ) )
    IF ((par != " " ) )
     IF ((((par = "F8" ) ) OR ((par = "I4" ) )) )
      SET param_value = parameter (index ,lnum )
      IF ((param_value > 0 ) )
       SET value_rec->cnt +=1
       SET stat = alterlist (value_rec->qual ,value_rec->cnt )
       SET value_rec->qual[value_rec->cnt ].value = param_value
      ENDIF
      SET lnum +=1
     ELSEIF ((substring (1 ,1 ,par ) = "C" ) )
      SET param_value_str = parameter (index ,lnum )
      IF ((trim (param_value_str ,3 ) != "" ) )
       SET value_rec->cnt +=1
       SET stat = alterlist (value_rec->qual ,value_rec->cnt )
       SET value_rec->qual[value_rec->cnt ].value = trim (param_value_str ,3 )
      ENDIF
      SET lnum +=1
     ENDIF
    ELSE
     SET lnum = 0
    ENDIF
   ENDWHILE
  ENDIF
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (value_rec )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getlookbackdatebytype (units =i4 (val ) ,flag =i4 (val ) ) =dq8 WITH protect )
  DECLARE looback_date = dq8 WITH noconstant (cnvtdatetime ("01-JAN-1800 00:00:00" ) )
  IF ((units != 0 ) )
   CASE (flag )
    OF 1 :
     SET looback_date = cnvtlookbehind (build (units ,",H" ) ,cnvtdatetime (sysdate ) )
    OF 2 :
     SET looback_date = cnvtlookbehind (build (units ,",D" ) ,cnvtdatetime (sysdate ) )
    OF 3 :
     SET looback_date = cnvtlookbehind (build (units ,",W" ) ,cnvtdatetime (sysdate ) )
    OF 4 :
     SET looback_date = cnvtlookbehind (build (units ,",M" ) ,cnvtdatetime (sysdate ) )
    OF 5 :
     SET looback_date = cnvtlookbehind (build (units ,",Y" ) ,cnvtdatetime (sysdate ) )
   ENDCASE
  ENDIF
  RETURN (looback_date )
 END ;Subroutine
 SUBROUTINE  (getcodevaluesfromcodeset (evt_set_rec =vc (ref ) ,evt_cd_rec =vc (ref ) ) =null WITH
  protect )
  DECLARE csidx = i4 WITH noconstant (0 )
  SELECT DISTINCT INTO "nl:"
   FROM (v500_event_set_explode vese )
   WHERE expand (csidx ,1 ,evt_set_rec->cnt ,vese.event_set_cd ,evt_set_rec->qual[csidx ].value )
   DETAIL
    evt_cd_rec->cnt +=1 ,
    stat = alterlist (evt_cd_rec->qual ,evt_cd_rec->cnt ) ,
    evt_cd_rec->qual[evt_cd_rec->cnt ].value = vese.event_cd
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  (geteventsetnamesfromeventsetcds (evt_set_rec =vc (ref ) ,evt_set_name_rec =vc (ref )
  ) =null WITH protect )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (v500_event_set_code v )
   WHERE expand (index ,1 ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
   HEAD REPORT
    cnt = 0 ,
    evt_set_name_rec->cnt = evt_set_rec->cnt ,
    stat = alterlist (evt_set_name_rec->qual ,evt_set_rec->cnt )
   DETAIL
    pos = locateval (index ,1 ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     cnt +=1 ,evt_set_name_rec->qual[pos ].value = v.event_set_name ,pos = locateval (index ,(pos +
      1 ) ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
    ENDWHILE
   FOOT REPORT
    pos = locateval (index ,1 ,evt_set_name_rec->cnt ,"" ,evt_set_name_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     evt_set_name_rec->cnt -=1 ,stat = alterlist (evt_set_name_rec->qual ,evt_set_name_rec->cnt ,(
      pos - 1 ) ) ,pos = locateval (index ,pos ,evt_set_name_rec->cnt ,"" ,evt_set_name_rec->qual[
      index ].value )
    ENDWHILE
    ,evt_set_name_rec->cnt = cnt ,
    stat = alterlist (evt_set_name_rec->qual ,evt_set_name_rec->cnt )
   WITH nocounter ,expand = value (evaluate (floor (((evt_set_rec->cnt - 1 ) / 30 ) ) ,0 ,0 ,1 ) )
  ;end select
 END ;Subroutine
 SUBROUTINE  (returnviewertype (eventclasscd =f8 (val ) ,eventid =f8 (val ) ) =vc WITH protect )
  CALL log_message ("In returnViewerType()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  IF ((eventclasscdpopulated = 0 ) )
   SET mpc_ap_type_cd = uar_get_code_by ("MEANING" ,53 ,"AP" )
   SET mpc_doc_type_cd = uar_get_code_by ("MEANING" ,53 ,"DOC" )
   SET mpc_mdoc_type_cd = uar_get_code_by ("MEANING" ,53 ,"MDOC" )
   SET mpc_rad_type_cd = uar_get_code_by ("MEANING" ,53 ,"RAD" )
   SET mpc_txt_type_cd = uar_get_code_by ("MEANING" ,53 ,"TXT" )
   SET mpc_num_type_cd = uar_get_code_by ("MEANING" ,53 ,"NUM" )
   SET mpc_immun_type_cd = uar_get_code_by ("MEANING" ,53 ,"IMMUN" )
   SET mpc_med_type_cd = uar_get_code_by ("MEANING" ,53 ,"MED" )
   SET mpc_date_type_cd = uar_get_code_by ("MEANING" ,53 ,"DATE" )
   SET mpc_done_type_cd = uar_get_code_by ("MEANING" ,53 ,"DONE" )
   SET mpc_mbo_type_cd = uar_get_code_by ("MEANING" ,53 ,"MBO" )
   SET mpc_procedure_type_cd = uar_get_code_by ("MEANING" ,53 ,"PROCEDURE" )
   SET mpc_grp_type_cd = uar_get_code_by ("MEANING" ,53 ,"GRP" )
   SET mpc_hlatyping_type_cd = uar_get_code_by ("MEANING" ,53 ,"HLATYPING" )
   SET eventclasscdpopulated = 1
  ENDIF
  DECLARE sviewerflag = vc WITH protect ,noconstant ("" )
  CASE (eventclasscd )
   OF mpc_ap_type_cd :
    SET sviewerflag = "AP"
   OF mpc_doc_type_cd :
   OF mpc_mdoc_type_cd :
   OF mpc_rad_type_cd :
    SET sviewerflag = "DOC"
   OF mpc_txt_type_cd :
   OF mpc_num_type_cd :
   OF mpc_immun_type_cd :
   OF mpc_med_type_cd :
   OF mpc_date_type_cd :
   OF mpc_done_type_cd :
    SET sviewerflag = "EVENT"
   OF mpc_mbo_type_cd :
    SET sviewerflag = "MICRO"
   OF mpc_procedure_type_cd :
    SET sviewerflag = "PROC"
   OF mpc_grp_type_cd :
    SET sviewerflag = "GRP"
   OF mpc_hlatyping_type_cd :
    SET sviewerflag = "HLA"
   ELSE
    SET sviewerflag = "STANDARD"
  ENDCASE
  IF ((eventclasscd = mpc_mdoc_type_cd ) )
   SELECT INTO "nl:"
    c2.*
    FROM (clinical_event c1 ),
     (clinical_event c2 )
    PLAN (c1
     WHERE (c1.event_id = eventid ) )
     JOIN (c2
     WHERE (c1.parent_event_id = c2.event_id )
     AND (c2.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100" ) ) )
    HEAD c2.event_id
     IF ((c2.event_class_cd = mpc_ap_type_cd ) ) sviewerflag = "AP"
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  CALL log_message (build ("Exit returnViewerType(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
  RETURN (sviewerflag )
 END ;Subroutine
 SUBROUTINE  (cnvtisodttmtodq8 (isodttmstr =vc ) =dq8 WITH protect )
  DECLARE converteddq8 = dq8 WITH protect ,noconstant (0 )
  SET converteddq8 = cnvtdatetimeutc2 (substring (1 ,10 ,isodttmstr ) ,"YYYY-MM-DD" ,substring (12 ,
    8 ,isodttmstr ) ,"HH:MM:SS" ,4 ,curtimezonedef )
  RETURN (converteddq8 )
 END ;Subroutine
 SUBROUTINE  (cnvtdq8toisodttm (dq8dttm =f8 ) =vc WITH protect )
  DECLARE convertedisodttm = vc WITH protect ,noconstant ("" )
  IF ((dq8dttm > 0.0 ) )
   SET convertedisodttm = build (replace (datetimezoneformat (cnvtdatetime (dq8dttm ) ,
      datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" )
  ELSE
   SET convertedisodttm = nullterm (convertedisodttm )
  ENDIF
  RETURN (convertedisodttm )
 END ;Subroutine
 SUBROUTINE  getorgsecurityflag (null )
  DECLARE org_security_flag = i2 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (dm_info di )
   WHERE (di.info_domain = "SECURITY" )
   AND (di.info_name = "SEC_ORG_RELTN" )
   HEAD REPORT
    org_security_flag = 0
   DETAIL
    org_security_flag = cnvtint (di.info_number )
   WITH nocounter
  ;end select
  RETURN (org_security_flag )
 END ;Subroutine
 SUBROUTINE  (getcomporgsecurityflag (dminfo_name =vc (val ) ) =i2 WITH protect )
  DECLARE org_security_flag = i2 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (dm_info di )
   WHERE (di.info_domain = "SECURITY" )
   AND (di.info_name = dminfo_name )
   HEAD REPORT
    org_security_flag = 0
   DETAIL
    org_security_flag = cnvtint (di.info_number )
   WITH nocounter
  ;end select
  RETURN (org_security_flag )
 END ;Subroutine
 SUBROUTINE  (populateauthorizedorganizations (personid =f8 (val ) ,value_rec =vc (ref ) ) =null
  WITH protect )
  DECLARE organization_cnt = i4 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (prsnl_org_reltn por )
   WHERE (por.person_id = personid )
   AND (por.active_ind = 1 )
   AND (por.beg_effective_dt_tm BETWEEN cnvtdatetime (lower_bound_date ) AND cnvtdatetime (sysdate )
   )
   AND (por.end_effective_dt_tm BETWEEN cnvtdatetime (sysdate ) AND cnvtdatetime (upper_bound_date )
   )
   ORDER BY por.organization_id
   HEAD REPORT
    organization_cnt = 0
   DETAIL
    organization_cnt +=1 ,
    IF ((mod (organization_cnt ,20 ) = 1 ) ) stat = alterlist (value_rec->organizations ,(
      organization_cnt + 19 ) )
    ENDIF
    ,value_rec->organizations[organization_cnt ].organizationid = por.organization_id
   FOOT REPORT
    value_rec->cnt = organization_cnt ,
    stat = alterlist (value_rec->organizations ,organization_cnt )
   WITH nocounter
  ;end select
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (value_rec )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getuserlogicaldomain (id =f8 ) =f8 WITH protect )
  DECLARE returnid = f8 WITH protect ,noconstant (0.0 )
  SELECT INTO "nl:"
   FROM (prsnl p )
   WHERE (p.person_id = id )
   DETAIL
    returnid = p.logical_domain_id
   WITH nocounter
  ;end select
  RETURN (returnid )
 END ;Subroutine
 SUBROUTINE  (getpersonneloverride (ppr_cd =f8 (val ) ) =i2 WITH protect )
  DECLARE override_ind = i2 WITH protect ,noconstant (0 )
  IF ((ppr_cd <= 0.0 ) )
   RETURN (0 )
  ENDIF
  SELECT INTO "nl:"
   FROM (code_value_extension cve )
   WHERE (cve.code_value = ppr_cd )
   AND (cve.code_set = 331 )
   AND (((cve.field_value = "1" ) ) OR ((cve.field_value = "2" ) ))
   AND (cve.field_name = "Override" )
   DETAIL
    override_ind = 1
   WITH nocounter
  ;end select
  RETURN (override_ind )
 END ;Subroutine
 SUBROUTINE  cclimpersonation (null )
  CALL log_message ("In cclImpersonation()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  EXECUTE secrtl
  DECLARE uar_secsetcontext ((hctx = i4 ) ) = i2 WITH image_axp = "secrtl" ,image_aix =
  "libsec.a(libsec.o)" ,uar = "SecSetContext" ,persist
  DECLARE seccntxt = i4 WITH public
  DECLARE namelen = i4 WITH public
  DECLARE domainnamelen = i4 WITH public
  SET namelen = (uar_secgetclientusernamelen () + 1 )
  SET domainnamelen = (uar_secgetclientdomainnamelen () + 2 )
  SET stat = memalloc (name ,1 ,build ("C" ,namelen ) )
  SET stat = memalloc (domainname ,1 ,build ("C" ,domainnamelen ) )
  SET stat = uar_secgetclientusername (name ,namelen )
  SET stat = uar_secgetclientdomainname (domainname ,domainnamelen )
  SET setcntxt = uar_secimpersonate (nullterm (name ) ,nullterm (domainname ) )
  CALL log_message (build ("Exit cclImpersonation(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (geteventsetdisplaysfromeventsetcds (evt_set_rec =vc (ref ) ,evt_set_disp_rec =vc (ref
   ) ) =null WITH protect )
  DECLARE index = i4 WITH protect ,noconstant (0 )
  DECLARE pos = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (v500_event_set_code v )
   WHERE expand (index ,1 ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
   HEAD REPORT
    cnt = 0 ,
    evt_set_disp_rec->cnt = evt_set_rec->cnt ,
    stat = alterlist (evt_set_disp_rec->qual ,evt_set_rec->cnt )
   DETAIL
    pos = locateval (index ,1 ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     cnt +=1 ,evt_set_disp_rec->qual[pos ].value = v.event_set_cd_disp ,pos = locateval (index ,(pos
      + 1 ) ,evt_set_rec->cnt ,v.event_set_cd ,evt_set_rec->qual[index ].value )
    ENDWHILE
   FOOT REPORT
    pos = locateval (index ,1 ,evt_set_disp_rec->cnt ,"" ,evt_set_disp_rec->qual[index ].value ) ,
    WHILE ((pos > 0 ) )
     evt_set_disp_rec->cnt -=1 ,stat = alterlist (evt_set_disp_rec->qual ,evt_set_disp_rec->cnt ,(
      pos - 1 ) ) ,pos = locateval (index ,pos ,evt_set_disp_rec->cnt ,"" ,evt_set_disp_rec->qual[
      index ].value )
    ENDWHILE
    ,evt_set_disp_rec->cnt = cnt ,
    stat = alterlist (evt_set_disp_rec->qual ,evt_set_disp_rec->cnt )
   WITH nocounter ,expand = value (evaluate (floor (((evt_set_rec->cnt - 1 ) / 30 ) ) ,0 ,0 ,1 ) )
  ;end select
 END ;Subroutine
 SUBROUTINE  (decodestringparameter (description =vc (val ) ) =vc WITH protect )
  DECLARE decodeddescription = vc WITH private
  SET decodeddescription = replace (description ,"%3B" ,";" ,0 )
  SET decodeddescription = replace (decodeddescription ,"%25" ,"%" ,0 )
  RETURN (decodeddescription )
 END ;Subroutine
 SUBROUTINE  (urlencode (json =vc (val ) ) =vc WITH protect )
  DECLARE encodedjson = vc WITH private
  SET encodedjson = replace (json ,char (91 ) ,"%5B" ,0 )
  SET encodedjson = replace (encodedjson ,char (123 ) ,"%7B" ,0 )
  SET encodedjson = replace (encodedjson ,char (58 ) ,"%3A" ,0 )
  SET encodedjson = replace (encodedjson ,char (125 ) ,"%7D" ,0 )
  SET encodedjson = replace (encodedjson ,char (93 ) ,"%5D" ,0 )
  SET encodedjson = replace (encodedjson ,char (44 ) ,"%2C" ,0 )
  SET encodedjson = replace (encodedjson ,char (34 ) ,"%22" ,0 )
  RETURN (encodedjson )
 END ;Subroutine
 SUBROUTINE  (istaskgranted (task_number =i4 (val ) ) =i2 WITH protect )
  CALL log_message ("In IsTaskGranted" ,log_level_debug )
  DECLARE fntime = f8 WITH private ,noconstant (curtime3 )
  DECLARE task_granted = i2 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (task_access ta ),
    (application_group ag )
   PLAN (ta
    WHERE (ta.task_number = task_number )
    AND (ta.app_group_cd > 0.0 ) )
    JOIN (ag
    WHERE (ag.position_cd = reqinfo->position_cd )
    AND (ag.app_group_cd = ta.app_group_cd )
    AND (ag.beg_effective_dt_tm <= cnvtdatetime (sysdate ) )
    AND (ag.end_effective_dt_tm > cnvtdatetime (sysdate ) ) )
   DETAIL
    task_granted = 1
   WITH nocounter ,maxqual (ta ,1 )
  ;end select
  CALL log_message (build ("Exit IsTaskGranted - " ,build2 (cnvtint ((curtime3 - fntime ) ) ) ,
    "0 ms" ) ,log_level_debug )
  RETURN (task_granted )
 END ;Subroutine
 DECLARE lapp_num = i4 WITH protect ,constant (3202004 )
 DECLARE ltask_num = i4 WITH protect ,constant (3202004 )
 DECLARE ecrmok = i2 WITH protect ,constant (0 )
 DECLARE esrvok = i2 WITH protect ,constant (0 )
 DECLARE hfailind = i2 WITH protect ,constant (0 )
 DECLARE string40 = i4 WITH protect ,constant (40 )
 DECLARE hmsg = i4 WITH protect ,noconstant (0 )
 DECLARE happ = i4 WITH protect ,noconstant (0 )
 DECLARE htask = i4 WITH protect ,noconstant (0 )
 DECLARE hstep = i4 WITH protect ,noconstant (0 )
 DECLARE hreq = i4 WITH protect ,noconstant (0 )
 DECLARE hrep = i4 WITH protect ,noconstant (0 )
 DECLARE hstatusdata = i4 WITH protect ,noconstant (0 )
 DECLARE ncrmstat = i2 WITH protect ,noconstant (0 )
 DECLARE nsrvstat = i2 WITH protect ,noconstant (0 )
 DECLARE g_perform_failed = i2 WITH protect ,noconstant (0 )
 SUBROUTINE  (initializeapptaskrequest (recorddata =vc (ref ) ,appnumber =i4 (val ) ,tasknumber =i4 (
   val ) ,requestnumber =i4 (val ) ,donotexitonfail =i2 (val ,0 ) ) =null WITH protect )
  SET ncrmstat = uar_crmbeginapp (appnumber ,happ )
  IF ((((ncrmstat != ecrmok ) ) OR ((happ = 0 ) )) )
   IF (donotexitonfail )
    CALL echo ("InitializeAppTaskRequest: BEGIN Application Handle failed" )
    CALL exit_servicerequest (happ ,htask ,hstep )
    RETURN
   ELSE
    CALL handleerror ("BEGIN" ,"F" ,"Application Handle" ,cnvtstring (ncrmstat ) ,recorddata )
    CALL exit_servicerequest (happ ,htask ,hstep )
   ENDIF
  ENDIF
  SET ncrmstat = uar_crmbegintask (happ ,tasknumber ,htask )
  IF ((((ncrmstat != ecrmok ) ) OR ((htask = 0 ) )) )
   IF (donotexitonfail )
    CALL echo ("InitializeAppTaskRequest: BEGIN Task Handle failed" )
    CALL exit_servicerequest (happ ,htask ,hstep )
    RETURN
   ELSE
    CALL handleerror ("BEGIN" ,"F" ,"Task Handle" ,cnvtstring (ncrmstat ) ,recorddata )
    CALL exit_servicerequest (happ ,htask ,hstep )
   ENDIF
  ENDIF
  SET ncrmstat = uar_crmbeginreq (htask ,0 ,requestnumber ,hstep )
  IF ((((ncrmstat != ecrmok ) ) OR ((hstep = 0 ) )) )
   IF (donotexitonfail )
    CALL echo ("InitializeAppTaskRequest: BEGIN Request Handle failed" )
    CALL exit_servicerequest (happ ,htask ,hstep )
    RETURN
   ELSE
    CALL handleerror ("BEGIN" ,"F" ,"Req Handle" ,cnvtstring (ncrmstat ) ,recorddata )
    CALL exit_servicerequest (happ ,htask ,hstep )
   ENDIF
  ENDIF
  SET hreq = uar_crmgetrequest (hstep )
  IF ((hreq = 0 ) )
   IF (donotexitonfail )
    CALL echo ("InitializeAppTaskRequest: GET Request Handle failed" )
    CALL exit_servicerequest (happ ,htask ,hstep )
    RETURN
   ELSE
    CALL handleerror ("GET" ,"F" ,"Req Handle" ,cnvtstring (ncrmstat ) ,recorddata )
    CALL exit_servicerequest (happ ,htask ,hstep )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (initializerequest (recorddata =vc (ref ) ,requestnumber =i4 (val ) ) =null WITH
  protect )
  CALL initializeapptaskrequest (recorddata ,lapp_num ,ltask_num ,requestnumber )
 END ;Subroutine
 SUBROUTINE  (initializesrvrequest (recorddata =vc (ref ) ,requestnumber =i4 (val ) ,donotexitonfail
  =i2 (val ,0 ) ) =null WITH protect )
  SET hmsg = uar_srvselectmessage (requestnumber )
  IF ((hmsg = hfailind ) )
   IF (donotexitonfail )
    CALL echo ("InitializeSRVRequest: Create Message handle failed" )
    CALL exit_srvrequest (hmsg ,hreq ,hrep )
    RETURN
   ELSE
    CALL handleerror ("CREATE" ,"F" ,"Message Handle" ,cnvtstring (hmsg ) ,recorddata )
    CALL exit_srvrequest (hmsg ,hreq ,hrep )
   ENDIF
  ENDIF
  SET hreq = uar_srvcreaterequest (hmsg )
  IF ((hreq = hfailind ) )
   IF (donotexitonfail )
    CALL echo ("InitializeSRVRequest: Create Request Handle failed" )
    CALL exit_srvrequest (hmsg ,hreq ,hrep )
    RETURN
   ELSE
    CALL handleerror ("CREATE" ,"F" ,"Req Handle" ,cnvtstring (hreq ) ,recorddata )
    CALL exit_srvrequest (hmsg ,hreq ,hrep )
   ENDIF
  ENDIF
  SET hrep = uar_srvcreatereply (hmsg )
  IF ((hrep = hfailind ) )
   IF (donotexitonfail )
    CALL echo ("InitializeSRVRequest: Create Reply Handle failed" )
    CALL exit_srvrequest (hmsg ,hreq ,hrep )
    RETURN
   ELSE
    CALL handleerror ("CREATE" ,"F" ,"Rep Handle" ,cnvtstring (hrep ) ,recorddata )
    CALL exit_srvrequest (hmsg ,hreq ,hrep )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getproviderposition (prsnl_id =f8 ) =f8 WITH protect )
  DECLARE prsnl_position_cd = f8 WITH noconstant (0 ) ,protect
  SELECT INTO "nl:"
   FROM (prsnl p )
   PLAN (p
    WHERE (p.person_id = prsnl_id )
    AND (p.end_effective_dt_tm > cnvtdatetime (sysdate ) ) )
   DETAIL
    prsnl_position_cd = p.position_cd
   WITH nocounter
  ;end select
  RETURN (prsnl_position_cd )
 END ;Subroutine
 SUBROUTINE  (createdatetimefromhandle (hhandle =i4 (ref ) ,sdatedataelement =vc (val ) ,
  stimezonedataelement =vc (val ) ) =vc WITH protect )
  DECLARE time_zone = i4 WITH noconstant (0 ) ,protect
  DECLARE return_val = vc WITH noconstant ("" ) ,protect
  SET stat = uar_srvgetdate (hhandle ,nullterm (sdatedataelement ) ,recdate->datetime )
  IF ((stimezonedataelement != "" ) )
   SET time_zone = uar_srvgetlong (hhandle ,nullterm (stimezonedataelement ) )
  ENDIF
  IF (validate (recdate->datetime ,0 ) )
   SET return_val = build (replace (datetimezoneformat (cnvtdatetime (recdate->datetime ) ,
      datetimezonebyname ("UTC" ) ,"yyyy-MM-dd HH:mm:ss" ,curtimezonedef ) ," " ,"T" ,1 ) ,"Z" )
  ELSE
   SET return_val = ""
  ENDIF
  RETURN (return_val )
 END ;Subroutine
 SUBROUTINE  (handleerror (operationname =vc ,operationstatus =c1 ,targetobjectname =vc ,
  targetobjectvalue =vc ,recorddata =vc (ref ) ) =null WITH protect )
  SET recorddata->status_data.status = "F"
  IF ((size (recorddata->status_data.subeventstatus ,5 ) = 0 ) )
   SET stat = alterlist (recorddata->status_data.subeventstatus ,1 )
  ENDIF
  SET recorddata->status_data.subeventstatus[1 ].operationname = operationname
  SET recorddata->status_data.subeventstatus[1 ].operationstatus = operationstatus
  SET recorddata->status_data.subeventstatus[1 ].targetobjectname = targetobjectname
  SET recorddata->status_data.subeventstatus[1 ].targetobjectvalue = targetobjectvalue
  SET g_perform_failed = 1
 END ;Subroutine
 SUBROUTINE  (handlenodata (operationname =vc ,operationstatus =c1 ,targetobjectname =vc ,
  targetobjectvalue =vc ,recorddata =vc (ref ) ) =null WITH protect )
  SET recorddata->status_data.status = "Z"
  IF ((size (recorddata->status_data.subeventstatus ,5 ) = 0 ) )
   SET stat = alterlist (recorddata->status_data.subeventstatus ,1 )
  ENDIF
  SET recorddata->status_data.subeventstatus[1 ].operationname = operationname
  SET recorddata->status_data.subeventstatus[1 ].operationstatus = operationstatus
  SET recorddata->status_data.subeventstatus[1 ].targetobjectname = targetobjectname
  SET recorddata->status_data.subeventstatus[1 ].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SUBROUTINE  (exit_servicerequest (happ =i4 ,htask =i4 ,hstep =i4 ) =null WITH protect )
  IF ((hstep != 0 ) )
   SET ncrmstat = uar_crmendreq (hstep )
  ENDIF
  IF ((htask != 0 ) )
   SET ncrmstat = uar_crmendtask (htask )
  ENDIF
  IF ((happ != 0 ) )
   SET ncrmstat = uar_crmendapp (happ )
  ENDIF
  IF ((g_perform_failed = 1 ) )
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE  exit_srvrequest (hmsg ,hreq ,hrep )
  IF ((hmsg != 0 ) )
   SET nsrvstat = uar_srvdestroyinstance (hmsg )
  ENDIF
  IF ((hreq != 0 ) )
   SET nsrvstat = uar_srvdestroyinstance (hreq )
  ENDIF
  IF ((hrep != 0 ) )
   SET nsrvstat = uar_srvdestroyinstance (hrep )
  ENDIF
  IF ((g_perform_failed = 1 ) )
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE  (validatereply (ncrmstat =i4 ,hstep =i4 ,recorddata =vc (ref ) ,zeroforceexit =i2 ) =i4
  WITH protect )
  DECLARE soperationname = vc WITH noconstant ("" ) ,protect
  DECLARE soperationstatus = vc WITH noconstant ("" ) ,protect
  DECLARE stargetobjectname = vc WITH noconstant ("" ) ,protect
  DECLARE stargetobjectvalue = vc WITH noconstant ("" ) ,protect
  DECLARE sstatus = c1 WITH noconstant (" " ) ,protect
  IF ((ncrmstat = ecrmok ) )
   SET hrep = uar_crmgetreply (hstep )
   SET hstatusdata = uar_srvgetstruct (hrep ,"status_data" )
   SET sstatus = uar_srvgetstringptr (hstatusdata ,"status" )
   IF ((validate (debug_ind ,0 ) = 1 ) )
    CALL echo (build ("Status: " ,sstatus ) )
   ENDIF
   IF ((sstatus = "Z" ) )
    CALL handlenodata ("PERFORM" ,"Z" ,srv_request ,cnvtstring (ncrmstat ) ,recorddata )
    IF ((zeroforceexit = 1 ) )
     CALL exit_servicerequest (happ ,htask ,hstep )
     GO TO exit_script
    ENDIF
   ELSEIF ((sstatus != "S" ) )
    IF ((uar_srvgetitemcount (hstatusdata ,"subeventstatus" ) > 0 ) )
     SET hitem = uar_srvgetitem (hstatusdata ,"subeventstatus" ,0 )
     SET soperationname = uar_srvgetstringptr (hitem ,"OperationName" )
     SET soperationstatus = uar_srvgetstringptr (hitem ,"OperationStatus" )
     SET stargetobjectname = uar_srvgetstringptr (hitem ,"TargetObjectName" )
     SET stargetobjectvalue = uar_srvgetstringptr (hitem ,"TargetObjectValue" )
    ENDIF
    CALL handleerror (soperationname ,sstatus ,stargetobjectname ,stargetobjectvalue ,recorddata )
    CALL exit_servicerequest (happ ,htask ,hstep )
   ENDIF
   RETURN (hrep )
  ELSE
   CALL handleerror ("PERFORM" ,"F" ,srv_request ,cnvtstring (ncrmstat ) ,recorddata )
   CALL exit_servicerequest (happ ,htask ,hstep )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (validatesubreply (ncrmstat =i4 ,hstep =i4 ,recorddata =vc (ref ) ) =i4 WITH protect )
  DECLARE soperationname = vc WITH noconstant ("" ) ,protect
  DECLARE soperationstatus = vc WITH noconstant ("" ) ,protect
  DECLARE stargetobjectname = vc WITH noconstant ("" ) ,protect
  DECLARE stargetobjectvalue = vc WITH noconstant ("" ) ,protect
  DECLARE sstatus = c1 WITH noconstant (" " ) ,protect
  IF ((ncrmstat = ecrmok ) )
   SET hrep = uar_crmgetreply (hstep )
   SET hstatusdata = uar_srvgetstruct (hrep ,"status_data" )
   SET sstatus = uar_srvgetstringptr (hstatusdata ,"status" )
   IF ((validate (debug_ind ,0 ) = 1 ) )
    CALL echo (build ("Status: " ,sstatus ) )
   ENDIF
   IF ((sstatus != "S" )
   AND (sstatus != "Z" ) )
    IF ((uar_srvgetitemcount (hstatusdata ,"subeventstatus" ) > 0 ) )
     SET hitem = uar_srvgetitem (hstatusdata ,"subeventstatus" ,0 )
     SET soperationname = uar_srvgetstringptr (hitem ,"OperationName" )
     SET soperationstatus = uar_srvgetstringptr (hitem ,"OperationStatus" )
     SET stargetobjectname = uar_srvgetstringptr (hitem ,"TargetObjectName" )
     SET stargetobjectvalue = uar_srvgetstringptr (hitem ,"TargetObjectValue" )
    ENDIF
    CALL handleerror (soperationname ,sstatus ,stargetobjectname ,stargetobjectvalue ,recorddata )
    CALL exit_servicerequest (happ ,htask ,hstep )
   ENDIF
   RETURN (hrep )
  ELSE
   CALL handleerror ("PERFORM" ,"F" ,srv_request ,cnvtstring (ncrmstat ) ,recorddata )
   CALL exit_servicerequest (happ ,htask ,hstep )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (validatereplyindicatordynamic (ncrmstat =i4 ,hstep =i4 ,recorddata =vc (ref ) ,
  zeroforceexit =i2 ,recordname =vc ,statusblock =vc ) =i4 WITH protect )
  DECLARE soperationname = vc WITH noconstant ("" ) ,protect
  DECLARE soperationstatus = vc WITH noconstant ("" ) ,protect
  DECLARE stargetobjectname = vc WITH noconstant ("" ) ,protect
  DECLARE stargetobjectvalue = vc WITH noconstant ("" ) ,protect
  DECLARE successind = i2 WITH noconstant (0 ) ,protect
  DECLARE errormessage = vc WITH noconstant ("" ) ,protect
  IF ((ncrmstat = ecrmok ) )
   SET hrep = uar_crmgetreply (hstep )
   SET hstatusdata = uar_srvgetstruct (hrep ,nullterm (statusblock ) )
   SET successind = uar_srvgetshort (hstatusdata ,"success_ind" )
   SET errormessage = uar_srvgetstringptr (hstatusdata ,"debug_error_message" )
   IF ((validate (debug_ind ,0 ) = 1 ) )
    CALL echo (build ("Status Indicator: " ,successind ) )
    CALL echo (build ("Error Message: " ,errormessage ) )
   ENDIF
   IF ((successind != 1 ) )
    CALL handleerror ("ValidateReplyIndicator" ,"F" ,srv_request ,errormessage ,recorddata )
    CALL exit_servicerequest (happ ,htask ,hstep )
   ELSEIF ((trim (recordname ) != "" ) )
    SET resultlistcnt = uar_srvgetitemcount (hrep ,nullterm (recordname ) )
    IF ((resultlistcnt = 0 ) )
     IF ((validate (debug_ind ,0 ) = 1 ) )
      CALL echo (build ("ZERO RESULTS found in [" ,trim (recordname ,3 ) ,"]" ) )
     ENDIF
     CALL handlenodata ("PERFORM" ,"Z" ,srv_request ,cnvtstring (ncrmstat ) ,recorddata )
     IF ((zeroforceexit = 1 ) )
      CALL exit_servicerequest (happ ,htask ,hstep )
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   RETURN (hrep )
  ELSE
   CALL handleerror ("PERFORM" ,"F" ,srv_request ,cnvtstring (ncrmstat ) ,recorddata )
   CALL exit_servicerequest (happ ,htask ,hstep )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (validatereplyindicator (ncrmstat =i4 ,hstep =i4 ,recorddata =vc (ref ) ,zeroforceexit =
  i2 ,recordname =vc ) =i4 WITH protect )
  CALL validatereplyindicatordynamic (ncrmstat ,hstep ,recorddata ,zeroforceexit ,recordname ,
   "status_data" )
 END ;Subroutine
 SUBROUTINE  (validatesrvreplyind (nsrvstat =i4 ,recorddata =vc (ref ) ,zeroforceexit =i2 ,
  recordname =vc ,statusblock =vc ) =i4 WITH protect )
  DECLARE soperationname = vc WITH noconstant ("" ) ,protect
  DECLARE soperationstatus = vc WITH noconstant ("" ) ,protect
  DECLARE stargetobjectname = vc WITH noconstant ("" ) ,protect
  DECLARE stargetobjectvalue = vc WITH noconstant ("" ) ,protect
  DECLARE successind = i2 WITH noconstant (0 ) ,protect
  DECLARE errormessage = vc WITH noconstant ("" ) ,protect
  IF ((nsrvstat = esrvok ) )
   SET hstatusdata = uar_srvgetstruct (hrep ,nullterm (statusblock ) )
   SET successind = uar_srvgetshort (hstatusdata ,"success_ind" )
   SET errormessage = uar_srvgetstringptr (hstatusdata ,"debug_error_message" )
   IF ((validate (debug_ind ,0 ) = 1 ) )
    CALL echo (build ("Status Indicator: " ,successind ) )
    CALL echo (build ("Error Message: " ,errormessage ) )
   ENDIF
   IF ((successind != 1 ) )
    CALL handleerror ("ValidateReply" ,"F" ,srv_request ,errormessage ,recorddata )
    CALL exit_srvrequest (hmsg ,hreq ,hrep )
   ELSEIF ((trim (recordname ) != "" ) )
    SET resultlistcnt = uar_srvgetitemcount (hrep ,nullterm (recordname ) )
    IF ((resultlistcnt = 0 ) )
     IF ((validate (debug_ind ,0 ) = 1 ) )
      CALL echo (build ("ZERO RESULTS found in [" ,trim (recordname ,3 ) ,"]" ) )
     ENDIF
     CALL handlenodata ("PERFORM" ,"Z" ,srv_request ,cnvtstring (nsrvstat ) ,recorddata )
     IF ((zeroforceexit = 1 ) )
      CALL exit_srvrequest (hmsg ,hreq ,hrep )
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   RETURN (hrep )
  ELSE
   CALL handleerror ("PERFORM" ,"F" ,srv_request ,cnvtstring (nsrvstat ) ,recorddata )
   CALL exit_srvrequest (hmsg ,hreq ,hrep )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (validatesrvreply (nsrvstat =i4 ,recorddata =vc (ref ) ,zeroforceexit =i2 ) =i4 WITH
  protect )
  DECLARE soperationname = vc WITH noconstant ("" ) ,protect
  DECLARE soperationstatus = vc WITH noconstant ("" ) ,protect
  DECLARE stargetobjectname = vc WITH noconstant ("" ) ,protect
  DECLARE stargetobjectvalue = vc WITH noconstant ("" ) ,protect
  DECLARE sstatus = c1 WITH noconstant (" " ) ,protect
  IF ((nsrvstat = esrvok ) )
   SET hstatusdata = uar_srvgetstruct (hrep ,"status_data" )
   SET sstatus = uar_srvgetstringptr (hstatusdata ,"status" )
   IF ((validate (debug_ind ,0 ) = 1 ) )
    CALL echo (build ("Status: " ,sstatus ) )
   ENDIF
   IF ((sstatus = "Z" ) )
    CALL handlenodata ("PERFORM" ,"Z" ,srv_request ,cnvtstring (nsrvstat ) ,recorddata )
    IF ((zeroforceexit = 1 ) )
     CALL exit_srvrequest (hmsg ,hreq ,hrep )
     GO TO exit_script
    ENDIF
   ELSEIF ((sstatus != "S" ) )
    IF ((uar_srvgetitemcount (hstatusdata ,"subeventstatus" ) > 0 ) )
     SET hitem = uar_srvgetitem (hstatusdata ,"subeventstatus" ,0 )
     SET soperationname = uar_srvgetstringptr (hitem ,"OperationName" )
     SET soperationstatus = uar_srvgetstringptr (hitem ,"OperationStatus" )
     SET stargetobjectname = uar_srvgetstringptr (hitem ,"TargetObjectName" )
     SET stargetobjectvalue = uar_srvgetstringptr (hitem ,"TargetObjectValue" )
    ENDIF
    CALL handleerror (soperationname ,sstatus ,stargetobjectname ,stargetobjectvalue ,recorddata )
    CALL exit_srvrequest (hmsg ,hreq ,hrep )
   ENDIF
   RETURN (hrep )
  ELSE
   CALL handleerror ("PERFORM" ,"F" ,srv_request ,cnvtstring (nsrvstat ) ,recorddata )
   CALL exit_srvrequest (hmsg ,hreq ,hrep )
  ENDIF
 END ;Subroutine
 IF ((validate (check_priv_request ) != 1 ) )
  RECORD check_priv_request (
    1 patient_user_criteria
      2 user_id = f8
      2 patient_user_relationship_cd = f8
    1 event_privileges
      2 event_set_level
        3 event_sets [* ]
          4 event_set_name = vc
        3 view_results_ind = i2
        3 add_documentation_ind = i2
        3 modify_documentation_ind = i2
        3 unchart_documentation_ind = i2
        3 sign_documentation_ind = i2
      2 event_code_level
        3 event_codes [* ]
          4 event_cd = f8
        3 view_results_ind = i2
        3 add_documentation_ind = i2
        3 modify_documentation_ind = i2
        3 unchart_documentation_ind = i2
        3 sign_documentation_ind = i2
  )
 ENDIF
 IF ((validate (check_priv_reply ) != 1 ) )
  RECORD check_priv_reply (
    1 patient_user_information
      2 user_id = f8
      2 patient_user_relationship_cd = f8
      2 role_id = f8
    1 event_privileges
      2 view_results
        3 granted
          4 event_sets [* ]
            5 event_set_name = vc
          4 event_codes [* ]
            5 event_cd = f8
        3 status
          4 success_ind = i2
      2 document_section_viewing
        3 granted
          4 event_codes [* ]
            5 event_cd = f8
        3 status
          4 success_ind = i2
      2 add_documentation
        3 granted
          4 event_sets [* ]
            5 event_set_name = vc
          4 event_codes [* ]
            5 event_cd = f8
        3 status
          4 success_ind = i2
      2 modify_documentation
        3 granted
          4 event_sets [* ]
            5 event_set_name = vc
          4 event_codes [* ]
            5 event_cd = f8
        3 status
          4 success_ind = i2
      2 unchart_documentation
        3 granted
          4 event_sets [* ]
            5 event_set_name = vc
          4 event_codes [* ]
            5 event_cd = f8
        3 status
          4 success_ind = i2
      2 sign_documentation
        3 granted
          4 event_sets [* ]
            5 event_set_name = vc
          4 event_codes [* ]
            5 event_cd = f8
        3 status
          4 success_ind = i2
    1 transaction_status
      2 success_ind = i2
      2 debug_error_message = vc
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SUBROUTINE  (checkprivileges (prsnlid =f8 (val ) ,pprcd =f8 (val ) ) =null WITH protect )
  SET check_priv_request->patient_user_criteria.user_id = prsnlid
  SET check_priv_request->patient_user_criteria.patient_user_relationship_cd = pprcd
  EXECUTE mp_check_privs WITH replace ("REQUEST" ,"CHECK_PRIV_REQUEST" ) ,
  replace ("REPLY" ,"CHECK_PRIV_REPLY" )
 END ;Subroutine
 SUBROUTINE  (explodeandinitbyeventset (eventsetrec =vc (ref ) ) =null WITH protect )
  SET break_cnt = 50
  SET idx = 0
  SET idxstart = 1
  SET nrecordsize = size (eventsetrec->qual ,5 )
  IF ((nrecordsize = 0 ) )
   RETURN
  ENDIF
  SET noptimizedtotal = (ceil ((cnvtreal (nrecordsize ) / break_cnt ) ) * break_cnt )
  SET stat = alterlist (eventsetrec->qual ,noptimizedtotal )
  FOR (i = (nrecordsize + 1 ) TO noptimizedtotal )
   SET eventsetrec->qual[i ].value = eventsetrec->qual[nrecordsize ].value
  ENDFOR
  SELECT DISTINCT INTO "nl:"
   v.event_cd
   FROM (dummyt d WITH seq = value ((1 + ((noptimizedtotal - 1 ) / break_cnt ) ) ) ),
    (v500_event_set_explode v )
   PLAN (d
    WHERE initarray (idxstart ,evaluate (d.seq ,1 ,1 ,(idxstart + break_cnt ) ) ) )
    JOIN (v
    WHERE expand (idx ,idxstart ,((idxstart + break_cnt ) - 1 ) ,v.event_set_cd ,eventsetrec->qual[
     idx ].value ,break_cnt ) )
   ORDER BY v.event_cd
   HEAD REPORT
    eccnt = 0
   HEAD v.event_cd
    eccnt +=1 ,
    IF ((eccnt > size (check_priv_request->event_privileges.event_code_level.event_codes ,5 ) ) )
     stat = alterlist (check_priv_request->event_privileges.event_code_level.event_codes ,(eccnt + 9
      ) )
    ENDIF
    ,check_priv_request->event_privileges.event_code_level.event_codes[eccnt ].event_cd = v.event_cd
   DETAIL
    donothing = 0
   FOOT REPORT
    stat = alterlist (check_priv_request->event_privileges.event_code_level.event_codes ,eccnt )
   WITH nocounter
  ;end select
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (check_priv_request )
  ENDIF
 END ;Subroutine
 IF ((validate (priv_request ) != 1 ) )
  RECORD priv_request (
    1 patient_user_criteria
      2 user_id = f8
      2 patient_user_relationship_cd = f8
    1 privilege_criteria
      2 privileges [* ]
        3 privilege_cd = f8
      2 locations [* ]
        3 location_id = f8
  )
 ENDIF
 IF ((validate (priv_reply ) != 1 ) )
  RECORD priv_reply (
    1 patient_user_information
      2 user_id = f8
      2 patient_user_relationship_cd = f8
      2 role_id = f8
    1 privileges [* ]
      2 privilege_cd = f8
      2 default [* ]
        3 granted_ind = i2
        3 exceptions [* ]
          4 entity_name = vc
          4 type_cd = f8
          4 id = f8
        3 status
          4 success_ind = i2
      2 locations [* ]
        3 location_id = f8
        3 privilege
          4 granted_ind = i2
          4 exceptions [* ]
            5 entity_name = vc
            5 type_cd = f8
            5 id = f8
          4 status
            5 success_ind = i2
    1 transaction_status
      2 success_ind = i2
      2 debug_error_message = vc
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE privoverride = i2 WITH noconstant (0 ) ,protect
 DECLARE prividx = i4 WITH noconstant (0 ) ,protect
 DECLARE prevprivcd = f8 WITH noconstant (0.0 ) ,protect
 DECLARE exceptidx = i4 WITH noconstant (0 ) ,protect
 DECLARE exceptioncnt = i4 WITH noconstant (0 ) ,protect
 DECLARE privgranted = i2 WITH noconstant (0 ) ,protect
 SUBROUTINE  (getsingleprivilegebycode (privcode =f8 (val ) ,userid =f8 (val ) ,pprcode =f8 (val )
  ) =i2 WITH protect )
  CALL log_message ("In GetSinglePrivilegeByCode()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (curtime3 ) ,private
  DECLARE privvalue = i2 WITH protect ,noconstant (0 )
  SET stat = alterlist (priv_request->privilege_criteria.privileges ,1 )
  SET priv_request->privilege_criteria.privileges[1 ].privilege_cd = privcode
  SET priv_request->patient_user_criteria.user_id = userid
  SET priv_request->patient_user_criteria.patient_user_relationship_cd = pprcode
  EXECUTE mp_get_privs_by_codes WITH replace ("REQUEST" ,"PRIV_REQUEST" ) ,
  replace ("REPLY" ,"PRIV_REPLY" )
  SET privvalue = isprivilegesgranted (privcode )
  CALL log_message (build ("Exit GetSinglePrivilegeByCode(), Elapsed time in seconds:" ,((curtime3 -
    begin_date_time ) / 100 ) ) ,log_level_debug )
  RETURN (privvalue )
 END ;Subroutine
 SUBROUTINE  (getprivilegesbycodes (prsnlid =f8 (val ) ,pprcd =f8 (val ) ) =null WITH protect )
  IF ((prsnlid > 0 )
  AND (pprcd > 0 ) )
   SET priv_request->patient_user_criteria.user_id = prsnlid
   SET priv_request->patient_user_criteria.patient_user_relationship_cd = pprcd
   EXECUTE mp_get_privs_by_codes WITH replace ("REQUEST" ,"PRIV_REQUEST" ) ,
   replace ("REPLY" ,"PRIV_REPLY" )
  ELSE
   SET privoverride = 1
  ENDIF
 END ;Subroutine
 SUBROUTINE  (isprivilegesgranted (privcd =f8 (val ) ) =i2 WITH protect )
  IF (privoverride )
   RETURN (1 )
  ENDIF
  SET prividx = locateprivilegecode (privcd )
  IF ((prividx > 0 ) )
   IF ((priv_reply->privileges[prividx ].default[1 ].granted_ind = 1 ) )
    RETURN (1 )
   ELSE
    SET exceptcnt = size (priv_reply->privileges[prividx ].default[1 ].exceptions ,5 )
    IF ((exceptcnt > 0 ) )
     RETURN (1 )
    ENDIF
   ENDIF
  ENDIF
  RETURN (0 )
 END ;Subroutine
 SUBROUTINE  (isprivilegesgrantedwithoutexceptions (privcd =f8 (val ) ) =i2 WITH protect )
  IF (privoverride )
   RETURN (1 )
  ENDIF
  SET prividx = locateprivilegecode (privcd )
  IF ((prividx > 0 ) )
   IF ((priv_reply->privileges[prividx ].default[1 ].granted_ind = 1 ) )
    RETURN (1 )
   ENDIF
  ENDIF
  RETURN (0 )
 END ;Subroutine
 SUBROUTINE  (locateprivilegecode (privcd =f8 (val ) ) =i4 WITH protect )
  IF ((((prevprivcd != privcd ) ) OR ((prividx = 0 ) )) )
   SET prividx = 0
   SET prividx = locateval (prividx ,1 ,size (priv_reply->privileges ,5 ) ,privcd ,priv_reply->
    privileges[prividx ].privilege_cd )
   SET prevprivcd = privcd
  ENDIF
  RETURN (prividx )
 END ;Subroutine
 SUBROUTINE  (locateexceptioncode (exceptioncd =f8 (val ) ,startpoint =i4 (val ,1 ) ) =i4 WITH
  protect )
  IF ((prividx > 0 ) )
   SET exceptidx = 0
   SET exceptidx = locateval (exceptidx ,startpoint ,size (priv_reply->privileges[prividx ].default[
     1 ].exceptions ,5 ) ,exceptioncd ,priv_reply->privileges[prividx ].default[1 ].exceptions[
    exceptidx ].id )
   RETURN (exceptidx )
  ENDIF
  RETURN (0 )
 END ;Subroutine
 SUBROUTINE  (isdisplayable (privcd =f8 (val ) ,exceptioncd =f8 (val ) ) =i2 WITH protect )
  IF (privoverride )
   RETURN (1 )
  ENDIF
  SET curalias privilege_rec priv_reply->privileges[prividx ]
  SET curalias default_rec priv_reply->privileges[prividx ].default[1 ]
  CALL locateprivilegecode (privcd )
  IF ((prividx = 0 ) )
   RETURN (1 )
  ELSEIF ((size (privilege_rec->default ,5 ) > 0 ) )
   SET privgranted = default_rec->granted_ind
   SET exceptioncnt = size (default_rec->exceptions ,5 )
   IF ((privgranted = 1 ) )
    IF ((exceptioncnt > 0 )
    AND (locateexceptioncode (exceptioncd ) > 0 ) )
     RETURN (0 )
    ELSE
     RETURN (1 )
    ENDIF
   ELSE
    IF ((exceptioncnt > 0 )
    AND (locateexceptioncode (exceptioncd ) > 0 ) )
     RETURN (1 )
    ELSE
     RETURN (0 )
    ENDIF
   ENDIF
  ENDIF
  SET curalias privilege_rec off
  SET curalias default_rec off
 END ;Subroutine
 SUBROUTINE  (istypedisplayable (privcd =f8 (val ) ,exceptioncd =f8 (val ) ,exceptiontypecd =f8 (val
   ) ) =i2 WITH protect )
  IF (privoverride )
   RETURN (1 )
  ENDIF
  SET curalias privilege_rec priv_reply->privileges[prividx ]
  SET curalias default_rec priv_reply->privileges[prividx ].default[1 ]
  SET curalias exception_rec priv_reply->privileges[prividx ].default[1 ].exceptions[exceptidx ]
  CALL locateprivilegecode (privcd )
  IF ((prividx = 0 ) )
   RETURN (1 )
  ELSEIF ((size (privilege_rec->default ,5 ) > 0 ) )
   SET privgranted = default_rec->granted_ind
   SET exceptioncnt = size (default_rec->exceptions ,5 )
   IF ((privgranted = 1 ) )
    IF ((exceptioncnt > 0 ) )
     SET pos = locateexceptioncode (exceptioncd )
     WHILE ((pos > 0 ) )
      IF ((exception_rec->type_cd = exceptiontypecd ) )
       RETURN (0 )
      ENDIF
      SET pos = locateexceptioncode (exceptioncd ,(pos + 1 ) )
     ENDWHILE
     RETURN (1 )
    ELSE
     RETURN (1 )
    ENDIF
   ELSE
    IF ((exceptioncnt > 0 ) )
     SET pos = locateexceptioncode (exceptioncd ,0 )
     WHILE ((pos > 0 ) )
      IF ((exception_rec->type_cd = exceptiontypecd ) )
       RETURN (1 )
      ENDIF
      SET pos = locateexceptioncode (exceptioncd ,(pos + 1 ) )
     ENDWHILE
     RETURN (0 )
    ELSE
     RETURN (0 )
    ENDIF
   ENDIF
  ENDIF
  SET curalias privilege_rec off
  SET curalias default_rec off
  SET curalias exception_rec off
 END ;Subroutine
 SUBROUTINE  (addtoeventprsnllist (hparent =i4 (ref ) ,personid =f8 ,actionprsnlid =f8 ,actiontype =
  f8 ,actionstatus =f8 ,actiondttm =dq8 ,recorddata =vc (ref ) ) =null )
  DECLARE hprsnl = i4 WITH noconstant (0 ) ,private
  IF ((hparent = 0 ) )
   CALL handleerror ("AddToEventPrsnlList()" ,"F" ,"Parent Handle Missing" ,"hParent required." ,
    recorddata )
   CALL exit_srvrequest (happ ,htask ,hstep )
  ENDIF
  IF ((personid = 0.0 ) )
   CALL handleerror ("AddToEventPrsnlList()" ,"F" ,"personId Missing" ,
    "Parameter PersonId required." ,recorddata )
   CALL exit_srvrequest (happ ,htask ,hstep )
  ENDIF
  IF ((actionprsnlid = 0.0 ) )
   CALL handleerror ("AddToEventPrsnlList()" ,"F" ,"actionPrsnlId Missing" ,
    "Parameter actionPrsnlId required." ,recorddata )
   CALL exit_srvrequest (happ ,htask ,hstep )
  ENDIF
  IF ((actiontype = 0.0 ) )
   CALL handleerror ("AddToEventPrsnlList()" ,"F" ,"actionType Missing" ,
    "Parameter actionType required." ,recorddata )
   CALL exit_srvrequest (happ ,htask ,hstep )
  ENDIF
  IF ((actionstatus = 0.0 ) )
   CALL handleerror ("AddToEventPrsnlList()" ,"F" ,"actionStatus Missing" ,
    "Parameter actionStatus required." ,recorddata )
   CALL exit_srvrequest (happ ,htask ,hstep )
  ENDIF
  IF ((actiondttm = 0.0 ) )
   CALL handleerror ("AddToEventPrsnlList()" ,"F" ,"actionDtTm Missing" ,
    "Parameter actionDtTm required." ,recorddata )
   CALL exit_srvrequest (happ ,htask ,hstep )
  ENDIF
  IF (hparent )
   SET hprsnl = uar_srvadditem (hparent ,"event_prsnl_list" )
   IF (hprsnl )
    SET srvstat = uar_srvsetdouble (hprsnl ,"person_id" ,personid )
    SET srvstat = uar_srvsetdouble (hprsnl ,"action_prsnl_id" ,actionprsnlid )
    SET srvstat = uar_srvsetdouble (hprsnl ,"action_type_cd" ,actiontype )
    SET srvstat = uar_srvsetdouble (hprsnl ,"action_status_cd" ,actionstatus )
    SET srvstat = uar_srvsetdate (hprsnl ,"action_dt_tm" ,actiondttm )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (execeventsensured (request =vc (ref ) ) =null WITH protect )
  CALL log_message ("In ExecEventsEnsured()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  DECLARE ee_app_id = i4 WITH private ,constant (600005 )
  DECLARE ee_task_id = i4 WITH private ,constant (600108 )
  DECLARE ee_request_number = i4 WITH private ,constant (600345 )
  DECLARE rblistsize = i4 WITH private ,noconstant (0 )
  DECLARE repsize = i4 WITH private ,noconstant (0 )
  DECLARE hreq = i4 WITH private ,noconstant (0 )
  DECLARE hreqlist = i4 WITH private ,noconstant (0 )
  DECLARE hreply = i4 WITH private ,noconstant (0 )
  DECLARE hstatusdata = i4 WITH private ,noconstant (0 )
  DECLARE x = i4 WITH private ,noconstant (0 )
  DECLARE y = i4 WITH private ,noconstant (0 )
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (request )
  ENDIF
  CALL initializeapptaskrequest (report_data ,ee_app_id ,ee_task_id ,ee_request_number )
  SET hreq = uar_crmgetrequest (hstep )
  CALL echo (build ("size(report_data->rep,5)::" ,size (report_data->rep ,5 ) ) )
  SET repsize = size (request->qual ,5 )
  IF ((repsize > 0 ) )
   FOR (x = 1 TO repsize )
    SET hreqlist = uar_srvadditem (hreq ,"elist" )
    SET nsrvstat = uar_srvsetdouble (hreqlist ,"event_id" ,request->qual[x ].event_id )
   ENDFOR
   SET ncrmstat = uar_crmperform (hstep )
  ENDIF
  IF ((ncrmstat = 0 ) )
   SET hreply = uar_crmgetreply (hstep )
   SET hstatusdata = uar_srvgetstruct (hreply ,"status_data" )
   IF ((uar_srvgetstringptr (hstatusdata ,"status" ) = "F" ) )
    CALL handleerror ("ExecEventsEnsured()" ,"F" ,cnvtstring (ncrmstat ) ,
     "Failure during execution of DCP_EVENTS_ENSURED" )
   ENDIF
  ELSE
   CALL handleerror ("ExecEventsEnsured()" ,"F" ,cnvtstring (ncrmstat ) ,
    "Failure during execution of DCP_EVENTS_ENSURED CRM STATUS" )
  ENDIF
  CALL exit_srvrequest (happ ,htask ,hstep )
  CALL log_message (build ("Exit ExecEventsEnsured(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (validateuserprivileges (valuerec =vc (ref ) ,view_results_ind =i2 ,
  add_documentation_ind =i2 ,modify_documentation_ind =i2 ,unchart_documentation_ind =i2 ,
  sign_documentation_ind =i2 ,recorddata =vc (ref ) ,event_set_level =i2 ) =i2 )
  CALL log_message ("In ValidateUserPrivileges()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  DECLARE x = i4 WITH noconstant (0 ) ,private
  DECLARE viewcnt = i4 WITH noconstant (0 ) ,private
  DECLARE addcnt = i4 WITH noconstant (0 ) ,private
  DECLARE modcnt = i4 WITH noconstant (0 ) ,private
  DECLARE unchartcnt = i4 WITH noconstant (0 ) ,private
  DECLARE signcnt = i4 WITH noconstant (0 ) ,private
  FREE RECORD priveventset_rec
  RECORD priveventset_rec (
    1 cnt = i4
    1 qual [* ]
      2 value = vc
  ) WITH protect
  IF (event_set_level )
   CALL geteventsetnamesfromeventsetcds (valuerec ,priveventset_rec )
   SET curalias chk_priv_req check_priv_request->event_privileges.event_set_level
   SET stat = movereclist (priveventset_rec->qual ,check_priv_request->event_set_name ,1 ,0 ,
    priveventset_rec->cnt ,1 )
  ELSE
   SET curalias chk_priv_req check_priv_request->event_privileges.event_code_level
   SET stat = movereclist (valuerec->qual ,chk_priv_req->event_codes ,1 ,0 ,valuerec->cnt ,1 )
  ENDIF
  SET curalias chk_priv_reply check_priv_reply->event_privileges
  SET chk_priv_req->view_results_ind = view_results_ind
  SET chk_priv_req->add_documentation_ind = add_documentation_ind
  SET chk_priv_req->modify_documentation_ind = modify_documentation_ind
  SET chk_priv_req->unchart_documentation_ind = unchart_documentation_ind
  SET chk_priv_req->sign_documentation_ind = sign_documentation_ind
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echo (build ("$INPUTPROVIDERID::" , $INPUTPROVIDERID ,"::$INPUTPPR::" , $INPUTPPR ) )
   CALL echorecord (check_priv_request )
  ENDIF
  CALL checkprivileges ( $INPUTPROVIDERID , $INPUTPPR )
  IF ((validate (debug_ind ,0 ) = 1 ) )
   CALL echorecord (check_priv_reply )
  ENDIF
  IF ((check_priv_reply->status_data.status = "S" ) )
   IF (event_set_level )
    SET viewcnt = size (chk_priv_reply->view_results.granted.event_sets ,5 )
    SET addcnt = size (chk_priv_reply->add_documentation.granted.event_sets ,5 )
    SET modcnt = size (chk_priv_reply->modify_documentation.granted.event_sets ,5 )
    SET unchartcnt = size (chk_priv_reply->unchart_documentation.granted.event_sets ,5 )
    SET signcnt = size (chk_priv_reply->sign_documentation.granted.event_sets ,5 )
   ELSE
    SET viewcnt = size (chk_priv_reply->view_results.granted.event_codes ,5 )
    SET addcnt = size (chk_priv_reply->add_documentation.granted.event_codes ,5 )
    SET modcnt = size (chk_priv_reply->modify_documentation.granted.event_codes ,5 )
    SET unchartcnt = size (chk_priv_reply->unchart_documentation.granted.event_codes ,5 )
    SET signcnt = size (chk_priv_reply->sign_documentation.granted.event_codes ,5 )
   ENDIF
   IF (view_results_ind
   AND (viewcnt != valuerec->cnt ) )
    CALL handleerror ("ValidateUserPrivileges()" ,"F" ,"" ,
     "User does not have necessary privs to view selected documents." ,recorddata )
    CALL exit_srvrequest (happ ,htask ,hstep )
    GO TO exit_script
   ENDIF
   IF (add_documentation_ind
   AND (addcnt != valuerec->cnt ) )
    CALL handleerror ("ValidateUserPrivileges()" ,"F" ,"" ,
     "User does not have necessary privs to add selected documents." ,recorddata )
    CALL exit_srvrequest (happ ,htask ,hstep )
    GO TO exit_script
   ENDIF
   IF (modify_documentation_ind
   AND (modcnt != valuerec->cnt ) )
    CALL handleerror ("ValidateUserPrivileges()" ,"F" ,"" ,
     "User does not have necessary privs to modify selected documents." ,recorddata )
    CALL exit_srvrequest (happ ,htask ,hstep )
    GO TO exit_script
   ENDIF
   IF (unchart_documentation_ind
   AND (unchartcnt != valuerec->cnt ) )
    CALL handleerror ("ValidateUserPrivileges()" ,"F" ,"" ,
     "User does not have necessary privs to unchart selected documents." ,recorddata )
    CALL exit_srvrequest (happ ,htask ,hstep )
    GO TO exit_script
   ENDIF
   IF (sign_documentation_ind
   AND (signcnt != valuerec->cnt ) )
    CALL handleerror ("ValidateUserPrivileges()" ,"F" ,"" ,
     "User does not have necessary privs to sign selected documents." ,recorddata )
    CALL exit_srvrequest (happ ,htask ,hstep )
    GO TO exit_script
   ENDIF
  ELSEIF ((check_priv_reply->status_data.status = "Z" ) )
   CALL handleerror ("ValidateUserPrivileges()" ,"F" ,"No Records" ,
    "CheckPrivileges() did not return any requested privs." ,recorddata )
   CALL exit_srvrequest (happ ,htask ,hstep )
   GO TO exit_script
  ENDIF
  SET curalias chk_priv_req off
  SET curalias chk_priv_reply off
  FREE RECORD priveventset_rec
  CALL exit_srvrequest (happ ,htask ,hstep )
  CALL log_message (build ("Exit ValidateUserPrivileges(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SET log_program_name = "INN_MP_UNCHART_RESULT"
 FREE RECORD ce_settings
 RECORD ce_settings (
   1 person_id = f8
   1 encntr_id = f8
   1 action_prsnl_id = f8
   1 action_dt_tm = dq8
   1 task_assay_cd = f8
   1 event_end_dt_tm = dq8
   1 result = vc
   1 event_id = f8
   1 normal_low = vc
   1 normal_high = vc
   1 critical_low = vc
   1 critical_high = vc
   1 normalcy_cd = f8
   1 result_units_cd = f8
   1 record_status_cd = f8
   1 result_status_cd = f8
   1 contributor_system_cd = f8
   1 event_class_cd = f8
   1 entry_mode_cd = f8
   1 string_result_format_cd = f8
   1 accession_nbr = vc
 )
 FREE RECORD eventcode_rec
 RECORD eventcode_rec (
   1 cnt = i4
   1 qual [* ]
     2 value = f8
 )
 FREE RECORD eventensuredreq
 RECORD eventensuredreq (
   1 cnt = i4
   1 qual [* ]
     2 event_id = f8
     2 order_id = f8
     2 task_id = f8
 )
 DECLARE retrievedtainfofromeventcd (null ) = null
 DECLARE populatecodedresultfromnomen (null ) = null
 DECLARE validaterequestrecord (null ) = null
 DECLARE populatecesettings (null ) = null
 DECLARE insertceresults (null ) = null
 DECLARE app_id = i4 WITH protect ,constant (1000071 )
 DECLARE task_id = i4 WITH protect ,constant (1000071 )
 DECLARE request_id = i4 WITH protect ,constant (1000071 )
 DECLARE powerchart = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,89 ,"POWERCHART" ) )
 DECLARE txt = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,53 ,"TXT" ) )
 DECLARE action_status_completed = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,103 ,
   "COMPLETED" ) )
 DECLARE action_type_perform = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,21 ,"PERFORM"
   ) )
 DECLARE action_type_verify = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,21 ,"VERIFY" )
  )
 DECLARE auth_verified = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) )
 DECLARE in_error = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,8 ,"INERROR" ) )
 DECLARE active = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,48 ,"ACTIVE" ) )
 DECLARE string_format_cd = f8 WITH protect ,constant (uar_get_code_by ("MEANING" ,14113 ,"ALPHA" )
  )
 DECLARE privviewres = i2 WITH protect ,constant (0 )
 DECLARE privadddoc = i2 WITH protect ,constant (0 )
 DECLARE privmoddoc = i2 WITH protect ,constant (0 )
 DECLARE privunchartdoc = i2 WITH protect ,constant (1 )
 DECLARE privsigndoc = i2 WITH protect ,constant (1 )
 DECLARE mnfailed = i2 WITH protect ,noconstant (0 )
 DECLARE iret = i4 WITH protect ,noconstant (0 )
 DECLARE srvstat = i2 WITH protect ,noconstant (0 )
 CALL log_message (concat ("Starting script: " ,log_program_name ) ,log_level_debug )
 SET report_data->status_data.status = "F"
 CALL getparametervalues (5 ,eventcode_rec )
 CALL validaterequestrecord (null )
 CALL validateuserprivileges (eventcode_rec ,privviewres ,privadddoc ,privmoddoc ,privunchartdoc ,
  privsigndoc ,report_data ,0 )
 CALL initializeapptaskrequest (report_data ,app_id ,task_id ,request_id )
 CALL populatecesettings (null )
 CALL insertceresults (null )
 CALL exit_srvrequest (happ ,htask ,hstep )
 CALL execeventsensured (eventensuredreq )
 SET report_data->status_data.status = "S"
 SUBROUTINE  validaterequestrecord (null )
  CALL log_message ("In ValidateRequestRecord()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  IF (( $INPUTPERSONID = 0.0 ) )
   CALL handleerror ("ValidateRequestRecord()" ,"F" ,"" ,"Person Id cannot be null" ,report_data )
   GO TO exit_script
  ELSEIF (( $INPUTENCOUNTERID = 0.0 ) )
   CALL handleerror ("ValidateRequestRecord()" ,"F" ,"" ,"Encounter Id cannot be null" ,report_data
    )
   GO TO exit_script
  ELSEIF (( $INPUTPROVIDERID = 0.0 ) )
   CALL handleerror ("ValidateRequestRecord()" ,"F" ,"" ,"User Id cannot be null" ,report_data )
   GO TO exit_script
  ELSEIF (((( $INPUTEVENTID = null ) ) OR (( $INPUTEVENTID = 0.0 ) )) )
   CALL handleerror ("ValidateRequestRecord()" ,"F" ,"" ,"Event Id cannot be null" ,report_data )
   GO TO exit_script
  ELSEIF (((( $INPUTEVENTCD = null ) ) OR (( $INPUTEVENTCD = 0.0 ) )) )
   CALL handleerror ("ValidateRequestRecord()" ,"F" ,"" ,"Event Cd cannot be null" ,report_data )
   GO TO exit_script
  ENDIF
  CALL log_message (build ("Exit ValidateRequestRecord(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  populatecesettings (null )
  CALL log_message ("In PopulateCESettings()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  SET ce_settings->person_id =  $INPUTPERSONID
  SET ce_settings->encntr_id =  $INPUTENCOUNTERID
  SET ce_settings->action_prsnl_id =  $INPUTPROVIDERID
  SET ce_settings->event_end_dt_tm = cnvtdatetime (current_date_time )
  SET ce_settings->action_dt_tm = cnvtdatetime (current_date_time )
  SET ce_settings->event_id =  $INPUTEVENTID
  SET ce_settings->record_status_cd = active
  SET ce_settings->result_status_cd = in_error
  SET ce_settings->contributor_system_cd = powerchart
  SET ce_settings->event_class_cd = txt
  CALL echorecord (ce_settings )
  CALL log_message (build ("Exit RetrieveCESettings(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  insertceresults (null )
  CALL log_message ("In InsertCEResults()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  DECLARE hreqlist = i4 WITH protect ,noconstant (0 )
  DECLARE hreply = i4 WITH protect ,noconstant (0 )
  DECLARE hstce = i4 WITH protect ,noconstant (0 )
  DECLARE hcodedres = i4 WITH protect ,noconstant (0 )
  DECLARE hstchildce = i4 WITH protect ,noconstant (0 )
  DECLARE hstrres = i4 WITH protect ,noconstant (0 )
  DECLARE hblobres = i4 WITH protect ,noconstant (0 )
  DECLARE hblob = i4 WITH protect ,noconstant (0 )
  DECLARE repcnt = i4 WITH noconstant (0 )
  DECLARE rep = i4 WITH noconstant (0 )
  DECLARE sb = i4 WITH noconstant (0 )
  DECLARE x = i4 WITH private ,noconstant (0 )
  DECLARE sfixedstring = c500 WITH public ,noconstant (fillstring (500 ," " ) )
  SET hreq = uar_crmgetrequest (hstep )
  SET hreqlist = uar_srvadditem (hreq ,"req" )
  SET srvstat = uar_srvsetshort (hreqlist ,"ensure_type" ,2 )
  SET hstce = uar_srvgetstruct (hreqlist ,"clin_event" )
  SET srvstat = uar_srvsetlong (hstce ,"view_level" ,1 )
  SET srvstat = uar_srvsetdouble (hstce ,"person_id" ,ce_settings->person_id )
  SET srvstat = uar_srvsetdouble (hstce ,"encntr_id" ,ce_settings->encntr_id )
  SET srvstat = uar_srvsetdouble (hstce ,"event_id" ,ce_settings->event_id )
  SET srvstat = uar_srvsetdouble (hstce ,"record_status_cd" ,ce_settings->record_status_cd )
  SET srvstat = uar_srvsetdouble (hstce ,"result_status_cd" ,ce_settings->result_status_cd )
  SET srvstat = uar_srvsetshort (hstce ,"publish_flag" ,1 )
  CALL addtoeventprsnllist (hstce ,ce_settings->person_id ,ce_settings->action_prsnl_id ,
   action_type_perform ,action_status_completed ,cnvtdatetime (ce_settings->action_dt_tm ) ,
   report_data )
  CALL addtoeventprsnllist (hstce ,ce_settings->person_id ,ce_settings->action_prsnl_id ,
   action_type_verify ,action_status_completed ,cnvtdatetime (ce_settings->action_dt_tm ) ,
   report_data )
  SET ncrmstat = uar_crmperform (hstep )
  SET hreply = uar_crmgetreply (hstep )
  CALL getcerep (hreply )
  CALL log_message (build ("Exit InsertCEResults(), Elapsed time in seconds:" ,datetimediff (
     cnvtdatetime (sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
 SUBROUTINE  (getcerep (hreply =i4 (ref ) ) =null WITH protect )
  CALL log_message ("In getCERep()" ,log_level_debug )
  DECLARE begin_date_time = dq8 WITH constant (cnvtdatetime (sysdate ) ) ,private
  DECLARE x = i4 WITH noconstant (0 ) ,private
  DECLARE y = i4 WITH noconstant (0 ) ,private
  DECLARE dynidx = i4 WITH noconstant (0 ) ,private
  DECLARE repidx = i4 WITH noconstant (0 ) ,private
  DECLARE rbidx = i4 WITH noconstant (0 ) ,private
  DECLARE sbsidx = i4 WITH noconstant (0 ) ,private
  DECLARE dynamiclabelcnt = i4 WITH noconstant (0 ) ,private
  DECLARE replylistcnt = i4 WITH noconstant (0 ) ,private
  DECLARE resultlistcnt = i4 WITH noconstant (0 ) ,private
  DECLARE hreplistitem = i4 WITH noconstant (0 ) ,private
  DECLARE hresultlistitem = i4 WITH noconstant (0 ) ,private
  DECLARE hdynamiclabel = i4 WITH noconstant (0 ) ,private
  SET replylistcnt = uar_srvgetitemcount (hreply ,nullterm ("rep" ) )
  IF ((replylistcnt > 0 ) )
   SET stat = alterlist (report_data->rep ,replylistcnt )
   FOR (x = 0 TO (replylistcnt - 1 ) )
    SET repidx +=1
    SET hreplistitem = uar_srvgetitem (hreply ,"rep" ,x )
    SET resultlistcnt = uar_srvgetitemcount (hreplistitem ,nullterm ("rb_list" ) )
    IF ((resultlistcnt > 0 ) )
     SET stat = alterlist (report_data->rep[repidx ].rb_list ,resultlistcnt )
     FOR (y = 0 TO (resultlistcnt - 1 ) )
      SET rbidx +=1
      SET hresultlistitem = uar_srvgetitem (hreplistitem ,"rb_list" ,y )
      SET report_data->rep[repidx ].rb_list[rbidx ].event_id = uar_srvgetdouble (hresultlistitem ,
       "event_id" )
      SET stat = uar_srvgetdate (hresultlistitem ,"valid_from_dt_tm" ,report_data->rep[repidx ].
       rb_list[rbidx ].valid_from_dt_tm )
      SET report_data->rep[repidx ].rb_list[rbidx ].event_cd = uar_srvgetdouble (hresultlistitem ,
       "event_cd" )
      SET report_data->rep[repidx ].rb_list[rbidx ].result_status_cd = uar_srvgetdouble (
       hresultlistitem ,"result_status_cd" )
      SET report_data->rep[repidx ].rb_list[rbidx ].contributor_system_cd = uar_srvgetdouble (
       hresultlistitem ,"contributor_system_cd" )
      SET report_data->rep[repidx ].rb_list[rbidx ].reference_nbr = uar_srvgetstringptr (
       hresultlistitem ,nullterm ("reference_nbr" ) )
      SET report_data->rep[repidx ].rb_list[rbidx ].collating_seq = uar_srvgetstringptr (
       hresultlistitem ,nullterm ("collating_seq" ) )
      SET report_data->rep[repidx ].rb_list[rbidx ].parent_event_id = uar_srvgetdouble (
       hresultlistitem ,"parent_event_id" )
      SET report_data->rep[repidx ].rb_list[rbidx ].clinical_event_id = uar_srvgetdouble (
       hresultlistitem ,"clinical_event_id" )
      SET report_data->rep[repidx ].rb_list[rbidx ].updt_cnt = uar_srvgetlong (hresultlistitem ,
       "updt_cnt" )
      SET eventensuredreq->cnt +=1
      SET stat = alterlist (eventensuredreq->qual ,eventensuredreq->cnt )
      SET eventensuredreq->qual[eventensuredreq->cnt ].event_id = report_data->rep[repidx ].rb_list[
      rbidx ].event_id
     ENDFOR
    ENDIF
    SET hstatusdata = uar_srvgetstruct (hreplistitem ,"sb" )
    SET report_data->rep[repidx ].sb.severitycd = uar_srvgetlong (hstatusdata ,"severityCd" )
    SET report_data->rep[repidx ].sb.statuscd = uar_srvgetlong (hstatusdata ,"statusCd" )
    SET report_data->rep[repidx ].sb.statustext = uar_srvgetstringptr (hstatusdata ,nullterm (
      "statusText" ) )
    SET substatuslistcnt = uar_srvgetitemcount (hstatusdata ,nullterm ("subStatusList" ) )
    IF ((substatuslistcnt > 0 ) )
     SET stat = alterlist (report_data->rep[repidx ].sb.substatuslist ,substatuslistcnt )
     FOR (y = 0 TO (substatuslistcnt - 1 ) )
      SET sbsidx +=1
      SET hsubstatuslistitem = uar_srvgetitem (hstatusdata ,nullterm ("subStatusList" ) ,y )
      SET report_data->rep[repidx ].sb.substatuslist[sbsidx ].substatuscd = uar_srvgetlong (
       hsubstatuslistitem ,"subStatusCd" )
     ENDFOR
    ENDIF
   ENDFOR
   SET dynamiclabelcnt = uar_srvgetitemcount (hreply ,nullterm ("dynamic_label_list" ) )
   IF ((dynamiclabelcnt > 0 ) )
    SET stat = alterlist (report_data->dynamic_label_list ,dynamiclabelcnt )
    FOR (x = 0 TO (dynamiclabelcnt - 1 ) )
     SET dynidx +=1
     SET hdynamiclabel = uar_srvgetitem (hstatusdata ,nullterm ("dynamic_label_list" ) ,x )
     SET report_data->dynamic_label_list[dynidx ].ce_dynamic_label_id = uar_srvgetdouble (
      hdynamiclabel ,"ce_dynamic_label_id" )
     SET report_data->dynamic_label_list[dynidx ].label_name = uar_srvgetstringptr (hdynamiclabel ,
      nullterm ("label_name" ) )
     SET report_data->dynamic_label_list[dynidx ].label_prsnl_id = uar_srvgetdouble (hdynamiclabel ,
      "label_prsnl_id" )
     SET report_data->dynamic_label_list[dynidx ].label_status_cd = uar_srvgetdouble (hdynamiclabel ,
      "label_status_cd" )
     SET report_data->dynamic_label_list[dynidx ].result_set_id = uar_srvgetdouble (hdynamiclabel ,
      "result_set_id" )
     SET report_data->dynamic_label_list[dynidx ].label_seq_nbr = uar_srvgetlong (hdynamiclabel ,
      "label_seq_nbr" )
     SET stat = uar_srvgetdate (hdynamiclabel ,"valid_from_dt_tm" ,report_data->dynamic_label_list[
      dynidx ].valid_from_dt_tm )
    ENDFOR
   ENDIF
  ENDIF
  SET hstatusdata = uar_srvgetstruct (hreply ,"sb" )
  SET report_data->sb.severitycd = uar_srvgetlong (hstatusdata ,"severityCd" )
  SET report_data->sb.statuscd = uar_srvgetlong (hstatusdata ,"statusCd" )
  SET report_data->sb.statustext = uar_srvgetstringptr (hstatusdata ,nullterm ("statusText" ) )
  SET substatuslistcnt = uar_srvgetitemcount (hstatusdata ,nullterm ("subStatusList" ) )
  IF ((substatuslistcnt > 0 ) )
   SET stat = alterlist (report_data->sb.substatuslist ,substatuslistcnt )
   SET sbsidx = 0
   FOR (y = 0 TO (substatuslistcnt - 1 ) )
    SET hsubstatuslistitem = uar_srvgetitem (hstatusdata ,nullterm ("subStatusList" ) ,y )
    SET report_data->sb.substatuslist[sbsidx ].substatuscd = uar_srvgetlong (hsubstatuslistitem ,
     "subStatusCd" )
    SET sbsidx +=1
   ENDFOR
  ENDIF
  CALL log_message (build ("Exit getCERep(), Elapsed time in seconds:" ,datetimediff (cnvtdatetime (
      sysdate ) ,begin_date_time ,5 ) ) ,log_level_debug )
 END ;Subroutine
#exit_script
 CALL putjsonrecordtofile (report_data )
 IF ((validate (debug_ind ,0 ) = 1 ) )
  CALL echorecord (ce_settings )
  CALL echorecord (check_priv_request )
  CALL echorecord (report_data )
  CALL echorecord (eventensuredreq )
 ELSE
  FREE RECORD ce_settings
  FREE RECORD check_priv_request
  FREE RECORD report_data
  FREE RECORD eventensuredreq
 ENDIF
 CALL log_message (concat ("Exiting script: " ,log_program_name ) ,log_level_debug )
 CALL log_message (build ("Total time in seconds:" ,datetimediff (cnvtdatetime (sysdate ) ,
    current_date_time ,5 ) ) ,log_level_debug )
END GO
