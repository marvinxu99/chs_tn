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

execute cov_std_log_routines
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
declare str= vc with noconstant(" "), protect
declare notfnd= vc with constant("<not_found>"), protect
declare pos= i4 with noconstant(0), protect

call SubroutineLog(build2("notfnd=",notfnd))
call SubroutineLog(build2("str=",str))

/**********************************************************************************************************************
** Function VALIDATE_CDI_CODE_VALUE(code_value)
** ---------------------------------------------------------------------------------------
** Return TRUE or FALSE if the code value supplied is a valid CDI coding definition
**
**********************************************************************************************************************/
declare validate_cdi_code_value(vCDICodeValue=f8) = i2 with persist, copy
subroutine validate_cdi_code_value(vCDICodeValue)

	declare vReturnResponse = i2 with protect, noconstant(FALSE)
	
	select into "nl:"
	from
		code_value cv
		,code_value_set cvs
	plan cv
		where cv.code_value = vCDICodeValue
		and   cv.cdf_meaning = "CDI_CODE"
		and   cv.active_ind = 1
		and   cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	join cvs
		where cvs.code_set = cv.code_set
		and   cvs.definition = "COVCUSTOM"
	detail
		vReturnResponse = TRUE
	with nocounter
	
	return (vReturnResponse)
end

/**********************************************************************************************************************
** Function VALIDATE_CDI_VALUE(code_value)
** ---------------------------------------------------------------------------------------
** Return TRUE or FALSE if the code value supplied is a valid CDI definition
**
**********************************************************************************************************************/
declare validate_cdi_value(vCDIValue=f8) = i2 with persist, copy
subroutine validate_cdi_value(vCDIValue)

	declare vReturnResponse = i2 with protect, noconstant(FALSE)
	
	select into "nl:"
	from
		code_value cv
		,code_value_set cvs
	plan cv
		where cv.code_value = vCDIValue
		and   cv.cdf_meaning = "CDI_QUERY"
		and   cv.active_ind = 1
		and   cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	join cvs
		where cvs.code_set = cv.code_set
		and   cvs.definition = "COVCUSTOM"
	detail
		vReturnResponse = TRUE
	with nocounter
	
	return (vReturnResponse)
end

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
		  3 definition  = vc
		  3 icd10code	= vc
		  3 snomedcode 	= vc
		  3 uuid		= vc
		  3 diag_nomenclature_id = f8
		  3 snomed_nomenclature_id = f8
		  3 start_pos	= i4
		  3 end_pos		= i4
		  3 checked_value = vc
		  3 codes_cnt = i4
	  	  3 codes[*]
	   		4 diag_nomenclature_id = f8
	   		4 snomed_nomenclature_id = f8
	   		4 icd10code	= vc
	   		4 snomedcode = vc
	   		4 icd10_ind = i4
	   		4 snomed_ind = i4
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
		pos = 0
		notfnd = "<not_found>"
		str=fillstring(100," ")
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
		cdi_definition->query_qual[i].code_qual[j].definition	= c.definition
		cdi_definition->query_qual[i].code_qual[j].icd10code	= piece(c.definition,";",1,notfnd)
		cdi_definition->query_qual[i].code_qual[j].snomedcode	= piece(c.definition,";",2,notfnd)
		cdi_definition->query_qual[i].code_qual[j].description	= c.description
		cdi_definition->query_qual[i].code_qual[j].uuid			= ce.field_value
		
		call SubroutineLog(build2("notfnd=",notfnd))
		call SubroutineLog(build2("str=",str))
		
		pos = 0
		cnt = 0
		if (piece(cdi_definition->query_qual[i].code_qual[j].icd10code,"%",1,notfnd) != notfnd)
			pos = 1
			str = " "
			while (str != notfnd)
				str = piece(cdi_definition->query_qual[i].code_qual[j].icd10code,'%',pos,notfnd)
				call SubroutineLog(build2("->pos=",pos))
				call SubroutineLog(build2("->str=",str))
				if (str != notfnd)
					cnt = (cnt + 1)
					stat = alterlist(cdi_definition->query_qual[i].code_qual[j].codes,cnt)
					cdi_definition->query_qual[i].code_qual[j].codes[cnt].icd10_ind = 1
					cdi_definition->query_qual[i].code_qual[j].codes[cnt].icd10code = str
				endif
				pos = pos+1
			endwhile
		endif
	
		if (piece(cdi_definition->query_qual[i].code_qual[j].snomedcode,"%",1,notfnd) != notfnd)
			pos = 1
			str = ""
			while (str != notfnd)
				str = piece(cdi_definition->query_qual[i].code_qual[j].snomedcode,'%',pos,notfnd)
				if (str != notfnd)
					cnt = (cnt + 1)
					stat = alterlist(cdi_definition->query_qual[i].code_qual[j].codes,cnt)
					cdi_definition->query_qual[i].code_qual[j].codes[cnt].snomed_ind = 1
					cdi_definition->query_qual[i].code_qual[j].codes[cnt].snomedcode = str
				endif
				pos = pos+1
			endwhile
		endif
		cdi_definition->query_qual[i].code_qual[j].codes_cnt = cnt
	foot cv.code_value	
		cdi_definition->query_qual[i].code_cnt = j
	foot report
		cdi_definition->query_cnt = i
	with nocounter


	select into "nl:"
	from
		 (dummyt d1 with seq=cdi_definition->query_cnt)
		,(dummyt d2)
		,(dummyt d3)
		,nomenclature n
	plan d1
		where maxrec(d2,cdi_definition->query_qual[d1.seq].code_cnt)
	join d2
		where maxrec(d3,cdi_definition->query_qual[d1.seq].code_qual[d2.seq].codes_cnt)
	join d3
		join n
		where n.source_identifier = cdi_definition->query_qual[d1.seq].code_qual[d2.seq].codes[d3.seq].icd10code
		and   n.source_vocabulary_cd = value(uar_get_code_by("DISPLAY",400,"ICD-10-CM")) 
		and   n.active_ind = 1
		and   cnvtdatetime(curdate,curtime3) between n.beg_effective_dt_tm and n.end_effective_dt_tm
	order by
		n.beg_effective_dt_tm
	detail
		cdi_definition->query_qual[d1.seq].code_qual[d2.seq].codes[d3.seq].diag_nomenclature_id = n.nomenclature_id
	with nocounter
	
	select into "nl:"
	from
		 (dummyt d1 with seq=cdi_definition->query_cnt)
		,(dummyt d2)		
		,(dummyt d3)
		,nomenclature n
	plan d1
		where maxrec(d2,cdi_definition->query_qual[d1.seq].code_cnt)
	join d2
		where maxrec(d3,cdi_definition->query_qual[d1.seq].code_qual[d2.seq].codes_cnt)
	join d3
		join n
		where n.source_identifier = cdi_definition->query_qual[d1.seq].code_qual[d2.seq].codes[d3.seq].snomedcode
		and   n.source_vocabulary_cd = value(uar_get_code_by("DISPLAY",400,"SNOMED CT")) 
		and   n.active_ind = 1
		and   cnvtdatetime(curdate,curtime3) between n.beg_effective_dt_tm and n.end_effective_dt_tm
	order by
		n.beg_effective_dt_tm
	detail
		cdi_definition->query_qual[d1.seq].code_qual[d2.seq].codes[d3.seq].snomed_nomenclature_id = n.nomenclature_id
	with nocounter
	
	call SubroutineLog("cdi_definition","record")
	
 	set vReturnJSON = cnvtrectojson(cdi_definition)
	return (vReturnJSON)
end
 
call echo(build2("finishing ",trim(cnvtlower(curprog))))


end 
go
