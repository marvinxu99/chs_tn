/*
;OPERATIONS -> sys_runccl (4903)
set debug_ind = 1 go 
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
 
set request->batch_selection = "ccl_template" go
set request->output_dist = "chad.cummings@covhlth.com" go
set request->ops_date = cnvtdatetime(curdate+0,curtime3) go
set reqinfo->updt_req = 4903 go
 
execute sys_runccl go
 
call echorecord(reply) go
*/
/*

free record 4903request go
 
record 4903request (
1 batch_selection = vc
1 output_dist = vc
1 ops_date = dq8
) go
 
 
free record 4903reply go
record 4903reply
(
1 ops_event = vc
%i cclsource:status_block.inc
) go
 
 
set 4903request->batch_selection = concat(^cov_pha_ops_prev_month NOFORMS^) go
set 4903request->output_dist = concat(^chad.cummings@covhlth.com^) go
set stat = tdbexecute(4600,4801,4903,"REC",4903request,"REC",4903reply) go
 
call echorecord(4903reply) go
 
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
free record patient_request go
record patient_request
(
	1 criteria[*]
	 2 value = vc
	 2 type = vc
) go
;~{'PATIENT_REQUEST':{'CRITERIA':[{'VALUE':'999999999','TYPE':'SSN'},
;{'VALUE':'11051955','TYPE':'DOB'},{'VALUE':'U','TYPE':'SEX'}]}}~

set stat = alterlist(patient_request->criteria,3) go
set patient_request->criteria[1].value = "999999999" go
set patient_request->criteria[1].type = "SSN" go

set patient_request->criteria[2].value = "11051955"  go
set patient_request->criteria[2].type = "DOB" go

set patient_request->criteria[3].value = "U" go
set patient_request->criteria[3].type = "SEX" go

call echo(cnvtrectojson(patient_request)) go
;declare _MEMORY_REPLY_STRING = vc go

set debug_ind = 0 go 
execute cov_patient_find_svc ^nl:^,cnvtrectojson(patient_request)  go

 
 
