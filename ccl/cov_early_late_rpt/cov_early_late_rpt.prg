drop program cov_early_late_rpt go
create program cov_early_late_rpt

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Facility" = VALUE(0.0           ) 

with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, FACILITY_PMPT


Record rec (
	1 username          	= vc
	1 startdate         	= vc
	1 enddate          	 	= vc
	1 encntr_cnt			= i4

)

declare username           	= vc with protect
declare initcap()          	= c100
declare num					= i4 with noconstant(0)
declare idx					= i4 with noconstant(0)
;
declare FIN_TYPE_VAR        = f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")),protect
declare NOTDONE_VAR         = f8 with constant(uar_get_code_by("DISPLAYKEY", 4000040, "NOTDONE")),protect
declare NOTGIVEN_VAR   		= f8 with constant(uar_get_code_by("DISPLAYKEY", 4000040, "NOTGIVEN")),protect
declare PHA_CAT_TYPE_VAR   	= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "PHARMACY")),protect
;
declare OPR_FAC_VAR		   	= vc with noconstant(fillstring(1000," "))
;
declare	START_DATETIME		= f8
declare END_DATETIME		= f8
 
 
;GET USERNAME FOR REPORT
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	rec->username = p.username
with nocounter
 
 
; SET DATE PROMPTS TO DATE VARIABLES
set START_DATETIME = cnvtdatetime($START_DATETIME_PMPT)
set END_DATETIME   = cnvtdatetime($END_DATETIME_PMPT)
 
 
; SET DATE VARIABLES FOR *****  MANUAL TESTING  *****
;set START_DATETIME = cnvtdatetime("01-JUN-2020 00:00:00")
;set END_DATETIME   = cnvtdatetime("05-JUN-2020 23:59:59")
 
 
; SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(START_DATETIME, "mm/dd/yyyy;;q") 	;substring(1,11,$START_DATETIME_PMPT)
set rec->enddate   = format(END_DATETIME, "mm/dd/yyyy;;q") 		;substring(1,11,$END_DATETIME_PMPT)
 
 
;SET FACILITY VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif

select into $OUTDEV
   window = if (datetimediff(maa.event_dt_tm,mame.scheduled_dt_tm,4) < -30)
  					"Early"
  				   elseif (datetimediff(maa.event_dt_tm,mame.scheduled_dt_tm,4) > 30)
  				    "Late"
  				   else
  				    "On-time"
  				   endif
  , mame.scheduled_dt_tm
  , mae.beg_dt_tm
  , difference = datetimediff(maa.event_dt_tm,mame.scheduled_dt_tm,4)
  , oi.hna_order_mnemonic
  , oi.order_detail_display_line
  , nu.loc_facility_cd
  , maa.nurse_unit_cd
  , FIN = trim(ea.alias)
  , prsnl = p.name_full_formatted
  , mame.reason_cd
  , freetext_reason=check(mame.freetext_reason)
  , mae.event_type_cd
  , mame.order_id
 
FROM ENCOUNTER ENC
  , ENCNTR_ALIAS EA
  , ORDER_INGREDIENT OI
  , NURSE_UNIT NU
  , MED_ADMIN_EVENT MAE
  , MED_ADMIN_ALERT MAA
  , MED_ADMIN_MED_ERROR MAME
  , PRSNL P
WHERE maa.med_admin_alert_id > 0
AND nu.location_cd = maa.nurse_unit_cd
AND mame.med_admin_alert_id = maa.med_admin_alert_id
AND mame.encounter_id = enc.encntr_id
and operator(enc.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
AND oi.order_id =  mame.template_order_id  and
oi.action_sequence = mame.action_sequence and
oi.ingredient_type_flag  != 5
AND mae.event_id = mame.event_id and
mae.event_id > 0.0 and
mae.event_type_cd != value(uar_get_code_by("MEANING",4000040,'TASKPURGED'))
AND mae.beg_dt_tm between cnvtdatetime(START_DATETIME) and cnvtdatetime(END_DATETIME)
  AND maa.alert_type_cd IN (4039991.00)
and ea.encntr_id = enc.encntr_id
and ea.encntr_alias_type_cd = 1077
and ea.active_ind = 1
and ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3) 
and p.person_id = maa.prsnl_id 
and (
 cnvtlower(oi.hna_order_mnemonic) in('*tacrolimus*')
or cnvtlower(oi.hna_order_mnemonic) in('*tacrolimus topical*')
or cnvtlower(oi.hna_order_mnemonic) in('*albumin human*')
or cnvtlower(oi.hna_order_mnemonic) in('*albumin aggregated*')
or cnvtlower(oi.hna_order_mnemonic) in('*pyridostigmine*')
or cnvtlower(oi.hna_order_mnemonic) in('*mycophenolate mofetil*')
or cnvtlower(oi.hna_order_mnemonic) in('*efgartigimod alfa*')
or cnvtlower(oi.hna_order_mnemonic) in('*prednisone*')
or cnvtlower(oi.hna_order_mnemonic) in('*azathioprine*')
or cnvtlower(oi.hna_order_mnemonic) in('*cyclosporine*')
or cnvtlower(oi.hna_order_mnemonic) in('*cyclosporine ophthalmic*')
or cnvtlower(oi.hna_order_mnemonic) in('*ravulizumab*')
or cnvtlower(oi.hna_order_mnemonic) in('*sirolimus*')
or cnvtlower(oi.hna_order_mnemonic) in('*sirolimus protein-bound*')
or cnvtlower(oi.hna_order_mnemonic) in('*everolimus*')
or cnvtlower(oi.hna_order_mnemonic) in('*insulin**')
or cnvtlower(oi.hna_order_mnemonic) in('*buprenorphine*')
or cnvtlower(oi.hna_order_mnemonic) in('*butorphanol*')
or cnvtlower(oi.hna_order_mnemonic) in('*codeine-guaifenesin*')
or cnvtlower(oi.hna_order_mnemonic) in('*fentanyl*')
or cnvtlower(oi.hna_order_mnemonic) in('*gabapentin*')
or cnvtlower(oi.hna_order_mnemonic) in('*hydrocodone-acetaminophen*')
or cnvtlower(oi.hna_order_mnemonic) in('*hydromorphone*')
or cnvtlower(oi.hna_order_mnemonic) in('*ketamine*')
or cnvtlower(oi.hna_order_mnemonic) in('*meperidine*')
or cnvtlower(oi.hna_order_mnemonic) in('*methadone*')
or cnvtlower(oi.hna_order_mnemonic) in('*morphine*')
or cnvtlower(oi.hna_order_mnemonic) in('*oxycodone*')
or cnvtlower(oi.hna_order_mnemonic) in('*pregabalin*')
or cnvtlower(oi.hna_order_mnemonic) in('*tramadol*')
)
with format(date,";;q"),uar_code(d,1),format,separator=" "

end 
go
