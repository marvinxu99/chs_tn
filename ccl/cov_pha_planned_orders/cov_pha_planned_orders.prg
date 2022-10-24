/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_pha_planned_orders.prg
	Object name:		cov_pha_planned_orders
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_pha_planned_orders:dba go
create program cov_pha_planned_orders:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Facility Search" = "*"
	, "Select Facility:" = 0
	, "Case Areas" = 0
	, "Begin Date:" = ""
	, "End Date" = "" 

with OUTDEV, FSEARCH, FACILITY, SURG_AREA, BEG_DATE, END_DATE


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
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

;free set t_rec
record t_rec
(
	1 cnt			= i4
	1 prompts
	 2 outdev		= vc
	 2 start_dt_tm	= vc
	 2 end_dt_tm	= vc
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 run_dt_tm 	= dq8
	1 dates
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
	1 qual[*]
	 2 person_id	= f8
	 2 encntr_id	= f8
	 2 mrn			= vc
	 2 fin			= vc
	 2 name_full_formatted = vc
)

;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->prompts.outdev = $OUTDEV

set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Orders   ***********************************"))

declare pNUM = i4
declare eNUM = i4
 
record pat_list (
  1 pat_list [*]  
    2 person_id = f8   
    2 encntr_id = f8   
) 

/*Get list of person_id and encntr_id from surgical case*/

select into "nl:"
p.name_full_formatted,
p.person_id,
e.encntr_id,
procedure = uar_get_code_display(scp.surg_proc_cd)
from
  surgical_case sc,
  surg_case_procedure scp,
  encounter e,
  person p
plan sc
  where sc.sched_start_dt_tm between cnvtdatetime($BEG_DATE) and cnvtdatetime($END_DATE)
  and sc.cancel_reason_cd = 0
  and (sc.surg_area_cd  = $SURG_AREA
       or sc.sched_surg_area_cd = $SURG_AREA
				)
join scp
  where scp.surg_case_id = sc.surg_case_id
  and scp.active_ind = 1
 
join e
  where e.encntr_id = sc.encntr_id
	and e.loc_facility_cd = $FACILITY

join p
	where e.person_id = p.person_id
head report
cnt = 0 
detail
cnt = cnt+1
stat = alterlist(pat_list->pat_list,cnt)
pat_list->pat_list[cnt]->person_id = p.person_id
pat_list->pat_list[cnt]->encntr_id = e.encntr_id
with nullreport




free record planned_ords
record planned_ords
 ( 1 planned_ords[*]
 	2 power_plan = c200
 	2 phase = c200
 	2 sub_phase = c200
 	2 mnem = c200
 	2 sent = c200
 	2 patient = c200
 	2 MRN = c200
 	2 FIN = c200
 	2 facility = vc
 	)
 	

SELECT into "nl:"
	POWER_PLAN = if(pw.type_mean = "CAREPLAN")
					 (trim(pw.description))
				 else
				 	(trim(pw.pw_group_desc))
				 endif
	, phase_sort = if(pw.type_mean = "PHASE" and pcat.sub_phase_ind = 0)
						cnvtupper(trim(pw.description))
			 		elseif(pw.type_mean = "SUBPHASE" and pcat.sub_phase_ind = 1)
						cnvtupper(trim(pw.parent_phase_desc))
			 		endif
	, sub_phase = if(pw.type_mean = "SUBPHASE")
					trim(pw.description)
				  endif
	, Order_mnemonic = trim(ocs.mnemonic)
	, Order_sentence = if(apc.parent_entity_name = "ORDERS")
					os.order_sentence_display_line
				 elseif(apc.parent_entity_name = "PROPOSAL")
				    op.clinical_display_line
				 endif
	, Patient = trim(p.name_full_formatted)
	, MRN = pa.alias
	, FIN = ea.alias

FROM
	act_pw_comp   apc
	, pathway_comp   pcomp
	, person   p
	, person_alias   pa
	, encounter   e
	, encntr_alias   ea
	, pathway   pw
	, pathway_catalog   pcat
	, order_catalog   oc
	, order_catalog_synonym   ocs
	, order_proposal   op
	, order_sentence   os

plan apc
where  

(expand(pNUM,
				1,
				size(pat_list->pat_list,5),
				apc.person_id,
				pat_list->pat_list[pNUM]->person_id)
		or
		expand(eNUM,
				1,
				size(pat_list->pat_list,5),
				apc.encntr_id,
				pat_list->pat_list[eNUM]->encntr_id))
				
and apc.included_ind = 1
and apc.activated_ind = 0
and apc.active_ind = 1

join pcomp
where pcomp.pathway_comp_id = apc.pathway_comp_id

join p
where p.person_id = apc.person_id

join pa
where pa.person_id = (p.person_id)
and pa.person_alias_type_cd = (value(uar_get_code_by("MEANING", 4, "CMRN")))

join e
where e.encntr_id = apc.encntr_id

join ea
where ea.encntr_id = (e.encntr_id)
and ea.encntr_alias_type_cd = (value(uar_get_code_by("MEANING", 319, "FIN NBR")))

join pw
where pw.pathway_id = apc.pathway_id
and pw.pw_status_cd =      674355.00
join pcat
where pcat.pathway_catalog_id = pw.pathway_catalog_id

join ocs
where ocs.synonym_id = apc.ref_prnt_ent_id
and ocs.catalog_type_cd = 2516

join oc
where oc.catalog_cd = ocs.catalog_cd

join os
where os.order_sentence_id = outerjoin(apc.order_sentence_id)

join op
where op.order_proposal_id = outerjoin(apc.parent_entity_id)

head report
cnt = 0
detail
cnt = cnt+1
stat = alterlist(planned_ords->planned_ords, cnt)
    planned_ords->planned_ords[cnt]->power_plan =  pw.pw_group_desc
  
  if(pw.type_mean = "PHASE" and pcat.sub_phase_ind = 0)  
     planned_ords->planned_ords[cnt]->phase = (trim(pw.description))
  elseif(pw.type_mean = "SUBPHASE" and pcat.sub_phase_ind = 1)
     planned_ords->planned_ords[cnt]->phase = (trim(pw.parent_phase_desc))
  endif
  
   if(pw.type_mean = "SUBPHASE")
    planned_ords->planned_ords[cnt]->sub_phase  = trim(pw.description)
   endif
   
    planned_ords->planned_ords[cnt]->mnem  = trim(ocs.mnemonic)
    
   if(apc.parent_entity_name = "ORDERS") 
      planned_ords->planned_ords[cnt]->sent  = trim(os.order_sentence_display_line)
    elseif(apc.parent_entity_name = "PROPOSAL")
      planned_ords->planned_ords[cnt]->sent  =   trim(op.clinical_display_line)
    endif
    
    
    planned_ords->planned_ords[cnt]->patient  = trim(p.name_full_formatted)
    planned_ords->planned_ords[cnt]->MRN  = trim(pa.alias)
    planned_ords->planned_ords[cnt]->FIN = trim(ea.alias)
    planned_ords->planned_ords[cnt]->facility = trim(uar_get_code_display(e.loc_facility_cd))
    
with nocounter

call echorecord(planned_ords)
   
call writeLog(build2("* END   Finding Diagnosis   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

SELECT into $OUTDEV
      Facility = trim(planned_ords->planned_ords[d.seq]->facility)
    , MRN = trim(planned_ords->planned_ords[d.seq]->MRN)
	, FIN = trim(planned_ords->planned_ords[d.seq]->FIN)
	, Patient = trim(planned_ords->planned_ords[d.seq]->patient)
	, POWER_PLAN = trim(planned_ords->planned_ords[d.seq]->power_plan )
	, phase = trim(planned_ords->planned_ords[d.seq]->phase)
	, sub_phase = trim(planned_ords->planned_ords[d.seq]->sub_phase)
	, Order_mnemonic = trim(planned_ords->planned_ords[d.seq]->mnem )
	, Order_sentence = trim(planned_ords->planned_ords[d.seq]->sent)
	

FROM
	(dummyt   d  with seq = value(size(planned_ords->planned_ords, 5)))

plan d

ORDER BY
	Patient
	, POWER_PLAN
	, phase
	, sub_phase
	, order_mnemonic

WITH format, separator = " "


call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

/*
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit *************************************"))
	call writeAudit(build2(
							char(34),^ITEM^,char(34),char(44),
							char(34),^DESC^,char(34)
						))
for (i=1 to t_rec->cnt)
		call writeAudit(build2(
							char(34),t_rec->qual[i].a											,char(34),char(44),
							char(34),t_rec->qual[i].b											,char(34)
						))

endfor
call writeLog(build2("* END   Creating Audit *************************************"))
call writeLog(build2("************************************************************"))
*/

#exit_script
;001 end

;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)


call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go
