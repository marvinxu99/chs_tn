/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_std_log_routines.prg
  Object name:        cov_std_log_routines
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
drop program cov_std_log_routines:dba go
create program cov_std_log_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Global Variables */
declare	cSystemPrsnlID = f8 with noconstant(1.0), protect, persist
 
/* Subroutines */
/**********************************************************************************************************************
** Function START_PROGRAM_LOG()
** ---------------------------------------------------------------------------------------
** Setup the the PROGRAM_LOG record structure and set initial values.  Returns a 0 if program_log is already setup
** and a 1 if the record was created and the inital variables set
**********************************************************************************************************************/
declare start_program_log(null) = i2 with persist, copy
subroutine start_program_log(null)
 
declare vRetSuccess = i2 with noconstant(FALSE)
 
if (not(validate(program_log)))
	record program_log
		(
		 1 produce_log				= i4	;0 to start a log, 1 to not create a log
		 1 produce_audit			= i4	;0 to start a log, 1 to not create a log
		 1 curdomain				= vc	;store the current domain
		 1 curprog					= vc	;current program
		 1 curnode					= vc	;current node the program is running from
		 1 display_on_exit			= i4	;display audit log on exit if 1
		 1 run_from_ops				= i4	;set to 1 if run from ops
		 1 run_from_eks				= i4 	;set to 1 if the script is executed from a rule
		 1 ops_request				= f8	;ops request number
		 1 ops_date					= dq8	;ops date
		 1 email							;list of email addresses
		  2 subject					= vc	;subject of the email
		  2 qual[*]							;array
		   3 email_address  		= vc	;email address to email
		 1 files							;files used in the program
		  2 cclscratch				= vc	;path to domain cclscratch
		  2 ccluserdir				= vc	;path to domain ccluserdir
		  2 filename_log 			= vc	;log filename
		  2 filename_log_full		= vc
		  2 filename_zip			= vc	;zip filename
		  2 filename_audit 			= vc	;audit filename
		  2 filename_audit_zip		= vc	;audit zip filename
		  2 attachments_cnt			= i4	;number of attachments
		  2 attachments[*]
		   3 file_path				= vc	;path to attachments
		   3 filename				= vc    ;file_names
		1 log_cnt					= i4	;log timers 
		1 log_qual[*]
		 2 log_dt_tm				= dq8
		 2 start_dt_tm			 	= dq8
		 2 end_dt_tm				= dq8
		 2 hundseconds_diff			= f8
		 2 log_display				= vc
		1 script_cnt				= i4
		1 script_qual[*]			
		 2 object_name				= vc
		 2 date_time_added			= dq8
	) with persist
 
	set program_log->curdomain				= cnvtlower(trim(curdomain))
	set program_log->curprog				= cnvtlower(trim(curprog))
	set program_log->curnode				= cnvtlower(trim(curnode))
	set program_log->files.cclscratch		= build("/cerner/d_",cnvtlower(trim(curdomain)),"/cclscratch/")
	set program_log->files.ccluserdir		= build("/cerner/d_",cnvtlower(trim(curdomain)),"/ccluserdir/")
	set program_log->files.filename_log 	= build(
												 cnvtlower(trim(curdomain))
												,"_",cnvtlower(trim(curprog))
												,"_",format(cnvtdatetime(sysdate)
												,"yyyy_mm_dd_hh_mm_ss;;d")
												,".log"
											)
	set program_log->files.filename_log_full = build(
														 program_log->files.cclscratch
														,program_log->files.filename_log
													)
	
	set stat = add_script_to_log(curprog)
	
	set vRetSuccess = TRUE
else
	set stat = add_script_to_log(curprog)
endif
	return (vRetSuccess)
end
 

/**********************************************************************************************************************
** Function ADD_SCRIPT_TO_LOG(sOBJECT)
** ---------------------------------------------------------------------------------------
** Add an object to the program_log.  Helpful in auditing when multipple sub programs are called
**********************************************************************************************************************/
declare add_script_to_log(sObject) = i2 with persist, copy
subroutine add_script_to_log(sObject)
	if (validate(program_log))
		set program_log->script_cnt = (program_log->script_cnt + 1)
		set stat = alterlist(program_log->script_qual,program_log->script_cnt)
		set program_log->script_qual[program_log->script_cnt].object_name = sObject
		set program_log->script_qual[program_log->script_cnt].date_time_added = cnvtdatetime(sysdate)
	endif
end

 
/**********************************************************
** Function GET_DMINFO_DATE()                            **
** ----------------------------                          **
** Returns the INFO_DATE for a given DOMAIN/NAME key.    **
** Parameters are for fields INFO_DOMAIN & INFO_NAME.    **
**********************************************************/
declare    get_dminfo_date(sdomain, sname) = dq8 with persist, copy
subroutine get_dminfo_date(sdomain, sname)
  declare dtatgdminfovalue 	= dq8 with protect
 
  select into "nl"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  detail
    dtatgdminfovalue = cnvtdatetime(di.info_date)
  with nocounter
 
  return (dtatgdminfovalue)
end

/**********************************************************
** SET ROUTINE SET_DMINFO_DATE()                         **
** ----------------------------                          **
** SETs the INFO_DATE for a given DOMAIN/NAME key.       **
** Parameters are for fields INFO_DOMAIN & INFO_NAME     **
** And Value.  This routine will call the GOLD MASTER.   **
**********************************************************/
declare set_dminfo_date(sdomain=vc, sname=vc, dtvalue=dq8) = null with persist, copy
subroutine set_dminfo_date(sdomain, sname, dtvalue)
 
  call clear_dminfo(null)
 
  select into "nl:"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  with nocounter
 
 
  if (curqual = 0)
    set stat = alterlist(atg_dminfo_reqi->qual, 1)
    set atg_dminfo_reqi->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqi->qual[1]->info_name   	= sname
    set atg_dminfo_reqi->qual[1]->info_date 	= cnvtdatetime(dtvalue)
    set atg_dminfo_reqi->info_domaini		= 1
    set atg_dminfo_reqi->info_namei 		= 1
    set atg_dminfo_reqi->info_datei		= 1
    execute gm_i_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQI"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  else
    set stat = alterlist(atg_dminfo_reqw->qual, 1)
    set atg_dminfo_reqw->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqw->qual[1]->info_name   	= sname
    set atg_dminfo_reqw->qual[1]->info_date 	= cnvtdatetime(dtvalue)
    set atg_dminfo_reqw->info_domainw		= 1
    set atg_dminfo_reqw->info_namew 		= 1
    set atg_dminfo_reqw->info_datef		= 1
    set atg_dminfo_reqw->force_updt_ind		= 1
    execute gm_u_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQW"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  endif
 
  if (reqinfo->commit_ind = 1)
    commit
  endif
end


/**********************************************************
** CLEAR Routine CLEAR_DMINFO()                        **
** ----------------------------                          **
** This is a PRIVATE ROUTINE and should NOT be called   **
** directly by your program. It is only to be called by **
** the functions above.                                 **
**********************************************************/
declare clear_dminfo(null) = null with persist, copy
subroutine clear_dminfo(null)

	/*********************************************
	** Request Structure For GOLD MASTER INSERT **
	*********************************************/
	record atg_dminfo_reqi
	(
	    1 allow_partial_ind = i2
	    1 info_domaini = i2
	    1 info_namei = i2
	    1 info_datei = i2
	    1 info_daten = i2
	    1 info_chari = i2
	    1 info_charn = i2
	    1 info_numberi = i2
	    1 info_numbern = i2
	    1 info_long_idi = i2
	    1 qual[*]
	      2 info_domain = c80
	      2 info_name = c255
	      2 info_date = dq8
	      2 info_char = c255
	      2 info_number = f8
	      2 info_long_id = f8
	) with protect, persistscript
	 
	/*********************************************
	** Request Structure For GOLD MASTER UPDATE **
	*********************************************/
	record atg_dminfo_reqw
	(
	    1 allow_partial_ind = i2
	    1 force_updt_ind = i2
	    ;where_clause indicator fields
	    1 info_domainw = i2
	    1 info_namew = i2
	    1 info_datew = i2
	    1 info_charw = i2
	    1 info_numberw = i2
	    1 info_long_idw = i2
	    1 updt_applctxw = i2
	    1 updt_dt_tmw = i2
	    1 updt_cntw = i2
	    1 updt_idw = i2
	    1 updt_taskw = i2
	    1 info_domainf = i2
	    1 info_namef = i2
	    1 info_datef = i2
	    1 info_charf = i2
	    1 info_numberf = i2
	    1 info_long_idf = i2
	    1 updt_cntf = i2
	    1 qual[*]
	      2 info_domain = c80
	      2 info_name = c255
	      2 info_date = dq8
	      2 info_char = c255
	      2 info_number = f8
	      2 info_long_id = f8
	      2 updt_applctx = i4
	      2 updt_dt_tm = dq8
	      2 updt_cnt = i4
	      2 updt_id = f8
	      2 updt_task = i4
	) with protect, persistscript
	 
	/*********************************************
	** Request Structure For GOLD MASTER DELETE **
	*********************************************/
	record atg_dminfo_reqd
	(
	 1 allow_partial_ind = i2
	 ;where_clause indicator fields
	 1 info_domainw = i2
	 1 info_namew = i2
	 1 qual[*]
	   2 info_domain = c80
	   2 info_name = c255
	) with protect, persistscript
	 
	 
	/*********************************************
	** Reply Structure For GOLD MASTER SCRIPTS  **
	*********************************************/
	record atg_dminfo_rep
	(
	   1 curqual = i4
	   1 qual[*]
	     2 status = i2
	     2 error_num = i4
	     2 error_msg = vc
	    2 info_domain = c80
	    2 info_name = c255
%i cclsource:status_block.inc
	) with protect, persistscript
	
	  if (currev = 8)
	    ;initrec only exists in rev 8.x
	    set stat = initrec(atg_dminfo_reqi)
	    set stat = initrec(atg_dminfo_reqw)
	    set stat = initrec(atg_dminfo_reqd)
	  else
	    ;insert
	    set stat = alterlist(atg_dminfo_reqi->qual, 0)
	    set atg_dminfo_reqi->allow_partial_ind 	= 0
	    set atg_dminfo_reqi->info_domaini 		= 0
	    set atg_dminfo_reqi->info_namei 		= 0
	    set atg_dminfo_reqi->info_datei 		= 0
	    set atg_dminfo_reqi->info_daten 		= 0
	    set atg_dminfo_reqi->info_chari 		= 0
	    set atg_dminfo_reqi->info_charn 		= 0
	    set atg_dminfo_reqi->info_numberi 		= 0
	    set atg_dminfo_reqi->info_numbern 		= 0
	    set atg_dminfo_reqi->info_long_idi 		= 0
	 
	    ;update
	    set stat = alterlist(atg_dminfo_reqw->qual, 0)
	    set atg_dminfo_reqw->allow_partial_ind 	= 0
	    set atg_dminfo_reqw->force_updt_ind 	= 0
	    set atg_dminfo_reqw->info_domainw 		= 0
	    set atg_dminfo_reqw->info_namew 		= 0
	    set atg_dminfo_reqw->info_datew 		= 0
	    set atg_dminfo_reqw->info_charw 		= 0
	    set atg_dminfo_reqw->info_numberw 		= 0
	    set atg_dminfo_reqw->info_long_idw 		= 0
	    set atg_dminfo_reqw->updt_applctxw 		= 0
	    set atg_dminfo_reqw->updt_dt_tmw 		= 0
	    set atg_dminfo_reqw->updt_cntw 		= 0
	    set atg_dminfo_reqw->updt_idw 		= 0
	    set atg_dminfo_reqw->updt_taskw 		= 0
	    set atg_dminfo_reqw->info_domainf 		= 0
	    set atg_dminfo_reqw->info_namef 		= 0
	    set atg_dminfo_reqw->info_datef 		= 0
	    set atg_dminfo_reqw->info_charf 		= 0
	    set atg_dminfo_reqw->info_numberf 		= 0
	    set atg_dminfo_reqw->info_long_idf 		= 0
	    set atg_dminfo_reqw->updt_cntf 		= 0
	 
	    ;delete
	    set stat = alterlist(atg_dminfo_reqd->qual, 0)
	    set atg_dminfo_reqd->allow_partial_ind 	= 0
	    set atg_dminfo_reqd->info_domainw 		= 0
	    set atg_dminfo_reqd->info_namew 		= 0
	 
	  endif
end

;==========================================================================================
; Capture and report logging for debug and testing
; pMessage = Message to log
; pParam = if set to 'record' then the pMessage is a record structure to be echorecord
; 
; USAGE: call SubroutineLog("record_structure","RECORD") 
;        call SubroutineLog("Log Message") 
;==========================================================================================
declare SubroutineLog(pMessage=vc,pParam=vc(value,'message')) = null with copy, persist
subroutine SubroutineLog(pMessage,pParam)
    declare vMessage = vc with constant(pMessage), protect
    declare vParam = vc with constant(pParam), protect
    declare vEchoParser = vc with noconstant(" "), protect

    if (SubroutineDebug(0)) ;check to make sure debug is on first
        if (cnvtupper(vParam) = cnvtupper('RECORD')) ;check to see if the message is actually a record structure
            set vEchoParser = concat(^call echorecord(^,trim(vMessage),^) go^)
            call echo(trim(vEchoParser))
            call parser(vEchoParser)
        else
            call echo(trim(vMessage))
        endif
    endif
end ;SubroutineLog 

;==========================================================================================
; Check if the debug_ind variable is defined and set to 1 to turn on echos
; 
; USAGE: set DEBUG = SubroutineDebug(null)
;==========================================================================================
declare SubroutineDebug(null) = i2 with copy, persist
subroutine SubroutineDebug(null)
    declare pDebugVar = f8 with noconstant(FALSE), protect

    if (validate(debug_ind))
        if (debug_ind > 0)
            set pDebugVar = TRUE
        endif
    endif
    return (pDebugVar)
end ;SubroutineDebug



/**********************************************************************************************************************
** Function sGetUsername(person_id)
** ---------------------------------------------------------------------------------------
** Returns the username associated to the person_id supplied
**********************************************************************************************************************/
declare sGetUsername(vPersonID=f8) = vc  with copy, persist
subroutine sGetUsername(vPersonID)

	declare vReturnUsername = vc with protect
	
	select into "nl:"
	from
		prsnl p
	plan p
		where p.person_id = vPersonID
	detail
		vReturnUsername = p.username
	with nocounter
	
	return (vReturnUsername)
end




/**********************************************************************************************************************
** Function add_eks_log_message(message)
** ---------------------------------------------------------------------------------------
** sets up and/or adds log message for use in EKS
**********************************************************************************************************************/

declare add_eks_log_message(vMessage = vc) = null with copy, persist
subroutine add_eks_log_message(vMessage)

	if (not(validate(eks_log)))
		
		record eks_log	(
			1 log_message = vc
		) with persistscript
		
	endif
	set eks_log->log_message = concat(
										trim(eks_log->log_message),";",
										trim(vMessage)
									)
end ;add_log_message

/**********************************************************************************************************************
** Function sGet_PromptValues(null)
** ---------------------------------------------------------------------------------------
** 
**********************************************************************************************************************/

declare sGet_PromptValues(pPromptNum = i2) = vc with copy, persist
subroutine sGet_PromptValues(pPromptNum)
	
	declare par = c20 with private
	declare lnum = i2 with private
	declare cnt2 = i2 with private

	free record prompt_values
	record prompt_values
	(
		1 prompt_num = i2
		1 value_cnt = i2
		1 value_qual[*]
		 2 value_f8 = f8
		 2 value_i4 = i2
		 2 value_vc = vc
	)
	
	/*
	$(4)L3
	$(4.1)F8=20265987.000000
	$(4.2)I4=20265575
	$(4.3)C4=test
	*/
	set prompt_values->prompt_num = pPromptNum
	set par = reflect(parameter(pPromptNum,0))
	
	if (substring(1,1,par) = "L") ;this is list type
		call SubroutineLog(build("$(",pPromptNum,")",par))
		set lnum = 1
		while (lnum>0)
			set par = reflect(parameter(pPromptNum,lnum))
				if (par = " ")
					;no more items in list for parameter
					set cnt2 = lnum-1
					set lnum = 0
				else
					;valid item in list for parameter
					call SubroutineLog(build("$(",pPromptNum,".",lnum,")",par,"=",parameter(pPromptNum,lnum)))
					
					set prompt_values->value_cnt += 1
					set stat = alterlist(prompt_values->value_qual,prompt_values->value_cnt)
					if (substring(1,1,par) = "F")
						set prompt_values->value_qual[prompt_values->value_cnt].value_f8 = parameter(pPromptNum,lnum)
					elseif (substring(1,1,par) = "I")
						set prompt_values->value_qual[prompt_values->value_cnt].value_i4 = parameter(pPromptNum,lnum)
					elseif (substring(1,1,par) = "C")
						set prompt_values->value_qual[prompt_values->value_cnt].value_vc = parameter(pPromptNum,lnum)
					endif
					set lnum = lnum+1
				endif
		endwhile
	else
		call SubroutineLog(build("$(",pPromptNum,")",par,"=",parameter(pPromptNum,lnum)))
		set par = reflect(parameter(pPromptNum,lnum))
		set prompt_values->value_cnt += 1
		set stat = alterlist(prompt_values->value_qual,prompt_values->value_cnt)
		if (substring(1,1,par) = "F")
			set prompt_values->value_qual[prompt_values->value_cnt].value_f8 = parameter(pPromptNum,lnum)
		elseif (substring(1,1,par) = "I")
			set prompt_values->value_qual[prompt_values->value_cnt].value_i4 = parameter(pPromptNum,lnum)
		elseif (substring(1,1,par) = "C")
			set prompt_values->value_qual[prompt_values->value_cnt].value_vc = parameter(pPromptNum,lnum)
		endif
	endif
	
	call SubroutineLog("prompt_values","RECORD")
	
	return(cnvtrectojson(prompt_values))
	
end ;add_log_message

/**********************************************************************************************************************
** Function sSet_ErrorReply(vMessage)
** ---------------------------------------------------------------------------------------
** 
**********************************************************************************************************************/

declare sSet_ErrorReply(vMessage = vc) = i2 with copy, persist
subroutine sSet_ErrorReply(vMessage)

	if (validate(reply->status_data))
		set reply->status_data = "F"
	endif
	
	if (validate(reply->text))
		set reply->text = vMessage
	endif
	
	return (TRUE)

end	;sSet_ErrorReply

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
