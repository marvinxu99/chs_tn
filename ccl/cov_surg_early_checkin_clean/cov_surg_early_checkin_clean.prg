/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_surg_early_checkin_clean.prg
	Object name:		cov_surg_early_checkin_clean
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_surg_early_checkin_clean:dba go
create program cov_surg_early_checkin_clean:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Audit Only" = 1 

with OUTDEV, AUDIT_MODE


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

call set_codevalues(null)
call check_ops(null)

;free set t_rec
record t_rec
(
	1 cnt			= i4
	1 prompts
	 2 outdev		= vc
	 2 audit_mode 	= i4
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 run_dt_tm 	= dq8
	1 dates
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->dminfo.info_domain	= "COV_DEV_OPS"
set t_rec->dminfo.info_name		= concat(trim(cnvtupper(curprog)),":","start_dt_tm")
set t_rec->dates.start_dt_tm 	= get_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name)
set t_rec->dates.end_dt_tm 		= cnvtdatetime(curdate,curtime3)

if (t_rec->dates.start_dt_tm = 0.0)
	call writeLog(build2("->No start date and time found, setting to go live date"))
	set t_rec->dates.start_dt_tm = cnvtdatetime(curdate,curtime3)
endif

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.audit_mode = $AUDIT_MODE

if (t_rec->prompts.audit_mode = 1)
	go to audit_section
endif

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

declare case_cnt = i4 with noconstant(0)
 
free record early_checkin 

record early_checkin
(
	1 cases[*]
		2 surg_case_id=f8
		2 sch_event_id=f8
		2 action_dt_tm=f8
)

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))


select into "nl:"
sc.surg_case_id,
sc.sch_event_id,
sea.action_dt_tm
from sch_event_action sea,
surgical_case sc
plan sc
where sc.sched_start_dt_tm > datetimeadd (cnvtdatetime (curdate ,curtime3 ) ,-(30))
    and sc.checkin_by_id > 0.00
    and sc.cancel_req_by_id = 0.00
    and sc.sch_event_id > 0
    and (sc.sched_start_dt_tm - sc.checkin_dt_tm) > 1
join sea
where
not exists
    (select sa.sch_event_id
    from sch_appt sa
    where sa.sch_event_id=sc.sch_event_id
    and sa.state_meaning='RESCHEDULED'
    and sa.orig_beg_dt_tm > cnvtdatetime("01-JAN-1800 00:00:00")
    and ((sa.orig_beg_dt_tm - sa.beg_dt_tm) > 1)
    and ((sa.orig_beg_dt_tm - sea.action_dt_tm) > 1))
and sea.sch_event_id = sc.sch_event_id
and sea.action_meaning = 'RESCHEDULE'
and sea.reason_meaning= 'EARLYCHECKIN'
order by sea.sch_event_id, sea.action_dt_tm desc
detail
    if(sc.surg_case_id > 0.00)
        case_cnt = case_cnt + 1
        stat = alterlist(early_checkin->cases, case_cnt)
 
        early_checkin->cases[case_cnt].surg_case_id = sc.surg_case_id
        early_checkin->cases[case_cnt].sch_event_id = sc.sch_event_id
        early_checkin->cases[case_cnt].action_dt_tm = sea.action_dt_tm
    endif
with nocounter

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

update into surgical_case sc
, (dummyt d with seq=value(size(early_checkin->cases,5)))
set sc.sched_start_dt_tm = cnvtdatetime(early_checkin->cases[d.seq].action_dt_tm),
sc.updt_id=reqinfo->updt_id,
sc.updt_task=-5107,
sc.updt_dt_tm = sysdate,
sc.updt_cnt = sc.updt_cnt + 1
plan d
join
sc
where sc.surg_case_id = early_checkin->cases[d.seq].surg_case_id
and sc.sch_event_id = early_checkin->cases[d.seq].sch_event_id 
 
update into sn_case_tracking sc
, (dummyt d with seq=value(size(early_checkin->cases,5)))
set sc.anticipated_start_dt_tm = cnvtdatetime(early_checkin->cases[d.seq].action_dt_tm),
sc.updt_id=reqinfo->updt_id,
sc.updt_task=-5107,
sc.updt_dt_tm = sysdate,
sc.updt_cnt = sc.updt_cnt + 1
plan d
join
sc
where sc.surg_case_id = early_checkin->cases[d.seq].surg_case_id
and sc.anticipated_start_dt_tm > sysdate

commit 


call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))



call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit *************************************"))

#audit_section

select into t_rec->prompts.outdev
CASE_NUMBER=sc.surg_case_nbr_formatted,
CHECKIN_DT_TM = sea.action_dt_tm "",
ORIGINAL_SCHEDULED_DT_TM = sc.sched_start_dt_tm "",
action_updt_dt_tm = sea.updt_dt_tm,
action_updt_id = sea.updt_id,
case_updt_dt_tm = sc.updt_dt_tm,
case_updt_id = sc.updt_id,
checked_in_by = p.name_full_formatted
from sch_event_action sea,
surgical_case sc,
prsnl p
plan sc where sc.sched_start_dt_tm > sysdate-30
    and sc.checkin_by_id > 0.00
    and sc.cancel_req_by_id = 0.00
    and sc.sch_event_id > 0
    and (sc.sched_start_dt_tm - sc.checkin_dt_tm) > 1
join sea
where
not exists
    (select sa.sch_event_id
    from sch_appt sa
    where sa.sch_event_id=sc.sch_event_id
    and sa.state_meaning='RESCHEDULED'
    and sa.orig_beg_dt_tm > cnvtdatetime("01-JAN-1800 00:00:00")
    and ((sa.orig_beg_dt_tm - sa.beg_dt_tm) > 1)
    and ((sa.orig_beg_dt_tm - sea.action_dt_tm) > 1))
and sea.sch_event_id = sc.sch_event_id
and sea.action_meaning = 'RESCHEDULE'
and sea.reason_meaning= 'EARLYCHECKIN'
join p where p.person_id = outerjoin(sc.checkin_by_id)
order by sea.sch_event_id, sea.action_dt_tm 
with nocounter, separator=" ", format

/*
	call writeAudit(build2(
							char(34),^ITEM^,char(34),char(44),
							char(34),^DESC^,char(34)
						))
for (i=1 to t_rec->cnt)
		call writeAudit(build2(
							char(34),t_rec->qual[i].a											,char(34),char(44),
							char(34),t_rec->qual[i].b											,char(34)
						))

endfor
*/

call writeLog(build2("* END   Creating Audit *************************************"))
call writeLog(build2("************************************************************"))

#exit_script

if (reply->status_data.status in("Z","S"))
	call writeLog(build2("* START Set Date Range ************************************"))
	call set_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name,t_rec->dates.end_dt_tm)
	call writeLog(build2("* END Set Date Range ************************************v1"))
endif
;001 end

;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)


call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go
