drop program cov_test_oru_out go
create program cov_test_oru_out

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "EVENT_ID" = 0 

with OUTDEV, EVENT_ID

 
execute srvrtl
 
declare hMsg001 = i4
declare hReq001 = i4
declare hRep001 = i4
declare hMsg016 = i4
declare tReq016 = i4
declare hCEMsg = i4
declare hCERep = i4
declare tyCERepType = i4
declare hMsgStruct = i4
declare hCqmStruct = i4
declare hTrigStruct = i4
declare hRBList = i4
declare stat      = i4
declare hStatus   = i4
declare cqmStat = i4
declare masterChoice = i2 with public, noconstant(0)
declare masterQuit   = c1 with public, noconstant(fillstring(1,"N"))
declare order_id = f8 with public, noconstant(0.0)
declare beg_dt_tm = f8
declare end_dt_tm = f8
declare dummyVar = c1
declare tot_cnt = i2 with public, noconstant(0)
declare miss_cnt = i2 with public, noconstant(0)
declare powerchart_cd = f8
declare final_cd = f8
declare code_set = i4
declare code_value = f8
declare cdf_meaning = c12
declare flat_disp_line = c130 with public, noconstant(fillstring(130,"-"))
 
set code_set  =  89
set cdf_meaning = "POWERCHART"
execute cpm_get_cd_for_cdf
set powerchart_cd = code_value
 
set code_set = 14202
set cdf_meaning = "FINAL"
execute cpm_get_cd_for_cdf
set final_cd = code_value
 
 
record internal
(1 int_rec[*]
   2 rad_report_id = f8
   2 reference_nbr = vc
   2 cont_refnum = vc
 1 missing[*]
   2 rad_report_id = f8
   2 reference_nbr = vc
 1 reference_nbr = vc
 1 cont_sys_cd = f8
 1 cont_sys_ref_nbr_str = vc
 1 person_id_str = vc
 1 event_id = f8
 1 valid_from_dt_tm = dq8
 1 parent_event_id = f8
 1 result_status_cd = f8
 1 event_cd = f8
)
 
select into "NL:"
    ce.event_id,
    ce.reference_nbr,
    ce.parent_event_id,
    ce.valid_from_dt_tm,
    ce.person_id,
    ce.contributor_system_cd
 
from clinical_event ce
 
plan ce
    where ce.event_id =  $EVENT_ID 

 
      and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
 
detail
    internal->event_id = ce.event_id
    internal->reference_nbr = ce.reference_nbr
    internal->cont_sys_cd = ce.contributor_system_cd
    ;internal->cont_sys_ref_nbr_str = concat(trim(ce.reference_nbr),"~",trim(cnvtstring(ce.contributor_system_cd)))
    internal->parent_event_id = ce.parent_event_id
    internal->valid_from_dt_tm = cnvtdatetime(ce.valid_from_dt_tm)
    internal->person_id_str = cnvtstring(cnvtint(ce.person_id))
    internal->result_status_cd = ce.result_status_cd
    internal->event_cd = ce.event_cd
 
with nocounter
 
/*
select into "NL:"
    ce.event_id,
    ce.reference_nbr,
    ce.parent_event_id,
    ce.valid_from_dt_tm,
    ce.person_id,
    ce.contributor_system_cd
 
from clinical_event ce
 
plan ce
    where ce.event_id =    	 1586880385.00
    						;1586862887.00 ;
    						;1586859620.00 ;COVID19 First Test
    					  	;1586861119.00 ;SARS-CoV-2
      and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
 
detail
    internal->event_id = ce.event_id
   ; internal->reference_nbr = ce.reference_nbr
 ;   internal->cont_sys_cd = ce.contributor_system_cd
  ;  internal->cont_sys_ref_nbr_str =
  ;      concat(trim(ce.reference_nbr),"~",
  ;      trim(cnvtstring(ce.contributor_system_cd)))
    internal->parent_event_id = ce.parent_event_id
    ;internal->parent_event_id =   1586861117.00 ;override parent_Event_id
    internal->valid_from_dt_tm = cnvtdatetime(ce.valid_from_dt_tm)
    internal->person_id_str = cnvtstring(cnvtint(ce.person_id))
    internal->result_status_cd = ce.result_status_cd
    internal->event_cd = ce.event_cd
 
with nocounter
*/
 
call echorecord(internal)
call echo(build("internal->event_cd=",uar_Get_code_display(internal->event_cd)))
 
   if (internal->event_id > 0)
      set hMsg001 = uar_SrvSelectMessage(1215001)
      set hCEMsg = uar_SrvSelectMessage(1000012)
 
      call echo(build("hMsg001=",hMsg001))
      call echo(build("hCEMsg=",hCEMsg))
 
      if ((hMsg001 != 0) and (hCEMsg != 0))
         set hReq001 =  uar_SrvCreateRequest(hMsg001)
         set hRep001 = uar_SrvCreateReply(hMsg001)
         set hCERep = uar_SrvCreateReply(hCEMsg)
 
		 call echo(build("hReq001=",hReq001))
		 call echo(build("hRep001=",hRep001))
		 call echo(build("hCERep=",hCERep))
 
         if ((hReq001 != 0) and (hRep001 != 0) and (hCERep != 0))
            set hMsg016 = uar_SrvSelectMessage(1215016)
 
            call echo(build("hMsg016=",hMsg016))
            if (hMsg016 != 0)
               set tReq016 =  uar_SrvCreateRequestType(hMsg016)
               set stat = uar_SrvReCreateInstance(hReq001,tReq016)
 
               call echo(build("tReq016=",tReq016))
               call echo(build("stat=",stat))
 
               if (stat > 0)
               	  call echo(build("hReq001=",hReq001))
                  set hMsgStruct = uar_SrvGetStruct(hReq001, "message")
 
                  set tyCERepType = uar_SrvCreateTypeFrom(hCERep, 0)
                  call uar_SrvBindItemType(hMsgStruct, "TRIGInfo", tyCERepType)
                  call uar_SrvDestroyType(tyCERepType)
 
                  set hCQMStruct = uar_SrvGetStruct(hMsgStruct, "cqminfo")
 
                  set stat =  uar_SrvSetString(hCQMStruct, "AppName", nullterm("FSIESO"))
                  set stat =  uar_SrvSetString(hCQMStruct, "ContribAlias", nullterm("CLINICAL_EVENT"))
                  set stat =  uar_SrvSetString(hCQMStruct, "ContribRefNum",nullterm(internal->cont_sys_ref_nbr_str))
                  set stat =  uar_SrvSetDate(hCQMStruct, "ContribDtTm", cnvtdatetime(curdate, curtime3))
                  set stat =  uar_SrvSetLong(hCQMStruct, "Priority", 99)
                 ; set stat =  uar_SrvSetString(hCQMStruct, "Class", nullterm("CE"))
                  ;set stat =  uar_SrvSetString(hCQMStruct, "Type", nullterm("GRP"))
                  ;set stat =  uar_SrvSetString(hCQMStruct, "Subtype", nullterm("GRP"))
                  set stat =  uar_SrvSetString(hCQMStruct, "Class", nullterm("CE"))
                  set stat =  uar_SrvSetString(hCQMStruct, "Type", nullterm("DOC"))
                  set stat =  uar_SrvSetString(hCQMStruct, "Subtype", nullterm("DOC"))
               ;   set stat =  uar_SrvSetString(hCQMStruct, "Subtype_detail", nullterm("2"))
                  set stat =  uar_SrvSetLong(hCQMStruct, "Debug_Ind", 0)
                  set stat =  uar_SrvSetLong(hCQMStruct, "Verbosity_Flag", 0)
 
                  set hTrigStruct = uar_SrvAddItem(hMsgStruct, "TRIGInfo")
                  set hRBList = uar_SrvAddItem(hTrigStruct, "rb_list")
 
                  set stat = uar_SrvSetDouble(hRBList, "event_id", internal->event_id)
                  set stat = uar_SrvSetDouble(hRBList, "event_cd", internal->event_cd)
                  set stat = uar_SrvSetDouble(hRBList, "result_status_cd",internal->result_status_cd)
                  set stat = uar_SrvSetDouble(hRBList, "contributor_system_cd", internal->cont_sys_cd)
                  set stat = uar_SrvSetString(hRBList, "reference_nbr", nullterm(internal->reference_nbr))
                  set stat = uar_SrvSetDouble(hRBList, "parent_event_id",internal->parent_event_id)
                  set stat = uar_SrvSetDate(  hRBList, "valid_from_dt_tm",cnvtdatetime(internal->valid_from_dt_tm))
 
				  call echo(build("uar_SrvExecute"))
                  set stat = uar_SrvExecute(hMsg001,hReq001,hRep001)
				  call echo(build("stat=",stat))
                  if (stat = 0)
                     set hStatus = uar_SrvGetStruct(hRep001, "SB")
                     if (hStatus > 0)
                        set stat = uar_SrvGetLong(hStatus, "STATUS_CD")
                        if (stat = 0)
                           call echo("captions->err_cqm_success")
                        else
                           call echo(build("**captions->err_cqm_error", cnvtstring(stat)))
                        endif
                     else
                        call echo("captions->err_status_block")
                     endif
                  else
                     call echo(build("captions->err_srvExecute", cnvtstring(stat)))
                  endif
               else
                  call echo("captions->err_recreate_msg")
               endif
            else
               call echo("captions->err_select_1215016")
            endif
         else
            call echo("captions->err_create_rr_1215001")
         endif
      else
         call echo("captions->err_create_msg_1215001")
      endif
   else
      call echo("captions->err_no_order_info")
   endif
   ;if (hReq001 > 0)
      call uar_SrvDestroyInstance(hReq001)
      set hReq001 = 0
   ;endif
   ;if (hRep001 > 0)
      call uar_SrvDestroyInstance(hRep001)
      set hRep001 = 0
  ; endif
   ;if (hMsg001 > 0)
      call uar_SrvDestroyMessage(hMsg001)
      set hMsg001 = 0
   ;endif
   ;if (tReq016 > 0)
      call uar_SrvDestroyInstance(tReq016)
      set tReq016 = 0
  ; endif
   ;if (hMsg016 > 0)
      call uar_SrvDestroyMessage(hMsg016)
      set hMsg016 = 0
  ; endif
  ; if (hCERep > 0)
      call uar_SrvDestroyInstance(hCERep)
      set hCERep = 0
  ; endif
  ; if (hCEMsg > 0)
      call uar_SrvDestroyMessage(hCEMsg)
      set hCEMsg = 0
   ;endif
 
call echorecord(internal)
end
go
 
