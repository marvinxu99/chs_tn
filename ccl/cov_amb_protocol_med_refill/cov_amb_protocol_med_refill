/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:
	Solution:
	Source file name:	cov_amb_protocol_med_refill.prg
	Object name:		cov_amb_protocol_med_refill
	Request #:
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:		Called by ccl program(s).
 					    use cov_st_ccl_template.tst test
						1) Find new CKI
							a. Select * from clinical_note_template go
							b. CKI.NOTETEMPLATE!Protocol-MedicationRefill(LPN&RNOnly)
						2) Updated CODE_VALUE table with new CKI
							a. update into code_value Set CKI = "CKI.NOTETEMPLATE!Protocol-MedicationRefill(LPN&RNOnly)"
								Where code_value = 3161599639 and code_set = 16529

 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/
 
drop program cov_amb_protocol_med_refill:dba go
create program cov_amb_protocol_med_refill:dba
 
 
call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))
 
execute cov_std_encntr_routines
execute cov_std_rtf_routines
 
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
 
call get_rtf_definitions(null)
 
record t_rec
(
	1 cnt			= i4
	1 encntr_id		= f8
	1 insurance
	 2 primary = vc
	 2 secondary = vc
	 2 tertiary = vc
	 2 quaternary = vc
) with protect
 
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Set Encounter ID ***********************************"))
 
if (validate(request->visit[1].encntr_id))
	set t_rec->encntr_id = request->visit[1].encntr_id
endif
 
if (t_rec->encntr_id = 0.0)
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "ENCNTR_ID"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "ENCNTR_ID"
	set reply->status_data.subeventstatus.targetobjectvalue = "Encoutner ID not found or set in request"
	go to exit_script
endif
 
call writeLog(build2("* END   Set Encounter ID ***********************************"))
call writeLog(build2("************************************************************"))
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Getting Insurance   ********************************"))
 
set stat = cnvtjsontorec(sGetInsuranceByEncntrID(t_rec->encntr_id))
 
if (stat = TRUE)
	call echorecord(insurance_list)
	
	set t_rec->insurance.primary 		= concat(
													 insurance_list->insurance.primary.plan_name
													,rtf_definitions->st.rtab
													," Group#: ",trim(insurance_list->insurance.primary.group_nbr)
													,rtf_definitions->st.rtab
													," Member#: ",trim(insurance_list->insurance.primary.member_nbr)
												)
	set t_rec->insurance.secondary 		= concat(
													 insurance_list->insurance.secondary.plan_name 
													 ,rtf_definitions->st.rtab
													 ," Group#: ",trim(insurance_list->secondary.group_nbr)
													 ,rtf_definitions->st.rtab
													 ," Member#: ",trim(insurance_list->secondary.member_nbr)
												)
	set t_rec->insurance.tertiary	 	= concat(
													 insurance_list->insurance.tertiary.plan_name 
													 ,rtf_definitions->st.rtab
													 ," Group#: ",trim(insurance_list->insurance.tertiary.group_nbr)
													 ,rtf_definitions->st.rtab
													 ," Member#: ",trim(insurance_list->insurance.tertiary.member_nbr)
												) 
	set t_rec->insurance.quaternary 	= concat(
													 insurance_list->insurance.quaternary.plan_name 
													 ,rtf_definitions->st.rtab
													 ," Group#: ",trim(insurance_list->insurance.quaternary.group_nbr)
													 ,rtf_definitions->st.rtab
													 ," Member#: ",trim(insurance_list->insurance.quaternary.member_nbr)
												) 
	
else
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "INSURANCE_LIST"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "INSURANCE_LIST"
	set reply->status_data.subeventstatus.targetobjectvalue = "Standard Insurance List routine failed"
	go to exit_script
endif
 
call writeLog(build2("* END   Getting Insurance   ********************************"))
call writeLog(build2("************************************************************"))
 
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building Reply  ************************************"))
 
set reply->text =  build2(reply->text,rtf_definitions->st.rhead)
set reply->text =  build2(reply->text,rtf_definitions->st.wr)

call echorecord(rtf_definitions)

if (t_rec->insurance.primary > "")
	set reply->text =  build2(	 reply->text
								,"Primary:"
								,rtf_definitions->st.rtab
								,t_rec->insurance.primary
								,rtf_definitions->st.reol
							)
endif

if (t_rec->insurance.secondary > "")
	set reply->text =  build2(	 reply->text
								," Secondary:"
								,rtf_definitions->st.rtab
								,t_rec->insurance.secondary
								,rtf_definitions->st.reol
							  )
endif

if (t_rec->insurance.tertiary > "")
	set reply->text =  build2(	 reply->text
								," Tertiary:"
								,rtf_definitions->st.rtab
								,t_rec->insurance.tertiary
								,rtf_definitions->st.reol
							  )
endif

if (t_rec->insurance.quaternary > "")
	set reply->text =  build2(	 reply->text
								," Quaternary:"
								,rtf_definitions->st.rtab
								,t_rec->insurance.quaternary
								,rtf_definitions->st.reol
							 )
endif
set reply->text =  build2(reply->text,rtf_definitions->st.rtfeof)

call echorecord(reply)

 
call writeLog(build2("* END   Building Reply  ************************************"))
call writeLog(build2("************************************************************"))
 
#exit_script
 
 
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
 
 
end
go
 
