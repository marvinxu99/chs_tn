
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       
  Solution:
  Source file name:   cov_eks_req_test.prg
  Object name:        cov_eks_req_test
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Called by ccl program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   			  Chad Cummings			initial build
******************************************************************************/
drop program cov_eks_req_test go
create program cov_eks_req_test 

prompt 
	"FILENAME" = ""
	, "REQUEST" = "" 

with FILENAME, REQUEST


if ($FILENAME = "")
	DECLARE FILEPATH = VC WITH CONSTANT( "CCLUSERDIR:3091000.dat" ) 
else
	DECLARE FILEPATH = VC WITH CONSTANT($FILENAME ) 
endif
 
free set request 

declare line_in = vc 

FREE DEFINE RTL3 
DEFINE RTL3 IS FILEPATH 
select into "nl:"
from rtl3t r
detail
	line_in = concat(line_in,r.line)
with nocounter 
;call echo(line_in) go
set stat = cnvtjsontorec(line_in) 

call echorecord(request) 

if ($REQUEST = "3091000")
	set stat = tdbexecute(1000000,3091000,3091000,"REC",request,"REC",rec_reply)
elseif ($REQUEST = "560201")
	set stat = tdbexecute(650001,560201,560201,"REC",request,"REC",rec_reply)
endif


call echorecord(rec_reply)
end go


;cov_eks_req_test "test.json" go
