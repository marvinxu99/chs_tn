/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			Perioperative
	Source file name:	cov_amb_report_ec2021.prg
	Object name:		cov_amb_report_ec2021
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

drop program cov_amb_report_ec2021:dba go
create program cov_amb_report_ec2021:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Report Type" = 1 

with OUTDEV, REPORT_TYPE


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
/*
  "Output to File/Printer/MINE" = "MINE" ,
  "Reporting Time Frame" = "YEAR" ,
  "Year" = "" ,
  "Start Date" = "CURDATE" ,
  "End Date" = "CURDATE" ,
  "Report Printing Options" = "SUM_PS" ,
  "Quality Measure" = "" ,
  "Organization" = - (1 ) ,
  "Filter EP List" = "ALL" ,
  "Eligible Provider" = 0 ,
  "Filter Measures" = "-1" ,
  "Quarter Start Date" = "" ,
  "QRDA Mode" = "NQF" ,
  "Report By" = "INDV"
  WITH outdev ,optinitiative ,year ,start_dt ,end_dt ,chksummaryonly ,lstmeasure ,orgfilter ,
  epfilter ,lsteligbleprovider ,brdefmeas ,dt_quarter_year ,qrdamode ,reportby
  

  "Output to File/Printer/MINE" = "MINE" ,
  "Reporting Time Frame" = "YEAR" ,
  "Year" = "" ,
  "Start Date" = "CURDATE" ,
  "End Date" = "CURDATE" ,
  "Report Printing Options" = "SUM_PS" ,
  "Quality Measure" = "" ,
  "Organization" = - (1 ) ,
  "Filter EP List" = "ALL" ,
  "Eligible Clinician" = 0 ,
  "Filter Measures" = "-1" ,
  "Quarter Start Date" = "" ,
  "Report By" = "INDV"
  */
  
free set t_rec
record t_rec
(
	1 cnt					= i4
	1 custom_code_set		= i4
	1 code_value_cnt		= i2
	1 prompts
	 2 outdev				= vc
	 2 report_type			= i2
	1 code_value_qual[*]
	 2 code_value			= f8
	 2 npi					= vc
	 2 name					= vc
	1 merged
	 2 full_path			= vc
	 2 short_path			= vc
	 2 filename				= vc
	 2 command				= vc
	 2 astream				= vc
	1 param_program			= vc
	1 report_program		= vc
	1 parser_param			= vc
	1 1_outdev				= vc
	1 2_optinitiative 		= vc
	1 3_year				= vc 
	1 4_start_dt			= vc
	1 5_end_dt				= vc
	1 6_chksummaryonly		= vc
	1 7_lstmeasure			= vc
	1 8_orgfilter			= i2
	1 9_epfilter			= vc
	1 10_lsteligbleprovider = vc
	1 11_brdefmeas			= vc
	1 12_dt_quarter_year	= vc
	1 13_reportby			= vc 
	1 batch_size			= i2
	1 batch_cnt				= i2
	1 batch_qual[*]
	 2 batch_num			= i2
	 2 prov_cnt				= i2
	 2 prov_qual[*]
	  3 br_eligible_provider_id = f8
	1 prov_cnt				= i2
	1 prov_qual[*]
	 2 br_eligible_provider_id	= f8
	 2 npi					= vc
	 2 tax					= vc
	 2 person_id			= f8
	1 file_cnt				= i2
	1 file_qual[*]
	 2 filename				= vc
	 2 merge_command		= vc
	 2 remove_command		= vc
) with protect

  
call addEmailLog("chad.cummings@covhlth.com")
;call addEmailLog("kswallow@CovHlth.com")
;call addEmailLog("jbryant3@covhlth.com")


call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Build Parameters ***********************************"))

set t_rec->batch_size				= 400

set t_rec->report_program 			= ^cov_lh_ec2021_report^
;set t_rec->param_program			= ^lh_ec2020_ops_params^

set t_rec->prompts.outdev			= $OUTDEV
set t_rec->prompts.report_type		= $REPORT_TYPE

set t_rec->1_outdev					= ^MINE^
set t_rec->2_optinitiative			= ^CUSTTF^; ^QTR_YEAR^	;^CUSTTF^
set t_rec->3_year					= ^^
set t_rec->4_start_dt				= ^25-APR-2022^
set t_rec->4_start_dt				= format(datetimefind(cnvtdatetime("01-JUN-2021 00:00:00"),'M','B','B'),"DD-MMM-YYYY;;q")
set t_rec->5_end_dt					= ^26-APR-2022^
set t_rec->5_end_dt					= format(datetimefind(cnvtdatetime("01-JUN-2021 00:00:00"),'M','E','E'),"DD-MMM-YYYY;;q")
set t_rec->6_chksummaryonly			= ^SUM_CSV^
set t_rec->7_lstmeasure				= concat(^value(^,
											^"MU_EC_CMS2_2021",^,
											^"MU_EC_CMS22_2021",^,
											^"MU_EC_CMS50_2021",^,
											^"MU_EC_CMS68_2021",^,
											^"MU_EC_CMS69_2021",^,
											^"MU_EC_CMS122_2021",^,
											^"MU_EC_CMS125_2021",^,
											^"MU_EC_CMS127_2021",^,
											^"MU_EC_CMS130_2021",^,
											^"MU_EC_CMS131_2021",^,
											^"MU_EC_CMS134_2021",^,
											^"MU_EC_CMS135_2021",^,
											^"MU_EC_CMS138_2021",^,
											^"MU_EC_CMS139_2021",^,
											^"MU_EC_CMS144_2021",^,
											^"MU_EC_CMS145_2021",^,
											^"MU_EC_CMS146_2021",^,
											^"MU_EC_CMS147_2021",^,
											^"MU_EC_CMS149_2021",^,
											^"MU_EC_CMS154_2021",^,
											^"MU_EC_CMS156_2021"^,
											^)^)
set t_rec->8_orgfilter				= -1
set t_rec->9_epfilter				= ^All  -1^
set t_rec->10_lsteligbleprovider	= concat(^value(^,cnvtstring(-1),^)^)
set t_rec->11_brdefmeas				= ^-1^
set t_rec->12_dt_quarter_year		= ^^	;^JAN^	;^^
set t_rec->13_reportby				= ^INDV^

set t_rec->merged.filename 		= concat("cov_ec2021_ops_TYPE_" ,format(cnvtdatetime(curdate,curtime3),"MMDDYYYY_HHMMSS;;q"),".csv")
set t_rec->merged.full_path 	= program_log->files.file_path
set t_rec->merged.short_path 	= "cclscratch:"
;set t_rec->merged.astream 		= build("/nfs/middle_fs/to_client_site/",trim(cnvtlower(curdomain)),"/CernerCCL/")

if (t_rec->prompts.report_type = 1)
	set t_rec->6_chksummaryonly = "DET_CSV"
else
	set t_rec->6_chksummaryonly = "SUM_CSV"
endif

set t_rec->merged.filename = cnvtlower(replace(t_rec->merged.filename,"TYPE",t_rec->6_chksummaryonly))
       
call writeLog(build2("* END   Build Parameters ***********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Adding Providers ***********************************"))

Select into "nl:"
      myKey = B.BR_ELIGIBLE_PROVIDER_ID
    , Name = P.NAME_FULL_FORMATTED
    , NPI = B.NATIONAL_PROVIDER_NBR_TXT
    , TIN = B.TAX_ID_NBR_TXT
    FROM BR_ELIGIBLE_PROVIDER   B
    , PRSNL   P
   WHERE P.PERSON_ID = B.PROVIDER_ID
      and B.BR_ELIGIBLE_PROVIDER_ID > 0.0
      and ("-1" = "-1"
      OR ("-1" != "-1" and
      ( EXISTS(select 1
               from lh_cqm_meas_svc_entity_r rel, lh_cqm_meas meas
               where b.br_eligible_provider_id = rel.parent_entity_id  
                 and b.br_eligible_provider_id != 0  ; to eliminate unqualified rows
                 and rel.parent_entity_name = 'BR_ELIGIBLE_PROVIDER'
                 and rel.active_ind = 1
                 and rel.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
                 and rel.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
                 and meas.lh_cqm_meas_id = rel.lh_cqm_meas_id
                 and meas.meas_ident = "MU_EC*2021" and meas.meas_ident not in ("*YQF*")
              )
      ));not -1
    )
 and (EXISTS(select 1 from BR_GROUP_RELTN bgr
                     where bgr.parent_entity_name = 'BR_ELIGIBLE_PROVIDER'
                       and b.BR_ELIGIBLE_PROVIDER_ID = bgr.parent_entity_id
                       and bgr.br_group_id = -1)
 
                       or  (-1 = -1 and -1 = VALUE(282401241, 282401276)) 
                       
                       or exists(select 1 from br_group_reltn bgr,
                                               br_group_reltn bgr1
                        where bgr.parent_entity_id = bgr1.br_group_id
                          and bgr1.parent_entity_name = "BR_ELIGIBLE_PROVIDER"
                          and bgr1.parent_entity_id = b.br_eligible_provider_id
                          and bgr.parent_entity_name = "BR_GROUP"  
                          and bgr.br_group_id =  (VALUE(282401241, 282401276))) and -1 = (-1))
and p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
and EXISTS(SELECT 1 FROM PRSNL PR, PRSNL_ORG_RELTN PO, ORGANIZATION ORG
WHERE po.person_id = p.person_id
and po.organization_id = org.organization_id
and pr.person_id = Reqinfo->Updt_id
and po.beg_effective_dt_tm <=  cnvtdatetime(curdate,curtime)
and org.beg_effective_dt_tm <=   cnvtdatetime(curdate,curtime)
and pr.beg_effective_dt_tm <=  cnvtdatetime(curdate,curtime)
and p.logical_domain_id = pr.logical_domain_id
and ((org.organization_id = -1 or -1 = -1)
and EXISTS(SELECT 1
FROM ORGANIZATION O, prsnl PNL, PRSNL_ORG_RELTN POR
WHERE o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
and pnl.person_id = Reqinfo->Updt_id
and o.logical_domain_id = pnl.logical_domain_id
and por.person_id = pnl.person_id
and por.organization_id = o.organization_id
and org.organization_id = o.organization_id
and por.beg_effective_dt_tm <=  cnvtdatetime(curdate,curtime)
)))
and (
      ;name in filter
      (
        substring(2,3,"ALL")=notrim(" - ") and
        substring(1,1,p.name_last_key) between substring(1,1,"ALL") and substring(5,1,"ALL")
      )
    OR ("ALL" in ('ALL','All','-1'))
    )
order by
	 p.name_full_formatted
	,b.br_eligible_provider_id
head report
	cnt = 0
head b.br_eligible_provider_id
	t_rec->prov_cnt = (t_rec->prov_cnt + 1)
	stat = alterlist(t_rec->prov_qual,t_rec->prov_cnt)
	t_rec->prov_qual[t_rec->prov_cnt].br_eligible_provider_id = b.br_eligible_provider_id
	t_rec->prov_qual[t_rec->prov_cnt].npi = b.national_provider_nbr_txt
	t_rec->prov_qual[t_rec->prov_cnt].tax = b.tax_id_nbr_txt
	t_rec->prov_qual[t_rec->prov_cnt].person_id = p.person_id
foot report
	cnt = 0
with nocounter

call writeLog(build2("* END   Adding Providers ***********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Build Batches **************************************"))

if (t_rec->batch_cnt = 0)
	set t_rec->batch_cnt = (t_rec->batch_cnt + 1)
	set stat = alterlist(t_rec->batch_qual,t_rec->batch_cnt)
endif
	
for (i=1 to t_rec->prov_cnt)
	set t_rec->batch_qual[t_rec->batch_cnt].prov_cnt = (t_rec->batch_qual[t_rec->batch_cnt].prov_cnt + 1)
	if (t_rec->batch_qual[t_rec->batch_cnt].prov_cnt > t_rec->batch_size)
		set t_rec->batch_qual[t_rec->batch_cnt].prov_cnt = t_rec->batch_size
		set t_rec->batch_cnt = (t_rec->batch_cnt + 1)
		set stat = alterlist(t_rec->batch_qual,t_rec->batch_cnt)
		set t_rec->batch_qual[t_rec->batch_cnt].prov_cnt = 1
	endif
	set stat = alterlist(t_rec->batch_qual[t_rec->batch_cnt].prov_qual,t_rec->batch_qual[t_rec->batch_cnt].prov_cnt)
	set t_rec->batch_qual[t_rec->batch_cnt].prov_qual[t_rec->batch_qual[t_rec->batch_cnt].prov_cnt].br_eligible_provider_id 
		= t_rec->prov_qual[i].br_eligible_provider_id
endfor

call writeLog(build2("* START Build Batches **************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Running Reports ************************************"))

for (i=1 to t_rec->batch_cnt)
 
 set t_rec->10_lsteligbleprovider	= concat(^value(^)
 for (j=1 to t_rec->batch_qual[i].prov_cnt)
  if (t_rec->batch_qual[i].prov_qual[j].br_eligible_provider_id > 0.0)
 	if (j=1)
 		set t_rec->10_lsteligbleprovider = concat(t_rec->10_lsteligbleprovider,cnvtstring(t_rec->batch_qual[i].prov_qual[j].
 		br_eligible_provider_id,20,2))
 	else
 		set t_rec->10_lsteligbleprovider = concat(t_rec->10_lsteligbleprovider,^,^,cnvtstring(t_rec->batch_qual[i].prov_qual[j].
 		br_eligible_provider_id,20,2))
 	endif 
  endif
 endfor
 set t_rec->10_lsteligbleprovider	= concat(t_rec->10_lsteligbleprovider,^)^)
 
 set t_rec->file_cnt = (t_rec->file_cnt + 1)
 set stat = alterlist(t_rec->file_qual,t_rec->file_cnt)
 set t_rec->file_qual[t_rec->file_cnt].filename = concat(
 								"tempcovec2021ops_"
 								,trim(cnvtstring(t_rec->file_cnt,2,0))
 								,"_"
 								,format(cnvtdatetime(curdate,curtime3),"MMDDYYYY_HHMMSS;;q")
 								,".csv")
 
 set t_rec->1_outdev = t_rec->file_qual[t_rec->file_cnt].filename
 
 set t_rec->parser_param = concat(
						 			trim(t_rec->report_program),					" "
									,"^",trim(t_rec->1_outdev),"^",					","
									,"^",trim(t_rec->2_optinitiative),"^",			","
									,"^",trim(t_rec->3_year),"^",					","
									,"^",trim(t_rec->4_start_dt),"^",				","
									,"^",trim(t_rec->5_end_dt),"^",					","
									,"^",trim(t_rec->6_chksummaryonly),"^",			","
									,trim(t_rec->7_lstmeasure),						","
									,trim(cnvtstring(t_rec->8_orgfilter)),			","
									,"^",trim(t_rec->9_epfilter),"^",				","
									,trim(t_rec->10_lsteligbleprovider),			","
									,"^",trim(t_rec->11_brdefmeas),"^",				","					
									,"^",trim(t_rec->12_dt_quarter_year),"^",		","
									,"^",trim(t_rec->13_reportby),"^"
								)
 

 ;set trace server 1 
 call writeLog(build2("running-->",t_rec->parser_param))
 call parser(concat("execute ",t_rec->parser_param," go"))
	
 ;set stat = initrec(params)
 ;call parser(concat("execute ",t_rec->report_program," go"))
 ;set trace server 2
	
 ;call addAttachment(program_log->files.ccluserdir,t_rec->file_qual[t_rec->file_cnt].filename)

endfor


call writeLog(build2("* END   Running Reports ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Merging Files **************************************"))
if (t_rec->file_cnt > 0)
	for (i=1 to t_rec->file_cnt)
	 if (t_rec->file_qual[i].filename > " ")
		call writeLog(build2("->adding file:",t_rec->file_qual[i].filename))
		set t_rec->file_qual[i].merge_command = concat(
				^cat ^	,trim(program_log->files.ccluserdir),trim(t_rec->file_qual[i].filename)
						,^ >> ^
						,trim(t_rec->merged.full_path),trim(t_rec->merged.filename)
				)
		set t_rec->file_qual[i].remove_command = concat(
				^rm ^	,trim(program_log->files.ccluserdir),trim(t_rec->file_qual[i].filename)
				)
		call writeLog(build2("->merge command:",t_rec->file_qual[i].merge_command))
		call writeLog(build2("->remove command:",t_rec->file_qual[i].remove_command))
		call dcl(t_rec->file_qual[i].merge_command,size(trim(t_rec->file_qual[i].merge_command)),stat)
		;call dcl(t_rec->file_qual[i].remove_command,size(trim(t_rec->file_qual[i].remove_command)),stat)
	 endif
	endfor
	;call addAttachment(t_rec->merged.full_path,t_rec->merged.filename)
	execute cov_astream_file_transfer "cclscratch",t_rec->merged.filename,"","MV"
endif	
call writeLog(build2("* END   Merging Files **************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

/*
if (validate(t_rec))
	call writeLog(build2(cnvtrectojson(t_rec))) 
endif
if (validate(request))
	call writeLog(build2(cnvtrectojson(request))) 
endif
if (validate(reqinfo))
	call writeLog(build2(cnvtrectojson(reqinfo))) 
endif
if (validate(reply))
	call writeLog(build2(cnvtrectojson(reply))) 
endif
if (validate(program_log))
	call writeLog(build2(cnvtrectojson(program_log)))
endif
*/

#exit_script
call exitScript(null)


for (i=1 to t_rec->file_cnt)
 if (t_rec->file_qual[i].filename > " ")
	call dcl(t_rec->file_qual[i].remove_command,size(trim(t_rec->file_qual[i].remove_command)),stat)
 endif
endfor


call echorecord(t_rec->file_qual)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
