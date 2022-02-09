DROP PROGRAM cov_eks_t_db_ref_help :dba GO
CREATE PROGRAM cov_eks_t_db_ref_help :dba
 PROMPT
  "call "
 SET strcallmethod =  $1
 DECLARE getlist ((npanelno = i2 ) ,(strorderdetail = vc ) ) = null
 DECLARE getcontinuingordermethodflag (_var1 ) = null
 DECLARE gettemplateorderflag (_var1 ) = null
 RECORD tmprec (
   1 cnt = i2
   1 qual [* ]
     2 order_entry_field = vc
     2 hidden_par = vc
 )
 SET parameterarray[10 ] = fillstring (1025 ," " )
 SET parametercount = 0
 DECLARE berror = i1 WITH noconstant (0 )
 DECLARE strerror = c132 WITH noconstant ("" )
 DECLARE strtext = c150 WITH noconstant ("" )
 DECLARE accessionid = f8
 DECLARE orderid = f8
 DECLARE encntrid = f8
 DECLARE personid = f8
 DECLARE bresult = i1 WITH noconstant (0 )
 RECORD treply (
   1 fieldname = vc
   1 cnt = i4
   1 qual [* ]
     2 display = vc
     2 hidden = vc
 )
 DECLARE sqlcalls[50 ] = c256 WITH public
 IF ((findstring ("^" , $1 ) > 0 ) )
  CALL getparameters ( $1 )
 ELSE
  SET parameterarray[1 ] =  $1
 ENDIF
 CASE (parameterarray[1 ] )
  OF "HELPORDALPHA" :
   CALL getalphaselect (parameterarray[2 ] )
  OF "HELPORDERS" :
   CALL getorders (parameterarray[2 ] ,"" )
  OF "HELPCATALOGTYPE" :
   CALL getcodeset (6000 ,"" ,"" ,"" ,parameterarray[2 ] )
  OF "HELPSTATUS" :
   CALL getcodeset_filter ("CDF6004" ,"" ,"" ,"*ANY" ,parameterarray[2 ] )
  OF "HELPDETAILSSEL" :
   CALL getordselect (1 )
  OF "HELPDETAILSSEL_PROVIDE" :
   CALL getordselect_provide (1 )
  OF "HELPDETAILSSELDB" :
   CALL getordselect (2 )
  OF "HELPDETAILSSELDB_PROVIDE" :
   CALL getordselect_provide (2 )
  OF "HELPDETAILS" :
   CALL getorddetail (cnvtint (parameterarray[2 ] ) ,parameterarray[3 ] ,"" )
  OF "HELPDETAILS_PROVIDE" :
   CALL getorddetail_provide (cnvtint (parameterarray[2 ] ) ,parameterarray[3 ] ,"" )
  OF "HELPDETAILS_NOACTION" :
   CALL getorddetail_provide (cnvtint (parameterarray[2 ] ) ,parameterarray[3 ] ,"NOACTION" )
  OF "HELPCODESET" :
   CALL getcodeset (parameterarray[2 ] ,parameterarray[4 ] ,parameterarray[5 ] ,parameterarray[6 ] ,
    parameterarray[7 ] )
  OF "HELPQUALIFIERS" :
   CALL getqualifiers (parameterarray[2 ] )
  OF "HELPQUALIFIERS_PROVIDE" :
   CALL getqualifiers_provide (parameterarray[2 ] )
  OF "HELPORDDETLIST1" :
   CALL getorderdetaillist (1 ,parameterarray[2 ] )
  OF "HELPORDDETLIST2" :
   CALL getorderdetaillist (2 ,parameterarray[2 ] )
  OF "HELPORDDETLIST3" :
   CALL getorderdetaillist (2.5 ,parameterarray[2 ] )
  OF "HELPORDDETLIST4" :
   CALL getorderdetaillist (4 ,parameterarray[2 ] )
  OF "HELPSUBJECT" :
   CALL helpsubject (0 )
  OF "HELPMSGTYPE" :
   CALL helpmsgtype (0 )
   OF "HELPREMINDERTYPE" :
   CALL helpremindertype (0 )
  OF "HELPRECIPIENT" :
   CALL helprecipient (cnvtint (parameterarray[2 ] ) ,parameterarray[3 ] )
  OF "HELPPRIORITY" :
   IF ((parametercount > 1 ) )
    CALL helppriority (cnvtint (parameterarray[2 ] ) )
   ELSE
    CALL helppriority (0 )
   ENDIF
  OF "HELPORDMETHOD" :
   CALL getordmethod (parameterarray[2 ] )
  OF "HELPCONTINUETYPE" :
   CALL getcontinuingordermethodflag (0 )
  OF "HELPPARENTCHILD" :
   CALL gettemplateorderflag (0 )
  OF "HELPNEWORDMETHOD" :
   CALL getnewordmethod (0 )
  OF "REASONFOREXAM" :
   CALL buildoefielddetails_provide (- (1 ) ,"OE" )
  ELSE
   CALL helperror (concat ("Unknown help request function :" ,parameterarray[1 ] ) )
 ENDCASE
 IF ((reply->cnt = 0 ) )
  CALL helperror ("No data found for help request" )
 ENDIF
 SUBROUTINE  (getorders (strorderfilter =vc ,strextra =vc ) =null )
  DECLARE catvoc = c30
  DECLARE catcd = f8
  IF ((findstring ("\2ndMCD" ,strorderfilter ) > 0 ) )
   CALL getmltmcombdrug ("\3rdMCD" )
  ELSE
   RECORD args (
     1 count = i2
     1 items [25 ]
       2 value = c1024
   )
   CALL parsearguments (strorderfilter ,"|" ,args )
   SET berror = 0
   IF ((substring (1 ,1 ,trim (args->items[2 ].value ) ) BETWEEN "0" AND "9" ) )
    SET catcd = cnvtreal (substring (1 ,size (trim (args->items[2 ].value ) ) ,trim (args->items[2 ].
       value ) ) )
    IF ((catcd > 0 ) )
     SELECT INTO "nl:"
      FROM (code_value cv )
      WHERE (cv.code_set = 6000 )
      AND (cv.code_value = catcd )
      WITH nocounter
     ;end select
     IF ((curqual = 0 ) )
      CALL helperror ("Cannot find valid catalog type code from code set 6000, please check again" )
      SET berror = 1
     ENDIF
    ENDIF
   ELSEIF ((trim (args->items[2 ].value ) = "OTHER" ) )
    SET catcd = 0
   ENDIF
   IF ((berror = 0 ) )
    IF ((trim (cnvtupper (args->items[1 ].value ) ) != "OTHER" ) )
     SET alphafilter = concat (trim (cnvtupper (args->items[1 ].value ) ) ,"*" )
    ELSE
     SET alphafilter = "#"
    ENDIF
    IF ((trim (args->items[3 ].value ) = "that was ordered as" ) )
     SET catvoc = "SYNONYM"
    ELSEIF ((trim (args->items[3 ].value ) = "whose primary mnemonic is" ) )
     SET catvoc = "PRIMARY"
    ELSEIF ((trim (args->items[3 ].value ) = "with catalog code" ) )
     SET catvoc = "CATALOGCODE"
    ELSE
     SET catvoc = "ANY"
    ENDIF
    IF ((catcd >= 0 ) )
     CALL getorderlist (catcd ,alphafilter ,catvoc ,strextra )
    ELSE
     CALL helperror (concat ("Invalid catalog type of " ,substring (2 ,(size (args->items[1 ].value
         ) - 1 ) ,trim (args->items[1 ].value ) ) ) )
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getorderlist (ncatalogtypecd =f8 ,stralphafilter =vc ,strvocab =vc ,strextraparam =vc
  ) =null )
  DECLARE strextra = vc
  DECLARE intcontordermethodflag = i2 WITH protect ,noconstant (0 )
  IF ((args->count = 4 ) )
   IF ((isnumeric (args->items[4 ].value ) > 0 ) )
    SET intcontordermethodflag = cnvtint (args->items[4 ].value )
   ELSE
    SET intcontordermethodflag = - (1 )
   ENDIF
  ELSE
   SET intcontordermethodflag = - (1 )
  ENDIF
  DECLARE intsyn = i2 WITH noconstant (0 )
  SET intsyn = findstring ("\" ,trim (par1 ) ,1 )
  DECLARE sqlstring = vc WITH protect
  IF ((strextraparam > " " ) )
   SET strextra = concat ("|" ,strextraparam )
  ELSE
   SET strextra = " "
  ENDIF
  IF ((trim (strvocab ) = "SYNONYM" ) )
   IF ((ncatalogtypecd > 0 ) )
    SET sqlstring = " ocs.catalog_type_cd = nCatalogTypeCD and "
   ENDIF
   IF ((trim (stralphafilter ) != "#" ) )
    SET sqlstring = concat (sqlstring ," ocs.mnemonic_key_cap = PatString(strAlphaFilter) " )
   ELSE
    SET sqlstring = concat (sqlstring ,
     " (SubString(1,1,ocs.mnemonic_key_cap) not between 'A' and 'Z') and " )
    SET sqlstring = concat (sqlstring ,
     " (SubString(1,1,ocs.mnemonic_key_cap) not between '0' and '9') " )
   ENDIF
   DECLARE tmpsqlstring = vc WITH protect
   SET tmpsqlstring = " oc.catalog_cd = ocs.catalog_cd "
   IF ((intcontordermethodflag >= 0 ) )
    SET tmpsqlstring = concat (trim (tmpsqlstring ) ,
     " and oc.cont_order_method_flag = intContOrderMethodFlag " )
   ENDIF
   CALL echo (concat ("sqlstring: " ,build (sqlstring ) ) )
   SELECT INTO "NL:"
    order_synonym = ocs.mnemonic ,
    _hidden_par = concat (trim (cnvtstring (ocs.synonym_id ,25 ,1 ) ) ,strextra ) ,
    synonym_type = uar_get_code_display (ocs.mnemonic_type_cd ) ,
    primary_mnemonic = uar_get_code_display (ocs.catalog_cd ) ,
    catalog_type = uar_get_code_display (ocs.catalog_type_cd )
    FROM (order_catalog_synonym ocs ),
     (order_catalog oc )
    PLAN (ocs
     WHERE parser (sqlstring ) )
     JOIN (oc
     WHERE parser (tmpsqlstring ) )
    ORDER BY cnvtupper (ocs.mnemonic ) ,
     synonym_type ,
     ocs.item_id
    HEAD REPORT
     stat = 0 ,
     reply->cnt = 0 ,
     reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
     reply->fieldsize = size (reply->fieldname )
    DETAIL
     reply->cnt +=1 ,
     IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
     ENDIF
     ,
     IF (ocs.active_ind ) reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
     ELSE reply->qual[reply->cnt ].result = concat ("*" ,reportinfo (2 ) ,"^" )
     ENDIF
    FOOT REPORT
     stat = alterlist (reply->qual ,reply->cnt )
    WITH maxrow = 1 ,reporthelp ,check
   ;end select
   IF ((reply->cnt = 0 ) )
    CALL helperror ("No Synonyms found" )
   ENDIF
  ELSEIF ((trim (strvocab ) = "PRIMARY" ) )
   IF ((ncatalogtypecd > 0 ) )
    SET sqlstring = " oc.catalog_type_cd = nCatalogTypeCD and "
   ENDIF
   IF ((trim (stralphafilter ) != "#" ) )
    SET sqlstring = concat (sqlstring ,
     " CnvtUpper(SubString(1,1,oc.primary_mnemonic)) = PatString(strAlphaFilter) " )
   ELSE
    SET sqlstring = concat (sqlstring ,
     " (CnvtUpper(SubString(1,1,oc.primary_mnemonic)) not between 'A' and 'Z') and " )
    SET sqlstring = concat (sqlstring ,
     " (CnvtUpper(SubString(1,1,oc.primary_mnemonic)) not between '0' and '9') " )
   ENDIF
   IF ((intcontordermethodflag >= 0 ) )
    SET sqlstring = concat (sqlstring ," and oc.cont_order_method_flag = intContOrderMethodFlag " )
   ENDIF
   CALL echo (concat ("sqlstring: " ,build (sqlstring ) ) )
   SELECT INTO "NL:"
    primary_mnemonic = oc.primary_mnemonic ,
    _hidden_par =
    IF ((size (trim (oc.concept_cki ) ) > 0 ) ) substring (1 ,400 ,concat ("CCK200:" ,trim (oc
        .concept_cki ) ,strextra ) )
    ELSEIF ((size (trim (cv.cki ,3 ) ) = 0 ) ) substring (1 ,400 ,concat (trim (cnvtstring (cv
         .code_value ,25 ,1 ) ) ,strextra ) )
    ELSE substring (1 ,400 ,concat (trim (cv.cki ) ,strextra ) )
    ENDIF
    FROM (order_catalog oc ),
     (code_value cv )
    PLAN (oc
     WHERE parser (sqlstring ) )
     JOIN (cv
     WHERE (cv.code_value = oc.catalog_cd )
     AND (cv.active_ind = 1 ) )
    ORDER BY cnvtupper (oc.primary_mnemonic )
    HEAD REPORT
     stat = 0 ,
     reply->cnt = 0 ,
     reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
     reply->fieldsize = size (reply->fieldname )
    DETAIL
     reply->cnt +=1 ,
     IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
     ENDIF
     ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
    FOOT REPORT
     stat = alterlist (reply->qual ,reply->cnt )
    WITH maxrow = 1 ,reporthelp ,check
   ;end select
  ELSEIF ((trim (strvocab ) = "CATALOGCODE" ) )
   IF ((ncatalogtypecd > 0 ) )
    SET sqlstring = " oc.catalog_type_cd = nCatalogTypeCD and "
   ENDIF
   IF ((trim (stralphafilter ) != "#" ) )
    SET sqlstring = concat (sqlstring ,
     " CnvtUpper(SubString(1,1,oc.primary_mnemonic)) = PatString(strAlphaFilter) " )
   ELSE
    SET sqlstring = concat (sqlstring ,
     " (CnvtUpper(SubString(1,1,oc.primary_mnemonic)) not between 'A' and 'Z') and " )
    SET sqlstring = concat (sqlstring ,
     " (CnvtUpper(SubString(1,1,oc.primary_mnemonic)) not between '0' and '9') " )
   ENDIF
   SELECT INTO "NL:"
    primary_mnemonic = oc.primary_mnemonic ,
    _hidden_par = oc.catalog_cd
    FROM (order_catalog oc ),
     (code_value cv )
    PLAN (oc
     WHERE parser (sqlstring ) )
     JOIN (cv
     WHERE (cv.code_value = oc.catalog_cd )
     AND (cv.active_ind = 1 )
     AND (cv.begin_effective_dt_tm <= cnvtdatetime (sysdate ) )
     AND (cv.end_effective_dt_tm >= cnvtdatetime (sysdate ) ) )
    ORDER BY cnvtupper (oc.primary_mnemonic )
    HEAD REPORT
     stat = 0 ,
     reply->cnt = 0 ,
     reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
     reply->fieldsize = size (reply->fieldname )
    DETAIL
     reply->cnt +=1 ,
     IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
     ENDIF
     ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
    FOOT REPORT
     stat = alterlist (reply->qual ,reply->cnt )
    WITH maxrow = 1 ,reporthelp ,check
   ;end select
  ELSEIF ((intsyn > 0 ) )
   CALL getdrugcategoryname (concat ("\3rd" ,par1 ) )
  ELSE
   CALL initreply ("ORDER_CATALOG" ,"" )
   CALL addreply ("ignoring order list" ,"*ANY ORDER" )
   CALL closereply (false )
  ENDIF
  IF ((reply->cnt = 0 ) )
   CALL helperror ("No order catalog entries found" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getqualifiers_provide (strparam )
  DECLARE ndettype = i2 WITH protect
  SET ndettype = 0
  IF ((findstring ("+" ,strparam ,1 ) > 0 ) )
   SET strparam = substring ((findstring ("+" ,strparam ,1 ) + 1 ) ,(size (strparam ,1 ) -
    findstring ("+" ,strparam ,1 ) ) ,strparam )
   SET ndettype = 1
   CALL buildqualifiers_provide (substring (1 ,1 ,strparam ) ,ndettype )
  ELSE
   IF ((substring (1 ,1 ,strparam ) IN ("X" ,
   "P" ,
   "U" ) ) )
    RECORD args (
      1 count = i2
      1 items [25 ]
        2 value = c1024
    )
    CALL parsearguments (strparam ,"|" ,args )
    IF ((cnvtupper (trim (args->items[1 ].value ) ) = "UI" ) )
     CALL buildqualifiers_provide (substring (2 ,1 ,args->items[1 ].value ) ,ndettype )
    ELSE
     SET ndettype = 1
     CALL buildqualifiers_provide (substring (1 ,1 ,args->items[args->count ].value ) ,ndettype )
    ENDIF
   ELSE
    CALL buildqualifiers_provide (substring (1 ,1 ,strparam ) ,ndettype )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  buildqualifiers_provide (cdatatype ,ndetailtype )
  IF ((cdatatype IN ("I" ,
  "B" ,
  "Q" ,
  "S" ,
  "X" ,
  "N" ) ) )
   CALL initreply ("QUALIFICATION" ,"DESCRIPTION" )
   CASE (cdatatype )
    OF "I" :
     CALL addreply ("is listed in" ,"in" )
     CALL addreply ("is not listed in" ,"not in" )
     IF ((ndetailtype = 1 ) )
      CALL addreply ("is defined (exists) but not listed in" ,"def not in" )
      CALL addreply ("is not defined (does not exist) or not listed in" ,"not def not in" )
     ENDIF
    OF "B" :
     CALL addreply ("is listed in" ,"in" )
     CALL addreply ("is not listed in" ,"not in" )
     IF ((ndetailtype = 1 ) )
      CALL addreply ("is defined (exists) but not listed in" ,"def not in" )
      CALL addreply ("is not defined (does not exist) or not listed in" ,"not def not in" )
     ENDIF
    OF "N" :
     CALL addreply ("is equal to" ,"=" )
     CALL addreply ("is not equal to" ,"!=" )
     CALL addreply ("is less than" ,"<" )
     CALL addreply ("is less than or equal to" ,"<=" )
     CALL addreply ("is greater than" ,">" )
     CALL addreply ("is greater than or equal to" ,">=" )
     CALL addreply ("is between" ,"between" )
     CALL addreply ("is outside" ,"outside" )
    OF "Q" :
     CALL addreply ("is equal to" ,"=" )
     CALL addreply ("is not equal to" ,"!=" )
     CALL addreply ("is less than" ,"<" )
     CALL addreply ("is less than or equal to" ,"<=" )
     CALL addreply ("is greater than" ,">" )
     CALL addreply ("is greater than or equal to" ,">=" )
     CALL addreply ("is between" ,"between" )
     CALL addreply ("is outside" ,"outside" )
    OF "S" :
     CALL addreply ("is listed in" ,"in" )
     CALL addreply ("is not listed in" ,"not in" )
     IF ((ndetailtype = 1 ) )
      CALL addreply ("is defined (exists) but not listed in" ,"def not in" )
      CALL addreply ("is not defined (does not exist) or not listed in" ,"not def not in" )
     ENDIF
   ENDCASE
   IF ((ndetailtype = 1 ) )
    CALL addreply ("is defined (exists)" ,"def" )
    CALL addreply ("is not defined (does not exist)" ,"not def" )
   ENDIF
   CALL closereply (false )
  ELSE
   CALL helperror (concat ("Invalid data type of " ,cdatatype ,parameterarray[2 ] ) )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getqualifiers (strparam =vc ) =null )
  DECLARE ndettype = i2 WITH protect
  SET ndettype = 0
  IF ((findstring ("+" ,strparam ,1 ) > 0 ) )
   SET strparam = substring ((findstring ("+" ,strparam ,1 ) + 1 ) ,(size (strparam ,1 ) -
    findstring ("+" ,strparam ,1 ) ) ,strparam )
   SET ndettype = 1
   CALL buildqualifiers (substring (1 ,1 ,strparam ) ,ndettype )
  ELSE
   IF ((substring (1 ,1 ,strparam ) IN ("X" ,
   "P" ) ) )
    RECORD args (
      1 count = i2
      1 items [25 ]
        2 value = c1024
    )
    CALL parsearguments (strparam ,"|" ,args )
    SET ndettype = 1
    CALL buildqualifiers (substring (1 ,1 ,args->items[args->count ].value ) ,ndettype )
   ELSE
    CALL buildqualifiers (substring (1 ,1 ,strparam ) ,ndettype )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  buildqualifiers (cdatatype ,ndetailtype )
  IF ((cdatatype IN ("I" ,
  "B" ,
  "Q" ,
  "S" ,
  "X" ,
  "N" ) ) )
   CALL initreply ("QUALIFICATION" ,"DESCRIPTION" )
   CASE (cdatatype )
    OF "I" :
     CALL addreply ("is listed in" ,"in" )
     CALL addreply ("is not listed in" ,"not in" )
     IF ((ndetailtype = 1 ) )
      CALL addreply ("is defined (exists) but not listed in" ,"def not in" )
      CALL addreply ("is not defined (does not exist) or not listed in" ,"not def not in" )
     ENDIF
    OF "B" :
     CALL addreply ("is listed in" ,"in" )
     CALL addreply ("is not listed in" ,"not in" )
     IF ((ndetailtype = 1 ) )
      CALL addreply ("is defined (exists) but not listed in" ,"def not in" )
      CALL addreply ("is not defined (does not exist) or not listed in" ,"not def not in" )
     ENDIF
    OF "N" :
     CALL addreply ("is equal to" ,"=" )
     CALL addreply ("is not equal to" ,"!=" )
     CALL addreply ("is less than" ,"<" )
     CALL addreply ("is less than or equal to" ,"<=" )
     CALL addreply ("is greater than" ,">" )
     CALL addreply ("is greater than or equal to" ,">=" )
    OF "Q" :
     CALL addreply ("is equal to" ,"=" )
     CALL addreply ("is not equal to" ,"!=" )
     CALL addreply ("is less than" ,"<" )
     CALL addreply ("is less than or equal to" ,"<=" )
     CALL addreply ("is greater than" ,">" )
     CALL addreply ("is greater than or equal to" ,">=" )
    OF "S" :
     CALL addreply ("is listed in" ,"in" )
     CALL addreply ("is not listed in" ,"not in" )
     IF ((ndetailtype = 1 ) )
      CALL addreply ("is defined (exists) but is not listed in" ,"def not in" )
      CALL addreply ("is not defined (does not exist) or is not listed in" ,"not def not in" )
     ENDIF
   ENDCASE
   IF ((ndetailtype = 1 ) )
    CALL addreply ("is defined (exists)" ,"def" )
    CALL addreply ("is not defined (does not exist)" ,"not def" )
   ENDIF
   CALL closereply (false )
  ELSE
   CALL helperror (concat ("Invalid data type of " ,cdatatype ,parameterarray[2 ] ) )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getordselect_provide (nreqtype )
  CALL initreply ("Detail Type" ,"" )
  CALL addreply ("Order Entry Field" ,"ORDER ENTRY FIELD" )
  CALL addreply ("Order List" ,"ORDER LIST" )
  CALL closereply (false )
 END ;Subroutine
 SUBROUTINE  getorddetail_provide (nreqtype ,strdetailtype ,strextraparam )
  CALL declaresqlstatements (nreqtype )
  CASE (trim (cnvtupper (strdetailtype ) ) )
   OF "ORDER LIST" :
    CALL initreply ("ORDER_LIST" ,"DESCRIPTION" )
    IF ((trim (strextraparam ) != "NOACTION" ) )
     CALL addreply ("Action Type" ,sqlcalls[41 ] )
    ENDIF
    ,
    CALL addreply ("Activity Type" ,sqlcalls[37 ] )
    CALL addreply ("Activity Sub Type" ,sqlcalls[38 ] )
    CALL addreply ("Catalog Code" ,sqlcalls[39 ] )
    CALL addreply ("Catalog Type" ,sqlcalls[36 ] )
    CALL addreply ("Day Of Treatment Order Indicator" ,sqlcalls[43 ] )
    CALL addreply ("Order Provider" ,sqlcalls[35 ] )
    CALL addreply ("Synonym Id" ,sqlcalls[40 ] )
    CALL addreply ("Protocol Order Indicator" ,sqlcalls[44 ] )
    CALL closereply (false )
   OF "ORDER ENTRY FIELD" :
    CALL buildoefielddetails_provide (nreqtype ,"OE" )
   ELSE
    CALL helperror (concat ("Unknown order detail type of " ,trim (strdetailtype ) ) )
  ENDCASE
 END ;Subroutine
 SUBROUTINE  buildoefielddetails_provide (nreqtype ,stroetypes )
  DECLARE funtypes[16 ] = c1 WITH constant ("S" ,"N" ,"N" ,"Q" ,"Q" ,"Q" ,"I" ,"B" ,"I" ,"I" ,"S" ,
   "I" ,"I" ,"I" ,"S" ,"S" )
  DECLARE fun1codes[16 ] = i2 WITH constant (1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,14 ,1 ,1 ,12 ,1 ,14 ,1 ,1 )
  DECLARE fun2codes[16 ] = i2 WITH constant (10 ,11 ,11 ,9 ,9 ,9 ,2 ,8 ,12 ,2 ,10 ,12 ,13 ,12 ,10 ,
   10 )
  IF ((stroetypes = "PROMPT" ) )
   SET fieldtype = "P|"
  ELSE
   SET fieldtype = "X|"
  ENDIF
  SELECT INTO "nl:"
   FROM (order_entry_fields oef ),
    (oe_field_meaning oft )
   PLAN (oef
    WHERE (((stroetypes = "OE" ) ) OR ((stroetypes = "PROMPT" )
    AND (oef.prompt_entity_id != 0 ) ))
    AND (oef.field_type_flag BETWEEN 0 AND 14 ) )
    JOIN (oft
    WHERE (oft.oe_field_meaning_id = oef.oe_field_meaning_id )
    AND (((nreqtype > 0 ) ) OR ((nreqtype = - (1 ) )
    AND (oft.oe_field_meaning = "REASONFOREXAM" ) )) )
   ORDER BY cnvtupper (oef.description )
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt +=1 ,
    stat = alterlist (tmprec->qual ,cnt ) ,
    IF ((mod (cnt ,10 ) = 1 )
    AND (cnt != 1 ) ) stat = alterlist (tmprec->qual ,(cnt + 10 ) )
    ENDIF
    ,tmprec->cnt = cnt ,
    tmprec->qual[cnt ].order_entry_field = concat (trim (oef.description ) ,", " ,cnvtupper (
      uar_get_code_display (oef.catalog_type_cd ) ) ) ,
    IF ((cnvtupper (trim (oft.oe_field_meaning ,3 ) ) IN ("STRENGTHDOSE" ,
    "STRENGTHDOSEUNIT" ,
    "VOLUMEDOSE" ,
    "VOLUMEDOSEUNIT" ,
    "FREETXTDOSE" ,
    "DOSEQTY" ,
    "DOSEQTYUNIT" ,
    "COMPONENTFREQ" ,
    "NORMALIZEDRATE" ,
    "NORMALIZEDRATEUNIT" ) ) )
     CASE (cnvtupper (trim (oft.oe_field_meaning ,3 ) ) )
      OF "COMPONENTFREQ" :
       tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
          .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] ) )
        ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,concat ("CDF" ,trim (cnvtstring (oef
           .codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
         .field_type_flag + 1 ) ] ) ,"+" ,"I|COMPONENTFREQ|1|2|CDF4004" )
      OF "STRENGTHDOSE" :
       tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
          .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] ) )
        ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (
          oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
         .field_type_flag + 1 ) ] ) ,"+" ,"N|STRENGTHDOSE|1|11" )
      OF "STRENGTHDOSEUNIT" :
       IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim
         (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
           .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
         concat ("CCK" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,
         trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|STRENGTHDOSEUNIT|1|2|CDF54" )
       ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
           .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
          ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CCK" ,
          trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes
          [(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|STRENGTHDOSEUNIT|1|2|CDF54" )
       ENDIF
      OF "VOLUMEDOSE" :
       tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
          .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] ) )
        ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (
          oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
         .field_type_flag + 1 ) ] ) ,"+" ,"N|VOLUMEDOSE|1|11" )
      OF "VOLUMEDOSEUNIT" :
       IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim
         (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
           .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
         concat ("CCK" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,
         trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|VOLUMEDOSEUNIT|1|2|CDF54" )
       ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
           .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
          ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CCK" ,
          trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes
          [(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|VOLUMEDOSEUNIT|1|2|CDF54" )
       ENDIF
      OF "FREETXTDOSE" :
       tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
          .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] ) )
        ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (
          oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
         .field_type_flag + 1 ) ] ) ,"+" ,"S|FREETXTDOSE|1|11" )
      OF "DOSEQTY" :
       tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
          .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] ) )
        ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (
          oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
         .field_type_flag + 1 ) ] ) ,"+" ,"N|DOSEQTY|1|11" )
      OF "DOSEQTYUNIT" :
       IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim
         (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
           .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
         concat ("CCK" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,
         trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|DOSEQTYUNIT|1|2|CDF54" )
       ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
           .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
          ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CCK" ,
          trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes
          [(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|DOSEQTYUNIT|1|2|CDF54" )
       ENDIF
      OF "NORMALIZEDRATE" :
       tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
          .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] ) )
        ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (
          oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
         .field_type_flag + 1 ) ] ) ,"+" ,"N|NORMALIZED_RATE|1|11" )
      OF "NORMALIZEDRATEUNIT" :
       IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim
         (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
           .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
         concat ("CCK" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,
         trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|NORMALIZED_RATE_UNIT|1|2|CDF54" )
       ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
           .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
          ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CCK" ,
          trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes
          [(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|NORMALIZED_RATE_UNIT|1|2|CDF54" )
       ENDIF
     ENDCASE
    ELSE
     IF ((oef.codeset IN (54 ,
     93 ,
     200 ,
     4001 ,
     4003 ) ) ) tmprec->qual[cnt ].hidden_par = concat (trim (fieldtype ) ,trim (cnvtstring (oef
         .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] ) ) ,
       "|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,concat ("CCK" ,trim (cnvtstring (oef
          .codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
        .field_type_flag + 1 ) ] ) )
     ELSEIF ((oef.codeset IN (8 ,
     57 ,
     106 ,
     1309 ,
     4004 ,
     6000 ,
     6003 ,
     6004 ) ) ) tmprec->qual[cnt ].hidden_par = concat (trim (fieldtype ) ,trim (cnvtstring (oef
         .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] ) ) ,
       "|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,concat ("CDF" ,trim (cnvtstring (oef
          .codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
        .field_type_flag + 1 ) ] ) )
     ELSEIF ((oef.field_type_flag = 11 ) ) tmprec->qual[cnt ].hidden_par = concat (trim (fieldtype )
       ,trim (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,"1" ,"|" ,"23" ,"|" ,trim (cnvtstring (oef
         .codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef.field_type_flag +
        1 ) ] ) )
     ELSE
      IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat (trim (fieldtype ) ,trim (
         cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
          .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,trim (
         cnvtstring (oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
         .field_type_flag + 1 ) ] ) )
      ELSE tmprec->qual[cnt ].hidden_par = concat (trim (fieldtype ) ,trim (cnvtstring (oef
          .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] ) )
        ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (
          oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
         .field_type_flag + 1 ) ] ) )
      ENDIF
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (tmprec->qual ,cnt )
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   order_entry_field = substring (1 ,1024 ,tmprec->qual[d1.seq ].order_entry_field ) ,
   _hidden_par = substring (1 ,1024 ,tmprec->qual[d1.seq ].hidden_par )
   FROM (dummyt d1 WITH seq = value (tmprec->cnt ) )
   ORDER BY cnvtupper (tmprec->qual[d1.seq ].order_entry_field )
   HEAD REPORT
    stat = 0 ,
    reply->cnt = 0 ,
    reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
    reply->fieldsize = size (reply->fieldname )
   DETAIL
    reply->cnt +=1 ,
    IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
    ENDIF
    ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
   FOOT REPORT
    stat = alterlist (reply->qual ,reply->cnt )
   WITH maxrow = 1 ,reporthelp ,check
  ;end select
 END ;Subroutine
 SUBROUTINE  (getordselect (nreqtype =vc ) =null )
  CALL initreply ("DETAIL_TYPE" ,"" )
  CALL addreply ("Order Entry Field" ,"ORDER ENTRY FIELD" )
  CALL addreply ("Order Level" ,"ORDER LEVEL" )
  CALL addreply ("Order List" ,"ORDER LIST" )
  IF ((nreqtype = 1 ) )
   CALL addreply ("Prompt Order Entry Field" ,"Prompt Order Entry Field" )
  ENDIF
  CALL addreply ("Service Resource" ,"SERVICE RESOURCE" )
  CALL closereply (false )
 END ;Subroutine
 SUBROUTINE  (getorddetail (nreqtype =i2 ,strdetailtype =vc ,strextraparam =vc ) =null )
  IF ((nreqtype IN (3 ,
  4 ) ) )
   CALL declaresqlstatements ((nreqtype - 2 ) )
   CALL initreply ("LOCATION TYPES" ,"" )
   CALL addreply ("Order Location" ,sqlcalls[5 ] )
   CALL addreply ("Person Facility" ,sqlcalls[1 ] )
   CALL addreply ("Person Nurse Unit" ,sqlcalls[2 ] )
   CALL addreply ("Person Room" ,sqlcalls[3 ] )
   CALL closereply (false )
  ELSE
   CALL declaresqlstatements (nreqtype )
   CASE (trim (cnvtupper (strdetailtype ) ) )
    OF "ORDER LEVEL" :
     CALL initreply ("ORDER_LEVEL" ,"DESCRIPTION" )
     CALL addreply ("Contributor System" ,sqlcalls[4 ] )
     CALL closereply (false )
    OF "ORDER LIST" :
     CALL initreply ("ORDER_LIST" ,"DESCRIPTION" )
     CALL addreply ("Action Type" ,sqlcalls[6 ] )
     CALL addreply ("Activity Type" ,sqlcalls[17 ] )
     CALL addreply ("Activity Sub Type" ,sqlcalls[32 ] )
     IF ((nreqtype = 1 ) )
      CALL addreply ("Bill Only Ind" ,sqlcalls[13 ] )
     ENDIF
     ,
     IF ((nreqtype = 1 ) )
      CALL addreply ("Catalog Code" ,sqlcalls[46 ] )
     ELSE
      CALL addreply ("Catalog Code" ,sqlcalls[33 ] )
     ENDIF
     ,
     CALL addreply ("Catalog Type" ,sqlcalls[11 ] )
     IF ((nreqtype = 1 ) )
      CALL addreply ("Consent Form Ind" ,sqlcalls[14 ] )
      CALL addreply ("Consent Form" ,sqlcalls[15 ] )
      CALL addreply ("Consent Form Routing" ,sqlcalls[16 ] )
     ENDIF
     ,
     CALL addreply ("Communication Type" ,sqlcalls[7 ] )
     CALL addreply ("Day Of Treatment Order Indicator" ,sqlcalls[47 ] )
     CALL addreply ("Department Status" ,sqlcalls[18 ] )
     IF ((nreqtype = 1 ) )
      CALL addreply ("No Charge Ind" ,sqlcalls[12 ] )
     ENDIF
     ,
     CALL addreply ("Order Date/Time" ,sqlcalls[9 ] )
     CALL addreply ("Order Entry Format" ,sqlcalls[10 ] )
     CALL addreply ("Order Provider" ,sqlcalls[8 ] )
     CALL addreply ("Order Status" ,sqlcalls[19 ] )
     CALL addreply ("Original Order As Flag" ,sqlcalls[42 ] )
     CALL addreply ("Protocol Order Indicator" ,sqlcalls[48 ] )
     IF ((nreqtype = 1 ) )
      CALL addreply ("Synonym Id" ,sqlcalls[45 ] )
     ELSE
      CALL addreply ("Synonym Id" ,sqlcalls[34 ] )
     ENDIF
     ,
     IF ((nreqtype = 1 ) )
      CALL addreply ("Template Order Flag" ,sqlcalls[31 ] )
     ENDIF
     ,
     CALL closereply (false )
    OF "PROMPT ORDER ENTRY FIELD" :
     CALL buildoefielddetials (nreqtype ,"PROMPT" )
    OF "SERVICE RESOURCE" :
     CALL initreply ("SERVICE_RESOURCE" ,"DESCRIPTION" )
     IF ((nreqtype = 1 ) )
      CALL addreply ("Collection Login Location" ,sqlcalls[21 ] )
      CALL addreply ("Service Area" ,sqlcalls[22 ] )
      CALL addreply ("Service Resource" ,sqlcalls[20 ] )
     ELSE
      CALL addreply ("Not valid for this template" ,"" )
     ENDIF
     ,
     CALL closereply (false )
    OF "ORDER ENTRY FIELD" :
     CALL buildoefielddetials (nreqtype ,"OE" )
    ELSE
     CALL helperror (concat ("Unknown order detail type of " ,trim (strdetailtype ) ) )
   ENDCASE
  ENDIF
 END ;Subroutine
 SUBROUTINE  buildoefielddetials (nreqtype ,stroetypes )
  DECLARE funtypes[16 ] = c1 WITH constant ("S" ,"N" ,"N" ,"Q" ,"Q" ,"Q" ,"I" ,"B" ,"I" ,"I" ,"S" ,
   "I" ,"I" ,"I" ,"S" ,"S" )
  DECLARE fun1codes[16 ] = i2 WITH constant (1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,14 ,1 ,1 ,12 ,1 ,14 ,1 ,1 )
  DECLARE fun2codes[16 ] = i2 WITH constant (10 ,11 ,11 ,9 ,9 ,9 ,2 ,8 ,12 ,2 ,10 ,12 ,13 ,12 ,10 ,
   10 )
  IF ((stroetypes = "PROMPT" ) )
   SET fieldtype = "P|"
  ELSE
   SET fieldtype = "X|"
  ENDIF
  SELECT INTO "nl:"
   FROM (order_entry_fields oef ),
    (oe_field_meaning oft )
   PLAN (oef
    WHERE (((stroetypes = "OE" ) ) OR ((stroetypes = "PROMPT" )
    AND (oef.prompt_entity_id != 0 ) ))
    AND (oef.field_type_flag BETWEEN 0 AND 14 ) )
    JOIN (oft
    WHERE (oft.oe_field_meaning_id = oef.oe_field_meaning_id ) )
   ORDER BY cnvtupper (oef.description )
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt +=1 ,
    stat = alterlist (tmprec->qual ,cnt ) ,
    IF ((mod (cnt ,10 ) = 1 )
    AND (cnt != 1 ) ) stat = alterlist (tmprec->qual ,(cnt + 10 ) )
    ENDIF
    ,tmprec->cnt = cnt ,
    tmprec->qual[cnt ].order_entry_field = concat (trim (oef.description ) ,", " ,cnvtupper (
      uar_get_code_display (oef.catalog_type_cd ) ) ) ,
    IF ((cnvtupper (trim (oft.oe_field_meaning ,3 ) ) IN ("DOSEQTY" ,
    "DOSEQTYUNIT" ,
    "FREETXTDOSE" ,
    "COMPONENTFREQ" ,
    "STRENGTHDOSEUNIT" ,
    "STRENGTHDOSE" ,
    "VOLUMEDOSEUNIT" ,
    "VOLUMEDOSE" ,
    "NORMALIZEDRATEUNIT" ,
    "NORMALIZEDRATE" ) ) )
     CASE (cnvtupper (trim (oft.oe_field_meaning ,3 ) ) )
      OF "DOSEQTY" :
       IF ((nreqtype = 1 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (
          cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
           .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 )
           ] ) ) ,"|" ,trim (cnvtstring (oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,
         trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"N|scDoseQuantity|1|11" )
       ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
           .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
          ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,trim (
          cnvtstring (oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
          .field_type_flag + 1 ) ] ) ,"+" ,"N|oi.dose_quantity|1|11" )
       ENDIF
      OF "DOSEQTYUNIT" :
       IF ((nreqtype = 1 ) )
        IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,
          trim (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
            .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
          concat ("CCK" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|"
          ,trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|scDoseQuantityUnit|1|2|CDF54" )
        ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
            .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
           ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CCK" ,
           trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (
           funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|scDoseQuantityUnit|1|2|CDF54" )
        ENDIF
       ELSE
        IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,
          trim (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
            .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
          concat ("CCK" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|"
          ,trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|oi.dose_quantity|1|2|CDF54" )
        ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
            .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
           ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CCK" ,
           trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (
           funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|oi.dose_quantity|1|2|CDF54" )
        ENDIF
       ENDIF
      OF "FREETXTDOSE" :
       IF ((nreqtype = 1 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (
          cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
           .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 )
           ] ) ) ,"|" ,trim (cnvtstring (oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,
         trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"S|scFreetextDose|1|11" )
       ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
           .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
          ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,trim (
          cnvtstring (oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
          .field_type_flag + 1 ) ] ) ,"+" ,"S|oi.freetext_dose|1|11" )
       ENDIF
      OF "COMPONENTFREQ" :
       IF ((nreqtype = 1 ) )
        IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,
          trim (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
            .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
          concat ("CDF" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|"
          ,trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|scFrequency|1|2|CDF4004" )
        ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
            .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
           ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CDF" ,
           trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (
           funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|scFrequency|1|2|CDF4004" )
        ENDIF
       ELSE
        IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,
          trim (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
            .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
          concat ("CDF" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|"
          ,trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|oi.freq_cd|1|2|CDF4004" )
        ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
            .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
           ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CDF" ,
           trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (
           funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|oi.freq_cd|1|2|CDF4004" )
        ENDIF
       ENDIF
      OF "STRENGTHDOSEUNIT" :
       IF ((nreqtype = 1 ) )
        IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,
          trim (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
            .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
          concat ("CCK" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|"
          ,trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|scStrengthUnit|1|2|CDF54" )
        ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
            .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
           ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CCK" ,
           trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (
           funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|scStrengthUnit|1|2|CDF54" )
        ENDIF
       ELSE
        IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,
          trim (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
            .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
          concat ("CCK" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|"
          ,trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|oi.strength_unit|1|2|CDF54" )
        ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
            .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
           ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CCK" ,
           trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (
           funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|oi.strength_unit|1|2|CDF54" )
        ENDIF
       ENDIF
      OF "STRENGTHDOSE" :
       IF ((nreqtype = 1 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (
          cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
           .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 )
           ] ) ) ,"|" ,trim (cnvtstring (oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,
         trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"N|scStrengthDose|1|11" )
       ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
           .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
          ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,trim (
          cnvtstring (oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
          .field_type_flag + 1 ) ] ) ,"+" ,"N|oi.strength|1|11" )
       ENDIF
      OF "VOLUMEDOSEUNIT" :
       IF ((nreqtype = 1 ) )
        IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,
          trim (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
            .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
          concat ("CCK" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|"
          ,trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|scVolumeUnit|1|2|CDF54" )
        ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
            .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
           ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CCK" ,
           trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (
           funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|scVolumeUnit|1|2|CDF54" )
        ENDIF
       ELSE
        IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,
          trim (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
            .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
          concat ("CCK" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|"
          ,trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|oi.Volume_Unit|1|2|CDF54" )
        ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
            .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
           ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CCK" ,
           trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (
           funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|oi.Volume_Unit|1|2|CDF54" )
        ENDIF
       ENDIF
      OF "VOLUMEDOSE" :
       IF ((nreqtype = 1 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (
          cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
           .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 )
           ] ) ) ,"|" ,trim (cnvtstring (oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,
         trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"N|scVolumeDose|1|11" )
       ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
           .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
          ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,trim (
          cnvtstring (oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
          .field_type_flag + 1 ) ] ) ,"+" ,"N|oi.volume|1|11" )
       ENDIF
      OF "NORMALIZEDRATE" :
       IF ((nreqtype = 1 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (
          cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
           .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 )
           ] ) ) ,"|" ,trim (cnvtstring (oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,
         trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"N|scNormalizedRate|1|11" )
       ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
           .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
          ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,trim (
          cnvtstring (oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
          .field_type_flag + 1 ) ] ) ,"+" ,"N|oi.normalized_rate|1|11" )
       ENDIF
      OF "NORMALIZEDRATEUNIT" :
       IF ((nreqtype = 1 ) )
        IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,
          trim (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
            .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
          concat ("CCK" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|"
          ,trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|scNormalizedRateUnitCd|1|2|CDF54"
          )
        ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
            .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
           ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CCK" ,
           trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (
           funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|scNormalizedRateUnitCd|1|2|CDF54" )
        ENDIF
       ELSE
        IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,
          trim (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
            .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,
          concat ("CCK" ,trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|"
          ,trim (funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,
          "I|oi.normalized_rate_unit_cd|1|2|CDF54" )
        ELSE tmprec->qual[cnt ].hidden_par = concat ("U" ,trim (fieldtype ) ,trim (cnvtstring (oef
            .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] )
           ) ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,concat ("CCK" ,
           trim (cnvtstring (oef.codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (
           funtypes[(oef.field_type_flag + 1 ) ] ) ,"+" ,"I|oi.normalized_rate_unit_cd|1|2|CDF54" )
        ENDIF
       ENDIF
     ENDCASE
    ELSE
     IF ((oef.codeset IN (54 ,
     93 ,
     200 ,
     4001 ,
     4003 ) ) ) tmprec->qual[cnt ].hidden_par = concat (trim (fieldtype ) ,trim (cnvtstring (oef
         .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] ) ) ,
       "|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,concat ("CCK" ,trim (cnvtstring (oef
          .codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
        .field_type_flag + 1 ) ] ) )
     ELSEIF ((oef.codeset IN (8 ,
     57 ,
     106 ,
     1309 ,
     4004 ,
     6000 ,
     6003 ,
     6004 ) ) ) tmprec->qual[cnt ].hidden_par = concat (trim (fieldtype ) ,trim (cnvtstring (oef
         .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] ) ) ,
       "|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,concat ("CDF" ,trim (cnvtstring (oef
          .codeset ) ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
        .field_type_flag + 1 ) ] ) )
     ELSEIF ((oef.field_type_flag = 11 ) ) tmprec->qual[cnt ].hidden_par = concat (trim (fieldtype )
       ,trim (cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,"1" ,"|" ,"23" ,"|" ,trim (cnvtstring (oef
         .codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef.field_type_flag +
        1 ) ] ) )
     ELSE
      IF ((oef.codeset > 0 ) ) tmprec->qual[cnt ].hidden_par = concat (trim (fieldtype ) ,trim (
         cnvtstring (oef.oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef
          .field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (fun2codes[(6 + 1 ) ] ) ) ,"|" ,trim (
         cnvtstring (oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
         .field_type_flag + 1 ) ] ) )
      ELSE tmprec->qual[cnt ].hidden_par = concat (trim (fieldtype ) ,trim (cnvtstring (oef
          .oe_field_id ,25 ,1 ) ) ,"|" ,trim (cnvtstring (fun1codes[(oef.field_type_flag + 1 ) ] ) )
        ,"|" ,trim (cnvtstring (fun2codes[(oef.field_type_flag + 1 ) ] ) ) ,"|" ,trim (cnvtstring (
          oef.codeset ) ) ,"|" ,trim (oft.oe_field_meaning ) ,"|" ,trim (funtypes[(oef
         .field_type_flag + 1 ) ] ) )
      ENDIF
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist (tmprec->qual ,cnt )
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   order_entry_field = substring (1 ,200 ,tmprec->qual[d1.seq ].order_entry_field ) ,
   _hidden_par = substring (1 ,1024 ,tmprec->qual[d1.seq ].hidden_par )
   FROM (dummyt d1 WITH seq = value (tmprec->cnt ) )
   ORDER BY cnvtupper (tmprec->qual[d1.seq ].order_entry_field )
   HEAD REPORT
    stat = 0 ,
    reply->cnt = 0 ,
    reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
    reply->fieldsize = size (reply->fieldname )
   DETAIL
    reply->cnt +=1 ,
    IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
    ENDIF
    ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
   FOOT REPORT
    stat = alterlist (reply->qual ,reply->cnt )
   WITH maxrow = 1 ,reporthelp ,check
  ;end select
 END ;Subroutine
 SUBROUTINE  declaresqlstatements (ndx )
  IF ((ndx = 1 ) )
   SET sqlcalls[1 ] = "I|rq.locFacilityCd|1|5"
   SET sqlcalls[2 ] = "I|rq.locNurseUnitCd|5|6"
   SET sqlcalls[3 ] = "I|rq.locRoomCd|6|7"
   SET sqlcalls[4 ] = "I|rq.contributorSystemCd|1|2|89"
   SET sqlcalls[5 ] = "I|rq.orderLocnCd|3|19|220"
   SET sqlcalls[6 ] = "I|ol.actionTypeCd|1|2|CDF6003"
   SET sqlcalls[7 ] = "I|ol.communicationTypeCd|1|2|6006"
   SET sqlcalls[8 ] = "I|ol.orderProviderId|14|12"
   SET sqlcalls[9 ] = "Q|ol.orderDtTm|1|9"
   SET sqlcalls[10 ] = "I|ol.oeFormatId|17|16|CDF6003"
   SET sqlcalls[11 ] = "I|ol.catalogTypeCd|1|2|CDF6000"
   SET sqlcalls[12 ] = "I|ol.noChargeInd|1|8"
   SET sqlcalls[13 ] = "I|ol.billOnlyInd|1|8"
   SET sqlcalls[14 ] = "I|ol.consentFormInd|1|8"
   SET sqlcalls[15 ] = "I|ol.consentFormFormatCd|1|2|14161"
   SET sqlcalls[16 ] = "I|ol.consentFormRoutingCd|1|2|14990"
   SET sqlcalls[17 ] = "I|ol.activityTypeCd|1|2|CDF106"
   SET sqlcalls[18 ] = "I|ol.deptStatusCd|1|2|14281"
   SET sqlcalls[19 ] = "I|ol.orderStatusCd|1|2|CDF6004"
   SET sqlcalls[20 ] = "I|sr.serviceResourceCd|3|4|221"
   SET sqlcalls[21 ] = "I|sr.csLoginLocCd|1|4|220|CSLOGIN"
   SET sqlcalls[22 ] = "I|sr.serviceAreaCd|1|4|220|SRVAREA"
   SET sqlcalls[23 ] = "N|sc.scStrengthDose|1|11"
   SET sqlcalls[24 ] = "I|sc.scStrengthUnit|1|2|CCK54"
   SET sqlcalls[25 ] = "N|sc.scVolumeDose|1|11"
   SET sqlcalls[26 ] = "I|sc.scVolumeUnit|1|2|CCK54"
   SET sqlcalls[27 ] = "S|sc.scFreetextDose|1|11"
   SET sqlcalls[28 ] = "I|sc.scFrequency|1|2|CDF4004"
   SET sqlcalls[29 ] = "N|sc.scDoseQuantity|1|11"
   SET sqlcalls[30 ] = "I|sc.scDoseQuantityUnit|1|2|CDF54"
   SET sqlcalls[31 ] = "I|ol.templateOrderFlag|1|18|1"
   SET sqlcalls[32 ] = "I|ol.activitySubTypeCd|1|2|5801"
   SET sqlcalls[33 ] = "I|os.catalog_cd|14|20"
   SET sqlcalls[34 ] = "I|os.synonym_id|14|20"
   SET sqlcalls[35 ] = "I|Physician|14|12"
   SET sqlcalls[36 ] = "I|CatalogTypeCd|1|2|CDF6000"
   SET sqlcalls[37 ] = "I|ActivityTypeCd|1|2|CDF106"
   SET sqlcalls[38 ] = "I|ActivitySubTypeCd|1|2|5801"
   SET sqlcalls[39 ] = "UI|Catalog_Code|14|21"
   SET sqlcalls[40 ] = "UI|Synonym_code|14|21"
   SET sqlcalls[41 ] = "I|ActionTypeCd|1|2|CDF6003"
   SET sqlcalls[42 ] = "I|ol.OrigOrdAsFlag|1|22|1"
   SET sqlcalls[43 ] = "I|DayOfTreatment_order_ind|1|8"
   SET sqlcalls[44 ] = "I|protocol_order_ind|1|8"
   SET sqlcalls[45 ] = "I|ol.synonymid|14|20"
   SET sqlcalls[46 ] = "I|ol.catalogcd|14|20"
   SET sqlcalls[47 ] = "I|ol.dayOfTreatmentInfo|1|8"
   SET sqlcalls[48 ] = "I|ol.ProtocolOrderInd|1|8"
  ELSEIF ((ndx = 2 ) )
   SET sqlcalls[1 ] = "I|en.loc_facility_cd|1|5"
   SET sqlcalls[2 ] = "I|en.loc_nurse_unit_cd|5|6"
   SET sqlcalls[3 ] = "I|en.loc_room_cd|6|7"
   SET sqlcalls[4 ] = "I|os.contributor_system_cd|1|2|89"
   SET sqlcalls[5 ] = "I|oa.order_locn_cd|3|19|220"
   SET sqlcalls[6 ] = "I|oa.action_type_cd|1|2|CDF6003"
   SET sqlcalls[7 ] = "I|oa.communication_type_cd|1|2|6006"
   SET sqlcalls[8 ] = "I|oa.order_provider_id|14|12"
   SET sqlcalls[9 ] = "Q|os.orig_order_dt_tm|1|9"
   SET sqlcalls[10 ] = "I|os.oe_format_id|17|16|CDF6003"
   SET sqlcalls[11 ] = "I|os.catalog_type_cd|1|2|CDF6000"
   SET sqlcalls[12 ] = "Z|ol.noChargeInd"
   SET sqlcalls[13 ] = "Z|ol.billOnlyInd"
   SET sqlcalls[14 ] = "Z|ol.consentFormInd"
   SET sqlcalls[15 ] = "Z|ol.consentFormFormatCd|1|2|14161"
   SET sqlcalls[16 ] = "Z|ol.consentFormRoutingCd|1|2|14990"
   SET sqlcalls[17 ] = "I|os.activity_type_cd|1|2|CDF106"
   SET sqlcalls[18 ] = "I|os.dept_status_cd|1|2|14281"
   SET sqlcalls[19 ] = "I|os.order_status_cd|1|2|CDF6004"
   SET sqlcalls[20 ] = "Z|sr.service_resource_cd|3|4|221"
   SET sqlcalls[21 ] = "Z|ce.current_location_cd|1|4|220|CSLOGIN"
   SET sqlcalls[22 ] = "Z|sr.serviceAreaCd"
   SET sqlcalls[23 ] = "N|oi.strength|1|11"
   SET sqlcalls[24 ] = "I|oi.strength_unit|1|2|CCK54"
   SET sqlcalls[25 ] = "N|oi.volume|1|11"
   SET sqlcalls[26 ] = "I|oi.Volume_Unit|1|2|CCK54"
   SET sqlcalls[27 ] = "S|oi.freetext_dose|1|11"
   SET sqlcalls[28 ] = "I|oi.freq_cd|1|2|CDF4003"
   SET sqlcalls[29 ] = "N|oi.dose_quantity|1|11"
   SET sqlcalls[30 ] = "I|oi.dose_quantity|1|2|CCK54"
   SET sqlcalls[31 ] = "I|os.template_order_flag|1|18|1"
   SET sqlcalls[32 ] = "I|oc.activity_subtype_cd|1|2|5801"
   SET sqlcalls[33 ] = "I|os.catalog_cd|14|20"
   SET sqlcalls[34 ] = "I|os.synonym_id|14|20"
   SET sqlcalls[35 ] = "UI|Physician|14|12"
   SET sqlcalls[36 ] = "I|CatalogTypeCd|1|2|CDF6000"
   SET sqlcalls[37 ] = "I|ActivityTypeCd|1|2|CDF106"
   SET sqlcalls[38 ] = "I|ActivitySubTypeCd|1|2|5801"
   SET sqlcalls[39 ] = "UI|Catalog_Code|14|21"
   SET sqlcalls[40 ] = "UI|Synonym_Code|14|21"
   SET sqlcalls[41 ] = "I|ActionTypeCd|1|2|CDF6003"
   SET sqlcalls[42 ] = "I|os.orig_ord_as_flag|1|22|1"
   SET sqlcalls[43 ] = "I|DayOfTreatment_order_ind|1|8"
   SET sqlcalls[44 ] = "I|protocol_order_ind|1|8"
   SET sqlcalls[45 ] = "I|oi.synonym_id|14|20"
   SET sqlcalls[46 ] = "I|oi.catalog_cd|14|20"
   SET sqlcalls[47 ] = "I|os.dayOfTreatmentInfo|1|8"
   SET sqlcalls[48 ] = "I|os.ProtocolOrderInd|1|8"
  ENDIF
 END ;Subroutine
 SUBROUTINE  getorderdetaillist (npanelno ,strorderdetail )
  RECORD args (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  SET boldactionexcludeind = 0
  DECLARE breasonforexamind = i2 WITH noconstant (0 )
  IF ((npanelno = 2.5 ) )
   SET boldactionexcludeind = 1
   SET breasonforexamind = 1
   SET npanelno = 2
  ENDIF
  IF ((npanelno = 4 ) )
   SET breasonforexamind = 1
   SET npanelno = 2
  ENDIF
  CALL parsearguments (strorderdetail ,"|" ,args )
  SET ncmd = cnvtint (trim (args->items[(2 + npanelno ) ].value ) )
  CASE (ncmd )
   OF 0 :
    CALL helperror ("Invalid Panel Function" )
   OF 1 :
    IF ((trim (args->items[5 ].value ) = "220" ) )
     CALL getlocations (1 ,"" )
    ELSE
     CALL donext (0 )
    ENDIF
   OF 2 :
    IF ((trim (args->items[5 ].value ) = "220" ) )
     CALL getlocations (2 ,trim (args->items[8 ].value ) )
    ELSE
     IF ((boldactionexcludeind = 1 )
     AND (trim (args->items[5 ].value ) = "CDF6003" ) )
      CALL getcodeset_filter (trim (args->items[5 ].value ) ,"" ,"" ,"NOOLDACTION" ,"" )
     ELSE
      CALL getcodeset_filter (trim (args->items[5 ].value ) ,"" ,"" ,"" ,"" )
     ENDIF
    ENDIF
   OF 3 :
    CALL getcdfmeaning (cnvtint (trim (args->items[5 ].value ) ) ,strorderdetail )
   OF 4 :
    CALL getcodesetcdf (cnvtint (trim (args->items[5 ].value ) ) ,trim (args->items[6 ].value ) ,"" ,
     "" ,"" ,"" )
   OF 5 :
    CALL getfacilities (npanelno ,strorderdetail )
   OF 6 :
    CALL getnursingunits (npanelno ,strorderdetail )
   OF 7 :
    CALL getrooms (strorderdetail )
   OF 8 :
    CALL getboolean (strorderdetail )
   OF 9 :
    CALL getdatetime (strorderdetail )
   OF 10 :
    CALL getstring (strorderdetail )
   OF 11 :
    CALL getnumber (strorderdetail )
   OF 12 :
    IF ((trim (args->items[1 ].value ) = "X" ) )
     CALL getpersonnel (trim (args->items[8 ].value ) ,strorderdetail )
    ELSE
     CALL getpersonnel (trim (args->items[5 ].value ) ,strorderdetail )
    ENDIF
   OF 13 :
    IF ((cnvtint (args->items[5 ].value ) > 0 ) )
     CALL getcodeset (cnvtint (trim (args->items[5 ].value ) ) ,"" ,"" ,"" ,"" )
    ELSEIF ((breasonforexamind = 1 )
    AND (trim (args->items[6 ].value ) = "REASONFOREXAM" ) )
     CALL getreasonforexamresult ("" )
    ELSEIF ((cnvtint (args->items[3 ].value ) = 1 )
    AND (cnvtint (args->items[4 ].value ) = 13 )
    AND (trim (args->items[7 ].value ) = "I" ) )
     CALL getnumericstring ("" )
    ELSE
     CALL getstring ("" )
    ENDIF
   OF 14 :
    CALL getalphafield (strorderdetail )
   OF 15 :
    CALL getcodesetfiltered (trim (args->items[5 ].value ) ,trim (args->items[6 ].value ) ,"" ,"" ,
     "" ,strorderdetail )
   OF 16 :
    SET activitycd = cnvtreal (args->items[6 ].value )
    CALL getorderentryformats (activitycd ,"" )
   OF 17 :
    IF ((isnumeric (args->items[5 ].value ) > 0 ) )
     CALL getcodesetpostfix (cnvtint (trim (args->items[5 ].value ) ) ,"" ,"" ,"" ,strorderdetail )
    ELSE
     SET intcodeset = cnvtint (substring (4 ,(size (trim (args->items[5 ].value ) ) - 3 ) ,trim (args
        ->items[5 ].value ) ) )
     IF ((intcodeset > 0 ) )
      CALL getcodesetpostfix (intcodeset ,"" ,"" ,"" ,strorderdetail )
     ENDIF
    ENDIF
   OF 18 :
    DECLARE sqlsubfields[50 ] = vc
    SET sqlsubfields[1 ] = concat ("TEMPLATE FLAG|DESCRIPTION|None|0" ,
     "|Future Recuring Instance|6|Future Recurring Template|5" ,
     "|Order Based Instance|2|Rx Based Instance|4" ,"|Task Based Instance|3|Template|1" )
    CALL buildliteralresponse ("|" ,sqlsubfields[cnvtint (trim (args->items[5 ] ) ) ] )
   OF 19 :
    CALL getorderlocations (trim (args->items[6 ] ) ,strorderdetail )
   OF 20 :
    IF ((cnvtlower (trim (args->items[2 ] ) ) = "os.catalog_cd" ) )
     CALL getorders (concat (trim (args->items[5 ] ) ,"|0|whose primary mnemonic is" ) ,"" )
    ELSEIF ((cnvtlower (trim (args->items[2 ] ) ) = "os.synonym_id" ) )
     CALL getorders (concat (trim (args->items[5 ] ) ,"|0|that was ordered as" ) ,"" )
    ELSE
     CALL helperror ("Invalid Argument!" )
    ENDIF
   OF 21 :
    IF ((cnvtupper (trim (args->items[2 ] ) ) = "CATALOG_CODE" ) )
     CALL getorders (concat (trim (args->items[5 ] ) ,"|0|whose primary mnemonic is" ) ,"" )
    ELSEIF ((cnvtupper (trim (args->items[2 ] ) ) = "SYNONYM_CODE" ) )
     CALL getorders (concat (trim (args->items[5 ] ) ,"|0|that was ordered as" ) ,"" )
    ELSE
     CALL helperror ("Invalid args->items[2] from 21 - " ,trim (args->items[2 ] ) )
    ENDIF
   OF 22 :
    DECLARE sqlsubfields[50 ] = vc
    SET sqlsubfields[1 ] = concat ("Original Order As Flag|DESCRIPTION|Normal Order|0|" ,
     "Patient Owns Meds|3|Pharmacy Charge Only|4|Prescription/Discharge Order|1|" ,
     "Recorded(don't update)/Home Meds|2|Satellite(Super Bill) Meds|5" )
    CALL buildliteralresponse ("|" ,sqlsubfields[cnvtint (trim (args->items[5 ] ) ) ] )
   OF 23 :
    CALL getprinters (0 )
   ELSE
    CALL helperror (concat ("Unknown order detail list function id :" ,trim (cnvtstring (ncmd ) ) )
     )
  ENDCASE
 END ;Subroutine
 SUBROUTINE  getreasonforexamresult (_arg0 )
  SELECT INTO "nl:"
   description = cer.description ,
   _hidden_par = cnvtstring (cer.exam_reason_id ,25 ,1 ) ,
   discipline_type = uar_get_code_display (cer.discipline_type_cd )
   FROM (coded_exam_reason cer )
   WHERE (cer.exam_reason_id > 0 )
   ORDER BY cnvtupper (cer.description )
   HEAD REPORT
    stat = 0 ,
    reply->cnt = 0 ,
    reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
    reply->fieldsize = size (reply->fieldname )
   DETAIL
    reply->cnt +=1 ,
    IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
    ENDIF
    ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
   FOOT REPORT
    stat = alterlist (reply->qual ,reply->cnt )
   WITH maxrow = 1 ,reporthelp ,check
  ;end select
 END ;Subroutine
 SUBROUTINE  (buildliteralresponse (delim =vc ,literallist =vc ) =null )
  RECORD args (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  CALL parsearguments (literallist ,delim ,args )
  CALL initreply (args->items[1 ].value ,args->items[2 ].value )
  FOR (resp = 3 TO args->count BY 2 )
   CALL addreply (args->items[resp ].value ,args->items[(resp + 1 ) ].value )
  ENDFOR
  CALL closereply (false )
 END ;Subroutine
 SUBROUTINE  (getalphaselect (strextra =vc ) =null )
  DECLARE intmltm = i2 WITH noconstant (0 )
  SET intmltm = findstring ("\1stMCD" ,trim (par1 ) ,1 )
  IF (intmltm )
   CALL getmltmcombdrug ("\2ndMCD" )
  ELSE
   DECLARE intsyn = i2 WITH noconstant (0 )
   SET intsyn = findstring ("\" ,trim (par1 ) ,1 )
   IF ((intsyn > 0 ) )
    CALL getdrugcategoryname (concat ("\2nd" ,par1 ) )
   ELSE
    CALL initreply ("ALPHA_FILTER" ,"DESCRIPTION" )
    SELECT INTO "NL:"
     alpha_filter = char ((47 + d.seq ) ) ,
     _hidden_par = concat (char ((47 + d.seq ) ) ,"|" ,strextra )
     FROM (dummyt d WITH seq = 10 )
     ORDER BY alpha_filter
     DETAIL
      CALL addreply (alpha_filter ,_hidden_par )
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     alpha_filter = char ((64 + d.seq ) ) ,
     _hidden_par = concat (char ((64 + d.seq ) ) ,"|" ,strextra )
     FROM (dummyt d WITH seq = 26 )
     ORDER BY alpha_filter
     DETAIL
      CALL addreply (alpha_filter ,_hidden_par )
     WITH nocounter
    ;end select
    CALL addreply ("OTHER" ,concat ("OTHER|" ,strextra ) )
    CALL closereply (false )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getlocations (nlevel =i2 ,smeaning =vc ) =null )
  DECLARE cdfmeaning = c12
  SET cdfmeaning = cnvtupper (trim (smeaning ) )
  IF ((nlevel = 1 ) )
   CALL initreply ("LOCATION_TYPE" ,"DESCRIPTION" )
   SELECT INTO "nl:"
    display = cv.display ,
    _hidden_par = substring (1 ,150 ,concat (trim (parameterarray[2 ] ) ,"|" ,cv.cdf_meaning ) ) ,
    description = cv.description
    FROM (code_value cv )
    WHERE (cv.code_set = 222 )
    AND (cv.active_ind = 1 )
    AND (cv.begin_effective_dt_tm <= cnvtdatetime (sysdate ) )
    AND (cv.end_effective_dt_tm >= cnvtdatetime (sysdate ) )
    ORDER BY cnvtupper (cv.display )
    HEAD REPORT
     stat = 0
    DETAIL
     treply->cnt +=1 ,
     stat = alterlist (treply->qual ,treply->cnt ) ,
     treply->qual[treply->cnt ].display = display ,
     treply->qual[treply->cnt ].hidden = _hidden_par
    FOOT REPORT
     stat = alterlist (treply->qual ,treply->cnt )
    WITH nocounter
   ;end select
   CALL closereply (false )
  ELSEIF ((nlevel = 2 ) )
   CALL initreply ("LOCATION" ,"DESCRIPTION" )
   SELECT INTO "nl:"
    display = cv.display ,
    _hidden_par = substring (1 ,150 ,trim (cnvtstring (cv.code_value ,25 ,1 ) ) ) ,
    description = cv.description
    FROM (code_value cv )
    WHERE (cv.code_set = 220 )
    AND (cv.cdf_meaning = cdfmeaning )
    AND (cv.active_ind = 1 )
    AND (cv.begin_effective_dt_tm <= cnvtdatetime (sysdate ) )
    AND (cv.end_effective_dt_tm >= cnvtdatetime (sysdate ) )
    ORDER BY cnvtupper (cv.display )
    HEAD REPORT
     stat = 0
    DETAIL
     treply->cnt +=1 ,
     stat = alterlist (treply->qual ,treply->cnt ) ,
     treply->qual[treply->cnt ].display = display ,
     treply->qual[treply->cnt ].hidden = _hidden_par
    FOOT REPORT
     stat = alterlist (treply->qual ,treply->cnt )
    WITH nocounter
   ;end select
   CALL closereply (false )
  ELSE
   CALL helperror (concat ("Invalid panel number - " ,trim (cnvtstring (nlevel ) ) ,"-" ,smeaning )
    )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getorderlocations (locmeaning =vc ,strorderdetail =vc ) =null )
  DECLARE faccode = f8 WITH public
  DECLARE buildingcode = f8 WITH public
  DECLARE nursecode = f1 WITH public
  DECLARE statuscd = f8
  DECLARE typecodes[4 ] = f8
  SET stat = uar_get_meaning_by_codeset (222 ,"FACILITY" ,1 ,faccode )
  SET stat = uar_get_meaning_by_codeset (222 ,"BUILDING" ,1 ,buildingcode )
  SET stat = uar_get_meaning_by_codeset (222 ,"NURSEUNIT" ,1 ,nursecode )
  SET stat = uar_get_meaning_by_codeset (48 ,"ACTIVE" ,1 ,statuscd )
  SET typecodes[1 ] = nursecode
  SET typecodes[2 ] = buildingcode
  SET typecodes[3 ] = faccode
  CALL initreply (concat (trim (locmeaning ) ,"_LOCATIONS" ) ,"" )
  SELECT DISTINCT INTO "NL:"
   loc.display ,
   lv1display = build (lv1code.display ,"(" ,trim (lv1code.cdf_meaning ) ,")" ,"==>" ) ,
   lv2display = build (lv2code.display ,"(" ,trim (lv2code.cdf_meaning ) ,")" ,"==>" ) ,
   lv3display = build (lv3code.display ,"(" ,trim (lv3code.cdf_meaning ) ,")" ,"==>" ) ,
   lv4display = build (lv4code.display ,"(" ,trim (lv4code.cdf_meaning ) ,")" ,"==>" )
   FROM (code_value loc ),
    (dummyt d_loc ),
    (location_group lv1 ),
    (code_value lv1code ),
    (dummyt d_lv1 ),
    (location_group lv2 ),
    (code_value lv2code ),
    (dummyt d_lv2 ),
    (location_group lv3 ),
    (code_value lv3code ),
    (dummyt d_lv3 ),
    (location_group lv4 ),
    (code_value lv4code )
   PLAN (loc
    WHERE (loc.code_set = 220 )
    AND (loc.cdf_meaning = trim (locmeaning ) )
    AND (loc.active_ind = true ) )
    JOIN (d_loc )
    JOIN (lv1
    WHERE (lv1.child_loc_cd = loc.code_value )
    AND (lv1.active_ind = true )
    AND (lv1.root_loc_cd = 0 ) )
    JOIN (lv1code
    WHERE (lv1code.code_value = lv1.parent_loc_cd )
    AND (lv1code.active_ind = true ) )
    JOIN (d_lv1 )
    JOIN (lv2
    WHERE (lv2.child_loc_cd = lv1.parent_loc_cd )
    AND (lv2.active_ind = true )
    AND (lv2.root_loc_cd = 0 ) )
    JOIN (lv2code
    WHERE (lv2code.code_value = lv2.parent_loc_cd )
    AND (lv2code.active_ind = true ) )
    JOIN (d_lv2 )
    JOIN (lv3
    WHERE (lv3.child_loc_cd = lv2.parent_loc_cd )
    AND (lv3.active_ind = true )
    AND (lv3.root_loc_cd = 0 ) )
    JOIN (lv3code
    WHERE (lv3code.code_value = lv3.parent_loc_cd )
    AND (lv3code.active_ind = true ) )
    JOIN (d_lv3 )
    JOIN (lv4
    WHERE (lv4.child_loc_cd = lv3.parent_loc_cd )
    AND (lv4.active_ind = true ) )
    JOIN (lv4code
    WHERE (lv4code.code_value = lv4.parent_loc_cd ) )
   ORDER BY cnvtupper (lv4code.display ) ,
    cnvtupper (lv3code.display ) ,
    cnvtupper (lv2code.display ) ,
    cnvtupper (lv1code.display ) ,
    cnvtupper (loc.display )
   DETAIL
    display = build (lv4display ,lv3display ,lv2display ,lv1display ,loc.display ) ,
    CALL addreply (display ,trim (cnvtstring (loc.code_value ,25 ,1 ) ) )
   WITH nocounter ,outerjoin = d_loc ,outerjoin = d_lv1 ,outerjoin = d_lv2 ,outerjoin = d_lv3
  ;end select
  CALL closereply (false )
 END ;Subroutine
 SUBROUTINE  getfacilities (npanelno ,strextra )
  DECLARE faccode = f8 WITH public
  DECLARE buildingcode = f8 WITH public
  DECLARE statuscd = f8
  SET stat = uar_get_meaning_by_codeset (222 ,"FACILITY" ,1 ,faccode )
  SET stat = uar_get_meaning_by_codeset (222 ,"BUILDING" ,1 ,buildingcode )
  SET stat = uar_get_meaning_by_codeset (48 ,"ACTIVE" ,1 ,statuscd )
  IF ((npanelno = 1 ) )
   CALL initreply ("FACILITY_BUILDING" ,"" )
  ELSE
   CALL initreply ("FACILITY" ,"" )
  ENDIF
  SELECT DISTINCT INTO "NL:"
   fac_name = uar_get_code_display (facility.parent_loc_cd ) ,
   bld_name = uar_get_code_display (building.location_cd )
   FROM (location building ),
    (location_group facility ),
    (location_group bld )
   PLAN (building
    WHERE (building.location_type_cd = buildingcode )
    AND (building.organization_id > 0 )
    AND (building.active_ind = true )
    AND (building.active_status_cd = statuscd ) )
    JOIN (bld
    WHERE (bld.parent_loc_cd = building.location_cd )
    AND (bld.location_group_type_cd = buildingcode )
    AND (bld.active_ind = true )
    AND (bld.active_status_cd = statuscd ) )
    JOIN (facility
    WHERE (facility.child_loc_cd = bld.parent_loc_cd )
    AND (facility.location_group_type_cd = faccode )
    AND (facility.active_ind = true )
    AND (facility.active_status_cd = statuscd ) )
   ORDER BY fac_name ,
    bld_name
   DETAIL
    IF ((npanelno = 1 ) )
     CALL addreply (concat (trim (fac_name ) ,"-->" ,trim (bld_name ) ) ,concat (trim (strextra ) ,
      "|" ,trim (cnvtstring (building.location_cd ,25 ,1 ) ) ) )
    ELSEIF ((npanelno = 2 ) )
     CALL addreply (concat (trim (fac_name ) ,"-->" ,trim (bld_name ) ) ,concat (trim (cnvtstring (
        facility.parent_loc_cd ,25 ,1 ) ) ) )
    ENDIF
   WITH nocounter
  ;end select
  CALL closereply (false )
 END ;Subroutine
 SUBROUTINE  getnursingunits (npanelno ,strextra )
  DECLARE faccode = f8
  DECLARE buildingcode = f8
  DECLARE fac = f8
  DECLARE nurseunit = f8
  DECLARE statuscd = f8
  RECORD args (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  SET stat = uar_get_meaning_by_codeset (222 ,"FACILITY" ,1 ,faccode )
  SET stat = uar_get_meaning_by_codeset (222 ,"BUILDING" ,1 ,buildingcode )
  SET stat = uar_get_meaning_by_codeset (222 ,"NURSEUNIT" ,1 ,nurseunit )
  SET stat = uar_get_meaning_by_codeset (48 ,"ACTIVE" ,1 ,statuscd )
  IF ((npanelno = 2 ) )
   CALL parsearguments (strextra ,"|" ,result )
   SET fac = cnvtreal (trim (args->items[5 ].value ) )
   SET disp = uar_get_code_description (fac )
   CALL initreply (concat ("BUILDING_LOCATIONS_FOR_" ,trim (disp ) ) ,"" )
  ELSE
   SET fac = 0.0
   CALL initreply ("WHICH_FACILITY_BUILDING_NURSE_UNIT" ,"" )
  ENDIF
  SELECT DISTINCT INTO "NL:"
   fac_name = uar_get_code_display (facility.parent_loc_cd ) ,
   bld_name = uar_get_code_display (building.location_cd ) ,
   loc_name = uar_get_code_display (bld.child_loc_cd )
   FROM (location building ),
    (location_group facility ),
    (location_group bld ),
    (code_value nurs )
   PLAN (building
    WHERE (building.location_type_cd = buildingcode )
    AND (((building.location_cd = fac ) ) OR ((fac = 0 ) ))
    AND (building.organization_id > 0 )
    AND (building.active_ind = true )
    AND (building.active_status_cd = statuscd ) )
    JOIN (bld
    WHERE (bld.parent_loc_cd = building.location_cd )
    AND (bld.location_group_type_cd = buildingcode )
    AND (bld.active_ind = true )
    AND (bld.active_status_cd = statuscd ) )
    JOIN (facility
    WHERE (facility.child_loc_cd = bld.parent_loc_cd )
    AND (facility.location_group_type_cd = faccode )
    AND (facility.active_ind = true ) )
    JOIN (nurs
    WHERE (nurs.code_value = bld.child_loc_cd )
    AND (nurs.active_ind = true ) )
   ORDER BY fac_name ,
    bld_name ,
    loc_name
   DETAIL
    IF ((npanelno = 1 ) )
     CALL addreply (concat (trim (fac_name ) ,"-->" ,trim (bld_name ) ,"-->" ,trim (loc_name ) ) ,
     concat (trim (strextra ) ,"|" ,trim (cnvtstring (building.location_cd ,25 ,1 ) ) ) )
    ELSEIF ((npanelno = 2 ) )
     CALL addreply (trim (loc_name ) ,concat (trim (strextra ) ,"|" ,trim (cnvtstring (facility
        .parent_loc_cd ,25 ,1 ) ) ) )
    ENDIF
   WITH nocounter
  ;end select
  CALL closereply (false )
 END ;Subroutine
 SUBROUTINE  getrooms (strextra )
  DECLARE nurseunit = f8 WITH protect
  RECORD args (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  CALL parsearguments (strextra ,"|" ,args )
  SET nurseunit = cnvtreal (trim (args->items[5 ].value ) )
  SET disp = uar_get_code_description (nurseunit )
  CALL initreply (concat ("ROOMS_FOR_" ,trim (disp ) ) ,"" )
  SELECT INTO "NL:"
   room.*
   FROM (code_value room ),
    (location_group rooms )
   PLAN (rooms
    WHERE (rooms.parent_loc_cd = nurseunit )
    AND (rooms.active_ind = 1 )
    AND (rooms.root_loc_cd = 0.0 ) )
    JOIN (room
    WHERE (room.code_value = rooms.child_loc_cd )
    AND (room.active_ind = 1 )
    AND (room.cdf_meaning = "ROOM" ) )
   ORDER BY cnvtupper (room.display )
   DETAIL
    CALL addreply (room.display ,concat (trim (cnvtstring (room.code_value ,25 ,1 ) ) ) )
   WITH nocounter
  ;end select
  CALL closereply (false )
 END ;Subroutine
 SUBROUTINE  (getboolean (strextraparam =vc ) =null )
  DECLARE strextra = vc
  IF ((size (trim (strextraparam ) ) > 0 ) )
   SET strextra = concat ("|" ,trim (strextraparam ) )
  ELSE
   SET strextra = ""
  ENDIF
  CALL initreply ("YES_NO" ,"" )
  CALL addreply ("Yes/True" ,"1" )
  CALL addreply ("No/False" ,"0" )
  CALL closereply (false )
 END ;Subroutine
 SUBROUTINE  (getdatetime (strextraparam =vc ) =null )
  DECLARE strextra = vc
  IF ((size (trim (strextraparam ) ) > 0 ) )
   SET strextra = concat ("|" ,trim (strextraparam ) )
  ELSE
   SET strextra = ""
  ENDIF
  CALL initreply ("DATE_TIME" ,"" )
  CALL addreply ("TODAY+days" ,"Current event date + #days" )
  CALL addreply ("TODAY-days" ,"Current event date - #days" )
  CALL addreply ("NOW+minutes" ,"Current event time + #minutes" )
  CALL addreply ("NOW-minutes" ,"Current event time - #minutes" )
  CALL closereply (true )
 END ;Subroutine
 SUBROUTINE  (getstring (strextraparam =vc ) =null )
  DECLARE strextra = vc
  IF ((size (trim (strextraparam ) ) > 0 ) )
   SET strextra = concat ("|" ,trim (strextraparam ) )
  ELSE
   SET strextra = ""
  ENDIF
  CALL initreply ("FREETEXT_STRING" ,"" )
  CALL addreply ("<new string>" ,"" )
  CALL closereply (true )
 END ;Subroutine
 SUBROUTINE  getnumericstring (strextraparam )
  DECLARE strextra = vc
  IF ((size (trim (strextraparam ) ) > 0 ) )
   SET strextra = concat ("|" ,trim (strextraparam ) )
  ELSE
   SET strextra = ""
  ENDIF
  CALL initreply ("FREETEXT_NUMER" ,"" )
  CALL addreply ("<new freetext number>" ,"" )
  CALL closereply (true )
 END ;Subroutine
 SUBROUTINE  (getnumber (strextraparam =vc ) =null )
  DECLARE strextra = vc
  IF ((size (trim (strextraparam ) ) > 0 ) )
   SET strextra = concat ("|" ,trim (strextraparam ) )
  ELSE
   SET strextra = ""
  ENDIF
  CALL initreply ("FREETEXT_NUMBER" ,"" )
  CALL addreply ("<new number>" ,"" )
  CALL closereply (true )
 END ;Subroutine
 SUBROUTINE  getpersonnel (strfilter ,strorderdetail )
  SET filter = concat (trim (cnvtupper (strfilter ) ) ,"*" )
  SELECT INTO "nl:"
   personnel_list = concat (trim (p.name_full_formatted ) ,",  " ,trim (uar_get_code_display (p
      .position_cd ) ) ) ,
   _hidden_par = trim (cnvtstring (p.person_id ,25 ,1 ) ) ,
   active_status =
   IF ((p.active_ind = 1 ) ) "Active"
   ELSE "InActive"
   ENDIF
   FROM (prsnl p )
   WHERE (p.name_last_key = patstring (filter ) )
   ORDER BY cnvtupper (p.name_full_formatted )
   HEAD REPORT
    stat = 0 ,
    reply->cnt = 0 ,
    reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
    reply->fieldsize = size (reply->fieldname )
   DETAIL
    reply->cnt +=1 ,
    IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
    ENDIF
    ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
   FOOT REPORT
    stat = alterlist (reply->qual ,reply->cnt )
   WITH maxrow = 1 ,reporthelp ,check
  ;end select
  IF ((reply->cnt = 0 ) )
   CALL helperror ("No itmes found" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getprinters (_null )
  DECLARE printer_type_cd = f8 WITH protect
  SET printer_type_cd = uar_get_code_by ("MEANING" ,3000 ,"PRINTER" )
  IF ((printer_type_cd > 0 ) )
   CALL initreply ("PRINTER_NAME" ,"" )
   SELECT INTO "nl:"
    printer_name = od.name ,
    _hidden_par = substring (1 ,256 ,trim (cnvtstring (od.output_dest_cd ,25 ,1 ) ) )
    FROM (output_dest od ),
     (device d )
    PLAN (od )
     JOIN (d
     WHERE (od.device_cd = d.device_cd )
     AND (d.device_type_cd = printer_type_cd ) )
    ORDER BY cnvtupper (od.name )
    DETAIL
     CALL addreply (printer_name ,_hidden_par )
    WITH nocounter
   ;end select
   IF ((treply->cnt <= 0 ) )
    CALL helperror ("No printers found!" )
   ELSE
    CALL closereply (false )
   ENDIF
  ELSE
   CALL helperror ("No printer type code found!" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getorderentryformats (nactiontypecd ,strorderdetail )
  CALL initreply ("ORDER_ENTRY_FORMATS" ,"" )
  IF ((strorderdetail > "" ) )
   SET orderdetail = concat ("|" ,strorderdetail )
  ELSE
   SET orderdetail = ""
  ENDIF
  SELECT INTO "NL:"
   oe_format_name = oef.oe_format_name ,
   _hidden_par = concat (trim (cnvtstring (oef.oe_format_id ,25 ,1 ) ) ,orderdetail )
   FROM (order_entry_format oef )
   WHERE (oef.action_type_cd = nactiontypecd )
   ORDER BY cnvtupper (oef.oe_format_name )
   DETAIL
    CALL addreply (oe_format_name ,_hidden_par )
   WITH nocounter
  ;end select
  CALL closereply (false )
 END ;Subroutine
 SUBROUTINE  getalphafield (strextra )
  CALL initreply ("ALPHA_FILTER" ,"" )
  SELECT INTO "NL:"
   alpha_filter = char ((47 + d.seq ) ) ,
   _hidden_par = concat (trim (strextra ) ,"|" ,char ((47 + d.seq ) ) )
   FROM (dummyt d WITH seq = 10 )
   ORDER BY alpha_filter
   DETAIL
    CALL addreply (alpha_filter ,_hidden_par )
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   alpha_filter = char ((64 + d.seq ) ) ,
   _hidden_par = concat (trim (strextra ) ,"|" ,char ((64 + d.seq ) ) )
   FROM (dummyt d WITH seq = 26 )
   DETAIL
    CALL addreply (alpha_filter ,_hidden_par )
   WITH nocounter
  ;end select
  CALL addreply ("OTHER" ,concat (trim (strextra ) ,"|" ,"OTHER" ) )
  CALL closereply (false )
 END ;Subroutine
 SUBROUTINE  donext (_null )
  CALL initreply ("ORDER_LIST_HELP_1_OF_2" ,"DESCRIPTION" )
  CALL addreply ("Select this line and press [<<Next>>] to continue or [Cancel] to quit" ,
   parameterarray[2 ] )
  CALL closereply (false )
 END ;Subroutine
 SUBROUTINE  (getcdfmeaning (ncodeset =i2 ,strextra =vc ) =null )
  SELECT INTO "NL:"
   _meaning = cdf.cdf_meaning ,
   _hidden_par = substring (1 ,1024 ,concat (trim (strextra ) ,"|" ,trim (cdf.cdf_meaning ) ) )
   FROM (common_data_foundation cdf )
   WHERE (cdf.code_set = ncodeset )
   ORDER BY cnvtupper (cdf.cdf_meaning )
   HEAD REPORT
    stat = 0 ,
    reply->cnt = 0 ,
    reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
    reply->fieldsize = size (reply->fieldname )
   DETAIL
    reply->cnt +=1 ,
    IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
    ENDIF
    ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
   FOOT REPORT
    stat = alterlist (reply->qual ,reply->cnt )
   WITH maxrow = 1 ,reporthelp ,check
  ;end select
 END ;Subroutine
 SUBROUTINE  getcodeset_filter (strcodeset ,strcol1header ,strcol2header ,stradditionaltext ,
  strextraparam )
  DECLARE sql = vc WITH private
  DECLARE sqlreply = vc WITH private
  DECLARE sqlselect = vc WITH private
  DECLARE strcol1hdr = vc
  DECLARE strcol2hdr = vc
  DECLARE strextra = vc
  RECORD extraargs (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  IF ((strextraparam > " " ) )
   SET strextra = concat ("|" ,strextraparam )
  ELSE
   SET strextra = ""
  ENDIF
  IF ((isnumeric (strcodeset ) > 0 ) )
   SET ncodeset = cnvtint (strcodeset )
   SET strtemp = ""
  ELSE
   SET strtemp = substring (1 ,3 ,trim (strcodeset ) )
   SET ncodeset = cnvtint (substring (4 ,(size (strcodeset ) - 3 ) ,trim (strcodeset ) ) )
  ENDIF
  SET bnooldactionind = 0
  IF ((trim (stradditionaltext ) = "NOOLDACTION" )
  AND (ncodeset = 6003 ) )
   SET bnooldactionind = 1
   SET stradditionaltext = ""
  ENDIF
  IF ((strcol1header > "" ) )
   SET strcol1hdr = strcol1header
   SET strcol2hdr = strcol1header
  ELSE
   SET strcol1hdr = fillstring (150 ,"" )
   CALL getcodesetname (ncodeset ,strcol1hdr )
   SET strcol2hdr = "DESCRIPTION"
  ENDIF
  SET extraargs->count = 0
  CALL parsearguments (stradditionaltext ,"|" ,extraargs )
  CALL initreply (strcol1hdr ,strcol2hdr )
  IF ((trim (strextraparam ) = "with drug class as" ) )
   CALL getdrugcategoryname ("\1st" )
  ELSEIF ((trim (strextraparam ) = "that contain" ) )
   CALL getmltmcombdrug ("\1stMCD" )
  ELSE
   SELECT INTO "NL:"
    display = format (extraargs->items[d.seq ].value ,"########################################" ) ,
    _hidden_par = substring (1 ,1024 ,concat (extraargs->items[d.seq ].value ,strextra ) ) ,
    description = format (" " ,"############################################################" )
    FROM (dummyt d WITH seq = value (extraargs->count ) )
    DETAIL
     CALL addreply (display ,_hidden_par )
    WITH nocounter
   ;end select
   CALL echo (concat ("strExtra: " ,build (strextra ) ) )
   SELECT INTO "nl:"
    display = cv.display ,
    _hidden_par =
    IF ((size (trim (strextra ) ) > 0 ) )
     IF ((size (trim (cv.cki ,3 ) ) = 0 ) ) substring (1 ,256 ,concat (trim (cnvtstring (cv
          .code_value ,25 ,1 ) ) ,strextra ) )
     ELSE substring (1 ,256 ,concat (trim (cv.cki ,3 ) ,strextra ) )
     ENDIF
    ELSE
     IF ((trim (strtemp ) = "CDF" )
     AND (size (trim (cv.cdf_meaning ,3 ) ) > 0 ) ) substring (1 ,256 ,concat ("CDF" ,trim (
         cnvtstring (ncodeset ) ) ,":" ,trim (cv.cdf_meaning ,3 ) ) )
     ELSEIF ((trim (strtemp ) = "CCK" )
     AND (size (trim (cv.concept_cki ,3 ) ) > 0 ) ) substring (1 ,256 ,concat ("CCK" ,trim (
         cnvtstring (ncodeset ) ) ,":" ,trim (cv.concept_cki ,3 ) ) )
     ELSEIF ((size (trim (cv.cki ,3 ) ) = 0 ) ) substring (1 ,256 ,trim (cnvtstring (cv.code_value ,
         25 ,1 ) ) )
     ELSE substring (1 ,256 ,trim (cv.cki ,3 ) )
     ENDIF
    ENDIF
    ,description = cv.description
    FROM (code_value cv )
    WHERE (cv.code_set = ncodeset )
    AND (cv.active_ind = 1 )
    AND (cv.code_value > 0 )
    AND (((bnooldactionind = 0 ) ) OR ((bnooldactionind = 1 )
    AND NOT ((trim (cv.cdf_meaning ) IN ("CANCEL" ,
    "COMPLETE" ,
    "DELETE" ,
    "SUSPEND" ,
    "DISCONTINUE" ,
    "TRANSFER/CAN" ) ) ) ))
    ORDER BY cnvtupper (cv.display )
    HEAD REPORT
     stat = 0
    DETAIL
     treply->cnt +=1 ,
     stat = alterlist (treply->qual ,treply->cnt ) ,
     treply->qual[treply->cnt ].display = display ,
     treply->qual[treply->cnt ].hidden = _hidden_par
    FOOT REPORT
     stat = alterlist (treply->qual ,treply->cnt )
    WITH maxrow = 1 ,reporthelp ,check
   ;end select
   CALL closereply (false )
  ENDIF
  IF ((reply->cnt = 0 ) )
   CALL helperror ("No code values found" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getcodeset (ncodeset =i2 ,strcol1header =vc ,strcol2header =vc ,stradditionaltext =vc ,
  strextraparam =vc ) =null )
  DECLARE sql = vc WITH private
  DECLARE sqlreply = vc WITH private
  DECLARE sqlselect = vc WITH private
  DECLARE strcol1hdr = vc
  DECLARE strcol2hdr = vc
  DECLARE strextra = vc
  RECORD extraargs (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  IF ((strextraparam > " " ) )
   SET strextra = concat ("|" ,strextraparam )
  ELSE
   SET strextra = ""
  ENDIF
  IF ((strcol1header > "" ) )
   SET strcol1hdr = strcol1header
   SET strcol2hdr = strcol1header
  ELSE
   SET strcol1hdr = fillstring (150 ,"" )
   CALL getcodesetname (ncodeset ,strcol1hdr )
   SET strcol2hdr = "DESCRIPTION"
  ENDIF
  SET extraargs->count = 0
  CALL parsearguments (stradditionaltext ,"|" ,extraargs )
  CALL initreply (strcol1hdr ,strcol2hdr )
  IF ((trim (strextraparam ) = "with drug class as" ) )
   CALL getdrugcategoryname ("\1st" )
  ELSEIF ((trim (strextraparam ) = "that contain" ) )
   CALL getmltmcombdrug ("\1stMCD" )
  ELSE
   SELECT INTO "NL:"
    display = format (extraargs->items[d.seq ].value ,"########################################" ) ,
    _hidden_par = substring (1 ,1024 ,concat (extraargs->items[d.seq ].value ,strextra ) ) ,
    description = format (" " ,"############################################################" )
    FROM (dummyt d WITH seq = value (extraargs->count ) )
    DETAIL
     CALL addreply (display ,_hidden_par )
   ;end select
   SET sqlselect = concat ('select into "nl:" ' ,"       display = cv.display, " ,
    "       _HIDDEN_PAR = SubString(1, 256, ConCat(trim(CnvtString(cv.code_value,25,1)), strExtra)) , "
    ,"       description =  cv.description /**/" ,"from code_value cv /**/" ,"where cv.code_set = " ,
    cnvtstring (ncodeset ) ,"       and cv.active_ind = 1 /**/" )
   SET sqlreply = concat ("order CnvtUpper(cv.display) " ,"head report " ,"       stat = 0 " ,
    "detail " ,"       tReply->cnt = tReply->cnt + 1 " ,
    "       stat = alterlist(tReply->qual,tReply->cnt) " ,
    "       tReply->qual[tReply->cnt].display = display " ,
    "       tReply->qual[tReply->cnt].hidden = _HIDDEN_PAR " ,"foot report " ,
    "       stat = alterlist(tReply->qual,tReply->cnt) " ,"with maxrow = 1, reporthelp, check GO " )
   SET sql = concat (sqlselect ,sqlreply )
   CALL parser (sql ,1 )
   CALL closereply (false )
  ENDIF
  IF ((reply->cnt = 0 ) )
   CALL helperror ("No code values found" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getcodesetpostfix (ncodeset ,strcol1header ,strcol2header ,stradditionaltext ,
  strextraparam )
  RECORD extraargs (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  DECLARE qual = vc
  DECLARE strextra = vc
  IF ((trim (strextraparam ) > "" ) )
   SET strextra = concat (trim (strextraparam ) ,"|" )
  ELSE
   SET strextra = ""
  ENDIF
  SET extraargs->count = 0
  CALL parsearguments (stradditionaltext ,"|" ,extraargs )
  CALL initreply ("TITLE" ,"DESCRIPTION" )
  SELECT INTO "NL:"
   display = extraargs->items[d.seq ].value ,
   _hidden_par = substring (1 ,1024 ,concat (extraargs->items[d.seq ].value ,strextra ) )
   FROM (dummyt d WITH seq = value (extraargs->count ) )
   DETAIL
    CALL addreply (display ,_hidden_par )
   WITH nocounter
  ;end select
  SET qual = concat ("cv.code_set = " ,trim (cnvtstring (ncodeset ) ) )
  SELECT INTO "nl:"
   cv.*
   FROM (code_value cv )
   WHERE parser (qual )
   AND (cv.active_ind = 1 )
   ORDER BY cnvtupper (cv.display )
   DETAIL
    CALL addreply (cv.display ,concat (trim (strextra ) ,trim (cnvtstring (cv.code_value ,25 ,1 ) )
     ) )
   WITH nocounter
  ;end select
  CALL closereply (false )
 END ;Subroutine
 SUBROUTINE  (getcodesetfiltered (strcodeset =vc ,strfilter =vc ,strcol1header =vc ,strcol2header =
  vc ,stradditionaltext =vc ,strextraparam =vc ) =null )
  IF (isnumeric (strcodeset ) )
   SET ncodeset = cnvtint (strcodeset )
   SET strtemp = ""
  ELSE
   SET strtemp = substring (1 ,3 ,trim (strcodeset ) )
   SET ncodeset = cnvtint (substring (4 ,(size (strcodeset ) - 3 ) ,trim (strcodeset ) ) )
  ENDIF
  DECLARE sql = vc WITH private ,notrim
  DECLARE sqlreply = vc WITH private ,notrim
  DECLARE sqlselect = vc WITH private ,notrim
  DECLARE strcol1hdr = vc
  DECLARE strcol2hdr = vc
  DECLARE strextra = vc
  DECLARE filter = c2
  RECORD extraargs (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  IF ((strextraparam > " " ) )
   SET strextra = concat ("|" ,strextraparam )
  ELSE
   SET strextra = ""
  ENDIF
  IF (isnumeric (strcodeset ) )
   SET ncodeset = cnvtint (strcodeset )
   SET strtemp = ""
  ELSE
   SET strtemp = substring (1 ,3 ,trim (strcodeset ) )
   SET ncodeset = cnvtint (substring (4 ,(size (strcodeset ) - 3 ) ,trim (strcodeset ) ) )
  ENDIF
  IF ((strcol1header > "" ) )
   SET strcol1hdr = strcol1header
   SET strcol2hdr = strcol1header
  ELSE
   SET strcol1hdr = fillstring (150 ,"" )
   CALL getcodesetname (ncodeset ,strcol1hdr )
   SET strcol2hdr = "DESCRIPTION"
  ENDIF
  SET filter = concat (trim (cnvtupper (strfilter ) ) ,"*" )
  SET extraargs->count = 0
  CALL parsearguments (stradditionaltext ,"|" ,extraargs )
  CALL initreply (strcol1hdr ,strcol2hdr )
  SELECT INTO "NL:"
   display = format (extraargs->items[d.seq ].value ,"########################################" ) ,
   _hidden_par = substring (1 ,1024 ,concat (extraargs->items[d.seq ].value ,strextra ) ) ,
   description = format (" " ,"############################################################" )
   FROM (dummyt d WITH seq = value (extraargs->count ) )
   DETAIL
    CALL addreply (display ,_hidden_par )
   WITH nocounter
  ;end select
  SET sqlselect = concat ('select into "nl:" ' ,"	display = cv.display, " ,
   "	_Hidden_par = if (size(trim(strExtra)) > 0) " ,"		if (size(trim(cv.cki,3)) = 0) " ,
   "			SubString(1, 256, ConCat(trim(CnvtString(cv.code_value,25,1)), strExtra)) " ,"		else " ,
   "			SubString(1, 256, ConCat( Trim(cv.cki,3), strExtra)) " ,"		endif " ,"	else " ,
   '		if (cnvtupper(trim(strTemp)) = "CDF" and size(trim(cv.cdf_meaning)) ) ' ,
   ' 	substring(1, 256, concat(trim(strTemp), trim(cnvtstring(nCodeSet)), ":", trim(cv.cdf_meaning)) '
   ,'		elseif (cnvtupper(trim(strTemp)) = "CCK" and size(trim(cv.concept_cki)) ) ' ,
   '	substring(1, 256, concat(trim(strTemp), trim(cnvtstring(nCodeSet)), ":", trim(cv.concept_cki)) '
   ,"		elseif (size(trim(cv.cki,3)) = 0) " ,
   "			SubString(1, 256, trim(CnvtString(cv.code_value,25,1)) ) " ,"		else " ,
   "			SubString(1, 256, Trim(cv.cki,3) ) " ,"		endif " ,"	endif, " ,
   " description =  cv.description /**/" ,"from code_value cv /**/" ,"where cv.code_set = " ,
   cnvtstring (ncodeset ) ,'       and cv.display_key =  "' ,trim (filter ) ,'" ' ,
   "       and cv.active_ind = 1 " )
  SET sqlreply = concat ("order CnvtUpper(cv.display) " ,"head report " ,"	stat = 0 " ,"detail " ,
   "	tReply->cnt = tReply->cnt + 1 " ,"	stat = alterlist(tReply->qual,tReply->cnt) " ,
   "	tReply->qual[tReply->cnt].display = display " ,
   "	tReply->qual[tReply->cnt].hidden = _HIDDEN_PAR " ,"foot report " ,
   "	stat = alterlist(tReply->qual,tReply->cnt) " ,"with maxrow = 1, reporthelp, check GO " )
  SET sql = concat (sqlselect ,sqlreply )
  CALL parser (sql ,1 )
  CALL closereply (false )
  IF ((reply->cnt = 0 ) )
   CALL helperror ("No code values found" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getcodesetcdf (ncodeset =i2 ,strcdfmeaning =vc ,strcol1header =vc ,strcol2header =vc ,
  stradditionaltext =vc ,strextraparam =vc ) =null )
  DECLARE sql = vc WITH private
  DECLARE sqlreply = vc WITH private
  DECLARE sqlselect = vc WITH private
  DECLARE strcol1hdr = vc
  DECLARE strcol2hdr = vc
  DECLARE strextra = vc
  RECORD extraargs (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  IF ((strextraparam > " " ) )
   SET strextra = concat ("|" ,strextraparam )
  ELSE
   SET strextra = ""
  ENDIF
  IF ((strcol1header > "" ) )
   SET strcol1hdr = strcol1header
   SET strcol2hdr = strcol1header
  ELSE
   SET strcol1hdr = fillstring (150 ,"" )
   CALL getcodesetname (ncodeset ,strcol1hdr )
   SET strcol2hdr = "DESCRIPTION"
  ENDIF
  SET extraargs->count = 0
  CALL parsearguments (stradditionaltext ,"|" ,extraargs )
  CALL initreply (strcol1hdr ,strcol2hdr )
  SELECT INTO "NL:"
   display = format (extraargs->items[d.seq ].value ,"########################################" ) ,
   _hidden_par = substring (1 ,1024 ,concat (extraargs->items[d.seq ].value ,strextra ) ) ,
   description = format (" " ,"############################################################" )
   FROM (dummyt d WITH seq = value (extraargs->count ) )
   DETAIL
    CALL addreply (display ,_hidden_par )
  ;end select
  SET sqlselect = concat ('select into "nl:" ' ,"	display = cv.display, " ,
   "	_HIDDEN_PAR = SubString(1, 256, ConCat(trim(CnvtString(cv.code_value,25,1)), strExtra)) , " ,
   "	description =  cv.description /**/" ,"from code_value cv /**/" ,"where cv.code_set = " ,
   cnvtstring (ncodeset ) ,' 	and cv.cdf_meaning = "' ,trim (strcdfmeaning ) ,'" ' ,
   "	and cv.active_ind = 1 /**/" )
  SET sqlreply = concat ("order CnvtUpper(cv.display) " ,"head report " ,"	stat = 0 " ,"detail " ,
   "	tReply->cnt = tReply->cnt + 1 " ,"	stat = alterlist(tReply->qual,tReply->cnt) " ,
   "	tReply->qual[tReply->cnt].display = display " ,
   "	tReply->qual[tReply->cnt].hidden = _HIDDEN_PAR " ,"foot report " ,
   "	stat = alterlist(tReply->qual,tReply->cnt) " ,"with maxrow = 1, reporthelp, check GO " )
  SET sql = concat (sqlselect ,sqlreply )
  CALL parser (sql ,1 )
  CALL closereply (false )
  IF ((reply->cnt = 0 ) )
   CALL helperror ("No code values found" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getcodesetname (ncodesettarget =i2 ,strresult =vc (ref ) ) =null )
  DECLARE setname = vc
  DECLARE result = vc
  SET setname = "Unknown                      "
  SELECT INTO "NL:"
   *
   FROM (code_value_set cs )
   WHERE (cs.code_set = ncodesettarget )
   DETAIL
    IF ((cs.display > " " ) ) setname = trim (cs.display )
    ENDIF
   WITH nocounter
  ;end select
  SET result = replace (trim (setname ) ," " ,"_" ,0 )
  SET strresult = result
 END ;Subroutine
 SUBROUTINE  getcontinuingordermethodflag (_null )
  SELECT INTO "NL:"
   continuing_order_method =
   IF ((d.seq = 1 ) ) "Order Based"
   ENDIF
   ,_hidden_par =
   IF ((d.seq = 1 ) ) "0"
   ENDIF
   ,description =
   IF ((d.seq = 1 ) ) "Order Based Continuing Order"
   ENDIF
   FROM (dummyt d WITH seq = 1 )
   PLAN (d
    WHERE (d.seq > 0 ) )
   HEAD REPORT
    stat = 0 ,
    reply->cnt = 0 ,
    reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
    reply->fieldsize = size (reply->fieldname )
   DETAIL
    reply->cnt +=1 ,
    IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
    ENDIF
    ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
   FOOT REPORT
    stat = alterlist (reply->qual ,reply->cnt )
   WITH maxrow = 1 ,reporthelp ,check
  ;end select
 END ;Subroutine
 SUBROUTINE  (getordmethod (strextra =vc ) =null )
  SELECT INTO "NL:"
   ord_method =
   IF ((d.seq = 1 ) ) "that was ordered as"
   ELSE "whose primary mnemonic is"
   ENDIF
   ,_hidden_par =
   IF ((d.seq = 1 ) ) concat ("that was ordered as" ,"|" ,strextra )
   ELSE concat ("whose primary mnemonic is" ,"|" ,strextra )
   ENDIF
   ,description =
   IF ((d.seq = 1 ) ) "Use only the order synonym for comparison"
   ELSE "Include all related synonms for this order"
   ENDIF
   FROM (dummyt d WITH seq = 2 )
   PLAN (d
    WHERE (d.seq > 0 ) )
   HEAD REPORT
    stat = 0 ,
    reply->cnt = 0 ,
    reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
    reply->fieldsize = size (reply->fieldname )
   DETAIL
    reply->cnt +=1 ,
    IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
    ENDIF
    ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
   FOOT REPORT
    stat = alterlist (reply->qual ,reply->cnt )
   WITH maxrow = 1 ,reporthelp ,check
  ;end select
 END ;Subroutine
 SUBROUTINE  getnewordmethod (strextra )
  DECLARE imultumind = i2 WITH noconstant (0 )
  SELECT INTO "nl:"
   FROM (mltm_category_drug_xref )
   WHERE (drug_synonym_id > 0 )
   WITH nocounter
  ;end select
  IF (curqual )
   SET imultumind = 0
  ELSE
   SET imultumind = 1
  ENDIF
  IF (imultumind )
   SELECT INTO "NL:"
    ord_method =
    IF ((d.seq = 1 ) ) "that was ordered as"
    ELSEIF ((d.seq = 2 ) ) "whose primary mnemonic is"
    ELSEIF ((d.seq = 3 ) ) "for any orderable"
    ELSEIF ((d.seq = 4 ) ) "with drug class as"
    ELSEIF ((d.seq = 5 ) ) "with catalog code"
    ELSEIF ((d.seq = 6 ) ) "that contain"
    ENDIF
    ,description =
    IF ((d.seq = 1 ) ) "Use only the order synonym for comparison"
    ELSEIF ((d.seq = 2 ) ) "Include all related synonms for this order"
    ELSEIF ((d.seq = 3 ) ) "Include all orderable procedure"
    ELSEIF ((d.seq = 4 ) ) "with drug class as"
    ELSEIF ((d.seq = 5 ) ) "do not use CKI"
    ELSEIF ((d.seq = 6 ) ) "component drugs"
    ENDIF
    FROM (dummyt d WITH seq = 6 )
    PLAN (d
     WHERE (d.seq > 0 ) )
    HEAD REPORT
     stat = 0 ,
     reply->cnt = 0 ,
     reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
     reply->fieldsize = size (reply->fieldname )
    DETAIL
     reply->cnt +=1 ,
     IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
     ENDIF
     ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
    FOOT REPORT
     stat = alterlist (reply->qual ,reply->cnt )
    WITH maxrow = 1 ,reporthelp ,check
   ;end select
  ELSE
   SELECT INTO "NL:"
    ord_method =
    IF ((d.seq = 1 ) ) "that was ordered as"
    ELSEIF ((d.seq = 2 ) ) "whose primary mnemonic is"
    ELSEIF ((d.seq = 3 ) ) "for any orderable"
    ELSEIF ((d.seq = 4 ) ) "with catalog code"
    ELSEIF ((d.seq = 5 ) ) "that contain"
    ENDIF
    ,description =
    IF ((d.seq = 1 ) ) "Use only the order synonym for comparison"
    ELSEIF ((d.seq = 2 ) ) "Include all related synonms for this order"
    ELSEIF ((d.seq = 3 ) ) "Include all orderable procedure"
    ELSEIF ((d.seq = 4 ) ) "do not use CKI"
    ELSEIF ((d.seq = 5 ) ) "component drugs"
    ENDIF
    FROM (dummyt d WITH seq = 5 )
    PLAN (d
     WHERE (d.seq > 0 ) )
    HEAD REPORT
     stat = 0 ,
     reply->cnt = 0 ,
     reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
     reply->fieldsize = size (reply->fieldname )
    DETAIL
     reply->cnt +=1 ,
     IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
     ENDIF
     ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
    FOOT REPORT
     stat = alterlist (reply->qual ,reply->cnt )
    WITH maxrow = 1 ,reporthelp ,check
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE  gettemplateorderflag (_null )
  SELECT INTO "NL:"
   parent_child =
   IF ((d.seq = 1 ) ) "Parent"
   ELSE "Child"
   ENDIF
   ,_hidden_par =
   IF ((d.seq = 1 ) ) "1"
   ELSE "2"
   ENDIF
   ,description =
   IF ((d.seq = 1 ) ) "Template Instance"
   ELSE "Order/Task Based Instance"
   ENDIF
   FROM (dummyt d WITH seq = 2 )
   PLAN (d
    WHERE (d.seq > 0 ) )
   HEAD REPORT
    stat = 0 ,
    reply->cnt = 0 ,
    reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
    reply->fieldsize = size (reply->fieldname )
   DETAIL
    reply->cnt +=1 ,
    IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
    ENDIF
    ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
   FOOT REPORT
    stat = alterlist (reply->qual ,reply->cnt )
   WITH maxrow = 1 ,reporthelp ,check
  ;end select
 END ;Subroutine
 SUBROUTINE  isvalidname (strvarname )
  DECLARE i = i4 WITH protect
  DECLARE text_size = i4 WITH protect
  DECLARE strtmptext = vc WITH protect
  SET abc_string = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _"
  SET strtmptext = trim (strvarname )
  SET text_size = size (strtmptext ,1 )
  FOR (i = 1 TO text_size )
   IF ((findstring (cnvtupper (substring (i ,1 ,strtmptext ) ) ,abc_string ,1 ) = 0 ) )
    SET i = (text_size + 1 )
    RETURN (0 )
   ENDIF
  ENDFOR
  RETURN (1 )
 END ;Subroutine
 SUBROUTINE  (initreply (strcol1header =vc ,strcol2header =vc ) =null )
  IF ((size (trim (strcol1header ) ) > 0 )
  AND isvalidname (trim (strcol1header ) ) )
   SET treply->fieldname = replace (trim (strcol1header ) ," " ,"_" ,0 )
  ELSE
   SET treply->fieldname = "DISPLAY"
  ENDIF
  SET treply->cnt = 0
 END ;Subroutine
 SUBROUTINE  (addreply (strdisplay =vc ,strhidden =vc ) =null )
  SET treply->cnt +=1
  SET stat = alterlist (treply->qual ,treply->cnt )
  SET treply->qual[treply->cnt ].display = strdisplay
  SET treply->qual[treply->cnt ].hidden = strhidden
 END ;Subroutine
 SUBROUTINE  closereply (bstandard )
  DECLARE sql = vc
  DECLARE sqlreply = vc WITH private
  DECLARE sqlselect = vc WITH private
  SET reply->cnt = 0
  IF ((bstandard = false ) )
   SET sqlselect = concat ('select into "NL:"  ' ,trim (treply->fieldname ) ,
    " = SubString(1, 1024, tReply->qual[d.seq].display), " ,
    "	_HIDDEN_PAR = SubString(1, 1024, tReply->qual[d.seq].hidden) " ,
    "from (dummyt d with seq = Value(tReply->cnt)) /**/" )
  ELSE
   SET sqlselect = concat ('select into "NL:"  ' ,trim (treply->fieldname ) ,
    " = SubString(1, 256, tReply->qual[d.seq].display), " ,' 	_hidden_par = " " ' ,
    "from (dummyt d with seq = Value(tReply->cnt)) /**/" )
  ENDIF
  SET sqlreply = concat ("where tReply->qual[d.seq].display > '' " ,"head report " ,
   "	stat = alterlist(reply->qual,reply->cnt + 50) " ,"	stat = 0 " ,
   '	reply->fieldname = concat(reportinfo(1),"^") ' ,"	reply->fieldsize = size(reply->fieldname) " ,
   "detail " ,"	reply->cnt = reply->cnt + 1 " ,"	if(mod(reply->cnt,50) = 1) " ,
   "		stat = alterlist(reply->qual,reply->cnt + 50) " ,"	endif " ,
   '	reply->qual[reply->cnt].result = concat(reportinfo(2),"^") ' ,"foot report " ,
   "	stat = alterlist(reply->qual,reply->cnt) " ,"with maxrow = 1, reporthelp, check go " )
  SET sql = concat (sqlselect ,sqlreply )
  CALL echo (concat ("sql = " ,sql ) )
  CALL parser (sql ,1 )
  IF ((reply->cnt = 0 ) )
   CALL helperror ("No items found" )
  ENDIF
  SET treply->cnt = 0
  SET stat = alterlist (treply->qual ,0 )
  CALL echo ("SENDING REPLY WITH :" )
 END ;Subroutine
 SUBROUTINE  helperror (errmsgx )
  SET strtext = errmsgx
  SELECT DISTINCT INTO "NL:"
   error_message = strtext ,
   _hidden = d1.seq
   FROM (dummyt d1 WITH seq = 1 )
   PLAN (d1 )
   ORDER BY d1.seq
   HEAD REPORT
    stat = 0 ,
    reply->cnt = 0 ,
    reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
    reply->fieldsize = size (reply->fieldname )
   DETAIL
    reply->cnt +=1 ,
    IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
    ENDIF
    ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
   FOOT REPORT
    stat = alterlist (reply->qual ,reply->cnt )
   WITH maxrow = 1 ,reporthelp ,check
  ;end select
 END ;Subroutine
 SUBROUTINE  (getparameters (stringparam =vc ) =null )
  SET curparam = 1
  SET paramend = 0
  SET parametercount = 0
  WHILE ((paramend < size (trim (stringparam ) ) ) )
   SET paramstart = (paramend + 1 )
   SET paramend = findstring ("^" ,stringparam ,paramstart )
   IF ((paramend = 0 ) )
    SET paramend = (size (trim (stringparam ) ) + 1 )
   ENDIF
   SET parameterarray[curparam ] = substring (paramstart ,(paramend - paramstart ) ,stringparam )
   SET curparam +=1
  ENDWHILE
  SET parametercount = (curparam - 1 )
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
 SUBROUTINE  writeexitmessage (wemekmmessage )
  SET eksdata->tqual[tinx ].qual[curindex ].logging = wemekmmessage
  IF (berror )
   SET retval = false
   CALL writemessage ("Error status, returning FALSE to EKS" )
  ENDIF
  SET retval = (bresult * 100 )
  CALL writemessage (wemekmmessage )
  CALL writemessage (concat ("**** " ,format (curdate ,"MM/DD/YYYY;;d" ) ," " ,format (curtime ,
     "hh:mm:ss;;m" ) ) )
  CALL writemessage (concat ("******** END OF " ,trim (tname ) ," ***********" ) )
 END ;Subroutine
 SUBROUTINE  writemessage (wmekmlogmessage )
  IF ((wmekmlogmessage > "" ) )
   SET len = size (trim (wmekmlogmessage ) )
   SET pos = 1
   IF ((len > 130 ) )
    WHILE (((len - pos ) <= 130 ) )
     CALL printstring (substring (pos ,130 ,wmekmlogmessage ) )
     SET pos +=130
    ENDWHILE
   ELSE
    CALL printstring (wmekmlogmessage )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (printstring (lpstring =vc ) =null )
  IF ((substring ((size (trim (lpstring ) ) - 2 ) ,3 ,lpstring ) = "..." ) )
   CALL echo (substring (1 ,(size (trim (lpstring ) ) - 3 ) ,lpstring ) ,0 )
  ELSE
   CALL echo (lpstring )
  ENDIF
 END ;Subroutine
 SUBROUTINE  helpsubject (_null )
  SELECT DISTINCT
   keyword =
   IF ((d1.seq = 1 ) ) "@ACCESSION:"
   ELSEIF ((d1.seq = 2 ) ) "@BIRTHDATE:"
   ELSEIF ((d1.seq = 3 ) ) "@BIRTHDTTM:"
   ELSEIF ((d1.seq = 4 ) ) "@CATALOGCDDISP:"
   ELSEIF ((d1.seq = 5 ) ) "@CURDATETIME"
   ELSEIF ((d1.seq = 6 ) ) "@CURREV"
   ELSEIF ((d1.seq = 7 ) ) "@CURSYS"
   ELSEIF ((d1.seq = 8 ) ) "@EKSMODULENAME"
   ELSEIF ((d1.seq = 9 ) ) "@EVENTCDDISP:"
   ELSEIF ((d1.seq = 10 ) ) "@EVENTENDDTTM"
   ELSEIF ((d1.seq = 11 ) ) "@MEDICALNUMBER:"
   ELSEIF ((d1.seq = 12 ) ) "@MISC:"
   ELSEIF ((d1.seq = 13 ) ) "@NEWLINE"
   ELSEIF ((d1.seq = 14 ) ) "@ORDERDOC:"
   ELSEIF ((d1.seq = 15 ) ) "@ORDERDOCEMAIL:"
   ELSEIF ((d1.seq = 16 ) ) "@ORDERDOCPRINTER:"
   ELSEIF ((d1.seq = 17 ) ) "@ORDERID:"
   ELSEIF ((d1.seq = 18 ) ) "@ORGPRINTER:"
   ELSEIF ((d1.seq = 19 ) ) "@ORIGORDERDTTM:"
   ELSEIF ((d1.seq = 20 ) ) "@PATIENT:"
   ELSEIF ((d1.seq = 21 ) ) "@PATIENTID:"
   ELSEIF ((d1.seq = 22 ) ) "@PTBLDGENC:"
   ELSEIF ((d1.seq = 23 ) ) "@PTBLDGENCEMAIL:"
   ELSEIF ((d1.seq = 24 ) ) "@PTBLDGENCPRINTER:"
   ELSEIF ((d1.seq = 25 ) ) "@PATFACENC:"
   ELSEIF ((d1.seq = 26 ) ) "@PTFACENCEMAIL:"
   ELSEIF ((d1.seq = 27 ) ) "@PTFACENCPRINTER:"
   ELSEIF ((d1.seq = 28 ) ) "@PTLOCENC:"
   ELSEIF ((d1.seq = 29 ) ) "@PTLOCENCEMAIL:"
   ELSEIF ((d1.seq = 30 ) ) "@PTLOCENCPRINTER:"
   ELSEIF ((d1.seq = 31 ) ) "@PTNURSENC:"
   ELSEIF ((d1.seq = 32 ) ) "@PTNURSENCEMAIL:"
   ELSEIF ((d1.seq = 33 ) ) "@PTNURSENCPRINTER:"
   ELSEIF ((d1.seq = 34 ) ) "@PTLOCORD:"
   ELSEIF ((d1.seq = 35 ) ) "@PTLOCORDEMAIL:"
   ELSEIF ((d1.seq = 36 ) ) "@PTLOCORDPRINTER:"
   ELSEIF ((d1.seq = 37 ) ) "@PTROOMENC:"
   ELSEIF ((d1.seq = 38 ) ) "@RESULT:"
   ELSEIF ((d1.seq = 39 ) ) "@TASKASSAY:"
   ELSEIF ((d1.seq = 40 ) ) "@AGE:"
   ELSEIF ((d1.seq = 41 ) ) "@AGEYRS:"
   ENDIF
   FROM (dummyt d1 WITH seq = 41 )
   ORDER BY keyword
   HEAD REPORT
    stat = 0 ,
    reply->cnt = 0 ,
    reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
    reply->fieldsize = size (reply->fieldname )
   DETAIL
    reply->cnt +=1 ,
    IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
    ENDIF
    ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
   FOOT REPORT
    stat = alterlist (reply->qual ,reply->cnt )
   WITH maxrow = 1 ,reporthelp ,check
  ;end select
 END ;Subroutine
 SUBROUTINE  (helppriority (ncnt =i2 ) =null )
  IF ((((ncnt = 0 ) ) OR ((ncnt = 3 ) )) )
   SET ncnt = 3
  ELSE
   SET ncnt = 2
  ENDIF
  SELECT DISTINCT
   priority =
   IF ((ncnt = 3 ) )
    IF ((d1.seq = 1 ) ) "Low"
    ELSEIF ((d1.seq = 2 ) ) "Medium"
    ELSEIF ((d1.seq = 3 ) ) "High"
    ENDIF
   ELSE
    IF ((d1.seq = 1 ) ) "Low"
    ELSEIF ((d1.seq = 2 ) ) "High"
    ENDIF
   ENDIF
   FROM (dummyt d1 WITH seq = value (ncnt ) )
   PLAN (d1 )
   ORDER BY d1.seq
   HEAD REPORT
    stat = 0 ,
    reply->cnt = 0 ,
    reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
    reply->fieldsize = size (reply->fieldname )
   DETAIL
    reply->cnt +=1 ,
    IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
    ENDIF
    ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
   FOOT REPORT
    stat = alterlist (reply->qual ,reply->cnt )
   WITH maxrow = 1 ,reporthelp ,check
  ;end select
 END ;Subroutine

 SUBROUTINE  helpremindertype (_null )
  DECLARE tmpcv = f8
  DECLARE tmpdisplay = vc
  DECLARE iret = i4
  SET tmpcv = 0
  SET tmpdisplay = ""
  SET iret = 0
  CALL initreply ("MESSAGE_TYPE" ,"" )
  SET iret = uar_get_meaning_by_codeset (6026 ,"REMINDER" ,1 ,tmpcv )
  IF ((iret = 0 ) )
   SET tmpdisplay = uar_get_code_display (tmpcv )
   IF ((tmpdisplay > "" ) )
    CALL addreply (tmpdisplay ,"REMINDER" )
   ENDIF
  ENDIF

  CALL closereply (false )
 END ;Subroutine
 
 SUBROUTINE  helpmsgtype (_null )
  DECLARE tmpcv = f8
  DECLARE tmpdisplay = vc
  DECLARE iret = i4
  SET tmpcv = 0
  SET tmpdisplay = ""
  SET iret = 0
  CALL initreply ("MESSAGE_TYPE" ,"" )
  SET iret = uar_get_meaning_by_codeset (6026 ,"PHONE MSG" ,1 ,tmpcv )
  IF ((iret = 0 ) )
   SET tmpdisplay = uar_get_code_display (tmpcv )
   IF ((tmpdisplay > "" ) )
    CALL addreply (tmpdisplay ,"PHONE MSG" )
   ENDIF
  ENDIF
  SET tmpdisplay = ""
  SET tmpcv = 0.0
  SET iret = uar_get_meaning_by_codeset (6026 ,"ALERT" ,1 ,tmpcv )
  IF ((iret = 0 ) )
   SET tmpdisplay = uar_get_code_display (tmpcv )
   IF ((tmpdisplay > "" ) )
    CALL addreply (tmpdisplay ,"ALERT" )
   ENDIF
  ENDIF
  CALL closereply (false )
 END ;Subroutine
 SUBROUTINE  (helprecipient (nlevel =i2 ,strextraparam =vc ) =null )
  DECLARE strextra = vc
  RECORD args (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  IF ((strextraparam > " " ) )
   SET strextra = concat ("|" ,strextraparam )
  ELSE
   SET strextra = " "
  ENDIF
  IF ((nlevel = 1 ) )
   CALL initreply ("CATEGORY" ,"" )
   CALL addreply ("Encounter/Personnel Relation" ,"EP_RELATION" )
   CALL addreply ("Order Relation" ,"OR_RELATION" )
   CALL addreply ("Patient" ,"PATIENT" )
   CALL addreply ("Person" ,"PERSON" )
   CALL addreply ("Person/Personnel Relation" ,"PP_RELATION" )
   CALL addreply ("Pool" ,"POOL" )
   CALL closereply (false )
  ELSEIF ((nlevel = 2 ) )
   IF ((strextraparam = "PERSON" ) )
    CALL getalphaselect ("0" )
   ELSEIF ((strextraparam = "PATIENT" ) )
    CALL initreply ("Patient_HELP_2_OF_3" ,"DESCRIPTION" )
    CALL addreply ("Select this line and press [<<Next>>] to continue or [Cancel] to quit" ,"3|3" )
    CALL closereply (false )
   ELSEIF ((strextraparam = "PP_RELATION" ) )
    CALL initreply ("Person_Personnel_Relation_HELP_2_OF_3" ,"DESCRIPTION" )
    CALL addreply ("Select this line and press [<<Next>>] to continue or [Cancel] to quit" ,
     "331|331" )
    CALL closereply (false )
   ELSEIF ((strextraparam = "EP_RELATION" ) )
    CALL initreply ("Encounter_Personnel_Relation_HELP_2_OF_3" ,"DESCRIPTION" )
    CALL addreply ("Select this line and press [<<Next>>] to continue or [Cancel] to quit" ,
     "333|333" )
    CALL closereply (false )
   ELSEIF ((strextraparam = "OR_RELATION" ) )
    CALL initreply ("Order_Relation_HELP_2_OF_3" ,"DESCRIPTION" )
    CALL addreply ("Select this line and press [<<Next>>] to continue or [Cancel] to quit" ,"1|1" )
    CALL closereply (false )
   ELSEIF ((strextraparam = "POOL" ) )
    CALL getalphaselect ("999" )
   ENDIF
  ELSEIF ((nlevel = 3 ) )
   CALL parsearguments (strextraparam ,"|" ,args )
   IF ((args->items[2 ].value = "0" ) )
    SET strname = concat (trim (cnvtupper (args->items[1 ].value ) ) ,"*" )
    SELECT INTO "NL:"
     person_name = p.name_full_formatted ,
     _hidden_par = concat (trim (cnvtstring (p.person_id ,25 ,1 ) ) ,"|" ,"0" )
     FROM (prsnl p )
     WHERE (p.name_last_key = patstring (strname ) )
     AND (trim (p.name_full_formatted ) > " " )
     ORDER BY cnvtupper (p.name_full_formatted )
     HEAD REPORT
      stat = 0 ,
      reply->cnt = 0 ,
      reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
      reply->fieldsize = size (reply->fieldname )
     DETAIL
      reply->cnt +=1 ,
      IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
      ENDIF
      ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
     FOOT REPORT
      stat = alterlist (reply->qual ,reply->cnt )
     WITH maxrow = 1 ,reporthelp ,check
    ;end select
    IF ((reply->cnt = 0 ) )
     CALL helperror ("No personnel names found" )
    ENDIF
   ELSEIF ((args->items[2 ].value = "3" ) )
    CALL initreply ("PATIENT" ,"" )
    CALL addreply ("Patient" ,"3|3" )
    CALL closereply (false )
   ELSEIF ((args->items[2 ].value = "331" ) )
    CALL getcodesetcki (331 ,"Person_Personnel Relation" ," " ," " ,"331" )
   ELSEIF ((args->items[2 ].value = "333" ) )
    CALL getcodesetcki (333 ,"Encounter_Personnel Relation" ," " ," " ,"333" )
   ELSEIF ((args->items[2 ].value = "1" ) )
    CALL initreply ("ORDER_RELATION" ,"" )
    CALL addreply ("Consult Physician" ,"1|1" )
    CALL addreply ("Order Physician" ,"2|1" )
    CALL closereply (false )
   ELSEIF ((args->items[2 ].value = "999" ) )
    FREE RECORD retrievepoolrequest
    RECORD retrievepoolrequest (
      1 pool_search_value = vc
      1 member_prsnl_id = f8
      1 prsnl_id = f8
      1 load_member_list_ind = i2
      1 load_member_names_ind = i2
      1 load_org_list_ind = i2
      1 load_org_name_ind = i2
      1 load_org_rules_ind = i2
      1 pool_retrieval_rules
        2 retrieve_avail_fwd_pool_ind = i2
        2 retrieve_avail_pool_to_view_ind = i2
    )
    FREE RECORD retrievepoolreply
    RECORD retrievepoolreply (
      1 pool_list [* ]
        2 pool_uid = vc
        2 pool_name = vc
        2 pool_description = vc
        2 pool_member_list [* ]
          3 member_prsnl_id = f8
          3 member_prsnl_name = vc
        2 org_list [* ]
          3 org_id = f8
          3 org_name = vc
        2 team_leader_prsnl_id = f8
        2 team_leader_prsnl_name = vc
        2 pool_rules
          3 can_add_from_outside_org = i2
          3 can_forward_from_outside_org = i2
          3 can_self_assign_leader = i2
          3 can_self_enroll = i2
        2 pool_id = f8
        2 version = i4
      1 status_data
        2 status = c1
        2 subeventstatus [1 ]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET retrievepoolrequest->pool_search_value = concat (trim (cnvtupper (args->items[1 ].value ) ) ,
     "*" )
    SET stat = tdbexecute (600005 ,967100 ,967553 ,"REC" ,retrievepoolrequest ,"REC" ,
     retrievepoolreply2 ,1 )
    SET isizeofretrievepool = 0
    SET isizeofretrievepool = size (retrievepoolreply2->pool_list ,5 )
    IF (isizeofretrievepool )
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
     SET stat = alterlist (valdrecrequest->receiver_list ,isizeofretrievepool )
     SET i = 1
     FOR (i = 1 TO isizeofretrievepool )
      SET valdrecrequest->receiver_list[i ].personnel_group_id = retrievepoolreply2->pool_list[i ].
      pool_id
     ENDFOR
     SET msg_cd = 0.00
     SET stat = uar_get_meaning_by_codeset (3404 ,"MESSAGES" ,1 ,msg_cd )
     SET valdrecrequest->category_type_cd = msg_cd
     SET stat = tdbexecute (600005 ,967100 ,967582 ,"REC" ,valdrecrequest ,"REC" ,valdrecreply2 ,1 )
     SET isizeofvaldrecreply = 0
     SET isizeofvaldrecreply = size (valdrecreply2->receiver_ind_list ,5 )
     IF (isizeofvaldrecreply )
      RECORD recpool (
        1 cnt = i4
        1 qual [* ]
          2 pool_name = vc
          2 pool_id = f8
          2 pool_desc = vc
      )
      SET i = 0
      SET j = 0
      FOR (i = 1 TO isizeofvaldrecreply )
       FOR (j = 1 TO isizeofretrievepool )
        IF ((valdrecreply2->receiver_ind_list[i ].valid_receiver_ind > 0 )
        AND (valdrecreply2->receiver_ind_list[i ].personnel_group_id = retrievepoolreply2->pool_list[
        j ].pool_id ) )
         SET recpool->cnt +=1
         SET stat = alterlist (recpool->qual ,recpool->cnt )
         SET recpool->qual[recpool->cnt ].pool_name = retrievepoolreply2->pool_list[j ].pool_name
         SET recpool->qual[recpool->cnt ].pool_desc = retrievepoolreply2->pool_list[j ].
         pool_description
         SET recpool->qual[recpool->cnt ].pool_id = valdrecreply2->receiver_ind_list[i ].
         personnel_group_id
        ENDIF
       ENDFOR
      ENDFOR
      IF (recpool->cnt )
       SET d1seq = 0
       SELECT INTO "nl:"
        pool_name = substring (1 ,1024 ,recpool->qual[d1seq ].pool_name ) ,
        _hidden = concat (trim (cnvtstring (recpool->qual[d1seq ].pool_id ,25 ,1 ) ) ,"|999" ) ,
        pool_description = substring (1 ,1024 ,recpool->qual[d1seq ].pool_desc )
        FROM (dummyt d1 WITH seq = value (recpool->cnt ) )
        PLAN (d1
         WHERE assign (d1seq ,d1.seq ) )
        ORDER BY cnvtupper (recpool->qual[d1seq ].pool_name )
        HEAD REPORT
         stat = 0 ,
         reply->cnt = 0 ,
         reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
         reply->fieldsize = size (reply->fieldname )
        DETAIL
         reply->cnt +=1 ,
         stat = alterlist (reply->qual ,reply->cnt ) ,
         IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
         ENDIF
         ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
        FOOT REPORT
         stat = alterlist (reply->qual ,reply->cnt )
        WITH reporthelp ,check
       ;end select
      ELSE
       CALL helperror ("No Valid Pool found." )
      ENDIF
     ENDIF
    ENDIF
    IF ((reply->cnt = 0 ) )
     CALL helperror ("No Valid Pool found" )
    ENDIF
   ELSE
    CALL helperror (concat ("Invalid parameter - " ,strextraparameter ) )
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  (getcodesetcki (ncodeset =i2 ,strcol1header =vc ,strcol2header =vc ,stradditionaltext =
  vc ,strextraparam =vc ) =null )
  DECLARE sql = vc WITH private
  DECLARE sqlreply = vc WITH private
  DECLARE sqlselect = vc WITH private
  DECLARE strcol1hdr = vc
  DECLARE strcol2hdr = vc
  DECLARE strextra = vc
  RECORD extraargs (
    1 count = i2
    1 items [25 ]
      2 value = c1024
  )
  IF ((strextraparam > " " ) )
   SET strextra = concat ("|" ,strextraparam )
  ELSE
   SET strextra = ""
  ENDIF
  IF ((strcol1header > "" ) )
   SET strcol1hdr = strcol1header
   SET strcol2hdr = strcol1header
  ELSE
   SET strcol1hdr = fillstring (150 ,"" )
   CALL getcodesetname (ncodeset ,strcol1hdr )
   SET strcol2hdr = "DESCRIPTION"
  ENDIF
  SET extraargs->count = 0
  CALL parsearguments (stradditionaltext ,"|" ,extraargs )
  CALL initreply (strcol1hdr ,strcol2hdr )
  IF ((trim (strextraparam ) = "with drug class as" ) )
   CALL getdrugcategoryname ("\1st" )
  ELSEIF ((trim (strextraparam ) = "that contain" ) )
   CALL getmltmcombdrug ("\1stMCD" )
  ELSE
   SELECT INTO "NL:"
    display = format (extraargs->items[d.seq ].value ,"########################################" ) ,
    _hidden_par = substring (1 ,1024 ,concat (extraargs->items[d.seq ].value ,strextra ) ) ,
    description = format (" " ,"############################################################" )
    FROM (dummyt d WITH seq = value (extraargs->count ) )
    DETAIL
     CALL addreply (display ,_hidden_par )
   ;end select
   SET sqlselect = concat ('select into "nl:" ' ,"	display = cv.display, " ,
    '	_HIDDEN_PAR = if (cv.cki > " ") ' ,"		SubString(1, 256, ConCat(Trim(cv.cki), strExtra))" ,
    "		else" ,"			SubString(1, 256, ConCat(trim(CnvtString(cv.code_value,25,1)), strExtra))" ,
    "		endif," ,"	description =  cv.description /**/" ,"from code_value cv /**/" ,
    "where cv.code_set = " ,cnvtstring (ncodeset ) ,"	and cv.active_ind = 1 /**/" )
   SET sqlreply = concat ("order CnvtUpper(cv.display) " ,"head report " ,"	stat = 0 " ,"detail " ,
    "	tReply->cnt = tReply->cnt + 1 " ,"	stat = alterlist(tReply->qual,tReply->cnt) " ,
    "	tReply->qual[tReply->cnt].display = display " ,
    "	tReply->qual[tReply->cnt].hidden = _HIDDEN_PAR " ,"foot report " ,
    "	stat = alterlist(tReply->qual,tReply->cnt) " ,"with maxrow = 1, reporthelp, check GO " )
   SET sql = concat (sqlselect ,sqlreply )
   CALL parser (sql ,1 )
   CALL closereply (false )
  ENDIF
  IF ((reply->cnt = 0 ) )
   CALL helperror ("No code values found" )
  ENDIF
 END ;Subroutine
 SUBROUTINE  getdrugcategoryname (strparameter )
  FREE SET internal
  RECORD internal (
    1 data [* ]
      2 cat_id = f8
      2 cat_name = vc
      2 cls_cnt = i4
      2 cls [* ]
        3 cls_id = f8
        3 cls_name = vc
        3 sub_cls_cnt = i4
        3 sub_cls [* ]
          4 sub_cls_id = f8
          4 sub_cls_name = vc
  )
  DECLARE intmultumflag = i2 WITH public ,noconstant (0 )
  SELECT INTO "nl:"
   FROM (dba_tables d )
   WHERE (d.table_name = "MLTM_CATEGORY_DRUG_XREF" )
   AND (d.owner = "V500" )
   WITH nocounter
  ;end select
  IF ((curqual = 1 ) )
   SET intmultumflag = 2
  ELSE
   SELECT INTO "nl:"
    FROM (dba_tables d )
    WHERE (d.table_name = "MULTUM_CATEGORY_DRUG_XREF" )
    AND (d.owner = "V500" )
    WITH nocounter
   ;end select
   IF ((curqual = 1 ) )
    SET intmultumflag = 1
   ELSE
    SELECT
     FROM (dba_tables d )
     WHERE (d.table_name = "MULTUM_CATEGORY_DRUG_XREF" )
     AND (d.owner = "V500_REF" )
     WITH nocounter
    ;end select
    IF ((curqual = 1 ) )
     SET intmultumflag = 0
    ENDIF
   ENDIF
  ENDIF
  IF ((findstring ("\1st" ,strparameter ) > 0 ) )
   IF ((intmultumflag = 1 ) )
    SELECT INTO "nl:"
     class_1_of_3 = substring (1 ,60 ,m.category_name ) ,
     _hidden_par = substring (1 ,300 ,concat (trim (m.category_name ,3 ) ,"\" ,trim (cnvtstring (m
         .multum_category_id ,25 ,1 ) ) ) )
     FROM (multum_drug_categories m )
     WHERE NOT (EXISTS (
     (SELECT
      mx.sub_category_id
      FROM (multum_category_sub_xref mx )
      WHERE (mx.sub_category_id = m.multum_category_id ) ) ) )
     ORDER BY cnvtupper (m.category_name )
     HEAD REPORT
      stat = 0 ,
      reply->cnt = 0 ,
      reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
      reply->fieldsize = size (reply->fieldname )
     DETAIL
      reply->cnt +=1 ,
      IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
      ENDIF
      ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
     FOOT REPORT
      stat = alterlist (reply->qual ,reply->cnt )
     WITH nocounter
    ;end select
   ELSEIF ((intmultumflag = 0 ) )
    SELECT INTO "nl:"
     class_1_of_3 = substring (1 ,60 ,m.category_name ) ,
     _hidden_par = substring (1 ,300 ,concat (trim (m.category_name ,3 ) ,"\" ,trim (cnvtstring (m
         .multum_category_id ,25 ,1 ) ) ) )
     FROM (v500_ref.multum_drug_categories m )
     WHERE NOT (EXISTS (
     (SELECT
      mx.sub_category_id
      FROM (v500_ref.multum_category_sub_xref mx )
      WHERE (mx.sub_category_id = m.multum_category_id ) ) ) )
     ORDER BY cnvtupper (m.category_name )
     HEAD REPORT
      stat = 0 ,
      reply->cnt = 0 ,
      reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
      reply->fieldsize = size (reply->fieldname )
     DETAIL
      reply->cnt +=1 ,
      IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
      ENDIF
      ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
     FOOT REPORT
      stat = alterlist (reply->qual ,reply->cnt )
     WITH nocounter
    ;end select
   ELSEIF ((intmultumflag = 2 ) )
    SELECT INTO "nl:"
     class_1_of_3 = substring (1 ,60 ,m.category_name ) ,
     _hidden_par = substring (1 ,300 ,concat (trim (m.category_name ,3 ) ,"\" ,trim (cnvtstring (m
         .multum_category_id ,25 ,1 ) ) ) )
     FROM (mltm_drug_categories m )
     WHERE NOT (EXISTS (
     (SELECT
      mx.sub_category_id
      FROM (mltm_category_sub_xref mx )
      WHERE (mx.sub_category_id = m.multum_category_id ) ) ) )
     ORDER BY cnvtupper (m.category_name )
     HEAD REPORT
      stat = 0 ,
      reply->cnt = 0 ,
      reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
      reply->fieldsize = size (reply->fieldname )
     DETAIL
      reply->cnt +=1 ,
      IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
      ENDIF
      ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
     FOOT REPORT
      stat = alterlist (reply->qual ,reply->cnt )
     WITH nocounter
    ;end select
   ENDIF
  ELSEIF ((findstring ("\2nd" ,strparameter ) > 0 ) )
   DECLARE isyn_1 = i2 WITH public ,noconstant (0 )
   SET isyn_1 = findstring ("\" ,trim (par1 ,3 ) ,1 )
   DECLARE strcategoryname = vc WITH public ,noconstant (" " )
   SET strcategoryname = substring (1 ,(isyn_1 - 1 ) ,trim (par1 ,3 ) )
   DECLARE dcategorycode = f8 WITH public ,noconstant (0.0 )
   SET dcategorycode = cnvtreal (substring ((isyn_1 + 1 ) ,(size (trim (par1 ,3 ) ) - isyn_1 ) ,trim
     (par1 ,3 ) ) )
   IF ((intmultumflag = 1 ) )
    SELECT INTO "nl:"
     m.* ,
     mx_hit = decode (mx.seq ,1 ,0 ) ,
     mx2_hit = decode (mx2.seq ,1 ,0 )
     FROM (multum_drug_categories m ),
      (multum_drug_categories m2 ),
      (multum_drug_categories m3 ),
      (multum_category_sub_xref mx ),
      (multum_category_sub_xref mx2 ),
      (dummyt d1 ),
      (dummyt d2 )
     PLAN (m
      WHERE (m.multum_category_id = dcategorycode ) )
      JOIN (d1 )
      JOIN (mx
      WHERE (m.multum_category_id = mx.multum_category_id ) )
      JOIN (m2
      WHERE (mx.sub_category_id = m2.multum_category_id ) )
      JOIN (d2 )
      JOIN (mx2
      WHERE (m2.multum_category_id = mx2.multum_category_id ) )
      JOIN (m3
      WHERE (mx2.sub_category_id = m3.multum_category_id ) )
     ORDER BY m.category_name ,
      m.multum_category_id ,
      m2.multum_category_id ,
      m3.multum_category_id
     HEAD REPORT
      icnt1 = 0 ,
      icnt2 = 0 ,
      icnt3 = 0
     HEAD m.multum_category_id
      icnt1 +=1 ,stat = alterlist (internal->data ,icnt1 ) ,internal->data[icnt1 ].cat_id = m
      .multum_category_id ,internal->data[icnt1 ].cat_name = m.category_name ,icnt2 = 0
     HEAD m2.multum_category_id
      IF ((mx_hit = 1 ) ) icnt2 +=1 ,stat = alterlist (internal->data[icnt1 ].cls ,icnt2 ) ,internal
       ->data[icnt1 ].cls[icnt2 ].cls_id = m2.multum_category_id ,internal->data[icnt1 ].cls[icnt2 ].
       cls_name = m2.category_name ,
       IF ((icnt2 > 0 ) ) internal->data[icnt1 ].cls_cnt = icnt2
       ENDIF
      ENDIF
      ,icnt3 = 0
     HEAD m3.multum_category_id
      IF ((mx2_hit = 1 ) ) icnt3 +=1 ,stat = alterlist (internal->data[icnt1 ].cls[icnt2 ].sub_cls ,
        icnt3 ) ,internal->data[icnt1 ].cls[icnt2 ].sub_cls[icnt3 ].sub_cls_id = m3
       .multum_category_id ,internal->data[icnt1 ].cls[icnt2 ].sub_cls[icnt3 ].sub_cls_name = m3
       .category_name ,
       IF ((icnt3 > 0 ) ) internal->data[icnt1 ].cls[icnt2 ].sub_cls_cnt = icnt3
       ENDIF
      ENDIF
     DETAIL
      x = 1
     FOOT  m2.multum_category_id
      icnt3 = 0
     FOOT  m.multum_category_id
      icnt2 = 0
     WITH nocounter ,outerjoin = d1 ,outerjoin = d2
    ;end select
   ELSEIF ((intmultumflag = 0 ) )
    SELECT INTO "nl:"
     m.* ,
     mx_hit = decode (mx.seq ,1 ,0 ) ,
     mx2_hit = decode (mx2.seq ,1 ,0 )
     FROM (v500_ref.multum_drug_categories m ),
      (v500_ref.multum_drug_categories m2 ),
      (v500_ref.multum_drug_categories m3 ),
      (v500_ref.multum_category_sub_xref mx ),
      (v500_ref.multum_category_sub_xref mx2 ),
      (dummyt d1 ),
      (dummyt d2 )
     PLAN (m
      WHERE (m.multum_category_id = dcategorycode ) )
      JOIN (d1 )
      JOIN (mx
      WHERE (m.multum_category_id = mx.multum_category_id ) )
      JOIN (m2
      WHERE (mx.sub_category_id = m2.multum_category_id ) )
      JOIN (d2 )
      JOIN (mx2
      WHERE (m2.multum_category_id = mx2.multum_category_id ) )
      JOIN (m3
      WHERE (mx2.sub_category_id = m3.multum_category_id ) )
     ORDER BY m.category_name ,
      m.multum_category_id ,
      m2.multum_category_id ,
      m3.multum_category_id
     HEAD REPORT
      icnt1 = 0 ,
      icnt2 = 0 ,
      icnt3 = 0
     HEAD m.multum_category_id
      icnt1 +=1 ,stat = alterlist (internal->data ,icnt1 ) ,internal->data[icnt1 ].cat_id = m
      .multum_category_id ,internal->data[icnt1 ].cat_name = m.category_name ,icnt2 = 0
     HEAD m2.multum_category_id
      IF ((mx_hit = 1 ) ) icnt2 +=1 ,stat = alterlist (internal->data[icnt1 ].cls ,icnt2 ) ,internal
       ->data[icnt1 ].cls[icnt2 ].cls_id = m2.multum_category_id ,internal->data[icnt1 ].cls[icnt2 ].
       cls_name = m2.category_name ,
       IF ((icnt2 > 0 ) ) internal->data[icnt1 ].cls_cnt = icnt2
       ENDIF
      ENDIF
      ,icnt3 = 0
     HEAD m3.multum_category_id
      IF ((mx2_hit = 1 ) ) icnt3 +=1 ,stat = alterlist (internal->data[icnt1 ].cls[icnt2 ].sub_cls ,
        icnt3 ) ,internal->data[icnt1 ].cls[icnt2 ].sub_cls[icnt3 ].sub_cls_id = m3
       .multum_category_id ,internal->data[icnt1 ].cls[icnt2 ].sub_cls[icnt3 ].sub_cls_name = m3
       .category_name ,
       IF ((icnt3 > 0 ) ) internal->data[icnt1 ].cls[icnt2 ].sub_cls_cnt = icnt3
       ENDIF
      ENDIF
     DETAIL
      x = 1
     FOOT  m2.multum_category_id
      icnt3 = 0
     FOOT  m.multum_category_id
      icnt2 = 0
     WITH nocounter ,outerjoin = d1 ,outerjoin = d2
    ;end select
   ELSEIF ((intmultumflag = 2 ) )
    SELECT INTO "nl:"
     m.* ,
     mx_hit = decode (mx.seq ,1 ,0 ) ,
     mx2_hit = decode (mx2.seq ,1 ,0 )
     FROM (mltm_drug_categories m ),
      (mltm_drug_categories m2 ),
      (mltm_drug_categories m3 ),
      (mltm_category_sub_xref mx ),
      (mltm_category_sub_xref mx2 ),
      (dummyt d1 ),
      (dummyt d2 )
     PLAN (m
      WHERE (m.multum_category_id = dcategorycode ) )
      JOIN (d1 )
      JOIN (mx
      WHERE (m.multum_category_id = mx.multum_category_id ) )
      JOIN (m2
      WHERE (mx.sub_category_id = m2.multum_category_id ) )
      JOIN (d2 )
      JOIN (mx2
      WHERE (m2.multum_category_id = mx2.multum_category_id ) )
      JOIN (m3
      WHERE (mx2.sub_category_id = m3.multum_category_id ) )
     ORDER BY m.category_name ,
      m.multum_category_id ,
      m2.multum_category_id ,
      m3.multum_category_id
     HEAD REPORT
      icnt1 = 0 ,
      icnt2 = 0 ,
      icnt3 = 0
     HEAD m.multum_category_id
      icnt1 +=1 ,stat = alterlist (internal->data ,icnt1 ) ,internal->data[icnt1 ].cat_id = m
      .multum_category_id ,internal->data[icnt1 ].cat_name = m.category_name ,icnt2 = 0
     HEAD m2.multum_category_id
      IF ((mx_hit = 1 ) ) icnt2 +=1 ,stat = alterlist (internal->data[icnt1 ].cls ,icnt2 ) ,internal
       ->data[icnt1 ].cls[icnt2 ].cls_id = m2.multum_category_id ,internal->data[icnt1 ].cls[icnt2 ].
       cls_name = m2.category_name ,
       IF ((icnt2 > 0 ) ) internal->data[icnt1 ].cls_cnt = icnt2
       ENDIF
      ENDIF
      ,icnt3 = 0
     HEAD m3.multum_category_id
      IF ((mx2_hit = 1 ) ) icnt3 +=1 ,stat = alterlist (internal->data[icnt1 ].cls[icnt2 ].sub_cls ,
        icnt3 ) ,internal->data[icnt1 ].cls[icnt2 ].sub_cls[icnt3 ].sub_cls_id = m3
       .multum_category_id ,internal->data[icnt1 ].cls[icnt2 ].sub_cls[icnt3 ].sub_cls_name = m3
       .category_name ,
       IF ((icnt3 > 0 ) ) internal->data[icnt1 ].cls[icnt2 ].sub_cls_cnt = icnt3
       ENDIF
      ENDIF
     DETAIL
      x = 1
     FOOT  m2.multum_category_id
      icnt3 = 0
     FOOT  m.multum_category_id
      icnt2 = 0
     WITH nocounter ,outerjoin = d1 ,outerjoin = d2
    ;end select
   ENDIF
   IF ((internal->data[1 ].cls_cnt > 0 ) )
    SELECT DISTINCT INTO "nl:"
     class_2_of_3 =
     IF ((t.seq = 1 ) ) substring (1 ,1024 ,concat ("*** " ,strcategoryname ) )
     ELSE substring (1 ,1024 ,concat (trim (strcategoryname ) ," -> " ,internal->data[1 ].cls[d1.seq
        ].cls_name ) )
     ENDIF
     ,_hidden_par =
     IF ((t.seq = 1 ) ) substring (1 ,1024 ,concat (trim (strcategoryname ) ,"\" ,"*" ,trim (
         cnvtstring (dcategorycode ,25 ,1 ) ) ) )
     ELSE substring (1 ,1024 ,concat (trim (strcategoryname ) ," -> " ,internal->data[1 ].cls[d1.seq
        ].cls_name ,"\" ,trim (cnvtstring (internal->data[1 ].cls[d1.seq ].cls_id ,25 ,1 ) ) ,"\" ,
        trim (cnvtstring (dcategorycode ,25 ,1 ) ) ) )
     ENDIF
     FROM (dummyt t WITH seq = 2 ),
      (dummyt d1 WITH seq = value (internal->data[1 ].cls_cnt ) )
     PLAN (t )
      JOIN (d1
      WHERE (d1.seq > 0 ) )
     ORDER BY class_2_of_3
     HEAD REPORT
      stat = 0 ,
      reply->cnt = 0 ,
      reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
      reply->fieldsize = size (reply->fieldname )
     DETAIL
      reply->cnt +=1 ,
      IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
      ENDIF
      ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
     FOOT REPORT
      stat = alterlist (reply->qual ,reply->cnt )
     WITH maxrow = 1 ,reporthelp ,check ,memsort
    ;end select
   ELSE
    SELECT INTO "nl:"
     class_2_of_3 = substring (1 ,1024 ,concat ("*** " ,strcategoryname ) ) ,
     _hidden_par = substring (1 ,1024 ,concat (trim (strcategoryname ) ,"\*" ,trim (cnvtstring (
         dcategorycode ,25 ,1 ) ) ) )
     FROM (dummyt t WITH seq = 1 )
     ORDER BY class_2_of_3
     HEAD REPORT
      stat = 0 ,
      reply->cnt = 0 ,
      reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
      reply->fieldsize = size (reply->fieldname )
     DETAIL
      reply->cnt +=1 ,
      IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
      ENDIF
      ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
     FOOT REPORT
      stat = alterlist (reply->qual ,reply->cnt )
     WITH maxrow = 1 ,reporthelp ,check ,memsort
    ;end select
   ENDIF
  ELSEIF ((findstring ("\3rd" ,strparameter ) > 0 ) )
   DECLARE isyn_1 = i2 WITH public ,noconstant (0 )
   SET isyn_1 = findstring ("\" ,trim (par1 ,3 ) ,1 )
   DECLARE isyn_2 = i2 WITH public ,noconstant (0 )
   SET isyn_2 = findstring ("\" ,trim (par1 ,3 ) ,(isyn_1 + 1 ) )
   DECLARE dchildcategoryid = f8 WITH public ,noconstant (0.0 )
   DECLARE dparentcategoryid = f8 WITH public ,noconstant (0.0 )
   DECLARE strcategoryid = vc WITH public ,noconstant (" " )
   DECLARE isyn_star = i2 WITH public ,noconstant (0 )
   SET isyn_star = findstring ("*" ,trim (par1 ,3 ) ,1 )
   DECLARE strcategoryname = vc WITH public ,noconstant (" " )
   SET strcategoryname = substring (1 ,(isyn_1 - 1 ) ,trim (par1 ,3 ) )
   IF ((isyn_2 > 0 ) )
    IF ((isyn_star = 0 ) )
     SET dchildcategoryid = cnvtreal (substring ((isyn_1 + 1 ) ,((isyn_2 - isyn_1 ) - 1 ) ,trim (
        par1 ,3 ) ) )
     SET dparentcategoryid = cnvtreal (substring ((isyn_2 + 1 ) ,(size (trim (par1 ,3 ) ) - isyn_2 )
       ,trim (par1 ,3 ) ) )
    ELSE
     SET dchildcategoryid = 0
     SET dparentcategoryid = 0
     SET strcategoryid = substring ((isyn_star + 1 ) ,(size (trim (par1 ,3 ) ) - isyn_star ) ,trim (
       par1 ,3 ) )
    ENDIF
   ELSE
    SET strcategoryid = substring ((isyn_star + 1 ) ,(size (trim (par1 ,3 ) ) - isyn_star ) ,trim (
      par1 ,3 ) )
   ENDIF
   IF ((intmultumflag = 1 ) )
    SELECT INTO "nl:"
     m.* ,
     mx_hit = decode (mx.seq ,1 ,0 ) ,
     mx2_hit = decode (mx2.seq ,1 ,0 )
     FROM (multum_drug_categories m ),
      (multum_drug_categories m2 ),
      (multum_drug_categories m3 ),
      (multum_category_sub_xref mx ),
      (multum_category_sub_xref mx2 ),
      (dummyt d1 ),
      (dummyt d2 )
     PLAN (m
      WHERE (m.multum_category_id = dparentcategoryid ) )
      JOIN (d1 )
      JOIN (mx
      WHERE (m.multum_category_id = mx.multum_category_id ) )
      JOIN (m2
      WHERE (m2.multum_category_id = dchildcategoryid )
      AND (mx.sub_category_id = m2.multum_category_id ) )
      JOIN (d2 )
      JOIN (mx2
      WHERE (m2.multum_category_id = mx2.multum_category_id ) )
      JOIN (m3
      WHERE (mx2.sub_category_id = m3.multum_category_id ) )
     ORDER BY m.category_name ,
      m.multum_category_id ,
      m2.multum_category_id ,
      m3.multum_category_id
     HEAD REPORT
      icnt1 = 0 ,
      icnt2 = 0 ,
      icnt3 = 0
     HEAD m.multum_category_id
      icnt1 +=1 ,stat = alterlist (internal->data ,icnt1 ) ,internal->data[icnt1 ].cat_id = m
      .multum_category_id ,internal->data[icnt1 ].cat_name = m.category_name ,icnt2 = 0
     HEAD m2.multum_category_id
      IF ((mx_hit = 1 ) ) icnt2 +=1 ,stat = alterlist (internal->data[icnt1 ].cls ,icnt2 ) ,internal
       ->data[icnt1 ].cls[icnt2 ].cls_id = m2.multum_category_id ,internal->data[icnt1 ].cls[icnt2 ].
       cls_name = m2.category_name ,
       IF ((icnt2 > 0 ) ) internal->data[icnt1 ].cls_cnt = icnt2
       ENDIF
      ENDIF
      ,icnt3 = 0
     HEAD m3.multum_category_id
      IF ((mx2_hit = 1 ) ) icnt3 +=1 ,stat = alterlist (internal->data[icnt1 ].cls[icnt2 ].sub_cls ,
        icnt3 ) ,internal->data[icnt1 ].cls[icnt2 ].sub_cls[icnt3 ].sub_cls_id = m3
       .multum_category_id ,internal->data[icnt1 ].cls[icnt2 ].sub_cls[icnt3 ].sub_cls_name = m3
       .category_name ,
       IF ((icnt3 > 0 ) ) internal->data[icnt1 ].cls[icnt2 ].sub_cls_cnt = icnt3
       ENDIF
      ENDIF
     DETAIL
      x = 1
     FOOT  m2.multum_category_id
      icnt3 = 0
     FOOT  m.multum_category_id
      icnt2 = 0
     WITH nocounter ,outerjoin = d1 ,outerjoin = d2
    ;end select
   ELSEIF ((intmultumflag = 0 ) )
    SELECT INTO "nl:"
     m.* ,
     mx_hit = decode (mx.seq ,1 ,0 ) ,
     mx2_hit = decode (mx2.seq ,1 ,0 )
     FROM (v500_ref.multum_drug_categories m ),
      (v500_ref.multum_drug_categories m2 ),
      (v500_ref.multum_drug_categories m3 ),
      (v500_ref.multum_category_sub_xref mx ),
      (v500_ref.multum_category_sub_xref mx2 ),
      (dummyt d1 ),
      (dummyt d2 )
     PLAN (m
      WHERE (m.multum_category_id = dparentcategoryid ) )
      JOIN (d1 )
      JOIN (mx
      WHERE (m.multum_category_id = mx.multum_category_id ) )
      JOIN (m2
      WHERE (m2.multum_category_id = dchildcategoryid )
      AND (mx.sub_category_id = m2.multum_category_id ) )
      JOIN (d2 )
      JOIN (mx2
      WHERE (m2.multum_category_id = mx2.multum_category_id ) )
      JOIN (m3
      WHERE (mx2.sub_category_id = m3.multum_category_id ) )
     ORDER BY m.category_name ,
      m.multum_category_id ,
      m2.multum_category_id ,
      m3.multum_category_id
     HEAD REPORT
      icnt1 = 0 ,
      icnt2 = 0 ,
      icnt3 = 0
     HEAD m.multum_category_id
      icnt1 +=1 ,stat = alterlist (internal->data ,icnt1 ) ,internal->data[icnt1 ].cat_id = m
      .multum_category_id ,internal->data[icnt1 ].cat_name = m.category_name ,icnt2 = 0
     HEAD m2.multum_category_id
      IF ((mx_hit = 1 ) ) icnt2 +=1 ,stat = alterlist (internal->data[icnt1 ].cls ,icnt2 ) ,internal
       ->data[icnt1 ].cls[icnt2 ].cls_id = m2.multum_category_id ,internal->data[icnt1 ].cls[icnt2 ].
       cls_name = m2.category_name ,
       IF ((icnt2 > 0 ) ) internal->data[icnt1 ].cls_cnt = icnt2
       ENDIF
      ENDIF
      ,icnt3 = 0
     HEAD m3.multum_category_id
      IF ((mx2_hit = 1 ) ) icnt3 +=1 ,stat = alterlist (internal->data[icnt1 ].cls[icnt2 ].sub_cls ,
        icnt3 ) ,internal->data[icnt1 ].cls[icnt2 ].sub_cls[icnt3 ].sub_cls_id = m3
       .multum_category_id ,internal->data[icnt1 ].cls[icnt2 ].sub_cls[icnt3 ].sub_cls_name = m3
       .category_name ,
       IF ((icnt3 > 0 ) ) internal->data[icnt1 ].cls[icnt2 ].sub_cls_cnt = icnt3
       ENDIF
      ENDIF
     DETAIL
      x = 1
     FOOT  m2.multum_category_id
      icnt3 = 0
     FOOT  m.multum_category_id
      icnt2 = 0
     WITH nocounter ,outerjoin = d1 ,outerjoin = d2
    ;end select
   ELSEIF ((intmultumflag = 2 ) )
    SELECT INTO "nl:"
     m.* ,
     mx_hit = decode (mx.seq ,1 ,0 ) ,
     mx2_hit = decode (mx2.seq ,1 ,0 )
     FROM (mltm_drug_categories m ),
      (mltm_drug_categories m2 ),
      (mltm_drug_categories m3 ),
      (mltm_category_sub_xref mx ),
      (mltm_category_sub_xref mx2 ),
      (dummyt d1 ),
      (dummyt d2 )
     PLAN (m
      WHERE (m.multum_category_id = dparentcategoryid ) )
      JOIN (d1 )
      JOIN (mx
      WHERE (m.multum_category_id = mx.multum_category_id ) )
      JOIN (m2
      WHERE (m2.multum_category_id = dchildcategoryid )
      AND (mx.sub_category_id = m2.multum_category_id ) )
      JOIN (d2 )
      JOIN (mx2
      WHERE (m2.multum_category_id = mx2.multum_category_id ) )
      JOIN (m3
      WHERE (mx2.sub_category_id = m3.multum_category_id ) )
     ORDER BY m.category_name ,
      m.multum_category_id ,
      m2.multum_category_id ,
      m3.multum_category_id
     HEAD REPORT
      icnt1 = 0 ,
      icnt2 = 0 ,
      icnt3 = 0
     HEAD m.multum_category_id
      icnt1 +=1 ,stat = alterlist (internal->data ,icnt1 ) ,internal->data[icnt1 ].cat_id = m
      .multum_category_id ,internal->data[icnt1 ].cat_name = m.category_name ,icnt2 = 0
     HEAD m2.multum_category_id
      IF ((mx_hit = 1 ) ) icnt2 +=1 ,stat = alterlist (internal->data[icnt1 ].cls ,icnt2 ) ,internal
       ->data[icnt1 ].cls[icnt2 ].cls_id = m2.multum_category_id ,internal->data[icnt1 ].cls[icnt2 ].
       cls_name = m2.category_name ,
       IF ((icnt2 > 0 ) ) internal->data[icnt1 ].cls_cnt = icnt2
       ENDIF
      ENDIF
      ,icnt3 = 0
     HEAD m3.multum_category_id
      IF ((mx2_hit = 1 ) ) icnt3 +=1 ,stat = alterlist (internal->data[icnt1 ].cls[icnt2 ].sub_cls ,
        icnt3 ) ,internal->data[icnt1 ].cls[icnt2 ].sub_cls[icnt3 ].sub_cls_id = m3
       .multum_category_id ,internal->data[icnt1 ].cls[icnt2 ].sub_cls[icnt3 ].sub_cls_name = m3
       .category_name ,
       IF ((icnt3 > 0 ) ) internal->data[icnt1 ].cls[icnt2 ].sub_cls_cnt = icnt3
       ENDIF
      ENDIF
     DETAIL
      x = 1
     FOOT  m2.multum_category_id
      icnt3 = 0
     FOOT  m.multum_category_id
      icnt2 = 0
     WITH nocounter ,outerjoin = d1 ,outerjoin = d2
    ;end select
   ENDIF
   IF ((isyn_star > 0 ) )
    SELECT INTO "nl:"
     class_3_of_3 = substring (1 ,1024 ,concat ("*** " ,strcategoryname ) ) ,
     _hidden_par = substring (1 ,1024 ,concat ("*" ,trim (strcategoryid ,3 ) ) )
     FROM (dummyt t WITH seq = 1 )
     ORDER BY class_3_of_3
     HEAD REPORT
      stat = 0 ,
      reply->cnt = 0 ,
      reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
      reply->fieldsize = size (reply->fieldname )
     DETAIL
      reply->cnt +=1 ,
      IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
      ENDIF
      ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
     FOOT REPORT
      stat = alterlist (reply->qual ,reply->cnt )
     WITH maxrow = 1 ,reporthelp ,check ,memsort
    ;end select
   ELSE
    IF ((internal->data[1 ].cls[1 ].sub_cls_cnt > 0 ) )
     SELECT DISTINCT INTO "nl:"
      class_3_of_3 =
      IF ((t.seq = 1 ) ) substring (1 ,1024 ,concat ("*** " ,strcategoryname ) )
      ELSE substring (1 ,1024 ,concat (trim (strcategoryname ) ," -> " ,internal->data[1 ].cls[1 ].
         sub_cls[d1.seq ].sub_cls_name ) )
      ENDIF
      ,_hidden_par =
      IF ((t.seq = 1 ) ) substring (1 ,1024 ,concat ("*" ,trim (cnvtstring (dchildcategoryid ,25 ,1
           ) ) ,"\" ,trim (cnvtstring (dparentcategoryid ,25 ,1 ) ) ) )
      ELSE substring (1 ,1024 ,trim (cnvtstring (internal->data[1 ].cls[1 ].sub_cls[d1.seq ].
          sub_cls_id ,25 ,1 ) ) )
      ENDIF
      FROM (dummyt t WITH seq = 2 ),
       (dummyt d1 WITH seq = value (internal->data[1 ].cls[1 ].sub_cls_cnt ) )
      PLAN (t )
       JOIN (d1
       WHERE (d1.seq > 0 ) )
      ORDER BY class_3_of_3
      HEAD REPORT
       stat = 0 ,
       reply->cnt = 0 ,
       reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
       reply->fieldsize = size (reply->fieldname )
      DETAIL
       reply->cnt +=1 ,
       IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
       ENDIF
       ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
      FOOT REPORT
       stat = alterlist (reply->qual ,reply->cnt )
      WITH maxrow = 1 ,reporthelp ,check ,memsort
     ;end select
    ELSE
     SELECT INTO "nl:"
      class_3_of_3 = substring (1 ,1024 ,concat ("*** " ,strcategoryname ) ) ,
      _hidden_par = substring (1 ,1024 ,trim (cnvtstring (dchildcategoryid ,25 ,1 ) ) )
      FROM (dummyt t WITH seq = 1 )
      ORDER BY class_3_of_3
      HEAD REPORT
       stat = 0 ,
       reply->cnt = 0 ,
       reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
       reply->fieldsize = size (reply->fieldname )
      DETAIL
       reply->cnt +=1 ,
       IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
       ENDIF
       ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
      FOOT REPORT
       stat = alterlist (reply->qual ,reply->cnt )
      WITH maxrow = 1 ,reporthelp ,check ,memsort
     ;end select
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE  getmltmcombdrug (strparameter )
  IF ((findstring ("\1stMCD" ,strparameter ) > 0 ) )
   CALL initreply ("Multum Combination Drug 1_OF_3" ,"DESCRIPTION" )
   CALL addreply ("Select this line and press [<<Next>>] to continue or [Cancel] to quit" ,"\1stMCD"
    )
   CALL closereply (false )
  ELSEIF ((findstring ("\2ndMCD" ,strparameter ) > 0 ) )
   CALL initreply ("Multum Combination Drug 2_OF_3" ,"DESCRIPTION" )
   CALL addreply ("Select this line and press [<<Next>>] to continue or [Cancel] to quit" ,"\2ndMCD"
    )
   CALL closereply (false )
  ELSEIF ((findstring ("\3rdMCD" ,strparameter ) > 0 ) )
   SELECT DISTINCT INTO "NL:"
    primary_mnemonic = occh.primary_mnemonic ,
    _hidden = drug.member_drug_identifier
    FROM (mltm_combination_drug drug ),
     (code_value cvch ),
     (order_catalog occh )
    PLAN (drug
     WHERE (drug.member_drug_identifier > " " ) )
     JOIN (cvch
     WHERE (cvch.code_set = 200 )
     AND (cvch.cki = concat ("MUL.ORD!" ,drug.member_drug_identifier ) )
     AND (cvch.active_ind = 1 )
     AND (cvch.cki > " " )
     AND (cvch.begin_effective_dt_tm <= cnvtdatetime (sysdate ) )
     AND (cvch.end_effective_dt_tm >= cnvtdatetime (sysdate ) ) )
     JOIN (occh
     WHERE (occh.catalog_cd = cvch.code_value ) )
    ORDER BY cnvtupper (occh.primary_mnemonic ) ,
     drug.member_drug_identifier
    HEAD REPORT
     stat = 0 ,
     reply->cnt = 0 ,
     reply->fieldname = concat (reportinfo (1 ) ,"^" ) ,
     reply->fieldsize = size (reply->fieldname )
    DETAIL
     reply->cnt +=1 ,
     IF ((mod (reply->cnt ,50 ) = 1 ) ) stat = alterlist (reply->qual ,(reply->cnt + 50 ) )
     ENDIF
     ,reply->qual[reply->cnt ].result = concat (reportinfo (2 ) ,"^" )
    FOOT REPORT
     stat = alterlist (reply->qual ,reply->cnt )
    WITH maxrow = 1 ,reporthelp ,check
   ;end select
  ENDIF
 END ;Subroutine
END GO
