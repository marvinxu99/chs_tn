
set debug_ind = 1 go
execute cov_std_eks_routines go
	
record eksdata(
 ;define data elements set and referenced in templates
 ;first 132 bytes used for logging to eks_module_audit
 1 tqual[4] ;data, evoke, logic and action
   2 temptype = c10
   2 qual[*]
     3 accession_id      = f8
     3 order_id          = f8
     3 encntr_id         = f8
     3 person_id         = f8
     3 task_assay_cd     = f8
     3 clinical_event_id = f8
     3 logging           = vc
     3 template_name     = c30 ;7.9
     3 cnt               = i4
     3 data[*]
       4 misc            = vc
 ; bldMsg structure added for user defined messages to be
 ; used in templates with @MESSAGE substitution values.
 ; paramInd designates if any of the messages are dynamically built parameters.
 1 bldMsg_cnt      = i4
 1 bldMsg_paramInd = i2
 1 bldMsg[*]
   2 name          = vc
   2 text          = vc
) go

set stat = SetBldMsg("FIRST","This is the first message") go
call echo(GetBldMsgText("FIRST")) go
call echo(build2(">>",GetBldMsgText("EVENT_PRSNL"),"<<")) go
call echo(build2(">>",cnvtreal(GetBldMsgText("EVENT_PRSNL")),"<<")) go
