/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-2005 Cerner Corporation                 *
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

        Source file name:       cov_sn_sched_driver.prg
        Object name:			cov_sn_sched_driver

        Product:
        Product Team:
        HNA Version:
        CCL Version:

        Program purpose:

        Tables read:


        Tables updated:         -

******************************************************************************/


;~DB~************************************************************************
;    *    GENERATED MODIFICATION CONTROL LOG              *
;    ****************************************************************************
;    *                                                                         *
;    *Mod Date       Engineeer          Comment                                *
;    *--- ---------- ------------------ -----------------------------------    *
;     000 18-10-22  					initial release			       *
;     001 14-06-18   CCUMMIN4           added modifiers			           *
;	  002 25-06-19   CCUMMIN4			correctd per CR 5202 https://wiki.cerner.com/x/Za0Neg
;	  003 27-06-19   CCUMMIN4			changed to use the primary synonym on the procedure code
;     004 02-10-19	 CCUMMIN4			CR 6436 https://wiki.cerner.com/x/_xLCfg corrected modifier
;	  005 11-06-19	 CCUMMIN4			Changed to private comments
;~DE~***************************************************************************


;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************

drop program cov_sn_sched_driver:dba go
create program cov_sn_sched_driver:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Report or Grid" = 0
	, "Facility" = 0
	, "Surgical Area" = 0
	, "Start Date" = "SYSDATE"               ;* Enter Start Date
	, "End Date" = "SYSDATE" 

with OUTDEV, RPT_GRID_PMPT, FACILITY, SURG_AREA, StartDate, EndDate


call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

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

call set_codevalues(null)
call check_ops(null)

if (not(validate(t_rec,0)))
free set t_rec
record t_rec
(
	1 organization_id				= f8
	1 org_name						= vc
	1 facility_prompt				= f8
	1 start_dt_tm_prompt			= dq8
	1 end_dt_tm_prompt				= dq8
	1 area_cnt						= i2
	1 printed_by					= vc
	1 area_qual[*]
	 2 sched_surg_area_cd			= f8
	1 cnt							= i4
	1 qual[*]    
	 2 encntr_id					= f8
	 2 person_id					= f8
	 2 sch_event_id					= f8
	 2 surg_case_id					= f8
	 2 sched_seq_num				= i2
	 2 sched_start_dt_tm			= f8
	 2 create_dt_tm					= f8
	 2 sched_ud1_cd					= f8
	 2 sched_dur					= i4
	 2 sched_surg_area_cd			= f8
	 2 sched_op_loc_cd				= f8
	 2 sched_pat_type_cd			= f8
	 2 sched_type_cd				= f8
	 2 surg_case_nbr_formatted		= vc
	 2 patient_name					= vc
	 2 sex_cd						= f8
	 2 age							= c12
	 2 dob							= dq8
	 2 loc_nurse_unit_cd			= f8
	 2 loc_facility_cd				= f8
	 2 loc_room_cd 					= f8
	 2 loc_bed_cd					= f8
	 2 encntr_type_cd				= f8
	 2 ip_room						= vc
	 2 fin							= vc
	 2 mrn							= vc
	 2 primary_surgeon				= vc
	 2 secondary_surgeon			= vc
	 2 sched_primary_surgeon_id		= f8
	 2 surgeon1_detail				= vc
	 2 surgeon2_detail				= vc
	 2 sched_surg_proc_cd			= f8
	 2 procedure					= vc
	 2 proc_text					= vc
	 2 sched_anesth_type_cd			= f8
	 2 surgery_comment				= vc
	 2 phone						= vc
	 2 phone_type_cd				= f8
	 2 phone_prefered_cd			= f8
	 2 phone_ind					= i2
	 2 phone_final					= vc
	 2 alt_phone					= vc
	 2 alt_phone_type_cd			= f8
	 2 medical_service				= vc
	 2 modifier						= c100 ;001
)
endif

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->start_dt_tm_prompt 	= cnvtdatetime($StartDate)
set t_rec->end_dt_tm_prompt		= cnvtdatetime($EndDate)

set t_rec->facility_prompt		= $3 ;$Facility

select into "nl:"
from 
	organization org
plan org
	where 	org.organization_id	=	t_rec->facility_prompt
detail
	t_rec->organization_id	= org.organization_id
	t_rec->org_name			= org.org_name
with nocounter

IF (validate (reqinfo->updt_id ,999 ) != 999  )

  SELECT INTO "nl:"
   p_name = trim (p.name_full_formatted )
   FROM (prsnl p )
   PLAN (p
    WHERE (p.person_id = reqinfo->updt_id ) )
   DETAIL
    t_rec->printed_by = trim (p_name ,3 )
   WITH nocounter
  ;end select
 ENDIF
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Locations **********************************"))

select into "nl:"
from
	code_value cv
plan cv
	where cv.code_set		= 221
	and   cv.active_ind		= 1
/*	and   cv.code_value		in(
										 2555150435.00	;COV Master Procedures
										,2557236019.00	;FLMC Endoscopy
										,2557236003.00	;FLMC Main OR
										,2557236583.00	;FLMC Non Surgical
										,2557236531.00	;FLMC PreAdmission Testing
										,32216055.00	;FSR Endoscopy
										,32216067.00	;FSR Labor and Delivery
										,25442723.00	;FSR Main OR
										,2561496783.00	;FSR Non Endo Procedure
										,2552923987.00	;FSR Non-Surgical
										,25442735.00	;FSR PreAdmission Testing
										,2552926567.00	;LCMC Endoscopy
										,2552926545.00	;LCMC Labor and Delivery
										,2552926529.00	;LCMC Main OR
										,2552926595.00	;LCMC Non Surgical
										,2552926505.00	;LCMC PreAdmission Testing
										,2562751609.00	;MHA Endoscopy
										,2562751555.00	;MHA Main OR
										,2562751631.00	;MHA Non Surgical
										,2562751685.00	;MHA Preadmission Testing
										,2557462459.00	;MHHS Endoscopy
										,2557462433.00	;MHHS Labor and Delivery
										,2557462381.00	;MHHS Main OR
										,2557462497.00	;MHHS Non Surgical
										,2557462357.00	;MHHS PreAdmission Testing
										,2554023973.00	;MMC Endoscopy
										,2554024337.00	;MMC Labor and Delivery
										,2554023941.00	;MMC Main OR
										,2554023989.00	;MMC Non-Surgical
										,2554023957.00	;MMC PreAdmission Testing
										,2557228455.00	;PWMC Endoscopy
										,2557228471.00	;PWMC Labor and Delivery
										,2557228439.00	;PWMC Main OR
										,2560310083.00	;PWMC Non Endo Procedure
										,2557228487.00	;PWMC Non Surgical
										,2557228423.00	;PWMC PreAdmission Testing
										,2554024461.00	;RMC Endoscopy
										,2554024417.00	;RMC Main OR
										,2554024477.00	;RMC Non-Surgical
										,2554024433.00	;RMC PreAdmission Testing
							  ) */
	and   cv.code_value		= $4
order by
	 cv.display
	,cv.code_value
head cv.code_value
	t_rec->area_cnt = (t_rec->area_cnt + 1)
	stat = alterlist(t_rec->area_qual,t_rec->area_cnt)
	t_rec->area_qual[t_rec->area_cnt].sched_surg_area_cd 	= cv.code_value
with nocounter

call writeLog(build2("* END   Finding Locations **********************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Appointments *******************************"))

select into "nl:"
from
	 surgical_case 			sc
	,encounter				e
	,person					p
	,sch_event				se
	,sch_event_attach		sea
	,surg_case_procedure	scp
	,sch_event_patient		sep
	;,prsnl					spr
	;,prsnl					pr
	,order_catalog_synonym ocs ;003
plan sc
	where 	expand(i,1,t_rec->area_cnt,sc.sched_surg_area_cd,t_rec->area_qual[i].sched_surg_area_cd)
	and		sc.active_ind 			= 1
	and		sc.cancel_dt_tm			= null
	and     sc.sched_start_dt_tm	between
										cnvtdatetime(t_rec->start_dt_tm_prompt)
											and
										cnvtdatetime(t_rec->end_dt_tm_prompt)
join p
	where 	p.person_id				= sc.person_id
join e
	where	e.encntr_id				= sc.encntr_id
	and		e.active_ind			= 1
join sea
	where	sea.sch_event_id		= sc.sch_event_id
	and		sea.state_meaning		= "ACTIVE"
	and 	sea.version_dt_tm 		= cnvtdatetime ("31-DEC-2100 00:00:00.00" )
	and 	sea.active_ind 			= 1
	and 	sea.order_status_cd		!= code_values->cv.cs_6004.canceled_cd
join se	
	where	se.sch_event_id 		= sc.sch_event_id
	and 	se.sch_state_cd 		not in(
												 code_values->cv.cs_14233.canceled_cd
												,code_values->cv.cs_14233.deleted_cd
												,code_values->cv.cs_14233.unschedulable_cd
												,code_values->cv.cs_14233.pending_cd
											)
	and 	se.version_dt_tm 		= cnvtdatetime ("31-DEC-2100 00:00:00.00" )
	and 	se.active_ind 			= 1
join scp 
	where 	scp.order_id			= sea.order_id
join sep 
	where 	sep.sch_event_id 		= se.sch_event_id
	and 	sep.version_dt_tm 		= cnvtdatetime ("31-DEC-2100 00:00:00.00" )
	and 	sep.active_ind 			= 1	
;003 start
join ocs
	where 	ocs.catalog_cd			= scp.sched_surg_proc_cd
	and     ocs.mnemonic_type_cd 	= value(uar_get_code_by("MEANING", 6011,"PRIMARY"))
;003 end
order by
		 sc.sched_surg_area_cd
		,sc.sched_start_dt_tm
		,sc.sched_op_loc_cd
		,sc.surg_case_nbr_formatted
		,scp.surg_case_id
		,scp.sched_seq_num
		
head report	
	call writeLog(build2(">>>Entering Report Writer"))
	stat = alterlist(t_rec->qual,100)
head scp.surg_case_id
	call writeLog(build2("--->Adding Case:",trim(cnvtstring(scp.surg_case_id)),":",trim(sc.surg_case_nbr_formatted)))
	t_rec->cnt 	= (t_rec->cnt + 1)
	if (mod(t_rec->cnt,100) = 1)
		stat = alterlist(t_rec->qual, (t_rec->cnt + 99))
	endif
	
	t_rec->qual[t_rec->cnt].encntr_id					= e.encntr_id 
	t_rec->qual[t_rec->cnt].person_id					= e.person_id
	t_rec->qual[t_rec->cnt].sch_event_id				= se.sch_event_id
	t_rec->qual[t_rec->cnt].surg_case_id				= sc.surg_case_id
	t_rec->qual[t_rec->cnt].sched_seq_num				= scp.sched_seq_num
	t_rec->qual[t_rec->cnt].sched_start_dt_tm			= sc.sched_start_dt_tm
	t_rec->qual[t_rec->cnt].create_dt_tm				= sc.create_dt_tm
	t_rec->qual[t_rec->cnt].sched_ud1_cd				= scp.sched_ud1_cd			
	t_rec->qual[t_rec->cnt].sched_dur					= sc.sched_dur
	t_rec->qual[t_rec->cnt].sched_surg_area_cd			= sc.sched_surg_area_cd
	t_rec->qual[t_rec->cnt].sched_op_loc_cd				= sc.sched_op_loc_cd
	t_rec->qual[t_rec->cnt].sched_pat_type_cd			= sc.sched_pat_type_cd
	t_rec->qual[t_rec->cnt].sched_type_cd				= sc.sched_type_cd
	t_rec->qual[t_rec->cnt].surg_case_nbr_formatted		= sc.surg_case_nbr_formatted
	t_rec->qual[t_rec->cnt].patient_name				= p.name_full_formatted
	t_rec->qual[t_rec->cnt].sex_cd						= p.sex_cd
	t_rec->qual[t_rec->cnt].age							= cnvtage(p.birth_dt_tm)
	t_rec->qual[t_rec->cnt].dob							= p.birth_dt_tm
	t_rec->qual[t_rec->cnt].loc_facility_cd				= e.loc_facility_cd
	t_rec->qual[t_rec->cnt].loc_nurse_unit_cd			= e.loc_nurse_unit_cd
	t_rec->qual[t_rec->cnt].loc_room_cd					= e.loc_room_cd
	t_rec->qual[t_rec->cnt].loc_bed_cd					= e.loc_bed_cd
	t_rec->qual[t_rec->cnt].encntr_type_cd				= e.encntr_type_cd
	t_rec->qual[t_rec->cnt].sched_primary_surgeon_id	= scp.sched_primary_surgeon_id
	t_rec->qual[t_rec->cnt].sched_surg_proc_cd			= scp.sched_surg_proc_cd
	;002 t_rec->qual[t_rec->cnt].procedure					= uar_get_code_description(scp.sched_surg_proc_cd)
	;003 t_rec->qual[t_rec->cnt].procedure					= uar_get_code_display(scp.sched_surg_proc_cd) ;002
	t_rec->qual[t_rec->cnt].procedure					= ocs.mnemonic ;003
	t_rec->qual[t_rec->cnt].proc_text					= trim(replace(scp.proc_text ,concat(char(13),char(10)),"; " ),3)
	t_rec->qual[t_rec->cnt].sched_anesth_type_cd		= scp.sched_anesth_type_cd
	t_rec->qual[t_rec->cnt].medical_service				= uar_get_code_display(e.med_service_cd)
	t_rec->qual[t_rec->cnt].modifier					= scp.modifier
	;004 start
	if (sc.surg_complete_qty = 0)
		t_rec->qual[t_rec->cnt].modifier					= scp.sched_modifier
	endif
	;004 end
foot report
	stat = alterlist(t_rec->qual, t_rec->cnt)
	call writeLog(build2("<<<Exiting Report Writer"))
with nocounter
call writeLog(build2("* END   Finding Appointments *******************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Surgeon Details ****************************"))

select into "nl:"
from
	 (dummyt d1 with seq = t_rec->cnt)
	,sch_event_detail sed
plan d1
join sed
	where	sed.sch_event_id		= t_rec->qual[d1.seq].sch_event_id
	and		sed.oe_field_meaning	in(
											 "SURGEON1"
											,"SURGEON2"
										)
	and		sed.version_dt_tm		= cnvtdatetime ("31-DEC-2100 00:00:00.00") 
	and		sed.active_ind			= 1
order by
	 sed.sch_event_id
	,sed.oe_field_meaning
	,sed.beg_effective_dt_tm desc
head report
	call writeLog(build2(">>>Entering Report Writer"))
head sed.sch_event_id
	call writeLog(build2("--->Reviewing Case:",trim(t_rec->qual[d1.seq].surg_case_nbr_formatted)))
	call writeLog(build2("--->sch_event_id = ",trim(cnvtstring(sed.sch_event_id))))
head sed.oe_field_meaning
	call writeLog(build2("_____Found ",trim(sed.oe_field_meaning)))
	case (sed.oe_field_meaning)
		of "SURGEON1":	t_rec->qual[d1.seq].surgeon1_detail		= sed.oe_field_display_value
						t_rec->qual[d1.seq].primary_surgeon		= sed.oe_field_display_value
		of "SURGEON2":	t_rec->qual[d1.seq].surgeon2_detail		= sed.oe_field_display_value
	endcase
foot report
	call writeLog(build2("<<<Exiting Report Writer"))
with nocounter


call writeLog(build2("* END   Finding Surgeon Details ****************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Comment Details ****************************"))

select into "nl:"
from
	 (dummyt d1 with seq = t_rec->cnt)
	,sch_event_comm sed
	,long_text lt
	
plan d1
join sed
	where	sed.sch_event_id		= t_rec->qual[d1.seq].sch_event_id
	and		sed.sub_text_meaning	in(
											 ;005 "SURGPUBLIC"
											 "SURGPRIVATE" ;005
										)
	and		sed.version_dt_tm		= cnvtdatetime ("31-DEC-2100 00:00:00.00") 
	and		sed.active_ind			= 1
join lt
	where 	lt.long_text_id			= sed.text_id
order by
	 sed.sch_event_id
	,sed.sub_text_meaning
	,sed.beg_effective_dt_tm desc
head report
	call writeLog(build2(">>>Entering Report Writer"))
head sed.sch_event_id
	call writeLog(build2("--->Reviewing Case:",trim(t_rec->qual[d1.seq].surg_case_nbr_formatted)))
	call writeLog(build2("--->sch_event_id = ",trim(cnvtstring(sed.sch_event_id))))
head sed.sub_text_meaning
	call writeLog(build2("_____Found ",trim(sed.sub_text_meaning)))
	call writeLog(build2("_____long_text_id = ",trim(cnvtstring(lt.long_text_id))))
	t_rec->qual[d1.seq].surgery_comment	= trim(replace(lt.long_text,concat(char(13),char(10)),"; "),3)
foot report
	call writeLog(build2("<<<Exiting Report Writer"))
with nocounter

call writeLog(build2("* END   Finding Comment Details ****************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding FIN          *******************************"))

select into "nl:"
from
	 (dummyt d1 with seq = t_rec->cnt)
	,encntr_Alias ea
plan d1
join ea
	where	ea.encntr_id		= t_rec->qual[d1.seq].encntr_id
	and		ea.active_ind		= 1
	and		ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and		ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and		ea.encntr_alias_type_cd = code_values->cv.cs_319.fin_nbr_cd		
order by
	  ea.encntr_id
	 ,ea.beg_effective_dt_tm 
head report
	call writeLog(build2(">>>Entering Report Writer"))
head ea.encntr_id
	call writeLog(build2("--->Reviewing Case:",trim(t_rec->qual[d1.seq].surg_case_nbr_formatted)))
	call writeLog(build2("--->encntr_id = ",trim(cnvtstring(ea.encntr_id))))
detail
	t_rec->qual[d1.seq].fin = ea.alias
foot report
	call writeLog(build2("<<<Exiting Report Writer"))
with nocounter

call writeLog(build2("* END   Finding FIN          *******************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding MRN          *******************************"))

select into "nl:"
from
	 (dummyt d1 with seq = t_rec->cnt)
	,encntr_Alias ea
plan d1
join ea
	where	ea.encntr_id		= t_rec->qual[d1.seq].encntr_id
	and		ea.active_ind		= 1
	and		ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and		ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and		ea.encntr_alias_type_cd = code_values->cv.cs_319.mrn_cd		
order by
	  ea.encntr_id
	 ,ea.beg_effective_dt_tm 
head report
	call writeLog(build2(">>>Entering Report Writer"))
head ea.encntr_id
	call writeLog(build2("--->Reviewing Case:",trim(t_rec->qual[d1.seq].surg_case_nbr_formatted)))
	call writeLog(build2("--->encntr_id = ",trim(cnvtstring(ea.encntr_id))))
detail
	t_rec->qual[d1.seq].mrn = ea.alias
foot report
	call writeLog(build2("<<<Exiting Report Writer"))
with nocounter

call writeLog(build2("* END   Finding MRN          *******************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Prefered Phone *****************************"))

select into "nl:"
from
	 (dummyt d1 with seq = t_rec->cnt)
	,person_info ea
plan d1
join ea
	where	ea.person_id		= t_rec->qual[d1.seq].person_id
	and ea.info_sub_type_cd = value(uar_get_code_by("MEANING",356,"PREFPHONE"))
    and ea.active_ind = 1
    and cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm	
order by
	  ea.person_id
	 ,ea.beg_effective_dt_tm  
head report
	call writeLog(build2(">>>Entering Report Writer"))
detail
	t_rec->qual[d1.seq].phone_prefered_cd = ea.value_cd
	case (ea.value_cd)
		of 26495467:	t_rec->qual[d1.seq].phone_type_cd = 0.0;			No Phone
		of 25735529:	t_rec->qual[d1.seq].phone_type_cd =	161;			Alternate Phone Number
		of 25342455:	t_rec->qual[d1.seq].phone_type_cd =	163;			Work Phone Number
		of 25341085:	t_rec->qual[d1.seq].phone_type_cd = 170;			Home Phone Number
		of 25342449:	t_rec->qual[d1.seq].phone_type_cd =	4149712;		Mobile Phone Number
	endcase
foot report
	call writeLog(build2("<<<Exiting Report Writer"))
with nocounter


select into "nl:"
from
	 (dummyt d1 with seq = t_rec->cnt)
	,phone ea
plan d1
join ea
	where	ea.parent_entity_id		= t_rec->qual[d1.seq].person_id
	and ea.phone_type_cd =  t_rec->qual[d1.seq].phone_type_cd
	and ea.parent_entity_name = "PERSON"
	and ea.phone_num_key > " "
	and ea.phone_num_key != "NONE"
    and ea.active_ind = 1
    and cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm	
order by
	  ea.parent_entity_id
	 ,ea.beg_effective_dt_tm 
head report
	call writeLog(build2(">>>Entering Report Writer"))
detail
	t_rec->qual[d1.seq].phone = format(ea.phone_num_key,"(###)###-####;;") 
	t_rec->qual[d1.seq].phone_ind = 1 ;preferred phone number
	t_rec->qual[d1.seq].phone_final = concat(trim(uar_get_code_display(ea.phone_type_cd))," (preferred)")
foot report
	call writeLog(build2("<<<Exiting Report Writer"))
with nocounter

select into "nl:"
from
	 (dummyt d1 with seq = t_rec->cnt)
	,phone ea
plan d1
	where  t_rec->qual[d1.seq].phone_ind = 0
join ea
	where	ea.parent_entity_id		= t_rec->qual[d1.seq].person_id
	and ea.phone_type_cd =  170
	and ea.parent_entity_name = "PERSON"
	and ea.phone_num_key > " "
	and ea.phone_num_key != "NONE"
    and ea.active_ind = 1
    and cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm	
order by
	  ea.parent_entity_id
	 ,ea.beg_effective_dt_tm 
head report
	call writeLog(build2(">>>Entering Report Writer"))
detail
	t_rec->qual[d1.seq].phone = format(ea.phone_num_key,"(###)###-####;;") 
	t_rec->qual[d1.seq].phone_ind = 2 ;home phone number
	t_rec->qual[d1.seq].phone_final = trim(uar_get_code_display(ea.phone_type_cd))
foot report
	call writeLog(build2("<<<Exiting Report Writer"))
with nocounter

call writeLog(build2("* END Finding Prefered Phone *****************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Appointments *******************************"))
call writeLog(build2("* END   Finding Appointments *******************************"))
call writeLog(build2("************************************************************"))


#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go

