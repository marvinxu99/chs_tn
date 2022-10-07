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
	
	;call echorecord(temp_cust_au_adtwardmapping)
	
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
	
	;call echorecord(temp_cust_au_dim_facility)
	
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

declare create_cust_au_nhsnloctypecode(p1=vc) = i2 with copy
subroutine create_cust_au_nhsnloctypecode(p1)
		;NHSNLocationTypeCode,NHSNLocationTypeName
		
		drop table cust_au_nhsnloctypecode
        select into table cust_au_nhsnloctypecode
            NHSNLocationTypeCode       		= type("vc"),
            NHSNLocationTypeName     		= type("vc")
        from dummyt         d
        with    constraint(NHSNLocationTypeCode, "primary key", "unique"),
                index(NHSNLocationTypeCode),
                synonym = "CUST_AU_NHSNLOCTYPECODE",
                organization = "P"
        
        execute oragen3 "CUST_AU_NHSNLOCTYPECODE"
        
	return (TRUE)
end

declare pop_cust_au_nhsnloctypecode(p1=vc) = i2 with copy
subroutine pop_cust_au_nhsnloctypecode(p1)

	if(findfile(p1) = 0)
   		call echo("*************************************************************************")
    	call echo(concat("Failed - could not find the file: ", p1))
    	call echo("*************************************************************************")
    	return (FALSE)
	endif
	
	free define rtl3
	define rtl3 is p1

	free record temp_cust_au_nhsnloctypecode
	record temp_cust_au_nhsnloctypecode
	(
		1 cnt = i4
		1 qual[*]
		 2 NHSNLocationTypeCode = vc
		 2 NHSNLocationTypeName = vc
	)
	
	select into "nl:"
	from rtl3t r
	where r.line > ""
	head report 
		i = 0
	detail
		i += 1
		stat = alterlist(temp_cust_au_nhsnloctypecode->qual,i)
		temp_cust_au_nhsnloctypecode->qual[i].NHSNLocationTypeCode			= piece(r.line,",",1,"notfnd",0)
		temp_cust_au_nhsnloctypecode->qual[i].NHSNLocationTypeName			= piece(r.line,",",2,"notfnd",0)
	foot report
		temp_cust_au_nhsnloctypecode->cnt = i
	with nocounter
	
	;call echorecord(temp_cust_au_nhsnloctypecode)
	
	if (temp_cust_au_nhsnloctypecode->cnt > 0)
		
		for (i=1 to temp_cust_au_nhsnloctypecode->cnt)
			if ((temp_cust_au_nhsnloctypecode->qual[i].NHSNLocationTypeName != "notfnd") and 
				(temp_cust_au_nhsnloctypecode->qual[i].NHSNLocationTypeName != "NHSNLocationTypeName"))
				insert into cust_au_nhsnloctypecode
				set 
					 NHSNLocationTypeCode 			= temp_cust_au_nhsnloctypecode->qual[i].NHSNLocationTypeCode
					,NHSNLocationTypeName			= temp_cust_au_nhsnloctypecode->qual[i].NHSNLocationTypeName
				commit
			endif
		endfor
	
	endif
	
	return (TRUE)
end


declare create_cust_au_localdrugingredcode(p1=vc) = i2 with copy
subroutine create_cust_au_localdrugingredcode(p1)
		;LocalDrugIngredientCode,LocalDrugIngredientName
		
		drop table cust_au_localdrugingredcode
        select into table cust_au_localdrugingredcode
            LocalDrugIngredientCode       		= type("vc"),
            LocalDrugIngredientName     		= type("vc")
        from dummyt         d
        with    constraint(LocalDrugIngredientCode, "primary key", "unique"),
                index(LocalDrugIngredientCode),
                synonym = "CUST_AU_LOCALDRUGINGREDCODE",
                organization = "P"
        
        execute oragen3 "CUST_AU_LOCALDRUGINGREDCODE"
        
	return (TRUE)
end

declare pop_cust_au_localdrugingredcode(p1=vc) = i2 with copy
subroutine pop_cust_au_localdrugingredcode(p1)

	if(findfile(p1) = 0)
   		call echo("*************************************************************************")
    	call echo(concat("Failed - could not find the file: ", p1))
    	call echo("*************************************************************************")
    	return (FALSE)
	endif
	
	free define rtl3
	define rtl3 is p1

	free record temp_cust_au_localdrugingredcode
	record temp_cust_au_localdrugingredcode
	(
		1 cnt = i4
		1 qual[*]
		 2 LocalDrugIngredientCode = vc
		 2 LocalDrugIngredientName = vc
	)
	
	select into "nl:"
	from rtl3t r
	where r.line > ""
	head report 
		i = 0
	detail
		i += 1
		stat = alterlist(temp_cust_au_localdrugingredcode->qual,i)
		temp_cust_au_localdrugingredcode->qual[i].LocalDrugIngredientCode			= piece(r.line,",",1,"notfnd",0)
		temp_cust_au_localdrugingredcode->qual[i].LocalDrugIngredientName			= piece(r.line,",",2,"notfnd",0)
	foot report
		temp_cust_au_localdrugingredcode->cnt = i
	with nocounter
	
	;call echorecord(temp_cust_au_localdrugingredcode)
	
	if (temp_cust_au_localdrugingredcode->cnt > 0)
		
		for (i=1 to temp_cust_au_localdrugingredcode->cnt)
			if ((temp_cust_au_localdrugingredcode->qual[i].LocalDrugIngredientName != "notfnd") and 
				(temp_cust_au_localdrugingredcode->qual[i].LocalDrugIngredientName != "LocalDrugIngredientName"))
				insert into cust_au_localdrugingredcode
				set 
					 LocalDrugIngredientCode 			= temp_cust_au_localdrugingredcode->qual[i].LocalDrugIngredientCode
					,LocalDrugIngredientName			= temp_cust_au_localdrugingredcode->qual[i].LocalDrugIngredientName
				commit
			endif
		endfor
	
	endif
	
	return (TRUE)
end


declare create_cust_au_nhsndrugingredcode(p1=vc) = i2 with copy
subroutine create_cust_au_nhsndrugingredcode(p1)
		;NHSNDrugIngredientCode,NHSNDrugIngredientCodeSystem,NHSNDrugIngredientName
		
		drop table cust_au_nhsndrugingredcode
        select into table cust_au_nhsndrugingredcode
            NHSNDrugIngredientCode       		= type("vc"),
            NHSNDrugIngredientCodeSystem     	= type("vc"),
            NHSNDrugIngredientName     			= type("vc")
        from dummyt         d
        with    constraint(NHSNDrugIngredientCode, "primary key", "unique"),
                index(NHSNDrugIngredientCode),
                synonym = "CUST_AU_NHSNDRUGINGREDCODE",
                organization = "P"
        
        execute oragen3 "CUST_AU_NHSNDRUGINGREDCODE"
        
	return (TRUE)
end

declare pop_cust_au_nhsndrugingredcode(p1=vc) = i2 with copy
subroutine pop_cust_au_nhsndrugingredcode(p1)

	if(findfile(p1) = 0)
   		call echo("*************************************************************************")
    	call echo(concat("Failed - could not find the file: ", p1))
    	call echo("*************************************************************************")
    	return (FALSE)
	endif
	
	free define rtl3
	define rtl3 is p1

	free record temp_cust_au_nhsndrugingredcode
	record temp_cust_au_nhsndrugingredcode
	(
		1 cnt = i4
		1 qual[*]
		 2 NHSNDrugIngredientCode = vc
		 2 NHSNDrugIngredientCodeSystem = vc
		 2 NHSNDrugIngredientName = vc
	)
	
	select into "nl:"
	from rtl3t r
	where r.line > ""
	head report 
		i = 0
	detail
		i += 1
		stat = alterlist(temp_cust_au_nhsndrugingredcode->qual,i)
		temp_cust_au_nhsndrugingredcode->qual[i].NHSNDrugIngredientCode			= piece(r.line,",",1,"notfnd",0)
		temp_cust_au_nhsndrugingredcode->qual[i].NHSNDrugIngredientCodeSystem	= piece(r.line,",",2,"notfnd",0)
		temp_cust_au_nhsndrugingredcode->qual[i].NHSNDrugIngredientName			= piece(r.line,",",3,"notfnd",0)
	foot report
		temp_cust_au_nhsndrugingredcode->cnt = i
	with nocounter
	
	;call echorecord(temp_cust_au_nhsndrugingredcode)
	
	if (temp_cust_au_nhsndrugingredcode->cnt > 0)
		
		for (i=1 to temp_cust_au_nhsndrugingredcode->cnt)
			if ((temp_cust_au_nhsndrugingredcode->qual[i].NHSNDrugIngredientName != "notfnd") and 
				(temp_cust_au_nhsndrugingredcode->qual[i].NHSNDrugIngredientName != "NHSNDrugIngredientName"))
				insert into cust_au_nhsndrugingredcode
				set 
					 NHSNDrugIngredientCode 			= temp_cust_au_nhsndrugingredcode->qual[i].NHSNDrugIngredientCode
					,NHSNDrugIngredientCodeSystem		= temp_cust_au_nhsndrugingredcode->qual[i].NHSNDrugIngredientCodeSystem
					,NHSNDrugIngredientName				= temp_cust_au_nhsndrugingredcode->qual[i].NHSNDrugIngredientName
				commit
			endif
		endfor
	
	endif
	
	return (TRUE)
end




declare create_cust_au_drugingredmapping(p1=vc) = i2 with copy
subroutine create_cust_au_drugingredmapping(p1)
		;LocalDrugIngredientCode,NHSNDrugIngredientCode
		
		drop table cust_au_drugingredmapping
        select into table cust_au_drugingredmapping
            LocalDrugIngredientCode       		= type("vc"),
            NHSNDrugIngredientCode     			= type("vc")
        from dummyt         d
        with    constraint(LocalDrugIngredientCode, "primary key", "unique"),
                index(LocalDrugIngredientCode),
                synonym = "CUST_AU_DRUGINGREDMAPPING",
                organization = "P"
        
        execute oragen3 "CUST_AU_DRUGINGREDMAPPING"
        
	return (TRUE)
end

declare pop_cust_au_drugingredmapping(p1=vc) = i2 with copy
subroutine pop_cust_au_drugingredmapping(p1)

	if(findfile(p1) = 0)
   		call echo("*************************************************************************")
    	call echo(concat("Failed - could not find the file: ", p1))
    	call echo("*************************************************************************")
    	return (FALSE)
	endif
	
	free define rtl3
	define rtl3 is p1

	free record temp_cust_au_drugingredmapping
	record temp_cust_au_drugingredmapping
	(
		1 cnt = i4
		1 qual[*]
		 2 LocalDrugIngredientCode = vc
		 2 NHSNDrugIngredientCode = vc
	)
	
	select into "nl:"
	from rtl3t r
	where r.line > ""
	head report 
		i = 0
	detail
		i += 1
		stat = alterlist(temp_cust_au_drugingredmapping->qual,i)
		temp_cust_au_drugingredmapping->qual[i].LocalDrugIngredientCode		= piece(r.line,",",1,"notfnd",0)
		temp_cust_au_drugingredmapping->qual[i].NHSNDrugIngredientCode		= piece(r.line,",",2,"notfnd",0)
	foot report
		temp_cust_au_drugingredmapping->cnt = i
	with nocounter
	
	;call echorecord(temp_cust_au_drugingredmapping)
	
	if (temp_cust_au_drugingredmapping->cnt > 0)
		
		for (i=1 to temp_cust_au_drugingredmapping->cnt)
			if ((temp_cust_au_drugingredmapping->qual[i].NHSNDrugIngredientCode != "notfnd") and 
				(temp_cust_au_drugingredmapping->qual[i].NHSNDrugIngredientCode != "NHSNDrugIngredientCode"))
				insert into cust_au_drugingredmapping
				set 
					 LocalDrugIngredientCode 			= temp_cust_au_drugingredmapping->qual[i].LocalDrugIngredientCode
					,NHSNDrugIngredientCode				= temp_cust_au_drugingredmapping->qual[i].NHSNDrugIngredientCode
				commit
			endif
		endfor
	
	endif
	
	return (TRUE)
end


declare create_cust_au_dim_wardtype(p1=vc) = i2 with copy
subroutine create_cust_au_dim_wardtype(p1)
		;WardTypeCode,WardTypeName
		
		drop table cust_au_dim_wardtype
        select into table cust_au_dim_wardtype
            WardTypeCode       		= type("vc"),
            WardTypeName     		= type("vc")
        from dummyt         d
        with    constraint(WardTypeCode, "primary key", "unique"),
                index(WardTypeCode),
                synonym = "CUST_AU_DIM_WARDTYPE",
                organization = "P"
        
        execute oragen3 "CUST_AU_DIM_WARDTYPE"
        
	return (TRUE)
end

declare pop_cust_au_dim_wardtype(p1=vc) = i2 with copy
subroutine pop_cust_au_dim_wardtype(p1)

	if(findfile(p1) = 0)
   		call echo("*************************************************************************")
    	call echo(concat("Failed - could not find the file: ", p1))
    	call echo("*************************************************************************")
    	return (FALSE)
	endif
	
	free define rtl3
	define rtl3 is p1

	free record temp_cust_au_dim_wardtype
	record temp_cust_au_dim_wardtype
	(
		1 cnt = i4
		1 qual[*]
		 2 WardTypeCode = vc
		 2 WardTypeName = vc
	)
	
	select into "nl:"
	from rtl3t r
	where r.line > ""
	head report 
		i = 0
	detail
		i += 1
		stat = alterlist(temp_cust_au_dim_wardtype->qual,i)
		temp_cust_au_dim_wardtype->qual[i].WardTypeCode		= piece(r.line,",",1,"notfnd",0)
		temp_cust_au_dim_wardtype->qual[i].WardTypeName		= piece(r.line,",",2,"notfnd",0)
	foot report
		temp_cust_au_dim_wardtype->cnt = i
	with nocounter
	
	;call echorecord(temp_cust_au_dim_wardtype)
	
	if (temp_cust_au_dim_wardtype->cnt > 0)
		
		for (i=1 to temp_cust_au_dim_wardtype->cnt)
			if ((temp_cust_au_dim_wardtype->qual[i].WardTypeName != "notfnd") and 
				(temp_cust_au_dim_wardtype->qual[i].WardTypeName != "WardTypeName"))
				insert into cust_au_dim_wardtype
				set 
					 WardTypeCode 			= temp_cust_au_dim_wardtype->qual[i].WardTypeCode
					,WardTypeName			= temp_cust_au_dim_wardtype->qual[i].WardTypeName
				commit
			endif
		endfor
	
	endif
	
	return (TRUE)
end




declare create_cust_au_routeofadminmapping(p1=vc) = i2 with copy
subroutine create_cust_au_routeofadminmapping(p1)
		;MedicationFormCode,MedicationRouteCode,NHSNMedicationRouteCode,NHSNMedicationRouteCodeSystem,NHSNMedicationRouteName
		
		drop table cust_au_routeofadminmapping
        select into table cust_au_routeofadminmapping
            MedicationFormCode       		= type("vc"),
            MedicationRouteCode     		= type("vc"),
            NHSNMedicationRouteCode     	= type("vc"),
            NHSNMedicationRouteCodeSystem  	= type("vc"),
            NHSNMedicationRouteName     	= type("vc")
        from dummyt         d
        with    constraint(MedicationFormCode, "primary key", "unique"),
                index(MedicationFormCode),
                synonym = "CUST_AU_ROUTEOFADMINMAPPING",
                organization = "P"
        
        execute oragen3 "CUST_AU_ROUTEOFADMINMAPPING"
        
	return (TRUE)
end

declare pop_cust_au_routeofadminmapping(p1=vc) = i2 with copy
subroutine pop_cust_au_routeofadminmapping(p1)

	if(findfile(p1) = 0)
   		call echo("*************************************************************************")
    	call echo(concat("Failed - could not find the file: ", p1))
    	call echo("*************************************************************************")
    	return (FALSE)
	endif
	
	free define rtl3
	define rtl3 is p1

	free record temp_cust_au_routeofadminmapping
	record temp_cust_au_routeofadminmapping
	(
		1 cnt = i4
		1 qual[*]
		 2 MedicationFormCode = vc
		 2 MedicationRouteCode = vc
		 2 NHSNMedicationRouteCode = vc
		 2 NHSNMedicationRouteCodeSystem = vc
		 2 NHSNMedicationRouteName = vc
	)
	
	select into "nl:"
	from rtl3t r
	where r.line > ""
	head report 
		i = 0
	detail
		i += 1
		stat = alterlist(temp_cust_au_routeofadminmapping->qual,i)
		temp_cust_au_routeofadminmapping->qual[i].MedicationFormCode			= piece(r.line,",",1,"notfnd",0)
		temp_cust_au_routeofadminmapping->qual[i].MedicationRouteCode			= piece(r.line,",",2,"notfnd",0)
		temp_cust_au_routeofadminmapping->qual[i].NHSNMedicationRouteCode		= piece(r.line,",",3,"notfnd",0)
		temp_cust_au_routeofadminmapping->qual[i].NHSNMedicationRouteCodeSystem	= piece(r.line,",",4,"notfnd",0)
		temp_cust_au_routeofadminmapping->qual[i].NHSNMedicationRouteName		= piece(r.line,",",5,"notfnd",0)
	foot report
		temp_cust_au_routeofadminmapping->cnt = i
	with nocounter
	
	;call echorecord(temp_cust_au_routeofadminmapping)
	
	if (temp_cust_au_routeofadminmapping->cnt > 0)
		
		for (i=1 to temp_cust_au_routeofadminmapping->cnt)
			if ((temp_cust_au_routeofadminmapping->qual[i].MedicationRouteCode != "notfnd") and 
				(temp_cust_au_routeofadminmapping->qual[i].MedicationRouteCode != "MedicationRouteCode"))
				
				insert into cust_au_routeofadminmapping
				set 
					 MedicationFormCode 			= temp_cust_au_routeofadminmapping->qual[i].MedicationFormCode
					,MedicationRouteCode			= temp_cust_au_routeofadminmapping->qual[i].MedicationRouteCode
					,NHSNMedicationRouteCode		= temp_cust_au_routeofadminmapping->qual[i].NHSNMedicationRouteCode
					,NHSNMedicationRouteCodeSystem	= temp_cust_au_routeofadminmapping->qual[i].NHSNMedicationRouteCodeSystem
					,NHSNMedicationRouteName		= temp_cust_au_routeofadminmapping->qual[i].NHSNMedicationRouteName
				commit
			endif
		endfor
	
	endif
	
	return (TRUE)
end


;au_sds_prod_medicationadministration.csv
declare create_cust_au_medadmin(p1=vc) = i2 with copy
subroutine create_cust_au_medadmin(p1)
		;MedicationAdministrationID,FacilityID,PatientID,LocalDrugIngredientCode,
		;AdministrationDateTime,MedicationFormCode,MedicationRouteCode,WardID,AdministrationStatusCode
		
		drop table cust_au_medadmin
        select into table cust_au_medadmin
            MedicationAdministrationID  = type("f8"),
            FacilityID     				= type("vc"),
            PatientID     				= type("vc"),
            LocalDrugIngredientCode  	= type("vc"),
            AdministrationDateTime     	= type("vc"),
            MedicationFormCode     		= type("vc"),
            MedicationRouteCode     	= type("vc"),
            WardID     					= type("vc"),
            AdministrationStatusCode    = type("vc")
        from dummyt         d
        with    constraint(MedicationAdministrationID, "primary key", "unique"),
                index(MedicationAdministrationID),
                synonym = "CUST_AU_MEDADMIN",
                organization = "P"
        
        execute oragen3 "CUST_AU_MEDADMIN"
        
	return (TRUE)
end

declare pop_cust_au_medadmin(p1=vc) = i2 with copy
subroutine pop_cust_au_medadmin(p1)

	if(findfile(p1) = 0)
   		call echo("*************************************************************************")
    	call echo(concat("Failed - could not find the file: ", p1))
    	call echo("*************************************************************************")
    	return (FALSE)
	endif
	
	free define rtl3
	define rtl3 is p1

	free record temp_cust_au_medadmin
	record temp_cust_au_medadmin
	(
		1 cnt = i4
		1 qual[*]
		 2 MedicationAdministrationID 	= f8
		 2 FacilityID 					= vc
		 2 PatientID 					= vc
		 2 LocalDrugIngredientCode 		= vc
		 2 AdministrationDateTime 		= vc
		 2 MedicationFormCode 			= vc
		 2 MedicationRouteCode 			= vc
		 2 WardID 						= vc
		 2 AdministrationStatusCode		= vc
	)	
	
	select into "nl:"
	from rtl3t r
	where r.line > ""
	head report 
		i = 0
	detail
		i += 1
		stat = alterlist(temp_cust_au_medadmin->qual,i)
		temp_cust_au_medadmin->qual[i].MedicationAdministrationID		= cnvtreal(piece(r.line,",",1,"notfnd",0))
		temp_cust_au_medadmin->qual[i].FacilityID						= piece(r.line,",",2,"notfnd",0)
		temp_cust_au_medadmin->qual[i].PatientID						= piece(r.line,",",3,"notfnd",0)
		temp_cust_au_medadmin->qual[i].LocalDrugIngredientCode			= piece(r.line,",",4,"notfnd",0)
		temp_cust_au_medadmin->qual[i].AdministrationDateTime			= piece(r.line,",",5,"notfnd",0)
		temp_cust_au_medadmin->qual[i].MedicationFormCode				= piece(r.line,",",6,"notfnd",0)
		temp_cust_au_medadmin->qual[i].MedicationRouteCode				= piece(r.line,",",7,"notfnd",0)
		temp_cust_au_medadmin->qual[i].WardID							= piece(r.line,",",8,"notfnd",0)
		temp_cust_au_medadmin->qual[i].AdministrationStatusCode			= piece(r.line,",",9,"notfnd",0)
	foot report
		temp_cust_au_medadmin->cnt = i
	with nocounter
	
	;call echorecord(temp_cust_au_medadmin)
	
	if (temp_cust_au_medadmin->cnt > 0)
		
		for (i=1 to temp_cust_au_medadmin->cnt)
			if ((temp_cust_au_medadmin->qual[i].MedicationRouteCode != "notfnd") and 
				(temp_cust_au_medadmin->qual[i].MedicationRouteCode != "MedicationRouteCode"))
				
				insert into cust_au_medadmin
				set 
					 MedicationAdministrationID = temp_cust_au_medadmin->qual[i].MedicationAdministrationID
					,FacilityID					= temp_cust_au_medadmin->qual[i].FacilityID
					,PatientID					= temp_cust_au_medadmin->qual[i].PatientID
					,LocalDrugIngredientCode	= temp_cust_au_medadmin->qual[i].LocalDrugIngredientCode
					,AdministrationDateTime		= temp_cust_au_medadmin->qual[i].AdministrationDateTime
					,MedicationFormCode			= temp_cust_au_medadmin->qual[i].MedicationFormCode
					,MedicationRouteCode		= temp_cust_au_medadmin->qual[i].MedicationRouteCode
					,WardID						= temp_cust_au_medadmin->qual[i].WardID
					,AdministrationStatusCode	= temp_cust_au_medadmin->qual[i].AdministrationStatusCode
					
				commit
			endif
		endfor
	
	endif
	
	return (TRUE)
end


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

if (t_rec->prompts.mode in("CREATE","RESET"))
	call writeLog(build2("->creating tables"))
	/*
	call create_cust_au_adtwardmapping(null)
	call create_cust_au_dim_facility(null)
	call create_cust_au_nhsnloctypecode(null)
	call create_cust_au_localdrugingredcode(null)
	call create_cust_au_nhsndrugingredcode(null)
	call create_cust_au_drugingredmapping(null)
	call create_cust_au_dim_wardtype(null)
	call create_cust_au_routeofadminmapping(null)
	*/
	call create_cust_au_medadmin(null)
endif

if (t_rec->prompts.mode in("POPULATE","RESET"))
	call writeLog(build2("->populating tables"))
	/*
	call pop_cust_au_adtwardmapping("au_sds_prod_adtwardmapping.csv")
	call pop_cust_au_dim_facility("au_sds_prod_dim_facility.csv")
	call pop_cust_au_nhsnloctypecode("au_sds_prod_dim_nhsnlocationtypecode.csv")
	call pop_cust_au_localdrugingredcode("au_sds_prod_dim_localdrugingredientcode.csv")
	call pop_cust_au_nhsndrugingredcode("au_sds_prod_dim_nhsndrugingredientcode.csv")
	call pop_cust_au_drugingredmapping("au_sds_prod_drugingredientmapping.csv")
	call pop_cust_au_dim_wardtype("au_sds_prod_dim_wardtype.csv")
	call pop_cust_au_routeofadminmapping("au_sds_prod_routeofadministrationmapping.csv")
	*/
	call pop_cust_au_medadmin("au_sds_prod_medicationadministration.csv")
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
