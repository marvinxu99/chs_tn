DROP PROGRAM cov_rule_current_ega2 GO
CREATE PROGRAM cov_rule_current_ega2
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
 SET retval = 0
 SET xreply->status_data.status = "F"
 SET zerodayscaption = uar_i18ngetmessage (i18nhandle ,"cap1" ,"0 days" )
 SET dayscaption = uar_i18ngetmessage (i18nhandle ,"cap2" ," days" )
 SET oneweekcaption = uar_i18ngetmessage (i18nhandle ,"cap3" ,"1 week" )
 SET weekscaption = uar_i18ngetmessage (i18nhandle ,"cap4" ," weeks" )
 SET fractionweekscaption = uar_i18ngetmessage (i18nhandle ,"cap5" ,"/7 weeks" )
 FREE RECORD dcp_request
 RECORD dcp_request (
   1 patient_list [1 ]
     2 patient_id = f8
   1 pregnancy_list [* ]
     2 pregnancy_id = f8
 )
 SET dcp_request->patient_list[1 ].patient_id = cnvtreal (link_personid )
 EXECUTE dcp_get_final_ega WITH replace ("REQUEST" ,dcp_request ) ,
 replace ("REPLY" ,dcp_reply )
 SET modify = nopredeclare
 call echorecord(dcp_reply)
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

/*
    nEGAWeeks = ega_days / 7
    nEGADays = mod(ega_days, 7)
    if (nEGAWeeks = 1)
        cEGA = "1 week"
    elseif (nEGAWeeks > 1)
        cEGA = concat(build(nEGAWeeks), " weeks")
    endif
 
    if (trim(cEGA) != "")
        cEGA = concat(trim(cEGA), ",")
    endif
 
    if (nEGADays = 1)
        cEGA = concat(trim(cEGA), " 1 day")
    elseif (nEGADays > 1 or nEGADays = 0)
        cEGA = concat(trim(cEGA), " ", build(nEGADays), " days")
    endif
*/


declare nNum = i4 with protect, noconstant(0)
declare cEGA = vc with protect, noconstant(" ")
declare cContent = vc with protect, noconstant("")
 

 IF ((dcp_reply->gestation_info[1 ].delivered_ind > 0 ) )
  ;SET log_misc1 = trim (cnvtstring ((dcp_reply->gestation_info[1 ].gest_age_at_delivery / 7 ) ) )
  SET retval = 100
  set ega_days = dcp_reply->gestation_info[1 ].gest_age_at_delivery
 ELSE
  ;SET log_misc1 = trim (cnvtstring ((dcp_reply->gestation_info[1 ].current_gest_age / 7 ) ) )
  SET retval = 100
  set ega_days = dcp_reply->gestation_info[1 ].current_gest_age
 ENDIF
 
set nEGAWeeks = ega_days / 7
set nEGADays = mod(ega_days, 7)
if (nEGAWeeks = 1)
	set cEGA = "1 week"
elseif (nEGAWeeks > 1)
	set cEGA = concat(build(nEGAWeeks), " weeks")
endif
 
if (trim(cEGA) != "")
	set cEGA = concat(trim(cEGA), ",")
endif
 
if (nEGADays = 1)
	set cEGA = concat(trim(cEGA), " 1 day")
elseif (nEGADays > 1 or nEGADays = 0)
	set cEGA = concat(trim(cEGA), " ", build(nEGADays), " days")
endif

call echo(build2("nEGAWeeks=",nEGAWeeks))
call echo(build2("nEGADays=",nEGADays))
call echo(build2("cEGA=",cEGA))

SET log_misc1 = trim (cEGA) 
 
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
 CALL echo ("RULE_CURRENT_EGA certld 10/03/2012" )
 SET log_message = build ("person_id :" ,link_personid ,"###" )
 CALL echo (build ("The current EGA is :" ,log_misc1 ) )
 CALL echo (build ("retval :" ,retval ) )
END GO
