subroutine COV_REMINDER_ADD_A ( MSG_TYPE, PATIENT, RECIPIENT, SUBJECT, MSG, MSG_PRIORITY )
/*******************************************************************************
The following lines of code handle template parameters that have List box 
control types and /or hidden values.  The record structure name should be the
parameter name with "list" tacked to the end of it.  The variable "orig_param" 
is the variable that the program EKS_T_PARSE_LIST will parse.Set it equal to the
parameter being parsed.  Then execute EKS_T_PARSE_LIST and it will fill out the 
record structure below.  Use this as a template for any of these type parameters 
after the initial saving of the template.;Parse PARAM1 parameter into value and 
display values  
record PARAM1list
(
    1 cnt = i4 ; the number of values parsed out of param1
    1 qual[*]
        2 value = vc  ; the value to be used for comparison in the template
        2 display = vc ; the display value for comparison value
)
set orig_param = PARAM1
execute eks_t_parse_list
               with replace(reply, PARAM1list)
free set orig_param
****************************************************************************/
set retval = 0
   set stat = 0
   set retVal = 0
   set tname = "COV_REMINDER_ADD_A"
   
;Allow for the following parameters to be dynamically defined
%i cclsource:eks_chkDynamicParam.inc
if (eksdata->bldMsg_paramInd)

   call eks_chkDynamicParam("MSG_TYPE", MSG_TYPE, 1, 0)
   call eks_chkDynamicParam("PATIENT", PATIENT, 0, 0)
   call eks_chkDynamicParam("RECIPIENT", RECIPIENT, 1, 1)
   call eks_chkDynamicParam("SUBJECT", SUBJECT, 0, 0)
   call eks_chkDynamicParam("MSG", MSG, 0, 0)
   call eks_chkDynamicParam("MSG_PRIORITY", MSG_PRIORITY, 0, 0)

endif
;End of dynamic parameters

   execute cov_eks_t_inbox 

   return(retval)
end


