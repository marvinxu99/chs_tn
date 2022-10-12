DROP PROGRAM cov_rule_current_ega1 GO
CREATE PROGRAM cov_rule_current_ega1
 IF (NOT (validate (xreply ) ) )
  RECORD xreply (
    1 status_data
      2 status = c1
      2 subeventstatus [* ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE errorhandler ((operationstatus = c1 ) ,(targetobjectname = vc ) ,(targetobjectvalue = vc )
  ) = null
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
 IF ((validate (i18nuar_def ,999 ) = 999 ) )
  CALL echo ("Declaring i18nuar_def" )
  DECLARE i18nuar_def = i2 WITH persist ,noconstant (1 )
  DECLARE uar_i18nlocalizationinit ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ,(p4 = f8 ) ) = i4 WITH
  persist
  DECLARE uar_i18ngetmessage ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ) = vc WITH persist
  DECLARE uar_i18nbuildmessage () = vc WITH persist
 ENDIF
 DECLARE i18nhandle = i4 WITH persistscript
 CALL uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
 DECLARE statusscript = c26 WITH constant ("RULE_CURRENT_EGA" ) ,protect
 DECLARE errmsg = c132 WITH protect ,noconstant (fillstring (132 ," " ) )
 DECLARE error_check = i2 WITH protect ,noconstant (error (errmsg ,1 ) )
 DECLARE error_cnt = i2 WITH protect
 DECLARE dperson_id = f8 WITH protect
 DECLARE dpregnancy_id = f8 WITH protect
 DECLARE now = i4 WITH protect
 DECLARE zerodayscaption = vc WITH protect
 DECLARE dayscaption = vc WITH protect
 DECLARE oneweekcaption = vc WITH protect
 DECLARE weekscaption = vc WITH protect
 DECLARE fractionweekscaption = vc WITH protect
 DECLARE testind = i2 WITH protect
 DECLARE dynamiclabelid = f8 WITH protect
 SET retval = 0
 SET xreply->status_data.status = "F"
 SET zerodayscaption = uar_i18ngetmessage (i18nhandle ,"cap1" ,"0 days" )
 SET dayscaption = uar_i18ngetmessage (i18nhandle ,"cap2" ," days" )
 SET oneweekcaption = uar_i18ngetmessage (i18nhandle ,"cap3" ,"1 week" )
 SET weekscaption = uar_i18ngetmessage (i18nhandle ,"cap4" ," weeks" )
 FREE RECORD dcp_request
 RECORD dcp_request (
   1 patient_list [1 ]
     2 patient_id = f8
     2 encntr_id = f8
   1 pregnancy_list [* ]
     2 pregnancy_id = f8
   1 multiple_egas = i2
   1 provider_list [1 ]
     2 patient_id = f8
     2 encntr_id = f8
     2 provider_patient_reltn_cd = f8
   1 provider_id = f8
   1 position_cd = f8
   1 cal_ega_multiple_gest = i2
   1 debug_ind = i2
 )
 IF ((size (trim (reflect (parameter (1 ,0 ) ) ) ,1 ) > 0 ) )
  SET dynamiclabelid = cnvtreal (value (parameter (1 ,0 ) ) )
 ELSE
  SET dynamiclabelid = 0
 ENDIF
 SET dcp_request->provider_id = reqinfo->updt_id
 SET dcp_request->position_cd = reqinfo->position_cd
 SET cedynamiclabelid = 0.0
 IF ((size (trim (reflect (parameter (1 ,0 ) ) ) ,1 ) > 1 ) )
  SET cedynamiclabelid = cnvtint (value (parameter (1 ,0 ) ) )
  IF ((link_clineventid > 0.0 ) )
   SELECT INTO "nl:"
    ce.verified_prsnl_id ,
    p.position_cd
    FROM (clinical_event ce ),
     (prsnl p )
    PLAN (ce
     WHERE (ce.clinical_event_id = link_clineventid ) )
     JOIN (p
     WHERE (ce.verified_prsnl_id = p.person_id ) )
    DETAIL
     dcp_request->provider_id = p.person_id ,
     dcp_request->position_cd = p.position_cd
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((size (trim (reflect (parameter (2 ,0 ) ) ) ,1 ) > 0 ) )
  SET testind = cnvtint (value (parameter (2 ,0 ) ) )
 ELSE
  SET testind = 0
 ENDIF
 SET dcp_request->debug_ind = testind
 SET log_personid = link_personid
 SET log_encntrid = link_encntrid
 SET dcp_request->patient_list[1 ].patient_id = cnvtreal (link_personid )
 SET dcp_request->provider_list[1 ].patient_id = cnvtreal (link_personid )
 SET dcp_request->provider_list[1 ].provider_patient_reltn_cd = 0.0
 SET dcp_request->cal_ega_multiple_gest = 1
 EXECUTE dcp_get_final_ega WITH replace ("REQUEST" ,dcp_request ) ,
 replace ("REPLY" ,dcp_reply )
 SET modify = nopredeclare
 IF ((testind = 1 ) )
  CALL echorecord (dcp_reply )
 ENDIF
 IF ((dcp_reply->status_data.status = "F" ) )
  SET xreply->status_data.status = "F"
  SET xreply->subeventstatus[1 ].operationname = "Execute"
  SET xreply->subeventstatus[1 ].operationstatus = "F"
  SET xreply->subeventstatus[1 ].targetobjectname = "dcp_get_final_ega"
  SET xreply->subeventstatus[1 ].targetobjectvalue = "fail status returned from dcp_get_final_ega"
  GO TO exit_report
 ELSEIF ((size (dcp_reply->gestation_info ,5 ) = 0 ) )
  SET retval = 0
  SET ierrorcode = error (errmsg ,1 )
  IF ((ierrorcode != 0 ) )
   CALL echo ("*********************************" )
   CALL echo (build ("ERROR MESSAGE : " ,serrormsg ) )
   CALL echo ("*********************************" )
   SET xreply->status_data.status = "F"
   SET xreply->subeventstatus[1 ].operationname = "Execute"
   SET xreply->subeventstatus[1 ].operationstatus = "F"
   SET xreply->subeventstatus[1 ].targetobjectname = "RULE_CURRENT_EGA"
   SET xreply->subeventstatus[1 ].targetobjectvalue = "Failure while printing NO DATA."
  ELSE
   SET xreply->status_data.status = "S"
  ENDIF
  GO TO no_data
 ENDIF
 CALL echo (build ("delivered_ind :" ,dcp_reply->gestation_info[1 ].delivered_ind ) )
 IF ((dcp_reply->gestation_info[1 ].delivered_ind > 0 ) )
  SET log_message = " (Delivered)"
  SET ageatdelivery = dcp_reply->gestation_info[1 ].gest_age_at_delivery
  SET nbirths = size (dcp_reply->gestation_info[1 ].dynamic_label ,5 )
  IF ((nbirths > 0 ) )
   CALL echo (build2 ("Size of DYNAMIC_LABEL:  " ,nbirths ) )
   FOR (_ii = 1 TO nbirths )
    IF ((dcp_reply->gestation_info[1 ].dynamic_label[_ii ].dynamic_label_id = cedynamiclabelid ) )
     SET ageatdelivery = dcp_reply->gestation_info[1 ].dynamic_label[_ii ].gest_age_at_delivery
     SET _ii = nbirths
    ENDIF
   ENDFOR
  ENDIf
  CALL echo (build2 ("ageAtDelivery:  " ,ageatdelivery ) )
  /*
  IF ((ageatdelivery < 7 ) )
   SET log_misc1 = build (ageatdelivery ,dayscaption )
   SET retval = 100
  ELSEIF ((ageatdelivery = 7 ) )
   SET log_misc1 = oneweekcaption
   SET retval = 100
  ELSEIF ((mod (ageatdelivery ,7 ) = 0 ) )
   SET log_misc1 = build ((ageatdelivery / 7 ) ,weekscaption )
   SET retval = 100
  ELSE
   SET log_misc1 = concat (trim (cnvtstring ((ageatdelivery / 7 ) ) ) ,"W " ,trim (cnvtstring (mod (
       ageatdelivery ,7 ) ) ) ,"D" )
   SET retval = 100
  ENDIF
 ELSEIF ((dcp_reply->gestation_info[1 ].current_gest_age < 7 ) )
  SET log_message = " (Not Yet Delivered)"
  SET log_misc1 = build (dcp_reply->gestation_info[1 ].current_gest_age ,dayscaption )
  SET retval = 100
 ELSEIF ((dcp_reply->gestation_info[1 ].current_gest_age = 7 ) )
  SET log_message = " (Not Yet Delivered)"
  SET log_misc1 = oneweekcaption
  SET retval = 100
 ELSEIF ((mod (dcp_reply->gestation_info[1 ].current_gest_age ,7 ) = 0 ) )
  SET log_message = " (Not Yet Delivered)"
  SET log_misc1 = build ((dcp_reply->gestation_info[1 ].current_gest_age / 7 ) ,weekscaption )
  SET retval = 100
 ELSE
  SET log_message = " (Not Yet Delivered)"
  SET log_misc1 = concat (trim (cnvtstring ((dcp_reply->gestation_info[1 ].current_gest_age / 7 ) )
    ) ,"W " ,trim (cnvtstring (mod (dcp_reply->gestation_info[1 ].current_gest_age ,7 ) ) ) ,"D" )
  SET retval = 100
 ENDIF
 */
 
  IF ((ageatdelivery > 0) )
   SET log_misc1 = build (ageatdelivery )
   SET retval = 100
  endif
endif
 
 SUBROUTINE  errorhandler (operationstatus ,targetobjectname ,targetobjectvalue )
  SET error_cnt = size (xreply->status_data.subeventstatus ,5 )
  SET error_cnt = (error_cnt + 1 )
  SET now = alterlist (xreply->status_data.subeventstatus ,error_cnt )
  SET xreply->status_data.status = "F"
  SET xreply->status_data.subeventstatus[error_cnt ].operationname = statusscript
  SET xreply->status_data.subeventstatus[error_cnt ].operationstatus = operationstatus
  SET xreply->status_data.subeventstatus[error_cnt ].targetobjectname = targetobjectname
  SET xreply->status_data.subeventstatus[error_cnt ].targetobjectvalue = targetobjectvalue
  SET retval = - (1 )
  SET log_message = concat (statusscript ," FAILED AT " ,targetobjectname ,"  " ,targetobjectvalue )
  GO TO exit_script
 END ;Subroutine
#no_data
 GO TO exit_script
#exit_script
 IF ((testind = 1 ) )
  CALL echorecord (xreply )
 ENDIF
 IF ((retval = 100 ) )
  SET log_message = build ("Post EGA of:  " ,log_misc1 ," to Mom's DynamicLabelId:  " ,
   cedynamiclabelid ,log_message )
    SET log_message = build (log_message,"|",cnvtrecjson(dcp_reply) )
   
 ENDIF
 CALL echo (build ("The current EGA is :" ,log_misc1 ) )
 CALL echo (build ("retval :" ,retval ) )
END GO
