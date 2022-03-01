/*~BB~************************************************************************
 * 																			 *
 * Copyright Notice: (c) 1983 Laboratory Information Systems &               *
 * Technology, Inc.                                                          *
 * Revision (c) 1984-1995 Cerner Corporation                                 *
 * 																	         *
 * Cerner (R) Proprietary Rights Notice: All rights reserved.                *
 * This material contains the valuable properties and trade secrets of       *
 * Cerner Corporation of Kansas City, Missouri, United States of             *
 * America (Cerner), embodying substantial creative efforts and              *
 * confidential information, ideas and expressions, no part of which         *
 * may be reproduced or transmitted in any form or by any means, or          *
 * retained in any storage or retrieval system without the express           *
 * written permission of Cerner.                                             *
 *                                                                           *
 * Cerner is a registered mark of Cerner Corporation.                        *
 *                                                                           *
 ~BE~************************************************************************/

/*****************************************************************************

	 Source file name: 	dcp_bld_query_stoke.PRG
	 Object name: 		dcp_bld_query_stoke
	 Request #: 		NA

	 Product: 			DCP
	 Product Team: 		PowerChart

	 Program purpose: 	ReadMe to call a script to build metadata for stroke consults

 	 Tables read: 		

 	 Tables updated: 	

  	 Executing from: 	README STEP

******************************************************************************/

 ;~DB~************************************************************************
 ; * GENERATED MODIFICATION CONTROL LOG 		                             *
 ; ***************************************************************************
 ; * *
 ; *Mod Date Engineer Comment 												 *
 ; *--- -------- -------------------- -----------------------------------    *
 ; ### 11/28/02 Mark Smith			  Initial Release                        *
 ;~DE~************************************************************************
 ;~END~ ****************** END OF ALL MODCONTROL BLOCKS **********************

drop program dcp_bld_query_stoke:dba go
create program dcp_bld_query_stoke:dba

/**************************************************************************
* Include files                                                           *
**************************************************************************/

;Defines a global readme data structure
%i cclsource:dm_readme_data.inc

/**************************************************************************
* Record Structure 														  *
**************************************************************************/

record bldRequest
(
 1 name = vc
 1 definition = vc
 1 query_script = vc
 1 parameters[*]
 	2 name = vc
 	2 description = vc
 	2 parameter_type_cd = f8
 	2 required_ind = i2
 	2 multiplicity_ind = i2
 	2 metadata[*]
 		3 name = vc
 		3 sequence = i4
 		3 value_string = vc
 		3 value_dt = dq8
 		3 value_id = f8
 		3 value_entity = vc
)

record bldReply
( 
1 query_type_cd = f8

%i cclsource:status_block.inc
)

/**************************************************************************
* Declare Variables 													  *
**************************************************************************/

declare rdm_errcode = i4 with noconstant (0)
declare rdm_errmsg = c132 with noconstant (fillstring(132, " "))
declare errmsg = c132 with noconstant (fillstring(132, " "))
declare readme_status = c1 with noconstant ("S")
declare MAXRECS = i4 with constant(100)
declare iteration_count = i4 with noconstant(1)
declare providerCd = f8 with noconstant(0.0)
declare entityCd = f8 with noconstant(0.0)
declare daterangeCd = f8 with noconstant(0.0)

set rdm_errcode = error(rdm_errmsg,1) ; Reset the queue.


/**************************************************************************
* Begin 																  *
**************************************************************************/

;******  Join against code_value table due to UAR's not working in a Readme  *********
	select into "nl:"
	from code_value cv
	where cv.code_set = 29803
	detail
		if(cv.cdf_meaning = "PROVIDER")
			providerCd = cv.code_value
		elseif(cv.cdf_meaning = "ENTITY")
			entityCd = cv.code_value
		elseif(cv.cdf_meaning = "DATERANGE")
			daterangeCd = cv.code_value
		endif
	with constant

  select into "nl:" from dm_info di where di.info_name = "Build Stroke Coordinator Query Type"
  if (curqual > 0)
  	delete from dm_info di where di.info_name = "Build Stroke Coordinator Query Type"
  endif

  ;Insert a row in DM_INFO setting the info_name to "Reference Text Readme"
  ;and info_date to the current date
  insert into dm_info di
  set di.info_name = "Build Stroke Coordinator Query Type",
	  di.info_date = cnvtdatetime(curdate, curtime3),
	  di.updt_applctx = 0,
	  di.updt_cnt = 0,
	  di.updt_dt_tm = cnvtdatetime(curdate, curtime3),
	  di.updt_id = 0,
	  di.updt_task = 0
  with nocounter

  ;Check for errors
  if (curqual = 0)
	  set readme_status = 'F'
	  set rdm_errmsg = "Could not set readme run date on DM_INFO table"
	  go to exit_readme
  endif
  
  
  ;Call the dcp_bld_query_type script to add the parameters and metadata to
  ;build the provider group query.
  
  ;Set the request
  set bldRequest->name = "Stroke Coordinator Query"
  set bldRequest->definition = "Stroke Coordinator Query"
  set bldRequest->query_script = "dcp_query_pl_stroke"
  
  set stat = alterlist(bldRequest->parameters,2)
  
  ;Set the FACILITY information
  set bldRequest->parameters[1]->name = "Facility"
  set bldRequest->parameters[1]->description = "Please specify the type of visit relationships you wish to qualify patients for."
  set bldRequest->parameters[1]->parameter_type_cd = entityCd
  set bldRequest->parameters[1]->required_ind = 1
  set bldRequest->parameters[1]->multiplicity_ind = 1

	;Set Metadata
	set stat = alterlist(bldRequest->parameters[1]->metadata,4)
	set bldRequest->parameters[1]->metadata[1]->name = "M_TABLE"
	set bldRequest->parameters[1]->metadata[1]->sequence = 1
	set bldRequest->parameters[1]->metadata[1]->value_string = "CODE_VALUE"
	set bldRequest->parameters[1]->metadata[1]->value_dt = null
	set bldRequest->parameters[1]->metadata[1]->value_id = 0
	set bldRequest->parameters[1]->metadata[1]->value_entity = ""
	
	set bldRequest->parameters[1]->metadata[2]->name = "M_DISPLAY_FIELD"
	set bldRequest->parameters[1]->metadata[2]->sequence = 1
	set bldRequest->parameters[1]->metadata[2]->value_string = "display"
	set bldRequest->parameters[1]->metadata[2]->value_dt = null
	set bldRequest->parameters[1]->metadata[2]->value_id = 0
	set bldRequest->parameters[1]->metadata[2]->value_entity = ""
	
	set bldRequest->parameters[1]->metadata[3]->name = "M_IDENTIFICATION_FIELD"
	set bldRequest->parameters[1]->metadata[3]->sequence = 1
	set bldRequest->parameters[1]->metadata[3]->value_string = "code_value"
	set bldRequest->parameters[1]->metadata[3]->value_dt = null
	set bldRequest->parameters[1]->metadata[3]->value_id = 0
	set bldRequest->parameters[1]->metadata[3]->value_entity = ""
	
	set bldRequest->parameters[1]->metadata[4]->name = "M_CRITERIA"
	set bldRequest->parameters[1]->metadata[4]->sequence = 1
	set bldRequest->parameters[1]->metadata[4]->value_string = "code_set = 220 and cdf_meaning ='FACILITY' and active_ind = 1"
	set bldRequest->parameters[1]->metadata[4]->value_dt = null
	set bldRequest->parameters[1]->metadata[4]->value_id = 0
	set bldRequest->parameters[1]->metadata[4]->value_entity = ""
	
 ;Set the ENCNTR_STATUS information
  set bldRequest->parameters[2]->name = "Encounter Statuses"
  set bldRequest->parameters[2]->description = "Please identify the statuses of encounters you wish to qualify patients for."
  set bldRequest->parameters[2]->parameter_type_cd = entityCd
  set bldRequest->parameters[2]->required_ind = 1
  set bldRequest->parameters[2]->multiplicity_ind = 1

	;Set Metadata
	set stat = alterlist(bldRequest->parameters[2]->metadata,4)
	set bldRequest->parameters[2]->metadata[1]->name = "M_TABLE"
	set bldRequest->parameters[2]->metadata[1]->sequence = 1
	set bldRequest->parameters[2]->metadata[1]->value_string = "CODE_VALUE"
	set bldRequest->parameters[2]->metadata[1]->value_id = 0
	set bldRequest->parameters[2]->metadata[1]->value_entity = ""
	
	set bldRequest->parameters[2]->metadata[2]->name = "M_DISPLAY_FIELD"
	set bldRequest->parameters[2]->metadata[2]->sequence = 1
	set bldRequest->parameters[2]->metadata[2]->value_string = "display"
	set bldRequest->parameters[2]->metadata[2]->value_id = 0
	set bldRequest->parameters[2]->metadata[2]->value_entity = ""
	
	set bldRequest->parameters[2]->metadata[3]->name = "M_IDENTIFICATION_FIELD"
	set bldRequest->parameters[2]->metadata[3]->sequence = 1
	set bldRequest->parameters[2]->metadata[3]->value_string = "code_value"
	set bldRequest->parameters[2]->metadata[3]->value_id = 0
	set bldRequest->parameters[2]->metadata[3]->value_entity = ""
	
	set bldRequest->parameters[2]->metadata[4]->name = "M_CRITERIA"
	set bldRequest->parameters[2]->metadata[4]->sequence = 1
	set bldRequest->parameters[2]->metadata[4]->value_string = "code_set = 261 and active_ind = 1"	
	set bldRequest->parameters[2]->metadata[4]->value_id = 0
	set bldRequest->parameters[2]->metadata[4]->value_entity = ""
	
	;call echorecord(bldRequest)
  ;Execute the dcp_bld_query_type script with the above request.
  execute dcp_bld_query_type
  with replace(request,bldRequest), replace(reply,bldReply)
  ;call echorecord(bldReply)
  
  ;Check for errors
  if(bldReply->status_data->status = "F")
    set readme_status = 'F'
	set rdm_errmsg = "dcp_bld_query_type script failed"
	go to exit_readme
  elseif (bldReply->status_data->status = "Z")
  	set readme_status = 'Q'
  endif


/**************************************************************************
* Exit Readme 															  *
**************************************************************************/

  #exit_readme
  
 free record bldRequest
 free record bldReply

if(validate(readme_data->readme_id,0) > 0)

 if(readme_status = "F")
  set readme_data->status = "F"
  set readme_data->message = rdm_errmsg
  rollback
 elseif (readme_status = "S")
  set readme_data->status = "S"
  set readme_data->message = "Successfully created provider group query type."
  commit
 elseif (readme_status = "Q")
  set readme_data->status = "S"
  set readme_data->message = "The query type code already existed."
  rollback
 endif

 execute DM_README_STATUS
 
else

 if(readme_status = "F" or readme_status = "Q")
 	rollback
 elseif (readme_status = "S")
 	commit
 endif
 
endif

 end
 go
	

