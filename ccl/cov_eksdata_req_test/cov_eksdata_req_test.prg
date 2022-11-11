drop program cov_eksdata_req_test go
create program cov_eksdata_req_test
 
prompt 
	"EKSDATA_FILE" = "MINE"
	, "REQUEST_FILE" = ""
	, "SCRIPT" = "" 

with EKSDATA_FILE, REQUEST_FILE, SCRIPT
 
 
if ($EKSDATA_FILE = "")
	DECLARE FILEPATH1 = VC WITH CONSTANT( "CCLUSERDIR:test_eksdate.json" )
else
	DECLARE FILEPATH1 = VC WITH CONSTANT($EKSDATA_FILE )
endif
 
if ($REQUEST_FILE = "")
	DECLARE FILEPATH2 = VC WITH CONSTANT( "CCLUSERDIR:test_req_eksdate.json" )
else
	DECLARE FILEPATH2 = VC WITH CONSTANT($REQUEST_FILE )
endif
 
free set request
free set eksdata
 
declare eksdata_line_in = vc
declare request_line_in = vc
declare link_encntrid = f8 with noconstant(0.0)
declare link_personid = f8 with noconstant(0.0)
declare link_template = i4 with noconstant(0)
declare link_clineventid = f8 with noconstant(0.0)
declare log_misc1 = vc with noconstant("")
declare trigger_orderid = f8 with noconstant(0.0)
declare trigger_encntrid = f8 with noconstant(0.0)
declare trigger_personid = f8 with noconstant(0.0)
declare curindex = i2 with noconstant(0)
declare retval = i2 with noconstant(0)


FREE DEFINE RTL3
DEFINE RTL3 IS FILEPATH1
select into "nl:"
from rtl3t r
detail
	eksdata_line_in = concat(eksdata_line_in,r.line)
with nocounter
 
call echo(eksdata_line_in)
set stat = cnvtjsontorec(eksdata_line_in)
call echorecord(eksdata)
 
FREE DEFINE RTL3
DEFINE RTL3 IS FILEPATH2
select into "nl:"
from rtl3t r
detail
	request_line_in = concat(request_line_in,r.line)
with nocounter
 
call echo(request_line_in)
set stat = cnvtjsontorec(request_line_in)
call echorecord(request)
 
 
/*
set link_clineventid = request->CLIN_DETAIL_LIST[1].CLINICAL_EVENT_ID 
select into "nl:"
from
	clinical_event ce
plan ce
	where ce.clinical_event_id = link_clineventid
detail
	link_encntrid = ce.encntr_id
	link_personid = ce.person_id
with nocounter
*/

call parser(concat("execute ",trim($SCRIPT)," go ")) 
 
call echo(build2("retval = ",retval))
end go
 
 
;cov_eks_req_test "test.json" go
