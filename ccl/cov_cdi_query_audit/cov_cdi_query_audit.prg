/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_cdi_query_audit.prg
  Object name:        cov_cdi_query_audit
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			initial build
******************************************************************************/
drop program cov_cdi_query_audit go
create program cov_cdi_query_audit 

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "REQUEST" = "" 

with OUTDEV, REQUEST


execute cov_cdi_routines
execute cov_std_html_routines

declare mpage_content_url = vc with noconstant(" ") 
declare html_output = vc with noconstant(" ")


if ($REQUEST = "DEFINITIONS")

	set _memory_reply_string = get_cdi_code_query_def(null)
	call echo(build2("_memory_reply_string=",_memory_reply_string))
	go to exit_script

endif


set html_output = get_html_template("cdi_audit.html")

set html_output = replace(html_output,"%%MPAGE_CONTENT_URL%%",get_content_service_url(null))
	
call put_html_output($OUTDEV,html_output)

#exit_script

end
go

