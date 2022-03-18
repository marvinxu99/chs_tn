declare link_encntrid = f8 go
declare link_personid = f8 go
set debug_ind = 1 go


select into "nl:"
from encounter e
	 ,encntr_alias ea
plan ea
	where ea.alias = "2116300845" ;2116400626
join e
	where e.encntr_id = ea.encntr_id
detail
	link_encntrid	= e.encntr_id
	link_personid	= e.person_id
with nocounter go

execute cov_copy_powerform_results ~MINE~,~Lymphedema Measurements Worksheet~ go

