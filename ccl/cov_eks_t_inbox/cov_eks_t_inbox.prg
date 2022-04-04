/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_eks_t_inbox.prg
  Object name:        cov_eks_t_inbox
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Additional Required Scripts:
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   12/02/2021  Chad Cummings			initial build
******************************************************************************/
DROP PROGRAM cov_eks_t_inbox :dba GO
CREATE PROGRAM cov_eks_t_inbox :dba
 EXECUTE cov_std_message_routines
 SET failed = - (1 )
 SET nop = - (2 )
 DECLARE gekmmessage = vc
 DECLARE gekmerror = i4
 DECLARE gekmmsgno = i4
 DECLARE gekmresult = i4
 DECLARE discernorddoc_id = f8
 DECLARE request_number = i4
 DECLARE accessionid = f8
 DECLARE orderid = f8
 DECLARE encntrid = f8
 DECLARE personid = f8
 DECLARE linkencntrid = f8
 DECLARE linkpersonid = f8
 SET outbuf = fillstring (32538 ," " )
 SET inbuf = fillstring (32538 ," " )
 RECORD content (
   1 recipientcount = i4
   1 recipients [* ]
     2 personid = f8
     2 name = vc
     2 status = c1
   1 poolcount = i4
   1 pools [* ]
     2 poolid = f8
     2 poolname = vc
     2 status = c1
   1 subject = vc
   1 message = vc
   1 messagetype = i2
   1 priority = i4
   1 status = c1
 )
 RECORD recipientlist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 RECORD msgtlist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 RECORD tmpid (
   1 cnt = i4
   1 qual [* ]
     2 value = f8
     2 name = vc
 )
 RECORD mrecipient (
   1 cnt = i4
   1 qual [* ]
     2 title = vc
 )
 RECORD tmppoolid (
   1 cnt = i4
   1 qual [* ]
     2 value = f8
     2 name = vc
 )
 DECLARE errmsg = vc WITH protect
 DECLARE errcode = i4 WITH protect ,noconstant (0 )
 SET rev_inc = "708"
 SET ininc = "eks_tell_ekscommon"
 SET ttemp = trim (eks_common->cur_module_name )
 SET eksmodule = trim (ttemp )
 FREE SET ttemp
 SET ttemp = trim (eks_common->event_name )
 SET eksevent = ttemp
 SET eksrequest = eks_common->request_number
 FREE SET ttemp
 DECLARE tcurindex = i4
 DECLARE tinx = i4
 SET tcurindex = 1
 SET tinx = 1
 SET evoke_inx = 1
 SET data_inx = 2
 SET logic_inx = 3
 SET action_inx = 4
 IF (NOT ((validate (eksdata->tqual ,"Y" ) = "Y" )
 AND (validate (eksdata->tqual ,"Z" ) = "Z" ) ) )
  FREE SET templatetype
  IF ((conclude > 0 ) )
   SET templatetype = "ACTION"
   SET basecurindex = (logiccnt + evokecnt )
   SET tcurindex = 4
  ELSE
   SET templatetype = "LOGIC"
   SET basecurindex = evokecnt
   SET tcurindex = 3
  ENDIF
  SET cbinx = curindex
  SET tinx = logic_inx
 ELSE
  SET templatetype = "EVOKE"
  SET curindex = 0
  SET tcurindex = 0
  SET tinx = 0
 ENDIF
 CALL echo (concat ("****  " ,format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,
    "hh:mm:ss.cc;3;m" ) ,"     Module:  " ,trim (eksmodule ) ,"  ****" ) ,1 ,0 )
 IF ((validate (tname ,"Y" ) = "Y" )
 AND (validate (tname ,"Z" ) = "Z" ) )
  IF ((templatetype != "EVOKE" ) )
   CALL echo (concat ("****  EKM Beginning of " ,trim (templatetype ) ," Template(" ,build (curindex
      ) ,")           Event:  " ,trim (eksevent ) ,"         Request number:  " ,cnvtstring (
      eksrequest ) ) ,1 ,10 )
  ELSE
   CALL echo (concat ("****  EKM Beginning an Evoke Template" ,"           Event:  " ,trim (eksevent
      ) ,"         Request number:  " ,cnvtstring (eksrequest ) ) ,1 ,10 )
  ENDIF
 ELSE
  IF ((templatetype != "EVOKE" ) )
   CALL echo (concat ("****  EKM Beginning of " ,trim (templatetype ) ," Template(" ,build (curindex
      ) ,"):  " ,trim (tname ) ,"       Event:  " ,trim (eksevent ) ,"         Request number:  " ,
     cnvtstring (eksrequest ) ) ,1 ,10 )
  ELSE
   CALL echo (concat ("****  EKM Beginning Evoke Template:  " ,trim (tname ) ,"       Event:  " ,
     trim (eksevent ) ,"         Request number:  " ,cnvtstring (eksrequest ) ) ,1 ,10 )
  ENDIF
 ENDIF
 SET ininc = "eks_sub_record.inc"
 RECORD ekssub (
   1 orig = vc
   1 parse_ind = i2
   1 num_dec_places = i2
   1 mod = vc
   1 status_flag = i2
   1 msg = vc
   1 format_flag = i4
   1 time_zone = i4
   1 skip_curdate_ind = i2
   1 curdate_fnd_ind = i2
   1 dttm_dq8 = dq8
 )
 FREE RECORD addnotificationrequest
 RECORD addnotificationrequest (
   1 message_list [* ]
     2 draft_msg_uid = vc
     2 person_id = f8
     2 encntr_id = f8
     2 event_cd = f8
     2 task_type_cd = f8
     2 priority_cd = f8
     2 save_to_chart_ind = i2
     2 msg_sender_pool_id = f8
     2 msg_sender_person_id = f8
     2 msg_sender_prsnl_id = f8
     2 msg_subject = vc
     2 refill_request_ind = i2
     2 msg_text = gvc
     2 reminder_dt_tm = dq8
     2 due_dt_tm = dq8
     2 callername = vc
     2 callerphone = vc
     2 notify_info
       3 notify_pool_id = f8
       3 notify_prsnl_id = f8
       3 notify_priority_cd = f8
       3 notify_status_list [* ]
         4 notify_status_cd = f8
         4 delay
           5 value = i4
           5 unit_flag = i2
     2 action_request_list [* ]
       3 action_request_cd = f8
     2 assign_prsnl_list [* ]
       3 assign_prsnl_id = f8
       3 cc_ind = i2
       3 selection_nbr = i4
     2 assign_person_list [* ]
       3 assign_person_id = f8
       3 cc_ind = i2
       3 selection_nbr = i4
       3 reply_allowed_ind = i2
     2 assign_pool_list [* ]
       3 assign_pool_id = f8
       3 assign_prsnl_id = f8
       3 cc_ind = i2
       3 selection_nbr = i4
     2 encounter_class_cd = f8
     2 encounter_type_cd = f8
     2 org_id = f8
     2 get_best_encounter = i2
     2 create_encounter = i2
     2 proposed_order_list [* ]
       3 proposed_order_id = f8
     2 event_id = f8
     2 order_id = f8
     2 encntr_prsnl_reltn_cd = f8
     2 facility_cd = f8
     2 send_to_chart_ind = i2
     2 original_task_uid = vc
     2 rx_renewal_list [* ]
       3 rx_renewal_uid = vc
     2 task_status_flag = i2
     2 task_activity_flag = i2
     2 event_class_flag = i2
     2 attachments [* ]
       3 name = c255
       3 location_handle = c255
       3 media_identifier = c255
       3 media_version = i4
     2 sender_email = c320
     2 assign_emails [* ]
       3 email = c320
       3 cc_ind = i2
       3 selection_nbr = i4
       3 first_name = c100
       3 last_name = c100
       3 display_name = c100
     2 sender_email_display_name = c100
   1 action_dt_tm = dq8
   1 action_tz = i4
   1 skip_validation_ind = i2
 )
 FREE RECORD addnotificationreply
 RECORD addnotificationreply (
   1 invalid_receivers [* ]
     2 entity_id = f8
     2 entity_type = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET eksinx = eks_common->event_repeat_index
 SET gekmmessage = " "
 SET gekmerror = false
 SET gekmmsgno = 1
 SET gekmresult = true
 SET rfailed = 0
 SET request_number = 967102
 SET discernorddoc_id = 0
 CALL writemessage (nop ,concat ("*** Send a MSG_TYPE related to PATIENT to the In-Box" ,
   " of RECIPIENT with subject SUBJECT and message MSG with priority MSG_PRIORITY." ) )
 SET stat_high_cd = 0.00
 SET routine_low_cd = 0.00
 SET stat = uar_get_meaning_by_codeset (1304 ,"STAT" ,1 ,stat_high_cd )
 SET stat = uar_get_meaning_by_codeset (1304 ,"ROUTINE" ,1 ,routine_low_cd )
 SET phone_msg_cd = 0.00
 SET stat = uar_get_meaning_by_codeset (6026 ,"PHONE MSG" ,1 ,phone_msg_cd )
 IF (validateparams (0 ) )
  SET stat = alterlist (addnotificationrequest->message_list ,1 )
  SET addnotificationrequest->message_list[1 ].person_id = personid
  SET addnotificationrequest->message_list[1 ].encntr_id = encntrid
  IF ((content->priority = 3 ) )
   SET addnotificationrequest->message_list[1 ].priority_cd = stat_high_cd
  ELSE
   SET addnotificationrequest->message_list[1 ].priority_cd = routine_low_cd
  ENDIF
  SET addnotificationrequest->message_list[1 ].task_type_cd = phone_msg_cd
  SET addnotificationrequest->message_list[1 ].msg_sender_prsnl_id = reqinfo->updt_id
  SET addnotificationrequest->message_list[1 ].msg_text = content->message
  SET addnotificationrequest->message_list[1 ].msg_subject = content->subject
  SET addnotificationrequest->message_list[1 ].event_id = 0
  IF ((content->recipientcount > 0 ) )
   CALL writemessage (nop ,"Checking for duplicate recipients." )
   SET tmpid->cnt = 0
   SET stat = alterlist (tmpid->qual ,content->recipientcount )
   SELECT DISTINCT INTO "NL:"
    content->recipients[d.seq ].personid
    FROM (dummyt d WITH seq = value (content->recipientcount ) )
    ORDER BY content->recipients[d.seq ].personid
    DETAIL
     tmpid->cnt +=1 ,
     tmpid->qual[tmpid->cnt ].value = content->recipients[d.seq ].personid ,
     tmpid->qual[tmpid->cnt ].name = content->recipients[d.seq ].name
    WITH nocounter
   ;end select
   SET stat = alterlist (tmpid->qual ,tmpid->cnt )
   CALL writemessage (nop ,concat ("Removed " ,trim (cnvtstring ((content->recipientcount - tmpid->
       cnt ) ) ) ," duplicate records." ) )
  ENDIF
  IF ((content->poolcount > 0 ) )
   CALL writemessage (nop ,"Checking for duplicate pools." )
   SET tmppoolid->cnt = 0
   SET stat = alterlist (tmppoolid->qual ,content->poolcount )
   SELECT DISTINCT INTO "NL:"
    content->pools[d.seq ].poolid
    FROM (dummyt d WITH seq = value (content->poolcount ) )
    ORDER BY content->pools[d.seq ].poolid
    DETAIL
     tmppoolid->cnt +=1 ,
     tmppoolid->qual[tmppoolid->cnt ].value = content->pools[d.seq ].poolid ,
     tmppoolid->qual[tmppoolid->cnt ].name = content->pools[d.seq ].poolname
    WITH nocounter
   ;end select
   SET stat = alterlist (tmppoolid->qual ,tmppoolid->cnt )
   CALL writemessage (nop ,concat ("Removed " ,trim (cnvtstring ((content->poolcount - tmppoolid->cnt
        ) ) ) ," duplicate records." ) )
  ENDIF
  FREE RECORD valdrecrequest
  RECORD valdrecrequest (
    1 person_id = f8
    1 notification_type_cd = f8
    1 event_id_list [* ]
      2 event_id = f8
    1 order_id_list [* ]
      2 order_id = f8
    1 encntr_id_list [* ]
      2 encntr_id = f8
    1 receiver_list [* ]
      2 personnel_id = f8
      2 personnel_group_id = f8
    1 org_id = f8
    1 get_best_encounter = i2
    1 create_encounter = i2
    1 facility_cd = f8
    1 reminder_save_to_chart_ind = i2
    1 encntr_prsnl_reltn_cd = f8
    1 category_type_cd = f8
  )
  FREE RECORD valdrecreply
  RECORD valdrecreply (
    1 receiver_ind_list [* ]
      2 personnel_id = f8
      2 personnel_group_id = f8
      2 valid_receiver_ind = i2
    1 encntr_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET valdrecrequest->person_id = addnotificationrequest->message_list[1 ].person_id
  SET stat = alterlist (valdrecrequest->encntr_id_list ,1 )
  SET valdrecrequest->encntr_id_list[1 ].encntr_id = addnotificationrequest->message_list[1 ].
  encntr_id
  SET msg_cd = 0.00
  SET stat = uar_get_meaning_by_codeset (3404 ,"MESSAGES" ,1 ,msg_cd )
  SET valdrecrequest->category_type_cd = msg_cd
  IF ((tmpid->cnt > 0 ) )
   SET stat = alterlist (valdrecrequest->receiver_list ,tmpid->cnt )
   FOR (i = 1 TO tmpid->cnt )
    SET valdrecrequest->receiver_list[i ].personnel_id = tmpid->qual[i ].value
   ENDFOR
  ENDIF
  IF ((tmppoolid->cnt > 0 ) )
   SET stat = alterlist (valdrecrequest->receiver_list ,(tmpid->cnt + tmppoolid->cnt ) )
   FOR (i = (tmpid->cnt + 1 ) TO size (valdrecrequest->receiver_list ,5 ) )
    SET valdrecrequest->receiver_list[i ].personnel_group_id = tmppoolid->qual[(i - tmpid->cnt ) ].
    value
   ENDFOR
  ENDIF
  SET stat = tdbexecute (0 ,967100 ,967582 ,"REC" ,valdrecrequest ,"REC" ,valdrecreply ,1 )
  SET errcode = error (errmsg ,1 )
  IF ((stat != 0 ) )
   CALL writemessage (failed ,concat ("TDBEXECUTE 967582-error code: " ,build (errcode ) ,
     " with error message: " ,build (errmsg ) ) )
  ENDIF
  IF ((cnvtupper (trim (valdrecreply->status_data.status ) ) = "F" ) )
   CALL writemessage (failed ,"cannot process request 967582 succesfully" )
  ENDIF
  SET gekmmessage = "Sent to: "
  DECLARE recipientname = vc WITH protect
  DECLARE iprsnlcnt = i4 WITH protect
  DECLARE ipoolcnt = i4 WITH protect
  DECLARE iinvalidcnt = i4 WITH protect
  DECLARE ivalreplysize = i4 WITH protect
  SET ivalreplysize = size (valdrecreply->receiver_ind_list ,5 )
  FOR (i = 1 TO ivalreplysize )
   SET ipos = 0
   SET inum = 0
   SET recipientname = "<unknown>"
   IF ((valdrecreply->receiver_ind_list[i ].personnel_id > 0 ) )
    SET ipos = locateval (inum ,ipos ,tmpid->cnt ,valdrecreply->receiver_ind_list[i ].personnel_id ,
     tmpid->qual[inum ].value )
    IF ((ipos > 0 ) )
     SET recipientname = trim (tmpid->qual[ipos ].name )
    ENDIF
   ELSEIF ((valdrecreply->receiver_ind_list[i ].personnel_group_id > 0 ) )
    SET ipos = locateval (inum ,ipos ,tmppoolid->cnt ,valdrecreply->receiver_ind_list[i ].
     personnel_group_id ,tmppoolid->qual[inum ].value )
    IF ((ipos > 0 ) )
     SET recipientname = trim (tmppoolid->qual[ipos ].name )
    ENDIF
   ENDIF
   IF ((ipos <= 0 ) )
    SET recipientname = trim (cnvtstring (valdrecreply->receiver_ind_list[i ].personnel_id ,25 ,1 )
     )
   ENDIF
   IF ((valdrecreply->receiver_ind_list[i ].valid_receiver_ind > 0 ) )
    IF ((valdrecreply->receiver_ind_list[i ].personnel_id > 0 ) )
     SET iprsnlcnt +=1
     SET stat = alterlist (addnotificationrequest->message_list[1 ].assign_prsnl_list ,iprsnlcnt )
     SET addnotificationrequest->message_list[1 ].assign_prsnl_list[iprsnlcnt ].assign_prsnl_id =
     valdrecreply->receiver_ind_list[i ].personnel_id
    ELSEIF ((valdrecreply->receiver_ind_list[i ].personnel_group_id > 0 ) )
     SET ipoolcnt +=1
     SET stat = alterlist (addnotificationrequest->message_list[1 ].assign_pool_list ,ipoolcnt )
     SET addnotificationrequest->message_list[1 ].assign_pool_list[ipoolcnt ].assign_pool_id =
     valdrecreply->receiver_ind_list[i ].personnel_group_id
    ENDIF
    SET gekmmessage = concat (gekmmessage ," " ,recipientname ,"; " )
   ELSE
    SET mrecipient->cnt +=1
    SET stat = alterlist (mrecipient->qual ,mrecipient->cnt )
    SET mrecipient->qual[mrecipient->cnt ].title = concat (recipientname ,"(" ,trim (cnvtstring (
       valdrecreply->receiver_ind_list[i ].valid_receiver_ind ) ) ,")" )
    SET iinvalidcnt +=1
   ENDIF
  ENDFOR
  SET gekmmessage = concat (substring (1 ,(size (gekmmessage ,1 ) - 1 ) ,gekmmessage ) ,".  " )
  CALL echo (concat ("Found " ,build (iinvalidcnt ) ," invalid recipients!" ) )
  CALL echorecord (addnotificationrequest )
  DECLARE ii = i2
  FOR (ii = 1 TO size (addnotificationrequest->message_list[1 ].assign_pool_list ,5 ) )
   SET stat = add_reminder (addnotificationrequest->message_list[1 ].assign_pool_list[ii ].
    assign_pool_id ,addnotificationrequest->message_list[1 ].msg_sender_prsnl_id ,
    addnotificationrequest->message_list[1 ].encntr_id ,addnotificationrequest->message_list[1 ].
    msg_subject ,addnotificationrequest->message_list[1 ].msg_text )
  ENDFOR
  IF ((stat = 0 ) )
   CALL writemessage (failed ,"cannot process request add_reminder succesfully" )
  ENDIF
  IF ((content->poolcount = 0 ) )
   CALL writemessage (false ,"Recipients/Pools are not found." )
  ENDIF
 ELSE
  CALL writemessage (nop ,"Error in validating parameters. No messages sent." )
 ENDIF
 IF ((gekmresult IN (1 ,
 0 ) ) )
  IF ((mrecipient->cnt > 0 ) )
   SET gekmmessage = concat (gekmmessage ," Unable to send to: " )
   FOR (i = 1 TO mrecipient->cnt )
    IF ((i < mrecipient->cnt ) )
     SET gekmmessage = concat (gekmmessage ," " ,mrecipient->qual[i ].title ,"; " )
    ELSE
     SET gekmmessage = concat (gekmmessage ," " ,mrecipient->qual[i ].title ,". " )
    ENDIF
   ENDFOR
  ENDIF
  IF ((size (gekmmessage ) > 2000 ) )
   SET gekmmessage = substring (1 ,2000 ,gekmmessage )
  ENDIF
  SET eksdata->tqual[tcurindex ].qual[curindex ].logging = gekmmessage
  SET retval = (gekmresult * 100 )
 ELSE
  IF ((size (gekmmessage ) > 2000 ) )
   SET gekmmessage = substring (1 ,2000 ,gekmmessage )
  ENDIF
  SET eksdata->tqual[tcurindex ].qual[curindex ].logging = gekmmessage
  SET retval = gekmresult
 ENDIF
 SET rev_inc = "708"
 SET ininc = "eks_set_eksdata"
 IF ((accessionid = 0 ) )
  IF ((orderid != 0 ) )
   SELECT INTO "NL:"
    a.accession_id
    FROM (accession_order_r a )
    WHERE (a.order_id = orderid )
    AND (a.primary_flag = 0 )
    DETAIL
     accessionid = a.accession_id
    WITH nocounter
   ;end select
  ELSEIF (NOT ((validate (accession ,"Y" ) = "Y" )
  AND (validate (accession ,"Z" ) = "Z" ) ) )
   IF ((textlen (trim (accession ) ) > 0 ) )
    SELECT INTO "NL:"
     a.accession_id
     FROM (accession_order_r a )
     WHERE (a.accession = accession )
     DETAIL
      accessionid = a.accession_id
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 IF ((personid = 0 ) )
  FREE SET temp
  IF ((orderid > 0 ) )
   SELECT
    *
    FROM (orders o )
    WHERE (o.order_id = orderid )
    DETAIL
     personid = o.person_id
    WITH nocounter
   ;end select
  ELSEIF ((encntrid > 0 ) )
   SELECT
    *
    FROM (encounter en )
    WHERE (en.encntr_id = encntrid )
    DETAIL
     personid = en.person_id
    WITH nocounter
   ;end select
  ENDIF
  IF (NOT ((validate (temp ,"Y" ) = "Y" )
  AND (validate (temp ,"Z" ) = "Z" ) ) )
   SELECT INTO "nl:"
    o.person_id
    FROM (orders o )
    WHERE parser (temp )
    DETAIL
     personid = o.person_id
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET eksdata->tqual[tcurindex ].qual[curindex ].accession_id = accessionid
 SET eksdata->tqual[tcurindex ].qual[curindex ].order_id = orderid
 SET eksdata->tqual[tcurindex ].qual[curindex ].encntr_id = encntrid
 SET eksdata->tqual[tcurindex ].qual[curindex ].person_id = personid
 IF (NOT ((validate (ekstaskassaycd ,0 ) = 0 )
 AND (validate (ekstaskassaycd ,1 ) = 1 ) ) )
  SET eksdata->tqual[tcurindex ].qual[curindex ].task_assay_cd = ekstaskassaycd
 ELSE
  SET eksdata->tqual[tcurindex ].qual[curindex ].task_assay_cd = 0
 ENDIF
 IF (NOT ((validate (eksdata->tqual[tcurindex ].qual[curindex ].template_name ,"Y" ) = "Y" )
 AND (validate (eksdata->tqual[tcurindex ].qual[curindex ].template_name ,"Z" ) = "Z" ) ) )
  IF ((trim (eksdata->tqual[tcurindex ].qual[curindex ].template_name ) = "" )
  AND NOT ((validate (tname ,"Y" ) = "Y" )
  AND (validate (tname ,"Z" ) = "Z" ) ) )
   SET eksdata->tqual[tcurindex ].qual[curindex ].template_name = tname
  ENDIF
 ENDIF
 IF (NOT ((validate (eksce_id ,0 ) = 0 )
 AND (validate (eksce_id ,1 ) = 1 ) ) )
  IF (NOT ((validate (eksdata->tqual[tcurindex ].qual[curindex ].clinical_event_id ,0 ) = 0 )
  AND (validate (eksdata->tqual[tcurindex ].qual[curindex ].clinical_event_id ,1 ) = 1 ) ) )
   SET eksdata->tqual[tcurindex ].qual[curindex ].clinical_event_id = eksce_id
  ENDIF
 ENDIF
 SUBROUTINE  validateparams (_null )
  DECLARE link_indx = i2
  CALL writemessage (nop ,"Validating external variable RECIPIENT." )
  IF ((validate (recipient ,"Z" ) = "Z" )
  AND (validate (recipient ,"Y" ) = "Y" ) )
   CALL writemessage (failed ,"The external variable RECIPIENT wasn't defined by the template!" )
  ELSE
   SET orig_param = recipient
   EXECUTE eks_t_parse_list WITH replace (reply ,recipientlist )
   FREE SET orig_param
   IF ((recipientlist->cnt = 0 ) )
    CALL writemessage (failed ,"The required variable RECIPIENT doesn't contain any values!" )
   ENDIF
  ENDIF
  IF (NOT (gekmerror ) )
   CALL writemessage (nop ,"Validating external variable PATIENT." )
   IF ((validate (patient ,"Y" ) = "Y" )
   AND (validate (patient ,"Z" ) = "Z" ) )
    SET link_indx = 0
    CALL writemessage (failed ,"The external variable PATIENT wasn't defined by the template!" )
   ELSE
    SET link_indx = cnvtint (patient )
    SET accessionid = eksdata->tqual[logic_inx ].qual[link_indx ].accession_id
    SET orderid = eksdata->tqual[logic_inx ].qual[link_indx ].order_id
    SET personid = eksdata->tqual[logic_inx ].qual[link_indx ].person_id
    SET encntrid = eksdata->tqual[logic_inx ].qual[link_indx ].encntr_id
    IF ((personid = 0 ) )
     CALL writemessage (failed ,"Invalid link! PersonID is not defined!" )
    ENDIF
   ENDIF
  ENDIF
  IF (NOT (gekmerror ) )
   CALL writemessage (nop ,"Validating external variable SUBJECT" )
   IF ((validate (subject ,"Z" ) = "Z" )
   AND (validate (subject ,"Y" ) = "Y" ) )
    CALL writemessage (failed ,"The external variable SUBJECT wasn't defined by the template!" )
   ELSEIF ((((subject = "" ) ) OR ((((subject = " " ) ) OR ((trim (cnvtupper (subject ) ) =
   "<UNDEFINED>" ) )) )) )
    CALL writemessage (failed ,"The required variable SUBJECT doesn't contain any values!" )
   ENDIF
  ENDIF
  IF (NOT (gekmerror ) )
   CALL writemessage (nop ,"Validating external variable MSG" )
   IF ((validate (msg ,"Z" ) = "Z" )
   AND (validate (msg ,"Y" ) = "Y" ) )
    CALL writemessage (failed ,"The external variable MSG wasn't defined by the template!" )
   ELSEIF ((((msg = "" ) ) OR ((((msg = " " ) ) OR ((trim (cnvtupper (msg ) ) = "<UNDEFINED>" ) ))
   )) )
    CALL writemessage (failed ,"The required variable MSG doesn't contain any values!!" )
   ENDIF
  ENDIF
  IF (NOT (gekmerror ) )
   CALL writemessage (nop ,"Validating external variable MSG_TYPE" )
   IF ((validate (msg_type ,"Z" ) = "Z" )
   AND (validate (msg_type ,"Y" ) = "Y" ) )
    CALL writemessage (failed ,"The external variable MSG_TYPE wasn't defined by the template!" )
   ELSEIF ((((msg_type = "" ) ) OR ((((msg_type = " " ) ) OR ((trim (cnvtupper (msg_type ) ) =
   "<UNDEFINED>" ) )) )) )
    CALL writemessage (failed ,"The required variable MSG_TYPE doesn't contain any values!!" )
   ELSE
    SET orig_param = msg_type
    EXECUTE eks_t_parse_list WITH replace (reply ,msgtlist )
    FREE SET orig_param
    IF ((msgtlist->cnt = 0 ) )
     CALL writemessage (failed ,"MSG_TYPE doesn't contain any values!" )
    ENDIF
   ENDIF
  ENDIF
  IF (NOT (gekmerror ) )
   CALL writemessage (nop ,"Validating external variable MSG_PRIORITY" )
   IF ((validate (msg_priority ,"Z" ) = "Z" )
   AND (validate (msg_priority ,"Y" ) = "Y" ) )
    CALL writemessage (failed ,"The external variable MSG_PRIORITY wasn't defined by the template!"
     )
   ENDIF
   IF ((msg_priority > " " )
   AND (trim (cnvtupper (msg_priority ) ) != "<UNDEFINED>" )
   AND NOT (gekmerror ) )
    CASE (cnvtupper (msg_priority ) )
     OF "LOW" :
      SET content->priority = 1
     OF "MEDIUM" :
      SET content->priority = 2
     OF "HIGH" :
      SET content->priority = 3
     ELSE
      SET content->priority = cnvtint (msg_priority )
    ENDCASE
   ELSE
    CALL writemessage (failed ,"MSG_PRIORITY doesn't contain any values!" )
   ENDIF
  ENDIF
  IF ((gekmerror = false ) )
   CALL writemessage (nop ,"Inbox parameters are:" )
   CALL writemessage (nop ,concat ("     Sending: " ,trim (msg_type ) ) )
   CALL writemessage (nop ,concat ("     With subject: " ,trim (subject ) ) )
   CALL writemessage (nop ,concat ("     With priority of	: " ,trim (msg_priority ) ) )
   CALL writemessage (nop ,concat ("     And message text of : " ,trim (msg ) ) )
  ENDIF
  IF (gekmresult
  AND NOT (gekmerror ) )
   CALL parserecipients (0 )
  ENDIF
  IF (gekmresult
  AND NOT (gekmerror ) )
   CALL parsesubject (0 )
   IF ((validate (escalation_data->subject ,"X" ) = "X" )
   AND (validate (escalation_data->subject ,"Y" ) = "Y" ) )
    CALL echo ("Escalation Subject will not be written to table" )
   ELSE
    SET escalation_data->subject = content->subject
    CALL echo (concat ("Escalation Subject of <" ,content->subject ,"> will be written to the table"
      ) )
   ENDIF
  ENDIF
  IF (gekmresult
  AND NOT (gekmerror ) )
   CALL parsemessage (0 )
   IF ((validate (escalation_data->message ,"X" ) = "X" )
   AND (validate (escalation_data->message ,"Y" ) = "Y" ) )
    CALL echo ("Escalation Message will not be written to table" )
   ELSE
    SET escalation_data->message = content->message
    CALL echo ("Escalation Message will be written to the table" )
   ENDIF
  ENDIF
  IF ((((gekmresult = failed ) ) OR ((gekmresult = false ) )) )
   RETURN (false )
  ELSE
   RETURN (gekmresult )
  ENDIF
 END ;Subroutine
 SUBROUTINE  parserecipients (_null )
  CALL writemessage (nop ,"Building a list of recipients." )
  RECORD tmpargs (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  RECORD tmpprsnl (
    1 count = i2
    1 prsnl [* ]
      2 category = i4
      2 value = f8
      2 name = vc
      2 status = i2
  )
  DECLARE tmpcode_set = i4
  DECLARE tmpcount = i4
  CALL writemessage (nop ,
   "Converting arguments and checking PERSON, PATIENT and ORDER_RELATION category." )
  SET content->recipientcount = 0
  SET tmpprsnl->count = recipientlist->cnt
  SET stat = alterlist (tmpprsnl->prsnl ,recipientlist->cnt )
  FOR (i = 1 TO recipientlist->cnt )
   CALL parsearguments (recipientlist->qual[i ].value ,"|" ,tmpargs )
   SET tmpprsnl->prsnl[i ].category = cnvtint (trim (tmpargs->items[2 ].value ) )
   SET eks_cki_string = "!"
   SET cki_pos = findstring (eks_cki_string ,tmpargs->items[1 ].value ,1 )
   IF ((cki_pos > 0 )
   AND (substring ((cki_pos + 1 ) ,1 ,tmpargs->items[1 ].value ) != "=" ) )
    CALL echo (concat ("CKI found - " ,tmpargs->items[1 ].value ) )
    SET tmpprsnl->prsnl[i ].value = uar_get_code_by_cki (nullterm (tmpargs->items[1 ].value ) )
   ELSE
    SET tmpprsnl->prsnl[i ].value = cnvtreal (trim (tmpargs->items[1 ].value ) )
   ENDIF
   SET tmpprsnl->prsnl[i ].name = recipientlist->qual[i ].display
   SET tmpprsnl->prsnl[i ].status = 0
   IF ((tmpprsnl->prsnl[i ].category = 0 ) )
    SET content->recipientcount +=1
    SET stat = alterlist (content->recipients ,content->recipientcount )
    SET content->recipients[content->recipientcount ].personid = tmpprsnl->prsnl[i ].value
    SET content->recipients[content->recipientcount ].name = recipientlist->qual[i ].display
    SET tmpprsnl->prsnl[i ].status = 1
   ELSEIF ((tmpprsnl->prsnl[i ].category = 3 ) )
    CALL writemessage (nop ,"Checking Patient" )
    IF ((personid > 0 ) )
     SELECT INTO "nl:"
      pl.person_id
      FROM (prsnl pl )
      WHERE (pl.person_id = personid )
      DETAIL
       content->recipientcount +=1 ,
       stat = alterlist (content->recipients ,content->recipientcount ) ,
       content->recipients[content->recipientcount ].personid = personid ,
       content->recipients[content->recipientcount ].name = pl.name_full_formatted ,
       tmpprsnl->prsnl[i ].status = 1
      WITH nocounter
     ;end select
     IF ((curqual > 0 ) )
      CALL writemessage (nop ,"Found Patient" )
     ENDIF
    ENDIF
   ELSEIF ((tmpprsnl->prsnl[i ].category = 1 ) )
    IF ((tmpprsnl->prsnl[i ].value = 1 ) )
     CALL writemessage (nop ,"Checking Consult Physician" )
     IF ((orderid > 0 ) )
      SET consultdoc_flag = 0
      SET consultdoc_value_flag = 0
      SELECT INTO "nl:"
       od.oe_field_value
       FROM (order_detail od ),
        (prsnl pl )
       PLAN (od
        WHERE (od.order_id = orderid )
        AND (od.oe_field_meaning = "CONSULTDOC" ) )
        JOIN (pl
        WHERE (pl.person_id = od.oe_field_value ) )
       ORDER BY od.order_id ,
        od.action_sequence DESC
       DETAIL
        IF ((consultdoc_flag = 0 )
        AND (od.oe_field_value > 0 ) ) consultdoc_value_flag = 1 ,content->recipientcount +=1 ,stat
         = alterlist (content->recipients ,content->recipientcount ) ,content->recipients[content->
         recipientcount ].personid = od.oe_field_value ,content->recipients[content->recipientcount ]
         .name = pl.name_full_formatted ,tmpprsnl->prsnl[i ].status = 1
        ENDIF
       FOOT  od.action_sequence
        consultdoc_flag = 1
       WITH nocounter
      ;end select
      IF ((curqual > 0 )
      AND (consultdoc_value_flag = 1 ) )
       CALL writemessage (nop ,"Found Consult Physician" )
      ELSEIF ((curqual > 0 )
      AND (consultdoc_value_flag = 0 ) )
       CALL writemessage (nop ,"Found Consult Physician but oe_field_value = 0" )
      ENDIF
     ENDIF
    ELSEIF ((tmpprsnl->prsnl[i ].value = 2 ) )
     CALL writemessage (nop ,"Checking Order Physician" )
     EXECUTE eks_t_get_orderphysician
     IF ((discernorddoc_id > 0 ) )
      SELECT INTO "nl:"
       pl.person_id
       FROM (prsnl pl )
       WHERE (pl.person_id = discernorddoc_id )
       DETAIL
        content->recipientcount +=1 ,
        stat = alterlist (content->recipients ,content->recipientcount ) ,
        content->recipients[content->recipientcount ].personid = discernorddoc_id ,
        content->recipients[content->recipientcount ].name = pl.name_full_formatted ,
        tmpprsnl->prsnl[i ].status = 1
       WITH nocounter
      ;end select
      IF ((curqual > 0 ) )
       CALL writemessage (nop ,"Found Order Physician" )
      ENDIF
      SET discernorddoc_id = 0
     ENDIF
    ENDIF
   ELSEIF ((tmpprsnl->prsnl[i ].category = 999 ) )
    CALL writemessage (nop ,"Checking Pool" )
    SET content->poolcount +=1
    SET stat = alterlist (content->pools ,content->poolcount )
    SET content->pools[content->poolcount ].poolid = tmpprsnl->prsnl[i ].value
    SET content->pools[content->poolcount ].poolname = tmpprsnl->prsnl[i ].name
    SET tmpprsnl->prsnl[i ].status = 1
   ENDIF
  ENDFOR
  IF ((content->recipientcount = 0 ) )
   CALL writemessage (nop ,"No entries found in PERSON, PATIENT or ORDER_RELATION category" )
  ELSE
   CALL writemessage (nop ,concat ("Found " ,trim (cnvtstring (content->recipientcount ) ) ,
     " entries in PERSON, PATIENT or ORDER_RELATION category." ) )
  ENDIF
  CALL writemessage (nop ,"Checking PERSON/PERSONNEL category." )
  SET tmpcode_set = 331
  SET tmpcount = 0
  SELECT INTO "NL:"
   p.prsnl_person_id
   FROM (person_prsnl_reltn p ),
    (prsnl pl ),
    (dummyt d WITH seq = value (tmpprsnl->count ) )
   PLAN (d )
    JOIN (p
    WHERE (p.person_id = personid )
    AND (p.active_ind > 0 )
    AND (p.person_prsnl_r_cd = tmpprsnl->prsnl[d.seq ].value )
    AND (cnvtdatetime (sysdate ) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm )
    AND (tmpprsnl->prsnl[d.seq ].category = tmpcode_set ) )
    JOIN (pl
    WHERE (p.prsnl_person_id = pl.person_id ) )
   DETAIL
    tmpcount +=1 ,
    content->recipientcount +=1 ,
    stat = alterlist (content->recipients ,content->recipientcount ) ,
    content->recipients[content->recipientcount ].personid = p.prsnl_person_id ,
    content->recipients[content->recipientcount ].name = pl.name_full_formatted ,
    tmpprsnl->prsnl[d.seq ].status = 1
   WITH nocounter
  ;end select
  IF ((tmpcount > 0 ) )
   CALL writemessage (nop ,concat ("Found " ,trim (cnvtstring (tmpcount ) ) ,
     " entries in PERSON/PERSONNEL category." ) )
  ELSE
   CALL writemessage (nop ,"No entries found in PERSON/PERSONNEL category" )
  ENDIF
  CALL writemessage (nop ,"Checking ENCOUNTER/PERSONNEL category." )
  SET tmpcode_set = 333
  SET tmpcount = 0
  SELECT INTO "NL:"
   e.prsnl_person_id
   FROM (encntr_prsnl_reltn e ),
    (prsnl pl ),
    (dummyt d WITH seq = value (tmpprsnl->count ) )
   PLAN (d )
    JOIN (e
    WHERE (e.encntr_id = encntrid )
    AND (e.active_ind > 0 )
    AND (e.encntr_prsnl_r_cd = tmpprsnl->prsnl[d.seq ].value )
    AND ((e.expiration_ind + 0 ) = 0 )
    AND (cnvtdatetime (sysdate ) BETWEEN e.beg_effective_dt_tm AND e.end_effective_dt_tm )
    AND (tmpprsnl->prsnl[d.seq ].category = tmpcode_set ) )
    JOIN (pl
    WHERE (e.prsnl_person_id = pl.person_id ) )
   DETAIL
    tmpcount +=1 ,
    content->recipientcount +=1 ,
    stat = alterlist (content->recipients ,content->recipientcount ) ,
    content->recipients[content->recipientcount ].personid = e.prsnl_person_id ,
    content->recipients[content->recipientcount ].name = pl.name_full_formatted ,
    tmpprsnl->prsnl[d.seq ].status = 1
   WITH nocounter
  ;end select
  IF ((tmpcount > 0 ) )
   CALL writemessage (nop ,concat ("Found " ,trim (cnvtstring (tmpcount ) ) ,
     " entries in ENCOUNTER/PERSONNEL category." ) )
  ELSE
   CALL writemessage (nop ,"No entries found in ENCOUNTER/PERSONNEL category" )
  ENDIF
  CALL writemessage (nop ,"Recipients not related to the patient: " )
  SET mrecipient->cnt = 0
  FOR (i = 1 TO tmpprsnl->count )
   IF ((tmpprsnl->prsnl[i ].status = 0 ) )
    SET mrecipient->cnt +=1
    SET stat = alterlist (mrecipient->qual ,mrecipient->cnt )
    IF ((tmpprsnl->prsnl[i ].category = 1 ) )
     IF ((tmpprsnl->prsnl[i ].value = 1 ) )
      SET mrecipient->qual[mrecipient->cnt ].title = "Consult Physician"
     ELSE
      SET mrecipient->qual[mrecipient->cnt ].title = "Order Physician"
     ENDIF
    ELSEIF ((tmpprsnl->prsnl[i ].category = 3 ) )
     SET mrecipient->qual[mrecipient->cnt ].title = cnvtstring (personid ,25 ,1 )
    ELSE
     SET mrecipient->qual[mrecipient->cnt ].title = uar_get_code_display (tmpprsnl->prsnl[i ].value
      )
    ENDIF
    CALL echo (mrecipient->qual[mrecipient->cnt ].title )
   ENDIF
  ENDFOR
  CALL echo (concat ("Total: " ,cnvtstring (mrecipient->cnt ) ) )
  IF ((content->recipientcount = 0 )
  AND (content->poolcount = 0 ) )
   CALL writemessage (false ,"No recipients/Pools are found!" )
  ELSE
   CALL writemessage (nop ,"List of recipients" )
   FOR (i = 1 TO content->recipientcount )
    CALL writemessage (nop ,concat ("   Found " ,content->recipients[i ].name ," with person ID = " ,
      cnvtstring (content->recipients[i ].personid ,25 ,1 ) ) )
   ENDFOR
   IF ((content->poolcount > 0 ) )
    CALL writemessage (nop ,"List of pools" )
    FOR (i = 1 TO content->poolcount )
     CALL writemessage (nop ,concat ("   Found " ,content->pools[i ].poolname ," with pool ID = " ,
       cnvtstring (content->pools[i ].poolid ,25 ,1 ) ) )
    ENDFOR
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  parsesubject (_null )
  CALL writemessage (nop ,concat ("Parsing SUBJECT." ,subject ) )
  IF (findstring ("@TEMPLATE" ,subject ) )
   CALL writemessage (failed ,"Substitution option @TEMPLATE can not be used in a subject" )
  ENDIF
  IF (findstring ("@" ,subject ) )
   SET ekssub->parse_ind = 0
   SET ekssub->orig = subject
   EXECUTE eks_t_subcalc
   SET content->subject = ekssub->mod
   IF ((ekssub->format_flag != 0 ) )
    SET inbuf = content->subject
    CALL striprtf (0 )
    SET content->subject = outbuf
   ENDIF
  ELSE
   SET content->subject = subject
  ENDIF
 END ;Subroutine
 SUBROUTINE  parsemessage (_null )
  CALL writemessage (nop ,"Parsing MSG." )
  IF ((findstring ("@" ,msg ) > 0 ) )
   CALL writemessage (nop ,"'@' substitution symbol found." )
   IF ((findstring ("@FILE[" ,msg ) > 0 ) )
    CALL writemessage (nop ,"@FILE substitution symbol found, using file as message content" )
    SET filename = fillstring (255 ," " )
    SET pos = (findstring ("@FILE[" ,msg ) + 6 )
    SET len = size (trim (msg ) )
    WHILE ((pos < len ) )
     IF ((substring (pos ,1 ,msg ) != "]" ) )
      SET filename = concat (trim (filename ) ,substring (pos ,1 ,msg ) )
      SET pos +=1
     ENDIF
    ENDWHILE
    CALL writemessage (nop ,concat ("Reading file '" ,trim (filename ) ,"' for message." ) )
    FREE DEFINE rtl
    DEFINE rtl value (filename ) WITH nomodify
    SELECT INTO "NL:"
     r.*
     FROM (rtlt r )
     HEAD REPORT
      content->message = "" ,
      first = true
     DETAIL
      IF ((first = true ) ) content->message = concat (trim (content->message ) ,trim (r.line ) ,
        " @NEWLINE" ) ,first = false
      ELSE content->message = concat (trim (content->message ) ," " ,trim (r.line ) ," @NEWLINE" )
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SET content->message = trim (msg )
   ENDIF
   IF ((findstring ("@" ,content->message ) > 0 ) )
    SET ekssub->parse_ind = 0
    SET ekssub->orig = content->message
    EXECUTE eks_t_subcalc
    SET content->message = trim (ekssub->mod )
    SET content->messagetype = ekssub->format_flag
   ENDIF
  ELSE
   SET content->message = trim (msg )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (parsearguments (strvararg =vc ,strdelimiter =vc ,result =vc (ref ) ) =null )
  RECORD targuments (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  SET delstart = 1
  SET delend = size (trim (strvararg ) ,1 )
  SET delim = trim (strdelimiter )
  IF (NOT ((delim > "" ) ) )
   SET delim = "|"
  ENDIF
  SET targuments->count = 0
  WHILE ((findstring (delim ,strvararg ,delstart ) > 0 )
  AND (targuments->count <= 25 ) )
   SET cutto = findstring (delim ,strvararg ,delstart )
   SET cutlen = (cutto - delstart )
   SET targuments->count +=1
   SET targuments->items[targuments->count ].value = substring (delstart ,cutlen ,strvararg )
   SET delstart = (cutto + 1 )
  ENDWHILE
  SET cutto = ((delend - delstart ) + 1 )
  SET targuments->count +=1
  SET targuments->items[targuments->count ].value = substring (delstart ,cutto ,strvararg )
  SET result = targuments
 END ;Subroutine
 SUBROUTINE  writemessage (wmekmstatus ,wmekmlogmessage )
  SET rtlmsg = fillstring (132 ,"" )
  IF ((wmekmstatus = failed ) )
   SET gekmerror = true
   SET gekmresult = failed
   SET gekmmessage = wmekmlogmessage
  ELSEIF ((wmekmstatus = false ) )
   SET gekmresult = false
  ENDIF
  IF ((wmekmlogmessage > "" ) )
   IF ((substring ((size (trim (wmekmlogmessage ) ) - 2 ) ,3 ,wmekmlogmessage ) = "..." ) )
    CALL echo (substring (1 ,(size (trim (wmekmlogmessage ) ) - 3 ) ,wmekmlogmessage ) ,0 )
   ELSE
    CALL echo (wmekmlogmessage )
   ENDIF
  ENDIF
 END ;Subroutine
END GO
