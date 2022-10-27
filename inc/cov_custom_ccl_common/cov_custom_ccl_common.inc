/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-2002 Cerner Corporation                 *
      *                                                                      *
      *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
      *  This material contains the valuable properties and trade secrets of *
      *  Cerner Corporation of Kansas City, Missouri, United States of       *
      *  America (Cerner), embodying substantial creative efforts and        *
      *  confidential information, ideas and expressions, no part of which   *
      *  may be reproduced or transmitted in any form or by any means, or    *
      *  retained in any storage or retrieval system without the express     *
      *  written permission of Cerner.                                       *
      *                                                                      *
      *  Cerner is a registered mark of Cerner Corporation.                  *
      *                                                                      *
  ~BE~***********************************************************************/
 
/*****************************************************************************
 
        Source file name:	cov_custom_ccl_common.inc
        Object name:
        Request #:
 
        Product:
        Product Team:
        HNA Version:
        CCL Version:
 
        Program purpose:
 
        Tables read:
 
        Tables updated:          -
        Executing from:
 
******************************************************************************/
 
 
;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date       Engineeer          Comment                             *
;    *--- ---------- ------------------ ----------------------------------- *
;	 *000 10-20-2015 cc010582           initial release					    *
;~DE~************************************************************************
 
 
;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************
call echo(build("including subroutines: cov_custom_ccl_common.inc"))
 
;the frec record structure is used by CCLIO() for the log file
record frec
	(
     1 file_desc = i4
     1 file_offset = i4
     1 file_dir = i4
     1 file_name = vc
     1 file_buf = vc
) with protect
 
;the frec record structure is used by CCLIO() for the audit file
record freca
	(
     1 file_desc = i4
     1 file_offset = i4
     1 file_dir = i4
     1 file_name = vc
     1 file_buf = vc
)  with protect
 
record drec
(
  1 line_cnt		= i4
  1 display_line 	= vc
  1 line_qual[*]
	2 disp_line		= vc
) with protect
 
 
record location_list
(
	1 location_cnt				= i4
	1 locations[*]
	 2 display					= vc
	 2 location_cd				= f8
	 2 location_type_cd			= f8
	 2 type_meaning				= vc
) with protect
 
record program_log
	(
	 1 produce_log				= i2	;0 to start a log, 1 to not create a log
	 1 produce_audit			= i2	;0 to start a log, 1 to not create a log
	 1 curdomain				= vc	;store the current domain
	 1 curprog					= vc	;current program
	 1 curnode					= vc	;current node the program is running from
	 1 display_on_exit			= i2	;display audit log on exit if 1
	 1 run_from_ops				= i2	;set to 1 if run from ops
	 1 run_from_eks				= i2 	;set to 1 if the script is executed from a rule
	 1 ops_request				= f8	;ops request number
	 1 ops_date					= dq8	;ops date
	 1 email							;list of email addresses
	  2 subject					= vc	;subject of the email
	  2 qual[*]							;array
	   3 email_address  		= vc	;email address to email
	 1 files							;files used in the program
	  2 file_path				= vc	;path to domain cclscratch
	  2 ccluserdir				= vc	;path to domain ccluserdir
	  2 filename_log 			= vc	;log filename
	  2 filename_zip			= vc	;zip filename
	  2 filename_audit 			= vc	;audit filename
	  2 filename_audit_zip		= vc	;audit zip filename
	  2 attachments_cnt			= i2	;number of attachments
	  2 attachments[*]
	   3 file_path				= vc	;path to attachments
	   3 filename				= vc    ;file_names
	1 log_cnt					= i2
	1 log_qual[*]
	 2 log_dt_tm				= dq8
	 2 start_dt_tm			 	= dq8
	 2 end_dt_tm				= dq8
	 2 hundseconds_diff			= f8
	 2 log_display				= vc
) with protect
 
;free record audit
record audit
(
	1 oef_cnt				= i4
	1 oef[*]
	 2 catalog_type_cd		= f8
	 2 oe_format_id			= f8
	 2 oe_format_name		= c200
	 2 format_action_cd		= f8
	 2 field_label_text 	= c200
	 2 oe_field_id			= f8
	 2 oe_field_meaning_id	= f8
	 2 field_description	= c100
	 2 oe_field_meaning	 	= c25
) with protect
 
;free record code_values
record code_values
	(
	1 cv
	  2 cs_4							;CS 4 person alias type cd
		3 account_number_cd = f8
		3 biometric_identifier_cd = f8
		3 childmother_tracking_number_cd = f8
		3 community_medical_record_number_cd = f8
		3 donor_number_cd = f8
		3 donor_id_cd = f8
		3 drivers_license_number_cd = f8
		3 federated_person_principal_cd = f8
		3 filler_order_cd = f8
		3 foreign_id_cd = f8
		3 hic_recipient_id_cd = f8
		3 historical_cmrn_cd = f8
		3 historical_mrn_cd = f8
		3 hnasysid_cd = f8
		3 insc_cd = f8
		3 international_donor_id_cd = f8
		3 cerners_internal_person_id_cd = f8
		3 member_number_cd = f8
		3 messaging_cd = f8
		3 militaryid_cd = f8
		3 military_pin_cd = f8
		3 health_exchange_patient_identifier_cd = f8
		3 mrn_cd = f8
		3 national_health_number_cd = f8
		3 nmdp_cd = f8
		3 nmdp_donor_id_cd = f8
		3 nmdp_recipient_id_cd = f8
		3 cerner_card_number_cd = f8
		3 opo_donor_id_cd = f8
		3 opo_recipient_id_cd = f8
		3 other_cd = f8
		3 outreach_person_identifier_cd = f8
		3 outreach_person_id_cd = f8
		3 passport_cd = f8
		3 password_cd = f8
		3 patient_id_classic_ocf_cd = f8
		3 pbs_patient_id_cd = f8
		3 person_name_cd = f8
		3 placer_order_cd = f8
		3 prn_cd = f8
		3 pxid_cd = f8
		3 referring_mrn_cd = f8
		3 state_health_number_cd = f8
		3 ssn_cd = f8
		3 taxpayer_id_cd = f8
		3 temporary_primary_id_cd = f8
		3 unos_cd = f8
		3 unos_donor_id_cd = f8
		3 version_cd = f8
		3 veteran_id_cd = f8
		3 visa_cd = f8
	  2 cs_8							;CS 8 Data Status Cd
		3 active_cd = f8
		3 altered_cd = f8
		3 anticipated_cd = f8
		3 auth_cd = f8
		3 cancelled_cd = f8
		3 c_transcribe_cd = f8
		3 dictated_cd = f8
		3 in_error_cd = f8
		3 in_lab_cd = f8
		3 in_progress_cd = f8
		3 inerrnomut_cd = f8
		3 inerrnoview_cd = f8
		3 inerror_cd = f8
		3 modified_cd = f8
		3 not_done_cd = f8
		3 rejected_cd = f8
		3 superseded_cd = f8
		3 transcribed_cd = f8
		3 unauth_cd = f8
		3 unknown_cd = f8
	  2 cs_21
	   3 inlab_cd = f8
		3 cosign_cd = f8
		3 insert_cd = f8
		3 modify_cd = f8
		3 order_cd = f8
		3 perform_cd = f8
		3 remove_cd = f8
		3 review_cd = f8
		3 sign_cd = f8
		3 start_admin_cd = f8
		3 stop_admin_cd = f8
		3 transcribe_cd = f8
		3 unknown_cd = f8
		3 verify_cd = f8
		3 assist_cd = f8
		3 author_cd = f8
		3 cancel_cd = f8
		3 collect_cd = f8
		3 correct_cd = f8
		3 convey_cd = f8
		3 endorse_cd = f8
		3 consumr_revw_cd = f8
		3 witness_cd = f8
		3 flag_cd = f8
		3 confirm_cd = f8
		3 unconfirm_cd = f8
		3 followup_cd = f8
		3 copy_cd = f8
		3 endorsesave_cd = f8
		3 unflag_cd = f8
	  2 cs_27
		3 multiple_cd = f8
		3 hispanic_latino_or_spanish_origin_cd = f8
		3 not_hispanic_latino_or_spanish_origin_cd = f8
	  2 cs_52
	   3 low_cd					= f8
	   3 high_cd				= f8
	   3 critical_cd			= f8
	  2 cs_43
		 3 alternate_cd = f8
		 3 billing_cd = f8
		 3 business_cd = f8
		 3 fax_alt_cd = f8
		 3 fax_bill_cd = f8
		 3 fax_bus_cd = f8
		 3 fax_pers_cd = f8
		 3 fax_prev_cd = f8
		 3 fax_temp_cd = f8
		 3 home_cd = f8
		 3 modem_bus_cd = f8
		 3 modem_pers_cd = f8
		 3 os_afterhour_cd = f8
		 3 os_phone_cd = f8
		 3 os_pager_cd = f8
		 3 os_bk_office_cd = f8
		 3 os_fax_cd = f8
		 3 pager_alt_cd = f8
		 3 pager_bus_cd = f8
		 3 pager_pers_cd = f8
		 3 pager_prev_cd = f8
		 3 pager_temp_cd = f8
		 3 port_bus_cd = f8
		 3 port_pers_cd = f8
		 3 port_temp_cd = f8
		 3 previous_cd = f8
		 3 temporary_cd = f8
		 3 professional_cd = f8
		 3 secbusiness_cd = f8
		 3 technical_cd = f8
		 3 verify_cd = f8
		 3 pager_bill_cd = f8
		 3 usual_cd = f8
		 3 phome_cd = f8
		 3 aam_cd = f8
		 3 paging_cd = f8
		 3 emc_cd = f8
		 3 extsecemail_cd = f8
		 3 intsecemail_cd = f8
		 3 mobile_cd = f8
	  2 cs_53
	   3 trans_cd = f8
		 3 unknown_cd = f8
		 3 ap_cd = f8
		 3 count_cd = f8
		 3 date_cd = f8
		 3 doc_cd = f8
		 3 done_cd = f8
		 3 grp_cd = f8
		 3 hlatyping_cd = f8
		 3 immun_cd = f8
		 3 interp_cd = f8
		 3 mbo_cd = f8
		 3 mdoc_cd = f8
		 3 num_cd = f8
		 3 rad_cd = f8
		 3 grpdoc_cd = f8
		 3 placeholder_cd = f8
		 3 addendum_cd = f8
		 3 clindoc_cd = f8
		 3 contribution_cd = f8
		 3 document_cd = f8
		 3 grpsection_cd = f8
		 3 section_cd = f8
		 3 scdocument_cd = f8
		 3 case_cd = f8
		 3 procedure_cd = f8
		 3 io_cd = f8
		 3 med_cd = f8
		 3 txt_cd = f8
		 3 helix_cd = f8
		 3 attachment_cd = f8
	  2 cs_69
		3 blood_donation_cd = f8
		3 case_management_cd = f8
		3 emergency_cd = f8
		3 home_health_cd = f8
		3 inbox_message_cd = f8
		3 inpatient_cd = f8
		3 observation_cd = f8
		3 outpatient_cd = f8
		3 phone_msg_cd = f8
		3 preadmit_cd = f8
		3 private_duty_cd = f8
		3 recurring_cd = f8
		3 research_cd = f8
		3 skilled_nursing_cd = f8
		3 wait_list_cd = f8
	  2 cs_71							;CS 71 Encounter Type Cd
		3 emergency_cd = f8
		3 day_surgery_cd = f8
		3 preadmit_cd = f8
		3 inpatient_cd = f8
		3 observation_cd = f8
		3 outpatient_in_a_bed_cd = f8
		3 outpatient_cd = f8
		3 outpatient_message_cd = f8
		3 recurring_cd = f8
		3 legacy_data_cd = f8
		3 prereg_cd = f8
		3 clinic_cd = f8
		3 snf_inpatient_cd = f8
		3 prerecurring_cd = f8
		3 phone_message_cd = f8
		3 adolescent_iop_cd = f8
		3 adult_iop_cd = f8
		3 advanced_pay_outpatient_cd = f8
		3 advanced_pay_pt_cd = f8
		3 hospital_adult_psych_cd = f8
		3 blount_clinic_series_cd = f8
		3 behavioral_health_cd = f8
		3 patricia_neal_outpatient_series_cd = f8
		3 cancel_admit_cd = f8
		3 cardiac_diagnostics_cd = f8
		3 contract_film_read_only_cd = f8
		3 contract_operation_health_check_cd = f8
		3 contract_cd = f8
		3 cancel_upon_review_cd = f8
		3 cheyenne_outpatient_clinic_cd = f8
		3 hospital_outpatient_cd = f8
		3 results_only_cd = f8
		3 home_infusion_cd = f8
		3 plw_cd = f8
		3 smokey_mtn_childrens_home_cd = f8
		3 diagnostic_center_outpatient_cd = f8
		3 hospital_adolescent_psych_cd = f8
		3 hospital_detox_cd = f8
		3 intermediate_care_nh_cd = f8
		3 knox_clinic_series_cd = f8
		3 knox_open_arms_clinic_cd = f8
		3 loudon_clinic_series_cd = f8
		3 hospital_latency_cd = f8
		3 non_financial_cd = f8
		3 non_commit_psych_hospital_cd = f8
		3 non_patient_lab_specimen_cd = f8
		3 outpatient_monitoring_cd = f8
		3 tcsc_oncology_cd = f8
		3 tcsc_outpatient_cd = f8
		3 pre_reg_pen_op_clinic_cd = f8
		3 scheduled_cd = f8
		3 preadmit_ob_cd = f8
		3 peninsula_outpatients_at_parkwest_cd = f8
		3 quick_bed_registration_cd = f8
		3 quick_ed_registration_cd = f8
		3 quick_lab_registration_cd = f8
		3 rapid_access_preregistration_cd = f8
		3 patricia_neal_outpatient_cd = f8
		3 rehab_inpatient_cd = f8
		3 sevier_clinic_series_cd = f8
		3 recurring_outpatient_extended_cd = f8
		3 select_specialty_cd = f8
		3 therapy_pt_ot_sp_cd = f8
		3 wound_care_cd = f8
		3 wellness_recovery_cd = f8
		3 clearingwire_account_cd = f8
		3 pre_admission_cd = f8
		3 newborn_cd = f8
		3 cardio_pulmonary_rehab_cd = f8
		3 sleep_lab_recurring_cd = f8
		3 multiday_op_diagnostic_cd = f8
		3 women_in_treatment_cd = f8
		3 intercompany_transfer_cd = f8
		3 lab_only_providers_cd = f8
		3 quick_lab_only_providers_cd = f8
	  2 cs_72
	   	3 admin_info_cd						= f8
	   	3 cal_kg_day_cd						= f8
	   	3 weight_kg							= f8
	   	3 dcp_generic_cd					= f8
		3 io_confirmed_cd      				= f8
		 3 admission_note_physician = f8
		 3 cardiovascular_surgery_consultation = f8
		 3 discharge_summary = f8
		 3 ed_note_physician = f8
		 3 24_hour_ph_probe = f8
		 3 colonoscopy = f8
		 3 esophagogastroduodenoscopy_egd = f8
		 3 bronchoscopy = f8
		 3 operative_report_hx = f8
		 3 history_and_physical = f8
		 3 echocardiogram_transesophageal = f8
		 3 physician_order = f8
		 3 procedure_notes = f8
		 3 cardio_test_or_study = f8
		 3 special_procedure = f8
		 3 cardiac_catheterization_diagnostic = f8
		 3 cardiology_general_procedures = f8
		 3 cardiac_cath_procedure = f8
		 3 history_and_physical_update = f8
		 3 cardiology_procedure_note = f8
		 3 cardiothoracic_operative_note = f8
		 3 ent_operative_note = f8
		 3 gastroenterology_operative_note = f8
		 3 gynecology_procedure_note = f8
		 3 gynecology_operative_note = f8
		 3 interventional_radiology_procedure_note = f8
		 3 neurosurgery_operative_note = f8
		 3 obstetrics_procedure_note = f8
		 3 obstetrics_operative_note = f8
		 3 ophthalmology_operative_note = f8
		 3 orthopedic_procedure_note = f8
		 3 orthopedic_operative_note = f8
		 3 plastic_surgery_operative_note = f8
		 3 podiatry_operative_note = f8
		 3 surgery_operative_note = f8
		 3 urology_operative_note = f8
		 3 vascular_surgery_operative_note = f8
		 3 cardiology_operative_note = f8
		 3 gastroenterology_op_note_brief = f8
		 3 oral_maxillofacial_operative_note = f8
		 3 pediatric_procedure_note = f8
		 3 report_of_death = f8
		 3 procedure_note = f8
		 3 progress_note = f8
	  2 cs_73
		3 caretracker_cd = f8
		3 ingenix_cd = f8
		3 ingenix_authentication_cd = f8
		3 monitoring_cd = f8
		3 mayo_rli_cd = f8
		3 hl7__aliases_cd = f8
		3 lynx_cd = f8
		3 twmc_adt_cd = f8
		3 okmc_adt_cd = f8
		3 stagecoach_adt_cd = f8
		3 clinic_charge_ticket_cd = f8
		3 bridge_cd = f8
		3 cpm_copay_cd = f8
		3 cms_cd = f8
		3 vaccine_registry_cd = f8
		3 res_affinity_src_cd = f8
		3 homeworks_cd = f8
		3 collections_cd = f8
		3 277castc01_cd = f8
		3 277castatus_cd = f8
		3 277castc03_cd = f8
		3 accretive_cd = f8
		3 varian_cd = f8
		3 syngo_cd = f8
		3 allergies_cd = f8
		3 usiis_cd = f8
		3 telcor_cd = f8
		3 ih_export_cd = f8
		3 uhddb_cd = f8
		3 covenant_cd = f8
		3 mscm_cd = f8
		3 pmm_cd = f8
		3 blount_cd = f8
		3 history_cd = f8
		3 fusion_cd = f8
		3 copath_cd = f8
		3 pathgroup_cd = f8
		3 muse_cd = f8
		3 hx_acute_cd = f8
		3 mayo_cd = f8
		3 quest_cd = f8
		3 hx_ccd_chs_src_cd = f8
		3 vrad_cd = f8
		3 fcor_cd = f8
		3 medilinks_cd = f8
		3 mrs_cd = f8
		3 labcorp_amb_cd = f8
		3 quest_amb_cd = f8
		3 ambulatory_rln_cd = f8
		3 labcorp_cd = f8
		3 vdcor_cd = f8
		3 schyulab_cd = f8
		3 labdaqc_cd = f8
		3 labdaqs_cd = f8
		3 acudose_cd = f8
		3 chuborders_cd = f8
		3 xds_contributor_source_cd = f8
		3 muse_cf_cd = f8
		3 ggastro_cd = f8
		3 pacs_cd = f8
		3 phs_outbound_cd = f8
		3 train_cd = f8
		3 automed_cd = f8
		3 tog_cd = f8
		3 367285_automsgplaces_cd = f8
		3 367286_automsgplaces_cd = f8
		3 ccd_cd = f8
		3 hchb_cd = f8
		3 labdaq_cd = f8
		3 3m_cd = f8
		3 3m_hos_cd = f8
		3 acr_cd = f8
		3 global_address_lookup_cd = f8
		3 allergy_cd = f8
		3 anatomicpat_cd = f8
		3 aps01_cd = f8
		3 aps02_cd = f8
		3 aps03_cd = f8
		3 ascend_hit_llc_cd = f8
		3 baxa_cd = f8
		3 bbt_cd = f8
		3 bcb_cd = f8
		3 bloodbank_cd = f8
		3 careaware_cd = f8
		3 ccee_cd = f8
		3 cdc_cd = f8
		3 cdi_cd = f8
		3 cerner_cd = f8
		3 cerner_chr_cd = f8
		3 cerner_ldap_cd = f8
		3 clia_number_cd = f8
		3 cmw_guided_scheduling_cd = f8
		3 cpt4_cd = f8
		3 cvx_cd = f8
		3 deers_source_cd = f8
		3 default_cd = f8
		3 3m_dialect_cd = f8
		3 image_cd = f8
		3 dod_export_cd = f8
		3 emirates_card_cd = f8
		3 esi_server_cd = f8
		3 esi_testing_1_cd = f8
		3 facility_charge_ticket_cd = f8
		3 fipspub2_cd = f8
		3 firstdata_cd = f8
		3 fmannotation_cd = f8
		3 freetext_cd = f8
		3 global_drug_database_cd = f8
		3 general_electric_cd = f8
		3 generallab_cd = f8
		3 generic_card_cd = f8
		3 german_egk_card_data_cd = f8
		3 german_kvk_card_data_cd = f8
		3 haad_cd = f8
		3 healthe_idm_cd = f8
		3 healtheintent_cd = f8
		3 hl7_cd = f8
		3 hl7_v2_cd = f8
		3 hla_cd = f8
		3 hla01_cd = f8
		3 hla02_cd = f8
		3 hla03_cd = f8
		3 hladilution_cd = f8
		3 hlameth_cd = f8
		3 hlareaction_cd = f8
		3 hlatype_cd = f8
		3 hlaxmtype_cd = f8
		3 icd10cm_cd = f8
		3 icd10pcs_cd = f8
		3 icd9cm_cd = f8
		3 idc_cd = f8
		3 ietf2048_cd = f8
		3 ietf3066_cd = f8
		3 ietf5646_cd = f8
		3 ihe_cd = f8
		3 infox_cd = f8
		3 iso_cd = f8
		3 iso_639_2_cd = f8
		3 kodip_cd = f8
		3 lab_cd = f8
		3 loinc_cd = f8
		3 medical_of_california_cd = f8
		3 medicode_cd = f8
		3 medicus_cd = f8
		3 medical_necessity_cd = f8
		3 merge_medical_systems_cd = f8
		3 mesh_cd = f8
		3 micromedex_cd = f8
		3 ministry_of_health_ontario_cd = f8
		3 mulalgcat_cd = f8
		3 muldclass_cd = f8
		3 multum_cd = f8
		3 manufacturers_of_vaccines_cd = f8
		3 myp_cd = f8
		3 nci_cd = f8
		3 nci_thesaurus_cd = f8
		3 ncoder_cd = f8
		3 ncpdp_cd = f8
		3 ncpdpscript_cd = f8
		3 ndc_cd = f8
		3 nhs_contributor_source_cd = f8
		3 nhs_pas_reason_codes_cd = f8
		3 nhs_uk_internal_codes_cd = f8
		3 nhs_disability_cd = f8
		3 nhs_address_use_codes_cd = f8
		3 nhs_name_type_codes_cd = f8
		3 nhs_priority_code_cd = f8
		3 nhs_contact_method_cd = f8
		3 nhs_callback_consent_cd = f8
		3 nhs_copy_correspondence_cd = f8
		3 nhs_cancel_reason_codes_cd = f8
		3 nhs_did_not_attend_reason_cd = f8
		3 nhs_ebs_update_person_reason_cd = f8
		3 nhs_ebookings_error_codes_cd = f8
		3 nhs_telecom_contact_method_cd = f8
		3 nhs_job_role_code_cd = f8
		3 nhs_death_notification_cd = f8
		3 nhs_assigning_authorities_cd = f8
		3 nhs_ethnic_category_codes_cd = f8
		3 nhs_organization_types_cd = f8
		3 nhs_consent_status_cd = f8
		3 nhs_consent_type_cd = f8
		3 nhs_suspected_abnormality_codes_cd = f8
		3 nhs_stillborn_indicator_codes_cd = f8
		3 nhs_delivery_place_codes_cd = f8
		3 nhs_interpreter_required_indicator_cd = f8
		3 nhs_person_personel_relation_cd = f8
		3 nhs_number_of_babies_codes_cd = f8
		3 nhs_person_relation_type_cd = f8
		3 nhs_language_codes_cd = f8
		3 nhs_related_person_relation_code_cd = f8
		3 nhs_preferred_written_comm_format_cd = f8
		3 nhs_multiple_birth_order_number_cd = f8
		3 nhs_lrs_response_type_codes_cd = f8
		3 nhs_lr_type_cd = f8
		3 nhs_access_reason_code_cd = f8
		3 nhs_sc_reason_code_cd = f8
		3 nhs_phone_use_codes_cd = f8
		3 nhs_administrative_gender_codes_cd = f8
		3 nhs_position_codes_cd = f8
		3 nhs_can_rsn_cd = f8
		3 nhs_dna_rsn_cd = f8
		3 national_health_system_cd = f8
		3 national_immunization_program_cd = f8
		3 nucc_cd = f8
		3 code_system_contributor_source_cd = f8
		3 patient_friendly_display_cd = f8
		3 pharma_cd = f8
		3 phinvads_cd = f8
		3 powerchart_cd = f8
		3 ed_professional_coding_and_charging_cd = f8
		3 profile_cd = f8
		3 ptcare_cd = f8
		3 pyxis_cd = f8
		3 rad01_cd = f8
		3 revenue_cycle_analytics_cd = f8
		3 redbook_cd = f8
		3 referral_cd = f8
		3 rxnorm_cd = f8
		3 sds_contributor_source_cd = f8
		3 siemens_healthcare_cd = f8
		3 snomed_ct_cd = f8
		3 system_cd = f8
		3 unified_code_for_units_of_measure_cd = f8
		3 umls_cd = f8
		3 unii_cd = f8
		3 vsac_cd = f8
		3 x12claim_cd = f8
		3 xr_xml_cd = f8
	  2 cs_79
	   3 canceled_cd = f8
		 3 complete_cd = f8
		 3 deleted_cd = f8
		 3 delivered_cd = f8
		 3 discontinued_cd = f8
		 3 dropped_cd = f8
		 3 inerror_cd = f8
		 3 inprocess_cd = f8
		 3 onhold_cd = f8
		 3 opened_cd = f8
		 3 overdue_cd = f8
		 3 pending_cd = f8
		 3 read_cd = f8
		 3 rework_cd = f8
		 3 suspended_cd = f8
		 3 refused_cd = f8
		 3 validation_cd = f8
		 3 recalled_cd = f8
		 3 readwaitsign_cd = f8
	  2 cs_93
	   	3 intake_cd				= f8
	   	3 output_cd				= f8
	  2 cs_103
	   	3 canceled_cd = f8
		3 completed_cd = f8
		3 deleted_cd = f8
		3 inerror_cd = f8
		3 refused_cd = f8
		3 requested_cd = f8
		3 unknown_cd = f8
		3 pending_cd = f8
	  2 cs_106
	  	3 cardiovascular_cd		= f8
	  2 cs_120
	   3 nocomp_cd				= f8
	   3 ocfcomp_cd				= f8
	  2 cs_212
		3 alpha_pager_cd = f8
		3 alternate_cd = f8
		3 billing_cd = f8
		3 bill_to_cd = f8
		3 birth_cd = f8
		3 business_cd = f8
		3 email_cd = f8
		3 eprescribing_cd = f8
		3 home_cd = f8
		3 mailing_cd = f8
		3 previous_cd = f8
		3 product_return_cd = f8
		3 professional_cd = f8
		3 remittance_cd = f8
		3 roi_cd = f8
		3 secondary_business_cd = f8
		3 ship_to_cd = f8
		3 technical_cd = f8
		3 temporary_cd = f8
		3 usual_cd = f8
	  2 cs_222
		3 activity_assignment_view_cd = f8
		3 rx_station_cluster_cd = f8
		3 ambulatorys_cd = f8
		3 surgery_cd = f8
		3 appointment_locations_cd = f8
		3 scheduling_views_cd = f8
		3 bb_drawing_stations_cd = f8
		3 bb_inventory_area_cd = f8
		3 bb_owner_area_views_cd = f8
		3 beds_cd = f8
		3 buildings_cd = f8
		3 check_outs_cd = f8
		3 specimen_collection_views_cd = f8
		3 collection_routes_cd = f8
		3 collection_runs_cd = f8
		3 specimen_login_locations_cd = f8
		3 specimen_tracking_locations_cd = f8
		3 facilitys_cd = f8
		3 followup_clinic_cd = f8
		3 health_information_mgmt_cd = f8
		3 health_information_mgmt_views_cd = f8
		3 inventory_groups_cd = f8
		3 inventory_locations_cd = f8
		3 inventory_locators_cd = f8
		3 inventory_view_cd = f8
		3 laboratorys_cd = f8
		3 materials_management_group_views_cd = f8
		3 nurse_units_cd = f8
		3 patient_list_view_cd = f8
		3 pharmacys_cd = f8
		3 remote_location_cd = f8
		3 prearrival_cd = f8
		3 recycle_cd = f8
		3 patient_tracking_view_cd = f8
		3 radiology_cd = f8
		3 rx_station_return_bin_cd = f8
		3 rooms_cd = f8
		3 rounds_list_view_cd = f8
		3 rx_location_group_cd = f8
		3 rxstation_view_cd = f8
		3 shift_assignment_view_cd = f8
		3 specimen_tracking_viewss_cd = f8
		3 service_areas_cd = f8
		3 storage_compartments_cd = f8
		3 storage_racks_cd = f8
		3 storage_tracking_views_cd = f8
		3 storage_shelfs_cd = f8
		3 storage_trays_cd = f8
		3 storage_units_cd = f8
		3 storage_tracking_views_cd = f8
		3 surgery_fill_cd = f8
		3 transport_cd = f8
		3 task_group_view_cd = f8
		3 waiting_rooms_cd = f8
	  2 cs_263
		3 health_plan_cd = f8
		3 dea_cd = f8
		3 star_doctor_number_cd = f8
		3 encounter_org_cd = f8
		3 external_id_cd = f8
		3 insurance_code_cd = f8
		3 media_alias_cd = f8
		3 ssn_cd = f8
		3 upin_cd = f8
		3 personnel_primary_identifier_cd = f8
		3 pft_statement_alias_cd = f8
		3 pft_claim_alias_pool_cd = f8
		3 org_unique_identifier_cd = f8
		3 financial_extract_org_alias_cd = f8
		3 visit_id_cd = f8
		3 naic_cd = f8
		3 client_code_cd = f8
		3 organization_npi_cd = f8
		3 provider_messaging_cd = f8
		3 surescripts_prescriber__index_cd = f8
		3 consumer_messaging_cd = f8
		3 unos_donor_id_cd = f8
		3 local_messaging_bw_cd = f8
		3 xds_alias_pool_cd = f8
		3 national_provider_identifier_cd = f8
		3 texas_dea_cd = f8
		3 nct_number_cd = f8
		3 default_place_of_service_cd = f8
		3 naic_org_cd = f8
		3 rxhx_order_event_id_cd = f8
		3 pft_invoice_alias_pool_cd = f8
		3 health_plan_address_cd = f8
		3 temp_mrn_cd = f8
		3 temp_fin_cd = f8
		3 nextgen_person_id_cd = f8
		3 cerner_fin_cd = f8
		3 cmrn_cd = f8
		3 star_fin_cd = f8
		3 cerner_mrn_cd = f8
		3 star_mrn_rmc_cd = f8
		3 star_mrn_mmc_cd = f8
		3 star_mrn_fsr_cd = f8
		3 star_mrn_cmc_cd = f8
		3 star_mrn_clmc_cd = f8
		3 star_mrn_lcmc_cd = f8
		3 star_mrn_flmc_cd = f8
		3 star_mrn_mhhs_cd = f8
		3 star_mrn_pw_cd = f8
		3 star_mrn_pbh_cd = f8
		3 star_mrn_tcsc_cd = f8
		3 cov_hp_search_cd = f8
		3 item_master_org_cd = f8
		3 taxonomy_id_cd = f8
		3 personnel_badge_id_cd = f8
		3 state_license_number_cd = f8
		3 cerner_federated_person_principal_cd = f8
		3 rln_quest_filler_order_id_cd = f8
		3 rln_mayo_filler_order_id_cd = f8
		3 cpm_client_facility_cd = f8
		3 cdadefaultpool_0_cd = f8
		3 hx_bb_supplier_org_cd = f8
		3 arln_quest_mrn_cd = f8
		3 arln_labcorp_mrn_cd = f8
		3 arln_quest_fin_cd = f8
		3 arln_labcorp_fin_cd = f8
		3 chub_placer_order_id_cd = f8
		3 resonance_alias_pool_chs_cd = f8
		3 mscm_item_master_cd = f8
		3 strata_pharmacy_org_ids_cd = f8
		3 arln_health_plan_pool_cd = f8
		3 rop_user_cd = f8
		3 dummy_facility_transfer_cd = f8
		3 intercompany_transfer_cd = f8
		3 lab_only_providers_cd = f8
		3 quick_lab_only_providers_cd = f8
	  2 cs_278							;CS 278 org_type_Cd
	   3 facility_cd			= f8	;278 FACILITY
	  2 cs_319
		3 extencnbr_cd = f8
		3 fin_nbr_cd = f8
		3 hnaencnbr_cd = f8
		3 mrn_cd = f8
		3 other_cd = f8
		3 pbs_visit_id_cd = f8
		3 req_nbr_cd = f8
		3 visit_id_cd = f8
	  2 cs_320
		3 admuserid_cd = f8
		3 al3cid_cd = f8
		3 contsubnbr_cd = f8
		3 covfamphys_cd = f8
		3 doccnbr_cd = f8
		3 docdea_cd = f8
		3 docnbr_cd = f8
		3 docupin_cd = f8
		3 externalid_cd = f8
		3 gdp_cd = f8
		3 hltheupresc_cd = f8
		3 imxaccessind_cd = f8
		3 licensenbr_cd = f8
		3 medicaid_cd = f8
		3 messaging_cd = f8
		3 nongp_cd = f8
		3 npi_cd = f8
		3 other_cd = f8
		3 postcode_cd = f8
		3 provgrpnum_cd = f8
		3 provider_num_cd = f8
		3 prsnlbadge_cd = f8
		3 prsnlid_cd = f8
		3 prsnlprimid_cd = f8
		3 pvddirid_cd = f8
		3 pvddirlinkid_cd = f8
		3 spi_cd = f8
		3 taxid_cd = f8
		3 taxonomyid_cd = f8
		3 userid_cd = f8
		3 username_cd = f8
	  2 cs_331
		3 birthdoc_cd = f8
		3 care_coord_cd = f8
		3 cmadmin_cd = f8
		3 cmassist_cd = f8
		3 deathdoc_cd = f8
		3 dentist_cd = f8
		3 emrgcyaccess_cd = f8
		3 familydoc_cd = f8
		3 lifecasemgr_cd = f8
		3 mntlhlthprmc_cd = f8
		3 obgyn_cd = f8
		3 oncologist_cd = f8
		3 other_cd = f8
		3 pcp_cd = f8
		3 pediatrician_cd = f8
		3 psychiatrist_cd = f8
		3 sponsor_cd = f8
	  2 cs_333							;CS 333 visit_reltn_cd
		3 admitdoc_cd = f8
		3 assigned_cd = f8
		3 assigned_pat_cd = f8
		3 attenddoc_cd = f8
		3 casemngr_cd = f8
		3 consultdoc_cd = f8
		3 coordinator_cd = f8
		3 dcspecialist_cd = f8
		3 locumadmit_cd = f8
		3 locumattend_cd = f8
		3 mntlhlthattp_cd = f8
		3 mrndefcnt_cd = f8
		3 orderdoc_cd = f8
		3 other_cd = f8
		3 primarynurse_cd = f8
		3 referdoc_cd = f8
		3 socialworker_cd = f8
		3 supervising_cd = f8
		3 nurseprac_cd = f8
	  2 cs_351
		3 asthmaguardi_cd = f8
		3 authrep_cd = f8
		3 bbrecipient_cd = f8
		3 consentor_cd = f8
		3 conservator_cd = f8
		3 defguar_cd = f8
		3 emc_cd = f8
		3 family_cd = f8
		3 familyhist_cd = f8
		3 genetic_cd = f8
		3 guarantor_cd = f8
		3 guardian_cd = f8
		3 hla_donrec_cd = f8
		3 insured_cd = f8
		3 nok_cd = f8
		3 pcg_cd = f8
		3 poa_cd = f8
		3 self_cd = f8
	  2 cs_354
		3 commercial_cd = f8
		3 medicare_cd = f8
		3 medicare_advantage_cd = f8
		3 other_cd = f8
		3 self_pay_cd = f8
		3 managed_care_cd = f8
		3 blue_cross_cd = f8
		3 tenncare_cd = f8
		3 self_pay_after_insurance_cd = f8
	  2 cs_356
		3 accrelatedvi_cd = f8
		3 addchgchk_cd = f8
		3 addptincern_cd = f8
		3 addr_info_cd = f8
		3 adlt_minor_cd = f8
		3 akaname1_cd = f8
		3 akaname2_cd = f8
		3 akaname3_cd = f8
		3 amb_company_cd = f8
		3 angel_alert_cd = f8
		3 angel_cmnt_cd = f8
		3 appt_alerts_cd = f8
		3 arrival_comm_cd = f8
		3 attend_city_cd = f8
		3 attend_clin_cd = f8
		3 attend_state_cd = f8
		3 att_address_cd = f8
		3 att_firstnam_cd = f8
		3 att_lastname_cd = f8
		3 att_npi_cd = f8
		3 att_phone_cd = f8
		3 att_zipcode_cd = f8
		3 badge_id_cd = f8
		3 bh_auth_comm_cd = f8
		3 bill_alerts_cd = f8
		3 botox_alerts_cd = f8
		3 cenbaddept_cd = f8
		3 cg_id_cd = f8
		3 challengeans_cd = f8
		3 checkoutdttm_cd = f8
		3 clergy_visit_cd = f8
		3 clinical_tri_cd = f8
		3 code_green_v_cd = f8
		3 code_green_d_cd = f8
		3 code_green_r_cd = f8
		3 complete_msp_cd = f8
		3 complete_reg_cd = f8
		3 consent_cd = f8
		3 consentdt_cd = f8
		3 conversation_cd = f8
		3 corr_alerts_cd = f8
		3 customalert_cd = f8
		3 cwautoenroll_cd = f8
		3 daystoretr_cd = f8
		3 defdoctype_cd = f8
		3 demo_alerts_cd = f8
		3 diag_cd = f8
		3 diag2_cd = f8
		3 diag3_cd = f8
		3 diag4_cd = f8
		3 diag_code1_cd = f8
		3 diag_code2_cd = f8
		3 diag_code3_cd = f8
		3 diag_desc_1_cd = f8
		3 diag_desc_2_cd = f8
		3 diag_desc_3_cd = f8
		3 dobchangech_cd = f8
		3 documentstat_cd = f8
		3 doc_req_dt_cd = f8
		3 do_not_resch_cd = f8
		3 drarescinddt_cd = f8
		3 dra_status_cd = f8
		3 dra_statusdt_cd = f8
		3 ed_visit_cd = f8
		3 emaildec_dt_cd = f8
		3 emaildec_rea_cd = f8
		3 emaildec_yn_cd = f8
		3 emc_add_optn_cd = f8
		3 emncptdminor_cd = f8
		3 encntrinfoav_cd = f8
		3 encntr_com_cd = f8
		3 est_tot_cost_cd = f8
		3 expired_nb_cd = f8
		3 fadecdate_cd = f8
		3 fallrisksev_cd = f8
		3 finan_com_cd = f8
		3 fnchangechek_cd = f8
		3 ftreltncvg_cd = f8
		3 fullpre_user_cd = f8
		3 fullreg_cd = f8
		3 fullregcomp_cd = f8
		3 full_reg_usr_cd = f8
		3 funeral_addr_cd = f8
		3 funeral_name_cd = f8
		3 funeral_phon_cd = f8
		3 ghp_addr4_cd = f8
		3 ghp_csz4_cd = f8
		3 ghp_grpnbr4_cd = f8
		3 ghp_hp_cd = f8
		3 ghp_hp5_cd = f8
		3 ghp_hp6_cd = f8
		3 ghp_mbrnbr4_cd = f8
		3 ghp_name4_cd = f8
		3 ghp_polhldr4_cd = f8
		3 ghp_polnbr4_cd = f8
		3 ghp_reltn4_cd = f8
		3 gt_addr_opt_cd = f8
		3 gt_alt_optn_cd = f8
		3 home_hlth_co_cd = f8
		3 home_hlth_pn_cd = f8
		3 home_hlth_pt_cd = f8
		3 hopsice_pat_cd = f8
		3 hospice_comp_cd = f8
		3 hospice_phon_cd = f8
		3 hpchgreview_cd = f8
		3 incidentto_cd = f8
		3 ins_comment_cd = f8
		3 ins_type_cd = f8
		3 lastdatework_cd = f8
		3 ltc_serv_req_cd = f8
		3 minqryintvl_cd = f8
		3 msp_complete_cd = f8
		3 mspqperiod_cd = f8
		3 mspq_30month_cd = f8
		3 msp_alert_cd = f8
		3 msp_reviewed_cd = f8
		3 namechangech_cd = f8
		3 newencntrcom_cd = f8
		3 newinscommen_cd = f8
		3 nok_add_optn_cd = f8
		3 nopnotes_cd = f8
		3 nop_priv_dt_cd = f8
		3 nop_status_cd = f8
		3 nossnreason_cd = f8
		3 ob_filter_cd = f8
		3 odmdarchvind_cd = f8
		3 odmdauthmode_cd = f8
		3 odmdrptmplid_cd = f8
		3 oon_ins_cd = f8
		3 os_csm_cd = f8
		3 other_alerts_cd = f8
		3 paperforms_cd = f8
		3 parsedoc_cd = f8
		3 passr_date_cd = f8
		3 passr_eval_cd = f8
		3 pastdueamt_cd = f8
		3 patient_pin_cd = f8
		3 patientporta_cd = f8
		3 pcp_address_cd = f8
		3 pcp_city_cd = f8
		3 pcp_clinic_cd = f8
		3 pcp_firstnam_cd = f8
		3 pcp_lastname_cd = f8
		3 pcp_npi_cd = f8
		3 pcp_phone_cd = f8
		3 pcp_state_cd = f8
		3 pcp_verified_cd = f8
		3 pcp_zipcode_cd = f8
		3 pos_alert_cd = f8
		3 preferred_ge_cd = f8
		3 prefphone_cd = f8
		3 pref_loc_cd = f8
		3 prepaydet_cd = f8
		3 prepayenddat_cd = f8
		3 prereg_comp_cd = f8
		3 prevpattype_cd = f8
		3 primselfstat_cd = f8
		3 prim_card_cd = f8
		3 prim_gastro_cd = f8
		3 prim_surg_cd = f8
		3 privacyword_cd = f8
		3 proc_code1_cd = f8
		3 proc_code2_cd = f8
		3 proc_code3_cd = f8
		3 proc_code4_cd = f8
		3 proc_code5_cd = f8
		3 proc_code6_cd = f8
		3 proc_code7_cd = f8
		3 proc_desc_1_cd = f8
		3 proc_desc_2_cd = f8
		3 proc_desc_3_cd = f8
		3 proc_desc_4_cd = f8
		3 proc_desc_5_cd = f8
		3 proc_desc_6_cd = f8
		3 proc_desc_7_cd = f8
		3 prsn_comment_cd = f8
		3 prsn_roialrt_cd = f8
		3 prsn_roicmnt_cd = f8
		3 ptbalance_cd = f8
		3 pt_alt_addr_cd = f8
		3 pt_phys_addr_cd = f8
		3 pymtaarngdet_cd = f8
		3 r1_add_optn_cd = f8
		3 realreltncvg_cd = f8
		3 reason_nopcp_cd = f8
		3 reason_noref_cd = f8
		3 rec_review_cd = f8
		3 refer_addres_cd = f8
		3 refer_city_cd = f8
		3 refer_clinic_cd = f8
		3 refer_firstn_cd = f8
		3 refer_lastna_cd = f8
		3 refer_npi_cd = f8
		3 refer_phone_cd = f8
		3 refer_state_cd = f8
		3 refer_zipcod_cd = f8
		3 reg_fin_risk_cd = f8
		3 retrievedoc_cd = f8
		3 roi_alert_cd = f8
		3 roi_cmnt_cd = f8
		3 s2_addr_opt_cd = f8
		3 s3_addr_opt_cd = f8
		3 s4_addr_opt_cd = f8
		3 selfpaybalan_cd = f8
		3 seqrec_alert_cd = f8
		3 seqrec_cmnt_cd = f8
		3 sex_orient_cd = f8
		3 slfpay_dt_tm_cd = f8
		3 snf_company_cd = f8
		3 snf_patient_cd = f8
		3 snf_phon_num_cd = f8
		3 specneedslev_cd = f8
		3 spouses_emp4_cd = f8
		3 spouses_emp5_cd = f8
		3 sps_emp_cty4_cd = f8
		3 sps_emp_cty5_cd = f8
		3 sps_emp_st4_cd = f8
		3 sps_emp_st5_cd = f8
		3 sps_emp_stt4_cd = f8
		3 sps_emp_stt5_cd = f8
		3 sps_emp_zip4_cd = f8
		3 sps_emp_zip5_cd = f8
		3 sp_exp_mothe_cd = f8
		3 sp_flag_cd = f8
		3 sp_hlth_issu_cd = f8
		3 sp_ins_cover_cd = f8
		3 sp_military_cd = f8
		3 sp_pt_custod_cd = f8
		3 sp_pt_tx_can_cd = f8
		3 sp_pt_und_26_cd = f8
		3 sp_quest_1_cd = f8
		3 sp_us_citizn_cd = f8
		3 sub_addr_opt_cd = f8
		3 transplant_cd = f8
		3 tran_doc_req_cd = f8
		3 tran_fac_nam_cd = f8
		3 travel_cd = f8
		3 traveltext_cd = f8
		3 valuegroup_cd = f8
		3 verify_forms_cd = f8
		3 ver_per_ins_cd = f8
		3 ver_relatedp_cd = f8
		3 ver_vis_ins_cd = f8
		3 veteran_cd = f8
		3 wc_addr_cd = f8
		3 wc_csz_cd = f8
		3 wc_name_cd = f8
		3 wc_polnbr_cd = f8
		3 workcomp_hp_cd = f8
	  2 cs_396
	    3 freetext_cd = f8
	    3 org_cd = f8
	  2 cs_400
		3 ada_au_cd = f8
		3 aediag_cd = f8
		3 algyreact_cd = f8
		3 allergy_cd = f8
		3 anatomic_pat_cd = f8
		3 apc_cd = f8
		3 apdrg_cd = f8
		3 apdrgnj_cd = f8
		3 apdrg_in_cd = f8
		3 apdrg_nc_cd = f8
		3 apdrg_ne_cd = f8
		3 apdrg_ny_cd = f8
		3 apdrg_oh_cd = f8
		3 apdrg_wa_cd = f8
		3 apg_cd = f8
		3 apinternal_cd = f8
		3 aprdrg_cd = f8
		3 aprdrgaz_cd = f8
		3 aprdrgca_cd = f8
		3 aprdrgfl_cd = f8
		3 aprdrgil_cd = f8
		3 aprdrgin_cd = f8
		3 aprdrgma_cd = f8
		3 aprdrgmd_cd = f8
		3 aprdrgmi_cd = f8
		3 aprdrgms_cd = f8
		3 aprdrgny_cd = f8
		3 aprdrgva_cd = f8
		3 aprdrgwa_cd = f8
		3 ardrg_42_cd = f8
		3 ardrg_51_cd = f8
		3 ardrg_52_cd = f8
		3 ardrg_60_cd = f8
		3 ardrg_60x_cd = f8
		3 ardrg_70_cd = f8
		3 ardrg_80_cd = f8
		3 ardrg_90_cd = f8
		3 asa_cd = f8
		3 bcdx_cd = f8
		3 blood_bank_cd = f8
		3 c10es_cd = f8
		3 cap_ecc_cd = f8
		3 ceddx_cd = f8
		3 cerner_cd = f8
		3 cid10br_cd = f8
		3 cidobr_cd = f8
		3 cie10mx_cd = f8
		3 cie10es_cd = f8
		3 cie9mc_cd = f8
		3 cie9mcmx_cd = f8
		3 cieoes_cd = f8
		3 cif_cd = f8
		3 cihi_cd = f8
		3 cim10_cd = f8
		3 cim10_2010_cd = f8
		3 cim10_2011_cd = f8
		3 cim10_2012_cd = f8
		3 cim10_2013_cd = f8
		3 cim10_2014_cd = f8
		3 cim10_2015_cd = f8
		3 cim10_2016_cd = f8
		3 cim10_2017_cd = f8
		3 cki_cd = f8
		3 clinbio_cd = f8
		3 cmg_cd = f8
		3 cot_cd = f8
		3 cpt4_cd = f8
		3 cvx_cd = f8
		3 dor27_cd = f8
		3 dpg_cd = f8
		3 drggeorgia_cd = f8
		3 drggermany_cd = f8
		3 drgillinois_cd = f8
		3 drgir_cd = f8
		3 dsm4_cd = f8
		3 dsm4_tr_cd = f8
		3 dsm5_cd = f8
		3 dsm5ca_cd = f8
		3 eapg_cd = f8
		3 freetext_cd = f8
		3 gddbactcomp_cd = f8
		3 gddbactgrp_cd = f8
		3 gddbggpi_cd = f8
		3 gddbhlthiss_cd = f8
		3 gddbmol_cd = f8
		3 gddbprod_cd = f8
		3 gddbprodln_cd = f8
		3 gddbsubst_cd = f8
		3 general_lab_cd = f8
		3 hcfa_cd = f8
		3 hcpcs_cd = f8
		3 hhccdiag_cd = f8
		3 hhccintr_cd = f8
		3 hl7_cd = f8
		3 hla_cd = f8
		3 hla_dilution_cd = f8
		3 hla_meth_cd = f8
		3 hla_reaction_cd = f8
		3 hla_type_cd = f8
		3 hla_xm_type_cd = f8
		3 hlipft_cd = f8
		3 hpo_cd = f8
		3 hrg_cd = f8
		3 icd10_cd = f8
		3 icd10amnd_cd = f8
		3 icd10amvemd_cd = f8
		3 icd10cm_cd = f8
		3 icd10invld_cd = f8
		3 icd10invld_cd = f8
		3 icd10pcs_cd = f8
		3 icd10sgb_cd = f8
		3 icd10who_cd = f8
		3 icd10_ca_cd = f8
		3 icd9_cd = f8
		3 icdo_cd = f8
		3 icpm_cd = f8
		3 imo_cd = f8
		3 imodsm5_cd = f8
		3 imo_au_cd = f8
		3 imo_aume_cd = f8
		3 inegi_cd = f8
		3 iqhphr_cd = f8
		3 loinc_cd = f8
		3 lynx_cd = f8
		3 mayo_prob_cd = f8
		3 mbse_nsw_cd = f8
		3 mbs_au_cd = f8
		3 mdi_cd = f8
		3 medicomalg_cd = f8
		3 microbiology_cd = f8
		3 micromedex_cd = f8
		3 mohprocedure_cd = f8
		3 msdrg_cd = f8
		3 msdrgltc_cd = f8
		3 msdrgnc_cd = f8
		3 msdrgnm_cd = f8
		3 msdrgtri_cd = f8
		3 msdrgtx_cd = f8
		3 msdrgtx_cd = f8
		3 msdrgut_cd = f8
		3 msdrgwi_cd = f8
		3 mulalgcat_cd = f8
		3 muldci_cd = f8
		3 muldclass_cd = f8
		3 muldrug_cd = f8
		3 mulmmdc_cd = f8
		3 multum_cd = f8
		3 namcs_cd = f8
		3 nanda_cd = f8
		3 ncci_cd = f8
		3 nci_cd = f8
		3 ncpdp_cd = f8
		3 ndc_cd = f8
		3 ndfrt_cd = f8
		3 nic_cd = f8
		3 nicip_cd = f8
		3 noc_cd = f8
		3 opcs4_cd = f8
		3 ops301gmany_cd = f8
		3 orsos_cd = f8
		3 packageprice_cd = f8
		3 pcats_cd = f8
		3 phin_vads_cd = f8
		3 pned_cd = f8
		3 pned_ped_cd = f8
		3 pros_doh_cd = f8
		3 psl_cd = f8
		3 ptcare_cd = f8
		3 rol_cd = f8
		3 rxnorm_cd = f8
		3 smni95_cd = f8
		3 snm2_cd = f8
		3 snm2ext_cd = f8
		3 snmct_cd = f8
		3 snmi95_cd = f8
		3 snmi95ext_cd = f8
		3 snmukemed_cd = f8
		3 sus_cd = f8
		3 tuss_cd = f8
		3 ucum_cd = f8
		3 unii_cd = f8
		3 webnap_cd = f8
	  2 cs_4010							;4010
		3 now					= f8	;NOW
		3 routine				= f8	;ROUTINE
		3 stat					= f8	;STAT
	  2 cs_6000
		3 nutrition_services_cd = f8
		3 discern_rule_order_cd = f8
		3 materials_management_cd = f8
		3 patient_care_cd = f8
		3 pharmacy_cd = f8
		3 radiology_cd = f8
		3 scheduling_cd = f8
		3 surgery_cd = f8
		3 home_care_cd = f8
		3 home_care_plans_pathways_protocols_cd = f8
		3 environmental_services_cd = f8
		3 evaluation_and_management_cd = f8
		3 admit_transfer_discharge_cd = f8
		3 respiratory_therapy_cd = f8
		3 sleep_disorders_cd = f8
		3 speech_therapy_cd = f8
		3 supplies_cd = f8
		3 urology_cd = f8
		3 volunteer_services_cd = f8
		3 womens_services_cd = f8
		3 audiology_cd = f8
		3 cardiology_cd = f8
		3 consults_cd = f8
		3 dialysis_cd = f8
		3 ent_cd = f8
		3 gastroenterology_cd = f8
		3 infection_control_cd = f8
		3 neurodiagnostics_cd = f8
		3 occupational_therapy_cd = f8
		3 orthopedics_cd = f8
		3 pastoral_care_cd = f8
		3 physical_therapy_cd = f8
		3 procedures_cd = f8
		3 pulmonary_medicine_cd = f8
		3 recreational_therapy_cd = f8
		3 point_of_care_testing_cd = f8
		3 physician_charges_cd = f8
		3 blood_bank_donor_cd = f8
		3 case_manager_cd = f8
		3 social_work_cd = f8
		3 ambulatory_poc_cd = f8
		3 cardiovascular_cd = f8
		3 ambulatory_referrals_cd = f8
		3 ambulatory_procedures_cd = f8
		3 durable_medical_equipment_cd = f8
		3 person_management_cd = f8
		3 referral_cd = f8
		3 laboratory_cd = f8
		3 ophthalmology_cd = f8
		3 ambulatory_scheduling_cd = f8
	  2 cs_6003
		3 activate_cd = f8
		3 add_alias_cd = f8
		3 cancel_cd = f8
		3 cancel_dc_cd = f8
		3 cancel_reord_cd = f8
		3 clear_cd = f8
		3 collection_cd = f8
		3 complete_cd = f8
		3 delete_cd = f8
		3 demogchange_cd = f8
		3 discontinue_cd = f8
		3 disorder_cd = f8
		3 futuredc_cd = f8
		3 hisorder_cd = f8
		3 modify_cd = f8
		3 order_cd = f8
		3 refill_cd = f8
		3 renew_cd = f8
		3 reschedule_cd = f8
		3 restore_cd = f8
		3 resume_cd = f8
		3 resume_renew_cd = f8
		3 review_cd = f8
		3 statuschange_cd = f8
		3 studactivate_cd = f8
		3 suspend_cd = f8
		3 transfer_can_cd = f8
		3 undo_cd = f8
	  2 cs_6004
		3 canceled_cd = f8
		3 completed_cd = f8
		3 deleted_cd = f8
		3 discontinued_cd = f8
		3 future_cd = f8
		3 incomplete_cd = f8
		3 inprocess_cd = f8
		3 medstudent_cd = f8
		3 ordered_cd = f8
		3 pending_cd = f8
		3 pending_rev_cd = f8
		3 suspended_cd = f8
		3 transcancel_cd = f8
		3 unscheduled_cd = f8
		3 voidedwrslt_cd = f8
	  2 cs_12025
	  	3 active_cd = f8
		3 canceled_cd = f8
		3 proposed_cd = f8
		3 resolved_cd = f8
	  2 cs_12034
		3 tertiary_cd = f8
		3 primary_cd = f8
		3 secondary_cd = f8
	  2 cs_13029
		3 display_cd = f8
		3 actual_cd = f8
		3 administered_cd = f8
		3 attempted_cd = f8
		3 bbreturn_cd = f8
		3 bbreturning_cd = f8
		3 cancel_cd = f8
		3 canceling_cd = f8
		3 checkin_cd = f8
		3 checkout_cd = f8
		3 clear_cd = f8
		3 collected_cd = f8
		3 collecting_cd = f8
		3 complete_cd = f8
		3 completing_cd = f8
		3 corrected_cd = f8
		3 correcting_cd = f8
		3 debug_reprocess_cd = f8
		3 dispensed_cd = f8
		3 dispensing_cd = f8
		3 disposed_cd = f8
		3 exam_complete_cd = f8
		3 in_lab_cd = f8
		3 loaded_cd = f8
		3 manual_cd = f8
		3 modified_cd = f8
		3 nocommit_cd = f8
		3 ordered_cd = f8
		3 ordering_cd = f8
		3 performed_cd = f8
		3 performing_cd = f8
		3 projected_cd = f8
		3 received_cd = f8
		3 referred_cd = f8
		3 released_cd = f8
		3 reprocess_cd = f8
		3 reverse_cd = f8
		3 scheduled_cd = f8
		3 setup_cd = f8
		3 signout_cd = f8
		3 transcribed_cd = f8
		3 transfused_cd = f8
		3 transfusing_cd = f8
		3 uncollecteduninlab_cd = f8
		3 uncomplete_cd = f8
		3 verified_cd = f8
		3 verifying_cd = f8
	  2 cs_14002
		3 all_suspend_cd = f8
		3 asa_cd = f8
		3 cdmschedpharm_cd = f8
		3 hospital_cdm_tech_cd = f8
		3 hospital_cdm_prof_cd = f8
		3 ambulatory_cdm_prof_cd = f8
		3 path_tech_purchased_cdm_cd = f8
		3 tog_cdm_professional_cd = f8
		3 hospital_medicare_cdm_tech_cd = f8
		3 hospital_cdm_tech_no_charge_cd = f8
		3 ambulatory_charge_point_profee_cd = f8
		3 hospital_charge_point_tech_cd = f8
		3 hospital_charge_point_professional_cd = f8
		3 ambulatory_charge_point_lab_cd = f8
		3 no_charge_cd = f8
		3 hospital_medicare_tech_cd = f8
		3 hospital_medicare_professional_cd = f8
		3 combine_cd = f8
		3 cpt_cd = f8
		3 bh_cpt_hosp_prof_cd = f8
		3 bh_cpt_hosp_tech_cd = f8
		3 hcpcs_cd = f8
		3 bh_hcpcs_hosp_prof_cd = f8
		3 bh_hcpcs_hosp_tech_cd = f8
		3 icd_cd = f8
		3 cpt_modifier_cd = f8
		3 hospital_340b_tech_jgtb_cd = f8
		3 hospital_340b_tech_standard_cd = f8
		3 bh_tech_modifier_cd = f8
		3 bh_prof_modifier_cd = f8
		3 hospital_340b_tech_orphaned_cd = f8
	  2 cs_14123
		3 completed_cd = f8
		3 removed_cd = f8
		3 started_cd = f8
	  2 cs_14192
		3 canceled_cd = f8
		3 completed_cd = f8
		3 in_process_cd = f8
		3 on_hold_cd = f8
		3 ordered_cd = f8
		3 removed_cd = f8
		3 replaced_cd = f8
		3 started_cd = f8
	  2 cs_14232
	    3 addclininfo_cd = f8
		3 addedbmsx04_cd = f8
		3 addedbmsx05_cd = f8
		3 addreferral_cd = f8
		3 addrequrmnt_cd = f8
		3 addshortlist_cd = f8
		3 advice_cd = f8
		3 appointment_cd = f8
		3 apptnoxpas_cd = f8
		3 apptxpas_cd = f8
		3 asi_cd = f8
		3 asicontact_cd = f8
		3 assess_cd = f8
		3 block_cd = f8
		3 cancel_cd = f8
		3 canceladv_cd = f8
		3 cancelreq_cd = f8
		3 canreqfollup_cd = f8
		3 checkabn_cd = f8
		3 checkin_cd = f8
		3 checkout_cd = f8
		3 closeadv_cd = f8
		3 cmpltprnting_cd = f8
		3 cnlrequrmnt_cd = f8
		3 complete_cd = f8
		3 completereq_cd = f8
		3 confirm_cd = f8
		3 contact_cd = f8
		3 contactref_cd = f8
		3 cutpaste_cd = f8
		3 defer_cd = f8
		3 deferresched_cd = f8
		3 delete_cd = f8
		3 discard_cd = f8
		3 displaced_cd = f8
		3 esoskip_cd = f8
		3 finalize_cd = f8
		3 hold_cd = f8
		3 link_cd = f8
		3 lock_cd = f8
		3 modassess_cd = f8
		3 modify_cd = f8
		3 modifyadv_cd = f8
		3 modifyreq_cd = f8
		3 modreferral_cd = f8
		3 mohhcv_cd = f8
		3 moveres_cd = f8
		3 noshow_cd = f8
		3 noswreqfolup_cd = f8
		3 patseen_cd = f8
		3 print_cd = f8
		3 private_cd = f8
		3 processdna_cd = f8
		3 ptpatarrved_cd = f8
		3 ptpatfinish_cd = f8
		3 ptpatinroom_cd = f8
		3 ptpatleft_cd = f8
		3 ptpatready_cd = f8
		3 ptpatstarted_cd = f8
		3 ptpatstatrst_cd = f8
		3 public_cd = f8
		3 recordnoshow_cd = f8
		3 recur_cd = f8
		3 reject_cd = f8
		3 rejectcancel_cd = f8
		3 remind_cd = f8
		3 rempatlock_cd = f8
		3 reorder_cd = f8
		3 request_cd = f8
		3 reschedule_cd = f8
		3 respond_cd = f8
		3 restore_cd = f8
		3 restorereq_cd = f8
		3 retainreq_cd = f8
		3 review_cd = f8
		3 rmvfrmwklst_cd = f8
		3 schedule_cd = f8
		3 seenbygen1_cd = f8
		3 seenbygen2_cd = f8
		3 seenbygen3_cd = f8
		3 seenbygen4_cd = f8
		3 seenbymedstu_cd = f8
		3 seenbymidlev_cd = f8
		3 seenbynurse_cd = f8
		3 seenbyphysic_cd = f8
		3 seenbyreside_cd = f8
		3 shuffle_cd = f8
		3 standby_cd = f8
		3 swapres_cd = f8
		3 unblock_cd = f8
		3 undocancel_cd = f8
		3 undocheckin_cd = f8
		3 undocheckout_cd = f8
		3 undonoshow_cd = f8
		3 unlink_cd = f8
		3 unlock_cd = f8
		3 updtrequrmnt_cd = f8
		3 verify_cd = f8
		3 view_cd = f8
	  2 cs_14233
	  	3 advice_cd = f8
		3 default_cd = f8
		3 assessed_cd = f8
		3 block_cd = f8
		3 canceled_cd = f8
		3 canceled_advice_cd = f8
		3 checked_in_cd = f8
		3 checked_out_cd = f8
		3 closed_advice_cd = f8
		3 complete_cd = f8
		3 confirmed_cd = f8
		3 deleted_cd = f8
		3 discarded_cd = f8
		3 finalized_cd = f8
		3 hold_cd = f8
		3 no_show_cd = f8
		3 pending_cd = f8
		3 request_cd = f8
		3 rescheduled_cd = f8
		3 advice_response_cd = f8
		3 scheduled_cd = f8
		3 shortlisted_cd = f8
		3 standby_cd = f8
		3 unschedulable_cd = f8
	  2 cs_14281
		3 canceled_cd = f8
		3 completed_cd = f8
		3 cvarrived_cd = f8
		3 cvcompleted_cd = f8
		3 cvedreview_cd = f8
		3 cvinprocess_cd = f8
		3 cvscheduled_cd = f8
		3 cvsigned_cd = f8
		3 cvunsigned_cd = f8
		3 cvverified_cd = f8
		3 deleted_cd = f8
		3 discontinued_cd = f8
		3 inpathology_cd = f8
		3 labcollected_cd = f8
		3 labdeleted_cd = f8
		3 labdispatch_cd = f8
		3 labfinal_cd = f8
		3 labinlab_cd = f8
		3 labinprocess_cd = f8
		3 labintransit_cd = f8
		3 labprelim_cd = f8
		3 labresultdel_cd = f8
		3 labscheduled_cd = f8
		3 labstain_cd = f8
		3 labsus_cd = f8
		3 onhold_cd = f8
		3 ordered_cd = f8
		3 partialfill_cd = f8
		3 pendcollect_cd = f8
		3 radcompleted_cd = f8
		3 radordered_cd = f8
		3 radremoved_cd = f8
		3 radreplaced_cd = f8
		3 radstarted_cd = f8
		3 refill_cd = f8
		3 rxhistord_cd = f8
		3 rxhxincmplt_cd = f8
		3 rxonfile_cd = f8
		3 rxonhold_cd = f8
		3 transferout_cd = f8
	  2 cs_16769
	  	3 completed_cd = f8
		3 discontinued_cd = f8
		3 dropped_cd = f8
		3 excluded_cd = f8
		3 future_cd = f8
		3 future_cd = f8
		3 future_proposed_cd = f8
		3 held_cd = f8
		3 initiated_cd = f8
		3 initiated_proposed_cd = f8
		3 initiated_cd = f8
		3 ordered_cd = f8
		3 planned_cd = f8
		3 planned_proposed_cd = f8
		3 proposed_cd = f8
		3 skipped_cd = f8
		3 started_cd = f8
		3 suspended_cd = f8
		3 void_cd = f8
	  2 cs_19189						;CS 19189 prsnl group types
		3 ambcaregrp_cd = f8
		3 asgmtgrp_cd = f8
		3 careteam_cd = f8
		3 ccadmin_cd = f8
		3 cccsr_cd = f8
		3 ccdba_cd = f8
		3 cclpn_cd = f8
		3 ccrn_cd = f8
		3 dcpteam_cd = f8
		3 department_cd = f8
		3 himsusphys_cd = f8
		3 pkpda_cd = f8
		3 poolgrp_cd = f8
		3 providerset_cd = f8
		3 referrer_cd = f8
		3 scheduser_cd = f8
		3 service_cd = f8
	  2 cs_27360						;CS 27350 patient_list_type_cd
	   3 lreltn 		 		= f8	;27360, "LRELTN"
	   3 providergrp 	 		= f8	;27360, "PROVIDERGRP"
	   3 service				= f8	;27360, "SERVICE"
	   3 vreltn		 			= f8	;27360, "VRELTN"
	   3 anc_asgmt	     		= f8	;27360, "ANC_ASGMT"
	   3 assignment	 			= f8	;27360, "ASSIGNMENT"
	   3 custom		 			= f8	;27360, "CUSTOM"
	   3 location		 		= f8	;27360, "LOCATION"
	   3 locationgrp	 		= f8	;27360, "LOCATIONGRP"
	   3 query		     		= f8	;27360, "QUERY"
	   3 careteam		 		= f8	;27360, "CARETEAM"
	   3 reltn		     		= f8	;27360, "RELTN"
	   3 schedule		 		= f8	;27360, "SCHEDULE"
	  2 cs_28880
		3 addended_cd = f8
		3 approved_cd = f8
		3 corrected_cd = f8
		3 cosigned_cd = f8
		3 dictated_cd = f8
		3 modified_cd = f8
		3 onhold_cd = f8
		3 proxied_cd = f8
		3 rejected_cd = f8
		3 rettores_cd = f8
		3 transcribed_cd = f8
	  2 cs_28881						;group organizations for streamlining prsnl-org relationships
 		3 security_cd			= f8	;28881	SECURITY
 	  2 cs_29520
 	    3 vitalslink_cd			= f8
 	  2 cs_254550
		3 forward_cd = f8
		3 author_cd = f8
		3 carboncopy_cd = f8
		3 originator_cd = f8
		3 responsiblec_cd = f8
		3 referral_cd = f8
		3 letters_cd = f8
		3 fax_modifier_cd = f8
		3 mail_modif_cd = f8
		3 email_modif_cd = f8
 	  2 cs_4000160
 	   	3 confirmed_cd			= f8
	  2 cs_4002773
		3 accommchange_cd = f8
		3 accommreqchg_cd = f8
		3 adhocexclusn_cd = f8
		3 bioenrstat_cd = f8
		3 casestatchg_cd = f8
		3 clindischrg_cd = f8
		3 dischrg_cd = f8
		3 enctypechg_cd = f8
		3 finclasschg_cd = f8
		3 haaccoffrchg_cd = f8
		3 hiaccoffrchg_cd = f8
		3 medsvcchg_cd = f8
		3 outpatinbed_cd = f8
		3 startinpat_cd = f8
		3 startobs_cd = f8
		3 urgencychg_cd = f8
 	   2 cs_4003273						;4003273 status code
		3 ERROR_cd				= f8
		3 NO_TRANSACT_cd		= f8
		3 PARTIAL_SUCC_cd		= f8
		3 PENDING_cd			= f8
		3 SUCCESS_cd			= f8
		3 PROTECTED_cd 			= f8
)  with protect
 
;free set rtf_commands
record rtf_commands
(
	1 start_ind					= i2
	1 end_ind					= i2
	1 st
		2 rhead					= vc
		2 rh2r					= c32
		2 rh2b					= c35
		2 rh2bu					= c38
		2 rh2u					= c35
		2 rh2i					= c35
		2 reol					= c5
		2 rtab					= c5
		2 center				= c4
		2 wr					= c22
		2 wb					= c25
		2 wb_end				= c4
		2 wu					= c26
		2 wi					= c25
		2 wbi					= c28
		2 wiu					= c29
		2 wbiu					= c32
		2 wbu					= c29
		2 sr					= c22
		2 sb					= c25
		2 sb_end				= vc
		2 su					= c26
		2 si					= c25
		2 sbi					= c28
		2 siu					= c29
		2 sbiu					= c32
		2 sbu					= c29
		2 rtfeof				= c1
		2 rtf_row_end			= c5
		2 rtf_table_end			= c10
		2 rtf_cell_begin		= c7
		2 rtf_cell_end			= c6
		2 rtf_grid_row_begin	= vc
		2 rtrow_begin			= vc
		2 rtrow_begin_center	= vc
		2 rtrow_brdr_l			= vc
		2 rtrow_brdr_b			= vc
		2 rtrow_brdr_r			= vc
		2 rtrow_brdr_t			= vc
		2 rtcell_brdr			= c87
		2 rtcell_brdr_no_l		= c66
		2 rtcell_brdr_no_r		= c66
		2 rtborder				= vc
		2 rtcell_end			= c6
		2 rtrow_end				= c5
		2 rtend					= c5
		2 rtcel1				= vc
		2 rtcel2				= vc
		2 rtcel3				= vc
		2 rtcel4				= vc
		2 rtcel5				= vc
		2 rtcel6				= vc
		2 rtcel7				= vc
		2 rtcel8				= vc
		2 rtcel9				= vc
) with protect
 
;free record 4171666_request	;core_ens_cd_value_ext
record 4171666_request
(
  1 extension_list[*]
    2 action_type_flag = i2 ;(1:insert) (2:update) (3:delete)
    2 code_set         = i4
    2 code_value       = f8
    2 field_name       = c32
    2 field_type       = i4
    2 field_value      = vc
) with protect
 
;free record 4171666_reply	;core_ens_cd_value_ext
record 4171666_reply
(
  1 curqual     = i4
  1 qual[*]
    2 status    = i2
    2 error_num = i4
    2 error_msg = vc
%i cclsource:status_block.inc
) with protect
 
;free record 967705_request ;600005 967100 967705 Retrieve_Documents_By_Receiver
record 967705_request
(
  1 receiver
    2 pool_id = f8
    2 provider_id = f8
  1 patient_id = f8
  1 status_codes[*]
    2 status_cd = f8
  1 date_range
    2 begin_dt_tm = dq8
    2 end_dt_tm = dq8
  1 configuration
    2 msg_category_config_id = f8
    2 msg_subcategory_config_id = f8
    2 application_number = i4
  1 load
    2 only_unassigned_pool_items_ind = i2
    2 suppress_unauth_docs_ind = i2
    2 all_docs_ind = i2
    2 names_ind = i2
) with protect
 
;free record 967705_reply ;600005 967100 967705 Retrieve_Documents_By_Receiver
record 967705_reply (
  1 transaction_status
    2 success_ind = i2
    2 debug_error_message = vc
  1 transaction_uid = vc
  1 documents[*]
    2 notification_uid = vc
    2 person_id = f8
    2 person_name = vc
    2 encounter_id = f8
    2 event_id = f8
    2 result_status_cd = f8
    2 event_class_cd = f8
    2 task_status_cd = f8
    2 notification_type_cd = f8
    2 task_type_cd = f8
    2 task_activity_cd = f8
    2 msg_subject = vc
    2 comments = vc
    2 event_tag = vc
    2 ward_disp = vc
    2 msg_sender_id = f8
    2 msg_sender_name = vc
    2 msg_sender_pool_id = f8
    2 msg_sender_pool_name = vc
    2 performed_prsnl_id = f8
    2 performed_prsnl_name = vc
    2 transcribed_prsnl_id = f8
    2 transcribed_prsnl_name = vc
    2 creation_dt_tm = dq8
    2 updated_dt_tm = dq8
    2 reg_dt_tm = dq8
    2 disch_dt_tm = dq8
    2 version = i4
    2 owner_version = i4
    2 assign_prsnl_id = f8
    2 assign_prsnl_name = vc
    2 assign_pool_id = f8
    2 assign_pool_name = vc
    2 fwd_docs[*]
      3 notification_uid = vc
      3 comments = vc
      3 msg_sender_id = f8
      3 msg_sender_name = vc
      3 msg_sender_pool_id = f8
      3 msg_sender_pool_name = vc
      3 creation_dt_tm = dq8
      3 version = i4
      3 owner_version = i4
    2 document_type
      3 paper_document_ind = i2
      3 block_signature_ind = i2
      3 anticipated_document_ind = i2
      3 powernote_ind = i2
    2 transcribers[*]
      3 transcriber_prsnl_id = f8
      3 transcriber_prsnl_name = vc
  1 document_limit_exceeded_ind = i2
) with protect
 
;free record 967529_request	;600005 967100 967529 Sign_Review_Document
record 967529_request (
  1 action_prsnl_id = f8
  1 action
    2 sign_ind = i2
    2 review_ind = i2
  1 documents[*]
    2 event_id = f8
    2 event_version = i4
    2 notification_uid = vc
    2 notification_version = i4
    2 notification_assign_version = i4
    2 receivers[*]
      3 prsnl_id = f8
      3 pool_id = f8
      3 comment = vc
      3 action
        4 sign_ind = i2
        4 review_ind = i2
    2 comment = vc
  1 run_synchronously_ind = i2
  1 on_behalf_of_prsnl_id = f8
  1 pool_id = f8
  1 action_dt_tm = dq8
  1 action_tz = i4
  1 author_id = f8
) with protect
 
;free record 967529_reply
record 967529_reply (
  1 transaction_status
    2 success_ind = i2
    2 debug_error_message = vc
  1 transaction_uid = vc
  1 successful_actions[*]
    2 notification_uid = vc
    2 event_id = f8
  1 failed_actions[*]
    2 notification_uid = vc
    2 event_id = f8
    2 reason
      3 comment_too_long_ind = i2
      3 data_access_failure_ind = i2
      3 doc_lookup_failure_ind = i2
      3 dup_request_for_provider_ind = i2
      3 illegal_status_ind = i2
      3 no_forward_privilege_ind = i2
      3 no_sign_identifiers_ind = i2
      3 paper_not_supported_ind = i2
      3 prov_not_assigned_to_req_ind = i2
      3 prov_not_member_of_pool_ind = i2
      3 order_action_not_found_ind = i2
      3 too_many_sign_requests_ind = i2
      3 wrong_doc_version_ind = i2
      3 action_already_canceled_ind = i2
      3 no_review_req_to_comp_pool_ind = i2
      3 no_sign_req_to_complete_ind = i2
      3 no_sign_req_to_comp_pool_ind = i2
      3 failed_not_version_ind = i2
      3 failed_not_assign_version_ind = i2
      3 in_prcs_doc_grace_period_ind = i2
      3 unknown_ind = i2
      3 cannot_fwd_ant_doc_for_sign = i2
      3 cannot_sign_prelim_powernote = i2
      3 otg_doc_not_supported = i2
      3 cannot_sign_letter_ind = i2
      3 cannot_sign_draft_letter_ind = i2
) with protect
 
;free set 114557_request
record 114557_request
(
 1 output_dest_cd = f8
  1 file_name = vc
  1 copies = i4
  1 output_handle_id = f8
  1 number_of_copies = i4
  1 transmit_dt_tm = dq8
  1 priority_value = i4
  1 report_title = vc
  1 server = vc
  1 country_code = vc
  1 area_code = vc
  1 exchange = vc
  1 suffix = vc
  1 destination[*]
    2 program_name = vc
    2 output_dest_cd = f8
    2 file_name = vc
    2 copies = i4
    2 output_handle_id = f8
    2 number_of_copies = i4
    2 transmit_dt_tm = dq8
    2 priority_value = i4
    2 report_title = vc
    2 server = vc
    2 country_code = vc
    2 area_code = vc
    2 exchange = vc
    2 suffix = vc
  1 patient_data
    2 person
      3 person_id = f8
      3 pcp
       4 prsnl_person_id	= f8
      3 death_physician
       4 prsnl_person_id = f8
    3 encounter
      4 encntr_id = f8
) with protect
 
;free set 650701_request		;sch_chg_event_detail
record 650701_request
(
  1 call_echo_ind = i2
  1 qual[*]
    2 sch_event_id = f8
    2 sch_action_id = f8
    2 oe_field_id = f8
    2 seq_nbr = i4
    2 version_dt_tm = dq8
    2 oe_field_display_value = vc
    2 oe_field_dt_tm_value = dq8
    2 oe_field_meaning = vc
    2 oe_field_value = f8
    2 oe_field_meaning_id = f8
    2 updt_cnt = i4
    2 allow_partial_ind = i2
    2 version_ind = i2
    2 force_updt_ind = i2
) with protect
 
;free set 500182_request ;DCP_ADD_APP_PREFS
record 500182_request
(
1 application_number = I4
1 position_cd = F8
1 prsnl_id = f8
1 nv[*]
  2 pvc_name = c32
  2 pvc_value = vc
  2 sequence = i2
  2 merge_id = f8
  2 merge_name = vc
) with protect
 
;free set 500182_reply ;DCP_ADD_APP_PREFS
record 500182_reply
(
  1 app_prefs_id = f8
  1 nv[*]
    2 name_value_prefs_id = f8
%i cclsource:status_block.inc
) with protect
 
 
;free set 650701_reply		;sch_chg_event_detail
record 650701_reply		;sch_chg_event_detail
(
  1  qual_cnt                          = i4
  1  qual [*]
     2  status                         = i4
%i cclsource:status_block.inc
) with protect
 
;free set 265084_request		;specimen_label
record 265084_request
(
  1 printer_id = f8
  1 print_queue = vc
  1 label_program_prefix = vc
  1 label_program = vc
  1 label_x_pos = i2
  1 label_y_pos = i2
  1 print_med_rec_flag = i2
  1 hibc_flag = i2
  1 print_id_flag = i2
  1 person_id = f8
  1 encntr_id = f8
  1 name_full_formatted = vc
  1 mednbr = vc
  1 finnbr = vc
  1 ssnnbr = vc
  1 reqnbr = vc
  1 sex_cd = f8
  1 sex_disp = vc
  1 birthdate = dq8
  1 reason_for_visit = vc
  1 location_cd = f8
  1 location_disp = vc
  1 facility_cd = f8
  1 facility_disp = vc
  1 building_cd = f8
  1 building_disp = vc
  1 nurse_unit_cd = f8
  1 nurse_unit_disp = vc
  1 room_cd = f8
  1 room_disp = vc
  1 bed_cd = f8
  1 bed_disp = vc
  1 loc_temp_cd = f8
  1 loc_temp_disp = vc
  1 disch_dt_tm = dq8
  1 isolation_cd = f8
  1 isolation_disp = vc
  1 label_type = vc
  1 accession = vc
  1 accession_id = f8
  1 formatted_accession = vc
  1 barcode_accession = vc
  1 collection_list_nbr = i4
  1 container_count = i4
  1 admit_doc = vc
  1 attend_doc = vc
  1 consult_doc = vc
  1 organization_name = vc
  1 client_alias = vc
  1 unique_file_name_ind = i2
  1 container_qual[*]
    2 container_id = f8
    2 acc_container_nbr = i4
    2 barcode_acc_container = vc
    2 specimen_type_cd = f8
    2 specimen_type_disp = vc
    2 spec_cntnr_cd = f8
    2 spec_cntnr_disp = vc
    2 coll_class_cd = f8
    2 coll_class_disp = vc
    2 symbology = vc
    2 smg_barcode_adjust = i4
    2 smg_format = vc
    2 container_id_print = vc
    2 spec_hndl_cd = f8
    2 spec_hndl_disp = vc
    2 container_comment = vc
    2 collection_comment = vc
    2 volume = f8
    2 volume_units = vc
    2 volume_units_cd = f8
    2 volume_units_disp = vc
    2 drawn_dt_tm = dq8
    2 label_dt_tm = dq8
    2 coll_method_cd = f8
    2 coll_method_disp = vc
    2 specimen_src_text = vc
    2 body_site_cd = f8
    2 body_site_disp = vc
    2 additional_labels = i4
    2 order_count = i4
    2 parent_container_id = f8
    2 parent_container_nbr = i4
    2 order_qual[*]
      3 order_id = f8
      3 order_mnemonic = vc
      3 catalog_cd = f8
      3 cpri_cd = f8
      3 cpri_disp = vc
      3 rpri_cd = f8
      3 rpri_disp = vc
      3 label_sequence = i4
      3 collection_comment = vc
      3 provider_name = vc
      3 order_nbr = vc
    2 container_alias_cd = f8
    2 container_alias_disp = vc
    2 lab_handling_count = i4
    2 lab_handling_qual[*]
      3 lab_handling_cd = f8
      3 lab_handling_disp = vc
      3 lab_handling_order_seq = ui4
    2 drawn_prsnl_username = vc
    2 rfid_epc_hex = vc
  1 barcode_format_qual[*]
    2 barcode_prefix = vc
    2 barcode_alias_type_cd = f8
    2 barcode_z_data = vc
    2 barcode_check_digit_ind = i2
  1 mednbr_unformatted = vc
  1 finnbr_unformatted = vc
  1 ssnnbr_unformatted = vc
  1 reqnbr_unformatted = vc
  1 birth_tz = i4
) with protect
 
;free set 265084_reply		;specimen_label
record 265084_reply
(
  1  file_name           = vc
  1  file_name_full_path = vc
  1  node                = vc
%i cclsource:status_block.inc
) with protect
 
 
 
 
;free set 265072_request		;SCS_GET_LABEL_DATA
record 265072_request
(
  1 accession = vc
  1 output_dest_cd = f8
  1 output_name = vc
  1 label_type_flag = i2
) with protect
 
;free set 265072_reply		;SCS_GET_LABEL_DATA
record 265072_reply
(
    1  printer_id           = f8
    1  print_queue          = vc
    1  label_program_prefix = vc
    1  label_program        = vc
    1  label_x_pos          = i2
    1  label_y_pos          = i2
    1  print_med_rec_flag   = i2
    1  hibc_flag            = i2
    1  print_id_flag        = i2
    1  person_id            = f8
    1  encntr_id            = f8
    1  name_full_formatted  = vc
    1  mednbr               = vc
    1  finnbr               = vc
    1  ssnnbr               = vc
    1  reqnbr               = vc
    1  sex_cd               = f8
    1  sex_disp             = vc
    1  birthdate            = dq8
    1  reason_for_visit     = vc
    1  location_cd          = f8
    1  location_disp        = vc
    1  facility_cd          = f8
    1  facility_disp        = vc
    1  building_cd          = f8
    1  building_disp        = vc
    1  nurse_unit_cd        = f8
    1  nurse_unit_disp      = vc
    1  room_cd              = f8
    1  room_disp            = vc
    1  bed_cd               = f8
    1  bed_disp             = vc
    1  loc_temp_cd          = f8
    1  loc_temp_disp        = vc
    1  disch_dt_tm          = dq8
    1  isolation_cd         = f8
    1  isolation_disp       = vc
    1  label_type           = c1
    1  accession            = vc
    1  accession_id         = f8
    1  formatted_accession  = vc
    1  barcode_accession    = vc
    1  collection_list_nbr  = i4
    1  container_count      = i4
    1  admit_doc            = vc
    1  attend_doc           = vc
    1  consult_doc          = vc
    1  organization_name    = vc
    1  client_alias         = vc
    1  unique_file_name_ind = i2
    1  container_qual[*]
        10 container_id            = f8
        10 acc_container_nbr       = i4
        10 barcode_acc_container   = vc
        10 specimen_type_cd        = f8
        10 specimen_type_disp      = vc
        10 spec_cntnr_cd           = f8
        10 spec_cntnr_disp         = vc
        10 coll_class_cd           = f8
        10 coll_class_disp         = vc
        10 symbology               = c1
        10 smg_barcode_adjust      = i4
        10 smg_format              = c1
        10 container_id_print      = c1
        10 spec_hndl_cd            = f8
        10 spec_hndl_disp          = vc
        10 container_comment       = vc
        10 collection_comment      = vc
        10 volume                  = f8
        10 volume_units            = vc
        10 volume_units_cd         = f8
        10 volume_units_disp       = vc
        10 drawn_dt_tm             = dq8
        10 label_dt_tm             = dq8
        10 coll_method_cd          = f8
        10 coll_method_disp        = vc
        10 specimen_src_text       = vc
        10 body_site_cd            = f8
        10 body_site_disp          = vc
        10 additional_labels       = i4
        10 order_count             = i4
        10 parent_container_id     = f8
        10 parent_container_nbr    = i4
        10 order_qual[*]
          15 order_id              = f8
          15 order_mnemonic        = vc
          15 catalog_cd            = f8
          15 cpri_cd               = f8
          15 cpri_disp             = vc
          15 rpri_cd               = f8
          15 rpri_disp             = vc
          15 label_sequence        = i4
          15 collection_comment    = vc
          15 provider_name         = vc
          15 order_nbr             = vc
        10 container_alias_cd      = f8
        10 container_alias_disp    = vc
        10 lab_handling_count      = i4
        10 lab_handling_qual[*]
          15 lab_handling_cd       = f8
          15 lab_handling_disp     = vc
          15 lab_handling_order_seq= ui4
	10 drawn_prsnl_username	   = vc
    1  barcode_format_qual[*]
        10  barcode_prefix              = vc
        10  barcode_alias_type_cd       = f8
        10  barcode_z_data              = vc
        10  barcode_check_digit_ind     = i2
%i cclsource:status_block.inc
) with protect
 
;free set 225012_request		;bbt_rpt_pat_typ_com_xml
record 225012_request
(
  1 facility_cd = f8
  1 beg_dt_tm = dq8
  1 end_dt_tm = dq8
  1 report_flag = vc
  1 update_end_date_ind = i2
  1 debug_ind = i2
  1 batch_selection = vc
  1 output_dist = vc
  1 ops_dt_tm = dq8
) with protect
 
;free set 225012_reply		;bbt_rpt_pat_typ_com_xml
record 225012_reply
(
        1 file_name  = vc
        1 rpt_list[*]
          2 rpt_filename = vc
		  2 data_blob                 = gvc
		  2 data_blob_size            = i4
 
%i cclsource:status_block.inc
 
) with protect
 
 
;free set 3015_request 	;uzr_get_prsnl_by_position
record 3015_request	;uzr_get_prsnl_by_position
(
  1 name_last = vc
  1 name_first = vc
  1 view_flag = i2
  1 position_type_cd = f8
  1 hnauser_mode = i2
  1 logical_domain_id = f8
  1 logical_domain_enabled = i2
) with protect
 
;free set 3015_reply	;uzr_get_prsnl_by_position
record 3015_reply	;uzr_get_prsnl_by_position
(
1 qual[*]
    2 person_id = f8
    2 name_full_formatted = vc
    2 username = c50
    2 active_ind = i2
    2 status_ind = i2
    2 authorized_ind = i2
    2 suspended_ind = i2
    2 updt_cnt = i4
    2 combined_ind = i2 ;*002*
    2 contributor_system_cd = f8 ;*007*
    2 logical_domain_id = f8
    2 logical_domain_name = vc
%i cclsource:status_block.inc
) with protect
free set 3018_request	;uzr_get_prsnl_alias
record 3018_request	;uzr_get_prsnl_alias
(
  1 person_id = f8
  1 get_all_flag = i2
  1 end_effect_flag = i2
  1 get_org_flag = i2
  1 alias_type_mean = vc
)
 
free set 3018_reply	;uzr_get_prsnl_alias
record 3018_reply	;uzr_get_prsnl_alias
(
1 qual[*]
    2 prsnl_alias_id = f8
    2 alias = c50
    2 alias_formatted = c50  ;*002*
    2 prsnl_alias_type_cd = f8
    2 prsnl_alias_sub_type_cd = f8
    2 prsnl_alias_type_disp = vc  ;*002*
    2 alias_pool_cd = f8
    2 active_ind = i2
    2 beg_effective_dt_tm = dq8
    2 end_effective_dt_tm = dq8
    2 status_ind = i2
    2 updt_cnt = i4
    2 orgqual[*]  ;*002*
    	3 org_id = f8  ;*002*
    	3 org_name = vc  ;*002*
%i CCLSOURCE:status_block.inc
)
 
 
free record 1000056_request	;600005 1000056 1000056 event_prsnl_batch_ensure
record 1000056_request
(
  1 req[*]
    2 ensure_type = i2
    2 version_dt_tm = dq8
    2 version_dt_tm_ind = i2
    2 event_prsnl
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
      3 event_action_modifier_list[*]
        4 ce_event_action_modifier_id = f8
        4 event_action_modifier_id = f8
        4 event_id = f8
        4 event_prsnl_id = f8
        4 action_type_modifier_cd = f8
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
      3 ensure_type = i2
      3 digital_signature_ident = vc
      3 action_prsnl_group_id = f8
      3 request_prsnl_group_id = f8
      3 receiving_person_id = f8
      3 receiving_person_ft = vc
    2 ensure_type2 = i2
    2 clinsig_updt_dt_tm_flag = i2
    2 clinsig_updt_dt_tm = dq8
    2 clinsig_updt_dt_tm_ind = i2
  1 message_item
    2 message_text = vc
    2 subject = vc
    2 confidentiality = i2
    2 priority = i2
    2 due_date = dq8
    2 sender_id = f8
  1 user_id = f8
  1 result_set_links[*]
    2 ensure_type = i2
    2 event_id = f8
    2 result_set_id = f8
    2 entry_type_cd = f8
    2 relation_type_cd = f8
)
 
free record 1000056_reply	;600005 1000056 1000056 event_prsnl_batch_ensure
record 1000056_reply (
  1 rep[*]
    2 event_prsnl_id = f8
    2 event_id = f8
    2 action_prsnl_id = f8
    2 action_type_cd = f8
    2 sb
      3 severityCd = i4
      3 statusCd = i4
      3 statusText = vc
      3 subStatusList[*]
        4 subStatusCd = i4
  1 sb
    2 severityCd = i4
    2 statusCd = i4
    2 statusText = vc
    2 subStatusList[*]
      3 subStatusCd = i4
)
 
free record 3209070_request	;retrieve_dispatched_collections
record 3209070_request		;retrieve_dispatched_collections
(
  1 person_id = f8
  1 encounter_ids[*]
    2 encounter_id = f8
)
 
free set 3016_request	;uzr_add_prsnl_alias
record 3016_request	;uzr_add_prsnl_alias
(
  1 person_id = f8
  1 verify_unique_ind = i2
  1 qual[*]
    2 alias = vc
    2 prsnl_alias_type_cd = f8
    2 prsnl_alias_type_meaning = vc
    2 alias_pool_cd = f8
    2 active_ind = i2
    2 beg_effective_dt_tm = dq8
    2 end_effective_dt_tm = dq8
)
 
free set 3016_reply	;uzr_add_prsnl_alias
record 3016_reply	;uzr_add_prsnl_alias
(
  1 qual[*]
    2 prsnl_alias_id = f8
    2 alias = vc
    2 prsnl_alias_type_mean = c12
%i cclsource:status_block.inc
)
 
 
free record 3209070_reply	;retrieve_dispatched_collections
record 3209070_reply		;retrieve_dispatched_collections
(
1 person_id = f8
  1 encounter_accessions[*]
    2 encounter_id = f8
    2 accessions[*]
      3 accession_id = f8
      3 formatted_accession = vc
      3 unformatted_accession = vc
      3 containers[*]
        4 container_id = f8
        4 accession_container_number = i4
        4 scheduled_dt_tm = dq8
        4 volume = f8
        4 volume_units = vc
        4 collection_method = vc
        4 collection_method_cd = f8
        4 collection_class = vc
        4 specimen_type = vc
        4 specimen_type_cd = f8
        4 container_type = vc
        4 container_type_cd = f8
        4 special_handling_instr = vc
        4 body_site = vc
        4 specimen_source_text = vc
        4 specimen_id = f8
        4 specimen_updt_cnt = i4
        4 container_updt_cnt = i4
        4 nurse_collect_ind = i2
        4 orders[*]
          5 order_id = f8
          5 order_container_updt_cnt = i4
    2 orders[*]
      3 order_id = f8
      3 display_name = vc
      3 clinical_display_line = vc
      3 comment = vc
      3 special_handling_instr = vc
      3 collection_priority_cd = f8
      3 label_sequence = i2
      3 timed_study = i2
      3 cancel_allowed_ind = i2
      3 reschedule_allowed_ind = i2
  1 status_data
    2 status = vc
    2 subeventstatus[*]
      3 OperationName = vc
      3 OperationStatus = vc
      3 TargetObjectName = vc
      3 TargetObjectValue = vc
)
 
free record 13013_request	;LOC_GET_ALL_CHILDREN_FOR_LOC
record 13013_request		;LOC_GET_ALL_CHILDREN_FOR_LOC
(
  1 location_cd = f8
  1 cdf_meaning = vc
  1 root_loc_cd = f8
  1 get_all_flag = i2
  1 get_master_flag = i2
  1 get_prsnl_org_flag = i2
)
 
free record 13013_reply		;LOC_GET_ALL_CHILDREN_FOR_LOC
record 13013_reply			;LOC_GET_ALL_CHILDREN_FOR_LOC
(
  1 qual[*]
    2 child_loc_cd		= f8
    2 child_loc_disp		= c40
    2 child_loc_desc		= c60
    2 child_loc_mean		= c12
    2 cv_updt_cnt		= i4
    2 collation_seq		= i4
    2 child_ind                 = i2
    2 loc_status_ind		= i2
    2 loc_active_ind            = i2
    2 lg_status_ind		= i2
    2 lg_active_ind		= i2
    2 lg_updt_cnt               = i4
    2 sequence			= i4
    2 location_type_mean	= c12
    2 data_status_cd = f8
%i cclsource:status_block.inc
)
 
 
 
 
free record 13016_request	;LOC_GET_ALL_LOC_FOR_CDF
record 13016_request		;LOC_GET_ALL_LOC_FOR_CDF
(
  1 code_set = i4
  1 cdf_meaning = vc
  1 get_all_flag = i2
  1 get_view_flag = i2
  1 get_master_flag = i2
  1 get_facility_flag = i2
  1 skip_loc_group_ind = i2
  1 get_prsnl_org_flag = i2
)
 
free record 13016_reply		;LOC_GET_ALL_LOC_FOR_CDF
record 13016_reply			;LOC_GET_ALL_LOC_FOR_CDF
(
1 qual[*]
    2 code_value				= f8
    2 cdf_meaning               = c12
    2 description				= c200
    2 display                   = c40
    2 active_ind                = i2
    2 beg_effective_dt_tm       = dq8
    2 end_effective_dt_tm       = dq8
    2 status_ind				= i2
    2 child_ind                 = i2
    2 collation_seq				= i4
    2 updt_cnt					= i4
    2 root_loc_cd				= f8
    2 data_status_cd 			= f8
%i cclsource:status_block.inc
)
 
 
free record 600123_request  ;dcp_get_patient_list2
record 600123_request  		;dcp_get_patient_list2
(
  1 patient_list_id = f8
  1 patient_list_type_cd = f8
  1 best_encntr_flag = i2
  1 arguments[*]
    2 argument_name = vc
    2 argument_value = vc
    2 parent_entity_name = vc
    2 parent_entity_id = f8
  1 encntr_type_filters[*]
    2 encntr_type_cd = f8
    2 encntr_class_cd = f8
  1 patient_list_name = vc
  1 mv_flag = i2
  1 rmv_pl_rows_flag = i2
)
 
free record 600123_reply
record 600123_reply
(
	1 patient_list_id = f8
	1 name = vc
	1 description = vc
	1 patient_list_type_cd = f8
	1 owner_id = f8
	1 prsnl_access_cd = f8
	1 execution_dt_tm = dq8			;002
	1 execution_status_cd = f8		;002
	1 execution_status_disp = vc	;002
	1 arguments[*]
		2 argument_name = vc
		2 argument_value = vc
		2 parent_entity_name = vc
		2 parent_entity_id = f8
	1 encntr_type_filters[*]
		2 encntr_type_cd = f8
	1 patients[*]
		2 person_id = f8
		2 person_name = vc
		2 encntr_id = f8
		2 priority = i4
		2 active_ind = i2
		2 filter_ind = i2
		2 responsible_prsnl_id = f8
		2 responsible_prsnl_name = vc
		2 responsible_reltn_cd = f8
		2 responsible_reltn_disp = vc
		2 responsible_reltn_id = f8
		2 responsible_reltn_flag = i2
		2 organization_id = f8
		2 confid_level_cd = f8
		2 confid_level_disp = c40
		2 confid_level = i4
		;These fields are currently only filled out by the provider group script
	    2 birthdate					= dq8
	    2 birth_tz					= i4
	    2 end_effective_dt_tm		= dq8
	    2 service_cd                = f8
	    2 service_disp              = c40
	    2 gender_cd                 = f8
   		2 gender_disp               = c40
   		2 temp_location_cd          = f8
	    2 temp_location_disp		= c40
	    2 vip_cd                    = f8
	    2 visit_reason              = vc
	    2 visitor_status_cd         = f8
   		2 visitor_status_disp       = c40
   		2 deceased_date			    = dq8
   		2 deceased_tz			    = i4
   		      ;These fields are currently only filled out by dcp_get_pl_provider_group2 and dcp_get_pl_reltn
   	2 remove_ind = i4
   	2 remove_dt_tm = dq8
%i cclsource:status_block.inc
)
 
free record 600625_request	;dcp_upd_patient_list
record 600625_request		;dcp_upd_patient_list
(
  1 patient_list_id = f8
  1 name = vc
  1 description = vc
  1 patient_list_type_cd = f8
  1 owner_id = f8
  1 arguments[*]
    2 argument_name = vc
    2 argument_value = vc
    2 parent_entity_name = vc
    2 parent_entity_id = f8
  1 encntr_filters[*]
    2 encntr_type_cd = f8
    2 encntr_class_cd = f8
  1 proxies[*]
    2 prsnl_group_id = f8
    2 prsnl_id = f8
    2 list_access_cd = f8
    2 beg_dt_tm = dq8
    2 end_dt_tm = dq8
  1 template_id = f8
)
 
free record 600625_reply	;dcp_upd_patient_list
record 600625_reply			;dcp_upd_patient_list
(
  1 patient_list_id        = f8
%i cclsource:status_block.inc
)
 
free record 600144_request	;dcp_get_pat_list_definition
record 600144_request (
  1 patient_list_id = f8
  1 prsnl_id = f8
  1 definition_version = i4
)
 
free record 600144_reply
record 600144_reply
(
	1 patient_list_id = f8
	1 name = vc
	1 description = vc
	1 patient_list_type_cd = f8
	1 owner_id = f8
	1 access_cd = f8
	1 arguments[*]
		2 argument_name = vc
		2 argument_value = vc
		2 parent_entity_name = vc
		2 parent_entity_id = f8
	1 encntr_type_filters[*]
		2 encntr_type_cd = f8
		2 encntr_class_cd = f8
	1 proxies[*]
		2 prsnl_id = f8
		2 prsnl_group_id = f8
		2 list_access_cd = f8
		2 beg_effective_dt_tm = dq8		;001
    		2 end_effective_dt_tm = dq8		;001
 
%i cclsource:status_block.inc
)
 
 
 
free record 600627_request 			;dcp_upd_custom_pl
record 600627_request 				;dcp_upd_custom_pl
(
  1 patient_list_id = f8
  1 additions[*]
    2 person_id = f8
    2 encounter_id = f8
    2 priority = i4
  1 subtractions[*]
    2 person_id = f8
    2 encounter_id = f8
)
 
free record 600627_reply
record 600627_reply
(
%i cclsource:status_block.inc
)
 
 
free record 600855_request	;dcp_get_child_loc
record 600855_request		;dcp_get_child_loc
(
  1 location_cd = f8
  1 location_type_cd = f8		;used when we need to load locations by type
  1 location_type_list[*]		;location_cd and the list of types which we would like to load for this location_cd
    2 location_type_cd = f8
  1 only_patcare_node_ind = i2	;1 locations with the patcare_node_ind = 1, 0 will not filter based on the patcare_node_ind
)
 
free record 600855_reply	;dcp_get_child_loc
record 600855_reply			;dcp_get_child_loc
(
  1 loc_List[*]
    2 location_cd = f8
    2 location_disp = vc
    2 location_desc = vc
    2 location_mean = vc
    2 location_type_cd = f8
    2 collation_seq = i4
    2 patcare_node_ind = i2
    2 location_type_mean = c12
    2 location_sequence = i4
%i cclsource:status_block.inc
)
 
free record 600614_request	;PTS_GET_PRSNL_GRP_BY_CLASS
record 600614_request		;PTS_GET_PRSNL_GRP_BY_CLASS
(
  1 prsnl_group_class_cd = f8
)
 
free record 600614_reply	;PTS_GET_PRSNL_GRP_BY_CLASS
record 600614_reply			;PTS_GET_PRSNL_GRP_BY_CLASS
(
  1 qual[1]
    2 prsnl_group_id = f8
    2 prsnl_group_type_cd = f8
    2 prsnl_group_type_disp = vc
    2 service_resource_cd = f8
    2 service_resource_disp = c40
%i cclsource:status_block.inc
)
 
free record request_3053	;uzr_get_organization
record request_3053			;uzr_get_organization
(
  1 get_all_flag = i2
  1 facilities_only_ind = i2
  1 OrgType_pref = i2
  1 filter_dir_ind = i2
  1 Org_type[*]
    2 org_type_cd = f8
  1 auth_only_ind = i2
  1 return_types_ind = i2
  1 logical_domain_id = f8
  1 logical_domain_enabled = i2
)
 
free record reply_3053		;uzr_get_organization
record reply_3053			;uzr_get_organization
(
  1 qual[*]
    2 organization_id = f8
    2 org_name = vc
    2 org_types[*] ;*010*
      3 org_type_cd = f8
      3 org_type_disp = c40
      3 org_type_desc = vc
      3 org_type_mean = c12
%i cclsource:status_block.inc
)
 
free record request_3054		;uzr_get_prsnl_org_reltn
record request_3054				;uzr_get_prsnl_org_reltn
(
  1 person_id = f8
  1 filter_dir_ind = i2
  1 OrgType_pref = i2
  1 Org_type[*]
    2 org_type_cd = f8
  1 auth_only_ind = i2
  1 return_types_ind = i2
)
 
free record reply_3054			;uzr_get_prsnl_org_reltn
record reply_3054				;uzr_get_prsnl_org_reltn
(
  1 qual[*]
    2 prsnl_org_reltn_id = f8
    2 organization_id = f8
    2 org_name = vc
    2 person_id = f8
    2 name_full_formatted = vc
    2 confid_level_cd = f8
    2 confid_level_disp = c40
    2 confid_level_desc = c60
    2 service_resource_mean = c12
    2 active_ind = i2
    2 updt_cnt = i4
    2 beg_effective_dt_tm = dq8
    2 end_effective_dt_tm = dq8
    2 org_types[*] ;*007*
      3 org_type_cd = f8
      3 org_type_disp = c40
      3 org_type_desc = vc
      3 org_type_mean = c12
%i cclsource:status_block.inc
)
 
free record request_3055		;uzr_add_org_to_prsnl
record request_3055				;uzr_add_org_to_prsnl
(
  1 person_id = f8
  1 qual[*]
    2 organization_id = f8
    2 active_ind = i2
    2 confid_level_cd = f8
)
 
free record reply_3055			;uzr_add_org_to_prsnl
record reply_3055				;uzr_add_org_to_prsnl
(
  1 qual[*]
  	2 organization_id = f8 ;*004*
  	2 confid_level_cd = f8 ;*004*
    2 prsnl_org_reltn_id = f8
%i cclsource:status_block.inc
)
 
 
 
free record request_3062	;PM_PRSNL_ORG_SET
record request_3062			;PM_PRSNL_ORG_SET
(
  1 action_flag = i2
  1 mode = i2
  1 options = vc
  1 prsnl_id = f8
  1 org_set_type_cd = f8
  1 org_set[*]
    2 subaction_flag = i2
    2 org_set_id = f8
    2 org_set_type_cd = f8
    2 orgs[*]
      3 subaction_flag = i2
      3 org_id = f8
)
 
free record reply_3062_get_action	;PM_PRSNL_ORG_SET
record reply_3062_get_action		;PM_PRSNL_ORG_SET
(
	1 org_sets[*]
		2 org_set_id = f8
		2 org_set_name = vc
		2 org_set_type = f8
		2 prsnl_org_rel_id = f8
%i cclsource:status_block.inc
)
 
free record reply_3062_ens_sets_only	;PM_PRSNL_ORG_SET
record reply_3062_ens_sets_only			;PM_PRSNL_ORG_SET
(
	1 org_set_prsnl_r[*]
		2 org_set_prsnl_id = f8
		2 org_set_id = f8
 
%i cclsource:status_block.inc
)
 
free record request_112510			;PM_ORG_SET
record request_112510				;PM_ORG_SET
(
  1 action_flag = i2
  1 mode = i2
  1 options = vc
  1 org_set_type_cd = f8
  1 org_set_types[*]
    2 org_set_type_cd = f8
  1 org_set[*]
    2 subaction_flag = i2
    2 org_set_id = f8
    2 name = vc
    2 description = vc
    2 attr_bit = i4
    2 org_set_type[*]
      3 subaction_flag = i2
      3 org_set_id = f8
      3 org_set_type_cd = f8
    2 org_set_reltn[*]
      3 subaction_flag = i2
      3 org_set_org_r_id = f8
      3 org_set_id = f8
      3 org_id = f8
  1 org[*]
    2 org_id = f8
    2 org_group[*]
      3 subaction_flag = i2
      3 org_set_id = f8
  1 org_type[*]
    2 org_type_cd = f8
  1 logical_domain_id = f8
  1 logical_domain_enabled = i2
)
 
free record reply_112510
record reply_112510
(
	1 stat = i2
)
 
if (validate(debug_ind) = 0)
	declare debug_ind		= i2 with protect, noconstant(0)
endif
declare echorecord_ind	= i2 with protect, noconstant(0)
declare stat			= i2 with protect, noconstant(0)
declare cnt				= i4 with protect, noconstant(0)
declare i				= i4 with noconstant(0), protect
declare idx				= i4 with noconstant(0), protect
declare ii				= i4 with noconstant(0), protect
declare j				= i4 with noconstant(0), protect
declare k				= i4 with noconstant(0), protect
declare dclstat			= i2 with noconstant(0), protect
declare dclcom			= vc with noconstant(" "), protect
declare query_parser	= vc with noconstant(" "), protect
declare email_list		= vc with noconstant(" "), protect
declare disp_line       = vc with noconstant(" "), protect
declare check_line       = vc with noconstant(" "), protect
declare audit_header    = vc with noconstant(" "), protect
declare audit_line      = vc with noconstant(" "), protect
declare reply_rtf       = vc with noconstant(" "), protect
declare hApp			= i4 with protect, noconstant(0)
declare hTask			= i4 with protect, noconstant(0)
declare hStep			= i4 with protect, noconstant(0)
declare hReq			= i4 with protect, noconstant(0)
declare hMsgList		= i4 with protect, noconstant(0)
declare hNotify			= i4 with protect, noconstant(0)
declare hReply			= i4 with noconstant(0), protect
declare hReplyStatusBlock       = i4 with noconstant(0), protect
declare reply_error             = vc with noconstant(" "), protect
declare reply_status            = vc with noconstant(" "), protect
declare blobout   		= vc with noconstant(" "), protect
declare orig_blob 		= vc with noconstant(" "), protect
declare str 			= vc with noconstant(" "), protect
declare notfnd 			= vc with constant("<not_found>"), protect
declare pos				= i4 with noconstant(0), protect
 
;*************************************************************************
;* Setup Logging
;*************************************************************************
set stat = initrec(program_log)
set program_log->curdomain			= cnvtlower(trim(curdomain))
set program_log->curprog			= cnvtlower(trim(curprog))
set program_log->curnode			= cnvtlower(trim(curnode))
set program_log->files.file_path	= build("/cerner/d_",cnvtlower(trim(curdomain)),"/cclscratch/")
set program_log->files.ccluserdir	= build("/cerner/d_",cnvtlower(trim(curdomain)),"/ccluserdir/")
set program_log->files.filename_log = build(
										 program_log->files.file_path
										,cnvtlower(trim(curdomain))
										,"_",cnvtlower(trim(curprog))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".log"
										)
 
set program_log->email.subject 		= concat(
												 "Emailing Log For: "
												,format(sysdate,"mm/dd/yyyy;;q")
												," "
												,trim(program_log->curdomain)
												," "
												,trim(program_log->curprog)
											)
call echo(build2("program_log->email.subject  = ",program_log->email.subject))
call echo(build2("program_log->files.filename_log = ",program_log->files.filename_log))
 
if (validate(nologvar) = 1)
	set program_log->produce_log = nologvar
	call echo(build2("program_log->produce_log = ",program_log->produce_log))
endif
 
if (validate(noaudvar) = 1)
	set program_log->produce_audit = noaudvar
	call echo(build2("program_log->produce_audit = ",program_log->produce_audit))
endif
 
call startLog(program_log->files.filename_log)			;start log file
 
;*************************************************************************
;* Setup Auditing
;*************************************************************************
 
set program_log->files.filename_audit = build(
										 program_log->files.file_path
										,cnvtlower(trim(curdomain))
										,"_",cnvtlower(trim(curprog))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".csv"
										)
 
 
call echo(build2("program_log->files.filename_audit = ",program_log->files.filename_audit))
 
call startAudit(program_log->files.filename_audit)			;start audit file
 
;*************************************************************************
;* Set debugging variables if defined in Request.
;*************************************************************************
if (validate(request->debug_ind) = 1)
  set debug_ind = request->debug_ind
  call echo(build2("debug_ind = ",cnvtstring(debug_ind)))
endif
if (validate(request->echorecord_ind) = 1)
  set echorecord_ind = request->echorecord_ind
endif
 
 
 
;*************************************************************************
;* SUBROUTINES
;*************************************************************************
;*************************************************************************
;* Add FIN to t_rec->qual[i].FIN based on t_rec->qual[i].encntr_id
;*************************************************************************
 
declare	  	get_fin(null) = null
subroutine	get_fin(null)
 
	call writeLog(build2("** START Finding FIN       ****************************"))
	select into "nl:"
	from
		 encntr_alias ea
		,encounter e
		,(dummyt d1 with seq=size(t_rec->qual,5))
	plan d1
		where t_rec->qual[d1.seq].encntr_id > 0.0
	join e
		where e.encntr_id = t_rec->qual[d1.seq].encntr_id
	join ea
		where ea.encntr_id = e.encntr_id
		and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
		and   ea.active_ind = 1
		and   ea.encntr_alias_type_cd = code_values->cv.cs_319.fin_nbr_cd
	order by
		 e.encntr_id
		,d1.seq
		,e.beg_effective_dt_tm desc
	head report
		call writeLog(build2("**STARTING get_fin"))
	head d1.seq
		call writeLog(build2("-->Adding FIN for t_rec->qual[",trim(cnvtstring(d1.seq)),"].encntr_id = ",trim(cnvtstring(e.
		encntr_id))," as ",trim(cnvtalias(ea.alias,ea.alias_pool_cd))))
		t_rec->qual[d1.seq].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
	foot report
		call writeLog(build2("**ENDING get_fin"))
	with nocounter,nullreport
	call writeLog(build2("** END   Finding FIN       ****************************"))
 
 
end	;get_fin
 
 
;*************************************************************************
;* Add MRN to t_rec->qual[i].MRN based on t_rec->qual[i].person_id
;*************************************************************************
 
declare	  	get_mrn(null) = null
subroutine	get_mrn(null)
 
	call writeLog(build2("** START Finding MRN       ****************************"))
	select into "nl:"
	from
		 person_alias pa
		,person p
		,(dummyt d1 with seq=size(t_rec->qual,5))
	plan d1
		where t_rec->qual[d1.seq].person_id > 0.0
	join p
		where p.person_id = t_rec->qual[d1.seq].person_id
	join pa
		where pa.person_id = p.person_id
		and   pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
		and   pa.active_ind = 1
		and   pa.person_alias_type_cd = code_values->cv.cs_4.mrn_cd
	order by
		 p.person_id
		,d1.seq
		,p.beg_effective_dt_tm desc
	head report
		call writeLog(build2("**STARTING get_mrn"))
	head d1.seq
		call writeLog(build2("-->Adding MRN for t_rec->qual[",trim(cnvtstring(d1.seq)),"].person_id = ",trim(cnvtstring(p.
		person_id))," as ",trim(cnvtalias(pa.alias,pa.alias_pool_cd))))
		t_rec->qual[d1.seq].mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
	foot report
		call writeLog(build2("**ENDING get_mrn"))
	with nocounter,nullreport
	call writeLog(build2("** END   Finding MRN       ****************************"))
 
 
end	;get_mrn
 
;*************************************************************************
;* Return username based on person_id
;*************************************************************************
 
declare	  	get_username(p_id = f8) = vc
subroutine	get_username(p_id)
 	declare temp_username = vc with protect
	call writeLog(build2("** START Getting Username   ****************************"))
	select into "nl:"
	from
		 prsnl p
	plan p
		where p.person_id = p_id
	order by
		 p.person_id
	head report
		call writeLog(build2("**STARTING get_username"))
	head p.person_id
		call writeLog(build2("-->Found Username=",p.username))
		temp_username = p.username
	foot report
		call writeLog(build2("**ENDING get_username"))
	with nocounter,nullreport
	call writeLog(build2("** END   Finding MRN       ****************************"))
 
	return(temp_username)
 
end	;get_username
 
;*************************************************************************
;* Get Full OEF Audit
;*************************************************************************
declare	  	get_oef_audit(null) = null
subroutine	get_oef_audit(null)
	call writeLog(build2("** START OEF Full Audit       ****************************"))
 
	select into "nl:"
	from
		 order_entry_format o
		,order_entry_fields oe
		,oe_format_fields off
		,oe_field_meaning ofm
	plan o
		where o.catalog_type_cd >= 0.0
	join off
		where off.oe_format_id = o.oe_format_id
	join oe
		where oe.oe_field_id = off.oe_field_id
	join ofm
		where ofm.oe_field_meaning_id = oe.oe_field_meaning_id
	order by
		 o.catalog_type_cd
		,o.oe_format_name
		,off.action_type_cd
		,off.group_seq
		,off.field_seq
	head report
		cnt = 0
		stat = alterlist(audit->oef, (cnt + 1000))
	detail
		cnt = (cnt + 1)
		if (mod(cnt,1000) = 1)
			stat = alterlist(audit->oef, (cnt + 999))
		endif
		audit->oef[cnt].catalog_type_cd				= o.catalog_type_cd
		audit->oef[cnt].field_description			= oe.description
		audit->oef[cnt].field_label_text			= off.label_text
		audit->oef[cnt].format_action_cd			= o.action_type_cd
		audit->oef[cnt].oe_field_id					= oe.oe_field_id
		audit->oef[cnt].oe_field_meaning			= ofm.oe_field_meaning
		audit->oef[cnt].oe_field_meaning_id			= oe.oe_field_meaning_id
		audit->oef[cnt].oe_format_id				= o.oe_format_id
		audit->oef[cnt].oe_format_name				= o.oe_format_name
	with nocounter
 
	call writeLog(build2("** END  OEF Full Audit     *********************************"))
end ;get_oef_audit
 
 
;*************************************************************************
;* Add the commands to the rtf_commands record structure
;*************************************************************************
 
declare    set_rtf_commands(null) = null
subroutine set_rtf_commands(null)
	set rtf_commands->st.rhead				= concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}"
													,"{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134")
	set rtf_commands->st.rh2r				= "\plain \f0 \fs18 \cb2 \pard\sl0 "
	set rtf_commands->st.rh2b				= "\plain \f0 \fs24 \b \cb2 \pard\sl0 "
	set rtf_commands->st.rh2bu				= "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
	set rtf_commands->st.rh2u				= "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
	set rtf_commands->st.rh2i				= "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
	set rtf_commands->st.reol				= "\par "
	set rtf_commands->st.rtab				= "\tab "
	set rtf_commands->st.wr		 			= "\plain \f0 \fs20 \cb2 "
	set rtf_commands->st.center	 			= "\qc"
	set rtf_commands->st.wb		 			= "\plain \f0 \fs20 \b \cb2 "
	set rtf_commands->st.wb_end				= "\b0 "
	set rtf_commands->st.wu		 			= "\plain \f0 \fs18 \ul \cb2 "
	set rtf_commands->st.wi		 			= "\plain \f0 \fs18 \i \cb2 "
	set rtf_commands->st.wbi				= "\plain \f0 \fs18 \b \i \cb2 "
	set rtf_commands->st.wiu				= "\plain \f0 \fs18 \i \ul \cb2 "
	set rtf_commands->st.wbiu				= "\plain \f0 \fs18 \b \ul \i \cb2 "
	set rtf_commands->st.wbu				= "\plain \f0 \fs18 \b \ul \cb2 "
	set rtf_commands->st.sb					= "\plain \f0 \fs12 \b \cb2 "
	set rtf_commands->st.sr					= "\plain \f0 \fs12 \cb2 "
	set rtf_commands->st.su					= "\plain \f0 \fs12 \ul \cb2 "
	set rtf_commands->st.si					= "\plain \f0 \fs12 \i \cb2 "
	set rtf_commands->st.sbi				= "\plain \f0 \fs12 \b \i \cb2 "
	set rtf_commands->st.siu				= "\plain \f0 \fs12 \i \ul \cb2 "
	set rtf_commands->st.sbiu				= "\plain \f0 \fs12 \b \ul \i \cb2 "
	set rtf_commands->st.sbu				= "\plain \f0 \fs12 \b \ul \cb2 "
	set rtf_commands->st.rtfeof				= "}"
	set rtf_commands->st.rtf_row_end		= "\row "
	set rtf_commands->st.rtf_table_end		= "\row\pard "
	set rtf_commands->st.rtf_cell_begin		= "\intbl "
	set rtf_commands->st.rtf_cell_end		= "\cell "
	set rtf_commands->st.rtrow_begin		= "\trowd \trgaph180\intbl "
	set rtf_commands->st.rtrow_begin_center	= "\trowd \trqc\trautofit1\intbl "
	set rtf_commands->st.rtrow_brdr_l		= "\clbrdrl\brdrw15\brdrs "
	set rtf_commands->st.rtrow_brdr_b		= "\clbrdrb\brdrw15\brdrs "
	set rtf_commands->st.rtrow_brdr_r		= "\clbrdrr\brdrw15\brdrs "
	set rtf_commands->st.rtrow_brdr_t		= "\clbrdrt\brdrw15\brdrs "
	set rtf_commands->st.rtcell_brdr		= "\clbrdrl\brdrw1\brdrs\clbrdrt\brdrw1\brdrs\clbrdrr\brdrw1\brdrs\clbrdrb\brdrw1\brdrs\"
	set rtf_commands->st.rtcell_brdr_no_l	= "\clbrdrt\brdrw1\brdrs\clbrdrr\brdrw1\brdrs\clbrdrb\brdrw1\brdrs\"
	set rtf_commands->st.rtcell_brdr_no_r	= "\clbrdrt\brdrw1\brdrs\clbrdrl\brdrw1\brdrs\clbrdrb\brdrw1\brdrs\"
	set rtf_commands->st.rtborder			= "\brdrw15\brdrs\clbrdrr\brdrw15\brdrs "
	set rtf_commands->st.rtcell_end			= "\cell "
	set rtf_commands->st.rtrow_end			= "\row "
	set rtf_commands->st.rtend				= "\par "
end ;set_rtf_commands
 
declare    RTFReply(str) = i2
subroutine RTFReply(str)
	if (rtf_commands->start_ind = 0)
		set reply->text 			= str
		set reply_rtf				= str
		set rtf_commands->start_ind = 1
	elseif ((rtf_commands->start_ind = 1) and (rtf_commands->end_ind = 1))
		set reply->text 			= reply_rtf
		call echorecord(reply)
	else
		set reply->text = concat(reply->text,str)
		set reply_rtf 	= concat(reply_rtf,str)
	endif
end	;RTFReply(str)
 
declare    check_ops(null) = null
subroutine check_ops(null)
	call writeLog(build2("* START Check OPS Status ************************************"))
	if (validate(request->batch_selection))
		call writeLog(build2("** script executed from Operations *********"))
		set program_log->run_from_ops = 1
		set program_log->ops_request  = reqinfo->updt_req
 
		call writeLog(build2("--->program_log->run_from_ops =",program_log->run_from_ops))
		call writeLog(build2("--->program_log->ops_request =",program_log->ops_request))
 
		if (program_log->ops_request = 4903)
			call writeLog(build2("** script executed with sys_runccl, getting output *********"))
		endif
	endif
 
	if (validate(request->ops_date))
		call writeLog(build2("--->request->ops_date =",format(request->ops_date,";;q")))
		set program_log->ops_date = request->ops_date
	else
		set program_log->ops_date = cnvtdatetime(curdate,curtime3)
	endif
	call writeLog(build2("--->program_log->ops_date =",format(program_log->ops_date,";;q")))
 
	if (validate(request->output_dist))
		set i = 1
		while (str != notfnd)
			set str = piece(request->output_dist,';',i,notfnd)
			if (str != notfnd)
				call writeLog(build2(^calling addEmailLog for "^,str,^"^))
				call addEmailLog(str)
			endif
			set i = i+1
		endwhile
	endif
 
	if (validate(event->qual[1].encntr_id))
		set program_log->run_from_eks = 1
		set retval = -1
		call writeLog(build2("--->program_log->run_from_eks =",program_log->run_from_eks))
		call writeLog(build2("--->retval =",retval))
	endif
 
	call writeLog(build2("* END   Check OPS Status ************************************"))
end ;subroutine check_ops
 
declare    set_codevalues(null) = null
subroutine set_codevalues(null)
	call writeLog(build2("* START Set Code Values ************************************"))
	call writeLog(build2("** Code Set 4         ************************************"))
	set code_values->cv.cs_4.account_number_cd = uar_get_code_by_cki("CKI.CODEVALUE!2797127")
	set code_values->cv.cs_4.biometric_identifier_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200806244")
	set code_values->cv.cs_4.childmother_tracking_number_cd = uar_get_code_by_cki("CKI.CODEVALUE!4202428990")
	set code_values->cv.cs_4.community_medical_record_number_cd = uar_get_code_by_cki("CKI.CODEVALUE!2621")
	set code_values->cv.cs_4.donor_number_cd = uar_get_code_by_cki("CKI.CODEVALUE!11413")
	set code_values->cv.cs_4.donor_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!9918")
	set code_values->cv.cs_4.drivers_license_number_cd = uar_get_code_by_cki("CKI.CODEVALUE!2622")
	set code_values->cv.cs_4.federated_person_principal_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201594618")
	set code_values->cv.cs_4.filler_order_cd = uar_get_code_by_cki("CKI.CODEVALUE!11410")
	set code_values->cv.cs_4.foreign_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201478967")
	set code_values->cv.cs_4.hic_recipient_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!3250826")
	set code_values->cv.cs_4.historical_cmrn_cd = uar_get_code_by_cki("CKI.CODEVALUE!15183")
	set code_values->cv.cs_4.historical_mrn_cd = uar_get_code_by_cki("CKI.CODEVALUE!15182")
	set code_values->cv.cs_4.hnasysid_cd = uar_get_code_by_cki("CKI.CODEVALUE!11409")
	set code_values->cv.cs_4.insc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200097001")
	set code_values->cv.cs_4.international_donor_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!3250825")
	set code_values->cv.cs_4.cerners_internal_person_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!14986")
	set code_values->cv.cs_4.member_number_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160587783")
	set code_values->cv.cs_4.messaging_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989941")
	set code_values->cv.cs_4.militaryid_cd = uar_get_code_by_cki("CKI.CODEVALUE!9584")
	set code_values->cv.cs_4.military_pin_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201478968")
	set code_values->cv.cs_4.health_exchange_patient_identifier_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200149542")
	set code_values->cv.cs_4.mrn_cd = uar_get_code_by_cki("CKI.CODEVALUE!2623")
	set code_values->cv.cs_4.national_health_number_cd = uar_get_code_by_cki("CKI.CODEVALUE!9585")
	set code_values->cv.cs_4.nmdp_cd = uar_get_code_by_cki("CKI.CODEVALUE!12378")
	set code_values->cv.cs_4.nmdp_donor_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!3250822")
	set code_values->cv.cs_4.nmdp_recipient_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!3250827")
	set code_values->cv.cs_4.cerner_card_number_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200092536")
	set code_values->cv.cs_4.opo_donor_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!3250824")
	set code_values->cv.cs_4.opo_recipient_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!3250828")
	set code_values->cv.cs_4.other_cd = uar_get_code_by_cki("CKI.CODEVALUE!7980")
	set code_values->cv.cs_4.outreach_person_identifier_cd = uar_get_code_by_cki("CKI.CODEVALUE!1301331")
	set code_values->cv.cs_4.outreach_person_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!144874")
	set code_values->cv.cs_4.passport_cd = uar_get_code_by_cki("CKI.CODEVALUE!9586")
	set code_values->cv.cs_4.password_cd = uar_get_code_by_cki("CKI.CODEVALUE!3862198")
	set code_values->cv.cs_4.patient_id_classic_ocf_cd = uar_get_code_by_cki("CKI.CODEVALUE!14360")
	set code_values->cv.cs_4.pbs_patient_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!2562039")
	set code_values->cv.cs_4.person_name_cd = uar_get_code_by_cki("CKI.CODEVALUE!3801")
	set code_values->cv.cs_4.placer_order_cd = uar_get_code_by_cki("CKI.CODEVALUE!11412")
	set code_values->cv.cs_4.prn_cd = uar_get_code_by_cki("CKI.CODEVALUE!2624")
	set code_values->cv.cs_4.pxid_cd = uar_get_code_by_cki("CKI.CODEVALUE!3250829")
	set code_values->cv.cs_4.referring_mrn_cd = uar_get_code_by_cki("CKI.CODEVALUE!56411")
	set code_values->cv.cs_4.state_health_number_cd = uar_get_code_by_cki("CKI.CODEVALUE!9587")
	set code_values->cv.cs_4.ssn_cd = uar_get_code_by_cki("CKI.CODEVALUE!2626")
	set code_values->cv.cs_4.taxpayer_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201478965")
	set code_values->cv.cs_4.temporary_primary_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201478966")
	set code_values->cv.cs_4.unos_cd = uar_get_code_by_cki("CKI.CODEVALUE!12379")
	set code_values->cv.cs_4.unos_donor_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!3250823")
	set code_values->cv.cs_4.version_cd = uar_get_code_by_cki("CKI.CODEVALUE!3862199")
	set code_values->cv.cs_4.veteran_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!4202428988")
	set code_values->cv.cs_4.visa_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201826913")
 
	call writeLog(build2("** Code Set 8         ************************************"))
	set code_values->cv.cs_8.active_cd = uar_get_code_by_cki("CKI.CODEVALUE!2627")
	set code_values->cv.cs_8.altered_cd = uar_get_code_by_cki("CKI.CODEVALUE!16901")
	set code_values->cv.cs_8.anticipated_cd = uar_get_code_by_cki("CKI.CODEVALUE!7981")
	set code_values->cv.cs_8.auth_cd = uar_get_code_by_cki("CKI.CODEVALUE!2628")
	set code_values->cv.cs_8.cancelled_cd = uar_get_code_by_cki("CKI.CODEVALUE!2630")
	set code_values->cv.cs_8.c_transcribe_cd = uar_get_code_by_cki("CKI.CODEVALUE!421865")
	set code_values->cv.cs_8.dictated_cd = uar_get_code_by_cki("CKI.CODEVALUE!28281")
	set code_values->cv.cs_8.in_error_cd = uar_get_code_by_cki("CKI.CODEVALUE!8419")
	set code_values->cv.cs_8.in_lab_cd = uar_get_code_by_cki("CKI.CODEVALUE!2629")
	set code_values->cv.cs_8.in_progress_cd = uar_get_code_by_cki("CKI.CODEVALUE!2637")
	set code_values->cv.cs_8.inerrnomut_cd = uar_get_code_by_cki("CKI.CODEVALUE!20644")
	set code_values->cv.cs_8.inerrnoview_cd = uar_get_code_by_cki("CKI.CODEVALUE!20645")
	set code_values->cv.cs_8.inerror_cd = uar_get_code_by_cki("CKI.CODEVALUE!7982")
	set code_values->cv.cs_8.modified_cd = uar_get_code_by_cki("CKI.CODEVALUE!2636")
	set code_values->cv.cs_8.not_done_cd = uar_get_code_by_cki("CKI.CODEVALUE!2631")
	set code_values->cv.cs_8.rejected_cd = uar_get_code_by_cki("CKI.CODEVALUE!2563990")
	set code_values->cv.cs_8.superseded_cd = uar_get_code_by_cki("CKI.CODEVALUE!2635")
	set code_values->cv.cs_8.transcribed_cd = uar_get_code_by_cki("CKI.CODEVALUE!2632")
	set code_values->cv.cs_8.unauth_cd = uar_get_code_by_cki("CKI.CODEVALUE!2634")
	set code_values->cv.cs_8.unknown_cd = uar_get_code_by_cki("CKI.CODEVALUE!2633")
 
	call writeLog(build2("** Code Set 21        ************************************"))
	set code_values->cv.cs_21.inlab_cd = uar_get_code_by("MEANING",21,"INLAB")
	set code_values->cv.cs_21.cosign_cd = uar_get_code_by("MEANING",21,"COSIGN")
	set code_values->cv.cs_21.insert_cd = uar_get_code_by("MEANING",21,"INSERT")
	set code_values->cv.cs_21.modify_cd = uar_get_code_by("MEANING",21,"MODIFY")
	set code_values->cv.cs_21.order_cd = uar_get_code_by("MEANING",21,"ORDER")
	set code_values->cv.cs_21.perform_cd = uar_get_code_by("MEANING",21,"PERFORM")
	set code_values->cv.cs_21.remove_cd = uar_get_code_by("MEANING",21,"REMOVE")
	set code_values->cv.cs_21.review_cd = uar_get_code_by("MEANING",21,"REVIEW")
	set code_values->cv.cs_21.sign_cd = uar_get_code_by("MEANING",21,"SIGN")
	set code_values->cv.cs_21.start_admin_cd = uar_get_code_by("MEANING",21,"START_ADMIN")
	set code_values->cv.cs_21.stop_admin_cd = uar_get_code_by("MEANING",21,"STOP_ADMIN")
	set code_values->cv.cs_21.transcribe_cd = uar_get_code_by("MEANING",21,"TRANSCRIBE")
	set code_values->cv.cs_21.unknown_cd = uar_get_code_by("MEANING",21,"UNKNOWN")
	set code_values->cv.cs_21.verify_cd = uar_get_code_by("MEANING",21,"VERIFY")
	set code_values->cv.cs_21.assist_cd = uar_get_code_by("MEANING",21,"ASSIST")
	set code_values->cv.cs_21.author_cd = uar_get_code_by("MEANING",21,"AUTHOR")
	set code_values->cv.cs_21.cancel_cd = uar_get_code_by("MEANING",21,"CANCEL")
	set code_values->cv.cs_21.collect_cd = uar_get_code_by("MEANING",21,"COLLECT")
	set code_values->cv.cs_21.correct_cd = uar_get_code_by("MEANING",21,"CORRECT")
	set code_values->cv.cs_21.convey_cd = uar_get_code_by("MEANING",21,"CONVEY")
	set code_values->cv.cs_21.endorse_cd = uar_get_code_by("MEANING",21,"ENDORSE")
	set code_values->cv.cs_21.consumr_revw_cd = uar_get_code_by("MEANING",21,"CONSUMR_REVW")
	set code_values->cv.cs_21.witness_cd = uar_get_code_by("MEANING",21,"WITNESS")
	set code_values->cv.cs_21.flag_cd = uar_get_code_by("MEANING",21,"FLAG")
	set code_values->cv.cs_21.confirm_cd = uar_get_code_by("MEANING",21,"CONFIRM")
	set code_values->cv.cs_21.unconfirm_cd = uar_get_code_by("MEANING",21,"UNCONFIRM")
	set code_values->cv.cs_21.followup_cd = uar_get_code_by("MEANING",21,"FOLLOWUP")
	set code_values->cv.cs_21.copy_cd = uar_get_code_by("MEANING",21,"COPY")
	set code_values->cv.cs_21.endorsesave_cd = uar_get_code_by("MEANING",21,"ENDORSESAVE")
	set code_values->cv.cs_21.unflag_cd = uar_get_code_by("MEANING",21,"UNFLAG")
 
	call writeLog(build2("** Code Set 27        ************************************"))
	set code_values->cv.cs_27.multiple_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201413559")
	set code_values->cv.cs_27.hispanic_latino_or_spanish_origin_cd = uar_get_code_by_cki("CKI.CODEVALUE!1003004")
	set code_values->cv.cs_27.not_hispanic_latino_or_spanish_origin_cd = uar_get_code_by_cki("CKI.CODEVALUE!1003005")
 
	call writeLog(build2("** Code Set 52        ************************************"))
	set  code_values->cv.cs_52.low_cd			= uar_get_code_by_cki("CKI.CODEVALUE!2681")
	set  code_values->cv.cs_52.high_cd			= uar_get_code_by_cki("CKI.CODEVALUE!3803")
	set  code_values->cv.cs_52.critical_cd		= uar_get_code_by_cki("CKI.CODEVALUE!2683")
 
	call writeLog(build2("** Code Set 53        ************************************"))
	set code_values->cv.cs_53.trans_cd = uar_get_code_by("MEANING",53,"TRANS")
	set code_values->cv.cs_53.unknown_cd = uar_get_code_by("MEANING",53,"UNKNOWN")
	set code_values->cv.cs_53.ap_cd = uar_get_code_by("MEANING",53,"AP")
	set code_values->cv.cs_53.count_cd = uar_get_code_by("MEANING",53,"COUNT")
	set code_values->cv.cs_53.date_cd = uar_get_code_by("MEANING",53,"DATE")
	set code_values->cv.cs_53.doc_cd = uar_get_code_by("MEANING",53,"DOC")
	set code_values->cv.cs_53.done_cd = uar_get_code_by("MEANING",53,"DONE")
	set code_values->cv.cs_53.grp_cd = uar_get_code_by("MEANING",53,"GRP")
	set code_values->cv.cs_53.hlatyping_cd = uar_get_code_by("MEANING",53,"HLATYPING")
	set code_values->cv.cs_53.immun_cd = uar_get_code_by("MEANING",53,"IMMUN")
	set code_values->cv.cs_53.interp_cd = uar_get_code_by("MEANING",53,"INTERP")
	set code_values->cv.cs_53.mbo_cd = uar_get_code_by("MEANING",53,"MBO")
	set code_values->cv.cs_53.mdoc_cd = uar_get_code_by("MEANING",53,"MDOC")
	set code_values->cv.cs_53.num_cd = uar_get_code_by("MEANING",53,"NUM")
	set code_values->cv.cs_53.rad_cd = uar_get_code_by("MEANING",53,"RAD")
	set code_values->cv.cs_53.grpdoc_cd = uar_get_code_by("MEANING",53,"GRPDOC")
	set code_values->cv.cs_53.placeholder_cd = uar_get_code_by("MEANING",53,"PLACEHOLDER")
	set code_values->cv.cs_53.addendum_cd = uar_get_code_by("MEANING",53,"ADDENDUM")
	set code_values->cv.cs_53.clindoc_cd = uar_get_code_by("MEANING",53,"CLINDOC")
	set code_values->cv.cs_53.contribution_cd = uar_get_code_by("MEANING",53,"CONTRIBUTION")
	set code_values->cv.cs_53.document_cd = uar_get_code_by("MEANING",53,"DOCUMENT")
	set code_values->cv.cs_53.grpsection_cd = uar_get_code_by("MEANING",53,"GRPSECTION")
	set code_values->cv.cs_53.section_cd = uar_get_code_by("MEANING",53,"SECTION")
	set code_values->cv.cs_53.scdocument_cd = uar_get_code_by("MEANING",53,"SCDOCUMENT")
	set code_values->cv.cs_53.case_cd = uar_get_code_by("MEANING",53,"CASE")
	set code_values->cv.cs_53.procedure_cd = uar_get_code_by("MEANING",53,"PROCEDURE")
	set code_values->cv.cs_53.io_cd = uar_get_code_by("MEANING",53,"IO")
	set code_values->cv.cs_53.med_cd = uar_get_code_by("MEANING",53,"MED")
	set code_values->cv.cs_53.txt_cd = uar_get_code_by("MEANING",53,"TXT")
	set code_values->cv.cs_53.helix_cd = uar_get_code_by("MEANING",53,"HELIX")
	set code_values->cv.cs_53.attachment_cd = uar_get_code_by("MEANING",53,"ATTACHMENT")
 
	call writeLog(build2("** Code Set 69        ************************************"))
	set code_values->cv.cs_69.blood_donation_cd = uar_get_code_by_cki("CKI.CODEVALUE!17004")
	set code_values->cv.cs_69.case_management_cd = uar_get_code_by_cki("CKI.CODEVALUE!2651845")
	set code_values->cv.cs_69.emergency_cd = uar_get_code_by_cki("CKI.CODEVALUE!17005")
	set code_values->cv.cs_69.home_health_cd = uar_get_code_by_cki("CKI.CODEVALUE!15498")
	set code_values->cv.cs_69.inbox_message_cd = uar_get_code_by_cki("CKI.CODEVALUE!2971152")
	set code_values->cv.cs_69.inpatient_cd = uar_get_code_by_cki("CKI.CODEVALUE!17006")
	set code_values->cv.cs_69.observation_cd = uar_get_code_by_cki("CKI.CODEVALUE!73451")
	set code_values->cv.cs_69.outpatient_cd = uar_get_code_by_cki("CKI.CODEVALUE!17007")
	set code_values->cv.cs_69.phone_msg_cd = uar_get_code_by_cki("CKI.CODEVALUE!17008")
	set code_values->cv.cs_69.preadmit_cd = uar_get_code_by_cki("CKI.CODEVALUE!17009")
	set code_values->cv.cs_69.private_duty_cd = uar_get_code_by_cki("CKI.CODEVALUE!17010")
	set code_values->cv.cs_69.recurring_cd = uar_get_code_by_cki("CKI.CODEVALUE!17011")
	set code_values->cv.cs_69.research_cd = uar_get_code_by_cki("CKI.CODEVALUE!11811")
	set code_values->cv.cs_69.skilled_nursing_cd = uar_get_code_by_cki("CKI.CODEVALUE!2785129")
	set code_values->cv.cs_69.wait_list_cd = uar_get_code_by_cki("CKI.CODEVALUE!14363")
 
	call writeLog(build2("** Code Set 71        ************************************"))
	set code_values->cv.cs_71.emergency_cd = uar_get_code_by("DISPLAYKEY",71,"EMERGENCY")
	set code_values->cv.cs_71.day_surgery_cd = uar_get_code_by("DISPLAYKEY",71,"DAYSURGERY")
	set code_values->cv.cs_71.preadmit_cd = uar_get_code_by("DISPLAYKEY",71,"PREADMIT")
	set code_values->cv.cs_71.inpatient_cd = uar_get_code_by("DISPLAYKEY",71,"INPATIENT")
	set code_values->cv.cs_71.observation_cd = uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
	set code_values->cv.cs_71.outpatient_in_a_bed_cd = uar_get_code_by("DISPLAYKEY",71,"OUTPATIENTINABED")
	set code_values->cv.cs_71.outpatient_cd = uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT")
	set code_values->cv.cs_71.outpatient_message_cd = uar_get_code_by("DISPLAYKEY",71,"OUTPATIENTMESSAGE")
	set code_values->cv.cs_71.recurring_cd = uar_get_code_by("DISPLAYKEY",71,"RECURRING")
	set code_values->cv.cs_71.legacy_data_cd = uar_get_code_by("DISPLAYKEY",71,"LEGACYDATA")
	set code_values->cv.cs_71.prereg_cd = uar_get_code_by("DISPLAYKEY",71,"PREREG")
	set code_values->cv.cs_71.clinic_cd = uar_get_code_by("DISPLAYKEY",71,"CLINIC")
	set code_values->cv.cs_71.snf_inpatient_cd = uar_get_code_by("DISPLAYKEY",71,"SNFINPATIENT")
	set code_values->cv.cs_71.prerecurring_cd = uar_get_code_by("DISPLAYKEY",71,"PRERECURRING")
	set code_values->cv.cs_71.phone_message_cd = uar_get_code_by("DISPLAYKEY",71,"PHONEMESSAGE")
	set code_values->cv.cs_71.adolescent_iop_cd = uar_get_code_by("DISPLAYKEY",71,"ADOLESCENTIOP")
	set code_values->cv.cs_71.adult_iop_cd = uar_get_code_by("DISPLAYKEY",71,"ADULTIOP")
	set code_values->cv.cs_71.advanced_pay_outpatient_cd = uar_get_code_by("DISPLAYKEY",71,"ADVANCEDPAYOUTPATIENT")
	set code_values->cv.cs_71.advanced_pay_pt_cd = uar_get_code_by("DISPLAYKEY",71,"ADVANCEDPAYPT")
	set code_values->cv.cs_71.hospital_adult_psych_cd = uar_get_code_by("DISPLAYKEY",71,"HOSPITALADULTPSYCH")
	set code_values->cv.cs_71.blount_clinic_series_cd = uar_get_code_by("DISPLAYKEY",71,"BLOUNTCLINICSERIES")
	set code_values->cv.cs_71.behavioral_health_cd = uar_get_code_by("DISPLAYKEY",71,"BEHAVIORALHEALTH")
	set code_values->cv.cs_71.patricia_neal_outpatient_series_cd = uar_get_code_by("DISPLAYKEY",71,"PATRICIANEALOUTPATIENTSERIES")
	set code_values->cv.cs_71.cancel_admit_cd = uar_get_code_by("DISPLAYKEY",71,"CANCELADMIT")
	set code_values->cv.cs_71.cardiac_diagnostics_cd = uar_get_code_by("DISPLAYKEY",71,"CARDIACDIAGNOSTICS")
	set code_values->cv.cs_71.contract_film_read_only_cd = uar_get_code_by("DISPLAYKEY",71,"CONTRACTFILMREADONLY")
	set code_values->cv.cs_71.contract_operation_health_check_cd = uar_get_code_by("DISPLAYKEY",71,"CONTRACTOPERATIONHEALTHCHECK")
	set code_values->cv.cs_71.contract_cd = uar_get_code_by("DISPLAYKEY",71,"CONTRACT")
	set code_values->cv.cs_71.cancel_upon_review_cd = uar_get_code_by("DISPLAYKEY",71,"CANCELUPONREVIEW")
	set code_values->cv.cs_71.cheyenne_outpatient_clinic_cd = uar_get_code_by("DISPLAYKEY",71,"CHEYENNEOUTPATIENTCLINIC")
	set code_values->cv.cs_71.hospital_outpatient_cd = uar_get_code_by("DISPLAYKEY",71,"HOSPITALOUTPATIENT")
	set code_values->cv.cs_71.results_only_cd = uar_get_code_by("DISPLAYKEY",71,"RESULTSONLY")
	set code_values->cv.cs_71.home_infusion_cd = uar_get_code_by("DISPLAYKEY",71,"HOMEINFUSION")
	set code_values->cv.cs_71.plw_cd = uar_get_code_by("DISPLAYKEY",71,"PLW")
	set code_values->cv.cs_71.smokey_mtn_childrens_home_cd = uar_get_code_by("DISPLAYKEY",71,"SMOKEYMTNCHILDRENSHOME")
	set code_values->cv.cs_71.diagnostic_center_outpatient_cd = uar_get_code_by("DISPLAYKEY",71,"DIAGNOSTICCENTEROUTPATIENT")
	set code_values->cv.cs_71.hospital_adolescent_psych_cd = uar_get_code_by("DISPLAYKEY",71,"HOSPITALADOLESCENTPSYCH")
	set code_values->cv.cs_71.hospital_detox_cd = uar_get_code_by("DISPLAYKEY",71,"HOSPITALDETOX")
	set code_values->cv.cs_71.intermediate_care_nh_cd = uar_get_code_by("DISPLAYKEY",71,"INTERMEDIATECARENH")
	set code_values->cv.cs_71.knox_clinic_series_cd = uar_get_code_by("DISPLAYKEY",71,"KNOXCLINICSERIES")
	set code_values->cv.cs_71.knox_open_arms_clinic_cd = uar_get_code_by("DISPLAYKEY",71,"KNOXOPENARMSCLINIC")
	set code_values->cv.cs_71.loudon_clinic_series_cd = uar_get_code_by("DISPLAYKEY",71,"LOUDONCLINICSERIES")
	set code_values->cv.cs_71.hospital_latency_cd = uar_get_code_by("DISPLAYKEY",71,"HOSPITALLATENCY")
	set code_values->cv.cs_71.non_financial_cd = uar_get_code_by("DISPLAYKEY",71,"NONFINANCIAL")
	set code_values->cv.cs_71.non_commit_psych_hospital_cd = uar_get_code_by("DISPLAYKEY",71,"NONCOMMITPSYCHHOSPITAL")
	set code_values->cv.cs_71.non_patient_lab_specimen_cd = uar_get_code_by("DISPLAYKEY",71,"NONPATIENTLABSPECIMEN")
	set code_values->cv.cs_71.outpatient_monitoring_cd = uar_get_code_by("DISPLAYKEY",71,"OUTPATIENTMONITORING")
	set code_values->cv.cs_71.tcsc_oncology_cd = uar_get_code_by("DISPLAYKEY",71,"TCSCONCOLOGY")
	set code_values->cv.cs_71.tcsc_outpatient_cd = uar_get_code_by("DISPLAYKEY",71,"TCSCOUTPATIENT")
	set code_values->cv.cs_71.pre_reg_pen_op_clinic_cd = uar_get_code_by("DISPLAYKEY",71,"PREREGPENOPCLINIC")
	set code_values->cv.cs_71.scheduled_cd = uar_get_code_by("DISPLAYKEY",71,"SCHEDULED")
	set code_values->cv.cs_71.preadmit_ob_cd = uar_get_code_by("DISPLAYKEY",71,"PREADMITOB")
	set code_values->cv.cs_71.peninsula_outpatients_at_parkwest_cd =
		uar_get_code_by("DISPLAYKEY",71,"PENINSULAOUTPATIENTSATPARKWEST")
	set code_values->cv.cs_71.quick_bed_registration_cd = uar_get_code_by("DISPLAYKEY",71,"QUICKBEDREGISTRATION")
	set code_values->cv.cs_71.quick_ed_registration_cd = uar_get_code_by("DISPLAYKEY",71,"QUICKEDREGISTRATION")
	set code_values->cv.cs_71.quick_lab_registration_cd = uar_get_code_by("DISPLAYKEY",71,"QUICKLABREGISTRATION")
	set code_values->cv.cs_71.rapid_access_preregistration_cd = uar_get_code_by("DISPLAYKEY",71,"RAPIDACCESSPREREGISTRATION")
	set code_values->cv.cs_71.patricia_neal_outpatient_cd = uar_get_code_by("DISPLAYKEY",71,"PATRICIANEALOUTPATIENT")
	set code_values->cv.cs_71.rehab_inpatient_cd = uar_get_code_by("DISPLAYKEY",71,"REHABINPATIENT")
	set code_values->cv.cs_71.sevier_clinic_series_cd = uar_get_code_by("DISPLAYKEY",71,"SEVIERCLINICSERIES")
	set code_values->cv.cs_71.recurring_outpatient_extended_cd = uar_get_code_by("DISPLAYKEY",71,"RECURRINGOUTPATIENTEXTENDED")
	set code_values->cv.cs_71.select_specialty_cd = uar_get_code_by("DISPLAYKEY",71,"SELECTSPECIALTY")
	set code_values->cv.cs_71.therapy_pt_ot_sp_cd = uar_get_code_by("DISPLAYKEY",71,"THERAPYPTOTSP")
	set code_values->cv.cs_71.wound_care_cd = uar_get_code_by("DISPLAYKEY",71,"WOUNDCARE")
	set code_values->cv.cs_71.wellness_recovery_cd = uar_get_code_by("DISPLAYKEY",71,"WELLNESSRECOVERY")
	set code_values->cv.cs_71.clearingwire_account_cd = uar_get_code_by("DISPLAYKEY",71,"CLEARINGWIREACCOUNT")
	set code_values->cv.cs_71.pre_admission_cd = uar_get_code_by("DISPLAYKEY",71,"PREADMISSION")
	set code_values->cv.cs_71.newborn_cd = uar_get_code_by("DISPLAYKEY",71,"NEWBORN")
	set code_values->cv.cs_71.cardio_pulmonary_rehab_cd = uar_get_code_by("DISPLAYKEY",71,"CARDIOPULMONARYREHAB")
	set code_values->cv.cs_71.sleep_lab_recurring_cd = uar_get_code_by("DISPLAYKEY",71,"SLEEPLABRECURRING")
	set code_values->cv.cs_71.multiday_op_diagnostic_cd = uar_get_code_by("DISPLAYKEY",71,"MULTIDAYOPDIAGNOSTIC")
	set code_values->cv.cs_71.women_in_treatment_cd = uar_get_code_by("DISPLAYKEY",71,"WOMENINTREATMENT")
	set code_values->cv.cs_71.intercompany_transfer_cd = uar_get_code_by("DISPLAYKEY",71,"INTERCOMPANYTRANSFER")
	set code_values->cv.cs_71.lab_only_providers_cd = uar_get_code_by("DISPLAYKEY",71,"LABONLYPROVIDERS")
	set code_values->cv.cs_71.quick_lab_only_providers_cd = uar_get_code_by("DISPLAYKEY",71,"QUICKLABONLYPROVIDERS")
 
	call writeLog(build2("** Code Set 73        ************************************"))
	set code_values->cv.cs_73.caretracker_cd = uar_get_code_by("DISPLAYKEY",73,"CARETRACKER")
	set code_values->cv.cs_73.ingenix_cd = uar_get_code_by("DISPLAYKEY",73,"INGENIX")
	set code_values->cv.cs_73.ingenix_authentication_cd = uar_get_code_by("DISPLAYKEY",73,"INGENIXAUTHENTICATION")
	set code_values->cv.cs_73.monitoring_cd = uar_get_code_by("DISPLAYKEY",73,"MONITORING")
	set code_values->cv.cs_73.mayo_rli_cd = uar_get_code_by("DISPLAYKEY",73,"MAYORLI")
	set code_values->cv.cs_73.hl7__aliases_cd = uar_get_code_by("DISPLAYKEY",73,"HL7ALIASES")
	set code_values->cv.cs_73.lynx_cd = uar_get_code_by("DISPLAYKEY",73,"LYNX")
	set code_values->cv.cs_73.twmc_adt_cd = uar_get_code_by("DISPLAYKEY",73,"TWMCADT")
	set code_values->cv.cs_73.okmc_adt_cd = uar_get_code_by("DISPLAYKEY",73,"OKMCADT")
	set code_values->cv.cs_73.stagecoach_adt_cd = uar_get_code_by("DISPLAYKEY",73,"STAGECOACHADT")
	set code_values->cv.cs_73.clinic_charge_ticket_cd = uar_get_code_by("DISPLAYKEY",73,"CLINICCHARGETICKET")
	set code_values->cv.cs_73.bridge_cd = uar_get_code_by("DISPLAYKEY",73,"BRIDGE")
	set code_values->cv.cs_73.cpm_copay_cd = uar_get_code_by("DISPLAYKEY",73,"CPMCOPAY")
	set code_values->cv.cs_73.cms_cd = uar_get_code_by("DISPLAYKEY",73,"CMS")
	set code_values->cv.cs_73.vaccine_registry_cd = uar_get_code_by("DISPLAYKEY",73,"VACCINEREGISTRY")
	set code_values->cv.cs_73.res_affinity_src_cd = uar_get_code_by("DISPLAYKEY",73,"RESAFFINITYSRC")
	set code_values->cv.cs_73.homeworks_cd = uar_get_code_by("DISPLAYKEY",73,"HOMEWORKS")
	set code_values->cv.cs_73.collections_cd = uar_get_code_by("DISPLAYKEY",73,"COLLECTIONS")
	set code_values->cv.cs_73.277castc01_cd = uar_get_code_by("DISPLAYKEY",73,"277CASTC01")
	set code_values->cv.cs_73.277castatus_cd = uar_get_code_by("DISPLAYKEY",73,"277CASTATUS")
	set code_values->cv.cs_73.277castc03_cd = uar_get_code_by("DISPLAYKEY",73,"277CASTC03")
	set code_values->cv.cs_73.accretive_cd = uar_get_code_by("DISPLAYKEY",73,"ACCRETIVE")
	set code_values->cv.cs_73.varian_cd = uar_get_code_by("DISPLAYKEY",73,"VARIAN")
	set code_values->cv.cs_73.syngo_cd = uar_get_code_by("DISPLAYKEY",73,"SYNGO")
	set code_values->cv.cs_73.allergies_cd = uar_get_code_by("DISPLAYKEY",73,"ALLERGIES")
	set code_values->cv.cs_73.usiis_cd = uar_get_code_by("DISPLAYKEY",73,"USIIS")
	set code_values->cv.cs_73.telcor_cd = uar_get_code_by("DISPLAYKEY",73,"TELCOR")
	set code_values->cv.cs_73.ih_export_cd = uar_get_code_by("DISPLAYKEY",73,"IHEXPORT")
	set code_values->cv.cs_73.uhddb_cd = uar_get_code_by("DISPLAYKEY",73,"UHDDB")
	set code_values->cv.cs_73.covenant_cd = uar_get_code_by("DISPLAYKEY",73,"COVENANT")
	set code_values->cv.cs_73.mscm_cd = uar_get_code_by("DISPLAYKEY",73,"MSCM")
	set code_values->cv.cs_73.pmm_cd = uar_get_code_by("DISPLAYKEY",73,"PMM")
	set code_values->cv.cs_73.blount_cd = uar_get_code_by("DISPLAYKEY",73,"BLOUNT")
	set code_values->cv.cs_73.history_cd = uar_get_code_by("DISPLAYKEY",73,"HISTORY")
	set code_values->cv.cs_73.fusion_cd = uar_get_code_by("DISPLAYKEY",73,"FUSION")
	set code_values->cv.cs_73.copath_cd = uar_get_code_by("DISPLAYKEY",73,"COPATH")
	set code_values->cv.cs_73.pathgroup_cd = uar_get_code_by("DISPLAYKEY",73,"PATHGROUP")
	set code_values->cv.cs_73.muse_cd = uar_get_code_by("DISPLAYKEY",73,"MUSE")
	set code_values->cv.cs_73.hx_acute_cd = uar_get_code_by("DISPLAYKEY",73,"HXACUTE")
	set code_values->cv.cs_73.mayo_cd = uar_get_code_by("DISPLAYKEY",73,"MAYO")
	set code_values->cv.cs_73.quest_cd = uar_get_code_by("DISPLAYKEY",73,"QUEST")
	set code_values->cv.cs_73.hx_ccd_chs_src_cd = uar_get_code_by("DISPLAYKEY",73,"HXCCDCHSSRC")
	set code_values->cv.cs_73.vrad_cd = uar_get_code_by("DISPLAYKEY",73,"VRAD")
	set code_values->cv.cs_73.fcor_cd = uar_get_code_by("DISPLAYKEY",73,"FCOR")
	set code_values->cv.cs_73.medilinks_cd = uar_get_code_by("DISPLAYKEY",73,"MEDILINKS")
	set code_values->cv.cs_73.mrs_cd = uar_get_code_by("DISPLAYKEY",73,"MRS")
	set code_values->cv.cs_73.labcorp_amb_cd = uar_get_code_by("DISPLAYKEY",73,"LABCORPAMB")
	set code_values->cv.cs_73.quest_amb_cd = uar_get_code_by("DISPLAYKEY",73,"QUESTAMB")
	set code_values->cv.cs_73.ambulatory_rln_cd = uar_get_code_by("DISPLAYKEY",73,"AMBULATORYRLN")
	set code_values->cv.cs_73.labcorp_cd = uar_get_code_by("DISPLAYKEY",73,"LABCORP")
	set code_values->cv.cs_73.vdcor_cd = uar_get_code_by("DISPLAYKEY",73,"VDCOR")
	set code_values->cv.cs_73.schyulab_cd = uar_get_code_by("DISPLAYKEY",73,"SCHYULAB")
	set code_values->cv.cs_73.labdaqc_cd = uar_get_code_by("DISPLAYKEY",73,"LABDAQC")
	set code_values->cv.cs_73.labdaqs_cd = uar_get_code_by("DISPLAYKEY",73,"LABDAQS")
	set code_values->cv.cs_73.acudose_cd = uar_get_code_by("DISPLAYKEY",73,"ACUDOSE")
	set code_values->cv.cs_73.chuborders_cd = uar_get_code_by("DISPLAYKEY",73,"CHUBORDERS")
	set code_values->cv.cs_73.xds_contributor_source_cd = uar_get_code_by("DISPLAYKEY",73,"XDSCONTRIBUTORSOURCE")
	set code_values->cv.cs_73.muse_cf_cd = uar_get_code_by("DISPLAYKEY",73,"MUSECF")
	set code_values->cv.cs_73.ggastro_cd = uar_get_code_by("DISPLAYKEY",73,"GGASTRO")
	set code_values->cv.cs_73.pacs_cd = uar_get_code_by("DISPLAYKEY",73,"PACS")
	set code_values->cv.cs_73.phs_outbound_cd = uar_get_code_by("DISPLAYKEY",73,"PHSOUTBOUND")
	set code_values->cv.cs_73.train_cd = uar_get_code_by("DISPLAYKEY",73,"TRAIN")
	set code_values->cv.cs_73.automed_cd = uar_get_code_by("DISPLAYKEY",73,"AUTOMED")
	set code_values->cv.cs_73.tog_cd = uar_get_code_by("DISPLAYKEY",73,"TOG")
	set code_values->cv.cs_73.367285_automsgplaces_cd = uar_get_code_by("DISPLAYKEY",73,"367285AUTOMSGPLACES")
	set code_values->cv.cs_73.367286_automsgplaces_cd = uar_get_code_by("DISPLAYKEY",73,"367286AUTOMSGPLACES")
	set code_values->cv.cs_73.ccd_cd = uar_get_code_by("DISPLAYKEY",73,"CCD")
	set code_values->cv.cs_73.hchb_cd = uar_get_code_by("DISPLAYKEY",73,"HCHB")
	set code_values->cv.cs_73.labdaq_cd = uar_get_code_by("DISPLAYKEY",73,"LABDAQ")
	set code_values->cv.cs_73.3m_cd = uar_get_code_by_cki("CKI.CODEVALUE!2765867")
	set code_values->cv.cs_73.3m_hos_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200008824")
	set code_values->cv.cs_73.acr_cd = uar_get_code_by_cki("CKI.CODEVALUE!4110899514")
	set code_values->cv.cs_73.global_address_lookup_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201648598")
	set code_values->cv.cs_73.allergy_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101330148")
	set code_values->cv.cs_73.anatomicpat_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101334188")
	set code_values->cv.cs_73.aps01_cd = uar_get_code_by_cki("CKI.CODEVALUE!9548")
	set code_values->cv.cs_73.aps02_cd = uar_get_code_by_cki("CKI.CODEVALUE!514848")
	set code_values->cv.cs_73.aps03_cd = uar_get_code_by_cki("CKI.CODEVALUE!723877188")
	set code_values->cv.cs_73.ascend_hit_llc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109892518")
	set code_values->cv.cs_73.baxa_cd = uar_get_code_by_cki("CKI.CODEVALUE!4304793")
	set code_values->cv.cs_73.bbt_cd = uar_get_code_by_cki("CKI.CODEVALUE!11954")
	set code_values->cv.cs_73.bcb_cd = uar_get_code_by_cki("CKI.CODEVALUE!4110491129")
	set code_values->cv.cs_73.bloodbank_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101324188")
	set code_values->cv.cs_73.careaware_cd = uar_get_code_by_cki("CKI.CODEVALUE!723972688")
	set code_values->cv.cs_73.ccee_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201826662")
	set code_values->cv.cs_73.cdc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101320368")
	set code_values->cv.cs_73.cdi_cd = uar_get_code_by_cki("CKI.CODEVALUE!3165789")
	set code_values->cv.cs_73.cerner_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101330149")
	set code_values->cv.cs_73.cerner_chr_cd = uar_get_code_by_cki("CKI.CODEVALUE!1435720969")
	set code_values->cv.cs_73.cerner_ldap_cd = uar_get_code_by_cki("CKI.CODEVALUE!4028349")
	set code_values->cv.cs_73.clia_number_cd = uar_get_code_by_cki("CKI.CODEVALUE!723883747")
	set code_values->cv.cs_73.cmw_guided_scheduling_cd = uar_get_code_by_cki("CKI.CODEVALUE!4116972813")
	set code_values->cv.cs_73.cpt4_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101300775")
	set code_values->cv.cs_73.cvx_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101300765")
	set code_values->cv.cs_73.deers_source_cd = uar_get_code_by_cki("CKI.CODEVALUE!4113542402")
	set code_values->cv.cs_73.default_cd = uar_get_code_by_cki("CKI.CODEVALUE!4639")
	set code_values->cv.cs_73.3m_dialect_cd = uar_get_code_by_cki("CKI.CODEVALUE!2570014976")
	set code_values->cv.cs_73.image_cd = uar_get_code_by_cki("CKI.CODEVALUE!723877065")
	set code_values->cv.cs_73.dod_export_cd = uar_get_code_by_cki("CKI.CODEVALUE!4114060261")
	set code_values->cv.cs_73.emirates_card_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201592291")
	set code_values->cv.cs_73.esi_server_cd = uar_get_code_by_cki("CKI.CODEVALUE!7997")
	set code_values->cv.cs_73.esi_testing_1_cd = uar_get_code_by_cki("CKI.CODEVALUE!7996")
	set code_values->cv.cs_73.facility_charge_ticket_cd = uar_get_code_by_cki("CKI.CODEVALUE!12805835")
	set code_values->cv.cs_73.fipspub2_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101300766")
	set code_values->cv.cs_73.firstdata_cd = uar_get_code_by_cki("CKI.CODEVALUE!2790")
	set code_values->cv.cs_73.fmannotation_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201584884")
	set code_values->cv.cs_73.freetext_cd = uar_get_code_by_cki("CKI.CODEVALUE!12219093")
	set code_values->cv.cs_73.global_drug_database_cd = uar_get_code_by_cki("CKI.CODEVALUE!2901617")
	set code_values->cv.cs_73.general_electric_cd = uar_get_code_by_cki("CKI.CODEVALUE!4110837473")
	set code_values->cv.cs_73.generallab_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101330150")
	set code_values->cv.cs_73.generic_card_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200034077")
	set code_values->cv.cs_73.german_egk_card_data_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200836365")
	set code_values->cv.cs_73.german_kvk_card_data_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200836366")
	set code_values->cv.cs_73.haad_cd = uar_get_code_by_cki("CKI.CODEVALUE!4107629651")
	set code_values->cv.cs_73.healthe_idm_cd = uar_get_code_by_cki("CKI.CODEVALUE!1435786628")
	set code_values->cv.cs_73.healtheintent_cd = uar_get_code_by_cki("CKI.CODEVALUE!4112792659")
	set code_values->cv.cs_73.hl7_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101286803")
	set code_values->cv.cs_73.hl7_v2_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200951706")
	set code_values->cv.cs_73.hla_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101334189")
	set code_values->cv.cs_73.hla01_cd = uar_get_code_by_cki("CKI.CODEVALUE!10603")
	set code_values->cv.cs_73.hla02_cd = uar_get_code_by_cki("CKI.CODEVALUE!17012")
	set code_values->cv.cs_73.hla03_cd = uar_get_code_by_cki("CKI.CODEVALUE!46673")
	set code_values->cv.cs_73.hladilution_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101334190")
	set code_values->cv.cs_73.hlameth_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101334191")
	set code_values->cv.cs_73.hlareaction_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101334192")
	set code_values->cv.cs_73.hlatype_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101334193")
	set code_values->cv.cs_73.hlaxmtype_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101334194")
	set code_values->cv.cs_73.icd10cm_cd = uar_get_code_by_cki("CKI.CODEVALUE!4114275225")
	set code_values->cv.cs_73.icd10pcs_cd = uar_get_code_by_cki("CKI.CODEVALUE!4114275224")
	set code_values->cv.cs_73.icd9cm_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101300776")
	set code_values->cv.cs_73.idc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4104678956")
	set code_values->cv.cs_73.ietf2048_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201126333")
	set code_values->cv.cs_73.ietf3066_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101300767")
	set code_values->cv.cs_73.ietf5646_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201624118")
	set code_values->cv.cs_73.ihe_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200102242")
	set code_values->cv.cs_73.infox_cd = uar_get_code_by_cki("CKI.CODEVALUE!3339600")
	set code_values->cv.cs_73.iso_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101300768")
	set code_values->cv.cs_73.iso_639_2_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201126913")
	set code_values->cv.cs_73.kodip_cd = uar_get_code_by_cki("CKI.CODEVALUE!3669280")
	set code_values->cv.cs_73.lab_cd = uar_get_code_by_cki("CKI.CODEVALUE!11503")
	set code_values->cv.cs_73.loinc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101300769")
	set code_values->cv.cs_73.medical_of_california_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200081242")
	set code_values->cv.cs_73.medicode_cd = uar_get_code_by_cki("CKI.CODEVALUE!3759589")
	set code_values->cv.cs_73.medicus_cd = uar_get_code_by_cki("CKI.CODEVALUE!2765887")
	set code_values->cv.cs_73.medical_necessity_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200153702")
	set code_values->cv.cs_73.merge_medical_systems_cd = uar_get_code_by_cki("CKI.CODEVALUE!4103695303")
	set code_values->cv.cs_73.mesh_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201583178")
	set code_values->cv.cs_73.micromedex_cd = uar_get_code_by_cki("CKI.CODEVALUE!3833")
	set code_values->cv.cs_73.ministry_of_health_ontario_cd = uar_get_code_by_cki("CKI.CODEVALUE!3008485")
	set code_values->cv.cs_73.mulalgcat_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101334195")
	set code_values->cv.cs_73.muldclass_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101334196")
	set code_values->cv.cs_73.multum_cd = uar_get_code_by_cki("CKI.CODEVALUE!36701")
	set code_values->cv.cs_73.manufacturers_of_vaccines_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200951708")
	set code_values->cv.cs_73.myp_cd = uar_get_code_by_cki("CKI.CODEVALUE!2786")
	set code_values->cv.cs_73.nci_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101311315")
	set code_values->cv.cs_73.nci_thesaurus_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200951709")
	set code_values->cv.cs_73.ncoder_cd = uar_get_code_by_cki("CKI.CODEVALUE!2765888")
	set code_values->cv.cs_73.ncpdp_cd = uar_get_code_by_cki("CKI.CODEVALUE!2597545")
	set code_values->cv.cs_73.ncpdpscript_cd = uar_get_code_by_cki("CKI.CODEVALUE!1435723619")
	set code_values->cv.cs_73.ndc_cd = uar_get_code_by_cki("CKI.CODEVALUE!2759687")
	set code_values->cv.cs_73.nhs_contributor_source_cd = uar_get_code_by_cki("CKI.CODEVALUE!3865524")
	set code_values->cv.cs_73.nhs_pas_reason_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160587843")
	set code_values->cv.cs_73.nhs_uk_internal_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109338287")
	set code_values->cv.cs_73.nhs_disability_cd = uar_get_code_by_cki("CKI.CODEVALUE!3877502")
	set code_values->cv.cs_73.nhs_address_use_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!3865515")
	set code_values->cv.cs_73.nhs_name_type_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!3865516")
	set code_values->cv.cs_73.nhs_priority_code_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160587838")
	set code_values->cv.cs_73.nhs_contact_method_cd = uar_get_code_by_cki("CKI.CODEVALUE!3877500")
	set code_values->cv.cs_73.nhs_callback_consent_cd = uar_get_code_by_cki("CKI.CODEVALUE!3877501")
	set code_values->cv.cs_73.nhs_copy_correspondence_cd = uar_get_code_by_cki("CKI.CODEVALUE!3877503")
	set code_values->cv.cs_73.nhs_cancel_reason_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!3865521")
	set code_values->cv.cs_73.nhs_did_not_attend_reason_cd = uar_get_code_by_cki("CKI.CODEVALUE!3898021")
	set code_values->cv.cs_73.nhs_ebs_update_person_reason_cd = uar_get_code_by_cki("CKI.CODEVALUE!3877496")
	set code_values->cv.cs_73.nhs_ebookings_error_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!3897968")
	set code_values->cv.cs_73.nhs_telecom_contact_method_cd = uar_get_code_by_cki("CKI.CODEVALUE!3877638")
	set code_values->cv.cs_73.nhs_job_role_code_cd = uar_get_code_by_cki("CKI.CODEVALUE!2510011080")
	set code_values->cv.cs_73.nhs_death_notification_cd = uar_get_code_by_cki("CKI.CODEVALUE!2510010936")
	set code_values->cv.cs_73.nhs_assigning_authorities_cd = uar_get_code_by_cki("CKI.CODEVALUE!3865517")
	set code_values->cv.cs_73.nhs_ethnic_category_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109338241")
	set code_values->cv.cs_73.nhs_organization_types_cd = uar_get_code_by_cki("CKI.CODEVALUE!3878050")
	set code_values->cv.cs_73.nhs_consent_status_cd = uar_get_code_by_cki("CKI.CODEVALUE!3877498")
	set code_values->cv.cs_73.nhs_consent_type_cd = uar_get_code_by_cki("CKI.CODEVALUE!3877497")
	set code_values->cv.cs_73.nhs_suspected_abnormality_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109338350")
	set code_values->cv.cs_73.nhs_stillborn_indicator_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109338330")
	set code_values->cv.cs_73.nhs_delivery_place_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109338339")
	set code_values->cv.cs_73.nhs_interpreter_required_indicator_cd = uar_get_code_by_cki("CKI.CODEVALUE!2510013008")
	set code_values->cv.cs_73.nhs_person_personel_relation_cd = uar_get_code_by_cki("CKI.CODEVALUE!3877499")
	set code_values->cv.cs_73.nhs_number_of_babies_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109338300")
	set code_values->cv.cs_73.nhs_person_relation_type_cd = uar_get_code_by_cki("CKI.CODEVALUE!2510010935")
	set code_values->cv.cs_73.nhs_language_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!3865518")
	set code_values->cv.cs_73.nhs_related_person_relation_code_cd = uar_get_code_by_cki("CKI.CODEVALUE!2510010934")
	set code_values->cv.cs_73.nhs_preferred_written_comm_format_cd = uar_get_code_by_cki("CKI.CODEVALUE!2510010937")
	set code_values->cv.cs_73.nhs_multiple_birth_order_number_cd = uar_get_code_by_cki("CKI.CODEVALUE!2510010938")
	set code_values->cv.cs_73.nhs_lrs_response_type_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!723875030")
	set code_values->cv.cs_73.nhs_lr_type_cd = uar_get_code_by_cki("CKI.CODEVALUE!12346536")
	set code_values->cv.cs_73.nhs_access_reason_code_cd = uar_get_code_by_cki("CKI.CODEVALUE!12346537")
	set code_values->cv.cs_73.nhs_sc_reason_code_cd = uar_get_code_by_cki("CKI.CODEVALUE!12346538")
	set code_values->cv.cs_73.nhs_phone_use_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!3865519")
	set code_values->cv.cs_73.nhs_administrative_gender_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!3865520")
	set code_values->cv.cs_73.nhs_position_codes_cd = uar_get_code_by_cki("CKI.CODEVALUE!3877637")
	set code_values->cv.cs_73.nhs_can_rsn_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160606220")
	set code_values->cv.cs_73.nhs_dna_rsn_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160606221")
	set code_values->cv.cs_73.national_health_system_cd = uar_get_code_by_cki("CKI.CODEVALUE!3651716")
	set code_values->cv.cs_73.national_immunization_program_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200951707")
	set code_values->cv.cs_73.nucc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101300770")
	set code_values->cv.cs_73.code_system_contributor_source_cd = uar_get_code_by_cki("CKI.CODEVALUE!3851495")
	set code_values->cv.cs_73.patient_friendly_display_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201422240")
	set code_values->cv.cs_73.pharma_cd = uar_get_code_by_cki("CKI.CODEVALUE!4102947887")
	set code_values->cv.cs_73.phinvads_cd = uar_get_code_by_cki("CKI.CODEVALUE!4116940579")
	set code_values->cv.cs_73.powerchart_cd = uar_get_code_by_cki("CKI.CODEVALUE!2787")
	set code_values->cv.cs_73.ed_professional_coding_and_charging_cd = uar_get_code_by_cki("CKI.CODEVALUE!4100277341")
	set code_values->cv.cs_73.profile_cd = uar_get_code_by_cki("CKI.CODEVALUE!14364")
	set code_values->cv.cs_73.ptcare_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101334197")
	set code_values->cv.cs_73.pyxis_cd = uar_get_code_by_cki("CKI.CODEVALUE!12183731")
	set code_values->cv.cs_73.rad01_cd = uar_get_code_by_cki("CKI.CODEVALUE!7998")
	set code_values->cv.cs_73.revenue_cycle_analytics_cd = uar_get_code_by_cki("CKI.CODEVALUE!723879886")
	set code_values->cv.cs_73.redbook_cd = uar_get_code_by_cki("CKI.CODEVALUE!2789")
	set code_values->cv.cs_73.referral_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200814404")
	set code_values->cv.cs_73.rxnorm_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101300771")
	set code_values->cv.cs_73.sds_contributor_source_cd = uar_get_code_by_cki("CKI.CODEVALUE!3909671")
	set code_values->cv.cs_73.siemens_healthcare_cd = uar_get_code_by_cki("CKI.CODEVALUE!4115030321")
	set code_values->cv.cs_73.snomed_ct_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101300772")
	set code_values->cv.cs_73.system_cd = uar_get_code_by_cki("CKI.CODEVALUE!2788")
	set code_values->cv.cs_73.unified_code_for_units_of_measure_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101285544")
	set code_values->cv.cs_73.umls_cd = uar_get_code_by_cki("CKI.CODEVALUE!9549")
	set code_values->cv.cs_73.unii_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101300773")
	set code_values->cv.cs_73.vsac_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201613418")
	set code_values->cv.cs_73.x12claim_cd = uar_get_code_by_cki("CKI.CODEVALUE!1435708868")
	set code_values->cv.cs_73.xr_xml_cd = uar_get_code_by_cki("CKI.CODEVALUE!4100272125")
 
	call writeLog(build2("** Code Set 79        ************************************"))
	set code_values->cv.cs_79.canceled_cd = uar_get_code_by("MEANING",79,"CANCELED")
	set code_values->cv.cs_79.complete_cd = uar_get_code_by("MEANING",79,"COMPLETE")
	set code_values->cv.cs_79.deleted_cd = uar_get_code_by("MEANING",79,"DELETED")
	set code_values->cv.cs_79.delivered_cd = uar_get_code_by("MEANING",79,"DELIVERED")
	set code_values->cv.cs_79.discontinued_cd = uar_get_code_by("MEANING",79,"DISCONTINUED")
	set code_values->cv.cs_79.dropped_cd = uar_get_code_by("MEANING",79,"DROPPED")
	set code_values->cv.cs_79.inerror_cd = uar_get_code_by("MEANING",79,"INERROR")
	set code_values->cv.cs_79.inprocess_cd = uar_get_code_by("MEANING",79,"INPROCESS")
	set code_values->cv.cs_79.onhold_cd = uar_get_code_by("MEANING",79,"ONHOLD")
	set code_values->cv.cs_79.opened_cd = uar_get_code_by("MEANING",79,"OPENED")
	set code_values->cv.cs_79.overdue_cd = uar_get_code_by("MEANING",79,"OVERDUE")
	set code_values->cv.cs_79.pending_cd = uar_get_code_by("MEANING",79,"PENDING")
	set code_values->cv.cs_79.read_cd = uar_get_code_by("MEANING",79,"READ")
	set code_values->cv.cs_79.rework_cd = uar_get_code_by("MEANING",79,"REWORK")
	set code_values->cv.cs_79.suspended_cd = uar_get_code_by("MEANING",79,"SUSPENDED")
	set code_values->cv.cs_79.refused_cd = uar_get_code_by("MEANING",79,"REFUSED")
	set code_values->cv.cs_79.validation_cd = uar_get_code_by("MEANING",79,"VALIDATION")
	set code_values->cv.cs_79.recalled_cd = uar_get_code_by("MEANING",79,"RECALLED")
	set code_values->cv.cs_79.readwaitsign_cd = uar_get_code_by("MEANING",79,"READWAITSIGN")
 
	call writeLog(build2("** Code Set 103       ************************************"))
	set code_values->cv.cs_103.canceled_cd = uar_get_code_by("MEANING",103,"CANCELED")
	set code_values->cv.cs_103.completed_cd = uar_get_code_by("MEANING",103,"COMPLETED")
	set code_values->cv.cs_103.deleted_cd = uar_get_code_by("MEANING",103,"DELETED")
	set code_values->cv.cs_103.inerror_cd = uar_get_code_by("MEANING",103,"INERROR")
	set code_values->cv.cs_103.refused_cd = uar_get_code_by("MEANING",103,"REFUSED")
	set code_values->cv.cs_103.requested_cd = uar_get_code_by("MEANING",103,"REQUESTED")
	set code_values->cv.cs_103.unknown_cd = uar_get_code_by("MEANING",103,"UNKNOWN")
	set code_values->cv.cs_103.pending_cd = uar_get_code_by("MEANING",103,"PENDING")
 
	call writeLog(build2("** Code Set 106       ************************************"))
	set code_values->cv.cs_106.cardiovascular_cd = uar_get_code_by("MEANING",106,"CARDIOVASCUL")
 
	call writeLog(build2("** Code Set 120       ************************************"))
	set  code_values->cv.cs_120.nocomp_cd  		= uar_get_code_by("MEANING",120,"NOCOMP"	)		;NOCOMP
	set  code_values->cv.cs_120.ocfcomp_cd  	= uar_get_code_by("MEANING",120,"OCFCOMP"	)		;OCFCOMP
 
	call writeLog(build2("** Code Set 212       ************************************"))
	set code_values->cv.cs_212.alpha_pager_cd = uar_get_code_by_cki("CKI.CODEVALUE!3164462")
	set code_values->cv.cs_212.alternate_cd = uar_get_code_by_cki("CKI.CODEVALUE!9559")
	set code_values->cv.cs_212.billing_cd = uar_get_code_by_cki("CKI.CODEVALUE!8007")
	set code_values->cv.cs_212.bill_to_cd = uar_get_code_by_cki("CKI.CODEVALUE!8008")
	set code_values->cv.cs_212.birth_cd = uar_get_code_by_cki("CKI.CODEVALUE!9560")
	set code_values->cv.cs_212.business_cd = uar_get_code_by_cki("CKI.CODEVALUE!8009")
	set code_values->cv.cs_212.email_cd = uar_get_code_by_cki("CKI.CODEVALUE!8010")
	set code_values->cv.cs_212.eprescribing_cd = uar_get_code_by_cki("CKI.CODEVALUE!4102433413")
	set code_values->cv.cs_212.home_cd = uar_get_code_by_cki("CKI.CODEVALUE!4018")
	set code_values->cv.cs_212.mailing_cd = uar_get_code_by_cki("CKI.CODEVALUE!8011")
	set code_values->cv.cs_212.previous_cd = uar_get_code_by_cki("CKI.CODEVALUE!9561")
	set code_values->cv.cs_212.product_return_cd = uar_get_code_by_cki("CKI.CODEVALUE!8435")
	set code_values->cv.cs_212.professional_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989926")
	set code_values->cv.cs_212.remittance_cd = uar_get_code_by_cki("CKI.CODEVALUE!8012")
	set code_values->cv.cs_212.roi_cd = uar_get_code_by_cki("CKI.CODEVALUE!10218")
	set code_values->cv.cs_212.secondary_business_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989925")
	set code_values->cv.cs_212.ship_to_cd = uar_get_code_by_cki("CKI.CODEVALUE!8013")
	set code_values->cv.cs_212.technical_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989927")
	set code_values->cv.cs_212.temporary_cd = uar_get_code_by_cki("CKI.CODEVALUE!8014")
	set code_values->cv.cs_212.usual_cd = uar_get_code_by_cki("CKI.CODEVALUE!3862202")
 
	call writeLog(build2("** Code Set 222       ************************************"))
	set code_values->cv.cs_222.activity_assignment_view_cd = uar_get_code_by_cki("CKI.CODEVALUE!472650")
	set code_values->cv.cs_222.rx_station_cluster_cd = uar_get_code_by_cki("CKI.CODEVALUE!12105770")
	set code_values->cv.cs_222.ambulatorys_cd = uar_get_code_by_cki("CKI.CODEVALUE!9458")
	set code_values->cv.cs_222.surgery_cd = uar_get_code_by_cki("CKI.CODEVALUE!2859")
	set code_values->cv.cs_222.appointment_locations_cd = uar_get_code_by_cki("CKI.CODEVALUE!11420")
	set code_values->cv.cs_222.scheduling_views_cd = uar_get_code_by_cki("CKI.CODEVALUE!11421")
	set code_values->cv.cs_222.bb_drawing_stations_cd = uar_get_code_by_cki("CKI.CODEVALUE!9499")
	set code_values->cv.cs_222.bb_inventory_area_cd = uar_get_code_by_cki("CKI.CODEVALUE!9500")
	set code_values->cv.cs_222.bb_owner_area_views_cd = uar_get_code_by_cki("CKI.CODEVALUE!9501")
	set code_values->cv.cs_222.beds_cd = uar_get_code_by_cki("CKI.CODEVALUE!2851")
	set code_values->cv.cs_222.buildings_cd = uar_get_code_by_cki("CKI.CODEVALUE!2843")
	set code_values->cv.cs_222.check_outs_cd = uar_get_code_by_cki("CKI.CODEVALUE!2858")
	set code_values->cv.cs_222.specimen_collection_views_cd = uar_get_code_by_cki("CKI.CODEVALUE!6949")
	set code_values->cv.cs_222.collection_routes_cd = uar_get_code_by_cki("CKI.CODEVALUE!3769")
	set code_values->cv.cs_222.collection_runs_cd = uar_get_code_by_cki("CKI.CODEVALUE!2855")
	set code_values->cv.cs_222.specimen_login_locations_cd = uar_get_code_by_cki("CKI.CODEVALUE!3720")
	set code_values->cv.cs_222.specimen_tracking_locations_cd = uar_get_code_by_cki("CKI.CODEVALUE!9502")
	set code_values->cv.cs_222.facilitys_cd = uar_get_code_by_cki("CKI.CODEVALUE!2844")
	set code_values->cv.cs_222.followup_clinic_cd = uar_get_code_by_cki("CKI.CODEVALUE!3924334")
	set code_values->cv.cs_222.health_information_mgmt_cd = uar_get_code_by_cki("CKI.CODEVALUE!8016")
	set code_values->cv.cs_222.health_information_mgmt_views_cd = uar_get_code_by_cki("CKI.CODEVALUE!6950")
	set code_values->cv.cs_222.inventory_groups_cd = uar_get_code_by_cki("CKI.CODEVALUE!10608")
	set code_values->cv.cs_222.inventory_locations_cd = uar_get_code_by_cki("CKI.CODEVALUE!2848")
	set code_values->cv.cs_222.inventory_locators_cd = uar_get_code_by_cki("CKI.CODEVALUE!2846")
	set code_values->cv.cs_222.inventory_view_cd = uar_get_code_by_cki("CKI.CODEVALUE!2852")
	set code_values->cv.cs_222.laboratorys_cd = uar_get_code_by_cki("CKI.CODEVALUE!2853")
	set code_values->cv.cs_222.materials_management_group_views_cd = uar_get_code_by_cki("CKI.CODEVALUE!6951")
	set code_values->cv.cs_222.nurse_units_cd = uar_get_code_by_cki("CKI.CODEVALUE!2845")
	set code_values->cv.cs_222.patient_list_view_cd = uar_get_code_by_cki("CKI.CODEVALUE!2598223")
	set code_values->cv.cs_222.pharmacys_cd = uar_get_code_by_cki("CKI.CODEVALUE!2854")
	set code_values->cv.cs_222.remote_location_cd = uar_get_code_by_cki("CKI.CODEVALUE!2661171")
	set code_values->cv.cs_222.prearrival_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160834022")
	set code_values->cv.cs_222.recycle_cd = uar_get_code_by_cki("CKI.CODEVALUE!2850")
	set code_values->cv.cs_222.patient_tracking_view_cd = uar_get_code_by_cki("CKI.CODEVALUE!10609")
	set code_values->cv.cs_222.radiology_cd = uar_get_code_by_cki("CKI.CODEVALUE!25069")
	set code_values->cv.cs_222.rx_station_return_bin_cd = uar_get_code_by_cki("CKI.CODEVALUE!12105771")
	set code_values->cv.cs_222.rooms_cd = uar_get_code_by_cki("CKI.CODEVALUE!2842")
	set code_values->cv.cs_222.rounds_list_view_cd = uar_get_code_by_cki("CKI.CODEVALUE!25071")
	set code_values->cv.cs_222.rx_location_group_cd = uar_get_code_by_cki("CKI.CODEVALUE!10604")
	set code_values->cv.cs_222.rxstation_view_cd = uar_get_code_by_cki("CKI.CODEVALUE!12265029")
	set code_values->cv.cs_222.shift_assignment_view_cd = uar_get_code_by_cki("CKI.CODEVALUE!2563993")
	set code_values->cv.cs_222.specimen_tracking_viewss_cd = uar_get_code_by_cki("CKI.CODEVALUE!11422")
	set code_values->cv.cs_222.service_areas_cd = uar_get_code_by_cki("CKI.CODEVALUE!2856")
	set code_values->cv.cs_222.storage_compartments_cd = uar_get_code_by_cki("CKI.CODEVALUE!723874071")
	set code_values->cv.cs_222.storage_racks_cd = uar_get_code_by_cki("CKI.CODEVALUE!9503")
	set code_values->cv.cs_222.storage_tracking_views_cd = uar_get_code_by_cki("CKI.CODEVALUE!10182")
	set code_values->cv.cs_222.storage_shelfs_cd = uar_get_code_by_cki("CKI.CODEVALUE!9504")
	set code_values->cv.cs_222.storage_trays_cd = uar_get_code_by_cki("CKI.CODEVALUE!9505")
	set code_values->cv.cs_222.storage_units_cd = uar_get_code_by_cki("CKI.CODEVALUE!9506")
	set code_values->cv.cs_222.storage_tracking_views_cd = uar_get_code_by_cki("CKI.CODEVALUE!9507")
	set code_values->cv.cs_222.surgery_fill_cd = uar_get_code_by_cki("CKI.CODEVALUE!10607")
	set code_values->cv.cs_222.transport_cd = uar_get_code_by_cki("CKI.CODEVALUE!25070")
	set code_values->cv.cs_222.task_group_view_cd = uar_get_code_by_cki("CKI.CODEVALUE!258284")
	set code_values->cv.cs_222.waiting_rooms_cd = uar_get_code_by_cki("CKI.CODEVALUE!2857")
 
	call writeLog(build2("** Code Set 263       ************************************"))
	set code_values->cv.cs_263.health_plan_cd = uar_get_code_by("DISPLAYKEY",263,"HEALTHPLAN")
	set code_values->cv.cs_263.dea_cd = uar_get_code_by("DISPLAYKEY",263,"DEA")
	set code_values->cv.cs_263.star_doctor_number_cd = uar_get_code_by("DISPLAYKEY",263,"STARDOCTORNUMBER")
	set code_values->cv.cs_263.encounter_org_cd = uar_get_code_by("DISPLAYKEY",263,"ENCOUNTERORG")
	set code_values->cv.cs_263.external_id_cd = uar_get_code_by("DISPLAYKEY",263,"EXTERNALID")
	set code_values->cv.cs_263.insurance_code_cd = uar_get_code_by("DISPLAYKEY",263,"INSURANCECODE")
	set code_values->cv.cs_263.media_alias_cd = uar_get_code_by("DISPLAYKEY",263,"MEDIAALIAS")
	set code_values->cv.cs_263.ssn_cd = uar_get_code_by("DISPLAYKEY",263,"SSN")
	set code_values->cv.cs_263.upin_cd = uar_get_code_by("DISPLAYKEY",263,"UPIN")
	set code_values->cv.cs_263.personnel_primary_identifier_cd = uar_get_code_by("DISPLAYKEY",263,"PERSONNELPRIMARYIDENTIFIER")
	set code_values->cv.cs_263.pft_statement_alias_cd = uar_get_code_by("DISPLAYKEY",263,"PFTSTATEMENTALIAS")
	set code_values->cv.cs_263.pft_claim_alias_pool_cd = uar_get_code_by("DISPLAYKEY",263,"PFTCLAIMALIASPOOL")
	set code_values->cv.cs_263.org_unique_identifier_cd = uar_get_code_by("DISPLAYKEY",263,"ORGUNIQUEIDENTIFIER")
	set code_values->cv.cs_263.financial_extract_org_alias_cd = uar_get_code_by("DISPLAYKEY",263,"FINANCIALEXTRACTORGALIAS")
	set code_values->cv.cs_263.visit_id_cd = uar_get_code_by("DISPLAYKEY",263,"VISITID")
	set code_values->cv.cs_263.naic_cd = uar_get_code_by("DISPLAYKEY",263,"NAIC")
	set code_values->cv.cs_263.client_code_cd = uar_get_code_by("DISPLAYKEY",263,"CLIENTCODE")
	set code_values->cv.cs_263.organization_npi_cd = uar_get_code_by("DISPLAYKEY",263,"ORGANIZATIONNPI")
	set code_values->cv.cs_263.provider_messaging_cd = uar_get_code_by("DISPLAYKEY",263,"PROVIDERMESSAGING")
	set code_values->cv.cs_263.surescripts_prescriber__index_cd = uar_get_code_by("DISPLAYKEY",263,"SURESCRIPTSPRESCRIBERINDEX")
	set code_values->cv.cs_263.consumer_messaging_cd = uar_get_code_by("DISPLAYKEY",263,"CONSUMERMESSAGING")
	set code_values->cv.cs_263.unos_donor_id_cd = uar_get_code_by("DISPLAYKEY",263,"UNOSDONORID")
	set code_values->cv.cs_263.local_messaging_bw_cd = uar_get_code_by("DISPLAYKEY",263,"LOCALMESSAGINGBW")
	set code_values->cv.cs_263.xds_alias_pool_cd = uar_get_code_by("DISPLAYKEY",263,"XDSALIASPOOL")
	set code_values->cv.cs_263.national_provider_identifier_cd = uar_get_code_by("DISPLAYKEY",263,"NATIONALPROVIDERIDENTIFIER")
	set code_values->cv.cs_263.texas_dea_cd = uar_get_code_by("DISPLAYKEY",263,"TEXASDEA")
	set code_values->cv.cs_263.nct_number_cd = uar_get_code_by("DISPLAYKEY",263,"NCTNUMBER")
	set code_values->cv.cs_263.default_place_of_service_cd = uar_get_code_by("DISPLAYKEY",263,"DEFAULTPLACEOFSERVICE")
	set code_values->cv.cs_263.naic_org_cd = uar_get_code_by("DISPLAYKEY",263,"NAICORG")
	set code_values->cv.cs_263.rxhx_order_event_id_cd = uar_get_code_by("DISPLAYKEY",263,"RXHXORDEREVENTID")
	set code_values->cv.cs_263.pft_invoice_alias_pool_cd = uar_get_code_by("DISPLAYKEY",263,"PFTINVOICEALIASPOOL")
	set code_values->cv.cs_263.health_plan_address_cd = uar_get_code_by("DISPLAYKEY",263,"HEALTHPLANADDRESS")
	set code_values->cv.cs_263.temp_mrn_cd = uar_get_code_by("DISPLAYKEY",263,"TEMPMRN")
	set code_values->cv.cs_263.temp_fin_cd = uar_get_code_by("DISPLAYKEY",263,"TEMPFIN")
	set code_values->cv.cs_263.nextgen_person_id_cd = uar_get_code_by("DISPLAYKEY",263,"NEXTGENPERSONID")
	set code_values->cv.cs_263.cerner_fin_cd = uar_get_code_by("DISPLAYKEY",263,"CERNERFIN")
	set code_values->cv.cs_263.cmrn_cd = uar_get_code_by("DISPLAYKEY",263,"CMRN")
	set code_values->cv.cs_263.star_fin_cd = uar_get_code_by("DISPLAYKEY",263,"STARFIN")
	set code_values->cv.cs_263.cerner_mrn_cd = uar_get_code_by("DISPLAYKEY",263,"CERNERMRN")
	set code_values->cv.cs_263.star_mrn_rmc_cd = uar_get_code_by("DISPLAYKEY",263,"STARMRNRMC")
	set code_values->cv.cs_263.star_mrn_mmc_cd = uar_get_code_by("DISPLAYKEY",263,"STARMRNMMC")
	set code_values->cv.cs_263.star_mrn_fsr_cd = uar_get_code_by("DISPLAYKEY",263,"STARMRNFSR")
	set code_values->cv.cs_263.star_mrn_cmc_cd = uar_get_code_by("DISPLAYKEY",263,"STARMRNCMC")
	set code_values->cv.cs_263.star_mrn_clmc_cd = uar_get_code_by("DISPLAYKEY",263,"STARMRNCLMC")
	set code_values->cv.cs_263.star_mrn_lcmc_cd = uar_get_code_by("DISPLAYKEY",263,"STARMRNLCMC")
	set code_values->cv.cs_263.star_mrn_flmc_cd = uar_get_code_by("DISPLAYKEY",263,"STARMRNFLMC")
	set code_values->cv.cs_263.star_mrn_mhhs_cd = uar_get_code_by("DISPLAYKEY",263,"STARMRNMHHS")
	set code_values->cv.cs_263.star_mrn_pw_cd = uar_get_code_by("DISPLAYKEY",263,"STARMRNPW")
	set code_values->cv.cs_263.star_mrn_pbh_cd = uar_get_code_by("DISPLAYKEY",263,"STARMRNPBH")
	set code_values->cv.cs_263.star_mrn_tcsc_cd = uar_get_code_by("DISPLAYKEY",263,"STARMRNTCSC")
	set code_values->cv.cs_263.cov_hp_search_cd = uar_get_code_by("DISPLAYKEY",263,"COVHPSEARCH")
	set code_values->cv.cs_263.item_master_org_cd = uar_get_code_by("DISPLAYKEY",263,"ITEMMASTERORG")
	set code_values->cv.cs_263.taxonomy_id_cd = uar_get_code_by("DISPLAYKEY",263,"TAXONOMYID")
	set code_values->cv.cs_263.personnel_badge_id_cd = uar_get_code_by("DISPLAYKEY",263,"PERSONNELBADGEID")
	set code_values->cv.cs_263.state_license_number_cd = uar_get_code_by("DISPLAYKEY",263,"STATELICENSENUMBER")
	set code_values->cv.cs_263.cerner_federated_person_principal_cd =
		uar_get_code_by("DISPLAYKEY",263,"CERNERFEDERATEDPERSONPRINCIPAL")
	set code_values->cv.cs_263.rln_quest_filler_order_id_cd = uar_get_code_by("DISPLAYKEY",263,"RLNQUESTFILLERORDERID")
	set code_values->cv.cs_263.rln_mayo_filler_order_id_cd = uar_get_code_by("DISPLAYKEY",263,"RLNMAYOFILLERORDERID")
	set code_values->cv.cs_263.cpm_client_facility_cd = uar_get_code_by("DISPLAYKEY",263,"CPMCLIENTFACILITY")
	set code_values->cv.cs_263.cdadefaultpool_0_cd = uar_get_code_by("DISPLAYKEY",263,"CDADEFAULTPOOL0")
	set code_values->cv.cs_263.hx_bb_supplier_org_cd = uar_get_code_by("DISPLAYKEY",263,"HXBBSUPPLIERORG")
	set code_values->cv.cs_263.arln_quest_mrn_cd = uar_get_code_by("DISPLAYKEY",263,"ARLNQUESTMRN")
	set code_values->cv.cs_263.arln_labcorp_mrn_cd = uar_get_code_by("DISPLAYKEY",263,"ARLNLABCORPMRN")
	set code_values->cv.cs_263.arln_quest_fin_cd = uar_get_code_by("DISPLAYKEY",263,"ARLNQUESTFIN")
	set code_values->cv.cs_263.arln_labcorp_fin_cd = uar_get_code_by("DISPLAYKEY",263,"ARLNLABCORPFIN")
	set code_values->cv.cs_263.chub_placer_order_id_cd = uar_get_code_by("DISPLAYKEY",263,"CHUBPLACERORDERID")
	set code_values->cv.cs_263.resonance_alias_pool_chs_cd = uar_get_code_by("DISPLAYKEY",263,"RESONANCEALIASPOOLCHS")
	set code_values->cv.cs_263.mscm_item_master_cd = uar_get_code_by("DISPLAYKEY",263,"MSCMITEMMASTER")
	set code_values->cv.cs_263.strata_pharmacy_org_ids_cd = uar_get_code_by("DISPLAYKEY",263,"STRATAPHARMACYORGIDS")
	set code_values->cv.cs_263.arln_health_plan_pool_cd = uar_get_code_by("DISPLAYKEY",263,"ARLNHEALTHPLANPOOL")
	set code_values->cv.cs_263.rop_user_cd = uar_get_code_by("DISPLAYKEY",263,"ROPUSER")
	set code_values->cv.cs_263.dummy_facility_transfer_cd = uar_get_code_by("DISPLAYKEY",263,"DUMMYFACILITYTRANSFER")
	set code_values->cv.cs_263.intercompany_transfer_cd = uar_get_code_by("DISPLAYKEY",263,"INTERCOMPANYTRANSFER")
	set code_values->cv.cs_263.lab_only_providers_cd = uar_get_code_by("DISPLAYKEY",263,"LABONLYPROVIDERS")
	set code_values->cv.cs_263.quick_lab_only_providers_cd = uar_get_code_by("DISPLAYKEY",263,"QUICKLABONLYPROVIDERS")
 
	call writeLog(build2("** Code Set 278       ************************************"))
	set  code_values->cv.cs_278.facility_cd  	= uar_get_code_by("MEANING",278,"FACILITY"	)		;Facility
 
	call writeLog(build2("** Code Set 319       ************************************"))
	set code_values->cv.cs_319.extencnbr_cd = uar_get_code_by_cki("CKI.CODEVALUE!2928")
	set code_values->cv.cs_319.fin_nbr_cd = uar_get_code_by_cki("CKI.CODEVALUE!2930")
	set code_values->cv.cs_319.hnaencnbr_cd = uar_get_code_by_cki("CKI.CODEVALUE!2927")
	set code_values->cv.cs_319.mrn_cd = uar_get_code_by_cki("CKI.CODEVALUE!8021")
	set code_values->cv.cs_319.other_cd = uar_get_code_by_cki("CKI.CODEVALUE!2929")
	set code_values->cv.cs_319.pbs_visit_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!2562052")
	set code_values->cv.cs_319.req_nbr_cd = uar_get_code_by_cki("CKI.CODEVALUE!2931")
	set code_values->cv.cs_319.visit_id_cd = uar_get_code_by_cki("CKI.CODEVALUE!13730")
 
	call writeLog(build2("** Code Set 320       ************************************"))
	set code_values->cv.cs_320.admuserid_cd = uar_get_code_by("MEANING",320,"ADMUSERID")
	set code_values->cv.cs_320.al3cid_cd = uar_get_code_by("MEANING",320,"AL3CID")
	set code_values->cv.cs_320.contsubnbr_cd = uar_get_code_by("MEANING",320,"CONTSUBNBR")
	set code_values->cv.cs_320.covfamphys_cd = uar_get_code_by("MEANING",320,"COVFAMPHYS")
	set code_values->cv.cs_320.doccnbr_cd = uar_get_code_by("MEANING",320,"DOCCNBR")
	set code_values->cv.cs_320.docdea_cd = uar_get_code_by("MEANING",320,"DOCDEA")
	set code_values->cv.cs_320.docnbr_cd = uar_get_code_by("MEANING",320,"DOCNBR")
	set code_values->cv.cs_320.docupin_cd = uar_get_code_by("MEANING",320,"DOCUPIN")
	set code_values->cv.cs_320.externalid_cd = uar_get_code_by("MEANING",320,"EXTERNALID")
	set code_values->cv.cs_320.gdp_cd = uar_get_code_by("MEANING",320,"GDP")
	set code_values->cv.cs_320.hltheupresc_cd = uar_get_code_by("MEANING",320,"HLTHEUPRESC")
	set code_values->cv.cs_320.imxaccessind_cd = uar_get_code_by("MEANING",320,"IMXACCESSIND")
	set code_values->cv.cs_320.licensenbr_cd = uar_get_code_by("MEANING",320,"LICENSENBR")
	set code_values->cv.cs_320.medicaid_cd = uar_get_code_by("MEANING",320,"MEDICAID")
	set code_values->cv.cs_320.messaging_cd = uar_get_code_by("MEANING",320,"MESSAGING")
	set code_values->cv.cs_320.nongp_cd = uar_get_code_by("MEANING",320,"NONGP")
	set code_values->cv.cs_320.npi_cd = uar_get_code_by("MEANING",320,"NPI")
	set code_values->cv.cs_320.other_cd = uar_get_code_by("MEANING",320,"OTHER")
	set code_values->cv.cs_320.postcode_cd = uar_get_code_by("MEANING",320,"POSTCODE")
	set code_values->cv.cs_320.provgrpnum_cd = uar_get_code_by("MEANING",320,"PROVGRPNUM")
	set code_values->cv.cs_320.provider_num_cd = uar_get_code_by("MEANING",320,"PROVIDER NUM")
	set code_values->cv.cs_320.prsnlbadge_cd = uar_get_code_by("MEANING",320,"PRSNLBADGE")
	set code_values->cv.cs_320.prsnlid_cd = uar_get_code_by("MEANING",320,"PRSNLID")
	set code_values->cv.cs_320.prsnlprimid_cd = uar_get_code_by("MEANING",320,"PRSNLPRIMID")
	set code_values->cv.cs_320.pvddirid_cd = uar_get_code_by("MEANING",320,"PVDDIRID")
	set code_values->cv.cs_320.pvddirlinkid_cd = uar_get_code_by("MEANING",320,"PVDDIRLINKID")
	set code_values->cv.cs_320.spi_cd = uar_get_code_by("MEANING",320,"SPI")
	set code_values->cv.cs_320.taxid_cd = uar_get_code_by("MEANING",320,"TAXID")
	set code_values->cv.cs_320.taxonomyid_cd = uar_get_code_by("MEANING",320,"TAXONOMYID")
	set code_values->cv.cs_320.userid_cd = uar_get_code_by("MEANING",320,"USERID")
	set code_values->cv.cs_320.username_cd = uar_get_code_by("MEANING",320,"USERNAME")
 
	call writeLog(build2("** Code Set 331       ************************************"))
	set code_values->cv.cs_331.birthdoc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4588")
	set code_values->cv.cs_331.care_coord_cd = uar_get_code_by_cki("CKI.CODEVALUE!3166062")
	set code_values->cv.cs_331.cmadmin_cd = uar_get_code_by_cki("CKI.CODEVALUE!2285365")
	set code_values->cv.cs_331.cmassist_cd = uar_get_code_by_cki("CKI.CODEVALUE!2285364")
	set code_values->cv.cs_331.deathdoc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4589")
	set code_values->cv.cs_331.dentist_cd = uar_get_code_by_cki("CKI.CODEVALUE!3648457")
	set code_values->cv.cs_331.emrgcyaccess_cd = uar_get_code_by_cki("CKI.CODEVALUE!723874500")
	set code_values->cv.cs_331.familydoc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4590")
	set code_values->cv.cs_331.lifecasemgr_cd = uar_get_code_by_cki("CKI.CODEVALUE!515088")
	set code_values->cv.cs_331.mntlhlthprmc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201659658")
	set code_values->cv.cs_331.obgyn_cd = uar_get_code_by_cki("CKI.CODEVALUE!4591")
	set code_values->cv.cs_331.oncologist_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201659659")
	set code_values->cv.cs_331.other_cd = uar_get_code_by_cki("CKI.CODEVALUE!8022")
	set code_values->cv.cs_331.pcp_cd = uar_get_code_by_cki("CKI.CODEVALUE!4593")
	set code_values->cv.cs_331.pediatrician_cd = uar_get_code_by_cki("CKI.CODEVALUE!4592")
	set code_values->cv.cs_331.psychiatrist_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201659558")
	set code_values->cv.cs_331.sponsor_cd = uar_get_code_by_cki("CKI.CODEVALUE!2814776")
 
	call writeLog(build2("** Code Set 333       ************************************"))
	set code_values->cv.cs_333.admitdoc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4023")
	set code_values->cv.cs_333.assigned_cd = uar_get_code_by_cki("CKI.CODEVALUE!8436")
	set code_values->cv.cs_333.assigned_pat_cd = uar_get_code_by_cki("CKI.CODEVALUE!11485")
	set code_values->cv.cs_333.attenddoc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4024")
	set code_values->cv.cs_333.casemngr_cd = uar_get_code_by_cki("CKI.CODEVALUE!4594")
	set code_values->cv.cs_333.consultdoc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4595")
	set code_values->cv.cs_333.coordinator_cd = uar_get_code_by_cki("CKI.CODEVALUE!2814778")
	set code_values->cv.cs_333.dcspecialist_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200145402")
	set code_values->cv.cs_333.locumadmit_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989549")
	set code_values->cv.cs_333.locumattend_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989550")
	set code_values->cv.cs_333.mntlhlthattp_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201659698")
	set code_values->cv.cs_333.mrndefcnt_cd = uar_get_code_by_cki("CKI.CODEVALUE!8480")
	set code_values->cv.cs_333.orderdoc_cd = uar_get_code_by_cki("CKI.CODEVALUE!9515")
	set code_values->cv.cs_333.other_cd = uar_get_code_by_cki("CKI.CODEVALUE!8023")
	set code_values->cv.cs_333.primarynurse_cd = uar_get_code_by_cki("CKI.CODEVALUE!4596")
	set code_values->cv.cs_333.referdoc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4597")
	set code_values->cv.cs_333.socialworker_cd = uar_get_code_by_cki("CKI.CODEVALUE!2910505")
	set code_values->cv.cs_333.supervising_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200081916")
	set code_values->cv.cs_333.nurseprac_cd = uar_get_code_by("DISPLAY",333,"Nurse Practitioner")
 
	call writeLog(build2("** Code Set 351       ************************************"))
	set code_values->cv.cs_351.asthmaguardi_cd = uar_get_code_by_cki("CKI.CODEVALUE!3757383")
	set code_values->cv.cs_351.authrep_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201586563")
	set code_values->cv.cs_351.bbrecipient_cd = uar_get_code_by_cki("CKI.CODEVALUE!11682")
	set code_values->cv.cs_351.consentor_cd = uar_get_code_by_cki("CKI.CODEVALUE!3189251")
	set code_values->cv.cs_351.conservator_cd = uar_get_code_by_cki("CKI.CODEVALUE!3657995")
	set code_values->cv.cs_351.defguar_cd = uar_get_code_by_cki("CKI.CODEVALUE!9519")
	set code_values->cv.cs_351.emc_cd = uar_get_code_by_cki("CKI.CODEVALUE!6328")
	set code_values->cv.cs_351.family_cd = uar_get_code_by_cki("CKI.CODEVALUE!3236")
	set code_values->cv.cs_351.familyhist_cd = uar_get_code_by_cki("CKI.CODEVALUE!723874135")
	set code_values->cv.cs_351.genetic_cd = uar_get_code_by_cki("CKI.CODEVALUE!10138")
	set code_values->cv.cs_351.guarantor_cd = uar_get_code_by_cki("CKI.CODEVALUE!9520")
	set code_values->cv.cs_351.guardian_cd = uar_get_code_by_cki("CKI.CODEVALUE!17057")
	set code_values->cv.cs_351.hla_donrec_cd = uar_get_code_by_cki("CKI.CODEVALUE!10139")
	set code_values->cv.cs_351.insured_cd = uar_get_code_by_cki("CKI.CODEVALUE!9521")
	set code_values->cv.cs_351.nok_cd = uar_get_code_by_cki("CKI.CODEVALUE!9522")
	set code_values->cv.cs_351.pcg_cd = uar_get_code_by_cki("CKI.CODEVALUE!14370")
	set code_values->cv.cs_351.poa_cd = uar_get_code_by_cki("CKI.CODEVALUE!14371")
	set code_values->cv.cs_351.self_cd = uar_get_code_by_cki("CKI.CODEVALUE!9523")
 
	call writeLog(build2("** Code Set 354       ************************************"))
	set code_values->cv.cs_354.commercial_cd = uar_get_code_by("DISPLAYKEY",354,"COMMERCIAL")
	set code_values->cv.cs_354.medicare_cd = uar_get_code_by("DISPLAYKEY",354,"MEDICARE")
	set code_values->cv.cs_354.medicare_advantage_cd = uar_get_code_by("DISPLAYKEY",354,"MEDICAREADVANTAGE")
	set code_values->cv.cs_354.other_cd = uar_get_code_by("DISPLAYKEY",354,"OTHER")
	set code_values->cv.cs_354.self_pay_cd = uar_get_code_by("DISPLAYKEY",354,"SELFPAY")
	set code_values->cv.cs_354.managed_care_cd = uar_get_code_by("DISPLAYKEY",354,"MANAGEDCARE")
	set code_values->cv.cs_354.blue_cross_cd = uar_get_code_by("DISPLAYKEY",354,"BLUECROSS")
	set code_values->cv.cs_354.tenncare_cd = uar_get_code_by("DISPLAYKEY",354,"TENNCARE")
	set code_values->cv.cs_354.self_pay_after_insurance_cd = uar_get_code_by("DISPLAYKEY",354,"SELFPAYAFTERINSURANCE")
 
	call writeLog(build2("** Code Set 356       ************************************"))
	set code_values->cv.cs_356.accrelatedvi_cd = uar_get_code_by("MEANING",356,"ACCRELATEDVI")
	set code_values->cv.cs_356.addchgchk_cd = uar_get_code_by("MEANING",356,"ADDCHGCHK")
	set code_values->cv.cs_356.addptincern_cd = uar_get_code_by("MEANING",356,"ADDPTINCERN")
	set code_values->cv.cs_356.addr_info_cd = uar_get_code_by("MEANING",356,"ADDR_INFO")
	set code_values->cv.cs_356.adlt_minor_cd = uar_get_code_by("MEANING",356,"ADLT_MINOR")
	set code_values->cv.cs_356.akaname1_cd = uar_get_code_by("MEANING",356,"AKANAME1")
	set code_values->cv.cs_356.akaname2_cd = uar_get_code_by("MEANING",356,"AKANAME2")
	set code_values->cv.cs_356.akaname3_cd = uar_get_code_by("MEANING",356,"AKANAME3")
	set code_values->cv.cs_356.amb_company_cd = uar_get_code_by("MEANING",356,"AMB_COMPANY")
	set code_values->cv.cs_356.angel_alert_cd = uar_get_code_by("MEANING",356,"ANGEL_ALERT")
	set code_values->cv.cs_356.angel_cmnt_cd = uar_get_code_by("MEANING",356,"ANGEL_CMNT")
	set code_values->cv.cs_356.appt_alerts_cd = uar_get_code_by("MEANING",356,"APPT_ALERTS")
	set code_values->cv.cs_356.arrival_comm_cd = uar_get_code_by("MEANING",356,"ARRIVAL_COMM")
	set code_values->cv.cs_356.attend_city_cd = uar_get_code_by("MEANING",356,"ATTEND_CITY")
	set code_values->cv.cs_356.attend_clin_cd = uar_get_code_by("MEANING",356,"ATTEND_CLIN")
	set code_values->cv.cs_356.attend_state_cd = uar_get_code_by("MEANING",356,"ATTEND_STATE")
	set code_values->cv.cs_356.att_address_cd = uar_get_code_by("MEANING",356,"ATT_ADDRESS")
	set code_values->cv.cs_356.att_firstnam_cd = uar_get_code_by("MEANING",356,"ATT_FIRSTNAM")
	set code_values->cv.cs_356.att_lastname_cd = uar_get_code_by("MEANING",356,"ATT_LASTNAME")
	set code_values->cv.cs_356.att_npi_cd = uar_get_code_by("MEANING",356,"ATT_NPI")
	set code_values->cv.cs_356.att_phone_cd = uar_get_code_by("MEANING",356,"ATT_PHONE")
	set code_values->cv.cs_356.att_zipcode_cd = uar_get_code_by("MEANING",356,"ATT_ZIPCODE")
	set code_values->cv.cs_356.badge_id_cd = uar_get_code_by("MEANING",356,"BADGE_ID")
	set code_values->cv.cs_356.bh_auth_comm_cd = uar_get_code_by("MEANING",356,"BH_AUTH_COMM")
	set code_values->cv.cs_356.bill_alerts_cd = uar_get_code_by("MEANING",356,"BILL_ALERTS")
	set code_values->cv.cs_356.botox_alerts_cd = uar_get_code_by("MEANING",356,"BOTOX_ALERTS")
	set code_values->cv.cs_356.cenbaddept_cd = uar_get_code_by("MEANING",356,"CENBADDEPT")
	set code_values->cv.cs_356.cg_id_cd = uar_get_code_by("MEANING",356,"CG_ID")
	set code_values->cv.cs_356.challengeans_cd = uar_get_code_by("MEANING",356,"CHALLENGEANS")
	set code_values->cv.cs_356.checkoutdttm_cd = uar_get_code_by("MEANING",356,"CHECKOUTDTTM")
	set code_values->cv.cs_356.clergy_visit_cd = uar_get_code_by("MEANING",356,"CLERGY_VISIT")
	set code_values->cv.cs_356.clinical_tri_cd = uar_get_code_by("MEANING",356,"CLINICAL_TRI")
	set code_values->cv.cs_356.code_green_v_cd = uar_get_code_by("MEANING",356,"CODE GREEN V")
	set code_values->cv.cs_356.code_green_d_cd = uar_get_code_by("MEANING",356,"CODE_GREEN_D")
	set code_values->cv.cs_356.code_green_r_cd = uar_get_code_by("MEANING",356,"CODE_GREEN_R")
	set code_values->cv.cs_356.complete_msp_cd = uar_get_code_by("MEANING",356,"COMPLETE_MSP")
	set code_values->cv.cs_356.complete_reg_cd = uar_get_code_by("MEANING",356,"COMPLETE_REG")
	set code_values->cv.cs_356.consent_cd = uar_get_code_by("MEANING",356,"CONSENT")
	set code_values->cv.cs_356.consentdt_cd = uar_get_code_by("MEANING",356,"CONSENTDT")
	set code_values->cv.cs_356.conversation_cd = uar_get_code_by("MEANING",356,"CONVERSATION")
	set code_values->cv.cs_356.corr_alerts_cd = uar_get_code_by("MEANING",356,"CORR_ALERTS")
	set code_values->cv.cs_356.customalert_cd = uar_get_code_by("MEANING",356,"CUSTOMALERT")
	set code_values->cv.cs_356.cwautoenroll_cd = uar_get_code_by("MEANING",356,"CWAUTOENROLL")
	set code_values->cv.cs_356.daystoretr_cd = uar_get_code_by("MEANING",356,"DAYSTORETR")
	set code_values->cv.cs_356.defdoctype_cd = uar_get_code_by("MEANING",356,"DEFDOCTYPE")
	set code_values->cv.cs_356.demo_alerts_cd = uar_get_code_by("MEANING",356,"DEMO_ALERTS")
	set code_values->cv.cs_356.diag_cd = uar_get_code_by("MEANING",356,"DIAG")
	set code_values->cv.cs_356.diag2_cd = uar_get_code_by("MEANING",356,"DIAG2")
	set code_values->cv.cs_356.diag3_cd = uar_get_code_by("MEANING",356,"DIAG3")
	set code_values->cv.cs_356.diag4_cd = uar_get_code_by("MEANING",356,"DIAG4")
	set code_values->cv.cs_356.diag_code1_cd = uar_get_code_by("MEANING",356,"DIAG_CODE1")
	set code_values->cv.cs_356.diag_code2_cd = uar_get_code_by("MEANING",356,"DIAG_CODE2")
	set code_values->cv.cs_356.diag_code3_cd = uar_get_code_by("MEANING",356,"DIAG_CODE3")
	set code_values->cv.cs_356.diag_desc_1_cd = uar_get_code_by("MEANING",356,"DIAG_DESC_1")
	set code_values->cv.cs_356.diag_desc_2_cd = uar_get_code_by("MEANING",356,"DIAG_DESC_2")
	set code_values->cv.cs_356.diag_desc_3_cd = uar_get_code_by("MEANING",356,"DIAG_DESC_3")
	set code_values->cv.cs_356.dobchangech_cd = uar_get_code_by("MEANING",356,"DOBCHANGECH")
	set code_values->cv.cs_356.documentstat_cd = uar_get_code_by("MEANING",356,"DOCUMENTSTAT")
	set code_values->cv.cs_356.doc_req_dt_cd = uar_get_code_by("MEANING",356,"DOC_REQ_DT")
	set code_values->cv.cs_356.do_not_resch_cd = uar_get_code_by("MEANING",356,"DO_NOT_RESCH")
	set code_values->cv.cs_356.drarescinddt_cd = uar_get_code_by("MEANING",356,"DRARESCINDDT")
	set code_values->cv.cs_356.dra_status_cd = uar_get_code_by("MEANING",356,"DRA_STATUS")
	set code_values->cv.cs_356.dra_statusdt_cd = uar_get_code_by("MEANING",356,"DRA_STATUSDT")
	set code_values->cv.cs_356.ed_visit_cd = uar_get_code_by("MEANING",356,"ED_VISIT")
	set code_values->cv.cs_356.emaildec_dt_cd = uar_get_code_by("MEANING",356,"EMAILDEC_DT")
	set code_values->cv.cs_356.emaildec_rea_cd = uar_get_code_by("MEANING",356,"EMAILDEC_REA")
	set code_values->cv.cs_356.emaildec_yn_cd = uar_get_code_by("MEANING",356,"EMAILDEC_YN")
	set code_values->cv.cs_356.emc_add_optn_cd = uar_get_code_by("MEANING",356,"EMC_ADD_OPTN")
	set code_values->cv.cs_356.emncptdminor_cd = uar_get_code_by("MEANING",356,"EMNCPTDMINOR")
	set code_values->cv.cs_356.encntrinfoav_cd = uar_get_code_by("MEANING",356,"ENCNTRINFOAV")
	set code_values->cv.cs_356.encntr_com_cd = uar_get_code_by("MEANING",356,"ENCNTR_COM")
	set code_values->cv.cs_356.est_tot_cost_cd = uar_get_code_by("MEANING",356,"EST_TOT_COST")
	set code_values->cv.cs_356.expired_nb_cd = uar_get_code_by("MEANING",356,"EXPIRED_NB")
	set code_values->cv.cs_356.fadecdate_cd = uar_get_code_by("MEANING",356,"FADECDATE")
	set code_values->cv.cs_356.fallrisksev_cd = uar_get_code_by("MEANING",356,"FALLRISKSEV")
	set code_values->cv.cs_356.finan_com_cd = uar_get_code_by("MEANING",356,"FINAN_COM")
	set code_values->cv.cs_356.fnchangechek_cd = uar_get_code_by("MEANING",356,"FNCHANGECHEK")
	set code_values->cv.cs_356.ftreltncvg_cd = uar_get_code_by("MEANING",356,"FTRELTNCVG")
	set code_values->cv.cs_356.fullpre_user_cd = uar_get_code_by("MEANING",356,"FULLPRE_USER")
	set code_values->cv.cs_356.fullreg_cd = uar_get_code_by("MEANING",356,"FULLREG")
	set code_values->cv.cs_356.fullregcomp_cd = uar_get_code_by("MEANING",356,"FULLREGCOMP")
	set code_values->cv.cs_356.full_reg_usr_cd = uar_get_code_by("MEANING",356,"FULL_REG_USR")
	set code_values->cv.cs_356.funeral_addr_cd = uar_get_code_by("MEANING",356,"FUNERAL_ADDR")
	set code_values->cv.cs_356.funeral_name_cd = uar_get_code_by("MEANING",356,"FUNERAL_NAME")
	set code_values->cv.cs_356.funeral_phon_cd = uar_get_code_by("MEANING",356,"FUNERAL_PHON")
	set code_values->cv.cs_356.ghp_addr4_cd = uar_get_code_by("MEANING",356,"GHP_ADDR4")
	set code_values->cv.cs_356.ghp_csz4_cd = uar_get_code_by("MEANING",356,"GHP_CSZ4")
	set code_values->cv.cs_356.ghp_grpnbr4_cd = uar_get_code_by("MEANING",356,"GHP_GRPNBR4")
	set code_values->cv.cs_356.ghp_hp_cd = uar_get_code_by("MEANING",356,"GHP_HP")
	set code_values->cv.cs_356.ghp_hp5_cd = uar_get_code_by("MEANING",356,"GHP_HP5")
	set code_values->cv.cs_356.ghp_hp6_cd = uar_get_code_by("MEANING",356,"GHP_HP6")
	set code_values->cv.cs_356.ghp_mbrnbr4_cd = uar_get_code_by("MEANING",356,"GHP_MBRNBR4")
	set code_values->cv.cs_356.ghp_name4_cd = uar_get_code_by("MEANING",356,"GHP_NAME4")
	set code_values->cv.cs_356.ghp_polhldr4_cd = uar_get_code_by("MEANING",356,"GHP_POLHLDR4")
	set code_values->cv.cs_356.ghp_polnbr4_cd = uar_get_code_by("MEANING",356,"GHP_POLNBR4")
	set code_values->cv.cs_356.ghp_reltn4_cd = uar_get_code_by("MEANING",356,"GHP_RELTN4")
	set code_values->cv.cs_356.gt_addr_opt_cd = uar_get_code_by("MEANING",356,"GT_ADDR_OPT")
	set code_values->cv.cs_356.gt_alt_optn_cd = uar_get_code_by("MEANING",356,"GT_ALT_OPTN")
	set code_values->cv.cs_356.home_hlth_co_cd = uar_get_code_by("MEANING",356,"HOME_HLTH_CO")
	set code_values->cv.cs_356.home_hlth_pn_cd = uar_get_code_by("MEANING",356,"HOME_HLTH_PN")
	set code_values->cv.cs_356.home_hlth_pt_cd = uar_get_code_by("MEANING",356,"HOME_HLTH_PT")
	set code_values->cv.cs_356.hopsice_pat_cd = uar_get_code_by("MEANING",356,"HOPSICE_PAT")
	set code_values->cv.cs_356.hospice_comp_cd = uar_get_code_by("MEANING",356,"HOSPICE_COMP")
	set code_values->cv.cs_356.hospice_phon_cd = uar_get_code_by("MEANING",356,"HOSPICE_PHON")
	set code_values->cv.cs_356.hpchgreview_cd = uar_get_code_by("MEANING",356,"HPCHGREVIEW")
	set code_values->cv.cs_356.incidentto_cd = uar_get_code_by("MEANING",356,"INCIDENTTO")
	set code_values->cv.cs_356.ins_comment_cd = uar_get_code_by("MEANING",356,"INS_COMMENT")
	set code_values->cv.cs_356.ins_type_cd = uar_get_code_by("MEANING",356,"INS_TYPE")
	set code_values->cv.cs_356.lastdatework_cd = uar_get_code_by("MEANING",356,"LASTDATEWORK")
	set code_values->cv.cs_356.ltc_serv_req_cd = uar_get_code_by("MEANING",356,"LTC_SERV_REQ")
	set code_values->cv.cs_356.minqryintvl_cd = uar_get_code_by("MEANING",356,"MINQRYINTVL")
	set code_values->cv.cs_356.msp_complete_cd = uar_get_code_by("MEANING",356,"MSP COMPLETE")
	set code_values->cv.cs_356.mspqperiod_cd = uar_get_code_by("MEANING",356,"MSPQPERIOD")
	set code_values->cv.cs_356.mspq_30month_cd = uar_get_code_by("MEANING",356,"MSPQ_30MONTH")
	set code_values->cv.cs_356.msp_alert_cd = uar_get_code_by("MEANING",356,"MSP_ALERT")
	set code_values->cv.cs_356.msp_reviewed_cd = uar_get_code_by("MEANING",356,"MSP_REVIEWED")
	set code_values->cv.cs_356.namechangech_cd = uar_get_code_by("MEANING",356,"NAMECHANGECH")
	set code_values->cv.cs_356.newencntrcom_cd = uar_get_code_by("MEANING",356,"NEWENCNTRCOM")
	set code_values->cv.cs_356.newinscommen_cd = uar_get_code_by("MEANING",356,"NEWINSCOMMEN")
	set code_values->cv.cs_356.nok_add_optn_cd = uar_get_code_by("MEANING",356,"NOK_ADD_OPTN")
	set code_values->cv.cs_356.nopnotes_cd = uar_get_code_by("MEANING",356,"NOPNOTES")
	set code_values->cv.cs_356.nop_priv_dt_cd = uar_get_code_by("MEANING",356,"NOP_PRIV_DT")
	set code_values->cv.cs_356.nop_status_cd = uar_get_code_by("MEANING",356,"NOP_STATUS")
	set code_values->cv.cs_356.nossnreason_cd = uar_get_code_by("MEANING",356,"NOSSNREASON")
	set code_values->cv.cs_356.ob_filter_cd = uar_get_code_by("MEANING",356,"OB_FILTER")
	set code_values->cv.cs_356.odmdarchvind_cd = uar_get_code_by("MEANING",356,"ODMDARCHVIND")
	set code_values->cv.cs_356.odmdauthmode_cd = uar_get_code_by("MEANING",356,"ODMDAUTHMODE")
	set code_values->cv.cs_356.odmdrptmplid_cd = uar_get_code_by("MEANING",356,"ODMDRPTMPLID")
	set code_values->cv.cs_356.oon_ins_cd = uar_get_code_by("MEANING",356,"OON_INS")
	set code_values->cv.cs_356.os_csm_cd = uar_get_code_by("MEANING",356,"OS_CSM")
	set code_values->cv.cs_356.other_alerts_cd = uar_get_code_by("MEANING",356,"OTHER_ALERTS")
	set code_values->cv.cs_356.paperforms_cd = uar_get_code_by("MEANING",356,"PAPERFORMS")
	set code_values->cv.cs_356.parsedoc_cd = uar_get_code_by("MEANING",356,"PARSEDOC")
	set code_values->cv.cs_356.passr_date_cd = uar_get_code_by("MEANING",356,"PASSR_DATE")
	set code_values->cv.cs_356.passr_eval_cd = uar_get_code_by("MEANING",356,"PASSR_EVAL")
	set code_values->cv.cs_356.pastdueamt_cd = uar_get_code_by("MEANING",356,"PASTDUEAMT")
	set code_values->cv.cs_356.patient_pin_cd = uar_get_code_by("MEANING",356,"PATIENT PIN")
	set code_values->cv.cs_356.patientporta_cd = uar_get_code_by("MEANING",356,"PATIENTPORTA")
	set code_values->cv.cs_356.pcp_address_cd = uar_get_code_by("MEANING",356,"PCP_ADDRESS")
	set code_values->cv.cs_356.pcp_city_cd = uar_get_code_by("MEANING",356,"PCP_CITY")
	set code_values->cv.cs_356.pcp_clinic_cd = uar_get_code_by("MEANING",356,"PCP_CLINIC")
	set code_values->cv.cs_356.pcp_firstnam_cd = uar_get_code_by("MEANING",356,"PCP_FIRSTNAM")
	set code_values->cv.cs_356.pcp_lastname_cd = uar_get_code_by("MEANING",356,"PCP_LASTNAME")
	set code_values->cv.cs_356.pcp_npi_cd = uar_get_code_by("MEANING",356,"PCP_NPI")
	set code_values->cv.cs_356.pcp_phone_cd = uar_get_code_by("MEANING",356,"PCP_PHONE")
	set code_values->cv.cs_356.pcp_state_cd = uar_get_code_by("MEANING",356,"PCP_STATE")
	set code_values->cv.cs_356.pcp_verified_cd = uar_get_code_by("MEANING",356,"PCP_VERIFIED")
	set code_values->cv.cs_356.pcp_zipcode_cd = uar_get_code_by("MEANING",356,"PCP_ZIPCODE")
	set code_values->cv.cs_356.pos_alert_cd = uar_get_code_by("MEANING",356,"POS_ALERT")
	set code_values->cv.cs_356.preferred_ge_cd = uar_get_code_by("MEANING",356,"PREFERRED_GE")
	set code_values->cv.cs_356.prefphone_cd = uar_get_code_by("MEANING",356,"PREFPHONE")
	set code_values->cv.cs_356.pref_loc_cd = uar_get_code_by("MEANING",356,"PREF_LOC")
	set code_values->cv.cs_356.prepaydet_cd = uar_get_code_by("MEANING",356,"PREPAYDET")
	set code_values->cv.cs_356.prepayenddat_cd = uar_get_code_by("MEANING",356,"PREPAYENDDAT")
	set code_values->cv.cs_356.prereg_comp_cd = uar_get_code_by("MEANING",356,"PREREG COMP")
	set code_values->cv.cs_356.prevpattype_cd = uar_get_code_by("MEANING",356,"PREVPATTYPE")
	set code_values->cv.cs_356.primselfstat_cd = uar_get_code_by("MEANING",356,"PRIMSELFSTAT")
	set code_values->cv.cs_356.prim_card_cd = uar_get_code_by("MEANING",356,"PRIM_CARD")
	set code_values->cv.cs_356.prim_gastro_cd = uar_get_code_by("MEANING",356,"PRIM_GASTRO")
	set code_values->cv.cs_356.prim_surg_cd = uar_get_code_by("MEANING",356,"PRIM_SURG")
	set code_values->cv.cs_356.privacyword_cd = uar_get_code_by("MEANING",356,"PRIVACYWORD")
	set code_values->cv.cs_356.proc_code1_cd = uar_get_code_by("MEANING",356,"PROC_CODE1")
	set code_values->cv.cs_356.proc_code2_cd = uar_get_code_by("MEANING",356,"PROC_CODE2")
	set code_values->cv.cs_356.proc_code3_cd = uar_get_code_by("MEANING",356,"PROC_CODE3")
	set code_values->cv.cs_356.proc_code4_cd = uar_get_code_by("MEANING",356,"PROC_CODE4")
	set code_values->cv.cs_356.proc_code5_cd = uar_get_code_by("MEANING",356,"PROC_CODE5")
	set code_values->cv.cs_356.proc_code6_cd = uar_get_code_by("MEANING",356,"PROC_CODE6")
	set code_values->cv.cs_356.proc_code7_cd = uar_get_code_by("MEANING",356,"PROC_CODE7")
	set code_values->cv.cs_356.proc_desc_1_cd = uar_get_code_by("MEANING",356,"PROC_DESC_1")
	set code_values->cv.cs_356.proc_desc_2_cd = uar_get_code_by("MEANING",356,"PROC_DESC_2")
	set code_values->cv.cs_356.proc_desc_3_cd = uar_get_code_by("MEANING",356,"PROC_DESC_3")
	set code_values->cv.cs_356.proc_desc_4_cd = uar_get_code_by("MEANING",356,"PROC_DESC_4")
	set code_values->cv.cs_356.proc_desc_5_cd = uar_get_code_by("MEANING",356,"PROC_DESC_5")
	set code_values->cv.cs_356.proc_desc_6_cd = uar_get_code_by("MEANING",356,"PROC_DESC_6")
	set code_values->cv.cs_356.proc_desc_7_cd = uar_get_code_by("MEANING",356,"PROC_DESC_7")
	set code_values->cv.cs_356.prsn_comment_cd = uar_get_code_by("MEANING",356,"PRSN_COMMENT")
	set code_values->cv.cs_356.prsn_roialrt_cd = uar_get_code_by("MEANING",356,"PRSN_ROIALRT")
	set code_values->cv.cs_356.prsn_roicmnt_cd = uar_get_code_by("MEANING",356,"PRSN_ROICMNT")
	set code_values->cv.cs_356.ptbalance_cd = uar_get_code_by("MEANING",356,"PTBALANCE")
	set code_values->cv.cs_356.pt_alt_addr_cd = uar_get_code_by("MEANING",356,"PT_ALT_ADDR")
	set code_values->cv.cs_356.pt_phys_addr_cd = uar_get_code_by("MEANING",356,"PT_PHYS_ADDR")
	set code_values->cv.cs_356.pymtaarngdet_cd = uar_get_code_by("MEANING",356,"PYMTAARNGDET")
	set code_values->cv.cs_356.r1_add_optn_cd = uar_get_code_by("MEANING",356,"R1_ADD_OPTN")
	set code_values->cv.cs_356.realreltncvg_cd = uar_get_code_by("MEANING",356,"REALRELTNCVG")
	set code_values->cv.cs_356.reason_nopcp_cd = uar_get_code_by("MEANING",356,"REASON_NOPCP")
	set code_values->cv.cs_356.reason_noref_cd = uar_get_code_by("MEANING",356,"REASON_NOREF")
	set code_values->cv.cs_356.rec_review_cd = uar_get_code_by("MEANING",356,"REC_REVIEW")
	set code_values->cv.cs_356.refer_addres_cd = uar_get_code_by("MEANING",356,"REFER_ADDRES")
	set code_values->cv.cs_356.refer_city_cd = uar_get_code_by("MEANING",356,"REFER_CITY")
	set code_values->cv.cs_356.refer_clinic_cd = uar_get_code_by("MEANING",356,"REFER_CLINIC")
	set code_values->cv.cs_356.refer_firstn_cd = uar_get_code_by("MEANING",356,"REFER_FIRSTN")
	set code_values->cv.cs_356.refer_lastna_cd = uar_get_code_by("MEANING",356,"REFER_LASTNA")
	set code_values->cv.cs_356.refer_npi_cd = uar_get_code_by("MEANING",356,"REFER_NPI")
	set code_values->cv.cs_356.refer_phone_cd = uar_get_code_by("MEANING",356,"REFER_PHONE")
	set code_values->cv.cs_356.refer_state_cd = uar_get_code_by("MEANING",356,"REFER_STATE")
	set code_values->cv.cs_356.refer_zipcod_cd = uar_get_code_by("MEANING",356,"REFER_ZIPCOD")
	set code_values->cv.cs_356.reg_fin_risk_cd = uar_get_code_by("MEANING",356,"REG_FIN_RISK")
	set code_values->cv.cs_356.retrievedoc_cd = uar_get_code_by("MEANING",356,"RETRIEVEDOC")
	set code_values->cv.cs_356.roi_alert_cd = uar_get_code_by("MEANING",356,"ROI_ALERT")
	set code_values->cv.cs_356.roi_cmnt_cd = uar_get_code_by("MEANING",356,"ROI_CMNT")
	set code_values->cv.cs_356.s2_addr_opt_cd = uar_get_code_by("MEANING",356,"S2_ADDR_OPT")
	set code_values->cv.cs_356.s3_addr_opt_cd = uar_get_code_by("MEANING",356,"S3_ADDR_OPT")
	set code_values->cv.cs_356.s4_addr_opt_cd = uar_get_code_by("MEANING",356,"S4_ADDR_OPT")
	set code_values->cv.cs_356.selfpaybalan_cd = uar_get_code_by("MEANING",356,"SELFPAYBALAN")
	set code_values->cv.cs_356.seqrec_alert_cd = uar_get_code_by("MEANING",356,"SEQREC_ALERT")
	set code_values->cv.cs_356.seqrec_cmnt_cd = uar_get_code_by("MEANING",356,"SEQREC_CMNT")
	set code_values->cv.cs_356.sex_orient_cd = uar_get_code_by("MEANING",356,"SEX_ORIENT")
	set code_values->cv.cs_356.slfpay_dt_tm_cd = uar_get_code_by("MEANING",356,"SLFPAY_DT_TM")
	set code_values->cv.cs_356.snf_company_cd = uar_get_code_by("MEANING",356,"SNF_COMPANY")
	set code_values->cv.cs_356.snf_patient_cd = uar_get_code_by("MEANING",356,"SNF_PATIENT")
	set code_values->cv.cs_356.snf_phon_num_cd = uar_get_code_by("MEANING",356,"SNF_PHON_NUM")
	set code_values->cv.cs_356.specneedslev_cd = uar_get_code_by("MEANING",356,"SPECNEEDSLEV")
	set code_values->cv.cs_356.spouses_emp4_cd = uar_get_code_by("MEANING",356,"SPOUSES_EMP4")
	set code_values->cv.cs_356.spouses_emp5_cd = uar_get_code_by("MEANING",356,"SPOUSES_EMP5")
	set code_values->cv.cs_356.sps_emp_cty4_cd = uar_get_code_by("MEANING",356,"SPS_EMP_CTY4")
	set code_values->cv.cs_356.sps_emp_cty5_cd = uar_get_code_by("MEANING",356,"SPS_EMP_CTY5")
	set code_values->cv.cs_356.sps_emp_st4_cd = uar_get_code_by("MEANING",356,"SPS_EMP_ST4")
	set code_values->cv.cs_356.sps_emp_st5_cd = uar_get_code_by("MEANING",356,"SPS_EMP_ST5")
	set code_values->cv.cs_356.sps_emp_stt4_cd = uar_get_code_by("MEANING",356,"SPS_EMP_STT4")
	set code_values->cv.cs_356.sps_emp_stt5_cd = uar_get_code_by("MEANING",356,"SPS_EMP_STT5")
	set code_values->cv.cs_356.sps_emp_zip4_cd = uar_get_code_by("MEANING",356,"SPS_EMP_ZIP4")
	set code_values->cv.cs_356.sps_emp_zip5_cd = uar_get_code_by("MEANING",356,"SPS_EMP_ZIP5")
	set code_values->cv.cs_356.sp_exp_mothe_cd = uar_get_code_by("MEANING",356,"SP_EXP_MOTHE")
	set code_values->cv.cs_356.sp_flag_cd = uar_get_code_by("MEANING",356,"SP_FLAG")
	set code_values->cv.cs_356.sp_hlth_issu_cd = uar_get_code_by("MEANING",356,"SP_HLTH_ISSU")
	set code_values->cv.cs_356.sp_ins_cover_cd = uar_get_code_by("MEANING",356,"SP_INS_COVER")
	set code_values->cv.cs_356.sp_military_cd = uar_get_code_by("MEANING",356,"SP_MILITARY")
	set code_values->cv.cs_356.sp_pt_custod_cd = uar_get_code_by("MEANING",356,"SP_PT_CUSTOD")
	set code_values->cv.cs_356.sp_pt_tx_can_cd = uar_get_code_by("MEANING",356,"SP_PT_TX_CAN")
	set code_values->cv.cs_356.sp_pt_und_26_cd = uar_get_code_by("MEANING",356,"SP_PT_UND_26")
	set code_values->cv.cs_356.sp_quest_1_cd = uar_get_code_by("MEANING",356,"SP_QUEST_1")
	set code_values->cv.cs_356.sp_us_citizn_cd = uar_get_code_by("MEANING",356,"SP_US_CITIZN")
	set code_values->cv.cs_356.sub_addr_opt_cd = uar_get_code_by("MEANING",356,"SUB_ADDR_OPT")
	set code_values->cv.cs_356.transplant_cd = uar_get_code_by("MEANING",356,"TRANSPLANT")
	set code_values->cv.cs_356.tran_doc_req_cd = uar_get_code_by("MEANING",356,"TRAN_DOC_REQ")
	set code_values->cv.cs_356.tran_fac_nam_cd = uar_get_code_by("MEANING",356,"TRAN_FAC_NAM")
	set code_values->cv.cs_356.travel_cd = uar_get_code_by("MEANING",356,"TRAVEL")
	set code_values->cv.cs_356.traveltext_cd = uar_get_code_by("MEANING",356,"TRAVELTEXT")
	set code_values->cv.cs_356.valuegroup_cd = uar_get_code_by("MEANING",356,"VALUEGROUP")
	set code_values->cv.cs_356.verify_forms_cd = uar_get_code_by("MEANING",356,"VERIFY_FORMS")
	set code_values->cv.cs_356.ver_per_ins_cd = uar_get_code_by("MEANING",356,"VER_PER_INS")
	set code_values->cv.cs_356.ver_relatedp_cd = uar_get_code_by("MEANING",356,"VER_RELATEDP")
	set code_values->cv.cs_356.ver_vis_ins_cd = uar_get_code_by("MEANING",356,"VER_VIS_INS")
	set code_values->cv.cs_356.veteran_cd = uar_get_code_by("MEANING",356,"VETERAN")
	set code_values->cv.cs_356.wc_addr_cd = uar_get_code_by("MEANING",356,"WC_ADDR")
	set code_values->cv.cs_356.wc_csz_cd = uar_get_code_by("MEANING",356,"WC_CSZ")
	set code_values->cv.cs_356.wc_name_cd = uar_get_code_by("MEANING",356,"WC_NAME")
	set code_values->cv.cs_356.wc_polnbr_cd = uar_get_code_by("MEANING",356,"WC_POLNBR")
	set code_values->cv.cs_356.workcomp_hp_cd = uar_get_code_by("MEANING",356,"WORKCOMP_HP")
 
	call writeLog(build2("** Code Set 396       ************************************"))
	set code_values->cv.cs_396.freetext_cd = uar_get_code_by("MEANING",396,"FREETEXT")
	set code_values->cv.cs_396.org_cd = uar_get_code_by("MEANING",396,"ORG")
 
	call writeLog(build2("** Code Set 400       ************************************"))
	set code_values->cv.cs_400.ada_au_cd = uar_get_code_by_cki("CKI.CODEVALUE!4113496612")
	set code_values->cv.cs_400.aediag_cd = uar_get_code_by_cki("CKI.CODEVALUE!4104451935")
	set code_values->cv.cs_400.algyreact_cd = uar_get_code_by_cki("")
	set code_values->cv.cs_400.allergy_cd = uar_get_code_by_cki("CKI.CODEVALUE!2960")
	set code_values->cv.cs_400.anatomic_pat_cd = uar_get_code_by_cki("CKI.CODEVALUE!3811")
	set code_values->cv.cs_400.apc_cd = uar_get_code_by_cki("CKI.CODEVALUE!2548586")
	set code_values->cv.cs_400.apdrg_cd = uar_get_code_by_cki("CKI.CODEVALUE!3379471")
	set code_values->cv.cs_400.apdrgnj_cd = uar_get_code_by_cki("CKI.CODEVALUE!4115908731")
	set code_values->cv.cs_400.apdrg_in_cd = uar_get_code_by_cki("CKI.CODEVALUE!4104734935")
	set code_values->cv.cs_400.apdrg_nc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4102959275")
	set code_values->cv.cs_400.apdrg_ne_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200106129")
	set code_values->cv.cs_400.apdrg_ny_cd = uar_get_code_by_cki("CKI.CODEVALUE!4300000001")
	set code_values->cv.cs_400.apdrg_oh_cd = uar_get_code_by_cki("CKI.CODEVALUE!4104556116")
	set code_values->cv.cs_400.apdrg_wa_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101285601")
	set code_values->cv.cs_400.apg_cd = uar_get_code_by_cki("CKI.CODEVALUE!3759712")
	set code_values->cv.cs_400.apinternal_cd = uar_get_code_by_cki("CKI.CODEVALUE!11526")
	set code_values->cv.cs_400.aprdrg_cd = uar_get_code_by_cki("CKI.CODEVALUE!2251228")
	set code_values->cv.cs_400.aprdrgaz_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109630899")
	set code_values->cv.cs_400.aprdrgca_cd = uar_get_code_by_cki("CKI.CODEVALUE!4108114977")
	set code_values->cv.cs_400.aprdrgfl_cd = uar_get_code_by_cki("CKI.CODEVALUE!4107202005")
	set code_values->cv.cs_400.aprdrgil_cd = uar_get_code_by_cki("CKI.CODEVALUE!4117984928")
	set code_values->cv.cs_400.aprdrgin_cd = uar_get_code_by_cki("CKI.CODEVALUE!4114088200")
	set code_values->cv.cs_400.aprdrgma_cd = uar_get_code_by_cki("CKI.CODEVALUE!4115478357")
	set code_values->cv.cs_400.aprdrgmd_cd = uar_get_code_by_cki("CKI.CODEVALUE!4102959274")
	set code_values->cv.cs_400.aprdrgmi_cd = uar_get_code_by_cki("CKI.CODEVALUE!4114817456")
	set code_values->cv.cs_400.aprdrgms_cd = uar_get_code_by_cki("CKI.CODEVALUE!4118421210")
	set code_values->cv.cs_400.aprdrgny_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101606192")
	set code_values->cv.cs_400.aprdrgva_cd = uar_get_code_by_cki("CKI.CODEVALUE!4118847986")
	set code_values->cv.cs_400.aprdrgwa_cd = uar_get_code_by_cki("CKI.CODEVALUE!4114691182")
	set code_values->cv.cs_400.ardrg_42_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200099523")
	set code_values->cv.cs_400.ardrg_51_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200099522")
	set code_values->cv.cs_400.ardrg_52_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200099521")
	set code_values->cv.cs_400.ardrg_60_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200099520")
	set code_values->cv.cs_400.ardrg_60x_cd = uar_get_code_by_cki("CKI.CODEVALUE!4105101607")
	set code_values->cv.cs_400.ardrg_70_cd = uar_get_code_by_cki("CKI.CODEVALUE!4107827786")
	set code_values->cv.cs_400.ardrg_80_cd = uar_get_code_by_cki("CKI.CODEVALUE!4114871028")
	set code_values->cv.cs_400.ardrg_90_cd = uar_get_code_by_cki("CKI.CODEVALUE!4119522720")
	set code_values->cv.cs_400.asa_cd = uar_get_code_by_cki("CKI.CODEVALUE!4112640165")
	set code_values->cv.cs_400.bcdx_cd = uar_get_code_by_cki("CKI.CODEVALUE!4113002130")
	set code_values->cv.cs_400.blood_bank_cd = uar_get_code_by_cki("CKI.CODEVALUE!2963")
	set code_values->cv.cs_400.c10es_cd = uar_get_code_by_cki("CKI.CODEVALUE!4114156362")
	set code_values->cv.cs_400.cap_ecc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101501939")
	set code_values->cv.cs_400.ceddx_cd = uar_get_code_by_cki("CKI.CODEVALUE!4117063652")
	set code_values->cv.cs_400.cerner_cd = uar_get_code_by_cki("CKI.CODEVALUE!3771826")
	set code_values->cv.cs_400.cid10br_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109644124")
	set code_values->cv.cs_400.cidobr_cd = uar_get_code_by_cki("CKI.CODEVALUE!4118012052")
	set code_values->cv.cs_400.cie10mx_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109000091")
	set code_values->cv.cs_400.cie10es_cd = uar_get_code_by_cki("CKI.CODEVALUE!4300000241")
	set code_values->cv.cs_400.cie9mc_cd = uar_get_code_by_cki("CKI.CODEVALUE!2570191984")
	set code_values->cv.cs_400.cie9mcmx_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109054985")
	set code_values->cv.cs_400.cieoes_cd = uar_get_code_by_cki("CKI.CODEVALUE!4115535105")
	set code_values->cv.cs_400.cif_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109020756")
	set code_values->cv.cs_400.cihi_cd = uar_get_code_by_cki("CKI.CODEVALUE!17059")
	set code_values->cv.cs_400.cim10_cd = uar_get_code_by_cki("CKI.CODEVALUE!2570105873")
	set code_values->cv.cs_400.cim10_2010_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101333069")
	set code_values->cv.cs_400.cim10_2011_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200105852")
	set code_values->cv.cs_400.cim10_2012_cd = uar_get_code_by_cki("CKI.CODEVALUE!4104153012")
	set code_values->cv.cs_400.cim10_2013_cd = uar_get_code_by_cki("CKI.CODEVALUE!4106233585")
	set code_values->cv.cs_400.cim10_2014_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109492665")
	set code_values->cv.cs_400.cim10_2015_cd = uar_get_code_by_cki("CKI.CODEVALUE!4112688599")
	set code_values->cv.cs_400.cim10_2016_cd = uar_get_code_by_cki("CKI.CODEVALUE!4114918278")
	set code_values->cv.cs_400.cim10_2017_cd = uar_get_code_by_cki("CKI.CODEVALUE!4116710979")
	set code_values->cv.cs_400.cki_cd = uar_get_code_by_cki("CKI.CODEVALUE!2848996")
	set code_values->cv.cs_400.clinbio_cd = uar_get_code_by_cki("CKI.CODEVALUE!3762581")
	set code_values->cv.cs_400.cmg_cd = uar_get_code_by_cki("CKI.CODEVALUE!2765747")
	set code_values->cv.cs_400.cot_cd = uar_get_code_by_cki("CKI.CODEVALUE!4116423850")
	set code_values->cv.cs_400.cpt4_cd = uar_get_code_by_cki("CKI.CODEVALUE!2954")
	set code_values->cv.cs_400.cvx_cd = uar_get_code_by_cki("CKI.CODEVALUE!4105880065")
	set code_values->cv.cs_400.dor27_cd = uar_get_code_by_cki("CKI.CODEVALUE!2958")
	set code_values->cv.cs_400.dpg_cd = uar_get_code_by_cki("CKI.CODEVALUE!2765748")
	set code_values->cv.cs_400.drggeorgia_cd = uar_get_code_by_cki("CKI.CODEVALUE!4100274422")
	set code_values->cv.cs_400.drggermany_cd = uar_get_code_by_cki("CKI.CODEVALUE!3738861")
	set code_values->cv.cs_400.drgillinois_cd = uar_get_code_by_cki("CKI.CODEVALUE!4100277750")
	set code_values->cv.cs_400.drgir_cd = uar_get_code_by_cki("CKI.CODEVALUE!4100275493")
	set code_values->cv.cs_400.dsm4_cd = uar_get_code_by_cki("CKI.CODEVALUE!55993")
	set code_values->cv.cs_400.dsm4_tr_cd = uar_get_code_by_cki("CKI.CODEVALUE!2766287")
	set code_values->cv.cs_400.dsm5_cd = uar_get_code_by_cki("CKI.CODEVALUE!4110388576")
	set code_values->cv.cs_400.dsm5ca_cd = uar_get_code_by_cki("CKI.CODEVALUE!4110263311")
	set code_values->cv.cs_400.eapg_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101341348")
	set code_values->cv.cs_400.freetext_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160004081")
	set code_values->cv.cs_400.gddbactcomp_cd = uar_get_code_by_cki("CKI.CODEVALUE!2910543")
	set code_values->cv.cs_400.gddbactgrp_cd = uar_get_code_by_cki("CKI.CODEVALUE!2910544")
	set code_values->cv.cs_400.gddbggpi_cd = uar_get_code_by_cki("CKI.CODEVALUE!3546602")
	set code_values->cv.cs_400.gddbhlthiss_cd = uar_get_code_by_cki("CKI.CODEVALUE!2910546")
	set code_values->cv.cs_400.gddbmol_cd = uar_get_code_by_cki("CKI.CODEVALUE!2914094")
	set code_values->cv.cs_400.gddbprod_cd = uar_get_code_by_cki("CKI.CODEVALUE!2910547")
	set code_values->cv.cs_400.gddbprodln_cd = uar_get_code_by_cki("CKI.CODEVALUE!2910548")
	set code_values->cv.cs_400.gddbsubst_cd = uar_get_code_by_cki("CKI.CODEVALUE!2910556")
	set code_values->cv.cs_400.general_lab_cd = uar_get_code_by_cki("CKI.CODEVALUE!2962")
	set code_values->cv.cs_400.hcfa_cd = uar_get_code_by_cki("CKI.CODEVALUE!5669")
	set code_values->cv.cs_400.hcpcs_cd = uar_get_code_by_cki("CKI.CODEVALUE!42457")
	set code_values->cv.cs_400.hhccdiag_cd = uar_get_code_by_cki("CKI.CODEVALUE!11527")
	set code_values->cv.cs_400.hhccintr_cd = uar_get_code_by_cki("CKI.CODEVALUE!11528")
	set code_values->cv.cs_400.hl7_cd = uar_get_code_by_cki("CKI.CODEVALUE!4115352726")
	set code_values->cv.cs_400.hla_cd = uar_get_code_by_cki("CKI.CODEVALUE!2966")
	set code_values->cv.cs_400.hla_dilution_cd = uar_get_code_by_cki("CKI.CODEVALUE!8439")
	set code_values->cv.cs_400.hla_meth_cd = uar_get_code_by_cki("CKI.CODEVALUE!8438")
	set code_values->cv.cs_400.hla_reaction_cd = uar_get_code_by_cki("CKI.CODEVALUE!17060")
	set code_values->cv.cs_400.hla_type_cd = uar_get_code_by_cki("CKI.CODEVALUE!8437")
	set code_values->cv.cs_400.hla_xm_type_cd = uar_get_code_by_cki("CKI.CODEVALUE!40596")
	set code_values->cv.cs_400.hlipft_cd = uar_get_code_by_cki("CKI.CODEVALUE!4102617641")
	set code_values->cv.cs_400.hpo_cd = uar_get_code_by_cki("CKI.CODEVALUE!4117074871")
	set code_values->cv.cs_400.hrg_cd = uar_get_code_by_cki("CKI.CODEVALUE!3652020")
	set code_values->cv.cs_400.icd10_cd = uar_get_code_by_cki("CKI.CODEVALUE!56781")
	set code_values->cv.cs_400.icd10amnd_cd = uar_get_code_by_cki("CKI.CODEVALUE!4107253287")
	set code_values->cv.cs_400.icd10amvemd_cd = uar_get_code_by_cki("CKI.CODEVALUE!4110185229")
	set code_values->cv.cs_400.icd10cm_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101498946")
	set code_values->cv.cs_400.icd10invld_cd = uar_get_code_by_cki("CKI.CODEVALUE!3649432")
	set code_values->cv.cs_400.icd10invld_cd = uar_get_code_by_cki("CKI.CODEVALUE!4110549185")
	set code_values->cv.cs_400.icd10pcs_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101496118")
	set code_values->cv.cs_400.icd10sgb_cd = uar_get_code_by_cki("CKI.CODEVALUE!3771824")
	set code_values->cv.cs_400.icd10who_cd = uar_get_code_by_cki("CKI.CODEVALUE!3811269")
	set code_values->cv.cs_400.icd10_ca_cd = uar_get_code_by_cki("CKI.CODEVALUE!2766288")
	set code_values->cv.cs_400.icd9_cd = uar_get_code_by_cki("CKI.CODEVALUE!2953")
	set code_values->cv.cs_400.icdo_cd = uar_get_code_by_cki("CKI.CODEVALUE!98291")
	set code_values->cv.cs_400.icpm_cd = uar_get_code_by_cki("CKI.CODEVALUE!2552922")
	set code_values->cv.cs_400.imo_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200092576")
	set code_values->cv.cs_400.imodsm5_cd = uar_get_code_by_cki("CKI.CODEVALUE!4114205762")
	set code_values->cv.cs_400.imo_au_cd = uar_get_code_by_cki("CKI.CODEVALUE!4116079974")
	set code_values->cv.cs_400.imo_aume_cd = uar_get_code_by_cki("CKI.CODEVALUE!4113681026")
	set code_values->cv.cs_400.inegi_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109361602")
	set code_values->cv.cs_400.iqhphr_cd = uar_get_code_by_cki("CKI.CODEVALUE!2961961")
	set code_values->cv.cs_400.loinc_cd = uar_get_code_by_cki("CKI.CODEVALUE!3455349")
	set code_values->cv.cs_400.lynx_cd = uar_get_code_by_cki("CKI.CODEVALUE!3481609")
	set code_values->cv.cs_400.mayo_prob_cd = uar_get_code_by_cki("CKI.CODEVALUE!4105320056")
	set code_values->cv.cs_400.mbse_nsw_cd = uar_get_code_by_cki("CKI.CODEVALUE!4106022386")
	set code_values->cv.cs_400.mbs_au_cd = uar_get_code_by_cki("CKI.CODEVALUE!4116262510")
	set code_values->cv.cs_400.mdi_cd = uar_get_code_by_cki("CKI.CODEVALUE!11530")
	set code_values->cv.cs_400.medicomalg_cd = uar_get_code_by_cki("CKI.CODEVALUE!2077293")
	set code_values->cv.cs_400.microbiology_cd = uar_get_code_by_cki("CKI.CODEVALUE!2961")
	set code_values->cv.cs_400.micromedex_cd = uar_get_code_by_cki("CKI.CODEVALUE!2967")
	set code_values->cv.cs_400.mohprocedure_cd = uar_get_code_by_cki("CKI.CODEVALUE!4115072921")
	set code_values->cv.cs_400.msdrg_cd = uar_get_code_by_cki("CKI.CODEVALUE!2570183840")
	set code_values->cv.cs_400.msdrgltc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4100276624")
	set code_values->cv.cs_400.msdrgnc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4107957411")
	set code_values->cv.cs_400.msdrgnm_cd = uar_get_code_by_cki("CKI.CODEVALUE!4105248355")
	set code_values->cv.cs_400.msdrgtri_cd = uar_get_code_by_cki("CKI.CODEVALUE!4100276623")
	set code_values->cv.cs_400.msdrgtx_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200139676")
	set code_values->cv.cs_400.msdrgtx_cd = uar_get_code_by_cki("CKI.CODEVALUE!4102547729")
	set code_values->cv.cs_400.msdrgut_cd = uar_get_code_by_cki("CKI.CODEVALUE!4113286632")
	set code_values->cv.cs_400.msdrgwi_cd = uar_get_code_by_cki("CKI.CODEVALUE!4103169123")
	set code_values->cv.cs_400.mulalgcat_cd = uar_get_code_by_cki("CKI.CODEVALUE!22969")
	set code_values->cv.cs_400.muldci_cd = uar_get_code_by_cki("CKI.CODEVALUE!4117293551")
	set code_values->cv.cs_400.muldclass_cd = uar_get_code_by_cki("CKI.CODEVALUE!2389845")
	set code_values->cv.cs_400.muldrug_cd = uar_get_code_by_cki("CKI.CODEVALUE!22970")
	set code_values->cv.cs_400.mulmmdc_cd = uar_get_code_by_cki("CKI.CODEVALUE!43584")
	set code_values->cv.cs_400.multum_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200098480")
	set code_values->cv.cs_400.namcs_cd = uar_get_code_by_cki("CKI.CODEVALUE!2956")
	set code_values->cv.cs_400.nanda_cd = uar_get_code_by_cki("CKI.CODEVALUE!2955")
	set code_values->cv.cs_400.ncci_cd = uar_get_code_by_cki("CKI.CODEVALUE!4119903830")
	set code_values->cv.cs_400.nci_cd = uar_get_code_by_cki("CKI.CODEVALUE!4102831174")
	set code_values->cv.cs_400.ncpdp_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200095220")
	set code_values->cv.cs_400.ndc_cd = uar_get_code_by_cki("CKI.CODEVALUE!4115393318")
	set code_values->cv.cs_400.ndfrt_cd = uar_get_code_by_cki("CKI.CODEVALUE!4102535625")
	set code_values->cv.cs_400.nic_cd = uar_get_code_by_cki("CKI.CODEVALUE!3858121")
	set code_values->cv.cs_400.nicip_cd = uar_get_code_by_cki("CKI.CODEVALUE!4106264286")
	set code_values->cv.cs_400.noc_cd = uar_get_code_by_cki("CKI.CODEVALUE!3858122")
	set code_values->cv.cs_400.opcs4_cd = uar_get_code_by_cki("CKI.CODEVALUE!3648300")
	set code_values->cv.cs_400.ops301gmany_cd = uar_get_code_by_cki("CKI.CODEVALUE!3738862")
	set code_values->cv.cs_400.orsos_cd = uar_get_code_by_cki("CKI.CODEVALUE!4110108518")
	set code_values->cv.cs_400.packageprice_cd = uar_get_code_by_cki("CKI.CODEVALUE!3757946")
	set code_values->cv.cs_400.pcats_cd = uar_get_code_by_cki("CKI.CODEVALUE!4116589936")
	set code_values->cv.cs_400.phin_vads_cd = uar_get_code_by_cki("CKI.CODEVALUE!4106054846")
	set code_values->cv.cs_400.pned_cd = uar_get_code_by_cki("CKI.CODEVALUE!723952686")
	set code_values->cv.cs_400.pned_ped_cd = uar_get_code_by_cki("CKI.CODEVALUE!4100457121")
	set code_values->cv.cs_400.pros_doh_cd = uar_get_code_by_cki("CKI.CODEVALUE!4113455544")
	set code_values->cv.cs_400.psl_cd = uar_get_code_by_cki("CKI.CODEVALUE!2193539")
	set code_values->cv.cs_400.ptcare_cd = uar_get_code_by_cki("CKI.CODEVALUE!4780")
	set code_values->cv.cs_400.rol_cd = uar_get_code_by_cki("CKI.CODEVALUE!4110097002")
	set code_values->cv.cs_400.rxnorm_cd = uar_get_code_by_cki("CKI.CODEVALUE!4100735102")
	set code_values->cv.cs_400.smni95_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160410014")
	set code_values->cv.cs_400.snm2_cd = uar_get_code_by_cki("CKI.CODEVALUE!11533")
	set code_values->cv.cs_400.snm2ext_cd = uar_get_code_by_cki("CKI.CODEVALUE!16899")
	set code_values->cv.cs_400.snmct_cd = uar_get_code_by_cki("CKI.CODEVALUE!3240237")
	set code_values->cv.cs_400.snmi95_cd = uar_get_code_by_cki("CKI.CODEVALUE!2964")
	set code_values->cv.cs_400.snmi95ext_cd = uar_get_code_by_cki("CKI.CODEVALUE!16900")
	set code_values->cv.cs_400.snmukemed_cd = uar_get_code_by_cki("CKI.CODEVALUE!4117139506")
	set code_values->cv.cs_400.sus_cd = uar_get_code_by_cki("CKI.CODEVALUE!4110596371")
	set code_values->cv.cs_400.tuss_cd = uar_get_code_by_cki("CKI.CODEVALUE!4110097001")
	set code_values->cv.cs_400.ucum_cd = uar_get_code_by_cki("CKI.CODEVALUE!4105879832")
	set code_values->cv.cs_400.unii_cd = uar_get_code_by_cki("CKI.CODEVALUE!4100735101")
	set code_values->cv.cs_400.webnap_cd = uar_get_code_by_cki("CKI.CODEVALUE!4110394611")
 
	call writeLog(build2("** Code Set 4010        ************************************"))
	set code_values->cv.cs_4010.now 			= uar_get_code_by("MEANING",4010, "NOW"	)
	set code_values->cv.cs_4010.routine 		= uar_get_code_by("MEANING",4010, "ROUTINE"	)
	set code_values->cv.cs_4010.stat 			= uar_get_code_by("MEANING",4010, "STAT"	)
	call writeLog(build2("** Code Set 6000        ************************************"))
	set code_values->cv.cs_6000.nutrition_services_cd = uar_get_code_by("MEANING",6000,"DIETARY")
	set code_values->cv.cs_6000.discern_rule_order_cd = uar_get_code_by("MEANING",6000,"RULEORDERS")
	set code_values->cv.cs_6000.materials_management_cd = uar_get_code_by("MEANING",6000,"MATERIALMGMT")
	set code_values->cv.cs_6000.patient_care_cd = uar_get_code_by("MEANING",6000,"NURS")
	set code_values->cv.cs_6000.pharmacy_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
	set code_values->cv.cs_6000.radiology_cd = uar_get_code_by("MEANING",6000,"RADIOLOGY")
	set code_values->cv.cs_6000.scheduling_cd = uar_get_code_by("MEANING",6000,"SCHEDULING")
	set code_values->cv.cs_6000.surgery_cd = uar_get_code_by("MEANING",6000,"SURGERY")
	set code_values->cv.cs_6000.home_care_cd = uar_get_code_by("MEANING",6000,"HOMECARE")
	set code_values->cv.cs_6000.home_care_plans_pathways_protocols_cd = uar_get_code_by("MEANING",6000,"HC_PLANPATH")
	set code_values->cv.cs_6000.environmental_services_cd = uar_get_code_by("MEANING",6000,"ENV SVCS")
	set code_values->cv.cs_6000.evaluation_and_management_cd = uar_get_code_by("MEANING",6000,"E & M")
	set code_values->cv.cs_6000.admit_transfer_discharge_cd = uar_get_code_by("MEANING",6000,"ATD")
	set code_values->cv.cs_6000.respiratory_therapy_cd = uar_get_code_by("MEANING",6000,"RESP THER")
	set code_values->cv.cs_6000.sleep_disorders_cd = uar_get_code_by("MEANING",6000,"SLEEP DIS")
	set code_values->cv.cs_6000.speech_therapy_cd = uar_get_code_by("MEANING",6000,"SPEECH THER")
	set code_values->cv.cs_6000.supplies_cd = uar_get_code_by("MEANING",6000,"SUPPLIES")
	set code_values->cv.cs_6000.urology_cd = uar_get_code_by("MEANING",6000,"UROLOGY")
	set code_values->cv.cs_6000.volunteer_services_cd = uar_get_code_by("MEANING",6000,"VOL SVCS")
	set code_values->cv.cs_6000.womens_services_cd = uar_get_code_by("MEANING",6000,"WOMENS SVCS")
	set code_values->cv.cs_6000.audiology_cd = uar_get_code_by("MEANING",6000,"AUDIOLOGY")
	set code_values->cv.cs_6000.cardiology_cd = uar_get_code_by("MEANING",6000,"CARDIOLOGY")
	set code_values->cv.cs_6000.consults_cd = uar_get_code_by("MEANING",6000,"CONSULTS")
	set code_values->cv.cs_6000.dialysis_cd = uar_get_code_by("MEANING",6000,"DIALYSIS")
	set code_values->cv.cs_6000.ent_cd = uar_get_code_by("MEANING",6000,"ENT")
	set code_values->cv.cs_6000.gastroenterology_cd = uar_get_code_by("MEANING",6000,"GASTROENT")
	set code_values->cv.cs_6000.infection_control_cd = uar_get_code_by("MEANING",6000,"INFECT CONTR")
	set code_values->cv.cs_6000.neurodiagnostics_cd = uar_get_code_by("MEANING",6000,"NEURODIAG")
	set code_values->cv.cs_6000.occupational_therapy_cd = uar_get_code_by("MEANING",6000,"OCC THER")
	set code_values->cv.cs_6000.orthopedics_cd = uar_get_code_by("MEANING",6000,"ORTHOPEDICS")
	set code_values->cv.cs_6000.pastoral_care_cd = uar_get_code_by("MEANING",6000,"PASTORAL")
	set code_values->cv.cs_6000.physical_therapy_cd = uar_get_code_by("MEANING",6000,"PHYS THER")
	set code_values->cv.cs_6000.procedures_cd = uar_get_code_by("MEANING",6000,"PROCEDURES")
	set code_values->cv.cs_6000.pulmonary_medicine_cd = uar_get_code_by("MEANING",6000,"PULMONARY")
	set code_values->cv.cs_6000.recreational_therapy_cd = uar_get_code_by("MEANING",6000,"REC THER")
	set code_values->cv.cs_6000.point_of_care_testing_cd = uar_get_code_by("MEANING",6000,"POINT OF CAR")
	set code_values->cv.cs_6000.physician_charges_cd = uar_get_code_by("MEANING",6000,"PHYSICIAN CH")
	set code_values->cv.cs_6000.blood_bank_donor_cd = uar_get_code_by("MEANING",6000,"BBDONOR")
	set code_values->cv.cs_6000.case_manager_cd = uar_get_code_by("MEANING",6000,"CASE MANAGEM")
	set code_values->cv.cs_6000.social_work_cd = uar_get_code_by("MEANING",6000,"SOCIAL WORK")
	set code_values->cv.cs_6000.ambulatory_poc_cd = uar_get_code_by("MEANING",6000,"AMB POC")
	set code_values->cv.cs_6000.cardiovascular_cd = uar_get_code_by("MEANING",6000,"CARDIOVASCUL")
	set code_values->cv.cs_6000.ambulatory_referrals_cd = uar_get_code_by("MEANING",6000,"AMB REFERRAL")
	set code_values->cv.cs_6000.ambulatory_procedures_cd = uar_get_code_by("MEANING",6000,"AMB PROC")
	set code_values->cv.cs_6000.durable_medical_equipment_cd = uar_get_code_by("MEANING",6000,"DURMEDEQUIP")
	set code_values->cv.cs_6000.person_management_cd = uar_get_code_by("MEANING",6000,"PERSON MGMT")
	set code_values->cv.cs_6000.referral_cd = uar_get_code_by("MEANING",6000,"REFERRAL")
	set code_values->cv.cs_6000.laboratory_cd = uar_get_code_by("MEANING",6000,"GENERAL LAB")
	set code_values->cv.cs_6000.ophthalmology_cd = uar_get_code_by("MEANING",6000,"OPHTHALMOLOG")
	set code_values->cv.cs_6000.ambulatory_scheduling_cd = uar_get_code_by("MEANING",6000,"AMBSCHED")
 
	call writeLog(build2("** Code Set 6003        ************************************"))
	set code_values->cv.cs_6003.activate_cd = uar_get_code_by("MEANING",6003,"ACTIVATE")
	set code_values->cv.cs_6003.add_alias_cd = uar_get_code_by("MEANING",6003,"ADD ALIAS")
	set code_values->cv.cs_6003.cancel_cd = uar_get_code_by("MEANING",6003,"CANCEL")
	set code_values->cv.cs_6003.cancel_dc_cd = uar_get_code_by("MEANING",6003,"CANCEL DC")
	set code_values->cv.cs_6003.cancel_reord_cd = uar_get_code_by("MEANING",6003,"CANCEL REORD")
	set code_values->cv.cs_6003.clear_cd = uar_get_code_by("MEANING",6003,"CLEAR")
	set code_values->cv.cs_6003.collection_cd = uar_get_code_by("MEANING",6003,"COLLECTION")
	set code_values->cv.cs_6003.complete_cd = uar_get_code_by("MEANING",6003,"COMPLETE")
	set code_values->cv.cs_6003.delete_cd = uar_get_code_by("MEANING",6003,"DELETE")
	set code_values->cv.cs_6003.demogchange_cd = uar_get_code_by("MEANING",6003,"DEMOGCHANGE")
	set code_values->cv.cs_6003.discontinue_cd = uar_get_code_by("MEANING",6003,"DISCONTINUE")
	set code_values->cv.cs_6003.disorder_cd = uar_get_code_by("MEANING",6003,"DISORDER")
	set code_values->cv.cs_6003.futuredc_cd = uar_get_code_by("MEANING",6003,"FUTUREDC")
	set code_values->cv.cs_6003.hisorder_cd = uar_get_code_by("MEANING",6003,"HISORDER")
	set code_values->cv.cs_6003.modify_cd = uar_get_code_by("MEANING",6003,"MODIFY")
	set code_values->cv.cs_6003.order_cd = uar_get_code_by("MEANING",6003,"ORDER")
	set code_values->cv.cs_6003.refill_cd = uar_get_code_by("MEANING",6003,"REFILL")
	set code_values->cv.cs_6003.renew_cd = uar_get_code_by("MEANING",6003,"RENEW")
	set code_values->cv.cs_6003.reschedule_cd = uar_get_code_by("MEANING",6003,"RESCHEDULE")
	set code_values->cv.cs_6003.restore_cd = uar_get_code_by("MEANING",6003,"RESTORE")
	set code_values->cv.cs_6003.resume_cd = uar_get_code_by("MEANING",6003,"RESUME")
	set code_values->cv.cs_6003.resume_renew_cd = uar_get_code_by("MEANING",6003,"RESUME/RENEW")
	set code_values->cv.cs_6003.review_cd = uar_get_code_by("MEANING",6003,"REVIEW")
	set code_values->cv.cs_6003.statuschange_cd = uar_get_code_by("MEANING",6003,"STATUSCHANGE")
	set code_values->cv.cs_6003.studactivate_cd = uar_get_code_by("MEANING",6003,"STUDACTIVATE")
	set code_values->cv.cs_6003.suspend_cd = uar_get_code_by("MEANING",6003,"SUSPEND")
	set code_values->cv.cs_6003.transfer_can_cd = uar_get_code_by("MEANING",6003,"TRANSFER/CAN")
	set code_values->cv.cs_6003.undo_cd = uar_get_code_by("MEANING",6003,"UNDO")
 
	call writeLog(build2("** Code Set 6004        ************************************"))
	set code_values->cv.cs_6004.canceled_cd = uar_get_code_by_cki("CKI.CODEVALUE!3099")
	set code_values->cv.cs_6004.completed_cd = uar_get_code_by_cki("CKI.CODEVALUE!3100")
	set code_values->cv.cs_6004.deleted_cd = uar_get_code_by_cki("CKI.CODEVALUE!44311")
	set code_values->cv.cs_6004.discontinued_cd = uar_get_code_by_cki("CKI.CODEVALUE!3101")
	set code_values->cv.cs_6004.future_cd = uar_get_code_by_cki("CKI.CODEVALUE!11559")
	set code_values->cv.cs_6004.incomplete_cd = uar_get_code_by_cki("CKI.CODEVALUE!3815")
	set code_values->cv.cs_6004.inprocess_cd = uar_get_code_by_cki("CKI.CODEVALUE!3224")
	set code_values->cv.cs_6004.medstudent_cd = uar_get_code_by_cki("CKI.CODEVALUE!14311")
	set code_values->cv.cs_6004.ordered_cd = uar_get_code_by_cki("CKI.CODEVALUE!3102")
	set code_values->cv.cs_6004.pending_cd = uar_get_code_by_cki("CKI.CODEVALUE!2564278")
	set code_values->cv.cs_6004.pending_rev_cd = uar_get_code_by_cki("CKI.CODEVALUE!3103")
	set code_values->cv.cs_6004.suspended_cd = uar_get_code_by_cki("CKI.CODEVALUE!3104")
	set code_values->cv.cs_6004.transcancel_cd = uar_get_code_by_cki("CKI.CODEVALUE!406488")
	set code_values->cv.cs_6004.unscheduled_cd = uar_get_code_by_cki("CKI.CODEVALUE!3105")
	set code_values->cv.cs_6004.voidedwrslt_cd = uar_get_code_by_cki("CKI.CODEVALUE!2488992")
 
 
	call writeLog(build2("** Code Set 12025       ************************************"))
	set code_values->cv.cs_12025.active_cd = uar_get_code_by("MEANING",12025,"ACTIVE")
	set code_values->cv.cs_12025.canceled_cd = uar_get_code_by("MEANING",12025,"CANCELED")
	set code_values->cv.cs_12025.proposed_cd = uar_get_code_by("MEANING",12025,"PROPOSED")
	set code_values->cv.cs_12025.resolved_cd = uar_get_code_by("MEANING",12025,"RESOLVED")
 
	call writeLog(build2("** Code Set 12034       ************************************"))
	set code_values->cv.cs_12034.tertiary_cd = uar_get_code_by_cki("CKI.CODEVALUE!3756565")
	set code_values->cv.cs_12034.primary_cd = uar_get_code_by_cki("CKI.CODEVALUE!3474")
	set code_values->cv.cs_12034.secondary_cd = uar_get_code_by_cki("CKI.CODEVALUE!3475")
 
	call writeLog(build2("** Code Set 13029       ************************************"))
	set code_values->cv.cs_13029.display_cd = uar_get_code_by_cki("CKI")
	set code_values->cv.cs_13029.actual_cd = uar_get_code_by_cki("CKI.CODEVALUE!11690")
	set code_values->cv.cs_13029.administered_cd = uar_get_code_by_cki("CKI.CODEVALUE!2008220")
	set code_values->cv.cs_13029.attempted_cd = uar_get_code_by_cki("CKI.CODEVALUE!11691")
	set code_values->cv.cs_13029.bbreturn_cd = uar_get_code_by_cki("CKI.CODEVALUE!8149")
	set code_values->cv.cs_13029.bbreturning_cd = uar_get_code_by_cki("CKI.CODEVALUE!8595")
	set code_values->cv.cs_13029.cancel_cd = uar_get_code_by_cki("CKI.CODEVALUE!3538")
	set code_values->cv.cs_13029.canceling_cd = uar_get_code_by_cki("CKI.CODEVALUE!3539")
	set code_values->cv.cs_13029.checkin_cd = uar_get_code_by_cki("CKI.CODEVALUE!2797849")
	set code_values->cv.cs_13029.checkout_cd = uar_get_code_by_cki("CKI.CODEVALUE!2797850")
	set code_values->cv.cs_13029.clear_cd = uar_get_code_by_cki("CKI.CODEVALUE!3540")
	set code_values->cv.cs_13029.collected_cd = uar_get_code_by_cki("CKI.CODEVALUE!3541")
	set code_values->cv.cs_13029.collecting_cd = uar_get_code_by_cki("CKI.CODEVALUE!3542")
	set code_values->cv.cs_13029.complete_cd = uar_get_code_by_cki("CKI.CODEVALUE!3543")
	set code_values->cv.cs_13029.completing_cd = uar_get_code_by_cki("CKI.CODEVALUE!3544")
	set code_values->cv.cs_13029.corrected_cd = uar_get_code_by_cki("CKI.CODEVALUE!3545")
	set code_values->cv.cs_13029.correcting_cd = uar_get_code_by_cki("CKI.CODEVALUE!3546")
	set code_values->cv.cs_13029.debug_reprocess_cd = uar_get_code_by_cki("CKI.CODEVALUE!2398113")
	set code_values->cv.cs_13029.dispensed_cd = uar_get_code_by_cki("CKI.CODEVALUE!3547")
	set code_values->cv.cs_13029.dispensing_cd = uar_get_code_by_cki("CKI.CODEVALUE!3548")
	set code_values->cv.cs_13029.disposed_cd = uar_get_code_by_cki("CKI.CODEVALUE!11695")
	set code_values->cv.cs_13029.exam_complete_cd = uar_get_code_by_cki("CKI.CODEVALUE!5436")
	set code_values->cv.cs_13029.in_lab_cd = uar_get_code_by_cki("CKI.CODEVALUE!8542")
	set code_values->cv.cs_13029.loaded_cd = uar_get_code_by_cki("CKI.CODEVALUE!8983")
	set code_values->cv.cs_13029.manual_cd = uar_get_code_by_cki("CKI.CODEVALUE!3550")
	set code_values->cv.cs_13029.modified_cd = uar_get_code_by_cki("CKI.CODEVALUE!11696")
	set code_values->cv.cs_13029.nocommit_cd = uar_get_code_by_cki("CKI.CODEVALUE!723881939")
	set code_values->cv.cs_13029.ordered_cd = uar_get_code_by_cki("CKI.CODEVALUE!3551")
	set code_values->cv.cs_13029.ordering_cd = uar_get_code_by_cki("CKI.CODEVALUE!3825")
	set code_values->cv.cs_13029.performed_cd = uar_get_code_by_cki("CKI.CODEVALUE!3761")
	set code_values->cv.cs_13029.performing_cd = uar_get_code_by_cki("CKI.CODEVALUE!3552")
	set code_values->cv.cs_13029.projected_cd = uar_get_code_by_cki("CKI.CODEVALUE!11692")
	set code_values->cv.cs_13029.received_cd = uar_get_code_by_cki("CKI.CODEVALUE!11697")
	set code_values->cv.cs_13029.referred_cd = uar_get_code_by_cki("CKI.CODEVALUE!2759567")
	set code_values->cv.cs_13029.released_cd = uar_get_code_by_cki("CKI.CODEVALUE!11698")
	set code_values->cv.cs_13029.reprocess_cd = uar_get_code_by_cki("CKI.CODEVALUE!2398114")
	set code_values->cv.cs_13029.reverse_cd = uar_get_code_by_cki("CKI.CODEVALUE!2008260")
	set code_values->cv.cs_13029.scheduled_cd = uar_get_code_by_cki("CKI.CODEVALUE!11699")
	set code_values->cv.cs_13029.setup_cd = uar_get_code_by_cki("CKI.CODEVALUE!13746")
	set code_values->cv.cs_13029.signout_cd = uar_get_code_by_cki("CKI.CODEVALUE!5437")
	set code_values->cv.cs_13029.transcribed_cd = uar_get_code_by_cki("CKI.CODEVALUE!11700")
	set code_values->cv.cs_13029.transfused_cd = uar_get_code_by_cki("CKI.CODEVALUE!3553")
	set code_values->cv.cs_13029.transfusing_cd = uar_get_code_by_cki("CKI.CODEVALUE!3554")
	set code_values->cv.cs_13029.uncollecteduninlab_cd = uar_get_code_by_cki("CKI.CODEVALUE!3982184")
	set code_values->cv.cs_13029.uncomplete_cd = uar_get_code_by_cki("CKI.CODEVALUE!53731")
	set code_values->cv.cs_13029.verified_cd = uar_get_code_by_cki("CKI.CODEVALUE!3555")
	set code_values->cv.cs_13029.verifying_cd = uar_get_code_by_cki("CKI.CODEVALUE!3556")
 
 
	call writeLog(build2("** Code Set 14002       ************************************"))
	set code_values->cv.cs_14002.all_suspend_cd = uar_get_code_by("DISPLAYKEY",14002,"ALLSUSPEND")
	set code_values->cv.cs_14002.asa_cd = uar_get_code_by("DISPLAYKEY",14002,"ASA")
	set code_values->cv.cs_14002.cdmschedpharm_cd = uar_get_code_by("DISPLAYKEY",14002,"CDMSCHEDPHARM")
	set code_values->cv.cs_14002.hospital_cdm_tech_cd = uar_get_code_by("DISPLAYKEY",14002,"HOSPITALCDMTECH")
	set code_values->cv.cs_14002.hospital_cdm_prof_cd = uar_get_code_by("DISPLAYKEY",14002,"HOSPITALCDMPROF")
	set code_values->cv.cs_14002.ambulatory_cdm_prof_cd = uar_get_code_by("DISPLAYKEY",14002,"AMBULATORYCDMPROF")
	set code_values->cv.cs_14002.path_tech_purchased_cdm_cd = uar_get_code_by("DISPLAYKEY",14002,"PATHTECHPURCHASEDCDM")
	set code_values->cv.cs_14002.tog_cdm_professional_cd = uar_get_code_by("DISPLAYKEY",14002,"TOGCDMPROFESSIONAL")
	set code_values->cv.cs_14002.hospital_medicare_cdm_tech_cd = uar_get_code_by("DISPLAYKEY",14002,"HOSPITALMEDICARECDMTECH")
	set code_values->cv.cs_14002.hospital_cdm_tech_no_charge_cd = uar_get_code_by("DISPLAYKEY",14002,"HOSPITALCDMTECHNOCHARGE")
	set code_values->cv.cs_14002.ambulatory_charge_point_profee_cd =
		uar_get_code_by("DISPLAYKEY",14002,"AMBULATORYCHARGEPOINTPROFEE")
	set code_values->cv.cs_14002.hospital_charge_point_tech_cd =
		uar_get_code_by("DISPLAYKEY",14002,"HOSPITALCHARGEPOINTTECH")
	set code_values->cv.cs_14002.hospital_charge_point_professional_cd =
		uar_get_code_by("DISPLAYKEY",14002,"HOSPITALCHARGEPOINTPROFESSIONAL")
	set code_values->cv.cs_14002.ambulatory_charge_point_lab_cd = uar_get_code_by("DISPLAYKEY",14002,"AMBULATORYCHARGEPOINTLAB")
	set code_values->cv.cs_14002.no_charge_cd = uar_get_code_by("DISPLAYKEY",14002,"NOCHARGE")
	set code_values->cv.cs_14002.hospital_medicare_tech_cd = uar_get_code_by("DISPLAYKEY",14002,"HOSPITALMEDICARETECH")
	set code_values->cv.cs_14002.hospital_medicare_professional_cd =
		uar_get_code_by("DISPLAYKEY",14002,"HOSPITALMEDICAREPROFESSIONAL")
	set code_values->cv.cs_14002.combine_cd = uar_get_code_by("DISPLAYKEY",14002,"COMBINE")
	set code_values->cv.cs_14002.cpt_cd = uar_get_code_by("DISPLAYKEY",14002,"CPT")
	set code_values->cv.cs_14002.bh_cpt_hosp_prof_cd = uar_get_code_by("DISPLAYKEY",14002,"BHCPTHOSPPROF")
	set code_values->cv.cs_14002.bh_cpt_hosp_tech_cd = uar_get_code_by("DISPLAYKEY",14002,"BHCPTHOSPTECH")
	set code_values->cv.cs_14002.hcpcs_cd = uar_get_code_by("DISPLAYKEY",14002,"HCPCS")
	set code_values->cv.cs_14002.bh_hcpcs_hosp_prof_cd = uar_get_code_by("DISPLAYKEY",14002,"BHHCPCSHOSPPROF")
	set code_values->cv.cs_14002.bh_hcpcs_hosp_tech_cd = uar_get_code_by("DISPLAYKEY",14002,"BHHCPCSHOSPTECH")
	set code_values->cv.cs_14002.icd_cd = uar_get_code_by("DISPLAYKEY",14002,"ICD")
	set code_values->cv.cs_14002.cpt_modifier_cd = uar_get_code_by("DISPLAYKEY",14002,"CPTMODIFIER")
	set code_values->cv.cs_14002.hospital_340b_tech_jgtb_cd = uar_get_code_by("DISPLAYKEY",14002,"HOSPITAL340BTECHJGTB")
	set code_values->cv.cs_14002.hospital_340b_tech_standard_cd = uar_get_code_by("DISPLAYKEY",14002,"HOSPITAL340BTECHSTANDARD")
	set code_values->cv.cs_14002.bh_tech_modifier_cd = uar_get_code_by("DISPLAYKEY",14002,"BHTECHMODIFIER")
	set code_values->cv.cs_14002.bh_prof_modifier_cd = uar_get_code_by("DISPLAYKEY",14002,"BHPROFMODIFIER")
	set code_values->cv.cs_14002.hospital_340b_tech_orphaned_cd = uar_get_code_by("DISPLAYKEY",14002,"HOSPITAL340BTECHORPHANED")
 
	call writeLog(build2("** Code Set 14123       ************************************"))
	set code_values->cv.cs_14123.completed_cd = uar_get_code_by_cki("CKI.CODEVALUE!8228")
	set code_values->cv.cs_14123.removed_cd = uar_get_code_by_cki("CKI.CODEVALUE!16913")
	set code_values->cv.cs_14123.started_cd = uar_get_code_by_cki("CKI.CODEVALUE!8229")
 
	call writeLog(build2("** Code Set 14192       ************************************"))
	set code_values->cv.cs_14192.canceled_cd = uar_get_code_by_cki("CKI.CODEVALUE!5581")
	set code_values->cv.cs_14192.completed_cd = uar_get_code_by_cki("CKI.CODEVALUE!5583")
	set code_values->cv.cs_14192.in_process_cd = uar_get_code_by_cki("CKI.CODEVALUE!5582")
	set code_values->cv.cs_14192.on_hold_cd = uar_get_code_by_cki("CKI.CODEVALUE!2189927")
	set code_values->cv.cs_14192.ordered_cd = uar_get_code_by_cki("CKI.CODEVALUE!5584")
	set code_values->cv.cs_14192.removed_cd = uar_get_code_by_cki("CKI.CODEVALUE!16919")
	set code_values->cv.cs_14192.replaced_cd = uar_get_code_by_cki("CKI.CODEVALUE!16921")
	set code_values->cv.cs_14192.started_cd = uar_get_code_by_cki("CKI.CODEVALUE!5585")
 
 	call writeLog(build2("** Code Set 14232       ************************************"))
	set code_values->cv.cs_14232.addclininfo_cd = uar_get_code_by("MEANING",14232,"ADDCLININFO")
	set code_values->cv.cs_14232.addedbmsx04_cd = uar_get_code_by("MEANING",14232,"ADDEDBMSX04")
	set code_values->cv.cs_14232.addedbmsx05_cd = uar_get_code_by("MEANING",14232,"ADDEDBMSX05")
	set code_values->cv.cs_14232.addreferral_cd = uar_get_code_by("MEANING",14232,"ADDREFERRAL")
	set code_values->cv.cs_14232.addrequrmnt_cd = uar_get_code_by("MEANING",14232,"ADDREQURMNT")
	set code_values->cv.cs_14232.addshortlist_cd = uar_get_code_by("MEANING",14232,"ADDSHORTLIST")
	set code_values->cv.cs_14232.advice_cd = uar_get_code_by("MEANING",14232,"ADVICE")
	set code_values->cv.cs_14232.appointment_cd = uar_get_code_by("MEANING",14232,"APPOINTMENT")
	set code_values->cv.cs_14232.apptnoxpas_cd = uar_get_code_by("MEANING",14232,"APPTNOXPAS")
	set code_values->cv.cs_14232.apptxpas_cd = uar_get_code_by("MEANING",14232,"APPTXPAS")
	set code_values->cv.cs_14232.asi_cd = uar_get_code_by("MEANING",14232,"ASI")
	set code_values->cv.cs_14232.asicontact_cd = uar_get_code_by("MEANING",14232,"ASICONTACT")
	set code_values->cv.cs_14232.assess_cd = uar_get_code_by("MEANING",14232,"ASSESS")
	set code_values->cv.cs_14232.block_cd = uar_get_code_by("MEANING",14232,"BLOCK")
	set code_values->cv.cs_14232.cancel_cd = uar_get_code_by("MEANING",14232,"CANCEL")
	set code_values->cv.cs_14232.canceladv_cd = uar_get_code_by("MEANING",14232,"CANCELADV")
	set code_values->cv.cs_14232.cancelreq_cd = uar_get_code_by("MEANING",14232,"CANCELREQ")
	set code_values->cv.cs_14232.canreqfollup_cd = uar_get_code_by("MEANING",14232,"CANREQFOLLUP")
	set code_values->cv.cs_14232.checkabn_cd = uar_get_code_by("MEANING",14232,"CHECKABN")
	set code_values->cv.cs_14232.checkin_cd = uar_get_code_by("MEANING",14232,"CHECKIN")
	set code_values->cv.cs_14232.checkout_cd = uar_get_code_by("MEANING",14232,"CHECKOUT")
	set code_values->cv.cs_14232.closeadv_cd = uar_get_code_by("MEANING",14232,"CLOSEADV")
	set code_values->cv.cs_14232.cmpltprnting_cd = uar_get_code_by("MEANING",14232,"CMPLTPRNTING")
	set code_values->cv.cs_14232.cnlrequrmnt_cd = uar_get_code_by("MEANING",14232,"CNLREQURMNT")
	set code_values->cv.cs_14232.complete_cd = uar_get_code_by("MEANING",14232,"COMPLETE")
	set code_values->cv.cs_14232.completereq_cd = uar_get_code_by("MEANING",14232,"COMPLETEREQ")
	set code_values->cv.cs_14232.confirm_cd = uar_get_code_by("MEANING",14232,"CONFIRM")
	set code_values->cv.cs_14232.contact_cd = uar_get_code_by("MEANING",14232,"CONTACT")
	set code_values->cv.cs_14232.contactref_cd = uar_get_code_by("MEANING",14232,"CONTACTREF")
	set code_values->cv.cs_14232.cutpaste_cd = uar_get_code_by("MEANING",14232,"CUTPASTE")
	set code_values->cv.cs_14232.defer_cd = uar_get_code_by("MEANING",14232,"DEFER")
	set code_values->cv.cs_14232.deferresched_cd = uar_get_code_by("MEANING",14232,"DEFERRESCHED")
	set code_values->cv.cs_14232.delete_cd = uar_get_code_by("MEANING",14232,"DELETE")
	set code_values->cv.cs_14232.discard_cd = uar_get_code_by("MEANING",14232,"DISCARD")
	set code_values->cv.cs_14232.displaced_cd = uar_get_code_by("MEANING",14232,"DISPLACED")
	set code_values->cv.cs_14232.esoskip_cd = uar_get_code_by("MEANING",14232,"ESOSKIP")
	set code_values->cv.cs_14232.finalize_cd = uar_get_code_by("MEANING",14232,"FINALIZE")
	set code_values->cv.cs_14232.hold_cd = uar_get_code_by("MEANING",14232,"HOLD")
	set code_values->cv.cs_14232.link_cd = uar_get_code_by("MEANING",14232,"LINK")
	set code_values->cv.cs_14232.lock_cd = uar_get_code_by("MEANING",14232,"LOCK")
	set code_values->cv.cs_14232.modassess_cd = uar_get_code_by("MEANING",14232,"MODASSESS")
	set code_values->cv.cs_14232.modify_cd = uar_get_code_by("MEANING",14232,"MODIFY")
	set code_values->cv.cs_14232.modifyadv_cd = uar_get_code_by("MEANING",14232,"MODIFYADV")
	set code_values->cv.cs_14232.modifyreq_cd = uar_get_code_by("MEANING",14232,"MODIFYREQ")
	set code_values->cv.cs_14232.modreferral_cd = uar_get_code_by("MEANING",14232,"MODREFERRAL")
	set code_values->cv.cs_14232.mohhcv_cd = uar_get_code_by("MEANING",14232,"MOHHCV")
	set code_values->cv.cs_14232.moveres_cd = uar_get_code_by("MEANING",14232,"MOVERES")
	set code_values->cv.cs_14232.noshow_cd = uar_get_code_by("MEANING",14232,"NOSHOW")
	set code_values->cv.cs_14232.noswreqfolup_cd = uar_get_code_by("MEANING",14232,"NOSWREQFOLUP")
	set code_values->cv.cs_14232.patseen_cd = uar_get_code_by("MEANING",14232,"PATSEEN")
	set code_values->cv.cs_14232.print_cd = uar_get_code_by("MEANING",14232,"PRINT")
	set code_values->cv.cs_14232.private_cd = uar_get_code_by("MEANING",14232,"PRIVATE")
	set code_values->cv.cs_14232.processdna_cd = uar_get_code_by("MEANING",14232,"PROCESSDNA")
	set code_values->cv.cs_14232.ptpatarrved_cd = uar_get_code_by("MEANING",14232,"PTPATARRVED")
	set code_values->cv.cs_14232.ptpatfinish_cd = uar_get_code_by("MEANING",14232,"PTPATFINISH")
	set code_values->cv.cs_14232.ptpatinroom_cd = uar_get_code_by("MEANING",14232,"PTPATINROOM")
	set code_values->cv.cs_14232.ptpatleft_cd = uar_get_code_by("MEANING",14232,"PTPATLEFT")
	set code_values->cv.cs_14232.ptpatready_cd = uar_get_code_by("MEANING",14232,"PTPATREADY")
	set code_values->cv.cs_14232.ptpatstarted_cd = uar_get_code_by("MEANING",14232,"PTPATSTARTED")
	set code_values->cv.cs_14232.ptpatstatrst_cd = uar_get_code_by("MEANING",14232,"PTPATSTATRST")
	set code_values->cv.cs_14232.public_cd = uar_get_code_by("MEANING",14232,"PUBLIC")
	set code_values->cv.cs_14232.recordnoshow_cd = uar_get_code_by("MEANING",14232,"RECORDNOSHOW")
	set code_values->cv.cs_14232.recur_cd = uar_get_code_by("MEANING",14232,"RECUR")
	set code_values->cv.cs_14232.reject_cd = uar_get_code_by("MEANING",14232,"REJECT")
	set code_values->cv.cs_14232.rejectcancel_cd = uar_get_code_by("MEANING",14232,"REJECTCANCEL")
	set code_values->cv.cs_14232.remind_cd = uar_get_code_by("MEANING",14232,"REMIND")
	set code_values->cv.cs_14232.rempatlock_cd = uar_get_code_by("MEANING",14232,"REMPATLOCK")
	set code_values->cv.cs_14232.reorder_cd = uar_get_code_by("MEANING",14232,"REORDER")
	set code_values->cv.cs_14232.request_cd = uar_get_code_by("MEANING",14232,"REQUEST")
	set code_values->cv.cs_14232.reschedule_cd = uar_get_code_by("MEANING",14232,"RESCHEDULE")
	set code_values->cv.cs_14232.respond_cd = uar_get_code_by("MEANING",14232,"RESPOND")
	set code_values->cv.cs_14232.restore_cd = uar_get_code_by("MEANING",14232,"RESTORE")
	set code_values->cv.cs_14232.restorereq_cd = uar_get_code_by("MEANING",14232,"RESTOREREQ")
	set code_values->cv.cs_14232.retainreq_cd = uar_get_code_by("MEANING",14232,"RETAINREQ")
	set code_values->cv.cs_14232.review_cd = uar_get_code_by("MEANING",14232,"REVIEW")
	set code_values->cv.cs_14232.rmvfrmwklst_cd = uar_get_code_by("MEANING",14232,"RMVFRMWKLST")
	set code_values->cv.cs_14232.schedule_cd = uar_get_code_by("MEANING",14232,"SCHEDULE")
	set code_values->cv.cs_14232.seenbygen1_cd = uar_get_code_by("MEANING",14232,"SEENBYGEN1")
	set code_values->cv.cs_14232.seenbygen2_cd = uar_get_code_by("MEANING",14232,"SEENBYGEN2")
	set code_values->cv.cs_14232.seenbygen3_cd = uar_get_code_by("MEANING",14232,"SEENBYGEN3")
	set code_values->cv.cs_14232.seenbygen4_cd = uar_get_code_by("MEANING",14232,"SEENBYGEN4")
	set code_values->cv.cs_14232.seenbymedstu_cd = uar_get_code_by("MEANING",14232,"SEENBYMEDSTU")
	set code_values->cv.cs_14232.seenbymidlev_cd = uar_get_code_by("MEANING",14232,"SEENBYMIDLEV")
	set code_values->cv.cs_14232.seenbynurse_cd = uar_get_code_by("MEANING",14232,"SEENBYNURSE")
	set code_values->cv.cs_14232.seenbyphysic_cd = uar_get_code_by("MEANING",14232,"SEENBYPHYSIC")
	set code_values->cv.cs_14232.seenbyreside_cd = uar_get_code_by("MEANING",14232,"SEENBYRESIDE")
	set code_values->cv.cs_14232.shuffle_cd = uar_get_code_by("MEANING",14232,"SHUFFLE")
	set code_values->cv.cs_14232.standby_cd = uar_get_code_by("MEANING",14232,"STANDBY")
	set code_values->cv.cs_14232.swapres_cd = uar_get_code_by("MEANING",14232,"SWAPRES")
	set code_values->cv.cs_14232.unblock_cd = uar_get_code_by("MEANING",14232,"UNBLOCK")
	set code_values->cv.cs_14232.undocancel_cd = uar_get_code_by("MEANING",14232,"UNDOCANCEL")
	set code_values->cv.cs_14232.undocheckin_cd = uar_get_code_by("MEANING",14232,"UNDOCHECKIN")
	set code_values->cv.cs_14232.undocheckout_cd = uar_get_code_by("MEANING",14232,"UNDOCHECKOUT")
	set code_values->cv.cs_14232.undonoshow_cd = uar_get_code_by("MEANING",14232,"UNDONOSHOW")
	set code_values->cv.cs_14232.unlink_cd = uar_get_code_by("MEANING",14232,"UNLINK")
	set code_values->cv.cs_14232.unlock_cd = uar_get_code_by("MEANING",14232,"UNLOCK")
	set code_values->cv.cs_14232.updtrequrmnt_cd = uar_get_code_by("MEANING",14232,"UPDTREQURMNT")
	set code_values->cv.cs_14232.verify_cd = uar_get_code_by("MEANING",14232,"VERIFY")
	set code_values->cv.cs_14232.view_cd = uar_get_code_by("MEANING",14232,"VIEW")
 
	call writeLog(build2("** Code Set 14233       ************************************"))
	set code_values->cv.cs_14233.advice_cd = uar_get_code_by_cki("CKI.CODEVALUE!3843374")
	set code_values->cv.cs_14233.default_cd = uar_get_code_by_cki("CKI.CODEVALUE!6155")
	set code_values->cv.cs_14233.assessed_cd = uar_get_code_by_cki("CKI.CODEVALUE!4533557")
	set code_values->cv.cs_14233.block_cd = uar_get_code_by_cki("CKI.CODEVALUE!56834")
	set code_values->cv.cs_14233.canceled_cd = uar_get_code_by_cki("CKI.CODEVALUE!6156")
	set code_values->cv.cs_14233.canceled_advice_cd = uar_get_code_by_cki("CKI.CODEVALUE!3845338")
	set code_values->cv.cs_14233.checked_in_cd = uar_get_code_by_cki("CKI.CODEVALUE!6157")
	set code_values->cv.cs_14233.checked_out_cd = uar_get_code_by_cki("CKI.CODEVALUE!6158")
	set code_values->cv.cs_14233.closed_advice_cd = uar_get_code_by_cki("CKI.CODEVALUE!3843376")
	set code_values->cv.cs_14233.complete_cd = uar_get_code_by_cki("CKI.CODEVALUE!4533558")
	set code_values->cv.cs_14233.confirmed_cd = uar_get_code_by_cki("CKI.CODEVALUE!6159")
	set code_values->cv.cs_14233.deleted_cd = uar_get_code_by_cki("CKI.CODEVALUE!6160")
	set code_values->cv.cs_14233.discarded_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160142027")
	set code_values->cv.cs_14233.finalized_cd = uar_get_code_by_cki("CKI.CODEVALUE!6161")
	set code_values->cv.cs_14233.hold_cd = uar_get_code_by_cki("CKI.CODEVALUE!6162")
	set code_values->cv.cs_14233.no_show_cd = uar_get_code_by_cki("CKI.CODEVALUE!6163")
	set code_values->cv.cs_14233.pending_cd = uar_get_code_by_cki("CKI.CODEVALUE!6164")
	set code_values->cv.cs_14233.request_cd = uar_get_code_by_cki("CKI.CODEVALUE!2156953")
	set code_values->cv.cs_14233.rescheduled_cd = uar_get_code_by_cki("CKI.CODEVALUE!12095")
	set code_values->cv.cs_14233.advice_response_cd = uar_get_code_by_cki("CKI.CODEVALUE!3843375")
	set code_values->cv.cs_14233.scheduled_cd = uar_get_code_by_cki("CKI.CODEVALUE!62494")
	set code_values->cv.cs_14233.shortlisted_cd = uar_get_code_by_cki("CKI.CODEVALUE!4533559")
	set code_values->cv.cs_14233.standby_cd = uar_get_code_by_cki("CKI.CODEVALUE!6165")
	set code_values->cv.cs_14233.unschedulable_cd = uar_get_code_by_cki("CKI.CODEVALUE!13834")
 
 
	call writeLog(build2("** Code Set 14281       ************************************"))
	set code_values->cv.cs_14281.canceled_cd = uar_get_code_by_cki("CKI.CODEVALUE!10483")
	set code_values->cv.cs_14281.completed_cd = uar_get_code_by_cki("CKI.CODEVALUE!10484")
	set code_values->cv.cs_14281.cvarrived_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160682021")
	set code_values->cv.cs_14281.cvcompleted_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160682023")
	set code_values->cv.cs_14281.cvedreview_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101288821")
	set code_values->cv.cs_14281.cvinprocess_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160682022")
	set code_values->cv.cs_14281.cvscheduled_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160682020")
	set code_values->cv.cs_14281.cvsigned_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160682026")
	set code_values->cv.cs_14281.cvunsigned_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160682025")
	set code_values->cv.cs_14281.cvverified_cd = uar_get_code_by_cki("CKI.CODEVALUE!2160682024")
	set code_values->cv.cs_14281.deleted_cd = uar_get_code_by_cki("CKI.CODEVALUE!45294")
	set code_values->cv.cs_14281.discontinued_cd = uar_get_code_by_cki("CKI.CODEVALUE!10485")
	set code_values->cv.cs_14281.inpathology_cd = uar_get_code_by_cki("CKI.CODEVALUE!10486")
	set code_values->cv.cs_14281.labcollected_cd = uar_get_code_by_cki("CKI.CODEVALUE!12587")
	set code_values->cv.cs_14281.labdeleted_cd = uar_get_code_by_cki("CKI.CODEVALUE!23680")
	set code_values->cv.cs_14281.labdispatch_cd = uar_get_code_by_cki("CKI.CODEVALUE!12588")
	set code_values->cv.cs_14281.labfinal_cd = uar_get_code_by_cki("CKI.CODEVALUE!47338")
	set code_values->cv.cs_14281.labinlab_cd = uar_get_code_by_cki("CKI.CODEVALUE!16922")
	set code_values->cv.cs_14281.labinprocess_cd = uar_get_code_by_cki("CKI.CODEVALUE!12589")
	set code_values->cv.cs_14281.labintransit_cd = uar_get_code_by_cki("CKI.CODEVALUE!2598968")
	set code_values->cv.cs_14281.labprelim_cd = uar_get_code_by_cki("CKI.CODEVALUE!47339")
	set code_values->cv.cs_14281.labresultdel_cd = uar_get_code_by_cki("CKI.CODEVALUE!23681")
	set code_values->cv.cs_14281.labscheduled_cd = uar_get_code_by_cki("CKI.CODEVALUE!12590")
	set code_values->cv.cs_14281.labstain_cd = uar_get_code_by_cki("CKI.CODEVALUE!47340")
	set code_values->cv.cs_14281.labsus_cd = uar_get_code_by_cki("CKI.CODEVALUE!47341")
	set code_values->cv.cs_14281.onhold_cd = uar_get_code_by_cki("CKI.CODEVALUE!11558")
	set code_values->cv.cs_14281.ordered_cd = uar_get_code_by_cki("CKI.CODEVALUE!10487")
	set code_values->cv.cs_14281.partialfill_cd = uar_get_code_by_cki("CKI.CODEVALUE!2768567")
	set code_values->cv.cs_14281.pendcollect_cd = uar_get_code_by_cki("CKI.CODEVALUE!388665")
	set code_values->cv.cs_14281.radcompleted_cd = uar_get_code_by_cki("CKI.CODEVALUE!11767")
	set code_values->cv.cs_14281.radordered_cd = uar_get_code_by_cki("CKI.CODEVALUE!16923")
	set code_values->cv.cs_14281.radremoved_cd = uar_get_code_by_cki("CKI.CODEVALUE!16924")
	set code_values->cv.cs_14281.radreplaced_cd = uar_get_code_by_cki("CKI.CODEVALUE!16925")
	set code_values->cv.cs_14281.radstarted_cd = uar_get_code_by_cki("CKI.CODEVALUE!11766")
	set code_values->cv.cs_14281.refill_cd = uar_get_code_by_cki("CKI.CODEVALUE!2768568")
	set code_values->cv.cs_14281.rxhistord_cd = uar_get_code_by_cki("CKI.CODEVALUE!2962270")
	set code_values->cv.cs_14281.rxhxincmplt_cd = uar_get_code_by_cki("CKI.CODEVALUE!3897952")
	set code_values->cv.cs_14281.rxonfile_cd = uar_get_code_by_cki("CKI.CODEVALUE!2767508")
	set code_values->cv.cs_14281.rxonhold_cd = uar_get_code_by_cki("CKI.CODEVALUE!2767507")
	set code_values->cv.cs_14281.transferout_cd = uar_get_code_by_cki("CKI.CODEVALUE!2759490")
 
	call writeLog(build2("** Code Set 16769       ************************************"))
	set code_values->cv.cs_16769.completed_cd = uar_get_code_by_cki("CKI.CODEVALUE!22093")
	set code_values->cv.cs_16769.discontinued_cd = uar_get_code_by_cki("CKI.CODEVALUE!22094")
	set code_values->cv.cs_16769.dropped_cd = uar_get_code_by_cki("CKI.CODEVALUE!4164346")
	set code_values->cv.cs_16769.excluded_cd = uar_get_code_by_cki("CKI.CODEVALUE!4100381161")
	set code_values->cv.cs_16769.future_cd = uar_get_code_by_cki("CKI.CODEVALUE!4100381162")
	set code_values->cv.cs_16769.future_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101285190")
	set code_values->cv.cs_16769.future_proposed_cd = uar_get_code_by_cki("CKI.CODEVALUE!4115475192")
	set code_values->cv.cs_16769.held_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109136228")
	set code_values->cv.cs_16769.initiated_cd = uar_get_code_by_cki("CKI.CODEVALUE!3235228")
	set code_values->cv.cs_16769.initiated_proposed_cd = uar_get_code_by_cki("CKI.CODEVALUE!4115475193")
	set code_values->cv.cs_16769.initiated_cd = uar_get_code_by_cki("CKI.CODEVALUE!4101285189")
	set code_values->cv.cs_16769.ordered_cd = uar_get_code_by_cki("CKI.CODEVALUE!22095")
	set code_values->cv.cs_16769.planned_cd = uar_get_code_by_cki("CKI.CODEVALUE!3235227")
	set code_values->cv.cs_16769.planned_proposed_cd = uar_get_code_by_cki("CKI.CODEVALUE!4115907535")
	set code_values->cv.cs_16769.proposed_cd = uar_get_code_by_cki("CKI.CODEVALUE!4106564865")
	set code_values->cv.cs_16769.skipped_cd = uar_get_code_by_cki("CKI.CODEVALUE!4109136229")
	set code_values->cv.cs_16769.started_cd = uar_get_code_by_cki("CKI.CODEVALUE!31915")
	set code_values->cv.cs_16769.suspended_cd = uar_get_code_by_cki("CKI.CODEVALUE!22096")
	set code_values->cv.cs_16769.void_cd = uar_get_code_by_cki("CKI.CODEVALUE!3235343")
 
	call writeLog(build2("** Code Set 19189       ************************************"))
	set code_values->cv.cs_19189.ambcaregrp_cd = uar_get_code_by_cki("CKI.CODEVALUE!4103650531")
	set code_values->cv.cs_19189.asgmtgrp_cd = uar_get_code_by_cki("CKI.CODEVALUE!2636931")
	set code_values->cv.cs_19189.careteam_cd = uar_get_code_by_cki("CKI.CODEVALUE!57143")
	set code_values->cv.cs_19189.ccadmin_cd = uar_get_code_by_cki("CKI.CODEVALUE!129424")
	set code_values->cv.cs_19189.cccsr_cd = uar_get_code_by_cki("CKI.CODEVALUE!129425")
	set code_values->cv.cs_19189.ccdba_cd = uar_get_code_by_cki("CKI.CODEVALUE!129427")
	set code_values->cv.cs_19189.cclpn_cd = uar_get_code_by_cki("CKI.CODEVALUE!430945")
	set code_values->cv.cs_19189.ccrn_cd = uar_get_code_by_cki("CKI.CODEVALUE!129426")
	set code_values->cv.cs_19189.dcpteam_cd = uar_get_code_by_cki("CKI.CODEVALUE!111133")
	set code_values->cv.cs_19189.department_cd = uar_get_code_by_cki("CKI.CODEVALUE!108331")
	set code_values->cv.cs_19189.himsusphys_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200098183")
	set code_values->cv.cs_19189.pkpda_cd = uar_get_code_by_cki("CKI.CODEVALUE!2961161")
	set code_values->cv.cs_19189.poolgrp_cd = uar_get_code_by_cki("CKI.CODEVALUE!2500015245")
	set code_values->cv.cs_19189.providerset_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201626343")
	set code_values->cv.cs_19189.referrer_cd = uar_get_code_by_cki("CKI.CODEVALUE!1435791909")
	set code_values->cv.cs_19189.scheduser_cd = uar_get_code_by_cki("CKI.CODEVALUE!723879859")
	set code_values->cv.cs_19189.service_cd = uar_get_code_by_cki("CKI.CODEVALUE!108368")
 
	call writeLog(build2("** Code Set 27360       ************************************"))
	set code_values->cv.cs_27360.lreltn 		= uar_get_code_by("MEANING",27360, "LRELTN"		)	;Lifetime Relationship
	set code_values->cv.cs_27360.providergrp 	= uar_get_code_by("MEANING",27360, "PROVIDERGRP")	;Provider Group
	set code_values->cv.cs_27360.service		= uar_get_code_by("MEANING",27360, "SERVICE"	)	;Medical Service
	set code_values->cv.cs_27360.vreltn			= uar_get_code_by("MEANING",27360, "VRELTN"		)	;Visit Relationship
	set code_values->cv.cs_27360.anc_asgmt		= uar_get_code_by("MEANING",27360, "ANC_ASGMT"	)	;Assignment (Ancillary)
	set code_values->cv.cs_27360.assignment		= uar_get_code_by("MEANING",27360, "ASSIGNMENT"	)	;Assignment
	set code_values->cv.cs_27360.custom			= uar_get_code_by("MEANING",27360, "CUSTOM"		)	;Custom
	set code_values->cv.cs_27360.location		= uar_get_code_by("MEANING",27360, "LOCATION"	)	;Location
	set code_values->cv.cs_27360.locationgrp	= uar_get_code_by("MEANING",27360, "LOCATIONGRP")	;Location Group
	set code_values->cv.cs_27360.query			= uar_get_code_by("MEANING",27360, "QUERY"		)	;Query
	set code_values->cv.cs_27360.careteam		= uar_get_code_by("MEANING",27360, "CARETEAM"	)	;CareTeam
	set code_values->cv.cs_27360.reltn			= uar_get_code_by("MEANING",27360, "RELTN"		)	;Relationship
	set code_values->cv.cs_27360.schedule		= uar_get_code_by("MEANING",27360, "SCHEDULE"	)	;Scheduled
 
	call writeLog(build2("** Code Set 28880       ************************************"))
	set code_values->cv.cs_28880.addended_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989567")
	set code_values->cv.cs_28880.approved_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989568")
	set code_values->cv.cs_28880.corrected_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989569")
	set code_values->cv.cs_28880.cosigned_cd = uar_get_code_by_cki("CKI.CODEVALUE!3130263")
	set code_values->cv.cs_28880.dictated_cd = uar_get_code_by_cki("CKI.CODEVALUE!3130264")
	set code_values->cv.cs_28880.modified_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989570")
	set code_values->cv.cs_28880.onhold_cd = uar_get_code_by_cki("CKI.CODEVALUE!2990252")
	set code_values->cv.cs_28880.proxied_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989571")
	set code_values->cv.cs_28880.rejected_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989572")
	set code_values->cv.cs_28880.rettores_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989573")
	set code_values->cv.cs_28880.transcribed_cd = uar_get_code_by_cki("CKI.CODEVALUE!2989574")
 
	call writeLog(build2("** Code Set 28881       ************************************"))
	set code_values->cv.cs_28881.security_cd		= uar_get_code_by("MEANING",28881, "SECURITY"	)	;SECURITY
	call writeLog(build2("** Code Set 29520	      ************************************"))
	set code_values->cv.cs_29520.vitalslink_cd	= uar_get_code_by("MEANING",29520, "VITALSLINK"	)	;VITALSLINK
	call writeLog(build2("** Code Set 254550      ************************************"))
	set code_values->cv.cs_254550.forward_cd = uar_get_code_by("MEANING",254550,"FORWARD")
	set code_values->cv.cs_254550.author_cd = uar_get_code_by("MEANING",254550,"AUTHOR")
	set code_values->cv.cs_254550.carboncopy_cd = uar_get_code_by("MEANING",254550,"CARBONCOPY")
	set code_values->cv.cs_254550.originator_cd = uar_get_code_by("MEANING",254550,"ORIGINATOR")
	set code_values->cv.cs_254550.responsiblec_cd = uar_get_code_by("MEANING",254550,"RESPONSIBLEC")
	set code_values->cv.cs_254550.referral_cd = uar_get_code_by("MEANING",254550,"REFERRAL")
	set code_values->cv.cs_254550.letters_cd = uar_get_code_by("MEANING",254550,"LETTERS")
	set code_values->cv.cs_254550.fax_modifier_cd = uar_get_code_by("MEANING",254550,"FAX_MODIFIER")
	set code_values->cv.cs_254550.mail_modif_cd = uar_get_code_by("MEANING",254550,"MAIL_MODIF")
	set code_values->cv.cs_254550.email_modif_cd = uar_get_code_by("MEANING",254550,"EMAIL_MODIF")
 
	call writeLog(build2("** Code Set 4000160      ************************************"))
	set code_values->cv.cs_4000160.confirmed_cd		= uar_get_code_by("MEANING",4000160, "CONFIRMED"	)	;CONFIRMED
 
	call writeLog(build2("** Code Set 4002773	      ************************************"))
	set code_values->cv.cs_4002773.accommchange_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201468567")
	set code_values->cv.cs_4002773.accommreqchg_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201482849")
	set code_values->cv.cs_4002773.adhocexclusn_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200803764")
	set code_values->cv.cs_4002773.bioenrstat_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201673672")
	set code_values->cv.cs_4002773.casestatchg_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201468489")
	set code_values->cv.cs_4002773.clindischrg_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200187346")
	set code_values->cv.cs_4002773.dischrg_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200798925")
	set code_values->cv.cs_4002773.enctypechg_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201495268")
	set code_values->cv.cs_4002773.finclasschg_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201482605")
	set code_values->cv.cs_4002773.haaccoffrchg_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201709420")
	set code_values->cv.cs_4002773.hiaccoffrchg_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201647438")
	set code_values->cv.cs_4002773.medsvcchg_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201827260")
	set code_values->cv.cs_4002773.outpatinbed_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200798924")
	set code_values->cv.cs_4002773.startinpat_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200187345")
	set code_values->cv.cs_4002773.startobs_cd = uar_get_code_by_cki("CKI.CODEVALUE!4200187344")
	set code_values->cv.cs_4002773.urgencychg_cd = uar_get_code_by_cki("CKI.CODEVALUE!4201482610")
 
	call writeLog(build2("** Code Set 4003273      ************************************"))
	set code_values->cv.cs_4003273.ERROR_cd			= uar_get_code_by("MEANING",4003273, "ERROR"	)
	set code_values->cv.cs_4003273.NO_TRANSACT_cd		= uar_get_code_by("MEANING",4003273, "NO_TRANSACT"	)
	set code_values->cv.cs_4003273.PARTIAL_SUCC_cd		= uar_get_code_by("MEANING",4003273, "PARTIAL_SUCC"	)
	set code_values->cv.cs_4003273.PENDING_cd			= uar_get_code_by("MEANING",4003273, "PENDING"	)
	set code_values->cv.cs_4003273.SUCCESS_cd			= uar_get_code_by("MEANING",4003273, "SUCCESS"	)
	set code_values->cv.cs_4003273.PROTECTED_cd		= uar_get_code_by("MEANING",4003273, "PROTECTED"	)
 
	call writeLog(build2("** Code Set 72          ************************************"))
	select into "nl:"
	from
		code_value cv1
	plan cv1
		where cv1.code_set		= 72
		and   cv1.active_ind	= 1
		and   cv1.display	in(
								  	"Administration Information",
								 	"Admission Note Physician",
									"Cardiovascular Surgery Consultation",
									"Discharge Summary",
									"ED Note Physician",
									"24 Hour pH Probe",
									"Colonoscopy",
									"Esophagogastroduodenoscopy EGD",
									"Bronchoscopy",
									"Operative Report - Hx",
									"History and Physical",
									"Echocardiogram Transesophageal",
									"Physician Order",
									"Procedure Notes",
									"Cardio Test or Study",
									"Special Procedure",
									"Cardiac Catheterization diagnostic",
									"Cardiology General Procedures",
									"Cardiac Cath Procedure",
									"History and Physical Update",
									"Cardiology Procedure Note",
									"Cardiothoracic Operative Note",
									"ENT Operative Note",
									"Gastroenterology Operative Note",
									"Gynecology Procedure Note",
									"Gynecology Operative Note",
									"Interventional Radiology Procedure Note",
									"Neurosurgery Operative Note",
									"Obstetrics Procedure Note",
									"Obstetrics Operative Note",
									"Ophthalmology Operative Note",
									"Orthopedic Procedure Note",
									"Orthopedic Operative Note",
									"Plastic Surgery Operative Note",
									"Podiatry Operative Note",
									"Surgery Operative Note",
									"Urology Operative Note",
									"Vascular Surgery Operative Note",
									"Cardiology Operative Note",
									"Gastroenterology Op Note - Brief",
									"Oral & Maxillofacial Operative Note",
									"Pediatric Procedure Note",
									"Report of Death",
									"Procedure Note",
									"Progress Note"
							  )
	order by
		 cv1.display
		,cv1.begin_effective_dt_tm
		,cv1.code_value
	detail
		case (cv1.display)
of  "Administration Information":			code_values->cv.cs_72.admin_info_cd  		= cv1.code_value
of "Admission Note Physician": code_values->cv.cs_72.admission_note_physician    = cv1.code_value
of "Cardiovascular Surgery Consultation": code_values->cv.cs_72.cardiovascular_surgery_consultation    = cv1.code_value
of "Discharge Summary": code_values->cv.cs_72.discharge_summary    = cv1.code_value
of "ED Note Physician": code_values->cv.cs_72.ed_note_physician    = cv1.code_value
of "24 Hour pH Probe": code_values->cv.cs_72.24_hour_ph_probe    = cv1.code_value
of "Colonoscopy": code_values->cv.cs_72.colonoscopy    = cv1.code_value
of "Esophagogastroduodenoscopy EGD": code_values->cv.cs_72.esophagogastroduodenoscopy_egd    = cv1.code_value
of "Bronchoscopy": code_values->cv.cs_72.bronchoscopy    = cv1.code_value
of "Operative Report - Hx": code_values->cv.cs_72.operative_report_hx    = cv1.code_value
of "History and Physical": code_values->cv.cs_72.history_and_physical    = cv1.code_value
of "Echocardiogram Transesophageal": code_values->cv.cs_72.echocardiogram_transesophageal    = cv1.code_value
of "Physician Order": code_values->cv.cs_72.physician_order    = cv1.code_value
of "Procedure Notes": code_values->cv.cs_72.procedure_notes    = cv1.code_value
of "Cardio Test or Study": code_values->cv.cs_72.cardio_test_or_study    = cv1.code_value
of "Special Procedure": code_values->cv.cs_72.special_procedure    = cv1.code_value
of "Cardiac Catheterization diagnostic": code_values->cv.cs_72.cardiac_catheterization_diagnostic    = cv1.code_value
of "Cardiology General Procedures": code_values->cv.cs_72.cardiology_general_procedures    = cv1.code_value
of "Cardiac Cath Procedure": code_values->cv.cs_72.cardiac_cath_procedure    = cv1.code_value
of "History and Physical Update": code_values->cv.cs_72.history_and_physical_update    = cv1.code_value
of "Cardiology Procedure Note": code_values->cv.cs_72.cardiology_procedure_note    = cv1.code_value
of "Cardiothoracic Operative Note": code_values->cv.cs_72.cardiothoracic_operative_note    = cv1.code_value
of "ENT Operative Note": code_values->cv.cs_72.ent_operative_note    = cv1.code_value
of "Gastroenterology Operative Note": code_values->cv.cs_72.gastroenterology_operative_note    = cv1.code_value
of "Gynecology Procedure Note": code_values->cv.cs_72.gynecology_procedure_note    = cv1.code_value
of "Gynecology Operative Note": code_values->cv.cs_72.gynecology_operative_note    = cv1.code_value
of "Interventional Radiology Procedure Note": code_values->cv.cs_72.interventional_radiology_procedure_note    = cv1.code_value
of "Neurosurgery Operative Note": code_values->cv.cs_72.neurosurgery_operative_note    = cv1.code_value
of "Obstetrics Procedure Note": code_values->cv.cs_72.obstetrics_procedure_note    = cv1.code_value
of "Obstetrics Operative Note": code_values->cv.cs_72.obstetrics_operative_note    = cv1.code_value
of "Ophthalmology Operative Note": code_values->cv.cs_72.ophthalmology_operative_note    = cv1.code_value
of "Orthopedic Procedure Note": code_values->cv.cs_72.orthopedic_procedure_note    = cv1.code_value
of "Orthopedic Operative Note": code_values->cv.cs_72.orthopedic_operative_note    = cv1.code_value
of "Plastic Surgery Operative Note": code_values->cv.cs_72.plastic_surgery_operative_note    = cv1.code_value
of "Podiatry Operative Note": code_values->cv.cs_72.podiatry_operative_note    = cv1.code_value
of "Surgery Operative Note": code_values->cv.cs_72.surgery_operative_note    = cv1.code_value
of "Urology Operative Note": code_values->cv.cs_72.urology_operative_note    = cv1.code_value
of "Vascular Surgery Operative Note": code_values->cv.cs_72.vascular_surgery_operative_note    = cv1.code_value
of "Cardiology Operative Note": code_values->cv.cs_72.cardiology_operative_note    = cv1.code_value
of "Gastroenterology Op Note - Brief": code_values->cv.cs_72.gastroenterology_op_note_brief    = cv1.code_value
of "Oral & Maxillofacial Operative Note": code_values->cv.cs_72.oral_maxillofacial_operative_note    = cv1.code_value
of "Pediatric Procedure Note": code_values->cv.cs_72.pediatric_procedure_note    = cv1.code_value
of "Report of Death": code_values->cv.cs_72.report_of_death    = cv1.code_value
of "Procedure Note": code_values->cv.cs_72.procedure_note    = cv1.code_value
of "Progress Note": code_values->cv.cs_72.progress_note    = cv1.code_value
		endcase
	with nocounter
	call writeLog(build2("** Code Set 93          ************************************"))
	select into "nl:"
	from
		code_value cv1
	plan cv1
		where cv1.code_set		= 93
		and   cv1.active_ind	= 1
		and   cv1.display	in(
								 "Intake"
								,"Output"
							  )
	order by
			 cv1.display
			,cv1.updt_dt_tm desc
	head cv1.display
		case (cv1.display)
			of  "Intake":	code_values->cv.cs_93.intake_cd = cv1.code_value
			of  "Output": 	code_values->cv.cs_93.output_cd = cv1.code_value
		endcase
	with nocounter
	call writeLog(build2("* FINISH Set Code Values ***********************************"))
end	;subroutine set_codevalues
 
declare    set_maxvarlen(SetValues=i4) = i4
subroutine set_maxvarlen(SetValues)
	if (SetValues > 0)
		set modify maxvarlen value(SetValues)
	else
		call writeLog(build2("FAILED set modify maxvarlen = ",cnvtstring(SetValues)))
	endif
	call writeLog(build2("set modify maxvarlen = ",cnvtstring(SetValues)))
	return (SetValues)
end ;subroutine set_maxvarlen(SetValues)
 
declare    echo2(str=vc) = null
subroutine echo2(str)
	if ((validate(debug_ind) = 1))
		if (debug_ind != 0)
			call echo(str)
		endif
	endif
end ;subroutine echo2(str)
 
declare    echorecord2(str=vc) = null
subroutine echorecord2(str)
	if ((validate(debug_ind) = 1) and (debug_ind = 1))
		call echorecord(value(str))
	endif
end ;subroutine echorecord2(str)
 
;*************************************************************************
;* Setup the log subroutines
;*************************************************************************
subroutine startLog(str)			;subroutine to start a log file in cclscratch. must pass the filename to sub
	if (program_log->produce_log = 0)
		set frec->file_name = str		;set the filename to the string passed
		set frec->file_buf = "w"   		;case sensitive must be lowercase, opens a new file
		set stat = cclio("OPEN",frec)	;call CCLIO() to open the file in the frec record structure
		call echo(build2("startLog(",str,")"))
	endif
end									;end startLog subroutine
 
declare    LogActivity(str=vc) = null
subroutine LogActivity(str)
	call writeLog(build2("LogActivity(",str,")"))
	set disp_line = trim(str,3)
	if ((program_log->log_cnt > 0) and (disp_line = "_END"))
		set program_log->log_qual[program_log->log_cnt].end_dt_tm = cnvtdatetime(curdate,curtime3)
		set program_log->log_qual[program_log->log_cnt].hundseconds_diff = datetimediff(
				 program_log->log_qual[program_log->log_cnt].end_dt_tm
				,program_log->log_qual[program_log->log_cnt].start_dt_tm
				,6)
	else
		if (program_log->log_cnt > 1)
			set program_log->log_qual[program_log->log_cnt].end_dt_tm = cnvtdatetime(curdate,curtime3)
			set program_log->log_qual[program_log->log_cnt].hundseconds_diff = datetimediff(
				 program_log->log_qual[program_log->log_cnt].end_dt_tm
				,program_log->log_qual[program_log->log_cnt].start_dt_tm
				,6)
		endif
		set program_log->log_cnt = (program_log->log_cnt + 1)
		set stat = alterlist(program_log->log_qual,program_log->log_cnt)
		set program_log->log_qual[program_log->log_cnt].log_dt_tm = cnvtdatetime(curdate,curtime3)
		set program_log->log_qual[program_log->log_cnt].start_dt_tm = cnvtdatetime(curdate,curtime3)
		set program_log->log_qual[program_log->log_cnt].log_display = disp_line
	endif
end								;end writeLog subroutine
 
subroutine writeLogs(str)			;subroutine to silently add a line to log with the date and time and the string passed
									;line below builds a string to add to the log file
	set disp_line = build2("[",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;q"),"]",trim(str,3),char(13),char(10))
	set disp_line = substring(1,131,disp_line)
	if (program_log->produce_log = 0)
		set frec->file_buf = disp_line	;sends the string to the file buffer
		set stat = cclio("WRITE", frec)	;calls CCLIO to dump the buffer to the file
	endif
end 								;end writeLog subroutine
 
subroutine writeLog(str)			;subroutine to add a line to log with the date and time and the string passed
									;line below builds a string to add to the log file
	set disp_line = build2("[",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;q"),"]",trim(str,3),char(13),char(10))
	set frec->file_buf = disp_line	;sends the string to the file buffer
	call echo2(disp_line)			;echo output to the command line
	if (program_log->produce_log = 0)
		set stat = cclio("WRITE", frec)	;calls CCLIO to dump the buffer to the file
	endif
end 								;end writeLog subroutine
 
subroutine closeLog(str)   			;subroutine to close the log file, currently the passed in string does nothing
	if (program_log->produce_log = 0)
		set stat = cclio("CLOSE",frec)	;call CCLIO to close the file
		call echo(build2("closeLog(",str,")"))
	endif
end
 
subroutine addEmailLog(str)			;subroutine to add email to
	if (program_log->produce_log = 0)
		if (str  > " ")					;make sure string passed is not empty
			set stat = alterlist(program_log->email.qual,(size(program_log->email.qual,5) + 1))
			set program_log->email.qual[size(program_log->email.qual,5)].email_address = str
			call writeLog(build2("addEmailLog(",str,")"))
		endif							;endif (str  > " ")
	endif
end
 
declare    addAttachment(str=vc,file=vc) = null
subroutine addAttachment(str,file)			;subroutine to add attachment to zip
	if (program_log->produce_audit = 0)
		if (file  > " ")					;make sure string passed is not empty
			set program_log->files.attachments_cnt = (program_log->files.attachments_cnt + 1)
			set stat = alterlist(program_log->files.attachments,program_log->files.attachments_cnt)
			set program_log->files.attachments[program_log->files.attachments_cnt].file_path = str
			set program_log->files.attachments[program_log->files.attachments_cnt].filename = file
			call writeLog(build2("addAttachment(",str,file,")"))
		endif							;endif (str  > " ")
	endif
end
 
;*************************************************************************
;* Setup the audit subroutines
;*************************************************************************
subroutine startAudit(str)			;subroutine to start a audit file in cclscratch. must pass the filename to sub
	if (program_log->produce_audit = 0)
		set freca->file_name = str		;set the filename to the string passed
		set freca->file_buf = "w"		;case sensitive must be lowercase, opens a new file
		set stat = cclio("OPEN",freca)	;call CCLIO() to open the file in the frec record structure
		call echo(build2("startAudit(",str,")"))
	endif
end									;end startAudit subroutine
 
subroutine writeAudit(str)			;subroutine to add a line to audit with the date and time and the string passed
									;line below builds a string to add to the log file
	if (program_log->produce_audit = 0)
		set disp_line = concat(trim(str,3),char(13),char(10))
		set freca->file_buf = disp_line	;sends the string to the file buffer
		set stat = cclio("WRITE", freca);calls CCLIO to dump the buffer to the file
	endif
end 								;end startAudit subroutine
 
subroutine closeAudit(str)   		;subroutine to close the audit file, currently the passed in string does nothing
	if (program_log->produce_audit = 0)
		set stat = cclio("CLOSE",freca)	;call CCLIO to close the file
		call echo(build2("closeAudit(",str,")"))
	endif
end
 
 
;*************************************************************************
;* Build the email_list variable for emailing
;*************************************************************************
declare	   BuildEmailList(null) = null
subroutine BuildEmailList(null)
	if (program_log->produce_log = 0)
		call writeLog(build2("* START Email List Build ************************************"))
		call writeLog(build2("** program_log->email.qual size  = ",size(program_log->email.qual,5)))
			if (size(program_log->email.qual,5) > 0)																;make sure email list is populated
				for (i=1 to size(program_log->email.qual,5))
					if (i=1)								;if this is the first email in the list, add it
						set email_list = trim(program_log->email.qual[i].email_address)	;add email address to list
					else												;if >1st in the list, add with space
						set email_list = build2(email_list," ",trim(program_log->email.qual[i].email_address));add to email list with space between
					endif	;endif (i=1)
				endfor	;end loop  through added emails
			endif
		call writeLog(build2("* END   Email List Build ************************************"))
	endif
end ;subroutine BuildEmailList(null)
 
 
;*************************************************************************
;* Email the zipped log file
;*************************************************************************
declare	   emailLog(null) = null
subroutine emailLog(null)
	if (program_log->produce_log = 0)
		if (program_log->files.filename_zip > " ")
			if (email_list > " ")
				/*
				set dclcom = build2("echo ",trim(program_log->files.filename_log)," | mailx -a "
								,trim(program_log->files.filename_zip)," -s "
								;,trim(program_log->files.filename_log)," -s ", uncomment and comment above to send just log
								,"'",trim(program_log->email.subject)," '"
								," ",email_list)
 
				set dclcom = build2("echo ",trim(program_log->files.filename_log)," | mailx -a "
								,trim(program_log->files.filename_zip)," -s ",
								;,trim(program_log->files.filename_log)," -s ", uncomment and comment above to send just log
								"'Emailing Log For: ",format(sysdate,"mm/dd/yyyy;;q")," ",
								trim(curdomain)," ",curprog," '"
								," ",email_list)
				*/
				set dclcom = build2("echo ",trim(program_log->files.filename_log)," | mailx -a "
								,trim(program_log->files.filename_zip)," -s ",
								;,trim(program_log->files.filename_log)," -s ", uncomment and comment above to send just log
								"'",trim(program_log->email.subject),"'"
								," ",email_list)
				set dclstat = 0
				call echo2(build2("sending log file dclcom = ",dclcom))
				call dcl(dclcom, size(trim(dclcom)), dclstat)
			else
				call echo2("email_list empty, skipping")
			endif
		endif
	endif
end ;subroutine emailLog(null)
;*************************************************************************
;* Zip the log file for distribution
;*************************************************************************
declare	   zipLog(null) = null
subroutine zipLog(null)
	if (program_log->produce_log = 0)
		set program_log->files.filename_zip = replace(
												 program_log->files.filename_log
												,".log"
												,".zip"
												,0
												)
		call echo2(build2("program_log->files.filename_zip = ",program_log->files.filename_zip))
		set dclcom = build2("zip -j ",trim(program_log->files.filename_zip)," ",trim(program_log->files.filename_log))
		set dclstat = 0
		call echo2(build2("zip log file dclcom = ",dclcom))
		call dcl(dclcom, size(trim(dclcom)), dclstat)
		call echo2(build2("dclstat = ",dclstat))
	endif
end ;subroutine zipLog(null)
 
;*************************************************************************
;* Zip the Audit file for distribution
;*************************************************************************
declare	   zipAudit(null) = null
subroutine zipAudit(null)
	if (program_log->produce_audit = 0)
		set program_log->files.filename_audit_zip = replace(
												 program_log->files.filename_audit
												,".csv"
												,".zip"
												,0
												)
		call echo2(build2("program_log->files.filename_audit_zip = ",program_log->files.filename_audit_zip))
		set dclcom = build2("zip -j ",trim(program_log->files.filename_audit_zip)," ",trim(program_log->files.filename_audit))
		set dclstat = 0
		call echo2(build2("zip log file dclcom = ",dclcom))
		call dcl(dclcom, size(trim(dclcom)), dclstat)
		call echo2(build2("dclstat = ",dclstat))
	endif
end ;subroutine zipAudit(null)
 
 
 
;*************************************************************************
;* Attach files to zip
;*************************************************************************
declare	   zipAttachment(null) = null
subroutine zipAttachment(null)
	if (program_log->produce_audit = 0)
		if (program_log->files.attachments_cnt > 0)
			call echo2(build2("program_log->files.filename_audit_zip = ",program_log->files.filename_audit_zip))
			for (i=1 to program_log->files.attachments_cnt)
				set dclcom = build2("zip -j ",trim(program_log->files.filename_audit_zip)
							," "
							,trim(program_log->files.attachments[i].file_path)
							,trim(program_log->files.attachments[i].filename))
				set dclstat = 0
				call echo2(build2("zip attachment file dclcom = ",dclcom))
				call dcl(dclcom, size(trim(dclcom)), dclstat)
				call echo2(build2("dclstat = ",dclstat))
			endfor
		endif
	endif
end ;subroutine zipAttachment(null)
 
;*************************************************************************
;* clean up log file(s) for distribution
;*************************************************************************
declare	   cleanLog(null) = null
subroutine cleanLog(null)
	if (program_log->produce_log = 0)
		if (program_log->files.filename_zip > " " )
			if (email_list > " ")
				set dclcom = build2("rm -f ",trim(program_log->files.filename_zip))
				set dclstat = 0
				call echo2(build2("remove log file dclcom = ",dclcom))
				call dcl(dclcom, size(trim(dclcom)), dclstat)
				call echo2(build2("dclstat = ",dclstat))
			endif
		endif
 
		if (program_log->files.filename_log > " ")
			set dclcom = build2("rm -f ",trim(program_log->files.filename_log))
			set dclstat = 0
			call echo2(build2("zip log file dclcom = ",dclcom))
			call dcl(dclcom, size(trim(dclcom)), dclstat)
			call echo2(build2("dclstat = ",dclstat))
		endif
	endif
end ;subroutine cleanLog(null)
 
;*************************************************************************
;* clean up log file(s) for distribution
;*************************************************************************
declare	   cleanAudit(null) = null
subroutine cleanAudit(null)
	if (program_log->produce_audit = 0)
		if (program_log->files.filename_audit > " ")
			set dclcom = build2("rm -f ",trim(program_log->files.filename_audit))
			set dclstat = 0
			call echo2(build2("remove audit file dclcom = ",dclcom))
			call dcl(dclcom, size(trim(dclcom)), dclstat)
			call echo2(build2("dclstat = ",dclstat))
		endif
	endif
end ;subroutine cleanLog(null)
 
;*************************************************************************
;* clean up log file(s) for distribution
;*************************************************************************
declare	   displayLog(null) = null
subroutine displayLog(null)
	if ((program_log->display_on_exit = 1) and (program_log->produce_log = 0))
		free define rtl2
		define rtl2 is value(program_log->files.filename_log)
 
		select into $OUTDEV
			r.line
		from
			rtl2t r
		plan r
		with nocounter,maxcol=32000,separator = " ",format
	endif
end ;subroutine displayLog(null)
 
;*************************************************************************
;* Setup the exit subroutines
;*************************************************************************
declare    exitScript(null) = null
subroutine exitScript(null)
	call BuildEmailList(null)
	call closeLog(program_log->files.filename_log)
	call closeAudit(program_log->files.filename_audit)
	call displayLog(null)
	call zipLog(null)
	call zipAudit(null)
	call zipAttachment(null)
	call emailLog(null)
	call cleanAudit(null)
	call cleanLog(null)
	call LogActivity("_END")
	call echo2(build2("exiting script ",curprog))
end	;subroutine exitScript(null)
 
/*********************************************
** Request Structure For GOLD MASTER INSERT **
*********************************************/
record atg_dminfo_reqi
(
    1 allow_partial_ind = i2
    1 info_domaini = i2
    1 info_namei = i2
    1 info_datei = i2
    1 info_daten = i2
    1 info_chari = i2
    1 info_charn = i2
    1 info_numberi = i2
    1 info_numbern = i2
    1 info_long_idi = i2
    1 qual[*]
      2 info_domain = c80
      2 info_name = c255
      2 info_date = dq8
      2 info_char = c255
      2 info_number = f8
      2 info_long_id = f8
) with protect
 
/*********************************************
** Request Structure For GOLD MASTER UPDATE **
*********************************************/
record atg_dminfo_reqw
(
    1 allow_partial_ind = i2
    1 force_updt_ind = i2
    ;where_clause indicator fields
    1 info_domainw = i2
    1 info_namew = i2
    1 info_datew = i2
    1 info_charw = i2
    1 info_numberw = i2
    1 info_long_idw = i2
    1 updt_applctxw = i2
    1 updt_dt_tmw = i2
    1 updt_cntw = i2
    1 updt_idw = i2
    1 updt_taskw = i2
    1 info_domainf = i2
    1 info_namef = i2
    1 info_datef = i2
    1 info_charf = i2
    1 info_numberf = i2
    1 info_long_idf = i2
    1 updt_cntf = i2
    1 qual[*]
      2 info_domain = c80
      2 info_name = c255
      2 info_date = dq8
      2 info_char = c255
      2 info_number = f8
      2 info_long_id = f8
      2 updt_applctx = i4
      2 updt_dt_tm = dq8
      2 updt_cnt = i4
      2 updt_id = f8
      2 updt_task = i4
) with protect
 
/*********************************************
** Request Structure For GOLD MASTER DELETE **
*********************************************/
record atg_dminfo_reqd
(
 1 allow_partial_ind = i2
 ;where_clause indicator fields
 1 info_domainw = i2
 1 info_namew = i2
 1 qual[*]
   2 info_domain = c80
   2 info_name = c255
) with protect
 
 
/*********************************************
** Reply Structure For GOLD MASTER SCRIPTS  **
*********************************************/
record atg_dminfo_rep
(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
    2 info_domain = c80
    2 info_name = c255
%i cclsource:status_block.inc
) with protect
 
/**********************************************************
** Function GET_DMINFO_NUMBER()                          **
** ----------------------------                          **
** Returns the INFO_NUMBER for a given DOMAIN/NAME key.  **
** Parameters are for fields INFO_DOMAIN & INFO_NAME.    **
**********************************************************/
declare    get_dminfo_number(sdomain, sname) = f8
subroutine get_dminfo_number(sdomain, sname)
  declare datgdminfovalue 	= f8 with protect, noconstant(0.0)
 
  select into "nl"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  detail
    datgdminfovalue = di.info_number
  with nocounter
 
  return (datgdminfovalue)
end
 
/**********************************************************
** Function GET_DMINFO_CHAR()                            **
** ----------------------------                          **
** Returns the INFO_CHAR for a given DOMAIN/NAME key.    **
** Parameters are for fields INFO_DOMAIN & INFO_NAME.    **
**********************************************************/
declare    get_dminfo_char(sdomain, sname) = c255
subroutine get_dminfo_char(sdomain, sname)
  declare satgdminfovalue 	= c255 with protect, noconstant("")
 
  select into "nl"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  detail
    satgdminfovalue = di.info_char
  with nocounter
 
  return (satgdminfovalue)
end
 
/**********************************************************
** Function GET_DMINFO_DATE()                            **
** ----------------------------                          **
** Returns the INFO_DATE for a given DOMAIN/NAME key.    **
** Parameters are for fields INFO_DOMAIN & INFO_NAME.    **
**********************************************************/
declare    get_dminfo_date(sdomain, sname) = dq8
subroutine get_dminfo_date(sdomain, sname)
  declare dtatgdminfovalue 	= dq8 with protect, noconstant
 
  select into "nl"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  detail
    dtatgdminfovalue = cnvtdatetime(di.info_date)
  with nocounter
 
  return (dtatgdminfovalue)
end
 
/**********************************************************
** Function GET_DMINFO_LONGID()                          **
** ----------------------------                          **
** Returns the INFO_LONG_ID for a given DOMAIN/NAME key. **
** Parameters are for fields INFO_DOMAIN & INFO_NAME.    **
**********************************************************/
declare    get_dminfo_longid(sdomain, sname) = f8
subroutine get_dminfo_longid(sdomain, sname)
  declare datgdminfovalue 	= f8 with protect, noconstant(0.0)
 
  select into "nl"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  detail
    datgdminfovalue = di.info_long_id
  with nocounter
 
  return (datgdminfovalue)
end
 
/**********************************************************
** SET ROUTINE SET_DMINFO_NUMBER()                       **
** ----------------------------                          **
** SETs the INFO_NUMBER for a given DOMAIN/NAME key.     **
** Parameters are for fields INFO_DOMAIN & INFO_NAME     **
** And Value.  This routine will call the GOLD MASTER.   **
**********************************************************/
subroutine set_dminfo_number(sdomain, sname, dvalue)
 
  call clear_dminfo(null)
 
  select into "nl:"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  with nocounter
 
  if (curqual = 0)
    set stat = alterlist(atg_dminfo_reqi->qual, 1)
    set atg_dminfo_reqi->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqi->qual[1]->info_name   	= sname
    set atg_dminfo_reqi->qual[1]->info_number 	= dvalue
    set atg_dminfo_reqi->info_domaini		= 1
    set atg_dminfo_reqi->info_namei 		= 1
    set atg_dminfo_reqi->info_numberi		= 1
    execute gm_i_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQI"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  else
    set stat = alterlist(atg_dminfo_reqw->qual, 1)
    set atg_dminfo_reqw->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqw->qual[1]->info_name   	= sname
    set atg_dminfo_reqw->qual[1]->info_number 	= dvalue
    set atg_dminfo_reqw->info_domainw		= 1
    set atg_dminfo_reqw->info_namew 		= 1
    set atg_dminfo_reqw->info_numberf		= 1
    set atg_dminfo_reqw->force_updt_ind		= 1
    execute gm_u_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQW"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  endif
 
  if (reqinfo->commit_ind = 1)
    commit
  endif
end
 
 
/**********************************************************
** SET ROUTINE SET_DMINFO_DATE()                         **
** ----------------------------                          **
** SETs the INFO_DATE for a given DOMAIN/NAME key.       **
** Parameters are for fields INFO_DOMAIN & INFO_NAME     **
** And Value.  This routine will call the GOLD MASTER.   **
**********************************************************/
subroutine set_dminfo_date(sdomain, sname, dtvalue)
 
  call clear_dminfo(null)
 
  select into "nl:"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  with nocounter
 
 
  if (curqual = 0)
    set stat = alterlist(atg_dminfo_reqi->qual, 1)
    set atg_dminfo_reqi->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqi->qual[1]->info_name   	= sname
    set atg_dminfo_reqi->qual[1]->info_date 	= cnvtdatetime(dtvalue)
    set atg_dminfo_reqi->info_domaini		= 1
    set atg_dminfo_reqi->info_namei 		= 1
    set atg_dminfo_reqi->info_datei		= 1
    execute gm_i_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQI"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  else
    set stat = alterlist(atg_dminfo_reqw->qual, 1)
    set atg_dminfo_reqw->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqw->qual[1]->info_name   	= sname
    set atg_dminfo_reqw->qual[1]->info_date 	= cnvtdatetime(dtvalue)
    set atg_dminfo_reqw->info_domainw		= 1
    set atg_dminfo_reqw->info_namew 		= 1
    set atg_dminfo_reqw->info_datef		= 1
    set atg_dminfo_reqw->force_updt_ind		= 1
    execute gm_u_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQW"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  endif
 
  if (reqinfo->commit_ind = 1)
    commit
  endif
end
 
/**********************************************************
** SET ROUTINE SET_DMINFO_CHAR()                         **
** ----------------------------                          **
** SETs the INFO_CHAR for a given DOMAIN/NAME key.       **
** Parameters are for fields INFO_DOMAIN & INFO_NAME     **
** And Value.  This routine will call the GOLD MASTER.   **
**********************************************************/
subroutine set_dminfo_char(sdomain, sname, svalue)
 
  call clear_dminfo(null)
 
  select into "nl:"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  with nocounter
 
 
  if (curqual = 0)
    set stat = alterlist(atg_dminfo_reqi->qual, 1)
    set atg_dminfo_reqi->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqi->qual[1]->info_name   	= sname
    set atg_dminfo_reqi->qual[1]->info_char 	= svalue
    set atg_dminfo_reqi->info_domaini		= 1
    set atg_dminfo_reqi->info_namei 		= 1
    set atg_dminfo_reqi->info_chari		= 1
    execute gm_i_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQI"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  else
    set stat = alterlist(atg_dminfo_reqw->qual, 1)
    set atg_dminfo_reqw->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqw->qual[1]->info_name   	= sname
    set atg_dminfo_reqw->qual[1]->info_char 	= svalue
    set atg_dminfo_reqw->info_domainw		= 1
    set atg_dminfo_reqw->info_namew 		= 1
    set atg_dminfo_reqw->info_charf		= 1
    set atg_dminfo_reqw->force_updt_ind		= 1
    execute gm_u_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQW"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  endif
 
  if (reqinfo->commit_ind = 1)
    commit
  endif
end
 
/**********************************************************
** SET ROUTINE SET_DMINFO_LONGID()                       **
** ----------------------------                          **
** SETs the INFO_LONG_ID for a given DOMAIN/NAME key.    **
** Parameters are for fields INFO_DOMAIN & INFO_NAME     **
** And Value.  This routine will call the GOLD MASTER.   **
**********************************************************/
subroutine set_dminfo_longid(sdomain, sname, dvalue)
 
  call clear_dminfo(null)
 
  select into "nl:"
  from dm_info di
  plan di
  where di.info_domain = sdomain
    and di.info_name   = sname
  with nocounter
 
 
  if (curqual = 0)
    set stat = alterlist(atg_dminfo_reqi->qual, 1)
    set atg_dminfo_reqi->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqi->qual[1]->info_name   	= sname
    set atg_dminfo_reqi->qual[1]->info_long_id 	= dvalue
    set atg_dminfo_reqi->info_domaini		= 1
    set atg_dminfo_reqi->info_namei 		= 1
    set atg_dminfo_reqi->info_long_idi		= 1
    execute gm_i_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQI"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  else
    set stat = alterlist(atg_dminfo_reqw->qual, 1)
    set atg_dminfo_reqw->qual[1]->info_domain 	= sdomain
    set atg_dminfo_reqw->qual[1]->info_name   	= sname
    set atg_dminfo_reqw->qual[1]->info_long_id 	= dvalue
    set atg_dminfo_reqw->info_domainw		= 1
    set atg_dminfo_reqw->info_namew 		= 1
    set atg_dminfo_reqw->info_long_idf		= 1
    set atg_dminfo_reqw->force_updt_ind		= 1
    execute gm_u_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQW"),
    				  replace("REPLY", "ATG_DMINFO_REP")
  endif
 
  if (reqinfo->commit_ind = 1)
    commit
  endif
end
 
/**********************************************************
** REMOVE Routine REMOVE_DMINFO()                        **
** ----------------------------                          **
** This routine will delete a given DM_INFO row based on **
** the INFO_DOMAIN & INFO_NAME.                          **
**********************************************************/
subroutine remove_dminfo(sdomain, sname)
  call clear_dminfo(null)
 
  set stat = alterlist(atg_dminfo_reqd->qual, 1)
  set atg_dminfo_reqd->qual[1]->info_domain 	= sdomain
  set atg_dminfo_reqd->qual[1]->info_name   	= sname
  set atg_dminfo_reqd->info_domainw		= 1
  set atg_dminfo_reqd->info_namew 		= 1
  execute gm_d_dm_info2388 with replace("REQUEST","ATG_DMINFO_REQD"),
				replace("REPLY", "ATG_DMINFO_REP")
  if (reqinfo->commit_ind = 1)
    commit
  endif
end
 
/**********************************************************
** CLEAR Routine CLEAR_DMINFO()                        **
** ----------------------------                          **
** This is a PRIVATE ROUTINE and should NOT be called   **
** directly by your program. It is only to be called by **
** the functions above.                                 **
**********************************************************/
subroutine clear_dminfo(null)
  if (currev = 8)
    ;initrec only exists in rev 8.x
    set stat = initrec(atg_dminfo_reqi)
    set stat = initrec(atg_dminfo_reqw)
    set stat = initrec(atg_dminfo_reqd)
  else
    ;insert
    set stat = alterlist(atg_dminfo_reqi->qual, 0)
    set atg_dminfo_reqi->allow_partial_ind 	= 0
    set atg_dminfo_reqi->info_domaini 		= 0
    set atg_dminfo_reqi->info_namei 		= 0
    set atg_dminfo_reqi->info_datei 		= 0
    set atg_dminfo_reqi->info_daten 		= 0
    set atg_dminfo_reqi->info_chari 		= 0
    set atg_dminfo_reqi->info_charn 		= 0
    set atg_dminfo_reqi->info_numberi 		= 0
    set atg_dminfo_reqi->info_numbern 		= 0
    set atg_dminfo_reqi->info_long_idi 		= 0
 
    ;update
    set stat = alterlist(atg_dminfo_reqw->qual, 0)
    set atg_dminfo_reqw->allow_partial_ind 	= 0
    set atg_dminfo_reqw->force_updt_ind 	= 0
    set atg_dminfo_reqw->info_domainw 		= 0
    set atg_dminfo_reqw->info_namew 		= 0
    set atg_dminfo_reqw->info_datew 		= 0
    set atg_dminfo_reqw->info_charw 		= 0
    set atg_dminfo_reqw->info_numberw 		= 0
    set atg_dminfo_reqw->info_long_idw 		= 0
    set atg_dminfo_reqw->updt_applctxw 		= 0
    set atg_dminfo_reqw->updt_dt_tmw 		= 0
    set atg_dminfo_reqw->updt_cntw 		= 0
    set atg_dminfo_reqw->updt_idw 		= 0
    set atg_dminfo_reqw->updt_taskw 		= 0
    set atg_dminfo_reqw->info_domainf 		= 0
    set atg_dminfo_reqw->info_namef 		= 0
    set atg_dminfo_reqw->info_datef 		= 0
    set atg_dminfo_reqw->info_charf 		= 0
    set atg_dminfo_reqw->info_numberf 		= 0
    set atg_dminfo_reqw->info_long_idf 		= 0
    set atg_dminfo_reqw->updt_cntf 		= 0
 
    ;delete
    set stat = alterlist(atg_dminfo_reqd->qual, 0)
    set atg_dminfo_reqd->allow_partial_ind 	= 0
    set atg_dminfo_reqd->info_domainw 		= 0
    set atg_dminfo_reqd->info_namew 		= 0
 
  endif
end
 
declare AddLocationList(cdfString=vc, displayString=vc)=f8
subroutine AddLocationList(cdfString, displayString)
	call writeLog(build2("**** START AddLocationList ****************************"))
	declare location_cd = f8 with public   
	declare err = i2 with private                ;return -1 if error
    set err = -1.0
    if (displayString = "") return (err) endif
    if (cdfString = "") return (err) endif
	call writeLog(build2(^***** Calling getLocationDetail("^,cdfString,^","^,displayString,^")^))
	set location_cd = getLocationDetail(cdfString,displayString)
 
	if (location_cd > 0.0)
		call writeLog(build2("***** location_cd returned = ",location_cd))
		set location_list->location_cnt = (location_list->location_cnt + 1)
		call writeLog(build2("****** location_list->location_cnt = ",location_list->location_cnt))
		set stat = alterlist(location_list->locations,location_list->location_cnt)
		set location_list->locations[location_list->location_cnt].location_cd = location_cd
		set location_list->locations[location_list->location_cnt].display = uar_get_code_display(location_cd)
		call writeLog(build2("****** location_list->locations[",location_list->location_cnt,"].location_cd = ",
			location_list->locations[location_list->location_cnt].location_cd))
		call writeLog(build2("****** location_list->locations[",location_list->location_cnt,"].display = ",
			location_list->locations[location_list->location_cnt].display))
		select into "nl:"
		from location l
		plan l
			where l.location_cd = location_cd
			and   l.active_ind = 1
		detail
			location_list->locations[location_list->location_cnt].location_type_cd = l.location_type_cd
			location_list->locations[location_list->location_cnt].type_meaning = uar_get_code_meaning(l.location_type_cd)
			call writeLog(build2("****** location_list->locations[",location_list->location_cnt,"].location_type_cd = ",
			location_list->locations[location_list->location_cnt].location_type_cd))
			call writeLog(build2("****** location_list->locations[",location_list->location_cnt,"].type_meaning = ",
			location_list->locations[location_list->location_cnt].type_meaning))
		with nocounter
	endif
	call writeLog(build2("**** END   AddLocationList ****************************"))
end ;AddLocationList
 
declare getLocationDetail(cdfString=vc, displayString=vc)=f8
subroutine getLocationDetail(cdfString, displayString)
 	call writeLog(build2("**** START getLocationDetail ****************************"))
    declare code_value = f8 with public         ;code_value to return
    declare err = i2 with public                ;return -1 if error
    set err = -1.0
    if (displayString = "") return (err) endif
    if (cdfString = "") return (err) endif
  
    select into "nl:"
    from code_value cv
    plan cv
        where cv.code_set = 220
        and   cv.cdf_meaning = cdfString
        and   cv.display = displayString
        and   cv.active_ind = 1
        and   cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        and   cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    order by
        cv.code_value
    head report
        code_value = 0.0
    head cv.code_value
        code_value = cv.code_value
        ;call echo(cv.code_value)
        ;call echo(code_value)
    with nocounter
    if (code_value > 0.0) return (code_value) else return (err) endif
	call writeLog(build2("**** END   getLocationDetail ****************************"))
end ;subroutine
 
declare get_code_value_alias(_code_value = f8,_cont_source_cd = f8) = vc
subroutine get_code_value_alias(_code_value,_cont_source_cd)
	declare _cv_alias = vc
 	if (_code_value > 0.0)
		select into "nl:"
		cva.alias
		from code_value_outbound cva
		where cva.code_value = _code_value
			and cva.contributor_source_cd = _cont_source_cd
		detail
			_cv_alias = cva.alias
		with nocounter
		if (trim(_cv_alias) > "")
			return(_cv_alias)
		else
			return("x")
		endif
 
	else
		return("")
	endif
end ;subroutine
 
declare covEmailAttachment(send_from = vc,
                           send_to = vc,
                           subject = vc,
                           body = vc,
                           filepath = vc,
                           priority = i2) = i4
 
;******************************************************************************
; ATGEmailAttachment
;******************************************************************************
subroutine covEmailAttachment(send_from, send_to, subject, body, filepath, priority)
   declare dcllen1 = i4 with protect, noconstant(0)
   declare file_pos = i4 with protect, noconstant(0)
   declare nFind = i4 with protect, noconstant(0)
   declare nPathLen = i4 with protect, noconstant(0)
   declare temp_pos = i4 with protect, noconstant(0)
 
   declare brPath = vc with protect, noconstant(" ")
   declare brPath1 = vc with protect, noconstant(" ")
   declare dclcom1 = vc with protect, noconstant(" ")
   declare filename = vc with protect, noconstant(" ")
   declare message_body = vc with protect, noconstant(" ")
   declare msg_file = vc with protect, constant(concat("covmsg_", trim(format(sysdate, "yyyymmddhhmmss;;q")), ".msg"))
   declare vcLogPath = vc with protect, noconstant(filepath)
 
   ; Get the logical path if this is AIX
   if (cursys = "AIX")
      set nFind = findstring(":", filepath, 1)
      if(nFind > 0)
        set brPath1 = substring(1, nFind - 1, filepath)
        set brPath1 = cnvtlower(logical(brPath1))
        if(textlen(trim(brPath1))>0 and (substring(textlen(trim(brPath1)), 1, brPath1) != "/"))
          set brPath1 = concat(brPath1, "/")
        endif
        set nPathLen = textlen(filepath)
        if(nFind < nPathLen)
          set brPath = concat(trim(brPath1), trim(
                  substring(nFind + 1, nPathLen - nFind, filepath)))
        else
          set brPath = brPath1
        endif
        set vcLogPath = brPath
      endif
   endif
 
   ; Get the filename (strip the path)
   set file_pos = findstring(":", vcLogPath, 1, 1)
 
   set temp_pos = findstring("]", vcLogPath, 1, 1)
   if(temp_pos > file_pos)
      set file_pos = temp_pos
   endif
 
   set temp_pos = findstring("\", vcLogPath, 1, 1)
   if(temp_pos > file_pos)
      set file_pos = temp_pos
   endif
 
   set temp_pos = findstring("/", vcLogPath, 1, 1)
   if(temp_pos > file_pos)
      set file_pos = temp_pos
   endif
 
   if(file_pos > 0)
      set filename = substring(file_pos + 1, size(vcLogPath) - file_pos, vcLogPath)
   else
      set filename = vcLogPath
   endif
 
   ; Encode the file for email
   if(cursys = "AIX")
      set dclcom1 = concat("uuencode ", vcLogPath, " ", filename, " > ", msg_file)
   else
      set dclcom1 = concat("mcr sys$system:tcpip$uuencode.exe ", vcLogPath, " ", msg_file)
   endif
 
   set dcllen1 = size(trim(dclcom1))
   set dclstatus = 0
   set stat = dcl(dclcom1, dcllen1, dclstatus)
   call echo(dclcom1)
 
   free set REQUESTIN
	record REQUESTIN
	(
	 1 Module_Dir = vc
	 1 Module_Name = vc
	 1 bAsBlob = i2
	)
 
	free set REPLYOUT
	record REPLYOUT
	(
	 1 INFO_LINE [*]
	   2 NEW_LINE = VC
	 1 DATA_BLOB = GVC
	 1 DATA_BLOB_SIZE = I4
	 1 STATUS_DATA
	   2 STATUS = C1
	   2 SUBEVENTSTATUS [1]
	     3 OPERATIONNAME = C25
	     3 OPERATIONSTATUS = C1
	     3 TARGETOBJECTNAME = C25
	     3 TARGETOBJECTVALUE = VC
	)
 
 
   if(dclstatus = 0)
      call uar_send_mail(nullterm(send_to),
                         nullterm(subject),
                         nullterm(concat(dclcom1, " send file failed")),
                         nullterm(send_from),
                         priority,
                         nullterm("IPM.NOTE"))
   else
      set stat = initrec(requestin)
      set stat = initrec(replyout)
      set requestin->module_dir = value("ccluserdir:")
      set requestin->module_name = msg_file
      set requestin->bAsBlob = 1
 
      execute eks_get_source with replace("REQUEST", "REQUESTIN"), replace("REPLY", "REPLYOUT")
 
      call uar_send_mail(nullterm(send_to),
                         nullterm(subject),
                         nullterm(concat(body, char(10), replyout->data_blob)),
                         nullterm(send_from),
                         priority,
                         nullterm("IPM.NOTE"))
 
      set stat = remove(msg_file)
   endif
end