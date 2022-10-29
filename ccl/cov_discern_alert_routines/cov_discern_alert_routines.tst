set debug_ind = 1 go
execute cov_std_ce_routines go
execute cov_discern_alert_routines go

declare pEncntrID = f8 with noconstant(0) go
declare pPersonID = f8 with noconstant(0) go

select into "nl:"
from
	encntr_alias ea
	,encounter e
plan ea where ea.alias = "2116400626"
join e where e.encntr_id = ea.encntr_id
detail
	pEncntrID = ea.encntr_id
	pPersonID = e.person_id
with nocounter go
	
	
;call echo(build2("sAddCovDiscernAlert=",sAddCovDiscernAlert(pEncntrID,0.0,"Patient Custody","Needs to be reviewed again"))) go
call echo(build2("sGetCovDiscernAlert=",sGetCovDiscernAlert(pEncntrID,0.0,"Patient Custody"))) go

/*
select ce.event_cd,ce.result_val,ce.event_end_dt_tm,clr.result_cd,clr.descriptor,clr.nomenclature_id,clr.* from
clinical_event ce,ce_coded_result clr
plan ce where ce.encntr_id = 124858279
and ce.valid_from_dt_tm >= cnvtdatetime(curdate-1,0)
join clr
	where clr.event_id = ce.event_id
order by
	ce.updt_dt_tm desc
with nocounter,uar_code(d),format(date,";;q"),time=60
go
*/
