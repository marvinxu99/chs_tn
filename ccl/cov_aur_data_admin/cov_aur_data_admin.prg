/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_aur_data_admin.prg
	Object name:		cov_aur_data_admin
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_aur_data_admin:dba go
create program cov_aur_data_admin:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "MODE" = "" 

with OUTDEV, MODE


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
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
)
endif


;free set t_rec
record t_rec
(
	1 cnt			= i4
	1 prompts
	 2 outdev		= vc
	 2 mode			= vc
	1 files
	 2 records_attachment		= vc
	1 dminfo
	 2 info_domain	= vc
	 2 info_name	= vc
	1 cons
	 2 run_dt_tm 	= dq8
	1 dates
	 2 start_dt_tm	= dq8
	 2 end_dt_tm	= dq8
	1 qual[*]
	 2 person_id	= f8
	 2 encntr_id	= f8
	 2 mrn			= vc
	 2 fin			= vc
	 2 name_full_formatted = vc
)

;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.mode = $MODE

set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

declare create_cust_au_adtwardmapping(p1=vc) = i2 with copy
subroutine create_cust_au_adtwardmapping(p1)
		;FacilityID	WardTypeCode	WardID	WardName	NHSNLocationTypeCode
		
		drop table cust_au_adtwardmapping
        select into table cust_au_adtwardmapping
            FacilityID       		= type("vc"),
            WardTypeCode     		= type("vc"),
            WardID           		= type("vc"),
            WardName    	 		= type("vc"),
            NHSNLocationTypeCode    = type("vc")
        from dummyt         d
        with    constraint(WardID, "primary key", "unique"),
                index(WardID),
                index(FacilityID),
                synonym = "CUST_AU_ADTWARDMAPPING",
                organization = "P"
        
        execute oragen3 "CUST_AU_ADTWARDMAPPING"
        
	return (TRUE)
end

declare pop_cust_au_adtwardmapping(p1=vc) = i2 with copy
subroutine pop_cust_au_adtwardmapping(p1)

	if(findfile(p1) = 0)
   		call echo("*************************************************************************")
    	call echo(concat("Failed - could not find the file: ", p1))
    	call echo("*************************************************************************")
    	return (FALSE)
	endif
	
	free define rtl3
	define rtl3 is p1

	free record temp_cust_au_adtwardmapping
	record temp_cust_au_adtwardmapping
	(
		1 cnt = i4
		1 qual[*]
		 2 FacilityID = vc
		 2 WardTypeCode = vc
		 2 WardID = vc
		 2 WardName = vc
		 2 NHSNLocationTypeCode = vc
	)
	
	select into "nl:"
	from rtl3t r
	where r.line > ""
	head report 
		i = 0
	detail
		i += 1
		stat = alterlist(temp_cust_au_adtwardmapping->qual,i)
		temp_cust_au_adtwardmapping->qual[i].FacilityID				= piece(r.line,",",1,"notfnd",0)
		temp_cust_au_adtwardmapping->qual[i].WardTypeCode			= piece(r.line,",",2,"notfnd",0)
		temp_cust_au_adtwardmapping->qual[i].WardID					= piece(r.line,",",3,"notfnd",0)
		temp_cust_au_adtwardmapping->qual[i].WardName				= piece(r.line,",",4,"notfnd",0)
		temp_cust_au_adtwardmapping->qual[i].NHSNLocationTypeCode	= piece(r.line,",",5,"notfnd",0)
	foot report
		temp_cust_au_adtwardmapping->cnt = i
	with nocounter
	
	call echorecord(temp_cust_au_adtwardmapping)
	
	if (temp_cust_au_adtwardmapping->cnt > 0)
		
		for (i=1 to temp_cust_au_adtwardmapping->cnt)
			if ((temp_cust_au_adtwardmapping->qual[i].WardID != "notfnd")
				 and (temp_cust_au_adtwardmapping->qual[i].WardID != "WardID"))
				insert into cust_au_adtwardmapping
				set 
					 FacilityID 			= temp_cust_au_adtwardmapping->qual[i].FacilityID
					,WardTypeCode			= temp_cust_au_adtwardmapping->qual[i].WardTypeCode
					,WardID					= temp_cust_au_adtwardmapping->qual[i].WardID	
					,WardName				= temp_cust_au_adtwardmapping->qual[i].WardName
					,NHSNLocationTypeCode	= temp_cust_au_adtwardmapping->qual[i].NHSNLocationTypeCode
				commit
			endif
		endfor
	
	endif
	
	return (TRUE)
end


declare create_cust_au_dim_facility(p1=vc) = i2 with copy
subroutine create_cust_au_dim_facility(p1)
		;FacilityID	FacilityName
		
		drop table cust_au_dim_facility
        select into table cust_au_dim_facility
            FacilityID       		= type("vc"),
            FacilityName     		= type("vc")
        from dummyt         d
        with    constraint(FacilityID, "primary key", "unique"),
                index(FacilityID),
                synonym = "CUST_AU_DIM_FACILITY",
                organization = "P"
        
        execute oragen3 "CUST_AU_DIM_FACILITY"
        
	return (TRUE)
end

declare pop_cust_au_dim_facility(p1=vc) = i2 with copy
subroutine pop_cust_au_dim_facility(p1)

	if(findfile(p1) = 0)
   		call echo("*************************************************************************")
    	call echo(concat("Failed - could not find the file: ", p1))
    	call echo("*************************************************************************")
    	return (FALSE)
	endif
	
	free define rtl3
	define rtl3 is p1

	free record temp_cust_au_dim_facility
	record temp_cust_au_dim_facility
	(
		1 cnt = i4
		1 qual[*]
		 2 FacilityID = vc
		 2 FacilityName = vc
	)
	
	select into "nl:"
	from rtl3t r
	where r.line > ""
	head report 
		i = 0
	detail
		i += 1
		stat = alterlist(temp_cust_au_dim_facility->qual,i)
		temp_cust_au_dim_facility->qual[i].FacilityID			= piece(r.line,",",1,"notfnd",0)
		temp_cust_au_dim_facility->qual[i].FacilityName			= piece(r.line,",",2,"notfnd",0)
	foot report
		temp_cust_au_dim_facility->cnt = i
	with nocounter
	
	call echorecord(temp_cust_au_dim_facility)
	
	if (temp_cust_au_dim_facility->cnt > 0)
		
		for (i=1 to temp_cust_au_dim_facility->cnt)
			if ((temp_cust_au_dim_facility->qual[i].FacilityName != "notfnd") and 
				(temp_cust_au_dim_facility->qual[i].FacilityName != "FacilityName"))
				insert into cust_au_dim_facility
				set 
					 FacilityID 			= temp_cust_au_dim_facility->qual[i].FacilityID
					,FacilityName			= temp_cust_au_dim_facility->qual[i].FacilityName
				commit
			endif
		endfor
	
	endif
	
	return (TRUE)
end


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

if (t_rec->prompts.mode = "CREATE")
	call writeLog(build2("->creating tables"))
	call create_cust_au_adtwardmapping(null)
	call create_cust_au_dim_facility(null)
endif

if (t_rec->prompts.mode = "POPULATE")
	call writeLog(build2("->populating tables"))
	call pop_cust_au_adtwardmapping("au_sds_prod_adtwardmapping.csv")
	call pop_cust_au_dim_facility("au_sds_prod_dim_facility.csv")
endif





call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

/*
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit *************************************"))
	call writeAudit(build2(
							char(34),^ITEM^,char(34),char(44),
							char(34),^DESC^,char(34)
						))
for (i=1 to t_rec->cnt)
		call writeAudit(build2(
							char(34),t_rec->qual[i].a											,char(34),char(44),
							char(34),t_rec->qual[i].b											,char(34)
						))

endfor
call writeLog(build2("* END   Creating Audit *************************************"))
call writeLog(build2("************************************************************"))
*/

#exit_script

;call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
;execute cov_astream_file_transfer "cclscratch",t_rec->files.records_attachment,"Extracts/HIM/","CP" 
;execute cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)


call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
