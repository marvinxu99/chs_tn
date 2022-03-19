
set debug_ind = 1 go
execute cov_std_cv_routines go

;select all that apply:
call echo(ensure_code_value_ext(3886338215,~CODING_TITLE~,~updated by subs~,1)) go

; 3886338215.00	     100496	CDI_QUERY	Sepsis Diagnosis Review	SEPSISDIAGNOSISREVIEW	Sepsis Diagnosis Review
;ensure_code_value(pCodeValue,pCodeSet,pCVCDFMeaning,pCVDisplay,pCVDefinition,pCVDescription)
call echo(
	ensure_code_value(3886338215,0.0,~CDI_QUERY~,~Sepsis Diagnosis Review~,~future~,~before~)
) go

	

