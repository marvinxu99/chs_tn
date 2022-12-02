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
   window = if (datetimediff(mae.beg_dt_tm,o.current_start_dt_tm,4) < -30)
  					"Early"
  				   elseif (datetimediff(mae.beg_dt_tm,o.current_start_dt_tm,4) > 30)
  				    "Late"
  				   else
  				    "On-time"
  				   endif
  , o.current_start_dt_tm
  , mae.beg_dt_tm
  , difference = datetimediff(mae.beg_dt_tm,o.current_start_dt_tm,4)
  , o.order_mnemonic
  , oi.hna_order_mnemonic
  , o.simplified_display_line
  , enc.loc_nurse_unit_cd
  , FIN = trim(ea.alias)
  , prsnl = p.name_full_formatted
  , mae.event_type_cd
  , o.order_id


/*

MED_ADMIN_EVENT MAE
  ,CLINICAL_EVENT CE
  ,ENCOUNTER E
  ,ENCNTR_ALIAS EA
  ,ORDERS O
;;; set your time range below - start with one day or less then expand out if necessary
plan MAE where
  ( MAE.BEG_DT_TM  between CNVTDATETIME( "15-May-2019 00:00:00:00" ) ; START TIME - TIME ADMINISTERED
                  and    CNVTDATETIME( "15-May-2019 23:59:59:00" ) ) ; STOP TIME
                  and    MAE.EVENT_TYPE_CD = 4055412.00 ; ADMINISTERED
                                                        ;;; if CCL does not execute, check this value in your domain
join CE where
    CE.EVENT_ID = OUTERJOIN( MAE.EVENT_ID )
join O where
    O.ORDER_ID = MAE.ORDER_ID
and O.PRN_IND = 0 ; IGNORE PRN ORDERS
                  ;;; set to 1 if you want to include PRN orders
;;; remove the comment on the and line below to filter down the orders returned based on the frequency type flag
;;;
;;; 0-1-2-3 unknown (at least, I cannot find their meaning on the Wiki pages)
;;; 4: Once (scheduled)
;;; 5: Unscheduled frequencies
; and o.freq_type_flag !=
join E where
    E.ENCNTR_ID = CE.ENCNTR_ID
join EA where
    EA.ENCNTR_ID = E.ENCNTR_ID
and EA.ENCNTR_ALIAS_TYPE_CD = 1077.00 ; FIN NUMBER
*/ 
FROM 
	ENCOUNTER ENC
  , ENCNTR_ALIAS EA
  , MED_ADMIN_EVENT MAE
  , PRSNL P
  ,	CLINICAL_EVENT CE
  , ORDER_INGREDIENT OI
  , ORDERS O
  , ORDER_CATALOG OC
plan mae
	where mae.beg_dt_tm between cnvtdatetime(START_DATETIME) and cnvtdatetime(END_DATETIME)
 	
join ce
	where ce.event_id = mae.event_id
join enc
	where enc.encntr_id = ce.encntr_id
	and operator(enc.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
	;and enc.encntr_id = 132104854
join ea
	where ea.encntr_id = enc.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
	and ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3) 
join p
	where p.person_id = mae.prsnl_id
join o
	where o.order_id = mae.order_id
	and   o.prn_ind = 0
join oi
	where oi.order_id  = outerjoin(mae.order_id)
join oc
	where oc.catalog_cd = o.catalog_cd
	
	and (
		   cnvtlower(oc.primary_mnemonic) in('*tacrolimus')
		;or cnvtlower(oc.primary_mnemonic) in('*tacrolimus topical*')
		;or cnvtlower(oc.primary_mnemonic) in('*albumin human*')
		;or cnvtlower(oc.primary_mnemonic) in('*albumin aggregated*')
		;or cnvtlower(oc.primary_mnemonic) in('*pyridostigmine*')
		or cnvtlower(oc.primary_mnemonic) in('*mycophenolate mofetil')
		;or cnvtlower(oc.primary_mnemonic) in('*efgartigimod alfa*')
		;or cnvtlower(oc.primary_mnemonic) in('*prednisone*')
		;or cnvtlower(oc.primary_mnemonic) in('*azathioprine*')
		or cnvtlower(oc.primary_mnemonic) in('*cyclosporine')
		;or cnvtlower(oc.primary_mnemonic) in('*cyclosporine ophthalmic*')
		;or cnvtlower(oc.primary_mnemonic) in('*ravulizumab*')
		;or cnvtlower(oc.primary_mnemonic) in('*sirolimus*')
		;or cnvtlower(oc.primary_mnemonic) in('*sirolimus protein-bound*')
		;or cnvtlower(oc.primary_mnemonic) in('*everolimus*')
		;or cnvtlower(oc.primary_mnemonic) in('*insulin**')
		;or cnvtlower(oc.primary_mnemonic) in('*buprenorphine*')
		;or cnvtlower(oc.primary_mnemonic) in('*butorphanol*')
		;or cnvtlower(oc.primary_mnemonic) in('*codeine-guaifenesin*')
		;or cnvtlower(oc.primary_mnemonic) in('*fentanyl*')
		;or cnvtlower(oc.primary_mnemonic) in('*gabapentin*')
		;or cnvtlower(oc.primary_mnemonic) in('*hydrocodone-acetaminophen*')
		;or cnvtlower(oc.primary_mnemonic) in('*hydromorphone*')
		;or cnvtlower(oc.primary_mnemonic) in('*ketamine*')
		;or cnvtlower(oc.primary_mnemonic) in('*meperidine*')
		;or cnvtlower(oc.primary_mnemonic) in('*methadone*')
		;or cnvtlower(oc.primary_mnemonic) in('*morphine*')
		;or cnvtlower(oc.primary_mnemonic) in('*oxycodone*')
		;or cnvtlower(oc.primary_mnemonic) in('*pregabalin*')
		;or cnvtlower(oc.primary_mnemonic) in('*tramadol*')
		)
		
with format(date,";;q"),uar_code(d,1),format,separator=" "

end 
go
