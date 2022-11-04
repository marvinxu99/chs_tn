;drop program cov_mpage_svc_fin_test go
;create program cov_mpage_svc_fin_test 
drop program cov_mpage_svc_fin go
create program cov_mpage_svc_fin
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = "" 

with OUTDEV, FIN

set _MEMORY_REPLY_STRING = "<html><body>script executed, nothing returned</body></html>"

free record t_rec
record t_rec
(
	1 sel_Fin				= vc
	1 cnt					= i2
	1 qual[*]
		2 encntr_id 		= f8
		2 person_id			= f8
		2 loc_facility_cd	= f8
		2 loc_nurse_unit_cd	= f8
		2 loc_room_cd		= f8
		2 loc_bed_cd		= f8
		2 cMRN				= vc
		2 facMRN			= vc
		2 FIN				= vc
		2 patient_name		= vc
		2 dob				= dq8
		2 gender_cd			= f8
		2 reg_dt_tm			= dq8
		2 disch_dt_tm		= dq8
)

free record o_rec
record o_rec
(
	1 encntr_id				= f8
	1 person_id				= f8
	1 facility				= vc
	1 nurse_unit			= vc
	1 room					= vc
	1 bed					= vc
	1 cmrn					= vc
	1 mrn					= vc
	1 fin					= vc
	1 patient_name			= vc
	1 dob					= vc
	1 gender				= vc
	1 reg_dt_tm				= vc
	1 disch_dt_tm			= vc
)

set t_rec->sel_Fin = $FIN

select into "nl:"
from
	 encntr_alias ea
	,encounter e
	,person p
plan ea
	where 	ea.alias = t_rec->sel_Fin
	and		ea.active_ind = 1
	and		ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and		ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and		ea.encntr_alias_type_cd	= 1077
join e
	where	e.encntr_id = ea.encntr_id
	and		e.active_ind = 1
join p
	where	p.person_id = e.person_id
	and		p.active_ind = 1
order by
	e.encntr_id
head report	
	t_rec->cnt = 0
head e.encntr_id
	t_rec->cnt = (t_rec->cnt + 1)
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].encntr_id				= e.encntr_id
	t_rec->qual[t_rec->cnt].person_id				= e.person_id
	t_rec->qual[t_rec->cnt].loc_bed_cd				= e.loc_bed_cd
	t_rec->qual[t_rec->cnt].loc_facility_cd			= e.loc_facility_cd
	t_rec->qual[t_rec->cnt].loc_nurse_unit_cd		= e.loc_nurse_unit_cd
	t_rec->qual[t_rec->cnt].loc_room_cd				= e.loc_room_cd
	t_rec->qual[t_rec->cnt].reg_dt_tm				= e.reg_dt_tm
	t_rec->qual[t_rec->cnt].disch_dt_tm				= e.disch_dt_tm
	t_rec->qual[t_rec->cnt].patient_name			= p.name_full_formatted
	t_rec->qual[t_rec->cnt].dob						= p.birth_dt_tm
	t_rec->qual[t_rec->cnt].FIN						= ea.alias
	t_rec->qual[t_rec->cnt].gender_cd				= p.sex_cd
foot report
	stat = 0
with nocounter

select into "nl:"
from
	 person_alias ea
	,code_value cv
	,(dummyt d1 with seq=t_rec->cnt)
plan d1
join ea
	where ea.person_id	= t_rec->qual[d1.seq].person_id
	and	  ea.active_ind	= 1
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join cv
	where cv.code_value =  ea.person_alias_type_cd
order by
	 ea.person_id
	,cv.display
head report
	stat = 0 
head ea.person_id
	stat = 0
head cv.display
	case (cv.display)
		of "Community Medical Record Number":	t_rec->qual[d1.seq].cMRN = cnvtalias(ea.alias,ea.alias_pool_cd)
	endcase
with nocounter

select into "nl:"
from
	 encntr_alias ea
	,code_value cv
	,(dummyt d1 with seq=t_rec->cnt)
plan d1
join ea
	where ea.encntr_id	= t_rec->qual[d1.seq].encntr_id
	and	  ea.active_ind	= 1
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join cv
	where cv.code_value = ea.encntr_alias_type_cd
order by
	 ea.encntr_id
	,cv.display
head report
	stat = 0 
head ea.encntr_id
	stat = 0
head cv.display
	case (cv.display)
		of "MRN":								t_rec->qual[d1.seq].facMRN = cnvtalias(ea.alias,ea.alias_pool_cd)
	endcase
with nocounter

call echo(cnvtrectojson(t_rec))

if (t_rec->cnt > 1)
	go to exit_script
endif

set o_rec->facility			= uar_get_code_display(t_rec->qual[1].loc_facility_cd)
set o_rec->nurse_unit		= uar_get_code_display(t_rec->qual[1].loc_nurse_unit_cd)
set o_rec->room				= uar_get_code_display(t_rec->qual[1].loc_room_cd)
set o_rec->bed				= uar_get_code_display(t_rec->qual[1].loc_bed_cd)
set o_rec->cmrn				= t_rec->qual[1].cMRN
set o_rec->mrn				= t_rec->qual[1].facMRN
set o_rec->fin				= t_rec->qual[1].FIN
set o_rec->patient_name		= t_rec->qual[1].patient_name
set o_rec->dob				= format(t_rec->qual[1].dob,";;q")
set o_rec->gender			= uar_get_code_display(t_rec->qual[1].gender_cd)
set o_rec->encntr_id		= t_rec->qual[1].encntr_id
set o_rec->person_id		= t_rec->qual[1].person_id
set o_rec->reg_dt_tm		= format(t_rec->qual[1].reg_dt_tm,";;q")
set o_rec->disch_dt_tm		= format(t_rec->qual[1].disch_dt_tm,";;q")

set _MEMORY_REPLY_STRING = cnvtrectojson(o_rec)

call echo(cnvtrectojson(o_rec))
/*
Passed in parameter:
·         Financial Number (for example, at Methodist currently Inpatient, 1900901710)
 
Web page would return:
·         Facility
·         Unit/Department
·         Room
·         Bed
·         CMRN
·         Facility MRN (alias pool)
·         Facility Financial Number
·         Patient Name (Last, First, MI)
·         Patient Date of Birth
·         Patient Birth Gender
·         Encounter Admit Date
·         Encounter Discharge Date
*/

#exit_script

end
go
