drop program cov_std_ord_routines_tst go
create program cov_std_ord_routines_tst

execute cov_std_ord_routines 

/*
call echo(SetupOrder(125328124.00)) go
call echo(UpdateOrderDetailValueCd("COLLPRI",value(uar_get_code_by("MEANING",2054,"ROUTINE")))) go
call echo(UpdateOrderDetailValueCd("PRIORITY",value(uar_get_code_by("MEANING",1304,"STAT")))) go
call echo(UpdateOrderDetailDtTm("REQSTARTDTTM",cnvtdatetime(curdate,curtime3))) go
call echo(AddOrderComment(concat("adding a comment to see if this works"
									,"how long can the comment be"
									,"i was running into a limit i think when adding one through"
									,"ordering process. It should be much longer than that"))) go
;call echorecord(ordrequest) go
call echo(CallOrderServer(null)) go
*/

set debug_ind = 1 
call echo(GetOrderSynonymbyMnemonic("NS Chaser")) 
call echo(SetupProcOrder(125474565.0,GetOrderSynonymbyMnemonic("NS Chaser")))
 





call echo(SetProcOrderDetailValue("Freetext Orderable",0,0,1,0)) 
call echo(SetProcOrderDetailValue("Combination Dosing Ingredient",0,0,15,0)) 
call echo(SetProcOrderDetailValue("Strength Dose",0,0,15,1)) 
call echo(SetProcOrderDetailValue("Strength Dose Unit",0,0,15,2)) 
call echo(SetProcOrderDetailValue("Volume Dose",30,1,15,3)) 
call echo(SetProcOrderDetailValueCd("Volume Dose Unit",293.00,1,15,4)) 
call echo(SetProcOrderDetailValueCd("Route of Administration",318173.00,1,20)) 
call echo(SetProcOrderDetailValue("Drug Form",0,0,25)) 
call echo(SetProcOrderDetailValueCd("Frequency",4199451.00,1,26)) 
call echo(SetProcOrderDetailDTTm("Requested Start Date/Time",cnvtdatetime(curdate,curtime3)),1,28) 
call echo(SetProcOrderDetailValue("Duration",30,1,29,1)) 
call echo(SetProcOrderDetailValueCd("Duration Unit",251.00,1,29,2))
call echo(SetProcOrderDetailValue("Scheduled / PRN",1,1,30,1)) 
call echo(SetProcOrderDetailValueCd("PRN Reason",3909098297.00,1,30,2)) 
call echo(SetProcOrderDetailValue("Infuse Over",30,1,32,1)) 
call echo(SetProcOrderDetailValueCd("Infuse Over Unit",292.00,1,32,2)) 
call echo(SetProcOrderDetailDTTm("Stop Date/Time",cnvtdatetime(curdate+30,curtime3)),1,43) 
call echo(SetProcOrderDetailValueCd("Stop Type",2338.00,1,46)) 
call echo(SetProcOrderDetailValue("Adhoc Frequency Instance",-1,1,55))
call echo(SetProcOrderDetailValue("PAR Doses",0,0,70))
call echo(SetProcOrderDetailValue("Pharmacy Order Priority",0,0,75))
call echo(SetProcOrderDetailDTTm("Next Dose Dt Tm",cnvtdatetime(curdate,curtime3),1,85)) 

call echo(SetProcOrderDetailValue("Future Order",0,0,110))
call echo(SetProcOrderDetailValue("Dispense Category",0,0,170))
call echo(SetProcOrderDetailValue("Freetext Rate",0,0,125))
call echo(SetProcOrderDetailValue("Rate",0,0,125,1))
call echo(SetProcOrderDetailValue("Rate Unit",0,0,125,2))
call echo(SetProcOrderDetailValue("Total Volume",0,0,150))
call echo(SetProcOrderDetailValue("Replace Every",0,0,155))
call echo(SetProcOrderDetailValue("Replace Every Unit",0,0,160))
call echo(SetProcOrderDetailValue("Titrate Indicator",0,0,165))
call echo(SetProcOrderDetailValue("Next IV Sequence",0,0,170))
call echo(SetProcOrderDetailValue("Number of bags in IV seq",0))
call echo(SetProcOrderDetailValue("IV Set Shell Item Id",0))
call echo(SetProcOrderDetailValue("Original Order Id",0))
call echo(SetProcOrderDetailValue("Pharmacy Order Type",3)) 
call echo(SetProcOrderDetailValue("Pass Medication Indicator",0))
call echo(SetProcOrderDetailValue("Difference in Minutes",-1,1))
call echo(SetProcOrderDetailValue("Total Dispense Doses",0))
call echo(SetProcOrderDetailValue("Dispense From Location",0))
call echo(SetProcOrderDetailValue("Next Dispense Date/Time",0))
call echo(SetProcOrderDetailValue("Initial Dose Override",0))
call echo(SetProcOrderDetailValue("Floor Stock Indicator",0))
call echo(SetProcOrderDetailValue("FS Override",0))
call echo(SetProcOrderDetailValue("Write Order Dispense Flag",0))
call echo(SetProcOrderDetailValue("Price Schedule",0))
call echo(SetProcOrderDetailValue("Order Price",0))
call echo(SetProcOrderDetailValue("Order Cost",0))
call echo(SetProcOrderDetailValue("Auto Assign Flag",0))
call echo(SetProcOrderDetailValue("Cancel Reason",0))
call echo(SetProcOrderDetailValue("Discontinue Reason",0))
call echo(SetProcOrderDetailValue("Resume Reason",0))
call echo(SetProcOrderDetailValue("Suspend Reason",0))
call echo(SetProcOrderDetailValue("Dispense Quantity",0))
call echo(SetProcOrderDetailValue("Dispense Quantity Unit",0))
call echo(SetProcOrderDetailValue("Requested Dispense Duration",0))
call echo(SetProcOrderDetailValue("Requested Dispense Duration Unit",0))
call echo(SetProcOrderDetailValue("Number of Refills",0))
call echo(SetProcOrderDetailValue("Additional Refills",0))
call echo(SetProcOrderDetailValue("Total Refills",0))
call echo(SetProcOrderDetailValue("Requested Refill Date",0))
call echo(SetProcOrderDetailValue("zzzSamply Quantity",0))
call echo(SetProcOrderDetailValue("Sample Quantity Unit",0))
call echo(SetProcOrderDetailValue("Indication",0))
call echo(SetProcOrderDetailValue("DAW",0))
call echo(SetProcOrderDetailValue("Print DEA Number",0))
call echo(SetProcOrderDetailValue("Performing Location",0))
call echo(SetProcOrderDetailValue("Don't Print Rx Reason",0))
call echo(SetProcOrderDetailValue("Physician Address",0))
call echo(SetProcOrderDetailValue("Physician Address Id",0))
call echo(SetProcOrderDetailValue("Order Location",0))
call echo(SetProcOrderDetailValue("Component Cost",0))
call echo(SetProcOrderDetailValue("Continuous IV",0))
call echo(SetProcOrderDetailValue("Start Bag",0))
call echo(SetProcOrderDetailValue("IV Seq",0))
call echo(SetProcOrderDetailValue("Diluent Volume",0))
call echo(SetProcOrderDetailValue("Print Indicator",0))
call echo(SetProcOrderDetailValue("Diluent Id",0))
call echo(SetProcOrderDetailValue("Number of Labels",0))
call echo(SetProcOrderDetailValue("DC Display Days",0))
call echo(SetProcOrderDetailValue("Diagnosis",0))
call echo(SetProcOrderDetailValue("Freetext Provider",0))
call echo(SetProcOrderDetailValue("Dose Quantity",0))
call echo(SetProcOrderDetailValue("Dose Quantity Unit",0))
call echo(SetProcOrderDetailValue("Sort Lower",0))
call echo(SetProcOrderDetailValue("Requisition Routing Type",0))
call echo(SetProcOrderDetailValue("Order Output Destination",0))
call echo(SetProcOrderDetailValue("Freetext Order Fax Number",0))
call echo(SetProcOrderDetailValue("Routing Pharmacy Id",0))
call echo(SetProcOrderDetailValue("Instructions Replace Required Details",0))
call echo(SetProcOrderDetailValue("Rx Special Instructions",0))
call echo(SetProcOrderDetailValue("Patient's Own Meds",0))
call echo(SetProcOrderDetailValue("Pharmacy Reference",0))
;call echo(SetProcOrderDetailValue("Treatment Period",0))
call echo(SetProcOrderDetailValue("Workflow Sequence",0))
call echo(SetProcOrderDetailValue("Freetext Dose",0))
call echo(SetProcOrderDetailValue("Pharmacy Instructions",0))
call echo(SetProcOrderDetailValueCd("Frequency Schedule Id",12021.00,1)) 
call echo(SetProcOrderDetailValue("IVPO Rule",1,1))
call echo(SetProcOrderDetailDTTm("Reference Start Date/Time",cnvtdatetime(curdate,curtime3))) 







call echorecord(procrequest) 
call echo(CallProcServer(null)) 
end
go

execute cov_std_ord_routines_tst go
