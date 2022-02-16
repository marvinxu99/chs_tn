execute pfmt_cov_msgview go
call echo(build2("CURSERVER=",CURSERVER)) go

  execute msgrtl go


declare log_handle = i4 go

set log_handle = 0 go

set log_level = 2 go ; error LEVEL

set log_handle = uar_MsgOpen( "CCLMSGTEST" ) go

call uar_Msgsetlevel( log_handle, log_level ) go

; log message

set stat =  uar_msgwrite( log_handle, 0, "CCLTEST", 2, "Testing msgwrite" ) go
;call echo(build2("stat=",stat)) go
; end of program

call echo(log_handle) go
call uar_msgclose( log_handle ) go

