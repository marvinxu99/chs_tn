/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_std_ce_routines.prg
  Object name:        cov_std_ce_routines
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Additional Required Scripts:
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   12/02/2021  Chad Cummings			initial build
******************************************************************************/
drop program cov_std_ce_routines:dba go
create program cov_std_ce_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Subroutines */
/**********************************************************************************************************************
** Function ()
** ---------------------------------------------------------------------------------------
** Return a record structure named  
**********************************************************************************************************************/

declare Add_CEResult(vEncntrID=f8,vEventCD=f8,vResult=vc,vEventDateTime=dq8(VALUE,cnvtdatetime(sysdate))) = f8 with copy, persist
subroutine Add_CEResult(vEncntrID,vEventCD,vResult,vEventDateTime)

	declare vReturnSuccess = f8 with noconstant(FALSE)
 
	if ((vEventCD > 0.0) and (vEncntrID > 0.0) and (vResult > ""))
		free record cerequest
		free record cereply
		
%i cclsource:eks_rprq1000012.inc

		select into "nl:"
		from
			encounter e
		plan e
			where e.encntr_id = vEncntrID
		detail
			cerequest->ensure_type = 2
			cerequest->clin_event.view_level = 1
			cerequest->clin_event.person_id = e.person_id
			cerequest->clin_event.encntr_id = e.encntr_id
			cerequest->clin_event.contributor_system_cd = uar_get_code_by("MEANING",89,"POWERCHART")
			cerequest->clin_event.event_class_cd = uar_get_code_by("MEANING",53,"TXT")
			cerequest->clin_event.event_cd = vEventCD
			cerequest->clin_event.event_tag = vResult
			cerequest->clin_event.event_start_dt_tm = vEventDateTime
			cerequest->clin_event.event_end_dt_tm = vEventDateTime
			cerequest->clin_event.event_end_dt_tm_os_ind = 1
			cerequest->clin_event.record_status_cd = uar_get_code_by("MEANING",48,"ACTIVE")
			cerequest->clin_event.result_status_cd = uar_get_code_by("MEANING",8,"AUTH")
			cerequest->clin_event.authentic_flag_ind = 1
			cerequest->clin_event.publish_flag = 1
			cerequest->clin_event.normalcy_cd = uar_get_code_by_cki("CKI.CODEVALUE!2690")	;Normal
			cerequest->clin_event.subtable_bit_map = 8193
			cerequest->clin_event.expiration_dt_tm_ind = 1
			cerequest->clin_event.valid_from_dt_tm = cnvtdatetime(sysdate)
			cerequest->clin_event.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
			cerequest->clin_event.valid_from_dt_tm_ind = 1
			cerequest->clin_event.valid_until_dt_tm_ind = 1
			cerequest->clin_event.verified_dt_tm_ind = 1
			cerequest->clin_event.performed_dt_tm = cnvtdatetime(sysdate)
			cerequest->clin_event.performed_prsnl_id = 1
			cerequest->clin_event.updt_id = 1
			cerequest->clin_event.updt_dt_tm = cnvtdatetime(sysdate)
			cerequest->ensure_type2 = 1
 
			stat = alterlist(cerequest->clin_event.string_result,1)
			cerequest->clin_event.string_result.string_result_text = vResult
			cerequest->clin_event.string_result.string_result_format_cd = uar_get_code_by("MEANING",14113,"ALPHA")
			cerequest->clin_event.string_result.last_norm_dt_tm_ind = 1
			cerequest->clin_event.string_result.feasible_ind_ind = 1
			cerequest->clin_event.string_result.inaccurate_ind_ind = 1
 
			stat = alterlist(cerequest->clin_event.event_prsnl_list,2)
			cerequest->clin_event.event_prsnl_list[1].person_id = 1.0 ;update this to possibly include a passed in value
			cerequest->clin_event.event_prsnl_list[1].action_type_cd = 112
			cerequest->clin_event.event_prsnl_list[1].request_dt_tm_ind = 1
			cerequest->clin_event.event_prsnl_list[1].action_dt_tm = cnvtdatetime(sysdate)
			cerequest->clin_event.event_prsnl_list[1].action_prsnl_id = 1.0
			cerequest->clin_event.event_prsnl_list[1].action_status_cd = 653
			cerequest->clin_event.event_prsnl_list[1].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
 
			cerequest->clin_event.event_prsnl_list[2].person_id = 1.0 ;update this to possibly include a passed in value
			cerequest->clin_event.event_prsnl_list[2].action_type_cd = 104
			cerequest->clin_event.event_prsnl_list[2].request_dt_tm_ind = 1
			cerequest->clin_event.event_prsnl_list[2].action_dt_tm = cnvtdatetime(curdate,curtime3)
			cerequest->clin_event.event_prsnl_list[2].action_prsnl_id = 1.0
			cerequest->clin_event.event_prsnl_list[2].action_status_cd = 653
			cerequest->clin_event.event_prsnl_list[2].valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
		with nocounter
 
		set stat = tdbexecute(0,3055000,1000012,"REC",CERequest,"REC",CEReply,1)
 
		call echorecord(CERequest)
		call echorecord(CEReply)
		call echo(build2("CEReply->rb_list[1].event_id=",CEReply->rb_list[1].event_id))
		
		if (validate(CEReply->rb_list[1].event_id))
			set vReturnSuccess = CEReply->rb_list[1].event_id
		else
			call echo("CEReply->rb_list[1].event_id not valid")
			set vReturnSuccess = FALSE
		endif
	endif
 
	return (vReturnSuccess)
end 

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
