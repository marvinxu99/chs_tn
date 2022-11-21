/******************************************************************************
/******************************************************************************
 *                                                                            *
 *  Copyright Notice:  (c) 1983 Laboratory Information Systems &              *
 *                              Technology, Inc.                              *
 *       Revision      (c) 1984-2003 Cerner Corporation                       *
 *                                                                            *
 *  Cerner (R) Proprietary Rights Notice:  All rights reserved.               *
 *  This material contains the valuable properties and trade secrets of       *
 *  Cerner Corporation of Kansas City, Missouri, United States of             *
 *  America (Cerner), embodying substantial creative efforts and              *
 *  confidential information, ideas and expressions, no part of which         *
 *  may be reproduced or transmitted in any form or by any means, or          *
 *  retained in any storage or retrieval system without the express           *
 *  written permission of Cerner.                                             *
 *                                                                            *
 *  Cerner is a registered mark of Cerner Corporation.                        *
 *                                                                            *
 *****************************************************************************/
/******************************************************************************
 
        Source file name:       chs_tn_pc_phys_audit_rpt.prg
        Object name:            chs_tn_pc_phys_audit_rpt
        Request #:              CCPS-18129
 
        Program purpose:        Physician Audit Report
 
 *****************************************************************************/
/******************************************************************************
 *                        Modification Control Log                            *
 ******************************************************************************
 *Mod   Date     Engineer                Comment                              *
 *--- ---------- -------- 			------------------------------------------*
 *001 12/22/19	 DS051289             CCPS-18129 CHS_TN:Initial Release       *
 *****************************************************************************/
drop program chs_tn_pc_phys_audit_rpt:dba go
create program chs_tn_pc_phys_audit_rpt:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"                  ;* Enter or select the printer or file name to send this report to.
	, "Begin Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Clinic" = VALUE(*             )
	, "Physician's Name" = VALUE(*             )
	, "Mid-Level Provider's name" = VALUE(*             )
	, "Display" = "1" 

with OUTDEV, beg_date, end_date, fac, phy_name, mid_lvl_nme, disp
 
/**************************************************************
; Include Files
**************************************************************/
%i ccluserdir:sc_cps_get_prompt_list.inc
%i ccluserdir:sc_cps_parse_date_subs.inc
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare beg_dt_tm = dq8 with noconstant(ParseDatePrompt($beg_date,CURDATE,000000)),protect
declare end_dt_tm = dq8 with noconstant(ParseDatePrompt($end_date,CURDATE,235959)),protect
 
declare cnt = i4 with protect, noconstant
declare num = i4 with protect, noconstant
declare pos = i4 with protect, noconstant
 
declare facility_parser                 = vc with noconstant(" "), protect
declare phy_nme_parser                  = vc with noconstant(" "), protect
declare mid_lvl_parser                  = vc with noconstant(" "), protect
declare 72_wellchildofficenote_cd       = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 72, "WELLCHILDOFFICENOTE"))
declare 72_procedurenote_cd             = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 72, "PROCEDURENOTE"))
declare 72_anticoagulationofficenote_cd = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 72, "ANTICOAGULATIONOFFICENOTE"))
declare 72_annualphysicalofficenote_cd  = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 72, "ANNUALPHYSICALOFFICENOTE"))
declare 319_fin_cd                      = f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!2930")),protect
declare 21_verify_cd                    = f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!2639")),protect
declare 21_sign_cd                      = f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!2644")),protect
declare 103_completed_cd                = f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!3782")),protect
declare 103_requested_cd                = f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!2819")),protect
declare 8_inprogress_cd                 = f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!2637")),protect
 
;/*** Facility Parser ***/
if (IsPromptEmpty(4) OR IsPromptAny(4))
    set facility_parser = "1=1"
else
 	set facility_parser = GetPromptList (4 ,"e.loc_facility_cd" ,LIST_IN )
endif
 
;/*** Mid-Level Provider's Name Parser ***/
if (IsPromptEmpty(5) OR IsPromptAny(5))
    set phy_nme_parser = "1=1"
else
 	set phy_nme_parser = GetPromptList (5 ,"pr2.person_id" ,LIST_IN )
endif
 
;/*** Physician's Name Parser ***/
if (IsPromptEmpty(6) OR IsPromptAny(6))
    set mid_lvl_parser = "1=1"
else
 	set mid_lvl_parser = GetPromptList (6 ,"pr1.person_id" ,LIST_IN )
endif
 
free record phys_data
record phys_data
(
  1 qual_cnt = i4
  1 begin_date        = vc
  1 end_date          = vc
  1 qual[*]
    2 person_id         = f8
    2 encntr_id         = f8
    2 event_id          = f8
    2 facility          = vc
    2 fin               = vc
    2 pat_name          = vc
    2 enct_type         = vc
    2 enct_dt_tm        = vc
    2 note_dt_dtm		= vc
    2 enct_dt_tm_tat    = dq8
    2 note_dt_dtm_tat	= dq8
    2 mid_lvl_pvd_name  = vc
    2 doc_type          = vc
    2 doc_sub           = vc
    2 perf_dt_tm        = vc
    2 fwd_dt_tm         = vc
    2 perf_dt_tm_tat    = dq8
    2 fwd_dt_tm_tat     = dq8
    2 rec_phy_name      = vc
    2 note_opnd_dt_tm   = vc
    2 prov_complte_dt_tm= vc
    
    2 prov_complte_dt_tm_tat = dq8
    2 note_opnd_dt_tm_tat   = dq8

    2 comp_phy_name		= vc
)
 
free record phys_summary
record phys_summary
(
  1 qual_cnt = i4
  1 qual[*]
    2 person_count  = i4
    2 person_id     = f8
    2 unique_fin_cnt = i4
    2 performed_count= i4
    2 forwarded_count= i4
    2 completed_10_count= i4
    2 completed_30_count= i4
)
 
 
SET  phys_data->begin_date = format(cnvtdatetime(beg_dt_tm), "DD/MMM/YY HH:MM ;;D")
SET  phys_data->end_date   = format(cnvtdatetime(end_dt_tm), "DD/MMM/YY HH:MM ;;D")
 
;***************************************************
;Main query - Get Qualifying Encounters
;***************************************************
call echo("Get Qualifying Encounters")
 
 
select into "nl:"
from encounter e
    ,person p
    ,clinical_event ce
    ,ce_event_prsnl cep
    ,prsnl pr1
    ,prsnl pr2
    ,code_value cv
 
plan e
    where e.reg_dt_tm between cnvtdatetime(beg_dt_tm) and cnvtdatetime(end_dt_tm)
    and parser(facility_parser)
    ;and e.encntr_id =    113920349.00;!= 0.00
    and e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    and e.end_effective_dt_tm >  cnvtdatetime(curdate,curtime3)
    and e.active_ind = 1
 
join p
    where e.person_id = p.person_id
    and p.person_id != 0.00
    and p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    and p.end_effective_dt_tm >  cnvtdatetime(curdate,curtime3)
    and p.active_ind = 1
 
join ce
    where ce.encntr_id = e.encntr_id
    ;and ce.event_id =    953509583.00; 953331996.00
  ;  and ce.event_cd in (72_wellchildofficenote_cd, 72_procedurenote_cd,
   ;                     72_anticoagulationofficenote_cd,
    ;                    72_annualphysicalofficenote_cd, 2563650561.00,2563650577)
    ;and ce.performed_dt_tm between cnvtdatetime("29-JAN-2020 00:00") and cnvtdatetime("30-JAN-2020 23:59")
    and ce.view_level = 1
    and ce.valid_until_dt_tm  >= cnvtdatetime(curdate, curtime3)
join cv
	where cv.code_value = ce.event_cd
	and   cv.active_ind = 1
	and   cv.display = "*Office Note*"
join cep
    where cep.event_id = ce.event_id
    and cep.action_type_cd in (104.00);(21_verify_cd);, 21_sign_cd)
    and cep.action_status_cd in (103_completed_cd);, 103_requested_cd )
 
join pr1
    where pr1.person_id = cep.action_prsnl_id
    and parser(mid_lvl_parser)
    and pr1.position_cd in ( 2716282021.00, 2717074137.00,   31767941.00, 2562470291.00)
    and pr1.name_full_formatted not in ("*CERNER*","*Cerner*")
 
join pr2
    where pr2.person_id = cep.action_prsnl_id
    and parser(phy_nme_parser)
    ;and pr2.name_full_formatted not in ("*CERNER*","*Cerner*")
 
order by ce.event_id,cep.updt_dt_tm  desc
 
head report
	cnt = 0
 
head ce.encntr_id
    null
 
head ce.event_id
	cnt = cnt + 1
	if (mod(cnt,100) = 1)
		stat = alterlist(phys_data->qual,cnt+99)
	endif
 
 
 
 ;call echo(build2("Test:",uar_get_code_display(ce.event_cd),"--",ce.event_id))
	phys_data->qual[cnt]->person_id = e.person_id
    phys_data->qual[cnt]->encntr_id = ce.encntr_id
    phys_data->qual[cnt]->event_id  = ce.event_id
    phys_data->qual[cnt]->facility  = trim(uar_get_code_display(e.loc_facility_cd),3)
    phys_data->qual[cnt]->pat_name  = trim(p.name_full_formatted,3)
    phys_data->qual[cnt]->enct_type = trim(uar_get_code_display(e.encntr_type_cd),3)
    phys_data->qual[cnt]->enct_dt_tm= format(e.reg_dt_tm, "mm/dd/yy hh:mm")
    phys_data->qual[cnt]->enct_dt_tm_tat = e.reg_dt_tm
    phys_data->qual[cnt]->note_dt_dtm= format(ce.event_end_dt_tm, "mm/dd/yy hh:mm")
    phys_data->qual[cnt]->note_dt_dtm_tat =ce.event_end_dt_tm
    if(ce.result_status_cd != 8_inprogress_cd)
        phys_data->qual[cnt]->doc_type  = trim(uar_get_code_display(ce.event_cd),3)
        phys_data->qual[cnt]->doc_sub   = trim(ce.event_title_text,3)
        phys_data->qual[cnt]->perf_dt_tm= format(ce.performed_dt_tm, "mm/dd/yy hh:mm")
        phys_data->qual[cnt]->perf_dt_tm_tat = ce.performed_dt_tm
    ;phys_data->qual[cnt]->perf_dt_tm= DATETIMEZONE(ce.performed_dt_tm,ce.performed_tz,1)
    endif
 
detail
    ;if(ce.result_status_cd != 8_inprogress_cd)
        ;if(cep.action_type_cd = 21_verify_cd and cep.action_status_cd = 103_completed_cd)
            phys_data->qual[cnt]->mid_lvl_pvd_name = trim(pr1.name_full_formatted,3)
;        elseif(cep.action_type_cd = 21_sign_cd and cep.action_status_cd = 103_requested_cd)
;            phys_data->qual[cnt]->rec_phy_name = trim(pr.name_full_formatted,3)
;            phys_data->qual[cnt]->fwd_dt_tm = format(cep.request_dt_tm, "mm/dd/yy hh:mm")
;        elseif(cep.action_type_cd = 21_sign_cd and cep.action_status_cd = 103_completed_cd)
;            phys_data->qual[cnt]->prov_complte_dt_tm = format(cep.action_dt_tm, "mm/dd/yy hh:mm")
        ;endif
    ;endif
 
foot ce.event_id
    null
 
foot e.encntr_id
    null
 
foot report
	stat = alterlist(phys_data->qual,cnt)
	phys_data->qual_cnt = cnt
 
with nocounter
 
;Exit Script
if (phys_data->qual_cnt = 0)
	go to exit_script
endif
 
/**************************************************************
;FIN
**************************************************************/
call echo("FIN")
 
select into "nl:"
from encntr_alias ea
 
plan ea
    where expand(num,1,phys_data->qual_cnt,ea.encntr_id,phys_data->qual[num].encntr_id)
    and ea.encntr_alias_type_cd = 319_fin_cd
	and ea.active_ind = 1
	and ea.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3)
    and ea.end_effective_dt_tm >  cnvtdatetime (curdate ,curtime3)
 
order by ea.encntr_id,ea.encntr_alias_type_cd
 
head report
	pos=0
head ea.encntr_id
    pos = locateval(num,1,phys_data->qual_cnt,ea.encntr_id,phys_data->qual[num].encntr_id)
 
head ea.encntr_alias_type_cd
    phys_data->qual[pos]->fin = trim(cnvtalias(ea.alias,ea.alias_pool_cd),3)
 
foot ea.encntr_alias_type_cd
    null
 
foot ea.encntr_id
    pos1=pos
    while(pos>0)
    	phys_data->qual[pos]->fin = phys_data->qual[pos1]->fin
        pos=locateval(num,pos+1,phys_data->qual_cnt,ea.encntr_id,phys_data->qual[num].encntr_id)
    endwhile
 
with nocounter, expand = 2
 
/**************************************************************
; Physician name receiving the Note details
**************************************************************/
select into "nl:"
from ce_event_prsnl ce
    ,prsnl p
 
plan ce
    where expand(num,1,phys_data->qual_cnt,ce.event_id,phys_data->qual[num].event_id)
    and ce.action_type_cd in (21_verify_cd, 21_sign_cd)
    and ce.action_status_cd in (103_completed_cd, 103_requested_cd )
join p
    where p.person_id = ce.action_prsnl_id
    and p.position_cd not in ( 2716282021.00
            ,2717074137.00,        441.00,31767941.00, 2562470291.00)
    ;and p.name_full_formatted not in ("Cerner*","UA*")
 
order by ce.event_id,ce.updt_dt_tm ;desc
 
head report
    pos = 0
 
head ce.event_id
    pos = locateval(num,1,phys_data->qual_cnt,ce.event_id,phys_data->qual[num].event_id)
 
detail
    if(ce.action_type_cd = 21_verify_cd and ce.action_status_cd = 103_completed_cd)
        phys_data->qual[pos]->mid_lvl_pvd_name = trim(p.name_full_formatted,3)
    elseif(ce.action_type_cd = 21_sign_cd and ce.action_status_cd = 103_requested_cd)
        phys_data->qual[pos]->rec_phy_name = trim(p.name_full_formatted,3)
        phys_data->qual[pos]->fwd_dt_tm = format(ce.request_dt_tm, "mm/dd/yy hh:mm")
        phys_data->qual[pos]->fwd_dt_tm_tat = ce.request_dt_tm
        
    elseif(ce.action_type_cd = 21_sign_cd and ce.action_status_cd = 103_completed_cd)
        phys_data->qual[pos]->prov_complte_dt_tm = format(ce.action_dt_tm, "mm/dd/yy hh:mm")
        phys_data->qual[pos]->prov_complte_dt_tm_tat = ce.action_dt_tm
        phys_data->qual[pos]->comp_phy_name = trim(p.name_full_formatted,3)
    endif
 
foot ce.event_id
    null
 
foot report
    null
 
with nocounter, expand = 2
 
/**************************************************************
;Note Opened Date Time
**************************************************************/
select into "nl:"
from task_activity   t
 
plan t
    where expand(num,1,phys_data->qual_cnt,t.event_id,phys_data->qual[num].event_id)
    and t.task_status_cd =         427.00
 
order by t.event_id
 
head report
    pos = 0
 
head t.event_id
    pos = locateval(num,1,phys_data->qual_cnt,t.event_id,phys_data->qual[num].event_id)
 
    phys_data->qual[pos]->note_opnd_dt_tm = format(t.updt_dt_tm, "mm/dd/yy hh:mm")
    phys_data->qual[pos]->note_opnd_dt_tm_tat = t.updt_dt_tm
 
foot t.event_id
    null
 
foot report
    null
 
with nocounter, expand = 2
 
/**************************************************************
; Summary
**************************************************************/
select into "nl:"
from encounter e
    ,clinical_event ce
    ,ce_event_prsnl cep
    ,prsnl pr1
 
plan e
    where expand(num,1,phys_data->qual_cnt,e.encntr_id,phys_data->qual[num].encntr_id)
 
join ce
    where ce.encntr_id = e.encntr_id
    and ce.performed_dt_tm between cnvtdatetime("29-JAN-2020 00:00") and cnvtdatetime("30-JAN-2020 23:59")
    and ce.view_level = 1
 
join cep
    where cep.event_id = ce.event_id
 
join pr1
    where pr1.person_id = cep.action_prsnl_id
    and parser(mid_lvl_parser)
 
order by pr1.person_id,e.encntr_id,ce.event_id
 
head report
    p_cnt =0
 
head pr1.person_id
    p_cnt = p_cnt + 1
    if(mod(p_cnt,10)=1)
    	stat=alterlist(phys_summary->qual,p_cnt+9)
    endif
    e_cnt = 0
 
head e.encntr_id
    e_cnt = e_cnt + 1
    pf_cnt = 0
 
head ce.event_id
    if(ce.performed_dt_tm > 0)
    call echo(build2("Test:",ce.performed_dt_tm,"--",ce.event_id))
        pf_cnt = pf_cnt + 1
    endif
 
foot ce.event_id
    phys_summary->qual[p_cnt]->performed_count = pf_cnt
 
foot e.encntr_id
    phys_summary->qual[p_cnt]->unique_fin_cnt = e_cnt
 
foot report
    phys_summary->qual_cnt = p_cnt
    stat=alterlist(phys_summary->qual, p_cnt)
 
with nocounter, expand = 2
 
if($disp = "1")
SELECT into $outdev
	Mid_Level_Providers_Name = SUBSTRING(1, 30, PHYS_DATA->qual[D1.SEQ].mid_lvl_pvd_name)
	, Patients_FIN = SUBSTRING(1, 30, PHYS_DATA->qual[D1.SEQ].fin)
	, Patient_Full_Name = SUBSTRING(1, 30, PHYS_DATA->qual[D1.SEQ].pat_name)
	, Encounter_Date_Time = SUBSTRING(1, 30, PHYS_DATA->qual[D1.SEQ].enct_dt_tm)
	, Document_Type = SUBSTRING(1, 30, PHYS_DATA->qual[D1.SEQ].doc_type)
	, Document_Subject = SUBSTRING(1, 30, PHYS_DATA->qual[D1.SEQ].doc_sub)
	, Note_Date_Time = SUBSTRING(1, 30, PHYS_DATA->qual[D1.SEQ].note_dt_dtm)
	, Performed_Date_Time = SUBSTRING(1, 30, PHYS_DATA->qual[D1.SEQ].perf_dt_tm)
	, Note_Performed_TAT = datetimediff(PHYS_DATA->qual[D1.SEQ].perf_dt_tm_tat,PHYS_DATA->qual[D1.SEQ].note_dt_dtm_tat,3)
	, Forwarded_Date_Time = SUBSTRING(1, 30, PHYS_DATA->qual[D1.SEQ].fwd_dt_tm)
	, Performed_Forward_TAT = datetimediff(PHYS_DATA->qual[D1.SEQ].fwd_dt_tm_tat,PHYS_DATA->qual[D1.SEQ].perf_dt_tm_tat,3)
	, Name_Forwarded_To = SUBSTRING(1, 30, PHYS_DATA->qual[D1.SEQ].rec_phy_name)
	, Date_Time_Note_Opened = SUBSTRING(1, 30, PHYS_DATA->qual[D1.SEQ].note_opnd_dt_tm)
	, Date_Time_Note_Completed = SUBSTRING(1, 30, PHYS_DATA->qual[D1.SEQ].prov_complte_dt_tm)
	, Forward_Complete_TAT = datetimediff(PHYS_DATA->qual[D1.SEQ].prov_complte_dt_tm_tat,PHYS_DATA->qual[D1.SEQ].fwd_dt_tm_tat,3)
	, Name_Note_Completed = substring(1,30,PHYS_DATA->qual[D1.SEQ].comp_phy_name)
	, Performed_Completed_TAT = datetimediff(PHYS_DATA->qual[D1.SEQ].prov_complte_dt_tm_tat,PHYS_DATA->qual[D1.SEQ].perf_dt_tm_tat,3)
	, event_id = PHYS_DATA->qual[D1.SEQ].event_id
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(PHYS_DATA->qual, 5))
 
PLAN D1
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
else
execute CHS_TN_PC_AUDIT_DETAIL_LYT:dba $outdev
endif
 
/**************************************************************
; Exit Script
**************************************************************/
#exit_script
 
if( phys_data->qual_cnt = 0)
 
 	select into $outdev
    from (dummyt d with seq = 1)
    plan d
 
    head report
	  row 0, col 0, call print(build2("PROGRAM:  ", cnvtlower(curprog) ))
	  row + 1
	  row 3, col 0, call print(build2("NODE:  ", curnode))
	  row + 1
	  row 6, col 0, call print(build2("Execution Date/Time:  ", format(cnvtdatetime(curdate,curtime), "mm/dd/yyyy hh:mm:ss;;q")))
	  row + 1
	  row 9, col 0, call print(build2("No Data Qualified for the below prompt values,"))
	  row + 1
	  row 12, col 0, call print(build2("Registration Start Date: ",format(cnvtdatetime(beg_dt_tm),"DD-MMM-YYYY hh:mm ;;q")))
	  row + 1
	  row 15, col 0, call print(build2("Registration End Date: ",format(cnvtdatetime(end_dt_tm),"DD-MMM-YYYY hh:mm ;;q")))
	  row + 1
 
	  with nocounter, nullreport, maxcol = 300, dio = postscript
endif
 
call echorecord(phys_data)
call echorecord(phys_summary)
 
end
go
 
;EXECUTE chs_tn_pc_phys_audit_rpt:dba "MINE", "10-JAN-2017 19:48:00", "10-JAN-2020 19:48:00", "*", "*", "*", "1" go

