
execute cov_std_ord_routines go

call echo(SetupOrder(125328124.00)) go
call echo(UpdateOrderDetailValueCd("COLLPRI",value(uar_get_code_by("MEANING",2054,"ROUTINE")))) go
call echo(UpdateOrderDetailValueCd("PRIORITY",value(uar_get_code_by("MEANING",1304,"STAT")))) go
call echo(UpdateOrderDetailDtTm("REQSTARTDTTM",cnvtdatetime(curdate,curtime3))) go
call echo(AddOrderComment(concat("adding a comment to see if this works"
									,"how long can the comment be"
									,"i was running into a limit i think when adding one through"
									,"ordering process. It should be much longer than that"))) go
call echorecord(ordrequest) go
call echo(CallOrderServer(null)) go
