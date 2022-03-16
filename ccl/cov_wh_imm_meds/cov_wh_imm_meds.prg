/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren / Chad Cummings
	Date Written:		June 2021
	Solution:
	Source file name:	cov_wh_imm_meds.prg
	Object name:		cov_wh_imm_meds
	CR#:				9517
 
	Program purpose:	Smart Template - WH_Newborn_Immunizations_Medications
						Code Value: 3161714745
	Executing from:		CCL
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*
*
******************************************************************************************/
drop program cov_wh_imm_meds:dba go
create program cov_wh_imm_meds:dba
 
prompt
	"Output to File/Printer/MINE " = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
%i cust_script:cov_st_imm_meds_common.inc
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
set rhead = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}",
    "}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134 ")
/*The end of line embedded RTF command */
set Reol = "\par "
/*The tab embedded RTF command */
set Rtab = "\tab "
/*the embedded RTF commands for normal word(s) */
set wr = "\plain \f0 \fs18 \cb2 "
/*the embedded RTF commands for bold word(s) */
set wb = "\plain \f0 \fs18 \b \cb2 "
/*the embedded RTF commands for stike-thru word(s) */
set ws = "\plain \f0 \fs18 \strike \cb2 "
/*the embedded RTF command for hanging indent */
set hi = "\pard\fi-2340\li2340 "
/*the embedded RTF commands to end the document*/
set rtfeof = "}"
/*the embedded RTF commands for bold & underline & font18 word(s) */
set wbuf18 = "\plain \f0 \fs18 \b \ul \cb2 "
/*the embedded RTF commands for bold & underline & font26 word(s) */
set wbuf26 = "\plain \f0 \fs26 \b \ul \cb2 "
/*The embedded RTF command for resetting paragraph-formatting attributes to their default value */
set rpard = "\pard "
/*the embedded RTF commands for underlined, bold word(s) */
set wbu = "\plain \f0 \fs18 \b \ul \cb2 "
 
 
set reply->text = build2("{\rtf1\ansi{\colortbl;\red255\green255\blue255;}{\*\revtbl{Unknown;}}\viewkind4\cb1")
 
for (i=1 to size(rec->list,5))
 
	if (i>1)
		set reply->text = build2(reply->text,Reol,Reol)
	endif
 
	set reply->text = build2(reply->text
		,wb, "Medication:","  ", wr, rec->list[i].ce_event, Reol
		,wb, "Dose/Route:","  ", wr, rec->list[i].dosage, Reol
		,wb, "Result:","  ", wr, rec->list[i].ce_result, Reol
		,wb, "Date/Time:","  ", wr, format(rec->list[i].ce_clinsig_dt,"mm/dd/yyyy hh:mm;;d")
	)
endfor
 
set reply->text = build2(reply->text,"}")
 
 
;call echo(reply->text)
#exitscript
end go
