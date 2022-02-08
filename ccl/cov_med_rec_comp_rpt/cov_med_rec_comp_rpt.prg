/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:
	Source file name:	cov_med_rec_comp_rpt.prg
	Object name:		cov_med_rec_comp_rpt
	Request #:
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:		Called by ccl program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
 
001		01/31/2022	Dan Herren				CR 11911
 
******************************************************************************/
 
;;;drop program cov_med_rec_compliance_rpt:dba go
;;;create program cov_med_rec_compliance_rpt:dba
 
drop program cov_med_rec_comp_rpt:dba go
create program cov_med_rec_comp_rpt:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date and Time" = "SYSDATE"
	, "End Date and Time" = "SYSDATE"
	, "Facility" = 0
	, "Encounter Type(s)" = 0
	, "Provider" = 0
	;<<hidden>>"Search" = ""
	;<<hidden>>"Delete" = ""
	, "Output to File" = 0
 
with OUTDEV, START_DT_TM, END_DT_TM, FACILITY, ENCNTR_TYPE, NEW_PROVIDER,
	OUTPUT_FILE
 
 
call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))
 
declare ADMIT_PHY_VAR = f8 with constant(uar_get_code_by("DISPLAYKEY",  333, "ADMITTINGPHYSICIAN")),protect ;001
 
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
 
free set t_rec
record t_rec
(
	1 cnt			= i4
	1 prompts
	 2 start_dt_tm	= vc
	 2 end_dt_tm	= vc
	1 parameters
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
	 2 opr_fac_var = vc
	 2 opr_encntr_type_var = vc
	 2 opr_provider_var = vc ;001
	1 qual[*]
	 2 person_id = f8
	 2 encntr_id = f8
	 2 reg_dt_tm = dq8
	 2 disch_dt_tm = dq8
	 2 encntr_type = vc
	 2 patient_name = vc
	 2 facility = vc
	 2 unit = vc
	 2 room = vc
	 2 fin = vc
	 2 med_history_complete_ind = i2
	 2 med_history_complete_dt_tm  =dq8
	 2 med_history_complete_prsnl = vc
	 2 med_history_complete_prsnl_id = f8
	 2 med_history_complete_role = vc
	 2 admitting_physician_id = f8 ;001
	 2 admitting_physician = vc ;001
	 2 admission_med_rec_ind = i2
	 2 admission_med_rec_dt_tm = dq8
	 2 admission_med_rec_prsnl = vc
	 2 admission_med_rec_prsnl_id = f8
	 2 admission_med_rec_status = vc
	 2 admission_med_rec_role = vc
	 2 admit_decision_dt_tm = dq8
	 2 discharge_med_rec_ind = i2
	 2 discharge_med_rec_dt_tm = dq8
	 2 discharge_med_rec_prsnl = vc
	 2 discharge_med_rec_prsnl_id = f8
	 2 discharge_med_rec_status = vc
	 2 discharge_med_rec_role = vc
)
 
;call addEmailLog("chad.cummings@covhlth.com")
 
 
;
 
set t_rec->prompts.start_dt_tm = $START_DT_TM
set t_rec->prompts.end_dt_tm = $END_DT_TM
 
 
if(substring(1,1,reflect(parameter(parameter2($FACILITY),0))) = "L")	;multiple values were selected
	set t_rec->parameters.opr_fac_var = "in"
elseif(parameter(parameter2($FACILITY),1)= 0.0)						;all (any) values were selected
	set t_rec->parameters.opr_fac_var = "!="
else																		;a single value was selected
	set t_rec->parameters.opr_fac_var = "="
endif
 
if(substring(1,1,reflect(parameter(parameter2($ENCNTR_TYPE),0))) = "L")	;multiple values were selected
	set t_rec->parameters.opr_encntr_type_var = "in"
elseif(parameter(parameter2($ENCNTR_TYPE),1)= 0.0)						;all (any) values were selected
	set t_rec->parameters.opr_encntr_type_var = "!="
else																		;a single value was selected
	set t_rec->parameters.opr_encntr_type_var = "="
endif
 
/* BEGIN 001 */
if(substring(1,1,reflect(parameter(parameter2($NEW_PROVIDER),0))) = "L")	;multiple values were selected
	set t_rec->parameters.opr_provider_var = "in"
elseif(parameter(parameter2($NEW_PROVIDER),1)= 0)						;all (any) values were selected
	set t_rec->parameters.opr_provider_var = ">="
else																		;a single value was selected
	set t_rec->parameters.opr_provider_var = "="
endif
/* END 001 */
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Encounters *********************************"))
 
select into "nl:"
from
	 encounter e
	,person p
	,encntr_prsnl_reltn epr ;001
	,prsnl pl ;001
	,dummyt d1
	,order_recon oc
	,prsnl p1
plan e
	where	(		(e.disch_dt_tm between cnvtdatetime(t_rec->prompts.start_dt_tm) and cnvtdatetime(t_rec->prompts.end_dt_tm))
				or	(e.reg_dt_tm between cnvtdatetime(t_rec->prompts.start_dt_tm) and cnvtdatetime(t_rec->prompts.end_dt_tm))
				or 	(e.reg_dt_tm < cnvtdatetime(t_rec->prompts.end_dt_tm) and (e.disch_dt_tm = null))
			)
	;and e.encntr_type_cd in(value(uar_get_code_by("MEANING",71,"INPATIENT")))
	and operator(e.loc_facility_cd,	t_rec->parameters.opr_fac_var, 			$FACILITY)
	and operator(e.encntr_type_cd, 	t_rec->parameters.opr_encntr_type_var, 	$ENCNTR_TYPE)
	and e.active_ind = 1
join p
	where p.person_id = e.person_id
join d1
join epr ;001
	where epr.encntr_id = e.encntr_id
		and epr.encntr_prsnl_r_cd = ADMIT_PHY_VAR ;1116
		and epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and epr.active_ind = 1
join pl ;001
	where pl.person_id = epr.prsnl_person_id ;admitting physician
		and pl.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and pl.active_ind = 1
join oc
	where oc.encntr_id = e.encntr_id
	and   oc.recon_type_flag in(1,3) ;admission and discharge
join p1
	where p1.person_id = oc.performed_prsnl_id
order by
	e.encntr_id
head report
	i = 0
;head e.encntr_id
detail
	t_rec->cnt = (t_rec->cnt + 1)
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].encntr_id 				= e.encntr_id
	t_rec->qual[t_rec->cnt].person_id 				= e.person_id
	t_rec->qual[t_rec->cnt].reg_dt_tm 				= e.reg_dt_tm
	t_rec->qual[t_rec->cnt].disch_dt_tm				= e.disch_dt_tm
	t_rec->qual[t_rec->cnt].encntr_type	 			= uar_get_code_display(e.encntr_type_cd)
	t_rec->qual[t_rec->cnt].facility 				= uar_get_code_display(e.loc_facility_cd)
	t_rec->qual[t_rec->cnt].room 					= uar_get_code_display(e.loc_room_cd)
	t_rec->qual[t_rec->cnt].unit 					= uar_get_code_display(e.loc_nurse_unit_cd)
	t_rec->qual[t_rec->cnt].patient_name 			= p.name_full_formatted
	t_rec->qual[t_rec->cnt].admitting_physician_id	= pl.person_id ;001
	t_rec->qual[t_rec->cnt].admitting_physician		= pl.name_full_formatted ;001
 
	if (oc.recon_type_flag = 1)
		t_rec->qual[t_rec->cnt].admission_med_rec_ind = 1
		t_rec->qual[t_rec->cnt].admission_med_rec_prsnl = p1.name_full_formatted
		t_rec->qual[t_rec->cnt].admission_med_rec_prsnl_id = p1.person_id
		t_rec->qual[t_rec->cnt].admission_med_rec_dt_tm = oc.performed_dt_tm
		t_rec->qual[t_rec->cnt].admission_med_rec_role = uar_get_code_display(p1.position_cd)
		t_rec->qual[t_rec->cnt].admission_med_rec_status = uar_get_code_display(oc.recon_status_cd)
	elseif (oc.recon_type_flag = 3)
		t_rec->qual[t_rec->cnt].discharge_med_rec_ind = 1
		t_rec->qual[t_rec->cnt].discharge_med_rec_prsnl = p1.name_full_formatted
		t_rec->qual[t_rec->cnt].discharge_med_rec_prsnl_id = p1.person_id
		t_rec->qual[t_rec->cnt].discharge_med_rec_dt_tm = oc.performed_dt_tm
		t_rec->qual[t_rec->cnt].discharge_med_rec_role = uar_get_code_display(p1.position_cd)
		t_rec->qual[t_rec->cnt].discharge_med_rec_status = uar_get_code_display(oc.recon_status_cd)
	endif
with nocounter, outerjoin = d1
 
call writeLog(build2("* END   Finding Encounters *********************************"))
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
with nocounter
 
call writeLog(build2("* END   Determine Med Hx Compliance ************************"))
call writeLog(build2("************************************************************"))
 
/*
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Determine Admission Med Rec ************************"))
 
select into "nl:"
from
	(dummyt d1 with seq=t_rec->cnt)
	,order_recon oc
	,prsnl p1
plan d1
join oc
	where oc.encntr_id = t_rec->qual[d1.seq].encntr_id
	and   oc.recon_type_flag = 1 ;admission
join p1
	where p1.person_id = oc.performed_prsnl_id
order by
	 oc.encntr_id
	,oc.performed_dt_tm desc
head oc.encntr_id
	t_rec->qual[d1.seq].admission_med_rec_ind = 1
	t_rec->qual[d1.seq].admission_med_rec_prsnl = p1.name_full_formatted
	t_rec->qual[d1.seq].admission_med_rec_prsnl_id = p1.person_id
	t_rec->qual[d1.seq].admission_med_rec_dt_tm = oc.performed_dt_tm
	t_rec->qual[d1.seq].admission_med_rec_role = uar_get_code_display(p1.position_cd)
	t_rec->qual[d1.seq].admission_med_rec_status = uar_get_code_display(oc.recon_status_cd)
with nocounter
 
call writeLog(build2("* END   Determine Admission Med Rec ************************"))
call writeLog(build2("************************************************************"))
 
/* BEGIN 001 */
/*
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Determine Discharge Med Rec ************************"))
 
select into "nl:"
from
	(dummyt d1 with seq=t_rec->cnt)
	,order_recon oc
	,prsnl p1
plan d1
join oc
	where oc.encntr_id = t_rec->qual[d1.seq].encntr_id
	and   oc.recon_type_flag = 3 ;discharge
join p1
	where p1.person_id = oc.performed_prsnl_id
order by
	 oc.encntr_id
	,oc.performed_dt_tm desc
head oc.encntr_id
	t_rec->qual[d1.seq].discharge_med_rec_ind = 1
	t_rec->qual[d1.seq].discharge_med_rec_prsnl = p1.name_full_formatted
	t_rec->qual[d1.seq].discharge_med_rec_prsnl_id = p1.person_id
	t_rec->qual[d1.seq].discharge_med_rec_dt_tm = oc.performed_dt_tm
	t_rec->qual[d1.seq].discharge_med_rec_role = uar_get_code_display(p1.position_cd)
	t_rec->qual[d1.seq].discharge_med_rec_status = uar_get_code_display(oc.recon_status_cd)
with nocounter
 
call writeLog(build2("* END   Determine Admission Med Rec ************************"))
call writeLog(build2("************************************************************"))
/* END 001 */
 
call get_fin(null)
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Generating Output **********************************"))
 
select
 
	if ($OUTPUT_FILE = 1)
		with nocounter, pcformat (^"^, ^,^, 1,0), format, format=stream, formfeed=none  ;no padding
	else
		with nocounter, separator = " ", format
	endif
 
into $OUTDEV
	 person_id 								 = t_rec->qual[d1.seq].person_id
	,encntr_id                               = t_rec->qual[d1.seq].encntr_id
	,patient_name                            = substring(1,100,t_rec->qual[d1.seq].patient_name)
	,facility                                = substring(1,100,t_rec->qual[d1.seq].facility    )
	,unit                                    = substring(1,100,t_rec->qual[d1.seq].unit        )
	,room                                    = substring(1,100,t_rec->qual[d1.seq].room        )
	,fin                                     = substring(1,100,t_rec->qual[d1.seq].fin         )
	,reg_dt_tm				                 = format(t_rec->qual[d1.seq].reg_dt_tm,";;q")
	,disch_dt_tm			                 = format(t_rec->qual[d1.seq].disch_dt_tm,";;q")
	,encntr_type				             = substring(1,100,t_rec->qual[d1.seq].encntr_type)
	,admitting_physician					 = substring(1,100,t_rec->qual[d1.seq].admitting_physician) ;001
	,med_history_complete_ind                = t_rec->qual[d1.seq].med_history_complete_ind
	,med_history_complete_dt_tm              = format(t_rec->qual[d1.seq].med_history_complete_dt_tm,";;q")
	,med_history_complete_prsnl              = substring(1,100,t_rec->qual[d1.seq].med_history_complete_prsnl)
	;,med_history_complete_prsnl_id          = t_rec->qual[d1.seq].med_history_complete_prsnl_id
	,med_history_complete_role               = substring(1,100,t_rec->qual[d1.seq].med_history_complete_role)
	,admission_med_rec_ind                   = t_rec->qual[d1.seq].admission_med_rec_ind
	,admission_med_rec_dt_tm                 = format(t_rec->qual[d1.seq].admission_med_rec_dt_tm,";;q")
	,admission_med_rec_prsnl                 = substring(1,100,t_rec->qual[d1.seq].admission_med_rec_prsnl)
	;,admission_med_rec_prsnl_id             = t_rec->qual[d1.seq].admission_med_rec_prsnl_id
	,admission_med_rec_status                = substring(1,100,t_rec->qual[d1.seq].admission_med_rec_status)
	,admission_med_rec_role                  = substring(1,100,t_rec->qual[d1.seq].admission_med_rec_role)
	,admit_decision_dt_tm                    = format(t_rec->qual[d1.seq].admit_decision_dt_tm,";;q")
	/* begin 001 */
	,discharge_med_rec_ind                   = t_rec->qual[d1.seq].discharge_med_rec_ind
	,discharge_med_rec_dt_tm                 = format(t_rec->qual[d1.seq].discharge_med_rec_dt_tm,";;q")
	,discharge_med_rec_prsnl                 = substring(1,100,t_rec->qual[d1.seq].discharge_med_rec_prsnl)
	;,discharge_med_rec_prsnl_id             = t_rec->qual[d1.seq].discharge_med_rec_prsnl_id
	,discharge_med_rec_status                = substring(1,100,t_rec->qual[d1.seq].discharge_med_rec_status)
	,discharge_med_rec_role                  = substring(1,100,t_rec->qual[d1.seq].discharge_med_rec_role)
	/* end 001 */
from
	(dummyt d1 with seq = t_rec->cnt)
plan d1
	where operator(t_rec->qual[d1.seq].admitting_physician_id, t_rec->parameters.opr_provider_var, cnvtreal($NEW_PROVIDER))
order by
	 facility
	,unit
	,room
	,patient_name
with nocounter,format,separator=" "
 
call writeLog(build2("* END   Generating Output **********************************"))
call writeLog(build2("************************************************************"))
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))
 
#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)
call echorecord(t_rec)
 
end
go
 
