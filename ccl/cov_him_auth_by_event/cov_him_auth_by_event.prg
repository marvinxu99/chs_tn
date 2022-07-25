/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				   Chad Cummings
	Date Written:		   03/01/2019
	Solution:			   
	Source file name:	   cov_him_auth_by_event.prg
	Object name:		   cov_him_auth_by_event
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	03/01/2019  Chad Cummings
******************************************************************************/

drop program cov_him_auth_by_event:dba go
create program cov_him_auth_by_event:dba

prompt 
	"EVENT_ID" = 0 

with EVENT_ID


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

if (program_log->run_from_ops = 1)
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus[1].operationname		= "STARTUP"
	set reply->status_data.subeventstatus[1].operationstatus	= "F"
	set reply->status_data.subeventstatus[1].targetobjectname	= ""
	set reply->status_data.subeventstatus[1].targetobjectvalue	= "Script Started and Ended"
endif

call set_codevalues(null)
call check_ops(null)



free record t_rec
record t_rec
(
	1 cnt = i2
	1 start_dt_tm = dq8
	1 audit_mode = i2
	1 qual[*]
	 2 clinical_event_id  = f8
) 
record EKSOPSRequest (
   1 expert_trigger	= vc
   1 qual[*]
	2 person_id	= f8
	2 sex_cd	= f8
	2 birth_dt_tm	= dq8
	2 encntr_id	= f8
	2 accession_id	= f8
	2 order_id	= f8
	2 data[*]
	     3 vc_var		= vc
	     3 double_var	= f8
	     3 long_var		= i4
	     3 short_var	= i2
)

%i cclsource:eks_rprq3091001.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Documents **********************************"))

select into "nl:"
	facility=uar_get_code_display(e.loc_facility_cd)
	,document=uar_get_code_display(ce.event_cd)
	,ce.event_title_text
	,ce.event_end_dt_tm ";;q"
	,ce.performed_dt_tm ";;q"
	,status = uar_get_code_display(ce.result_status_cd)
	,p1.name_full_formatted
	,position=uar_get_code_display(p1.position_cd)
	,ce.event_id
from
	clinical_event ce
	,encounter e
	,prsnl p1
	,person p
plan ce
	where ce.event_id = $EVENT_ID
join e
	where e.encntr_id = ce.encntr_id
join p1
	where p1.person_id = ce.performed_prsnl_id
join p
	where p.person_id = e.person_id
order by
	ce.clinical_event_id
head report
	cnt = 0
head ce.clinical_event_id
	cnt = cnt +1
	if(mod(cnt,100) = 1)
		stat = alterlist(t_rec->qual, cnt +99)
	endif
	call writeLog(build2("->Adding clinical_event_id=",trim(cnvtstring(ce.clinical_event_id))))
	t_rec->qual[cnt].clinical_event_id = ce.clinical_event_id
foot report
	 stat = alterlist(t_rec->qual, cnt)
	 t_rec->cnt = cnt
	 call writeLog(build2("-->Total to process:",trim(cnvtstring(t_rec->cnt))))
with nocounter

call writeLog(build2("* END   Finding Documents **********************************"))
call writeLog(build2("************************************************************"))

if (t_rec->cnt = 0)
	if (program_log->run_from_ops = 1)
		set reply->status_data.status = "Z"
		set reply->status_data.subeventstatus[1].operationname		= "DOCUMENTS"
		set reply->status_data.subeventstatus[1].operationstatus	= "Z"
		set reply->status_data.subeventstatus[1].targetobjectname	= "CLINICAL_EVENT"
		set reply->status_data.subeventstatus[1].targetobjectvalue	= "No documents qualified for removal"
	endif
	go to exit_script
endif
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Sending Documents to EKS ***************************"))

/*
Use the following commands to create and call the sub-routine that sends
the data in the EKSOPSRequest to the Expert Servers.
*/
 
%i cclsource:eks_run3091001.inc

call writeLog(build2("Starting EKSOPSRequest calls:",trim(cnvtstring(t_rec->cnt))))
for (i = 1 to t_rec->cnt)
	call writeLog(build2("-->Looking at Item:",trim(cnvtstring(i))))
	call writeLog(build2("-->Setting Expert Trigger to HIM_AUTH_DOCUMENTS"))
	set stat = initrec(EKSOPSRequest)
	select into "NL:"
		e.encntr_id,
		e.person_id,
		e.reg_dt_tm,
		p.birth_dt_tm,
		p.sex_cd
	from
		person p,
		encounter e,
		clinical_event ce
	plan ce
		where ce.clinical_event_id = t_rec->qual[i].clinical_event_id
	join e where e.encntr_id = ce.encntr_id
	join p where p.person_id= e.person_id
	head report
		cnt = 0
		EKSOPSRequest->expert_trigger = "HIM_AUTH_DOCUMENTS"
	detail
		cnt = cnt +1
		stat = alterlist(EKSOPSRequest->qual, cnt)
		EKSOPSRequest->qual[cnt].person_id = p.person_id
		EKSOPSRequest->qual[cnt].sex_cd  = p.sex_cd
		EKSOPSRequest->qual[cnt].birth_dt_tm  = p.birth_dt_tm
		EKSOPSRequest->qual[cnt].encntr_id  = e.encntr_id
		stat = alterlist(EKSOPSRequest->qual[cnt].data,1)
		EKSOPSRequest->qual[cnt].data[1].double_var = ce.clinical_event_id
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].person_id=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].person_id))))
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].encntr_id=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].encntr_id))))
		call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].data[1].double_var=",
			trim(cnvtstring(EKSOPSRequest->qual[cnt].data[1].double_var))))
	with nocounter
	set dparam = 0
	if (t_rec->audit_mode != 1)
		call writeLog(build2("------>CALLING srvRequest"))
		call srvRequest(dparam)
		call pause(3)
	else
		call writeLog(build2("------>AUDIT MODE, Not calling srvRequest"))
	endif
endfor

call writeLog(build2("* END   Sending Documents to EKS ***************************"))
call writeLog(build2("************************************************************"))

if (program_log->run_from_ops = 1)
	set reply->status_data.status = "S"
	set reply->status_data.subeventstatus[1].operationname		= "DOCUMENTS"
	set reply->status_data.subeventstatus[1].operationstatus	= "S"
	set reply->status_data.subeventstatus[1].targetobjectname	= "CLINICAL_EVENT"
	set reply->status_data.subeventstatus[1].targetobjectvalue	= "Documents Removed"
endif
	
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

;call writeLog(build2("************************************************************"))
;call writeLog(build2("* START Sending Documents to EKS ***************************"))
;call writeLog(build2("* END   Sending Documents to EKS ***************************"))
;call writeLog(build2("************************************************************"))


#exit_script
call exitScript(null)
call echorecord(EKSOPSRequest)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
