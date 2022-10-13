drop program cov_bld_cx_contam_rpt_svc go
create program cov_bld_cx_contam_rpt_svc
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start date time" = "SYSDATE"
	, "End date time" = "SYSDATE"
 
with OUTDEV, begin_dt_tm, end_dt_tm
 
%i cust_script:cov_bld_cx_contam_rpt.inc
 
record t_rec
(
	1 ord_cnt = i2
	1 ord_qual[*]
	 2 catalog_cd = f8
	 2 mnemonic = vc
	1 resp_cnt = i2
	1 resp_qual[*]
	 2 response_cd = f8
	 2 response = vc
	1 exec_statement = vc
)
 
 
select into "nl:"
    cv1.display
    , cv1.code_value
    , cv1.display_key
 
from
    code_value   cv1
 
plan cv1 where cv1.code_set = value(1022)
and cv1.active_ind in (1)
 
order by
    cv1.display_key
head report
	cnt = 0
detail
	cnt += 1
	stat = alterlist(t_rec->resp_qual,cnt)
	t_rec->resp_qual[cnt].response = cv1.display
	t_rec->resp_qual[cnt].response_cd = cv1.code_value
foot report
	t_rec->resp_cnt = cnt
with nocounter
 
 
 
SELECT
    O.PRIMARY_MNEMONIC
    , O.CATALOG_CD
    , SORT = cnvtupper(O.PRIMARY_MNEMONIC)
 
FROM
    ORDER_CATALOG   O
 
plan o where o.catalog_type_cd = value(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
and o.activity_type_cd+0 = value(uar_get_code_by("MEANING",106,"MICROBIOLOGY"))
and o.active_ind = 1
ORDER BY
    SORT
head report
	cnt = 0
detail
	cnt += 1
	stat = alterlist(t_rec->ord_qual,cnt)
	t_rec->ord_qual[cnt].catalog_cd = o.catalog_cd
	t_rec->ord_qual[cnt].mnemonic = o.primary_mnemonic
foot report
	t_rec->ord_cnt = cnt
with nocounter
 
 
 
set t_rec->exec_statement = build2( 
										 ^execute cov_bld_cx_contam_rpt_drv ^
										,^"nl:"^
										,^,"^,format(cnvtdatetime($begin_dt_tm),"DD-MMM-YYYY HH:MM:SS;;q"),^"^
										,^,"^,format(cnvtdatetime($end_dt_tm),"DD-MMM-YYYY HH:MM:SS;;q"),^"^
										,^,null^
										,^,null^
										,^,value(^
									)

for (i=1 to t_rec->ord_cnt)
	if (i>1)
		set t_rec->exec_statement = build2( t_rec->exec_statement, ^,^)
	endif
	set t_rec->exec_statement = build2( t_rec->exec_statement, t_rec->ord_qual[i].catalog_cd)
endfor

set t_rec->exec_statement = build2( t_rec->exec_statement, ^),0.0 go^) 

call parser(t_rec->exec_statement)

select into $OUTDEV
from dummyt d1
head report
	col 0 "just a report"
 
set _MEMORY_REPLY_STRING = cnvtrectojson(contam,0,1,0)
 
call echorecord(contam->stats)
call echorecord(contam->rec)
call echorecord(t_rec)
 
end go
