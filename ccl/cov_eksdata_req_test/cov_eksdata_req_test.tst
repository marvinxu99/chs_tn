set debug_ind = 1 go
execute cov_eksdata_req_test 
								 "ccluserdir:wh_eksdata_1.json"
								,"ccluserdir:wh_request_1.json"
								,"cov_eks_bld_ingredient_list ^INC_MED_IV;INC_MED_PRN^" 
go
