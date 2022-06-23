 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		OCT'2018
	Solution:			Pharmacy/PharmNet
	Source file name:  	cov_pha_scorecard_medadmin_ops.prg
	Object name:		cov_pha_scorecard_medadmin_ops
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
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
;Date setup - Runs for the previous day.
declare start_date = f8
declare end_date   = f8
 
set start_date = cnvtlookbehind("2,M")
set start_date = datetimefind(start_date,"M","B","B")
;set end_date   = cnvtlookahead("2,D",start_date)
;set end_date   = cnvtlookbehind("1,SEC", end_date)
set end_date = datetimefind(start_date,"M","E","E")
 
call echo(build2("start_date=",format(start_date,";;q")))
call echo(build2("end_date=",format(end_date,";;q")))
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
 
RECORD facility(
	1 rec_cnt =	i4
	1 flist[*]
		2 facility_cd   =	f8
		2 facility_desc =	vc
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
and l.location_cd in (2552503635.00, 21250403.00, 2553765571.00, 2553455025.00, 2553765707.00, 2555024777.00,
		2552503653.00, 2553765635.00, 2553454905.00, 2719834165.00, 2552503639.00, 2553765467.00, 2553765475.00,
		2553765483.00, 2918486997.00, 2764879815.00, 2552503613.00, 2555024801.00, 2553455257.00, 2555024785.00,
		2553765579.00, 2552503645.00, 2553765531.00, 2553765539.00, 2552503649.00) ;001
 
order by facility_name
 
 
Head report
	cnt = 0
Detail
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 		stat = alterlist(facility->flist, cnt + 9)
 	endif
 
	facility->flist[cnt].facility_cd	= l.location_cd
	facility->flist[cnt].facility_desc	= facility_name
	facility->rec_cnt		      	= cnt
 
Foot report
	stat = alterlist(facility->flist, cnt)
 
With nocounter
 
 
;Loop through all facilities.
For(fcnt = 1 to facility->rec_cnt)
	call echo(build2("start_date=",format(start_date,";;q")))
	call echo(build2("end_date=",format(end_date,";;q")))
  
  	;everyday
 	EXECUTE COV_MEDREB8_EXTRACT "mine", 0, start_date, end_date, facility->flist[fcnt].facility_cd
 

Endfor
 
 
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
 
