/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_bh_adult_agitation_rpt.prg
	Object name:		cov_bh_adult_agitation_rpt
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

drop program cov_bh_adult_agitation_rpt:dba go
create program cov_bh_adult_agitation_rpt:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0 

with OUTDEV, start_datetime, end_datetime, facility_list


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
	1 qual[*]
	 2 person_id	= f8
	 2 encntr_id	= f8
	 2 mrn 			= vc
	 2 fin			= vc
	 2 loc_facility = vc
	 2 loc_unit     = vc
	 2 loc_room		= vc
	 2 loc_bed		= vc
	 2 loc_display  = vc
	 2 patient_name = vc
	 2 reg_dt_tm	= dq8
	 2 encntr_type 	= vc
	 2 attending_prov = vc
	 2 MOAS_score	= vc
	 2 MOAS_dt_tm	= vc
	 2 Broset_score = vc
	 2 Broset_dt_tm	= vc
	 2 meds_cnt 	= i2
	 2 meds_qual[*]
	  3 event_id 		= f8
	  3 admin_dt_tm		= dq8
	  3 admin_dt_tm_vc	= vc
	  3 admin_med		= vc
	  3 post_med_broset	= vc
	  3 post_med_broset_dt_tm = vc
	  3 order_id		= f8
	1 prompts
	 2 outdev		= vc
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 outdev 				= vc
	 2 run_dt_tm 			= dq8
	 2 adult_psych_var 		= f8
	 2 behavior_hlth_var 	= f8
	 2 adulocent_psych_var 	= f8
	 2 moas_score			= f8
	 2 broset_score			= f8
	1 dates
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->prompts.outdev = $OUTDEV
set t_rec->cons.outdev = t_rec->prompts.outdev

/*
set t_rec->dminfo.info_domain	= "COV_DEV_OPS"
set t_rec->dminfo.info_name		= concat(trim(cnvtupper(curprog)),":","start_dt_tm")
set t_rec->dates.start_dt_tm 	= get_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name)
set t_rec->dates.end_dt_tm 		= cnvtdatetime(curdate,curtime3)

if (t_rec->dates.start_dt_tm = 0.0)
	call writeLog(build2("->No start date and time found, setting to go live date"))
	set t_rec->dates.start_dt_tm = cnvtdatetime(curdate,curtime3)
endif
*/

set t_rec->cons.adult_psych_var = uar_get_code_by("DISPLAY", 71, 'Hospital Adult Psych')
set t_rec->cons.behavior_hlth_var = uar_get_code_by("DISPLAY", 71, 'Behavioral Health')
set t_rec->cons.adulocent_psych_var = uar_get_code_by("DISPLAY", 71, 'Hospital Adolescent Psych')

set t_rec->cons.moas_score = uar_get_code_by("DISPLAY",72,"Total Weighted Score")
set t_rec->cons.broset_score = uar_get_code_by("DISPLAY",72,"Broset Sum")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

select into "nl:"
from
	encounter e
	,person p
plan e where e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.loc_facility_cd = $facility_list
	and e.encntr_type_cd in (t_rec->cons.adulocent_psych_var,t_rec->cons.adult_psych_var,t_rec->cons.behavior_hlth_var)
	and e.active_ind = 1
join p
	where p.person_id = e.person_id
order by
	e.encntr_id
head report
	i = 0
head e.encntr_id
	i = (i + 1)
	stat = alterlist(t_rec->qual,i)
	t_rec->qual[i].person_id = p.person_id
	t_rec->qual[i].encntr_id = e.encntr_id
	t_rec->qual[i].reg_dt_tm = e.reg_dt_tm
	t_rec->qual[i].patient_name = p.name_full_formatted
	t_rec->qual[i].loc_facility = uar_get_code_display(e.loc_facility_cd)
	t_rec->qual[i].loc_unit = uar_get_code_display(e.loc_nurse_unit_cd)
	t_rec->qual[i].loc_room = uar_get_code_display(e.loc_room_cd)
	t_rec->qual[i].loc_bed = uar_get_code_display(e.loc_bed_cd)
	t_rec->qual[i].encntr_type = uar_get_code_display(e.encntr_type_cd)
	
	t_rec->qual[i].loc_display = build2(
											 trim(t_rec->qual[i].loc_unit)
										," ",trim(t_rec->qual[i].loc_room)
										,", ",trim(t_rec->qual[i].loc_bed))
foot report
	t_rec->cnt = i
with nocounter 

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding MOAS Score *********************************"))

select into "nl:"
from
	(dummyt d1 with seq = t_rec->cnt)
	,clinical_event ce
plan d1
join ce
	where ce.encntr_id = t_rec->qual[d1.seq].encntr_id
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and	  ce.event_cd = t_rec->cons.moas_score
	and   cnvtint(ce.result_val) > 4
order by
	 ce.encntr_id
	,ce.event_end_dt_tm desc
	,ce.event_id
head report
	i = 0
head ce.encntr_id
	t_rec->qual[d1.seq].MOAS_score = ce.result_val
	;t_rec->qual[d1.seq].MOAS_dt_tm = format(ce.event_end_dt_tm,"dd-mmm-yyyy hh:mm:ss zzz;;q")
	t_rec->qual[d1.seq].MOAS_dt_tm = datetimezoneformat(ce.event_end_dt_tm,ce.event_end_tz,"dd-mmm-yyyy hh:mm:ss zzz;;q")
with nocounter

call writeLog(build2("* END   Finding MOAS Score *********************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Broset Score *********************************"))

select into "nl:"
from
	(dummyt d1 with seq = t_rec->cnt)
	,clinical_event ce
plan d1
join ce
	where ce.encntr_id = t_rec->qual[d1.seq].encntr_id
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and	  ce.event_cd = t_rec->cons.broset_score
	and   ce.order_id = 0.0
order by
	 ce.encntr_id
	,ce.event_end_dt_tm desc
	,ce.event_id
head report
	i = 0
head ce.encntr_id
	t_rec->qual[d1.seq].Broset_score = ce.result_val
	;t_rec->qual[d1.seq].MOAS_dt_tm = format(ce.event_end_dt_tm,"dd-mmm-yyyy hh:mm:ss zzz;;q")
	t_rec->qual[d1.seq].Broset_dt_tm = datetimezoneformat(ce.event_end_dt_tm,ce.event_end_tz,"dd-mmm-yyyy hh:mm:ss zzz;;q")
with nocounter

call writeLog(build2("* END   Finding Broset Score *********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Medications *********************************"))

select into "nl:"
from
	(dummyt d1 with seq = t_rec->cnt)
	,clinical_event ce
	,orders o
	,order_catalog oc
plan d1
join ce
	where ce.encntr_id = t_rec->qual[d1.seq].encntr_id
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.event_class_cd = value(uar_get_code_by("MEANING",53,"MED"))
join o
	where o.order_id = ce.order_id
join oc
	where oc.catalog_cd = o.catalog_cd
	and   oc.primary_mnemonic in(
									"chlorproMAZINE"
								)
order by
	 ce.encntr_id
	,ce.event_end_dt_tm
	,ce.event_id
head report
	i = 0
head ce.encntr_id
	i = 0
head ce.event_id
	i = (i + 1)
	stat = alterlist(t_rec->qual[d1.seq].meds_qual,i)
	t_rec->qual[d1.seq].meds_qual[i].event_id = ce.event_id
	t_rec->qual[d1.seq].meds_qual[i].admin_med = ce.event_title_text
	t_rec->qual[d1.seq].meds_qual[i].order_id = ce.order_id
	t_rec->qual[d1.seq].meds_qual[i].admin_dt_tm = ce.event_end_dt_tm
	t_rec->qual[d1.seq].meds_qual[i].admin_dt_tm_vc = 
		datetimezoneformat(ce.event_end_dt_tm,ce.event_end_tz,"dd-mmm-yyyy hh:mm:ss zzz;;q")
foot ce.encntr_id
	t_rec->qual[d1.seq].meds_cnt = i
with nocounter

call writeLog(build2("* END   Finding Medications *********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Broset Score After Meds ********************"))

select into "nl:"
	med_admin_id = t_rec->qual[d1.seq].meds_qual[d2.seq].event_id
from
	(dummyt d1 with seq = t_rec->cnt)
	,(dummyt d2 with seq = 1)
	,clinical_event ce
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].meds_cnt)
join d2
join ce
	where ce.encntr_id = t_rec->qual[d1.seq].encntr_id
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ce.event_end_dt_tm >= cnvtdatetime(t_rec->qual[d1.seq].meds_qual[d2.seq].admin_dt_tm)
	and   ce.order_id = t_rec->qual[d1.seq].meds_qual[d2.seq].order_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and	  ce.event_cd = t_rec->cons.broset_score
order by
	ce.encntr_id
	,ce.order_id
	,med_admin_id
	,ce.event_end_dt_tm 	
head med_admin_id
	call writeLog(build2("ce.event_id=",ce.event_id))
	call writeLog(build2("ce.post_med_broset_dt_tm=",t_rec->qual[d1.seq].meds_qual[i].post_med_broset_dt_tm))
	t_rec->qual[d1.seq].meds_qual[d2.seq].post_med_broset = ce.result_val
	t_rec->qual[d1.seq].meds_qual[i].post_med_broset_dt_tm = 
		datetimezoneformat(ce.event_end_dt_tm,ce.event_end_tz,"dd-mmm-yyyy hh:mm:ss zzz;;q")
	call writeLog(build2("ce.event_id=",ce.event_id))
	call writeLog(build2("admin_dt_tm_vc=",t_rec->qual[d1.seq].meds_qual[i].admin_dt_tm_vc))
	call writeLog(build2("ce.post_med_broset=",t_rec->qual[d1.seq].meds_qual[i].post_med_broset))
	call writeLog(build2("ce.post_med_broset_dt_tm=",t_rec->qual[d1.seq].meds_qual[i].post_med_broset_dt_tm))
with nocounter


call writeLog(build2("* END   Finding Broset Score After Meds ********************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

call get_mrn(null)
call get_fin(null)

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

select into t_rec->cons.outdev
	 patient = t_rec->qual[d1.seq].patient_name
	,location = t_rec->qual[d1.seq].loc_display
	,fin = t_rec->qual[d1.seq].fin
	,reg_dt_tm = substring(1,24,format(t_rec->qual[d1.seq].reg_dt_tm,"dd-mmm-yyyy hh:mm:ss zzz;;q"))
	,attending = t_rec->qual[d1.seq].attending_prov
	,moas_score	= t_rec->qual[d1.seq].MOAS_score
	,moas_dt_tm	= substring(1,24,t_rec->qual[d1.seq].MOAS_dt_tm)
	,Broset_score	= t_rec->qual[d1.seq].Broset_score
	,Broset_dt_tm	= t_rec->qual[d1.seq].Broset_dt_tm
	,agitation_meds	= t_rec->qual[d1.seq].meds_qual[d2.seq].admin_med
	,agitation_meds_dt_tm = t_rec->qual[d1.seq].meds_qual[d2.seq].admin_dt_tm_vc
	,post_meds_broset	= t_rec->qual[d1.seq].meds_qual[d2.seq].post_med_broset
	,post_meds_broset_dt = substring(1,24,t_rec->qual[d1.seq].meds_qual[d2.seq].post_med_broset_dt_tm)
	,encntr_id = t_rec->qual[d1.seq].encntr_id
from
	(dummyt d1 with seq = t_rec->cnt)
	,(dummyt d2 with seq = 1)
	,(dummyt d3)
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].meds_cnt)
join d3
join d2
order by
	 patient
	,agitation_meds_dt_tm
	,agitation_meds
	
with nocounter,format,separator = " ",outerjoin = d3

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


/*
if (reply->status_data.status in("Z","S"))
	call writeLog(build2("* START Set Date Range ************************************"))
	call set_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name,t_rec->dates.end_dt_tm)
	call writeLog(build2("* END Set Date Range ************************************v1"))
endif
*/
;001 end

;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment

call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go
