/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-2005 Cerner Corporation                 *
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

        Source file name:       cov_trkfn_tracking_cleanup.prg
        Object name:			cov_trkfn_tracking_cleanup

        Product:
        Product Team:
        HNA Version:
        CCL Version:

        Program purpose:

        Tables read:


        Tables updated:         -

******************************************************************************/


;~DB~************************************************************************
;    *    GENERATED MODIFICATION CONTROL LOG              *
;    ****************************************************************************
;    *                                                                         *
;    *Mod Date       Engineeer          Comment                                *
;    *--- ---------- ------------------ -----------------------------------    *
;     000 18-10-22  							initial release			       *
;     001 03-05-19						Added Tracking Group CD		           *
;	  002 05-31-19						Added FIN for auditing				   *
;~DE~***************************************************************************


;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************

drop program cov_trkfn_tracking_cleanup:dba go
create program cov_trkfn_tracking_cleanup:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 cnt					= i4
	1 qual[*]
	 2 tracking_id 			= f8
	1 group_cnt     		= i2
	1 group_qual[*]
	 2 tracking_group_cd	= f8
	1 encntr_cnt 			= i2
	1 encntr_qual[*]
	 2 encntr_id 			= f8
	 2 fin					= vc

)
if (program_log->run_from_ops != 1)
  call addEmailLog("chad.cummings@covhlth.com")
endif

call writeLog(build2("* START Get Tracking Groups  *******************************"))

select into "nl:"
	cv.code_value
from
	code_value cv
plan cv
	where cv.code_set = 16370
	and   cv.cdf_meaning = "OTHER"
	and   cv.display in(
							 "FSR OB Tracking Group"
							,"LCMC OB Tracking Group"
							,"MMC OB Tracking Group"
							,"PWMC OB Tracking Group"
							,"MHHS OB Tracking Group"
                            ,"CMC OB Tracking Group"
						)
order by
	 cv.display
	,cv.code_value
	,cv.active_dt_tm desc
head report
	t_rec->group_cnt = 0
head cv.code_value
	t_rec->group_cnt = (t_rec->group_cnt + 1)
	stat = alterlist(t_rec->group_qual,t_rec->group_cnt)
	t_rec->group_qual[t_rec->group_cnt].tracking_group_cd = cv.code_value
	call writeLog(build2("-->Adding ",trim(cv.display)," (",trim(cnvtstring(cv.code_value)),")"))
with nocounter

if (t_rec->group_cnt <= 0)
	if (program_log->run_from_ops = 1)
		set reply->status_data.status = "F"
		set reply->status_data.subeventstatus[1].operationname		= "TRACKING_GROUP_CD"
		set reply->status_data.subeventstatus[1].operationstatus	= "Z"
		set reply->status_data.subeventstatus[1].targetobjectname	= "t_rec->group_qual"
		set reply->status_data.subeventstatus[1].targetobjectvalue	= "No Tracking Groups Found"
	endif
	call writeLog(build2("* ERROR NO TRACKING GROUPS FOUND"))
	go to exit_script
endif
call writeLog(build2("* END   Get Tracking Groups  *******************************"))

call writeLog(build2("* START Cleanup  *******************************************"))

free set tiRecs
record tiRecs(
  1 ti[*]
    2 tracking_id = f8
    2 end_tracking_dt_tm = dq8
    2 active_ind = i2
    2 active_status_cd = f8
    2 active_status_dt_tm = dq8
    2 active_status_prsnl_id = f8
)

free set tlRecs
record tlRecs(
  1 tl[*]
    2 tracking_locator_id = f8
    2 end_tracking_dt_tm = dq8
)

free set tcRecs
record tcRecs(
  1 tc[*]
    2 tracking_checkin_id = f8
    2 end_tracking_dt_tm = dq8
)

declare tiCnt = i4 with noconstant(0)
declare tlCnt = i4 with noconstant(0)
declare tcCnt = i4 with noconstant(0)
declare lContinueProcess = i4 with noconstant(1)
declare total_cnt = f8 with noconstant(0.0)

call writeLog(build("Starting cleanup"))

declare FNEncounterQuery = f8 with private, noconstant(curtime3)
while (lContinueProcess = 1)    ;loop through 5000 patients at a time
  select into "nl:"
  ;001 from tracking_item ti, encounter e
  from tracking_item ti, encounter e, tracking_checkin tc ;001
  plan ti
    where ti.encntr_id > 0.0
      and ti.end_tracking_dt_tm = NULL
     ; and expand(i,1,t_rec->group_cnt,ti.tracking_grou
  join e
    where ti.encntr_id = e.encntr_id
      and (e.active_ind = 0 or e.disch_dt_tm<cnvtdatetime(curdate, curtime3))
  ;001 start
  join tc
    where tc.tracking_id = ti.tracking_id
    and   expand(i,1,t_rec->group_cnt,tc.tracking_group_cd,t_rec->group_qual[i].tracking_group_cd)
  ;001 end
  detail
    tiCnt = tiCnt + 1
    if (tiCnt>size(tiRecs->ti,5))
      stat = alterlist(tiRecs->ti, tiCnt + 1000)
    endif

    tiRecs->ti[tiCnt]->tracking_id = ti.tracking_id
    tiRecs->ti[tiCnt]->active_ind = e.active_ind

    if (e.disch_dt_tm < cnvtdatetime(curdate, curtime3) and e.disch_dt_tm != NULL)
      ;discharged encounter - tracking_item.end_tracking_dt_tm not set
      tiRecs->ti[tiCnt]->end_tracking_dt_tm = e.disch_dt_tm
    else
      ;inactive encounter - tracking_item.end_tracking_dt_tm not set
      tiRecs->ti[tiCnt]->end_tracking_dt_tm = e.active_status_dt_tm
    endif

    if (tiRecs->ti[tiCnt]->end_tracking_dt_tm = NULL)
      tiRecs->ti[tiCnt]->end_tracking_dt_tm = cnvtdatetime(curdate, curtime3)
    endif

    if (ti.active_ind = 1)
      if(e.active_ind = 0)
        tiRecs->ti[tiCnt]->active_ind = e.active_ind
        tiRecs->ti[tiCnt]->active_status_cd = e.active_status_cd
        tiRecs->ti[tiCnt]->active_status_dt_tm = e.active_status_dt_tm
        tiRecs->ti[tiCnt]->active_status_prsnl_id = e.active_status_prsnl_id
      else
        tiRecs->ti[tiCnt]->active_ind = ti.active_ind
        tiRecs->ti[tiCnt]->active_status_cd = ti.active_status_cd
        tiRecs->ti[tiCnt]->active_status_dt_tm = ti.active_status_dt_tm
        tiRecs->ti[tiCnt]->active_status_prsnl_id = ti.active_status_prsnl_id
      endif
    else
      tiRecs->ti[tiCnt]->active_ind = ti.active_ind
      tiRecs->ti[tiCnt]->active_status_cd = ti.active_status_cd
      tiRecs->ti[tiCnt]->active_status_dt_tm = ti.active_status_dt_tm
      tiRecs->ti[tiCnt]->active_status_prsnl_id = ti.active_status_prsnl_id
    endif
    
    ;002 start
    t_rec->encntr_cnt = (t_rec->encntr_cnt + 1)
    stat = alterlist(t_rec->encntr_qual,t_rec->encntr_cnt)
    t_rec->encntr_qual[t_rec->encntr_cnt].encntr_id = e.encntr_id
    ;002 end
    
  foot report
    stat = alterlist(tiRecs->ti, tiCnt)
  with nocounter, maxrec = 5000

  set total_cnt = total_cnt + tiCnt

  if (tiCnt > 0)
    update into tracking_item ti, (dummyt d with seq = value(tiCnt)) set
      ti.active_ind = tiRecs->ti[d.seq]->active_ind,
      ti.active_status_cd = tiRecs->ti[d.seq]->active_status_cd,
      ti.active_status_dt_tm = cnvtdatetime(tiRecs->ti[d.seq]->active_status_dt_tm),
      ti.active_status_prsnl_id = tiRecs->ti[d.seq]->active_status_prsnl_id,
      ti.end_tracking_dt_tm = cnvtdatetime(tiRecs->ti[d.seq]->end_tracking_dt_tm),
      ti.end_tracking_id = reqinfo->updt_id,
      ti.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ti.updt_id = reqinfo->updt_id,
      ti.updt_task = reqinfo->updt_task,
      ti.updt_applctx = reqinfo->updt_applctx,
      ti.updt_cnt = ti.updt_cnt + 1,
      ti.cur_tracking_locator_id = 0.0,
      ti.base_loc_cd = 0.0
    plan d
    join ti
    where
       ti.tracking_id = tiRecs->ti[d.seq]->tracking_id
    with nocounter, maxcommit = 500
    commit
    call WriteLog(build("updated ->", tiCnt, "<- encounter records." ))
    set stat = alterlist(tiRecs->ti, 0)
    set tiCnt = 0
  else
    set lContinueProcess = 0      ;no more patients qualified exit while loop
  endif
endwhile
call WriteLog(build("FNEncounterQuery-> ", build2(cnvtint(curtime3 - FNEncounterQuery)), "0 ms"))

set stat = alterlist(tiRecs->ti, 0)
set tiCnt = 0
set lContinueProcess = 1      ;reset for next query

declare FNPersonQuery = f8 with private, noconstant(curtime3)
while (lContinueProcess = 1)
  select into "nl:"
  ;001  from tracking_item ti, person 
  from tracking_item ti, person p, tracking_checkin tc ;001

  plan ti
    where ti.person_id > 0.0
      and ti.end_tracking_dt_tm = NULL
    ;001 start
  join tc
    where tc.tracking_id = ti.tracking_id
    and   expand(i,1,t_rec->group_cnt,tc.tracking_group_cd,t_rec->group_qual[i].tracking_group_cd)
  ;001 end
  join p
    where ti.person_id = p.person_id
      and p.active_ind = 0
  detail
   tiCnt = tiCnt + 1
   if (tiCnt>size(tiRecs->ti,5))
     stat = alterlist(tiRecs->ti, tiCnt + 1000)
   endif
   tiRecs->ti[tiCnt]->tracking_id = ti.tracking_id
   tiRecs->ti[tiCnt]->end_tracking_dt_tm = p.active_status_dt_tm
   tiRecs->ti[tiCnt]->active_status_cd = p.active_status_cd
   tiRecs->ti[tiCnt]->active_status_dt_tm = p.active_status_dt_tm
   tiRecs->ti[tiCnt]->active_status_prsnl_id = p.active_status_prsnl_id
   if (tiRecs->ti[tiCnt]->end_tracking_dt_tm = NULL)
    tiRecs->ti[tiCnt]->end_tracking_dt_tm = cnvtdatetime(curdate, curtime3)
   endif
  foot report
    stat = alterlist(tiRecs->ti, tiCnt)
  with nocounter, maxrec = 5000

  set total_cnt = total_cnt + tiCnt

  if (tiCnt > 0)
    update into tracking_item ti, (dummyt d with seq = value(tiCnt)) set
      ti.active_ind = 0,
      ti.end_tracking_dt_tm = cnvtdatetime(tiRecs->ti[d.seq]->end_tracking_dt_tm),
      ti.end_tracking_id = reqinfo->updt_id,
      ti.active_ind = tiRecs->ti[d.seq]->active_ind,
      ti.active_status_cd = 0,
      ti.active_status_dt_tm = cnvtdatetime(tiRecs->ti[d.seq]->active_status_dt_tm),
      ti.active_status_prsnl_id = tiRecs->ti[d.seq]->active_status_prsnl_id,
      ti.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ti.updt_id = reqinfo->updt_id,
      ti.updt_task = reqinfo->updt_task,
      ti.updt_applctx = reqinfo->updt_applctx,
      ti.updt_cnt = ti.updt_cnt + 1,
      ti.cur_tracking_locator_id = 0.0,
      ti.base_loc_cd = 0.0
    plan d
    join ti
    where
      ti.tracking_id = tiRecs->ti[d.seq]->tracking_id
    with nocounter, maxcommit = 500
    commit
    call WriteLog(build("updated ->", tiCnt, "<- person records." ))
    set stat = alterlist(tiRecs->ti, 0)
    set tiCnt = 0
  else
    set lContinueProcess = 0      ;no more patients qualified exit while loop
  endif
endwhile
call WriteLog(build("FNPersonQuery-> ", build2(cnvtint(curtime3 - FNPersonQuery)), "0 ms"))

set stat = alterlist(tiRecs->ti, 0)
set tiCnt = 0
set lContinueProcess = 1      ;reset for next query

declare FNPrsnlQuery = f8 with private, noconstant(curtime3)
while (lContinueProcess = 1)
  select into "nl:"
  ;002 from tracking_item ti, prsnl p
	from tracking_item ti, prsnl p, tracking_checkin tc ;001

  plan ti
    where ti.prsnl_person_id > 0.0
      and ti.end_tracking_dt_tm = NULL

  ;001 start
  join tc
    where tc.tracking_id = ti.tracking_id
    and   expand(i,1,t_rec->group_cnt,tc.tracking_group_cd,t_rec->group_qual[i].tracking_group_cd)
  ;001 end
  join p
    where ti.prsnl_person_id = p.person_id
      and p.active_ind = 0
  detail
    tiCnt = tiCnt + 1
    if (tiCnt>size(tiRecs->ti,5))
      stat = alterlist(tiRecs->ti, tiCnt + 1000)
    endif
    tiRecs->ti[tiCnt]->tracking_id = ti.tracking_id
    tiRecs->ti[tiCnt]->end_tracking_dt_tm = p.active_status_dt_tm
    tiRecs->ti[tiCnt]->active_status_cd = p.active_status_cd
    tiRecs->ti[tiCnt]->active_status_dt_tm = p.active_status_dt_tm
    tiRecs->ti[tiCnt]->active_status_prsnl_id = p.active_status_prsnl_id
    if (tiRecs->ti[tiCnt]->end_tracking_dt_tm = NULL)
      tiRecs->ti[tiCnt]->end_tracking_dt_tm = cnvtdatetime(curdate, curtime3)
    endif
  foot report
    stat = alterlist(tiRecs->ti, tiCnt)
  with nocounter, maxrec = 5000

  set total_cnt = total_cnt + tiCnt

  if (tiCnt > 0)
    update into tracking_item ti, (dummyt d with seq = value(tiCnt)) set
      ti.end_tracking_dt_tm = cnvtdatetime(tiRecs->ti[d.seq]->end_tracking_dt_tm),
      ti.end_tracking_id = reqinfo->updt_id,
      ti.active_status_cd = 0,
      ti.active_status_dt_tm = cnvtdatetime(tiRecs->ti[d.seq]->active_status_dt_tm),
      ti.active_status_prsnl_id = tiRecs->ti[d.seq]->active_status_prsnl_id,
      ti.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ti.updt_id = reqinfo->updt_id,
      ti.updt_task = reqinfo->updt_task,
      ti.updt_applctx = reqinfo->updt_applctx,
      ti.updt_cnt = ti.updt_cnt + 1,
      ti.cur_tracking_locator_id = 0.0,
      ti.base_loc_cd = 0.0
    plan d
    join ti
    where
      ti.tracking_id = tiRecs->ti[d.seq]->tracking_id
    with nocounter, maxcommit = 500
    commit
    call WriteLog(build("updated ->", tiCnt, "<- prsnl records." ))
    set stat = alterlist(tiRecs->ti, 0)
    set tiCnt = 0
  else
    set lContinueProcess = 0      ;no more patients qualified exit while loop
  endif
endwhile
call WriteLog(build("FNPrsnlQuery-> ", build2(cnvtint(curtime3 - FNPrsnlQuery)), "0 ms"))

set lContinueProcess = 1      ;reset for next query

declare FNTrackingLocatorQuery = f8 with private, noconstant(curtime3)
while (lContinueProcess = 1)
  select into "nl:"
  ;001 from tracking_item ti, tracking_locator tl
  from tracking_item ti, tracking_locator tl, tracking_checkin tc ;001
  plan tl
    where tl.depart_dt_tm = cnvtdatetime("31-DEC-2100")
  join ti
    where ti.tracking_id = tl.tracking_id
      and ((ti.end_tracking_dt_tm < cnvtdatetime(curdate, curtime3)) or ti.active_ind = 0)
      and ti.tracking_id+0 > 0.0
  ;001 start
  join tc
    where tc.tracking_id = ti.tracking_id
    and   expand(i,1,t_rec->group_cnt,tc.tracking_group_cd,t_rec->group_qual[i].tracking_group_cd)
  ;001 end
  detail
    tlCnt = tlCnt + 1
    if (tlCnt>size(tlRecs->tl,5))
      stat = alterlist(tlRecs->tl, tlCnt + 1000)
    endif
    tlRecs->tl[tlCnt]->tracking_locator_id = tl.tracking_locator_id
    if (ti.end_tracking_dt_tm = null)
      tlRecs->tl[tlCnt]->end_tracking_dt_tm = cnvtdatetime('01-JAN-1900')
    else
      tlRecs->tl[tlCnt]->end_tracking_dt_tm = ti.end_tracking_dt_tm
    endif
    if ((tlRecs->tl[tlCnt]->end_tracking_dt_tm = NULL) or (tlRecs->tl[tlCnt]->end_tracking_dt_tm = cnvtdatetime("31-DEC-2100")))
      tlRecs->tl[tlCnt]->end_tracking_dt_tm = cnvtdatetime(curdate, curtime3)
    endif
  foot report
    stat = alterlist(tlRecs->tl, tlCnt)
  with nocounter, maxrec = 5000

  set total_cnt = total_cnt + tlCnt

  if (tlCnt > 0)
    update into tracking_locator tl, (dummyt d with seq = value(tlCnt)) set
      tl.depart_dt_tm = cnvtdatetime(tlRecs->tl[d.seq]->end_tracking_dt_tm),
      tl.depart_id = reqinfo->updt_id,
      tl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      tl.updt_id = reqinfo->updt_id,
      tl.updt_task = reqinfo->updt_task,
      tl.updt_applctx = reqinfo->updt_applctx,
      tl.updt_cnt = tl.updt_cnt + 1
    plan d
    join tl
    where
      tl.tracking_locator_id = tlRecs->tl[d.seq]->tracking_locator_id
    with nocounter, maxcommit = 500
    commit
    call WriteLog(build("updated ->", tlCnt, "<- tracking_locator records." ))
    set stat = alterlist(tlRecs->tl, 0)
    set tlCnt = 0
  else
    set lContinueProcess = 0       ;no more patients qualified exit while loop
  endif
endwhile
call WriteLog(build("FNTrackingLocatorQuery-> ", build2(cnvtint(curtime3 - FNTrackingLocatorQuery)), "0 ms"))

set lContinueProcess = 1      ;reset for next query

declare FNTrackingCheckinQuery = f8 with private, noconstant(curtime3)
while (lContinueProcess = 1)
  select into "nl:"
  from tracking_item ti, tracking_checkin tc
  plan tc
    ;where tc.tracking_group_cd in (select cv.code_value from code_value cv where cv.code_set = 16370)
    where expand(i,1,t_rec->group_cnt,tc.tracking_group_cd,t_rec->group_qual[i].tracking_group_cd) ;001
      and tc.checkout_dt_tm = cnvtdatetime('31-DEC-2100')
  join ti
    where ti.tracking_id = tc.tracking_id
      and ((ti.end_tracking_dt_tm < cnvtdatetime(curdate, curtime3)) or ti.active_ind = 0)
      and ti.tracking_id+0 > 0.0
  detail
    tcCnt = tcCnt + 1
    if (tcCnt>size(tcRecs->tc,5))
      stat = alterlist(tcRecs->tc, tcCnt + 1000)
    endif
    tcRecs->tc[tcCnt]->tracking_checkin_id = tc.tracking_checkin_id
    if (ti.end_tracking_dt_tm = null)
      tcRecs->tc[tcCnt]->end_tracking_dt_tm = cnvtdatetime('01-JAN-1900')
    else
      tcRecs->tc[tcCnt]->end_tracking_dt_tm = ti.end_tracking_dt_tm
    endif
    if ((tcRecs->tc[tcCnt]->end_tracking_dt_tm = NULL) or (tcRecs->tc[tcCnt]->end_tracking_dt_tm = cnvtdatetime('31-DEC-2100')))
      tcRecs->tc[tcCnt]->end_tracking_dt_tm = cnvtdatetime(curdate, curtime3)
    endif
  foot report
    stat = alterlist(tcRecs->tc, tcCnt)
  with nocounter, maxrec = 5000

  set total_cnt = total_cnt + tcCnt

  if (tcCnt > 0)
    update into tracking_checkin tc, (dummyt d with seq = value(tcCnt)) set
      tc.checkout_dt_tm = cnvtdatetime(tcRecs->tc[d.seq]->end_tracking_dt_tm),
      tc.checkout_id = reqinfo->updt_id,
      tc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      tc.updt_id = reqinfo->updt_id,
      tc.updt_task = reqinfo->updt_task,
      tc.updt_applctx = reqinfo->updt_applctx,
      tc.updt_cnt = tc.updt_cnt + 1
    plan d
    join tc
    where
      tc.tracking_checkin_id = tcRecs->tc[d.seq]->tracking_checkin_id
    with nocounter, maxcommit = 500
    commit
    call WriteLog(build("updated ->", tcCnt, "<- tracking_checkin records." ))
    set stat = alterlist(tcRecs->tc, 0)
    set tcCnt = 0
  else
    set lContinueProcess = 0       ;no more patients qualified exit while loop
  endif
endwhile
call WriteLog(build("FNTrackingCheckinQuery-> ", build2(cnvtint(curtime3 - FNTrackingCheckinQuery)), "0 ms"))

call WriteLog(build("Total Records Updated:", total_cnt))

call writeLog(build2("* END   Finisehd Cleanup  **********************************"))


call writeLog(build2("* START Finding FIN ****************************************"))
if (t_rec->encntr_cnt > 0)
	select into "nl:"
	from
		encntr_alias ea
		,(dummyt d1 with seq=t_rec->encntr_cnt)
	plan d1
	join ea
		where ea.encntr_id = t_rec->encntr_qual[d1.seq].encntr_id
		and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
		and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
		and   ea.active_ind = 1
	order by
		ea.encntr_id
	head ea.encntr_id
		t_rec->encntr_qual[d1.seq].fin = ea.alias
		call writeLog(build2("-->Found FIN:",trim(ea.alias)))
	with nocounter
endif
call writeLog(build2("* END   Finding FIN ****************************************"))

if (total_cnt = 0)
	if (program_log->run_from_ops = 1)
		set reply->status_data.status = "Z"
		set reply->status_data.subeventstatus[1].operationname		= "TRACKING_ITEM"
		set reply->status_data.subeventstatus[1].operationstatus	= "Z"
		set reply->status_data.subeventstatus[1].targetobjectname	= ""
		set reply->status_data.subeventstatus[1].targetobjectvalue	= "No Tracking Items Found"
		;remove all emails
		set stat = alterlist(program_log->email->qual,0)
	endif
	call writeLog(build2("*NO TRACKING ITEMS FOUND"))
else
	if (program_log->run_from_ops = 1)
		set reply->status_data.status = "S"
		set reply->status_data.subeventstatus[1].operationname		= "TRACKING_ITEM"
		set reply->status_data.subeventstatus[1].operationstatus	= "S"
		set reply->status_data.subeventstatus[1].targetobjectname	= "Records Updated"
		set reply->status_data.subeventstatus[1].targetobjectvalue	= concat(trim(cnvtstring(total_cnt))," records updated")
	endif	
endif

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
