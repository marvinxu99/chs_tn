/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_orders_vv_audit.prg
	Object name:		cov_orders_vv_audit
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

drop program cov_orders_vv_audit:dba go
create program cov_orders_vv_audit:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Facility" = 0 

with OUTDEV, FACILITY_PMPT

execute cov_std_log_routines

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
	 2 sel_fac = i2
	 2 sel_fac_qual[*]
	  3 location_cd = f8
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
	 2 synonym_id	= f8
	 2 virtual_viewed = vc
	 2 fac_cnt = i4
	 2 fac_qual[*]
	  3 facility_cd = f8
	  3 facility = vc
	  3 selected = i4
)

;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->prompts.outdev = $OUTDEV
set t_rec->dates.end_dt_tm 		= cnvtdatetime(curdate,curtime3)
set t_rec->dates.start_dt_tm = cnvtdatetime(curdate,curtime3)

set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)

select into "nl:"
from
	code_value cv 
plan cv
	where cv.code_value = $FACILITY_PMPT
detail
	t_rec->prompts.sel_fac += 1
	stat = alterlist(t_rec->prompts.sel_fac_qual,t_rec->prompts.sel_fac)
	t_rec->prompts.sel_fac_qual[t_rec->prompts.sel_fac].location_cd = cv.code_value
with nocounter

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

select into "nl:"
	 o.catalog_type_cd
	,o.description
	,o.primary_mnemonic
	,synonym=ocs.mnemonic
	,facility=uar_get_code_display(f.facility_cd)
	,facility_ind = nullind(f.synonym_id)
from
     order_catalog o,
     order_catalog_synonym ocs,
     ocs_facility_r f,
     (dummyt d1)
plan o 
	where o.active_ind = 1
	;and o.catalog_type_cd =        2511.00
join ocs 
	where ocs.catalog_cd = o.catalog_cd
    and ocs.active_ind = 1
join d1
join f 
	where f.synonym_id = ocs.synonym_id
order by
	 ocs.synonym_id
	,facility
head report
	i=0
	j=0
	flag=0
head ocs.synonym_id
	j=0
	i += 1
	stat = alterlist(t_rec->qual,i)
	t_rec->qual[i].synonym_id = ocs.synonym_id
head facility
	j += 1
	stat = alterlist(t_rec->qual[i].fac_qual,j)
	if ((f.facility_cd = 0) and (f.synonym_id > 0.0))
		t_rec->qual[i].fac_qual[j].facility_cd = 0.0
		t_rec->qual[i].fac_qual[j].facility = "<All facilities included>"
		t_rec->qual[i].fac_qual[j].selected = 1
	else
	t_rec->qual[i].fac_qual[j].facility_cd = f.facility_cd
	t_rec->qual[i].fac_qual[j].facility = uar_get_code_display(f.facility_cd)
	t_rec->qual[i].fac_qual[j].selected = 
		locateval(k,1,t_rec->prompts.sel_fac,f.facility_cd,t_rec->prompts.sel_fac_qual[k].location_cd)
	endif
foot ocs.synonym_id
	t_rec->qual[i].fac_cnt = j
	
	call SubroutineLog(build("->i=",i))
	call SubroutineLog(build("starting to review ",o.primary_mnemonic," (",ocs.mnemonic,") ",ocs.synonym_id))
	call SubroutineLog(build("->fac_cnt=",t_rec->qual[i].fac_cnt))
	
	flag = 0
	for (k=1 to t_rec->qual[i].fac_cnt)
	 if (t_rec->qual[i].fac_qual[k].selected > 0)
		if (flag > 0)
			t_rec->qual[i].virtual_viewed = concat(t_rec->qual[i].virtual_viewed,";")
		endif
		t_rec->qual[i].virtual_viewed = concat(t_rec->qual[i].virtual_viewed,t_rec->qual[i].fac_qual[k].facility)
		flag = 1
		call SubroutineLog(build("-->adding=",t_rec->qual[i].fac_qual[k].facility))
	 endif
	endfor
	
foot report
	t_rec->cnt = i
with format(date,";;q"),uar_code(d,1),format,separator=" ",outerjoin=d1


call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

select into t_rec->prompts.outdev
	 oc.catalog_type_cd
	,oc.description
	,oc.primary_mnemonic
	,ocs.mnemonic
	,hidden=if(ocs.hide_flag = 1) "Yes" endif
	,virtual_views = substring(1,100,t_rec->qual[d1.seq].virtual_viewed)
	,synonym_id = ocs.synonym_id
	
from
	 (dummyt d1 with seq=t_rec->cnt)
	,order_catalog_synonym ocs
	,order_catalog oc
plan d1
join ocs
	where ocs.synonym_id = t_rec->qual[d1.seq].synonym_id
join oc
	where oc.catalog_cd = ocs.catalog_cd
order by
	 oc.catalog_type_cd
	,oc.description
with format(date,";;q"),uar_code(d,1),format,separator=" "

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


;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)


call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
