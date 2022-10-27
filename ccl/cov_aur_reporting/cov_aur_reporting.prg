/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_aur_data_admin.prg
	Object name:		cov_aur_data_admin
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_aur_reporting:dba go
create program cov_aur_reporting:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Report Type" = "AU"
	, "File Location:" = "\\client\c$"
	, "Output:" = 0 

with OUTDEV, REPORT_TYPE, FILE, CSV


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
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


;free set t_rec
record t_rec
(
	1 cnt			= i4
	1 prompts
	 2 outdev			= vc
	 2 report_type		= vc
	 2 file				= vc
	 2 csv				= i4
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 run_dt_tm 	= dq8
	1 dates
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
	1 qual[*]
	 2 person_id	= f8
	 2 encntr_id	= f8
	 2 mrn			= vc
	 2 fin			= vc
	 2 name_full_formatted = vc
)

;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.report_type = $REPORT_TYPE
set t_rec->prompts.file = $FILE
set t_rec->prompts.csv = $CSV


set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)



subroutine OpenPage(sFile)
	
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
	
	set getrequest->module_dir= "cer_install:"
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
	 
	set putRequest->source_dir = $outdev
	set putRequest->IsBlob = "1"
	set putRequest->document = replace(getReply->data_blob,"sXMLData",sData,0)
	set putRequest->document_size = size(putRequest->document)
	call echorecord(putREQUEST)
	
	execute eks_put_source with replace(Request,putRequest),replace(reply,putReply)
	
	return ( 1 )
end ; subroutine OpenPage()
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))



call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

/*
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit *************************************"))
	call writeAudit(build2(
							char(34),^ITEM^,char(34),char(44),
							char(34),^DESC^,char(34)
						))
for (i=1 to t_rec->cnt)
		call writeAudit(build2(
							char(34),t_rec->qual[i].a											,char(34),char(44),
							char(34),t_rec->qual[i].b											,char(34)
						))

endfor
call writeLog(build2("* END   Creating Audit *************************************"))
call writeLog(build2("************************************************************"))
*/

#exit_script

;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)


call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
