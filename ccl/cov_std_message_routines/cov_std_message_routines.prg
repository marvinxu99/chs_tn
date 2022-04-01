/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_std_message_routines.prg
  Object name:        cov_std_message_routines
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
drop program cov_std_message_routines:dba go
create program cov_std_message_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))

execute cov_std_log_routines
execute cov_std_encntr_routines
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Subroutines */
/**********************************************************************************************************************
** Function SEND_DISCERN_NOTIFICATION(USERNAME,SUBJECT,CONTENT)
** ---------------------------------------------------------------------------------------
** Put HTML content to the supplied output
**********************************************************************************************************************/
declare send_discern_notification(vUsername=vc,vSubject=vc(VALUE,"Error"),vContent=gvc(VALUE,"<html>Error</html>")) 
																									= i2 with persist, copy
subroutine send_discern_notification(vUsername,vSubject,vContent)
	
	declare vReturnStatus = i2 with noconstant(FALSE), protect
	
	free record 3051004Request 
	record 3051004Request (
		1 MsgText = vc
		1 Priority = i4
		1 TypeFlag = i4
		1 Subject = vc
		1 MsgClass = vc
		1 MsgSubClass = vc
		1 Location = vc
		1 UserName = vc
	) 
			
	set 3051004Request->MsgText = vContent 
	set 3051004Request->Priority = 100 
	set 3051004Request->TypeFlag = 0 
	set 3051004Request->Subject = vSubject
	set 3051004Request->MsgClass = "APPLICATION" 
	set 3051004Request->MsgSubClass = "DISCERN" 
	set 3051004Request->Location = "REPLY" 
	set 3051004Request->UserName = vUsername
		 
	set stat = tdbexecute(3030000,3036100,3051004,"REC",3051004Request,"REC",3051004Reply)
	
	if (validate(3051004Reply))
		if (3051004Reply->status_data->status = "S")
			set vReturnStatus = TRUE
		endif
	endif
	
	;call echojson(3051004Request,"3051004Request.json")
	;call echojson(3051004Reply,"3051004Reply.json")
	
	return (vReturnStatus)
end


/**********************************************************************************************************************
** Function ADD_REMINDER(RECEIEVER_ID,SENDER_ID,SUBJECT,CONTENT,DATETIME)
** ---------------------------------------------------------------------------------------
** Adds a reminder in message center for the prsnl/provider 
**********************************************************************************************************************/
declare add_reminder(
						vReceiverID=f8,
						vSenderID=f8,
						vEncntrID=f8,
						vSubject=vc(VALUE,"Error"),
						vContent=gvc(VALUE,"Error"),
						vDateTime=dq8(VALUE,sysdate)) 
		= i2 with persist, copy
		
subroutine add_reminder(vReceiverID,vSenderID,vEncntrID,vSubject,vContent,vDateTime)
	
	call SubroutineLog(build2(
   		'start add_reminder('				 ,vReceiverID
   										,',',vSenderID
   										,',',vEncntrID
   										,',',vSubject
   										,',',vContent
   										,',',vDateTime
   									,')'))
   									
   									
   									
	declare vReturnSuccess = i2 with noconstant(0), protect
	
	free record 967731_reply
	free record 967731_request
	record 967731_request (
	  1 action_pool_id = f8   
	  1 action_personnel_id = f8   
	  1 action_dt_tm = dq8   
	  1 action_tz = i4   
	  1 reminders [*]   
	    2 action  
	      3 send_to_recipient_ind = i2   
	      3 send_to_chart_ind = i2   
	      3 save_to_chart_ind = i2   
	    2 subject = c255  
	    2 text = gvc   
	    2 person_id = f8   
	    2 encounter_id = f8   
	    2 remind_dt_tm = dq8   
	    2 due_dt_tm = dq8   
	    2 event_id = f8   
	    2 event_cd = f8   
	    2 priority_flag = i2   
	    2 notify  
	      3 to_pool_id = f8   
	      3 to_personnel_id = f8   
	      3 priority_flag = i2   
	      3 statuses [*]   
	        4 status_flag = i2   
	        4 delay  
	          5 value = i4   
	          5 unit_flag = i2   
	    2 recipients [*]   
	      3 pool_id = f8   
	      3 personnel_id = f8   
	      3 person_id = f8   
	      3 cc_ind = i2   
	      3 selection_nbr = i4   
	    2 action_requests [*]   
	      3 action_request_cd = f8   
	    2 attachments [*]   
	      3 name = c255  
	      3 location_handle = c255  
	      3 media_identifier = c255  
	      3 media_version = i4   
	    2 original_task_uid = vc  
	    2 result_set_id = f8   
	    2 task_subtype_cd = f8   
	    2 portal_users [*]   
	      3 portal_user_uuid = c128  
	    2 responsible_prsnl_id = f8   
	  1 skip_validation_ind = i2   
	)
	
	set 967731_request->action_personnel_id = vSenderID 
	set 967731_request->action_dt_tm = cnvtdatetime(sysdate) 
	set 967731_request->action_tz = 75 
	
	set stat = alterlist(967731_request->reminders,1) 
	set 967731_request->reminders[1].action.send_to_recipient_ind = 1 
	set 967731_request->reminders[1].subject = "hi jobina" 
	set 967731_request->reminders[1].text = vSubject 
	set 967731_request->reminders[1].person_id = sGetPersonID_ByEncntrID(vEncntrID) 
	set 967731_request->reminders[1].encounter_id= vEncntrID 
	set 967731_request->reminders[1].remind_dt_tm = vDateTime	 
	set 967731_request->reminders[1].priority_flag = 2 
	set stat = alterlist(967731_request->reminders[1].recipients,1) 
	set 967731_request->reminders[1].recipients[1].pool_id = vReceiverID 
	set 967731_request->reminders[1].recipients[1].selection_nbr = 1 

	call SubroutineLog("967731_request","record")
	set stat = tdbexecute(600005,967100,967731,"rec",967731_request,"rec",967731_reply) 
	call SubroutineLog("967731_reply","record")
	
	if (validate(967731_reply))
		if (967731_reply->transaction_status->success_ind = 1)
			set vReturnSuccess = 1
		endif
	endif
	
	call SubroutineLog(build2('end add_reminder=',vReturnSuccess))	
	return (vReturnSuccess)
end 																	

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
