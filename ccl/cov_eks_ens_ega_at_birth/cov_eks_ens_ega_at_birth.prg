/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       
  Solution:           
  Source file name:   cov_eks_ens_ega_at_birth.prg
  Object name:        cov_eks_ens_ega_at_birth
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   			  Chad Cummings			initial build
******************************************************************************/
drop program cov_eks_ens_ega_at_birth:dba go
create program cov_eks_ens_ega_at_birth:dba

execute cov_std_eks_routines

call SubroutineLog(build2("starting ",trim(curprog)))

set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	1 result
	 2 ega_at_birth_vc = vc
	 2 ega_at_birth = i2
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
)

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid


if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

; Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = build2("param1:",value(parameter(1,0)))
  set t_rec->result.ega_at_birth_vc = value(parameter(1,0))
  set t_rec->result.ega_at_birth = cnvtint(t_rec->result.ega_at_birth_vc)
endif 

set t_rec->return_value = "FALSE"

update into 
	person_patient
set gest_age_at_birth = t_rec->result.ega_at_birth
where
	person_id = t_rec->patient.person_id
with nocounter
commit


set t_rec->return_value = "TRUE"

#exit_script

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
	set t_rec->log_misc1 = ""
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|",
										trim(cnvtrectojson(t_rec))
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end 
go
