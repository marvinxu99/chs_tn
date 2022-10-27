DROP PROGRAM cov_t_ce_create_ce :dba GO
CREATE PROGRAM cov_t_ce_create_ce :dba
 DECLARE bzeroplaces = i2 WITH noconstant (0 )
 DECLARE todaynowdttm = f8
 DECLARE goodstatuscnt = i4 WITH noconstant (0 )
 DECLARE badstatuscnt = i4 WITH noconstant (0 )
 DECLARE goodevents = vc
 DECLARE badevents = vc
 DECLARE msg = vc
 DECLARE ceelapsed = f8 WITH noconstant (0.0 )
 DECLARE ceservertm = f8
 DECLARE event_updt_id = f8 WITH noconstant (0.0 ) ,protect
 DECLARE multvalueind = i2 WITH protect ,noconstant (0 )
 DECLARE cridx = i4 WITH protect ,noconstant (0.0 )
 DECLARE pos = i4 WITH protect ,noconstant (0 )
 DECLARE ii = i4 WITH protect
 DECLARE tempstarttime = f8
 SET tempstarttime = curtime3
 SET rev_inc = "708"
 SET ininc = "eks_tell_ekscommon"
 SET ttemp = trim (eks_common->cur_module_name )
 SET eksmodule = trim (ttemp )
 FREE SET ttemp
 SET ttemp = trim (eks_common->event_name )
 SET eksevent = ttemp
 SET eksrequest = eks_common->request_number
 FREE SET ttemp
 DECLARE tcurindex = i4
 DECLARE tinx = i4
 SET tcurindex = 1
 SET tinx = 1
 SET evoke_inx = 1
 SET data_inx = 2
 SET logic_inx = 3
 SET action_inx = 4
 IF (NOT ((validate (eksdata->tqual ,"Y" ) = "Y" )
 AND (validate (eksdata->tqual ,"Z" ) = "Z" ) ) )
  FREE SET templatetype
  IF ((conclude > 0 ) )
   SET templatetype = "ACTION"
   SET basecurindex = (logiccnt + evokecnt )
   SET tcurindex = 4
  ELSE
   SET templatetype = "LOGIC"
   SET basecurindex = evokecnt
   SET tcurindex = 3
  ENDIF
  SET cbinx = curindex
  SET tinx = logic_inx
 ELSE
  SET templatetype = "EVOKE"
  SET curindex = 0
  SET tcurindex = 0
  SET tinx = 0
 ENDIF
 CALL echo (concat ("****  " ,format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,
    "hh:mm:ss.cc;3;m" ) ,"     Module:  " ,trim (eksmodule ) ,"  ****" ) ,1 ,0 )
 IF ((validate (tname ,"Y" ) = "Y" )
 AND (validate (tname ,"Z" ) = "Z" ) )
  IF ((templatetype != "EVOKE" ) )
   CALL echo (concat ("****  EKM Beginning of " ,trim (templatetype ) ," Template(" ,build (curindex
      ) ,")           Event:  " ,trim (eksevent ) ,"         Request number:  " ,cnvtstring (
      eksrequest ) ) ,1 ,10 )
  ELSE
   CALL echo (concat ("****  EKM Beginning an Evoke Template" ,"           Event:  " ,trim (eksevent
      ) ,"         Request number:  " ,cnvtstring (eksrequest ) ) ,1 ,10 )
  ENDIF
 ELSE
  IF ((templatetype != "EVOKE" ) )
   CALL echo (concat ("****  EKM Beginning of " ,trim (templatetype ) ," Template(" ,build (curindex
      ) ,"):  " ,trim (tname ) ,"       Event:  " ,trim (eksevent ) ,"         Request number:  " ,
     cnvtstring (eksrequest ) ) ,1 ,10 )
  ELSE
   CALL echo (concat ("****  EKM Beginning Evoke Template:  " ,trim (tname ) ,"       Event:  " ,
     trim (eksevent ) ,"         Request number:  " ,cnvtstring (eksrequest ) ) ,1 ,10 )
  ENDIF
 ENDIF
 CALL echo (concat (format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,"hh:mm:ss.cc;3;m" ) ,
   "  *******  Beginning of Program eks_t_ce_create_ce_a  *********" ) )
 SET inbuf = fillstring (32538 ," " )
 SET outbuf = fillstring (32538 ," " )
 SET note_format_cd = 0.0
 SET eksinx = 0
 SET personid = 0.0
 SET eksinx = eks_common->event_repeat_index
 SET personid = event->qual[eksinx ].person_id
 CALL echo (concat (trim (eks_common->event_name ) ," for person_id = " ,trim (cnvtstring (personid ,
     25 ,1 ) ) ) ,1 ,0 )
 IF ((eksrequest = 3072006 )
 AND (reqinfo->updt_id > 0.0 ) )
  SET event_updt_id = reqinfo->updt_id
  CALL echo (concat ("updt_id being used is from reqinfo:  " ,build (event_updt_id ) ) )
 ELSE
  SET event_updt_id = eks_common->discern_person_id
  CALL echo (concat ("updt_id being used is from eks_common:  " ,build (event_updt_id ) ) )
 ENDIF
 
 ;override event_updt_id with EVENT_PRSNL EKS Message Parameter if present
 execute cov_std_eks_routines
 if (cnvtreal(GetBldMsgText("EVENT_PRSNL")) > 0.0)
 	set event_updt_id = cnvtreal(GetBldMsgText("EVENT_PRSNL"))
 endif
 
 CALL echo ("Checking existence and validity of template parameters..." ,1 ,0 )
 RECORD cerequest (
   1 ensure_type = i2
   1 event_subclass_cd = f8
   1 eso_action_meaning = vc
   1 clin_event
     2 ensure_type = i2
     2 event_id = f8
     2 view_level = i4
     2 view_level_ind = i2
     2 order_id = f8
     2 catalog_cd = f8
     2 catalog_cd_cki = vc
     2 series_ref_nbr = vc
     2 person_id = f8
     2 encntr_id = f8
     2 encntr_financial_id = f8
     2 accession_nbr = vc
     2 contributor_system_cd = f8
     2 contributor_system_cd_cki = vc
     2 reference_nbr = vc
     2 parent_event_id = f8
     2 event_class_cd = f8
     2 event_class_cd_cki = vc
     2 event_cd = f8
     2 event_cd_cki = vc
     2 event_tag = vc
     2 event_reltn_cd = f8
     2 event_reltn_cd_cki = vc
     2 event_start_dt_tm = dq8
     2 event_start_dt_tm_ind = i2
     2 event_end_dt_tm = dq8
     2 event_end_dt_tm_ind = i2
     2 event_end_dt_tm_os = f8
     2 event_end_dt_tm_os_ind = i2
     2 task_assay_cd = f8
     2 task_assay_cd_cki = vc
     2 record_status_cd = f8
     2 record_status_cd_cki = vc
     2 result_status_cd = f8
     2 result_status_cd_cki = vc
     2 authentic_flag = i2
     2 authentic_flag_ind = i2
     2 publish_flag = i2
     2 publish_flag_ind = i2
     2 qc_review_cd = f8
     2 qc_review_cd_cki = vc
     2 normalcy_cd = f8
     2 normalcy_cd_cki = vc
     2 normalcy_method_cd = f8
     2 normalcy_method_cd_cki = vc
     2 inquire_security_cd = f8
     2 inquire_security_cd_cki = vc
     2 resource_group_cd = f8
     2 resource_group_cd_cki = vc
     2 resource_cd = f8
     2 resource_cd_cki = vc
     2 subtable_bit_map = i4
     2 subtable_bit_map_ind = i2
     2 event_title_text = vc
     2 collating_seq = vc
     2 normal_low = vc
     2 normal_high = vc
     2 critical_low = vc
     2 critical_high = vc
     2 expiration_dt_tm = dq8
     2 expiration_dt_tm_ind = i2
     2 note_importance_bit_map = i2
     2 event_tag_set_flag = i2
	 2 entry_mode_cd = f8
     2 io_result [* ]
       3 person_id = f8
       3 io_dt_tm = dq8
       3 io_dt_tm_ind = i2
       3 type_cd = f8
       3 group_cd = f8
       3 volume = f8
       3 volume_ind = i2
       3 authentic_flag = i2
       3 authentic_flag_ind = i2
       3 record_status_cd = f8
       3 io_comment = vc
       3 system_note = vc
       3 ce_io_result_id = f8
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 specimen_coll [* ]
       3 specimen_id = f8
       3 container_id = f8
       3 container_type_cd = f8
       3 specimen_status_cd = f8
       3 collect_dt_tm = dq8
       3 collect_dt_tm_ind = i2
       3 collect_method_cd = f8
       3 collect_loc_cd = f8
       3 collect_prsnl_id = f8
       3 collect_volume = f8
       3 collect_volume_ind = i2
       3 collect_unit_cd = f8
       3 collect_priority_cd = f8
       3 source_type_cd = f8
       3 source_text = vc
       3 body_site_cd = f8
       3 danger_cd = f8
       3 positive_ind = i2
       3 positive_ind_ind = i2
       3 specimen_trans_list [* ]
         4 sequence_nbr = i4
         4 sequence_nbr_ind = i2
         4 transfer_dt_tm = dq8
         4 transfer_dt_tm_ind = i2
         4 transfer_prsnl_id = f8
         4 transfer_loc_cd = f8
         4 receive_dt_tm = dq8
         4 receive_dt_tm_ind = i2
         4 receive_prsnl_id = f8
         4 receive_loc_cd = f8
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 blob_result [* ]
       3 succession_type_cd = f8
       3 sub_series_ref_nbr = vc
       3 storage_cd = f8
       3 format_cd = f8
       3 device_cd = f8
       3 blob_handle = vc
       3 blob_attributes = vc
       3 blob [* ]
         4 blob_seq_num = i4
         4 blob_seq_num_ind = i2
         4 compression_cd = f8
         4 blob_contents = gvc
         4 blob_contents_ind = i2
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 blob_length = i4
         4 blob_length_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 blob_summary [* ]
         4 blob_length = i4
         4 blob_length_ind = i2
         4 format_cd = f8
         4 compression_cd = f8
         4 checksum = i4
         4 checksum_ind = i2
         4 long_blob = gvc
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 ce_blob_summary_id = f8
         4 blob_summary_id = f8
         4 event_id = f8
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 max_sequence_nbr = i4
       3 max_sequence_nbr_ind = i2
       3 checksum = i4
       3 checksum_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 string_result [* ]
       3 ensure_type = i2
       3 string_result_text = vc
       3 string_result_format_cd = f8
       3 equation_id = f8
       3 last_norm_dt_tm = dq8
       3 last_norm_dt_tm_ind = i2
       3 unit_of_measure_cd = f8
       3 feasible_ind = i2
       3 feasible_ind_ind = i2
       3 inaccurate_ind = i2
       3 inaccurate_ind_ind = i2
       3 interp_comp_list [* ]
         4 comp_idx = i4
         4 comp_idx_ind = i2
         4 comp_event_id = f8
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 blood_transfuse [* ]
       3 transfuse_start_dt_tm = dq8
       3 transfuse_start_dt_tm_ind = i2
       3 transfuse_end_dt_tm = dq8
       3 transfuse_end_dt_tm_ind = i2
       3 transfuse_note = vc
       3 transfuse_route_cd = f8
       3 transfuse_site_cd = f8
       3 transfuse_pt_loc_cd = f8
       3 initial_volume = f8
       3 total_intake_volume = f8
       3 transfusion_rate = f8
       3 transfusion_unit_cd = f8
       3 transfusion_time_cd = f8
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 apparatus [* ]
       3 apparatus_type_cd = f8
       3 apparatus_serial_nbr = vc
       3 apparatus_size_cd = f8
       3 body_site_cd = f8
       3 insertion_pt_loc_cd = f8
       3 insertion_prsnl_id = f8
       3 removal_pt_loc_cd = f8
       3 removal_prsnl_id = f8
       3 assistant_list [* ]
         4 assistant_type_cd = f8
         4 sequence_nbr = i4
         4 sequence_nbr_ind = i2
         4 assistant_prsnl_id = f8
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 product [* ]
       3 product_id = f8
       3 product_nbr = vc
       3 product_cd = f8
       3 abo_cd = f8
       3 rh_cd = f8
       3 product_status_cd = f8
       3 product_antigen_list [* ]
         4 prod_ant_seq_nbr = i4
         4 prod_ant_seq_nbr_ind = i2
         4 antigen_cd = f8
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 date_result [* ]
       3 result_dt_tm = dq8
       3 result_dt_tm_ind = i2
       3 result_dt_tm_os = f8
       3 result_dt_tm_os_ind = i2
       3 date_type_flag = i2
       3 date_type_flag_ind = i2
       3 event_id = f8
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 med_result_list [* ]
       3 admin_note = vc
       3 admin_prov_id = f8
       3 admin_start_dt_tm = dq8
       3 admin_start_dt_tm_ind = i2
       3 admin_end_dt_tm = dq8
       3 admin_end_dt_tm_ind = i2
       3 admin_route_cd = f8
       3 admin_site_cd = f8
       3 admin_method_cd = f8
       3 admin_pt_loc_cd = f8
       3 initial_dosage = f8
       3 initial_dosage_ind = i2
       3 admin_dosage = f8
       3 admin_dosage_ind = i2
       3 dosage_unit_cd = f8
       3 initial_volume = f8
       3 initial_volume_ind = i2
       3 total_intake_volume = f8
       3 total_intake_volume_ind = i2
       3 diluent_type_cd = f8
       3 ph_dispense_id = f8
       3 infusion_rate = f8
       3 infusion_rate_ind = i2
       3 infusion_unit_cd = f8
       3 infusion_time_cd = f8
       3 medication_form_cd = f8
       3 reason_required_flag = i2
       3 reason_required_flag_ind = i2
       3 response_required_flag = i2
       3 response_required_flag_ind = i2
       3 admin_strength = i4
       3 admin_strength_ind = i2
       3 admin_strength_unit_cd = f8
       3 substance_lot_number = vc
       3 substance_exp_dt_tm = dq8
       3 substance_exp_dt_tm_ind = i2
       3 substance_manufacturer_cd = f8
       3 refusal_cd = f8
       3 system_entry_dt_tm = dq8
       3 system_entry_dt_tm_ind = i2
       3 iv_event_cd = f8
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 event_note_list [* ]
       3 note_type_cd = f8
       3 note_format_cd = f8
       3 entry_method_cd = f8
       3 note_prsnl_id = f8
       3 note_dt_tm = dq8
       3 note_dt_tm_ind = i2
       3 record_status_cd = f8
       3 compression_cd = f8
       3 checksum = i4
       3 checksum_ind = i2
       3 long_text_id = f8
       3 non_chartable_flag = i2
       3 importance_flag = i2
       3 long_blob = gvc
       3 ce_event_note_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 event_note_id = f8
       3 event_id = f8
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 event_prsnl_list [* ]
       3 event_prsnl_id = f8
       3 person_id = f8
       3 event_id = f8
       3 action_type_cd = f8
       3 request_dt_tm = dq8
       3 request_dt_tm_ind = i2
       3 request_prsnl_id = f8
       3 request_prsnl_ft = vc
       3 request_comment = vc
       3 action_dt_tm = dq8
       3 action_dt_tm_ind = i2
       3 action_prsnl_id = f8
       3 action_prsnl_ft = vc
       3 proxy_prsnl_id = f8
       3 proxy_prsnl_ft = vc
       3 action_status_cd = f8
       3 action_comment = vc
       3 change_since_action_flag = i2
       3 change_since_action_flag_ind = i2
       3 action_prsnl_pin = vc
       3 defeat_succn_ind = i2
       3 ce_event_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 long_text_id = f8
       3 linked_event_id = f8
       3 request_tz = i4
       3 action_tz = i4
       3 system_comment = vc
     2 microbiology_list [* ]
       3 ensure_type = i2
       3 micro_seq_nbr = i4
       3 micro_seq_nbr_ind = i2
       3 organism_cd = f8
       3 organism_occurrence_nbr = i4
       3 organism_occurrence_nbr_ind = i2
       3 organism_type_cd = f8
       3 observation_prsnl_id = f8
       3 biotype = vc
       3 probability = f8
       3 positive_ind = i2
       3 positive_ind_ind = i2
       3 susceptibility_list [* ]
         4 ensure_type = i2
         4 micro_seq_nbr = i4
         4 micro_seq_nbr_ind = i2
         4 suscep_seq_nbr = i4
         4 suscep_seq_nbr_ind = i2
         4 susceptibility_test_cd = f8
         4 detail_susceptibility_cd = f8
         4 panel_antibiotic_cd = f8
         4 antibiotic_cd = f8
         4 diluent_volume = f8
         4 diluent_volume_ind = i2
         4 result_cd = f8
         4 result_text_value = vc
         4 result_numeric_value = f8
         4 result_numeric_value_ind = i2
         4 result_unit_cd = f8
         4 result_dt_tm = dq8
         4 result_dt_tm_ind = i2
         4 result_prsnl_id = f8
         4 susceptibility_status_cd = f8
         4 abnormal_flag = i2
         4 abnormal_flag_ind = i2
         4 chartable_flag = i2
         4 chartable_flag_ind = i2
         4 nomenclature_id = f8
         4 antibiotic_note = vc
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 coded_result_list [* ]
       3 ensure_type = i2
       3 sequence_nbr = i4
       3 sequence_nbr_ind = i2
       3 nomenclature_id = f8
       3 acr_code_str = vc
       3 proc_code_str = vc
       3 pathology_str = vc
       3 result_set = i4
       3 result_set_ind = i2
       3 result_cd = f8
       3 group_nbr = i4
       3 group_nbr_ind = i2
       3 mnemonic = vc
       3 short_string = vc
       3 descriptor = vc
       3 unit_of_measure_cd = f8
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 linked_result_list [* ]
       3 ensure_type = i2
       3 linked_event_id = f8
       3 order_id = f8
       3 encntr_id = f8
       3 accession_nbr = vc
       3 contributor_system_cd = f8
       3 reference_nbr = vc
       3 event_class_cd = f8
       3 series_ref_nbr = vc
       3 sub_series_ref_nbr = vc
       3 succession_type_cd = f8
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 event_modifier_list [* ]
       3 modifier_cd = f8
       3 modifier_value_cd = f8
       3 modifier_val_ft = vc
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 suscep_footnote_r_list [* ]
       3 ensure_type = i2
       3 micro_seq_nbr = i4
       3 micro_seq_nbr_ind = i2
       3 suscep_seq_nbr = i4
       3 suscep_seq_nbr_ind = i2
       3 suscep_footnote_id = f8
       3 suscep_footnote [* ]
         4 event_id = f8
         4 ce_suscep_footnote_id = f8
         4 suscep_footnote_id = f8
         4 checksum = i4
         4 checksum_ind = i2
         4 compression_cd = f8
         4 format_cd = f8
         4 contributor_system_cd = f8
         4 blob_length = i4
         4 blob_length_ind = i2
         4 reference_nbr = vc
         4 long_blob = gvc
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 inventory_result_list [* ]
       3 ensure_type = i2
       3 item_id = f8
       3 serial_nbr = vc
       3 serial_mnemonic = vc
       3 description = vc
       3 item_nbr = vc
       3 quantity = f8
       3 quantity_ind = i2
       3 body_site = vc
       3 reference_entity_id = f8
       3 reference_entity_name = vc
       3 implant_result [* ]
         4 ensure_type = i2
         4 item_id = f8
         4 item_size = vc
         4 harvest_site = vc
         4 culture_ind = i2
         4 culture_ind_ind = i2
         4 tissue_graft_type_cd = f8
         4 explant_reason_cd = f8
         4 explant_disposition_cd = f8
         4 reference_entity_id = f8
         4 reference_entity_name = vc
         4 manufacturer_cd = f8
         4 manufacturer_ft = vc
         4 model_nbr = vc
         4 lot_nbr = vc
         4 other_identifier = vc
         4 expiration_dt_tm = dq8
         4 expiration_dt_tm_ind = i2
         4 ecri_code = vc
         4 batch_nbr = vc
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 inv_time_result_list [* ]
         4 ensure_type = i2
         4 item_id = f8
         4 start_dt_tm = dq8
         4 start_dt_tm_ind = i2
         4 end_dt_tm = dq8
         4 end_dt_tm_ind = i2
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
     2 script_list [* ]
       3 event_req_flag = i2
       3 event_rep_flag = i2
       3 script_name = vc
       3 location = vc
     2 clinical_event_id = f8
     2 valid_until_dt_tm = dq8
     2 valid_until_dt_tm_ind = i2
     2 valid_from_dt_tm = dq8
     2 valid_from_dt_tm_ind = i2
     2 result_val = vc
     2 result_units_cd = f8
     2 result_units_cd_cki = vc
     2 result_time_units_cd = f8
     2 result_time_units_cd_cki = vc
     2 verified_dt_tm = dq8
     2 verified_dt_tm_ind = i2
     2 verified_prsnl_id = f8
     2 performed_dt_tm = dq8
     2 performed_dt_tm_ind = i2
     2 performed_prsnl_id = f8
     2 updt_dt_tm = dq8
     2 updt_dt_tm_ind = i2
     2 updt_id = f8
     2 updt_task = i4
     2 updt_task_ind = i2
     2 updt_cnt = i4
     2 updt_cnt_ind = i2
     2 updt_applctx = i4
     2 updt_applctx_ind = i2
     2 ce_dynamic_label_id = f8
   1 ensure_type2 = i2
 )
 RECORD cereply (
   1 sb
     2 severitycd = i4
     2 statuscd = i4
     2 statustext = vc
     2 substatuslist [* ]
       3 substatuscd = f8
   1 rb_list [* ]
     2 event_id = f8
     2 valid_from_dt_tm = dq8
     2 event_cd = f8
     2 result_status_cd = f8
     2 contributor_system_cd = f8
     2 reference_nbr = vc
     2 collating_seq = vc
     2 parent_event_id = f8
     2 prsnl_list [* ]
       3 event_prsnl_id = f8
       3 action_prsnl_id = f8
       3 action_type_cd = f8
       3 action_dt_tm = dq8
       3 action_dt_tm_ind = i2
   1 script_reply_list [* ]
 )
 RECORD subcalc (
   1 value1 = vc
   1 opt_comment = vc
 )
 RECORD event_namelist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
     2 status = i4
 )
 DECLARE tmp_string = vc WITH protect ,noconstant (" " )
 DECLARE tmpoffsetvalue = vc WITH protect ,noconstant (" " )
 DECLARE date_cd = f8 WITH protect ,noconstant (0.0 )
 IF (NOT (ce_update_ind ) )
  IF (findstring (char (6 ) ,event_name ) )
   SET orig_param = event_name
   CALL echo ("parameter EVENT_NAME: " )
   EXECUTE eks_t_parse_list WITH replace (reply ,event_namelist )
   FREE SET orig_param
  ELSEIF ((trim (event_name ) > " " )
  AND (trim (cnvtupper (event_name ) ) != "<UNDEFINED>" ) )
   SET stat = alterlist (event_namelist->qual ,1 )
   SET event_namelist->qual[1 ].value = event_name
   SET event_namelist->qual[1 ].display = event_name
   SET event_namelist->cnt = 1
  ELSE
   SET event_namelist->cnt = 0
  ENDIF
  IF ((event_namelist->cnt <= 0 ) )
   SET msg = "No EVENT_NAME was specified in the template."
   SET retval = - (1 )
   GO TO endprogram
  ELSE
   CALL echo (concat (build (event_namelist->cnt ) ," event(s) will be created" ) )
  ENDIF
 ELSE
  SET event_namelist->cnt = 1
  SET stat = alterlist (event_namelist->qual ,1 )
  SET event_cd = 0.0
 ENDIF
 RECORD statuslist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 SET orig_param = status
 CALL echo ("parameter STATUS: " )
 EXECUTE eks_t_parse_list WITH replace (reply ,statuslist )
 FREE SET orig_param
 IF ((statuslist->cnt <= 0 ) )
  SET msg = "No STATUS was specified in the template."
  SET retval = - (1 )
  GO TO endprogram
 ELSEIF ((statuslist->cnt < event_namelist->cnt ) )
  SET stat = alterlist (statuslist->qual ,event_namelist->cnt )
  FOR (pindx = (statuslist->cnt + 1 ) TO event_namelist->cnt )
   SET statuslist->qual[pindx ].value = statuslist->qual[statuslist->cnt ].value
   SET statuslist->qual[pindx ].display = statuslist->qual[statuslist->cnt ].display
  ENDFOR
  SET statuslist->cnt = event_namelist->cnt
 ENDIF
 RECORD opt_normalcylist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 IF (NOT ((tname IN ("EKS_CE_CREATE_DATE_CE_A" ,
 "EKS_CE_UPDATE_DATE_CE_A" ) ) ) )
  SET orig_param = opt_normalcy
  CALL echo ("parameter OPT_NORMALCY: " )
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_normalcylist )
  FREE SET orig_param
  IF ((opt_normalcylist->cnt <= 0 ) )
   CALL echo ("Template is running without normalcy." )
   SET stat = alterlist (opt_normalcylist->qual ,maxval (event_namelist->cnt ,1 ) )
   SET opt_normalcylist->cnt = size (opt_normalcylist->qual ,5 )
   FOR (pindx = 1 TO opt_normalcylist->cnt )
    SET opt_normalcylist->qual[pindx ].value = "0"
    SET opt_normalcylist->qual[pindx ].display = "0"
   ENDFOR
  ELSEIF ((opt_normalcylist->cnt < event_namelist->cnt ) )
   SET stat = alterlist (opt_normalcylist->qual ,event_namelist->cnt )
   FOR (pindx = (opt_normalcylist->cnt + 1 ) TO event_namelist->cnt )
    SET opt_normalcylist->qual[pindx ].value = opt_normalcylist->qual[opt_normalcylist->cnt ].value
    SET opt_normalcylist->qual[pindx ].display = opt_normalcylist->qual[opt_normalcylist->cnt ].
    display
   ENDFOR
   SET opt_normalcylist->cnt = event_namelist->cnt
  ENDIF
 ENDIF
 SET date_cd = 0.0
 SET iret = uar_get_meaning_by_codeset (53 ,"DATE" ,1 ,date_cd )
 IF ((date_cd <= 0 ) )
  SET msg = concat ("There is no cdf_meaning - DATE under code_set 53 in the database" )
 ENDIF
 SET text_cd = 0.0
 SET iret = uar_get_meaning_by_codeset (53 ,"TXT" ,1 ,text_cd )
 IF ((text_cd <= 0 ) )
  SET msg = concat ("There is no cdf_meaning - TXT under code_set 53 in the database" )
 ENDIF
 SET num_cd = 0.0
 SET iret = uar_get_meaning_by_codeset (53 ,"NUM" ,1 ,num_cd )
 IF ((num_cd <= 0 ) )
  SET msg = concat ("There is no cdf_meaning - NUM under code_set 53 in the database" )
 ENDIF
 SET num_format_cd = 0.0
 SET iret = uar_get_meaning_by_codeset (14113 ,"NUMERIC" ,1 ,num_format_cd )
 IF ((num_format_cd <= 0 ) )
  SET msg = "There is no cdf_meaning named NUMERIC under codeset 14113in the database."
 ENDIF
 SET alpha_format_cd = 0.0
 SET iret = uar_get_meaning_by_codeset (14113 ,"ALPHA" ,1 ,alpha_format_cd )
 IF ((alpha_format_cd <= 0 ) )
  SET msg = "There is no cdf_meaning named ALPHA under codeset 14113in the database."
 ENDIF
 SET ininc = "eks_sub_record.inc"
 RECORD ekssub (
   1 orig = vc
   1 parse_ind = i2
   1 num_dec_places = i2
   1 mod = vc
   1 status_flag = i2
   1 msg = vc
   1 format_flag = i4
   1 time_zone = i4
   1 skip_curdate_ind = i2
   1 curdate_fnd_ind = i2
   1 dttm_dq8 = dq8
 )
 IF (ce_update_ind )
  CALL echo ("Updating an existing clinical_event" )
 ELSE
  CALL echo ("Creating new clinical_event(s)" )
 ENDIF
 RECORD value1list (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
     2 event_class_cd = f8
     2 r_value = f8
     2 alpha_value = vc
     2 string_result_format_cd = f8
     2 anchor_dt_tm = dq8
     2 offset = f8
     2 result_dt_tm = dq8
 )
 IF (NOT ((tname IN ("EKS_CE_CREATE_DATE_CE_A" ,
 "EKS_CE_UPDATE_DATE_CE_A" ) ) ) )
  IF ((validate (value1 ,"Z" ) = "Z" )
  AND (validate (value1 ,"Y" ) = "Y" ) )
   SET msg = "VALUE1 parameter does not exist."
   SET retval = - (1 )
   GO TO endprogram
  ELSEIF ((((validate (ce_update_ind ,1 ) = 1 )
  AND (validate (ce_update_ind ,0 ) = 0 ) ) OR (NOT ((ce_update_ind IN (0 ,
  1 ) ) ) )) )
   SET msg = "CE_UPDATE_IND variable does not exist or is not 0 or 1."
   SET retval = - (1 )
   GO TO endprogram
  ENDIF
  IF (findstring (char (6 ) ,value1 ) )
   CALL echo ("Multiple VALUE1's detected" )
   SET orig_param = value1
   CALL echo ("parameter VALUE1: " )
   EXECUTE eks_t_parse_list WITH replace (reply ,value1list )
   FREE SET orig_param
   IF ((value1list->cnt != event_namelist->cnt )
   AND (event_namelist->cnt > 1 ) )
    SET msg = concat ("VALUE1 contained " ,build (value1list->cnt ) ,
     " value(s) while EVENT_NAME contained " ,build (event_namelist->cnt ) ,
     " value(s).  They must match." )
    SET retval = - (1 )
    GO TO endprogram
   ENDIF
   IF ((tname IN ("EKS_CE_CREATE_CODED_CE_A" ,
   "EKS_CE_UPDATE_CODED_CE_A" ) )
   AND (value1list->cnt > 1 )
   AND (event_namelist->cnt = 1 ) )
    SET multvalueind = 1
    CALL echo ("MultValueInd is set for EKS_CE_CREATE_CODED_CE_A" )
   ENDIF
  ELSE
   SET stat = alterlist (value1list->qual ,1 )
   SET value1list->qual[1 ].value = value1
   SET value1list->qual[1 ].display = value1
   SET value1list->cnt = 1
  ENDIF
 ENDIF
 RECORD opt_num_dec_placeslist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
     2 ivalue = i2
     2 bzeroplaces = i2
 )
 IF (NOT ((tname IN ("EKS_CE_CREATE_CODED_CE_A" ,
 "EKS_CE_UPDATE_CODED_CE_A" ,
 "EKS_CE_CREATE_DATE_CE_A" ,
 "EKS_CE_UPDATE_DATE_CE_A" ) ) ) )
  IF (findstring (char (6 ) ,opt_num_dec_places ) )
   CALL echo ("Multiple OPT_NUM_DEC_PLACES's detected" )
   SET orig_param = opt_num_dec_places
   CALL echo ("parameter OPT_NUM_DEC_PLACES: " )
   EXECUTE eks_t_parse_list WITH replace (reply ,opt_num_dec_placeslist )
   FREE SET orig_param
  ELSE
   SET stat = alterlist (opt_num_dec_placeslist->qual ,1 )
   SET opt_num_dec_placeslist->qual[1 ].value = opt_num_dec_places
   SET opt_num_dec_placeslist->qual[1 ].display = opt_num_dec_places
   SET opt_num_dec_placeslist->cnt = 1
  ENDIF
  FOR (pindx = 1 TO opt_num_dec_placeslist->cnt )
   SET opt_num_dec_placeslist->qual[pindx ].bzeroplaces = 0
   IF (isnumeric (opt_num_dec_placeslist->qual[pindx ].display ) )
    SET opt_num_dec_placeslist->qual[pindx ].ivalue = cnvtint (opt_num_dec_placeslist->qual[pindx ].
     display )
    CALL echo (concat ("Number of decimal places set to " ,trim (opt_num_dec_placeslist->qual[pindx ]
       .display ) ) ,1 ,0 )
    IF ((opt_num_dec_placeslist->qual[pindx ].ivalue > 10 ) )
     SET opt_num_dec_placeslist->qual[pindx ].ivalue = 10
     CALL echo (concat ("Number of decimal places of " ,trim (opt_num_dec_placeslist->qual[pindx ].
        display ) ," exceeds maximum of 10, maximum will be used" ) ,1 ,0 )
    ELSEIF ((opt_num_dec_placeslist->qual[pindx ].ivalue = 0 ) )
     SET opt_num_dec_placeslist->qual[pindx ].bzeroplaces = 1
    ENDIF
   ELSEIF ((opt_num_dec_placeslist->qual[pindx ].display IN ("" ,
   "<undefined>" ) ) )
    CALL echo (concat ("Defaulting OPT_NUM_DEC_PLACES[" ,build (pindx ) ,"] to 2." ) )
    SET opt_num_dec_placeslist->qual[pindx ].ivalue = 2
   ELSE
    SET msg = concat ("Invalid value of " ,opt_num_dec_placeslist->qual[pindx ].display ,
     " specified for entry number " ,build (pindx ) )
    SET retval = - (1 )
    GO TO endprogram
   ENDIF
  ENDFOR
  IF ((opt_num_dec_placeslist->cnt < event_namelist->cnt ) )
   SET stat = alterlist (opt_num_dec_placeslist->qual ,event_namelist->cnt )
   FOR (pindx = (opt_num_dec_placeslist->cnt + 1 ) TO event_namelist->cnt )
    SET opt_num_dec_placeslist->qual[pindx ].value = opt_num_dec_placeslist->qual[
    opt_num_dec_placeslist->cnt ].value
    SET opt_num_dec_placeslist->qual[pindx ].display = opt_num_dec_placeslist->qual[
    opt_num_dec_placeslist->cnt ].display
    SET opt_num_dec_placeslist->qual[pindx ].ivalue = opt_num_dec_placeslist->qual[
    opt_num_dec_placeslist->cnt ].ivalue
    SET opt_num_dec_placeslist->qual[pindx ].bzeroplaces = opt_num_dec_placeslist->qual[
    opt_num_dec_placeslist->cnt ].bzeroplaces
   ENDFOR
   SET opt_num_dec_placeslist->cnt = event_namelist->cnt
  ENDIF
  IF (NOT (ce_update_ind ) )
   FOR (pindx = 1 TO value1list->cnt )
    IF ((trim (value1list->qual[pindx ].value ) IN ("" ,
    "<undefined>" ) ) )
     SET msg = concat ("Required parameter VALUE1[" ,build (pindx ) ,"] not specified." )
     SET retval = - (1 )
     GO TO endprogram
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 RECORD opt_result_unitslist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 IF (NOT ((tname IN ("EKS_CE_CREATE_DATE_CE_A" ,
 "EKS_CE_UPDATE_DATE_CE_A" ) ) ) )
  SET orig_param = opt_result_units
  CALL echo ("parameter OPT_RESULT_UNITS: " )
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_result_unitslist )
  FREE SET orig_param
  IF ((opt_result_unitslist->cnt <= 0 ) )
   CALL echo ("Template is running without result units." )
   SET stat = alterlist (opt_result_unitslist->qual ,maxval (event_namelist->cnt ,1 ) )
   SET opt_result_unitslist->cnt = size (opt_result_unitslist->qual ,5 )
   FOR (pindx = 1 TO opt_result_unitslist->cnt )
    SET opt_result_unitslist->qual[pindx ].value = "0"
    SET opt_result_unitslist->qual[pindx ].display = "0"
   ENDFOR
  ELSEIF ((opt_result_unitslist->cnt < event_namelist->cnt ) )
   SET stat = alterlist (opt_result_unitslist->qual ,event_namelist->cnt )
   FOR (pindx = (opt_result_unitslist->cnt + 1 ) TO event_namelist->cnt )
    SET opt_result_unitslist->qual[pindx ].value = opt_result_unitslist->qual[opt_result_unitslist->
    cnt ].value
    SET opt_result_unitslist->qual[pindx ].display = opt_result_unitslist->qual[opt_result_unitslist
    ->cnt ].display
   ENDFOR
   SET opt_result_unitslist->cnt = event_namelist->cnt
  ENDIF
 ENDIF
 RECORD opt_comment_typelist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 SET orig_param = opt_comment_type
 CALL echo ("parameter OPT_COMMENT_TYPE: " )
 EXECUTE eks_t_parse_list WITH replace (reply ,opt_comment_typelist )
 FREE SET orig_param
 IF ((opt_comment_typelist->cnt <= 0 ) )
  CALL echo ("Template is running without comment type." )
  IF ((trim (opt_comment ) > " " )
  AND (opt_comment != "<undefined>" ) )
   SET msg = "OPT_COMMENT_TYPE must be used when specifying an OPT_COMMENT value"
   SET retval = - (1 )
   GO TO endprogram
  ENDIF
  SET stat = alterlist (opt_comment_typelist->qual ,maxval (event_namelist->cnt ,1 ) )
  SET opt_comment_typelist->cnt = size (opt_comment_typelist->qual ,5 )
  FOR (pindx = 1 TO opt_comment_typelist->cnt )
   SET opt_comment_typelist->qual[pindx ].value = "0"
   SET opt_comment_typelist->qual[pindx ].display = "0"
  ENDFOR
 ELSE
  IF ((trim (opt_comment ) IN ("" ,
  "<undefined>" ) ) )
   SET msg = "OPT_COMMENT must be used when specifying an OPT_COMMENT_TYPE"
   SET retval = - (1 )
   GO TO endprogram
  ELSEIF ((opt_comment_typelist->cnt < event_namelist->cnt ) )
   SET stat = alterlist (opt_comment_typelist->qual ,event_namelist->cnt )
   FOR (pindx = (opt_comment_typelist->cnt + 1 ) TO event_namelist->cnt )
    SET opt_comment_typelist->qual[pindx ].value = opt_comment_typelist->qual[opt_comment_typelist->
    cnt ].value
    SET opt_comment_typelist->qual[pindx ].display = opt_comment_typelist->qual[opt_comment_typelist
    ->cnt ].display
   ENDFOR
   SET opt_comment_typelist->cnt = event_namelist->cnt
  ENDIF
 ENDIF
 RECORD opt_commentlist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 IF (findstring (char (6 ) ,opt_comment ) )
  CALL echo ("Multiple OPT_COMMENT's detected" )
  SET orig_param = opt_comment
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_commentlist )
  FREE SET orig_param
 ELSE
  SET stat = alterlist (opt_commentlist->qual ,1 )
  IF ((findstring ("@" ,opt_comment ) > 0 ) )
   SET ekssub->orig = opt_comment
   SET ekssub->parse_ind = 0
   EXECUTE eks_t_subcalc
   SET subcalc->opt_comment = ekssub->mod
   IF ((ekssub->format_flag = 1 ) )
    SET inbuf = trim (subcalc->opt_comment )
    CALL striprtf (0 )
    SET subcalc->opt_comment = outbuf
   ENDIF
  ELSE
   SET subcalc->opt_comment = trim (opt_comment )
  ENDIF
  SET opt_commentlist->qual[1 ].value = subcalc->opt_comment
  SET opt_commentlist->qual[1 ].display = subcalc->opt_comment
  SET opt_commentlist->cnt = 1
 ENDIF
 IF ((opt_commentlist->cnt <= 0 ) )
  CALL echo ("Template is running without comment." )
  SET stat = alterlist (opt_commentlist->qual ,maxval (event_namelist->cnt ,1 ) )
  SET opt_commentlist->cnt = size (opt_commentlist->qual ,5 )
  FOR (pindx = 1 TO opt_commentlist->cnt )
   SET opt_commentlist->qual[pindx ].value = ""
   SET opt_commentlist->qual[pindx ].display = ""
  ENDFOR
 ELSEIF ((opt_commentlist->cnt < event_namelist->cnt ) )
  SET stat = alterlist (opt_commentlist->qual ,event_namelist->cnt )
  FOR (pindx = (opt_commentlist->cnt + 1 ) TO event_namelist->cnt )
   SET opt_commentlist->qual[pindx ].value = opt_commentlist->qual[opt_commentlist->cnt ].value
   SET opt_commentlist->qual[pindx ].display = opt_commentlist->qual[opt_commentlist->cnt ].display
  ENDFOR
  SET opt_commentlist->cnt = event_namelist->cnt
 ENDIF
 FOR (pindx = 1 TO event_namelist->cnt )
  IF ((tname IN ("EKS_CE_CREATE_CODED_CE_A" ,
  "EKS_CE_UPDATE_CODED_CE_A" ) ) )
   IF ((multvalueind > 0 ) )
    FOR (cridx = 1 TO value1list->cnt )
     SET value1list->qual[cridx ].alpha_value = value1list->qual[cridx ].display
     SET value1list->qual[cridx ].event_class_cd = text_cd
     SET value1list->qual[cridx ].string_result_format_cd = alpha_format_cd
     SET value1list->qual[cridx ].r_value = cnvtreal (value1list->qual[cridx ].value )
    ENDFOR
   ELSE
    SET value1list->qual[pindx ].alpha_value = value1list->qual[pindx ].display
    SET value1list->qual[pindx ].event_class_cd = text_cd
    SET value1list->qual[pindx ].string_result_format_cd = alpha_format_cd
    SET value1list->qual[pindx ].r_value = cnvtreal (value1list->qual[pindx ].value )
   ENDIF
  ELSEIF ((tname IN ("EKS_CE_CREATE_DATE_CE_A" ,
  "EKS_CE_UPDATE_DATE_CE_A" ) ) )
   CALL echo ("For date templates value is set later after processing LINK parameter." )
  ELSE
   IF ((findstring ("@" ,value1list->qual[pindx ].display ) > 0 ) )
    SET ekssub->orig = value1list->qual[pindx ].display
    SET ekssub->parse_ind = 1
    SET ekssub->num_dec_places = cnvtint (opt_num_dec_placeslist->qual[pindx ].value )
    EXECUTE eks_t_subcalc
    IF ((ekssub->status_flag = 1 ) )
     CALL echo ("EKS_T_SUBCALC was successful" )
     SET value1list->qual[pindx ].display = ekssub->mod
    ELSE
     SET msg = ekssub->msg
     SET retval = - (1 )
     GO TO endprogram
    ENDIF
   ENDIF
   IF (isnumeric (value1list->qual[pindx ].display ) )
    CALL echo (concat ("Value1 Display = " ,build (cnvtreal (value1list->qual[pindx ].display ) ) ,
      "      iValue = " ,build (opt_num_dec_placeslist->qual[pindx ].ivalue ) ) )
    CALL echo (build2 ("ekssub->num_dec_places:  " ,ekssub->num_dec_places ) )
    IF ((ekssub->num_dec_places != - (1 ) ) )
     SET value1list->qual[pindx ].display = cnvtstring (cnvtreal (value1list->qual[pindx ].display )
      ,11 ,value (opt_num_dec_placeslist->qual[pindx ].ivalue ) )
     CALL echo (concat ("Value adjusted for zero decimal places:  " ,value1list->qual[pindx ].display
        ) )
    ELSE
     CALL echo (
      "VALUE1 contained an @FORMATRESULTNUM and OPT_NUM_DEC_PLACES was not specified, don't override"
      )
    ENDIF
    SET value1list->qual[pindx ].r_value = cnvtreal (value1list->qual[pindx ].display )
    SET value1list->qual[pindx ].alpha_value = value1list->qual[pindx ].display
    SET value1list->qual[pindx ].event_class_cd = num_cd
    SET value1list->qual[pindx ].string_result_format_cd = num_format_cd
   ELSE
    SET value1list->qual[pindx ].alpha_value = value1list->qual[pindx ].display
    CALL echo ("Value is not numeric!" )
    IF ((((ce_update_ind <= 0 ) ) OR (NOT ((trim (cnvtlower (value1list->qual[pindx ].alpha_value )
     ) IN ("" ,
    "<undefined>" ) ) ) )) )
     CALL echo ("Set event class!" )
     SET value1list->qual[pindx ].event_class_cd = text_cd
     SET value1list->qual[pindx ].string_result_format_cd = alpha_format_cd
    ENDIF
   ENDIF
  ENDIF
  IF ((findstring ("@" ,opt_commentlist->qual[pindx ].display ) > 0 ) )
   SET ekssub->orig = opt_commentlist->qual[pindx ].display
   SET ekssub->parse_ind = 0
   EXECUTE eks_t_subcalc
   IF ((ekssub->status_flag = 1 ) )
    CALL echo ("EKS_T_SUBCALC was successful" )
    SET opt_commentlist->qual[pindx ].display = ekssub->mod
    IF ((ekssub->format_flag = 1 ) )
     SET inbuf = trim (opt_commentlist->qual[pindx ].display )
     CALL striprtf (0 )
     SET opt_commentlist->qual[pindx ].display = outbuf
    ENDIF
   ELSE
    SET msg = ekssub->msg
    CALL echo (concat ("OPT_COMMENT subcalc error:  " ,msg ) )
   ENDIF
  ENDIF
 ENDFOR
 SET num_logic_temps = - (1 )
 SET link_personid = 0.0
 SET link_ceid = 0.0
 SET link_encntr = 0.0
 SET link_event_start_dt_tm = 0.0
 SET link_event_end_dt_tm = 0.0
 SET link_orderid = 0.0
 SET link_event_id = 0.0
 SET link_event_cd = 0.0
 SET link_task_assay_cd = 0.0
 SET link_ce_dynamic_label_id = 0.0
 SET todaynowdttm = cnvtdatetime (sysdate )
 IF ((validate (link ,"Z" ) = "Z" )
 AND (validate (link ,"Y" ) = "Y" ) )
  SET msg = "LINK parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  IF (isnumeric (link ) )
   SET link_indx = cnvtint (link )
   SET num_logic_temps = size (eksdata->tqual[tinx ].qual ,5 )
   IF ((((link_indx <= 0 ) ) OR ((link_indx > num_logic_temps ) )) )
    SET msg = concat ("LINK value of '" ,trim (link ) ,"' is invalid." )
    SET retval = - (1 )
    GO TO endprogram
   ELSE
    IF ((ce_update_ind = 1 ) )
     SET link_ceid = eksdata->tqual[tinx ].qual[link_indx ].clinical_event_id
     IF ((link_ceid = 0 ) )
      IF ((size (eksdata->tqual[tinx ].qual[link_indx ].data ,5 ) = 2 ) )
       IF ((trim (cnvtupper (eksdata->tqual[tinx ].qual[link_indx ].data[1 ].misc ) ) =
       "<CLINICAL_EVENT_ID>" )
       AND (isnumeric (eksdata->tqual[tinx ].qual[link_indx ].data[2 ].misc ) > 0 ) )
        SET link_ceid = cnvtreal (eksdata->tqual[tinx ].qual[link_indx ].data[2 ].misc )
        IF ((link_ceid = 0 ) )
         SET msg = "no valid clinical_event_id found in the 2nd field of misc"
         SET retval = - (1 )
         GO TO endprogram
        ENDIF
       ELSE
        SET msg = "no valid clinical_event_id setup in misc area for eks_ce_update_ce_a"
        SET retval = - (1 )
        GO TO endprogram
       ENDIF
      ELSE
       SET msg = "only one clinical_event_id is allowed in eks_ce_update_ce_a template"
       SET retval = - (1 )
       GO TO endprogram
      ENDIF
     ELSE
      SELECT INTO "nl:"
       ce.clinical_event_id ,
       ce.encntr_id ,
       ce.event_end_dt_tm ,
       ce.order_id
       FROM (clinical_event ce )
       WHERE (ce.clinical_event_id = link_ceid )
       DETAIL
        link_encntr = ce.encntr_id ,
        link_personid = ce.person_id ,
        link_event_end_dt_tm = ce.event_end_dt_tm ,
        link_event_start_dt_tm = ce.event_start_dt_tm ,
        link_orderid = ce.order_id ,
        link_event_id = ce.event_id ,
        link_event_cd = ce.event_cd ,
        link_task_assay_cd = ce.task_assay_cd ,
        link_ce_dynamic_label_id = ce.ce_dynamic_label_id ,
        event_namelist->qual[1 ].display = uar_get_code_display (ce.event_cd )
       WITH nocounter
      ;end select
     ENDIF
    ELSE
     SET intsizeofmisc = size (eksdata->tqual[tinx ].qual[link_indx ].data ,5 )
     IF ((intsizeofmisc > 0 )
     AND (trim (cnvtupper (eksdata->tqual[tinx ].qual[link_indx ].data[1 ].misc ) ) =
     "<CLINICAL_EVENT_ID>" ) )
      CALL echo (concat ("size of misc = " ,trim (cnvtstring (intsizeofmisc ) ) ,". misc[1] = " ,
        trim (eksdata->tqual[tinx ].qual[link_indx ].data[1 ].misc ) ) )
      IF ((intsizeofmisc > 1 ) )
       CALL echo (concat ("Link Template found " ,trim (cnvtstring ((intsizeofmisc - 1 ) ) ) ,
         " clinical event(s)." ) )
       SET bdiffeventenddttm_ind = 0
       SET bdiffencntrid_ind = 0
       SELECT INTO "nl:"
        ce.event_end_dt_tm ,
        ce.encntr_id
        FROM (clinical_event ce ),
         (dummyt d WITH seq = (value (intsizeofmisc ) - 1 ) )
        PLAN (d )
         JOIN (ce
         WHERE (ce.clinical_event_id = cnvtreal (eksdata->tqual[tinx ].qual[link_indx ].data[(d.seq
          + 1 ) ].misc ) ) )
        HEAD REPORT
         eventenddttm = ce.event_end_dt_tm ,
         link_ceid = cnvtreal (eksdata->tqual[tinx ].qual[link_indx ].data[(d.seq + 1 ) ].misc ) ,
         encntrid = ce.encntr_id
        DETAIL
         IF ((eventenddttm != ce.event_end_dt_tm ) ) bdiffeventenddttm_ind = 1
         ENDIF
         ,
         IF ((encntrid != ce.encntr_id ) ) bdiffencntrid_ind = 1
         ENDIF
        WITH nocounter
       ;end select
       IF ((bdiffeventenddttm_ind = 1 ) )
        SET msg = concat ("Cannot link to logic template " ,trim (link ) ,
         " because not all clinical events had the same event end time." )
        SET retval = - (1 )
        GO TO endprogram
       ELSE
        IF ((bdiffencntrid_ind = 1 ) )
         SET msg = concat ("Cannot link to logic template " ,trim (link ) ,
          " because not all clinical events had the same encounter id." )
         SET retval = - (1 )
         GO TO endprogram
        ELSE
         CALL echo ("All clinical events had matching encntr_id's and event_end_dt_tm's" )
         SELECT INTO "nl:"
          ce.clinical_event_id ,
          ce.encntr_id ,
          ce.event_end_dt_tm ,
          ce.order_id
          FROM (clinical_event ce )
          WHERE (ce.clinical_event_id = link_ceid )
          DETAIL
           link_encntr = ce.encntr_id ,
           link_personid = ce.person_id ,
           link_event_end_dt_tm = ce.event_end_dt_tm ,
           link_event_start_dt_tm = ce.event_start_dt_tm ,
           link_orderid = ce.order_id ,
           link_event_id = ce.event_id ,
           link_event_cd = ce.event_cd ,
           link_task_assay_cd = ce.task_assay_cd ,
           link_ce_dynamic_label_id = ce.ce_dynamic_label_id
          WITH nocounter
         ;end select
        ENDIF
       ENDIF
      ENDIF
     ELSE
      SET link_ceid = eksdata->tqual[tinx ].qual[link_indx ].clinical_event_id
      IF ((link_ceid <= 0 ) )
       SET msg = concat ("no valid clinical_event_id setup in misc area from linked logic template "
        ,trim (link ) )
       CALL echo (msg )
       SET link_encntr = eksdata->tqual[tinx ].qual[link_indx ].encntr_id
       SET link_personid = eksdata->tqual[tinx ].qual[link_indx ].person_id
       CALL echo (build2 ("tinx = " ,tinx ,"  and link_indx = " ,link_indx ,"  link_encntr = " ,
         eksdata->tqual[tinx ].qual[link_indx ].encntr_id ) )
       IF ((link_encntr <= 0 ) )
        SET msg = concat ("Invalid encntr_id from linked logic template " ,trim (link ) )
        SET retval = - (1 )
        GO TO endprogram
       ENDIF
       CALL echo ("Current date/time will be used for event_end and event_start_dt_tm" )
       SET link_event_end_dt_tm = todaynowdttm
       SET link_event_start_dt_tm = link_event_end_dt_tm
       SET link_orderid = 0.0
       SET link_event_id = 0.0
       SET link_event_cd = 0.0
       SET link_task_assay_cd = 0.0
       SET link_ce_dynamic_label_id = 0.0
      ELSE
       SELECT INTO "nl:"
        ce.clinical_event_id ,
        ce.encntr_id ,
        ce.event_end_dt_tm ,
        ce.order_id
        FROM (clinical_event ce )
        WHERE (ce.clinical_event_id = link_ceid )
        DETAIL
         link_encntr = ce.encntr_id ,
         link_personid = ce.person_id ,
         link_event_end_dt_tm = ce.event_end_dt_tm ,
         link_event_start_dt_tm = ce.event_start_dt_tm ,
         link_orderid = ce.order_id ,
         link_event_id = ce.event_id ,
         link_event_cd = ce.event_cd ,
         link_task_assay_cd = ce.task_assay_cd ,
         link_ce_dynamic_label_id = ce.ce_dynamic_label_id
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ELSE
   SET msg = concat ("This template can not run successfully without link" )
   SET retval = - (1 )
   GO TO endprogram
  ENDIF
 ENDIF
 IF ((tname IN ("EKS_CE_CREATE_DATE_CE_A" ,
 "EKS_CE_UPDATE_DATE_CE_A" ) ) )
  DECLARE opt_anchor_dt_ind = i2
  DECLARE link_anchor_dt_tm = dq8
  RECORD opt_anchor_dtlist (
    1 cnt = i4
    1 qual [* ]
      2 value = vc
      2 display = vc
  )
  SET value1list->cnt = event_namelist->cnt
  SET stat = alterlist (value1list->qual ,value1list->cnt )
  IF ((validate (opt_anchor_dt ,"Z" ) = "Z" )
  AND (validate (opt_anchor_dt ,"Y" ) = "Y" ) )
   SET msg = "Parameter OPT_ANCHOR_DT does not exist!"
   SET retval = - (1 )
   GO TO endprogram
  ELSEIF ((((trim (opt_anchor_dt ) <= " " ) ) OR ((trim (opt_anchor_dt ) = "<undefined>" ) )) )
   IF ((tname = "EKS_CE_CREATE_DATE_CE_A" ) )
    SET msg = "Required parameter ANCHOR_DT is not set!"
    SET retval = - (1 )
    GO TO endprogram
   ELSE
    CALL echo ("Optional parameter OPT_ANCHOR_DT is not set!" )
    SET opt_anchor_dt_ind = 0
   ENDIF
  ELSE
   CALL echo (opt_anchor_dt )
   SET opt_anchor_dt_ind = 1
   IF (findstring (char (6 ) ,opt_anchor_dt ) )
    CALL echo ("Multiple OPT_ANCHOR_DT's detected" )
    SET orig_param = opt_anchor_dt
    CALL echo ("parameter OPT_ANCHOR_DT: " )
    EXECUTE eks_t_parse_list WITH replace (reply ,opt_anchor_dtlist )
    FREE SET orig_param
   ELSE
    SET stat = alterlist (opt_anchor_dtlist->qual ,1 )
    SET opt_anchor_dtlist->qual[1 ].value = opt_anchor_dt
    SET opt_anchor_dtlist->qual[1 ].display = opt_anchor_dt
    SET opt_anchor_dtlist->cnt = 1
   ENDIF
   IF ((opt_anchor_dtlist->cnt != value1list->cnt ) )
    SET msg = concat ("OPT_ANCHOR_DT contained " ,build (opt_anchor_dtlist->cnt ) ,
     " value(s) while EVENT_NAME contained " ,build (event_namelist->cnt ) ,
     " value(s).  They must match." )
    SET retval = - (1 )
    GO TO endprogram
   ENDIF
   FOR (pindx = 1 TO opt_anchor_dtlist->cnt )
    SET ekssub->parse_ind = 1
    SET tmp_string = trim (cnvtupper (opt_anchor_dtlist->qual[pindx ].value ) )
    IF ((substring ((textlen (tmp_string ) - 2 ) ,3 ,tmp_string ) != " GO" ) )
     SET ekssub->orig = concat ("'" ,trim (opt_anchor_dtlist->qual[pindx ].value ) ,"'" )
    ELSE
     SET ekssub->orig = trim (opt_anchor_dtlist->qual[pindx ].value )
    ENDIF
    EXECUTE eks_t_subcalc
    DECLARE dttm_dq8_set_ind = i2 WITH protect ,noconstant (0 )
    CALL echo (concat ("Anchor date/time = " ,trim (ekssub->mod ) ) )
    CALL echo (concat ("ekssub->time_zone: " ,build (ekssub->time_zone ) ) )
    IF ((validate (ekssub->dttm_dq8 ,- (1 ) ) != - (1 ) ) )
     IF ((ekssub->dttm_dq8 > 0 ) )
      CALL echo (concat ("after eks_t_subcalc - ekssub->dttm_dq8: " ,build (ekssub->dttm_dq8 ) ,
        " -- " ,build (datetimezoneformat (ekssub->dttm_dq8 ,ekssub->time_zone ,
          "DD-MMM-YYYY HH:mm:ss ZZZ" ) ) ) )
      SET value1list->qual[pindx ].anchor_dt_tm = ekssub->dttm_dq8
      SET dttm_dq8_set_ind = 1
     ENDIF
    ENDIF
    IF ((dttm_dq8_set_ind <= 0 ) )
     CALL echo ("Variable ekssub->dttm_dq8 is not set. Using ekssub->mod." )
     SET value1list->qual[pindx ].anchor_dt_tm = cnvtdatetime (trim (ekssub->mod ) )
     CALL echo (build ("Converted anchor date/time = " ,value1list->qual[pindx ].anchor_dt_tm ) )
    ENDIF
    IF ((value1list->qual[pindx ].anchor_dt_tm <= 0 ) )
     SET msg = "Invalid value of the OPT_ANCHOR_DT parameter!"
     SET retval = - (1 )
     GO TO endprogram
    ENDIF
   ENDFOR
  ENDIF
  RECORD opt_offset_daylist (
    1 cnt = i4
    1 qual [* ]
      2 value = vc
      2 display = vc
      2 i_value = i4
  )
  IF ((validate (opt_offset_day ,"Z" ) = "Z" )
  AND (validate (opt_offset_day ,"Y" ) = "Y" ) )
   SET msg = "Parameter OPT_OFFSET_DAY does not exist!"
   SET retval = - (1 )
   GO TO endprogram
  ELSEIF ((((trim (opt_offset_day ) <= " " ) ) OR ((trim (opt_offset_day ) = "<undefined>" ) )) )
   CALL echo ("Optional parameter OPT_OFFSET_DAY is not set!" )
   SET stat = alterlist (opt_offset_daylist->qual ,value1list->cnt )
   SET opt_offset_daylist->cnt = value1list->cnt
  ELSE
   CALL echo (opt_offset_day )
   IF (findstring (char (6 ) ,opt_offset_day ) )
    CALL echo ("Multiple OPT_OFFSET_DAY's detected" )
    SET orig_param = opt_offset_day
    CALL echo ("parameter OPT_OFFSET_DAY: " )
    EXECUTE eks_t_parse_list WITH replace (reply ,opt_offset_daylist )
    FREE SET orig_param
   ELSE
    SET stat = alterlist (opt_offset_daylist->qual ,1 )
    SET opt_offset_daylist->qual[1 ].value = opt_offset_day
    SET opt_offset_daylist->qual[1 ].display = opt_offset_day
    SET opt_offset_daylist->cnt = 1
   ENDIF
   IF ((opt_offset_daylist->cnt != value1list->cnt ) )
    SET msg = concat ("OPT_OFFSET_DAY contained " ,build (opt_offset_daylist->cnt ) ,
     " value(s) while EVENT_NAME contained " ,build (event_namelist->cnt ) ,
     " value(s).  They must match." )
    SET retval = - (1 )
    GO TO endprogram
   ENDIF
   FOR (pindx = 1 TO opt_offset_daylist->cnt )
    IF ((findstring ("@" ,opt_offset_daylist->qual[pindx ].value ) > 0 ) )
     SET ekssub->parse_ind = 0
     SET ekssub->orig = trim (opt_offset_daylist->qual[pindx ].value )
     EXECUTE eks_t_subcalc
     SET tmpoffsetvalue = trim (ekssub->mod )
    ELSE
     SET tmpoffsetvalue = trim (opt_offset_daylist->qual[pindx ].value )
    ENDIF
    IF (isnumeric (tmpoffsetvalue ) )
     SET opt_offset_daylist->qual[pindx ].i_value = cnvtint (tmpoffsetvalue )
    ELSE
     SET msg = "Value of the OPT_OFFSET_DAY parameter is not numeric!"
     SET retval = - (1 )
     GO TO endprogram
    ENDIF
   ENDFOR
  ENDIF
  RECORD opt_offset_hourlist (
    1 cnt = i4
    1 qual [* ]
      2 value = vc
      2 display = vc
      2 i_value = i4
  )
  IF ((validate (opt_offset_hour ,"Z" ) = "Z" )
  AND (validate (opt_offset_hour ,"Y" ) = "Y" ) )
   SET msg = "Parameter OPT_OFFSET_HOUR does not exist!"
   SET retval = - (1 )
   GO TO endprogram
  ELSEIF ((((trim (opt_offset_hour ) <= " " ) ) OR ((trim (opt_offset_hour ) = "<undefined>" ) )) )
   CALL echo ("Optional parameter OPT_OFFSET_HOUR is not set!" )
   SET stat = alterlist (opt_offset_hourlist->qual ,value1list->cnt )
   SET opt_offset_hourlist->cnt = value1list->cnt
  ELSE
   CALL echo (opt_offset_hour )
   IF (findstring (char (6 ) ,opt_offset_hour ) )
    CALL echo ("Multiple OPT_OFFSET_HOUR's detected" )
    SET orig_param = opt_offset_hour
    CALL echo ("parameter OPT_OFFSET_HOUR: " )
    EXECUTE eks_t_parse_list WITH replace (reply ,opt_offset_hourlist )
    FREE SET orig_param
   ELSE
    SET stat = alterlist (opt_offset_hourlist->qual ,1 )
    SET opt_offset_hourlist->qual[1 ].value = opt_offset_hour
    SET opt_offset_hourlist->qual[1 ].display = opt_offset_hour
    SET opt_offset_hourlist->cnt = 1
   ENDIF
   IF ((opt_offset_hourlist->cnt != value1list->cnt ) )
    SET msg = concat ("OPT_OFFSET_HOUR contained " ,build (opt_offset_hourlist->cnt ) ,
     " value(s) while EVENT_NAME contained " ,build (event_namelist->cnt ) ,
     " value(s).  They must match." )
    SET retval = - (1 )
    GO TO endprogram
   ENDIF
   FOR (pindx = 1 TO opt_offset_hourlist->cnt )
    IF ((findstring ("@" ,opt_offset_hourlist->qual[pindx ].value ) > 0 ) )
     SET ekssub->parse_ind = 0
     SET ekssub->orig = trim (opt_offset_hourlist->qual[pindx ].value )
     EXECUTE eks_t_subcalc
     SET tmpoffsetvalue = trim (ekssub->mod )
    ELSE
     SET tmpoffsetvalue = trim (opt_offset_hourlist->qual[pindx ].value )
    ENDIF
    IF (isnumeric (tmpoffsetvalue ) )
     SET opt_offset_hourlist->qual[pindx ].i_value = cnvtint (tmpoffsetvalue )
    ELSE
     SET msg = "Value of the OPT_OFFSET_HOUR parameter is not numeric!"
     SET retval = - (1 )
     GO TO endprogram
    ENDIF
   ENDFOR
  ENDIF
  RECORD opt_offset_minlist (
    1 cnt = i4
    1 qual [* ]
      2 value = vc
      2 display = vc
      2 i_value = i4
  )
  IF ((validate (opt_offset_min ,"Z" ) = "Z" )
  AND (validate (opt_offset_min ,"Y" ) = "Y" ) )
   SET msg = "Parameter OPT_OFFSET_MIN does not exist!"
   SET retval = - (1 )
   GO TO endprogram
  ELSEIF ((((trim (opt_offset_min ) <= " " ) ) OR ((trim (opt_offset_min ) = "<undefined>" ) )) )
   CALL echo ("Optional parameter OPT_OFFSET_MIN is not set!" )
   SET stat = alterlist (opt_offset_minlist->qual ,value1list->cnt )
   SET opt_offset_minlist->cnt = value1list->cnt
  ELSE
   CALL echo (opt_offset_min )
   IF (findstring (char (6 ) ,opt_offset_min ) )
    CALL echo ("Multiple OPT_OFFSET_MIN's detected" )
    SET orig_param = opt_offset_min
    CALL echo ("parameter OPT_OFFSET_MIN: " )
    EXECUTE eks_t_parse_list WITH replace (reply ,opt_offset_minlist )
    FREE SET orig_param
   ELSE
    SET stat = alterlist (opt_offset_minlist->qual ,1 )
    SET opt_offset_minlist->qual[1 ].value = opt_offset_min
    SET opt_offset_minlist->qual[1 ].display = opt_offset_min
    SET opt_offset_minlist->cnt = 1
   ENDIF
   IF ((opt_offset_minlist->cnt != value1list->cnt ) )
    SET msg = concat ("OPT_OFFSET_MIN contained " ,build (opt_offset_minlist->cnt ) ,
     " value(s) while EVENT_NAME contained " ,build (event_namelist->cnt ) ,
     " value(s).  They must match." )
    SET retval = - (1 )
    GO TO endprogram
   ENDIF
   FOR (pindx = 1 TO opt_offset_minlist->cnt )
    IF ((findstring ("@" ,opt_offset_min ) > 0 ) )
     SET ekssub->parse_ind = 0
     SET ekssub->orig = trim (opt_offset_minlist->qual[pindx ].value )
     EXECUTE eks_t_subcalc
     SET tmpoffsetvalue = trim (ekssub->mod )
    ELSE
     SET tmpoffsetvalue = trim (opt_offset_minlist->qual[pindx ].value )
    ENDIF
    IF (isnumeric (tmpoffsetvalue ) )
     SET opt_offset_minlist->qual[pindx ].i_value = cnvtint (tmpoffsetvalue )
    ELSE
     SET msg = "Value of the OPT_OFFSET_MIN parameter is not numeric!"
     SET retval = - (1 )
     GO TO endprogram
    ENDIF
   ENDFOR
  ENDIF
  IF (ce_update_ind
  AND (opt_anchor_dt_ind = 0 ) )
   SELECT INTO "nl:"
    FROM (ce_date_result cdr )
    WHERE (cdr.event_id = link_event_id )
    AND (cdr.valid_until_dt_tm > cnvtdatetime (sysdate ) )
    DETAIL
     link_anchor_dt_tm = cdr.result_dt_tm
    WITH nocounter
   ;end select
   IF ((link_anchor_dt_tm > 0 ) )
    CALL echo (concat ("Anchor date/timer from the CE_DATE_RESULT = " ,format (link_anchor_dt_tm ,
       ";;q" ) ) )
   ELSE
    SET msg = concat ("Anchor date/timer from the CE_DATE_RESULT = 0!" )
    SET retval = - (1 )
    GO TO endprogram
   ENDIF
  ENDIF
  FOR (pindx = 1 TO value1list->cnt )
   IF ((opt_anchor_dt_ind = 0 ) )
    CALL echo ("opt_anchor_dt_ind = 0" )
    SET value1list->qual[pindx ].anchor_dt_tm = link_anchor_dt_tm
   ENDIF
   SET value1list->qual[pindx ].offset = ((opt_offset_daylist->qual[pindx ].i_value + (
   opt_offset_hourlist->qual[pindx ].i_value / 24.0 ) ) + (opt_offset_minlist->qual[pindx ].i_value
   / 1440.0 ) )
   CALL echo (build ("Offset = " ,opt_offset_daylist->qual[pindx ].i_value ," + " ,
     opt_offset_hourlist->qual[pindx ].i_value ,"/24.0 + " ,opt_offset_minlist->qual[pindx ].i_value
     ,"/1440.0 = " ,value1list->qual[pindx ].offset ) )
   SET value1list->qual[pindx ].result_dt_tm = datetimeadd (value1list->qual[pindx ].anchor_dt_tm ,
    value1list->qual[pindx ].offset )
   SET value1list->qual[pindx ].value = format (value1list->qual[pindx ].result_dt_tm ,";;q" )
   CALL echo (concat ("New date - <" ,value1list->qual[pindx ].value ,">." ) )
   SET value1list->qual[pindx ].display = value1list->qual[pindx ].value
   SET value1list->qual[pindx ].event_class_cd = date_cd
   SET value1list->qual[pindx ].r_value = value1list->qual[pindx ].result_dt_tm
   SET value1list->qual[pindx ].alpha_value = value1list->qual[pindx ].value
  ENDFOR
  SET value1 = value1list->qual[1 ].display
 ENDIF
 IF ((validate (resend ,"Z" ) = "Z" )
 AND (validate (resend ,"Y" ) = "Y" ) )
  SET msg = "RESEND parameter does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSEIF (NOT ((trim (cnvtlower (resend ) ) IN ("do" ,
 "do not" ) ) ) )
  SET msg = concat ("RESEND value of *" ,trim (cnvtlower (resend ) ) ," not 'do' or 'do not'" )
  SET retval = - (1 )
  GO TO endprogram
 ENDIF
 DECLARE idynamiclabelind = i2 WITH protect ,noconstant (0 )
 IF ((validate (opt_inherit_dyn_label ,"Z" ) = "Z" )
 AND (validate (opt_inherit_dyn_label ,"Y" ) = "Y" ) )
  CALL echo ("OPT_INHERIT_DYN_LABEL parameter does not exist." )
  SET link_ce_dynamic_label_id = 0.0
 ELSEIF (NOT ((trim (cnvtlower (opt_inherit_dyn_label ) ) IN ("do" ,
 "do not" ) ) ) )
  SET msg = concat ("OPT_INHERIT_DYN_LABEL value of *" ,trim (cnvtlower (opt_inherit_dyn_label ) ) ,
   " not 'do' or 'do not'" )
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET idynamiclabelind = 1
  CALL echo (concat ("template is using OPT_INHERIT_DYN_LABEL with value of '" ,build (
     opt_inherit_dyn_label ) ,"'" ) )
  IF ((trim (cnvtlower (opt_inherit_dyn_label ) ) = "do not" ) )
   SET link_ce_dynamic_label_id = 0.0
  ENDIF
 ENDIF
 IF (ce_update_ind )
  SET msg = concat ("Update the clinical event in Logic Template " ,trim (cnvtstring (link ) ) ,
   " using " )
 ELSE
  SET msg = concat ("Create a new clinical event on the same encounter as " ,trim (cnvtstring (link
     ) ) ," using " )
 ENDIF
 SET msg = concat (trim (msg ) ," " ,statuslist->qual[1 ].display )
 IF ((opt_normalcylist->cnt > 0 ) )
  SET msg = concat (trim (msg ) ," " ,opt_normalcylist->qual[1 ].display )
 ENDIF
 IF ((event_namelist->cnt > 0 ) )
  SET msg = concat (trim (msg ) ," " ,event_namelist->qual[1 ].display )
 ENDIF
 IF ((trim (subcalc->value1 ) > "" ) )
  SET msg = concat (trim (msg ) ," result of " ,trim (value1list->qual[1 ].display ) )
 ELSE
  SET msg = concat (trim (msg ) ," keeping the existing result" )
 ENDIF
 IF ((opt_comment_typelist->cnt > 0 ) )
  SET msg = concat (trim (msg ) ," with comment type of " ,opt_comment_typelist->qual[1 ].display )
 ENDIF
 SET msg = concat (trim (msg ) ," and " ,trim (cnvtlower (resend ) ) ,
  " send this event back through Expert" )
 CALL echo (msg ,1 ,0 )
 SET msg = " "
 SET contributor_system_cd = 0.0
 SET iret = uar_get_meaning_by_codeset (89 ,"POWERCHART" ,1 ,contributor_system_cd )
 IF ((contributor_system_cd <= 0 ) )
  SET msg = "There is no cdf_meaning named DISCRNEXPERT under codeset 89 in database."
  SET retval = - (1 )
  GO TO endprogram
 ENDIF
 SET record_status_cd = 0.0
 SET iret = uar_get_meaning_by_codeset (48 ,"ACTIVE" ,1 ,record_status_cd )
 IF ((record_status_cd <= 0 ) )
  SET msg = "There is no cdf_meaning named ACTIVE under codeset 48 in database."
  SET retval = - (1 )
  GO TO endprogram
 ENDIF
 SET non_chartable_flag = 0
 SET iret = uar_get_meaning_by_codeset (23 ,"AH" ,1 ,note_format_cd )
 IF ((note_format_cd <= 0 ) )
  SET msg = "There is no cdf_meaning named AH under codeset 23 in database."
  SET retval = - (1 )
  GO TO endprogram
 ENDIF
 SUBROUTINE  striprtf (_argrtf )
  SET outbuf = fillstring (32538 ," " )
  SET bflag = 0
  SET inbuf = replace (inbuf ,"\tab" ,char (9 ) ,0 )
  SET inbuf = replace (inbuf ,"\pard" ," " ,0 )
  SET inlen = size (trim (inbuf ) )
  SET outlen = 32538
  SET stat = uar_rtf2 (inbuf ,inlen ,outbuf ,outlen ,32538 ,bflag )
 END ;Subroutine
 SET entry_method_cd = 0.0
 SET iret = uar_get_meaning_by_codeset (13 ,"EKS" ,1 ,entry_method_cd )
 IF ((entry_method_cd <= 0 ) )
  SET msg = "There is no cdf_meaning named EKS under codeset 13 in database."
  SET retval = - (1 )
  GO TO endprogram
 ENDIF
 SET compression_cd = 0.0
 SET iret = uar_get_meaning_by_codeset (120 ,"OCFCOMP" ,1 ,compression_cd )
 IF ((compression_cd <= 0 ) )
  SET msg = "There is no cdf_meaning named OCFCOMP under codeset 120 in database."
  SET retval = - (1 )
  GO TO endprogram
 ENDIF
 SET action_type_cd_v = 0.0
 SET iret = uar_get_meaning_by_codeset (21 ,"VERIFY" ,1 ,action_type_cd_v )
 IF ((action_type_cd_v <= 0 ) )
  SET msg = "There is no cdf_meaning named VERIFY under codeset 21 in the database."
 ENDIF
 SET action_type_cd_p = 0.0
 SET iret = uar_get_meaning_by_codeset (21 ,"PERFORM" ,1 ,action_type_cd_p )
 IF ((action_type_cd_p <= 0 ) )
  SET msg = "There is no cdf_meaning named PERFORM under codeset 21 in the database."
 ENDIF
 SET action_type_cd_m = 0.0
 SET iret = uar_get_meaning_by_codeset (21 ,"MODIFY" ,1 ,action_type_cd_m )
 IF ((action_type_cd_m <= 0 ) )
  SET msg = "There is no cdf_meaning named MODIFY under codeset 21 in the database."
 ENDIF
 SET action_status_cd = 0.0
 SET iret = uar_get_meaning_by_codeset (103 ,"COMPLETED" ,1 ,action_status_cd )
 IF ((action_status_cd <= 0 ) )
  SET msg = "There is no cdf_meaning named COMPLETED under codeset 103 in the database."
 ENDIF
 SET cerequest->ensure_type = 2
 IF ((trim (cnvtlower (resend ) ) = "do" ) )
  SET cerequest->ensure_type2 = 0
  CALL echo ("This event ensure WILL be sent back through Discern Expert" ,1 ,0 )
 ELSE
  SET cerequest->ensure_type2 = 1
  CALL echo ("This event ensure WILL NOT be sent back through Discern Expert" ,1 ,0 )
 ENDIF
 SET cerequest->clin_event[1 ].contributor_system_cd = contributor_system_cd
 SET cerequest->clin_event[1 ].performed_dt_tm = todaynowdttm
 SET cerequest->clin_event[1 ].performed_dt_tm_ind = 0
 SET cerequest->clin_event[1 ].verified_prsnl_id = event_updt_id
 SET cerequest->clin_event[1 ].updt_dt_tm = todaynowdttm
 SET cerequest->clin_event[1 ].updt_dt_tm_ind = 0
 SET cerequest->clin_event[1 ].updt_id = event_updt_id
 SET cerequest->clin_event[1 ].updt_task = reqinfo->updt_task
 SET cerequest->clin_event[1 ].updt_task_ind = 0
 SET cerequest->clin_event[1 ].updt_applctx = reqinfo->updt_applctx
 SET cerequest->clin_event[1 ].updt_applctx_ind = 0
 SET cerequest->clin_event[1 ].view_level = 1
 SET cerequest->clin_event[1 ].view_level_ind = 0
 SET cerequest->clin_event[1 ].publish_flag = 1
 SET cerequest->clin_event[1 ].publish_flag_ind = 0
 SET cerequest->clin_event[1 ].entry_mode_cd =      679378.00
 SET cerequest->clin_event[1 ].ce_dynamic_label_id = link_ce_dynamic_label_id
 IF (NOT (ce_update_ind ) )
  SET cerequest->clin_event[1 ].person_id = link_personid
  SET cerequest->clin_event[1 ].event_start_dt_tm = link_event_start_dt_tm
  SET cerequest->clin_event[1 ].event_start_dt_tm_ind = 0
  SET cerequest->clin_event[1 ].event_end_dt_tm = link_event_end_dt_tm
  SET cerequest->clin_event[1 ].event_end_dt_tm_ind = 0
  SET cerequest->clin_event[1 ].event_end_dt_tm_os_ind = 1
  SET cerequest->clin_event[1 ].record_status_cd = record_status_cd
  SET cerequest->clin_event[1 ].authentic_flag_ind = 1
  SET cerequest->clin_event[1 ].publish_flag = 1
  SET cerequest->clin_event[1 ].publish_flag_ind = 0
  SET cerequest->clin_event[1 ].expiration_dt_tm_ind = 1
  SET cerequest->clin_event[1 ].valid_until_dt_tm_ind = 1
  SET cerequest->clin_event[1 ].valid_from_dt_tm_ind = 1
  SET cerequest->clin_event[1 ].verified_dt_tm_ind = 1
  SET cerequest->clin_event[1 ].encntr_id = link_encntr
  SET cerequest->clin_event[1 ].performed_prsnl_id = event_updt_id
  CALL echo (concat ("New Clinical Event will be associated with encntr_id:  " ,build (link_encntr )
    ) )
 ELSE
  SET cerequest->clin_event[1 ].event_id = link_event_id
  CALL echo (concat ("Updating event_id " ,trim (cnvtstring (link_event_id ,25 ,1 ) ) ) ,1 ,0 )
 ENDIF
 IF (NOT ((tname IN ("EKS_CE_CREATE_DATE_CE_A" ,
 "EKS_CE_UPDATE_DATE_CE_A" ,
 "EKS_CE_CREATE_CODED_CE_A" ,
 "EKS_CE_UPDATE_CODED_CE_A" ) ) ) )
  IF (((NOT (ce_update_ind ) ) OR ((trim (value1 ) > " " )
  AND (trim (value1 ) != "<undefined>" ) )) )
   SET stat = alterlist (cerequest->clin_event[1 ].string_result ,1 )
   SET cerequest->clin_event[1 ].string_result[1 ].valid_from_dt_tm = todaynowdttm
   SET cerequest->clin_event[1 ].string_result[1 ].valid_from_dt_tm_ind = 0
   SET cerequest->clin_event[1 ].string_result[1 ].valid_until_dt_tm = cnvtdatetime (
    "31-DEC-2100 00:00:00" )
   SET cerequest->clin_event[1 ].string_result[1 ].valid_until_dt_tm_ind = 0
   SET cerequest->clin_event[1 ].string_result[1 ].last_norm_dt_tm_ind = 1
   SET cerequest->clin_event[1 ].string_result[1 ].feasible_ind_ind = 1
   SET cerequest->clin_event[1 ].string_result[1 ].inaccurate_ind_ind = 1
   SET cerequest->clin_event[1 ].string_result[1 ].valid_from_dt_tm_ind = 1
   SET cerequest->clin_event[1 ].string_result[1 ].valid_until_dt_tm_ind = 1
   SET cerequest->clin_event[1 ].string_result[1 ].updt_dt_tm = todaynowdttm
   SET cerequest->clin_event[1 ].string_result[1 ].updt_dt_tm_ind = 0
   SET cerequest->clin_event[1 ].string_result[1 ].updt_id = event_updt_id
   SET cerequest->clin_event[1 ].string_result[1 ].updt_task = reqinfo->updt_task
   SET cerequest->clin_event[1 ].string_result[1 ].updt_task_ind = 0
   SET cerequest->clin_event[1 ].string_result[1 ].updt_cnt_ind = 1
   SET cerequest->clin_event[1 ].string_result[1 ].updt_applctx = reqinfo->updt_applctx
   SET cerequest->clin_event[1 ].string_result[1 ].updt_applctx_ind = 0
  ENDIF
 ENDIF
 IF (ce_update_ind )
  SET stat = alterlist (cerequest->clin_event[1 ].event_prsnl_list ,1 )
  SET cerequest->clin_event.event_prsnl_list[1 ].person_id = personid
  SET cerequest->clin_event.event_prsnl_list[1 ].event_id = link_event_id
  SET cerequest->clin_event.event_prsnl_list[1 ].action_type_cd = action_type_cd_m
  SET cerequest->clin_event.event_prsnl_list[1 ].request_dt_tm_ind = 1
  SET cerequest->clin_event.event_prsnl_list[1 ].action_dt_tm = todaynowdttm
  SET cerequest->clin_event.event_prsnl_list[1 ].action_prsnl_id = event_updt_id
  SET cerequest->clin_event.event_prsnl_list[1 ].action_status_cd = action_status_cd
  SET cerequest->clin_event.event_prsnl_list[1 ].valid_until_dt_tm = cnvtdatetime (
   "31-DEC-2100 00:00:00" )
 ELSE
  SET stat = alterlist (cerequest->clin_event[1 ].event_prsnl_list ,2 )
  SET cerequest->clin_event.event_prsnl_list[1 ].person_id = personid
  SET cerequest->clin_event.event_prsnl_list[1 ].action_type_cd = action_type_cd_v
  SET cerequest->clin_event.event_prsnl_list[1 ].request_dt_tm_ind = 1
  SET cerequest->clin_event.event_prsnl_list[1 ].action_dt_tm = todaynowdttm
  SET cerequest->clin_event.event_prsnl_list[1 ].action_prsnl_id = event_updt_id
  SET cerequest->clin_event.event_prsnl_list[1 ].action_status_cd = action_status_cd
  SET cerequest->clin_event.event_prsnl_list[1 ].valid_until_dt_tm = cnvtdatetime (
   "31-DEC-2100 00:00:00" )
  SET cerequest->clin_event.event_prsnl_list[2 ].person_id = personid
  SET cerequest->clin_event.event_prsnl_list[2 ].action_type_cd = action_type_cd_p
  SET cerequest->clin_event.event_prsnl_list[2 ].request_dt_tm_ind = 1
  SET cerequest->clin_event.event_prsnl_list[2 ].action_dt_tm = todaynowdttm
  SET cerequest->clin_event.event_prsnl_list[2 ].action_prsnl_id = event_updt_id
  SET cerequest->clin_event.event_prsnl_list[2 ].action_status_cd = action_status_cd
  SET cerequest->clin_event.event_prsnl_list[2 ].valid_until_dt_tm = cnvtdatetime (
   "31-DEC-2100 00:00:00" )
 ENDIF
 FOR (pindx = 1 TO event_namelist->cnt )
  SET cerequest->clin_event[1 ].result_status_cd = cnvtreal (statuslist->qual[pindx ].value )
  IF (NOT (ce_update_ind ) )
   SET cerequest->clin_event[1 ].event_cd = cnvtreal (event_namelist->qual[pindx ].value )
  ENDIF
  CALL echo (concat ("--- tname: " ,build (tname ) ) )
  IF ((tname IN ("EKS_CE_CREATE_CODED_CE_A" ,
  "EKS_CE_UPDATE_CODED_CE_A" ) ) )
   CALL echo ("for EKS_CE_CREATE_CODED_CE_A or EKS_CE_UPDATE_CODED_CE_A" )
   SET cerequest->clin_event[1 ].event_class_cd = cnvtreal (value1list->qual[pindx ].event_class_cd
    )
   CALL echo (build ("link_event_id = " ,link_event_id ) )
   CALL echo (concat ("--- MultValueInd: " ,build (multvalueind ) ) )
   IF ((multvalueind > 0 ) )
    SET stat = alterlist (cerequest->clin_event.coded_result_list ,value1list->cnt )
    SET ii = 0
    FOR (cridx = 1 TO value1list->cnt )
     IF ((value1list->qual[cridx ].r_value > 0 ) )
      SET ii +=1
      SET cerequest->clin_event.coded_result_list[ii ].nomenclature_id = value1list->qual[cridx ].
      r_value
      SET cerequest->clin_event.coded_result_list[ii ].unit_of_measure_cd = cnvtreal (
       opt_result_unitslist->qual[pindx ].value )
      SET cerequest->clin_event.coded_result_list[ii ].descriptor = value1list->qual[cridx ].
      alpha_value
      IF (ce_update_ind )
       SET cerequest->clin_event.coded_result_list[ii ].event_id = link_event_id
       SET cerequest->clin_event.coded_result_list[ii ].sequence_nbr = cridx
       SET cerequest->clin_event.coded_result_list[ii ].ensure_type = (cerequest->ensure_type + 256
       )
      ENDIF
     ENDIF
    ENDFOR
    IF ((ii < value1list->cnt ) )
     SET stat = alterlist (cerequest->clin_event.coded_result_list ,ii )
    ENDIF
   ELSE
    IF ((value1list->qual[pindx ].r_value > 0 ) )
     SET stat = alterlist (cerequest->clin_event.coded_result_list ,1 )
     SET cerequest->clin_event.coded_result_list[1 ].nomenclature_id = value1list->qual[pindx ].
     r_value
     SET cerequest->clin_event.coded_result_list[1 ].unit_of_measure_cd = cnvtreal (
      opt_result_unitslist->qual[pindx ].value )
     SET cerequest->clin_event.coded_result_list[1 ].descriptor = value1list->qual[pindx ].
     alpha_value
     IF (ce_update_ind )
      SET cerequest->clin_event.coded_result_list[1 ].event_id = link_event_id
      SET cerequest->clin_event.coded_result_list[1 ].sequence_nbr = 1
      SET cerequest->clin_event.coded_result_list[1 ].ensure_type = (cerequest->ensure_type + 256 )
     ENDIF
    ENDIF
   ENDIF
   IF ((value1list->qual[pindx ].alpha_value > " " )
   AND (value1list->qual[pindx ].alpha_value != "<undefined>" ) )
    FOR (ii = 1 TO value1list->cnt )
     IF ((ii = 1 ) )
      SET cerequest->clin_event[1 ].event_tag = trim (value1list->qual[ii ].alpha_value )
     ELSE
      SET cerequest->clin_event[1 ].event_tag = concat (trim (cerequest->clin_event[1 ].event_tag ) ,
       ", " ,trim (value1list->qual[ii ].alpha_value ) )
     ENDIF
    ENDFOR
    SET cerequest->clin_event[1 ].event_class_cd = cnvtreal (value1list->qual[pindx ].event_class_cd
     )
    SET cerequest->clin_event[1 ].normalcy_cd = cnvtreal (opt_normalcylist->qual[pindx ].value )
    CALL echo ("Value and normalcy are set" )
   ELSEIF ((opt_normalcylist->qual[pindx ].value > " " )
   AND (opt_normalcylist->qual[pindx ].value != "<undefined>" ) )
    SET cerequest->clin_event[1 ].event_class_cd = cnvtreal (value1list->qual[pindx ].event_class_cd
     )
    SET cerequest->clin_event[1 ].normalcy_cd = cnvtreal (opt_normalcylist->qual[pindx ].value )
    CALL echo ("Only normalcy is set" )
   ENDIF
  ELSEIF ((tname IN ("EKS_CE_CREATE_DATE_CE_A" ,
  "EKS_CE_UPDATE_DATE_CE_A" ) ) )
   CALL echo ("for EKS_CE_CREATE_DATE_CE_A or EKS_CE_UPDATE_DATE_CE_A" )
   SET cerequest->clin_event[1 ].event_class_cd = cnvtreal (value1list->qual[pindx ].event_class_cd
    )
   SET stat = alterlist (cerequest->clin_event.date_result ,1 )
   SET cerequest->clin_event.date_result[1 ].result_dt_tm = value1list->qual[pindx ].result_dt_tm
   IF (ce_update_ind )
    SET cerequest->clin_event.date_result[1 ].event_id = link_event_id
   ENDIF
  ELSE
   CALL echo ("EKS_CE_CREATE_CE_A or EKS_CE_UPDATE_CE_A" )
   IF ((value1list->qual[pindx ].alpha_value > " " )
   AND (value1list->qual[pindx ].alpha_value != "<undefined>" ) )
    SET cerequest->clin_event[1 ].string_result[1 ].string_result_text = value1list->qual[pindx ].
    alpha_value
    SET cerequest->clin_event[1 ].event_tag = value1list->qual[pindx ].alpha_value
    SET cerequest->clin_event[1 ].event_class_cd = cnvtreal (value1list->qual[pindx ].event_class_cd
     )
    SET cerequest->clin_event[1 ].string_result[1 ].string_result_format_cd = cnvtreal (value1list->
     qual[pindx ].string_result_format_cd )
    SET cerequest->clin_event[1 ].string_result[1 ].unit_of_measure_cd = cnvtreal (
     opt_result_unitslist->qual[pindx ].value )
    SET cerequest->clin_event[1 ].normalcy_cd = cnvtreal (opt_normalcylist->qual[pindx ].value )
    CALL echo ("Value and normalcy are set" )
   ELSEIF ((opt_normalcylist->qual[pindx ].value > " " )
   AND (opt_normalcylist->qual[pindx ].value != "<undefined>" ) )
    SET cerequest->clin_event[1 ].event_class_cd = cnvtreal (value1list->qual[pindx ].event_class_cd
     )
    SET cerequest->clin_event[1 ].normalcy_cd = cnvtreal (opt_normalcylist->qual[pindx ].value )
    CALL echo ("Only normalcy is set" )
   ENDIF
  ENDIF
  IF ((cnvtreal (opt_comment_typelist->qual[pindx ].value ) > 0 ) )
   SET cerequest->clin_event[1 ].subtable_bit_map = 8195
   SET stat = alterlist (cerequest->clin_event[1 ].event_note_list ,1 )
   SET cerequest->clin_event.event_note_list[1 ].note_type_cd = cnvtreal (opt_comment_typelist->qual[
    pindx ].value )
   SET cerequest->clin_event.event_note_list[1 ].note_format_cd = note_format_cd
   SET cerequest->clin_event.event_note_list[1 ].entry_method_cd = entry_method_cd
   SET cerequest->clin_event.event_note_list[1 ].note_prsnl_id = event_updt_id
   SET cerequest->clin_event.event_note_list[1 ].note_dt_tm = todaynowdttm
   SET cerequest->clin_event.event_note_list[1 ].note_dt_tm_ind = 0
   SET cerequest->clin_event.event_note_list[1 ].record_status_cd = record_status_cd
   SET cerequest->clin_event.event_note_list[1 ].compression_cd = compression_cd
   SET cerequest->clin_event.event_note_list[1 ].checksum = 0
   SET cerequest->clin_event.event_note_list[1 ].checksum_ind = 1
   SET cerequest->clin_event.event_note_list[1 ].non_chartable_flag = non_chartable_flag
   SET cerequest->clin_event.event_note_list[1 ].long_blob = opt_commentlist->qual[pindx ].display
   SET cerequest->clin_event.event_note_list[1 ].valid_from_dt_tm_ind = 1
   SET cerequest->clin_event.event_note_list[1 ].valid_until_dt_tm_ind = 1
   SET cerequest->clin_event.event_note_list[1 ].updt_dt_tm = todaynowdttm
   SET cerequest->clin_event.event_note_list[1 ].updt_dt_tm_ind = 0
   SET cerequest->clin_event.event_note_list[1 ].updt_task = reqinfo->updt_task
   SET cerequest->clin_event.event_note_list[1 ].updt_task_ind = 0
   SET cerequest->clin_event.event_note_list[1 ].updt_id = event_updt_id
   SET cerequest->clin_event.event_note_list[1 ].updt_cnt_ind = 1
   SET cerequest->clin_event.event_note_list[1 ].updt_applctx = reqinfo->updt_applctx
   SET cerequest->clin_event.event_note_list[1 ].updt_applctx_ind = 0
  ELSE
   SET stat = alterlist (cerequest->clin_event[1 ].event_note_list ,0 )
   SET cerequest->clin_event[1 ].subtable_bit_map = 8193
  ENDIF
  SET retval = 0
  SET ceservertm = curtime3
  DECLARE errmsg = vc WITH protect
  DECLARE errcode = i4 WITH protect ,noconstant (0 )
  CALL echo ("tdbexecute for 1000012" )
  SET stat = tdbexecute (0 ,3055000 ,1000012 ,"REC" ,cerequest ,"REC" ,cereply ,1 )
  SET errcode = error (errmsg ,1 )
  IF ((stat != 0 ) )
   SET retval = - (1 )
   SET msg = concat ("TDBEXECUTE 1000012 - error code: " ,build (errcode ) ," with error message: " ,
    build (errmsg ) )
   GO TO endprogram
  ENDIF
  SET ceelapsed +=(maxval (0 ,(curtime3 - ceservertm ) ) / 100.0 )
  CALL echo (concat ("Total CE Server time = " ,format (ceelapsed ,"######.##" ) ," seconds" ) )
  CALL echo (concat ("retval = " ,build (retval ) ) )
  CALL echo (concat ("size of CEReply->sb->subStatusList: " ,build (size (cereply->sb.substatuslist ,
      5 ) ) ) )
  IF ((size (cereply->sb.substatuslist ,5 ) = 0 ) )
   CALL echo (concat ("Commited result for " ,event_namelist->qual[pindx ].display ) )
   IF ((trim (goodevents ) > " " ) )
    SET goodevents = concat (goodevents ,", " ,event_namelist->qual[pindx ].display )
   ELSE
    SET goodevents = event_namelist->qual[pindx ].display
   ENDIF
   SET goodstatuscnt +=1
  ELSE
   CALL echo ("size of CEReply->sb->subStatusList is > 0" )
   CALL echo (concat ("CEReply->sb->subStatusList[1]->SUBSTATUSCD: " ,build (cereply->sb.
      substatuslist[1 ].substatuscd ) ) )
   IF ((cereply->sb.substatuslist[1 ].substatuscd = 1 ) )
    CALL echo (
     "no change - meaning that the request does not differ from the existing row, nothing to write"
     )
   ELSEIF ((cereply->sb.substatuslist[1 ].substatuscd = 2 ) )
    CALL echo (
     "skipped items - meaning that some non-fatal situation caused the transaction to skip the request"
     )
   ENDIF
   CALL echo (concat ("Failed to commit result for " ,event_namelist->qual[pindx ].display ) )
   IF ((trim (badevents ) > " " ) )
    SET badevents = concat (badevents ,", " ,event_namelist->qual[pindx ].display )
   ELSE
    SET badevents = event_namelist->qual[pindx ].display
   ENDIF
   SET badstatuscnt +=1
  ENDIF
  SET event_namelist->qual[pindx ].status = retval
 ENDFOR
#endprogram
 IF ((tcurindex > 0 )
 AND (curindex > 0 ) )
  CALL echo (concat ("goodStatusCnt = " ,build (goodstatuscnt ) ,"   badStatusCnt = " ,build (
     badstatuscnt ) ) )
  CALL echo (concat ("goodEvents = " ,goodevents ,"   badEvents = " ,badevents ) )
  IF ((badstatuscnt > 0 ) )
   SET retval = - (1 )
   IF (ce_update_ind )
    SET msg = concat ("Failed to update " ,event_namelist->qual[1 ].display ," equal to " ,value1list
     ->qual[1 ].alpha_value ," " ,evaluate (trim (opt_result_unitslist->qual[1 ].display ) ,"0" ," "
      ) )
   ELSE
    SET msg = concat ("Failed to create:  " ,badevents ,".  " )
   ENDIF
  ENDIF
  IF ((goodstatuscnt > 0 ) )
   SET retval = 100
   IF (ce_update_ind )
    IF ((multvalueind > 0 ) )
     SET msg = concat ("Updated " ,event_namelist->qual[1 ].display ," equal to " )
     FOR (i = 1 TO value1list->cnt )
      SET msg = concat (msg ," " ,trim (value1list->qual[i ].alpha_value ) )
      IF ((i < value1list->cnt ) )
       SET msg = concat (msg ,"," )
      ENDIF
     ENDFOR
     SET msg = concat (msg ," for the same event_id as L" ,trim (link ) )
    ELSE
     SET msg = concat ("Updated " ,event_namelist->qual[1 ].display ," equal to " ,trim (value1list->
       qual[1 ].alpha_value ) ," " ,evaluate (trim (opt_result_unitslist->qual[1 ].display ) ,"0" ,
       " " ) ," for the same event_id as L" ,trim (link ) )
    ENDIF
   ELSE
    IF ((multvalueind > 0 ) )
     SET msg = concat (msg ,"  Created:  " ,goodevents ," equal to" )
     FOR (i = 1 TO value1list->cnt )
      SET msg = concat (msg ," " ,trim (value1list->qual[i ].alpha_value ) )
      IF ((i < value1list->cnt ) )
       SET msg = concat (msg ,"," )
      ENDIF
     ENDFOR
     SET msg = concat (msg ," on the same encounter as L" ,trim (link ) )
    ELSE
     SET msg = concat (msg ,"  Created:  " ,goodevents ," equal to " ,trim (value1list->qual[1 ].
       alpha_value ) ," on the same encounter as L" ,trim (link ) )
    ENDIF
   ENDIF
   SET accessionid = 0.0
   SET personid = link_personid
   SET orderid = link_orderid
   SET encntrid = link_encntr
   SET eksce_id = link_ceid
   SET ekstaskassaycd = link_task_assay_cd
   SET eksce_id = link_ceid
   SET rev_inc = "708"
   SET ininc = "eks_set_eksdata"
   IF ((accessionid = 0 ) )
    IF ((orderid != 0 ) )
     SELECT INTO "NL:"
      a.accession_id
      FROM (accession_order_r a )
      WHERE (a.order_id = orderid )
      AND (a.primary_flag = 0 )
      DETAIL
       accessionid = a.accession_id
      WITH nocounter
     ;end select
    ELSEIF (NOT ((validate (accession ,"Y" ) = "Y" )
    AND (validate (accession ,"Z" ) = "Z" ) ) )
     IF ((textlen (trim (accession ) ) > 0 ) )
      SELECT INTO "NL:"
       a.accession_id
       FROM (accession_order_r a )
       WHERE (a.accession = accession )
       DETAIL
        accessionid = a.accession_id
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDIF
   IF ((personid = 0 ) )
    FREE SET temp
    IF ((orderid > 0 ) )
     SELECT
      *
      FROM (orders o )
      WHERE (o.order_id = orderid )
      DETAIL
       personid = o.person_id
      WITH nocounter
     ;end select
    ELSEIF ((encntrid > 0 ) )
     SELECT
      *
      FROM (encounter en )
      WHERE (en.encntr_id = encntrid )
      DETAIL
       personid = en.person_id
      WITH nocounter
     ;end select
    ENDIF
    IF (NOT ((validate (temp ,"Y" ) = "Y" )
    AND (validate (temp ,"Z" ) = "Z" ) ) )
     SELECT INTO "nl:"
      o.person_id
      FROM (orders o )
      WHERE parser (temp )
      DETAIL
       personid = o.person_id
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   SET eksdata->tqual[tcurindex ].qual[curindex ].accession_id = accessionid
   SET eksdata->tqual[tcurindex ].qual[curindex ].order_id = orderid
   SET eksdata->tqual[tcurindex ].qual[curindex ].encntr_id = encntrid
   SET eksdata->tqual[tcurindex ].qual[curindex ].person_id = personid
   IF (NOT ((validate (ekstaskassaycd ,0 ) = 0 )
   AND (validate (ekstaskassaycd ,1 ) = 1 ) ) )
    SET eksdata->tqual[tcurindex ].qual[curindex ].task_assay_cd = ekstaskassaycd
   ELSE
    SET eksdata->tqual[tcurindex ].qual[curindex ].task_assay_cd = 0
   ENDIF
   IF (NOT ((validate (eksdata->tqual[tcurindex ].qual[curindex ].template_name ,"Y" ) = "Y" )
   AND (validate (eksdata->tqual[tcurindex ].qual[curindex ].template_name ,"Z" ) = "Z" ) ) )
    IF ((trim (eksdata->tqual[tcurindex ].qual[curindex ].template_name ) = "" )
    AND NOT ((validate (tname ,"Y" ) = "Y" )
    AND (validate (tname ,"Z" ) = "Z" ) ) )
     SET eksdata->tqual[tcurindex ].qual[curindex ].template_name = tname
    ENDIF
   ENDIF
   IF (NOT ((validate (eksce_id ,0 ) = 0 )
   AND (validate (eksce_id ,1 ) = 1 ) ) )
    IF (NOT ((validate (eksdata->tqual[tcurindex ].qual[curindex ].clinical_event_id ,0 ) = 0 )
    AND (validate (eksdata->tqual[tcurindex ].qual[curindex ].clinical_event_id ,1 ) = 1 ) ) )
     SET eksdata->tqual[tcurindex ].qual[curindex ].clinical_event_id = eksce_id
    ENDIF
   ENDIF
  ENDIF
  IF ((ceelapsed > 0 ) )
   SET msg = concat (msg ," (" ,trim (format (ceelapsed ,"######.##;L" ) ) ,"s/" ,trim (format ((
      maxval (0 ,(curtime3 - tempstarttime ) ) / 100.0 ) ,"######.##" ) ,3 ) ,"s)" )
  ELSE
   SET msg = concat (msg ," (" ,trim (format ((maxval (0 ,(curtime3 - tempstarttime ) ) / 100.0 ) ,
      "######.##" ) ,3 ) ,"s)" )
  ENDIF
  SET eksdata->tqual[tcurindex ].qual[curindex ].logging = msg
 ENDIF
 set filename = concat("cclscratch:eks_cerequest_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
 ;call echojson(cerequest,filename)
 FREE SET cerequest
 CALL echo (msg )
 CALL echo (concat (format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,"hh:mm:ss.cc;3;m" ) ,
   "  *******  End of Program eks_t_ce_create_ce_a  *********" ) )
END GO
