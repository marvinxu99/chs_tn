drop program cov_cdi_routines_tst go
create program cov_cdi_routines_tst
set debug_ind = 1  
execute cov_cdi_routines  
call echo(get_cdi_code_query_def(null)) 
end go
cov_cdi_routines_tst go
