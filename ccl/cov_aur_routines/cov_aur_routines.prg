/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_aur_routines.prg
  Object name:        cov_aur_routines
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
drop program cov_aur_routines:dba go
create program cov_aur_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))

execute cov_std_log_routines
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Subroutines */
/**********************************************************************************************************************
** Function ()
** ---------------------------------------------------------------------------------------
** Return a record structure named  
**********************************************************************************************************************/

declare BuildParams  (null) = i2 with copy, persist
subroutine BuildParams(null)
	call echo("temp")
end


declare OpenPage(sFile = vc,sOutdev = vc) = i2 with copy, persist
subroutine OpenPage(sFile,sOutdev)
	
	call echo("calling OpenPage")
	free set replyOut
	record replyOut(
    	1 info_line [*]
      	2 new_line = vc
  	)
  	free set getREPLY
  	record getREPLY (
    	1 INFO_LINE[*]
      		2 new_line                = vc
    	1 data_blob                 = gvc
    	1 data_blob_size            = i4
%i cclsource:status_block.inc
	)
	free set getREQUEST
  	record getREQUEST (
    	1 Module_Dir = vc
    	1 Module_Name = vc
	    1 bAsBlob = i2
	)
	
	set getrequest->module_dir= "cust_script:"
	set getrequest->Module_name = trim(sFile)
	set getrequest->bAsBlob = 1
	execute eks_get_source with replace (REQUEST,getREQUEST),replace(REPLY,getREPLY)
	call echo("after eks_get_source")
	free set putreply
	record putreply (
    	1 INFO_LINE [*]
			2 new_line = vc
%i cclsource:status_block.inc
		)
	free set putREQUEST
	record putREQUEST (
	    	1 source_dir = vc
	    1 source_filename = vc
	    1 nbrlines = i4
	    1 line [*]
			2 lineData = vc
		1 OverFlowPage [*]
			2 ofr_qual [*]
				3 ofr_line = vc
		1 IsBlob = c1
		1 document_size = i4
		1 document = gvc
	  )
	 
	call echo(build("sData ------------>",sData))
	call echorecord(getReply)
	 
	set putRequest->source_dir = sOutdev
	set putRequest->IsBlob = "1"
	set putRequest->document = replace(getReply->data_blob,"sXMLData",sData,0)
	set putRequest->document_size = size(putRequest->document)
	call echorecord(putREQUEST)
	
	execute eks_put_source with replace(Request,putRequest),replace(reply,putReply)
	
	return ( 1 )
end ; subroutine OpenPage()

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
