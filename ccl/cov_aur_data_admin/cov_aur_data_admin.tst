drop program cov_aur_data_admin_tst go
create program cov_aur_data_admin_tst 
	execute cov_aur_data_admin ~nl:~, ~~ 
	call pop_cust_au_dim_facility("au_sds_prod_dim_facility.csv") 
end go
execute cov_aur_data_admin_tst go
