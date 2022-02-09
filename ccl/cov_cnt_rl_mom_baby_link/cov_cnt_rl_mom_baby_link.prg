DROP PROGRAM cov_cnt_rl_mom_baby_link :dba GO
CREATE PROGRAM cov_cnt_rl_mom_baby_link :dba
 DECLARE script_version = vc WITH protect ,noconstant ("002 12/14/12 cerpdj" )
 DECLARE lstat = i4 WITH protect ,noconstant (0 )
 DECLARE errmsg = c132 WITH protect ,noconstant (fillstring (132 ," " ) )
 DECLARE error_check = i2 WITH protect ,noconstant (error (errmsg ,1 ) )
 DECLARE newborncd = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!723871538" ) ) ,protect
 DECLARE gen_lab_cat_cd = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,6000 ,"GENERAL LAB"
   ) )
 DECLARE aborh_cd = f8 WITH constant (uar_get_code_by_cki ("CKI.EC!8431" ) ) ,protect
 DECLARE mompersonid = f8 WITH protect ,noconstant (0 )
 DECLARE momencntrid = f8 WITH protect ,noconstant (0 )
 DECLARE momaborh = c100 WITH protect ,noconstant (fillstring (100 ," " ) )
 SET retval = - (1 )
 select into "nl:"
	from
		 person_person_reltn ppr
		,person p1
		,person p2
		,encounter e
	plan p1
		where p1.person_id = 20735788
	join ppr
		where ppr.person_id = p1.person_id
		and   ppr.person_reltn_cd in(value(uar_get_code_by("DISPLAYKEY",40,"MOTHER")))
	join p2
		where p2.person_id = ppr.related_person_id
	join e
		where e.person_id = p2.person_id
		and   e.encntr_type_cd in(value(uar_get_code_by("MEANING",71,"INPATIENT")))
	order by
		e.encntr_id
		,e.reg_dt_tm desc
  head e.encntr_id
   retval = 100 ,
   mompersonid = e.person_id ,
   momencntrid = e.encntr_id ,
   CALL echo (build (" Mom person id   " ,mompersonid ) ) ,
   CALL echo (build (" Mom encntr id   " ,momencntrid ) )
  WITH nocounter
 ;end select
 SET error_check = error (errmsg ,0 )
 IF ((error_check != 0 ) )
  SET log_misc1 = "ERROR"
  GO TO exit_script
 ENDIF
 IF ((curqual = 0 ) )
  SET retval = 0
 ENDIF
#set_return
 IF ((retval = 100 ) )
  SET log_personid = mompersonid
  SET log_encntrid = momencntrid
  SET log_misc1 = "100"
 ELSEIF ((retval = 0 ) )
  SET log_misc1 = "0"
 ELSE
  SET log_misc1 = "ERROR"
 ENDIF
 CALL echo (build ("log_misc1 ....." ,log_misc1 ) )
 CALL echo (build ("log_personid ..." ,log_personid ) )
 CALL echo (build ("log_enntrid ..." ,log_encntrid ) )
 CALL echo (build ("retval ........" ,retval ) )
#exit_script
 CALL echo ("Ending script....." )
END GO
