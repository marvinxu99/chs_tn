/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_code_value_routines.prg
  Object name:        cov_code_value_routines
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
drop program cov_code_value_routines:dba go
create program cov_code_value_routines:dba


call echo(build2("starting ",trim(cnvtlower(curprog))))

execute cov_std_log_routines
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect

/**********************************************************************************************************************
** Function ENSURE_CODE_VAlUE_EXT(CODE_VALUE,"FIELD_NAME","FIELD_VALUE",1)
** ---------------------------------------------------------------------------------------
** Return TRUE or FALSE if the provided code value extension was updated.
**
**********************************************************************************************************************/
declare ensure_code_value_ext(pCodeValue=f8,pCVEFieldName=vc,pCVEFieldValue=vc,pCVEFieldType=i2(value,1)) = i2 with copy, persist
subroutine ensure_code_value_ext(pCodeValue,pCVEFieldName,pCVEFieldValue,pCVEFieldType)
	call SubroutineLog(build2(
            'start sAddUpdateCodeValueExtension(',pCodeValue,',',pCVEFieldName,',',pCVEFieldValue,',',pCVEFieldType,')'))
                
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
