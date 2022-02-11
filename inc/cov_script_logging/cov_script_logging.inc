/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		06/01/2020
	Solution:			
	Source file name:	cov_pcs_add_covid_aoe.prg
	Object name:		cov_pcs_add_covid_aoe
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	06/01/2020	  Chad Cummings
******************************************************************************/
 
;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************
;moved outside of validate block so the correct program name is displayed when
;a script calls another script that is also using this file
declare log_program_name  = vc with protect, noconstant(CURPROG)
if (validate(GLBSL_DEF, 999) = 999)
  ;call echo("Declaring GLBSL_DEF")
  declare GLBSL_DEF = i2 with protect, constant(1)
 
/***********************************************************************
 *   Parameter Variables                                               *
 ***********************************************************************/
  declare log_override_ind  = i2 with protect, noconstant(0)
 
/***********************************************************************
 *   Initialize Parameters                                             *
 ***********************************************************************/
  set log_override_ind = 0
 
/***********************************************************************
 *   Initialize Constants                                              *
 ***********************************************************************/
  declare LOG_LEVEL_ERROR   = i2 with protect, noconstant(0)
  declare LOG_LEVEL_WARNING = i2 with protect, noconstant(1)
  declare LOG_LEVEL_AUDIT   = i2 with protect, noconstant(2)
  declare LOG_LEVEL_INFO    = i2 with protect, noconstant(3)
  declare LOG_LEVEL_DEBUG   = i2 with protect, noconstant(4)
 
/***********************************************************************
 *   Initialize Logging and Error() Function                           *
 ***********************************************************************/
  declare hSys     = i4 with protect, noconstant(0)
  declare SysStat  = i4 with protect, noconstant(0)
  declare sErrMsg  = c132 with protect, noconstant(" ")
  declare iErrCode = i4 with protect, noconstant(Error(sErrMsg, 1))
 
  declare GLBSL_MSG_DEFAULT = i4 with protect, noconstant(0)
  declare GLBSL_MSG_LEVEL   = i4 with protect, noconstant(0)
 
  execute msgrtl
  set GLBSL_MSG_DEFAULT = uar_MsgDefHandle ()
  set GLBSL_MSG_LEVEL   = uar_MsgGetLevel (GLBSL_MSG_DEFAULT)
 
/************************************************************************
 *   Initialize other variables.  These were moved here since a declare *
 *   statement cannot be used within a subroutine called from within    *
 *   detail clauses (as these subroutines are).                         *
 ***********************************************************************/
  declare lGLBSLSubEventCnt       = i4 with protect, noconstant(0)
  declare iGLBSLLoggingStat       = i2 with protect, noconstant(0)
  declare lGLBSLSubEventSize      = i4 with protect, noconstant(0)
  declare iGLBSLLogLvlOverrideInd = i2 with protect, noconstant(0)
  declare sGLBSLLogText           = vc with protect, noconstant("")
  declare sGLBSLLogEvent          = vc with protect, noconstant("")
  declare iGLBSLHoldLogLevel      = i2 with protect, noconstant(0)
  declare iGLBSLErrorOccured      = i2 with protect, noconstant(0)
  declare lGLBSLUarMsgwriteStat   = i4 with protect, noconstant(0)
 
/***********************************************************************
 *   Read the DM_INFO table for the program name.  This will eliminate *
 *   the need for scripts to read for a DM_INFO row to turn on script  *
 *   logging override.                                                 *
 *   Simply setup the DM_INFO row as follows to turn on logging:       *
 *     INFO_DOMAIN = "PATHNET SCRIPT LOGGING"                          *
 *     INFO_NAME   = ccl program name in all uppercase                 *
 *     INFO_CHAR   = "L"                                               *
 ***********************************************************************/
  declare GLBSL_INFO_DOMAIN    = vc with protect, constant("PATHNET SCRIPT LOGGING")
  declare GLBSL_LOGGING_ON     = c1 with protect, constant("L")
 
endif
 
  select into "nl:"
  from
    dm_info dm
  plan dm
    where dm.info_domain = GLBSL_INFO_DOMAIN
      and dm.info_name   = CURPROG
  detail
    if (dm.info_char = GLBSL_LOGGING_ON)
      log_override_ind = 1
    endif
  with nocounter
 
DECLARE LOG_MESSAGE(LogMsg=VC,LogLvl=I4) = NULL
/***********************************************************************
 *   LOG_MESSAGE routine is called to write out a log message to       *
 *   msgview.  The log message and message level should be passed in   *
 *   the corresponding parameters.  The routine will use the string    *
 *   stored in log_program_name as the script.  It will also override  *
 *   the log level passed in if the log_override_ind is set to 1.      *
 ***********************************************************************/
subroutine LOG_MESSAGE(LogMsg, LogLvl)
 
  ; Initialize override flag
  set iGLBSLLogLvlOverrideInd = 0
 
  ; Build log message in form "{{Script::ScriptName}} Log Message"
  set sGLBSLLogText = ""
  set sGLBSLLogEvent = ""
  set sGLBSLLogText = CONCAT("{{Script::", VALUE(log_program_name), "}} ", LogMsg)
  ;call echo(build2("log_override_ind=",log_override_ind))
  ; Determine the appropriate log level at which to write message
  if (log_override_ind = 0)
    set iGLBSLHoldLogLevel = LogLvl               ; write using passed in log level
  else
    if (GLBSL_MSG_LEVEL < LogLvl)
      set iGLBSLHoldLogLevel = GLBSL_MSG_LEVEL  ; write using server log level (override)
      set iGLBSLLogLvlOverrideInd = 1
    else
      set iGLBSLHoldLogLevel = LogLvl             ; write using passed in log level
    endif
  endif
 
  ; Write log message using appropriate log level
  if (iGLBSLLogLvlOverrideInd = 1)
    set sGLBSLLogEvent = "ScriptOverride"
  else
    case (iGLBSLHoldLogLevel)
      of LOG_LEVEL_ERROR:
         set sGLBSLLogEvent = "ScriptError"
      of LOG_LEVEL_WARNING:
         set sGLBSLLogEvent = "ScriptWarning"
      of LOG_LEVEL_AUDIT:
         set sGLBSLLogEvent = "ScriptAudit"
      of LOG_LEVEL_INFO:
         set sGLBSLLogEvent = "ScriptInfo"
      of LOG_LEVEL_DEBUG:
         set sGLBSLLogEvent = "ScriptDebug"
    endcase
  endif
	;call echo(build2("GLBSL_MSG_DEFAULTv=",GLBSL_MSG_DEFAULT))
	call echo(LogMsg)
  set lGLBSLUarMsgwriteStat =
  	uar_MsgWrite(GLBSL_MSG_DEFAULT, 0, nullterm(sGLBSLLogEvent), iGLBSLHoldLogLevel, nullterm(sGLBSLLogText))
	;uar_MsgWrite(GLBSL_MSG_DEFAULT, 0, nullterm(sGLBSLLogEvent), 0, nullterm(sGLBSLLogText))
end ; LOG_MESSAGE subroutine
 
/***************/
 
DECLARE ERROR_MESSAGE(LogStatusBlockInd = i2) = i2
/***********************************************************************
 *   The ERROR_MESSAGE routine is called to check for CCL errors after *
 *   a CCL select statement.  If errors are found, this routine will   *
 *   write the error to msgview and the subeventstatus block in the    *
 *   reply record.                                                     *
 ***********************************************************************/
subroutine ERROR_MESSAGE(LogStatusBlockInd)
 
  set iGLBSLErrorOccured = 0
 
  ; Check for CCL error
  set iErrCode = Error(sErrMsg, 0)
  while (iErrCode > 0)
    set iGLBSLErrorOccured = 1
 
    ; Write CCL error message to msgview
    call log_message(sErrMsg, log_level_audit)
 
    ; Write CCL errors to subeventstatus block if it exists
    if (LogStatusBlockInd = 1)
      ; write error to subeventstatus
      call populate_subeventstatus("EXECUTE", "F", "CCL SCRIPT", sErrMsg)
    endif
 
    ; Retrieve additional CCL errors
    set iErrCode = Error(sErrMsg, 0)
  endwhile
 
  return(iGLBSLErrorOccured)
 
end ; ERROR_MESSAGE subroutine
 
 /***************/
 
declare POPULATE_SUBEVENTSTATUS(OperationName = vc (value),
                                OperationStatus = vc (value),
                                TargetObjectName = vc (value),
                                TargetObjectValue = vc (value)) = i2
/***********************************************************************
*   The POPULATE_SUBEVENTSTATUS routine is called to fill out an entry *
*   in the subeventstatus list of a standard reply.                    *
************************************************************************/
subroutine POPULATE_SUBEVENTSTATUS(OperationName, OperationStatus, TargetObjectName, TargetObjectValue)
 
  /* Validate that status block exists */
  if (validate(reply->status_data->status, "-1") != "-1")
    /* get current size of subevent status */
    set lGLBSLSubEventCnt = size(reply->status_data->subeventstatus, 5)
 
    if (lGLBSLSubEventCnt > 0)
      /* If last item in array is populated, then increase the size of the array by one.
         Otherwise, assume it is an empty item in the list and use it. */
      set lGLBSLSubEventSize = size(trim(reply->status_data->subeventstatus[lGLBSLSubEventCnt].OperationName))
      set lGLBSLSubEventSize = lGLBSLSubEventSize +
        size(trim(reply->status_data->subeventstatus[lGLBSLSubEventCnt].OperationStatus))
      set lGLBSLSubEventSize = lGLBSLSubEventSize +
        size(trim(reply->status_data->subeventstatus[lGLBSLSubEventCnt].TargetObjectName))
      set lGLBSLSubEventSize = lGLBSLSubEventSize +
        size(trim(reply->status_data->subeventstatus[lGLBSLSubEventCnt].TargetObjectValue))
    else
      set lGLBSLSubEventSize = 1
    endif
 
    if (lGLBSLSubEventSize > 0)
      set lGLBSLSubEventCnt = lGLBSLSubEventCnt + 1
/*
 * Use preprocessor defines to flex between alter and alterlist since otherwise we have problems with scripts which
 * call POPULATE_SUBEVENTSTATUS from within detail sections.
 */
%#IFNDEF SUBEVENT_ALTERLIST
      set iGLBSLLoggingStat = alter(reply->status_data->subeventstatus, lGLBSLSubEventCnt)
%#ELSE
      set iGLBSLLoggingStat = alterlist(reply->status_data->subeventstatus, lGLBSLSubEventCnt)
%#ENDIF
    endif
 
    set reply->status_data.subeventstatus[lGLBSLSubEventCnt].OperationName =
      substring(1, 25, OperationName)
    set reply->status_data.subeventstatus[lGLBSLSubEventCnt].OperationStatus =
      substring(1, 1, OperationStatus)
    set reply->status_data.subeventstatus[lGLBSLSubEventCnt].TargetObjectName =
      substring(1, 25, TargetObjectName)
    set reply->status_data.subeventstatus[lGLBSLSubEventCnt].TargetObjectValue =
      TargetObjectValue
  endif
 
end ; POPULATE_SUBEVENTSTATUS subroutine
 
/***************/
 
declare POPULATE_SUBEVENTSTATUS_MSG(OperationName = vc (value),
                                    OperationStatus = vc (value),
                                    TargetObjectName = vc (value),
                                    TargetObjectValue = vc (value),
                                    LogLevel = i2 (value)) = i2
/***************************************************************************
*   The POPULATE_SUBEVENTSTATUS_MSG routine is called to fill out an entry *
*   in the subeventstatus list of a standard reply and to write the        *
*   TargetObjectValue argument to the message log                          *
****************************************************************************/
subroutine POPULATE_SUBEVENTSTATUS_MSG(OperationName, OperationStatus, TargetObjectName, TargetObjectValue, LogLevel)
 
  call populate_subeventstatus(OperationName, OperationStatus, TargetObjectName, TargetObjectValue)
  call log_message(TargetObjectValue, LogLevel)
 
end ; POPULATE_SUBEVENTSTATUS_MSG subroutine
 
/***************/
 
DECLARE CHECK_LOG_LEVEL( arg_log_level = i4 ) = i2
/****************************************************************************
*   The CHECK_LOG_LEVEL routine determines if message will be written at a  *
*   given level.                                                            *
****************************************************************************/
subroutine CHECK_LOG_LEVEL(arg_log_level)
  if( GLBSL_MSG_LEVEL  >= arg_log_level
   or log_override_ind = 1)
    return (1)  ;The log_level is sufficient to log messages or override is turned on
  else
    return (0)  ;The log_level is not sufficient to log messages
  endif
 
end ; CHECK_LOG_LEVEL subroutine
 
 
 