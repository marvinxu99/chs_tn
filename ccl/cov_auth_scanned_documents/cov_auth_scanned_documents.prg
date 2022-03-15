/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_auth_scanned_documents.prg
	Object name:		cov_auth_scanned_documents
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

drop program cov_auth_scanned_documents:dba go
create program cov_auth_scanned_documents:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


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
) with protect
endif

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 prompts
	 2 outdev		= vc
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 run_dt_tm 	= dq8
	 2 run_user		= vc
	1 dates
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
	1 cnt			= i4
	1 qual[*]
	 2 person_id			= f8
	 2 encntr_id			= f8
	 2 fin					= vc
	 2 mrn					= vc
	 2 patient_name 		= vc
	 2 clinical_event_id	= f8
	 2 facility				= vc
     2 nurse_unit			= vc
     2 organization_id      = f8
     2 org_name             = vc
     2 event_disp           = c20
     2 event_cd				= f8
     2 event_id				= f8 
     2 event_title_text 	= vc
     2 verified_prsnl_id    = f8
     2 verified_prsnl_pos   = vc 
     2 verified_prsnl  		= vc
     2 valid_from_dt_tm     = dq8
) with protect

declare i = i4 with noconstant(0)
declare eks_event_id = f8 with noconstant(0.0)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->cons.run_dt_tm = cnvtdatetime(curdate,curtime3)
set t_rec->cons.run_user = get_username(reqinfo->updt_id)

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->dminfo.info_domain	= "COV_DEV_OPS"
set t_rec->dminfo.info_name		= concat(trim(cnvtupper(curprog)),":","start_dt_tm")

/*FOR TESING, RESETS DATE*/
;call set_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name,cnvtdatetime("09-DEC-2021 12:00:00"))
/*************************/

set t_rec->dates.start_dt_tm 	= get_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name)
set t_rec->dates.end_dt_tm 		= cnvtdatetime(curdate,curtime3)

if (t_rec->dates.start_dt_tm = 0.0)
	call writeLog(build2("->No start date and time found, setting to go live date"))
	set t_rec->dates.start_dt_tm = cnvtdatetime("09-DEC-2021 12:00:00")
endif


call writeLog(build2("->Shift the dates back 1 hour"))
set t_rec->dates.start_dt_tm = cnvtlookbehind("60,MIN",t_rec->dates.start_dt_tm)
set t_rec->dates.end_dt_tm = cnvtlookbehind("60,MIN",t_rec->dates.end_dt_tm)

free set him_request
record him_request
(
  1 sort_flag = i2
  1 date_flag = i2
  1 start_dt_tm = dq8
  1 end_dt_tm = dq8
  1 org_qual[*]
    2 organization_id = f8
  1 debug_ind = i2
)

free set him_temp
record him_temp
(
 1  qual[*]
     2  encntr_id               = f8
     2  person_id               = f8
     2  mrn_formatted           = c20
     2  fin_formatted           = c20
     2  name_full_formatted     = c35
     2  encntr_type_disp        = c15
     2  med_service_cd			= f8
     2  loc_facility_cd			= f8
     2  loc_nurse_unit_cd		= f8
     2  visit_age               = i2
     2  visit_alloc_dt_tm       = dq8
     2  disch_dt_tm             = dq8
     2  tdo                     = c20
     2  organization_id         = f8
     2  org_name                = vc
     2  doc_qual[*]
         3 clinical_event_id    = f8
         3 event_disp           = c20
         3 event_cd				= f8
         3 status_cd			= f8 
         3 verified_prsnl_id    = f8
         3 verified_prsnl_pos   = vc 
         3 verified_prsnl  		= vc
         3 valid_from_dt_tm     = dq8
         3 event_id				= f8 
         3 scanned_ind			= i2
         3 event_title_text		= vc
         3 valid_ind			= i2
)


set him_request->date_flag = 1
set him_request->debug_ind = 1
set him_request->sort_flag = 1
set him_request->start_dt_tm = cnvtdatetime(t_rec->dates.start_dt_tm)
set him_request->end_dt_tm = cnvtdatetime(t_rec->dates.end_dt_tm)


select into "nl:"
from
	organization o
plan o
	where o.org_name in(
							"Fort Loudoun Medical Center",
							"Fort Sanders Regional Medical Center",
							"LeConte Medical Center",
							"Methodist Medical Center",
							"Morristown-Hamblen Healthcare System",
							"Parkwest Medical Center",
							"Peninsula Behavioral Health",
							"Roane Medical Center"
						)
	and o.active_ind = 1 
head report
	i = 0
detail
	i = (i + 1)
	stat = alterlist(him_request->org_qual,i)
	him_request->org_qual[i].organization_id = o.organization_id
with nocounter

call writeLog(build2(cnvtrectojson(t_rec)))
	
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("* START Execute cov_mak_unauth_doc_driver ******************"))

free set him_reply
record him_reply
(
  1 file_name = vc
%i cclsource:status_block.inc
)

call writeLog(build2(cnvtrectojson(him_request)))

call writeLog(build2("->cov_mak_unauth_doc_driver skipped, using query instead"))
/*
execute cov_mak_unauth_doc_driver with replace(request,him_request), replace(temp,him_temp), replace(reply,him_reply)
*/

select into "nl:"
from
	 clinical_event ce
	,encounter e
	,person p
plan ce
	where ce.clinsig_updt_dt_tm between cnvtdatetime(t_rec->dates.start_dt_tm) and cnvtdatetime(t_rec->dates.end_dt_tm)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ce.result_status_cd in(
									 value(uar_get_code_by("MEANING",8,"UNAUTH"))
									,value(uar_get_code_by("MEANING",8,"IN PROGRESS"))
								)
	and   ce.parent_event_id = ce.event_id
join e
	where e.encntr_id = ce.encntr_id
	and   expand(i,1,size(him_request->org_qual,5),e.organization_id,him_request->org_qual[i].organization_id)
join p
	where p.person_id = e.person_id
order by
	e.encntr_id
head report
	i = 0
	j = 0
head e.encntr_id
	i = (i + 1)
	stat = alterlist(him_temp->qual,i)
	him_temp->qual[i].encntr_id = ce.encntr_id
	him_temp->qual[i].person_id = ce.person_id
	him_temp->qual[i].loc_facility_cd = e.loc_facility_cd
	him_temp->qual[i].loc_nurse_unit_cd = e.loc_nurse_unit_cd
	him_temp->qual[i].med_service_cd = e.med_service_cd
	him_temp->qual[i].name_full_formatted = p.name_full_formatted
	him_temp->qual[i].organization_id = e.organization_id
	j = 0
detail
	j = (j + 1)
	stat = alterlist(him_temp->qual[i].doc_qual,j)
	him_temp->qual[i].doc_qual[j].clinical_event_id = ce.clinical_event_id
	him_temp->qual[i].doc_qual[j].event_cd = ce.event_cd
	him_temp->qual[i].doc_qual[j].event_disp = uar_get_code_display(ce.event_cd)
	him_temp->qual[i].doc_qual[j].event_id = ce.event_id
	him_temp->qual[i].doc_qual[j].valid_from_dt_tm = ce.valid_from_dt_tm
	him_temp->qual[i].doc_qual[j].status_cd = ce.result_status_cd
with nocounter

if (size(him_temp->qual,5) <= 0)
	go to exit_script
endif

call writeLog(build2("* END   Execute cov_mak_unauth_doc_driver *******************"))

/*
call writeLog(build2("* START Getting Encounter Information ***********************"))

select into "nl:"
from
	 encounter e
	,(dummyt d1 with seq=value(size(him_temp->qual,5)))
plan d1
join e
	where e.encntr_id = him_temp->qual[d1.seq].encntr_id
order by
	e.encntr_id
head e.encntr_id
	him_temp->qual[d1.seq].med_service_cd = e.med_service_cd
	him_temp->qual[d1.seq].loc_facility_cd = e.loc_facility_cd
	him_temp->qual[d1.seq].loc_nurse_unit_cd = e.loc_building_cd
with nocounter
call writeLog(build2("* END   Getting Encounter Information ***********************"))
*/

call writeLog(build2("* START Getting Document Information ************************"))

select into "nl:"
from
	 clinical_event ce
	,(dummyt d1 with seq=size(him_temp->qual,5))
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,size(him_temp->qual[d1.seq].doc_qual,5))
join d2
join ce
	where ce.clinical_event_id = him_temp->qual[d1.seq].doc_qual[d2.seq].clinical_event_id
order by
	ce.clinical_event_id
head ce.clinical_event_id
	 him_temp->qual[d1.seq].doc_qual[d2.seq].event_cd = ce.event_cd
	 him_temp->qual[d1.seq].doc_qual[d2.seq].status_cd = ce.result_status_cd ;003
	 him_temp->qual[d1.seq].doc_qual[d2.seq].event_title_text = ce.event_title_text ;003
	 him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl_id = ce.verified_prsnl_id
	 if (him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl_id = 0.0)
	 	him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl_id = ce.performed_prsnl_id
	 endif
with nocounter
call writeLog(build2("* END   Getting Document Information ************************"))

call writeLog(build2("* START Scanned Document Check *****************************"))
select into "nl:"
from 
	 ce_blob_result cbr
	,clinical_event ce 
	,(dummyt d1 with seq=size(him_temp->qual,5))
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,size(him_temp->qual[d1.seq].doc_qual,5))
join d2
join ce	
	where ce.parent_event_id = him_temp->qual[d1.seq].doc_qual[d2.seq].event_id 
join cbr	
	where cbr.event_id = ce.event_id	
	and cbr.storage_cd = value(uar_get_code_by("DISPLAYKEY", 25, "OTG")) 
	and cbr.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)  
detail
	him_temp->qual[d1.seq].doc_qual[d2.seq].scanned_ind = 1
	him_temp->qual[d1.seq].doc_qual[d2.seq].valid_ind = 1
with nocounter
call writeLog(build2("* END   Scanned Document Check *****************************"))

call writeLog(build2("* START Getting Document Author *****************************"))

select into "nl:"
from
	 prsnl p1
	,(dummyt d1 with seq=size(him_temp->qual,5))
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,size(him_temp->qual[d1.seq].doc_qual,5))
join d2
join p1
	where p1.person_id = him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl_id
detail
	him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl = p1.name_full_formatted
	him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl_pos = uar_get_code_display(p1.position_cd) 
	if (p1.physician_ind = 1)
		him_temp->qual[d1.seq].doc_qual[d2.seq].valid_ind = 0
	endif
with nocounter
call writeLog(build2("* END   Getting Document Author *****************************"))

call writeLog(build2("* START Check Sign Request *********************************"))
select into "nl:"
from 
	 ce_event_prsnl cep
	,clinical_event ce 
	,(dummyt d1 with seq=size(him_temp->qual,5))
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,size(him_temp->qual[d1.seq].doc_qual,5))
join d2
join ce	
	where ce.parent_event_id = him_temp->qual[d1.seq].doc_qual[d2.seq].event_id 
join cep	
	where cep.event_id = ce.event_id	
	and   cep.action_type_cd = value(uar_get_code_by("MEANING",21,"SIGN"))
	and   cep.action_status_cd = value(uar_get_code_by("MEANING",103,"REQUESTED"))
	and   cep.valid_from_dt_tm >= cnvtdatetime(curdate,curtime3)
detail
	him_temp->qual[d1.seq].doc_qual[d2.seq].valid_ind = 0
	call writeLog(build2("->Resetting valid_ind for event_id = ",ce.event_id))
with nocounter
call writeLog(build2("* END   Check Sign Request *********************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Adding Scanned Documents to List *******************"))

select into "nl:"
from
	 (dummyt d1 with seq=size(him_temp->qual,5))
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,size(him_temp->qual[d1.seq].doc_qual,5))
join d2
	where him_temp->qual[d1.seq].doc_qual[d2.seq].valid_ind = 1
head report
	i = 0
detail
	i = (i + 1)
	stat = alterlist(t_rec->qual,i)
	t_rec->qual[i].person_id					= him_temp->qual[d1.seq].person_id
	t_rec->qual[i].encntr_id					= him_temp->qual[d1.seq].encntr_id
	t_rec->qual[i].patient_name 	            = him_temp->qual[d1.seq].name_full_formatted
	t_rec->qual[i].clinical_event_id            = him_temp->qual[d1.seq].doc_qual[d2.seq].clinical_event_id
	t_rec->qual[i].facility			            = uar_get_code_display(him_temp->qual[d1.seq].loc_facility_cd)
	t_rec->qual[i].nurse_unit		            = uar_get_code_display(him_temp->qual[d1.seq].loc_nurse_unit_cd)  
	t_rec->qual[i].organization_id              = him_temp->qual[d1.seq].organization_id
	t_rec->qual[i].org_name                     = him_temp->qual[d1.seq].org_name
	t_rec->qual[i].event_disp                   = him_temp->qual[d1.seq].doc_qual[d2.seq].event_disp
	t_rec->qual[i].event_cd						= him_temp->qual[d1.seq].doc_qual[d2.seq].event_cd
	t_rec->qual[i].event_id			            = him_temp->qual[d1.seq].doc_qual[d2.seq].event_id
	t_rec->qual[i].event_title_text	            = him_temp->qual[d1.seq].doc_qual[d2.seq].event_title_text
	t_rec->qual[i].verified_prsnl_id	        = him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl_id
	t_rec->qual[i].verified_prsnl	            = him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl
	t_rec->qual[i].verified_prsnl_pos	        = him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl_pos
	t_rec->qual[i].valid_from_dt_tm				= him_temp->qual[d1.seq].doc_qual[d2.seq].valid_from_dt_tm
foot report
	t_rec->cnt = i
with nocounter

call writeLog(build2("* END   Adding Scanned Documents to List *******************"))
call writeLog(build2("************************************************************"))


call get_fin(0)
call get_mrn(0)

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit *************************************"))
	call writeAudit(build2(
							char(34),	"run_dt_tm:"													,char(34),char(44),				
							char(34),	format(t_rec->cons.run_dt_tm,"DD-MMM-YYYY HH:MM:SS;;q")	,char(34),char(44),
							char(34),	"start_dt_tm:"													,char(34),char(44), 
							char(34),	format(t_rec->dates.start_dt_tm,"DD-MMM-YYYY HH:MM:SS;;q"),char(34),char(44), 
							char(34),	"end_dt_tm:"		,char(34),char(44),   
							char(34),	format(t_rec->dates.end_dt_tm,"DD-MMM-YYYY HH:MM:SS;;q")	,char(34),char(44),   
							char(34),	"user:"	  														,char(34),char(44),   
							char(34),	t_rec->cons.run_user											,char(34),char(44),   
							char(34),	""			,char(34),char(44),   
							char(34),	""			,char(34),char(44),   
							char(34),	""			,char(34),char(44),   
							char(34),	""			,char(34),char(44), 
							char(34),	""			,char(34),char(44),
							char(34),	""			,char(34)
						))
	call writeAudit(build2(
							char(34),	"person_id"			,char(34),char(44),				
							char(34),	"encntr_id"			,char(34),char(44),
							char(34),	"mrn"				,char(34),char(44), 
							char(34),	"fin"				,char(34),char(44), 
							char(34),	"patient_name"		,char(34),char(44),   
							char(34),	"clinical_event_id"	,char(34),char(44),
							char(34),	"prsnl"		  		,char(34),char(44),
							char(34),	"prsnl_position"	,char(34),char(44),
							char(34),	"prsnl_id"	  		,char(34),char(44),   
							char(34),	"facility"	  		,char(34),char(44),   
							char(34),	"nurse_unit"		,char(34),char(44),   
							char(34),	"organization_id"	,char(34),char(44),   
							char(34),	"org_name"			,char(34),char(44),   
							char(34),	"event_disp"		,char(34),char(44),   
							char(34),	"event_title_text"	,char(34),char(44), 
							char(34),	"event_cd"			,char(34),char(44),
							char(34),	"event_id"			,char(34),char(44),
							char(34),	"clinical_event_id" ,char(34)
						))
for (i=1 to t_rec->cnt)
		call writeAudit(build2(
							char(34),	t_rec->qual[i].person_id					,char(34),char(44),				
							char(34),	t_rec->qual[i].encntr_id					,char(34),char(44),
							char(34),	t_rec->qual[i].mrn		 		            ,char(34),char(44),  
							char(34),	t_rec->qual[i].fin			 	            ,char(34),char(44),  
							char(34),	t_rec->qual[i].patient_name 	            ,char(34),char(44),   
							char(34),	t_rec->qual[i].clinical_event_id            ,char(34),char(44),
							char(34),	t_rec->qual[i].verified_prsnl	            ,char(34),char(44),
							char(34),	t_rec->qual[i].verified_prsnl_pos	        ,char(34),char(44),
							char(34),	t_rec->qual[i].verified_prsnl_id	        ,char(34),char(44),   
							char(34),	t_rec->qual[i].facility			            ,char(34),char(44),   
							char(34),	t_rec->qual[i].nurse_unit		            ,char(34),char(44),   
							char(34),	t_rec->qual[i].organization_id              ,char(34),char(44),   
							char(34),	t_rec->qual[i].org_name                     ,char(34),char(44),   
							char(34),	t_rec->qual[i].event_disp                   ,char(34),char(44),   
							char(34),	t_rec->qual[i].event_title_text             ,char(34),char(44),   
							char(34),	t_rec->qual[i].event_cd						,char(34),char(44),
							char(34),	t_rec->qual[i].event_id			            ,char(34),char(44),
							char(34),	t_rec->qual[i].clinical_event_id            ,char(34)
						))

endfor
call writeLog(build2("* END   Creating Audit *************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Sending Documents to Rule **************************"))
for (i=1 to t_rec->cnt)	
	call writeLog(build2("->sending t_rec->qual[",trim(cnvtstring(i)),"].clinical_event_id=",t_rec->qual[i].clinical_event_id))
	set eks_event_id = t_rec->qual[i].clinical_event_id
	execute COV_HIM_AUTH_BY_CE_EVENT ^MINE^,eks_event_id
endfor

if (t_rec->cnt = 0)
	set reply->status_data.status = "Z"
elseif (t_rec->cnt > 0)
	set reply->status_data.status = "S"
endif

call writeLog(build2("* END Sending Documents to Rule ****************************"))

#exit_script

if (reply->status_data.status in("Z","S"))
	call writeLog(build2("* START Set Date Range ************************************"))
	call set_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name,t_rec->dates.end_dt_tm)
	call writeLog(build2("* END Set Date Range ************************************v1"))
endif

call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"","MV" 

call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
