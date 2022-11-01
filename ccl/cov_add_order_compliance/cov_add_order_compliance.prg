/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		   	10/29/2019
	Solution:			
	Source file name:	 	cov_add_order_compliance.prg
	Object name:		   	cov_add_order_compliance
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	10/29/2019  Chad Cummings
******************************************************************************/

drop program cov_add_order_compliance:dba go
create program cov_add_order_compliance:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))


if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 cnt			= i4
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
	
)

free record 500511request
record 500511request (
  1 encntr_id = f8   
  1 encntr_compliance_status_flag = i2   
  1 performed_dt_tm = dq8   
  1 performed_tz = i4   
  1 performed_prsnl_id = f8   
  1 no_known_home_meds_ind = i2   
  1 unable_to_obtain_ind = i2   
  1 order_list [*]   
    2 order_nbr = f8   
    2 compliance_status_cd = f8   
    2 information_source_cd = f8   
    2 last_occurred_dt_tm = dq8   
    2 last_occurred_tz = i4   
    2 order_compliance_comment = vc  
    2 last_occurred_dt_only_ind = i2   
)

/* Sample
<encntr_id>113915787</encntr_id>
    <encntr_compliance_status_flag>0</encntr_compliance_status_flag>
    <performed_dt_tm>2019-11-06T13:09:52.00</performed_dt_tm>
    <performed_tz>126</performed_tz>
    <performed_prsnl_id>16908168</performed_prsnl_id>
    <no_known_home_meds_ind>1</no_known_home_meds_ind>
    <unable_to_obtain_ind>0</unable_to_obtain_ind>
    
*/

free record 500511reply
record 500511reply (
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
)

set retval 									= -1
set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Setting Values ************************************"))

set 500511request->encntr_id = t_rec->patient.encntr_id
set 500511request->performed_dt_tm = cnvtdatetime(curdate,curtime3)
set 500511request->performed_tz = 126
set 500511request->no_known_home_meds_ind = 1
set 500511request->performed_prsnl_id = 1

call writeLog(build2("* END   Setting Values ************************************"))

call writeLog(build2("* START Documenting Home Meds  ***************************"))

set stat = tdbexecute(600005, 500195, 500511, "REC", 500511request, "REC", 500511reply)

if (500511reply->status_data.status = "Z")
	set t_rec->return_value = "FALSE"
elseif (500511reply->status_data.status = "S")
	set t_rec->return_value = "TRUE"
endif



call writeLog(build2("* END   Documenting Home Meds  ***************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   ************************************"))
call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("************************************************************"))


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

call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
