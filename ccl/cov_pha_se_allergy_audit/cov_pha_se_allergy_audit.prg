/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			
	Source file name:	cov_pha_se_allergy_audit.prg
	Object name:		cov_pha_se_allergy_audit
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_pha_se_allergy_audit:dba go
create program cov_pha_se_allergy_audit:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Audit Type" = 0 

with OUTDEV, AUDIT_TYPE


call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Definition Section  ************************************"))

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

record t_rec (
  1 curprog = vc   
  1 custom_code_set = i4   
  1 custom_code_set_conv = i4   
  1 patient   
    2 encntr_id = f8   
    2 person_id = f8   
  1 retval = i2   
  1 log_message = vc   
  1 log_misc1 = vc   
  1 return_value = vc   
  1 nka_nomed_id = f8   
  1 substance_type_cd = f8   
  1 reaction_class_cd = f8   
  1 side_effect_reaction_class_cd = f8   
  1 int_reaction_class_cd = f8   
  1 contr_reaction_class_cd = f8   
  1 reaction_status_cd = f8   
  1 cur_allergy_qual = i2   
  1 cur_side_effect_qual = i2   
  1 allergy_cnt = i2   
  1 allergy_qual [*]  
    2 allergy_id = f8   
  1 reactions   
    2 freetext_pos = i2   
    2 freetext_cnt = i2   
    2 freetext_qual [*]  
      3 reaction_ftdesc = vc   
    2 nomenclature_pos = i2   
    2 nomenclature_cnt = i2   
    2 nomenclature_qual [*]  
      3 source_string = vc   
  1 allergies   
    2 freetext_pos = i2   
    2 freetext_cnt = i2   
    2 freetext_qual [*]  
      3 allergies_ftdesc = vc   
    2 nomenclature_pos = i2   
    2 nomenclature_cnt = i2   
    2 nomenclature_qual [*]  
      3 source_string = vc   
  1 alg_ex_cat_cnt = i2   
  1 alg_ex_cat_qual [*]  
    2 category_name = vc   
    2 category_id = f8   
  1 alg_ex_class_cnt = i2   
  1 alg_ex_class_qual [*]  
    2 class_name = vc   
    2 class_id = f8   
  1 alg_exclude_pos = i2   
  1 alg_exclude_cnt = i2   
  1 alg_exclude_qual [*]  
    2 identifier = vc   
    2 name = vc
    2 class = vc
    2 class_type = vc
  1 exclude_collection_cnt = i2   
  1 exclude_collection_qual [*]  
    2 colleciton_group = vc   
    2 freetext_pos = i2   
    2 freetext_cnt = i2   
    2 freetext_qual [*]  
      3 reaction_ftdesc = vc   
    2 nomenclature_pos = i2   
    2 nomenclature_cnt = i2   
    2 nomenclature_qual [*]  
      3 source_string = vc 
    2 reaction_cnt = i4
    2 reaction_qual[*]
     3 type = vc
     3 reaction = vc
      
  1 conversion   
    2 substance_cnt = i2   
    2 substance_qual [*]  
      3 source_string = vc   
      3 source_identifier = vc   
      3 allergy_type_disp = vc   
      3 allergy_type_cd = f8   
      3 substance_nomen_id = f8   
      3 freetext_cnt = i2   
      3 substance_type = vc   
      3 substance_type_cd = f8   
      3 freetext_qual [*]  
        4 substance_ftdesc = vc   
) 


set t_rec->curprog = "cov_upd_allergy_profile"

call writeLog(build2("* END   Definition Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Code Set  ************************************"))



;call addEmailLog("chad.cummings@covhlth.com")

select into "nl:"
from
	code_value_set cvs
plan cvs
	    where cvs.definition            in("COVCUSTOM","COVCUSTOMPHACONV")
order by
	 cvs.definition
	,cvs.updt_dt_tm desc
head cvs.definition
	case (cvs.definition)
		of "COVCUSTOM":			t_rec->custom_code_set		= cvs.code_set
		of "COVCUSTOMPHACONV":	t_rec->custom_code_set_conv = cvs.code_set
	endcase
 
with nocounter

call writeLog(build2("* END   Custom Code Set  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Reaction, Allergy and Classifications *********************"))

select into "nl:"
from
     code_value cv1
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	;and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			in(
										 "REACTION_FT"
										,"REACTION_KEY"
										,"ALLERGY_FT"  ;005
										,"ALLERGY_KEY" ;005
										,"ALG_EX_CAT"
										,"ALG_EX_CLASS"
									   )
order by
	 cv1.cdf_meaning
	,cv1.code_value
head report
	row +0
head cv1.cdf_meaning
	row +0
head cv1.code_value
	case (cv1.cdf_meaning)
		of "REACTION_FT":	t_rec->reactions.freetext_cnt = (t_rec->reactions.freetext_cnt + 1)
							stat = alterlist(t_rec->reactions.freetext_qual,t_rec->reactions.freetext_cnt)
							t_rec->reactions.freetext_qual[t_rec->reactions.freetext_cnt].reaction_ftdesc = cv1.display
		of "REACTION_KEY":	t_rec->reactions.nomenclature_cnt = (t_rec->reactions.nomenclature_cnt + 1)
							stat = alterlist(t_rec->reactions.nomenclature_qual,t_rec->reactions.nomenclature_cnt)
							t_rec->reactions.nomenclature_qual[t_rec->reactions.nomenclature_cnt].source_string = cv1.display
		;start 005
		of "ALLERGY_FT":	t_rec->allergies.freetext_cnt = (t_rec->allergies.freetext_cnt + 1)
							stat = alterlist(t_rec->allergies.freetext_qual,t_rec->allergies.freetext_cnt)
							t_rec->allergies.freetext_qual[t_rec->allergies.freetext_cnt].allergies_ftdesc = cv1.display
		of "ALLERGY_KEY":	t_rec->allergies.nomenclature_cnt = (t_rec->allergies.nomenclature_cnt + 1)
							stat = alterlist(t_rec->allergies.nomenclature_qual,t_rec->allergies.nomenclature_cnt)
							t_rec->allergies.nomenclature_qual[t_rec->allergies.nomenclature_cnt].source_string = cv1.display
		;end 005
		of "ALG_EX_CAT":	t_rec->alg_ex_cat_cnt = (t_rec->alg_ex_cat_cnt + 1)
							stat = alterlist(t_rec->alg_ex_cat_qual,t_rec->alg_ex_cat_cnt)
							t_rec->alg_ex_cat_qual[t_rec->alg_ex_cat_cnt].category_name = cv1.display
		of "ALG_EX_CLASS":	t_rec->alg_ex_class_cnt = (t_rec->alg_ex_class_cnt + 1)
							stat = alterlist(t_rec->alg_ex_class_qual,t_rec->alg_ex_class_cnt)
							t_rec->alg_ex_class_qual[t_rec->alg_ex_class_cnt].class_name = cv1.display
	endcase
foot cv1.code_value
	row +0
foot cv1.cdf_meaning
	row +0
foot report
	row +0
with nocounter


call writeLog(build2("* END   Reaction, Allergy and Classifications *********************"))
call writeLog(build2("************************************************************"))



call writeLog(build2("************************************************************"))
call writeLog(build2("* START Getting List of Meds for Side Effect to Allergy Exclusions ****"))

select distinct into "nl:"
	 mdc.category_name
	,mcdx.drug_identifier
	,n.source_string
from 
	 mltm_drug_categories mdc
	,mltm_category_drug_xref mcdx
	,nomenclature n
plan mdc 
	where expand(i,1,t_rec->alg_ex_cat_cnt,mdc.category_name,t_rec->alg_ex_cat_qual[i].category_name)
join mcdx 
	where mcdx.multum_category_id = mdc.multum_category_id
join n 
	where n.source_identifier = mcdx.drug_identifier
order by 
	 mdc.category_name
	,mcdx.drug_identifier
	,0
head report
	call echo(build2("entering category_name query"))
detail
	t_rec->alg_exclude_cnt = (t_rec->alg_exclude_cnt + 1)
	stat = alterlist(t_rec->alg_exclude_qual,t_rec->alg_exclude_cnt)
	t_rec->alg_exclude_qual[t_rec->alg_exclude_cnt].identifier = mcdx.drug_identifier
	t_rec->alg_exclude_qual[t_rec->alg_exclude_cnt].name = n.source_string
	t_rec->alg_exclude_qual[t_rec->alg_exclude_cnt].class = mdc.category_name
	t_rec->alg_exclude_qual[t_rec->alg_exclude_cnt].class_type = "Drug Category"
foot report
	call echo(build2("leaving category_name query"))
with nocounter, nullreport


select distinct into "nl:"
	macdm.drug_identifier
from
	 mltm_alr_category mac
	,mltm_alr_category_drug_map macdm
	,nomenclature n
plan mac
	where expand(i,1,t_rec->alg_ex_class_cnt,mac.category_description,t_rec->alg_ex_class_qual[i].class_name)
join macdm
	where macdm.alr_category_id = mac.alr_category_id
join n 
	where n.source_identifier = macdm.drug_identifier
order by
	 mac.category_description
	,macdm.drug_identifier
	,0
head report
	call echo(build2("entering category_description query"))
detail
	t_rec->alg_exclude_cnt = (t_rec->alg_exclude_cnt + 1)
	stat = alterlist(t_rec->alg_exclude_qual,t_rec->alg_exclude_cnt)
	t_rec->alg_exclude_qual[t_rec->alg_exclude_cnt].identifier = n.source_identifier
	t_rec->alg_exclude_qual[t_rec->alg_exclude_cnt].name = n.source_string
	t_rec->alg_exclude_qual[t_rec->alg_exclude_cnt].class = mac.category_description
	t_rec->alg_exclude_qual[t_rec->alg_exclude_cnt].class_type = "Allergy Category"
foot report
	call echo(build2("leaving category_description query"))
with nocounter, nullreport

select into "nl:"
from
      code_value cv1
     ,code_value_group cvg
     ,code_value cv2
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog))
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			in(
										 "EXCLUDE_COLL"
									   )
join cvg
	where cvg.parent_code_value		= cv1.code_value
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind 			= 1
	and   cv2.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv2.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv2.cdf_meaning			in(
										 "ALLERGY_KEY"
										,"ALLERGY_FT"
										)
order by
	 cv1.code_value
	,cv2.code_value
head report
	call echo(build2("entering EXCLUDE_COLL query"))
head cv1.code_value
	t_rec->exclude_collection_cnt = (t_rec->exclude_collection_cnt + 1)
	stat = alterlist(t_rec->exclude_collection_qual,t_rec->exclude_collection_cnt)
	t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].colleciton_group = cv1.display
	;call echo(build2("->added collection group=",cv1.display))
head cv2.code_value
	if (cv2.cdf_meaning = "ALLERGY_FT")
		t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].freetext_cnt += 1
		stat = alterlist(t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].freetext_qual,
			t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].freetext_cnt)
			
		t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].
			freetext_qual[t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].freetext_cnt].reaction_ftdesc = cv2.display
	elseif (cv2.cdf_meaning = "ALLERGY_KEY")
		t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].nomenclature_cnt += 1
		stat = alterlist(t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].nomenclature_qual,
			t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].nomenclature_cnt)
			
		t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].
			nomenclature_qual[t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].nomenclature_cnt].source_string = cv2.display
	endif
	t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].reaction_cnt += 1
	stat = alterlist(t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].reaction_qual,
						t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].reaction_cnt)
	t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].reaction_qual[
		t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].reaction_cnt].type = cv2.cdf_meaning
	t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].reaction_qual[
		t_rec->exclude_collection_qual[t_rec->exclude_collection_cnt].reaction_cnt].reaction = cv2.display
foot report
	call echo(build2("leaving EXCLUDE_COLL query"))
with nocounter,nullreport

call writeLog(build2("* END Getting List of Meds for Side Effect to Allergy Exclusions***"))
call writeLog(build2("************************************************************"))

if ($AUDIT_TYPE = 1)
 select into $OUTDEV
 	 class_type=substring(1,50,t_rec->alg_exclude_qual[d1.seq].class_type)
 	,classification=substring(1,50,t_rec->alg_exclude_qual[d1.seq].class)
 	,identifier=substring(1,50,t_rec->alg_exclude_qual[d1.seq].identifier)
 	,name = substring(1,100,t_rec->alg_exclude_qual[d1.seq].name)
 from
 	(dummyt d1 with seq=t_rec->alg_exclude_cnt)
 plan d1
 order by
 	name
 with nocounter,format,separator= ""
 
elseif ($AUDIT_TYPE = 2)
 select distinct into $OUTDEV
 	 side_effect_coded=substring(1,100,t_rec->allergies.nomenclature_qual[d2.seq].source_string)
 	,side_effect_ft=substring(1,100,t_rec->allergies.freetext_qual[d1.seq].allergies_ftdesc)
 from
 	(dummyt d1 with seq=t_rec->allergies.freetext_cnt)
 	,(dummyt d2 with seq=t_rec->allergies.nomenclature_cnt)
 plan d1 and d2
 order by
 	side_effect_coded
 	,side_effect_ft
 with nocounter,format,separator= ""
else
 select into $OUTDEV
 	 collection= substring(1,50,t_rec->exclude_collection_qual[d1.seq].colleciton_group)
 	,reaction_type = substring(1,50,t_rec->exclude_collection_qual[d1.seq].reaction_qual[d2.seq].type)
 	,reaction = substring(1,50,t_rec->exclude_collection_qual[d1.seq].reaction_qual[d2.seq].reaction)
 from
 	 (dummyt d1 with seq=t_rec->exclude_collection_cnt)
 	,(dummyt d2)
 plan d1
 	where maxrec(d2,t_rec->exclude_collection_qual[d1.seq].reaction_cnt)
 join d2
 order by
 	 collection
 	 ,reaction
 	 ,reaction_type
 with nocounter,format,separator= ""
endif

#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go

