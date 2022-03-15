/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_std_ord_routines.prg
  Object name:        cov_std_ord_routines
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
drop program cov_std_ord_routines:dba go
create program cov_std_ord_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect
 
/* Subroutines */
/**********************************************************************************************************************
** Function ()
** ---------------------------------------------------------------------------------------
** Return a record structure named  
**********************************************************************************************************************/

declare SetupOrder(vEncntrID=f8) = i2 with copy, persist
subroutine SetupOrder(vEncntrID)

	declare vReturnSuccess = i2 with noconstant(FALSE), protect
	declare vPersonID = f8 with noconstant(0.0), protect
	declare ordrequest_template = vc with constant("cust_script:ordrequest.json")
	declare ordrequest_line_in = vc with noconstant(" ")
    
    select into "nl:"
    from
    	encounter e
    plan e
    	where e.encntr_id = vEncntrID
    detail
    	vPersonID = e.person_id
    with nocounter
    
	free define rtl3
	define rtl3 is ordrequest_template
 
	select into "nl:"
	from rtl3t r
	detail
		ordrequest_line_in = concat(ordrequest_line_in,r.line)
	with nocounter
 
	free record ordrequest
	set stat = cnvtjsontorec(ordrequest_line_in,2)
 
	if (validate(ordrequest) = FALSE)
		set vReturnSuccess = FALSE
	else
		set ordrequest->personid = vPersonID
		set ordrequest->encntrid = vEncntrID
		set ordrequest->orderlist[1].encntrid = vEncntrID
 
		set vReturnSuccess = TRUE
	endif
	return (vReturnSuccess)
end ;SetupOrder



declare UpdateOrderDetailDtTm(vOEFieldMeaning=vc,vDateTime=dq8) = i2 with copy, persist
subroutine UpdateOrderDetailDtTm(vOEFieldMeaning,vDateTime)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
 
	if (validate(ordrequest) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	endif
 
	for (j=1 to size(ordrequest->orderlist,5))
		for (i=1 to size(ordrequest->orderlist[j].detaillist,5))
			if (ordrequest->orderlist[j].detaillist[i].oefieldmeaning=trim(cnvtupper(vOEFieldMeaning)))
				set ordrequest->orderlist[j].detaillist[i].oefielddttmvalue = cnvtdatetime(vDateTime)
				set ordrequest->orderlist[j].detaillist[i].oefielddisplayvalue = format(vDateTime,";;q")
				set vReturnSuccess = TRUE
			endif
		endfor
	endfor
 
	return (vReturnSuccess)
end ;UpdateOrderDetailDtTm


declare UpdateOrderDetailValueCd(vOEFieldMeaning=vc,vValueCd=f8) = i2 with copy, persist
subroutine UpdateOrderDetailValueCd(vOEFieldMeaning,vValueCd)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
 
	if (validate(ordrequest) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	endif
 
	for (j=1 to size(ordrequest->orderlist,5))
		for (i=1 to size(ordrequest->orderlist[j].detaillist,5))
			if (ordrequest->orderlist[j].detaillist[i].oefieldmeaning=trim(cnvtupper(vOEFieldMeaning)))
				set ordrequest->orderlist[j].detaillist[i].oefieldvalue = vValueCd
				set ordrequest->orderlist[j].detaillist[i].oefielddisplayvalue = uar_get_code_display(vValueCd)
				set vReturnSuccess = TRUE
			endif
		endfor
	endfor
 
	return (vReturnSuccess)
end ;UpdateOrderDetailValueCd



declare AddOrderComment(vComment=vc) = i2 with copy, persist
subroutine AddOrderComment(vComment)
	declare vReturnSuccess = i2 with noconstant(FALSE), protect
 	declare j=i4 with noconstant(0), protect
 	declare i=i4 with noconstant(0), protect
 
	if (validate(ordrequest) = FALSE)
		set vReturnSuccess = FALSE
		return (vReturnSuccess)
	endif
 
	for (j=1 to size(ordrequest->orderlist,5))
		;set i = size(hstrop_ordrequest->orderlist[j].commentlist,5)
		;set i = (i + 1)
		;set stat = alterlist(hstrop_ordrequest->orderlist[j].commentlist,i)
		set i = 1
		set ordrequest->orderlist[j].commentlist[i].commenttype = uar_get_code_by("MEANING",14,"ORD COMMENT")
		set ordrequest->orderlist[j].commentlist[i].commenttext = trim(vComment)
		set vReturnSuccess = TRUE
	endfor
 
	return (vReturnSuccess)
end ;AddOrderComment

declare CallOrderServer(null) = f8 with copy, persist
subroutine CallOrderServer(null)
	declare vNewOrderID = f8 with noconstant(0.0), protect
 
 	free record ordreply
	set stat = tdbexecute(560210,500210,560201,"REC",ordrequest,"REC",ordreply)
 	call echo(build2("stat=",stat))
 	
	for (i=1 to size(ordreply->orderlist,5))
		set vNewOrderID = ordreply->orderlist[i].orderid
	endfor
 
 	call echorecord(ordreply)
 	
	return (vNewOrderID)
end ;CallOrderServer

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
