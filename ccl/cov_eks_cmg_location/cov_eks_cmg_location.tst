set debug_ind = 1 go
execute cov_std_encntr_routines go

declare trigger_personid = f8 with protect go
declare trigger_encntrid = f8 with protect go
declare trigger_orderid = f8 with protect go

declare link_personid = f8 with protect go
declare link_encntrid = f8 with protect go
declare link_orderid = f8 with protect go

declare FIN = vc with constant("2302921977") go
		
set trigger_encntrid = sGetEncntrID_ByFIN(FIN) go
set trigger_personid = sGetPersonID_ByFIN(FIN) go

set link_personid = trigger_personid go
set link_encntrid = trigger_encntrid go

call echo(build2("trigger_personid=",trigger_personid)) go
call echo(build2("trigger_encntrid=",trigger_encntrid)) go

execute cov_eks_cmg_location go