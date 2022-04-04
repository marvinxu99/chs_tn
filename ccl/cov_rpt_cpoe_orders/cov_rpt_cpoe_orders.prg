/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			
	Source file name:	cov_rpt_cpoe_orders.prg
	Object name:		cov_rpt_cpoe_orders
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	09/30/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_rpt_cpoe_orders:dba go
create program cov_rpt_cpoe_orders:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "BEGIN_DATE_TIME" = "SYSDATE"
	, "END_DATE_TIME" = "SYSDATE"
	, "REPORT_TYPE" = 2
	, "Exclude Child Orders" = 0 

with OUTDEV, BEGIN_DATE_TIME, END_DATE_TIME, REPORT_TYPE, CHILD_ORDERS


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

set modify maxvarlen 268435456

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

free set t_rec
free record t_rec
record t_rec
(
	1 prompts
	 2 outdev					= vc
	 2 begin_date_time			= vc
	 2 end_date_time			= vc
	 2 child_orders				= i2
	 2 report_type				= i2
	1 dates
	 2 beg_dt_tm				= dq8
	 2 end_dt_tm				= dq8
	1 parser
	 2 template_order_id		= vc
	1 files
	 2 directory				= vc
	 2 full_details				= vc
	 2 by_provider				= vc
	 2 by_facility				= vc
	1 cnt						= i4
	1 qual[*]
	 2 fin						= vc
	 2 patient_name				= vc
	 2 reg_dt_tm				= dq8
	 2 disch_dt_tm				= dq8
	 2 encntr_type_cd			= f8
	 2 order_id					= f8
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 med_order_type_cd		= f8
	 2 order_status_cd			= f8
	 2 action_sequence			= i2
	 2 action_type_cd			= f8
	 2 action_dt_tm				= dq8
	 2 communication_type_cd	= f8
	 2 communication_type		= vc
	 2 orig_order_dt_tm			= dq8
	 2 order_mnemonic			= vc
	 2 denominator				= i2
	 2 numerator				= i2
	 2 loc_facility_cd			= f8
	 2 loc_nurse_unit_cd		= f8
	 2 order_provider			= vc
	 2 order_provider_id		= f8
	 2 pathway_catalog_id		= f8
	 2 pathway_id				= f8
	 2 pathway_action_id		= f8
	 2 pathway_comm_type_cd		= f8
	 2 pathway_action_prsnl		= vc
	 2 pathway_description		= vc
	1 by_provider_cnt			= i2
	1 by_provider_qual[*]
 	 2 provider_name		= vc
 	 2 faciliy				= vc
 	 2 provider_id			= f8
 	 2 provider_specialty	= vc
 	 2 patient_type			= vc
 	 2 order_count			= i4
 	 2 communication_type	= vc
 	 2 order_dt				= c6
	1 by_facility_cnt		= i2
	1 by_facility_qual[*]
 	 2 faciliy				= vc
 	 2 patient_type			= vc
 	 2 order_count			= i4
 	 2 communication_type	= vc
 	 2 order_dt				= c6
)

;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->prompts.outdev			= $OUTDEV
set t_rec->prompts.begin_date_time	= $BEGIN_DATE_TIME
set t_rec->prompts.end_date_time	= $END_DATE_TIME
set t_rec->prompts.child_orders 	= $CHILD_ORDERS
set t_rec->prompts.report_type		= $REPORT_TYPE

set t_rec->dates.beg_dt_tm = cnvtdatetime(t_rec->prompts.begin_date_time)
set t_rec->dates.end_dt_tm = cnvtdatetime(t_rec->prompts.end_date_time)

/*
	o.template_order_flag in(0,1,5)
          0.00	None
          1.00	Template
          2.00	Order Based Instance
          3.00	Task Based Instance
          4.00	Rx Based Instance
          5.00	Future Recurring Template
          6.00	Future Recurring Instance
*/

set t_rec->files.directory		= "cclscratch"
set t_rec->files.full_details	= concat(trim("cpoe_full_details")
										,trim("_type_")
										,format(t_rec->dates.beg_dt_tm,"yyyymmdd;;d")
										,"_"
										,format(t_rec->dates.end_dt_tm,"yyyymmdd;;d")
										,"_"
										,trim(format(sysdate,"yyyymmdd_hhmmss;;d")),".csv")
										
set t_rec->files.by_provider	= concat(trim("cpoe_by_provider")
										,trim("_type_")
										,format(t_rec->dates.beg_dt_tm,"yyyymmdd;;d")
										,"_"
										,format(t_rec->dates.end_dt_tm,"yyyymmdd;;d")
										,"_"
										,trim(format(sysdate,"yyyymmdd_hhmmss;;d")),".csv")
										
set t_rec->files.by_facility	= concat(trim("cpoe_by_facility")
										,trim("_type_")
										,format(t_rec->dates.beg_dt_tm,"yyyymmdd;;d")
										,"_"
										,format(t_rec->dates.end_dt_tm,"yyyymmdd;;d")
										,"_"
										,trim(format(sysdate,"yyyymmdd_hhmmss;;d")),".csv")
										
if (t_rec->prompts.child_orders = 1)
	set t_rec->parser.template_order_id = "1=1"
	set t_rec->files.full_details 	= replace(t_rec->files.full_details,"_type_","_incl_child_")
	set t_rec->files.by_provider 	= replace(t_rec->files.by_provider,"_type_","_incl_child_")
	set t_rec->files.by_facility 	= replace(t_rec->files.by_facility,"_type_","_incl_child_")
else
	set t_rec->parser.template_order_id = "o.template_order_flag in(0,1,5)"
	set t_rec->files.full_details 	= replace(t_rec->files.full_details,"_type_","_no_child_")
	set t_rec->files.by_provider 	= replace(t_rec->files.by_provider,"_type_","_no_child_")
	set t_rec->files.by_facility 	= replace(t_rec->files.by_facility,"_type_","_no_child_")
endif

if (program_log->run_from_ops = 0)
	if (t_rec->prompts.outdev = "OPS")
		set program_log->run_from_ops = 1
		set program_log->display_on_exit = 0
	endif
endif 

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Orders *************************************"))

select into "nl:"
from 
	 encounter e
	,orders o
	,order_action oa
	,encntr_alias ea
	,person p
	,prsnl p1
	,prsnl p2
plan o
	where	o.orig_order_dt_tm between cnvtdatetime(t_rec->dates.beg_dt_tm) and cnvtdatetime(t_rec->dates.end_dt_tm)
    and 	parser(t_rec->parser.template_order_id)
    and  	o.orderable_type_flag != 6
    /*          
    	  0.00	Standard
          1.00	Standard
          2.00	Supergroup
          3.00	CarePlan
          4.00	AP Special
          5.00	Department Only
          6.00	Order Set
          7.00	Home Health Problem
          8.00	Multi-ingredient
          9.00	Interval Test
         10.00	Freetext
         11.00	TPN
         12.00	Attachment
         13.00	Compound
	*/
    and 	o.active_ind = 1
join oa
	where	oa.order_id = o.order_id
    and 	oa.action_sequence = 1
    and     oa.order_provider_id > 0.0
    and 	oa.communication_type_cd in(
          		 value(uar_get_code_by("MEANING",6006,"PHONE"))
          		,value(uar_get_code_by("MEANING",6006,"VERBAL"))
          		,value(uar_get_code_by("MEANING",6006,"WRITTEN"))
          		,value(uar_get_code_by("MEANING",6006,"INITPLAN"))
          		,value(uar_get_code_by("MEANING",6006,"PAPERFAX"))
          		,value(uar_get_code_by("MEANING",6006,"STANDOCOREQ"))
          		,value(uar_get_code_by("MEANING",6006,"PERPROTOCOL"))
          		,value(uar_get_code_by("MEANING",6006,"PERNUTPOLNOC"))
          	) 
join e
    where 	e.encntr_id = o.encntr_id
    and   	e.encntr_id != 0.0
    and	  	e.active_ind = 1
    and		e.loc_facility_cd > 0.0
join p
	where 	p.person_id = e.person_id
join ea
	where 	ea.encntr_id = e.encntr_id
	and   	ea.active_ind = 1
	and   	ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   	ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   	ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join p1
	where	p1.person_id = oa.action_personnel_id
join p2
	where	p2.person_id = oa.order_provider_id 
order by
	o.order_id
head report
	call writeLog(build2("->Inside Order Query"))
head o.order_id
	t_rec->cnt = (t_rec->cnt + 1)
	if ((mod(t_rec->cnt,10000) = 1) or (t_rec->cnt = 1))
		stat = alterlist(t_rec->qual,(t_rec->cnt + 9999))
	endif
	t_rec->qual[t_rec->cnt].action_dt_tm				= oa.action_dt_tm
	t_rec->qual[t_rec->cnt].action_sequence				= oa.action_sequence
	t_rec->qual[t_rec->cnt].action_type_cd				= oa.action_type_cd
	t_rec->qual[t_rec->cnt].communication_type_cd		= oa.communication_type_cd
	t_rec->qual[t_rec->cnt].communication_type			= uar_get_code_display(oa.communication_type_cd)
	t_rec->qual[t_rec->cnt].denominator					= 1
	t_rec->qual[t_rec->cnt].disch_dt_tm					= e.disch_dt_tm
	t_rec->qual[t_rec->cnt].encntr_id					= e.encntr_id
	t_rec->qual[t_rec->cnt].encntr_type_cd				= e.encntr_type_cd
	t_rec->qual[t_rec->cnt].fin							= cnvtalias(ea.alias,ea.alias_pool_cd)
	t_rec->qual[t_rec->cnt].loc_facility_cd				= e.loc_facility_cd
	t_rec->qual[t_rec->cnt].loc_nurse_unit_cd			= e.loc_nurse_unit_cd
	t_rec->qual[t_rec->cnt].med_order_type_cd			= o.med_order_type_cd
	t_rec->qual[t_rec->cnt].numerator					= 0
	t_rec->qual[t_rec->cnt].order_id					= o.order_id
	t_rec->qual[t_rec->cnt].order_mnemonic				= o.order_mnemonic
	t_rec->qual[t_rec->cnt].order_provider				= p2.name_full_formatted
	t_rec->qual[t_rec->cnt].order_provider_id			= oa.order_provider_id
	t_rec->qual[t_rec->cnt].order_status_cd				= o.order_status_cd
	t_rec->qual[t_rec->cnt].orig_order_dt_tm			= o.orig_order_dt_tm
	t_rec->qual[t_rec->cnt].patient_name				= p.name_full_formatted
	t_rec->qual[t_rec->cnt].pathway_catalog_id			= o.pathway_catalog_id
	t_rec->qual[t_rec->cnt].person_id					= p.person_id
	t_rec->qual[t_rec->cnt].reg_dt_tm					= e.reg_dt_tm
foot report
	stat = alterlist(t_rec->qual,(t_rec->cnt))
	call writeLog(build2("-->t_rec->cnt=",trim(cnvtstring(t_rec->cnt))))
	call writeLog(build2("<-Leaving Order Query"))
with nocounter

call writeLog(build2("* END   Finding Orders *************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding PowerPlan Data *****************************"))
select into "nl:"
	order_id = t_rec->qual[d1.seq].order_id
from
	 (dummyt d1 with seq=t_rec->cnt)
	,act_pw_comp apc
	,pathway_action pa
	,code_value cv
	,prsnl p1
	,pathway p
plan d1         
	where t_rec->qual[d1.seq].pathway_catalog_id > 0.0
join apc
	where apc.parent_entity_id = t_rec->qual[d1.seq].order_id
join pa	
	where 	pa.pathway_id = apc.pathway_id
	and 	pa.pw_status_cd in(
									value(uar_get_code_by("MEANING",16769,"PLANNED"))
								)
join cv
	where cv.code_value = pa.communication_type_cd
join p1
	where p1.person_id = pa.action_prsnl_id
join p
	where p.pathway_id = pa.pathway_id
order by
	order_id
head report
	call writeLog(build2("->Inside PowerPlan Query"))
	order_qual = 0
head order_id
	order_qual = 1
detail
	if (p1.physician_ind = 1)
		order_qual = 0
		if (p1.person_id = t_rec->qual[d1.seq].order_provider_id)
			t_rec->qual[d1.seq].pathway_action_id		= p1.person_id
			t_rec->qual[d1.seq].pathway_action_prsnl	= p1.name_full_formatted
			t_rec->qual[d1.seq].pathway_comm_type_cd	= pa.communication_type_cd
			t_rec->qual[d1.seq].pathway_id				= pa.pathway_id
			t_rec->qual[d1.seq].pathway_description		= p.description
		endif
	endif
foot order_id
	if (order_qual = 1)
		t_rec->qual[d1.seq].pathway_action_id		= p1.person_id
		t_rec->qual[d1.seq].pathway_action_prsnl	= p1.name_full_formatted
		t_rec->qual[d1.seq].pathway_comm_type_cd	= pa.communication_type_cd
		t_rec->qual[d1.seq].pathway_id				= pa.pathway_id
		t_rec->qual[d1.seq].pathway_description		= p.description
		t_rec->qual[d1.seq].communication_type		= "Nurse Plan"
	endif
foot report
	call writeLog(build2("<-Leaving PowerPlan Query"))
with nocounter
call writeLog(build2("* END   Finding  PowerPlan Data ****************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Calculate By Provider ******************************"))

select into "nl:"
	 ;communication_type = substring(1,40,uar_get_code_display(t_rec->qual[d1.seq].communication_type_cd))
	 communication_type = substring(1,40,t_rec->qual[d1.seq].communication_type)
	,order_dt 			= format(t_rec->qual[d1.seq].orig_order_dt_tm, 'yyyymm;;q')
	,patient_type 		= substring(1,40,uar_get_code_display(t_rec->qual[d1.seq].encntr_type_cd))
	,facility			= substring(1,40,uar_get_code_display(t_rec->qual[d1.seq].loc_facility_cd))
	,provider			= substring(1,100,t_rec->qual[d1.seq].order_provider)
	,order_provider_id	= t_rec->qual[d1.seq].order_provider_id
	,order_id			= t_rec->qual[d1.seq].order_id
from
		(dummyt d1 with seq=t_rec->cnt)
plan d1
order by 
	 facility
	,order_dt
	,patient_type
	,communication_type
	,provider
	,order_id
head report
	call writeLog(build2("->Inside By Provider Query"))
	order_cnt = 0
head facility
	stat = 0
head order_dt
	stat = 0
head patient_type
	stat = 0
head communication_type
	stat = 0
head provider
	t_rec->by_provider_cnt = (t_rec->by_provider_cnt + 1)
	stat = alterlist(t_rec->by_provider_qual,t_rec->by_provider_cnt)
	t_rec->by_provider_qual[t_rec->by_provider_cnt].faciliy 			= facility
	t_rec->by_provider_qual[t_rec->by_provider_cnt].order_dt			= order_dt
	t_rec->by_provider_qual[t_rec->by_provider_cnt].patient_type		= patient_type
	t_rec->by_provider_qual[t_rec->by_provider_cnt].communication_type	= communication_type
	t_rec->by_provider_qual[t_rec->by_provider_cnt].provider_name		= provider
	t_rec->by_provider_qual[t_rec->by_provider_cnt].provider_id			= order_provider_id
head order_id
	stat = 0
	t_rec->by_provider_qual[t_rec->by_provider_cnt].order_count = (t_rec->by_provider_qual[t_rec->by_provider_cnt].order_count + 1)
foot order_id
	stat = 0
foot provider
	stat = 0
foot communication_type
	stat = 0
foot patient_type
	stat = 0
foot order_dt
	stat = 0
foot facility
	stat = 0
foot report
	call writeLog(build2("<-Leaving By Provider Query"))
with nocounter

call writeLog(build2("* END   Calculate By Provider ******************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Adding Specialty ***********************************"))
select into "nl:"
from
	 prsnl p
    ,prsnl_group_reltn pgr
    ,prsnl_group pg
    ,(dummyt d1 with seq=t_rec->by_provider_cnt)
plan d1
join p
	where p.person_id = t_rec->by_provider_qual[d1.seq].provider_id
join pgr
	where pgr.person_id = p.person_id
	and   cnvtdatetime(curdate,curtime3) between pgr.beg_effective_dt_tm and pgr.end_effective_dt_tm
	and   pgr.contributor_system_cd = value(uar_get_code_by("DISPLAY",89,"STAR"))
join pg
	where pg.prsnl_group_id = pgr.prsnl_group_id
	and   pg.active_ind = 1
	and   cnvtdatetime(curdate,curtime3) between pg.beg_effective_dt_tm and pg.end_effective_dt_tm
	and   pg.prsnl_group_class_cd = value(uar_get_code_by("MEANING",19189,"SERVICE"))
order by
	 p.person_id
	,pgr.beg_effective_dt_tm desc
head report
	call writeLog(build2("->Inside By Provider Specialty"))
head p.person_id
	stat =0
detail
	t_rec->by_provider_qual[d1.seq].provider_specialty = pg.prsnl_group_name
foot p.person_id	
	stat = 0
foot report
	call writeLog(build2("<-Leaving By Provider Specialty"))
with nocounter
call writeLog(build2("* END   Adding Specialty ***********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Calculate By Facility ******************************"))

select into "nl:"
	 communication_type = substring(1,40,t_rec->qual[d1.seq].communication_type)
	,order_dt 			= format(t_rec->qual[d1.seq].orig_order_dt_tm, 'yyyymm;;q')
	,patient_type 		= substring(1,40,uar_get_code_display(t_rec->qual[d1.seq].encntr_type_cd))
	,facility			= substring(1,40,uar_get_code_display(t_rec->qual[d1.seq].loc_facility_cd))
	,order_id			= t_rec->qual[d1.seq].order_id
from
		(dummyt d1 with seq=t_rec->cnt)
plan d1
order by 
	 facility
	,order_dt
	,patient_type
	,communication_type
	,order_id
head report
	call writeLog(build2("->Inside By Facility Query"))
	order_cnt = 0
head facility
	stat = 0
head order_dt
	stat = 0
head patient_type
	stat = 0
head communication_type
	t_rec->by_facility_cnt = (t_rec->by_facility_cnt + 1)
	stat = alterlist(t_rec->by_facility_qual,t_rec->by_facility_cnt)
	t_rec->by_facility_qual[t_rec->by_facility_cnt].faciliy 			= facility
	t_rec->by_facility_qual[t_rec->by_facility_cnt].order_dt			= order_dt
	t_rec->by_facility_qual[t_rec->by_facility_cnt].patient_type		= patient_type
	t_rec->by_facility_qual[t_rec->by_facility_cnt].communication_type	= communication_type
head order_id
	stat = 0
	t_rec->by_facility_qual[t_rec->by_facility_cnt].order_count = (t_rec->by_facility_qual[t_rec->by_facility_cnt].order_count + 1)
foot order_id
	stat = 0
foot communication_type
	stat = 0
foot patient_type
	stat = 0
foot order_dt
	stat = 0
foot facility
	stat = 0
foot report
	call writeLog(build2("<-Leaving By Facility Query"))
with nocounter

call writeLog(build2("* END   Calculate By Facility ******************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Generating Output **********************************"))

if (datetimediff(cnvtdatetime(t_rec->dates.end_dt_tm),cnvtdatetime(t_rec->dates.beg_dt_tm),3) < 26)
 if ((program_log->run_from_ops = 1) or ((program_log->run_from_ops = 0) and (t_rec->prompts.report_type = 0)))
	select 
		if (program_log->run_from_ops = 1)
			into value(concat(t_rec->files.directory,":",t_rec->files.full_details))
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into t_rec->prompts.outdev
	 loc_facility_cd			= substring(1,100,uar_get_code_display(t_rec->qual[d1.seq].loc_facility_cd))
	,loc_nurse_unit_cd			= substring(1,100,uar_get_code_display(t_rec->qual[d1.seq].loc_nurse_unit_cd))
	,encntr_type_cd				= substring(1,100,uar_get_code_display(t_rec->qual[d1.seq].encntr_type_cd))	
	,fin						= substring(1,20,t_rec->qual[d1.seq].fin)
	,patient_name				= substring(1,100,t_rec->qual[d1.seq].patient_name)
	,reg_dt_tm					= substring(1,20,format(t_rec->qual[d1.seq].reg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q"))
	,disch_dt_tm				= substring(1,20,format(t_rec->qual[d1.seq].disch_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q"))
	,order_provider				= substring(1,100,t_rec->qual[d1.seq].order_provider)	
	,order_mnemonic				= substring(1,100,t_rec->qual[d1.seq].order_mnemonic)	
	,order_status_cd			= substring(1,100,uar_get_code_display(t_rec->qual[d1.seq].order_status_cd))
	,orig_order_dt_tm			= substring(1,20,format(t_rec->qual[d1.seq].orig_order_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q"))
	,communication_type			= substring(1,100,t_rec->qual[d1.seq].communication_type)
	,action_dt_tm				= substring(1,20,format(t_rec->qual[d1.seq].action_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q"))
	,action_sequence			= t_rec->qual[d1.seq].action_sequence			
	,action_type_cd				= substring(1,100,uar_get_code_display(t_rec->qual[d1.seq].action_type_cd))	
	,med_order_type_cd			= substring(1,100,uar_get_code_display(t_rec->qual[d1.seq].med_order_type_cd))
	,denominator				= t_rec->qual[d1.seq].denominator
	,numerator					= t_rec->qual[d1.seq].numerator
	,powerplan					= substring(1,100,t_rec->qual[d1.seq].pathway_description)
	,powerplan_comm_type		= substring(1,100,uar_get_code_display(t_rec->qual[d1.seq].pathway_comm_type_cd))				
	,powerplan_action_prsnl		= substring(1,100,t_rec->qual[d1.seq].pathway_action_prsnl)
	,person_id					= t_rec->qual[d1.seq].person_id
	,encntr_id					= t_rec->qual[d1.seq].encntr_id
	,order_provider_id			= t_rec->qual[d1.seq].order_provider_id
	,order_id					= t_rec->qual[d1.seq].order_id
	,pathway_catalog_id			= t_rec->qual[d1.seq].pathway_catalog_id
	,pathway_id					= t_rec->qual[d1.seq].pathway_id
	,pathway_action_id			= t_rec->qual[d1.seq].pathway_action_id
	from
		(dummyt d1 with seq=t_rec->cnt)
	plan d1
	with nocounter
	
	if (program_log->run_from_ops = 1)
		call writeLog(build2("->copying file to astream"))
		call writeLog(build2("->t_rec->files.directory=",t_rec->files.directory))
		call writeLog(build2("->t_rec->files.full_details=",t_rec->files.full_details))
		execute cov_astream_file_transfer t_rec->files.directory,t_rec->files.full_details,"","MV"	
	endif
 endif
endif

if ((program_log->run_from_ops = 1) or ((program_log->run_from_ops = 0) and (t_rec->prompts.report_type = 1)))
	select 
		if (program_log->run_from_ops = 1)
			into value(concat(t_rec->files.directory,":",t_rec->files.by_facility))
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into t_rec->prompts.outdev
		 communication_type	= substring(1,40,t_rec->by_facility_qual[d1.seq].communication_type)		
		,order_dt			= substring(1,6,t_rec->by_facility_qual[d1.seq].order_dt)
		,patient_type		= substring(1,20,t_rec->by_facility_qual[d1.seq].patient_type)
		,facility			= substring(1,20,t_rec->by_facility_qual[d1.seq].faciliy)
		,order_count		= t_rec->by_facility_qual[d1.seq].order_count
	from
		(dummyt d1 with seq=t_rec->by_facility_cnt)
	plan d1
	order by
		 communication_type
 		,order_dt			
 		,patient_type		
 		,facility
	with nocounter
	
	if (program_log->run_from_ops = 1)
		call writeLog(build2("->copying file to astream"))
		call writeLog(build2("->t_rec->files.directory=",t_rec->files.directory))
		call writeLog(build2("->t_rec->files.full_details=",t_rec->files.by_facility))
		execute cov_astream_file_transfer t_rec->files.directory,t_rec->files.by_facility,"","MV"	
	endif
endif

if ((program_log->run_from_ops = 1) or ((program_log->run_from_ops = 0) and (t_rec->prompts.report_type = 2)))
	select 
		if (program_log->run_from_ops = 1)
			into value(concat(t_rec->files.directory,":",t_rec->files.by_provider))
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into t_rec->prompts.outdev
		 communication_type	= substring(1,40,t_rec->by_provider_qual[d1.seq].communication_type)		
		,order_dt			= substring(1,6,t_rec->by_provider_qual[d1.seq].order_dt)
		,patient_type		= substring(1,20,t_rec->by_provider_qual[d1.seq].patient_type)
		,facility			= substring(1,20,t_rec->by_provider_qual[d1.seq].faciliy)
		,provider			= substring(1,100,t_rec->by_provider_qual[d1.seq].provider_name)
		,provider_specialty	= substring(1,40,t_rec->by_provider_qual[d1.seq].provider_specialty)
		,order_provider_id	= t_rec->by_provider_qual[d1.seq].provider_id
		,order_count		= t_rec->by_provider_qual[d1.seq].order_count
		
	from
		(dummyt d1 with seq=t_rec->by_provider_cnt)
	plan d1
	order by
		 communication_type
		,order_dt
		,patient_type		
		,facility			
		,provider			
		,provider_specialty	
		,order_provider_id	
	with nocounter
	
	if (program_log->run_from_ops = 1)
		call writeLog(build2("->copying file to astream"))
		call writeLog(build2("->t_rec->files.directory=",t_rec->files.directory))
		call writeLog(build2("->t_rec->files.full_details=",t_rec->files.by_provider))
		execute cov_astream_file_transfer t_rec->files.directory,t_rec->files.by_provider,"","MV"	
	endif
endif

set reply->status_data.status = "S"


call writeLog(build2("* END   Generating Output **********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
