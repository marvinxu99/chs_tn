/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/11/2021
  Solution:
  Source file name:   cov_eks_hstrop_cancel.prg
  Object name:        cov_eks_hstrop_cancel
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Additional Scripts:
 
  						cov_troponin_util
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   12/11/2021  Chad Cummings			initial build
******************************************************************************/
drop program cov_eks_hstrop_cancel:dba go
create program cov_eks_hstrop_cancel:dba
 
set retval = -1
 
 
record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	 2 order_id = f8
	 2 clinical_event_id = f8
	 2 event_id = f8
	 2 parent_event_id = f8
	 2 update_needed = i2
	1 algorithm_data
	 2 linked_eventid = f8
	 2 new_eventid = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
) with protect
 
declare add_log_message(vMessage = vc) = null
 
declare order_comment = vc with noconstant(" "), protect
declare updated_result = vc with noconstant(" "), protect
declare context_clinical_event_id = f8 with noconstant(0.0), protect
 
subroutine add_log_message(vMessage)
	call echo(vMessage)
	set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(vMessage)
									)
end ;add_log_message
 
call add_log_message("v1")
 
set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
 
set t_rec->patient.order_id					= link_orderid
 
if (t_rec->patient.encntr_id <= 0.0)
	call add_log_message("link_encntrid not found")
	go to exit_script
endif
 
if (t_rec->patient.person_id <= 0.0)
	call add_log_message("link_personid not found")
	go to exit_script
endif
 
if (t_rec->patient.order_id <= 0.0)
	call add_log_message("link_orderid not found")
	go to exit_script
endif
 
/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */
 
set t_rec->return_value = "FALSE"
 
execute cov_troponin_util
 
call add_log_message(cnvtupper(GetOrderPowerPlanbyOrderID(t_rec->patient.order_id)))
 
;get the clinical event that holds the data for the instance of the algorithm.
;the order_list for each instance of the algo is searched
set t_rec->algorithm_data.linked_eventid = FindOrderInhsTrop(t_rec->patient.order_id)
 
 
;if no previous algo instance is found
if (t_rec->algorithm_data.linked_eventid = 0.0)
	call add_log_message("order_id was not found as part of an algorithm")
	go to exit_script
else
	call add_log_message("updating existing algorithm")
	set stat = cnvtjsontorec(GethsTropAlgDataByEventID(t_rec->algorithm_data.linked_eventid))
 
	if (validate(hsTroponin_data) = FALSE)
		call add_log_message("unable to get algorithm information for supplied event")
		go to exit_script
	endif
 
	if ((hsTroponin_data->one_hour.needed_ind = 1) and (hsTroponin_data->one_hour.order_id = t_rec->patient.order_id))
		set hsTroponin_data->one_hour.order_id = 0.0
		set t_rec->patient.update_needed = 1
		call add_log_message("matched one hour order_id, resetting to 0")
	endif
 
	if ((hsTroponin_data->three_hour.needed_ind = 1) and (hsTroponin_data->three_hour.order_id = t_rec->patient.order_id))
		set hsTroponin_data->three_hour.order_id = 0.0
		set t_rec->patient.update_needed = 1
		call add_log_message("matched three hour order_id, resetting to 0")
	endif
 
	if (t_rec->patient.update_needed = 1)
		set t_rec->algorithm_data.new_eventid = EnsurehsTropAlgData(
																	 hsTroponin_data->person_id
																	,hsTroponin_data->encntr_id
																	,t_rec->algorithm_data.linked_eventid
																	,cnvtrectojson(hsTroponin_data)
																	)
	endif
endif
 
set t_rec->return_value = "TRUE"
 
#exit_script
 
if (validate(hsTroponin_data))
	call add_log_message(cnvtrectojson(hsTroponin_data))
	call echorecord(hsTroponin_data)
endif
 
if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
	set t_rec->log_misc1 = ""
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif
 
call add_log_message(cnvtrectojson(t_rec))
 
call echorecord(t_rec)
 
set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1
 
end
go
 
