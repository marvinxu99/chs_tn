/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_appt_to_document.prg
	Object name:		cov_appt_to_document
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

drop program cov_appt_to_document:dba go
create program cov_appt_to_document:dba

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
)
endif

  
free record document_request 
record document_request
(
   1 personId = f8
   1 encounterId = f8
   1 documentType_key = vc ;  code set 72 display_key
   1 title = vc
   1 service_dt_tm = dq8
   1 notetext = vc
   1 noteformat = vc ; code set 23 cdf_meaning
   1 personnel[3]
     2 id = f8
     2 action = vc     ; code set 21 cdf_meaning
     2 status = vc     ; code set 103 cdf_meanings
   1 mediaObjects[*]
     2 display = vc
     2 identifier = vc
   1 mediaObjectGroups[*]
     2 identifier = vc
   1 publishAsNote = i2
   1 debug = i2
)
 
free record document_reply
record document_reply (
	1 parentEventId = f8
%i cclsource:status_block.inc
)

set reply->status_data.status = "F"

call set_codevalues(null)
call check_ops(null)

record t_rec
(
	1 prompts
	 2 outdev		= vc
	1 values
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
	 2 document_key = vc
	 2 html_template = vc
	1 files
	 2 records_attachment		= vc
	1 cnt			= i4
	1 qual[*]
	 2 order_id					= f8
	 2 person_id				= f8
	 2 encntr_id				= f8
	 2 mrn						= vc
	 2 fin						= vc
	 2 patient_name				= vc
	 2 appt_location			= vc
	 2 encntr_type				= vc
	 2 encntr_facility			= vc
	 2 order_mnemonic			= vc
	 2 sch_event_id				= f8
	 2 ordering_provider_id 	= f8
	 2 ordering_provider		= vc
	 2 sch_state				= c40
	 2 appt_dt_tm				= dq8
	 2 valid_appt_ind			= i2
	 2 document_created_ind		= i2
	 2 html_document			= vc
	 2 document_title			= vc 
	 2 event_id					= f8
	 2 qualifying_program		= vc
	 2 cancel_reason_1			= vc
	 2 cancel_reason_2			= vc
	 2 cancel_comment_1			= vc
	 2 cancel_comment_2			= vc
	 2 cancel_reason_comment	= vc
	 2 is_cmg					= i2
) with protect


record 3011001_request (
  1 module_dir = vc  
  1 module_name = vc  
  1 basblob = i2   
) 

set 3011001_request->module_dir = "cust_script:"
set 3011001_request->module_name = "cov_appt_to_document.html"
set 3011001_request->basblob = 1

free record 3011001_reply

call writeLog(build2(cnvtrectojson(3011001_request)))

set stat = tdbexecute(3010000,3011002,3011001,"REC",3011001_request,"REC",3011001_reply)

if (validate(3011001_reply))
	call writeLog(build2(cnvtrectojson(3011001_reply)))
	if (3011001_reply->status_data.status = "S")
		set t_rec->values.html_template = 3011001_reply->data_blob
	else
		call writeLog(build2("HTML Template not found, exiting"))
		go to exit_script
	endif
else	
	call writeLog(build2("HTML Template not found, exiting"))
	go to exit_script
endif




call writeLog(build2("* END   Custom Section  ************************************"))


;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->values.start_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
set t_rec->values.end_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')

set t_rec->values.document_key = "OUTPATIENTDIAGNOSTICSCHEDULINGUPDATE"

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START cov_sm_Appointments_NonCMG *************************"))

call writeLog(build2("->SKIPPING starting cov_sm_appointments_noncmg execution"))
/*
free record request
execute cov_sm_Appointments_NonCMG ^NOFORMS^, 0
call writeLog(build2("->finished cov_sm_appointments_noncmg execution"))

if (validate(noncmg_data->cnt))
	call writeLog(build2("->noncmg_data->cnt validated"))
	if (noncmg_data->cnt > 0)
		call writeLog(build2("->noncmg_data->cnt=",cnvtstring(noncmg_data->cnt)))
		select distinct into "nl:"
			order_id = noncmg_data->list[d1.seq].order_id
		from
			(dummyt d1 with seq=noncmg_data->cnt)
		plan d1
			where noncmg_data->list[d1.seq].sch_action_dt_tm 
				between cnvtdatetime(t_rec->values.start_dt_tm) and cnvtdatetime(t_rec->values.end_dt_tm)
		order by
			order_id
		head report
			call writeLog(build2("->starting query to get data from noncmg_data"))
			i=0
		head order_id
		;detail
			call writeLog(build2("-->noncmg_data->list[",trim(cnvtstring(d1.seq)),"].order_id=",noncmg_data->list[d1.seq].order_id))
			i = (i + 1)
			stat = alterlist(t_rec->qual,i)
			t_rec->qual[i].order_id 				= noncmg_data->list[d1.seq].order_id
			t_rec->qual[i].sch_event_id				= noncmg_data->list[d1.seq].sch_event_id
			t_rec->qual[i].ordering_provider_id 	= noncmg_data->list[d1.seq].order_physician_id
			t_rec->qual[i].appt_location		 	= noncmg_data->list[d1.seq].appt_location
			t_rec->qual[i].encntr_facility		 	= noncmg_data->list[d1.seq].org_name
			t_rec->qual[i].appt_dt_tm			 	= noncmg_data->list[d1.seq].appt_dt_tm
			t_rec->qual[i].sch_state			 	= cnvtupper(noncmg_data->list[d1.seq].appt_state)
			t_rec->qual[i].qualifying_program		= "cov_sm_appointments_noncmg"
		foot report
			t_rec->cnt = i
			call writeLog(build2("<-ending query to get data from noncmg_data"))
		with nocounter
	endif
endif
*/
call writeLog(build2("* END   cov_sm_Appointments_NonCMG *************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START cov_sm_order_appointment_tat ***********************"))

call writeLog(build2("->starting cov_sm_order_appointment_tat execution"))
free record request
execute cov_sm_order_appointment_tat 
										 ^NOFORMS^
										,format(t_rec->values.start_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")
										,format(t_rec->values.end_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")
										,1
										,0
call writeLog(build2("->finished cov_sm_order_appointment_tat execution"))

if (validate(tat_data->list))
	call writeLog(build2("size(tat_data->list,5)=",cnvtstring(size(tat_data->list,5))))
	if (size(tat_data->list,5) > 0)

		select distinct into "nl:"
			order_id = tat_data->list[d1.seq].order_id
		from
			(dummyt d1 with seq=size(tat_data->list,5))
		plan d1
			where tat_data->list[d1.seq].sch_action_dt_tm 
				between cnvtdatetime(t_rec->values.start_dt_tm) and cnvtdatetime(t_rec->values.end_dt_tm)
		order by
			order_id
		head report
			call writeLog(build2("->starting query to get data from tat_data"))
			k=0
			i=t_rec->cnt
		head order_id
			call writeLog(build2("-->tat_data->list[",trim(cnvtstring(d1.seq)),"].order_id=",tat_data->list[d1.seq].order_id))
			k = 0
			k = locateval(j,1,t_rec->cnt,tat_data->list[d1.seq].order_id,t_rec->qual[j].order_id)
			if (k = 0)
				i = (i + 1)
				stat = alterlist(t_rec->qual,i)
				t_rec->qual[i].order_id 				= tat_data->list[d1.seq].order_id
				t_rec->qual[i].encntr_id 				= tat_data->list[d1.seq].encntr_id
				t_rec->qual[i].person_id 				= tat_data->list[d1.seq].person_id
				t_rec->qual[i].appt_dt_tm 				= tat_data->list[d1.seq].appt_dt_tm
				t_rec->qual[i].encntr_type 				= tat_data->list[d1.seq].encntr_type
				t_rec->qual[i].appt_location			= tat_data->list[d1.seq].appt_location
				t_rec->qual[i].encntr_facility			= tat_data->list[d1.seq].org_name
				t_rec->qual[i].sch_state 				= cnvtupper(tat_data->list[d1.seq].sch_state)
				t_rec->qual[i].qualifying_program		= "cov_sm_order_appointment_tat"
				t_rec->qual[i].is_cmg					= tat_data->list[d1.seq].is_cmg
			endif
		foot report
				t_rec->cnt = i
			call writeLog(build2("<-ending query to get data from tat_data"))
		with nocounter
	endif
endif


call writeLog(build2("* END   cov_sm_order_appointment_tat ***********************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Collecting Details *********************************"))

if (t_rec->cnt = 0)
	call writeLog(build2("->t_rec->cnt = 0, setting reply to Z and exiting"))
	set reply->status_data.status = "Z"
	go to exit_script
endif


call writeLog(build2("* Finding Scheduling Events"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	 ,sch_event_attach sea
plan d1
	where t_rec->qual[d1.seq].sch_event_id = 0.0
join sea
	where sea.order_id = t_rec->qual[d1.seq].order_id
	and sea.attach_type_cd in(value(uar_get_code_by("DISPLAYKEY",16110,"ORDER")))
	and cnvtdatetime(curdate,curtime3) between sea.beg_effective_dt_tm and sea.end_effective_dt_tm
head report
	call writeLog(build2("->inside scheduling events query"))
detail
	t_rec->qual[d1.seq].sch_event_id = sea.sch_event_id
	call writeLog(build2("-->order_id=",cnvtstring(sea.order_id)))
	call writeLog(build2("-->sch_event_id=",cnvtstring(sea.sch_event_id)))
foot report
	call writeLog(build2("<-leaving scheduling events query"))
with nocounter	

call writeLog(build2("* Finding Missing Ordering Provider"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,orders o
	,order_action oa
plan d1
	where t_rec->qual[d1.seq].ordering_provider_id = 0.0
join o
	where o.order_id = t_rec->qual[d1.seq].order_id
join oa
	where oa.order_id = o.order_id
	and   oa.action_type_cd in(value(uar_get_code_by("MEANING",6003,"ORDER")))
	and   oa.action_sequence > 0
order by
	 o.order_id
	,oa.action_sequence asc
head report
	call writeLog(build2("->inside ordering provider query"))
;head o.order_id
detail
	t_rec->qual[d1.seq].ordering_provider_id = oa.order_provider_id
	call writeLog(build2("-->order_id=",cnvtstring(o.order_id)))
	call writeLog(build2("-->order_provider_id=",cnvtstring(oa.order_provider_id)))
foot report
	call writeLog(build2("<-leaving ordering provider query"))
with nocounter


call writeLog(build2("* Finding Person and Encounter Information"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,orders o
plan d1
join o
	where o.order_id = t_rec->qual[d1.seq].order_id
	and ((t_rec->qual[d1.seq].encntr_id = 0.0) or (t_rec->qual[d1.seq].person_id))
order by
	 o.order_id
head report
	call writeLog(build2("->inside person and encounter query"))
;head o.order_id
detail
	t_rec->qual[d1.seq].person_id = o.person_id
	if (o.encntr_id = 0.0)
		t_rec->qual[d1.seq].encntr_id = o.originating_encntr_id
	else
		t_rec->qual[d1.seq].encntr_id = o.encntr_id
	endif
	
	call writeLog(build2("-->order_id=",cnvtstring(o.order_id)))
	call writeLog(build2("-->person_id=",cnvtstring(t_rec->qual[d1.seq].person_id)))
	call writeLog(build2("-->encntr_id=",cnvtstring(t_rec->qual[d1.seq].encntr_id)))
foot report
	call writeLog(build2("<-leaving person and encounter query"))
with nocounter


call writeLog(build2("* Finding Encounter Information"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,encounter e
plan d1
	where t_rec->qual[d1.seq].encntr_type = ""
join e
	where e.encntr_id = t_rec->qual[d1.seq].encntr_id
order by
	 e.encntr_id
head report
	call writeLog(build2("->inside encounter query"))
;head o.order_id
detail
	call writeLog(build2("-->person_id=",cnvtstring(t_rec->qual[d1.seq].person_id)))
	call writeLog(build2("-->encntr_id=",cnvtstring(t_rec->qual[d1.seq].encntr_id)))
	call writeLog(build2("-->encntr_id=",uar_get_code_display(e.encntr_type_cd)))
	t_rec->qual[d1.seq].encntr_type = uar_get_code_display(e.encntr_type_cd)
foot report
	call writeLog(build2("<-leaving encounter query"))
with nocounter

call writeLog(build2("* END   Collecting Details *********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Validating Appointments ****************************"))

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
plan d1	
	where t_rec->qual[d1.seq].ordering_provider_id > 0.0
	and   t_rec->qual[d1.seq].order_id > 0.0
	and   t_rec->qual[d1.seq].is_cmg = 0
	and   t_rec->qual[d1.seq].sch_state in(
												 "NO SHOW"
												,"CONFIRMED"
												,"CANCELED"
								
											)
	and  t_rec->qual[d1.seq].appt_location not in(
														"FSBC TBC",
														"FSR CTL",
														"FSR INF",
														"FSR SPC",
														"FSR TPC",
														"FSSL SLP",
														"LCCR CDR",
														"LCMC MBS",
														"LCMC MMO",
														"LCMC TPC",
														"MHHS CTL",
														"MHHS PET",
														"MMBC ORBC",
														"MMC CAR",
														"MMC CTL",
														"MMC SPC",
														"MMC TST",
														"PW CTL",
														"PW TPC",
														"PW SPC",
														"PWBC BRC",
														"RMC SLP"
													)
head report
	call writeLog(build2("->entering appointment validation"))
detail
	t_rec->qual[d1.seq].valid_appt_ind = 1
foot report
	call writeLog(build2("<-leaving appointment validation"))
with nocounter
call writeLog(build2("* END   Validating Appointments ****************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Getting Patient Identifiers ************************"))

call get_fin(0)
call get_mrn(0)

call writeLog(build2("* END   Getting Patient Identifiers ************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Cancel Informmation ************************"))
                                
select into "nl:"
	 cancel_reason = trim(sed.oe_field_display_value)
    ,cancel_reason2 = trim(uar_get_code_display(seva.sch_reason_cd))
from 
	(dummyt d1 with seq=t_rec->cnt)
	,sch_appt sa
	,SCH_EVENT_ATTACH sea
	,sch_event_action seva
	,sch_event_detail sed
	,(dummyt d2)
	,(dummyt d3)
plan d1	
	where 	t_rec->qual[d1.seq].sch_state in(
											 "CANCELED"
											,"NO SHOW"
											)
	;and   	t_rec->qual[d1.seq].sch_event_id > 0.0
	and   	t_rec->qual[d1.seq].order_id > 0.0
	and   	t_rec->qual[d1.seq].valid_appt_ind = 1
join sea
	where  	sea.order_id = t_rec->qual[d1.seq].order_id
    and 	sea.sch_event_id > 0.0
    and 	sea.attach_type_cd = 10473.00 ; order
    and 	sea.active_ind = 1
join sa
	where 	sa.sch_event_id = sea.sch_event_id
	and 	sa.role_meaning = "PATIENT"
	and 	sa.active_ind = 1
join d2
join seva
	where	seva.sch_event_id 	= sea.sch_event_id
	and 	seva.schedule_id 	= sa.schedule_id
	and 	seva.sch_action_cd 	= 4518.00 ; cancel
	and 	seva.active_ind 	= 1
join d3
join sed 
	where	sed.sch_event_id = sea.sch_event_id
	and 	sed.oe_field_meaning_id in (1105.00) ; cancel reason
	and 	sed.active_ind = 1
head report
	call writeLog(build2("->entering appointment cancellation query"))
detail
	t_rec->qual[d1.seq].cancel_reason_1 	= cancel_reason
	t_rec->qual[d1.seq].cancel_reason_2 	= cancel_reason2
	
	call writeLog(build2("-->order_id=",cnvtstring(t_rec->qual[d1.seq].order_id)))
	call writeLog(build2("-->cancel_reason_1=",trim(t_rec->qual[d1.seq].cancel_reason_1)))
	call writeLog(build2("-->cancel_reason_2=",trim(t_rec->qual[d1.seq].cancel_reason_2)))
foot report
	call writeLog(build2("<-leaving appointment cancellation query"))
with nocounter,outerjoin=d2,outerjoin=d3,dontcare=sed,dontcare=seva

select into "nl:"
	 comment1 = replace(replace(trim(sed2.oe_field_display_value), char(10), ""), char(13), "")
	,comment2 = replace(replace(trim(lt.long_text), char(10), ""), char(13), "")
from 
	(dummyt d1 with seq=t_rec->cnt)
	,sch_appt sa
	,SCH_EVENT_ATTACH sea
	,sch_event_action seva
	,sch_event_detail sed2
	,sch_event_comm sec
	,long_text lt
	,(dummyt d2)
	,(dummyt d4)
	,(dummyt d5)
	,(dummyt d6)
plan d1	
	where 	t_rec->qual[d1.seq].sch_state in(
											 "CANCELED"
											,"NO SHOW"
											)
	;and   	t_rec->qual[d1.seq].sch_event_id > 0.0
	and   	t_rec->qual[d1.seq].order_id > 0.0
	and   	t_rec->qual[d1.seq].valid_appt_ind = 1
join sea
	where  	sea.order_id = t_rec->qual[d1.seq].order_id
    and 	sea.sch_event_id > 0.0
    and 	sea.attach_type_cd = 10473.00 ; order
    and 	sea.active_ind = 1
join sa
	where 	sa.sch_event_id = sea.sch_event_id
	and 	sa.role_meaning = "PATIENT"
	and 	sa.active_ind = 1
join d2
join seva
	where	seva.sch_event_id 	= sea.sch_event_id
	and 	seva.schedule_id 	= sa.schedule_id
	and 	seva.sch_action_cd 	= 4518.00 ; cancel
	and 	seva.active_ind 	= 1
join d4
join sed2
	where	sed2.sch_event_id = sea.sch_event_id
   	and 	sed2.oe_field_meaning_id in (2085.00) ; comment
	and 	sed2.active_ind = 1
join d5
join sec 
	where	sec.sch_event_id = sea.sch_event_id
    and 	sec.sch_action_id = seva.sch_action_id
	and 	sec.active_ind = 1
join d6
join lt
	where	lt.long_text_id = sec.text_id
head report
	call writeLog(build2("->entering appointment cancellation query"))
detail
	t_rec->qual[d1.seq].cancel_comment_1 	= comment1
	t_rec->qual[d1.seq].cancel_comment_2 	= comment2
	
	call writeLog(build2("-->order_id=",cnvtstring(t_rec->qual[d1.seq].order_id)))
	call writeLog(build2("-->cancel_comment_1=",trim(t_rec->qual[d1.seq].cancel_comment_1)))
	call writeLog(build2("-->cancel_comment_2=",trim(t_rec->qual[d1.seq].cancel_comment_2)))
foot report
	call writeLog(build2("<-leaving appointment cancellation query"))
with nocounter,outerjoin=d2,outerjoin=d3,outerjoin=d4,outerjoin=d5,outerjoin=d6,outerjoin=d7,dontcare=sed2,dontcare=sec,dontcare=lt

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
plan d1
head report
	call writeLog(build2("->entering cancel reason"))
detail
	t_rec->qual[d1.seq].cancel_reason_comment = concat(
															 t_rec->qual[d1.seq].cancel_reason_1," "
															,t_rec->qual[d1.seq].cancel_reason_2," "
															,t_rec->qual[d1.seq].cancel_comment_1," "
															,t_rec->qual[d1.seq].cancel_comment_2
														)
foot report
	call writeLog(build2("<-leaving appointment cancellation query"))
with nocounter

call writeLog(build2("* END   Finding Cancel Informmation ************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding No Show Informmation ***********************"))


call writeLog(build2("* END   Finding No Show Informmation ***********************"))
call writeLog(build2("************************************************************"))




call writeLog(build2("************************************************************"))
call writeLog(build2("* START Document Creation **********************************"))

subroutine add_html(text)
	call writeLog(build2("_add_html=",trim(text)))
	set t_rec->qual[d1.seq].html_document = concat(t_rec->qual[d1.seq].html_document,text)
	call writeLog(build2("->t_rec->qual[d1.seq].html_document=",t_rec->qual[d1.seq].html_document))
end

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	 ,orders o
	 ,order_detail od
	 ,oe_format_fields oef
	 ,prsnl p
	 ,person p2
plan d1	
	where t_rec->qual[d1.seq].valid_appt_ind = 1
join o
	where o.order_id = t_rec->qual[d1.seq].order_id
join od
	where od.order_id = o.order_id
join oef
	where oef.oe_field_id = od.oe_field_id
	and   oef.oe_format_id = o.oe_format_id
join p
	where p.person_id = t_rec->qual[d1.seq].ordering_provider_id
join p2
	where p2.person_id = o.person_id	
order by
	 o.order_id
	,od.oe_field_id
	,od.action_sequence desc
head report
	call writeLog(build2("->entering document creation"))
	k = 0
head o.order_id
	call writeLog(build2("-->head order_id=",cnvtstring(o.order_id)))
	call writeLog(build2("-->head order_id (d1.seq) =",cnvtstring(d1.seq)))
	call writeLog(build2("-->t_rec->qual[d1.seq].ordering_provider_id=",cnvtstring(t_rec->qual[d1.seq].ordering_provider_id)))

	t_rec->qual[d1.seq].order_mnemonic = o.order_mnemonic
	t_rec->qual[d1.seq].ordering_provider = p.name_full_formatted
	t_rec->qual[d1.seq].patient_name = p2.name_full_formatted
	t_rec->qual[d1.seq].document_title = concat(trim(o.order_mnemonic)," - ",t_rec->qual[d1.seq].sch_state)
	t_rec->qual[d1.seq].html_document = t_rec->values.html_template
	/*
	call add_html(^<html><head><body>^)
	call add_html(	build2(
							 ^<h3>^
							,^Ordering Provider: ^
							,trim(p.name_full_formatted)
							,^</h3>^
						)
					)
head od.oe_field_id
	call writeLog(build2("-->head od.oe_field_id=",cnvtstring(od.oe_field_id)))
	call writeLog(build2("-->head od.oe_field_id (d1.seq) = ",cnvtstring(d1.seq)))
	call add_html(	build2(
							 ^<b>^
							,trim(oef.label_text)
							,^: ^
							,^</b>^
							,trim(od.oe_field_display_value)
							,^<br>^
						)
					)
foot o.order_id
		call writeLog(build2("-->foot order_id=",cnvtstring(o.order_id)))
		call writeLog(build2("-->foot order_id (d1.seq) = ",cnvtstring(d1.seq)))
		call add_html(	build2(
							 ^<b>^
							,trim("Order ID")
							,^: ^
							,^</b>^
							,trim(cnvtstring(o.order_id))
							,^<br>^
						)
					)
				call add_html(	build2(
							 ^<b>^
							,trim("Scheduling ID")
							,^: ^
							,^</b>^
							,trim(cnvtstring(t_rec->qual[d1.seq].sch_event_id))
							,^<br>^
						)
					)
	call add_html(^</body></head></html>^)
	t_rec->qual[d1.seq].document_created_ind = 1
*/
foot o.order_id
	t_rec->qual[d1.seq].html_document = replace(t_rec->qual[d1.seq].html_document,"[Date]"
		,trim(format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy;;d")))
	t_rec->qual[d1.seq].html_document = replace(t_rec->qual[d1.seq].html_document,"[Patient Name]",trim(p2.name_full_formatted))
	t_rec->qual[d1.seq].html_document = replace(t_rec->qual[d1.seq].html_document,"[Date of Birth]"
		,trim(format(cnvtdatetimeutc(datetimezone(p2.birth_dt_tm,p2.birth_tz),1),'DD-MMM-YYYY;;Q')))
	t_rec->qual[d1.seq].html_document = replace(t_rec->qual[d1.seq].html_document,"[Ordering Provider]",trim(p.name_full_formatted))
	t_rec->qual[d1.seq].html_document = replace(t_rec->qual[d1.seq].html_document,"[Order Mneumonic]",trim(o.order_mnemonic))
	t_rec->qual[d1.seq].html_document = replace(t_rec->qual[d1.seq].html_document,"[Appointment Status]"
		,trim(t_rec->qual[d1.seq].sch_state))
	t_rec->qual[d1.seq].html_document = replace(t_rec->qual[d1.seq].html_document,"[Cancel Reason with Comments]"
		,trim(t_rec->qual[d1.seq].cancel_reason_comment))
	t_rec->qual[d1.seq].html_document = replace(t_rec->qual[d1.seq].html_document,"[Date/Time of Confirmed Appointments]"
		,trim(format(t_rec->qual[d1.seq].appt_dt_tm,"dd-mmm-yyyy hh:mm;;q")))
	
	t_rec->qual[d1.seq].document_created_ind = 1
		
foot report
	call writeLog(build2("<-leaving document creation"))
with nocounter


call writeLog(build2("* END   Document Creation **********************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Adding Document to Chart ***************************"))

for (i=1 to t_rec->cnt)
	if (t_rec->qual[i].document_created_ind = 1)
		set stat = initrec(document_request)
		set stat = initrec(document_reply)
		
		set document_request->service_dt_tm			= cnvtdatetime(curdate,curtime3)
		set document_request->documenttype_key 		= t_rec->values.document_key
		set document_request->personId 				= t_rec->qual[i].person_id
		set document_request->encounterId 			= t_rec->qual[i].encntr_id
		set document_request->title 				= nullterm(build2(t_rec->qual[i].document_title))
		set document_request->notetext 				= nullterm(build2(t_rec->qual[i].html_document))
		set document_request->noteformat 			= 'HTML' 
		set document_request->personnel[1]->id 		= t_rec->qual[i].ordering_provider_id
		set document_request->personnel[1]->action 	= 'PERFORM'  
		set document_request->personnel[1]->status 	= 'COMPLETED'  
		set document_request->personnel[2]->id 		= t_rec->qual[i].ordering_provider_id
		set document_request->personnel[2]->action 	= 'SIGN' 
		set document_request->personnel[2]->status 	= 'COMPLETED'  
		set document_request->personnel[3]->id 		= t_rec->qual[i].ordering_provider_id
		set document_request->personnel[3]->action 	= 'VERIFY' 
		set document_request->personnel[3]->status 	= 'COMPLETED'  

		set document_request->publishAsNote=0 
		set document_request->debug=1 
		set t_rec->qual[i].document_created_ind = 2
		
		call writeLog(build2(^execute mmf_publish_ce with replace("REQUEST", "DOCUMENT_REQUEST"), replace("REPLY", "DOCUMENT_REPLY")^))
		
		call writeLog(build2(^->mrn=^,t_rec->qual[i].mrn))
		call writeLog(build2(^->fin=^,t_rec->qual[i].fin))
		call writeLog(build2(^->person_id=^,t_rec->qual[i].person_id))
		call writeLog(build2(^->order_id=^,t_rec->qual[i].order_id))
		
		;call writeLog(build2(cnvtrectojson(document_request)))
		execute mmf_publish_ce with replace("REQUEST", "DOCUMENT_REQUEST"), replace("REPLY", "DOCUMENT_REPLY")
		
		;call writeLog(build2(cnvtrectojson(document_reply)))
		set t_rec->qual[i].event_id = document_reply->parentEventId
		set t_rec->qual[i].html_document = "" ;clelaring html document so log file isn't oversized
	endif
endfor

call writeLog(build2("* END   Adding Document to Chart ***************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit *************************************"))
	call writeAudit(build2(
							char(34),^SEQUENCE^,char(34),char(44),
							char(34),^MRN^,char(34),char(44),
							char(34),^FIN^,char(34),char(44),
							char(34),^PATIENT_NAME^,char(34),char(44),
							char(34),^FACILITY^,char(34),char(44),
							char(34),^ENCNTR_TYPE^,char(34),char(44),
							char(34),^APPT_LOCATION^,char(34),char(44),
							char(34),^SCH_STATE^,char(34),char(44),
							char(34),^ORDER_MNEMONIC^,char(34),char(44),
							char(34),^APPT_DT_TM^,char(34),char(44),
							char(34),^VALID_APPT_IND^,char(34),char(44),
							char(34),^DOCUMENT_CREATED_IND^,char(34),char(44),
							char(34),^QUALIFYING_PROGRAM^,char(34),char(44),
							char(34),^DOCUMENT_TITLE^,char(34),char(44),
							char(34),^CANCEL_REASON_COMMENT^,char(34),char(44),
							char(34),^ORDERING_PROVIDER^,char(34),char(44),
							char(34),^IS_CMG^,char(34),char(44),
							char(34),^PERSON_ID^,char(34),char(44),
							char(34),^ENCNTR_ID^,char(34),char(44),
							char(34),^ORDER_ID^,char(34),char(44),
							char(34),^SCH_EVENT_ID^,char(34),char(44),
							char(34),^ORDERING_PROVIDER_ID^,char(34),char(44),
							char(34),^EVENT_ID^,char(34)
						))
for (i=1 to t_rec->cnt)
		call writeAudit(build2(
							char(34),i,char(34),char(44),
							char(34),t_rec->qual[i].mrn											,char(34),char(44),
							char(34),t_rec->qual[i].fin											,char(34),char(44),
							char(34),t_rec->qual[i].patient_name								,char(34),char(44),
							char(34),t_rec->qual[i].encntr_facility								,char(34),char(44),
							char(34),t_rec->qual[i].encntr_type									,char(34),char(44),
							char(34),t_rec->qual[i].appt_location								,char(34),char(44),
							char(34),t_rec->qual[i].sch_state									,char(34),char(44),
							char(34),t_rec->qual[i].order_mnemonic								,char(34),char(44),
							char(34),format(t_rec->qual[i].appt_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q"),char(34),char(44),
							char(34),t_rec->qual[i].valid_appt_ind								,char(34),char(44),
							char(34),t_rec->qual[i].document_created_ind						,char(34),char(44),
							char(34),t_rec->qual[i].qualifying_program							,char(34),char(44),
							char(34),t_rec->qual[i].document_title								,char(34),char(44),
							char(34),t_rec->qual[i].cancel_reason_comment						,char(34),char(44),
							char(34),t_rec->qual[i].ordering_provider							,char(34),char(44),
							char(34),t_rec->qual[i].is_cmg										,char(34),char(44),
							char(34),t_rec->qual[i].person_id									,char(34),char(44),
							char(34),t_rec->qual[i].encntr_id									,char(34),char(44),
							char(34),t_rec->qual[i].order_id									,char(34),char(44),
							char(34),t_rec->qual[i].sch_event_id								,char(34),char(44),
							char(34),t_rec->qual[i].ordering_provider_id						,char(34),char(44),
							char(34),t_rec->qual[i].event_id									,char(34)
						))

endfor
call writeLog(build2("* END   Creating Audit *************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

;


set reply->status_data.status = "S"

#exit_script


call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
if (validate(noncmg_data->cnt))
	call echojson(noncmg_data, concat("cclscratch:",t_rec->files.records_attachment) , 1)
endif

if (validate(tat_data->list))
	call echojson(tat_data, concat("cclscratch:",t_rec->files.records_attachment) , 1)
endif

execute  cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)

call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
