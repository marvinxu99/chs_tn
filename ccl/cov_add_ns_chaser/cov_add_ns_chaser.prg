/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       
  Solution:           
  Source file name:   cov_add_ns_chaser.prg
  Object name:        cov_add_ns_chaser
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   			  Chad Cummings			initial build
******************************************************************************/
drop program cov_add_ns_chaser:dba go
create program cov_add_ns_chaser:dba

execute cov_std_ord_routines 

call SubroutineLog(build2("starting ",trim(curprog)))

set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 order_id = f8
	 2 order_provider_id = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
) with protect

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
set t_rec->patient.order_id 				= trigger_orderid

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

if (t_rec->patient.order_id <= 0.0)
	set t_rec->log_message = concat("trigger_orderid not found")
	go to exit_script
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

set t_rec->return_value = "FALSE"

select into "nl:"
from
	 orders o
	,order_action oa
plan o
	where o.order_id = t_rec->patient.order_id
join oa
	where oa.order_id = o.order_id
	and   oa.action_type_cd = value(uar_get_code_by("MEANING",6003,"ORDER"))
order by
	o.order_id
head report
	null
head o.order_id
	t_rec->patient.order_provider_id = oa.order_provider_id
with nocounter

if (t_rec->patient.order_provider_id = 0.0)
	set t_rec->patient.order_provider_id = 1.0
endif	

set stat = (GetOrderSynonymbyMnemonic("NS Chaser")) 
set stat = SetupProcOrder(
							 t_rec->patient.encntr_id
							,GetOrderSynonymbyMnemonic("NS Chaser")
							,t_rec->patient.order_provider_id
						)

set stat = (SetProcOrderDetailValue("Freetext Orderable",0,0,1,0)) 
set stat = (SetProcOrderDetailValue("Combination Dosing Ingredient",0,0,15,0)) 
set stat = (SetProcOrderDetailValue("Strength Dose",0,0,15,1)) 
set stat = (SetProcOrderDetailValue("Strength Dose Unit",0,0,15,2)) 
set stat = (SetProcOrderDetailValue("Volume Dose",30,1,15,3)) 
set stat = (SetProcOrderDetailValueCd("Volume Dose Unit",293.00,1,15,4)) 
set stat = (SetProcOrderDetailValueCd("Route of Administration",318173.00,1,20)) 
set stat = (SetProcOrderDetailValue("Drug Form",0,0,25)) 
set stat = (SetProcOrderDetailValueCd("Frequency",4199451.00,1,26)) 
set stat = SetProcOrderDetailDTTm("Requested Start Date/Time",cnvtdatetime(curdate,curtime3),1,28)
set stat = (SetProcOrderDetailValue("Duration",30,1,29,1)) 
set stat = (SetProcOrderDetailValueCd("Duration Unit",251.00,1,29,2))
set stat = (SetProcOrderDetailValue("Scheduled / PRN",1,1,30,1)) 
set stat = (SetProcOrderDetailValueCd("PRN Reason",3909098297.00,1,30,2)) 
set stat = (SetProcOrderDetailValue("Infuse Over",30,1,32,1)) 
set stat = (SetProcOrderDetailValueCd("Infuse Over Unit",292.00,1,32,2)) 
;set stat = (SetProcOrderDetailDTTm("Stop Date/Time",cnvtdatetime(curdate+30,curtime3)),1,43) 
set stat = (SetProcOrderDetailValueCd("Stop Type",2338.00,1,46)) 
set stat = (SetProcOrderDetailValue("Adhoc Frequency Instance",-1,1,55))
set stat = (SetProcOrderDetailValue("PAR Doses",0,0,70))
;set stat = (SetProcOrderDetailValue("Pharmacy Order Priority",0,0,75))
;set stat = (SetProcOrderDetailDTTm("Next Dose Dt Tm",cnvtdatetime(curdate,curtime3),1,85)) 

set stat = (SetProcOrderDetailValue("Future Order",0,0,110))
set stat = (SetProcOrderDetailValue("Dispense Category",0,0,170))
set stat = (SetProcOrderDetailValue("Freetext Rate",0,0,125))
set stat = (SetProcOrderDetailValue("Rate",0,0,125,1))
set stat = (SetProcOrderDetailValue("Rate Unit",0,0,125,2))
set stat = (SetProcOrderDetailValue("Total Volume",0,0,150))
set stat = (SetProcOrderDetailValue("Replace Every",0,0,155))
set stat = (SetProcOrderDetailValue("Replace Every Unit",0,0,160))
set stat = (SetProcOrderDetailValue("Titrate Indicator",0,0,165))
set stat = (SetProcOrderDetailValue("Next IV Sequence",0,0,170))
set stat = (SetProcOrderDetailValue("Number of bags in IV seq",0))
set stat = (SetProcOrderDetailValue("IV Set Shell Item Id",0))
set stat = (SetProcOrderDetailValue("Original Order Id",0))
set stat = (SetProcOrderDetailValue("Pharmacy Order Type",3,1)) 
set stat = (SetProcOrderDetailValue("Pass Medication Indicator",0))
set stat = (SetProcOrderDetailValue("Difference in Minutes",-1,1))
set stat = (SetProcOrderDetailValue("Total Dispense Doses",0))
set stat = (SetProcOrderDetailValue("Dispense From Location",0))
set stat = (SetProcOrderDetailValue("Next Dispense Date/Time",0))
set stat = (SetProcOrderDetailValue("Initial Dose Override",0))
set stat = (SetProcOrderDetailValue("Floor Stock Indicator",0))
set stat = (SetProcOrderDetailValue("FS Override",0))
set stat = (SetProcOrderDetailValue("Write Order Dispense Flag",0))
set stat = (SetProcOrderDetailValue("Price Schedule",0))
set stat = (SetProcOrderDetailValue("Order Price",0))
set stat = (SetProcOrderDetailValue("Order Cost",0))
set stat = (SetProcOrderDetailValue("Auto Assign Flag",0))
set stat = (SetProcOrderDetailValue("Cancel Reason",0))
set stat = (SetProcOrderDetailValue("Discontinue Reason",0))
set stat = (SetProcOrderDetailValue("Resume Reason",0))
set stat = (SetProcOrderDetailValue("Suspend Reason",0))
set stat = (SetProcOrderDetailValue("Dispense Quantity",0))
set stat = (SetProcOrderDetailValue("Dispense Quantity Unit",0))
set stat = (SetProcOrderDetailValue("Requested Dispense Duration",0))
set stat = (SetProcOrderDetailValue("Requested Dispense Duration Unit",0))
set stat = (SetProcOrderDetailValue("Number of Refills",0))
set stat = (SetProcOrderDetailValue("Additional Refills",0))
set stat = (SetProcOrderDetailValue("Total Refills",0))
set stat = (SetProcOrderDetailValue("Requested Refill Date",0))
set stat = (SetProcOrderDetailValue("zzzSamply Quantity",0))
set stat = (SetProcOrderDetailValue("Sample Quantity Unit",0))
set stat = (SetProcOrderDetailValue("Indication",0))
set stat = (SetProcOrderDetailValue("DAW",0))
set stat = (SetProcOrderDetailValue("Print DEA Number",0))
set stat = (SetProcOrderDetailValue("Performing Location",0))
set stat = (SetProcOrderDetailValue("Don't Print Rx Reason",0))
set stat = (SetProcOrderDetailValue("Physician Address",0))
set stat = (SetProcOrderDetailValue("Physician Address Id",0))
set stat = (SetProcOrderDetailValue("Order Location",0))
set stat = (SetProcOrderDetailValue("Component Cost",0))
set stat = (SetProcOrderDetailValue("Continuous IV",0))
set stat = (SetProcOrderDetailValue("Start Bag",0))
set stat = (SetProcOrderDetailValue("IV Seq",0))
set stat = (SetProcOrderDetailValue("Diluent Volume",0))
set stat = (SetProcOrderDetailValue("Print Indicator",0))
set stat = (SetProcOrderDetailValue("Diluent Id",0))
set stat = (SetProcOrderDetailValue("Number of Labels",0))
set stat = (SetProcOrderDetailValue("DC Display Days",0))
set stat = (SetProcOrderDetailValue("Diagnosis",0))
set stat = (SetProcOrderDetailValue("Freetext Provider",0))
set stat = (SetProcOrderDetailValue("Dose Quantity",0))
set stat = (SetProcOrderDetailValue("Dose Quantity Unit",0))
set stat = (SetProcOrderDetailValue("Sort Lower",0))
set stat = (SetProcOrderDetailValue("Requisition Routing Type",0))
set stat = (SetProcOrderDetailValue("Order Output Destination",0))
set stat = (SetProcOrderDetailValue("Freetext Order Fax Number",0))
set stat = (SetProcOrderDetailValue("Routing Pharmacy Id",0))
set stat = (SetProcOrderDetailValue("Instructions Replace Required Details",0))
set stat = (SetProcOrderDetailValue("Rx Special Instructions",0))
set stat = (SetProcOrderDetailValue("Patient's Own Meds",0))
set stat = (SetProcOrderDetailValue("Pharmacy Reference",0))
;set stat = (SetProcOrderDetailValue("Treatment Period",0))
set stat = (SetProcOrderDetailValue("Workflow Sequence",0))
set stat = (SetProcOrderDetailValue("Freetext Dose",0))
set stat = (SetProcOrderDetailValue("Pharmacy Instructions",0))
set stat = (SetProcOrderDetailValueCd("Frequency Schedule Id",12021.00,1)) 
set stat = (SetProcOrderDetailValue("IVPO Rule",1,1))
set stat = SetProcOrderDetailDTTm("Reference Start Date/Time",cnvtdatetime(curdate,curtime3))

set stat = CallProcServer(null)

set t_rec->return_value = "TRUE"

#exit_script

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
	set t_rec->log_misc1 = ""
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end 
go
