DROP PROGRAM cov_fnrpt_ed_nedocs_detail :dba GO
CREATE PROGRAM cov_fnrpt_ed_nedocs_detail :dba
 prompt 
	"Output to File/Printer/MINE" = "MINE"                   ;* Enter or select the printer or file name to send this report to.
	, "Report Name" = "ED Dashboard NEDOCS Detail By Hour"
	, "Tracking Group" = 0.000000
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, repName, trackGroupCd, startDate, endDate
 EXECUTE reportrtl
 DECLARE stat = i4 WITH protect ,noconstant (0 )
 DECLARE _createfonts (dummy ) = null WITH protect
 DECLARE _createpens (dummy ) = null WITH protect
 DECLARE layoutquery (dummy ) = null WITH protect
 DECLARE __layoutquery (dummy ) = null WITH protect
 DECLARE pagebreak (dummy ) = null WITH protect
 DECLARE initializereport (dummy ) = null WITH protect
 DECLARE _hreport = h WITH noconstant (0 ) ,protect
 DECLARE _yoffset = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _xoffset = f8 WITH noconstant (0.0 ) ,protect
 RECORD _htmlfileinfo (
   1 file_desc = i4
   1 file_name = vc
   1 file_buf = vc
   1 file_offset = i4
   1 file_dir = i4
 ) WITH protect
 SET _htmlfileinfo->file_desc = 0
 DECLARE _htmlfilestat = i4 WITH noconstant (0 ) ,protect
 DECLARE _bgeneratehtml = i1 WITH noconstant (evaluate (validate (request->output_device ,"N" ) ,
   "MINE" ,1 ,'"MINE"' ,1 ,0 ) ) ,protect
 DECLARE rpt_render = i2 WITH constant (0 ) ,protect
 DECLARE _crlf = vc WITH constant (concat (char (13 ) ,char (10 ) ) ) ,protect
 DECLARE rpt_calcheight = i2 WITH constant (1 ) ,protect
 DECLARE _yshift = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _xshift = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _sendto = vc WITH noconstant ("" ) ,protect
 DECLARE _rpterr = i2 WITH noconstant (0 ) ,protect
 DECLARE _rptstat = i2 WITH noconstant (0 ) ,protect
 DECLARE _oldfont = i4 WITH noconstant (0 ) ,protect
 DECLARE _oldpen = i4 WITH noconstant (0 ) ,protect
 DECLARE _dummyfont = i4 WITH noconstant (0 ) ,protect
 DECLARE _dummypen = i4 WITH noconstant (0 ) ,protect
 DECLARE _fdrawheight = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _rptpage = h WITH noconstant (0 ) ,protect
 DECLARE _diotype = i2 WITH noconstant (8 ) ,protect
 DECLARE _outputtype = i2 WITH noconstant (rpt_postscript ) ,protect
 DECLARE _times140 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times100 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times10b0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times12b0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times14b0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times10b16777215 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen14s0c16711680 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen0s0c0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen14s0c0 = i4 WITH noconstant (0 ) ,protect
 SUBROUTINE  (cclbuildhlink (vcprogname =vc ,vcparams =vc ,nwindow =i2 ,vcdescription =vc ) =vc WITH
  protect )
  DECLARE vcreturn = vc WITH private ,noconstant (vcdescription )
  IF ((_htmlfileinfo->file_desc != 0 ) )
   SET vcreturn = build (^<a href='javascript:CCLLINK("^ ,vcprogname ,'","' ,vcparams ,'",' ,nwindow
    ,")'>" ,vcdescription ,"</a>" )
  ENDIF
  RETURN (vcreturn )
 END ;Subroutine
 SUBROUTINE  (cclbuildapplink (nmode =i2 ,vcappname =vc ,vcparams =vc ,vcdescription =vc ) =vc WITH
  protect )
  DECLARE vcreturn = vc WITH private ,noconstant (vcdescription )
  IF ((_htmlfileinfo->file_desc != 0 ) )
   SET vcreturn = build ("<a href='javascript:APPLINK(" ,nmode ,',"' ,vcappname ,'","' ,vcparams ,
    ^")'>^ ,vcdescription ,"</a>" )
  ENDIF
  RETURN (vcreturn )
 END ;Subroutine
 SUBROUTINE  (cclbuildweblink (vcaddress =vc ,nmode =i2 ,vcdescription =vc ) =vc WITH protect )
  DECLARE vcreturn = vc WITH private ,noconstant (vcdescription )
  IF ((_htmlfileinfo->file_desc != 0 ) )
   IF ((nmode = 1 ) )
    SET vcreturn = build ("<a href='" ,vcaddress ,"'>" ,vcdescription ,"</a>" )
   ELSE
    SET vcreturn = build ("<a href='" ,vcaddress ,"' target='_blank'>" ,vcdescription ,"</a>" )
   ENDIF
  ENDIF
  RETURN (vcreturn )
 END ;Subroutine
 SUBROUTINE  layoutquery (dummy )
  CALL initializereport (0 )
  CALL __layoutquery (0 )
  CALL finalizereport (_sendto )
 END ;Subroutine
 SUBROUTINE  __layoutquery (dummy )
  SELECT INTO "NL:"
   nedocs_starttime = substring (1 ,30 ,rnedocs->list[dtrs1.seq ].starttime ) ,
   nedocs_endtime = substring (1 ,30 ,rnedocs->list[dtrs1.seq ].endtime ) ,
   nedocs_level = substring (1 ,30 ,rnedocs->list[dtrs1.seq ].levelstr ) ,
   nedocs_score = rnedocs->list[dtrs1.seq ].scoreval ,
   nedocs_patient = rnedocs->list[dtrs1.seq ].patcnt ,
   nedocs_bed = rnedocs->list[dtrs1.seq ].bedcnt ,
   nedocs_inpatient = rnedocs->list[dtrs1.seq ].inpatientcnt ,
   nedocs_admit = rnedocs->list[dtrs1.seq ].admitcnt ,
   nedocs_critical = rnedocs->list[dtrs1.seq ].criticalcnt ,
   nedocs_longest_admit = rnedocs->list[dtrs1.seq ].longadmitmin ,
   nedocs_last_bed = rnedocs->list[dtrs1.seq ].lastbedmin ,
   nedocs_scale = substring (1 ,30 ,rnedocs->list[dtrs1.seq ].scale )
   FROM (dummyt d1 ),
    (dummyt dtrs1 WITH seq = value (size (rnedocs->list ,5 ) ) )
   WHERE (1 = 1 )
   HEAD REPORT
    _d0 = nedocs_starttime ,
    _d1 = nedocs_endtime ,
    _d2 = nedocs_level ,
    _d3 = nedocs_score ,
    _d4 = nedocs_patient ,
    _d5 = nedocs_bed ,
    _d6 = nedocs_inpatient ,
    _d7 = nedocs_admit ,
    _d8 = nedocs_critical ,
    _d9 = nedocs_longest_admit ,
    _d10 = nedocs_last_bed ,
    _d11 = nedocs_scale ,
    _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom ) ,
    _fdrawheight = fieldname00 (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight +=fieldname01 (rpt_calcheight )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight +=fieldname02 (rpt_calcheight )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > (rptreport->m_pageheight - rptreport->m_marginbottom ) ) )
     CALL pagebreak (0 )
    ENDIF
    ,dummy_val = fieldname00 (rpt_render ) ,
    _fdrawheight = fieldname01 (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight +=fieldname02 (rpt_calcheight )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > (rptreport->m_pageheight - rptreport->m_marginbottom ) ) )
     CALL pagebreak (0 )
    ENDIF
    ,dummy_val = fieldname01 (rpt_render ) ,
    _fdrawheight = fieldname02 (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > (rptreport->m_pageheight - rptreport->m_marginbottom ) ) )
     CALL pagebreak (0 )
    ENDIF
    ,dummy_val = fieldname02 (rpt_render )
   HEAD PAGE
    IF ((curpage > 1 ) ) dummy_val = pagebreak (0 )
    ENDIF
    ,dummy_val = fieldname03 (rpt_render )
   DETAIL
    _fdrawheight = fieldname04 (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = fieldname04 (rpt_render )
   FOOT REPORT
    _fdrawheight = fieldname05 (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     CALL pagebreak (0 )
    ENDIF
    ,dummy_val = fieldname05 (rpt_render )
   WITH nocounter ,separator = " " ,format
  ;end select
 END ;Subroutine
 SUBROUTINE  (layoutqueryhtml (ndummy =i2 ) =null WITH protect )
  DECLARE rpt_pageofpage = vc WITH noconstant ("Page 1 of 1" ) ,protect
  SELECT INTO "NL:"
   nedocs_starttime = substring (1 ,30 ,rnedocs->list[dtrs1.seq ].starttime ) ,
   nedocs_endtime = substring (1 ,30 ,rnedocs->list[dtrs1.seq ].endtime ) ,
   nedocs_level = substring (1 ,30 ,rnedocs->list[dtrs1.seq ].levelstr ) ,
   nedocs_score = rnedocs->list[dtrs1.seq ].scoreval ,
   nedocs_patient = rnedocs->list[dtrs1.seq ].patcnt ,
   nedocs_bed = rnedocs->list[dtrs1.seq ].bedcnt ,
   nedocs_inpatient = rnedocs->list[dtrs1.seq ].inpatientcnt ,
   nedocs_admit = rnedocs->list[dtrs1.seq ].admitcnt ,
   nedocs_critical = rnedocs->list[dtrs1.seq ].criticalcnt ,
   nedocs_longest_admit = rnedocs->list[dtrs1.seq ].longadmitmin ,
   nedocs_last_bed = rnedocs->list[dtrs1.seq ].lastbedmin ,
   nedocs_scale = substring (1 ,30 ,rnedocs->list[dtrs1.seq ].scale )
   FROM (dummyt d1 ),
    (dummyt dtrs1 WITH seq = value (size (rnedocs->list ,5 ) ) )
   WHERE (1 = 1 )
   HEAD REPORT
    _d0 = nedocs_starttime ,
    _d1 = nedocs_endtime ,
    _d2 = nedocs_level ,
    _d3 = nedocs_score ,
    _d4 = nedocs_patient ,
    _d5 = nedocs_bed ,
    _d6 = nedocs_inpatient ,
    _d7 = nedocs_admit ,
    _d8 = nedocs_critical ,
    _d9 = nedocs_longest_admit ,
    _d10 = nedocs_last_bed ,
    _d11 = nedocs_scale ,
    _htmlfileinfo->file_buf = build2 ("<STYLE>" ,
     "table {border-collapse: collapse; empty-cells: show;  border: 0.000in none #000000;  }" ,
     ".FieldName000 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: solid solid none solid;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 14pt Times;" ," " ," color: #000000;" ," background: #a0ffa0;" ,
     " text-align: center;" ," vertical-align: top;}" ,
     ".FieldName010 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none none solid;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 12pt Times;" ," " ," color: #000000;" ," background: #a0ffa0;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName011 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 12pt Times;" ," " ," color: #000000;" ," background: #a0ffa0;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName018 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none solid none none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 12pt Times;" ," " ," color: #000000;" ," background: #a0ffa0;" ,
     " text-align: right;" ," vertical-align: top;}" ,
     ".FieldName030 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: solid solid solid solid;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 12pt Times;" ," " ," color: #000000;" ," background: #a0ffa0;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName031 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: solid solid solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 12pt Times;" ," " ," color: #000000;" ," background: #a0ffa0;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName040 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none solid solid;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   10pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName041 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   10pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName042 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 10pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,
     ".FieldName042_Condition1 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 10pt Times;" ," " ," color: #ffffff;" ," background: #cc0000;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName042_Condition2 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 10pt Times;" ," " ," color: #ffffff;" ," background: #ff5100;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName042_Condition3 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 10pt Times;" ," " ," color: #ffffff;" ," background: #ff7700;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName042_Condition4 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 10pt Times;" ," " ," color: #000000;" ," background: #ffcc00;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName042_Condition5 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 10pt Times;" ," " ," color: #000000;" ," background: #bdddff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName042_Condition6 { border-width: 0.014in; border-color: #0000ff;" ,
     " border-style: none none solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:  bold 10pt Times;" ," " ," color: #000000;" ," background: #429eff;" ,
     " text-align: left;" ," vertical-align: top;}" ,
     ".FieldName0411 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: none solid solid none;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   10pt Times;" ," " ," color: #000000;" ," " ," text-align: left;" ,
     " vertical-align: top;}" ,".FieldName050 { border-width: 0.014in; border-color: #000000;" ,
     " border-style: solid solid solid solid;" ," padding: 0.000in 0.000in 0.000in 0.000in;" ,
     " font:   14pt Times;" ," " ," color: #000000;" ," " ," text-align: right;" ,
     " vertical-align: top;}" ,"</STYLE>" ) ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    _htmlfileinfo->file_buf = "<table width='100%'><caption>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    _htmlfileinfo->file_buf = build2 ("<colgroup span=21>" ,"<col width=138/>" ,"<col width=129/>" ,
     "<col width=53/>" ,"<col width=2/>" ,"<col width=6/>" ,"<col width=10/>" ,"<col width=4/>" ,
     "<col width=12/>" ,"<col width=7/>" ,"<col width=13/>" ,"<col width=33/>" ,"<col width=8/>" ,
     "<col width=17/>" ,"<col width=4/>" ,"<col width=36/>" ,"<col width=5/>" ,"<col width=21/>" ,
     "<col width=30/>" ,"<col width=33/>" ,"<col width=176/>" ,"<col width=204/>" ,"</colgroup>" ) ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    _htmlfileinfo->file_buf = "<thead>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    dummy_val = fieldname00html (0 ) ,
    dummy_val = fieldname01html (0 ) ,
    dummy_val = fieldname02html (0 ) ,
    dummy_val = fieldname03html (0 ) ,
    _htmlfileinfo->file_buf = "</thead>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    _htmlfileinfo->file_buf = "<tbody>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
   DETAIL
    dummy_val = fieldname04html (0 )
   FOOT REPORT
    _htmlfileinfo->file_buf = "</tbody>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    _htmlfileinfo->file_buf = "<tfoot>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    dummy_val = fieldname05html (0 ) ,
    _htmlfileinfo->file_buf = "</tfoot>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo ) ,
    _htmlfileinfo->file_buf = "</table>" ,
    _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
   WITH nocounter ,separator = " " ,format
  ;end select
 END ;Subroutine
 SUBROUTINE  pagebreak (dummy )
  SET _rptpage = uar_rptendpage (_hreport )
  SET _rptpage = uar_rptstartpage (_hreport )
  SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE  (finalizereport (ssendreport =vc ) =null WITH protect )
  IF (_htmlfileinfo->file_desc )
   SET _htmlfileinfo->file_buf = "</html>"
   SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
   SET _htmlfilestat = cclio ("CLOSE" ,_htmlfileinfo )
  ELSE
   SET _rptpage = uar_rptendpage (_hreport )
   SET _rptstat = uar_rptendreport (_hreport )
   DECLARE sfilename = vc WITH noconstant (trim (ssendreport ) ) ,private
   DECLARE bprint = i2 WITH noconstant (0 ) ,private
   IF ((textlen (sfilename ) > 0 ) )
    SET bprint = checkqueue (sfilename )
    IF (bprint )
     EXECUTE cpm_create_file_name "RPT" ,
     "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile (_hreport ,nullterm (sfilename ) )
   IF (bprint )
    SET spool value (sfilename ) value (ssendreport ) WITH deleted
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant (0 ) ,protect
   DECLARE _errcnt = i2 WITH noconstant (0 ) ,protect
   SET _errorfound = uar_rptfirsterror (_hreport ,rpterror )
   WHILE ((_errorfound = rpt_errorfound )
   AND (_errcnt < 512 ) )
    SET _errcnt +=1
    SET stat = alterlist (rpterrors->errors ,_errcnt )
    SET rpterrors->errors[_errcnt ].m_severity = rpterror->m_severity
    SET rpterrors->errors[_errcnt ].m_text = rpterror->m_text
    SET rpterrors->errors[_errcnt ].m_source = rpterror->m_source
    SET _errorfound = uar_rptnexterror (_hreport ,rpterror )
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport (_hreport )
  ENDIF
 END ;Subroutine
 SUBROUTINE  (fieldname00 (ncalc =i2 ) =f8 WITH protect )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname00abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  (fieldname00abs (ncalc =i2 ,offsetx =f8 ,offsety =f8 ) =f8 WITH protect )
  DECLARE sectionheight = f8 WITH noconstant (0.320000 ) ,private
  DECLARE __reporttitle = vc WITH noconstant (build (output_data->report_data.report_title ,char (0
     ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = bor (bor (rpt_sdtopborder ,rpt_sdleftborder ) ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 7.492
   SET rptsd->m_height = 0.334
   SET _oldfont = uar_rptsetfont (_hreport ,_times14b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__reporttitle )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 7.492 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.492 ) ,offsety ,(offsetx + 7.492 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    7.492 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  (fieldname00html (dummy =i2 ) =null WITH protect )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName000' colspan='21'>" ,output_data
   ->report_data.report_title ,"</td>" ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  (fieldname01 (ncalc =i2 ) =f8 WITH protect )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname01abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  (fieldname01abs (ncalc =i2 ,offsetx =f8 ,offsety =f8 ) =f8 WITH protect )
  DECLARE sectionheight = f8 WITH noconstant (0.320000 ) ,private
  DECLARE __generationuser = vc WITH noconstant (build (output_data->report_data.
    report_generation_name ,char (0 ) ) ) ,protect
  DECLARE __trackgroup = vc WITH noconstant (build (output_data->report_data.track_group_display ,
    char (0 ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 64
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.276 )
   SET rptsd->m_width = 2.217
   SET rptsd->m_height = 0.334
   SET _oldfont = uar_rptsetfont (_hreport ,_times12b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__generationuser )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.767 )
   SET rptsd->m_width = 0.509
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.359 )
   SET rptsd->m_width = 0.409
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.151 )
   SET rptsd->m_width = 0.209
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.742 )
   SET rptsd->m_width = 0.409
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.542 )
   SET rptsd->m_width = 0.201
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.376 )
   SET rptsd->m_width = 0.167
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.201 )
   SET rptsd->m_width = 0.175
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 3.201
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__trackgroup )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 7.492 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.200 ) ,offsety ,(offsetx + 3.200 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.375 ) ,offsety ,(offsetx + 3.375 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.542 ) ,offsety ,(offsetx + 3.542 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.742 ) ,offsety ,(offsetx + 3.742 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.150 ) ,offsety ,(offsetx + 4.150 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.358 ) ,offsety ,(offsetx + 4.358 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.767 ) ,offsety ,(offsetx + 4.767 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.275 ) ,offsety ,(offsetx + 5.275 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.492 ) ,offsety ,(offsetx + 7.492 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    7.492 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  (fieldname01html (dummy =i2 ) =null WITH protect )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName010' colspan='3'>" ,output_data
   ->report_data.track_group_display ,"</td>" ,"<td class='FieldName011' colspan='3'>" ,"" ,"</td>" ,
   "<td class='FieldName011' colspan='2'>" ,"" ,"</td>" ,"<td class='FieldName011' colspan='2'>" ,""
   ,"</td>" ,"<td class='FieldName011' colspan='2'>" ,"" ,"</td>" ,
   "<td class='FieldName011' colspan='2'>" ,"" ,"</td>" ,"<td class='FieldName011' colspan='2'>" ,""
   ,"</td>" ,"<td class='FieldName011' colspan='2'>" ,"" ,"</td>" ,
   "<td class='FieldName018' colspan='3'>" ,output_data->report_data.report_generation_name ,"</td>"
   ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  (fieldname02 (ncalc =i2 ) =f8 WITH protect )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname02abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  (fieldname02abs (ncalc =i2 ,offsetx =f8 ,offsety =f8 ) =f8 WITH protect )
  DECLARE sectionheight = f8 WITH noconstant (0.320000 ) ,private
  DECLARE __generationdate = vc WITH noconstant (build (output_data->report_data.
    report_generation_date ,char (0 ) ) ) ,protect
  DECLARE __reportdate = vc WITH noconstant (build (output_data->report_data.report_date ,char (0 )
    ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 64
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.276 )
   SET rptsd->m_width = 2.217
   SET rptsd->m_height = 0.334
   SET _oldfont = uar_rptsetfont (_hreport ,_times12b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__generationdate )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.767 )
   SET rptsd->m_width = 0.509
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.359 )
   SET rptsd->m_width = 0.409
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.151 )
   SET rptsd->m_width = 0.209
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.742 )
   SET rptsd->m_width = 0.409
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.542 )
   SET rptsd->m_width = 0.201
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.376 )
   SET rptsd->m_width = 0.167
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.225 )
   SET rptsd->m_width = 0.151
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 3.225
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__reportdate )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 7.492 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.225 ) ,offsety ,(offsetx + 3.225 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.375 ) ,offsety ,(offsetx + 3.375 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.542 ) ,offsety ,(offsetx + 3.542 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.742 ) ,offsety ,(offsetx + 3.742 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.150 ) ,offsety ,(offsetx + 4.150 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.358 ) ,offsety ,(offsetx + 4.358 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.767 ) ,offsety ,(offsetx + 4.767 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.275 ) ,offsety ,(offsetx + 5.275 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.492 ) ,offsety ,(offsetx + 7.492 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    7.492 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  (fieldname02html (dummy =i2 ) =null WITH protect )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName010' colspan='4'>" ,output_data
   ->report_data.report_date ,"</td>" ,"<td class='FieldName011' colspan='2'>" ,"" ,"</td>" ,
   "<td class='FieldName011' colspan='2'>" ,"" ,"</td>" ,"<td class='FieldName011' colspan='2'>" ,""
   ,"</td>" ,"<td class='FieldName011' colspan='2'>" ,"" ,"</td>" ,
   "<td class='FieldName011' colspan='2'>" ,"" ,"</td>" ,"<td class='FieldName011' colspan='2'>" ,""
   ,"</td>" ,"<td class='FieldName011' colspan='2'>" ,"" ,"</td>" ,
   "<td class='FieldName018' colspan='3'>" ,output_data->report_data.report_generation_date ,"</td>"
   ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  (fieldname03 (ncalc =i2 ) =f8 WITH protect )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname03abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  (fieldname03abs (ncalc =i2 ,offsetx =f8 ,offsety =f8 ) =f8 WITH protect )
  DECLARE sectionheight = f8 WITH noconstant (0.320000 ) ,private
  DECLARE __scale = vc WITH noconstant (build (rreportlabels->scale ,char (0 ) ) ) ,protect
  DECLARE __lastbed = vc WITH noconstant (build (rreportlabels->lastbed ,char (0 ) ) ) ,protect
  DECLARE __longadmit = vc WITH noconstant (build (rreportlabels->longestadmit ,char (0 ) ) ) ,
  protect
  DECLARE __critical = vc WITH noconstant (build (rreportlabels->critical ,char (0 ) ) ) ,protect
  DECLARE __admit = vc WITH noconstant (build (rreportlabels->admit ,char (0 ) ) ) ,protect
  DECLARE __inpatient = vc WITH noconstant (build (rreportlabels->inpatient ,char (0 ) ) ) ,protect
  DECLARE __bed = vc WITH noconstant (build (rreportlabels->bed ,char (0 ) ) ) ,protect
  DECLARE __patient = vc WITH noconstant (build (rreportlabels->patient ,char (0 ) ) ) ,protect
  DECLARE __score = vc WITH noconstant (build (rreportlabels->score ,char (0 ) ) ) ,protect
  DECLARE __level = vc WITH noconstant (build (rreportlabels->level ,char (0 ) ) ) ,protect
  DECLARE __endinterval = vc WITH noconstant (build (rreportlabels->endinterval ,char (0 ) ) ) ,
  protect
  DECLARE __startinterval = vc WITH noconstant (build (rreportlabels->startinterval ,char (0 ) ) ) ,
  protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 32
   SET rptsd->m_borders = bor (bor (rpt_sdtopborder ,rpt_sdbottomborder ) ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 7.367 )
   SET rptsd->m_width = 0.126
   SET rptsd->m_height = 0.334
   SET _oldfont = uar_rptsetfont (_hreport ,_times12b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__scale )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.609 )
   SET rptsd->m_width = 1.759
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__lastbed )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.984 )
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__longadmit )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.725 )
   SET rptsd->m_width = 0.259
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__critical )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.317 )
   SET rptsd->m_width = 0.409
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__admit )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.075 )
   SET rptsd->m_width = 0.242
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__inpatient )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.609 )
   SET rptsd->m_width = 0.467
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__bed )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.417 )
   SET rptsd->m_width = 0.192
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__patient )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.276 )
   SET rptsd->m_width = 0.142
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__score )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.667 )
   SET rptsd->m_width = 0.609
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__level )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.384 )
   SET rptsd->m_width = 1.284
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__endinterval )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 1.384
   SET rptsd->m_height = 0.334
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (160 ,255 ,160 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__startinterval )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 7.492 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 1.383 ) ,offsety ,(offsetx + 1.383 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 2.667 ) ,offsety ,(offsetx + 2.667 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.275 ) ,offsety ,(offsetx + 3.275 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.417 ) ,offsety ,(offsetx + 3.417 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.608 ) ,offsety ,(offsetx + 3.608 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.075 ) ,offsety ,(offsetx + 4.075 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.317 ) ,offsety ,(offsetx + 4.317 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.725 ) ,offsety ,(offsetx + 4.725 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.983 ) ,offsety ,(offsetx + 4.983 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.608 ) ,offsety ,(offsetx + 5.608 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.367 ) ,offsety ,(offsetx + 7.367 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.492 ) ,offsety ,(offsetx + 7.492 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    7.492 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  (fieldname03html (dummy =i2 ) =null WITH protect )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName030' colspan='1'>" ,
   rreportlabels->startinterval ,"</td>" ,"<td class='FieldName031' colspan='1'>" ,rreportlabels->
   endinterval ,"</td>" ,"<td class='FieldName031' colspan='3'>" ,rreportlabels->level ,"</td>" ,
   "<td class='FieldName031' colspan='2'>" ,rreportlabels->score ,"</td>" ,
   "<td class='FieldName031' colspan='2'>" ,rreportlabels->patient ,"</td>" ,
   "<td class='FieldName031' colspan='2'>" ,rreportlabels->bed ,"</td>" ,
   "<td class='FieldName031' colspan='2'>" ,rreportlabels->inpatient ,"</td>" ,
   "<td class='FieldName031' colspan='2'>" ,rreportlabels->admit ,"</td>" ,
   "<td class='FieldName031' colspan='2'>" ,rreportlabels->critical ,"</td>" ,
   "<td class='FieldName031' colspan='2'>" ,rreportlabels->longestadmit ,"</td>" ,
   "<td class='FieldName031' colspan='1'>" ,rreportlabels->lastbed ,"</td>" ,
   "<td class='FieldName031' colspan='1'>" ,rreportlabels->scale ,"</td>" ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  (fieldname04 (ncalc =i2 ) =f8 WITH protect )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname04abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  (fieldname04abs (ncalc =i2 ,offsetx =f8 ,offsety =f8 ) =f8 WITH protect )
  DECLARE sectionheight = f8 WITH noconstant (0.320000 ) ,private
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 7.367 )
   SET rptsd->m_width = 0.126
   SET rptsd->m_height = 0.334
   SET _oldfont = uar_rptsetfont (_hreport ,_times100 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (nedocs_scale ,char (0 ) ) )
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.609 )
   SET rptsd->m_width = 1.759
   SET rptsd->m_height = 0.334
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (nedocs_last_bed ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.984 )
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.334
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (nedocs_longest_admit ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.725 )
   SET rptsd->m_width = 0.259
   SET rptsd->m_height = 0.334
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (nedocs_critical ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.317 )
   SET rptsd->m_width = 0.409
   SET rptsd->m_height = 0.334
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (nedocs_admit ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.075 )
   SET rptsd->m_width = 0.242
   SET rptsd->m_height = 0.334
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (nedocs_inpatient ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.609 )
   SET rptsd->m_width = 0.467
   SET rptsd->m_height = 0.334
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (nedocs_bed ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.417 )
   SET rptsd->m_width = 0.192
   SET rptsd->m_height = 0.334
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (nedocs_patient ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.276 )
   SET rptsd->m_width = 0.142
   SET rptsd->m_height = 0.334
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (nedocs_score ,char (0 ) ) )
   IF ((nedocs_score > 180 ) )
    SET _pencond = _pen14s0c16711680
    SET _fntcond = _times10b16777215
    SET _rgbcond_backcolor = uar_rptencodecolor (204 ,0 ,0 )
    SET _ncond_backmode = 1
   ELSEIF ((nedocs_score > 140 ) )
    SET _pencond = _pen14s0c16711680
    SET _fntcond = _times10b16777215
    SET _rgbcond_backcolor = uar_rptencodecolor (255 ,81 ,0 )
    SET _ncond_backmode = 1
   ELSEIF ((nedocs_score > 100 ) )
    SET _pencond = _pen14s0c16711680
    SET _fntcond = _times10b16777215
    SET _rgbcond_backcolor = uar_rptencodecolor (255 ,119 ,0 )
    SET _ncond_backmode = 1
   ELSEIF ((nedocs_score > 60 ) )
    SET _pencond = _pen14s0c16711680
    SET _fntcond = _times10b0
    SET _rgbcond_backcolor = uar_rptencodecolor (255 ,204 ,0 )
    SET _ncond_backmode = 1
   ELSEIF ((nedocs_score > 20 ) )
    SET _pencond = _pen14s0c16711680
    SET _fntcond = _times10b0
    SET _rgbcond_backcolor = uar_rptencodecolor (189 ,221 ,255 )
    SET _ncond_backmode = 1
   ELSEIF ((nedocs_score >= 0 ) )
    SET _pencond = _pen14s0c16711680
    SET _fntcond = _times10b0
    SET _rgbcond_backcolor = uar_rptencodecolor (66 ,158 ,255 )
    SET _ncond_backmode = 1
   ELSE
    SET _pencond = _pen14s0c0
    SET _fntcond = _times10b0
    SET _rgbcond_backcolor = rpt_black
    SET _ncond_backmode = 0
   ENDIF
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.667 )
   SET rptsd->m_width = 0.609
   SET rptsd->m_height = 0.334
   SET _dummyfont = uar_rptsetfont (_hreport ,_fntcond )
   SET _dummypen = uar_rptsetpen (_hreport ,_pencond )
   IF ((_ncond_backmode = 1 ) )
    SET oldbackcolor = uar_rptsetbackcolor (_hreport ,_rgbcond_backcolor )
   ENDIF
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (nedocs_level ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.384 )
   SET rptsd->m_width = 1.284
   SET rptsd->m_height = 0.334
   SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (nedocs_endtime ,char (0 ) ) )
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdleftborder )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 1.384
   SET rptsd->m_height = 0.334
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (nedocs_starttime ,char (0 ) ) )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 7.492 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 1.383 ) ,offsety ,(offsetx + 1.383 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 2.667 ) ,offsety ,(offsetx + 2.667 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.275 ) ,offsety ,(offsetx + 3.275 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.417 ) ,offsety ,(offsetx + 3.417 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.608 ) ,offsety ,(offsetx + 3.608 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.075 ) ,offsety ,(offsetx + 4.075 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.317 ) ,offsety ,(offsetx + 4.317 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.725 ) ,offsety ,(offsetx + 4.725 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.983 ) ,offsety ,(offsetx + 4.983 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.608 ) ,offsety ,(offsetx + 5.608 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.367 ) ,offsety ,(offsetx + 7.367 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.492 ) ,offsety ,(offsetx + 7.492 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    7.492 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  (fieldname04html (dummy =i2 ) =null WITH protect )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName040' colspan='1'>" ,
   nedocs_starttime ,"</td>" ,"<td class='FieldName041' colspan='1'>" ,nedocs_endtime ,"</td>" ,"" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
  IF ((nedocs_score > 180 ) )
   SET _htmlfileinfo->file_buf = build2 ("<td class='FieldName042_Condition1' colspan='3'>" )
   SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
  ELSEIF ((nedocs_score > 140 ) )
   SET _htmlfileinfo->file_buf = build2 ("<td class='FieldName042_Condition2' colspan='3'>" )
   SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
  ELSEIF ((nedocs_score > 100 ) )
   SET _htmlfileinfo->file_buf = build2 ("<td class='FieldName042_Condition3' colspan='3'>" )
   SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
  ELSEIF ((nedocs_score > 60 ) )
   SET _htmlfileinfo->file_buf = build2 ("<td class='FieldName042_Condition4' colspan='3'>" )
   SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
  ELSEIF ((nedocs_score > 20 ) )
   SET _htmlfileinfo->file_buf = build2 ("<td class='FieldName042_Condition5' colspan='3'>" )
   SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
  ELSEIF ((nedocs_score >= 0 ) )
   SET _htmlfileinfo->file_buf = build2 ("<td class='FieldName042_Condition6' colspan='3'>" )
   SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
  ELSE
   SET _htmlfileinfo->file_buf = build2 ("<td class='FieldName042' colspan='3'>" ,"" )
   SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
  ENDIF
  SET _htmlfileinfo->file_buf = build2 (nedocs_level ,"</td>" ,
   "<td class='FieldName041' colspan='2'>" ,nedocs_score ,"</td>" ,
   "<td class='FieldName041' colspan='2'>" ,nedocs_patient ,"</td>" ,
   "<td class='FieldName041' colspan='2'>" ,nedocs_bed ,"</td>" ,
   "<td class='FieldName041' colspan='2'>" ,nedocs_inpatient ,"</td>" ,
   "<td class='FieldName041' colspan='2'>" ,nedocs_admit ,"</td>" ,
   "<td class='FieldName041' colspan='2'>" ,nedocs_critical ,"</td>" ,
   "<td class='FieldName041' colspan='2'>" ,nedocs_longest_admit ,"</td>" ,
   "<td class='FieldName041' colspan='1'>" ,nedocs_last_bed ,"</td>" ,
   "<td class='FieldName0411' colspan='1'>" ,nedocs_scale ,"</td>" ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  (fieldname05 (ncalc =i2 ) =f8 WITH protect )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = fieldname05abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  (fieldname05abs (ncalc =i2 ,offsetx =f8 ,offsety =f8 ) =f8 WITH protect )
  DECLARE sectionheight = f8 WITH noconstant (0.320000 ) ,private
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 64
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 7.492
   SET rptsd->m_height = 0.334
   SET _oldfont = uar_rptsetfont (_hreport ,_times140 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 7.492 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.492 ) ,offsety ,(offsetx + 7.492 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    7.492 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  (fieldname05html (dummy =i2 ) =null WITH protect )
  SET _htmlfileinfo->file_buf = build2 ("<tr>" ,"<td class='FieldName050' colspan='21'>" ,"" ,
   "</td>" ,"</tr>" )
  SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
 END ;Subroutine
 SUBROUTINE  initializereport (dummy )
  IF ((_bgeneratehtml = 1 ) )
   SET _htmlfileinfo->file_name = _sendto
   SET _htmlfileinfo->file_buf = "w+b"
   SET _htmlfilestat = cclio ("OPEN" ,_htmlfileinfo )
   SET _htmlfileinfo->file_buf = "<html><head><META content=CCLLINK,APPLINK name=discern /></head>"
   SET _htmlfilestat = cclio ("WRITE" ,_htmlfileinfo )
  ELSE
   SET rptreport->m_recsize = 102
   SET rptreport->m_reportname = "FNRPT_ED_NEDOCS_DETAIL"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET rptreport->m_dioflag = 0
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport (rptreport ,_outputtype ,rpt_inches )
   SET _rpterr = uar_rptseterrorlevel (_hreport ,rpt_error )
   SET _rptstat = uar_rptstartreport (_hreport )
   SET _rptpage = uar_rptstartpage (_hreport )
  ENDIF
  CALL _createfonts (0 )
  CALL _createpens (0 )
 END ;Subroutine
 SUBROUTINE  _createfonts (dummy )
  SET rptfont->m_recsize = 62
  SET rptfont->m_fontname = rpt_times
  SET rptfont->m_pointsize = 10
  SET rptfont->m_bold = rpt_off
  SET rptfont->m_italic = rpt_off
  SET rptfont->m_underline = rpt_off
  SET rptfont->m_strikethrough = rpt_off
  SET rptfont->m_rgbcolor = rpt_black
  SET _times100 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 14
  SET rptfont->m_bold = rpt_on
  SET _times14b0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 12
  SET _times12b0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 10
  SET rptfont->m_rgbcolor = rpt_white
  SET _times10b16777215 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_rgbcolor = rpt_black
  SET _times10b0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 14
  SET rptfont->m_bold = rpt_off
  SET _times140 = uar_rptcreatefont (_hreport ,rptfont )
 END ;Subroutine
 SUBROUTINE  _createpens (dummy )
  SET rptpen->m_recsize = 16
  SET rptpen->m_penwidth = 0.014
  SET rptpen->m_penstyle = 0
  SET rptpen->m_rgbcolor = rpt_black
  SET _pen14s0c0 = uar_rptcreatepen (_hreport ,rptpen )
  SET rptpen->m_penwidth = 0.000
  SET _pen0s0c0 = uar_rptcreatepen (_hreport ,rptpen )
  SET rptpen->m_penwidth = 0.014
  SET rptpen->m_rgbcolor = rpt_blue
  SET _pen14s0c16711680 = uar_rptcreatepen (_hreport ,rptpen )
 END ;Subroutine
 DECLARE pat_count = i4 WITH noconstant (0 )
 DECLARE disch_cd = f8
 DECLARE rfv_cd = f8
 DECLARE admitdoc_cd = f8
 DECLARE attnddoc_cd = f8
 DECLARE refdoc_cd = f8
 DECLARE trkcommenttype = f8
 DECLARE acuitycd = f8
 DECLARE regstatuscd = f8
 DECLARE specialtycd = f8
 DECLARE teamcd = f8
 DECLARE pcpdoc_cd = f8
 DECLARE space_pos = i4
 DECLARE cut_pos = i4
 DECLARE age = vc
 DECLARE new_age = vc
 DECLARE user_name = vc
 DECLARE provsrc = f8 WITH noconstant (0.0 )
 DECLARE prvrelncd = f8
 DECLARE len = i4
 DECLARE comp_pref = vc
 DECLARE comp_name_unq = vc
 DECLARE counter = i4 WITH noconstant (0 )
 DECLARE counter1 = i4 WITH noconstant (0 )
 DECLARE counter2 = i4 WITH noconstant (0 )
 RECORD output_data (
   1 total_los = vc
   1 report_data
     2 report_title = vc
     2 facility_cd = f8
     2 facility_display = vc
     2 track_group_cd = f8
     2 track_group_display = vc
     2 report_date = vc
     2 start_date = vc
     2 end_date = vc
     2 report_generation_date = vc
     2 report_generation_id = f8
     2 report_generation_name = vc
     2 report_nurseunit_name = vc
     2 criteria = vc
     2 report_parameters [* ]
       3 parameter_type = f8
       3 parameter_value = vc
   1 patient_data [* ]
     2 current_location_display = vc
     2 sorting_field = vc
     2 accompanied_by = vc
     2 acuity = vc
     2 admit_mode = vc
     2 admitting_physician = vc
     2 admit_source = vc
     2 arrive_date_time = vc
     2 visit_id = f8
     2 attending_physician = vc
     2 avl = vc
     2 birth_date = vc
     2 checkout_date_time = vc
     2 checkout_date = vc
     2 checkout_time = vc
     2 checkin_date_time = vc
     2 checkin_date = vc
     2 checkin_time = vc
     2 chief_complaint = vc
     2 other_info = c32000
     2 prearrival_author = vc
     2 prearrival_form_date_time = vc
     2 cancelled_by = vc
     2 coded_by = vc
     2 coded_by_id = f8
     2 coded_dt_tm = vc
     2 comment1 = vc
     2 comment2 = vc
     2 comment3 = vc
     2 comment4 = vc
     2 comment5 = vc
     2 comment6 = vc
     2 comment7 = vc
     2 comment8 = vc
     2 comment9 = vc
     2 comment10 = vc
     2 depart_date_time = vc
     2 discharge_disposition = vc
     2 discharge_to_location = vc
     2 discharge_date_time = vc
     2 current_age = vc
     2 disch_diagnosis = vc
     2 encounter_comment = vc
     2 encntr_id = f8
     2 encounter_type = vc
     2 family_present = vc
     2 fin = vc
     2 financial_class = vc
     2 form_status = vc
     2 isolation = vc
     2 los = vc
     2 los_checkin = vc
     2 los_checkin_hours = vc
     2 los_hours = vc
     2 los_location = vc
     2 medical_service = vc
     2 mrn = vc
     2 name_full_formatted = vc
     2 order_id = f8
     2 order_display = vc
     2 order_result_display = vc
     2 indvordercnt = i4
     2 pcp = vc
     2 person_id = f8
     2 prearrival_type = vc
     2 primary_provider = vc
     2 secondary_provider = vc
     2 primary_nurse = vc
     2 secondary_nurse = vc
     2 reason_for_visit = vc
     2 referring_comment = vc
     2 referring_physician = vc
     2 referring_source = vc
     2 registration_provider = vc
     2 registration_status = vc
     2 registration_date_time = vc
     2 security_vip = vc
     2 sex = vc
     2 specialty = vc
     2 ssn = vc
     2 team = vc
     2 track_group_cd = cv
     2 track_group = vc
     2 tracking_checkin_id = f8
     2 tracking_comment1 = vc
     2 tracking_comment2 = vc
     2 tracking_comment3 = vc
     2 tracking_comment4 = vc
     2 tracking_comment5 = vc
     2 tracking_comment6 = vc
     2 tracking_comment7 = vc
     2 tracking_comment8 = vc
     2 tracking_comment9 = vc
     2 tracking_comment10 = vc
     2 tracking_id = f8
     2 tvl = vc
     2 visit_age = vc
     2 documentation_status = vc
     2 region_cd = f8
     2 disaster_name = c30
     2 pa_type = vc
     2 pa_eta = vc
     2 pa_ta = vc
     2 pa_user = vc
     2 pa_ref_source = vc
     2 radiologist = vc
     2 event_id = f8
     2 note_title = vc
     2 checkout_update_name = vc
     2 disch_action_reason = vc
     2 clinician = vc
     2 nurse = vc
     2 num_pat_seen = i4
     2 num_pat_admitted = i4
     2 num_pat_disch = i4
     2 admit_pat_info = vc
     2 disch_pat_info = vc
     2 interval_median = vc
     2 interval_max = vc
     2 interval_avg = vc
     2 ed_physician = vc
     2 ed_reviewer = vc
     2 discrepancy = vc
     2 cardiologist = vc
     2 proc_dt_tm = vc
     2 acknowledged_ind = i2
     2 presenting_problem_name = vc
     2 assigned_nurse = vc
     2 location_info [* ]
       3 arrival_date = vc
       3 location_nurse_cd = vc
       3 location_room_cd = vc
       3 location_bed_cd = vc
       3 location_updated_by = vc
       3 location_moved_by = vc
     2 event_info [* ]
       3 event_name = vc
       3 event_status_display = vc
       3 request_date_time = vc
       3 request_time = vc
       3 start_date_time = vc
       3 start_time = vc
       3 complete_date_time = vc
       3 complete_time = vc
     2 provider_info [* ]
       3 provider_name = vc
       3 provider_role = vc
       3 assign_date_time = vc
       3 unassign_date_time = vc
     2 em_charge = vc
     2 em_charges [* ]
       3 charge_item_id = f8
       3 bill_item_id = f8
       3 charge_cnt = i4
       3 cdm = vc
       3 cpt = vc
       3 mods [* ]
         4 modifier = vc
     2 iv_charge = vc
     2 iv_charges [* ]
       3 charge_item_id = f8
       3 bill_item_id = f8
       3 charge_cnt = i4
       3 cdm = vc
       3 cpt = vc
       3 mods [* ]
         4 modifier = vc
     2 encntr_text_key = vc
     2 incident_cd = f8
     2 incident_name = c30
   1 tracking_loc [* ]
     2 location_cd = f8
     2 location_value = vc
   1 results [* ]
     2 event_display = vc
     2 result_display = vc
   1 orders [* ]
     2 order_display = vc
     2 order_result_display = vc
     2 hna_order_mnemonic = vc
     2 orig_ord_date = vc
     2 doc_name = vc
     2 status_display = vc
     2 start_date = vc
     2 catalog_type_display = vc
     2 catalog_type_cd = f8
     2 start_date = vc
     2 stop_date = vc
   1 view_wet_read = vc
   1 track_group_cd = f8
 )
 RECORD acuities (
   1 total = i4
   1 acuity [* ]
     2 censuscnt = i4
     2 acuitystr = c50
     2 average = f8
 )
 RECORD events (
   1 total = i4
   1 firsteventdisplay = vc
   1 secondeventdisplay = vc
   1 avgtime = vc
   1 eventtime [* ]
     2 starttime = vc
     2 endtime = vc
     2 numberofpatients = i4
     2 averagetime = vc
 )
 RECORD orders (
   1 total = i4
   1 orderdisplay = vc
   1 avgtime = vc
   1 ordertime [* ]
     2 starttime = vc
     2 endtime = vc
     2 numberofpatients = i4
     2 averagetime = vc
 )
 RECORD emsstruct (
   1 intervaltime [* ]
     2 starttime = vc
     2 endtime = vc
     2 patientcount = vc
 )
 RECORD dispostruct (
   1 intervaltime [* ]
     2 starttime = vc
     2 endtime = vc
     2 dispostring = vc
     2 interval_total = i2
     2 startcount = i2
     2 endcount = i2
     2 averagetime = vc
     2 dispo [* ]
       3 starttime = vc
       3 endtime = vc
       3 dispositiondisplay = vc
       3 patientcount = i2
 )
 RECORD topproblemsstruct (
   1 tvlgroup [* ]
     2 tvl = c255
     2 totallos = f8
     2 tvlpatcount = i4
     2 rfvgroup [* ]
       3 tvldisplay = c255
       3 rfv = c255
       3 numberrfv = c255
       3 percentrfv = c255
       3 minlos = c255
       3 minlosf = f8
       3 avelos = c255
       3 totallos = f8
       3 maxlos = c255
       3 maxlosf = f8
       3 sortingfield = c255
   1 total_number = c255
   1 total_percent = c255
   1 total_min_los = c255
   1 total_ave_los = c255
   1 total_max_los = c255
   1 disposition = c255
   1 statistics = c255
 )
 RECORD diagchiefcomp (
   1 qual [* ]
     2 starttime = vc
     2 endtime = vc
     2 intervalpatcount = i4
     2 diagnosis [* ]
       3 diagnosiscnt = i4
       3 diagccdisplay = vc
       3 nomenclatureid = f8
 )
 RECORD dispodetailstruct (
   1 dispo [* ]
     2 starttime = vc
     2 endtime = vc
     2 dispositiondisplay = vc
     2 dispositioncd = f8
     2 patientcount = i2
     2 encntr_id = f8
     2 averagetime = vc
 )
 RECORD dashboard (
   1 totalpatients = i4
   1 totallos = i4
   1 avglos = vc
   1 highestlos = i4
   1 highestlostrackingid = f8
   1 bedcount = i4
   1 waitroomcount = i4
   1 lwbsdispocount = i4
   1 dispo1count = i4
   1 dispo1name = vc
   1 dispo2name = vc
   1 dispo3name = vc
   1 dispo4name = vc
   1 dispo2count = i4
   1 dispo3count = i4
   1 dispo4count = i4
   1 eventpair1time = vc
   1 eventpair2time = vc
   1 eventpair3time = vc
   1 eventpair4time = vc
   1 eventpair1name = vc
   1 eventpair2name = vc
   1 eventpair3name = vc
   1 eventpair4name = vc
   1 bed_status [* ]
     2 bed_status = vc
     2 bed_status_cnt = i4
     2 bed_status_cd = f8
   1 acuities [* ]
     2 acuity_desc = vc
     2 acuity_cnt = i4
     2 acuity_cd = f8
 )
 RECORD totals (
   1 total = i4
   1 avgtime = vc
   1 alllos = i4
   1 admittotals = i4
   1 intervaltime [* ]
     2 starttime = vc
     2 endtime = vc
     2 starttimeformat = vc
     2 endtimeformat = vc
     2 patientcount = i4
     2 intervalhour = i4
     2 averagetime = vc
     2 startcount = i2
     2 endcount = i2
     2 total_los = i4
     2 admittedcount = i4
 )
 RECORD topdiagnosis (
   1 total = i4
   1 diagnosis [* ]
     2 nomenclatureid = f8
     2 display = vc
     2 diagnosiscnt = i4
 )
 DECLARE pri_doc_role = f8 WITH noconstant (0.0 )
 DECLARE sec_doc_role = f8 WITH noconstant (0.0 )
 DECLARE pri_nur_role = f8 WITH noconstant (0.0 )
 DECLARE sec_nur_role = f8 WITH noconstant (0.0 )
 DECLARE pcpdoc_cd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,331 ,"PCP" ) )
 DECLARE attnddoc_cd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,333 ,"ATTENDDOC" ) )
 DECLARE admitdoc_cd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,333 ,"ADMITDOC" ) )
 DECLARE refdoc_cd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,333 ,"REFERDOC" ) )
 DECLARE rfv_cd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,17 ,"RFV" ) )
 DECLARE disch_cd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,17 ,"DISCHARGE" ) )
 DECLARE trkcommenttype = f8 WITH noconstant (uar_get_code_by ("MEANING" ,355 ,"TRACKCOMMENT" ) )
 DECLARE acuitycd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,16409 ,"ACUITY" ) )
 DECLARE regstatuscd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,16409 ,"REGSTAT" ) )
 DECLARE specialtycd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,16409 ,"SPECIALTY" ) )
 DECLARE teamcd = f8 WITH noconstant (uar_get_code_by ("MEANING" ,16409 ,"TEAM" ) )
 DECLARE provsrc = f8 WITH noconstant (uar_get_code_by ("MEANING" ,19009 ,"PSFENABLED" ) )
 DECLARE prvrole_assoc = f8 WITH noconstant (uar_get_code_by ("MEANING" ,20500 ,"PRVROLEASSOC" ) )
 DECLARE comp_pref = vc
 DECLARE comp_name_unique = vc
 DECLARE len = i4 WITH noconstant (0 )
 DECLARE delimpos1 = i4 WITH noconstant (0 )
 DECLARE delimpos2 = i4 WITH noconstant (0 )
 DECLARE delimpos3 = i4 WITH noconstant (0 )
 SELECT INTO "nl:"
  FROM (location loc ),
   (organization o ),
   (track_group tg )
  PLAN (tg
   WHERE (tg.tracking_group_cd =  $TRACKGROUPCD )
   AND (tg.child_table = "TRACK_ASSOC" ) )
   JOIN (loc
   WHERE (loc.location_cd = tg.parent_value )
   AND (loc.active_ind = 1 ) )
   JOIN (o
   WHERE (o.organization_id = loc.organization_id ) )
  DETAIL
   output_data->report_data.facility_display = o.org_name
  WITH nocounter ,maxrec = 1
 ;end select
 IF ((provsrc != 0.0 ) )
  SET comp_name_unique = concat (trim (cnvtstring ( $TRACKGROUPCD ) ) ,";" ,trim (cnvtstring (
     prvrole_assoc ) ) )
  SELECT INTO "nl:"
   FROM (track_prefs tp )
   WHERE (tp.comp_name_unq = comp_name_unique )
   DETAIL
    comp_pref = tp.comp_pref
   WITH nocounter
  ;end select
  CALL echo (build ("comp_pref: " ,comp_pref ) )
  SET len = textlen (comp_pref )
  SET delimpos1 = findstring (";" ,comp_pref )
  SET pri_doc_role = cnvtreal (substring (1 ,(delimpos1 - 1 ) ,comp_pref ) )
  SET delimpos2 = findstring (";" ,comp_pref ,(delimpos1 + 1 ) )
  SET sec_doc_role = cnvtreal (substring ((delimpos1 + 1 ) ,(delimpos2 - (delimpos1 + 1 ) ) ,
    comp_pref ) )
  SET delimpos3 = findstring (";" ,comp_pref ,(delimpos2 + 1 ) )
  SET pri_nur_role = cnvtreal (substring ((delimpos2 + 1 ) ,(delimpos3 - (delimpos2 + 1 ) ) ,
    comp_pref ) )
  SET sec_nur_role = cnvtreal (substring ((delimpos3 + 1 ) ,(len - delimpos3 ) ,comp_pref ) )
 ENDIF
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
 DECLARE i18nhandle = i4 WITH persistscript
 CALL uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
 SET output_data->report_data.report_title =  $REPNAME
 SET output_data->report_data.track_group_display = uar_i18nbuildmessage (i18nhandle ,"fn_TrkGroup" ,
  "For: %1" ,"s" ,nullterm (trim (uar_get_code_description ( $TRACKGROUPCD ) ) ) )
 SET output_data->report_data.report_generation_date = uar_i18nbuildmessage (i18nhandle ,
  "fn_GenReportDate" ,"Printed At: %1" ,"s" ,nullterm (concat (format (curdate ,"@SHORTDATE" ) ,
    "  " ,format (curtime3 ,"@TIMENOSECONDS" ) ) ) )
 SELECT INTO "nl:"
  FROM (prsnl p )
  WHERE (p.person_id = reqinfo->updt_id )
  DETAIL
   output_data->report_data.report_generation_name = uar_i18nbuildmessage (i18nhandle ,"fn_GenName" ,
    "Printed By: %1" ,"s" ,nullterm (p.name_full_formatted ) )
  WITH nocounter
 ;end select
 DECLARE date_range_size = f8 WITH noconstant (0.0 )
 DECLARE sbegin = vc WITH noconstant
 DECLARE send = vc WITH noconstant
 SET date_range_size = datetimediff (cnvtdatetime ( $ENDDATE ) ,cnvtdatetime ( $STARTDATE ) )
 SET sbegin = uar_i18nbuildmessage (i18nhandle ,"fn_GenStartDate" ,"From: %1" ,"s" ,nullterm (
   format (cnvtdatetime ( $STARTDATE ) ,"@SHORTDATETIMENOSEC" ) ) )
 SET send = uar_i18nbuildmessage (i18nhandle ,"fn_GenEndDate" ,"To: %1" ,"s" ,nullterm (format (
    cnvtdatetime ( $ENDDATE ) ,"@SHORTDATETIMENOSEC" ) ) )
 SET output_data->report_data.start_date = sbegin
 SET output_data->report_data.end_date = send
 SET output_data->report_data.report_date = trim (concat (sbegin ,"&nbsp;&nbsp;" ,send ) )
 DECLARE totalpats = i4 WITH persistscript ,noconstant (0 )
 SELECT INTO "nl:"
  FROM (tracking_checkin tc ),
   (tracking_item ti ),
   (encounter e ),
   (person p )
  PLAN (tc
   WHERE (tc.checkin_dt_tm >= cnvtdatetime ( $STARTDATE ) )
   AND (tc.checkin_dt_tm < cnvtdatetime ( $ENDDATE ) )
   AND ((tc.tracking_group_cd + 0 ) =  $TRACKGROUPCD )
   AND ((tc.active_ind + 0 ) = 1 ) )
   JOIN (ti
   WHERE (ti.tracking_id = tc.tracking_id )
   AND (ti.active_ind = 1 ) )
   JOIN (p
   WHERE (p.person_id = ti.person_id )
   AND (p.active_ind = 1 ) )
   JOIN (e
   WHERE (e.encntr_id = ti.encntr_id )
   AND (e.active_ind = 1 ) )
  ORDER BY tc.tracking_id
  HEAD tc.tracking_id
   totalpats +=1
  WITH nocounter
 ;end select
 FREE RECORD rnedocs
 RECORD rnedocs (
   1 cnt = i4
   1 list [* ]
     2 starttime = vc
     2 endtime = vc
     2 levelstr = vc
     2 scoreval = i4
     2 patcnt = i4
     2 bedcnt = i4
     2 inpatientcnt = i4
     2 admitcnt = i4
     2 criticalcnt = i4
     2 longadmitmin = i4
     2 lastbedmin = i4
     2 scale = vc
 )
 FREE RECORD rreportlabels
 RECORD rreportlabels (
   1 startinterval = vc
   1 endinterval = vc
   1 level = vc
   1 score = vc
   1 patient = vc
   1 bed = vc
   1 inpatient = vc
   1 admit = vc
   1 critical = vc
   1 longestadmit = vc
   1 lastbed = vc
   1 scale = vc
 )
 DECLARE i18nnotbusy = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"fn_level1" ,
   "Not Busy" ) )
 DECLARE i18nbusy = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"fn_level2" ,"Busy" )
  )
 DECLARE i18nextremebusy = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"fn_level3" ,
   "Extremely Busy" ) )
 DECLARE i18novercrowded = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,"fn_level4" ,
   "Overcrowded" ) )
 DECLARE i18nsevereovercrowded = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "fn_level5" ,"Severely Overcrowded" ) )
 DECLARE i18ndangerovercrowded = vc WITH protect ,constant (uar_i18ngetmessage (i18nhandle ,
   "fn_level6" ,"Dangerously Overcrowded" ) )
 DECLARE sinterval = vc WITH protect ,constant ("1H" )
 DECLARE sintervalstarttime = vc WITH protect
 DECLARE sendtime = vc WITH protect
 DECLARE sendtimecompare = vc WITH protect
 DECLARE ntmpscore = i4 WITH protect ,noconstant (0 )
 DECLARE dtrackgroupcd = f8 WITH protect ,constant ( $TRACKGROUPCD )
 SET sintervalstarttime = format (cnvtdatetime ( $STARTDATE ) ,";;Q" )
 WHILE ((cnvtdatetime (sintervalstarttime ) < cnvtdatetime ( $ENDDATE ) ) )
  SET sendtime = format (cnvtlookahead (sinterval ,cnvtdatetime (sintervalstarttime ) ) ,";;Q" )
  IF ((cnvtdatetime (sendtime ) > cnvtdatetime ( $ENDDATE ) ) )
   SET sendtimecompare =  $ENDDATE
  ELSE
   SET sendtimecompare = sendtime
  ENDIF
  SET rnedocs->cnt +=1
  SET stat = alterlist (rnedocs->list ,rnedocs->cnt )
  SET rnedocs->list[rnedocs->cnt ].starttime = format (cnvtdatetime (sintervalstarttime ) ,
   "@SHORTDATETIMENOSEC" )
  SET rnedocs->list[rnedocs->cnt ].endtime = format (cnvtdatetime (sendtime ) ,"@SHORTDATETIMENOSEC"
   )
  SET rnedocs->list[rnedocs->cnt ].scale = "0.00"
  SELECT INTO "nl:"
   interval = sintervalstarttime
   FROM (fn_dash_nedocs_info ni )
   WHERE (ni.performed_dt_tm >= cnvtdatetime (sintervalstarttime ) )
   AND (ni.performed_dt_tm < cnvtdatetime (sendtimecompare ) )
   AND (ni.tracking_group_cd = dtrackgroupcd )
   ORDER BY interval
   HEAD interval
    ntmpscore = 0
   DETAIL
    IF ((ntmpscore = 0 ) ) ntmpscore = ni.modified_score_val ,rnedocs->list[rnedocs->cnt ].scoreval
     = ni.modified_score_val ,rnedocs->list[rnedocs->cnt ].patcnt = ni.patient_cnt ,rnedocs->list[
     rnedocs->cnt ].bedcnt = ni.ed_bed_cnt ,rnedocs->list[rnedocs->cnt ].inpatientcnt = ni
     .inpatient_bed_cnt ,rnedocs->list[rnedocs->cnt ].admitcnt = ni.admit_patient_cnt ,rnedocs->list[
     rnedocs->cnt ].criticalcnt = ni.critical_patient_cnt ,rnedocs->list[rnedocs->cnt ].longadmitmin
     = ni.longest_admit_minutes ,rnedocs->list[rnedocs->cnt ].lastbedmin = ni.last_bed_minutes ,
     rnedocs->list[rnedocs->cnt ].scale = cnvtstring (ni.scaling_factor_value ,16 ,2 )
    ENDIF
   WITH nocounter
  ;end select
  IF ((ntmpscore > 180 ) )
   SET rnedocs->list[rnedocs->cnt ].levelstr = i18ndangerovercrowded
  ELSEIF ((ntmpscore > 140 ) )
   SET rnedocs->list[rnedocs->cnt ].levelstr = i18nsevereovercrowded
  ELSEIF ((ntmpscore > 100 ) )
   SET rnedocs->list[rnedocs->cnt ].levelstr = i18novercrowded
  ELSEIF ((ntmpscore > 60 ) )
   SET rnedocs->list[rnedocs->cnt ].levelstr = i18nextremebusy
  ELSEIF ((ntmpscore > 20 ) )
   SET rnedocs->list[rnedocs->cnt ].levelstr = i18nbusy
  ELSE
   SET rnedocs->list[rnedocs->cnt ].levelstr = i18nnotbusy
  ENDIF
  SET sintervalstarttime = sendtime
 ENDWHILE
 SET rreportlabels->startinterval = uar_i18ngetmessage (i18nhandle ,"fn_label1" ,"Start Interval" )
 SET rreportlabels->endinterval = uar_i18ngetmessage (i18nhandle ,"fn_label2" ,"End Interval" )
 SET rreportlabels->level = uar_i18ngetmessage (i18nhandle ,"fn_label3" ,"Level" )
 SET rreportlabels->score = uar_i18ngetmessage (i18nhandle ,"fn_label4" ,"Score" )
 SET rreportlabels->patient = uar_i18ngetmessage (i18nhandle ,"fn_label5" ,"Patient" )
 SET rreportlabels->bed = uar_i18ngetmessage (i18nhandle ,"fn_label6" ,"ED Bed" )
 SET rreportlabels->inpatient = uar_i18ngetmessage (i18nhandle ,"fn_label7" ,"Inpatient Bed" )
 SET rreportlabels->admit = uar_i18ngetmessage (i18nhandle ,"fn_label8" ,"Admit" )
 SET rreportlabels->critical = uar_i18ngetmessage (i18nhandle ,"fn_label9" ,"Critical" )
 SET rreportlabels->longestadmit = uar_i18ngetmessage (i18nhandle ,"fn_label10" ,
  "Longest Admit Time" )
 SET rreportlabels->lastbed = uar_i18ngetmessage (i18nhandle ,"fn_label11" ,"Last ED Bed Time" )
 SET rreportlabels->scale = uar_i18ngetmessage (i18nhandle ,"fn_label12" ,"Scale Factor" )
 IF ((validate (debug_ind ,0 ) = 1 ) )
  CALL echorecord (rreportlabels )
  CALL echorecord (rnedocs )
 ENDIF
 DECLARE htmlfileind = i4 WITH noconstant (0 )
 SET _sendto =  $OUTDEV
 CALL initializereport (0 )
 IF (validate (_htmlfileinfo ) )
  SET htmlfileind = _htmlfileinfo->file_desc
 ELSEIF (validate (_htmlfilehandle ) )
  SET htmlfileind = _htmlfilehandle
 ENDIF
 IF ((htmlfileind = 0 ) )
  IF ((checkfun (cnvtupper ("__LayoutQuery" ) ) = 7 ) )
   CALL __layoutquery (0 )
  ELSEIF ((checkfun (cnvtupper ("LayoutSection0" ) ) = 7 ) )
   SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom )
   IF (((_yoffset + layoutsection0 (1 ) ) > _fenddetail ) )
    CALL pagebreak (0 )
   ENDIF
   CALL layoutsection0 (0 )
  ENDIF
 ELSE
  IF ((checkfun (cnvtupper ("LayoutQueryHTML" ) ) = 7 ) )
   CALL layoutqueryhtml (0 )
  ELSEIF ((checkfun (cnvtupper ("FieldName0HTML" ) ) = 7 ) )
   CALL fieldname0html (0 )
  ENDIF
 ENDIF
 CALL finalizereport (_sendto )
 call echorecord(output_data)
END GO
