/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_ops_adv_care_ords.prg
	Object name:		cov_ops_adv_care_ords
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

drop program cov_ops_adv_care_ords:dba go
create program cov_ops_adv_care_ords:dba


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

%i cclsource:eks_rprq3091001.inc
%i cclsource:eks_run3091001.inc

;free set t_rec
record t_rec
(
	1 audit_mode	= i2
	1 cnt			= i4
	1 prompts
	 2 outdev		= vc
	 2 start_dt_tm	= vc
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 run_dt_tm 	= dq8
	 2 trigger		= vc
	 2 trigger_cancel = vc
	1 dates
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
	1 catalog_cnt   = i4
	1 catalog_qual[*]
	 2 catalog_cd	= f8
	 2 mnemonic = vc
	1 qual[*]
	 2 person_id	= f8
	 2 encntr_id	= f8
	 2 mrn			= vc
	 2 fin			= vc
	 2 name_full_formatted = vc
	 2 order_id		= f8
	 2 cancel_ind	= i2
	 2 diag_list	= vc
	 2 diag_cnt		= i4
	 2 diag_qual[*]
	  3 diagnosis_id = f8
	  3 nomenclature_id = f8
	 2 complete_cnt = i4
	 2 complete_qual[*]
	  3 order_id = f8
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

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

set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)
set t_rec->cons.trigger			= "COV_EE_ADD_DX_ORD"
set t_rec->cons.trigger_cancel	= "COV_EE_CANCEL_ORD"

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Order Catalog Items *******************************************"))

select
into "nl:"
from
	 order_catalog oc
plan oc
	where oc.description in(
								 "Advance Care Planning Discussion and Documentation Declined 1124F"
								,"Advance Care Planning Discussed  w/ Surrogate Decision Maker and Documented 1123F"
								,"Hospice services received by patient during measurement period G9692"
							)
	and oc.active_ind = 1
order by
	 oc.catalog_cd
head report
	null	
head oc.catalog_cd
	t_rec->catalog_cnt += 1
	stat = alterlist(t_rec->catalog_qual,t_rec->catalog_cnt)
	t_rec->catalog_qual[t_rec->catalog_cnt].catalog_cd = oc.catalog_cd
	t_rec->catalog_qual[t_rec->catalog_cnt].mnemonic = oc.description
with nocounter

call writeLog(build2("* END   Order Catalog Items ******************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Active Orders   *******************************************"))

	
select
into "nl:"
from
	 (dummyt d1 with seq=t_rec->catalog_cnt)
	,orders o
	,order_catalog oc
plan d1
join oc
	where oc.catalog_cd = t_rec->catalog_qual[d1.seq].catalog_cd
join o
	where o.catalog_cd = oc.catalog_cd
	and   o.order_status_cd in(value(uar_get_code_by("MEANING",6004,"ORDERED")))
	and   o.active_ind = 1
order by
	 o.order_id
head report
	null	
head o.order_id	
	t_rec->cnt += 1
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].order_id	= o.order_id
	t_rec->qual[t_rec->cnt].person_id	= o.person_id
	t_rec->qual[t_rec->cnt].encntr_id	= o.encntr_id
foot report
	null
with nocounter
    
call writeLog(build2("* END   Finding Active Orders   *******************************************"))
call writeLog(build2("************************************************************"))



call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Previous Orders   *******************************************"))

	
select
into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,orders o
	,order_catalog oc
	,orders o2
plan d1
join o2
	where o2.order_id = t_rec->qual[d1.seq].order_id
join o
	where o.person_id = t_rec->qual[d1.seq].person_id
	and   o.order_status_cd in(value(uar_get_code_by("MEANING",6004,"COMPLETED")))
	and   o.active_ind = 1
	and   o.orig_order_dt_tm >= cnvtdatetime(datetimefind(cnvtdatetime(sysdate), 'Y', 'B', 'B'))
join oc
	where oc.catalog_cd = o.catalog_cd
	and   expand(i,1,t_rec->catalog_cnt,oc.catalog_cd,t_rec->catalog_qual[i].catalog_cd)
	and   oc.catalog_cd = o2.catalog_cd
order by
	 o2.order_id
	,o.order_id
head report
	null	
head o2.order_id
	t_rec->qual[d1.seq].cancel_ind = 1
head o.order_id
	t_rec->qual[d1.seq].complete_cnt += 1
	stat = alterlist(t_rec->qual[d1.seq].complete_qual,t_rec->qual[d1.seq].complete_cnt)
	t_rec->qual[d1.seq].complete_qual[t_rec->qual[d1.seq].complete_cnt].order_id = o.order_id
foot report
	null
with nocounter
    
call writeLog(build2("* END   Finding Previous Orders   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Diagnosis   *******************************************"))


select into "nl:"
	order_id = t_rec->qual[d1.seq].order_id
from
	 diagnosis d
	,nomenclature n
	,(dummyt d1 with seq=t_rec->cnt)
plan d1
join d
	where d.encntr_id	= t_rec->qual[d1.seq].encntr_id
	and   d.active_ind	= 1
	and	  d.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and	  d.active_status_cd	in(
									value(uar_get_code_by("MEANING",48,"ACTIVE"))
								)
	and	  d.confirmation_status_cd	in(
									value(uar_get_code_by("MEANING",12031,"CONFIRMED"))
								)
join n
	where n.nomenclature_id = d.nomenclature_id
order by
	 order_id
	,d.diagnosis_id
head report
	null
head order_id
	null
head d.diagnosis_id
	t_rec->qual[d1.seq].diag_cnt += 1
	stat = alterlist(t_rec->qual[d1.seq].diag_qual,t_rec->qual[d1.seq].diag_cnt)
	t_rec->qual[d1.seq].diag_qual[t_rec->qual[d1.seq].diag_cnt].diagnosis_id = d.diagnosis_id
	t_rec->qual[d1.seq].diag_qual[t_rec->qual[d1.seq].diag_cnt].nomenclature_id = n.nomenclature_id
	
	if (t_rec->qual[d1.seq].diag_cnt = 1)
		t_rec->qual[d1.seq].diag_list = build(
												 "<P>OPT_VALUE_A3="
												,t_rec->qual[d1.seq].diag_qual[t_rec->qual[d1.seq].diag_cnt].nomenclature_id
												,char(6)
												,t_rec->qual[d1.seq].diag_qual[t_rec->qual[d1.seq].diag_cnt].nomenclature_id
												,char(7)
												,"X|12594.0|1|10|0|ICD9|S")
	elseif (t_rec->qual[d1.seq].diag_cnt > 1)
		t_rec->qual[d1.seq].diag_list = build(	 t_rec->qual[d1.seq].diag_list
												,"<P>OPT_VALUE_A3="
												,t_rec->qual[d1.seq].diag_qual[t_rec->qual[d1.seq].diag_cnt].nomenclature_id
												,char(6)
												,t_rec->qual[d1.seq].diag_qual[t_rec->qual[d1.seq].diag_cnt].nomenclature_id
												,char(7)
												,"X|12594.0|1|10|0|ICD9|S")
	endif
	
with nocounter

call writeLog(build2("* END   Finding Diagnosis   *******************************************"))
call writeLog(build2("************************************************************"))

call get_mrn(null)
call get_fin(null)
call get_patientname(null)


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building EKS Call to Add Dx   *******************************************"))

select into "NL:"
	e.encntr_id,
	e.person_id,
	e.reg_dt_tm,
	p.birth_dt_tm,
	p.sex_cd
from
	 person p
	,encounter e
	,(dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2)
plan d1
	where maxrec(d2,size(t_rec->qual[d1.seq].diag_qual,5))
	and   t_rec->qual[d1.seq].cancel_ind = 0
join d2
join e 
	where e.encntr_id = t_rec->qual[d1.seq].encntr_id
join p 
	where p.person_id= e.person_id
head report
	cnt = 0
	EKSOPSRequest->expert_trigger = t_rec->cons.trigger
detail
	cnt = cnt +1
	stat = alterlist(EKSOPSRequest->qual, cnt)
	EKSOPSRequest->qual[cnt].person_id = p.person_id
	EKSOPSRequest->qual[cnt].sex_cd  = p.sex_cd
	EKSOPSRequest->qual[cnt].birth_dt_tm  = p.birth_dt_tm
	EKSOPSRequest->qual[cnt].encntr_id  = e.encntr_id
	stat = alterlist(EKSOPSRequest->qual[cnt].data,2)
	EKSOPSRequest->qual[cnt].data[1].double_var = t_rec->qual[d1.seq].order_id
	EKSOPSRequest->qual[cnt].data[2].double_var = t_rec->qual[d1.seq].diag_qual[d2.seq].nomenclature_id
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].person_id=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].person_id))))
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].encntr_id=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].encntr_id))))
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].data[1].double_var=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].data[1].double_var))))
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].data[2].double_var=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].data[2].double_var))))
with nocounter



/*
select into "NL:"
	e.encntr_id,
	e.person_id,
	e.reg_dt_tm,
	p.birth_dt_tm,
	p.sex_cd
from
	 person p
	,encounter e
	,orders o
	,(dummyt d1 with seq=t_rec->cnt)
plan d1
	where t_rec->qual[d1.seq].cancel_ind = 0
join e 
	where e.encntr_id = t_rec->qual[d1.seq].encntr_id
join p 
	where p.person_id= e.person_id
join o
	where o.order_id = t_rec->qual[d1.seq].order_id
order by
	o.order_id
head report
	cnt = 0
	EKSOPSRequest->expert_trigger = t_rec->cons.trigger
head o.order_id
	cnt = cnt +1
	stat = alterlist(EKSOPSRequest->qual, cnt)
	EKSOPSRequest->qual[cnt].person_id = p.person_id
	EKSOPSRequest->qual[cnt].sex_cd  = p.sex_cd
	EKSOPSRequest->qual[cnt].birth_dt_tm  = p.birth_dt_tm
	EKSOPSRequest->qual[cnt].encntr_id  = e.encntr_id
	stat = alterlist(EKSOPSRequest->qual[cnt].data,1)
	EKSOPSRequest->qual[cnt].data[1].double_var = t_rec->qual[d1.seq].order_id
	EKSOPSRequest->qual[cnt].data[1].vc_var	 	= t_rec->qual[d1.seq].diag_list
	
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].person_id=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].person_id))))
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].encntr_id=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].encntr_id))))
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].data[1].double_var=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].data[1].double_var))))
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].data[1].vc_var=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].data[1].vc_var))))
with nocounter
*/	
call echorecord(EKSOPSRequest)

if (size(EKSOPSRequest->qual,5) > 0)

	set dparam = 0
	if (t_rec->audit_mode != 1)
		call writeLog(build2("------>CALLING srvRequest"))
		call srvRequest(dparam)
	endif
else
	set reply->status_data.status = "Z"
endif

call writeLog(build2("* END   Building EKS Call to Add Dx  *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building EKS Call to Cancel   *******************************************"))

select into "NL:"
	e.encntr_id,
	e.person_id,
	e.reg_dt_tm,
	p.birth_dt_tm,
	p.sex_cd
from
	 person p
	,encounter e
	,(dummyt d1 with seq=t_rec->cnt)
plan d1
	where t_rec->qual[d1.seq].cancel_ind = 1
join e 
	where e.encntr_id = t_rec->qual[d1.seq].encntr_id
join p 
	where p.person_id= e.person_id
head report
	cnt = 0
	EKSOPSRequest->expert_trigger = t_rec->cons.trigger_cancel
detail
	cnt = cnt +1
	stat = alterlist(EKSOPSRequest->qual, cnt)
	EKSOPSRequest->qual[cnt].person_id = p.person_id
	EKSOPSRequest->qual[cnt].sex_cd  = p.sex_cd
	EKSOPSRequest->qual[cnt].birth_dt_tm  = p.birth_dt_tm
	EKSOPSRequest->qual[cnt].encntr_id  = e.encntr_id
	stat = alterlist(EKSOPSRequest->qual[cnt].data,2)
	EKSOPSRequest->qual[cnt].data[1].double_var = t_rec->qual[d1.seq].order_id
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].person_id=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].person_id))))
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].encntr_id=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].encntr_id))))
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].data[1].double_var=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].data[1].double_var))))
with nocounter

call echorecord(EKSOPSRequest)

if (size(EKSOPSRequest->qual,5) > 0)

	set dparam = 0
	if (t_rec->audit_mode != 1)
		call writeLog(build2("------>CALLING srvRequest"))
		call srvRequest(dparam)
	endif
else
	set reply->status_data.status = "Z"
endif

call writeLog(build2("* END   Building EKS Call to Cancel  *******************************************"))
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

set reply->status_data.status = "S"
set reply->status_data.subeventstatus[1].targetobjectname = "records"
set reply->status_data.subeventstatus[1].targetobjectvalue = t_rec->files.records_attachment
#exit_script

/*
if (reply->status_data.status in("Z","S"))
	call writeLog(build2("* START Set Date Range ************************************"))
	call set_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name,t_rec->dates.end_dt_tm)
	call writeLog(build2("* END Set Date Range ************************************v1"))
endif
;001 end
*/

call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)


call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
