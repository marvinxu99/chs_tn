/***********************Change Log*************************
VERSION  DATE       ENGINEER            COMMENT
-------	 -------    -----------         -------------------
1.0		5/28/2018	Ryan Gotsche		CR-2080 - Create Surgery Schedule Report
2.0		5/28/2018	ccummin4			CR-3230 - Create Surgery Schedule Report
**************************************************************/
 
 
/***********************Program Notes*************************
Description - Report to display the surgery schedule via Reporting Portal.
 
Tables read: ORGANIZATION, PRSNL, SURGICAL_CASE, PERSON, ENCOUNTER,
	ENCNTR_ALIAS, SCH_EVENT_ATTACH, SCH_EVENT, SURG_CASE_PROCEDURE,
	SCH_EVENT_PATIENT, SCH_EVENT_DETAIL, SCH_EVENT_COMM, LONG_TEXT
 
Tables updated: None
**************************************************************/
 
drop program cov1_sn_sched go
create program cov1_sn_sched
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Surgical Area" = 0
	, "Start Date" = "CURDATE"               ;* Enter Start Date
	, "End Date" = "CURDATE"
 
with OUTDEV, Facility, Surg_Area, StartDate, EndDate
 
declare syp=i4
declare eyp=i4
declare cnt=i4
declare num=i4
DECLARE Page_CNT=i4
dECLARE AREA_CNT=I4
declare date_cnt=i4
declare romm_cnt=i4
dECLARE s_temp=VC
declare d_temp=vc
DECLARE y_POS=I4
DECLARE stm=VC
DECLARE REPORT_DATES=VC
declare c_lines=i4
DECLARE P_LINES=I4
declare sd=dq8
declare CurrentOp=vc
SET SD=CNVTDATETIME ( CNVTDATE ( $StartDate , "mmddyyyy" ), 0 )
declare ed=dq8
SET ed=CNVTDATETIME ( CNVTDATE ( $EndDate , "mmddyyyy" ), 0 )
DECLARE canceled_var = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,14233 ,"CANCELED" )),protect
DECLARE deleted_var = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,14233 ,"DELETED" )),protect
DECLARE unschedulable_var = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,14233 ,"UNSCHEDULABLE")),protect
DECLARE pending_var = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,14233 ,"PENDING")),protect
DECLARE finnbr_var = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,319 ,"FINNBR" ) ) ,protect
DECLARE mrn_var = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,319 ,"MRN" ) ) ,protect
DECLARE home_var = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,43 ,"HOME" ) ) ,protect
DECLARE altphone_var = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,43 ,"ALTERNATE" ) ) ,protect
DECLARE print_by = c100
DECLARE SURG_PROC_TEXT=VC
declare Surg_P_Text=vc
declare Surg_Proc_temp=vc
DECLARE SURG_PROC_ANEST=VC
DECLARE SURG_ASSIST=VC
DECLARE PROC_COUNT=I4
DECLARE AS_of=VC
Declare ORG_name =VC
SET ORG_NAME=""
SELECT INTO "nl:"
FROM ORGANIZATION   ORG
WHERE ORG.organization_id=$FACILITY
DETAIL
	ORG_NAME=ORG.org_name
WITH NOCOUNTER
IF (ORG_NAME="")
	GO TO EXITSCRIPT
ENDIF
RECORD SG(
	1 PROC[*]
		2 TXT=VC
		)
SET AS_OF=concat("Cases Scheduled as of ",format(CNVTDATETIME ( curdate , curtime ),"mm/dd/yyyy hh:mm;;D"))
if (sd = ed)
	set Report_Dates=concat("Cases Scheduled for {B}", format(sd,"MM/DD/YYYY;;d"))
else
	SET REPORT_DATES=CONCAT("Cases Scheduled for {B}",FORMAT(SD,"MM/DD/YYYY;;D")," - ", FORMAT(ED,"MM/DD/YYYY;;D"))
endif
IF (validate (reqinfo->updt_id ,999 ) != 999  )
  SELECT INTO "nl:"
   p_name = trim (p.name_full_formatted )
   FROM (prsnl p )
   PLAN (p
    WHERE (p.person_id = reqinfo->updt_id ) )
   DETAIL
    print_by = trim (p_name ,3 )
   WITH nocounter
  ;end select
 ENDIF
/**************************************************************
; SUBROUTINES
**************************************************************/
record line_text
( 1 line_cnt = i2
  1 lns[*]
    2 line = vc
)
 
DECLARE linelen= i4
Set linelen = 0
SUBROUTINE CalcLineLen( txt, maxlength )
  set c = maxlength
  set linelen = maxlength
  WHILE (c > maxlength-10)
    set tempchar = substring(c,1,txt)
    IF ((tempchar = " ") or (tempchar=",") or (tempchar=";"))
      set linelen=c
      set c=0
    endif
    set c = c - 1
  ENDWHILE
END ;subroutine
SUBROUTINE PARSE_TEXT( txt, maxlength )
  set holdstr = txt
  set line_text->line_cnt = 0
 
  WHILE (textlen(trim(holdstr)) > 0 )
    set line_text->line_cnt = line_text->line_cnt + 1
    set stat = alterlist(line_text->lns,line_text->line_cnt)
    call CalcLineLen( holdstr, maxlength)
    set line_text->lns[line_text->line_cnt].line = TRIM(substring(1,linelen,holdstr),3)
    set holdstr = substring( linelen+1, textlen(holdstr)-linelen, holdstr)
  ENDWHILE
END ;sub
/**************************************************************
; get the records
**************************************************************/
RECORD CS(
		1 PROC[*]
			2 CS_PR_ID=F8
			2 CAT_ID=F8
			2 DESC=VC
			2 P_TEXT=Vc
			2 proc=vc
			2 SURGEON=VC
			2 Anest_Type=vc
			)
DECLARE PROC_COUNT=I4
SET PROC_COUNT=0
;go to exitscript
SELECT distinct INTO $outdev ;"nl:"
	sc.sch_event_id
	,Surg_Date=CNVTDATETIME ( CNVTDATE ( format(sc.sched_start_dt_tm,"mmddyyyy;;d"), "mmddyyyy" ), 0 )
	;Format(sc.sched_start_dt_tm,"MM/dd/yyyy")
	,Surg_DtTm=	sc.sched_start_dt_tm
	,dur = sc.sched_dur ";L"
	,sc.sched_surg_area_cd
	, SURG_AREA = substring(1,20,UAR_GET_CODE_DISPLAY(SC.SCHED_SURG_AREA_CD))
	, SCHED_OP = UAR_GET_CODE_DISPLAY(SC.SCHED_OP_LOC_CD)
	,sl=SC.SCHED_OP_LOC_CD
	, SCHED_PAT_TYPE = TRIM(UAR_GET_CODE_DISPLAY(SC.SCHED_PAT_TYPE_CD))
	, sc.sched_type_cd
	, Priority = UAR_GET_CODE_DISPLAY(SC.SCHED_TYPE_CD)
	, CASE_NUMBER=TRIM(sc.surg_case_nbr_formatted)
	, Patient = p.name_full_formatted
	, gender = substring (1 ,10 ,uar_get_code_display (p.sex_cd ) )
	, age = CNVTAGE(P.BIRTH_DT_TM, sc.sched_start_dt_tm,0)
	, DOB=format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),'mm/dd/yyyy;;Q')
	, sc.encntr_id
	,eloc = substring (1 ,10 ,uar_get_code_display (e.loc_nurse_unit_cd ) )
  	,enctype = substring (1 ,7 ,uar_get_code_display (e.encntr_type_cd ) )
  	,facility = substring (1 ,55 ,uar_get_code_description (e.loc_facility_cd ) )
  	,room = substring (1 ,4 ,uar_get_code_display (e.loc_room_cd ) )
  	,bed = substring (1 ,4 ,uar_get_code_display (e.loc_bed_cd ) )
  	,IP_ROOM=evaluate2(
  		if(trim(substring (1 ,4 ,uar_get_code_display (e.loc_room_cd ) ))="")
  			" "
  		else
  			if (trim(substring (1 ,4 ,uar_get_code_display (e.loc_bed_cd ) ))="")
  				concat("Room: ",trim(substring (1 ,4 ,uar_get_code_display (e.loc_room_cd ) )))
  			else
  				concat("Room: ",trim(substring (1 ,4 ,uar_get_code_display (e.loc_bed_cd ) )),"-",
  				trim(substring (1 ,4 ,uar_get_code_display (e.loc_room_cd ) )))
  			endif
  		endif)
  	,fin = ea.alias
  	,mrn = ea1.alias
  	,status = substring (1 ,15 ,uar_get_code_display (e.encntr_status_cd ) )
	,Primary_Surgeon=evaluate2(
		if (sc.surgeon_prsnl_id=0)
			pr.name_full_formatted
		else
			sed16.oe_field_display_value
		endif)
	, Procedure=trim(uar_get_code_description(scp.sched_surg_proc_cd),3)
	, scp.sched_primary_surgeon_id
	, Surgeon=spr.name_full_formatted
	, surgeon2 = trim(sed17.oe_field_display_value,3)
	, proc_seq=scp.sched_seq_num
	, proc_text = TRIM(replace (scp.proc_text ,concat (char (13 ) ,char (10 ) ) ,"; " ),3 )
	, anes_type = uar_get_code_display (scp.sched_anesth_type_cd )
	, surgcomment = TRIM(replace (l.long_text ,concat (char (13 ) ,char (10 ) ) ,"; " ),3 )
	,cl=textlen(TRIM(replace (l.long_text ,concat (char (13 ) ,char (10 ) ) ,"; " ),3 ))
	, SC.create_dt_tm "@SHORTDATETIME"
	,P_TEXT_LEN=SUM(TEXTLEN(TRIM(scpX.proc_text ,3 )))
    ,P_CNT=COUNT(SCPX.order_id)
    , Inpatient_Proc = uar_get_code_display(scp.sched_ud1_cd)
    , MODIFIER=scp.modifier
;	, phone = ph.phone_num
  	,alt_phone = ph2.phone_num
  	,phone_type2 = uar_get_code_display (ph2.phone_type_cd )
  	,ph2.updt_dt_tm
  	,anes_type = uar_get_code_display (scp.sched_anesth_type_cd )
 
 
FROM
	surgical_case   sc
	, prsnl   pr
	, Person p
	,encounter e
    ,encntr_alias ea
    ,encntr_alias ea1
    ,sch_event_attach sea
    ,sch_event se
    ,surg_case_procedure scp
    ,sch_event_patient sep
    ,prsnl spr
    ,sch_event_detail sed16
    ,sch_event_detail sed17
 
    ,sch_event_comm sec
    ,long_text l
	, DUMMYT   DSPC
	, sch_event_attach seaX
	, surg_case_procedure scpX
 
	,phone ph
    ,phone ph2
 
 
plan sc where sc.sched_surg_area_cd=$Surg_Area
and sc.active_ind=1
and sc.cancel_dt_tm=null
and ((sc.sched_start_dt_tm between
	CNVTDATETIME ( CNVTDATE ( $StartDate , "mmddyyyy" ), 0 )
	AND
	CNVTDATETIME ( CNVTDATE ( $EndDate , "mmddyyyy" ), 2359 ) )
	)
 
join pr where pr.person_id=sc.surgeon_prsnl_id
 
join p where p.person_id=sc.person_id
JOIN e WHERE e.encntr_id = sc.encntr_id
	AND e.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime)
	AND e.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime )
	AND e.active_ind = 1
JOIN ea WHERE ea.encntr_id = outerjoin (sc.encntr_id )
	AND ea.encntr_alias_type_cd = outerjoin (finnbr_var )
	AND ea.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime ))
   	AND ea.end_effective_dt_tm >= outerjoin (cnvtdatetime (curdate ,curtime ))
   	AND ea.active_ind  = outerjoin (1 )
JOIN ea1 WHERE ea1.encntr_id = sc.encntr_id
	AND ea1.encntr_alias_type_cd = mrn_var
	AND ea1.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime )
	AND ea1.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime )
	AND ea1.active_ind = 1
JOIN sea WHERE sea.sch_event_id = sc.sch_event_id
	AND sea.state_meaning = "ACTIVE"
	AND sea.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" )
	AND sea.active_ind = 1
	AND sea.order_status_cd != 2542.00
JOIN se WHERE se.sch_event_id = sc.sch_event_id
	 AND NOT se.sch_state_cd IN (canceled_var,deleted_var,unschedulable_var,pending_var )
	 AND se.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" )
	 AND se.active_ind = 1
JOIN scp WHERE scp.order_id=sea.order_id
JOIN sep WHERE sep.sch_event_id = se.sch_event_id
	AND sep.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" )
	AND sep.active_ind = 1
join spr where spr.person_id=scp.sched_primary_surgeon_id
JOIN sed16 WHERE se.sch_event_id = sed16.sch_event_id
	AND sed16.oe_field_meaning = "SURGEON1"
	AND sed16.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" )
	AND sed16.active_ind = 1
JOIN sed17 WHERE sed17.sch_event_id = outerjoin (se.sch_event_id )
	AND sed17.oe_field_meaning =   outerjoin ("SURGEON2" )
	AND sed17.version_dt_tm = outerjoin (cnvtdatetime ("31-DEC-2100 00:00:00.00" ) )
	AND sed17.active_ind = outerjoin (1 )
join sec WHERE sec.sch_event_id = outerjoin (se.sch_event_id )
	AND sec.sub_text_meaning = outerjoin ("SURGPRIVATE" )
	AND sec.version_dt_tm = outerjoin (cnvtdatetime ("31-DEC-2100 00:00:00.00" ))
    AND sec.active_ind = outerjoin (1 )
JOIN l WHERE l.long_text_id = outerjoin (sec.text_id )
JOIN ph WHERE ph.parent_entity_name = outerjoin ("PERSON" )
 	AND ph.parent_entity_id = outerjoin (sep.person_id )
 	AND ph.phone_type_cd = outerjoin (home_var )
 	AND ph.phone_type_seq = outerjoin (1 )
 	AND ph.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime ) )
  	AND ph.end_effective_dt_tm >= outerjoin (cnvtdatetime (curdate ,curtime ) )
  	AND ph.active_ind = outerjoin (1)
JOIN ph2 WHERE ph2.parent_entity_name = outerjoin ("PERSON" )
    AND ph2.parent_entity_id = outerjoin (ph.parent_entity_id )
    AND ph2.phone_num_key != outerjoin (ph.phone_num_key )
    AND ph2.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime ) )
    AND ph2.end_effective_dt_tm >= outerjoin (cnvtdatetime (curdate ,curtime ) )
    AND ph2.active_ind =outerjoin (1 )
JOIN DSPC
join seaX where seax.sch_event_id=sc.sch_event_id
	AND seaX.state_meaning = "ACTIVE"
	AND seaX.version_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00.00" )
	AND seaX.active_ind = 1
	AND seaX.order_status_cd != 2542.00
 
JOIN scpX WHERE ScpX.order_id=seaX.order_id
	and textlen(trim(scpx.proc_text,3))>1
 
ORDER BY
	Surg_Area
	,Surg_Date
	,SCHED_OP
	,Surg_DtTm
	,CASE_NUMBER
	,scp.surg_case_id
	,scp.sched_seq_num
 
 
Head Report
	CurrentOp=""
	Page_CNT=0
	Y_POS=5
	ROW 1
	AREA_CNT=0
	room_cnt=0
	;reset the procedure record
	STAT=ALTERLIST(CS->PROC ,0)
	PROC_COUNT=0
	"{CPI/10}"
HEAD PAGE
   Page_cnt=page_cnt+1
   m_numlines = 0
   y_pos = 5 ,
   row +1
   "{CPI/10}" ,
  CALL center (trim(Org_Name,3) ,1 ,90 ) ,
   y_pos=y_pos+20
   row + 1 ,
   "{CPI/10}" ,
   S_TEMP=trim(concat("Surgery Schedule - ",Surg_area),3)
   d_temp=format(Surg_date,"mm/dd/yyyy;;d")
   CALL center (s_temp ,1 ,90 ) ,
   "{CPI/14}"
   row + 1
   CALL center (d_temp ,1 ,105 ) ,
 
   y_pos=y_pos+45
   row+1, y_val= 792-y_pos
  ^{PS/newpath 2 setlinewidth   15 ^, y_val, ^ moveto  590 ^, y_val, ^ lineto stroke 20 ^, y_val, ^ moveto/}^
  "{CPI/14}",
	CALL print (calcpos (20 ,(y_pos  ) ) ) ,"{B}",SCHED_OP,"{ENDB}"
  	y_pos=y_pos+10,
   	row+1
   	if (SCHED_OP!=CurrentOP)
    	room_cnt=0;room_cnt+1
    endif
head  SURG_AREA
	iF (AREA_CNT>0)
		Y_POS=5
		break
	ENDIF
	AREA_CNT=AREA_CNT+1
head Surg_date
	if (date_cnt>0)
		Y_POS=5
		break
	endif
	date_cnt=date_cnt+1
 
 
HEAD CASE_NUMBER
;Calculate estimated lines for case record
	if (SCHED_OP!=CurrentOP)
		cxp=y_pos+76+40
	ELSE
		cxp=y_pos+76
	endif
	;calculate line for comment
	c_lines=(textlen(trim(surgcomment,3))/108)
	if (mod(textlen(trim(surgcomment,3)),108)=0)
		c_lines=c_lines-1
	endif
	cxp=cxp+(c_lines*8)
	;calculate lines for procedure text
	P_LINES=((P_TEXT_LEN+P_CNT-1)/100)
	if (mod(P_TEXT_LEN,100)=0)
		P_lines=P_lines-1
	endif
	CXP=CXP+(P_LINES*8)
	;pAGE IF IT WONT FIT ON THE PAGE
	IF (CXP >=725)
		Y_POS=5
		break
	ENDIF
	;*print room if changed****************************************************************************
	if (SCHED_OP!= CurrentOP)
		if (room_cnt>0)
			row+1
			y_pos=y_pos+10
			"{CPI/14}",
			CALL print (calcpos (20 ,(y_pos  ) ) ) ,"{B}",SCHED_OP,"{ENDB}"
	  		y_pos=y_pos+10,
		   	row+1
		endif
		room_cnt=room_cnt+1
		currentop=Sched_op
	endif
	;*********************************************************************************
	ROW+1
	STM=format (sc.sched_start_dt_tm ,"mm/dd/yy hh:mm;;q" ) ,
	"{CPI/16}",
	CALL print (calcpos (20 ,(y_pos  ) ) ) ,"{U}",SC.surg_case_nbr_formatted
	row+1
	CALL print (calcpos (150 ,(y_pos  ) ) ) ,"SURGEON: ",Primary_Surgeon
 
	ROW+1
	y_pos=y_pos+10
	CALL print (calcpos (25 ,(y_pos  ) ) ),
	STM,
	;CALL print (calcpos (100 ,(y_pos  ) ) ),SURG_AREA,
	;CALL print (calcpos (200 ,(y_pos  ) ) ),SCHED_OP,
	CALL print (calcpos (100 ,(y_pos  ) ) ),"DUR: ",DUR,
	CALL print (calcpos (150 ,(y_pos  ) ) ),"Patient: ",p.name_full_formatted,
	row+1
	CALL print (calcpos (440 ,(y_pos  ) ) ) ,"Anest: ",anes_type
 
	ROW+1
	y_pos=y_pos+10
	CALL print (calcpos (40 ,(y_pos  ) ) ),ip_room
	CALL print (calcpos (125,(y_pos  ) ) ),"DOB: ",DOB,
	CALL print (calcpos (250 ,(y_pos  ) ) ),"AGE: ",age," " ,gender
	CALL print (calcpos (440 ,(y_pos  ) ) ),"Inpt Proc?: ",Inpatient_Proc
	;CALL print (calcpos (50 ,(y_pos  ) ) ),gender
	ROW+1
	y_pos=y_pos+10
	CALL print (calcpos (40 ,(y_pos  ) ) ),"MRN: ",MRN,
	CALL print (calcpos (125 ,(y_pos  ) ) ),"Account: ",FIN,
 
	ROW +1
	CALL print (calcpos (250 ,(y_pos  ) ) ),"Type: ",enctype,
	CALL print (calcpos (330 ,(y_pos  ) ) ),"Scheduled As: ",SCHED_PAT_TYPE
	;if (trim(alt_phone,3)!="")
	;	CALL print (calcpos (449 ,(y_pos  ) ) ),"Alt: ",alt_phone
	;endif
	ROW+1
	y_pos=y_pos+10
	SURG_PROC_TEXT=""
	surg_p_text=""
	Surg_proc_temp=""
	SURG_PROC_ANEST=""
	SURG_ASSIST=trim(surgeon2,3)
	PROC_COUNT=0
	stat=ALTERLIST(SG->PROC,0)
 
 
Detail
	IF (PROC_COUNT=0)
		PROC_TEMP="1"
	ELSE
		PROC_TEMP="1"
		FOR (A=1 TO PROC_COUNT)
			IF(SCP.surg_case_proc_id=CS->PROC [A].CS_PR_ID)
				PROC_TEMP="0"
			ENDIF
		ENDFOR
	ENDIF
	IF (PROC_TEMP="1")
		PROC_COUNT=PROC_COUNT +1
		STAT=aLTERLIST(CS->PROC ,PROC_COUNT)
		CS->PROC [PROC_COUNT].CS_PR_ID=SCP.surg_case_proc_id
		CS->PROC [PROC_COUNT].CAT_ID=scp.sched_surg_proc_cd
		CS->PROC [PROC_COUNT].DESC=uar_get_code_description(scp.sched_surg_proc_cd)
		CS->PROC [PROC_COUNT].P_TEXT=proc_text
		CS->PROC [PROC_COUNT].proc=Procedure
		CS->PROC [PROC_COUNT].SURGEON=Surgeon
		CS->PROC [PROC_COUNT].Anest_Type =anes_type
		IF(SCP.sched_primary_ind=1)
			SURG_PROC_ANEST=anes_type
		ENDIF
		IF (Surgeon != Primary_Surgeon and Surgeon != surgeon2)
			IF (SURG_ASSIST="")
				SURG_ASSIST=TRIM(SURGEON,3)
			ELSE
				SURG_ASSIST=CONCAT(SURG_ASSIST,", ",TRIM(SURGEON,3))
			endif
		ENDIF
		IF (TEXTLEN(trim(proc_text,3))>1)
			IF(SURG_PROC_TEXT="")
				SURG_PROC_TEXT=TRIM(PROC_TEXT,3)
			ELSE
				SURG_PROC_TEMP=concat("*",proc_text,"*")
				if (SURG_PROC_TEXT!=SURG_PROC_TEMP)
					SURG_PROC_TEXT=CONCAT(SURG_PROC_TEXT,", ",TRIM(PROC_TEXT,3))
				ENDIF
			ENDIF
		ENDIF
		if (surg_p_text="")
			surg_p_text=procedure
		else
			surg_p_text=concat(surg_p_text,", ",procedure)
		endif
	endif
 
Foot CASE_NUMBER
	;PRINT ASSISTANT SURGEONS
	ROW +1
	y_pos=y_pos+2
	if (surg_assist!="")
		;y_pos=y_pos+2
		CALL print (calcpos (40 ,(y_pos  ) ) ),"Co-Provider: "
		CALL print (calcpos (96 ,(y_pos  ) ) ),surg_assist
		row+1
		y_pos=y_pos+10
	endif
	;PRINT PROCEDURE
	if (trim(surg_proc_text,3)="")
		surg_proc_text=surg_p_text
	else														;3230
		surg_proc_text=build2(surg_p_text,"; ",surg_proc_text)	;3230
	endif
	CALL print (calcpos (40 ,(y_pos  ) ) ),"PROCEDURE: "
;	CALL print (calcpos (96 ,(y_pos  ) ) ),MODIFIER
	call parse_text(SURG_PROC_TEXT,108)
	for (z=1 to line_text->line_cnt)
		CALL print (calcpos (96 ,(y_pos  ) ) ),line_text->lns [z].line
		ROW+1
  		y_pos=y_pos+8
  endfor
 ;PRINT SCHEDULE COMMENT
	row +1
	SURGCOMMENT=TRIM(SURGCOMMENT,3)
	y_pos=y_pos+2
	CALL print (calcpos (40 ,(y_pos  ) ) ),"COMMENT: ",
	call parse_text(SURGCOMMENT,108)
	for (z=1 to line_text->line_cnt)
		CALL print (calcpos (96 ,(y_pos  ) ) ),line_text->lns [z].line
		ROW+1
		y_pos=y_pos+8
	endfor
	if (line_text->line_cnt>0)
		y_pos=y_pos-8
	endif
	row+1
	y_pos=y_pos+24
	eyp=y_pos
	;reset the PROCEDURE record
	stat=ALTERLIST(CS->PROC     ,0)
	PROC_COUNT=0
foot Surg_Area
	room_cnt=0
	date_cnt=0
foot page
	y_pos=730
 	y_val= 792- y_pos
  ^{PS/newpath 2 setlinewidth   20 ^, y_val, ^ moveto  590 ^, y_val, ^ lineto stroke 20 ^, y_val, ^ moveto/}^
   row+1,
   "{CPI/16}" ,
   "{F/0}{CPI/16}" ,
   CALL print (calcpos (20 ,(y_pos ) ) ) , "Printed by: " , print_by ,
   CALL print (calcpos (250 ,(y_pos ) ) ) ,"PAGE:","{PAGE}"
   Y_POS=Y_POS+10
   CALL print (calcpos (20 ,(y_pos ) ) ) ,AS_OF
 
 
 
WITH OUTERJOIN=DPT,format = variable ,nullreport,noheading,dio = 08,maxcol = 500 ,maxrow = 1000
 
 
#ExitScript
 
end
go
 
