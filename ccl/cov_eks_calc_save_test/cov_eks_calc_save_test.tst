declare log_retval = i2 with noconstant(-1) go
declare log_misc1 = vc go

select into "nl:"
from
	clinical_event ce
plan ce
	where ce.clinical_event_id =     3654217719.00
head report
	log_retval = 0
detail
	log_misc1 = build2(datetimediff(cnvtdatetime(sysdate),ce.valid_from_dt_tm,4)," mins")
	if (datetimediff(cnvtdatetime(sysdate),ce.valid_from_dt_tm,4) > 360)
		log_retval = 100
	endif
with nocounter,nullreport go

call echo(build2("log_retval=",log_retval)) go
call echo(build2("log_misc1=",log_misc1)) go
