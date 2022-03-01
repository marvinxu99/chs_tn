/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_cdi_routines.prg
  Object name:        cov_cdi_routines
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			initial build
******************************************************************************/
drop program cov_cdi_routines:dba go
create program cov_cdi_routines:dba


call echo(build2("starting ",trim(cnvtlower(curprog))))
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect

/**********************************************************************************************************************
** Function GET_CDI_CODE_QUERY_DEF(null)
** ---------------------------------------------------------------------------------------
** Return a JSON string with the cd_definition record structure that contains all the defined cdi queries
**
**********************************************************************************************************************/
declare get_cdi_code_query_def(null) = vc with persist, copy
subroutine get_cdi_code_query_def(null)
 
	declare vReturnJSON = vc with protect

	free record cdi_definition
	record cdi_definition
	(
		1 query_cnt 	= i4
		1 query_qual[*]
		 2 code_value	= f8
		 2 display		= vc
		 2 definition	= vc
		 2 coding_section = vc
		 2 code_cnt		= i4
		 2 code_qual[*]
		  3	code_value	= f8
		  3 display		= vc
		  3 description	= vc
		  3 icd10code	= vc
		  3 snomedcode 	= vc
		  3 uuid		= vc
		  3 diag_nomenclature_id = f8
		  3 snomed_nomenclature_id = f8
		  3 start_pos	= i4
		  3 end_pos		= i4
		  3 checked_value = vc
 	)
 	
 	select into "nl:"
	from
		 code_value_set cvs
		,code_value cv
		,code_value_group cvg
		,code_value c
		,code_value_extension cve
		,code_value_extension ce
	plan cvs
		where cvs.definition = "COVCUSTOM"
	join cv
		where cv.code_set = cvs.code_set
		and   cv.cdf_meaning = "CDI_QUERY"
		and   cv.active_ind = 1
		and   cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	join cvg
		where cvg.parent_code_value = cv.code_value
		and   cvg.code_set = cv.code_set
	join c
		where c.code_value = cvg.child_code_value
		and   c.cdf_meaning = "CDI_CODE"
		and   c.active_ind = 1
	join cve
		where cve.code_value = cv.code_value
		and   cve.field_name = "CODING_TITLE"
	join ce
		where ce.code_value = c.code_value
		and   ce.field_name = "CODING_UUID"
	order by
		cv.code_value
	head report
		i = 0
		j = 0
	head cv.code_value
		j = 0
		i = (i + 1)
		stat = alterlist(cdi_definition->query_qual,i)
		cdi_definition->query_qual[i].code_value		= cv.code_value
		cdi_definition->query_qual[i].definition		= cv.definition
		cdi_definition->query_qual[i].display		= cv.display
		cdi_definition->query_qual[i].coding_section	= cve.field_value
	detail
		j = (j + 1)
		stat = alterlist(cdi_definition->query_qual[i].code_qual,j)
		cdi_definition->query_qual[i].code_qual[j].code_value	= c.code_value
		cdi_definition->query_qual[i].code_qual[j].display		= c.display
		cdi_definition->query_qual[i].code_qual[j].icd10code		= piece(c.definition,";",1,"<notfound>")
		cdi_definition->query_qual[i].code_qual[j].snomedcode	= piece(c.definition,";",2,"<notfound>")
		cdi_definition->query_qual[i].code_qual[j].description	= c.description
		cdi_definition->query_qual[i].code_qual[j].uuid			= ce.field_value
	foot cv.code_value	
		cdi_definition->query_qual[i].code_cnt = j
	foot report
		cdi_definition->query_cnt = i
	with nocounter


	select into "nl:"
	from
		 (dummyt d1 with seq=cdi_definition->query_cnt)
		,(dummyt d2)
		,nomenclature n
	plan d1
		where maxrec(d2,cdi_definition->query_qual[d1.seq].code_cnt)
	join d2
	join n
		where n.source_identifier = cdi_definition->query_qual[d1.seq].code_qual[d2.seq].icd10code
		and   n.source_vocabulary_cd = value(uar_get_code_by("DISPLAY",400,"ICD-10-CM")) 
		and   n.active_ind = 1
		and   cnvtdatetime(curdate,curtime3) between n.beg_effective_dt_tm and n.end_effective_dt_tm
	order by
		n.beg_effective_dt_tm
	detail
		cdi_definition->query_qual[d1.seq].code_qual[d2.seq].diag_nomenclature_id = n.nomenclature_id
	with nocounter
	
	select into "nl:"
	from
		 (dummyt d1 with seq=cdi_definition->query_cnt)
		,(dummyt d2)
		,nomenclature n
	plan d1
		where maxrec(d2,cdi_definition->query_qual[d1.seq].code_cnt)
	join d2
	join n
		where n.source_identifier = cdi_definition->query_qual[d1.seq].code_qual[d2.seq].snomedcode
		and   n.source_vocabulary_cd = value(uar_get_code_by("DISPLAY",400,"SNOMED CT")) 
		and   n.active_ind = 1
		and   cnvtdatetime(curdate,curtime3) between n.beg_effective_dt_tm and n.end_effective_dt_tm
	order by
		n.beg_effective_dt_tm
	detail
		cdi_definition->query_qual[d1.seq].code_qual[d2.seq].snomed_nomenclature_id = n.nomenclature_id
	with nocounter
	
 	set vReturnJSON = cnvtrectojson(cdi_definition)
	return (vReturnJSON)
end
 
call echo(build2("finishing ",trim(cnvtlower(curprog))))


end 
go
