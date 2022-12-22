set debug_ind = 1 go
execute cov_std_encntr_routines go

declare trigger_personid = f8 with protect go
declare trigger_encntrid = f8 with protect go
declare trigger_orderid = f8 with protect go

declare link_personid = f8 with protect go
declare link_encntrid = f8 with protect go
declare link_orderid = f8 with protect go
declare log_retval = i4 go

declare FIN = vc with constant("5235501951") go
		
set trigger_encntrid = sGetEncntrID_ByFIN(FIN) go
set trigger_personid = sGetPersonID_ByFIN(FIN) go

set link_personid = trigger_personid go
set link_encntrid = trigger_encntrid go

call echo(build2("trigger_personid=",trigger_personid)) go
call echo(build2("trigger_encntrid=",trigger_encntrid)) go

select into "nl:"
from 
person_patient pp 
where pp.person_id = trigger_personid
head report
	log_retval = 0
detail
    call echo(pp.gest_age_at_birth)
	if (pp.gest_age_at_birth >= 259)
		log_retval = 100
	endif
with nocounter, nullreport go

call echo(build2("log_retval=",log_retval)) go

;execute cov_rule_current_ega2 go
