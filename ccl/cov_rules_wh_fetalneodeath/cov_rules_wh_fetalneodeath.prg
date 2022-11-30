DROP PROGRAM cov_rules_wh_fetalneodeath :dba GO
CREATE PROGRAM cov_rules_wh_fetalneodeath :dba
 DECLARE script_version = vc WITH protect ,noconstant (" " )
 DECLARE date_time_diff = f8 WITH protect ,noconstant (0 )
 DECLARE 4002121_nndeath_cd = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!12610724" ) ) ,
 protect
 DECLARE 4002121_fetaldeath_cd = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!12610723" ) )
 ,protect
 DECLARE 4002121_miscarriage_cd = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!4121714074"
   ) ) ,protect
 DECLARE nmeasure = i4 WITH protect ,noconstant (0 )
 DECLARE nopt = i4 WITH protect ,noconstant (1 )
 DECLARE noptstr = vc WITH protect ,noconstant (" " )
 DECLARE neonataldeathind = i4 WITH protect ,noconstant (0 )
 DECLARE errmsg = c132 WITH protect ,noconstant (fillstring (132 ," " ) )
 DECLARE error_check = i2 WITH protect ,noconstant (error (errmsg ,1 ) )
 DECLARE sscript_name = c18 WITH protect ,constant ("rules_wh_fetalneodeath" )
 DECLARE sscript_version = c21 WITH protect ,constant ("000 03/05/21 NT5990" )
 CALL echo (build2 ("  starting script (" ,sscript_name ," - " ,sscript_version ,")..." ) )
 SET log_accessionid = link_accessionid
 SET log_orderid = link_orderid			
 SET log_encntrid = link_encntrid
 SET log_personid = link_personid
 SET log_taskassaycd = link_taskassaycd
 SET log_clineventid = link_clineventid
 SET log_misc1 = "-1"
 SET eksrequest = 265226
 SET retval = - (1 )
 SET nmeasure = cnvtint ( $1 )
 SET nopt = cnvtint ( $2 )
 CALL echo ("Param(s) passed in..." )
 CALL echo (build2 ("  nmeasure ($1) = " ,nmeasure ) )
 CALL echo (build2 ("  nopt       ($2) = " ,nopt ) )
 IF ((nopt = 1 ) )
  SET noptstr = " Days"
 ELSE
  IF ((nopt = 2 ) )
   SET noptstr = " Weeks"
  ELSE
   IF ((nopt = 3 ) )
    SET noptstr = " Hours"
   ELSE
    IF ((nopt = 4 ) )
     SET noptstr = " Minutes"
    ELSE
     IF ((nopt = 5 ) )
      SET noptstr = " Seconds"
     ELSE
      IF ((nopt = 6 ) )
       SET noptstr = " HundSeconds"
      ELSE
       IF ((nopt = 7 ) )
        SET noptstr = " Days and HHMM"
       ELSE
        IF ((nopt = 8 ) )
         SET noptstr = " Days and HHMMSS"
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (pregnancy_instance p ),
   (pregnancy_child pc )
  PLAN (p
   WHERE (p.person_id = link_personid )
   AND (p.active_ind = 1 ) )
   JOIN (pc
   WHERE (pc.pregnancy_id = p.pregnancy_id )
   AND (pc.active_ind = 1 )
   AND (pc.neonate_outcome_cd IN (4002121_nndeath_cd ,
   4002121_miscarriage_cd ,
   4002121_fetaldeath_cd ) ) )
  HEAD REPORT
   row + 0
  DETAIL
   date_time_diff = datetimediff (cnvtdatetime (curdate ,curtime3 ) ,pc.delivery_dt_tm ,nopt ) ,
   CALL echo (build (" date_time_diff --- > " ,date_time_diff ) ) ,
   IF ((pc.neonate_outcome_cd > 0.0 )
   AND (date_time_diff > 0 )
   AND (date_time_diff < nmeasure ) ) neonataldeathind = 1
   ENDIF
   ,
   CALL echo (neonataldeathind )
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 SET error_check = error (errmsg ,0 )
 IF ((error_check != 0 ) )
  SET log_message = "Failed to find a neo-natal death"
  SET neonataldeathind = - (1 )
  GO TO exit_script
 ENDIF
 GO TO set_return
#set_return
 SET log_misc1 = cnvtstring (neonataldeathind )
 IF ((neonataldeathind = 1 ) )
  SET log_message = " Found a neo-natal death"
 ELSEIF ((neonataldeathind = 0 ) )
  SET log_message =
  " Patient doesn't have a current pregnancy or the delivery method was in the exclusion list"
 ENDIF
 SET retval = 100
#exit_script
 CALL echo (build ("log_misc1 ....." ,log_misc1 ) )
 CALL echo (build ("log_message ..." ,log_message ) )
 CALL echo (build ("retval ........" ,retval ) )
;#end
END GO
