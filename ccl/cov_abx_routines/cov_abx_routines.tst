drop program cov_abx_routines_tst go
create program cov_abx_routines_tst
set debug_ind = 1  
execute cov_abx_routines  
call echo(get_cdi_code_query_def(null)) 
end go
cov_abx_routines_tst go
