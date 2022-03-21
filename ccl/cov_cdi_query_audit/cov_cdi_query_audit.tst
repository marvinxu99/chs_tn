set debug_ind = 1 go

;Run initial MPage HTML
;execute cov_cdi_query_audit ~MINE~ go

;Get definitions 
;execute cov_cdi_query_audit ~MINE~,~DEFINITIONS~ go

;Update Main CDI Definition
;execute cov_cdi_query_audit ~MINE~,~UPDATE_CDI~,3886338215,~Today~,~Tomorrow~ go

;Update CDI Coding Code Value
;execute cov_cdi_query_audit ~MINE~,~UPDATE_CDI_CODE~,3886338993,~A41.9%J15.5~,~151281010~,~6961564d-6a6a-4e22-9125-496f5696ad3d~ go

;Get saved document
;execute cov_cdi_query_audit ~MINE~,~GET_SAVED_DOCUMENT~,4453870681 go
