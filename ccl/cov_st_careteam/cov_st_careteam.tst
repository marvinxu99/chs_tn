free set request go
record request
(
  1 output_device     = vc
  1 script_name       = vc
  1 person_cnt        = i4
  1 person[*]
      2 person_id     = f8
  1 visit_cnt = i4
  1 visit[*]
      2 encntr_id     = f8
  1 prsnl_cnt = i4
  1 prsnl[*]
      2 prsnl_id      = f8
  1 nv_cnt = i4
  1 nv[*]
      2 pvc_name      = vc
      2 pvc_value     = vc
  1 batch_selection   = vc
) go
 
free set reply go
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
) go
 
select into "nl:"
from
	encntr_alias ea
	,encounter e
plan ea
	where ea.alias = "2122000324"
join e
	where e.encntr_id = ea.encntr_id
head report
	cnt = 1
detail
	request->visit_cnt = cnt
	stat = alterlist(request->visit,cnt)
	request->visit[cnt].encntr_id = e.encntr_id
 
	request->person_cnt = cnt
	stat = alterlist(request->person,cnt)
	request->person[cnt].person_id = e.person_id
 
	request->prsnl_cnt = cnt
	stat = alterlist(request->prsnl,cnt)
	request->prsnl[cnt].prsnl_id = reqinfo->updt_id
with nocounter go
 
set debug_ind = 1 go
execute cov_st_careteam go
 
call echorecord(request) go
call echorecord(reply) go
 
