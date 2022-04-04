/*
;OPERATIONS -> sys_runccl (4903)
 
free record request go
record request (
	1 batch_selection = vc
	1 output_dist = vc
	1 ops_date = dq8
	) go
 
Free record reply go
record reply (
	1 ops_event = vc
%i cclsource:status_block.inc
	) go
 
set request->batch_selection = "CCL_TEMPLATE" go
set request->output_dist = "chad.cummings@covhlth.com" go
set request->ops_date = cnvtdatetime(curdate+0,curtime3) go
set reqinfo->updt_req = 4903 go
 
execute sys_runccl go
 
call echorecord(reply) go
 
 
 
 
free record request go
record request (
  1 program_name = vc
  1 query_command = vc
  1 output_device = vc
  1 Is_printer = i1
  1 Is_Odbc = i1
  1 IsBlob = i1
  1 params = vc
  1 qual[*]
    2 parameter = vc
    2 data_type = i1
  1 blob_in = gvc
) go
 
set request->program_name = "CCL_TEMPLATE" go
;set request->output_device = "MINE" go
set request->params = ^"MINE"^ go
 
execute VCCL_RUN_PROGRAM go
*/
 
set debug_ind = 0 go
;execute cov_rpt_cpoe_orders "OPS","01-SEP-2020 00:00:00","30-SEP-2020 23:59:00",0,1  go
;execute cov_rpt_cpoe_orders "OPS","01-SEP-2020 00:00:00","30-SEP-2020 23:59:00",0,0  go
execute cov_rpt_cpoe_orders "OPS","01-FEB-2022 00:00:00","28-FEB-2022 23:59:00",0,1  go
execute cov_rpt_cpoe_orders "OPS","01-FEB-2022 00:00:00","28-FEB-2022	 23:59:00",0,0  go
 
 
 
 
 