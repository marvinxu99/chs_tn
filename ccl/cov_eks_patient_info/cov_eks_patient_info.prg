/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       
  Solution:           
  Source file name:   cov_eks_patient_info.prg
  Object name:        cov_eks_patient_info
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
drop program cov_eks_patient_info:dba go
create program cov_eks_patient_info:dba

declare tempStartTime = f8 with constant(curtime3)

execute cov_std_eks_routines

call SubroutineLog(build2("starting ",trim(curprog)))

declare log_misc1 = vc
declare log_message = vc

record cov_patient_info
(
	1 patient
	 2 person_id = f8
	1 encounter
	 2 encntr_id = f8
	 2 loc_facility_cd = f8
	 2 facility_tz = i4
	 2 facility_tz_vc = vc
	1 orders
	 2 order_id = f8
	 2 accession_id = f8
	1 messages
	 2 COV_LOCAL_DTTM = vc
	 2 COV_LOCAL_DT = vc
) with protect

set cov_patient_info->encounter.encntr_id			= encntrid
set cov_patient_info->patient.person_id				= personid
set cov_patient_info->orders.order_id 				= orderid
set cov_patient_info->orders.accession_id			= accessionid

select into "nl:"
from
	encounter e
	,time_zone_r tzr
plan e
	where e.encntr_id = cov_patient_info->encounter.encntr_id
join tzr
	where tzr.parent_entity_id = e.loc_facility_cd
	and   tzr.parent_entity_name = "LOCATION"
order by
	 e.encntr_id
	,tzr.updt_dt_tm desc
head e.encntr_id
	cov_patient_info->encounter.facility_tz_vc = tzr.time_zone
	cov_patient_info->encounter.loc_facility_cd = e.loc_facility_cd
with nocounter

if (cov_patient_info->encounter.facility_tz_vc = "")
	set cov_patient_info->encounter.facility_tz_vc = CURTIMEZONE
endif

set cov_patient_info->encounter.facility_tz = datetimezonebyname(cov_patient_info->encounter.facility_tz_vc) 



set cov_patient_info->messages.COV_LOCAL_DTTM = datetimezoneformat(
																		 cnvtdatetime(sysdate)
																		,cov_patient_info->encounter.facility_tz
																		,"dd-mmm-yyyy hh:mm:ss zzz;;q")
set cov_patient_info->messages.COV_LOCAL_DT = datetimezoneformat(	
																		cnvtdatetime(sysdate)
																		,cov_patient_info->encounter.facility_tz
																		,"dd-mmm-yyyy;;q")
  
set stat = SetBldMsg("COV_LOCAL_DTTM",cov_patient_info->messages.COV_LOCAL_DTTM)
set stat = SetBldMsg("COV_LOCAL_DT",cov_patient_info->messages.COV_LOCAL_DT)
  
set log_message = cnvtrectojson(cov_patient_info)


if (log_misc1 > "")
	set eksdata->tqual[tcurindex].qual[curindex].cnt = 1
	set stat = alterlist(eksdata->tqual[tcurindex].qual[curindex].data,1)
	set eksdata->tqual[tcurindex].qual[curindex].data[1].misc = log_misc1
endif

set log_message = concat(log_message, " (",trim(format(maxval(0, (curtime3-tempStartTime))/100.0, "######.##"),3), "s)")
set eksdata->tqual[tcurindex].qual[curindex].logging 	       = log_message


#exit_script
call echorecord(cov_patient_info)


end 
go
