/***********************Change Log*************************
VERSION 	 DATE       ENGINEER            COMMENT
-------	 	-------    	-----------         ------------------------
1.0			5/23/2017	Ryan Gotsche		Initial Development
2.0			6/16/2017	Ryan Gotsche		Design Finalized
3.0			6/22/2017	Ryan Gotsche		CR-0045 - Added Fall Risk Logic
4.0			9/15/2017	Ryan Gotsche		CR-0322 - Dosing Weight Updates
5.0         1/16/2018   Jeremy Moore        CR-1051 - Display mutiple isolation status
6.0			5/24/2018	Ryan Gotsche		CR-1987 - Display only Primary Insurance
7.0			9/18/2019	Chad Cummings		CR-5599 - Added diagnosis check for fall risk
8.0		   10/27/2020	Chad Cummings		CR-0000 - Removed Fall Risk problem timeframe
**************************************************************/
 
/***********************PROGRAM NOTES*************************
Description - The Custom Banner Bar is loaded on each refresh
	within FirstNet.
 
	With a custom banner bar you introduce the flexabiltiy to
	quality on client specific criteria desired to be face-up
	in the clinical banner bar.
 
Tables Read: CLINICAL_EVENT, ORDERS, ORDER_DETAIL, ENCOUNTER,
	ENCNTR_PLAN_RELTN, HEALTH_PLAN, PROBLEM, NOMENCLATURE
 
Tables Updated: None
 
Scripts Executed: None
**************************************************************/
 
drop program test_pc_custom_banner_bar go
create program test_pc_custom_banner_bar
 
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
declare CustomField1(null) = null with Protect
declare CustomField2(null) = null with Protect
declare CustomField3(null) = null with Protect
declare CustomField4(null) = null with Protect
declare CustomField5(null) = null with Protect
declare ParseRequest(null) = null with Protect
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare iCustomFieldIndex = i4 with noconstant(0), Protect
declare iCustFieldCnt = i4 with Constant(size(request->custom_field, 5)),Protect
 
/****************************************************************************
*  Internationalization Declaration                                           *
*****************************************************************************/
 if (validate(i18nuar_def, 999)=999)
    call echo("Declaring i18nuar_def")
    declare i18nuar_def = i2 with persist
    set i18nuar_def = 1
    declare uar_i18nlocalizationinit(p1=i4, p2=vc, p3=vc, p4=f8) = i4 with persist
    declare uar_i18ngetmessage(p1=i4, p2=vc, p3=vc) = vc with persist
    declare uar_i18nbuildmessage() = vc with persist
 endif
   declare i18nHandle = i4 with persistscript
   call uar_i18nlocalizationinit(i18nHandle,curprog,"",curcclrev)
 
/****************************************************************************
*       Set Variables - Internationalized                                   *
*****************************************************************************/
 
/**Title and Section Labels**/
set NoResusitationData  = uar_i18ngetmessage(i18nHandle, "NoResusitationData","")
set NoIsolationData     = uar_i18ngetmessage(i18nHandle, "NoIsolationData","")
set NoWeightData	    = uar_i18ngetmessage(i18nHandle, "NoWeightData","")
set NoHealthPlanData	= uar_i18ngetmessage(i18nHandle, "NoHealthPlanData","")
set NoFallRiskData		= uar_i18ngetmessage(i18nHandle, "NoFallRiskData"," No")

/**************************************************************
; DVDev Start Coding
**************************************************************/
set reply->status_data->status = "F"
set stat = alterlist (reply->custom_field, iCustFieldCnt)
 
call ParseRequest(null)
 
set stat = alterlist (reply->custom_field, iCustomFieldIndex)
set reply->status_data->status = "S"
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
subroutine ParseRequest(x)
 
for(ind = 1 to iCustFieldCnt)
 
	case (request->custom_field[ind].custom_field_show)
		of 1:
			call CustomField1(null)
		of 2:
			call CustomField2(null)
		of 3:
			call CustomField3(null)
		of 4:
			call CustomField4(null)
		of 5:
			call CustomField5(null)
	endcase
 
endfor
 
end
 
;Dose Weight
subroutine CustomField1(null)
 
	declare 72_CLINICALWT      = f8 with constant(uar_get_code_by_cki("CKI.EC!9528")),protect
	declare 8_ALTERED   	   = f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!16901")),protect
	declare 8_AUTH             = f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!2628")),protect
	declare 8_MODIFIED         = f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!2636")),protect
	declare 89_POWERCHART      = f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!4835")),protect
 
	set iCustomFieldIndex                                                  = iCustomFieldIndex + 1
	set reply->custom_field[iCustomFieldIndex].custom_field_index          = 1
	set reply->custom_field[iCustomFieldIndex].custom_field_display        = ""
 
	select into "nl:"
	     ce.event_cd,
	     ce.clinical_event_id,
	     p.birth_dt_tm
 
	from clinical_event ce, person p
	plan ce
	where ce.person_id             = request->person_id
	  and ce.encntr_id             = request->encntr_id
	  and ce.event_cd              = 72_CLINICALWT
	  and ce.valid_until_dt_tm     = cnvtdatetime("31-DEC-2100 00:00:00")
	  and ce.result_status_cd      in (8_ALTERED,8_AUTH,8_MODIFIED)
	  and ce.view_level            = 1
	  and ce.publish_flag          = 1
	  and ce.CONTRIBUTOR_SYSTEM_CD = 89_POWERCHART
	join p
	where p.person_id = ce.person_id
 
	order by
	   ce.event_end_dt_tm desc
 
	head ce.event_cd
	if (p.birth_dt_tm > cnvtlookbehind("3,y"))
	 reply->custom_field[iCustomFieldIndex].custom_field_display =
			build2(" ",trim(cnvtstring(ce.result_val,10,2))," ",trim(uar_get_code_display(ce.result_units_cd),3)," ","(",
			trim(format(ce.updt_dt_tm, "MM/DD/YY"),3),")")
	else
	 reply->custom_field[iCustomFieldIndex].custom_field_display =
			build2(" ",trim(ce.result_val,3)," ",trim(uar_get_code_display(ce.result_units_cd),3)," ","(",
			trim(format(ce.updt_dt_tm, "MM/DD/YY"),3),")")
 	endif
	with nocounter
 
	if(curqual = 0)
	   set reply->custom_field[iCustomFieldIndex].custom_field_display        = NoWeightData
	endif
end
 
;Code Status / Resuscitation Status
subroutine CustomField2(null)
 
    declare 200_RESUS_STATUS_CD    = f8 with constant(uar_get_code_by("MEANING",200,"CODESTATUS")),protect
    declare 6004_ORDERED_STATUS_CD = f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!3102")), protect
	declare 16449_RESUS_TYPE_CD    = f8 with constant(uar_get_code_by("DISPLAY_KEY",16449,"RESUSCITATIONSTATUS")), protect
	declare 16449_RESUS_TYPE_CD1   = f8 with constant(uar_get_code_by("DISPLAY_KEY",16449,"RESUSCITATION STATUS")), protect
    set  icustomfieldindex         =  icustomfieldindex +1
 
	select into "nl"
	from
	  orders  o,
	  order_detail  od
	plan o
	  where o.encntr_id            = request->encntr_id
	    and o.catalog_cd           = 200_RESUS_STATUS_CD
	    and o.order_status_cd      = 6004_ORDERED_STATUS_CD
	    and o.active_ind           = 1
	join od
	  where od.order_id            = o.order_id
	    and od.oe_field_id         in( 16449_RESUS_TYPE_CD,16449_RESUS_TYPE_CD1)
	    and od.action_sequence     = (select max(od2.action_sequence) from order_detail od2 where od.order_id = od2.order_id
       								and od2.oe_field_id in(16449_RESUS_TYPE_CD,16449_RESUS_TYPE_CD1) )
	order by o.order_id, od.oe_field_id, od.action_sequence desc, od.detail_sequence desc
 
  	head o.order_id
 
	   reply->custom_field[iCustomFieldIndex].custom_field_display             = trim(od.oe_field_display_value)
	   reply->custom_field[iCustomFieldIndex].custom_field_index               = 2
 
	with nocounter
 
    if(curqual = 0)
	   set reply->custom_field[iCustomFieldIndex].custom_field_display        = NoResusitationData
	   set reply->custom_field[iCustomFieldIndex].custom_field_index          = 2
	endif
end
 
;Isolation Code
subroutine CustomField3(null)
 
    declare 200_ISOLATION_STATUS_CD   = f8 with constant(uar_get_code_by("MEANING",200,"ISOLATION")),protect
	declare 6004_ORDERED_STATUS_CD    = f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!3102")), protect
	declare 16449_ISOLATION_CD        = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!1301339")),protect
 
	set  icustomfieldindex            = icustomfieldindex +1
	declare temp_iso = vc   ;05
    set cur_qual = 0  ;05
    set count = 0     ;05
    set temp_iso = "" ;05
 
	select into "nl"
	from
	  orders  o,
	  order_detail  od
	plan o
	  where o.encntr_id =          request->encntr_id
	    and o.catalog_cd           = 200_ISOLATION_STATUS_CD
	    and o.order_status_cd      = 6004_ORDERED_STATUS_CD
	    and o.active_ind           = 1
	join od
	  where od.order_id            = o.order_id
	    and od.oe_field_id         = 16449_ISOLATION_CD
	    and od.action_sequence     = (select max(od2.action_sequence) from order_detail od2 where od.order_id = od2.order_id
       								and od2.oe_field_id = 16449_ISOLATION_CD )
    order by o.order_id, od.oe_field_id, od.action_sequence desc, od.detail_sequence desc
 
;begin 05
     detail
      cur_qual = cur_qual + 1
       While (cur_qual > count)
       	   if (cur_qual = 1)
       	     temp_iso = trim(od.oe_field_display_value,3)
       	   else
       	     temp_iso = concat(trim(temp_iso,3),",",trim(od.oe_field_display_value,3))
       	   endif
  	       count = count + 1
  	   endwhile
 
      reply->custom_field[iCustomFieldIndex].custom_field_display             = trim(temp_iso,3)
      ;  	     reply->custom_field[iCustomFieldIndex].custom_field_display             = trim(od.oe_field_display_value)
	  reply->custom_field[iCustomFieldIndex].custom_field_index               = 3
;end 05
 
  with nocounter
 
	if(curqual = 0)
	   set reply->custom_field[iCustomFieldIndex].custom_field_display        = NoIsolationData
	   set reply->custom_field[iCustomFieldIndex].custom_field_index          = 3
	endif
 
 
end
 
;Fall Risk
;Qualifies based on Fall Risk on the patient problem list
subroutine CustomField4(null)
 
declare FALLRISK_CONCEPT = vc with Protect
declare 400_SNOMED = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!3240237")),protect
declare 48_ACTIVE = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!2669")),protect
declare 12030_ACTIVE = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!3465")),protect
declare check_dx = i2 with noconstant(0) ;7.0
 
set FALLRISK_CONCEPT = "SNOMED!129839007"
set  icustomfieldindex            = icustomfieldindex +1
 
 
SELECT INTO "nl:"
FROM
	PROBLEM PR
	, NOMENCLATURE N
 
plan pr
	where pr.person_id = request->person_id
		and pr.life_cycle_status_cd = 12030_ACTIVE
		and pr.active_ind = 1
		;8.0 and pr.beg_effective_dt_tm between
		;8.0	cnvtlookbehind("6,m") and
		;8.0	cnvtdatetime(curdate,curtime3)
		and pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and pr.active_status_cd = 48_ACTIVE
		and pr.problem_id !=0
		and pr.problem_instance_id !=0
join n
	where n.nomenclature_id = pr.nomenclature_id
		and n.active_ind = 1
		and n.active_status_cd = 48_ACTIVE
		and n.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
		and n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and n.concept_cki = FALLRISK_CONCEPT
		and n.source_vocabulary_cd = 400_SNOMED
		and n.nomenclature_id !=0
 
order by pr.problem_id desc
 
head pr.problem_id
 
	   reply->custom_field[iCustomFieldIndex].custom_field_display             =
	   BUILD2(" ","Yes"," ","(", PR.BEG_EFFECTIVE_DT_TM,")")
	   reply->custom_field[iCustomFieldIndex].custom_field_index               = 4
 
WITH nocounter
	if(curqual = 0)
		set check_dx = 1 ;7.0
	   ;7.0 set reply->custom_field[iCustomFieldIndex].custom_field_display        = NoFallRiskData
	   ;7.0 set reply->custom_field[iCustomFieldIndex].custom_field_index          = 4
	endif
;start 7.0
if (check_dx = 1)
	select into "nl:"
	from 
		 diagnosis d
		,nomenclature n
	plan d
		where 	d.person_id = request->person_id 
   		and 	d.active_ind = 1 
   		and 	d.beg_effective_dt_tm between cnvtlookbehind("6,m") and cnvtdatetime(curdate,curtime3)
 		and 	d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
 		and 	d.active_status_cd = 48_ACTIVE
 		and 	d.diag_type_cd = value(uar_get_code_by("MEANING",17,"HC_OTHER"))
   	join n
   		where 	n.nomenclature_id = d.nomenclature_id
  		and 	n.concept_cki = FALLRISK_CONCEPT 
order by 
		d.person_id,
		d.beg_effective_dt_tm desc
 
head	d.person_id
 
	   reply->custom_field[iCustomFieldIndex].custom_field_display             =
	   BUILD2(" ","Yes"," ","(", format(d.BEG_EFFECTIVE_DT_TM,"mm/dd/yyyy;;d"),")")
	   reply->custom_field[iCustomFieldIndex].custom_field_index               = 4
with nocounter 
 
	if(curqual = 0)
	   set reply->custom_field[iCustomFieldIndex].custom_field_display        = NoFallRiskData
	   set reply->custom_field[iCustomFieldIndex].custom_field_index          = 4
	endif
endif
;end 7.0
 
end
 
;Insurance Information
;We will return the financial classs and health plan name
;All locations marked on code set extesnion for 220 No under the Display_Insurance field will not return insurance data.
;EMTALA regulation to why we do not display insurnace in particular areas
subroutine CustomField5(null)
 
declare health_plan = vc
declare 48_ACTIVE = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!2669")),protect
 
set  icustomfieldindex            = icustomfieldindex +1
 
select into "nl:"
	from encounter e
	, encntr_plan_reltn ep
	, health_plan hp
 
	plan e
		where e.person_id= request->person_id
			and e.encntr_id = request->encntr_id
			and e.loc_nurse_unit_cd not in (select code_value
											from code_value_extension
											where code_set = 220
												and field_name = "Display_Insurance"
												and field_value = "No")
	join ep
		where ep.encntr_id = e.encntr_id
			and ep.active_ind = 1
			and ep.active_status_cd = 48_ACTIVE
			and ep.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
			and ep.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
			and ep.priority_seq = 1 ;v.6
/*			and ep.encntr_plan_reltn_id =
				(select max(ep2.encntr_plan_reltn_id)
				from encntr_plan_reltn ep2
				where ep2.encntr_id = request->encntr_id)*/ ;v.6
	join hp
		where hp.health_plan_id = ep.health_plan_id
 
	order by ep.encntr_plan_reltn_id desc
 
head ep.encntr_plan_reltn_id
 
	   reply->custom_field[iCustomFieldIndex].custom_field_display             =
	  build2(trim(uar_get_code_display(hp.financial_class_cd))," - ",hp.plan_name)
	   reply->custom_field[iCustomFieldIndex].custom_field_index               = 5
 
	with nocounter
	if(curqual = 0)
	   set reply->custom_field[iCustomFieldIndex].custom_field_display        = NoHealthPlanData
	   set reply->custom_field[iCustomFieldIndex].custom_field_index          = 5
	endif
 
end
 
end
go
 

