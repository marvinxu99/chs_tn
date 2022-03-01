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

declare mpage_content_url = vc with noconstant("mpage-content")

free record 3011001Request
record 3011001Request (
  1 Module_Dir = vc  
  1 Module_Name = vc  
  1 bAsBlob = i2   
) 

free record 3011001Reply
record 3011001Reply (
    1 info_line [* ]
      2 new_line = vc
    1 data_blob = gvc
    1 data_blob_size = i4
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )

free record 3011002Request
record 3011002Request (
  1 source_dir = vc  
  1 source_filename = vc  
  1 nbrlines = i4   
  1 line [*]   
    2 lineData = vc  
  1 OverFlowPage [*]   
    2 ofr_qual [*]   
      3 ofr_line = vc  
  1 IsBlob = c1   
  1 document_size = i4   
  1 document = gvc   
) 

free record 3011002Reply
record 3011002Reply (
   1 info_line [* ]
     2 new_line = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 
 
declare html_output = vc with noconstant(" ")


if ($REQUEST = "DEFINITIONS")

	set _memory_reply_string = get_cdi_code_query_def(null)
	call echo(build2("_memory_reply_string=",_memory_reply_string))
	go to exit_script

endif


set 3011001Request->Module_Dir = "cust_script:"
set 3011001Request->Module_Name = "cdi_audit.html"
set 3011001Request->bAsBlob = 1

execute eks_get_source with replace ("REQUEST" ,3011001Request ) , replace ("REPLY" ,3011001Reply )

if (3011001Reply->status_data.status = "S")
	set html_output = 3011001Reply->data_blob
else
	set html_output = "<html><body>Error with getting html source</body></html>"
endif

select into "nl:"
from
	dm_info di
plan di
	where di.info_name = "CONTENT_SERVICE_URL"
detail
	mpage_content_url = di.info_char
with nocounter

set html_output = replace(html_output,"%%MPAGE_CONTENT_URL%%",mpage_content_url)

set 3011002Request->source_dir = $OUTDEV
set 3011002Request->IsBlob = "1"
set 3011002Request->document = html_output
set 3011002Request->document_size = size(3011002Request->document)

execute eks_put_source with replace ("REQUEST" ,3011002Request ) , replace ("REPLY" ,3011002Reply )

call echorecord(3011001Reply)

#exit_script

end
go

