/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       
  Solution:           
  Source file name:   cov_eks_bld_ingredient_list.prg
  Object name:        cov_eks_bld_ingredient_list
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
drop program cov_eks_bld_ingredient_list:dba go
create program cov_eks_bld_ingredient_list:dba

prompt 
	"Params" = "" 

with PARAMS


execute cov_std_eks_routines
execute cov_std_encntr_routines

call SubroutineLog(build2("starting ",trim(curprog)))

set retval = -1

free record t_rec
record t_rec
(
	1 prompts
	 2 params = vc
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 org_id = f8
	1 var
	 2 pos = i4
	 2 cnt = i4
	 2 str = vc
	 2 not_found = vc
	1 label_cnt = i2
	1 label_qual[*]
	 2 template_label = vc
	 2 msg_label = vc
	 2 template_loc = i2
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
)

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid

set t_rec->prompts.params = $PARAMS

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	;go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	;go to exit_script
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

set t_rec->return_value = "FALSE"

set t_rec->var.pos = 0
set t_rec->var.not_found = "<not found>"

if (piece(t_rec->prompts.params,";",1,t_rec->var.not_found) != t_rec->var.not_found)
	set t_rec->var.pos = 1
	set t_rec->var.str = " "
	while (t_rec->var.str != t_rec->var.not_found)
		set t_rec->var.str = piece(t_rec->prompts.params,';',t_rec->var.pos,t_rec->var.not_found)
		call SubroutineLog(build2("->pos=",t_rec->var.pos))
		call SubroutineLog(build2("->str=",t_rec->var.pos))
		if (t_rec->var.str != t_rec->var.not_found)
			set t_rec->label_cnt += 1
			set stat = alterlist(t_rec->label_qual,t_rec->label_cnt)
			set t_rec->label_qual[t_rec->label_cnt].template_label = t_rec->var.str
			set t_rec->label_qual[t_rec->label_cnt].msg_label = concat("MSG_",trim(t_rec->var.str))
			set t_rec->label_qual[t_rec->label_cnt].template_loc = GetTemplateByAlias(t_rec->var.str)
		endif
		set t_rec->var.pos = t_rec->var.pos+1
	endwhile
endif

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
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end 
go
