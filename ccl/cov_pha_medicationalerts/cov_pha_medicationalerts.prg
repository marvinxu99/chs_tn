/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:		April 2021
	Solution:			Pharmacy
	Source file name:	cov_pha_MedicationAlerts.prg
	Object name:		cov_pha_MedicationAlerts
	CR#:				9852
 
	Program purpose:
	Executing from:		CCL
 
	Note: **** Sync MOD Changes with program cov_pha_MedicationAlerts_ops.prg ****
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*
*
******************************************************************************************/
 
drop   program cov_pha_MedicationAlerts:DBA go
create program cov_pha_MedicationAlerts:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Facility" = 0
	, "Alert search string (*)" = ""         ;* Use (*) for wildcard
	, "Alert recipient search (*)" = ""      ;* Use (*) for wildcard
	;<<hidden>>"Reset Prompts" = 0
	, "Output To File" = 0
 
with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, FACILITY_PMPT,
	ALERT_NAME_PMPT, ALERT_USER_PMPT, OUTPUT_FILE
 
;BACKEND COMMAND
;;execute cov_pha_MedicationAlerts "MINE", "01-JAN-2021 0", "01-JAN-2021 23:59", 0.0, "", "", 1 GO
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record rec (
	1 rec_cnt				= i4
	1 username				= vc
	1 startdate				= vc
	1 enddate				= vc
	1 execute_start			= dq8
	1 execute_end			= dq8
	1 execute_time			= f8
	1 list[*]
		2 facility      	= vc
		2 nurse_unit    	= vc
		2 pat_name			= vc
		2 fin				= vc
		2 age				= vc
		2 receipient		= vc
		2 user				= vc
		2 position			= vc
		2 alert_name		= vc
		2 alert_dt			= dq8
		2 alert_seq			= i4
		2 order_type		= vc
		2 order_detail		= vc
		2 orig_ord_as_flag	= i2
		2 trigger			= vc
		2 interaction		= vc
		2 severity			= vc
		2 allergy			= vc
		2 override_reason	= vc
		2 override_comment	= vc
		2 cancelled_order	= vc
		2 encntr_type		= vc
		2 encntr_id			= f8
		2 person_id			= f8
		2 event_id			= f8
		2 order_id			= f8
		2 trigger_entity_id	= f8
		2 trigger_entity_name = vc
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare username           	= vc with protect
declare initcap()          	= c100
declare num				   	= i4 with noconstant(0)
 
declare FIN_VAR            	= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")),protect
 
declare OPR_FAC_VAR		   	= vc with noconstant(fillstring(1000," "))
declare OPR_ALERTNAME_VAR	= vc with noconstant(fillstring(1000," "))
declare OPR_ALERTUSER_VAR	= vc with noconstant(fillstring(1000," "))
;declare OPR_SUPPRESS_VAR	= vc with noconstant(fillstring(1000," "))
 
declare	START_DATETIME_VAR	= f8
declare END_DATETIME_VAR	= f8
 
 
/**************************************************************
; DVDev START CODING
**************************************************************/
; GET USERNAME FOR REPORT
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	rec->username = p.username
with nocounter
 
 
;**************************************************************
; SET DATE-RANGE VARIABLES
;**************************************************************
if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
	;=== PREVIOUS MONTH ===
	set START_DATETIME_VAR 	= datetimefind(cnvtlookbehind("1,M"),"M","B","B")
	set END_DATETIME_VAR 	= datetimefind(cnvtlookbehind("1,M"),"M","E","E")
 
	;=== SET FOR TESTING OPS-JOB EXTRACT RUN ===
;	set START_DATETIME_VAR = CNVTDATETIME("01-JUL-2021 00:00")
;	set END_DATETIME_VAR   = CNVTDATETIME("01-JUL-2021 23:59")
else
	set START_DATETIME_VAR = cnvtdatetime($START_DATETIME_PMPT)
	set END_DATETIME_VAR   = cnvtdatetime($END_DATETIME_PMPT)
endif
 
 
;**************************************************************
; SET DATA-FILE VARIABLES
;**************************************************************
declare filename_var	= vc with constant(build2("medalertsmonthly_", format(END_DATETIME_VAR, "yyyymm;;q"), ".csv"))
;;declare filename_var	= vc with constant(build2("testmedalertsmonthly_", format(END_DATETIME_VAR, "yyyymm;;q"), ".csv"))
;
declare dirname1_var	= vc with constant(build("cer_temp:",  filename_var))
declare dirname2_var	= vc with constant(build("$cer_temp/", filename_var))
 
;--PRODUCTION ASTREAM--
declare filepath_var	= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
													"_cust/to_client_site/ClinicalAncillary/Pharmacy/Med_Alerts/", filename_var))
 
;--DEVELOPMENT FILE PATH FOR TESTING-
;;declare filepath_var	= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
;;													"_cust/to_client_site/CernerCCL/", filename_var))
;
;-----------------------------
; DECLARE OUTPUT VALUES
;-----------------------------
declare output_var		= vc with noconstant("")
declare cmd				= vc with noconstant("")
declare len				= i4 with noconstant(0)
declare stat			= i4 with noconstant(0)
 
;-----------------------------
; DEFINE OUTPUT VALUE
;-----------------------------
if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
	set output_var = value(dirname1_var)   ;OPS JOB
else
	set output_var = value($OUTDEV)        ;DISPLAY TO SCREEN
endif
 
; SET FACILITY PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")		;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1)= 0.00)							;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																			;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
 
; SET ALERT NAME PROMPT VARIABLE
if ($ALERT_NAME_PMPT = null)
	set OPR_ALERTNAME_VAR = "1=1"
else
	set OPR_ALERTNAME_VAR = build2('cnvtupper(ede.dlg_name) = "', $ALERT_NAME_PMPT, '"')
endif
 
 
; SET ALERT USER PROMPT VARIABLE
if ($ALERT_USER_PMPT = null)
	set OPR_ALERTUSER_VAR = "1=1"
else
	set OPR_ALERTUSER_VAR = build2('cnvtupper(pl.name_full_formatted) = "', $ALERT_USER_PMPT, '"')
endif
 
 
; SET SUPPRESSED mCDS* ALERTS PROMPT VARIABLE (Code Set 800)
;if ($EXCLUDE_SUPPRESSED_PMPT = 0)
;	set OPR_SUPPRESS_VAR = "1=1"
;else
;	set OPR_SUPPRESS_VAR = "ede.override_reason_cd not in (2559792569, 2559690641, 2559687173, 2550130977, \
; 		2550129929, 3217106425, 2559589597, 2559589689, 2559588449,  275146697,  275146733,  275146701, \
;  		275146705, 275146709, 275146713, 275146717, 275146721, 275146725, 275146729, 1333, 1332, 1334, \
; 		2559589649, 2559589699, 2559588251, 27406431, 2557740641, 2559795975, 2559687147, \
;		1332, 1333, 1334, 2559687173, 27406431, 2550130977)"
;endif
 
 
; SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate 		= format(START_DATETIME_VAR, "mm/dd/yyyy hh:mm;;q") ;$START_DATETIME_PMPT
set rec->enddate   		= format(END_DATETIME_VAR, "mm/dd/yyyy hh:mm;;q")   ;$END_DATETIME_PMPT
 
set rec->execute_start	= cnvtdatetime(curdate,curtime3)
 
 
;====================================================
;MAIN SELECT FOR DATA
;====================================================
call echo(build2("*** EXECUTION START -> ", format(cnvtdatetime(curdate,curtime3), "mm/dd/yyyy hh:mm;;q")))
call echo("*** GET CORE DATA  ***")
 
select into "NL:"
from EKS_DLG_EVENT ede
 
	,(inner join ENCOUNTER e on e.encntr_id = ede.encntr_id
		and operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
		and e.active_ind = 1)
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = ede.encntr_id
		and ea.encntr_alias_type_cd = FIN_VAR ;1077
;		and ea.alias = "2100400055"
		and ea.active_ind = 1)
 
	,(inner join PERSON p on p.person_id = ede.person_id
;		and p.person_id = 16396313
		and p.active_ind = 1)
 
	,(inner join PRSNL pl on pl.person_id = ede.dlg_prsnl_id
		and pl.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and pl.active_ind = 1)
 
	,(left join ENCNTR_LOC_HIST elh on elh.encntr_id = ede.encntr_id
		and (elh.beg_effective_dt_tm < ede.dlg_dt_tm and elh.end_effective_dt_tm > ede.dlg_dt_tm)
		and elh.active_ind = 1)
 
	,(left join ORDERS o on o.order_id = ede.trigger_order_id
;		and o.order_id = 4132732051
		and o.active_ind = 1)
 
	,(left join LONG_TEXT lt on lt.long_text_id = ede.long_text_id
;		and lt.active_status_cd = 188 ;Active
		and lt.active_ind = 1)
 
where (ede.dlg_dt_tm between cnvtdatetime(START_DATETIME_VAR) and cnvtdatetime(END_DATETIME_VAR))
	and ede.dlg_name in ("MUL_MED!DRUGDRUG", "MUL_MED!DRUGALLERGY", "MUL_MED!ALLERGYDRUG", "MUL_MED!DRUGDUP",
		"PHA_EKM!PHA_CONTRAST_METFORMIN_2","PHA_EKM!PHA_DRC_W_HISTORY_EX_COV","PHA_EKM!PHA_LABDIGOXIN_2",
		"PHA_EKM!PHA_LR_ROCEPHIN_DDI_2","PHA_EKM!PHA_STD_ACET_MAXDOSE_5","PHA_EKM!PHA_STD_PREGLACTATION_10",
		"PHA_EKM!PHA_STP_ADE_WEIGHTCHANGE","PHA_EKM!PHA_STP_VITAMINK_1", "PHA_EKM!PHA_SYN_WARF_INR",
		"PHA_EKM!PHA_ZIPRASIDONE_ADMIN_1", "POC_EKM!POC_BISPHOSPHONATES_1", "POC_EKM!POC_DIGOXINLAB_1", "POC_EKM!POC_ROUTES_1")
	and ede.override_reason_cd not in (2559687173, 1332, 1333, 1334, 27406431)
	and parser(OPR_ALERTNAME_VAR)
	and parser(OPR_ALERTUSER_VAR)
;	and parser(OPR_SUPPRESS_VAR)
	and ede.active_ind = 1
;	and ede.dlg_event_id in ( 111602788.00,  111604038.00)
 
order by e.encntr_id, ede.dlg_event_id, o.order_id
 
head report
	cnt  = 0
	call alterlist(rec->list, 10)
 
detail
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 10)
		call alterlist(rec->list, cnt + 9)
	endif
 
 	rec->rec_cnt = cnt
 
	rec->list[cnt].facility  		= uar_get_code_display(e.loc_facility_cd)
	rec->list[cnt].nurse_unit		= uar_get_code_display(elh.loc_nurse_unit_cd)
	rec->list[cnt].pat_name			= p.name_full_formatted
	rec->list[cnt].fin				= ea.alias
	rec->list[cnt].age				= cnvtage(p.birth_dt_tm)
	rec->list[cnt].receipient		= pl.name_full_formatted
	rec->list[cnt].user				= pl.name_full_formatted
	rec->list[cnt].position			= uar_get_code_display(pl.position_cd)
	rec->list[cnt].alert_name		=
		if (trim(ede.modify_dlg_name) > " ") trim(ede.modify_dlg_name)
        else trim(ede.dlg_name)
        endif
	rec->list[cnt].alert_dt			= ede.dlg_dt_tm
	rec->list[cnt].alert_seq		= ede.seq
	rec->list[cnt].order_type		=
		if ((o.order_id > 0) and (o.orig_ord_as_flag = 0)) "Inpatient"
   		elseif ((o.order_id > 0) and (o.orig_ord_as_flag = 1)) "Prescription"
   		elseif ((o.order_id > 0) and (o.orig_ord_as_flag = 2)) "Home Medication"
   		elseif ((o.order_id > 0)) "Other"
		else null
   		endif
	rec->list[cnt].order_detail		= replace(replace(o.clinical_display_line, char(13), " ", 0), char(10), " ", 0)
	rec->list[cnt].trigger			= ;ede.trigger_entity_name
   		if (o.order_id > 0) ;;and o.orig_ord_as_flag = 0)
    		if (o.iv_ind = 1)
     			if (trim(o.ordered_as_mnemonic) > " ") trim(o.ordered_as_mnemonic)
     			else trim(o.hna_order_mnemonic)
     			endif
    		else
     			if (trim(o.ordered_as_mnemonic) > " " and trim(o.ordered_as_mnemonic) != trim(o.hna_order_mnemonic))
						concat(trim(o.hna_order_mnemonic), " (", trim(o.ordered_as_mnemonic), ")")
     			else trim(o.hna_order_mnemonic)
     			endif
    		endif
   		endif
	rec->list[cnt].override_reason	= uar_get_code_display(ede.override_reason_cd)
	rec->list[cnt].override_comment	= substring (1,100,lt.long_text)
	rec->list[cnt].cancelled_order	=
		if (o.order_id < 1 and ede.trigger_entity_name = "ORDER_CATALOG")
			uar_get_code_display(ede.trigger_entity_id)
		endif
;;		if (o.order_id < 1 and ede.trigger_entity_name = "ORDER_CATALOG")
;;			rec->list[cnt].override_reason = null
;;		endif
	rec->list[cnt].encntr_type		= uar_get_code_display(e.encntr_type_cd)
	rec->list[cnt].encntr_id		= e.encntr_id
	rec->list[cnt].person_id		= p.person_id
	rec->list[cnt].event_id			= ede.dlg_event_id
	rec->list[cnt].order_id			= if (o.order_id > 0) o.order_id else 0 endif
	rec->list[cnt].orig_ord_as_flag	= o.orig_ord_as_flag
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter ;, time=120
;
call echorecord(rec)
;go to exitscript
 
 
;============================================================================
; GET ALLERGY
;============================================================================
call echo("*** GET ALLERGY  ***")
 
select into "NL:"
from EKS_DLG_EVENT_ATTR edea
 
	,(inner join NOMENCLATURE n on n.nomenclature_id = edea.attr_id
		and n.active_ind = 1)
 
where expand(num, 1, size(rec->list, 5), edea.dlg_event_id, rec->list[num].event_id)
	and trim(edea.attr_name) = "NOMENCLATURE_ID"
	and edea.active_ind = 1
;	and edea.attr_id > 0
 
order by edea.dlg_event_id
 
detail
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(rec->list, 5), edea.dlg_event_id, rec->list[numx].event_id)
 
	if (idx > 0)
		rec->list[idx].allergy = n.source_string
	endif
 
;detail
;	numx = 0
;	idx = 0
;
;	idx = locateval(numx, 1, size(rec->list, 5), edea.dlg_event_id, rec->list[numx].event_id)
;
;    while(idx > 0)
;		rec->list[idx].allergy = n.source_string
;
; 		idx = locateval(numx, idx+1, size(rec->list, 5), edea.dlg_event_id, rec->list[numx].event_id)
;	endwhile
 
;with nocounter, expand = 1
with nocounter, expand = 2
 
 
;============================================================================
; GET INTERACTION
;============================================================================
call echo("*** GET INTERACTION  ***")
 
/*
select into "NL:"
from EKS_DLG_EVENT_ATTR edea
 
where expand(num, 1, size(rec->list, 5), edea.dlg_event_id, rec->list[num].event_id)
	and trim(edea.attr_name) in ("CATALOG_CD", "ORDER_ID")
	and edea.active_ind = 1
;	and edea.attr_id > 0
 
order by edea.dlg_event_id
 
detail
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(rec->list, 5), edea.dlg_event_id, rec->list[numx].event_id)
 
	if (idx > 0)
		rec->list[idx].interaction = uar_get_code_display(edea.attr_id)
	endif
 
;detail
;	numx = 0
;	idx = 0
;
;	idx = locateval(numx, 1, size(rec->list, 5), edea.dlg_event_id, rec->list[numx].event_id)
;
;    while(idx > 0)
;		rec->list[idx].interaction = uar_get_code_display(edea.attr_id)
;
; 		idx = locateval(numx, idx+1, size(rec->list, 5), edea.dlg_event_id, rec->list[numx].event_id)
;	endwhile
 
with nocounter, expand = 1
*/
 
select into "NL:"
from EKS_DLG_EVENT_ATTR edea,
	(dummyt d1 with seq = size(rec->list,5))
plan d1
join edea
	where edea.dlg_event_id = rec->list[d1.seq].event_id
	and trim(edea.attr_name) in ("CATALOG_CD", "ORDER_ID")
	and edea.active_ind = 1
;	and edea.attr_id > 0
 
order by edea.dlg_event_id
 
detail
	numx = 0
	idx = 0
 
	;idx = locateval(numx, 1, size(rec->list, 5), edea.dlg_event_id, rec->list[numx].event_id)
 
	;if (idx > 0)
		rec->list[d1.seq].interaction = uar_get_code_display(edea.attr_id)
	;endif
 
;detail
;	numx = 0
;	idx = 0
;
;	idx = locateval(numx, 1, size(rec->list, 5), edea.dlg_event_id, rec->list[numx].event_id)
;
;    while(idx > 0)
;		rec->list[idx].interaction = uar_get_code_display(edea.attr_id)
;
; 		idx = locateval(numx, idx+1, size(rec->list, 5), edea.dlg_event_id, rec->list[numx].event_id)
;	endwhile
 
with nocounter;, expand = 1
 
;============================================================================
; GET SEVERITY LEVEL
;============================================================================
call echo("*** GET SEVERITY LEVEL  ***")
 
select into "NL:"
from EKS_DLG_EVENT_ATTR edea
 
where expand(num, 1, size(rec->list, 5), edea.dlg_event_id, rec->list[num].event_id)
	and trim (edea.attr_name) in ("MAJOR_CONTRAINDICATED_IND", "SEVERITY*")
	and edea.active_ind = 1
 
order by edea.dlg_event_id
 
detail
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(rec->list, 5), edea.dlg_event_id, rec->list[numx].event_id)
 
	if (idx > 0)
		if (trim(edea.attr_name) = "MAJOR_CONTRAINDICATED_IND" and trim(edea.attr_value) = "1")
  			rec->list[idx].severity = "4"
  		elseif (trim(edea.attr_name) = "SEVERITY_LEVEL" and trim(rec->list[idx].severity) != "4")
   			rec->list[idx].severity = trim(edea.attr_value)
  		endif
	endif
 
;detail
;	numx = 0
;	idx = 0
;
;	idx = locateval(numx, 1, size(rec->list, 5), edea.dlg_event_id, rec->list[numx].event_id)
;
;    while(idx > 0)
;		if (trim(edea.attr_name) = "MAJOR_CONTRAINDICATED_IND" and trim(edea.attr_value) = "1")
;  			rec->list[idx].severity = "4"
;  		elseif (trim(edea.attr_name) = "SEVERITY_LEVEL" and trim(rec->list[idx].severity) != "4")
;   			rec->list[idx].severity = trim(edea.attr_value)
;  		endif
;
; 		idx = locateval(numx, idx+1, size(rec->list, 5), edea.dlg_event_id, rec->list[numx].event_id)
;	endwhile
 
with nocounter, expand = 1
 
 
;============================
; REPORT OUTPUT
;============================
call echo("*** GENERATING OUTPUT  ***")
 
set rec->execute_end 	= cnvtdatetime(curdate,curtime3)
set rec->execute_time	= datetimediff(rec->execute_end,rec->execute_start,8)
 
if (rec->rec_cnt > 0)
 
	if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
		set modify filestream
	endif
 
	select
		if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
			with nocounter, pcformat (^"^, ^,^, 1,0), format, format=stream, formfeed=none  ;no padding
		else
			with nocounter, separator = " ", format
		endif
 
	distinct into value(output_var)
 
		 alert_dt			= format(rec->list[d.seq].alert_dt, "mm/dd/yyyy hh:mm;;q")
		,alert_name			= substring(1,100,trim(rec->list[d.seq].alert_name))
		,order_type			= substring(1,50,trim(rec->list[d.seq].order_type))
		,trigger			= substring(1,100,trim(rec->list[d.seq].trigger))
		,order_detail		= substring(1,255,trim(rec->list[d.seq].order_detail))
		,interaction		= substring(1,200,trim(rec->list[d.seq].interaction))
		,severity			= substring(1,5,rec->list[d.seq].severity)
		,allergy			= substring(1,100,trim(rec->list[d.seq].allergy))
		,recipient			= substring(1,50,trim(rec->list[d.seq].receipient))
		,position			= substring(1,100,trim(rec->list[d.seq].position))
		,override_reason	= substring(1,100,trim(rec->list[d.seq].override_reason))
		,override_comment	= substring(1,100,trim(rec->list[d.seq].override_comment))
		,cancelled_order	= substring(1,100,trim(rec->list[d.seq].cancelled_order))
		,fin				= substring(1,12,rec->list[d.seq].fin)
		,age				= substring(1,5,rec->list[d.seq].age)
		,encntr_type		= substring(1,50,trim(rec->list[d.seq].encntr_type))
		,facility      		= substring(1,50,trim(rec->list[d.seq].facility))
		,unit    			= substring(1,40,trim(rec->list[d.seq].nurse_unit,3))
		,startdate			= rec->startdate
		,enddate			= rec->enddate
		,execute_start		= format(rec->execute_start, "mm/dd/yyyy hh:mm:ss;;q")
		,execute_end		= format(rec->execute_end, "mm/dd/yyyy hh:mm:ss;;q")
		,execute_time		= format(rec->execute_time, "####.##:##:##")
;;		,user				= substring(1,50,trim(rec->list[d.seq].user))
;;		,pat_name			= substring(1,40,trim(rec->list[d.seq].pat_name,3))
;;		,alert_seq			= rec->list[d.seq].alert_seq
;;		,username      		= rec->username
;;		,trigger_entity_id	= rec->list[d.seq].trigger_entity_id
;;		,order_id			= rec->list[d.seq].order_id
;;		,orig_ord_as_flag	= rec->list[d.seq].orig_ord_as_flag
;;		,event_id	  	 	= rec->list[d.seq].event_id
;;		,encntr_id     		= rec->list[d.seq].encntr_id
;;		,person_id			= rec->list[d.seq].person_id
;;		,rec_cnt			= rec->rec_cnt
 
	from
		 (DUMMYT d  with seq = value(size(rec->list,5)))
 
	plan d
 
	order by alert_name, alert_dt, facility, unit, rec->list[d.seq].encntr_id  ;;, rec->list[d.seq].event_id
 
	with nocounter, format, check, separator = " "
 
	;==============================
	; COPY FILE TO AStream
	;==============================
	if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
		set cmd = build2("cp ", dirname2_var, " ", filepath_var)
		set len = size(trim(cmd))
 
		call dcl(cmd, len, stat)
		call echo(build2(cmd, " : ", stat))
	endif
 
	;;call echo("**************************************************")
	;;call echo(build2("*** Directory/File name: ", dirname2_var))
	;;call echo("**************************************************")
 
else
 
	select into $OUTDEV
	from DUMMYT d
 
	head report
		call center("No records found for parameter input.",0,150)
 
	with nocounter
 
endif
 
call echo(build2("*** EXECUTION END -> ", format(cnvtdatetime(curdate,curtime3), "mm/dd/yyyy hh:mm;;q")))
 
#exitscript
end
go
 
 
