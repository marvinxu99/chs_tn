/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_passive_alert_audit.prg
  Object name:        cov_passive_alert_audit
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			initial build
******************************************************************************/
drop program cov_passive_alert_audit:dba go
create program cov_passive_alert_audit:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV


select  into $OUTDEV
	e.loc_facility_cd
	,e.encntr_status_cd
	,ea.alias
	,p.name_full_formatted
	,pa.alert_source
	,pa.alert_removal_source
	,pa.category_cd
	,pa.alert_txt
	,alert_active = pa.active_ind
	,created = pa.beg_effective_dt_tm
	,expire = pa.end_effective_dt_tm
	,pap.position_cd
	,paa.beg_effective_dt_tm
	,paa.action_type_txt
	,pr.name_full_formatted
	,pr.position_cd
	,pa.person_id
	,pa.encntr_id
	,pa.passive_alert_id
	,pa.allow_dismiss_ind
from 
	 passive_alert  pa
	,passive_alert_position pap
	,passive_alert_action paa
	,encounter e
	,person p
	,encntr_alias ea
	,prsnl pr
	,dummyt d1
	,dummyt d2
plan pa
	where cnvtdatetime(curdate,curtime3) between pa.beg_effective_dt_tm and pa.end_effective_dt_tm
	and   pa.active_ind = 1
join d1
join e 
	where e.encntr_id = pa.encntr_id
join p
	where p.person_id = pa.person_id
join d2
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
join pap
	where pap.passive_alert_id = outerjoin(pa.passive_alert_id)
join paa
	where paa.passive_alert_id = outerjoin(pa.passive_alert_id)
join pr
	where pr.person_id = outerjoin(paa.prsnl_id)
order by
	 p.name_full_formatted
	,pa.beg_effective_dt_tm desc
with format(date,"dd-mmm-yyyy hh:mm:ss;;q"),uar_code(d,1),separator = " ",format,outerjoin=d1,outerjoin=d2
end go

