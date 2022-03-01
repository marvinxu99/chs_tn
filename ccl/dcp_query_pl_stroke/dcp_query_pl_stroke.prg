/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-1995 Cerner Corporation                 *
      *                                                                      *
      *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
      *  This material contains the valuable properties and trade secrets of *
      *  Cerner Corporation of Kansas City, Missouri, United States of       *
      *  America (Cerner), embodying substantial creative efforts and        *
      *  confidential information, ideas and expressions, no part of which   *
      *  may be reproduced or transmitted in any form or by any means, or    *
      *  retained in any storage or retrieval system without the express     *
      *  written permission of Cerner.                                       *
      *                                                                      *
      *  Cerner is a registered mark of Cerner Corporation.                  *
      *                                                                      *
  ~BE~***********************************************************************/
 
/*****************************************************************************
 
        Source file name:       dcp_query_pl_stroke.PRG
        Object name:            dcp_query_pl_stroke
        Request #:				None - Executed from dcp_execute_query_list
 
        Product:                DCP
        Product Team:
        HNA Version:            500
        CCL Version:            4.0
 
        Program purpose:        Executes stroke coordinator query.
 
 
        Tables read:            PRSNL_GROUP_RELTN, ENCNTR_PRSNL_RELTN, ENCOUNTER
        						ENCNTR_PLAN_RELTN
        Tables updated:         -
        Executing from:         Readme
 
        Special Notes:          -
 
******************************************************************************/
 
 
;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date     Engineer             Comment                             *
;    *--- -------- -------------------- ----------------------------------- *
;     000 11/15/02 Mark Smith           initial release                     *
;~DE~************************************************************************
 
 
;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************
 
drop program dcp_query_pl_stroke:dba go
create program dcp_query_pl_stroke:dba
 
record definition
(
1 patient_list_id = f8
1 parameters[*]
	2 parameter_name = vc
	2 paramter_seq = i4
	2 values[*]
		3 value_name = vc
		3 value_seq = i4
		3 value_string = vc
		3 value_dt = dq8
		3 value_id = f8
		3 value_entity = vc
)
 
record patients
(
1 patients[*]
	2 person_id = f8
	2 encntr_id = f8
	2 priority = i4
 
%i cclsource:status_block.inc
)
 
record providers
(
1 providers[*]
	2 person_id = f8
)
 
record date
(
1 startDate = dq8
1 endDate = dq8
)
 
;call echorecord(definition)
set modify predeclare
;********************  Declare Variables  **********************************
declare paramCnt = i4 with constant(size(definition->parameters, 5))
declare valueCnt = i4 with noconstant(0)
declare patCnt = i4 with noconstant(0)
declare fac_where = vc with noconstant(fillstring(1000, " "))
declare ord_where = vc with noconstant(fillstring(1000, " "))
declare encntrStatus_where = vc with noconstant(fillstring(1000, " "))
declare x = i4 with noconstant(0)
declare y = i4 with noconstant(0)
 
declare stroke_order_cd = f8 with constant(uar_get_code_by("DISPLAY",200,"Notify Stroke Coordinator"))
declare ordered_cd = f8 with constant(uar_get_code_by("MEANING",6004,"ORDERED"))

set patients->status_data->status = "F"

for (y = 1 to paramCnt)
	;FACILITY
	if(definition->parameters[y]->parameter_seq = 1)
 
		set valueCnt = size(definition->parameters[y]->values, 5)
		set fac_where = " and e.loc_facility_cd in ("
 
		for(x = 1 to valueCnt)
			if(definition->parameters[y]->values[x]->value_name = "V_ENTITY_ID")
				set fac_where = concat(fac_where, trim(cnvtstring(definition->parameters[y]->values[x]->value_id)), ",")
			endif
		endfor
 
		if(trim(fac_where) = " and e.loc_facility_cd in (")
			for(x = 1 to valueCnt)
				if(definition->parameters[y]->values[x]->value_name = "R_ENTITY_ID")
					set fac_where = concat(fac_where, trim(cnvtstring(definition->parameters[y]->values[x]->value_id)), ",")
				endif
			endfor
		endif
 
		if(trim(fac_where) != "")
			set fac_where = replace(fac_where, ",", ")", 2)
		endif
 
	endif
	;ENCNTR_STATUS
	if(definition->parameters[y]->parameter_seq = 2)
 
		set valueCnt = size(definition->parameters[y]->values, 5)
		set encntrStatus_where = " and e.encntr_status_cd in ("
 
		for(x = 1 to valueCnt)
			if(definition->parameters[y]->values[x]->value_name = "V_ENTITY_ID")
				set encntrStatus_where = concat(encntrStatus_where, trim(cnvtstring(definition->parameters[y]->values[x]->value_id)), ",")
			endif
		endfor
 
		if(trim(encntrStatus_where) = " and e.encntr_status_cd in (")
			for(x = 1 to valueCnt)
				if(definition->parameters[y]->values[x]->value_name = "R_ENTITY_ID")
					set encntrStatus_where = concat(encntrStatus_where, trim(cnvtstring(definition->parameters[y]->values[x]->value_id)), ",")
				endif
			endfor
		endif
 
		if(trim(encntrStatus_where) != "")
			set encntrStatus_where = replace(encntrStatus_where, ",", ")", 2)
		endif
 
	endif
endfor

call echo(build2("fac_where=",fac_where))

set ord_where = "o.catalog_cd = stroke_order_cd and o.order_status_cd = ordered_cd"

call echo(build2("ord_where=",ord_where))

call parser("select into 'nl:' from orders o,encounter e ")
call parser("plan o where ")
call parser(ord_where)
call parser("join e where ")
call parser("e.encntr_id = o.encntr_id ")
call parser(fac_where)
call parser(encntrStatus_where)
call parser("order by e.person_id ")
call parser("head report ")
call parser("patCnt = 0 ")
call parser("detail ")
call parser("patCnt = patCnt + 1 ")
call parser("if (mod(patCnt, 10) = 1) ")
call parser("stat = alterlist(patients->patients, patCnt + 9) ")
call parser("endif ")
call parser("patients->patients[patCnt].person_id = e.person_id ")
call parser("patients->patients[patCnt].encntr_id = e.encntr_id ")
call parser("patients->patients[patCnt].priority = 0 ")
call parser("foot report ")
call parser("stat = alterlist(patients->patients, patCnt) ")
call parser("with nocounter go ")
 
if(patCnt > 0)
	set patients->status_data->status = "S"
else
	set patients->status_data->status = "Z"
endif
 
#exit_script
 
end go
 
 
