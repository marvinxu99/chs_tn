/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_eks_cdi_query_process.prg
  Object name:        cov_eks_cdi_query_process
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
drop program cov_eks_cdi_query_process:dba go
create program cov_eks_cdi_query_process:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "EVENTID" = "0" 

with OUTDEV, EVENTID

call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

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
set t_rec->constants.prsnl_id				= reqinfo->updt_id

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

if (t_rec->constants.classification_cd <= 0.0)
	set t_rec->log_message = concat("medical classification code value not found")
	go to exit_script
endif

if (t_rec->constants.confirmed_cd <= 0.0)
	set t_rec->log_message = concat("confirmed lifecycle code value not found")
	go to exit_script
endif

select into "nl:"
from
	 code_value_set cvs
	,code_value cv
	,code_value_group cvg
	,code_value c
	,code_value_extension cve
	,code_value_extension ce
plan cvs
	where cvs.definition = "COVCUSTOM"
join cv
	where cv.code_set = cvs.code_set
	and   cv.cdf_meaning = "CDI_QUERY"
	and   cv.active_ind = 1
	and   cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join cvg
	where cvg.parent_code_value = cv.code_value
	and   cvg.code_set = cv.code_set
join c
	where c.code_value = cvg.child_code_value
	and   c.cdf_meaning = "CDI_CODE"
	and   c.active_ind = 1
join cve
	where cve.code_value = cv.code_value
	and   cve.field_name = "CODING_TITLE"
join ce
	where ce.code_value = c.code_value
	and   ce.field_name = "CODING_UUID"
order by
	cv.code_value
head report
	i = 0
	j = 0
head cv.code_value
	j = 0
	i = (i + 1)
	stat = alterlist(t_rec->query_qual,i)
	t_rec->query_qual[i].code_value		= cv.code_value
	t_rec->query_qual[i].definition		= cv.definition
	t_rec->query_qual[i].display		= cv.display
	t_rec->query_qual[i].coding_section	= cve.field_value
detail
	j = (j + 1)
	stat = alterlist(t_rec->query_qual[i].code_qual,j)
	t_rec->query_qual[i].code_qual[j].code_value	= c.code_value
	t_rec->query_qual[i].code_qual[j].display		= c.display
	t_rec->query_qual[i].code_qual[j].icd10code		= piece(c.definition,";",1,"<notfound>")
	t_rec->query_qual[i].code_qual[j].snomedcode	= piece(c.definition,";",2,"<notfound>")
	t_rec->query_qual[i].code_qual[j].definition	= c.definition
	t_rec->query_qual[i].code_qual[j].description	= c.description
	t_rec->query_qual[i].code_qual[j].uuid			= ce.field_value
foot cv.code_value	
	t_rec->query_qual[i].code_cnt = j
foot report
	t_rec->query_cnt = i
with nocounter


select into "nl:"
from
	 (dummyt d1 with seq=t_rec->query_cnt)
	,(dummyt d2)
	,nomenclature n
plan d1
	where maxrec(d2,t_rec->query_qual[d1.seq].code_cnt)
join d2
join n
	where n.source_identifier = t_rec->query_qual[d1.seq].code_qual[d2.seq].icd10code
	and   n.source_vocabulary_cd = value(uar_get_code_by("DISPLAY",400,"ICD-10-CM")) 
	and   n.active_ind = 1
	and   cnvtdatetime(curdate,curtime3) between n.beg_effective_dt_tm and n.end_effective_dt_tm
order by
	n.beg_effective_dt_tm
detail
	t_rec->query_qual[d1.seq].code_qual[d2.seq].diag_nomenclature_id = n.nomenclature_id
with nocounter

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->query_cnt)
	,(dummyt d2)
	,nomenclature n
plan d1
	where maxrec(d2,t_rec->query_qual[d1.seq].code_cnt)
join d2
join n
	where n.source_identifier = t_rec->query_qual[d1.seq].code_qual[d2.seq].snomedcode
	and   n.source_vocabulary_cd = value(uar_get_code_by("DISPLAY",400,"SNOMED CT")) 
	and   n.active_ind = 1
	and   cnvtdatetime(curdate,curtime3) between n.beg_effective_dt_tm and n.end_effective_dt_tm
order by
	n.beg_effective_dt_tm
detail
	t_rec->query_qual[d1.seq].code_qual[d2.seq].snomed_nomenclature_id = n.nomenclature_id
with nocounter

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

select into "nl:"
from 
	clinical_event ce
	,code_value cv
plan ce
	where ce.clinical_event_id = t_rec->event.clinical_event_id
join cv
	where cv.code_set = 72
	and   cv.display = "CDI Coding Query"
	and   cv.active_ind = 1
	and   cv.code_value = ce.event_cd
detail
	t_rec->event.event_id = ce.parent_event_id
	t_rec->constants.prsnl_id = ce.verified_prsnl_id
with nocounter

if (t_rec->event.event_id <= 0.0)
	set t_rec->log_message = concat("not a CDI valid note")
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

;call echorecord(969503_reply)

for (i=1 to size(969503_reply->document->contributions,5))
	;call echo(969503_reply->document->contributions[i].html_text)
	;set pos = findstring("CDI Query Form: Response Requested",969503_reply->document->contributions[i].html_text,1,0)
	set pos = findstring("CDI Query",969503_reply->document->contributions[i].html_text,1,0)
	if (pos > 0)
		set t_rec->html_text = 969503_reply->document->contributions[i].html_text
		call echo(t_rec->html_text)
	endif	
endfor

if (t_rec->html_text = "")
	set t_rec->log_message = concat("no HTML document found")
	go to exit_script
endif


set t_rec->title_search = "Additional Specificity - "
set t_rec->title_start = findstring(t_rec->title_search,t_rec->html_text,1,0)

if (t_rec->title_start = 0)
	set t_rec->title_search = "Additional Specificity&#xa0;&#8211;&#xa0;"
	set t_rec->title_start = findstring(t_rec->title_search,t_rec->html_text,1,0)
endif

if (t_rec->title_start > 0)
	set t_rec->title_end = findstring("</span>",t_rec->html_text,t_rec->title_start,0)
else
	set t_rec->log_message = concat("Additional Specificity title not found")
	go to exit_script
endif


if (t_rec->title_end > 0)
	set t_rec->title_found = trim(substring(	 (t_rec->title_start + size(t_rec->title_search))
										,(t_rec->title_end - (t_rec->title_start + size(t_rec->title_search)))
										,t_rec->html_text),3)
	set t_rec->title_found = replace(t_rec->title_found,^&#xA0;^," ")
else
	set t_rec->log_message = concat("Additional Specificity title end position not found")
	go to exit_script
endif

for (i=1 to t_rec->query_cnt)
 if (t_rec->query_selected = 0) ;skip check if document title has already been found
	call writeLog(build2("->checking:",t_rec->query_qual[i].definition," against ",t_rec->title_found))
	if (t_rec->query_qual[i].definition = t_rec->title_found)
		call writeLog(build2("->matched:",t_rec->query_qual[i].definition))
		set t_rec->query_selected = i
		set t_rec->coding_start = findstring(t_rec->query_qual[i].coding_section,t_rec->html_text,t_rec->title_end,0)
		call writeLog(build2("->t_rec->coding_start:",t_rec->coding_start))
		if (t_rec->coding_start = 0)
			set t_rec->log_message = build2("Coding section of ",t_rec->query_qual[i].coding_section," not found")
			go to exit_script
		else
			set t_rec->coding_end = findstring("______________________________________________",t_rec->html_text,t_rec->coding_start,0)
			call writeLog(build2("->t_rec->coding_end:",t_rec->coding_end))
			if (t_rec->coding_end = 0)
				set t_rec->log_message = build2("End of coding section ",t_rec->query_qual[i].coding_section," not found")
				go to exit_script
			else
				set t_rec->coding_found = substring(t_rec->coding_start,(t_rec->coding_end - t_rec->coding_start),t_rec->html_text)
				call writeLog(build2("->t_rec->coding_found:",t_rec->coding_found))
			endif
		endif	
	endif
 endif
endfor

if (t_rec->query_selected = 0)
	set t_rec->log_message = concat("Title in document didn't match any defined in code set")
	go to exit_script
endif

for (i=1 to t_rec->query_qual[t_rec->query_selected].code_cnt)
	call writeLog(build2("->searching for uuid:",t_rec->query_qual[t_rec->query_selected].code_qual[i].uuid))
	set t_rec->query_qual[t_rec->query_selected].code_qual[i].start_pos = findstring(
																						 t_rec->query_qual[t_rec->query_selected].code_qual[i].uuid
																						,t_rec->coding_found
																						,0
																						,0
																					)
	if (t_rec->query_qual[t_rec->query_selected].code_qual[i].start_pos > 0)
		call writeLog(build2("-->start_pos=:",t_rec->query_qual[t_rec->query_selected].code_qual[i].start_pos))
		set t_rec->query_qual[t_rec->query_selected].code_qual[i].checked_value 
			= substring(
				(t_rec->query_qual[t_rec->query_selected].code_qual[i].start_pos 
					+ coding_uuid_int + size(t_rec->query_qual[t_rec->query_selected].code_qual[i].uuid))
											,1
											,t_rec->coding_found
										)
		call writeLog(build2("-->checked_value=:",t_rec->query_qual[t_rec->query_selected].code_qual[i].checked_value))
	endif
endfor

for (i=1 to t_rec->query_qual[t_rec->query_selected].code_cnt)
	if (t_rec->query_qual[t_rec->query_selected].code_qual[i].checked_value = "X")
		call writeLog(build2("-->checked_value=:",t_rec->query_qual[t_rec->query_selected].code_qual[i].checked_value))
		if ((t_rec->query_qual[t_rec->query_selected].code_qual[i].diag_nomenclature_id > 0.0)
		 or (t_rec->query_qual[t_rec->query_selected].code_qual[i].snomed_nomenclature_id > 0.0))
			
			call writeLog(build2("-->icd10code=:",t_rec->query_qual[t_rec->query_selected].code_qual[i].icd10code))
			call writeLog(build2("-->snomedcode=:",t_rec->query_qual[t_rec->query_selected].code_qual[i].snomedcode))
			
			set t_rec->select_cnt = (t_rec->select_cnt + 1)
			set stat = alterlist(t_rec->select_qual,t_rec->select_cnt)
			set t_rec->select_qual[t_rec->select_cnt].select_diag_code = t_rec->query_qual[t_rec->query_selected].code_qual[i].icd10code
			set t_rec->select_qual[t_rec->select_cnt].select_diag_text = t_rec->query_qual[t_rec->query_selected].code_qual[i].description
			set t_rec->select_qual[t_rec->select_cnt].select_snomed_text = t_rec->query_qual[t_rec->query_selected].code_qual[i].description
			set t_rec->select_qual[t_rec->select_cnt].select_snomed_code = t_rec->query_qual[t_rec->query_selected].code_qual[i].snomedcode
			set t_rec->select_qual[t_rec->select_cnt].diag_nomenclature_id = 
				t_rec->query_qual[t_rec->query_selected].code_qual[i].diag_nomenclature_id
			set t_rec->select_qual[t_rec->select_cnt].snomed_nomenclature_id =
				t_rec->query_qual[t_rec->query_selected].code_qual[i].snomed_nomenclature_id
		endif
	endif
endfor

for (i=1 to t_rec->select_cnt)
	
	if (t_rec->select_qual[i].diag_nomenclature_id > 0.0)
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
	 
	 
	 if (t_rec->select_qual[i].snomed_nomenclature_id > 0.0)
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
	 
	 /*
 	 set t_rec->log_message = concat(
										 trim(t_rec->log_message),"|",	
										t_rec->select_qual[i].select_code,",",
										t_rec->select_qual[i].select_text)	
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

set t_rec->log_message = concat(
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

call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)

end 
go
