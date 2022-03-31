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

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
