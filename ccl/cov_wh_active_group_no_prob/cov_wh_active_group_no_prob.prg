/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_wh_active_group_no_prob.prg
	Object name:		cov_wh_active_group_no_prob
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

drop program cov_wh_active_group_no_prob:dba go
create program cov_wh_active_group_no_prob:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Email" = "" 

with OUTDEV, Email


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
	 2 email = vc
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
	 2 dynamic_label = vc
	 2 label_dt_tm = dq8
	 2 problem = vc
	 2 encntr_type_cd = f8
	 2 encntr_status_cd = f8
	 2 reg_dt_tm = dq8
	 2 disch_dt_tm = dq8
	 2 loc_unit_cd = f8
	 2 preg_prob_ind = i2
	 2 loc_facility_cd = f8
	 2 inpatient_admit_dt_tm = dq8
	 2 facility = vc
	 2 unit = vc
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.email = $EMAIL

set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)

if (t_rec->prompts.email > " ")
	call addEmailLog(t_rec->prompts.email)
endif	

declare problem_var = vc

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Active Groups   *******************************************"))

select into "nl:"
	 e.loc_nurse_unit_cd
	,ea.alias
	,p.name_full_formatted
	,e.encntr_type_cd
	,e.encntr_status_cd
	,e.reg_dt_tm
	,e.disch_dt_tm
	,cdl.label_name
	,n.source_string
	,n.source_identifier
from
	 ce_dynamic_label cdl
	,clinical_event ce
	,encounter e
	,person p
	,problem pr
	,nomenclature n
	,encntr_alias ea
	,(dummyt d1)
	,(dummyt d2)
plan cdl
	where cdl.label_name = "Baby*"
	and   cdl.label_status_cd in(value(uar_get_code_by("MEANING",4002015,"ACTIVE")))
join ce
	where ce.ce_dynamic_label_id = cdl.ce_dynamic_label_id
join e
	where e.encntr_id = ce.encntr_id
	;and   e.encntr_id = 133243927
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
join p
	where p.person_id = e.person_id
join d1
join pr
 	where pr.person_id = p.person_id
 	and   pr.active_ind = 1
join d2
join n
	where n.nomenclature_id = pr.nomenclature_id
	and   n.source_string = "Preg*"
order by
	e.encntr_id
head report
	i = 0
	k = 0
	j = 0
head e.encntr_id
	k = 1
	j = 0
	problem_var = " "
	call echo(build2("e.encntr_id=",e.encntr_id))
detail
	if (n.source_string = "Preg*")
		j = 1
		problem_var = concat(problem_var,";",n.source_string)
	endif
	call echo(build2("n.nomenclature_id=",n.nomenclature_id))

foot e.encntr_id
	if (k=1)
		i += 1
		stat = alterlist(t_rec->qual,i)
		t_rec->qual[i].encntr_id = e.encntr_id
		t_rec->qual[i].person_id = e.person_id
		t_rec->qual[i].disch_dt_tm = e.disch_dt_tm
		t_rec->qual[i].dynamic_label = cdl.label_name
		t_rec->qual[i].encntr_status_cd = e.encntr_status_cd
		t_rec->qual[i].encntr_type_cd = e.encntr_type_cd
		t_rec->qual[i].problem = problem_var
		t_rec->qual[i].reg_dt_tm = e.reg_dt_tm
		t_rec->qual[i].label_dt_tm = cdl.create_dt_tm
		t_rec->qual[i].preg_prob_ind = j
	endif
	k=0
foot report
	t_rec->cnt = i
with counter,uar_code(d,1),format(date,"dd-mmm-yyyy hh:mm:ss;;q"),outerjoin=d1,outerjoin=d2;,time=240

call get_mrn(null)
call get_fin(null)
call get_patientname(null) 
call get_patientloc(null)   
    
call writeLog(build2("* END   Finding Active Groups   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit *************************************"))
	call writeAudit(build2(
							char(34),^Location^,char(34),char(44),
							char(34),^FIN^,char(34),char(44),
							char(34),^Name^,char(34),char(44),
							char(34),^Encounter Type^,char(34),char(44),
							char(34),^Encounter Status^,char(34),char(44),
							char(34),^Reg Dt Tm^,char(34),char(44),
							char(34),^Disch Dt Tm^,char(34),char(44),
							char(34),^Label Create Dt Tm^,char(34),char(44),
							char(34),^Baby Label^,char(34),char(44),
							char(34),^Problem^,char(34)
						))
for (i=1 to t_rec->cnt)
		call writeAudit(build2(
							char(34),uar_get_code_display(t_rec->qual[i].loc_unit_cd)	,char(34),char(44),
							char(34),t_rec->qual[i].fin									,char(34),char(44),
							char(34),t_rec->qual[i].name_full_formatted					,char(34),char(44),
							char(34),uar_get_code_display(t_rec->qual[i].encntr_type_cd)	,char(34),char(44),
							char(34),uar_get_code_display(t_rec->qual[i].encntr_status_cd)	,char(34),char(44),
							char(34),format(t_rec->qual[i].reg_dt_tm ,"dd-mmm-yyyy hh:mm:ss;;d")  ,char(34),char(44),
							char(34),format(t_rec->qual[i].disch_dt_tm ,"dd-mmm-yyyy hh:mm:ss;;d")  ,char(34),char(44),
							char(34),format(t_rec->qual[i].label_dt_tm ,"dd-mmm-yyyy hh:mm:ss;;d")  ,char(34),char(44),
							char(34),t_rec->qual[i].dynamic_label						,char(34),char(44),
							char(34),t_rec->qual[i].preg_prob_ind								,char(34)
						))
/*
	 e.loc_nurse_unit_cd
	,ea.alias
	,p.name_full_formatted
	,e.encntr_type_cd
	,e.encntr_status_cd
	,e.reg_dt_tm
	,e.disch_dt_tm
	,cdl.label_name
	,n.source_string
	,n.source_identifier*/
endfor
call writeLog(build2("* END   Creating Audit *************************************"))
call writeLog(build2("************************************************************"))

select into t_rec->prompts.outdev
	 location = substring(1,100,uar_get_code_display(t_rec->qual[d1.seq].loc_unit_cd))
	,fin = substring(1,100,t_rec->qual[d1.seq].fin)
	,name = substring(1,100,t_rec->qual[d1.seq].name_full_formatted)
	,encntr_type = substring(1,100,uar_get_code_display(t_rec->qual[d1.seq].encntr_type_cd))
	,encntr_status = substring(1,100,uar_get_code_display(t_rec->qual[d1.seq].encntr_status_cd))
	,reg_dt_tm = substring(1,100,format(t_rec->qual[d1.seq].reg_dt_tm ,"dd-mmm-yyyy hh:mm:ss;;d"))
	,disch_dt_tm = substring(1,100,format(t_rec->qual[d1.seq].disch_dt_tm ,"dd-mmm-yyyy hh:mm:ss;;d"))
	,group_dt_tm = substring(1,100,format(t_rec->qual[d1.seq].label_dt_tm ,"dd-mmm-yyyy hh:mm:ss;;d"))
	,label = substring(1,100,t_rec->qual[d1.seq].dynamic_label)
	,preg_prob_ind = t_rec->qual[d1.seq].preg_prob_ind
from
	(dummyt d1 with seq=t_rec->cnt)
plan d1
order by
	 t_rec->qual[d1.seq].unit
	,t_rec->qual[d1.seq].name_full_formatted
with nocounter, format, check, separator = " "
#exit_script


;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)


call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
