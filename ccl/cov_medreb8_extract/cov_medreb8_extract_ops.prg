 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		OCT'2018
	Solution:			Pharmacy/PharmNet
	Source file name:  	cov_medreb8_extract_ops.prg
	Object name:		cov_medreb8_extract_ops
	Request#:			3579
 
	Program purpose:	      Medication administration details.
	Executing from:		Ops sheduler
  	Special Notes:          Astream to Jerry Inman
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
  Mod Nbr	Mod Date	Developer			Comment
  -------	----------	------------------	----------------------------------
  001		07/09/2020	Dan Herren			Added Specialty facilities.
 
******************************************************************************/
 
drop program cov_medreb8_extract_ops:dba go
create program cov_medreb8_extract_ops:dba

call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc 

call set_codevalues(null)
call check_ops(null)
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
;Date setup - Runs for the previous day.
declare start_date = f8
declare end_date   = f8
 
set start_date = cnvtlookbehind("1,M")
set start_date = datetimefind(start_date,"D","B","B")
;set end_date   = cnvtlookahead("2,D",start_date)
;set end_date   = cnvtlookbehind("1,SEC", end_date)
set end_date = datetimefind(cnvtlookbehind("1,M"),"D","E","E")
 
call echo(build2("start_date=",format(start_date,";;q")))
call echo(build2("end_date=",format(end_date,";;q")))
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
 
RECORD facility(
	1 rec_cnt =	i4
	1 merged
	 2 full_path			= vc
	 2 short_path			= vc
	 2 filename				= vc
	 2 command				= vc
	 2 astream				= vc
	1 file_cnt				= i2
	1 file_qual[*]
	 2 filename				= vc
	 2 merge_command		= vc
	 2 remove_command		= vc
	1 flist[*]
		2 facility_cd   =	f8
		2 facility_desc =	vc
		2 fac_filename  =   vc
		2 merge_command = vc
		2 remove_command = vc
)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Get facilities
select into 'NL:'
  facility_name = uar_get_displaykey(l.location_cd), l.location_cd
 
from location l
where l.location_type_cd = 783.00
and l.active_ind = 1
;and l.location_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2553765579.00,
;	2552503645.00,2552503649.00) ;001

and l.location_cd in (

	 21250403 ;FSR
	,2552503613 ;MMC
	;,2552503635 ;FLMC
	;,2552503639 ;MHHS
	;,2552503645 ;PW
	;,2552503649 ;RMC
	;,2552503653 ;LCMC
	

)
 
order by facility_name
 
 
Head report
	cnt = 0
	facility->merged.full_path 	= program_log->files.file_path
	facility->merged.short_path = "cclscratch:"
	facility->merged.filename = concat(
 								"pha_medreb8_medadmin"
 								,"_"
 								,format(cnvtdatetime(curdate,curtime3),"MMDDYYYY_HHMMSS;;q")
 								,".csv")
Detail
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 		stat = alterlist(facility->flist, cnt + 9)
 	endif
 
	facility->flist[cnt].facility_cd	= l.location_cd
	facility->flist[cnt].facility_desc	= facility_name
	facility->rec_cnt		      	= cnt
	facility->flist[cnt].fac_filename = concat(
 								"tempmedreb8ops_"
 								,trim(cnvtstring(cnt,2,0))
 								,"_"
 								,format(cnvtdatetime(curdate,curtime3),"MMDDYYYY_HHMMSS;;q")
 								,".csv")
 								
 								
	stat = alterlist(facility->file_qual,cnt)
	
	facility->file_qual[cnt].filename = facility->flist[cnt].fac_filename
 
Foot report
	stat = alterlist(facility->flist, cnt)
 	facility->file_cnt = cnt
With nocounter
 
 
;Loop through all facilities.
For(fcnt = 1 to facility->rec_cnt)
	call echo(build2("start_date=",format(start_date,";;q")))
	call echo(build2("end_date=",format(end_date,";;q")))
  
  	;everyday
 	EXECUTE COV_MEDREB8_EXTRACT value(facility->flist[fcnt].fac_filename)
 			, 0, start_date, end_date, facility->flist[fcnt].facility_cd
 

Endfor


if (facility->file_cnt > 0)
	for (i=1 to facility->file_cnt)
	 if (facility->file_qual[i].filename > " ")
		call writeLog(build2("->adding file:",facility->file_qual[i].filename))
		if (i=1)
			set facility->file_qual[i].merge_command = concat(
				^cat ^	,trim(program_log->files.ccluserdir),trim(facility->file_qual[i].filename)
						,^ >> ^
						,trim(facility->merged.full_path),trim(facility->merged.filename)
				)
		else
			set facility->file_qual[i].merge_command = concat(
				"cat "	,trim(program_log->files.ccluserdir),trim(facility->file_qual[i].filename)
						," | grep -v '^"
						,^"Pharmacy ID"^
						,"' >> "
						,trim(facility->merged.full_path),trim(facility->merged.filename)
				)
		endif
		set facility->file_qual[i].remove_command = concat(
				^rm ^	,trim(program_log->files.ccluserdir),trim(facility->file_qual[i].filename)
				)
		call writeLog(build2("->merge command:",facility->file_qual[i].merge_command))
		call writeLog(build2("->remove command:",facility->file_qual[i].remove_command))
		call dcl(facility->file_qual[i].merge_command,size(trim(facility->file_qual[i].merge_command)),stat)
		call dcl(facility->file_qual[i].remove_command,size(trim(facility->file_qual[i].remove_command)),stat)
	 endif
	endfor
	;call addAttachment(facility->merged.full_path,facility->merged.filename)
	execute cov_astream_file_transfer "cclscratch",facility->merged.filename,"","MV"
endif	

call exitScript(null) 
 call echorecord(facility->file_qual)
 call echorecord(facility->merged)
end
go
 
 
/*
 
21250403.00     -20    ;FSR
 2552503613.00,  -24	;MMC - excluded as per Jeff Nedrow
 2553765579.00   -65    ;G
 2552503635.00,  -28	;FLMC
 2552503639.00,  -25	;MHHS
 2552503645.00,  -22 	;PW
 2552503649.00,  -27	;RMC - excluded as per Jeff Nedrow
 2552503653.00,  -26	;LCMC
 
 
	 2552503635.00	Fort Loudoun Medical Center	FLMC
	   21250403.00	Fort Sanders Regional Medical Center	FSR
	 2552503653.00	LeConte Medical Center	LCMC
	 2552503639.00	Morristown-Hamblen Hospital Association	MHHS
	 2552503613.00	Methodist Medical Center	MMC
	 2553765579.00	Peninsula Behavioral Health - Div of Parkwest Medical Center	PBHPENINSULA
	 2552503645.00	Parkwest Medical Center	PW
	 2552503649.00	Roane Medical Center	RMC
 
 */
 
