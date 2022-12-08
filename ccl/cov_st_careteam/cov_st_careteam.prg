/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Chad Cummings
	Date Written:
	Solution:
	Source file name:	cov_st_careteam.prg
	Object name:		cov_st_careteam
	Request #:
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:		Called by ccl program(s).
 					    use cov_st_careteam.tst test
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/
 
drop program cov_st_careteam:dba go
create program cov_st_careteam:dba

execute cov_std_encntr_routines
execute cov_std_rtf_routines
 
call SubroutineLog(build2("************************************************************"))
call SubroutineLog(build2("* START Custom Section  ************************************"))
 
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
	1 person_id		= f8
	1 insurance
	 2 primary = vc
	 2 secondary = vc
	 2 tertiary = vc
	 2 quaternary = vc
) with protect
 
 
call SubroutineLog(build2("* END   Custom Section  ************************************"))
call SubroutineLog(build2("************************************************************"))
 
 
call SubroutineLog(build2("************************************************************"))
call SubroutineLog(build2("* START Set Encounter ID ***********************************"))
 
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

set t_rec->person_id = sGetPersonID_ByEncntrID(t_rec->encntr_id)
if (t_rec->person_id = 0.0)
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "PERSON_ID"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "PERSON_ID"
	set reply->status_data.subeventstatus.targetobjectvalue = "Person ID not found"
	go to exit_script
endif

call SubroutineLog(build2("* END   Set Encounter ID ***********************************"))
call SubroutineLog(build2("************************************************************"))
 
call SubroutineLog(build2("************************************************************"))
call SubroutineLog(build2("* START Getting Careteam   ********************************"))
 
set stat = cnvtjsontorec(sGetCareTeam(t_rec->person_id,t_rec->encntr_id))

call echorecord(cov_careteam_info)
/* 
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
*/
 
call SubroutineLog(build2("* END   Getting Careteam   ********************************"))
call SubroutineLog(build2("************************************************************"))
 
 
call SubroutineLog(build2("************************************************************"))
call SubroutineLog(build2("* START Building Reply  ************************************"))
 
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

 
call SubroutineLog(build2("* END   Building Reply  ************************************"))
call SubroutineLog(build2("************************************************************"))
 
#exit_script
 
call echorecord(t_rec)
 
 
end
go
 
