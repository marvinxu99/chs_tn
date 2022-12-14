/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_eso_resend_tool.prg
	Object name:		cov_eso_resend_tool
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

drop program cov_eso_resend_tool:dba go
create program cov_eso_resend_tool:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Search for a Patient" = 0
	;<<hidden>>"Search" = ""
	;<<hidden>>"Remove" = ""
	, "Result List" = 0 

with OUTDEV, ENCNTR_ID, RESULT_LIST

execute cov_std_ce_routines

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


;free set t_rec
record t_rec
(
	1 cnt			= i4
	1 prompts
	 2 outdev		= vc
	 2 encntr_id	= f8
	 2 event_id		= f8
	 2 delete_sel	= i2
	 2 new_alert_type = vc
	 2 new_alert_text = vc
	 2 rpt_audits	= vc	 
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
	1 qual[*]
	 2 person_id	= f8
	 2 encntr_id	= f8
	 2 mrn			= vc
	 2 fin			= vc
	 2 name_full_formatted = vc
	 2 alert_type	= vc
	 2 alert_text 	= vc
	 2 alert_dt_tm	= vc
)

;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.encntr_id = $ENCNTR_ID
set t_rec->prompts.event_id = $ALERT_LIST
set t_rec->prompts.delete_sel = $DELETE_SEL
set t_rec->prompts.new_alert_type = $NEW_ALERT_TYPE
set t_rec->prompts.new_alert_text = $NEW_ALERT_TEXT
set t_rec->prompts.rpt_audits = $RPT_AUDITS

set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Diagnosis   *******************************************"))

if (t_rec->prompts.rpt_audits > " ")

	if (t_rec->prompts.rpt_audits = "PERSON")
	
		if (t_rec->prompts.encntr_id > 0.0)
		
			select into t_rec->prompts.outdev
			from
				dummyt d1
			plan d1
			head report
				col 0 "<html><body>"
				row +1
				col 0 "<font size=-1 family=arial>"
				row +1
				col 0 "Patient Audit"
				row +1
				col 0 "<br><br>"
				row +1
				col 0 "</body></html>"
			with nocounter,maxcol=32000
		
		endif
	
	elseif (t_rec->prompts.rpt_audits = "ACTIVE")
	
		select into t_rec->prompts.outdev
			from
				dummyt d1
			plan d1
			head report
				col 0 "<html><body>"
				row +1
				col 0 "<font size=-1 family=arial>"
				row +1
				col 0 "System Audit"
				row +1
				col 0 "<br><br>"
				row +1
				col 0 "</body></html>"
			with nocounter,maxcol=32000
	
	endif

elseif ((t_rec->prompts.new_alert_type > " ") and (t_rec->prompts.new_alert_text > " "))

	if (t_rec->prompts.encntr_id > 0.0)
	
		set stat = sAddCovDiscernAlert(t_rec->prompts.encntr_id,0.0,t_rec->prompts.new_alert_type,t_rec->prompts.new_alert_text)
		
		select into t_rec->prompts.outdev
			from
				dummyt d1
			plan d1
			head report
				col 0 "<html><body>"
				row +1
				col 0 "<font size=-1 family=arial>"
				row +1
				col 0 t_rec->prompts.new_alert_type
				row +1
				col 0 "<br><br>"
				row +1
				col 0 t_rec->prompts.new_alert_text
				row +1
				col 0 "</body></html>"
			with nocounter,maxcol=32000
		
	endif


elseif ((t_rec->prompts.delete_sel = 1) and (t_rec->prompts.event_id > 0.0))

	set stat = Remove_CEResult(t_rec->prompts.event_id)
	
	select into t_rec->prompts.outdev
			from
				dummyt d1
			plan d1
			head report
				col 0 "<html><body>"
				row +1
				col 0 "<font size=-1 family=arial>"
				row +1
				col 0 t_rec->prompts.event_id
				row +1
				col 0 "<br><br>"
				row +1
				col 0 "Removed"
				row +1
				col 0 "</body></html>"
			with nocounter,maxcol=32000
			
endif

call writeLog(build2("* END   Finding Diagnosis   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

/*
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit *************************************"))
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
call writeLog(build2("* END   Creating Audit *************************************"))
call writeLog(build2("************************************************************"))
*/

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
