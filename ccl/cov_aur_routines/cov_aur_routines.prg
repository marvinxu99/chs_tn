/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_aur_routines.prg
  Object name:        cov_aur_routines
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Additional Required Scripts:
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   12/02/2021  Chad Cummings			initial build
******************************************************************************/
drop program cov_aur_routines:dba go
create program cov_aur_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))

execute cov_std_log_routines
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Subroutines */
/**********************************************************************************************************************
** Function ()
** ---------------------------------------------------------------------------------------
** Return a record structure named  
**********************************************************************************************************************/

declare BuildParams  (null) = i2 with copy, persist
subroutine BuildParams(null)
		call echo("Starting BuildParams.....")
		declare iCnt  = i4  with protect, noconstant(0)
		declare sTemp = vc  with protect
		declare type = vc with protect
	 
		call echo(build("cnt -->",cnt))
		
		set count = 0
		set fcount = 0
	 
		for (fcnt = 1 to output_data->file_cnt)

			set count += 1
			
			if (count = 1)
				set sTemp = concat(		trim(sTemp), "$$",
			                          	trim(cnvtstring(fCnt)), "|",
			                           	trim(output_data->file_qual[fcnt].FacilityID), "|",
			                           	trim(output_data->file_qual[fcnt].Output))
				
			else
				set sTemp = concat(		trim(sTemp), "@@",
			                          	trim(cnvtstring(fCnt)), "|",
			                           	trim(output_data->file_qual[fcnt].FacilityID), "|",
			                           	trim(output_data->file_qual[fcnt].Output))
			
			endif	
			
		endfor
		
		/*
			for (cnt = 1 to reply->facility[fcnt]->event_cnt)
				if (reply->facility[fcnt]->event[cnt].XML_IND > 0)
					set count = count + 1
	
			    	if (count = 1)
				        set sTemp = concat(trim(sTemp), "$$",
			                           concat(trim(cnvtstring(reply->facility[fcnt]->event[cnt].EVENT_ID))
										,"_" ,trim(cnvtstring(reply->facility[fcnt]->event[cnt].LOCATION_CD))
										,"_" ,trim(reply->facility[fcnt]->event[cnt].MDRO_CAT_NAME,4)
										,"_" ,trim(format(reply->facility[fcnt]->event[cnt].COLL_DT_TM,"MMDDYY;;D"),4)),   "|",
										trim(reply->facility[fcnt].FACILITY_DISPLAY),      "|",
			                           trim(reply->facility[fcnt]->event[cnt].name_full_formatted),      "|",
			                           trim(cnvtstring(reply->facility[fcnt]->event[cnt].person_id)),    "|",
			                           trim(cnvtstring(reply->facility[fcnt]->event[cnt].encntr_id)),    "|",
			                           trim(reply->facility[fcnt]->event[cnt].mdro_cat_name),            "|",
			                           trim(cnvtstring(fCnt)), "|",
			                           trim(cnvtstring(reply->facility[fcnt]->event[cnt].BLOODIND)), "|",
			                           trim(reply->facility[fcnt]->event[cnt].xml_string))
			    	else
			        	set sTemp = concat(trim(sTemp), "@@",
			                           concat(trim(cnvtstring(reply->facility[fcnt]->event[cnt].EVENT_ID))
			                            ,"_" ,trim(cnvtstring(reply->facility[fcnt]->event[cnt].LOCATION_CD))
										,"_" ,trim(reply->facility[fcnt]->event[cnt].MDRO_CAT_NAME,4)
										,"_" ,trim(format(reply->facility[fcnt]->event[cnt].COLL_DT_TM,"MMDDYY;;D"),4)),   "|",
										trim(reply->facility[fcnt].FACILITY_DISPLAY),      "|",
			                           trim(reply->facility[fcnt]->event[cnt].name_full_formatted),      "|",
			                           trim(cnvtstring(reply->facility[fcnt]->event[cnt].person_id)),    "|",
			                           trim(cnvtstring(reply->facility[fcnt]->event[cnt].encntr_id)),    "|",
			                           trim(reply->facility[fcnt]->event[cnt].mdro_cat_name),            "|",
			                           trim(cnvtstring(fCnt)), "|",
			                           trim(cnvtstring(reply->facility[fcnt]->event[cnt].BLOODIND)), "|",
			                           trim(reply->facility[fcnt]->event[cnt].xml_string))
					endif
				endif
			endfor
			
		endfor
		*/
		
		set sTemp = concat(ploc, "$$", trim(cnvtstring(fcnt)), "|", trim(cnvtstring(count)),"$$",sFILE1, trim(sTemp))
	  
		set sData = sTemp
		call echo("Ending BuildParams.....")
		call echo(build("sTemp...",sTemp,"...ENDsTemp"))
		return ( 1 )
end ; subroutine BuildParams



declare OpenPage(sFile = vc,sOutdev = vc) = i2 with copy, persist
subroutine OpenPage(sFile,sOutdev)
	
	call echo("calling OpenPage")
	free set replyOut
	record replyOut(
    	1 info_line [*]
      	2 new_line = vc
  	)
  	free set getREPLY
  	record getREPLY (
    	1 INFO_LINE[*]
      		2 new_line                = vc
    	1 data_blob                 = gvc
    	1 data_blob_size            = i4
%i cclsource:status_block.inc
	)
	free set getREQUEST
  	record getREQUEST (
    	1 Module_Dir = vc
    	1 Module_Name = vc
	    1 bAsBlob = i2
	)
	
	set getrequest->module_dir= "cust_script:"
	set getrequest->Module_name = trim(sFile)
	set getrequest->bAsBlob = 1
	execute eks_get_source with replace (REQUEST,getREQUEST),replace(REPLY,getREPLY)
	call echo("after eks_get_source")
	free set putreply
	record putreply (
    	1 INFO_LINE [*]
			2 new_line = vc
%i cclsource:status_block.inc
		)
	free set putREQUEST
	record putREQUEST (
	    	1 source_dir = vc
	    1 source_filename = vc
	    1 nbrlines = i4
	    1 line [*]
			2 lineData = vc
		1 OverFlowPage [*]
			2 ofr_qual [*]
				3 ofr_line = vc
		1 IsBlob = c1
		1 document_size = i4
		1 document = gvc
	  )
	 
	call echo(build("sData ------------>",sData))
	call echorecord(getReply)
	 
	set putRequest->source_dir = sOutdev
	set putRequest->IsBlob = "1"
	set putRequest->document = replace(getReply->data_blob,"sXMLData",sData,0)
	set putRequest->document_size = size(putRequest->document)
	call echorecord(putREQUEST)
	
	execute eks_put_source with replace(Request,putRequest),replace(reply,putReply)
	
	return ( 1 )
end ; subroutine OpenPage()


declare sGetNSHNMedications(null) = vc with copy,persist
subroutine sGetNSHNMedications(null)

	free record medication_list
	record medication_list
	(
		1 cnt = i4
		1 qual[*]
		 2 nhsndrugingredientcode = vc
		 2 nhsndrugingredientname = vc
	)

	select into "nl:"
	from
		cust_au_nhsndrugingredcode an
	plan an
		where an.nhsndrugingredientcodesystem = "ANTIBIOTICS"
	order by
		an.nhsndrugingredientname
	detail
		medication_list->cnt += 1
		stat = alterlist(medication_list->qual,medication_list->cnt)
		medication_list->qual[medication_list->cnt].nhsndrugingredientcode	= an.nhsndrugingredientcode
		medication_list->qual[medication_list->cnt].nhsndrugingredientname = an.nhsndrugingredientname
	with nocounter
	
	return (cnvtrectojson(medication_list))

end


declare sGetNSHNRoutes(null) = vc with copy,persist
subroutine sGetNSHNRoutes(null)

	free record route_list
	record route_list
	(
		1 cnt = i4
		1 qual[*]
		 2 medicationformcode = vc
		 2 medicationroutecode = vc
		 2 nhsnmedicationroutecode = vc
		 2 nhsnmedicationroutename= vc
	)

	select into "nl:"
	from
		cust_au_routeofadminmapping ar
	plan ar
		where ar.nhsnmedicationroutecode != "0"
	order by
		ar.medicationroutecode
	detail
		route_list->cnt += 1
		stat = alterlist(route_list->qual,route_list->cnt)
		route_list->qual[route_list->cnt].medicationformcode		= ar.medicationformcode
		route_list->qual[route_list->cnt].medicationroutecode		= ar.medicationroutecode
		route_list->qual[route_list->cnt].nhsnmedicationroutecode	= ar.nhsnmedicationroutecode
		route_list->qual[route_list->cnt].nhsnmedicationroutename	= ar.nhsnmedicationroutename
	with nocounter
	
	return (cnvtrectojson(route_list))

end


declare sGetNSHNLocations(null) = vc with copy,persist
subroutine sGetNSHNLocations(null)

	free record location_list
	record location_list
	(
		1 cnt = i4
		1 qual[*]
		 2 nhsnlocationtypecode = vc
		 2 nhsnlocationtypename = vc
		 2 wardid = vc
		 2 wardname = vc
		 2 facilityname = vc
		 2 facilityid = vc
	)

	select into "nl:"
	from 
		 cust_au_nhsnloctypecode an
		,cust_au_adtwardmapping aa
		,cust_au_dim_facility adf
	plan an
	join aa
		where aa.nhsnlocationtypecode = an.nhsnlocationtypecode
	join adf
		where adf.facilityid = aa.facilityid
	detail
		location_list->cnt += 1
		stat = alterlist(location_list->qual,location_list->cnt)
		location_list->qual[location_list->cnt].facilityid				= adf.facilityid
		location_list->qual[location_list->cnt].facilityname			= adf.facilityname
		location_list->qual[location_list->cnt].nhsnlocationtypecode	= an.nhsnlocationtypecode
		location_list->qual[location_list->cnt].nhsnlocationtypename	= an.nhsnlocationtypename
		location_list->qual[location_list->cnt].wardid					= aa.wardid
		location_list->qual[location_list->cnt].wardname				= aa.wardname
	with nocounter
	
	return (cnvtrectojson(location_list
	))

end



declare sGetMedAdmins(null) = vc with copy,persist
subroutine sGetMedAdmins(null)

	free record admin_list
	record admin_list
	(
		1 cnt = i4
		1 qual[*]
		 2 medicationadministrationid = f8
		 2 facilityid = vc
		 2 wardid = vc
		 2 patientid = vc
		 2 localdrugingredientname = vc
		 2 nhsndrugingredientcode = vc
		 2 nhsnmedicationroutecode = vc
		 2 nhsnmedicationroutename = vc
		 2 administrationstatuscode = vc
		 2 administrationdatetime = vc
		 2 administrationdate = vc
		 2 wardname = vc
		 2 nhsnlocationtypecode = vc
		 2 nhsnlocationtypename = vc
	)

	select into "nl:"
	from 
		 cust_au_medadmin am
		,cust_au_dim_facility adf
		,cust_au_localdrugingredcode al
		,cust_au_drugingredmapping ad
		,cust_au_routeofadminmapping ar
		,cust_au_nhsndrugingredcode an
		,cust_au_adtwardmapping aa
		,cust_au_nhsnloctypecode an2
	plan am
	join adf
		where adf.facilityid = am.facilityid
	join al
		where al.localdrugingredientcode = am.localdrugingredientcode
	join ad
		where ad.localdrugingredientcode = am.localdrugingredientcode
	join ar
		where ar.medicationformcode = am.medicationformcode
	join an
		where an.nhsndrugingredientcode = ad.nhsndrugingredientcode
	join aa
		where aa.facilityid = am.facilityid
		and   aa.wardid = am.wardid
	join an2
		where an2.nhsnlocationtypecode = aa.nhsnlocationtypecode
	detail
		admin_list->cnt += 1
		stat = alterlist(admin_list->qual,admin_list->cnt)
		admin_list->qual[admin_list->cnt].medicationadministrationid	= am.medicationadministrationid
		admin_list->qual[admin_list->cnt].facilityid					= am.facilityid
		admin_list->qual[admin_list->cnt].wardid						= am.wardid
		admin_list->qual[admin_list->cnt].localdrugingredientname		= al.localdrugingredientname
		admin_list->qual[admin_list->cnt].nhsndrugingredientcode		= ad.nhsndrugingredientcode
		admin_list->qual[admin_list->cnt].nhsnmedicationroutecode		= ar.nhsnmedicationroutecode
		admin_list->qual[admin_list->cnt].nhsnmedicationroutename		= ar.nhsnmedicationroutename
		admin_list->qual[admin_list->cnt].administrationstatuscode		= am.administrationstatuscode
		admin_list->qual[admin_list->cnt].administrationdatetime		= am.administrationdatetime
		admin_list->qual[admin_list->cnt].administrationdate			= am.administrationdate
		admin_list->qual[admin_list->cnt].wardname						= aa.wardname
		admin_list->qual[admin_list->cnt].nhsnlocationtypecode			= an2.nhsnlocationtypecode
		admin_list->qual[admin_list->cnt].nhsnlocationtypename			= an2.nhsnlocationtypename
		admin_list->qual[admin_list->cnt].patientid						= am.patientid
	with nocounter
	
	return (cnvtrectojson(admin_list))

end

declare fillunitsreply(null) = null with copy,persist
SUBROUTINE  fillunitsreply (null )
  CALL log_message ("Begin - Subroutine FillUnitsReply" ,log_level_debug )
  SET sub_start_time = cnvtdatetime (curdate ,curtime3 )
  DECLARE month_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE unit_cnt = i4 WITH protect ,noconstant (0 )
  DECLARE agent_cnt = i4 WITH protect ,noconstant (0 )
  SELECT INTO "nl:"
   admin_month = datetimepart (cnvtdatetime (temp_reply->admin_date[d1.seq ].admin_dt_tm ) ,2 ) ,
   admin_date = cnvtdatetime (cnvtdate (temp_reply->admin_date[d1.seq ].admin_dt_tm ) ,0 ) ,
   admin_unit = temp_reply->admin_date[d1.seq ].units[d2.seq ].unit_cds ,
   admin_person = temp_reply->admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].person_id ,
   admin_med = temp_reply->admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].meds[d4.seq ].
   nhsn_med_cd ,
   admin_route = temp_reply->admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].meds[d4.seq ].routes[
   d5.seq ].nhsn_route_cd
   FROM (dummyt d1 WITH seq = value (size (temp_reply->admin_date ,5 ) ) ),
    (dummyt d2 WITH seq = 1 ),
    (dummyt d3 WITH seq = 1 ),
    (dummyt d4 WITH seq = 1 ),
    (dummyt d5 WITH seq = 1 )
   PLAN (d1
    WHERE maxrec (d2 ,size (temp_reply->admin_date[d1.seq ].units ,5 ) ) )
    JOIN (d2
    WHERE maxrec (d3 ,size (temp_reply->admin_date[d1.seq ].units[d2.seq ].person ,5 ) ) )
    JOIN (d3
    WHERE maxrec (d4 ,size (temp_reply->admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].meds ,5 )
     ) )
    JOIN (d4
    WHERE maxrec (d5 ,size (temp_reply->admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].meds[d4
      .seq ].routes ,5 ) ) )
    JOIN (d5 )
   ORDER BY admin_month ,
    admin_unit ,
    admin_med ,
    admin_person ,
    admin_date ,
    admin_route
   HEAD REPORT
    month_cnt = 0
   HEAD admin_month
    unit_cnt = 0 ,month_cnt = (month_cnt + 1 ) ,
    IF ((mod (month_cnt ,10 ) = 1 ) ) stat = alterlist (reply->months ,(month_cnt + 9 ) )
    ENDIF
    ,reply->months[month_cnt ].month_year = build2 (trim (format (cnvtdatetime (temp_reply->
        admin_date[d1.seq ].admin_dt_tm ) ,"MMMMMMMMM;;d" ) ,3 ) ," " ,cnvtstring (datetimepart (
       cnvtdatetime (temp_reply->admin_date[d1.seq ].admin_dt_tm ) ,1 ) ,4 ) ) ,reply->months[
    month_cnt ].month_dt_tm = cnvtdatetime (temp_reply->admin_date[d1.seq ].admin_dt_tm )
   HEAD admin_unit
    agent_cnt = 0 ,unit_cnt = (unit_cnt + 1 ) ,
    IF ((mod (unit_cnt ,10 ) = 1 ) ) stat = alterlist (reply->months[month_cnt ].locations ,(
      unit_cnt + 9 ) )
    ENDIF
    ,reply->months[month_cnt ].locations[unit_cnt ].location_name = temp_reply->admin_date[d1.seq ].
    units[d2.seq ].unit_disp ,reply->months[month_cnt ].locations[unit_cnt ].location_cd = temp_reply
    ->admin_date[d1.seq ].units[d2.seq ].unit_cds
   HEAD admin_med
    agent_cnt = (agent_cnt + 1 ) ,
    IF ((mod (agent_cnt ,100 ) = 1 ) ) stat = alterlist (reply->months[month_cnt ].locations[
      unit_cnt ].agents ,(agent_cnt + 99 ) )
    ENDIF
    ,reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].agent_name = temp_reply->
    admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].meds[d4.seq ].med_disp ,reply->months[
    month_cnt ].locations[unit_cnt ].agents[agent_cnt ].agent_cd = temp_reply->admin_date[d1.seq ].
    units[d2.seq ].person[d3.seq ].meds[d4.seq ].nhsn_med_cd ,reply->months[month_cnt ].locations[
    unit_cnt ].agents[agent_cnt ].nhsn_med_ind = temp_reply->admin_date[d1.seq ].units[d2.seq ].
    person[d3.seq ].meds[d4.seq ].nhsn_med_ind
   HEAD admin_person
    donothing = 0
   HEAD admin_date
    setroute = 0 ,stop_iv_cnt_ind = false ,stop_respiratory_cnt_ind = false ,stop_digest_cnt_ind =
    false ,stop_im_cnt_ind = false
   HEAD admin_route
    donothing = 0
   DETAIL
    CASE (temp_reply->admin_date[d1.seq ].units[d2.seq ].person[d3.seq ].meds[d4.seq ].routes[d5.seq
    ].route_disp )
     OF iv_route :
      IF ((stop_iv_cnt_ind = 0 ) ) reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].
       iv = (reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].iv + 1 ) ,
       stop_iv_cnt_ind = true
      ENDIF
      ,
      setroute = increment_total
     OF respiratory_route :
      IF ((stop_respiratory_cnt_ind = 0 ) ) reply->months[month_cnt ].locations[unit_cnt ].agents[
       agent_cnt ].respiratory = (reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].
       respiratory + 1 ) ,stop_respiratory_cnt_ind = true
      ENDIF
      ,
      setroute = increment_total
     OF digest_route :
      IF ((stop_digest_cnt_ind = 0 ) ) reply->months[month_cnt ].locations[unit_cnt ].agents[
       agent_cnt ].digestive = (reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].
       digestive + 1 ) ,stop_digest_cnt_ind = true
      ENDIF
      ,
      setroute = increment_total
     OF im_route :
      IF ((stop_im_cnt_ind = 0 ) ) reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].
       im = (reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].im + 1 ) ,
       stop_im_cnt_ind = true
      ENDIF
      ,
      setroute = increment_total
    ENDCASE
   FOOT  admin_route
    donothing = 0
   FOOT  admin_date
    IF ((setroute > 0 ) ) reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].total = (
     reply->months[month_cnt ].locations[unit_cnt ].agents[agent_cnt ].total + 1 )
    ENDIF
   FOOT  admin_person
    donothing = 0
   FOOT  admin_med
    donothing = 0
   FOOT  admin_unit
    stat = alterlist (reply->months[month_cnt ].locations[unit_cnt ].agents ,agent_cnt )
   FOOT  admin_month
    stat = alterlist (reply->months[month_cnt ].locations ,unit_cnt )
   FOOT REPORT
    stat = alterlist (reply->months ,month_cnt )
   WITH nocounter
  ;end select
  SET errorcode = error (errmsg ,0 )
  IF ((errorcode != 0 ) )
   CALL log_message (concat ("Subroutine FillUnitsReply failed: " ,errmsg ) ,log_level_debug )
   GO TO exit_script
  ENDIF
  IF ((debug_ind = 1 ) )
   CALL echorecord (reply )
  ENDIF
  CALL log_message (build ("End - Subroutine FillUnitsReply. Elapsed time in seconds:" ,datetimediff
    (cnvtdatetime (curdate ,curtime3 ) ,sub_start_time ,5 ) ) ,log_level_debug )
 END ;Subroutine

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
