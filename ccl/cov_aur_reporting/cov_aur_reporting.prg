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

with OUTDEV, REPORT_TYPE, FILE, CSV


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


set t_rec->cons.run_dt_tm 		= cnvtdatetime(curdate,curtime3)

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
