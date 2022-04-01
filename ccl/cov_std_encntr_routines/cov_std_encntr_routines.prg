/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_std_encntr_routines.prg
  Object name:        cov_std_encntr_routines
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Additional Required Scripts:
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   12/02/2021  Chad Cummings			initial build
******************************************************************************/
drop program cov_std_encntr_routines:dba go
create program cov_std_encntr_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Global Variables */
declare	cSystemPrsnlID = f8 with noconstant(1.0), protect, persist

/* Required Utilities */
execute cov_std_log_routines
 
/* Subroutines */

/**********************************************************************************************************************
** Function sGetFIN_ByEncntrID()
** ---------------------------------------------------------------------------------------
** Returns the active FIN for the encounter number supplied
**********************************************************************************************************************/
declare sGetFIN_ByEncntrID(vEncntrID=f8) = vc  with copy, persist
subroutine sGetFIN_ByEncntrID(vEncntrID)

	declare vReturnFIN = vc with protect
	
	select into "nl:"
	from
		encntr_alias ea
	plan ea
		where ea.encntr_id = vEncntrID
		and   ea.encntr_id > 0.0
		and   ea.active_ind = 1
		and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
		and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	order by
		 ea.encntr_id
		,ea.beg_effective_dt_tm desc
	head report
		i = 0
	head ea.encntr_id
		vReturnFIN = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
	with nocounter
	
	return (vReturnFIN)

end

/**********************************************************************************************************************
** Function sGetEncntrID_ByFIN()
** ---------------------------------------------------------------------------------------
** Returns the encounter ID for the FIN supplied
**********************************************************************************************************************/
declare sGetEncntrID_ByFIN(vFIN=vc) = f8  with copy, persist
subroutine sGetEncntrID_ByFIN(vFIN)

	declare vReturnEncntrID = f8 with protect
	
	select into "nl:"
	from
		encntr_alias ea
	plan ea
		where ea.alias = vFIN
		and   ea.encntr_id > 0.0
		and   ea.active_ind = 1
		and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
		and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	order by
		 ea.encntr_id
		,ea.beg_effective_dt_tm desc
	head report
		i = 0
	head ea.encntr_id
		vReturnEncntrID = ea.encntr_id
	with nocounter
	
	return (vReturnEncntrID)

end



/**********************************************************************************************************************
** Function sGetPersonID_ByFIN()
** ---------------------------------------------------------------------------------------
** Returns the person ID for the FIN supplied
**********************************************************************************************************************/
declare sGetPersonID_ByFIN(vFIN=vc) = f8  with copy, persist
subroutine sGetPersonID_ByFIN(vFIN)

	declare vReturnPersonID = f8 with protect
	
	select into "nl:"
	from
		encntr_alias ea
		,encounter e
	plan ea
		where ea.alias = vFIN
		and   ea.encntr_id > 0.0
		and   ea.active_ind = 1
		and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
		and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	join e
		where e.encntr_id = ea.encntr_id
	order by
		 ea.encntr_id
		,ea.beg_effective_dt_tm desc
	head report
		i = 0
	head ea.encntr_id
		vReturnPersonID = e.person_id
	with nocounter
	
	return (vReturnPersonID)

end


/**********************************************************************************************************************
** Function sGetPersonID_ByEncntrID()
** ---------------------------------------------------------------------------------------
** Returns the person ID for the FIN supplied
**********************************************************************************************************************/
declare sGetPersonID_ByEncntrID(vEncntrID=f8) = f8  with copy, persist
subroutine sGetPersonID_ByEncntrID(vEncntrID)

	declare vReturnPersonID = f8 with protect
	
	select into "nl:"
	from
		encounter e
	plan e
		where e.encntr_id = vEncntrID
	order by
		 e.encntr_id
	head report
		i = 0
	head e.encntr_id
		vReturnPersonID = e.person_id
	with nocounter
	
	return (vReturnPersonID)

end

/**********************************************************************************************************************
** Function sGetInsuranceByEncntrID()
** ---------------------------------------------------------------------------------------
** Returns a JSON object that is convertable to a record structure containting all the insurance information for the
** encounter supplied.  
** 
** INSURANCE_LIST
(
 		1 encntr_id = f8
 		1 person_id = f8
 		1 fin = vc
 		1 insurance
 		 2 primary
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		 2 secondary 
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		 2 tertiary
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		 2 quaternary
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		1 plan_cnt = i4
 		1 plan_qual[*]
 		 2 plan_name = vc
 		 2 plan_seq = i4  	
 	) 
** 
** NOTE: The record structure is destroyed on execution. 
**
**********************************************************************************************************************/
declare sGetInsuranceByEncntrID(vEncntrID=f8) = vc  with copy, persist
subroutine sGetInsuranceByEncntrID(vEncntrID)
		
 	free record insurance_list
 	record insurance_list
 	(
 		1 encntr_id = f8
 		1 person_id = f8
 		1 fin = vc
 		1 insurance
 		 2 primary
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		 2 secondary 
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		 2 tertiary
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		 2 quaternary
 		  3 plan_name = vc
 		  3 group_nbr = vc
 		  3 member_nbr = vc
 		1 plan_cnt = i4
 		1 plan_qual[*]
 		 2 plan_name = vc
 		 2 plan_seq = i4 	
 	) with protect
 
	select into "nl:"
	from
		 encounter e
		,encntr_plan_reltn epr
	 	,health_plan hp
	 	,(dummyt d1)
	plan e
		where e.encntr_id = vEncntrID
	join d1
	join epr
	 	where epr.encntr_id = e.encntr_id
	 	and epr.active_ind = 1
	 	and epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	 	and epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	join hp
		where hp.health_plan_id = epr.health_plan_id
		and hp.active_ind = 1
		and hp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and hp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	order by
		 e.encntr_id
		,epr.priority_seq
		,epr.beg_effective_dt_tm desc
	head report
		i = 0
	head e.encntr_id
		insurance_list->encntr_id = e.encntr_id
		insurance_list->person_id = e.person_id
	head epr.priority_seq
		case (epr.priority_seq)
			of 1:	insurance_list->insurance.primary.plan_name 		= hp.plan_name
					insurance_list->insurance.primary.group_nbr 		= epr.group_nbr 
					insurance_list->insurance.primary.member_nbr		= epr.member_nbr
			of 2:	insurance_list->insurance.secondary.plan_name 		= hp.plan_name
					insurance_list->insurance.secondary.member_nbr		= epr.member_nbr
					insurance_list->insurance.secondary.group_nbr		= epr.group_nbr
			of 3:   insurance_list->insurance.tertiary.plan_name 		= hp.plan_name
					insurance_list->insurance.tertiary.member_nbr		= epr.member_nbr
					insurance_list->insurance.tertiary.group_nbr		= epr.group_nbr
			of 4:   insurance_list->insurance.quaternary.plan_name 		= hp.plan_name
					insurance_list->insurance.quaternary.group_nbr		= epr.group_nbr
					insurance_list->insurance.quaternary.member_nbr		= epr.member_nbr
		endcase
		insurance_list->plan_cnt = (insurance_list->plan_cnt + 1)
		stat = alterlist(insurance_list->plan_qual,insurance_list->plan_cnt)
		insurance_list->plan_qual[insurance_list->plan_cnt].plan_name = hp.plan_name
		insurance_list->plan_qual[insurance_list->plan_cnt].plan_seq = epr.priority_seq
	foot report
		i = 0
	with nocounter,nullreport,outerjoin=d1
 
 	set insurance_list->fin = sGetFIN_ByEncntrID(insurance_list->encntr_id)
 
	return (cnvtrectojson(insurance_list))
end
 



/**********************************************************************************************************************
** Function sGetPatientDemo(PERSON_ID,ENCNTR_ID)
** ---------------------------------------------------------------------------------------
** Returns a JSON object that is convertable to a record structure containting all the insurance information for the
** encounter supplied.  
** 
** PATIENT_INFO

** 
** NOTE: The record structure is destroyed on execution. 
**
**********************************************************************************************************************/
declare sGetPatientDemo(vPersonID=f8,vEncntrID=f8) = vc  with copy, persist
subroutine sGetPatientDemo(vPersonID,vEncntrID)

call SubroutineLog(build2('start sGetPatientDemo(',vPersonID,',',vEncntrID,')'))	
 	free record patient_info
 	
 	declare _memory_reply_string = vc with noconstant(" "), protect
 	execute mp_get_patient_demo ~MINE~,vPersonID,vEncntrID,0 
 	
 	set stat = cnvtjsontorec(_memory_reply_string)
 	set stat = copyrec(record_data,patient_info,1)
 	
 	call SubroutineLog(build2('end sGetPatientDemo(',vPersonID,',',vEncntrID,')'))
 	return (cnvtrectojson(patient_info))
end 

 
call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
