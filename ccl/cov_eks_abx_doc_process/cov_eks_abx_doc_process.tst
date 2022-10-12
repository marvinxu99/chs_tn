declare link_encntrid = f8 go
declare link_personid = f8 go
declare link_clinicaleventid = f8 go
set debug_ind = 1 go
/*
;TRUE:person_id=15556719|encntr_id=111688463|clinical_event_id=4453601848|event_id=4453601849| (0.31s)
;TRUE:person_id=16799260|encntr_id=110765501|clinical_event_id=4453870681|event_id=4453870682| (0.57s)
The result of 'set log_misc1 = build2(3654205312.0) go' is  3654205312.00
*/
set link_clinicaleventid =        5105098624.00 go


select into "nl:"
from clinical_event ce
plan ce
	where ce.clinical_event_id = link_clinicaleventid
detail
	link_encntrid	= ce.encntr_id
	link_personid	= ce.person_id
with nocounter go

call echo(build2("link_encntrid=",link_encntrid)) go
call echo(build2("link_personid=",link_personid)) go

execute cov_eks_abx_doc_process ~MINE~,link_clinicaleventid,1 go
/*
execute mp_add_diagnosis 
								^MINE^, 						;"Output to File/Printer/MINE" = "MINE"
								15556726.00, 						;"person_id" = 0.0
								16908168.00, 						;"user_id" = 0.0
								124043747.00, 						;"encntr_id" = 0.
								681274.0, 						;"ppr_code" = 0.0
								13246904.0, 						;"nomenclature_id:" = 0.0
								441.0, 							;"position_cd" = 0.0
								13246904.0, 						;"originating_nomen_id" = 0.0
								1,												;"bedrock_config_ind" = 0
	 	 						89.0, 											;"add_type_cd:" = 0.0
	 	 						674232.0, 										;"classification_cd:" = 0.0
	 	 						0,												;"dupCheckOnly" = 0
	 	 						3305.0											;"confirmation_cd:" = 0.0
	 	 																		;"priority:" = 0
	 	 																		;"trans_nomen_id" = 0.0
	 	 																		;"diagnosis_display" = ""
go	 	 						
*/
/*

	
delete from problem where person_id = 16799260 go
delete from diagnosis where person_id = 16799260 go

 1 PATIENT
  2 ENCNTR_ID=F8   {124043747.0000000000                    }
  2 PERSON_ID=F8   {15556726.0000000000                     }
 1 EVENT
  2 CLINICAL_EVENT_ID=F8   {3646128577.0000000000                   }
  2 EVENT_ID=F8   {3646128578.0000000000                   }
 1 RETVAL= I2   {100}
 1 LOG_MESSAGE=VC62   {|A41.9,Ruled In;TRUE:15556726|124043747|3646128577|3646128578|}
 1 LOG_MISC1=VC0   {}
 1 RETURN_VALUE=VC4   {TRUE}
 1 DEBUG_IND= I2   {0}
 1 ACTIVE_IND= I2   {0}
 1 CONSTANTS
  2 PRSNL_ID=F8   {16908168.0000000000                     }
  2 CLASSIFICATION_CD=F8   {674232.0000000000                       }
  2 CONFIRMED_CD=F8   {3305.0000000000                         }
  2 POSITION_CD=F8   {441.0000000000                          }
  2 PPR_CD=F8   {681274.0000000000                       }
  */
