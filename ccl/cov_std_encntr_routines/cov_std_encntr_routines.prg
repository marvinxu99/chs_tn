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
** Function sGetPersonID_ByCMRN()
** ---------------------------------------------------------------------------------------
** Returns the encounter ID for the cMRN supplied
**********************************************************************************************************************/
declare sGetPersonID_ByCMRN(cMRN=vc) = f8  with copy, persist
subroutine sGetPersonID_ByCMRN(cMRN)

	declare vReturnPersonID = f8 with protect
	
	select into "nl:"
	from
		person_alias ea
	plan ea
		where ea.alias = cMRN
		and   ea.person_id > 0.0
		and   ea.active_ind = 1
		and   ea.person_alias_type_cd = value(uar_get_code_by("MEANING",4,"CMRN"))
		and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	order by
		 ea.person_id
		,ea.beg_effective_dt_tm desc
	head report
		i = 0
	head ea.person_id
		vReturnPersonID = ea.person_id
	with nocounter
	
	return (vReturnPersonID)

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
** Function sGetPersonID_ByAlias()
** ---------------------------------------------------------------------------------------
** Returns the person IDs for the Alias supplied in the cov_person_alias JSON record structure
**********************************************************************************************************************/
declare sGetPersonID_ByAlias(vAlias=vc,vType=vc(VALUE,"SSN")) = vc  with copy, persist
subroutine sGetPersonID_ByAlias(vAlias,vType)
	
	call SubroutineLog(build2('start sGetPersonID_ByAlias(',vAlias,',',vType,')'))
	
	free record cov_person_alias
	record cov_person_alias
	(
		1 cnt = i2
		1 qual[*]
		 2 person_id = f8
		 2 alias = vc
		 2 alias_type_cd = f8
		 2 alias_type_mean = vc
	)
	
	select into "nl:"
	from
		 person_alias pa
		,person p
	plan pa
		where pa.alias = vAlias
		and   pa.active_ind = 1
		and   pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
		and   pa.end_effective_dt_tm >= cnvtdatetime(sysdate)
		and   pa.person_alias_type_cd = value(uar_get_code_by("MEANING",4,vType))
	join p
		where p.person_id = pa.person_id
		and   p.active_ind = 1
	order by
		pa.person_id
	head report
		cov_person_alias->cnt = 0
	head pa.person_id
		cov_person_alias->cnt += 1
		stat = alterlist(cov_person_alias->qual,cov_person_alias->cnt)
		cov_person_alias->qual[cov_person_alias->cnt].person_id = p.person_id
		cov_person_alias->qual[cov_person_alias->cnt].alias_type_cd = pa.person_alias_type_cd
		cov_person_alias->qual[cov_person_alias->cnt].alias_type_mean = uar_get_code_meaning(pa.person_alias_type_cd)
	with nocounter
	
	call SubroutineLog(build2('end sGetPersonID_ByAlias(',vAlias,',',vType,')'))
	
	return (cnvtrectojson(cov_person_alias))

end

/**********************************************************************************************************************
** Function sGetDOB_ByPersonID(vPersonID=f8) = c8
** ---------------------------------------------------------------------------------------
** Returns the MMDDYYYY DOB for the provider person_id
**********************************************************************************************************************/
declare sGetDOB_ByPersonID(vPersonID=f8) = c8  with copy, persist
subroutine sGetDOB_ByPersonID(vPersonID)

	call SubroutineLog(build2('start sGetDOB_ByPersonID(',vPersonID,')'))
	
	declare vReturnDOB = c8 with protect
	
	select into "nl:"
	from
		person p
	plan p
		where p.person_id = vPersonID
		and   p.active_ind = 1
	order by
		p.person_id
	head p.person_id
		vReturnDOB = DateBirthFormat(p.birth_dt_tm,p.birth_tz,p.birth_prec_flag,"MMDDYYYY",0,0)
	with nocounter
	
	call SubroutineLog(build2('end sGetDOB_ByPersonID(',vPersonID,')'))
	
	return (vReturnDOB)

end


/**********************************************************************************************************************
** Function sValidate_DOB(vPersonID=f8,vDOB=c8) = i2
** ---------------------------------------------------------------------------------------
** Returns the TRUE or FALSE if supplied DOB MMDDYYYY matchs DOB for the provided person_id
**********************************************************************************************************************/
declare sValidate_DOB(vPersonID=f8,vDOB=c8) = i2  with copy, persist
subroutine sValidate_DOB(vPersonID,vDOB)

	call SubroutineLog(build2('start sValidate_DOB(',vPersonID,',',vDOB,')'))
	
	declare vReturnValue = i2 with noconstant(FALSE), protect
	declare vDOBCheck = c8 with private, protect

	set vDOBCheck = sGetDOB_ByPersonID(vPersonID)
	
	if (vDOBCheck = vDOB)
		set vReturnValue = TRUE
	endif
	
	call SubroutineLog(build2('end sValidate_DOB(',vPersonID,',',vDOB,')'))
	
	return (vReturnValue)

end

/**********************************************************************************************************************
** Function sGetSex_ByPersonID(vPersonID=f8) = vc
** ---------------------------------------------------------------------------------------
** Returns the alias for sex_cd from the Covenant contr. source  for the provider person_id
**********************************************************************************************************************/
declare sGetSex_ByPersonID(vPersonID=f8) = vc  with copy, persist
subroutine sGetSex_ByPersonID(vPersonID)

	call SubroutineLog(build2('start sGetSex_ByPersonID(',vPersonID,')'))
	
	declare vReturnSex = vc with protect
	
	select into "nl:"
	from
		 person p
		,code_value_alias cva
		,code_value cv
	plan p
		where p.person_id = vPersonID
		and   p.active_ind = 1
	join cva
		where cva.code_value = p.sex_cd
	join cv
		where cv.code_value = cva.contributor_source_cd
		and   cv.display = "COVENANT"
		and   cv.active_ind = 1
	order by
		 p.person_id
	head p.person_id
		vReturnSex = cva.alias
	with nocounter
	
	call SubroutineLog(build2('->vReturnSex=',vReturnSex,'<end>'))
	
	call SubroutineLog(build2('end sGetSex_ByPersonID(',vPersonID,')'))
	
	return (vReturnSex)

end

/**********************************************************************************************************************
** Function sValidate_Sex(vPersonID=f8,vSex=vc) = i2
** ---------------------------------------------------------------------------------------
** Returns the TRUE or FALSE if supplied Sex matchs Sex_cd for the provided person_id on the Covenant contr. source
**********************************************************************************************************************/
declare sValidate_Sex(vPersonID=f8,vSex=vc) = i2  with copy, persist
subroutine sValidate_Sex(vPersonID,vSex)

	call SubroutineLog(build2('start sValidate_Sex(',vPersonID,',',vSex,')'))
	
	declare vReturnValue = i2 with noconstant(FALSE), protect
	declare vDOBCheck = vc with private, protect

	set vSexCheck = sGetSex_ByPersonID(vPersonID)
	
	if (vSexCheck = vSex)
		set vReturnValue = TRUE
	endif
	
	call SubroutineLog(build2('end sValidate_Sex(',vPersonID,',',vSex,')'))
	
	return (vReturnValue)

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
** Function sGetFacility_ByEncntrID(encntr_id,[DISPLAY,DESCRIPTION])
** ---------------------------------------------------------------------------------------
** Returns the Facility [display] or description based on the provided encntr_id
**********************************************************************************************************************/
declare sGetFacility_ByEncntrID(vEncntrID=f8,vType=vc(VALUE,"DISPLAY")) = vc  with copy, persist
subroutine sGetFacility_ByEncntrID(vEncntrID,vType)

	declare vReturnFacility = vc with protect
	
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
		if (cnvtupper(vType) = "DESCRIPTION")
			vReturnFacility = uar_get_code_description(e.loc_facility_cd)
		else
			vReturnFacility = uar_get_code_display(e.loc_facility_cd)
		endif
	with nocounter
	
	return (vReturnFacility)

end


/**********************************************************************************************************************
** Function sGetUnit_ByEncntrID(encntr_id,[DISPLAY,DESCRIPTION])
** ---------------------------------------------------------------------------------------
** Returns the Unit [display] or description based on the provided encntr_id
**********************************************************************************************************************/
declare sGetUnit_ByEncntrID(vEncntrID=f8,vType=vc(VALUE,"DISPLAY")) = vc  with copy, persist
subroutine sGetUnit_ByEncntrID(vEncntrID,vType)

	declare vReturnUnit = vc with protect
	
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
		if (cnvtupper(vType) = "DESCRIPTION")
			vReturnUnit = uar_get_code_description(e.loc_nurse_unit_cd)
		else
			vReturnUnit = uar_get_code_display(e.loc_nurse_unit_cd)
		endif
	with nocounter
	
	return (vReturnUnit)

end


/**********************************************************************************************************************
** Function sGetAppts_ByPersonID()
** ---------------------------------------------------------------------------------------
** Returns a list of past or [future] appointments by the PersonID 
**********************************************************************************************************************/
declare sGetAppts_ByPersonID(vPersonID=f8,vDays=i2(VALUE,365),vPastFuture=vc(VALUE,"FUTURE")) = vc  with copy, persist
subroutine sGetAppts_ByPersonID(vPersonID,vDays,vPastFuture)

	call SubroutineLog(build2('start sGetPastAppts_ByPersonID(',vPersonID,',',vDays,',',vPastFuture,')'))
	
	declare vReturnAppts = vc with protect
	declare appt_pass = i2 with protect
	
	free record 651164Reply
	free record 651164Request 
	record 651164Request (
	  1 call_echo_ind = i2   
	  1 program_name = vc  
	  1 advanced_ind = i2   
	  1 query_type_cd = f8   
	  1 query_meaning = vc  
	  1 sch_query_id = f8   
	  1 qual [*]   
	    2 parameter = vc  
	    2 oe_field_id = f8   
	    2 oe_field_value = f8   
	    2 oe_field_display_value = vc  
	    2 oe_field_dt_tm_value = dq8   
	    2 oe_field_meaning_id = f8   
	    2 oe_field_meaning = vc  
	    2 label_text = vc  
	)
	
	free record appointment_list
	record appointment_list
	(
		1 person_id = f8
		1 cnt = i4
		1 qual[*]
			2 scheventid = f8   
			2 scheduleid = f8  
			2 scheduleseq = i4 
			2 schapptid = f8
			2 statemeaning = vc
			2 encounterid = f8  
			2 personid = f8  
			2 bitmask = i4  
			2 schappttypecd = f8   
			2 beg_dt_tm = dq8   
			2 duration = i4  
			2 state = vc   
			2 appt_type = vc
			2 appt_reason = vc
			2 prime_res = vc
			2 location = vc
	)
	
	
	if (vPersonID > 0.0)
	
		set 651164Request->call_echo_ind = 1 
		set 651164Request->advanced_ind = 1
		
		if (cnvtupper(vPastFuture) = "PAST")
			set 651164Request->query_meaning = "APPTINDEXPAS" 
			set 651164Request->program_name = "cov_inqa_appt_index_past" 
			set 651164Request->sch_query_id = 614425
		else
			set 651164Request->query_meaning = "APPTINDEXFUT" 
			set 651164Request->program_name = "cov_inqa_appt_index_future" 
			set 651164Request->sch_query_id = 614426
		endif
		
		set 651164Request->query_type_cd = uar_get_code_by("MEANING",14349,651164Request->query_meaning) 
		 
		set stat = alterlist(651164Request->qual,1) 
		set 651164Request->qual[1].oe_field_value =  vPersonID 
		set 651164Request->qual[1].oe_field_meaning = "PERSON" 
		
		call SubroutineLog("651164Request","record")	
		
		set stat = tdbexecute(600005,652000,651164,"REC",651164Request,"REC",651164Reply) 
		
		call SubroutineLog("651164Reply","record")	
		
		for (j=1 to 651164Reply->query_qual_cnt)
			set appointment_list->person_id = vPersonID
			set appt_pass = 0
			if (vDays > 0)
				if (abs(datetimediff(cnvtdatetime(sysdate),651164reply->query_qual[j].beg_dt_tm,1)) < vDays)
			   		set appt_pass = 1
			 	endif
			else
			  	set appt_pass = 1
			endif
			
			if (appt_pass = 1)
				set appointment_list->cnt = (appointment_list->cnt + 1)
				set stat = alterlist(appointment_list->qual,appointment_list->cnt)
				set appointment_list->qual[appointment_list->cnt].scheventid   		= 651164reply->query_qual[j].hide#scheventid
				set appointment_list->qual[appointment_list->cnt].scheduleid  		= 651164reply->query_qual[j].hide#scheduleid
				set appointment_list->qual[appointment_list->cnt].scheduleseq 	 	= 651164reply->query_qual[j].hide#scheduleseq
				set appointment_list->qual[appointment_list->cnt].schapptid 		= 651164reply->query_qual[j].hide#schapptid
				set appointment_list->qual[appointment_list->cnt].statemeaning 		= 651164reply->query_qual[j].hide#statemeaning
				set appointment_list->qual[appointment_list->cnt].encounterid  		= 651164reply->query_qual[j].hide#encounterid
				set appointment_list->qual[appointment_list->cnt].personid 			= 651164reply->query_qual[j].hide#personid 
				set appointment_list->qual[appointment_list->cnt].bitmask  			= 651164reply->query_qual[j].hide#bitmask
				set appointment_list->qual[appointment_list->cnt].schappttypecd  	= 651164reply->query_qual[j].hide#schappttypecd
				set appointment_list->qual[appointment_list->cnt].beg_dt_tm  		= 651164reply->query_qual[j].beg_dt_tm
				set appointment_list->qual[appointment_list->cnt].duration 			= 651164reply->query_qual[j].duration
				set appointment_list->qual[appointment_list->cnt].state    			= 651164reply->query_qual[j].state
				set appointment_list->qual[appointment_list->cnt].appt_type 		= 651164reply->query_qual[j].appt_type
				set appointment_list->qual[appointment_list->cnt].appt_reason 		= 651164reply->query_qual[j].appt_reason
				set appointment_list->qual[appointment_list->cnt].prime_res 		= 651164reply->query_qual[j].prime_res
				set appointment_list->qual[appointment_list->cnt].location 			= 651164reply->query_qual[j].location
			endif	
		endfor
	endif
	
	set vReturnAppts = cnvtrectojson(appointment_list)
	
	return (vReturnAppts)

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
** Function sGetPatientInfo(PERSON_ID,ENCNTR_ID)
** ---------------------------------------------------------------------------------------
** Returns a JSON object that is convertable to a record structure containting all the insurance information for the
** encounter supplied.  
** 
** COV_PATIENT_INFO

** 
** NOTE: The record structure is destroyed on execution. 
**
**********************************************************************************************************************/
declare sGetPatientInfo(vPersonID=f8,vEncntrID=f8) = vc  with copy, persist
subroutine sGetPatientInfo(vPersonID,vEncntrID)

call SubroutineLog(build2('start sGetPatientInfo(',vPersonID,',',vEncntrID,')'))	
 	free record cov_patient_info
 	
 	declare _memory_reply_string = vc with noconstant(" "), protect
 	execute mp_get_patient_info_wf ~MINE~,vPersonID,vEncntrID,1,1,1,1,0,0.0 
 	
 	set stat = cnvtjsontorec(_memory_reply_string)
 	set stat = copyrec(record_data,cov_patient_info,1)
 	
 	call SubroutineLog(build2('end sGetPatientInfo(',vPersonID,',',vEncntrID,')'))
 	return (cnvtrectojson(cov_patient_info))
end

/**********************************************************************************************************************
** Function sGetCareTeam(PERSON_ID,ENCNTR_ID)
** ---------------------------------------------------------------------------------------
** Returns a JSON object that is convertable to a record structure containting all the careteam information for the
** encounter supplied.  
** 
** COV_PATIENT_INFO

** 
** NOTE: The record structure is destroyed on execution. 
**
**********************************************************************************************************************/
declare sGetCareTeam(vPersonID=f8,vEncntrID=f8) = vc  with copy, persist
subroutine sGetCareTeam(vPersonID,vEncntrID)

call SubroutineLog(build2('start sGetCareTeam(',vPersonID,',',vEncntrID,')'))	
 	free record cov_careteam_info
 	
 	declare _memory_reply_string = vc with noconstant(" "), protect
 	
 	execute mp_get_care_team_assign ~MINE~,vPersonID,vEncntrID,0.0,0.0,0,0,0,0
 	
 	set stat = cnvtjsontorec(_memory_reply_string)
 	set stat = copyrec(record_data,cov_careteam_info,1)
 	
 	call SubroutineLog(build2('end sGetCareTeam(',vPersonID,',',vEncntrID,')'))
 	return (cnvtrectojson(cov_careteam_info))
end 



/**********************************************************************************************************************
** Function sGetPatientDemo(PERSON_ID,ENCNTR_ID)
** ---------------------------------------------------------------------------------------
** Returns a JSON object that is convertable to a record structure containting all the insurance information for the
** encounter supplied.  
** 
** COV_PATIENT_INFO

** 
** NOTE: The record structure is destroyed on execution. 
**
**********************************************************************************************************************/
declare sGetPatientDemo(vPersonID=f8,vEncntrID=f8) = vc  with copy, persist
subroutine sGetPatientDemo(vPersonID,vEncntrID)

call SubroutineLog(build2('start sGetPatientDemo(',vPersonID,',',vEncntrID,')'))	
 	free record cov_patient_info
 	record cov_patient_info
 	(
		1 demographics
				2 patient_info
					3 person_id = f8
					3 sex_cd = f8
					3 birth_dt_tm = vc
					3 local_birth_dt_tm = vc
					3 abs_birth_dt_tm = vc
					3 birth_date = dq8
					3 birth_tz = i4
					3 local_deceased_dt_tm = vc
					3 deceased_dt_tm = vc
					3 patient_name
						4 name_first = vc
						4 name_middle = vc
						4 name_last = vc
						4 name_full = vc
					3 alias[*]
						4 alias_type_cd = f8
						4 alias = vc
						4 formatted_alias = vc
					3 patient_provider[*]
						4 reltn_code = f8
						4 prsnl_id = f8
				2 encounter_info[*]
					3 encounter_id = f8
					3 type_code = f8
					3 reason_visit = vc
					3 provider[*]
						4 reltn_code = f8
						4 prsnl_id = f8
					3 alias[*]
						4 alias_type_cd = f8
						4 alias = vc
						4 formatted_alias = vc
					3 arrive_dt_tm = vc
					3 arrive_date = dq8
					3 depart_dt_tm = vc
					3 depart_date = dq8
					3 reg_dt_tm = vc
					3 reg_date = dq8
					3 discharge_dt_tm = vc
					3 discharge_date = dq8
					3 isolation_cd = f8
					3 location_cd = f8
					3 loc_facility_cd = f8
					3 loc_building_cd = f8
					3 loc_nurse_unit_cd = f8
					3 loc_room_cd = f8
					3 loc_bed_cd = f8
				2 addresses[*]
				    3 address_type = vc
				    3 street_address = vc
				    3 street_address2 = vc
				    3 street_address3 = vc
				    3 street_address4 = vc
				    3 city = vc
				    3 state = vc
				    3 zipcode = vc
				 2 health_plans[*]
				    3 priority = i4
				    3 plan_type = vc
				    3 plan_name = vc
				    3 plan_number = vc
				 2 emergency_contact_list[*]
				    3 name = vc
				    3 relationship_to_person = vc
				    3 contact_phone[*]
				      4 phone_type = vc
				      4 phone_number = vc
				      4 phone_type_code = f8
				 2 contact_information
				    3 phone[*]
				      4 phone_type = vc
				      4 phone_num = vc
				      4 phone_type_cd = f8
				    3 emails[*]
				      4 email = vc
				  	3 preferred_method_of_contact = vc
				 
		1 codes[*]
			2 sequence	= i4
			2 code		= f8
			2 code_set	= f8
			2 display	= vc
			2 description	= vc
			2 meaning 	= vc 	
 		1 prsnl[*]
			2 id = f8
			2 person_name_id = f8
			2 active_date = dq8
			2 beg_effective_dt_tm = dq8
			2 end_effective_dt_tm = dq8
			2 provider_name
				3 name_full = vc
				3 name_first = vc
				3 name_middle = vc
				3 name_last = vc
				3 username = vc
				3 initials = vc
				3 title = vc
%i cclsource:status_block.inc	
 	)
 	declare _memory_reply_string = vc with noconstant(" "), protect
 	execute mp_get_patient_demo ~MINE~,vPersonID,vEncntrID,0 ;with replace("REPORT_DATA",cov_patient_info)
 	
 	free record temp_patient_info
 	set stat = cnvtjsontorec(_memory_reply_string)
 	set stat = copyrec(record_data,temp_patient_info,1)
 	call echorecord(temp_patient_info)
 	
 	set stat = moverec(temp_patient_info->demographics.patient_info,cov_patient_info->demographics.patient_info)
 	set stat = moverec(temp_patient_info->demographics.encounter_info,cov_patient_info->demographics.encounter_info)
 	set stat = moverec(temp_patient_info->codes,cov_patient_info->codes)
 	set stat = moverec(temp_patient_info->prsnl,cov_patient_info->prsnl)
 	
 	free record record_data
 	free record temp_patient_info
 	
 	execute mp_get_patient_info_wf ~MINE~,vPersonID,vEncntrID,1,1,1,1,0,0.0 
 	
 	set stat = cnvtjsontorec(_memory_reply_string)
 	set stat = copyrec(record_data,temp_patient_info,1)
 	
 	call echorecord(temp_patient_info)
 	
 	if (size(temp_patient_info->addresses,5) > 5)
 		set stat = moverec(temp_patient_info->addresses,cov_patient_info->demographics.addresses)
 	endif
 	
 	if (size(temp_patient_info->contact_information.phone,5) > 0)
 		set stat = moverec(temp_patient_info->contact_information.phone,cov_patient_info->demographics.contact_information.phone)
 	endif
 	
 	if (size(temp_patient_info->health_plans,5) > 0)
 		set stat = moverec(temp_patient_info->health_plans,cov_patient_info->demographics.health_plans)
 	endif
 	
 	for (i=1 to size(temp_patient_info->emergency_contact_list,5))
 		set stat = alterlist(cov_patient_info->demographics.emergency_contact_list,i)
 		set cov_patient_info->demographics.emergency_contact_list[i].name =
 			temp_patient_info->emergency_contact_list[i].name
 		set cov_patient_info->demographics.emergency_contact_list[i].relationship_to_person = 
 			temp_patient_info->emergency_contact_list[i].relationship_to_person
 		for (j=1 to size(cov_patient_info->demographics.emergency_contact_list[i].contact_phone,5))
 			set stat = alterlist(cov_patient_info->demographics.emergency_contact_list[i].contact_phone,j)
 			set cov_patient_info->demographics.emergency_contact_list[i].contact_phone[j].phone_number =
 				temp_patient_info->emergency_contact_list[i].contact_phone[j].phone_number
 			set cov_patient_info->demographics.emergency_contact_list[i].contact_phone[j].phone_type = 
 				temp_patient_info->emergency_contact_list[i].contact_phone[j].phone_type
 			set cov_patient_info->demographics.emergency_contact_list[i].contact_phone[j].phone_type_code = 
 				temp_patient_info->emergency_contact_list[i].contact_phone[j].phone_type_code
 		endfor
 	endfor
 	
 	/*
 	1 emergency_contact_list[*]
    2 name = vc
    2 relationship_to_person = vc
    2 contact_phone[*]
      3 phone_type = vc
      3 phone_number = vc
      3 phone_type_code = f8
    */
 	
 	
 	set cov_patient_info->demographics.contact_information.preferred_method_of_contact 
 		= temp_patient_info->contact_information.preferred_method_of_contact
 	
 	for (i=1 to size(temp_patient_info->contact_information.emails,5))
 		set stat = alterlist(cov_patient_info->demographics.contact_information.emails,i)
 		set cov_patient_info->demographics.contact_information.emails[i].email = 
 			temp_patient_info->contact_information.emails[i].email
 	endfor
 	
 	set cov_patient_info->status_data.status = "S"
 	
 	call SubroutineLog(build2('end sGetPatientDemo(',vPersonID,',',vEncntrID,')'))
 	return (cnvtrectojson(cov_patient_info))
end 




/**********************************************************************************************************************
** Function sGetCMGLocations()
** ---------------------------------------------------------------------------------------
** Returns a JSON object of the CMG locations grouped by aliases 
**********************************************************************************************************************/
declare sGetCMGLocations(null) = vc  with copy, persist
subroutine sGetCMGLocations(null)

	call SubroutineLog(build2('start sGetCMGLocations(null)'))
 	
	free record cmg_locations
	record cmg_locations
	(
		1 cnt = i4
		1 qual[*]
			2 group 		= vc
			2 display 		= vc
			2 description 	= vc
			2 location_cd 	= f8
			2 unit			= vc
			2 org_name		= vc
			2 org_id		= f8
	)

	select into "nl:"
	from
	     location l
	    ,location l2
	    ,location_group lg1
	    ,location_group lg2
	    ,organization o
	    ,org_set os
	    ,org_set_org_r osr
	    ,code_value_outbound cvo
	plan l
	    where l.location_type_cd = value(uar_get_code_by("MEANING",222,"FACILITY") )
	    and l.active_ind = 1
	join o
	    where o.organization_id = l.organization_id
	join osr
	    where osr.organization_id = o.organization_id
	    and osr.active_ind = 1
	join os
	    where os.org_set_id = osr.org_set_id and os.name like '*CMG*'
	join lg1
		where lg1.parent_loc_cd = l.location_cd
		and   lg1.active_ind = 1
		and   cnvtdatetime(sysdate) between lg1.beg_effective_dt_tm and lg1.end_effective_dt_tm
	join lg2
		where lg2.parent_loc_cd = lg1.child_loc_cd
		and   lg2.active_ind = 1
		and   cnvtdatetime(sysdate) between lg2.beg_effective_dt_tm and lg2.end_effective_dt_tm
	join l2
		where l2.location_cd = lg2.child_loc_cd
		and   l2.location_type_cd = value(uar_get_code_by("MEANING",222,"AMBULATORY"))
	join cvo
	    where cvo.code_value = l.location_cd
	    and   cvo.contributor_source_cd = value(uar_get_code_by("DISPLAY",73,"COVDEV1"))
	    and   cvo.code_set = 220
	    and   cvo.alias_type_meaning in("FACILITY")
	order by
	    cvo.alias
	    ,uar_get_code_display(l.location_cd)
	    ,l.location_cd
	head report
		i = 0
	head l.location_cd
		i = (i + 1)
		stat = alterlist(cmg_locations->qual,i)
		cmg_locations->qual[i].group			= cvo.alias
		cmg_locations->qual[i].display			= uar_get_code_display(l.location_cd)
		cmg_locations->qual[i].description		= uar_get_code_description(l.location_cd)
		cmg_locations->qual[i].location_cd		= l.location_cd	
		cmg_locations->qual[i].unit				= uar_get_code_display(l2.location_cd)
		cmg_locations->qual[i].org_id			= o.organization_id
		cmg_locations->qual[i].org_name			= o.org_name
	foot report
		cmg_locations->cnt = i
	with nocounter
	
	call SubroutineLog("cmg_locations","record")
	call SubroutineLog(build2('end sGetCMGLocations(null)'))
	
	return	(cnvtrectojson(cmg_locations))
	
end
 
call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
