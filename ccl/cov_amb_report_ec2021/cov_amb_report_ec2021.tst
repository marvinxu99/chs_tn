;set debug_ind = 1 go
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
 
 
set 4903request->batch_selection = concat(^cov_amb_report_ec2021 NOFORMS^) go
set 4903request->output_dist = concat(^chad.cummings@covhlth.com^) go
set stat = tdbexecute(4600,4801,4903,"REC",4903request,"REC",4903reply) go
 
call echorecord(4903reply) go
 
;execute cov_amb_report_ec2021 ^MINE^ go
