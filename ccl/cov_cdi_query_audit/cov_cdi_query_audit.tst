
;Run initial MPage HTML
execute cov_cdi_query_audit ~MINE~ go;,~UPDATE_CDI~,3888327185 go

;Get definitions 
execute cov_cdi_query_audit ~MINE~,~DEFINITIONS~ go

;Update Main CDI Definition
execute cov_cdi_query_audit ~MINE~,~UPDATE_CDI~,3888327185 go
