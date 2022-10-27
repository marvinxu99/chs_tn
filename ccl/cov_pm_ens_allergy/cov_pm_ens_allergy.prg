/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_pm_ens_allergy.prg
  Object name:        cov_pm_ens_allergy
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
drop program cov_pm_ens_allergy:dba go
create program cov_pm_ens_allergy:dba

set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
	1 nka_nomed_id = f8
	1 substance_type_cd = f8
	1 reaction_class_cd = f8
	1 reaction_status_cd = f8
)

free record 101706request
record 101706request (
  1 allergy_cnt = i4   
  1 allergy [*]   
    2 allergy_instance_id = f8   
    2 allergy_id = f8   
    2 person_id = f8   
    2 encntr_id = f8   
    2 substance_nom_id = f8   
    2 substance_ftdesc = vc  
    2 substance_type_cd = f8   
    2 reaction_class_cd = f8   
    2 severity_cd = f8   
    2 source_of_info_cd = f8   
    2 source_of_info_ft = vc  
    2 onset_dt_tm = dq8   
    2 onset_tz = i4   
    2 onset_precision_cd = f8   
    2 onset_precision_flag = i2   
    2 reaction_status_cd = f8   
    2 cancel_reason_cd = f8   
    2 cancel_dt_tm = dq8   
    2 cancel_prsnl_id = f8   
    2 created_prsnl_id = f8   
    2 reviewed_dt_tm = dq8   
    2 reviewed_tz = i4   
    2 reviewed_prsnl_id = f8   
    2 active_ind = i2   
    2 active_status_cd = f8   
    2 active_status_dt_tm = dq8   
    2 active_status_prsnl_id = f8   
    2 beg_effective_dt_tm = dq8   
    2 beg_effective_tz = i4   
    2 end_effective_dt_tm = dq8   
    2 contributor_system_cd = f8   
    2 data_status_cd = f8   
    2 data_status_dt_tm = dq8   
    2 data_status_prsnl_id = f8   
    2 verified_status_flag = i2   
    2 rec_src_vocab_cd = f8   
    2 rec_src_identifier = vc  
    2 rec_src_string = vc  
    2 cmb_instance_id = f8   
    2 cmb_flag = i2   
    2 cmb_prsnl_id = f8   
    2 cmb_person_id = f8   
    2 cmb_dt_tm = dq8   
    2 cmb_tz = i2   
    2 updt_id = f8   
    2 reaction_status_dt_tm = dq8   
    2 created_dt_tm = dq8   
    2 orig_prsnl_id = f8   
    2 reaction_cnt = i4   
    2 reaction [*]   
      3 reaction_id = f8   
      3 allergy_instance_id = f8   
      3 allergy_id = f8   
      3 reaction_nom_id = f8   
      3 reaction_ftdesc = vc  
      3 active_ind = i2   
      3 active_status_cd = f8   
      3 active_status_dt_tm = dq8   
      3 active_status_prsnl_id = f8   
      3 beg_effective_dt_tm = dq8   
      3 end_effective_dt_tm = dq8   
      3 contributor_system_cd = f8   
      3 data_status_cd = f8   
      3 data_status_dt_tm = dq8   
      3 data_status_prsnl_id = f8   
      3 cmb_reaction_id = f8   
      3 cmb_flag = i2   
      3 cmb_prsnl_id = f8   
      3 cmb_person_id = f8   
      3 cmb_dt_tm = dq8   
      3 cmb_tz = i2   
      3 updt_id = f8   
      3 updt_dt_tm = dq8   
    2 allergy_comment_cnt = i4   
    2 allergy_comment [*]   
      3 allergy_comment_id = f8   
      3 allergy_instance_id = f8   
      3 allergy_id = f8   
      3 comment_dt_tm = dq8   
      3 comment_tz = i4   
      3 comment_prsnl_id = f8   
      3 allergy_comment = vc  
      3 active_ind = i2   
      3 active_status_cd = f8   
      3 active_status_dt_tm = dq8   
      3 active_status_prsnl_id = f8   
      3 beg_effective_dt_tm = dq8   
      3 beg_effective_tz = i4   
      3 end_effective_dt_tm = dq8   
      3 contributor_system_cd = f8   
      3 data_status_cd = f8   
      3 data_status_dt_tm = dq8   
      3 data_status_prsnl_id = f8   
      3 cmb_comment_id = f8   
      3 cmb_flag = i2   
      3 cmb_prsnl_id = f8   
      3 cmb_person_id = f8   
      3 cmb_dt_tm = dq8   
      3 cmb_tz = i2   
      3 updt_id = f8   
      3 updt_dt_tm = dq8   
    2 sub_concept_cki = vc  
    2 pre_generated_id = f8   
  1 disable_inactive_person_ens = i2   
  1 fail_on_duplicate = i2   
) 


free record 101706reply
record 101706reply (
    1 person_org_sec_on = i2
    1 allergy_cnt = i4
    1 allergy [* ]
      2 allergy_instance_id = f8
      2 allergy_id = f8
      2 adr_added_ind = i2
      2 status_flag = i2
      2 reaction_cnt = i4
      2 reaction [* ]
        3 reaction_id = f8
        3 status_flag = i2
      2 allergy_comment_cnt = i4
      2 allergy_comment [* ]
        3 allergy_comment_id = f8
        3 status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
)
/*Sample

 <allergy_cnt>1</allergy_cnt>
    <allergy>
       <allergy_instance_id>0</allergy_instance_id>
       <allergy_id>0</allergy_id>
       <person_id>18010348</person_id>
       <encntr_id>113915787</encntr_id>
       <substance_nom_id>960419</substance_nom_id>
       <substance_ftdesc></substance_ftdesc>
       <substance_type_cd>3288</substance_type_cd>
       <reaction_class_cd>638974</reaction_class_cd>
       <severity_cd>0</severity_cd>
       <source_of_info_cd>0</source_of_info_cd>
       <source_of_info_ft></source_of_info_ft>
       <onset_dt_tm>0000-00-00T00:00:00.00</onset_dt_tm>
       <onset_tz>0</onset_tz>
       <onset_precision_cd>0</onset_precision_cd>
       <onset_precision_flag>0</onset_precision_flag>
       <reaction_status_cd>3299</reaction_status_cd>
       <cancel_reason_cd>0</cancel_reason_cd>
       <cancel_dt_tm>0000-00-00T00:00:00.00</cancel_dt_tm>
       <cancel_prsnl_id>0</cancel_prsnl_id>
       <created_prsnl_id>-999</created_prsnl_id>
       <reviewed_dt_tm>2019-11-06T13:35:17.00</reviewed_dt_tm>
       <reviewed_tz>126</reviewed_tz>
       <reviewed_prsnl_id>16908168</reviewed_prsnl_id>
       <active_ind>1</active_ind>
       <active_status_cd>0</active_status_cd>
       <active_status_dt_tm>0000-00-00T00:00:00.00</active_status_dt_tm>
       <active_status_prsnl_id>0</active_status_prsnl_id>
       <beg_effective_dt_tm>0000-00-00T00:00:00.00</beg_effective_dt_tm>
       <beg_effective_tz>0</beg_effective_tz>
       <end_effective_dt_tm>0000-00-00T00:00:00.00</end_effective_dt_tm>
       <contributor_system_cd>0</contributor_system_cd>
       <data_status_cd>0</data_status_cd>
       <data_status_dt_tm>0000-00-00T00:00:00.00</data_status_dt_tm>
       <data_status_prsnl_id>0</data_status_prsnl_id>
       <verified_status_flag>0</verified_status_flag>
       <rec_src_vocab_cd>0</rec_src_vocab_cd>
       <rec_src_identifier></rec_src_identifier>
       <rec_src_string></rec_src_string>
       <cmb_instance_id>0</cmb_instance_id>
       <cmb_flag>0</cmb_flag>
       <cmb_prsnl_id>0</cmb_prsnl_id>
       <cmb_person_id>0</cmb_person_id>
       <cmb_dt_tm>0000-00-00T00:00:00.00</cmb_dt_tm>
       <cmb_tz>0</cmb_tz>
       <updt_id>0</updt_id>
       <reaction_status_dt_tm>0000-00-00T00:00:00.00</reaction_status_dt_tm>
       <created_dt_tm>0000-00-00T00:00:00.00</created_dt_tm>
       <orig_prsnl_id>0</orig_prsnl_id>
       <reaction_cnt>0</reaction_cnt>
       <allergy_comment_cnt>0</allergy_comment_cnt>
       <sub_concept_cki></sub_concept_cki>
       <pre_generated_id>0</pre_generated_id>
    </allergy>
    <disable_inactive_person_ens>1</disable_inactive_person_ens>
    <fail_on_duplicate>0</fail_on_duplicate>
    
*/

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

select into "nl:"
from
	nomenclature n
plan n
	where n.source_vocabulary_cd = value(uar_get_code_by("MEANING",400,"ALLERGY"))
	and   n.source_string = "No Known Allergies"
	and   n.active_ind = 1
	and   n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
order by
	 n.beg_effective_dt_tm 
	,n.nomenclature_id
head n.nomenclature_id
	t_rec->nka_nomed_id = n.nomenclature_id
with nocounter

if (t_rec->nka_nomed_id <= 0.0)
	set t_rec->log_message = concat("NKA Nomenclature not found")
	go to exit_script
endif

set t_rec->reaction_class_cd	= uar_get_code_by("MEANING",12021,"ALLERGY")
set t_rec->reaction_status_cd	= uar_get_code_by("MEANING",12025,"ACTIVE")
set t_rec->substance_type_cd	= uar_get_code_by("MEANING",12020,"DRUG")

if (t_rec->reaction_class_cd <= 0.0)
	set t_rec->log_message = concat("Reaction Class of Allegy not found")
	go to exit_script
endif

if (t_rec->reaction_status_cd <= 0.0)
	set t_rec->log_message = concat("Reaction Status of Active not found")
	go to exit_script
endif

if (t_rec->substance_type_cd <= 0.0)
	set t_rec->log_message = concat("Substance Type of Drug not found")
	go to exit_script
endif

set 101706request->allergy_cnt = 1
set stat = alterlist(101706request->allergy,101706request->allergy_cnt)
set 101706request->allergy[1].person_id = t_rec->patient.person_id
set 101706request->allergy[1].encntr_id = t_rec->patient.encntr_id
set 101706request->allergy[1].substance_nom_id = t_rec->nka_nomed_id
set 101706request->allergy[1].substance_type_cd = t_rec->substance_type_cd
set 101706request->allergy[1].reaction_class_cd = t_rec->reaction_class_cd
set 101706request->allergy[1].reaction_status_cd = t_rec->reaction_status_cd
set 101706request->allergy[1].reviewed_dt_tm = cnvtdatetime(curdate,curtime3)
set 101706request->allergy[1].reviewed_tz = 126
set 101706request->allergy[1].reviewed_prsnl_id = 1
set 101706request->allergy[1].active_ind = 1
set 101706request->allergy[1].created_prsnl_id = -999
set 101706request->disable_inactive_person_ens = 1

set t_rec->return_value = "FALSE"
set t_rec->return_value = "TRUE"

call echorecord(101706request)

set stat = tdbexecute(600005, 961706, 101706, "REC", 101706request, "REC", 101706reply)

call echorecord(101706reply)

#exit_script

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
	set t_rec->log_misc1 = ""
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end 
go
