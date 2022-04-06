set debug_ind = 1 go
execute cov_std_encntr_routines go

declare person_id = f8 with protect go
declare encntr_id = f8 with protect go

declare FIN = vc with constant("2302913670") go
		
set encntr_id = sGetEncntrID_ByFIN(FIN) go
set person_id = sGetPersonID_ByFIN(FIN) go

call echo(build2("encntr_id=",encntr_id)) go
call echo(build2("person_id=",person_id)) go

call echo(sGetAppts_ByPersonID(person_id,365,"future")) go
