/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_aur_reporting.prg
	Object name:		cov_aur_reporting
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

drop program cov_aur_reporting:dba go
create program cov_aur_reporting:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Report Type" = "AU"
	, "File Location:" = "\\client\c$"
	, "Output:" = 0
	, "Debug Reports" = "" 

with OUTDEV, REPORT_TYPE, FILE, CSV, DEBUG


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

execute cov_aur_routines

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
	 2 outdev			= vc
	 2 report_type		= vc
	 2 file				= vc
	 2 csv				= i4
	 2 debug			= vc
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

record output_data
(
	1 file_cnt = i4
	1 file_qual[*]
	 2 FacilityID = vc
	 2 Output = vc
	1 cnt = i4
	1 qual[*]
		2 FacilityID = vc
		2 WardID = vc
		2 NHSNLocationTypeCode = vc
		2 SummaryYYYYMM = vc
		2 AdmissionsForMonth = vc
		2 NumberOfDaysPresentForMonth = vc
		2 NHSNDrugIngredientCode = vc
		2 AUDaysAllRoute = vc
		2 AUDaysIMRoute = vc
		2 AUDaysIVRoute = vc
		2 AUDaysDigestiveRoute = vc
		2 AUDaysRespiratoryRoute = vc
)

;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.report_type = $REPORT_TYPE
set t_rec->prompts.file = $FILE
set t_rec->prompts.csv = $CSV
set t_rec->prompts.debug = $DEBUG

set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)


if (t_rec->prompts.debug > "")
	set t_rec->prompts.csv = -1
endif	

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))




call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))


;get list of medications
set stat = cnvtjsontorec(sGetNSHNMedications(null))
;call echorecord(medication_list)

;get list of routes
set stat = cnvtjsontorec(sGetNSHNRoutes(null))
;call echorecord(route_list)

;get list of locations
set stat = cnvtjsontorec(sGetNSHNLocations(null))
;call echorecord(location_list)

;get list of admins
set stat = cnvtjsontorec(sGetMedAdmins(null))
call echorecord(admin_list)


free record temp_reply
 record temp_reply (
   1 admin_date [* ]
     2 admin_dt_tm = dq8
     2 units [* ]
       3 unit_cds = vc
       3 unit_disp = vc
       3 person [* ]
         4 person_id = vc
         4 meds [* ]
           5 temp_med_cd = vc
           5 temp_med_disp = vc
           5 nhsn_med_cd = vc
           5 med_disp = vc
           5 med_total = i4
           5 nhsn_med_ind = i2
           5 routes [* ]
             6 nhsn_route_cd = vc
             6 temp_route_cd = vc
             6 routes_count = i4
             6 route_disp = vc
 )

/*
record admin_list
	(
		1 cnt = i4
		1 qual[*]
		 2 medicationadministrationid = f8
		 2 facilityid = vc
		 2 wardid = vc
		 2 patientid = vc
		 2 localdrugingredientname = vc
		 2 nhsndrugingredientcode = vc
		 2 nhsnmedicationroutecode = vc
		 2 nhsnmedicationroutename = vc
		 2 administrationstatuscode = vc
		 2 administrationdatetime = vc
		 2 administrationdate = vc
		 2 wardname = vc
		 2 nhsnlocationtypecode = vc
		 2 nhsnlocationtypename = vc
	)
*/

DECLARE location_cnt = i4 WITH protect ,noconstant (0 )
DECLARE medication_cnt = i4 WITH protect ,noconstant (0 )
DECLARE temp_route_cnt = i4 WITH protect ,noconstant (0 )
DECLARE admin_dt_cnt = i4 WITH protect ,noconstant (0 )
DECLARE unit_cnt = i4 WITH protect ,noconstant (0 )
DECLARE med_cnt = i4 WITH protect ,noconstant (0 )
DECLARE person_cnt = i4 WITH protect ,noconstant (0 )
DECLARE route_cnt = i4 WITH protect ,noconstant (0 )
DECLARE admin_route_cnt = i4 WITH protect ,noconstant (0 )
DECLARE exist_route_cnt = i4 WITH protect ,noconstant (0 )
DECLARE admin_med_cnt = i4 WITH protect ,noconstant (0 )
DECLARE med_size = i4 WITH protect ,noconstant (0 )
DECLARE route_size = i4 WITH protect ,noconstant (0 )
DECLARE temp_route_size = i4 WITH protect ,noconstant (0 )
DECLARE nhsn_route_size = i4 WITH protect ,noconstant (0 )


 select into "nl:"
    admin_date = admin_list->qual[d1.seq].administrationdate
   ,nurse_unit_cd = admin_list->qual[d1.seq].wardid
   ,person_id = admin_list->qual[d1.seq].patientid
   ,catalog_cd = admin_list->qual[d1.seq].nhsndrugingredientcode
   ,route_cd = admin_list->qual[d1.seq].nhsnmedicationroutecode
   from 
   	(dummyt d1 with seq=admin_list->cnt)
   plan d1
   order by 
   	 admin_date
   	,nurse_unit_cd
    ,person_id
    ,catalog_cd
    ,route_cd
   head report
    nhsn_route_size = route_list->cnt
    admin_dt_cnt = 0
   head admin_date
    unit_cnt = 0
    admin_dt_cnt = (admin_dt_cnt + 1)
    
	stat = alterlist (temp_reply->admin_date,admin_dt_cnt)
    temp_reply->admin_date[admin_dt_cnt ].admin_dt_tm = cnvtdatetime(admin_list->qual[d1.seq].administrationdatetime)
    
   head nurse_unit_cd
    person_cnt = 0
    unit_cnt = (unit_cnt + 1 )
    stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units,unit_cnt)
    
    temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].unit_cds = nurse_unit_cd 
    temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].unit_disp = admin_list->qual[d1.seq].wardname
    
   head person_id
    med_cnt = 0
    med_pos = 0
    admin_med_cnt = 0
    person_cnt = (person_cnt + 1 )
    
    stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person ,person_cnt)
    temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].person_id = person_id
    
   head catalog_cd
    route_cnt = 0
    admin_route_cnt = 0
    exist_route_cnt = 0
    med_cnt = (med_cnt + 1 )
    
    stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds,med_cnt)
    temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].temp_med_cd = catalog_cd
    temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].temp_med_disp = 
    	admin_list->qual[d1.seq].localdrugingredientname
    
    med_size = medication_list->cnt
    med_pos = locateval (admin_med_cnt ,1 ,med_size ,catalog_cd ,medication_list->qual[admin_med_cnt ].nhsndrugingredientcode ) 
    
    if ((med_pos > 0 ) ) 
    	temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].med_disp 
    		= medication_list->qual[med_pos ].nhsndrugingredientname
    	temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].nhsn_med_cd
    		= medication_list->qual[med_pos ].nhsndrugingredientcode
    	temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].nhsn_med_ind = 1
    endif
   
   head route_cd
    route_pos = 0
    
   detail
    if ((route_pos = 0 ) )
     FOR (route_index = 1 TO nhsn_route_size )
      route_size = route_list->cnt
      route_pos = locateval (admin_route_cnt ,1 ,route_size ,route_cd ,route_list->qual[route_index].nhsnmedicationroutecode)
      
      /*
		free record route_list
		record route_list
		(
			1 cnt = i4
			1 qual[*]
			 2 medicationformcode = vc
			 2 medicationroutecode = vc
			 2 nhsnmedicationroutecode = vc
			 2 nhsnmedicationroutename= vc
		)
	*/
      if ((route_pos > 0 ) ) 
      	temp_route_size = size (temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].routes ,5 )
       	
       	if ((locateval (exist_route_cnt ,1 ,temp_route_size ,route_list->nhsnroute_cds[route_index ].nhsnroute_cd ,temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].routes[exist_route_cnt ].nhsn_route_cd ) = 0 ) ) 
			route_cnt = (route_cnt + 1 )
       		
			stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].routes ,route_cnt)
        	temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].routes[route_cnt ].route_disp 
        		= route_list->nhsnroute_cds[route_index ].nhsnroute_disp
        	
        	temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].routes[route_cnt ].routes_count = 1
        	temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].routes[route_cnt ].nhsn_route_cd 
        		= route_list->nhsnroute_cds[route_index ].nhsnroute_cd
        	temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds[med_cnt ].routes[route_cnt ].temp_route_cd = mae.route_cd
        	route_index = (nhsn_route_size + 1 )
       else 
       		route_index = (nhsn_route_size + 1 )
       endif
      endif
     endfor
    endif
   FOOT  mae.route_cd
    donothing = 0
   FOOT  mae.catalog_cd
    stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].
     meds[med_cnt ].routes ,route_cnt )
   FOOT  ce.person_id
    stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person[person_cnt ].meds
      ,med_cnt )
   FOOT  mae.nurse_unit_cd
    stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units[unit_cnt ].person ,person_cnt )
   FOOT  admin_date
    stat = alterlist (temp_reply->admin_date[admin_dt_cnt ].units ,unit_cnt )
   FOOT REPORT
    stat = alterlist (temp_reply->admin_date ,admin_dt_cnt )
   WITH nocounter ,expand = 1
  ;end select

;get denominator

;create output_data
set output_data->cnt = 1
set stat = alterlist(output_data->qual,output_data->cnt)
set output_data->qual[output_data->cnt].FacilityID = ^1^
set output_data->qual[output_data->cnt].WardID = ^1^
set output_data->qual[output_data->cnt].NHSNLocationTypeCode = ^1072-8^
set output_data->qual[output_data->cnt].SummaryYYYYMM = ^202210^
set output_data->qual[output_data->cnt].AdmissionsForMonth = ^NULL^
set output_data->qual[output_data->cnt].NumberOfDaysPresentForMonth = ^100^
set output_data->qual[output_data->cnt].NHSNDrugIngredientCode = ^10207^
set output_data->qual[output_data->cnt].AUDaysAllRoute = ^5^
set output_data->qual[output_data->cnt].AUDaysIMRoute = ^2^
set output_data->qual[output_data->cnt].AUDaysIVRoute = ^1^
set output_data->qual[output_data->cnt].AUDaysDigestiveRoute = ^2^
set output_data->qual[output_data->cnt].AUDaysRespiratoryRoute = ^0^

set output_data->file_cnt += 1
set stat = alterlist(output_data->file_qual,output_data->file_cnt)
set output_data->file_qual[output_data->file_cnt].FacilityID = build(^Sample Data ^,output_data->file_cnt)

set output_data->file_cnt += 1
set stat = alterlist(output_data->file_qual,output_data->file_cnt)
set output_data->file_qual[output_data->file_cnt].FacilityID = build(^Sample Data ^,output_data->file_cnt)


call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Output   *******************************************"))

if (t_rec->prompts.csv = 0)

	select into t_rec->prompts.outdev
	from
		(dummyt d1 with seq=1)
	head report
		col 0 "ASCII Report"
	with nocounter

elseif (t_rec->prompts.csv = 1)

	select into t_rec->prompts.outdev
	detail
	
		col 0 	^FacilityID^, 					^,^,
				^WardID^, 						^,^,
				^NHSNLocationTypeCode^, 		^,^,
				^SummaryYYYYMM^, 				^,^,
				^AdmissionsForMonth^, 			^,^,
				^NumberOfDaysPresentForMonth^, 	^,^,
				^NHSNDrugIngredientCode^, 		^,^,
				^AUDaysAllRoute^, 				^,^,
				^AUDaysIMRoute^, 				^,^,
				^AUDaysIVRoute^, 				^,^,
				^AUDaysDigestiveRoute^, 		^,^,
				^AUDaysRespiratoryRoute^
		for (i=1 to output_data->cnt)
			row +1
			col 0  	output_data->qual[i].FacilityID, ^,^,
					output_data->qual[i].WardID, ^,^,
					output_data->qual[i].NHSNLocationTypeCode, ^,^,
					output_data->qual[i].SummaryYYYYMM, ^,^,
					output_data->qual[i].AdmissionsForMonth, ^,^,
					output_data->qual[i].NumberOfDaysPresentForMonth, ^,^,
					output_data->qual[i].NHSNDrugIngredientCode, ^,^,
					output_data->qual[i].AUDaysAllRoute, ^,^,
					output_data->qual[i].AUDaysIMRoute, ^,^,
					output_data->qual[i].AUDaysIVRoute, ^,^,
					output_data->qual[i].AUDaysDigestiveRoute, ^,^,
					output_data->qual[i].AUDaysRespiratoryRoute		
		endfor
	with format = variable, noheading, formfeed = none , maxrow = 1, maxcol = 30000

/*
	select into t_rec->prompts.outdev
		 FacilityID = output_data->qual[d1.seq].FacilityID
		,WardID = output_data->qual[d1.seq].WardID
		,NHSNLoc = output_data->qual[d1.seq].NHSNLocationTypeCode
		,SumYYYYMM = output_data->qual[d1.seq].SummaryYYYYMM
		,Admits = output_data->qual[d1.seq].AdmissionsForMonth
		,Days = output_data->qual[d1.seq].NumberOfDaysPresentForMonth
		,DrugCode = output_data->qual[d1.seq].NHSNDrugIngredientCode
		,AUDaysAll = output_data->qual[d1.seq].AUDaysAllRoute
		,AUDaysIM = output_data->qual[d1.seq].AUDaysIMRoute
		,AUDaysIV = output_data->qual[d1.seq].AUDaysIVRoute
		,AUDaysDig = output_data->qual[d1.seq].AUDaysDigestiveRoute
		,AUDaysRespe = output_data->qual[d1.seq].AUDaysRespiratoryRoute
	from
		(dummyt d1 with seq=output_data->cnt)
	with nocounter,format,separator=" "
*/

elseif (t_rec->prompts.csv = 2)

	declare sFILE1    = vc  with protect, constant("AU_")

 
	declare ploc      = vc  with protect
	declare sData     = vc  with protect
	declare stat      = i4  with protect, noconstant(0)
	declare lStat     = i4  with protect, noconstant(0)
	declare pCnt      = i4  with protect, noconstant(0)

	call echo(sFile1)
	
	; Get/Set Folder Location
	set ploc = t_rec->prompts.file
	set lStat = size(ploc,1)
	set stat = findstring("\",ploc,1,1)
	if (stat = 0)
	    set stat = findstring("/",ploc,1,1)
	endif
	
	call echo(build("lStat->",lStat, "/stat->",stat))
	if (stat < lStat)
    	call echo("Adding '\' to the end of the file location...")
	    set ploc = concat(trim(ploc),"\")
	endif

	set ploc = replace(ploc,"\","\\",0)
	set ploc = replace(ploc,"/","\\",0)
	
	set lStat =  BuildParams(null)
	call echo("calling html")
	set lStat = OpenPage("cov_aur_export.html",value(t_rec->prompts.outdev))
	call echo("ending call html")

endif

call writeLog(build2("* END   Creating Output   *******************************************"))
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


if (t_rec->prompts.debug > "")
 if (t_rec->prompts.debug = "MED_ADMIN")
	select into t_rec->prompts.outdev
		 am.medicationadministrationid
		,am.facilityid
		,am.wardid
		,am.patientid
		,al.localdrugingredientname
		,ad.nhsndrugingredientcode
		,ar.nhsnmedicationroutecode
		,ar.nhsnmedicationroutename
		,am.administrationstatuscode
		,am.administrationdatetime
		,am.administrationdate
		,aa.wardname
		,an2.nhsnlocationtypecode
		,an2.nhsnlocationtypename 
	from 
		 cust_au_medadmin am
		,cust_au_dim_facility adf
		,cust_au_localdrugingredcode al
		,cust_au_drugingredmapping ad
		,cust_au_routeofadminmapping ar
		,cust_au_nhsndrugingredcode an
		,cust_au_adtwardmapping aa
		,cust_au_nhsnloctypecode an2
	plan am
	join adf
		where adf.facilityid = am.facilityid
	join al
		where al.localdrugingredientcode = am.localdrugingredientcode
	join ad
		where ad.localdrugingredientcode = am.localdrugingredientcode
	join ar
		where ar.medicationformcode = am.medicationformcode
	join an
		where an.nhsndrugingredientcode = ad.nhsndrugingredientcode
	join aa
		where aa.facilityid = am.facilityid
		and   aa.wardid = am.wardid
	join an2
		where an2.nhsnlocationtypecode = aa.nhsnlocationtypecode
	with nocounter,separator= " ", format
	
 elseif (t_rec->prompts.debug = "LOCATION_MAP")
	
	select into t_rec->prompts.outdev
		*
	from 
		 cust_au_nhsnloctypecode an
		,cust_au_adtwardmapping aa
		,cust_au_dim_facility adf
	plan an
	join aa
		where aa.nhsnlocationtypecode = an.nhsnlocationtypecode
	join adf
		where adf.facilityid = aa.facilityid
	with nocounter,separator= " ", format
	
 endif
endif	

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
