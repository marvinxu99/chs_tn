/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_med_hx_monitoring_rpt.prg
	Object name:		cov_med_hx_monitoring_rpt
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).
						Facility
						Unit
						FIN
						Encntr Type
						Location Path
						ED Arrival Time
						ED Decision to Admit
						PSO Time
						Med Hx Time
						Admission Med Rec Time
						First Med order post PSO?
						
						Is Med Hx done before PSO
						Med hx done X hours after PSO

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_med_hx_monitoring_rpt:dba go
create program cov_med_hx_monitoring_rpt:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date and Time" = "SYSDATE"
	, "End Date and Time" = "SYSDATE"
	, "Facility" = 0 

with OUTDEV, START_DT_TM, END_DT_TM, FACILITY

execute cov_std_log_routines

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
	 2 start_dt_tm	= vc
	 2 end_dt_tm	= vc
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
	1 facility_cnt	= i4
	1 facility_qual[*]
	 2 loc_facility_cd = f8
	 2 facility_display = vc
	1 qual[*]
	 2 person_id			= f8
	 2 encntr_id			= f8
	 2 loc_unit_cd 			= f8
	 2 loc_facility_cd		= f8
	 2 facility				= vc
	 2 unit					= vc
	 2 reg_dt_tm			= dq8
	 2 inpatient_admit_dt_tm = dq8
	 2 disch_dt_tm			= dq8
	 2 arrival_dt_tm		= dq8
	 2 mrn					= vc
	 2 fin					= vc
	 2 name_full_formatted 	= vc
	 2 encntr_type			= vc
	 2 encntr_type_cd		= f8
	 2 location_history		= vc
	 2 encntr_loc_cnt		= i4
	 2 encntr_loc_qual[*]
  	  3 loc_facility_cd 	= f8
  	  3 loc_unit_cd 		= f8
  	  3 facility			= vc
  	  3 unit				= vc
  	  3 beg_dt_tm			= dq8
  	  3 end_dt_tm			= dq8
  	  3 encntr_loc_hist_id	= f8
  	 2 pso_admit_dt_tm		= dq8
  	 2 pso_admit_desc		= vc
  	 2 ed_decision_dt_tm	= dq8
  	 2 ed_decision_desc		= vc
  	 2 medication_hx_dt_tm	= dq8
  	 2 admission_med_rec_dt_tm = dq8
  	 2 first_med_post_pso_dt_tm = dq8
  	 2 first_med_post_desc = vc
	 2 med_history_complete_ind = i2
	 2 med_history_complete_dt_tm  =dq8
	 2 med_history_complete_prsnl = vc
	 2 med_history_complete_prsnl_id = f8
	 2 med_history_complete_role = vc
	 2 admitting_physician_id = f8 
	 2 admitting_physician = vc 
	 2 admission_med_rec_ind = i2
	 2 admission_med_rec_dt_tm = dq8
	 2 admission_med_rec_prsnl = vc
	 2 admission_med_rec_prsnl_id = f8
	 2 admission_med_rec_status = vc
	 2 admission_med_rec_role = vc  
	 2 med_hx_before_pso = i2
	 2 med_hx_after_pso_hrs = f8
	 2 medhx_after_pso = vc
	 2 medhx_before_pso = vc	 
)

;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.start_dt_tm = $START_DT_TM
set t_rec->prompts.end_dt_tm = $END_DT_TM

set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)

set t_rec->dates.start_dt_tm 	= cnvtdatetime(t_rec->prompts.start_dt_tm)
set t_rec->dates.end_dt_tm 		= cnvtdatetime(t_rec->prompts.end_dt_tm)

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Facility ***********************************"))

set stat = cnvtjsontorec(sGet_PromptValues(parameter2($FACILITY)))
call echorecord(prompt_values)

select into "nl:"
from
	code_value cv
plan cv
	where expand(i,1,prompt_values->value_cnt,cv.code_value,prompt_values->value_qual[i].value_f8)
	and   cv.active_ind = 1
order by
	 cv.display
	,cv.code_value
head cv.code_value
	t_rec->facility_cnt += 1
	stat = alterlist(t_rec->facility_qual,t_rec->facility_cnt)
	t_rec->facility_qual[t_rec->facility_cnt].loc_facility_cd = cv.code_value
	t_rec->facility_qual[t_rec->facility_cnt].facility_display = cv.display
with nocounter
	
/*
if (prompt_values->value_cnt = 0)
	set t_rec->cons.opr_catalog_var = "1=1"
else
	set t_rec->cons.opr_catalog_var = "expand(i,1,prompt_values->value_cnt,oc.catalog_cd,prompt_values->value_qual[i].value_f8)"
endif 
*/
   
call writeLog(build2("* END   Finding Facility  **********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Encounters   *******************************************"))

select into "nl:"
from
	encounter e
plan e
	where e.reg_dt_tm between cnvtdatetime(t_rec->dates.start_dt_tm) and cnvtdatetime(t_rec->dates.end_dt_tm)
	and   e.active_ind = 1
	and   expand(i,1,t_rec->facility_cnt,e.loc_facility_cd,t_rec->facility_qual[i].loc_facility_cd)
order by
	e.encntr_id
head report
	null
head e.encntr_id
	t_rec->cnt += 1
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].encntr_id = e.encntr_id
	t_rec->qual[t_rec->cnt].person_id = e.person_id
	t_rec->qual[t_rec->cnt].arrival_dt_tm = e.arrive_dt_tm
	t_rec->qual[t_rec->cnt].encntr_type_cd = e.encntr_type_cd
	t_rec->qual[t_rec->cnt].encntr_type = uar_get_code_display(e.encntr_type_cd)
foot report
	null
with nocounter

call get_patientloc(0)


call writeLog(build2("* END   Finding Encounters   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Finding Patient Location History ********************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,encntr_loc_hist elh
plan d1
	where t_rec->qual[d1.seq].encntr_id > 0.0
join elh
	where elh.encntr_id 		= t_rec->qual[d1.seq].encntr_id
	and   elh.active_ind 		= 1
	and   elh.loc_facility_cd 	> 0.0
	and   elh.loc_nurse_unit_cd > 0.0
order by
	 elh.encntr_id
	,elh.activity_dt_tm
	,elh.encntr_loc_hist_id
head report
	call writeLog(build2("->Inside location query query"))
	j = 0
	add_ind = 0
	prev_loc_cd = 0.0
head elh.encntr_id
	add_ind = 0
	prev_loc_cd = 0.0
	j = locateval(i,1,t_rec->cnt,elh.encntr_id,t_rec->qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(elh.encntr_id))," at position=",trim(cnvtstring(j))))
head elh.activity_dt_tm
	add_ind = 0
head elh.encntr_loc_hist_id
 if (j > 0)
	add_ind = 0
	if (t_rec->qual[j].encntr_loc_cnt = 0)
		add_ind = 1
	else
		if (elh.loc_nurse_unit_cd = prev_loc_cd)
			call writeLog(build2("same unit=",trim(uar_get_code_display(elh.loc_nurse_unit_cd))
				,"(",trim(cnvtstring(elh.loc_nurse_unit_cd)),")"))
			t_rec->qual[j].encntr_loc_qual[(t_rec->qual[j].encntr_loc_cnt-1)].end_dt_tm = elh.end_effective_dt_tm
		else
			add_ind = 1
			call writeLog(build2("old unit="
				,trim(uar_get_code_display(t_rec->qual[j].encntr_loc_qual[(t_rec->qual[j].encntr_loc_cnt-1)].loc_unit_cd))
				,"(",trim(cnvtstring(t_rec->qual[j].encntr_loc_qual[(t_rec->qual[j].encntr_loc_cnt-1)].loc_unit_cd)),")"))
			call writeLog(build2("new unit=",trim(uar_get_code_display(elh.loc_nurse_unit_cd))
				,"(",trim(cnvtstring(elh.loc_nurse_unit_cd)),")"))
		endif
	endif
	if (add_ind = 1)
		prev_loc_cd = elh.loc_nurse_unit_cd
		t_rec->qual[j].encntr_loc_cnt = (t_rec->qual[j].encntr_loc_cnt + 1)
		stat = alterlist(t_rec->qual[j].encntr_loc_qual,t_rec->qual[j].encntr_loc_cnt)
		call writeLog(build2("adding elh.encntr_loc_hist_id=",elh.encntr_loc_hist_id))
		call writeLog(build2("adding t_rec->patient_qual[j].encntr_loc_cnt=",t_rec->qual[j].encntr_loc_cnt))
		t_rec->qual[j].encntr_loc_qual[t_rec->qual[j].encntr_loc_cnt].loc_facility_cd		= elh.loc_facility_cd
		t_rec->qual[j].encntr_loc_qual[t_rec->qual[j].encntr_loc_cnt].loc_unit_cd			= elh.loc_nurse_unit_cd
		t_rec->qual[j].encntr_loc_qual[t_rec->qual[j].encntr_loc_cnt].facility = uar_get_code_display(elh.loc_facility_cd)
		t_rec->qual[j].encntr_loc_qual[t_rec->qual[j].encntr_loc_cnt].unit	= uar_get_code_display(elh.loc_nurse_unit_cd)
		t_rec->qual[j].encntr_loc_qual[t_rec->qual[j].encntr_loc_cnt].beg_dt_tm				= elh.beg_effective_dt_tm
		t_rec->qual[j].encntr_loc_qual[t_rec->qual[j].encntr_loc_cnt].end_dt_tm				= elh.end_effective_dt_tm
		t_rec->qual[j].encntr_loc_qual[t_rec->qual[j].encntr_loc_cnt].encntr_loc_hist_id	= elh.encntr_loc_hist_id
	endif
 endif
	add_ind = 0
foot elh.encntr_loc_hist_id
	add_ind = 0
foot elh.activity_dt_tm
	add_ind = 0
foot elh.encntr_id
	add_ind = 0
	prev_loc_cd = 0.0
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(elh.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
foot report
	j = 0
with nocounter


for (i=1 to t_rec->cnt)
	if (t_rec->qual[i].encntr_loc_cnt > 0)
		for (j=1 to t_rec->qual[i].encntr_loc_cnt)			
			if (j=1)
				set t_rec->qual[i].location_history =
					trim(replace(t_rec->qual[i].encntr_loc_qual[j].unit,t_rec->qual[i].facility,""),3)
			else
				set t_rec->qual[i].location_history = concat(
						 t_rec->qual[i].location_history
						,";"
						,trim(replace(t_rec->qual[i].encntr_loc_qual[j].unit,t_rec->qual[i].facility,""),3)
						 )
			endif
			
		endfor
	endif
endfor

call writeLog(build2("* END   Finding Patient Location History ********************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Orders   *******************************************"))

select into "nl:"
from
	 orders o
	,order_detail od
	,order_entry_fields oef
	,order_catalog oc
	,(dummyt d1 with seq=t_rec->cnt)
plan d1
join o
	where o.encntr_id = t_rec->qual[d1.seq].encntr_id
	and o.order_status_cd in(
								 value(uar_get_code_by("MEANING",6004,"ORDERED"))
								,value(uar_get_code_by("MEANING",6004,"COMPLETED"))
								)

join oc
	where oc.catalog_cd = o.catalog_cd
	and   oc.description in( 
								"PSO Admit*" 
								,"ED Decision to Admit"
							)
join od
	where od.order_id = o.order_id
join oef
	where oef.oe_field_id = od.oe_field_id
	and   oef.description = "Requested Start Date/Time"
order by
	 o.encntr_id
	,o.catalog_cd
	,o.orig_order_dt_tm
	,od.action_sequence desc
	,o.order_id
head report
	null
head o.encntr_id	
	null
head o.catalog_cd
	case (oc.description)
		of "PSO Admit*":			t_rec->qual[d1.seq].pso_admit_dt_tm		= od.oe_field_dt_tm_value
									t_rec->qual[d1.seq].pso_admit_desc 		= o.ordered_as_mnemonic
		of "ED Decision to Admit":	t_rec->qual[d1.seq].ed_decision_dt_tm	= od.oe_field_dt_tm_value
									t_rec->qual[d1.seq].ed_decision_desc	= o.ordered_as_mnemonic
	endcase
foot report
	null
with nocounter
	

call writeLog(build2("* END   Finding Orders   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Admission Med Rec *********************************"))
 
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,order_recon oc
	,prsnl p1
plan d1
join oc
	where oc.encntr_id = t_rec->qual[d1.seq].encntr_id
	and   oc.recon_type_flag in(1) ;admission
join p1
	where p1.person_id = oc.performed_prsnl_id
order by
	oc.encntr_id
head report
	i = 0
detail 
	if (oc.recon_type_flag = 1)
		t_rec->qual[t_rec->cnt].admission_med_rec_ind = 1
		t_rec->qual[t_rec->cnt].admission_med_rec_prsnl = p1.name_full_formatted
		t_rec->qual[t_rec->cnt].admission_med_rec_prsnl_id = p1.person_id
		t_rec->qual[t_rec->cnt].admission_med_rec_dt_tm = oc.performed_dt_tm
		t_rec->qual[t_rec->cnt].admission_med_rec_role = uar_get_code_display(p1.position_cd)
		t_rec->qual[t_rec->cnt].admission_med_rec_status = uar_get_code_display(oc.recon_status_cd)
	endif
with nocounter
 
call writeLog(build2("* END   Finding Admission Med Rec *********************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Determine Med Hx Compliance ************************"))
 
select into "nl:"
from
	(dummyt d1 with seq=t_rec->cnt)
	,order_compliance oc
	,prsnl p1
plan d1
join oc
	where oc.encntr_id = t_rec->qual[d1.seq].encntr_id
	and   oc.encntr_compliance_status_flag = 0
join p1
	where p1.person_id = oc.performed_prsnl_id
order by
	 oc.encntr_id
	,oc.performed_dt_tm desc
head oc.encntr_id
	t_rec->qual[d1.seq].med_history_complete_ind = 1
	t_rec->qual[d1.seq].med_history_complete_prsnl = p1.name_full_formatted
	t_rec->qual[d1.seq].med_history_complete_prsnl_id = p1.person_id
	t_rec->qual[d1.seq].med_history_complete_dt_tm = oc.performed_dt_tm
	t_rec->qual[d1.seq].med_history_complete_role = uar_get_code_display(p1.position_cd)
	
	if (oc.performed_dt_tm < t_rec->qual[d1.seq].pso_admit_dt_tm)
		t_rec->qual[d1.seq].med_hx_before_pso = 1
		t_rec->qual[d1.seq].medhx_before_pso = "X"
	else
		t_rec->qual[d1.seq].med_hx_after_pso_hrs = datetimediff(oc.performed_dt_tm,t_rec->qual[d1.seq].pso_admit_dt_tm,3)
		if (t_rec->qual[d1.seq].pso_admit_dt_tm > 0.0)
			t_rec->qual[d1.seq].medhx_after_pso = concat(trim(cnvtstring(t_rec->qual[d1.seq].med_hx_after_pso_hrs,11,2))," hours")
		endif
	endif
with nocounter
 
call writeLog(build2("* END   Determine Med Hx Compliance ************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding First Med Orders   *******************************************"))

select into "nl:"
from
	 orders o
	,order_catalog oc
	,(dummyt d1 with seq=t_rec->cnt)
plan d1
	where t_rec->qual[d1.seq].pso_admit_dt_tm > 0.0
join o
	where o.encntr_id = t_rec->qual[d1.seq].encntr_id
	and   o.orig_order_dt_tm >= cnvtdatetime(t_rec->qual[d1.seq].pso_admit_dt_tm)
	and   o.catalog_type_cd = value(uar_get_code_by("MEANING",6000,"PHARMACY"))
	and   o.orig_ord_as_flag = 0
join oc
	where oc.catalog_cd = o.catalog_cd
order by
	 o.encntr_id
	,o.orig_order_dt_tm
	,o.order_id
head report
	null
head o.encntr_id
	t_rec->qual[d1.seq].first_med_post_pso_dt_tm = o.orig_order_dt_tm
	t_rec->qual[d1.seq].first_med_post_desc = o.ordered_as_mnemonic
foot report
	null
with nocounter
	

call writeLog(build2("* END   Finding First Med Orders  *******************************************"))
call writeLog(build2("************************************************************"))


call get_mrn(0)
call get_fin(0)
call get_patientname(0)

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Output   *******************************************"))

select into t_rec->prompts.outdev
	 facility = substring(1,30,t_rec->qual[d1.seq].facility)
	,unit = substring(1,30,t_rec->qual[d1.seq].unit)
	,fin = substring(1,30,t_rec->qual[d1.seq].fin)
	,name_full_formatted = substring(1,100,t_rec->qual[d1.seq].name_full_formatted)
	,arrival_dt_tm = format(t_rec->qual[d1.seq].arrival_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
	,reg_dt_tm = format(t_rec->qual[d1.seq].reg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
	,ed_decision_dt_tm = format(t_rec->qual[d1.seq].ed_decision_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
	,pso_admit_dt_tm = format(t_rec->qual[d1.seq].pso_admit_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
	,med_hx_dt_tm = format(t_rec->qual[d1.seq].med_history_complete_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
	,med_rec_dt_tm = format(t_rec->qual[d1.seq].admission_med_rec_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
	,med_post_pso_dt_tm = format(t_rec->qual[d1.seq].first_med_post_pso_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
	,med_post_desc = substring(1,100,t_rec->qual[d1.seq].first_med_post_desc)
	,disch_dt_tm = format(t_rec->qual[d1.seq].disch_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")
	,medhx_before_pso = substring(1,30,t_rec->qual[d1.seq].medhx_before_pso)
	,medhx_after_pso = substring(1,30,t_rec->qual[d1.seq].medhx_after_pso)
from
	(dummyt d1 with seq=t_rec->cnt)
plan d1
order
	 facility
	,unit
	,name_full_formatted
with nocounter, format, separator = " "


call writeLog(build2("* END   Creating Output   *******************************************"))
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


;001 end

;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)


call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
