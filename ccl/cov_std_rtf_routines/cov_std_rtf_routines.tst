execute cov_std_rtf_routines go

free record reply go

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
) go

call echo(Set_RTFReply("test")) go

call echorecord(RTF_DEFINITIONS) go
call echorecord(reply) go
