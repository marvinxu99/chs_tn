/******************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		06/01/2020
	Solution:			
	Source file name:	pfmt_cov_msgview.prg
	Object name:		pfmt_cov_msgview
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	06/01/2020	  Chad Cummings
******************************************************************************/
drop program pfmt_cov_msgview:dba go
create program pfmt_cov_msgview:dba

%i cust_scirpt:cov_script_logging.inc  

free set t_rec
record t_rec
(
	1 cnt			= i4
	1 filename_a      = vc
	1 filename_b    = vc
	1 filename_c = vc
	1 audit_cnt = i4
	1 audit[*]
	 2 section = vc
	 2 title = vc
	 2 alias = vc
	 2 misc = vc
)

set t_rec->filename_a = concat(	 "cclscratch:"
								,trim(cnvtlower(curprog))
								,"_"
								,trim(cnvtstring(reqinfo->updt_req))
								,"_"
								,trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
call echojson(t_rec, t_rec->filename_a , 0) 

call log_message(concat(cnvtlower(curprog)," debug start execution..."), 0)

if (validate(reqinfo))
	call log_message(concat(cnvtrectojson(reqinfo)), 0)
	call echojson(reqinfo, t_rec->filename_a , 1) 
endif
if (validate(request))
	call log_message(concat(cnvtrectojson(request)), 0)
	call echojson(request, t_rec->filename_a , 1) 
endif

if (validate(requestin))
	call log_message(concat(cnvtrectojson(requestin)), 0)
	call echojson(requestin, t_rec->filename_a , 1) 
endif

call log_message(concat(cnvtrectojson(reqinfo)), 0)
if (validate(reply))
	call log_message(concat(cnvtrectojson(reply)), 0)
endif
call log_message(concat(cnvtlower(curprog)," debug finish execution..."), 0)
#exit_script
call log_message(concat(cnvtlower(curprog)," exit..."), 0)

end go
