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
	with nocounter
	
	return (cnvtrectojson(admin_list))

end

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
