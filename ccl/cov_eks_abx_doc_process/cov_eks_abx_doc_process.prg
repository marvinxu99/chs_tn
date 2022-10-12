/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_eks_abx_doc_process.prg
  Object name:        cov_eks_abx_doc_process
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG	
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			initial build
******************************************************************************/
drop program cov_eks_abx_doc_process:dba go
create program cov_eks_abx_doc_process:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "EVENTID" = "0"
	, "COMMIT_MODE" = 0 

with OUTDEV, EVENTID, COMMIT_MODE

call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0	
set noaudvar = 1	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

execute cov_std_log_routines
execute cov_abx_routines

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

call set_codevalues(null)
call check_ops(null)

call addEmailLog("chad.cummings@covhlth.com")

set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	1 event
	 2 clinical_event_id = f8
	 2 event_id = f8
	1 commit_mode = i4
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
	1 debug_ind		= i2
	1 active_ind	= i2
	1 constants
	 2 prsnl_id		= f8
	 2 classification_cd = f8
	 2 confirmed_cd	= f8
	 2 position_cd	= f8
	 2 ppr_cd		= f8
	 2 final_type_cd = f8
	1 query_cnt	    = i2	
	1 query_qual[*]
	 2 code_value	= f8
	 2 display		= vc
	 2 definition	= vc
	 2 coding_section = vc
	 2 code_cnt		= i2
	 2 code_qual[*]
	  3	code_value	= f8
	  3 display		= vc
	  3 description	= vc
	  3 definition  = vc
	  3 icd10code	= vc
	  3 snomedcode 	= vc
	  3 uuid		= vc
	  3 diag_nomenclature_id = f8
	  3 snomed_nomenclature_id = f8
	  3 start_pos	= i4
	  3 end_pos		= i4
	  3 checked_value = vc
	  3 codes_cnt = i4
	  3 codes[*]
	   4 diag_nomenclature_id = f8
	   4 snomed_nomenclature_id = f8
	   4 icd10code	= vc
	   4 snomedcode = vc
	1 prompts
	 2 outdev		= vc
	 2 eventid		= f8
	1 query_selected = i2
	1 title_start	= i4
	1 title_end		= i4
	1 title_found	= vc
	1 title_search  = vc
	1 coding_start  = i4
	1 coding_end	= i4
	1 coding_found	= vc
	1 html_text 	= gvc
	1 select_cnt	= i2
	1 select_qual[*]
	 2 select_diag_text	= vc
	 2 select_diag_code	= vc
	 2 select_snomed_text = vc
	 2 select_snomed_code = vc
	 2 diag_nomenclature_id = f8
	 2 snomed_nomenclature_id = f8
	 2 add_ind		= i2
)

record 969503_request (
  1 mdoc_event_id = f8   
  1 sessions [*]   
    2 dd_session_id = f8   
  1 read_only_flag = i4   
  1 revise_flag = i2   
)

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
set t_rec->event.clinical_event_id			= $EVENTID
set t_rec->commit_mode						= $COMMIT_MODE
set t_rec->constants.prsnl_id				= reqinfo->updt_id

call writeLog(build2("t_rec->patient.encntr_id=",t_rec->patient.encntr_id))
call writeLog(build2("t_rec->patient.person_id=",t_rec->patient.person_id))
call writeLog(build2("t_rec->event.clinical_event_id=",t_rec->event.clinical_event_id))
call writeLog(build2("t_rec->commit_mode=",t_rec->commit_mode))
call writeLog(build2("link_encntrid=",link_encntrid))
call writeLog(build2("link_personid=",link_personid))
call writeLog(build2("link_clinicaleventid=",link_clinicaleventid))

call writeLog(build2("$OUTDEV=",$OUTDEV))
call writeLog(build2("$EVENTID=",$EVENTID))
call writeLog(build2("$COMMIT_MODE=",$COMMIT_MODE))

declare pos = i4 with noconstant(0)
declare not_found = vc with constant("<not found>")
declare h = i4 with noconstant(0)
declare i = i4 with noconstant(0)
declare j = i4 with noconstant(0)
declare k = i4 with noconstant(0)
declare coding_uuid_int = i2 with noconstant(2)

if (not(validate(_memory_reply_string)))
	declare _memory_reply_string = gvc
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

set t_rec->return_value = "FALSE"

set t_rec->constants.classification_cd = uar_get_code_by("MEANING",12033,"MEDICAL")
set t_rec->constants.confirmed_cd = uar_get_code_by("MEANING",12031,"CONFIRMED")
set t_rec->constants.final_type_cd = uar_get_code_by("MEANING",17,"FINAL")

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

if (t_rec->constants.classification_cd <= 0.0)
	set t_rec->log_message = concat("medical classification code value not found")
	go to exit_script
endif

if (t_rec->constants.confirmed_cd <= 0.0)
	set t_rec->log_message = concat("confirmed lifecycle code value not found")
	go to exit_script
endif

set stat = cnvtjsontorec(get_cdi_code_query_def(null))

call echo(validate_cdi_document(t_rec->event.clinical_event_id))

select into "nl:"
from 
	clinical_event ce
	,code_value cv
plan ce
	where ce.clinical_event_id = t_rec->event.clinical_event_id
join cv
	where cv.code_set = 72
	and   cv.display in("Pharmacy Progress Note","Pharmacy Collaboration Note")
	and   cv.active_ind = 1
	and   cv.code_value = ce.event_cd
detail
	t_rec->event.event_id = ce.parent_event_id
	t_rec->constants.prsnl_id = ce.verified_prsnl_id
with nocounter

if (t_rec->event.event_id <= 0.0)
	set t_rec->log_message = concat("not a ABX valid note")
	go to exit_script
endif

select into "nl:"
from
	prsnl p
	,encntr_prsnl_reltn epr
plan p
	where p.person_id = t_rec->constants.prsnl_id
join epr
	where epr.prsnl_person_id = p.person_id
	and   epr.active_ind = 1
	and   cnvtdatetime(curdate,curtime3) between epr.beg_effective_dt_tm and epr.end_effective_dt_tm
	and   epr.encntr_id = t_rec->patient.encntr_id
detail
	t_rec->constants.position_cd = p.position_cd
	t_rec->constants.ppr_cd = epr.encntr_prsnl_r_cd
with nocounter

if (t_rec->constants.position_cd <= 0.0)
	set t_rec->log_message = concat("no position for user found")
	go to exit_script
endif

if (t_rec->constants.ppr_cd <= 0.0)
	set t_rec->log_message = concat("prsnl does not have an active encounter relationship")
	go to exit_script
endif

call writeLog(build2("Getting Document"))

set 969503_request->mdoc_event_id = t_rec->event.event_id
set 969503_request->read_only_flag = 1

free record 969503_reply
;call echorecord(969503_request)
set stat = tdbexecute(
            600005              /*appid - HNA: Powerchart*/
            , 3202004           /*taskid*/
            , 969503            /*reqid*/
            , "REC"             /*request_from_type*/
            , 969503_request    /*request_from*/
            , "REC"             /*reply_to_type*/
            , 969503_reply      /*reply_to*/
            , 0                 /*mode*/
        ) 

call echorecord(969503_reply)
call writeLog(build2("looking at 969503_reply->document->contributions"))
for (i=1 to size(969503_reply->document->contributions,5))
	;call echo(969503_reply->document->contributions[i].html_text)
	;set pos = findstring("CDI Query Form: Response Requested",969503_reply->document->contributions[i].html_text,1,0)
	set pos = findstring("PHARMACY COLLABORATION FOR IMPROVED DOCUMENTATION",969503_reply->document->contributions[i].html_text,1,0)
	if (pos > 0)
		set t_rec->html_text = 969503_reply->document->contributions[i].html_text
		call echo(t_rec->html_text)
	endif	
endfor

if (t_rec->html_text = "")
	set t_rec->log_message = concat("no HTML document found")
	go to exit_script
endif


set t_rec->title_search = "PHARMACY COLLABORATION FOR IMPROVED DOCUMENTATION - "
set t_rec->title_start = findstring(t_rec->title_search,t_rec->html_text,1,0)



if (t_rec->title_start > 0)
	set t_rec->title_end = findstring("</u></span>",t_rec->html_text,t_rec->title_start,0)
else
	set t_rec->log_message = concat("Additional Specificity title not found")
	go to exit_script
endif


if (t_rec->title_end > 0)
	set t_rec->title_found = trim(substring(	 (t_rec->title_start + size(t_rec->title_search))
										,(t_rec->title_end - (t_rec->title_start + size(t_rec->title_search)))
										,t_rec->html_text),3)
else
	set t_rec->log_message = concat("Additional Specificity title end position not found")
	go to exit_script
endif

call writeLog(build2("->starting t_rec->query_cnt loop"))

for (i=1 to cdi_definition->query_cnt)
 if (t_rec->query_selected = 0) ;skip check if document title has already been found
	call writeLog(build2("->checking:",cdi_definition->query_qual[i].definition," against ",t_rec->title_found))
	if (cdi_definition->query_qual[i].definition = t_rec->title_found)
		set t_rec->query_selected = i
		
		call writeLog(build2("->matched:",cdi_definition->query_qual[i].definition))
		call writeLog(build2("->t_rec->query_selected:",t_rec->query_selected))
		
		set t_rec->coding_start = findstring(cdi_definition->query_qual[i].coding_section,t_rec->html_text,t_rec->title_end,0)
		call writeLog(build2("->t_rec->coding_start:",t_rec->coding_start))
		if (t_rec->coding_start = 0)
			set t_rec->log_message = build2("Coding section of ",cdi_definition->query_qual[i].coding_section," not found")
			go to exit_script
		else
			set t_rec->coding_end = findstring("<u>Clinical Results</u>",t_rec->html_text,t_rec->coding_start,0)
			call writeLog(build2("->t_rec->coding_end:",t_rec->coding_end))
			if (t_rec->coding_end = 0)
				set t_rec->log_message = build2("End of coding section ",cdi_definition->query_qual[i].coding_section," not found")
				go to exit_script
			else
				set t_rec->coding_found = substring(t_rec->coding_start,(t_rec->coding_end - t_rec->coding_start),t_rec->html_text)
				call writeLog(build2("->t_rec->coding_found:",t_rec->coding_found))
			endif
		endif	
	endif
 endif
endfor

call writeLog(build2("<-finished t_rec->query_cnt loop"))

if (t_rec->query_selected = 0)
	set t_rec->log_message = concat("Title in document didn't match any defined in code set")
	go to exit_script
endif

call writeLog(build2("->start looking for uuids that are checked"))

for (i=1 to cdi_definition->query_qual[t_rec->query_selected].code_cnt)
	call writeLog(build2("->searching for uuid:",cdi_definition->query_qual[t_rec->query_selected].code_qual[i].uuid))
	set cdi_definition->query_qual[t_rec->query_selected].code_qual[i].start_pos = findstring(
																						 cdi_definition->query_qual[t_rec->query_selected].code_qual[i].uuid
																						,t_rec->coding_found
																						,0
																						,0
																					)
	if (cdi_definition->query_qual[t_rec->query_selected].code_qual[i].start_pos > 0)
		call writeLog(build2("-->start_pos=:",cdi_definition->query_qual[t_rec->query_selected].code_qual[i].start_pos))
		set cdi_definition->query_qual[t_rec->query_selected].code_qual[i].checked_value 
			= substring(
				(cdi_definition->query_qual[t_rec->query_selected].code_qual[i].start_pos 
					+ coding_uuid_int + size(cdi_definition->query_qual[t_rec->query_selected].code_qual[i].uuid))
											,1
											,t_rec->coding_found
										)
		call writeLog(build2("-->checked_value=:",cdi_definition->query_qual[t_rec->query_selected].code_qual[i].checked_value))
	endif
endfor

call writeLog(build2("<-end looking for uuids that are checked"))


call writeLog(build2("->start pulling in codes that qualify"))
for (i=1 to cdi_definition->query_qual[t_rec->query_selected].code_cnt)
	if (cdi_definition->query_qual[t_rec->query_selected].code_qual[i].checked_value = "X")
		call writeLog(build2("-->found checked_value=:",cdi_definition->query_qual[t_rec->query_selected].code_qual[i].checked_value))
		
		for (j=1 to cdi_definition->query_qual[t_rec->query_selected].code_qual[i].codes_cnt)
		
			if ((cdi_definition->query_qual[t_rec->query_selected].code_qual[i].codes[j].diag_nomenclature_id > 0.0)
			   and (cdi_definition->query_qual[t_rec->query_selected].code_qual[i].codes[j].icd10_ind = 1))
				call writeLog(build2("-->icd10code=:",cdi_definition->query_qual[t_rec->query_selected].code_qual[i].icd10code))
				
				set t_rec->select_cnt = (t_rec->select_cnt + 1)
				set stat = alterlist(t_rec->select_qual,t_rec->select_cnt)
				set t_rec->select_qual[t_rec->select_cnt].select_diag_code 
					= cdi_definition->query_qual[t_rec->query_selected].code_qual[i].codes[j].icd10code
				set t_rec->select_qual[t_rec->select_cnt].diag_nomenclature_id = 
					cdi_definition->query_qual[t_rec->query_selected].code_qual[i].codes[j].diag_nomenclature_id				
			endif
			
			if ((cdi_definition->query_qual[t_rec->query_selected].code_qual[i].codes[j].snomed_nomenclature_id > 0.0)
			   and (cdi_definition->query_qual[t_rec->query_selected].code_qual[i].codes[j].snomed_ind = 1))
				call writeLog(build2("-->snomedcode=:",cdi_definition->query_qual[t_rec->query_selected].code_qual[i].snomedcode))
				set t_rec->select_cnt = (t_rec->select_cnt + 1)
				set stat = alterlist(t_rec->select_qual,t_rec->select_cnt)
				set t_rec->select_qual[t_rec->select_cnt].select_snomed_code 
					= cdi_definition->query_qual[t_rec->query_selected].code_qual[i].codes[j].snomedcode
				set t_rec->select_qual[t_rec->select_cnt].snomed_nomenclature_id =
					cdi_definition->query_qual[t_rec->query_selected].code_qual[i].codes[j].snomed_nomenclature_id
			endif
		endfor
	endif
endfor
call echorecord(t_rec->select_qual)
call writeLog(build2("->end pulling in codes that qualify"))

for (i=1 to t_rec->select_cnt)
	
	if (t_rec->select_qual[i].diag_nomenclature_id > 0.0)
		if (t_rec->commit_mode = 1)
			execute mp_add_diagnosis 
								^MINE^, 										;"Output to File/Printer/MINE" = "MINE"
								t_rec->patient.person_id, 						;"person_id" = 0.0
								t_rec->constants.prsnl_id, 						;"user_id" = 0.0
								t_rec->patient.encntr_id, 						;"encntr_id" = 0.
								t_rec->constants.ppr_cd, 						;"ppr_code" = 0.0
								t_rec->select_qual[i].diag_nomenclature_id, 	;"nomenclature_id:" = 0.0
								t_rec->constants.position_cd, 					;"position_cd" = 0.0
								t_rec->select_qual[i].diag_nomenclature_id, 	;"originating_nomen_id" = 0.0
								1,												;"bedrock_config_ind" = 0
	 	 						t_rec->constants.final_type_cd, 				;"add_type_cd:" = 0.0
	 	 						t_rec->constants.classification_cd, 			;"classification_cd:" = 0.0
	 	 						0,												;"dupCheckOnly" = 0
	 	 						t_rec->constants.confirmed_cd,					;"confirmation_cd:" = 0.0
	 	 						0,												;"priority:" = 0
	 	 						0.0,											;"trans_nomen_id" = 0.0
	 	 						""												;"diagnosis_display" = ""
	 	 						
	 	 						 						
	 	 						
	 	 						
	 	 	set t_rec->select_qual[i].add_ind = 1
	 	 endif
	 	 set t_rec->log_message = build2(
										 trim(t_rec->log_message),"|",	
										t_rec->select_qual[i].select_diag_code,",",
										t_rec->select_qual[i].diag_nomenclature_id)
	 endif
	 
	 /* temporarily prevent problems
	 if (t_rec->select_qual[i].snomed_nomenclature_id > 0.0)
	 	if (t_rec->commit_mode = 1)
			execute mp_add_problem 
								^MINE^, 										;"Output to File/Printer/MINE" = "MINE"
								t_rec->patient.person_id, 						;"personId:" = 0.0
								t_rec->patient.encntr_id, 						;"encntrId:" = 0.0
								t_rec->constants.prsnl_id, 						;"userId:" = 0.0
								t_rec->constants.position_cd, 					;"positionCd:" = 0.0
								t_rec->constants.ppr_cd, 						;"pprCd:" = 0.0
								t_rec->select_qual[i].snomed_nomenclature_id, 	;"nomenclatureId:" = 0.0
								t_rec->select_qual[i].snomed_nomenclature_id, 	;"originatingNomenId:" = 0.0
								1,												;"lifeCycleStatusFlag:" = 0
	 	 						1, 												;"bedrock_config_ind:" = 0
	 	 						t_rec->constants.confirmed_cd, 					;"add_type_cd:" = 0.0
	 	 						t_rec->constants.classification_cd				;"classification_cd:" = 0.0
	 	 																		;"dupCheckOnly" = 0
																				;"problem_display:" =""
	 	 						
	 	 						
	 		set t_rec->select_qual[i].add_ind = 1
	 	endif
	 	set t_rec->log_message = build2(
										 trim(t_rec->log_message),"|",	
										t_rec->select_qual[i].select_snomed_code,",",
										t_rec->select_qual[i].snomed_nomenclature_id)
	 endif	
	 */	
 	 call echo(_memory_reply_string)
endfor


set t_rec->return_value = "TRUE"
/*
set t_rec->log_misc1 = concat(
								  t_rec->final_val.diag
								 ,"|"
								 ,t_rec->final_val.impact
							)
*/
#exit_script

set _memory_reply_string = ""; cnvtrectojson(t_rec)
;call echojson(t_rec,"cov_eks_cdi_query_process.dat")

#exit_script_not_active

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

set t_rec->log_message = build2(
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										"person_id=",trim(cnvtstring(t_rec->patient.person_id)),"|",
										"encntr_id=",trim(cnvtstring(t_rec->patient.encntr_id)),"|",
										"clinical_event_id=",trim(cnvtstring(t_rec->event.clinical_event_id)),"|",
										"event_id=",trim(cnvtstring(t_rec->event.event_id)),"|"
										;trim(t_rec->final_val.diag),"|",
										;trim(t_rec->final_val.impact),"|"
									)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

call writeLog(build2("retval=",retval))
call writeLog(build2("log_message=",log_message))
call writeLog(build2("log_misc1=",log_misc1))
call writeLog(build2("_Memory_Reply_String=",_Memory_Reply_String))
call writeLog(build2(cnvtrectojson(t_rec)))

call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)

end 
go
