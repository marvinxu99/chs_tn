/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_std_cv_routines.prg
  Object name:        cov_std_cv_routines
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			initial build
******************************************************************************/
drop program cov_std_cv_routines:dba go
create program cov_std_cv_routines:dba


call echo(build2("starting ",trim(cnvtlower(curprog))))

execute cov_std_log_routines
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect


/**********************************************************************************************************************
** Function ENSURE_CODE_VAlUE(CODE_VALUE,"CDF_MEANING","DISPLAY","DEFINITION","DESCRIPTION")
** ---------------------------------------------------------------------------------------
** Return TRUE or FALSE if the provided code value was updated.
** 
** NOTE: 	The following data fields are not updated with this subroutine and will be maintained when others
**  		are updated. 
**
**			CKI
**			CKI_CONCEPT
**			COLLATION_SEQ
**			BEGIN_EFFECTIVE_DT_TM
**			END_EFFECTIVE_DT_TM
**			ACTIVE_IND
**
record request
(
  1 cd_value_list[*]
    2 action_type_flag      = i2 ;(1:insert) (2:update) (3:delete)
    2 cdf_meaning           = vc
    2 cki                   = vc
    2 code_set              = i4
    2 code_value            = f8
    2 collation_seq         = i4
    2 concept_cki           = vc
    2 definition            = vc
    2 description           = vc
    2 display               = vc
    2 begin_effective_dt_tm = dq8
    2 end_effective_dt_tm   = dq8
    2 active_ind            = i2
    2 display_key           = vc ;003
)
**********************************************************************************************************************/
declare ensure_code_value(pCodeValue=f8,pCodeSet=f8,pCVCDFMeaning=vc,pCVDisplay=vc,pCVDefinition=vc,pCVDescription=vc) 
	= i2 with copy, persist
subroutine ensure_code_value(pCodeValue,pCodeSet,pCVCDFMeaning,pCVDisplay,pCVDefinition,pCVDescription)
	
	call SubroutineLog(build2(
   		'start ensure_code_value_ext('	,pCodeValue
   										,',',pCodeSet
   										,',',pCVCDFMeaning
   										,',',pCVDisplay
   										,',',pCVDefinition
   										,',',pCVDescription
   									,')'))

    record 4171655_request (
			1 cd_value_list[*]
			    2 action_type_flag      = i2 ;(1:insert) (2:update) (3:delete)
			    2 cdf_meaning           = vc
			    2 cki                   = vc
			    2 code_set              = i4
			    2 code_value            = f8
			    2 collation_seq         = i4
			    2 concept_cki           = vc
			    2 definition            = vc
			    2 description           = vc
			    2 display               = vc
			    2 begin_effective_dt_tm = dq8
			    2 end_effective_dt_tm   = dq8
			    2 active_ind            = i2
			    2 display_key           = vc  
	) with protect

    declare CVEReturnValue = i2 with noconstant(FALSE)

	set stat = initrec(4171655_request)
    free record 4171655_reply

	set stat = alterlist(4171655_request->cd_value_list,1)
	set 4171655_request->cd_value_list[1].action_type_flag = 0
	set 4171655_request->cd_value_list[1].code_value = pCodeValue
	set 4171655_request->cd_value_list[1].code_set = pCodeSet
	set 4171655_request->cd_value_list[1].cdf_meaning = pCVCDFMeaning
	set 4171655_request->cd_value_list[1].definition = pCVDefinition
	set 4171655_request->cd_value_list[1].description = pCVDescription
	set 4171655_request->cd_value_list[1].display = pCVDisplay
	set 4171655_request->cd_value_list[1].display_key = cnvtalphanum(pCVDisplay)
	set 4171655_request->cd_value_list[1].active_ind = 1
        
    if ((pCodeValue = 0.0) and (pCodeSet > 0))
		set 4171655_request->cd_value_list[1].action_type_flag = 1
	elseif ((pCodeValue > 0.0))
		set 4171655_request->cd_value_list[1].action_type_flag = 2
		
		select into "nl:" 
		from code_value cv 
		where cv.code_value = pCodeValue 
		detail 
			4171655_request->cd_value_list[1].code_set 					= cv.code_set 
			4171655_request->cd_value_list[1].cki						= cv.cki
			4171655_request->cd_value_list[1].concept_cki				= cv.concept_cki
			4171655_request->cd_value_list[1].begin_effective_dt_tm		= cv.begin_effective_dt_tm
			4171655_request->cd_value_list[1].end_effective_dt_tm		= cv.end_effective_dt_tm
			4171655_request->cd_value_list[1].collation_seq				= cv.collation_seq
			4171655_request->cd_value_list[1].active_ind				= cv.active_ind
		with nocounter
		
		
	else
		set 4171655_request->cd_value_list[1].action_type_flag = 0
	endif
       
       
    set stat = tdbexecute(4170105,4170151,4171655,"REC",4171655_request,"REC",4171655_reply)
    call SubroutineLog("4171655_reply","record")
		
	if (4171655_reply->status_data->status = "S")
		set CVEReturnValue = TRUE
    endif
    
    call SubroutineLog(build2('end ensure_code_value(',CVEReturnValue,")"))
    return (CVEReturnValue)
   
end ;ensure_code_value

/**********************************************************************************************************************
** Function ENSURE_CODE_VAlUE_EXT(CODE_VALUE,"FIELD_NAME","FIELD_VALUE",1)
** ---------------------------------------------------------------------------------------
** Return TRUE or FALSE if the provided code value extension was updated.
**
record request
(
  1 extension_list[*]
    2 action_type_flag = i2 ;(1:insert) (2:update) (3:delete)
    2 code_set         = i4
    2 code_value       = f8
    2 field_name       = c32
    2 field_type       = i4
    2 field_value      = vc
)
**********************************************************************************************************************/
declare ensure_code_value_ext(pCodeValue=f8,pCVEFieldName=vc,pCVEFieldValue=vc,pCVEFieldType=i2(value,1)) = i2 with copy, persist
subroutine ensure_code_value_ext(pCodeValue,pCVEFieldName,pCVEFieldValue,pCVEFieldType)
	
	call SubroutineLog(build2(
            'start ensure_code_value_ext(',pCodeValue,',',pCVEFieldName,',',pCVEFieldValue,',',pCVEFieldType,')'))
                
    declare pCodeSet = i4 with noconstant(0)

    record 4171666_request (
        1 extension_list [*]   
	        2 action_type_flag = i2   
	        2 code_set = i4   
	        2 code_value = f8   
	        2 field_name = vc  
	        2 field_type = i4   
	        2 field_value = vc  
	) with protect

    declare CVEReturnValue = i2 with noconstant(FALSE)

    select into "nl:" from code_value cv where cv.code_value = pCodeValue detail pCodeSet = cv.code_set with nocounter

    if ((pCodeValue > 0.0) and (pCVEFieldName > "") and (pCodeSet > 0))

        set stat = initrec(4171666_request)
        free record 4171666_reply

        set stat = alterlist(4171666_request->extension_list,1)
        set 4171666_request->extension_list[1].action_type_flag = 1
        set 4171666_request->extension_list[1].code_value = pCodeValue
        set 4171666_request->extension_list[1].code_set = pCodeSet
        set 4171666_request->extension_list[1].field_name = pCVEFieldName
        set 4171666_request->extension_list[1].field_value = pCVEFieldValue
        set 4171666_request->extension_list[1].field_type = pCVEFieldType

        set stat = tdbexecute(4170105,4170151,4171666,"REC",4171666_request,"REC",4171666_reply)
		call SubroutineLog("4171666_reply","record")
		
		if (4171666_reply->status_data->status = "S")
        	set CVEReturnValue = TRUE
        endif
    endif
    
    call SubroutineLog(build2('end ensure_code_value_ext(',CVEReturnValue,")"))
    return (CVEReturnValue)
   
end ;ensure_code_value_ext	
 
call echo(build2("finishing ",trim(cnvtlower(curprog))))


end 
go
