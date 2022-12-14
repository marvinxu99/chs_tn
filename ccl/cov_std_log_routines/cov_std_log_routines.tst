set debug_ind = 1 go
execute cov_std_log_routines go

call echo(build2("get_dminfo_date=",get_dminfo_date("COV_DEV_OPS",concat(trim(cnvtupper(curprog)),":","start_dt_tm")))) go
call set_dminfo_date("COV_DEV_OPS",concat(trim(cnvtupper(curprog)),":","start_dt_tm"),cnvtdatetime(sysdate)) go
call echo(build2("get_dminfo_date=",get_dminfo_date("COV_DEV_OPS",concat(trim(cnvtupper(curprog)),":","start_dt_tm")))) go


