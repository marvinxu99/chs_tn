DROP PROGRAM cov_t_alert_html_a :dba GO
CREATE PROGRAM cov_t_alert_html_a :dba
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
 DECLARE msg = vc WITH notrim
 DECLARE documentbody = vc
 DECLARE title = vc
 DECLARE freetext = vc
 DECLARE okbuttontitle = vc
 DECLARE modulename = vc
 DECLARE beksrepeatcountlink = i2 WITH public ,noconstant (0 )
 DECLARE tmpfilename = vc
 DECLARE tempstarttime = f8
 SET tempstarttime = curtime3
 DECLARE gethtmlcontents (_null ) = i2
 DECLARE validateparams (_null ) = i2
 DECLARE createxml (_null ) = i2
 DECLARE link_indx = i4
 DECLARE eksmsgval = vc
 DECLARE linkmiscsize = i4
 DECLARE beksrepeatcountlink = i2
 DECLARE endloop = i4
 DECLARE indx = i4
 DECLARE spindex = i4
 DECLARE newspindex = i4 WITH protect ,noconstant (0 )
 DECLARE alertcount = i4
 DECLARE origalertcount = i4
 DECLARE overridereasonrep = vc
 DECLARE overridedefaultrep = vc
 DECLARE problemsrep = vc
 DECLARE probdefaultrep = vc
 DECLARE probconfrep = vc
 DECLARE probclassrep = vc
 DECLARE boverridedefault = i2 WITH public ,noconstant (0 )
 DECLARE streksrepeatcount = vc WITH protect
 RECORD tmprecord (
   1 cnt = i2
   1 qual [* ]
     2 misc_data = vc
 )
 DECLARE cntspindex = i2 WITH protect ,noconstant (0 )
 DECLARE cntorderlist = i2 WITH protect ,noconstant (0 )
 DECLARE isyncolon = i2 WITH protect ,noconstant (0 )
 DECLARE isizeofstring = i2 WITH protect ,noconstant (0 )
 DECLARE cntqual = i2 WITH protect ,noconstant (0 )
 DECLARE isp = i4 WITH protect ,noconstant (0 )
 DECLARE jsp = i4 WITH protect ,noconstant (0 )
 DECLARE ipipe = i4 WITH protect ,noconstant (0 )
 DECLARE tmpeksstr = vc
 DECLARE inttemplateoptlink = i2 WITH public ,noconstant (0 )
 CALL echo (concat (format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,"hh:mm:ss.cc;3;m" ) ,
   "  *********  Beginning of Program EKS_T_ALERT_HTML_A" ,"  *********" ) ,1 ,0 )
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
 RECORD subcalc (
   1 body = vc
 )
 RECORD opt_override_reasonlist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 RECORD opt_problemslist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 RECORD opt_prob_confirmationlist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 RECORD opt_prob_classificationlist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 SET personid = 0.0
 SET encntrid = 0.0
 SET count = 0
 SET personid = request->person_id
 SET encntrid = request->encntr_id
 SET modulename = eks_common->cur_module_name
 SET temp_return = fillstring (2 ," " )
 SET temp_return = concat (char (10 ) ,char (13 ) )
 SET temp_linefeed = fillstring (1 ," " )
 SET temp_linefeed = char (10 )
 SET alertcount = size (reply->alerts ,5 )
 SET origalertcount = alertcount
 CALL echo (concat (build (alertcount ) ," alert(s) already exist in the reply structure" ) )
 SET link_indx = 0
 SET cnt_index = 0
 SET num_logic_temps = 0
 SET imiscsyn_ind = 0
 SET synonymid = 0.0
 SET ioptlink_ind = 0
 IF (validateparams (0 ) )
  IF ((linkmiscsize = 0 ) )
   SET endloop = 1
   SET spindex = 1
   IF ((newspindex != - (1 ) ) )
    SET newspindex = 0
   ENDIF
  ELSE
   SET endloop = linkmiscsize
   SET beksrepeatcountlink = 1
  ENDIF
  SET reply->progid = "EKSALERTHTMLA.EksalerthtmlaCtrl.1"
  SET reply->recipientid = reqinfo->updt_id
  SET reply->actiontemplateseq = curindex
  SELECT INTO "nl:"
   p.name_full_formatted ,
   p.person_id
   FROM (person p )
   WHERE (p.person_id = personid )
   DETAIL
    reply->personid = p.person_id ,
    reply->name_full_formatted = p.name_full_formatted
   WITH nocounter
  ;end select
  FOR (indx = 1 TO endloop )
   IF (linkmiscsize )
    SET streksrepeatcount = trim (tmprecord->qual[(indx + 1 ) ].misc_data ,3 )
    SET tmpeksstr = streksrepeatcount
    SET ipipe = findstring ("|" ,tmpeksstr )
    IF (ipipe )
     SET tmpeksstr = substring (1 ,(ipipe - 1 ) ,tmpeksstr )
    ENDIF
    CALL echo (concat ("tmpEksStr:  " ,tmpeksstr ) )
    IF (isnumeric (tmpeksstr ) )
     SET spindex = cnvtint (tmpeksstr )
    ELSE
     SET spindex = cnvtint (substring (1 ,(findstring (":" ,tmpeksstr ) - 1 ) ,tmpeksstr ) )
    ENDIF
    IF ((newspindex != - (1 ) ) )
     SET newspindex = spindex
    ENDIF
    CALL echo (concat ("spIndex set to " ,build (spindex ) ) )
   ENDIF
   IF ((((trim (opt_title ) = "" ) ) OR ((trim (cnvtlower (opt_title ) ) = "<undefined>" ) )) )
    SET title = "{NULL}"
   ELSEIF ((findstring ("@" ,trim (opt_title ) ) > 0 ) )
    SET ekssub->orig = trim (opt_title )
    SET ekssub->parse_ind = 0
    EXECUTE eks_t_subcalc
    SET subcalc->body = ekssub->mod
    SET i_temp_return = findstring (temp_return ,subcalc->body )
    IF ((i_temp_return > 0 ) )
     SET subcalc->body = replace (subcalc->body ,temp_return ,temp_linefeed ,0 )
    ENDIF
    SET title = subcalc->body
   ELSE
    SET title = trim (opt_title )
   ENDIF
   CALL echo (concat ("Title set to <" ,title ,">" ) )
   IF ((((trim (opt_freetext_param ) = "" ) ) OR ((trim (cnvtlower (opt_freetext_param ) ) =
   "<undefined>" ) )) )
    SET freetext = "{NULL}"
   ELSEIF ((findstring ("@" ,trim (opt_freetext_param ) ) > 0 ) )
    SET ekssub->orig = trim (opt_freetext_param )
    SET ekssub->parse_ind = 0
    EXECUTE eks_t_subcalc
    SET subcalc->body = ekssub->mod
    SET i_temp_return = findstring (temp_return ,subcalc->body )
    IF ((i_temp_return > 0 ) )
     SET subcalc->body = replace (subcalc->body ,temp_return ,temp_linefeed ,0 )
    ENDIF
    SET freetext = subcalc->body
   ELSE
    SET freetext = trim (opt_freetext_param )
   ENDIF
   CALL echo (concat ("freeText set to <" ,freetext ,">" ) )
   IF ((((trim (opt_ok_button_name ) = "" ) ) OR ((trim (cnvtlower (opt_ok_button_name ) ) =
   "<undefined>" ) )) )
    SET okbuttontitle = "{NULL}"
   ELSEIF ((findstring ("@" ,trim (opt_ok_button_name ) ) > 0 ) )
    SET ekssub->orig = trim (opt_ok_button_name )
    SET ekssub->parse_ind = 0
    EXECUTE eks_t_subcalc
    SET subcalc->body = ekssub->mod
    SET i_temp_return = findstring (temp_return ,subcalc->body )
    IF ((i_temp_return > 0 ) )
     SET subcalc->body = replace (subcalc->body ,temp_return ,temp_linefeed ,0 )
    ENDIF
    SET okbuttontitle = subcalc->body
   ELSE
    SET okbuttontitle = trim (opt_ok_button_name )
   ENDIF
   CALL echo (concat ("OKButtonTitle set to <" ,okbuttontitle ,">" ) )
   IF (gethtmlcontents (0 ) )
    SET alertcount +=1
    SET stat = alterlist (reply->alerts ,alertcount )
    SET reply->alerts[alertcount ].titlebar = title
    SET reply->alerts[alertcount ].okbutton = okbuttontitle
    IF (validate (server_url ) )
     IF ((cnvtupper (server_url ) != "<UNDEFINED>" ) )
      SET reply->alerts[alertcount ].serverurl = server_url
     ENDIF
    ENDIF
    SET reply->alerts[alertcount ].spindex = spindex
    SET reply->alerts[alertcount ].sp.spindex = newspindex
    SET itemp = findstring ("_" ,eks_common->cur_module_name )
    IF (itemp )
     SET reply->alerts[alertcount ].modulename = concat (substring (1 ,(itemp - 1 ) ,eks_common->
       cur_module_name ) ,"_EKM!" ,eks_common->cur_module_name )
    ELSE
     SET reply->alerts[alertcount ].modulename = concat ("EKM!" ,eks_common->cur_module_name )
    ENDIF
    SET stat = alterlist (reply->qual ,alertcount )
    SET reply->numreply = alertcount
    SET reply->qual[alertcount ].status = "S"
    SET reply->qual[alertcount ].progid = reply->progid
    SET reply->qual[alertcount ].spindex = spindex
    SET reply->qual[alertcount ].sp.spindex = newspindex
    SET reply->qual[alertcount ].actiontemplateseq = curindex
    SET reply->alerts[alertcount ].actiontemplateseq = curindex
    IF (opt_override_reasonlist->cnt )
     SET reply->alerts[alertcount ].overridecnt = opt_override_reasonlist->cnt
     SET stat = alterlist (reply->alerts[alertcount ].overrides ,reply->alerts[alertcount ].
      overridecnt )
     FOR (jndx = 1 TO reply->alerts[alertcount ].overridecnt )
      SET reply->alerts[alertcount ].overrides[jndx ].reasoncd = cnvtreal (opt_override_reasonlist->
       qual[jndx ].value )
      SET reply->alerts[alertcount ].overrides[jndx ].display = opt_override_reasonlist->qual[jndx ].
      display
     ENDFOR
     CALL echo (concat (build (reply->alerts[alertcount ].overridecnt ) ,
       " override(s) were set into reply" ) )
    ENDIF
    IF (opt_problemslist->cnt )
     CALL echorecord (opt_problemslist )
     DECLARE ibar = i4 WITH protect ,noconstant (0 )
     DECLARE isizeofpara = i4 WITH protect ,noconstant (0 )
     DECLARE strstring = vc
     DECLARE strorigstring = vc
     DECLARE isizeofstrorigstring = i4 WITH protect ,noconstant (0 )
     DECLARE isynorig = i4 WITH protect ,noconstant (0 )
     SET reply->alerts[alertcount ].addproblemcnt = opt_problemslist->cnt
     SET stat = alterlist (reply->alerts[alertcount ].addproblems ,reply->alerts[alertcount ].
      addproblemcnt )
     FOR (jndx = 1 TO reply->alerts[alertcount ].addproblemcnt )
      SET ibar = findstring ("|" ,trim (cnvtupper (opt_problemslist->qual[jndx ].value ) ) ,1 ,0 )
      SET isizeofpara = size (trim (opt_problemslist->qual[jndx ].value ) )
      SET strstring = substring (1 ,(ibar - 1 ) ,trim (opt_problemslist->qual[jndx ].value ) )
      IF (ibar )
       SET strorigstring = substring ((ibar + 1 ) ,(isizeofpara - ibar ) ,trim (opt_problemslist->
         qual[jndx ].value ) )
       SET isizeofstrorigstring = size (trim (strorigstring ) )
       SET isynorig = findstring ("ORIGNOMEN:" ,trim (cnvtupper (strorigstring ) ) ,1 ,0 )
      ENDIF
      IF (findstring ("NOMEN:" ,opt_problemslist->qual[jndx ].value ) )
       SET reply->alerts[alertcount ].addproblems[jndx ].nomenclatureid = cnvtreal (substring (1 ,(
         findstring ("NOMEN:" ,opt_problemslist->qual[jndx ].value ) - 1 ) ,opt_problemslist->qual[
         jndx ].value ) )
       IF (ibar )
        IF (isynorig )
         SET reply->alerts[alertcount ].addproblems[jndx ].originating_nomenclature_id = cnvtreal (
          substring (1 ,(isynorig - 1 ) ,trim (strorigstring ) ) )
        ELSE
         SET reply->alerts[alertcount ].addproblems[jndx ].originating_nomenclature_id = cnvtreal (
          strorigstring )
        ENDIF
       ENDIF
      ELSE
       IF (ibar )
        SET reply->alerts[alertcount ].addproblems[jndx ].nomenclatureid = cnvtreal (strstring )
        IF (isynorig )
         SET reply->alerts[alertcount ].addproblems[jndx ].originating_nomenclature_id = cnvtreal (
          substring (1 ,(isynorig - 1 ) ,trim (strorigstring ) ) )
        ELSE
         SET reply->alerts[alertcount ].addproblems[jndx ].originating_nomenclature_id = cnvtreal (
          strorigstring )
        ENDIF
       ELSE
        SET reply->alerts[alertcount ].addproblems[jndx ].nomenclatureid = cnvtreal (opt_problemslist
         ->qual[jndx ].value )
       ENDIF
      ENDIF
      SET reply->alerts[alertcount ].addproblems[jndx ].display = opt_problemslist->qual[jndx ].
      display
      CALL echo (concat ("added problem " ,build (jndx ) ,"  nomenclature_id of " ,build (reply->
         alerts[alertcount ].addproblems[jndx ].nomenclatureid ) ,"  '" ,build (reply->alerts[
         alertcount ].addproblems[jndx ].display ) ,"'  and originating_nomenclature_id: " ,build (
         reply->alerts[alertcount ].addproblems[jndx ].originating_nomenclature_id ) ) )
     ENDFOR
     CALL echo (concat (build (reply->alerts[alertcount ].addproblemcnt ) ,
       " problem(s) were set into reply" ) )
     IF (findstring ("@OPT_PROBLEMS" ,documentbody ) )
      CALL echo ("@OPT_PROBLEMS was found" )
      SET documentbody = replace (documentbody ,"@OPT_PROBLEMS" ,problemsrep ,0 )
     ENDIF
     IF (findstring ("@opt_problems" ,documentbody ) )
      CALL echo ("@opt_problems was found" )
      SET documentbody = replace (documentbody ,"@opt_problems" ,problemsrep ,0 )
     ENDIF
    ENDIF
    IF (textlen (probdefaultrep ) )
     IF ((probdefaultrep = "ENABLED" ) )
      SET reply->alerts[alertcount ].defaultfirstproblemind = 1
     ENDIF
     IF (findstring ("@OPT_DEFAULT_FIRST_PROBLEM" ,documentbody ) )
      CALL echo ("@OPT_DEFAULT_FIRST_PROBLEM was found" )
      SET documentbody = replace (documentbody ,"@OPT_DEFAULT_FIRST_PROBLEM" ,probdefaultrep ,0 )
     ENDIF
     IF (findstring ("@opt_default_first_problem" ,documentbody ) )
      CALL echo ("@opt_default_first_problem was found" )
      SET documentbody = replace (documentbody ,"@opt_default_first_problem" ,probdefaultrep ,0 )
     ENDIF
    ENDIF
    IF (opt_prob_confirmationlist->cnt )
     SET reply->alerts[alertcount ].confirmationcd = cnvtreal (opt_prob_confirmationlist->qual[1 ].
      value )
     IF (findstring ("@OPT_PROB_CONFIRMATION" ,documentbody ) )
      CALL echo ("@OPT_PROB_CONFIRMATION was found" )
      SET documentbody = replace (documentbody ,"@OPT_PROB_CONFIRMATION" ,probconfrep ,0 )
     ENDIF
     IF (findstring ("@opt_prob_confirmation" ,documentbody ) )
      CALL echo ("@opt_prob_confirmation was found" )
      SET documentbody = replace (documentbody ,"@opt_prob_confirmation" ,probconfrep ,0 )
     ENDIF
    ENDIF
    IF (opt_prob_classificationlist->cnt )
     SET reply->alerts[alertcount ].classificationcd = cnvtreal (opt_prob_classificationlist->qual[1
      ].value )
     IF (findstring ("@OPT_PROB_CLASSIFICATION" ,documentbody ) )
      CALL echo ("@OPT_PROB_CLASSIFICATION was found" )
      SET documentbody = replace (documentbody ,"@OPT_PROB_CLASSIFICATION" ,probclassrep ,0 )
     ENDIF
     IF (findstring ("@opt_prob_classification" ,documentbody ) )
      CALL echo ("@opt_prob_classification was found" )
      SET documentbody = replace (documentbody ,"@opt_prob_classification" ,probclassrep ,0 )
     ENDIF
    ENDIF
    SET reply->alerts[alertcount ].gtext = documentbody
   ELSE
    SET eksmsgval = concat ("HTML File " ,tmpfilename ," was not found" )
    CALL echo (eksmsgval )
   ENDIF
  ENDFOR
 ELSE
  SET retval = - (1 )
  GO TO endprogram
 ENDIF
 IF ((alertcount > origalertcount ) )
  SET retval = 100
  SET reply->status_data.status = "S"
  IF ((((substring (1 ,5 ,cnvtupper (tmpfilename ) ) = "<URL>" ) ) OR ((substring (1 ,7 ,cnvtupper (
    tmpfilename ) ) = "<OAUTH>" ) )) )
   SET eksmsgval = concat ("Navigate to " ,trim (tmpfilename ) ," in " ,build ((alertcount -
     origalertcount ) ) ," alert(s)" )
  ELSE
   SET eksmsgval = concat ("Show content of " ,trim (tmpfilename ) ," in " ,build ((alertcount -
     origalertcount ) ) ," alert(s)" )
  ENDIF
 ELSE
  SET retval = 0
 ENDIF
#endprogram
 SET eksmsgval = concat (eksmsgval ," (" ,trim (format (((curtime3 - tempstarttime ) / 100.0 ) ,
    "######.##" ) ,3 ) ,"s)" )
 CALL echo (eksmsgval )
 SET eksdata->tqual[tcurindex ].qual[curindex ].logging = eksmsgval
 SET eksdata->tqual[tcurindex ].qual[curindex ].person_id = personid
 SET eksdata->tqual[tcurindex ].qual[curindex ].encntr_id = encntrid
 CALL echo (concat (format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,"hh:mm:ss.cc;3;m" ) ,
   "  *********  End of Program EKS_T_ALERT_HTML_A" ,"  *********" ) ,1 ,0 )
 SUBROUTINE  gethtmlcontents (_null )
  IF ((findstring ("@" ,trim (html_file ) ) > 0 ) )
   SET ekssub->orig = trim (html_file )
   SET ekssub->parse_ind = 0
   EXECUTE eks_t_subcalc
   SET subcalc->body = ekssub->mod
   SET i_temp_return = findstring (temp_return ,subcalc->body )
   IF ((i_temp_return > 0 ) )
    SET subcalc->body = replace (subcalc->body ,temp_return ,temp_linefeed ,0 )
   ENDIF
   SET tmpfilename = subcalc->body
  ELSE
   SET tmpfilename = trim (html_file )
  ENDIF
  CALL echo (concat ("***  tmpFileName:  " ,tmpfilename ) )
  IF ((tname = "EKS_ALERT_ADVISOR_A" ) )
   IF (createxml (0 ) )
    RETURN (1 )
   ELSE
    RETURN (0 )
   ENDIF
  ELSEIF ((((substring (1 ,5 ,cnvtupper (tmpfilename ) ) = "<URL>" ) ) OR ((substring (1 ,7 ,
   cnvtupper (tmpfilename ) ) = "<OAUTH>" ) )) )
   SET documentbody = tmpfilename
   IF (textlen (freetext ) )
    SET documentbody = concat (documentbody ,"<DATA>" ,freetext )
   ENDIF
   CALL echo (concat ("URL:  " ,documentbody ) )
   RETURN (1 )
  ELSEIF ((findfile (tmpfilename ) > 0 ) )
   SET ekssub->orig = concat ("@FILE:[" ,tmpfilename ,"]" )
   SET ekssub->parse_ind = 0
   EXECUTE eks_t_subcalc
   SET subcalc->body = ekssub->mod
   SET i_temp_return = findstring (temp_return ,subcalc->body )
   IF ((i_temp_return > 0 ) )
    SET subcalc->body = replace (subcalc->body ,temp_return ,temp_linefeed ,0 )
   ENDIF
   SET documentbody = subcalc->body
   IF ((((documentbody = "" ) ) OR ((((findstring ("<HTML" ,cnvtupper (documentbody ) ) = 0 ) ) OR ((
   findstring ("</HTML" ,cnvtupper (documentbody ) ) = 0 ) )) )) )
    SET eksmsgval = concat ("HTML_FILE parameter " ,title ," does not appear to contain valid html."
     )
    RETURN (0 )
   ENDIF
   IF (findstring ("@OPT_OVERRIDE_REASON" ,documentbody ) )
    CALL echo ("@OPT_OVERRIDE_REASON was found" )
    SET documentbody = replace (documentbody ,"@OPT_OVERRIDE_REASON" ,overridereasonrep ,0 )
   ENDIF
   IF (findstring ("@opt_override_reason" ,documentbody ) )
    CALL echo ("@opt_override_reason was found" )
    SET documentbody = replace (documentbody ,"@opt_override_reason" ,overridereasonrep ,0 )
   ENDIF
   CALL echo (concat ("bOverrideDefault = " ,build (boverridedefault ) ) )
   IF (boverridedefault
   AND findstring ("@OPT_OVERRIDE_DEFAULT" ,documentbody ) )
    CALL echo ("@OPT_OVERRIDE_DEFAULT was found" )
    SET documentbody = replace (documentbody ,"@OPT_OVERRIDE_DEFAULT" ,opt_override_default ,0 )
   ENDIF
   IF (boverridedefault
   AND findstring ("@opt_override_default" ,documentbody ) )
    CALL echo ("@opt_override_default was found" )
    SET documentbody = replace (documentbody ,"@opt_override_default" ,opt_override_default ,0 )
   ENDIF
   IF (findstring ("@OPT_OK_BUTTON_NAME" ,documentbody ) )
    SET documentbody = replace (documentbody ,"OPT_OK_BUTTON_NAME" ,trim (okbuttontitle ) ,0 )
   ENDIF
   IF (findstring ("@opt_ok_button_name" ,documentbody ) )
    SET documentbody = replace (documentbody ,"@opt_ok_button_name" ,trim (okbuttontitle ) ,0 )
   ENDIF
   IF (findstring ("@OPT_FREETEXT_PARAM" ,documentbody ) )
    SET documentbody = replace (documentbody ,"@OPT_FREETEXT_PARAM" ,trim (freetext ) ,0 )
   ENDIF
   IF (findstring ("@opt_freetext_param" ,documentbody ) )
    SET documentbody = replace (documentbody ,"@opt_freetext_param" ,trim (freetext ) ,0 )
   ENDIF
   
   IF (findstring ("@reply_record_param" ,documentbody ) )
    SET documentbody = replace (documentbody ,"@reply_record_param" ,trim (cnvtrectojson(reply) ) ,0 )
   ENDIF
   
   RETURN (1 )
  ELSE
   SET eksmsgval = concat ("HTML_FILE parameter " ,tmpfilename ," was not found!" )
   RETURN (0 )
  ENDIF
 END ;Subroutine
 SUBROUTINE  validateparams (_null )
  IF (NOT (validate (html_file ) ) )
   SET eksmsgval = "HTML_FILE parameter does not exist"
   RETURN (0 )
  ELSEIF ((trim (cnvtlower (html_file ) ) IN ("" ,
  "<undefined>" ) ) )
   SET eksmsgval = "HTML_FILE must be specified"
   RETURN (0 )
  ENDIF
  IF (NOT (validate (opt_title ) ) )
   SET eksmsgval = "OPT_TITLE parameter does not exist"
   RETURN (0 )
  ENDIF
  IF (NOT (validate (opt_override_reason ) ) )
   SET eksmsgval = "OPT_OVERRIDE_REASON parameter does not exist"
   RETURN (0 )
  ENDIF
  CALL echo (concat ("OPT_OVERRIDE_REASON = " ,opt_override_reason ) )
  IF (NOT ((trim (cnvtlower (opt_override_reason ) ) IN ("" ,
  "<undefined>" ) ) ) )
   SET orig_param = opt_override_reason
   EXECUTE eks_t_parse_list WITH replace (reply ,opt_override_reasonlist )
   FREE SET orig_param
   IF (opt_override_reasonlist->cnt )
    FOR (jndx = 1 TO opt_override_reasonlist->cnt )
     IF ((jndx > 1 ) )
      SET overridereasonrep = concat (overridereasonrep ,"$$" )
     ENDIF
     SET overridereasonrep = concat (overridereasonrep ,opt_override_reasonlist->qual[jndx ].value ,
      "%%" ,opt_override_reasonlist->qual[jndx ].display )
    ENDFOR
    CALL echo (concat ("overrideReasonRep set to " ,overridereasonrep ) )
   ENDIF
  ENDIF
  IF (NOT (validate (opt_override_default ) ) )
   SET eksmsgval = "OPT_OVERRIDE_DEFAULT parameter does not exist"
   RETURN (0 )
  ENDIF
  SET boverridedefault = 0
  CALL echo (concat ("OPT_OVERRIDE_DEFAULT set to " ,opt_override_default ) )
  IF (NOT ((trim (cnvtlower (opt_override_default ) ) IN ("" ,
  "<undefined>" ) ) )
  AND (opt_override_reasonlist->cnt = 0 ) )
   SET eksmsgval = "OPT_OVERRIDE_DEFAULT cannot be specified with OPT_OVERRIDE_REASON being empty"
   RETURN (0 )
  ELSEIF ((cnvtupper (opt_override_default ) IN ("FIRST" ,
  "NONE" ,
  "FREETEXT" ) ) )
   SET boverridedefault = 1
   CALL echo (concat ("Default override set to " ,opt_override_default ) )
  ENDIF
  IF (NOT (validate (opt_problems ) ) )
   SET eksmsgval = "OPT_PROBLEMS parameter does not exist"
   RETURN (0 )
  ENDIF
  IF (NOT ((trim (cnvtlower (opt_problems ) ) IN ("" ,
  "<undefined>" ) ) ) )
   SET orig_param = opt_problems
   EXECUTE eks_t_parse_list WITH replace (reply ,opt_problemslist )
   FREE SET orig_param
   IF (opt_problemslist->cnt )
    FOR (jndx = 1 TO opt_problemslist->cnt )
     IF ((jndx > 1 ) )
      SET problemsrep = concat (problemsrep ,"$$" )
     ENDIF
     SET problemsrep = concat (problemsrep ,opt_problemslist->qual[jndx ].value ,"%%" ,
      opt_problemslist->qual[jndx ].display )
    ENDFOR
    CALL echo (concat ("problemsRep set to " ,problemsrep ) )
   ENDIF
  ENDIF
  IF (NOT (validate (opt_default_first_problem ) ) )
   SET eksmsgval = "OPT_DEFAULT_FIRST_PROBLEM parameter does not exist"
   RETURN (0 )
  ENDIF
  IF ((trim (cnvtupper (opt_default_first_problem ) ) IN ("ENABLED" ,
  "DISABLED" ) ) )
   SET probdefaultrep = cnvtupper (opt_default_first_problem )
  ENDIF
  IF (NOT (validate (opt_prob_confirmation ) ) )
   SET eksmsgval = "OPT_PROB_CONFIRMATION parameter does not exist"
   RETURN (0 )
  ENDIF
  IF (NOT ((trim (cnvtlower (opt_prob_confirmation ) ) IN ("" ,
  "<undefined>" ) ) ) )
   SET orig_param = opt_prob_confirmation
   EXECUTE eks_t_parse_list WITH replace (reply ,opt_prob_confirmationlist )
   FREE SET orig_param
   IF (opt_prob_confirmationlist->cnt
   AND (opt_problemslist->cnt = 0 ) )
    SET eksmsgval = "OPT_PROB_CONFIRMATION cannot be specified with OPT_PROBLEMS being empty"
    RETURN (0 )
   ENDIF
   IF (opt_prob_confirmationlist->cnt )
    SET probconfrep = concat (opt_prob_confirmationlist->qual[1 ].value ,"%%" ,
     opt_prob_confirmationlist->qual[1 ].display )
   ENDIF
  ENDIF
  IF (NOT (validate (opt_prob_classification ) ) )
   SET eksmsgval = "OPT_PROB_CLASSIFICATION parameter does not exist"
   RETURN (0 )
  ENDIF
  IF (NOT ((trim (cnvtlower (opt_prob_classification ) ) IN ("" ,
  "<undefined>" ) ) ) )
   SET orig_param = opt_prob_classification
   EXECUTE eks_t_parse_list WITH replace (reply ,opt_prob_classificationlist )
   FREE SET orig_param
   IF (opt_prob_classificationlist->cnt
   AND (opt_problemslist->cnt = 0 ) )
    SET eksmsgval = "OPT_PROB_CLASSIFICATION cannot be specified with OPT_PROBLEMS being empty"
    RETURN (0 )
   ENDIF
   IF (opt_prob_classificationlist->cnt )
    SET probclassrep = concat (opt_prob_classificationlist->qual[1 ].value ,"%%" ,
     opt_prob_classificationlist->qual[1 ].display )
   ENDIF
  ENDIF
  IF (NOT (validate (opt_freetext_param ) ) )
   SET eksmsgval = "OPT_FREETEXT_PARAM parameter does not exist"
   RETURN (0 )
  ENDIF
  IF ((eks_common->event_name IN ("*OPENCHART" ,
  "*CLOSECHART" ) ) )
   SET newspindex = - (1 )
  ENDIF
  IF (NOT (validate (opt_link ) ) )
   SET eksmsgval = "OPT_LINK parameter does not exist"
   RETURN (0 )
  ELSEIF (isnumeric (opt_link ) )
   SET link_indx = cnvtint (opt_link )
   SET inttemplateoptlink = link_indx
   SET num_logic_temps = size (eksdata->tqual[tinx ].qual ,5 )
   IF ((((link_indx <= 0 ) ) OR ((link_indx > num_logic_temps ) )) )
    SET eksmsgval = concat ("OPT_LINK value of " ,trim (opt_link ) ," is invalid." )
    RETURN (0 )
   ELSE
    SET linkmiscsize = (size (eksdata->tqual[tinx ].qual[link_indx ].data ,5 ) - 1 )
    IF ((linkmiscsize < 1 ) )
     SET eksmsgval = concat ("Link Template " ,build (link_indx ) ," does not contain valid data" )
     RETURN (0 )
    ELSEIF (NOT ((trim (cnvtupper (eksdata->tqual[tinx ].qual[link_indx ].data[1 ].misc ) ,3 ) IN (
    "<SPINDEX>" ,
    "<ORDER_ID>" ) ) ) )
     SET eksmsgval = concat ("Link Template " ,build (link_indx ) ," does not contain valid data" )
     RETURN (0 )
    ENDIF
    CALL echo (concat ("There were " ,build (linkmiscsize ) ," SPIndex values in Logic Template " ,
      build (link_indx ) ) )
    CALL echo ("putting data into tmpRecord" )
    SET cntspindex = size (eksdata->tqual[tinx ].qual[link_indx ].data ,5 )
    SET tmprecord->cnt = cntspindex
    SET stat = alterlist (tmprecord->qual ,tmprecord->cnt )
    SET cntorderlist = size (request->orderlist ,5 )
    IF ((trim (cnvtupper (eksdata->tqual[tinx ].qual[link_indx ].data[1 ].misc ) ,3 ) = "<ORDER_ID>"
    ) )
     CALL echo ("translate <ORDER_ID> to <SPINDEX> at tmpRecord" )
     FOR (isp = 2 TO cntspindex )
      SET tmprecord->qual[1 ].misc_data = "<SPINDEX>"
      SET isyncolon = findstring (":" ,eksdata->tqual[tinx ].qual[link_indx ].data[isp ].misc )
      IF ((isyncolon = 0 ) )
       FOR (jsp = 1 TO cntorderlist )
        IF ((cnvtreal (eksdata->tqual[tinx ].qual[link_indx ].data[isp ].misc ) = request->orderlist[
        jsp ].orderid ) )
         SET tmprecord->qual[isp ].misc_data = cnvtstring (jsp )
         SET jsp = (cntorderlist + 1 )
         SET cntqual +=1
        ENDIF
       ENDFOR
      ELSE
       FOR (jsp = 1 TO cntorderlist )
        IF ((cnvtreal (substring (1 ,(isyncolon - 1 ) ,trim (eksdata->tqual[tinx ].qual[link_indx ].
           data[isp ].misc ,3 ) ) ) = request->orderlist[jsp ].orderid ) )
         SET isizeofstring = size (trim (eksdata->tqual[tinx ].qual[link_indx ].data[isp ].misc ,3 )
          ,1 )
         SET tmprecord->qual[isp ].misc_data = concat (trim (cnvtstring (jsp ) ) ," : " ,substring ((
           isyncolon + 1 ) ,(isizeofstring - isyncolon ) ,trim (eksdata->tqual[tinx ].qual[link_indx
            ].data[isp ].misc ,3 ) ) )
         SET jsp = (cntorderlist + 1 )
         SET cntqual +=1
        ENDIF
       ENDFOR
      ENDIF
     ENDFOR
     CALL echo (concat ("cntQual: " ,build (cntqual ) ,"  cntSPIndex: " ,build (cntspindex ) ) )
     IF ((cntqual != (cntspindex - 1 ) ) )
      SET eksmsgval = "not all the linked order_id(s) could be found in incoming request"
      SET retval = 0
      RETURN (0 )
     ENDIF
    ELSE
     FOR (isp = 1 TO cntspindex )
      SET tmprecord->qual[isp ].misc_data = eksdata->tqual[tinx ].qual[link_indx ].data[isp ].misc
     ENDFOR
    ENDIF
   ENDIF
  ELSE
   SET eksmsgval = "No link value was specified"
   SET linkmiscsize = 0
   IF ((newspindex != - (1 ) ) )
    SET newspindex = 0
   ENDIF
  ENDIF
  RETURN (1 )
 END ;Subroutine
 SUBROUTINE  createxml (_param )
  DECLARE imsg = i4 WITH protect
  SET documentbody = concat ('<?xml version="1.0" encoding="UTF-8"?><discernadvisor><uri>' ,
   tmpfilename ,"</uri><parameters>" )
  SET documentbody = concat (documentbody ,"<opt_title><![CDATA[" ,title ,"]]></opt_title>" )
  IF (textlen (overridereasonrep ) )
   SET documentbody = concat (documentbody ,"<opt_override_reason><![CDATA[" ,overridereasonrep ,
    "]]></opt_override_reason>" )
  ENDIF
  IF (boverridedefault )
   SET documentbody = concat (documentbody ,"<opt_override_default><![CDATA[" ,opt_override_default ,
    "]]></opt_override_default>" )
  ENDIF
  IF (textlen (problemsrep ) )
   SET documentbody = concat (documentbody ,"<opt_problems><![CDATA[" ,problemsrep ,
    "]]></opt_problems>" )
  ENDIF
  IF (textlen (probdefaultrep ) )
   SET documentbody = concat (documentbody ,"<opt_default_first_problem><![CDATA[" ,probdefaultrep ,
    "]]></opt_default_first_problem>" )
  ENDIF
  IF (textlen (probconfrep ) )
   SET documentbody = concat (documentbody ,"<opt_prob_confirmation><![CDATA[" ,probconfrep ,
    "]]></opt_prob_confirmation>" )
  ENDIF
  IF (textlen (probclassrep ) )
   SET documentbody = concat (documentbody ,"<opt_prob_classification><![CDATA[" ,probclassrep ,
    "]]></opt_prob_classification>" )
  ENDIF
  IF (textlen (freetext ) )
   SET documentbody = concat (documentbody ,"<opt_freetext_param><![CDATA[" ,freetext ,
    "]]></opt_freetext_param>" )
  ENDIF
  IF (textlen (okbuttontitle ) )
   SET documentbody = concat (documentbody ,"<opt_ok_button_name><![CDATA[" ,okbuttontitle ,
    "]]></opt_ok_button_name>" )
  ENDIF
  IF (eksdata->bldmsg_cnt )
   SET documentbody = concat (documentbody ,"<messages>" )
   FOR (imsg = 1 TO eksdata->bldmsg_cnt )
    SET documentbody = concat (documentbody ,"<message><name>" ,eksdata->bldmsg[imsg ].name ,
     "</name><value><![CDATA[" ,eksdata->bldmsg[imsg ].text ,"]]></value></message>" )
   ENDFOR
   SET documentbody = concat (documentbody ,"</messages>" )
  ENDIF
  SET documentbody = concat (documentbody ,"</parameters></discernadvisor>" )
  CALL echo (documentbody )
  RETURN (1 )
 END ;Subroutine
END GO
