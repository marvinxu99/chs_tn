

record 600417_request (
  1 script_name = vc  
  1 person_id = f8   
  1 encntr_id = f8   
  1 custom_field [*]   
    2 custom_field_show = i2   
) go

record 600417_reply (
   1 custom_field [* ]
     2 custom_field_index = i4
     2 custom_field_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc ) go
 
select into "nl:"
from
	 encntr_alias ea
	,encounter e
plan ea
	where ea.alias = "2304217765"
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
join e
	where e.encntr_id = ea.encntr_id
order by
	 ea.beg_effective_dt_tm desc
	,e.encntr_id
head report
	stat = 0
head e.encntr_id
	600417_request->script_name = "cov_pc_custom_banner_bar"
	600417_request->person_id	= e.person_id
	600417_request->encntr_id	= e.encntr_id
	for (i=1 to 5)
		stat = alterlist(600417_request->custom_field,i)
		600417_request->custom_field[i].custom_field_show = i
	endfor
with nocounter go

set debug_ind = 1 go
;set stat = tdbexecute(600005,600311,600417,"REC",600417_request,"REC",600417_reply) go

call echorecord(600417_request) go
execute test_pc_custom_banner_bar with replace("REQUEST",600417_REQUEST), replace("REPLY",600417_REPLY) go

;call echorecord(600417_reply) go

