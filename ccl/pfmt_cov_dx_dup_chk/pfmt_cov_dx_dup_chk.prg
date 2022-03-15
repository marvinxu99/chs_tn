/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       01/28/2020
  Solution:           
  Source file name:   pfmt_cov_dx_dup_chk.prg
  Object name:        pfmt_cov_dx_dup_chk
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   01/28/2020  Chad Cummings			Initial Release
******************************************************************************/
drop program pfmt_cov_dx_dup_chk:dba go
create program pfmt_cov_dx_dup_chk:dba

free record t_rec
record t_rec
(
	1 log_file_a			= vc
	1 log_file_b			= vc
	1 log_comments			= vc
	1 keep_mode_ind			= i2	;0 = keep original, 1 = keep incoming
	1 request_number		= i4
	1 commit_mode			= i2	;0 = do not commit, 1 = commit changes
	1 debug_mode			= i2	;0 = off, 1 = on
	1 person_id				= f8
	1 encntr_id				= f8
	1 incoming_dx_cnt		= i2
	1 incoming_dx_qual[*]
	 2 diagnosis_id					= f8
	 2 originating_nomenclature_id 	= f8
	1 dx_cnt						= i2
	1 dx_qual[*]
		2 diagnosis_id					= f8
		2 diagnosis_group				= f8
		2 originating_nomenclature_id	= f8
	 	2 resolve_ind					= i2 ; 1 = script will resolve this dx
	1 code_values
	 2 48_combined_cd					= f8
)

free set 4170155Request
record 4170155Request (
  1 item [*]   
    2 action_ind = i2   
    2 diagnosis_id = f8   
    2 diagnosis_group = f8   
    2 encntr_id = f8   
    2 person_id = f8   
    2 nomenclature_id = f8   
    2 concept_cki = vc  
    2 diag_ft_desc = vc  
    2 diagnosis_display = vc  
    2 conditional_qual_cd = f8   
    2 confirmation_status_cd = f8   
    2 diag_dt_tm = dq8   
    2 classification_cd = f8   
    2 clinical_service_cd = f8   
    2 diag_type_cd = f8   
    2 ranking_cd = f8   
    2 severity_cd = f8   
    2 severity_ftdesc = vc  
    2 severity_class_cd = f8   
    2 certainty_cd = f8   
    2 probability = i4   
    2 long_blob_id = f8   
    2 comment = vc  
    2 active_ind = i2   
    2 diag_prsnl_id = f8   
    2 diag_prsnl_name = vc  
    2 diag_priority = i4   
    2 clinical_diag_priority = i4   
    2 secondary_desc_list [*]   
      3 group_sequence = i4   
      3 group [*]   
        4 secondary_desc_id = f8   
        4 nomenclature_id = f8   
        4 sequence = i4   
    2 related_dx_list [*]   
      3 active_ind = i2   
      3 child_entity_id = f8   
      3 reltn_subtype_cd = f8   
      3 priority = i4   
      3 child_dx_type_cd = f8   
      3 child_clin_srv_cd = f8   
      3 child_nomen_id = f8   
      3 child_ft_desc = vc  
    2 related_proc_list [*]   
      3 active_ind = i2   
      3 procedure_id = f8   
      3 reltn_subtype_cd = f8   
      3 priority = i4   
    2 laterality_cd = f8   
    2 originating_nomenclature_id = f8   
    2 updt_trans_nomen_ind = i2   
    2 trans_nomen_id = f8   
  1 user_id = f8   
) 

free set 4170155Reply
record 4170155Reply
(
  1 error_string      = vc
  1 item[*]
    2 diagnosis_id    = f8
    2 diagnosis_group = f8
    2 review_dt_tm    = dq8
    2 beg_effective_dt_tm = dq8
%i cclsource:status_block.inc
)

set t_rec->debug_mode 		= 1
set t_rec->request_number 	= reqinfo->updt_req
set t_rec->keep_mode_ind	= 0
set t_rec->commit_mode		= 0
set t_rec->log_file_a		= concat("cclscratch:",trim(cnvtlower(curprog)),"_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->log_file_b		= concat("cclscratch:dx_",trim(cnvtstring(reqinfo->updt_req))
										,"_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->code_values.48_combined_cd	= value(uar_get_code_by("MEANING",48,"COMBINED"))

select into "nl:"
from
	code_value_set cvs
	,code_value cv
plan cvs
	where cvs.definition = "COVCUSTOM"
join cv
	where cv.code_set = cvs.code_set
	and   cv.definition = trim(cnvtlower(curprog))
	and   cv.active_ind = 1
	and   cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)	
order by
	cv.cdf_meaning
	,cv.begin_effective_dt_tm desc
head cv.cdf_meaning	
	case (cv.cdf_meaning)
		of "KEEP_IND":		t_rec->keep_mode_ind = cnvtint(cv.description)
							t_rec->log_comments = concat(t_rec->log_comments,";","found keep_ind=",trim(cv.description))
		of "ACTIVE_IND":	t_rec->commit_mode = cnvtint(cv.description)
							t_rec->log_comments = concat(t_rec->log_comments,";","found active_ind=",trim(cv.description))
	endcase
with nocounter

if (t_rec->request_number = 4170155)		;4170155 - kia_ens_clin_dx
	if (size(requestin->reply->item,5) > 0)
		for (i=1 to size(requestin->reply->item,5))
			if (requestin->request->item[i].action_ind = 1)
				set t_rec->incoming_dx_cnt = (t_rec->incoming_dx_cnt + 1)
				set stat = alterlist(t_rec->incoming_dx_qual,t_rec->incoming_dx_cnt)
				set t_rec->incoming_dx_qual[i].diagnosis_id = requestin->reply->item[i].diagnosis_id
				set t_rec->incoming_dx_qual[i].originating_nomenclature_id = requestin->request->item[i].originating_nomenclature_id
				set t_rec->person_id = requestin->request->item[i].person_id
				set t_rec->encntr_id = requestin->request->item[i].encntr_id				
			endif
		endfor
	endif
elseif (t_rec->request_number = 3091009)	;3091009 - eks_condition_dummy
	set stat = 1
elseif (t_rec->request_number = 3091006)	;3091006 - eks_add_condition_dummy
	set t_rec->log_comments = concat(t_rec->log_comments,";","inside 3091006")
	if (size(requestin->conditions,5) > 0)
		set t_rec->log_comments = concat(t_rec->log_comments,";","requestin->conditions > 0")
		for (i=1 to size(requestin->conditions,5))
			set t_rec->log_comments = concat(t_rec->log_comments,";","inside conditions loop:",trim(cnvtstring(i)))
			if (validate(requestin->conditions[i]->diagnoses[1].diagnosis_id))
				set t_rec->log_comments = concat(t_rec->log_comments,";","inside requestin->conditions[i]->diagnoses[1].diagnosis_id")
				set t_rec->incoming_dx_cnt = (t_rec->incoming_dx_cnt + 1)
				set stat = alterlist(t_rec->incoming_dx_qual,t_rec->incoming_dx_cnt)
				set t_rec->incoming_dx_qual[i].diagnosis_id = requestin->conditions[i]->diagnoses[1].diagnosis_id
				set t_rec->incoming_dx_qual[i].originating_nomenclature_id = requestin->conditions[i].originating_nomen_id
				set t_rec->person_id = requestin->person_id
				set t_rec->encntr_id = requestin->conditions[i]->diagnoses[1].encounter_id
			endif
		endfor
	endif
elseif (t_rec->request_number = 3091007)	;3091007 - eks_modify_condition_dummy
	set stat = 1
elseif (t_rec->request_number = 965215)		;965215 - pm_add_diagnosis
	set stat = 1
elseif (t_rec->request_number = 965230)		;965230 - pm_upt_diagnosis
	set stat = 1
elseif (t_rec->request_number = 965232)		;965232 - pm_rmv_diagnosis
	set stat = 1
endif

if (t_rec->incoming_dx_cnt <= 0)
	go to exit_script
endif

#process_dx
for (i=1 to t_rec->incoming_dx_cnt)
	select into "nl:"
	from
		diagnosis d
	plan d
		where d.encntr_id	= t_rec->encntr_id
		and   d.person_id	= t_rec->person_id
		and   d.active_ind	= 1
		and	  d.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
		and	  d.active_status_cd	in(
										value(uar_get_code_by("MEANING",48,"ACTIVE"))
									)
		and   d.originating_nomenclature_id = t_rec->incoming_dx_qual[i].originating_nomenclature_id
	order by
		d.beg_effective_dt_tm
		,d.diagnosis_id
	head report
		cnt = 0
		keep_found = 0
	head d.diagnosis_id
		cnt = (cnt + 1)
		stat = alterlist(t_rec->dx_qual,cnt)
		t_rec->dx_qual[cnt].diagnosis_id = d.diagnosis_id
		t_rec->dx_qual[cnt].originating_nomenclature_id = d.originating_nomenclature_id
		t_rec->dx_qual[cnt].diagnosis_group = d.diagnosis_group
		
		if (t_rec->incoming_dx_qual[i].diagnosis_id = d.diagnosis_id)
			if (t_rec->keep_mode_ind = 0)
				t_rec->dx_qual[cnt].resolve_ind = 1
			endif
		else
			if (t_rec->keep_mode_ind = 1)
				t_rec->dx_qual[cnt].resolve_ind = 1
			else 
				if (keep_found = 0)
					keep_found = 1
				else
					t_rec->dx_qual[cnt].resolve_ind = 1
				endif
			endif
		endif
	foot report
		if ((cnt = 1) and (t_rec->incoming_dx_qual[i].diagnosis_id = d.diagnosis_id))
			t_rec->dx_cnt = 0
		else
			t_rec->dx_cnt = cnt
		endif
		
	with nocounter
endfor

if (t_rec->dx_cnt > 0)
	for (j=1 to t_rec->dx_cnt)
		if (t_rec->dx_qual[j].resolve_ind = 1)
			set stat = initrec(4170155Request)
			set stat = initrec(4170155Reply)
			
			set stat = alterlist(4170155Request->item,1)
			set 4170155Request->item[1].action_ind = 3
			set 4170155Request->item[1].diagnosis_id = t_rec->dx_qual[j].diagnosis_id
			set 4170155Request->item[1].diagnosis_group = t_rec->dx_qual[j].diagnosis_group
			if (t_rec->commit_mode = 1)
				set stat = tdbexecute(600005, 4170140, 4170155, "REC", 4170155Request, "REC", 4170155Reply) 
			endif
			if (t_rec->debug_mode = 1)
				call echojson(4170155Request,t_rec->log_file_a,1)
				call echojson(4170155Reply,t_rec->log_file_a,1)
			endif
		endif
	endfor
endif

#exit_script

if (t_rec->debug_mode = 1)
	call echojson(t_rec,t_rec->log_file_a,1)
	call echojson(reqinfo,t_rec->log_file_a,1)
	call echojson(requestin,t_rec->log_file_b)
endif

end
go

