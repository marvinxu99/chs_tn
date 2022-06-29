declare link_encntrid = f8 go
declare link_personid = f8 go
declare link_clinicaleventid = f8 go
declare link_orderid = f8 go
set debug_ind = 1 go
/*
;TRUE:person_id=15556719|encntr_id=111688463|clinical_event_id=4453601848|event_id=4453601849| (0.31s)
;TRUE:person_id=16799260|encntr_id=110765501|clinical_event_id=4453870681|event_id=4453870682| (0.57s)
The result of 'set log_misc1 = build2(3654205312.0) go' is  3654205312.00
*/
;set link_clinicaleventid =     4469868088 go


select into "nl:"
from  encounter e
	 ,encntr_alias ea
	 ,person p
plan ea
	where ea.alias = "5217801980"
join e
	where e.encntr_id = ea.encntr_id
join p
	where p.person_id = e.person_id
detail
	link_encntrid	= e.encntr_id
	link_personid	= p.person_id
with nocounter go

call echo(build2("link_encntrid=",link_encntrid)) go
call echo(build2("link_personid=",link_personid)) go

execute cov_wh_sepsis_ega_calc go
