declare link_encntrid = f8 go
declare link_personid = f8 go
declare link_clinicaleventid = f8 go

set link_clinicaleventid =    3646128577 go;3618766902 go


select into "nl:"
from clinical_event ce
plan ce
	where ce.clinical_event_id = link_clinicaleventid
detail
	link_encntrid	= ce.encntr_id
	link_personid	= ce.person_id
with nocounter go

execute cov_eks_cdi_query_process link_clinicaleventid go
