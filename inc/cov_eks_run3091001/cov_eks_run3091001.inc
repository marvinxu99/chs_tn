 
;*******************************************************************************
;* CRM Request calls for eks_run3091001.inc
;*
;* The file was created by CERKYH.
;* RECORD DEFINITION FILE      : eks_rprq3091001.inc
;*-----------------------------------------------------------------------------
;* DESCRIPTION:
;* Include this file at the end of your source program.
;* Then in your ccl source code call SrvRequest.
;*
;* Subroutines defined by this include file are:
;*		SrvRequest(dummy)
;*      	SrvRequest executes a dummy script, so there is no reason
;*			to check the reply coming back.
;*
;* Variables declared locally:
;*		req             Request no.
;*		hApp            Handle to application context
;*		hReply          Handle to reply context
;*		hTask           Handle to task context
;*		CrmStatus       Last CRM error code, passed to SrvError as crmErrNo
;*
;*  001  04/16/03  cerkyh  Changes to clean up CRM handles when necessary.
;*
;******************************************************************************
 
 
subroutine SrvRequest(dparam)
 
	if ( (Validate(recdate, "Y")="Y") and (Validate(recdate, "N")="N"))
		record recdate (
			1 datetime 	= dq8
		)
	endif
 
	declare	req = i4
	declare	hApp = i4
	declare	hTask = i4
	declare	hReq = i4
	declare	hReply = i4
	declare	CrmStatus = i4
	set eCrmOk = 0
	set NULL = 0
 
 
	set req = 3091001
	set hApp = 0
	set app = 3055000
	set task = 4801
 
	set endApp = 0     ;001
	set endTask = 0    ;001
	set endReq = 0     ;001
 
	call echo(concat("curenv = ",build(curenv)))
 
	if (curenv = 0)   ; if interactive, use Expert Server as the Application.
	   execute srvrtl
	   execute crmrtl
	   execute cclseclogin
 	   set crmStatus = uar_crmbeginapp( app, hApp )
       call echo(concat("beginapp status = ",build(crmstatus)))
       if (hApp)          ;001
       	  set endApp = 1  ;001
       endif              ;001
    else  ;  If not interactive CCL, get current App handle
	   set hApp = uar_crmgetapphandle()
	endif
 
	if (hApp > 0)
		set crmStatus = uar_crmbegintask( hApp, task, hTask )
    	if (crmStatus != eCrmOk)
       		call echo("Invalid CrmBeginTask return status")
       		set retval = -1
       	else
 
;----------------------------------------
; Begin EKSOPSREQUEST REQUEST
;----------------------------------------
 
		 	set endTask = 1    ;001
		    set crmStatus = uar_CrmBeginReq(hTask, 0, req, hReq)
		    if (crmStatus != eCrmOk)
		       set retval = -1
		       call echo(concat("Invalid CrmBeginReq return status of ", build(crmStatus)))
		    elseif (hReq = NULL)
		    	set retval = -1
		        call echo("Invalid hReq handle")
		    else
		    	 set endReq = 1    ;001
		    	 set request_handle = hReq
 
		         set hEKSOPSRequest = uar_CrmGetRequest(hReq)
		         if (hEKSOPSRequest = NULL)
		            set retval = -1
		            call echo("Invalid request handle return from CrmGetRequest")
		         else
 
		        	set stat =  uar_SrvSetString(hEKSOPSRequest,
		                      "EXPERT_TRIGGER",
		                      NullTerm(EKSOPSRequest->EXPERT_TRIGGER))
 
 
;----------------------------------------
; Begin QUAL
;----------------------------------------
		            for (ndx1= 1 to Size(EKSOPSRequest->QUAL, 5))
 
		               set hQUAL = uar_SrvAddItem(hEKSOPSRequest, "QUAL")
		               if (hQUAL = NULL) call echo("QUAL", "Invalid handle")
		               else
 
		                    set stat =  uar_SrvSetDouble(hQUAL,
		                              "PERSON_ID",
		                              EKSOPSRequest->QUAL[ndx1]
		                                            .PERSON_ID)
		            		set stat =  uar_SrvSetDouble(hQUAL,
		                              "SEX_CD",
		                              EKSOPSRequest->QUAL[ndx1]
		                                            .SEX_CD)
 
							set recdate->datetime = EKSOPSRequest->QUAL[ndx1].birth_dt_tm
		         			set stat =  uar_SrvSetDate2(hQUAL,
		                      			"BIRTH_DT_TM",
		                      			recdate)
 
		                   	set stat =  uar_SrvSetDouble(hQUAL,
		                              "ENCNTR_ID",
		                              EKSOPSRequest->QUAL[ndx1]
		                                            .ENCNTR_ID)
 
		                   	set stat =  uar_SrvSetDouble(hQUAL,
		                              "ACCESSION_ID",
		                              EKSOPSRequest->QUAL[ndx1]
		                                            .ACCESSION_ID)
 
		                   	set stat =  uar_SrvSetDouble(hQUAL,
		                              "ORDER_ID",
		                              EKSOPSRequest->QUAL[ndx1]
		                                            .ORDER_ID)
 
		                    for (ndx2= 1 to Size(EKSOPSRequest->QUAL[ndx1]->DATA, 5))
 
		               			set hDATA = uar_SrvAddItem(hQUAL, "DATA")
		               			if (hDATA = NULL) call echo("DATA", "Invalid handle")
		               			else
 
		                    		set stat =  uar_SrvSetString(hDATA,
		                    					"VC_VAR",
		                    					NullTerm(EKSOPSRequest->QUAL[ndx1]->DATA[ndx2]
		                    										.VC_VAR))
 
		                   			set stat =  uar_SrvSetDouble(hDATA,
		                              			"DOUBLE_VAR",
		                              			EKSOPSRequest->QUAL[ndx1]->DATA[ndx2]
		                                            		.DOUBLE_VAR)
 
		                   			set stat =  uar_SrvSetLong(hDATA,
		                              			"LONG_VAR",
		                              			EKSOPSRequest->QUAL[ndx1]->DATA[ndx2]
		                                            		.LONG_VAR)
 
		                   			set stat =  uar_SrvSetShort(hDATA,
		                              			"SHORT_VAR",
		                              			EKSOPSRequest->QUAL[ndx1]->DATA[ndx2]
		                                            		.SHORT_VAR)
		                        endif  /* hDATA */
							endfor /* hDATA */
							set retval = 100
		               endif /* hQUAL */
		            endfor /* hQUAL */
				endif /*hEKSOPSRequest*/
			endif  /*BeginReq*/
         endif   /*BeginTask*/
    endif /* hApp */
    if (crmStatus = eCrmOk)
       call Echo(ConCat("**** Begin perform request #", CnvtString(req),
            " -EKS Event @",
           format(CurDate, "dd-mmm-yyyy;;d"), " ",
           format(CurTime3, "hh:mm:ss.cc;3;m")))
       set crmStatus = uar_CrmPerform(hReq)
       call Echo(ConCat("**** End perform request #", CnvtString(req),
           " -EKS Event @",
           format(CurDate, "dd-mmm-yyyy;;d"), " ",
           format(CurTime3, "hh:mm:ss.cc;3;m")))
       if (crmStatus != eCrmOk)
          set retval = -1
          call echo("Invalid CrmPerform return status")
	   else
	      set retval = 100
	   	  call echo("CrmPerform was successful")
       endif
    else
       set retval = -1
       call Echo("CrmPerform not executed do to begin request error")
    endif
;001 Clean up CRM if necessary
	if (endReq)    ;001
	    call Echo("Ending CRM Request") ;001
	    call uar_CrmEndReq(hReq)        ;001
	endif          ;001
 
	if (endTask)   ;001
	    call Echo("Ending CRM Task")    ;001
	    call uar_CrmEndTask(hTask)       ;001
	endif          ;001
 
	if (endApp)   ;001
	    call Echo("Ending CRM App")    ;001
	    call uar_CrmEndApp(hApp)       ;001
	endif          ;001
 
end /* SrvRequest() */
