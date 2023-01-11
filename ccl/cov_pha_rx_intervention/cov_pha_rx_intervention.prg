/***************************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
****************************************************************************************************
	Author:				Cerner
	Date Written:		June 2020
	Solution:			Pharmacy
	Source file name:  	cov_pha_rx_intervention.prg
	Object name:		cov_pha_rx_intervention
	CR#:				7859
 
	Program purpose:	Detail RX Clinical Interventions
	Executing from:		CCL
  	Special Notes:		Cerner Orig Pgm: pha_rx_intervention_rpt_det(ail)
 
****************************************************************************************************
* 	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #  Mod Date    Developer              Comment
*  	----------- ----------  --------------------   -------------------------------------------------
*	001			June 2020	Chad/Dan			    CR-7859  - Localized and Revised for Covenant
*	002			Oct 2020	Dan						CR 8637  - Added muliple selections for facility
*	003			Sep	2021	Dan						CR 10626 - Added functionality for scrn display or file
*
****************************************************************************************************/
 
drop program cov_pha_rx_intervention:dba GO
create program cov_pha_rx_intervention:dba
 
; cov_pha_rx_intervention "MINE",  2552503635.00, "25-JUN-2020", "26-JUN-2020" go
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Select Facility" = 0
	, "Begin Date" = "CURDATE"
	, "End Date" = "CURDATE"
	, "Output To File" = 0
 
with OUTDEV, FACILITY, BEGDATE, ENDDATE, OUTPUT_FILE
 
;set cur_facility_cd = $FACILITY
 
declare OPR_FAC_VAR = vc with noconstant(fillstring(1000," "))
 
;SET FACILITY VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY),1)= 0.0)							;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																	;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
/*************************************************************************
Configure: Qualification strings
*************************************************************************/
set powerform_qual_str = "PHARM"
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
free record time
record time
(
  1 time [*]
    2 step	= vc
    2 time	= f8
)
 
free record pf_qual
record pf_qual
(
  1 pf_qual [*]
    2 dcp_forms_ref_id    		= f8
    2 dcp_section_instance_id	= f8
)
 
free record pf_events
record pf_events
(
  1 pf_events [*]
    2 event_id	= f8
    2 order_id	= f8
)
 
free record results
record results
(
  1 results [*]
    2 forms_parent_event_id			= f8
    2 parent_event_id        		= f8
    2 event_dt_tm            		= dq8
    2 intervention_type      		= vc
    2 cov_intervention_type	 		= vc
    2 intervention_time      		= vc
    2 prsnl_id               		= f8
    2 encntr_id              		= f8
    2 order_id               		= f8
    2 monitoring_target      		= vc
    2 associated_orders      		= vc
    2 prescriber             		= vc
    2 prescriber_response    		= vc
	2 intervention_comments	        = vc
	2 antimicrobial_recommendation	= vc
	2 intervention_recommendation	= vc
	2 antimicrobial_prescribed  	= vc
    2 additional_info        		= vc
    2 order_name             		= vc
)
 
free record output
record output
(
  1 results [*]
    2 forms_parent_event_id			= f8
    2 parent_event_id        		= f8
    2 event_dt_tm            		= dq8
    2 intervention_type      		= vc
    2 cov_intervention_type	 		= vc
    2 intervention_time      		= vc
    2 prsnl_id               		= f8
    2 encntr_id              		= f8
    2 order_id               		= f8
    2 monitoring_target      		= vc
    2 associated_orders      		= vc
    2 prescriber             		= vc
    2 prescriber_response    		= vc
	2 intervention_comments	        = vc
	2 antimicrobial_recommendation	= vc
	2 intervention_recommendation	= vc
	2 antimicrobial_prescribed  	= vc
    2 additional_info        		= vc
    2 order_name             		= vc
)
 
/* Identify event codes for qualification */
set mark_time = curtime3
 
free record ec_specify
record ec_specify
(
  1 ec_specify [9]
    2 event_cd       = f8
    2 display_key    = vc
    2 label          = vc
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare get_ce_blob_by_event_id(inc_event_id = f8) = vc
declare add_time_step(inc_step_str = vc, inc_time_val = f8) = null
 
set rpt_start_dt_tm	= cnvtdatetime(concat($BEGDATE, " 00:00:01"))
set rpt_end_dt_tm 	=  cnvtdatetime(concat($ENDDATE, " 23:59:59"))
 
set cINERROR 		= uar_get_code_by ("MEANING", 8, "INERROR")
set cNOTDONE 		= uar_get_code_by ("MEANING", 8, "NOT DONE")
set cAUTH 			= uar_get_code_by ("MEANING", 8, "AUTH")
set cPRIMARYEVENT	= uar_get_code_by ("MEANING", 18189, "CLINCALEVENT")
set cORDEREVENT 	= uar_get_code_by ("MEANING", 18189, "ORDER")
set cFIN 			= uar_get_code_by ("MEANING", 319, "FIN NBR")
set cNOCOMP 		= uar_get_code_by ("MEANING", 120, "NOCOMP")
set cOCFCOMP 		= uar_get_code_by ("MEANING", 120, "OCFCOMP")
 
declare pf_event_cnt	= i4
declare pf_qual_cnt 	= i4
declare ec_spec_cnt 	= i4
 
declare result_str 		= vc
 
set ec_specify->ec_specify[1]->display_key	= "PHARMACISTINTERVENTIONTIME"
set ec_specify->ec_specify[1]->label 		= "Pharmacist Intervention Time"
 
set ec_specify->ec_specify[2]->display_key 	= "INTERVENTIONTYPEPHARMACY"
set ec_specify->ec_specify[2]->label 		= "Intervention Type Pharmacy"
 
set ec_specify->ec_specify[3]->display_key 	= "ASSOCIATEDORDERSPHARMACY"
set ec_specify->ec_specify[3]->label 		= "Associated Orders Pharmacy"
 
set ec_specify->ec_specify[4]->display_key 	= "PHARMACYADDITIONALINFORMATION"
set ec_specify->ec_specify[4]->label 		= "Pharmacy Additional Information"
 
set ec_specify->ec_specify[5]->display_key 	= "PHARMACIST"
set ec_specify->ec_specify[5]->label 		= "Pharmacist"
 
set ec_specify->ec_specify[6]->display_key 	= "INTERVENTIONCOMMENTS"
set ec_specify->ec_specify[6]->label 		= "Intervention Comments"
 
set ec_specify->ec_specify[7]->display_key 	= "ANTIMICROBIALPRESCRIBED"
set ec_specify->ec_specify[7]->label 		= "Antimicrobial Prescribed"
;
set ec_specify->ec_specify[8]->display_key 	= "INTERVENTIONRECOMMENDATION"
set ec_specify->ec_specify[8]->label 		= "Intervention Recommendation"
 
set ec_specify->ec_specify[9]->display_key 	= "ANTIMICROBIALRECOMMENDATION"
set ec_specify->ec_specify[9]->label 		= "Antimicrobial Recommendation"
 
 
/************************************************************************
 Get Code Values
*************************************************************************/
select into "nl:"
  	cv.code_value,
  	cv.display
 
from
  	(dummyt d with seq = value(size(ec_specify->ec_specify,5))),
  	code_value cv
 
plan d
join cv
  	where cv.code_set = 72
  		and cv.active_ind = 1
  		and cv.display_key = ec_specify->ec_specify[d.seq]->display_key
 
order by
  	cv.display_key
 
detail
  	ec_specify->ec_specify[d.seq]->event_cd = cv.code_value
 
with
  nullreport
 
call echorecord(ec_specify)
;GO EXIT
call add_time_step("Identify event codes for qualification", (curtime3 - mark_time)/100)
 
 
/*************************************************************************
 Identify Relevant Powerforms
*************************************************************************/
set mark_time = curtime3
 
select distinct into "nl:"
	f.dcp_forms_ref_id,
  	powerform = substring(1,50,f.definition),
  	section_desc = substring(1,50,s.description),
  	section_def = substring(1,50,s.definition)
 
from
  	dcp_forms_def d,
  	dcp_forms_ref f,
  	dcp_section_ref s
 
plan f
  	where f.dcp_forms_ref_id > 0
  		and f.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
  		and f.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  		and (
        	cnvtupper(f.description) = patstring(build("*", cnvtupper(powerform_qual_str), "*"))
        	or
        	cnvtupper(f.definition) = patstring(build("*", cnvtupper(powerform_qual_str), "*"))
      	)
 
join d
  	where d.dcp_form_instance_id = f.dcp_form_instance_id
  		and d.active_ind = 1
join s
  	where s.dcp_section_ref_id = d.dcp_section_ref_id
  		and s.active_ind = 1
  		and s.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
  		and s.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
 
order by
  	powerform,
  	f.dcp_forms_ref_id,
  	section_desc,
  	s.dcp_section_ref_id
 
head report
  	cnt = 0
 
detail
	cnt = cnt + 1
	stat = alterlist(pf_qual->pf_qual, cnt)
	pf_qual->pf_qual[cnt]->dcp_forms_ref_id = f.dcp_forms_ref_id
	pf_qual->pf_qual[cnt]->dcp_section_instance_id = s.dcp_section_instance_id
 
with
  	nullreport
 
call add_time_step("Identify relevant PowerForms", (curtime3 - mark_time)/100)
 
call echorecord(pf_qual)
 
 
/*************************************************************************
 Identify Powerform Charting Events
*************************************************************************/
set mark_time = curtime3
 
select into "nl:"
	form_dt_tm = format(fa.form_dt_tm,"@SHORTDATETIME"),
	powerform_desc = substring(1,40,ref.description),
	powerform_def = substring(1,40,ref.definition),
	fa.dcp_forms_ref_id,
	dfac.parent_entity_id,
	event_id = dfac.parent_entity_id,
	component_cd = uar_get_code_display(dfac.component_cd),
	clinical_event_id = dfac.parent_entity_id,
	order_id = dfac2.parent_entity_id
 
from
  	dcp_forms_activity fa,
  	encounter e,
  	dcp_forms_ref ref,
  	dcp_forms_activity_comp dfac,
  	dcp_forms_activity_comp dfac2
 
plan fa
  	where fa.form_dt_tm >= cnvtdatetime(rpt_start_dt_tm)
  		and fa.form_dt_tm <= cnvtdatetime(rpt_end_dt_tm)
join e
  	where e.encntr_id = fa.encntr_id
;  		and e.loc_facility_cd = cur_facility_cd
		and operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY)
join ref
  	where ref.dcp_forms_ref_id = fa.dcp_forms_ref_id
  		and fa.version_dt_tm >= ref.beg_effective_dt_tm
  		and fa.version_dt_tm < ref.end_effective_dt_tm
  		and expand (pf_qual_cnt, 1, size(pf_qual->pf_qual,5), ref.dcp_forms_ref_id, pf_qual->pf_qual[pf_qual_cnt]->dcp_forms_ref_id)
join dfac
  	where dfac.dcp_forms_activity_id = fa.dcp_forms_activity_id
  		and dfac.component_cd = cPRIMARYEVENT
join dfac2
  	where dfac2.dcp_forms_activity_id = outerjoin(fa.dcp_forms_activity_id)
  		and dfac2.component_cd = outerjoin(cORDEREVENT)
 
order by
  	fa.form_dt_tm,
  	event_id
 
head report
  	cnt = 0
 
detail
  	if (fa.active_ind = 1)
    	cnt = cnt + 1
    	stat = alterlist(pf_events->pf_events, cnt)
    	pf_events->pf_events[cnt]->event_id = dfac.parent_entity_id
    	pf_events->pf_events[cnt]->order_id = dfac2.parent_entity_id
  	endif
 
with nullreport
 
call echo(".")
call echo("---------------------------------------------------------------")
call echo(concat("PowerForm charting events found: ", build(size(pf_events->pf_events,5))))
call echo("---------------------------------------------------------------")
 
call add_time_step("Identify PowerForm charting events", (curtime3 - mark_time)/100)
 
 
/*************************************************************************
 Identify Clinical Events related to PowerForm documentation
*************************************************************************/
set mark_time = curtime3
 
declare intervention_type_str = vc
declare intervention_time = vc
 
for (event_loop = 1 to size(pf_events->pf_events,5))
 
	call echo(".")
	call echo("---------------------------------------------------------------")
	call echo(concat("Processing event: ", build(event_loop), " / ", build(size(pf_events->pf_events,5))))
	call echo("---------------------------------------------------------------")
 
	select into "nl:"
		event_end_dt_tm = format(ce.event_end_dt_tm,"@SHORTDATETIME"),
		ce4_event_title = substring(1,40,ce4.event_title_text),
		ce4_result = ce4.result_val,
		ce4.clinical_event_id,
		ce4.event_id,
		ce4.parent_event_id,
		ce2_log_blob_id = lb2.long_blob_id,
		ce4_log_blob_id = lb4.long_blob_id
 
	from
		clinical_event ce,
		clinical_event ce2,
		clinical_event ce3,
		clinical_event ce4,
		code_value cv,
		ce_event_note cen2,
		ce_event_note cen4,
		long_blob lb2,
		long_blob lb4
 
  	plan ce
    	where (ce.event_id = pf_events->pf_events[event_loop]->event_id
            or
            ce.parent_event_id = pf_events->pf_events[event_loop]->event_id)
    		and ce.result_status_cd = cAUTH
  	join ce2
    	where ce2.parent_event_id = ce.event_id
    		and ce2.result_status_cd = cAUTH
  	join ce3
    	where ce3.parent_event_id = ce2.event_id
    		and ce3.result_status_cd = cAUTH
  	join ce4
    	where ce4.parent_event_id = ce3.event_id
    		and ce4.view_level = 1
    		and ce4.event_cd > 0
    		and cnvtdatetime(curdate,curtime3) between ce4.valid_from_dt_tm and ce4.valid_until_dt_tm
    		and expand (ec_spec_cnt, 1, size(ec_specify->ec_specify,5), ce4.event_cd, ec_specify->ec_specify[ec_spec_cnt]->event_cd)
  	join cv
    	where cv.code_value = ce4.event_cd
  	join cen2
    	where cen2.event_id = outerjoin(ce2.event_id)
  	join lb2
    	where lb2.parent_entity_id = outerjoin(cen2.ce_event_note_id)
    		and lb2.parent_entity_name = outerjoin("CE_EVENT_NOTE")
  	join cen4
    	where cen4.event_id = outerjoin(ce4.event_id)
  	join lb4
    	where lb4.parent_entity_id = outerjoin(cen4.ce_event_note_id)
    		and lb4.parent_entity_name = outerjoin("CE_EVENT_NOTE")
  	order by
    	ce.event_end_dt_tm desc,
    	;ce.parent_event_id, ;001
    	ce.event_id desc,
    	ce2.event_id,
    	ce3.event_id,
    	ce4.event_id,
    	ce4.clinical_event_id desc
 
  	head report
    	result_cnt = size(results->results,5)
 
  	head ce4.parent_event_id
    	event_add_flag = false
    	intervention_type_str = ""
;		intervention_time = 0
 
  	head ce4.event_id
    	if (ce4.result_status_cd not in (cINERROR,cNOTDONE))
 
			event_add_flag = true
 
      		if (ce4.event_cd = ec_specify->ec_specify[1]->event_cd)  ;Pharmacist Intervention Time
        		intervention_time  = trim(ec_specify->ec_specify[1]->label)
      		;endif
 
      		elseif (ce4.event_cd = ec_specify->ec_specify[2]->event_cd)  ;Intervention Type Pharmacy
        		intervention_type_str = trim(ec_specify->ec_specify[2]->label)
 
 			;endif
      	 	elseif (ce4.event_cd = ec_specify->ec_specify[3]->event_cd)  ;Associated Orders Pharmacy
        		intervention_type_str = trim(ec_specify->ec_specify[3]->label)
 
      		elseif (ce4.event_cd = ec_specify->ec_specify[4]->event_cd)  ;Pharmacy Additional Information
        		intervention_type_str = trim(ec_specify->ec_specify[4]->label)
 
      		elseif (ce4.event_cd = ec_specify->ec_specify[5]->event_cd)  ;Pharmacist
        		intervention_type_str = trim(ec_specify->ec_specify[5]->label)
 
      		elseif (ce4.event_cd = ec_specify->ec_specify[6]->event_cd)  ;Intervention Comments
        		intervention_type_str = trim(ec_specify->ec_specify[6]->label)
 
      		elseif (ce4.event_cd = ec_specify->ec_specify[7]->event_cd)  ;Antimicrobial Prescribed
        		intervention_type_str = trim(ec_specify->ec_specify[7]->label)
 
      		elseif (ce4.event_cd = ec_specify->ec_specify[8]->event_cd)  ;Intervention Recommendation
        		intervention_type_str = trim(ec_specify->ec_specify[8]->label)
 
      		elseif (ce4.event_cd = ec_specify->ec_specify[9]->event_cd)  ;Antimicrobial Recommendation
        		intervention_type_str = trim(ec_specify->ec_specify[9]->label)
 
      		endif
 
	    endif
 
  	foot ce4.parent_event_id
 
    if (event_add_flag = true and intervention_type_str != ""); and intervention_time > 0)
 
;	if (cnvtupper(intervention_type_str) = patstring(cnvtupper(build("*", $INTERVENTIONTYPE, "*"))))
;	if (intervention_type_str in ($INTERVENTIONTYPE))
  	    result_cnt = result_cnt + 1
  	    stat = alterlist(results->results, result_cnt)
  	    results->results[result_cnt]->intervention_type	= trim(intervention_type_str)
  	    results->results[result_cnt]->intervention_time = intervention_time
  	    results->results[result_cnt]->parent_event_id 	= ce4.parent_event_id
  	    results->results[result_cnt]->prsnl_id 			= ce4.performed_prsnl_id
  	    results->results[result_cnt]->order_id 			= ce4.order_id
  	    results->results[result_cnt]->encntr_id 		= ce4.encntr_id
  	    results->results[result_cnt]->event_dt_tm 		= ce4.event_end_dt_tm
  	    results->results[result_cnt]->forms_parent_event_id	= ce.parent_event_id
 
 
;	endif
 
    endif
  	with nullreport
 
;	call echorecord(results)
 
endfor
 
free record pf_events
 
call echo(".")
call echo("---------------------------------------------------------------")
call echo(concat("Results found: ", build(size(results->results,5))))
call echo("---------------------------------------------------------------")
 
call add_time_step("Identify clinical events related to PowerForm documentation", (curtime3 - mark_time)/100)
 
 
/*************************************************************************
 Get Monitoring Target value, initiated by current documentation
*************************************************************************/
set mark_time = curtime3
 
if (size(results->results,5) > 0)
 
	select into "nl:"
  	from
    	(dummyt d with seq = value(size(results->results,5))),
    	clinical_event ce,
    	code_value cv
 
  	plan d
  	join ce
    	where ce.parent_event_id = results->results[d.seq]->parent_event_id
  	join cv
    	where cv.code_value = ce.event_cd
    		and cv.display_key = "PHARM*TARGET*"
 
  	detail
     	results->results[d.seq]->monitoring_target = trim(ce.result_val)
 
  	with nullreport
 
endif
 
 
/*************************************************************************
 Get Monitoring Target value, against ongoing order
*************************************************************************/
if (size(results->results,5) > 0)
 
  	select into "nl:"
  	from
    	(dummyt d with seq = value(size(results->results,5))),
    	orders o,
    	order_detail od,
    	order_entry_fields oef
 
  	plan d
  	join o
    	where o.order_id = results->results[d.seq]->order_id
  	join od
    	where od.order_id = o.order_id
    		and o.last_action_sequence = od.action_sequence
  	join oef
    	where oef.oe_field_id = od.oe_field_id
    		and cnvtupper(oef.description) = "PHARM*TARGET*"
 
  	detail
     	results->results[d.seq]->monitoring_target = trim(od.oe_field_display_value)
 
  	with nullreport
 
endif
 
 
/*************************************************************************
 Get Intervention Type Pharmacy
*************************************************************************/
if (size(results->results,5) > 0)
 
  	select into "nl:"
  	from
    	(dummyt d with seq = value(size(results->results,5))),
    	clinical_event ce,
    	code_value cv
 
  	plan d
  	join ce
    	where ce.parent_event_id = results->results[d.seq]->parent_event_id
  	join cv
    	where cv.code_value = ce.event_cd
    		and cv.display_key = "INTERVENTIONTYPEPHARMACY"
 
  	detail
     	results->results[d.seq]->cov_intervention_type = trim(ce.result_val)
 
  	with nullreport
 
endif
 
 
/*************************************************************************
 Get Associated Orders values
*************************************************************************/
if (size(results->results,5) > 0)
 
  	select into "nl:"
  	from
    	(dummyt d with seq = value(size(results->results,5))),
    	clinical_event ce,
    	code_value cv
 
  	plan d
  	join ce
    	where ce.parent_event_id = results->results[d.seq]->parent_event_id
  	join cv
    	where cv.code_value = ce.event_cd
    		and cv.display_key = "ASSOCIATEDORDERSPHARMACY"
 
  	detail
     	results->results[d.seq]->associated_orders = trim(ce.result_val)
 
  	with nullreport
 
endif
 
 
/*************************************************************************
 Get Additional Information / Action values
*************************************************************************/
declare cur_event_id = f8
 
for (add_info_loop = 1 to size(results->results,5))
 
  	set cur_event_id = 0
 
  	select into "nl:"
  	from
    	clinical_event ce,
    	code_value cv
 
  	plan ce
    	where ce.parent_event_id = results->results[add_info_loop]->parent_event_id
  	join cv
    	where cv.code_value = ce.event_cd
    		and cv.display_key = "PHARMACYADDITIONALINFORMATION"
 
  	detail
    	results->results[add_info_loop]->additional_info = trim(ce.result_val)
 
  	with nullreport
 
endfor
 
 
;/*************************************************************************
; Get Antimicrobial Prescribed
;*************************************************************************/
if (size(results->results,5) > 0)
 
  	select into "nl:"
  	from
    	(dummyt d with seq = value(size(results->results,5))),
    	clinical_event ce,
    	code_value cv
 
  	plan d
  	join ce
    	where ce.parent_event_id = results->results[d.seq]->parent_event_id
  	join cv
    	where cv.code_value = ce.event_cd
    		and cv.display_key = "ANTIMICROBIALPRESCRIBED"
 
  	detail
     	results->results[d.seq]->antimicrobial_prescribed = trim(ce.result_val)
 
  	with nullreport
 
endif
 
 
;/*************************************************************************
; Get Intervention Recommendation
;*************************************************************************/
if (size(results->results,5) > 0)
 
  	select into "nl:"
  	from
    	(dummyt d with seq = value(size(results->results,5))),
    	clinical_event ce,
    	code_value cv
 
  	plan d
  	join ce
    	where ce.parent_event_id = results->results[d.seq]->parent_event_id
  	join cv
    	where cv.code_value = ce.event_cd
    		and cv.display_key = "INTERVENTIONRECOMMENDATION"
 
  	detail
     	results->results[d.seq]->intervention_recommendation = trim(ce.result_val)
 
  	with nullreport
 
endif
 
 
;/*************************************************************************
; Get Antimicrobial Recommendation
;*************************************************************************/
if (size(results->results,5) > 0)
 
  	select into "nl:"
  	from
    	(dummyt d with seq = value(size(results->results,5))),
    	clinical_event ce,
    	code_value cv
 
  	plan d
  	join ce
    	where ce.parent_event_id = results->results[d.seq]->parent_event_id
  	join cv
    	where cv.code_value = ce.event_cd
    		and cv.display_key = "ANTIMICROBIALRECOMMENDATION"
 
  	detail
     	results->results[d.seq]->antimicrobial_recommendation = trim(ce.result_val)
 
  	with nullreport
 
endif
 
 
;/*************************************************************************
; Get Intervention Comments
;*************************************************************************/
if (size(results->results,5) > 0)
 
  	select into "nl:"
  	from
    	(dummyt d with seq = value(size(results->results,5))),
    	clinical_event ce,
    	code_value cv
 
  	plan d
  	join ce
    	where ce.parent_event_id = results->results[d.seq]->parent_event_id
  	join cv
    	where cv.code_value = ce.event_cd
    		and cv.display_key = "INTERVENTIONCOMMENTS"
 
  	detail
     	results->results[d.seq]->intervention_comments = trim(ce.result_val)
 
  	with nullreport
 
endif
 
 
/*************************************************************************
 Get Prescriber values
*************************************************************************/
 
if (size(results->results,5) > 0)
 
  	select into "nl:"
  	from
    	(dummyt d with seq = value(size(results->results,5))),
    	clinical_event ce,
    	code_value cv
 
  	plan d
  	join ce
    	where ce.parent_event_id = results->results[d.seq]->parent_event_id
  	join cv
    	where cv.code_value = ce.event_cd
;    	and cv.display_key = "PHARMACYPRESCRIBINGPHYSICIAN"
    	and cv.display_key = "PRESCRIBER"
 
  	detail
     	results->results[d.seq]->prescriber = trim(ce.result_val)
 
  	with nullreport
 
endif
 
 
/*************************************************************************
 Get Prescriber Response values
*************************************************************************/
if (size(results->results,5) > 0)
 
  	select into "nl:"
  	from
    	(dummyt d with seq = value(size(results->results,5))),
    	clinical_event ce,
		code_value cv
 
  	plan d
  	join ce
    	where ce.parent_event_id = results->results[d.seq]->parent_event_id
  	join cv
    	where cv.code_value = ce.event_cd
    		and cv.display_key = "PRESCRIBERRESPONSEPHARMACY"
 
  	detail
    	results->results[d.seq]->prescriber_response = trim(ce.result_val)
 
  	with nullreport
 
endif
 
 
/*************************************************************************
 Get Order Name values
*************************************************************************/
if (size(results->results,5) > 0)
 
  	select into "nl:"
  	from
    	(dummyt d with seq = value(size(results->results,5))),
    	orders o
 
  	plan d
  	join o
    	where o.order_id = results->results[d.seq]->order_id
 
  	detail
    	results->results[d.seq]->order_name =
      		if (o.iv_ind = 1)
          		if (trim(o.ordered_as_mnemonic) > " ")
            		trim(o.ordered_as_mnemonic)
          		else
            		trim(o.hna_order_mnemonic)
          		endif
        	else
          		if (trim(o.ordered_as_mnemonic) > " " and trim(o.ordered_as_mnemonic)!=trim(o.hna_order_mnemonic))
            		concat(trim(o.hna_order_mnemonic)," (", trim(o.ordered_as_mnemonic),")")
          		else
            		trim(o.hna_order_mnemonic)
          		endif
        	endif
 
  	with nullreport
 
endif
 
call add_time_step("Get additional documentation information", (curtime3 - mark_time)/100)
 
 
/*************************************************************************
 Strip carriage returns from results
*************************************************************************/
for (result_loop = 1 to size(results->results,5))
	;check() try this function to remove the special characters
  	set results->results[result_loop]->intervention_type =
		replace (results->results[result_loop]->intervention_type, char(13), " ", 0)
 
  	set results->results[result_loop]->intervention_type =
		replace (results->results[result_loop]->intervention_type, char(10), " ", 0)
 
  	set results->results[result_loop]->order_name =
		replace (results->results[result_loop]->order_name, char(13), " ", 0)
 
  	set results->results[result_loop]->order_name =
		replace (results->results[result_loop]->order_name, char(10), " ", 0)
 
  	set results->results[result_loop]->associated_orders =
		replace (results->results[result_loop]->associated_orders, char(13), " ", 0)
 
  	set results->results[result_loop]->associated_orders =
		replace (results->results[result_loop]->associated_orders, char(10), " ", 0)
 
  	set results->results[result_loop]->monitoring_target =
		replace (results->results[result_loop]->monitoring_target, char(13), " ", 0)
 
  	set results->results[result_loop]->monitoring_target =
		replace (results->results[result_loop]->monitoring_target, char(10), " ", 0)
 
  	set results->results[result_loop]->additional_info =
		replace (results->results[result_loop]->additional_info, char(13), " ", 0)
 
  	set results->results[result_loop]->additional_info =
		replace (results->results[result_loop]->additional_info, char(10), " ", 0)
 
  	set results->results[result_loop]->intervention_comments =
		replace (results->results[result_loop]->intervention_comments, char(13), " ", 0)
 
  	set results->results[result_loop]->intervention_comments =
		replace (results->results[result_loop]->intervention_comments, char(10), " ", 0)
 
  	set results->results[result_loop]->prescriber_response =
		replace (results->results[result_loop]->prescriber_response, char(13), " ", 0)
 
  	set results->results[result_loop]->prescriber_response =
		replace (results->results[result_loop]->prescriber_response, char(10), " ", 0)
 
endfor
 
/*************************************************************************
 CREATE FINAL OUTPUT
*************************************************************************/
select into "nl:"
	form_event_id = results->results[d1.seq]->forms_parent_event_id
 
from
	(dummyt d1 with seq=size(results->results,5))
 
plan d1
 
order by
	form_event_id
 
head report
	call echo("CREATE FINAL OUTPUT")
	cnt = 0
 
head form_event_id
	cnt = (cnt + 1)
	stat = alterlist(output->results,cnt)
 
detail
	output->results[cnt].forms_parent_event_id			= results->results[d1.seq].forms_parent_event_id
	output->results[cnt].parent_event_id        		= results->results[d1.seq].parent_event_id
	output->results[cnt].event_dt_tm            		= results->results[d1.seq].event_dt_tm
	output->results[cnt].prsnl_id               		= results->results[d1.seq].prsnl_id
	output->results[cnt].encntr_id              		= results->results[d1.seq].encntr_id
	output->results[cnt].order_id               		= results->results[d1.seq].order_id
 
	if (output->results[cnt].intervention_type = " ")
		output->results[cnt].intervention_type      		= results->results[d1.seq].intervention_type
	endif
 
	if (output->results[cnt].cov_intervention_type = " ")
	output->results[cnt].cov_intervention_type	 		= results->results[d1.seq].cov_intervention_type
	endif
 
	if (output->results[cnt].intervention_time = " ")
	output->results[cnt].intervention_time      		= results->results[d1.seq].intervention_time
	endif
 
	if (output->results[cnt].monitoring_target = " ")
	output->results[cnt].monitoring_target      		= results->results[d1.seq].monitoring_target
	endif
 
	if (output->results[cnt].associated_orders  = " ")
	output->results[cnt].associated_orders      		= results->results[d1.seq].associated_orders
	endif
 
	if (output->results[cnt].prescriber = " ")
	output->results[cnt].prescriber             		= results->results[d1.seq].prescriber
	endif
 
	if (output->results[cnt].prescriber_response  = " ")
	output->results[cnt].prescriber_response    		= results->results[d1.seq].prescriber_response
	endif
 
	if (output->results[cnt].intervention_comments = " ")
	output->results[cnt].intervention_comments	        = results->results[d1.seq].intervention_comments
	endif
 
	if (output->results[cnt].antimicrobial_recommendation = " ")
	output->results[cnt].antimicrobial_recommendation	= results->results[d1.seq].antimicrobial_recommendation
	endif
 
	if (output->results[cnt].intervention_recommendation = " ")
	output->results[cnt].intervention_recommendation	= results->results[d1.seq].intervention_recommendation
	endif
 
	if (output->results[cnt].antimicrobial_prescribed = " ")
	output->results[cnt].antimicrobial_prescribed  	    = results->results[d1.seq].antimicrobial_prescribed
	endif
 
	if (output->results[cnt].additional_info = " ")
	output->results[cnt].additional_info        		= results->results[d1.seq].additional_info
	endif
 
	if (output->results[cnt].order_name = " ")
	output->results[cnt].order_name             		= results->results[d1.seq].order_name
	endif
 
foot form_event_id
	row +0
foot report
	call echo(build("results=",size(results->results,5)))
	call echo(build("output=",size(output->results,5)))
with nocounter
 
 
/*************************************************************************
 DISPLAY REPORT OUTPUT
*************************************************************************/
 
call echorecord(results)
call echorecord(output)
 
if (size(output->results,5) > 0)
 
  	select
 
; begin 003
		if ($OUTPUT_FILE = 1)
			with outerjoin = d2, outerjoin = d4, nocounter, pcformat (^"^, ^,^, 1,0), format, format=stream, formfeed=none  ;no padding
		else
			with outerjoin = d2, outerjoin = d4, nocounter, separator = " ", format
		endif
; end 003
 
	into $OUTDEV
		 facility						= uar_get_code_display(e.loc_facility_cd)
     	,patient 						= p.name_full_formatted
    	,fin_nbr 						= ea.alias
     	;intervention_type 				= substring(1,50,output->results[d.seq]->intervention_type)
     	,intervention_type 				= substring(1,255,output->results[d.seq]->cov_intervention_type)
     	,activity_dt_tm 				= format(output->results[d.seq]->event_dt_tm,"@SHORTDATETIME")
;    	,time 							= output->results[d.seq]->intervention_time
    	,order_name 					= substring(1,100,output->results[d.seq]->order_name)
    	,associated_orders 				= substring(1,255,output->results[d.seq]->associated_orders)
;		,monitoring_target 				= substring(1,100,output->results[d.seq]->monitoring_target)
    	,additional_information 		= substring(1,255,output->results[d.seq]->additional_info)
		,antimicrobial_prescribed		= substring(1,50,output->results[d.seq]->antimicrobial_prescribed)
		,intervention_recommendation	= substring(1,50,output->results[d.seq]->intervention_recommendation)
		,antimicrobial_recommendation	= substring(1,50,output->results[d.seq]->antimicrobial_recommendation)
		,intervention_comments			= substring(1,255,output->results[d.seq]->intervention_comments)
    	,prescriber 					= substring(1,50,output->results[d.seq]->prescriber)
    	,prescriber_response 			= substring(1,50,output->results[d.seq]->prescriber_response)
		,user 							= pr.name_full_formatted
;		,parent_event_id 				= output->results[d.seq]->forms_parent_event_id
 
  	from
    	(dummyt d with seq = value(size(output->results,5))),
    	encounter e,
    	person p,
    	prsnl pr,
    	dummyt d2,
    	encntr_alias ea
 
  	plan d
  	join e
    	where e.encntr_id = output->results[d.seq]->encntr_id
  	join p
    	where p.person_id = e.person_id
  	join pr
    	where pr.person_id = output->results[d.seq]->prsnl_id
  	join d2
  	join ea
    	where ea.encntr_id = e.encntr_id
    		and ea.encntr_alias_type_cd = cFIN
    		and ea.active_ind = 1
 
  	order by
		facility,
		p.name_full_formatted,
    	output->results[d.seq]->event_dt_tm,
    	output->results[d.seq]->intervention_type,
		output->results[d.seq]->forms_parent_event_id
 
;003
;  	with
;    	outerjoin = d2,
;    	outerjoin = d4,
;    	nocounter,
;    	separator = " " ,
;    	format
;003
 
endif
 
/*************************************************************************
 Subroutines
*************************************************************************/
subroutine get_ce_blob_by_event_id(inc_event_id)
 
  	declare return_str = c32000
  	declare blob_str = c32000
 
  	declare outblob = c32000
  	declare result_comments2= c32000
  	declare lout = i4
  	declare stat = i4
  	declare bsize = i4
 
  	if (inc_event_id > 0)
 
		select into "nl:"
      		c.event_id,
      		c.blob_length,
      		uncomp = UAR_OCF_UNCOMPRESS(C.BLOB_CONTENTS, blobgetlen(C.BLOB_CONTENTS),outblob,size(outblob),0),
      		uarstat =  assign( stat, uar_rtf2
                         ( outblob,
                           textlen(outblob),
                           result_comments2,
                           size(result_comments2),
                           lout,
                           1) ),
      		coms = replace(replace(trim(substring(1,lout,result_comments2),3),char(10),""),char(13),"")
    	from
      		ce_blob c
 
    	plan c
      		where c.event_id = inc_event_id
      			and c.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
      			and c.compression_cd = cOCFCOMP
 
    	detail
      		blob_str = trim(coms)
 
    	with nullreport
 
    	select into "nl:"
    	from
      		ce_blob c
 
    	plan c
      		where c.event_id = inc_event_id
      			and c.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
      			and c.compression_cd = cNOCOMP
 
    	detail
      		blob_str = trim(c.blob_contents)
 
    	with nullreport
 
    	set blob_str = trim(replace(blob_str,"ocf_blob","",0))
    	call uar_rtf2(blob_str,size(blob_str),return_str,size(return_str),bsize,0)
 
    	if (textlen(return_str) > 0)
      		set return_str = trim(return_str)
    	else
      		set return_str = trim(blob_str)
    	endif
 
    	if (bsize = 0)
      		set return_str = blob_str
    	endif
 
  	endif
 
  	return(return_str)
 
end ; subroutine
 
 
subroutine add_time_step(inc_step_str, inc_time_val)
 
  	set array_size = size(time->time, 5)
  	set array_size = array_size + 1
  	set stat = alterlist(time->time, array_size)
 
  	set time->time[array_size]->step = inc_step_str
  	set time->time[array_size]->time = inc_time_val
 
end ; subroutine
 
;exit
end
go
