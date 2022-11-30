/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_alteplase_admin_audit.prg
	Object name:		cov_alteplase_admin_audit
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

drop program cov_alteplase_admin_audit:dba go
create program cov_alteplase_admin_audit:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Select Facility" = 0 

with OUTDEV, FACILITY


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

free set t_rec
record t_rec
(
	1 cnt			= i4
	1 prompts
	 2 outdev		= vc
	 2 facility		= f8
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 outdev		= vc
	 2 run_dt_tm 	= dq8
	 2 atleplase_cd	= f8
	 2 tenecteplase_cd = f8
	1 query
	 2 facoper		= vc
	1 location[*]
	 2 location_cd  = f8
	1 dates
	 2 start_dt_tm	= dq8
	 2 stop_dt_tm	= dq8
	1 qual[*]
	 2 encntr_id	= f8
	 2 person_id	= f8
	 2 mrn			= vc
	 2 fin 			= vc
	 2 order_id		= f8
	 2 event_id		= f8
	 2 event_dt_tm	= dq8
	 2 patient_name	= vc
	 2 facility		= vc
	 2 unit			= vc
	 2 room			= vc
	 2 bed			= vc
	 2 orderable	= vc
	 2 financial_class = vc
)


set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->cons.atleplase_cd = uar_get_code_by("DISPLAY",200,"alteplase")
set t_rec->cons.tenecteplase_cd = uar_get_code_by("DISPLAY",200,"tenecteplase")

set t_rec->prompts.outdev = $OUTDEV

set t_rec->cons.outdev = t_rec->prompts.outdev


set t_rec->query.facoper =	fillstring(2,' ')
IF (SUBSTRING(1,1,reflect(parameter(parameter2($FACILITY),0)))="L")
	SET t_rec->query.facoper = "IN"
ELSEIF (parameter(parameter2($FACILITY),1) = 1.0)
	SET t_rec->query.facoper = "!="
ELSE
	SET t_rec->query.facoper = "="
ENDIF

/*
select into "nl:"
from
	location l
plan l
	where l.location_cd = $FACILITY
head report
	i = 0
detail
	i = (i + 1)
	stat = alterlist(t_rec->location,i)
	t_rec->location[i].location_cd = l.location_cd
with nocounter
*/

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

select into "nl:"
from
	orders o
	,order_detail od
	,clinical_event ce
	,ce_med_result cmr
	,encounter e
	,person p
plan o
	where o.catalog_cd in(t_rec->cons.atleplase_cd,t_rec->cons.tenecteplase_cd)
	and   o.active_ind = 1
join od
	where od.order_id = o.order_id
	and   od.oe_field_meaning = "VOLUMEDOSE"
	and   od.oe_field_value >= 50
	and   od.action_sequence = (
									select max(od2.action_sequence) from order_detail od2 where od.order_id = od2.order_id
									and od.oe_field_id = od2.oe_field_id
								)
join e
	where e.encntr_id = o.encntr_id
	and   operator(e.loc_facility_cd,t_rec->query.facoper,$FACILITY)
	and   e.financial_class_cd in(
									 value(uar_get_code_by("DISPLAY",354,"Self Pay"))
									,value(uar_get_code_by("DISPLAY",354,"Self Pay After Insurance"))
									;,value(uar_get_code_by("DISPLAY",354,"Medicare Advantage"))
									;,value(uar_get_code_by("DISPLAY",354,"Medicare"))
								 )
join p
	where p.person_id = e.person_id
join ce
	where ce.order_id = o.order_id
join cmr
	where cmr.event_id = ce.event_id
	and   cmr.admin_start_dt_tm >= cnvtdatetime(curdate-30,0)
head report
	i = 0
detail
	i = (i + 1)
	stat = alterlist(t_rec->qual,i)
	t_rec->qual[i].encntr_id = e.encntr_id
	t_rec->qual[i].person_id = p.person_id
	t_rec->qual[i].event_dt_tm = cmr.admin_start_dt_tm
	t_rec->qual[i].event_id	= ce.event_id
	t_rec->qual[i].patient_name = p.name_full_formatted
	t_rec->qual[i].order_id = o.order_id
	t_rec->qual[i].facility = uar_get_code_display(e.loc_facility_cd)
	t_rec->qual[i].unit = uar_get_code_display(e.loc_nurse_unit_cd)
	t_rec->qual[i].room = uar_get_code_display(e.loc_room_cd)
	t_rec->qual[i].bed = uar_get_code_display(e.loc_bed_cd)
	t_rec->qual[i].financial_class = uar_get_code_display(e.financial_class_cd)
	t_rec->qual[i].orderable = concat(o.order_mnemonic," (",o.hna_order_mnemonic,")")
foot report
	t_rec->cnt = i
with nocounter

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

call get_mrn(0)
call get_fin(0)

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

select into t_rec->cons.outdev
		 facility			= substring(1,150,t_rec->qual[d1.seq].facility		  )
		,unit			    = substring(1,150,t_rec->qual[d1.seq].unit			  )
		,room			    = substring(1,150,t_rec->qual[d1.seq].room			  )
		,bed                = substring(1,150,t_rec->qual[d1.seq].bed             )
		,patient_name       = substring(1,150,t_rec->qual[d1.seq].patient_name    )
		,mrn		        = substring(1,150,t_rec->qual[d1.seq].mrn		      )  
		,fin	            = substring(1,150,t_rec->qual[d1.seq].fin	          )  
		,orderable          = substring(1,150,t_rec->qual[d1.seq].orderable       )
		,admin_dt_tm        = format(t_rec->qual[d1.seq].event_dt_tm,"DD-MMM-YYYY HH:MM:SS;;q")
		,financial_class    = substring(1,150,t_rec->qual[d1.seq].financial_class )
		,encntr_id	        = t_rec->qual[d1.seq].encntr_id	    
		,person_id			= t_rec->qual[d1.seq].person_id			
		,order_id		    = t_rec->qual[d1.seq].order_id		
		,event_id           = t_rec->qual[d1.seq].event_id  
from
	(dummyt d1 with seq=t_rec->cnt)
order by
	t_rec->qual[d1.seq].event_dt_tm desc
with nocounter, format, separator = " "

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))



#exit_script



call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go

