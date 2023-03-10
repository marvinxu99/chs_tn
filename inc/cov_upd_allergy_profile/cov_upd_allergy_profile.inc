free record 963006request
record 963006request
(
	1 person_id = f8
)
 
free record 963006reply
record 963006reply
(
   1  person_org_sec_on = i2
   1  allergy_qual = i4
   1  allergy[*]
      2  allergy_id = f8
      2  allergy_instance_id = f8
      2  encntr_id = f8
      2  organization_id = f8
      2  source_string = vc
      2  substance_nom_id = f8
      2  substance_ftdesc = vc
      2  substance_type_cd = f8
      2  substance_type_disp = c40
      2  substance_type_mean = c12
      2  reaction_class_cd = f8
      2  reaction_class_disp = c40
      2  reaction_class_mean = c12
      2  severity_cd = f8
      2  severity_disp = c40
      2  severity_mean = c12
      2  source_of_info_cd = f8
      2  source_of_info_disp = c40
      2  source_of_info_mean = c12
      2  onset_dt_tm = dq8
      2  onset_tz = i4
      2  onset_precision_cd = f8
      2  onset_precision_disp = c40
      2  onset_precision_flag = i2
      2  reaction_status_cd = f8
      2  reaction_status_disp = c40
      2  reaction_status_mean = c12
      2  reaction_status_dt_tm = dq8
      2  created_dt_tm = dq8
      2  created_prsnl_id = f8
      2  created_prsnl_name = vc
      2  reviewed_dt_tm = dq8
      2  reviewed_tz = i4
      2  reviewed_prsnl_id = f8
      2  reviewed_prsnl_name = vc
      2  cancel_reason_cd = f8
      2  cancel_reason_disp = c40
      2  active_ind = i2
      2  orig_prsnl_id = f8
      2  orig_prsnl_name = vc
      2  updt_id = f8
      2  updt_name = vc
      2  updt_dt_tm = dq8
      2  cki = vc
      2  concept_source_cd = f8
      2  concept_source_disp = c40
      2  concept_source_mean = c12
      2  concept_identifier = vc
      2  cancel_dt_tm = dq8
      2  cancel_prsnl_id = f8
      2  cancel_prsnl_name = vc
      2  beg_effective_dt_tm = dq8
      2  beg_effective_tz = i4
      2  end_effective_dt_tm = dq8
      2  data_status_cd = f8
      2  data_status_dt_tm = dq8
      2  data_status_prsnl_id = f8
      2  contributor_system_cd = f8
      2  source_of_info_ft = vc
      2  active_status_cd = f8
      2  active_status_dt_tm = dq8
      2  active_status_prsnl_id = f8
      2  rec_src_identifier = vc
      2  rec_src_string = vc
      2  rec_src_vocab_cd = f8
      2  verified_status_flag = i2
      2  reaction_qual = i4
      2  cmb_instance_id = f8
      2  cmb_flag = i2
      2  cmb_prsnl_id = f8
      2  cmb_prsnl_name = vc
      2  cmb_person_id = f8
      2  cmb_person_name = vc
      2  cmb_dt_tm = dq8
      2  cmb_tz = i4
      2  reaction[*]
         3  allergy_instance_id = f8
         3  reaction_id = f8
         3  reaction_nom_id = f8
         3  source_string = vc
         3  reaction_ftdesc = vc
         3  beg_effective_dt_tm = dq8
         3  active_ind = i2
         3  end_effective_dt_tm = dq8
         3  data_status_cd = f8
         3  data_status_dt_tm = dq8
         3  data_status_prsnl_id = f8
         3  contributor_system_cd = f8
         3  active_status_cd = f8
         3  active_status_dt_tm = dq8
         3  active_status_prsnl_id = f8
         3  cmb_reaction_id = f8
         3  cmb_flag = i2
      	3  cmb_prsnl_id = f8
      	3  cmb_prsnl_name = vc
      	3  cmb_person_id = f8
      	3  cmb_person_name = vc
      	3  cmb_dt_tm = dq8
      	3  cmb_tz = i4
      2  comment_qual = i4
      2  comment[*]
         3  allergy_comment_id = f8
         3  allergy_instance_id = f8
         3  organization_id = f8
         3  comment_dt_tm = dq8
         3  comment_tz = i4
         3  comment_prsnl_id = f8
         3  comment_prsnl_name = vc
         3  allergy_comment = vc
         3  beg_effective_dt_tm = dq8
	      3  beg_effective_tz =i4
         3  active_ind = i4
         3  end_effective_dt_tm = dq8
         3  data_status_cd = f8
         3  data_status_dt_tm = dq8
         3  data_status_prsnl_id = f8
         3  contributor_system_cd = f8
         3  active_status_cd = f8
         3  active_status_dt_tm = dq8
         3  active_status_prsnl_id = f8
         3  cmb_comment_id = f8
         3  cmb_flag = i2
      	3  cmb_prsnl_id = f8
      	3  cmb_prsnl_name = vc
      	3  cmb_person_id = f8
      	3  cmb_person_name = vc
      	3  cmb_dt_tm = dq8
      	3  cmb_tz = i4
     2	sub_concept_cki = vc
     2  source_vocab_cd  = f8
     2  primary_vterm_ind = i2
     2  active_status_prsnl_name = vc
   1  adr_knt = i4
   1  adr[*]
      2  activity_data_reltn_id = f8
      2  person_id = f8
      2  activity_entity_name = vc
      2  activity_entity_id = f8
      2  activity_entity_inst_id = f8
      2  reltn_entity_name = vc
      2  reltn_entity_id = f8
      2  reltn_entity_all_ind = i2
   1  display_allergy_mode = vc
   1  status_data
      2  status = c1
      2  subeventstatus[1]
         3  operationName = c8
         3  operationStatus = c1
         3  targetObjectName = c15
         3  targetObjectValue = c100
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
