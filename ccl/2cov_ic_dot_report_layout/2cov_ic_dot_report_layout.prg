DROP PROGRAM 2cov_ic_dot_report_layout :dba GO
CREATE PROGRAM 2cov_ic_dot_report_layout :dba
 prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "From Date/Time" = ""
	, "To Date/Time" = ""
	, "Facility Name" = 0
	, "Facility Wide Reporting" = ""
	, "NHSN Location(s)" = 0
	, "Unit(s)" = 0
	, "Medication(s)" = 0
	, "Route(s)" = 0
	, "Output:" = 0
	, "File Location:" = "i:\custom\au"
	, "DEBUG_IND" = 0
	, "Denominator Data" = 0
	, "Admission Count" = 0
 
with OUTDEV, FROMDATE, THRUDATE, FACILITY, FACWIDE, NHSNLOC, UNITS, MEDICATION, ROUTE,
	OUTPUT, FILE, DEBUG_IND, DENOM, ADMISSIONS
 EXECUTE reportrtl
 
 record encntr_types
 (
  1 cnt = i2
  1 qual[*]
   2 encntr_type_Cd = f8
   2 inpatient_ind = i2
 )
 
  RECORD admissions_row_data (
   1 rows [* ]
     2 person_id = f8
     2 encntr_id = f8
     2 loc_nurse_unit_cd = f8
     2 arrive_dt_tm = dq8
     2 reg_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_Tm = dq8
     2 admission_ind = i2
     2 days_present_ind = i2
     2 begin_day_idx = i4
     2 end_day_idx= i4
     2 admission_dt_tm_used = dq8
     2 admission_used_ind = i2
 )
free record 3011001Request
record 3011001Request (
  1 Module_Dir = vc
  1 Module_Name = vc
  1 bAsBlob = i2
 
)
 
free record 3011001Reply
record 3011001Reply (
    1 info_line [* ]
      2 new_line = vc
    1 data_blob = gvc
    1 data_blob_size = i4
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
 
  )
 
 RECORD reply (
   1 facility_name = vc
   1 facility_name_display_key = vc
   1 facility_oid = vc
   1 from_date = dq8
   1 to_date = dq8
   1 rpt_type_flag = i2
   1 no_nhsn_flag = i2
   1 empty_reply_ind = i2
   1 your_code_ind = i2
   1 months [* ]
     2 month_year = vc
     2 month_dt_tm = dq8
     2 locations [* ]
       3 location_cd = f8
       3 location_name = vc
       3 location_name_display_key = vc
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
          4 person_specific_count [* ]
           5 person_id = f8
           5 person_mrn = vc
           5 total_count = i4
           5 dates [* ]
             6 med_admin_dt_tm = dq8
 
       3 units_by_your_code = vc
       3 units_by_your_code_csv = vc
   1 selected_routes [* ]
     2 route_display = vc
   1 facilities_disp_by_oid = vc
   1 facilities_disp_by_oid_csv = vc
   1 facilities_by_oid [* ]
     2 facility_cd = f8
 )
 
 declare html_output = vc with noconstant(" ")
 declare html_encounter = vc with noconstant(" ")
 declare html_encounter_type = vc with noconstant(" ")
 declare html_encounter_type_def = vc with noconstant(" ")
 declare html_admissions = vc with noconstant(" ")
 declare html_days_present_days = vc with noconstant(" ")
 declare html_denom_log = vc with noconstant(" ")
 
set 3011001Request->Module_Dir = "ccluserdir:"
set 3011001Request->Module_Name = "ic_debug.html"
set 3011001Request->bAsBlob = 1
 
execute eks_get_source with replace ("REQUEST" ,3011001Request ) , replace ("REPLY" ,3011001Reply )
 
 
set html_output = 3011001Reply->data_blob
 
 select into "nl:"
 from
 	code_Value cv
 plan cv
 	where cv.code_value in(
 		 value(uar_get_code_by(^DISPLAY^,71,^Inpatient^))
		,value(uar_get_code_by(^DISPLAY^,71,^Newborn^))
		,value(uar_get_code_by(^DISPLAY^,71,^Observation^))
		,value(uar_get_code_by(^DISPLAY^,71,^Outpatient Monitoring^))
		,value(uar_get_code_by(^DISPLAY^,71,^Outpatient in a Bed^))
)
head report
	i = 0
detail
	i = (i + 1)
	stat = alterlist(encntr_types->qual,i)
	encntr_types->qual[i].encntr_type_Cd = cv.code_value
	case (cv.display)
	 of ^Inpatient^: encntr_types->qual[i].inpatient_ind 	= 1
	 of ^Newborn^: encntr_types->qual[i].inpatient_ind		= 1
	 of ^Observation^: encntr_types->qual[i].inpatient_ind	= 1
	endcase
foot report
	encntr_Types->cnt = i
with nocounter
 
call echorecord(encntr_types)
 
 EXECUTE 2cov_ic_au_report outdev ,
  $FROMDATE ,
  $THRUDATE ,
  $FACILITY ,
 ;"" ,
  $FACWIDE ,
  $NHSNLOC ,
  $UNITS ,
  $MEDICATION ,
  $ROUTE ,
  $OUTPUT ,
  $FILE ,
 0,
 $ADMISSIONS
 
 call echorecord(reply)
 
 set html_output = replace(html_output,"%%cov_ic_au_report_reply%%",cnvtrectojson(reply))
 set html_output = replace(html_output,"%%html_denom_log%%",trim(html_denom_log))
 set html_output = replace(html_output,"%%html_encounter%%",trim(html_encounter))
 set html_output = replace(html_output,"%%html_admissions%%",trim(html_admissions))
 set html_output = replace(html_output,"%%html_days_present_days%%",trim(html_days_present_days))
 set html_output = replace(html_output,"%%html_encounter_type%%",trim(html_encounter_type))
 set html_output = replace(html_output,"%%html_encounter_type_def%%",cnvtrectojson(encntr_Types))
 
 
 DECLARE _createfonts (dummy ) = null WITH protect
 DECLARE _createpens (dummy ) = null WITH protect
 DECLARE query1 (dummy ) = null WITH protect
 DECLARE pagebreak (dummy ) = null WITH protect
 DECLARE finalizereport ((ssendreport = vc ) ) = null WITH protect
 DECLARE headreportrow1 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headreportrow1abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE headreportrow2 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headreportrow2abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE headpagerow1 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headpagerow1abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE headpagerow2 ((ncalc = i2 ) ,(maxheight = f8 ) ,(bcontinue = i2 (ref ) ) ) = f8 WITH
 protect
 DECLARE headpagerow2abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ,(maxheight = f8 ) ,(
  bcontinue = i2 (ref ) ) ) = f8 WITH protect
 DECLARE headpagerow3 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headpagerow3abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE headpagerow4 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headpagerow4abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE headpagerow5 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headpagerow5abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE headpagerow6 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE headpagerow6abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE detailrow1 ((ncalc = i2 ) ,(maxheight = f8 ) ,(bcontinue = i2 (ref ) ) ) = f8 WITH protect
 DECLARE detailrow1abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ,(maxheight = f8 ) ,(
  bcontinue = i2 (ref ) ) ) = f8 WITH protect
 DECLARE detailrow2 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE detailrow2abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE detailrow3 ((ncalc = i2 ) ,(maxheight = f8 ) ,(bcontinue = i2 (ref ) ) ) = f8 WITH protect
 DECLARE detailrow3abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ,(maxheight = f8 ) ,(
  bcontinue = i2 (ref ) ) ) = f8 WITH protect
 DECLARE detailrow4 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE detailrow4abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE detailrow ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE detailrowabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE footpagerow ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE footpagerowabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE footreportrow ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE footreportrowabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE initializereport (dummy ) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant (0 ) ,protect
 DECLARE _yoffset = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _xoffset = f8 WITH noconstant (0.0 ) ,protect
 DECLARE rpt_render = i2 WITH constant (0 ) ,protect
 DECLARE _crlf = vc WITH constant (concat (char (13 ) ,char (10 ) ) ) ,protect
 DECLARE rpt_calcheight = i2 WITH constant (1 ) ,protect
 DECLARE _yshift = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _xshift = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _sendto = vc WITH noconstant ( $OUTDEV ) ,protect
 DECLARE _rpterr = i2 WITH noconstant (0 ) ,protect
 DECLARE _rptstat = i2 WITH noconstant (0 ) ,protect
 DECLARE _oldfont = i4 WITH noconstant (0 ) ,protect
 DECLARE _oldpen = i4 WITH noconstant (0 ) ,protect
 DECLARE _dummyfont = i4 WITH noconstant (0 ) ,protect
 DECLARE _dummypen = i4 WITH noconstant (0 ) ,protect
 DECLARE _fdrawheight = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _rptpage = i4 WITH noconstant (0 ) ,protect
 DECLARE _diotype = i2 WITH noconstant (8 ) ,protect
 DECLARE _outputtype = i2 WITH noconstant (rpt_postscript ) ,protect
 DECLARE _remfieldname0 = i4 WITH noconstant (1 ) ,protect
 DECLARE _bholdcontinue = i2 WITH noconstant (0 ) ,protect
 DECLARE _bcontheadpagerow2 = i2 WITH noconstant (0 ) ,protect
 DECLARE _remfieldname2 = i4 WITH noconstant (1 ) ,protect
 DECLARE _bcontdetailrow1 = i2 WITH noconstant (0 ) ,protect
 DECLARE _remfieldname10 = i4 WITH noconstant (1 ) ,protect
 DECLARE _bcontdetailrow3 = i2 WITH noconstant (0 ) ,protect
 DECLARE _times140 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times100 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times200 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times10b0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen22s0c0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen12s0c0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen0s0c0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen14s0c0 = i4 WITH noconstant (0 ) ,protect
 SUBROUTINE  query1 (dummy )
  SELECT
   reply_facility_name = substring (1 ,60 ,reply->facility_name ) ,
   reply_facility_oid = substring (1 ,60 ,reply->facility_oid ) ,
   reply_from_date = reply->from_date ,
   reply_to_date = reply->to_date ,
   reply_rpt_type_flag = reply->rpt_type_flag ,
   reply_no_nhsn_flag = reply->no_nhsn_flag ,
   months_month_year = substring (1 ,60 ,reply->months[d1.seq ].month_year ) ,
   months_month_dt_tm = reply->months[d1.seq ].month_dt_tm ,
   locations_location_name = substring (1 ,60 ,reply->months[d1.seq ].locations[d2.seq ].
    location_name ) ,
   locations_days_present = reply->months[d1.seq ].locations[d2.seq ].days_present ,
   locations_admissions = reply->months[d1.seq ].locations[d2.seq ].admissions ,
   agents_agent_name = substring (1 ,60 ,reply->months[d1.seq ].locations[d2.seq ].agents[d3.seq ].
    agent_name ) ,
   agents_not_available_flag = reply->months[d1.seq ].locations[d2.seq ].agents[d3.seq ].
   not_available_flag ,
   agents_total = reply->months[d1.seq ].locations[d2.seq ].agents[d3.seq ].total ,
   agents_iv = reply->months[d1.seq ].locations[d2.seq ].agents[d3.seq ].iv ,
   agents_im = reply->months[d1.seq ].locations[d2.seq ].agents[d3.seq ].im ,
   agents_digestive = reply->months[d1.seq ].locations[d2.seq ].agents[d3.seq ].digestive ,
   agents_respiratory = reply->months[d1.seq ].locations[d2.seq ].agents[d3.seq ].respiratory ,
   reply_empty_reply_ind = reply->empty_reply_ind
   FROM (dummyt d1 WITH seq = size (reply->months ,5 ) ),
    (dummyt d2 WITH seq = 1 ),
    (dummyt d3 WITH seq = 1 )
   PLAN (d1
    WHERE maxrec (d2 ,size (reply->months[d1.seq ].locations ,5 ) ) )
    JOIN (d2
    WHERE maxrec (d3 ,size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
    JOIN (d3 )
   ORDER BY locations_location_name ,
    months_month_dt_tm
   HEAD REPORT
    _d0 = d1.seq ,
    _d1 = d2.seq ,
    _d2 = d3.seq ,
    _d3 = reply_facility_name ,
    _d4 = reply_from_date ,
    _d5 = reply_to_date ,
    _d6 = reply_rpt_type_flag ,
    _d7 = reply_no_nhsn_flag ,
    _d8 = months_month_year ,
    _d9 = locations_location_name ,
    _d10 = locations_days_present ,
    _d11 = locations_admissions ,
    _d12 = agents_agent_name ,
    _d13 = agents_not_available_flag ,
    _d14 = agents_total ,
    _d15 = agents_iv ,
    _d16 = agents_im ,
    _d17 = agents_digestive ,
    _d18 = agents_respiratory ,
    _d19 = reply_empty_reply_ind ,
    _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom ) ,
    _fenddetail = (_fenddetail - footpagerow (rpt_calcheight ) ) ,
    _fdrawheight = headreportrow1 (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
      headreportrow2 (rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > (rptreport->m_pagewidth - rptreport->m_marginbottom ) ) )
     CALL pagebreak (0 )
    ENDIF
    ,dummy_val = headreportrow1 (rpt_render ) ,
    _fdrawheight = headreportrow2 (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > (rptreport->m_pagewidth - rptreport->m_marginbottom ) ) )
     CALL pagebreak (0 )
    ENDIF
    ,dummy_val = headreportrow2 (rpt_render )
   HEAD PAGE
    IF ((curpage > 1 ) ) dummy_val = pagebreak (0 )
    ENDIF
    ,dummy_val = headpagerow1 (rpt_render ) ,
    _bcontheadpagerow2 = 0 ,
    dummy_val = headpagerow2 (rpt_render ,((rptreport->m_pagewidth - rptreport->m_marginbottom ) -
     _yoffset ) ,_bcontheadpagerow2 ) ,
    dummy_val = headpagerow3 (rpt_render ) ,
    dummy_val = headpagerow4 (rpt_render ) ,
    dummy_val = headpagerow5 (rpt_render ) ,
    dummy_val = headpagerow6 (rpt_render )
   HEAD locations_location_name
    row + 0
   HEAD months_month_dt_tm
    row + 0
   DETAIL
    _bcontdetailrow1 = 0 ,
    bfirsttime = 1 ,
    WHILE ((((_bcontdetailrow1 = 1 ) ) OR ((bfirsttime = 1 ) )) )
     _bholdcontinue = _bcontdetailrow1 ,_fdrawheight = detailrow1 (rpt_calcheight ,(_fenddetail -
      _yoffset ) ,_bholdcontinue ) ,
     IF ((((_bholdcontinue = 1 ) ) OR ((_fdrawheight > 0 ) )) )
      IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + detailrow2 (
        rpt_calcheight ) )
      ENDIF
      ,
      IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _bholdcontinue = 0 ,_fdrawheight = (
       _fdrawheight + detailrow3 (rpt_calcheight ,((_fenddetail - _yoffset ) - _fdrawheight ) ,
        _bholdcontinue ) ) ,
       IF ((_bholdcontinue = 1 ) ) _fdrawheight = (_fenddetail + 1 )
       ENDIF
      ENDIF
      ,
      IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + detailrow4 (
        rpt_calcheight ) )
      ENDIF
      ,
      IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + detailrow (
        rpt_calcheight ) )
      ENDIF
     ENDIF
     ,
     IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
      BREAK
     ELSEIF ((_bholdcontinue = 1 )
     AND (_bcontdetailrow1 = 0 ) )
      BREAK
     ENDIF
     ,dummy_val = detailrow1 (rpt_render ,(_fenddetail - _yoffset ) ,_bcontdetailrow1 ) ,bfirsttime
     = 0
    ENDWHILE
    ,_fdrawheight = detailrow2 (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _bholdcontinue = 0 ,_fdrawheight = (
      _fdrawheight + detailrow3 (rpt_calcheight ,((_fenddetail - _yoffset ) - _fdrawheight ) ,
       _bholdcontinue ) ) ,
      IF ((_bholdcontinue = 1 ) ) _fdrawheight = (_fenddetail + 1 )
      ENDIF
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + detailrow4 (
       rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + detailrow (
       rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = detailrow2 (rpt_render ) ,
    _bcontdetailrow3 = 0 ,
    bfirsttime = 1 ,
    WHILE ((((_bcontdetailrow3 = 1 ) ) OR ((bfirsttime = 1 ) )) )
     _bholdcontinue = _bcontdetailrow3 ,_fdrawheight = detailrow3 (rpt_calcheight ,(_fenddetail -
      _yoffset ) ,_bholdcontinue ) ,
     IF ((((_bholdcontinue = 1 ) ) OR ((_fdrawheight > 0 ) )) )
      IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + detailrow4 (
        rpt_calcheight ) )
      ENDIF
      ,
      IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + detailrow (
        rpt_calcheight ) )
      ENDIF
     ENDIF
     ,
     IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
      BREAK
     ELSEIF ((_bholdcontinue = 1 )
     AND (_bcontdetailrow3 = 0 ) )
      BREAK
     ENDIF
     ,dummy_val = detailrow3 (rpt_render ,(_fenddetail - _yoffset ) ,_bcontdetailrow3 ) ,bfirsttime
     = 0
    ENDWHILE
    ,_fdrawheight = detailrow4 (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + detailrow (
       rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = detailrow4 (rpt_render ) ,
    _fdrawheight = detailrow (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = detailrow (rpt_render )
   FOOT  months_month_dt_tm
    row + 0
   FOOT  locations_location_name
    row + 0
   FOOT PAGE
    _yhold = _yoffset ,
    _yoffset = _fenddetail ,
    dummy_val = footpagerow (rpt_render ) ,
    _yoffset = _yhold
   FOOT REPORT
    _fdrawheight = footreportrow (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     CALL pagebreak (0 )
    ENDIF
    ,dummy_val = footreportrow (rpt_render )
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE  pagebreak (dummy )
  SET _rptpage = uar_rptendpage (_hreport )
  SET _rptpage = uar_rptstartpage (_hreport )
  SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE  finalizereport (ssendreport )
  if ($DEBUG_IND = 1)
  FREE SET putreply
   RECORD putreply (
     1 info_line [* ]
       2 new_line = vc
     1 status_data
       2 status = c1
       2 subeventstatus [1 ]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FREE SET putrequest
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
   SET putrequest->document = html_output
   SET putrequest->document_size = size (putrequest->document )
   CALL echorecord (putrequest )
   EXECUTE eks_put_source WITH replace (request ,putrequest ) ,replace (reply ,putreply )
 elseif ($DENOM = 1)
 select into $OUTDEV
 
   loc_facility_cd = substring(1,100,uar_get_code_display(e.loc_facility_cd))
, loc_nurse_unit_cd= substring(1,100,uar_get_code_display(e.loc_nurse_unit_cd))
, encntr_type_cd= substring(1,100,uar_get_code_display(e.encntr_type_cd))
, alias = substring(1,100,trim(ea.alias))
, arrive_dt_tm= substring(1,100,format(admissions_row_data->rows[d1.seq].arrive_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
, reg_dt_tm= substring(1,100,format(admissions_row_data->rows[d1.seq].reg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
, inpatient_admit_dt_tm =substring(1,100, format(e.inpatient_admit_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
, beg_effective_dt_tm= substring(1,100,format(admissions_row_data->rows[d1.seq].beg_effective_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
, disch_dt_tm= substring(1,100,format(e.disch_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
, encntr_id = substring(1,100,cnvtstring(e.encntr_id))
, admin_ind = trim(substring(1,3,cnvtstring(admissions_row_data->rows[d1.seq].admission_ind)	))
, begin_day_idx = trim(substring(1,3,cnvtstring(admissions_row_data->rows[d1.seq].begin_day_idx)	))
, end_day_idx = trim(substring(1,3,cnvtstring(admissions_row_data->rows[d1.seq].end_day_idx)	))
, admission_dt_tm_used= substring(1,100,format(admissions_row_data->rows[d1.seq].admission_dt_tm_used,"dd-mmm-yyyy hh:mm:ss;;d"))
, admission_used_ind = trim(substring(1,3,cnvtstring(admissions_row_data->rows[d1.seq].admission_used_ind)	))
   from
   	(dummyt d1 with seq = size(admissions_row_data->rows,5))
   	,encounter e
   	,encntr_alias ea
   	plan d1
   	join e
   		where e.encntr_id = admissions_row_data->rows[d1.seq].encntr_id
   	join ea
   		where ea.encntr_id = e.encntr_id
   			and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
  with format,separator = " "
 
  else
 
	  ;call echojson(reply,"nshndot.json")
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
	   SET spool value (sfilename ) value (ssendreport ) WITH deleted ,dio = value (_diotype )
	  ENDIF
	  DECLARE _errorfound = i2 WITH noconstant (0 ) ,protect
	  DECLARE _errcnt = i2 WITH noconstant (0 ) ,protect
	  SET _errorfound = uar_rptfirsterror (_hreport ,rpterror )
	  WHILE ((_errorfound = rpt_errorfound )
	  AND (_errcnt < 512 ) )
	   SET _errcnt = (_errcnt + 1 )
	   SET stat = alterlist (rpterrors->errors ,_errcnt )
	   SET rpterrors->errors[_errcnt ].m_severity = rpterror->m_severity
	   SET rpterrors->errors[_errcnt ].m_text = rpterror->m_text
	   SET rpterrors->errors[_errcnt ].m_source = rpterror->m_source
	   SET _errorfound = uar_rptnexterror (_hreport ,rpterror )
	  ENDWHILE
	  SET _rptstat = uar_rptdestroyreport (_hreport )
  endif
 END ;Subroutine
 SUBROUTINE  headreportrow1 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headreportrow1abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headreportrow1abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.500000 ) ,private
  IF (NOT ((reply_rpt_type_flag = 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = bor (bor (rpt_sdtopborder ,rpt_sdleftborder ) ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 9.969
   SET rptsd->m_height = 0.500
   SET _oldfont = uar_rptsetfont (_hreport ,_times200 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen22s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (rptlabel1 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headreportrow2 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headreportrow2abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headreportrow2abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.500000 ) ,private
  IF (NOT ((reply_rpt_type_flag = 1 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = bor (bor (rpt_sdtopborder ,rpt_sdleftborder ) ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 9.969
   SET rptsd->m_height = 0.500
   SET _oldfont = uar_rptsetfont (_hreport ,_times200 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen22s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (rptlabel2 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headpagerow1 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headpagerow1abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headpagerow1abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.220000 ) ,private
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = bor (bor (rpt_sdtopborder ,rpt_sdbottomborder ) ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.020
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.792 )
   SET rptsd->m_width = 6.177
   SET rptsd->m_height = 0.219
   SET _oldfont = uar_rptsetfont (_hreport ,_times10b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen22s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption5 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 3.802
   SET rptsd->m_height = 0.219
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption1 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.792 ) ,offsety ,(offsetx + 3.792 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headpagerow2 (ncalc ,maxheight ,bcontinue )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headpagerow2abs (ncalc ,_xoffset ,_yoffset ,maxheight ,bcontinue )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headpagerow2abs (ncalc ,offsetx ,offsety ,maxheight ,bcontinue )
  DECLARE sectionheight = f8 WITH noconstant (0.190000 ) ,private
  DECLARE growsum = i4 WITH noconstant (0 ) ,private
  DECLARE drawheight_fieldname0 = f8 WITH noconstant (0.0 ) ,private
  DECLARE __fieldname2 = vc WITH noconstant (build (build (format (reply_from_date ,"MM/DD/YYYY ;;D"
      ) ," - " ,format (reply_to_date ,"MM/DD/YYYY ;;D" ) ) ,char (0 ) ) ) ,protect
  DECLARE __fieldname0 = vc WITH noconstant (build (reply_facility_name ,char (0 ) ) ) ,protect
  IF ((bcontinue = 0 ) )
   SET _remfieldname0 = 1
  ENDIF
  SET rptsd->m_flags = 261
  SET rptsd->m_borders = bor (bor (rpt_sdbottomborder ,rpt_sdleftborder ) ,rpt_sdrightborder )
  SET rptsd->m_padding = rpt_sdleftborder
  SET rptsd->m_paddingwidth = 0.020
  SET rptsd->m_linespacing = rpt_single
  SET rptsd->m_rotationangle = 0
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 0.000 )
  SET rptsd->m_width = 3.802
  SET rptsd->m_height = ((offsety + maxheight ) - rptsd->m_y )
  SET _oldfont = uar_rptsetfont (_hreport ,_times100 )
  SET _oldpen = uar_rptsetpen (_hreport ,_pen22s0c0 )
  SET _holdremfieldname0 = _remfieldname0
  IF ((_remfieldname0 > 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (_remfieldname0 ,((
      size (__fieldname0 ) - _remfieldname0 ) + 1 ) ,__fieldname0 ) ) )
   SET drawheight_fieldname0 = rptsd->m_height
   IF ((rptsd->m_height > ((offsety + sectionheight ) - rptsd->m_y ) ) )
    SET sectionheight = ((rptsd->m_y + _fdrawheight ) - offsety )
   ENDIF
   IF ((rptsd->m_drawlength = 0 ) )
    SET _remfieldname0 = 0
   ELSEIF ((rptsd->m_drawlength < size (nullterm (substring (_remfieldname0 ,((size (__fieldname0 )
      - _remfieldname0 ) + 1 ) ,__fieldname0 ) ) ) ) )
    SET _remfieldname0 = (_remfieldname0 + rptsd->m_drawlength )
   ELSE
    SET _remfieldname0 = 0
   ENDIF
   SET growsum = (growsum + _remfieldname0 )
  ENDIF
  SET rptsd->m_flags = 256
  SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 3.792 )
  SET rptsd->m_width = 6.177
  SET rptsd->m_height = sectionheight
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname2 )
  ENDIF
  SET rptsd->m_flags = 260
  SET rptsd->m_borders = bor (bor (rpt_sdbottomborder ,rpt_sdleftborder ) ,rpt_sdrightborder )
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 0.000 )
  SET rptsd->m_width = 3.802
  SET rptsd->m_height = sectionheight
  IF ((ncalc = rpt_render )
  AND (_holdremfieldname0 > 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (_holdremfieldname0 ,((
      size (__fieldname0 ) - _holdremfieldname0 ) + 1 ) ,__fieldname0 ) ) )
  ELSE
   SET _remfieldname0 = _holdremfieldname0
  ENDIF
  SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
  IF ((ncalc = rpt_render ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.792 ) ,offsety ,(offsetx + 3.792 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  IF ((growsum > 0 ) )
   SET bcontinue = 1
  ELSE
   SET bcontinue = 0
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headpagerow3 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headpagerow3abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headpagerow3abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.200000 ) ,private
  IF (NOT ((reply_rpt_type_flag > 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 8.750 )
   SET rptsd->m_width = 1.219
   SET rptsd->m_height = 0.198
   SET _oldfont = uar_rptsetfont (_hreport ,_times10b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen22s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption9 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.781 )
   SET rptsd->m_width = 2.969
   SET rptsd->m_height = 0.198
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption8 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.792 )
   SET rptsd->m_width = 1.990
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.688 )
   SET rptsd->m_width = 2.115
   SET rptsd->m_height = 0.198
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_borders = bor (rpt_sdleftborder ,rpt_sdrightborder )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = 0.198
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 1.688 ) ,offsety ,(offsetx + 1.688 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.792 ) ,offsety ,(offsetx + 3.792 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.781 ) ,offsety ,(offsetx + 5.781 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 8.750 ) ,offsety ,(offsetx + 8.750 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headpagerow4 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headpagerow4abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headpagerow4abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.250000 ) ,private
  IF (NOT ((reply_rpt_type_flag > 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 8.750 )
   SET rptsd->m_width = 1.219
   SET rptsd->m_height = 0.250
   SET _oldfont = uar_rptsetfont (_hreport ,_times10b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen22s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption15 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 7.865 )
   SET rptsd->m_width = 0.885
   SET rptsd->m_height = 0.250
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption14 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 6.979 )
   SET rptsd->m_width = 0.885
   SET rptsd->m_height = 0.250
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption13 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 6.583 )
   SET rptsd->m_width = 0.396
   SET rptsd->m_height = 0.250
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption12 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 6.188 )
   SET rptsd->m_width = 0.396
   SET rptsd->m_height = 0.250
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption11 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.781 )
   SET rptsd->m_width = 0.406
   SET rptsd->m_height = 0.250
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption10 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.792 )
   SET rptsd->m_width = 1.990
   SET rptsd->m_height = 0.250
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption7 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.688 )
   SET rptsd->m_width = 2.115
   SET rptsd->m_height = 0.250
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption4 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_borders = bor (bor (rpt_sdbottomborder ,rpt_sdleftborder ) ,rpt_sdrightborder )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = 0.250
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption6 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 1.688 ) ,offsety ,(offsetx + 1.688 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.792 ) ,offsety ,(offsetx + 3.792 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.781 ) ,offsety ,(offsetx + 5.781 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 6.188 ) ,offsety ,(offsetx + 6.188 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 6.583 ) ,offsety ,(offsetx + 6.583 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 6.979 ) ,offsety ,(offsetx + 6.979 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.865 ) ,offsety ,(offsetx + 7.865 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 8.750 ) ,offsety ,(offsetx + 8.750 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headpagerow5 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headpagerow5abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headpagerow5abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.220000 ) ,private
  IF (NOT ((reply_rpt_type_flag = 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 7.479 )
   SET rptsd->m_width = 2.479
   SET rptsd->m_height = 0.219
   SET _oldfont = uar_rptsetfont (_hreport ,_times10b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen22s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption9 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.792 )
   SET rptsd->m_width = 3.688
   SET rptsd->m_height = 0.219
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption8 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.688 )
   SET rptsd->m_width = 2.115
   SET rptsd->m_height = 0.219
   SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_borders = bor (rpt_sdleftborder ,rpt_sdrightborder )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = 0.219
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.958 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 1.688 ) ,offsety ,(offsetx + 1.688 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.792 ) ,offsety ,(offsetx + 3.792 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.479 ) ,offsety ,(offsetx + 7.479 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.958 ) ,offsety ,(offsetx + 9.958 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.958 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  headpagerow6 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = headpagerow6abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  headpagerow6abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.250000 ) ,private
  IF (NOT ((reply_rpt_type_flag = 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 8.750 )
   SET rptsd->m_width = 1.219
   SET rptsd->m_height = 0.281
   SET _oldfont = uar_rptsetfont (_hreport ,_times10b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen22s0c0 )
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption16 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 7.479 )
   SET rptsd->m_width = 1.271
   SET rptsd->m_height = 0.281
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption15 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 6.396 )
   SET rptsd->m_width = 1.083
   SET rptsd->m_height = 0.281
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption14 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 5.385 )
   SET rptsd->m_width = 1.021
   SET rptsd->m_height = 0.281
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption13 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.833 )
   SET rptsd->m_width = 0.552
   SET rptsd->m_height = 0.281
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption12 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.333 )
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.281
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption11 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.792 )
   SET rptsd->m_width = 0.542
   SET rptsd->m_height = 0.281
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption10 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.688 )
   SET rptsd->m_width = 2.115
   SET rptsd->m_height = 0.281
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption7 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET rptsd->m_borders = bor (bor (rpt_sdbottomborder ,rpt_sdleftborder ) ,rpt_sdrightborder )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = 0.281
   SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (230 ,255 ,204 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (scaption6 ,char (0 ) ) )
   SET oldbackcolor = uar_rptresetbackcolor (_hreport )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 1.688 ) ,offsety ,(offsetx + 1.688 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.792 ) ,offsety ,(offsetx + 3.792 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.333 ) ,offsety ,(offsetx + 4.333 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.833 ) ,offsety ,(offsetx + 4.833 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.385 ) ,offsety ,(offsetx + 5.385 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 6.396 ) ,offsety ,(offsetx + 6.396 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.479 ) ,offsety ,(offsetx + 7.479 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 8.750 ) ,offsety ,(offsetx + 8.750 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  detailrow1 (ncalc ,maxheight ,bcontinue )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = detailrow1abs (ncalc ,_xoffset ,_yoffset ,maxheight ,bcontinue )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  detailrow1abs (ncalc ,offsetx ,offsety ,maxheight ,bcontinue )
  DECLARE sectionheight = f8 WITH noconstant (0.200000 ) ,private
  DECLARE growsum = i4 WITH noconstant (0 ) ,private
  DECLARE drawheight_fieldname2 = f8 WITH noconstant (0.0 ) ,private
  DECLARE __fieldname10 = vc WITH noconstant (build (evaluate (agents_not_available_flag ,1 ,"N/A" ,
     cnvtstring (agents_respiratory ) ) ,char (0 ) ) ) ,protect
  DECLARE __fieldname9 = vc WITH noconstant (build (evaluate (agents_not_available_flag ,1 ,"N/A" ,
     cnvtstring (agents_digestive ) ) ,char (0 ) ) ) ,protect
  DECLARE __fieldname8 = vc WITH noconstant (build (evaluate (agents_not_available_flag ,1 ,"N/A" ,
     cnvtstring (agents_im ) ) ,char (0 ) ) ) ,protect
  DECLARE __fieldname7 = vc WITH noconstant (build (evaluate (agents_not_available_flag ,1 ,"N/A" ,
     cnvtstring (agents_iv ) ) ,char (0 ) ) ) ,protect
  DECLARE __fieldname6 = vc WITH noconstant (build (evaluate (agents_not_available_flag ,1 ,"N/A" ,
     cnvtstring (agents_total ) ) ,char (0 ) ) ) ,protect
  DECLARE __fieldname2 = vc WITH noconstant (build (agents_agent_name ,char (0 ) ) ) ,protect
  DECLARE __fieldname1 = vc WITH noconstant (build (evaluate (d3.seq ,1 ,locations_location_name ,""
     ) ,char (0 ) ) ) ,protect
  DECLARE __fieldname0 = vc WITH noconstant (build (evaluate (d3.seq ,1 ,months_month_year ,"" ) ,
    char (0 ) ) ) ,protect
  IF (NOT ((reply_rpt_type_flag > 0 )
  AND (reply_empty_reply_ind = 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((bcontinue = 0 ) )
   SET _remfieldname2 = 1
  ENDIF
  SET rptsd->m_flags = 277
  SET rptsd->m_padding = rpt_sdnoborders
  SET rptsd->m_paddingwidth = 0.000
  SET rptsd->m_linespacing = rpt_single
  SET rptsd->m_rotationangle = 0
  IF ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
   SET rptsd->m_borders = rpt_sdrightborder
  ELSE
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  ENDIF
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 3.792 )
  SET rptsd->m_width = 1.979
  SET rptsd->m_height = ((offsety + maxheight ) - rptsd->m_y )
  SET _oldfont = uar_rptsetfont (_hreport ,_times100 )
  SET _oldpen = uar_rptsetpen (_hreport ,_pen12s0c0 )
  SET _holdremfieldname2 = _remfieldname2
  IF ((_remfieldname2 > 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (_remfieldname2 ,((
      size (__fieldname2 ) - _remfieldname2 ) + 1 ) ,__fieldname2 ) ) )
   SET drawheight_fieldname2 = rptsd->m_height
   IF ((rptsd->m_height > ((offsety + sectionheight ) - rptsd->m_y ) ) )
    SET sectionheight = ((rptsd->m_y + _fdrawheight ) - offsety )
   ENDIF
   IF ((rptsd->m_drawlength = 0 ) )
    SET _remfieldname2 = 0
   ELSEIF ((rptsd->m_drawlength < size (nullterm (substring (_remfieldname2 ,((size (__fieldname2 )
      - _remfieldname2 ) + 1 ) ,__fieldname2 ) ) ) ) )
    SET _remfieldname2 = (_remfieldname2 + rptsd->m_drawlength )
   ELSE
    SET _remfieldname2 = 0
   ENDIF
   SET growsum = (growsum + _remfieldname2 )
  ENDIF
  SET rptsd->m_flags = 0
  SET rptsd->m_borders = rpt_sdrightborder
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 8.750 )
  SET rptsd->m_width = 1.219
  SET rptsd->m_height = sectionheight
  SET _dummypen = uar_rptsetpen (_hreport ,_pen22s0c0 )
  SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (119 ,119 ,119 ) )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
  ENDIF
  SET oldbackcolor = uar_rptresetbackcolor (_hreport )
  SET rptsd->m_flags = 272
  IF ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
   SET rptsd->m_borders = rpt_sdrightborder
  ELSE
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  ENDIF
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 7.854 )
  SET rptsd->m_width = 0.896
  SET rptsd->m_height = sectionheight
  SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
  SET _dummypen = uar_rptsetpen (_hreport ,_pen12s0c0 )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname10 )
  ENDIF
  SET rptsd->m_flags = 272
  IF ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
   SET rptsd->m_borders = rpt_sdrightborder
  ELSE
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  ENDIF
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 6.979 )
  SET rptsd->m_width = 0.875
  SET rptsd->m_height = sectionheight
  SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname9 )
  ENDIF
  SET rptsd->m_flags = 272
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 6.583 )
  SET rptsd->m_width = 0.396
  SET rptsd->m_height = sectionheight
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname8 )
  ENDIF
  SET rptsd->m_flags = 272
  IF ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
   SET rptsd->m_borders = rpt_sdrightborder
  ELSE
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  ENDIF
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 6.188 )
  SET rptsd->m_width = 0.396
  SET rptsd->m_height = sectionheight
  SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname7 )
  ENDIF
  SET rptsd->m_flags = 272
  IF ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
   SET rptsd->m_borders = rpt_sdrightborder
  ELSE
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  ENDIF
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 5.771 )
  SET rptsd->m_width = 0.406
  SET rptsd->m_height = sectionheight
  SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname6 )
  ENDIF
  SET rptsd->m_flags = 276
  IF ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
   SET rptsd->m_borders = rpt_sdrightborder
  ELSE
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  ENDIF
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 3.792 )
  SET rptsd->m_width = 1.979
  SET rptsd->m_height = sectionheight
  SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
  IF ((ncalc = rpt_render )
  AND (_holdremfieldname2 > 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (_holdremfieldname2 ,((
      size (__fieldname2 ) - _holdremfieldname2 ) + 1 ) ,__fieldname2 ) ) )
  ELSE
   SET _remfieldname2 = _holdremfieldname2
  ENDIF
  SET rptsd->m_flags = 272
  SET rptsd->m_borders = rpt_sdrightborder
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 1.688 )
  SET rptsd->m_width = 2.115
  SET rptsd->m_height = sectionheight
  SET _dummypen = uar_rptsetpen (_hreport ,_pen22s0c0 )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname1 )
  ENDIF
  SET rptsd->m_flags = 272
  SET rptsd->m_borders = rpt_sdleftborder
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 0.000 )
  SET rptsd->m_width = 1.688
  SET rptsd->m_height = sectionheight
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname0 )
  ENDIF
  SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
  IF ((ncalc = rpt_render ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 1.688 ) ,offsety ,(offsetx + 1.688 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.792 ) ,offsety ,(offsetx + 3.792 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.771 ) ,offsety ,(offsetx + 5.771 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 6.188 ) ,offsety ,(offsetx + 6.188 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 6.583 ) ,offsety ,(offsetx + 6.583 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 6.979 ) ,offsety ,(offsetx + 6.979 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.854 ) ,offsety ,(offsetx + 7.854 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 8.750 ) ,offsety ,(offsetx + 8.750 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  IF ((growsum > 0 ) )
   SET bcontinue = 1
  ELSE
   SET bcontinue = 0
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  detailrow2 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = detailrow2abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  detailrow2abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.220000 ) ,private
  IF (NOT ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) )
  AND (reply_rpt_type_flag > 0 )
  AND (reply_no_nhsn_flag = 0 )
  AND (reply_empty_reply_ind = 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = bor (bor (rpt_sdtopborder ,rpt_sdbottomborder ) ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 8.750 )
   SET rptsd->m_width = 1.219
   SET rptsd->m_height = 0.219
   SET _oldfont = uar_rptsetfont (_hreport ,_times100 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen22s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (locations_days_present ,char (0 ) )
    )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.771 )
   SET rptsd->m_width = 4.979
   SET rptsd->m_height = 0.219
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdleftborder )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 3.771
   SET rptsd->m_height = 0.219
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.771 ) ,offsety ,(offsetx + 3.771 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 8.750 ) ,offsety ,(offsetx + 8.750 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  detailrow3 (ncalc ,maxheight ,bcontinue )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = detailrow3abs (ncalc ,_xoffset ,_yoffset ,maxheight ,bcontinue )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  detailrow3abs (ncalc ,offsetx ,offsety ,maxheight ,bcontinue )
  DECLARE sectionheight = f8 WITH noconstant (0.200000 ) ,private
  DECLARE growsum = i4 WITH noconstant (0 ) ,private
  DECLARE drawheight_fieldname10 = f8 WITH noconstant (0.0 ) ,private
  DECLARE __fieldname15 = vc WITH noconstant (build (evaluate (agents_not_available_flag ,1 ,"N/A" ,
     cnvtstring (agents_respiratory ) ) ,char (0 ) ) ) ,protect
  DECLARE __fieldname14 = vc WITH noconstant (build (evaluate (agents_not_available_flag ,1 ,"N/A" ,
     cnvtstring (agents_digestive ) ) ,char (0 ) ) ) ,protect
  DECLARE __fieldname13 = vc WITH noconstant (build (evaluate (agents_not_available_flag ,1 ,"N/A" ,
     cnvtstring (agents_im ) ) ,char (0 ) ) ) ,protect
  DECLARE __fieldname12 = vc WITH noconstant (build (evaluate (agents_not_available_flag ,1 ,"N/A" ,
     cnvtstring (agents_iv ) ) ,char (0 ) ) ) ,protect
  DECLARE __fieldname11 = vc WITH noconstant (build (evaluate (agents_not_available_flag ,1 ,"N/A" ,
     cnvtstring (agents_total ) ) ,char (0 ) ) ) ,protect
  DECLARE __fieldname10 = vc WITH noconstant (build (agents_agent_name ,char (0 ) ) ) ,protect
  DECLARE __fieldname9 = vc WITH noconstant (build (evaluate (d3.seq ,1 ,months_month_year ,"" ) ,
    char (0 ) ) ) ,protect
  IF (NOT ((reply_rpt_type_flag = 0 )
  AND (reply_no_nhsn_flag = 0 )
  AND (reply_empty_reply_ind = 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((bcontinue = 0 ) )
   SET _remfieldname10 = 1
  ENDIF
  SET rptsd->m_flags = 277
  SET rptsd->m_padding = rpt_sdnoborders
  SET rptsd->m_paddingwidth = 0.000
  SET rptsd->m_linespacing = rpt_single
  SET rptsd->m_rotationangle = 0
  IF ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
   SET rptsd->m_borders = rpt_sdrightborder
  ELSE
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  ENDIF
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 1.688 )
  SET rptsd->m_width = 2.104
  SET rptsd->m_height = ((offsety + maxheight ) - rptsd->m_y )
  SET _oldfont = uar_rptsetfont (_hreport ,_times100 )
  SET _oldpen = uar_rptsetpen (_hreport ,_pen12s0c0 )
  SET _holdremfieldname10 = _remfieldname10
  IF ((_remfieldname10 > 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (_remfieldname10 ,((
      size (__fieldname10 ) - _remfieldname10 ) + 1 ) ,__fieldname10 ) ) )
   SET drawheight_fieldname10 = rptsd->m_height
   IF ((rptsd->m_height > ((offsety + sectionheight ) - rptsd->m_y ) ) )
    SET sectionheight = ((rptsd->m_y + _fdrawheight ) - offsety )
   ENDIF
   IF ((rptsd->m_drawlength = 0 ) )
    SET _remfieldname10 = 0
   ELSEIF ((rptsd->m_drawlength < size (nullterm (substring (_remfieldname10 ,((size (__fieldname10
       ) - _remfieldname10 ) + 1 ) ,__fieldname10 ) ) ) ) )
    SET _remfieldname10 = (_remfieldname10 + rptsd->m_drawlength )
   ELSE
    SET _remfieldname10 = 0
   ENDIF
   SET growsum = (growsum + _remfieldname10 )
  ENDIF
  SET rptsd->m_flags = 0
  SET rptsd->m_borders = rpt_sdrightborder
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 8.719 )
  SET rptsd->m_width = 1.250
  SET rptsd->m_height = sectionheight
  SET _dummypen = uar_rptsetpen (_hreport ,_pen22s0c0 )
  SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (119 ,119 ,119 ) )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
  ENDIF
  SET oldbackcolor = uar_rptresetbackcolor (_hreport )
  SET rptsd->m_flags = 0
  SET rptsd->m_borders = rpt_sdnoborders
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 7.479 )
  SET rptsd->m_width = 1.250
  SET rptsd->m_height = sectionheight
  SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
  SET oldbackcolor = uar_rptsetbackcolor (_hreport ,uar_rptencodecolor (119 ,119 ,119 ) )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
  ENDIF
  SET oldbackcolor = uar_rptresetbackcolor (_hreport )
  SET rptsd->m_flags = 272
  IF ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
   SET rptsd->m_borders = rpt_sdrightborder
  ELSE
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  ENDIF
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 6.396 )
  SET rptsd->m_width = 1.073
  SET rptsd->m_height = sectionheight
  SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
  SET _dummypen = uar_rptsetpen (_hreport ,_pen12s0c0 )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname15 )
  ENDIF
  SET rptsd->m_flags = 272
  IF ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
   SET rptsd->m_borders = rpt_sdrightborder
  ELSE
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  ENDIF
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 5.375 )
  SET rptsd->m_width = 1.021
  SET rptsd->m_height = sectionheight
  SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname14 )
  ENDIF
  SET rptsd->m_flags = 272
  IF ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
   SET rptsd->m_borders = rpt_sdrightborder
  ELSE
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  ENDIF
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 4.823 )
  SET rptsd->m_width = 0.552
  SET rptsd->m_height = sectionheight
  SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname13 )
  ENDIF
  SET rptsd->m_flags = 272
  IF ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
   SET rptsd->m_borders = rpt_sdrightborder
  ELSE
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  ENDIF
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 4.323 )
  SET rptsd->m_width = 0.500
  SET rptsd->m_height = sectionheight
  SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname12 )
  ENDIF
  SET rptsd->m_flags = 272
  IF ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
   SET rptsd->m_borders = rpt_sdrightborder
  ELSE
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  ENDIF
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 3.792 )
  SET rptsd->m_width = 0.531
  SET rptsd->m_height = sectionheight
  SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname11 )
  ENDIF
  SET rptsd->m_flags = 276
  IF ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) ) )
   SET rptsd->m_borders = rpt_sdrightborder
  ELSE
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdrightborder )
  ENDIF
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 1.688 )
  SET rptsd->m_width = 2.104
  SET rptsd->m_height = sectionheight
  SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
  IF ((ncalc = rpt_render )
  AND (_holdremfieldname10 > 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,nullterm (substring (_holdremfieldname10 ,(
      (size (__fieldname10 ) - _holdremfieldname10 ) + 1 ) ,__fieldname10 ) ) )
  ELSE
   SET _remfieldname10 = _holdremfieldname10
  ENDIF
  SET rptsd->m_flags = 272
  SET rptsd->m_borders = bor (rpt_sdleftborder ,rpt_sdrightborder )
  SET rptsd->m_y = (offsety + 0.000 )
  SET rptsd->m_x = (offsetx + 0.000 )
  SET rptsd->m_width = 1.688
  SET rptsd->m_height = sectionheight
  SET _dummypen = uar_rptsetpen (_hreport ,_pen22s0c0 )
  IF ((ncalc = rpt_render )
  AND (bcontinue = 0 ) )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fieldname9 )
  ENDIF
  SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
  IF ((ncalc = rpt_render ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 1.688 ) ,offsety ,(offsetx + 1.688 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 3.792 ) ,offsety ,(offsetx + 3.792 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.323 ) ,offsety ,(offsetx + 4.323 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.823 ) ,offsety ,(offsetx + 4.823 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.375 ) ,offsety ,(offsetx + 5.375 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 6.396 ) ,offsety ,(offsetx + 6.396 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.479 ) ,offsety ,(offsetx + 7.479 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 8.719 ) ,offsety ,(offsetx + 8.719 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  IF ((growsum > 0 ) )
   SET bcontinue = 1
  ELSE
   SET bcontinue = 0
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  detailrow4 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = detailrow4abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  detailrow4abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.220000 ) ,private
  IF (NOT ((d3.seq = size (reply->months[d1.seq ].locations[d2.seq ].agents ,5 ) )
  AND (reply_rpt_type_flag = 0 )
  AND (reply_no_nhsn_flag = 0 )
  AND (reply_empty_reply_ind = 0 ) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = bor (bor (rpt_sdtopborder ,rpt_sdbottomborder ) ,rpt_sdrightborder )
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 8.719 )
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.219
   SET _oldfont = uar_rptsetfont (_hreport ,_times100 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen22s0c0 )
   if ($ADMISSIONS > 0)
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ($ADMISSIONS ,char (0 ) ) )
   else
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (locations_admissions ,char (0 ) ) )
   endif
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 7.479 )
   SET rptsd->m_width = 1.240
   SET rptsd->m_height = 0.219
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (locations_days_present ,char (0 ) )
    )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 1.667 )
   SET rptsd->m_width = 5.813
   SET rptsd->m_height = 0.219
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET rptsd->m_borders = bor (rpt_sdbottomborder ,rpt_sdleftborder )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 1.667
   SET rptsd->m_height = 0.219
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build ("" ,char (0 ) ) )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 1.667 ) ,offsety ,(offsetx + 1.667 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 7.479 ) ,offsety ,(offsetx + 7.479 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 8.719 ) ,offsety ,(offsetx + 8.719 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  detailrow (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = detailrowabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  detailrowabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.500000 ) ,private
  IF (NOT ((((reply_no_nhsn_flag = 1 ) ) OR ((reply_empty_reply_ind = 1 ) )) ) )
   RETURN (0.0 )
  ENDIF
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 9.969
   SET rptsd->m_height = 0.500
   SET _oldfont = uar_rptsetfont (_hreport ,_times140 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (infoboxmessage ,char (0 ) ) )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  footpagerow (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = footpagerowabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  footpagerowabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.170000 ) ,private
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 9.969
   SET rptsd->m_height = 0.177
   SET _oldfont = uar_rptsetfont (_hreport ,_times100 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (rpt_pageofpage ,char (0 ) ) )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  footreportrow (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = footreportrowabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  footreportrowabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.170000 ) ,private
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.000 )
   SET rptsd->m_width = 9.969
   SET rptsd->m_height = 0.177
   SET _oldfont = uar_rptsetfont (_hreport ,_times100 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build (endofreport ,char (0 ) ) )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen0s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + 0.000 ) ,(offsetx + 9.969 ) ,
    (offsety + 0.000 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,offsety ,(offsetx + 0.000 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 9.969 ) ,offsety ,(offsetx + 9.969 ) ,(offsety +
    sectionheight ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.000 ) ,(offsety + sectionheight ) ,(offsetx +
    9.969 ) ,(offsety + sectionheight ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  initializereport (dummy )
  SET rptreport->m_recsize = 104
  SET rptreport->m_reportname = "IC_DOT_REPORT_LAYOUT"
  SET rptreport->m_pagewidth = 8.50
  SET rptreport->m_pageheight = 11.00
  SET rptreport->m_orientation = rpt_landscape
  SET rptreport->m_marginleft = 0.50
  SET rptreport->m_marginright = 0.50
  SET rptreport->m_margintop = 0.50
  SET rptreport->m_marginbottom = 0.50
  SET rptreport->m_horzprintoffset = _xshift
  SET rptreport->m_vertprintoffset = _yshift
  SET _yoffset = rptreport->m_margintop
  SET _xoffset = rptreport->m_marginleft
  SET _hreport = uar_rptcreatereport (rptreport ,_outputtype ,rpt_inches )
  SET _rpterr = uar_rptseterrorlevel (_hreport ,rpt_error )
  SET _rptstat = uar_rptstartreport (_hreport )
  SET _rptpage = uar_rptstartpage (_hreport )
  CALL _createfonts (0 )
  CALL _createpens (0 )
 END ;Subroutine
 SUBROUTINE  _createfonts (dummy )
  SET rptfont->m_recsize = 52
  SET rptfont->m_fontname = rpt_times
  SET rptfont->m_pointsize = 10
  SET rptfont->m_bold = rpt_off
  SET rptfont->m_italic = rpt_off
  SET rptfont->m_underline = rpt_off
  SET rptfont->m_strikethrough = rpt_off
  SET rptfont->m_rgbcolor = rpt_black
  SET _times100 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 20
  SET _times200 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 10
  SET rptfont->m_bold = rpt_on
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
  SET rptpen->m_penwidth = 0.022
  SET _pen22s0c0 = uar_rptcreatepen (_hreport ,rptpen )
  SET rptpen->m_penwidth = 0.000
  SET _pen0s0c0 = uar_rptcreatepen (_hreport ,rptpen )
  SET rptpen->m_penwidth = 0.012
  SET _pen12s0c0 = uar_rptcreatepen (_hreport ,rptpen )
 END ;Subroutine
 CALL echo ("Starting Preprocessing Code" )
 IF ((validate (i18nuar_def ,999 ) = 999 ) )
  CALL echo ("Declaring i18nuar_def" )
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ,(p4 = f8 ) ) = i4 WITH
  persist
  DECLARE uar_i18ngetmessage ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ) = vc WITH persist
  DECLARE uar_i18nbuildmessage () = vc WITH persist
 ENDIF
 DECLARE i18nhandle = i4 WITH persistscript
 CALL uar_i18nlocalizationinit (i18nhandle ,curprog ,"" ,curcclrev )
 DECLARE scaption1 = vc
 DECLARE scaption2 = vc
 DECLARE scaption3 = vc
 DECLARE scaption4 = vc
 DECLARE scaption5 = vc
 DECLARE scaption6 = vc
 DECLARE scaption7 = vc
 DECLARE scaption8 = vc
 DECLARE scaption9 = vc
 DECLARE scaption10 = vc
 DECLARE scaption11 = vc
 DECLARE scaption12 = vc
 DECLARE scaption13 = vc
 DECLARE scaption14 = vc
 DECLARE scaption15 = vc
 DECLARE endofreport = vc
 DECLARE rptlabel1 = vc
 DECLARE rptlabel2 = vc
 DECLARE rptlabel3 = vc
 DECLARE nonhsnlocation = vc
 DECLARE infoboxmessage = vc
 DECLARE emptyreply = vc
 SET scaption1 = uar_i18ngetmessage (i18nhandle ,"sCap1" ,"Facility Name" )
 SET scaption3 = uar_i18ngetmessage (i18nhandle ,"sCap3" ,"Date Range" )
 SET scaption4 = uar_i18ngetmessage (i18nhandle ,"sCap4" ,"Location" )
 SET scaption5 = uar_i18ngetmessage (i18nhandle ,"sCap5" ,"Date Range" )
 SET scaption6 = uar_i18ngetmessage (i18nhandle ,"sCap6" ,"Month-Year" )
 SET scaption7 = uar_i18ngetmessage (i18nhandle ,"sCap7" ,"Antimicrobial Agent" )
 SET scaption8 = uar_i18ngetmessage (i18nhandle ,"sCap8" ,"Drug-specific Antimicrobial Days" )
 SET scaption9 = uar_i18ngetmessage (i18nhandle ,"sCap9" ,"Denominator Data" )
 SET scaption10 = uar_i18ngetmessage (i18nhandle ,"sCap10" ,"Total" )
 SET scaption11 = uar_i18ngetmessage (i18nhandle ,"sCap11" ,"IV" )
 SET scaption12 = uar_i18ngetmessage (i18nhandle ,"sCap12" ,"IM" )
 SET scaption13 = uar_i18ngetmessage (i18nhandle ,"sCap13" ,"Digestive" )
 SET scaption14 = uar_i18ngetmessage (i18nhandle ,"sCap14" ,"Respiratory" )
 SET scaption15 = uar_i18ngetmessage (i18nhandle ,"sCap15" ,"Days Present" )
 SET scaption16 = uar_i18ngetmessage (i18nhandle ,"sCap16" ,"Admissions" )
 SET rptlabel1 = uar_i18ngetmessage (i18nhandle ,"rptLabel1" ,"Antimicrobial Use - FacWideIN" )
 SET rptlabel2 = uar_i18ngetmessage (i18nhandle ,"rptLabel2" ,"Days of Therapy by Location" )
 SET rptlabel3 = uar_i18ngetmessage (i18nhandle ,"rptLabel3" ,"Antimicrobial Use by NHSN Location" )
 SET endofreport = uar_i18ngetmessage (i18nhandle ,"endRpt" ,"**** END REPORT ****" )
 SET nonhsnlocation = uar_i18ngetmessage (i18nhandle ,"noNhsnLocation" ,
  "****No NHSN Locations have been selected****" )
 SET emptyreply = uar_i18ngetmessage (i18nhandle ,"emptyReplyMessageText" ,
  "****No antimicrobial administrations found****" )
 IF ((reply->no_nhsn_flag = 1 ) )
  SET infoboxmessage = nonhsnlocation
 ELSEIF ((reply->empty_reply_ind = 1 ) )
  SET infoboxmessage = emptyreply
 ENDIF
 CALL initializereport (0 )
 SET _fenddetail = (rptreport->m_pagewidth - rptreport->m_marginbottom )
 IF (( $OUTPUT = 0 ) )
  SET _fholdenddetail = _fenddetail
  CALL query1 (0 )
  SET _fenddetail = _fholdenddetail
 ENDIF
 IF (( $OUTPUT = 1 ) )
  SET _rptstat = uar_rptdestroyreport (_hreport )
  SET _hreport = 0
  SET date_range = build (format (reply->from_date ,"MM/DD/YYYY ;;D" ) ," - " ,format (reply->to_date
     ,"MM/DD/YYYY ;;D" ) )
  SELECT INTO  $OUTDEV
   DETAIL
    col 0 ,
    IF ((reply->rpt_type_flag = 0 ) ) rptlabel1
    ELSEIF ((reply->rpt_type_flag = 1 ) ) rptlabel2
    ELSE rptlabel3
    ENDIF
    ,row + 1 ,
    scaption1 ,
    "," ,
    scaption3 ,
    row + 1 ,
    reply->facility_name ,
    "," ,
    date_range ,
    row + 1 ,
    IF ((reply->rpt_type_flag > 0 ) ) ",,," ,scaption8 ,",,,,," ,scaption9 ,row + 1 ,scaption6 ,"," ,
     scaption4 ,"," ,scaption7 ,"," ,scaption10 ,"," ,scaption11 ,"," ,scaption12 ,"," ,scaption13 ,
     "," ,scaption14 ,"," ,scaption15 ,row + 1 ,
     FOR (month_idx = 1 TO size (reply->months ,5 ) )
      FOR (loc_idx = 1 TO size (reply->months[month_idx ].locations ,5 ) )
       FOR (agent_idx = 1 TO size (reply->months[month_idx ].locations[loc_idx ].agents ,5 ) )
        reply->months[month_idx ].month_year ,"," ,reply->months[month_idx ].locations[loc_idx ].
        location_name ,"," ,reply->months[month_idx ].locations[loc_idx ].agents[agent_idx ].
        agent_name ,"," ,
        IF ((reply->months[month_idx ].locations[loc_idx ].agents[agent_idx ].not_available_flag !=
        1 ) ) reply->months[month_idx ].locations[loc_idx ].agents[agent_idx ].total ,"," ,reply->
         months[month_idx ].locations[loc_idx ].agents[agent_idx ].iv ,"," ,reply->months[month_idx ]
         .locations[loc_idx ].agents[agent_idx ].im ,"," ,reply->months[month_idx ].locations[
         loc_idx ].agents[agent_idx ].digestive ,"," ,reply->months[month_idx ].locations[loc_idx ].
         agents[agent_idx ].respiratory
        ELSE "N/A" ,"," ,"N/A" ,"," ,"N/A" ,"," ,"N/A" ,"," ,"N/A"
        ENDIF
        ,row + 1
       ENDFOR
       ,reply->months[month_idx ].month_year ,"," ,reply->months[month_idx ].locations[loc_idx ].
       location_name ,",,,,,,," ,reply->months[month_idx ].locations[loc_idx ].days_present ,row + 1
      ENDFOR
     ENDFOR
    ELSE ",," ,scaption8 ,",,,,," ,scaption9 ,row + 1 ,scaption6 ,"," ,scaption7 ,"," ,scaption10 ,
     "," ,scaption11 ,"," ,scaption12 ,"," ,scaption13 ,"," ,scaption14 ,"," ,scaption15 ,"," ,
     scaption16 ,row + 1 ,
     FOR (month_idx = 1 TO size (reply->months ,5 ) )
      FOR (loc_idx = 1 TO size (reply->months[month_idx ].locations ,5 ) )
       FOR (agent_idx = 1 TO size (reply->months[month_idx ].locations[loc_idx ].agents ,5 ) )
        reply->months[month_idx ].month_year ,"," ,reply->months[month_idx ].locations[loc_idx ].
        agents[agent_idx ].agent_name ,"," ,
        IF ((reply->months[month_idx ].locations[loc_idx ].agents[agent_idx ].not_available_flag !=
        1 ) ) reply->months[month_idx ].locations[loc_idx ].agents[agent_idx ].total ,"," ,reply->
         months[month_idx ].locations[loc_idx ].agents[agent_idx ].iv ,"," ,reply->months[month_idx ]
         .locations[loc_idx ].agents[agent_idx ].im ,"," ,reply->months[month_idx ].locations[
         loc_idx ].agents[agent_idx ].digestive ,"," ,reply->months[month_idx ].locations[loc_idx ].
         agents[agent_idx ].respiratory
        ELSE "N/A" ,"," ,"N/A" ,"," ,"N/A" ,"," ,"N/A" ,"," ,"N/A"
        ENDIF
        ,row + 1
       ENDFOR
       if ($ADMISSIONS > 0)
       	 reply->months[month_idx ].locations[loc_idx ].admissions = $ADMISSIONS
       endif
       	,reply->months[month_idx ].month_year ,",,,,,,," ,reply->months[month_idx ].locations[loc_idx
       ].days_present ,"," ,reply->months[month_idx ].locations[loc_idx ].admissions ,row + 1
 
      ENDFOR
     ENDFOR
    ENDIF
   WITH format = variable ,noheading ,formfeed = none ,maxrow = 1 ,maxcol = 3000
  ;end select
 ENDIF
 iF (( $OUTPUT = 2 ) and ($DEBUG_IND = 0) )
  SET _rptstat = uar_rptdestroyreport (_hreport )
  SET _hreport = 0
  FREE SET pdata
  RECORD pdata (
    1 fac [* ]
      2 pqual [* ]
        3 fname = vc
        3 pid = f8
        3 npage = i4
        3 pname = vc
        3 eid = f8
        3 aeid = f8
        3 aedesc = vc
        3 data = vc
  )
  DECLARE buildparams (null ) = i2
  DECLARE openpage ((sfile = vc ) ) = i2
  DECLARE sfile1 = vc WITH protect ,constant ("AU_" )
  DECLARE cur_timestamp = vc WITH protect ,constant (format (cnvtdatetime (curdate ,curtime3 ) ,
    "MMDDYYYY;;Q" ) )
  DECLARE facwidein = i2 WITH protect ,constant (0 )
  DECLARE no_nhsn_locs_selected = i2 WITH protect ,constant (1 )
  DECLARE ploc = vc WITH protect
  DECLARE sdata = vc WITH protect
  DECLARE stat = i4 WITH protect ,noconstant (0 )
  DECLARE lstat = i4 WITH protect ,noconstant (0 )
  CALL echo (sfile1 )
  SET ploc =  $FILE
  SET lstat = size (ploc ,1 )
  SET stat = findstring ("\" ,ploc ,1 ,1 )
  IF ((stat = 0 ) )
   SET stat = findstring ("/" ,ploc ,1 ,1 )
  ENDIF
  CALL echo (build ("lStat->" ,lstat ,"/stat->" ,stat ) )
  IF ((stat < lstat ) )
   CALL echo ("Adding '\' to the end of the file location..." )
   SET ploc = concat (trim (ploc ) ,"\" )
  ENDIF
  SET ploc = replace (ploc ,"\" ,"\\" ,0 )
  SET ploc = replace (ploc ,"/" ,"\\" ,0 )
  SET lstat = buildparams (null )
  CALL echo ("calling html" )
  SET lstat = openpage ("cov_labid_export.html" )
  CALL echo ("ending call html" )
  SUBROUTINE  buildparams (null )
   CALL echo ("Starting BuildParams....." )
   DECLARE icnt = i4 WITH protect ,noconstant (0 )
   DECLARE stemp = vc WITH protect
   DECLARE type = vc WITH protect
   CALL echo (build ("cnt -->" ,cnt ) )
   SET count = 0
   FOR (mcnt = 1 TO size (reply->months ,5 ) )
    FOR (lcnt = 1 TO size (reply->months[mcnt ].locations ,5 ) )
     SET count = (count + 1 )
     IF ((count = 1 ) )
      SET stemp = concat (trim (stemp ) ,"$$" ,concat (trim (reply->facility_name ,4 ) ,"_" ,trim (
         reply->months[mcnt ].locations[lcnt ].location_name ,4 ) ,"_" ,trim (reply->months[mcnt ].
         month_year ,4 ) ,"_" ,cur_timestamp ) ,"|" ,trim (trim (reply->facility_name ,4 ) ) ,"|" ,
       replace (trim (reply->months[mcnt ].locations[lcnt ].xml_string ) ,"'" ,"\'" ) )
     ELSE
      SET stemp = concat (trim (stemp ) ,"@@" ,concat (trim (reply->facility_name ,4 ) ,"_" ,trim (
         reply->months[mcnt ].locations[lcnt ].location_name ,4 ) ,"_" ,trim (reply->months[mcnt ].
         month_year ,4 ) ,"_" ,cur_timestamp ) ,"|" ,trim (trim (reply->facility_name ,4 ) ) ,"|" ,
       replace (trim (reply->months[mcnt ].locations[lcnt ].xml_string ) ,"'" ,"\'" ) )
     ENDIF
    ENDFOR
   ENDFOR
   IF ((reply->rpt_type_flag = facwidein )
   AND (reply->no_nhsn_flag = no_nhsn_locs_selected ) )
    SET stemp = concat (ploc ,"$$" ,"1" ,"|" ,trim (cnvtstring (0 ) ) ,"$$" ,sfile1 ,trim (stemp ) )
   ELSE
    SET stemp = concat (ploc ,"$$" ,"1" ,"|" ,trim (cnvtstring (count ) ) ,"$$" ,sfile1 ,trim (stemp
      ) )
   ENDIF
   SET sdata = stemp
   CALL echo ("Ending BuildParams....." )
   CALL echo (build ("sTemp..." ,stemp ,"...ENDsTemp" ) )
   RETURN (1 )
  END ;Subroutine
  SUBROUTINE  openpage (sfile )
   CALL echo ("calling OpenPage" )
   FREE SET replyout
   RECORD replyout (
     1 info_line [* ]
       2 new_line = vc
   )
   FREE SET getreply
   RECORD getreply (
     1 info_line [* ]
       2 new_line = vc
     1 data_blob = vc
     1 data_blob_size = i4
     1 status_data
       2 status = c1
       2 subeventstatus [1 ]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FREE SET getrequest
   RECORD getrequest (
     1 module_dir = vc
     1 module_name = vc
     1 basblob = i2
   )
   SET getrequest->module_dir = "ccluserdir:"
   SET getrequest->module_name = trim (sfile )
   SET getrequest->basblob = 1
   EXECUTE eks_get_source WITH replace (request ,getrequest ) ,
   replace (reply ,getreply )
   CALL echo ("after eks_get_source" )
   FREE SET putreply
   RECORD putreply (
     1 info_line [* ]
       2 new_line = vc
     1 status_data
       2 status = c1
       2 subeventstatus [1 ]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FREE SET putrequest
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
   CALL echo (build ("sData ------------>" ,sdata ) )
   CALL echorecord (getreply )
   SET putrequest->source_dir =  $OUTDEV
   SET putrequest->isblob = "1"
   SET putrequest->document = replace (getreply->data_blob ,"sXMLData" ,sdata ,0 )
   SET putrequest->document_size = size (putrequest->document )
   CALL echorecord (putrequest )
   EXECUTE eks_put_source WITH replace (request ,putrequest ) ,
   replace (reply ,putreply )
   RETURN (1 )
  eND ;Subroutine
 ENDIF
 
 
 CALL finalizereport (_sendto )
#exit_script
 call echo(build2("html_output=",html_output))
END GO
