set debug_ind = 1 go
execute cov_std_ce_routines go

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

set pEventCD = uar_get_code_by("DISPLAY",72,"hs Troponin Interpretation") go
set pResult = "Testing Result" go
set pEventDateTime = cnvtdatetime(sysdate) go
set pEventClass = "TXT" go	

;subroutine Add_CEResult(vEncntrID,vEventCD,vResult,vEventDateTime,vEventClass)
;set new_event_id = Add_CEResult(pEncntrID,pEventCD,pResult,pEventDateTime,pEventClass) go
call echo(build2("sGetPowerFormRefbyDesc=",sGetPowerFormRefbyDesc("Lymphedema Measurements Worksheet"))) go

call echo(build2("sMostRecentPowerForm="
	,sMostRecentPowerForm(pPersonID,0.0,sGetPowerFormRefbyDesc("Lymphedema Measurements Worksheet"),0))) go
	
	
	
call echo(build2("sGetFullDTAInfo=",sGetFullDTAInfo("D-Covenant Discern Alert"))) go
call echo(build2("sGetNomenIDforDTAReponse=",sGetNomenIDforDTAReponse("D-Covenant Discern Alert","Power of Attorney"))) go


