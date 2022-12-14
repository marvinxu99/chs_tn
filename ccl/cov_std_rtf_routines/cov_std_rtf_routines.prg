/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       12/02/2021
  Solution:
  Source file name:   cov_std_rtf_routines.prg
  Object name:        cov_std_rtf_routines
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
drop program cov_std_rtf_routines:dba go
create program cov_std_rtf_routines:dba
 
call echo(build2("starting ",trim(cnvtlower(curprog))))

execute cov_std_log_routines
 
declare i=i4 with noconstant(0), protect
declare j=i4 with noconstant(0), protect
declare k=i4 with noconstant(0), protect


declare crowdef = c2000 with noconstant(fillstring(2000," ")), protect, persist
declare crowdata = c32768 with noconstant(fillstring(32768," ")), protect, persist
declare crowprefix = c2000 with noconstant(fillstring(2000," ")), protect, persist
declare ncellpos = i4 with noconstant(0), protect, persist
declare cprot_l = vc with constant("{\*\txfieldstart\txfieldtype0\txfieldflags19}"), protect, persist
declare cprot_r = vc with constant("{\*\txfieldend}"), protect, persist
declare csyscolor = c5 with constant("\cf8 "), protect, persist
declare csysedit = c5 with constant("\cf9 "), protect, persist
 
; function definitions
; --------------------
 
; Generic function to add Rich Text to REPLY structure
declare add_rtf(ctext) = vc with copy, persist
subroutine add_rtf(ctext) 
	set reply->text = concat(trim(reply->text), trim(ctext))
end
 
; Clear spreadsheet row
declare clear_row(nfont, nfontsize) = vc with copy, persist
subroutine clear_row(nfont, nfontsize)
	set crowdef = " "
	set crowdata = " "
	set ncellpos = 0
 
;	set crowdef = build("{\pard\trowd\trgaph30\trleft30")
	set crowdef = build("{\pard\trowd")
	set crowprefix = build("\pard\intbl\plain\f", nfont, "\fs", nfontsize)
end
 
; Add defintion and data for spreadsheet row
declare add_cell(ctext, cstyle, nwidth, nattribs, nlocked) = null with copy, persist
subroutine add_cell(ctext, cstyle, nwidth, nattribs, nlocked)
	set ncellpos = ncellpos + nwidth		; place the cursor position
 
	; parse out the cell attributes
	; four digit number. positions indicate the following
	; 1 - not used
	; 2 - not used
	; 3 - text alignment (0-left, 1-center)
	; 4 - color (0 - 9, see color tables below)
	set cattribs = format(nattribs,"####;P0")
	set nbgcolor = substring(4,1,cattribs)
 
	if (substring(3,1,cattribs) = "0")
		set calign = "\ql"
	else
		set calign = "\qc"
	endif
 
	case (cstyle)
		of "NONE":		set crowdef = build(crowdef, "\clvertalt\clcbpat", nbgcolor, "\cellx", ncellpos)
		of "UNDERLINE": set crowdef = build(crowdef, "\clvertalt\clbrdrb\brdrs\brdrw15\clcbpat", nbgcolor, "\cellx", ncellpos)
		of "OVERLINE":  set crowdef = build(crowdef, "\clvertalt\clbrdrt\brdrs\brdrw15\clcbpat", nbgcolor, "\cellx", ncellpos)
		of "BOX":		set crowdef = build(crowdef, "\clvertalt\clbrdrl\brdrs\brdrw15\clcbpat", nbgcolor, "\clbrdrt\brdrs\brdrw15",
													 "\clbrdrr\brdrs\brdrw15\clbrdrb\brdrs\brdrw15\cellx", ncellpos)
	endcase
 
	if (nlocked = 1)
		set crowdata = concat(trim(crowdata,3), cprot_l)
		set crowdata = concat(trim(crowdata,3), trim(crowprefix,3), calign, " {", trim(ctext), "}")
		set crowdata = concat(trim(crowdata,3), cprot_r)
		set crowdata = concat(trim(crowdata,3), "\cell")
	else
		set crowdata = concat(trim(crowdata,3), trim(crowprefix,3), calign, " {", trim(ctext), "}\cell")
	endif
end
 
; Write the table row to the RTF document
declare write_row(x)= null with copy, persist
subroutine write_row(x) 
	call add_rtf(crowdef)
	call add_rtf(crowdata)
	call add_rtf("\row}")
end
 
; Create a line that goes the full page length
declare write_line(x) = null with copy, persist
subroutine write_line(x)
	call clear_row(0,maxval(x,8))
	call add_cell(" ", "overrline", 12000, 0, 0)
	call write_row(0)
end
 
; Document Header
declare rtf_header(x) = null with copy, persist
subroutine rtf_header(x)
	; define beginning of document and font
	call add_rtf("{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss arial;}{\f9\fmodern Courier New;}}")
 
	; define the color table
	; ----------------------
	call add_rtf("{\colortbl;")											; init color definition
	call add_rtf("\red0\green0\blue0;")									; black
	call add_rtf("\red255\green255\blue255;")							; white
	call add_rtf("\red0\green255\blue0;")								; green
	call add_rtf("\red255\green0\blue0;")								; red
	call add_rtf("\red192\green192\blue192;")							; grey
	call add_rtf("\red215\green215\blue236;")							; pale blue
	call add_rtf("\red0\green128\blue255;")								; medium blue
	call add_rtf("\red0\green0\blue200;")								; dark blue
	call add_rtf("\red0\green128\blue0;")								; dark green
	call add_rtf("}")													; end color definition
end


 
/* Subroutines */
/**********************************************************************************************************************
** Function GET_RTF_DEFINITIONS()
** ---------------------------------------------------------------------------------------
** Return a record structure named RTF_DEFINITIONS with rtf definitions
**********************************************************************************************************************/
declare get_rtf_definitions(null) = vc with persist, copy
subroutine get_rtf_definitions(null)

	free record rtf_definitions
	record rtf_definitions
	(
	1 start_ind					= i2
	1 end_ind					= i2
	1 st
		2 rhead					= vc
		2 rh2r					= c32
		2 rh2b					= c35
		2 rh2bu					= c38
		2 rh2u					= c35
		2 rh2i					= c35
		2 reol					= c5
		2 rtab					= c5
		2 center				= c4
		2 wr					= c22
		2 wb					= c25
		2 wb_end				= c4
		2 wu					= c26
		2 wi					= c25
		2 wbi					= c28
		2 wiu					= c29
		2 wbiu					= c32
		2 wbu					= c29
		2 sr					= c22
		2 sb					= c25
		2 sb_end				= vc
		2 su					= c26
		2 si					= c25
		2 sbi					= c28
		2 siu					= c29
		2 sbiu					= c32
		2 sbu					= c29
		2 rtfeof				= c1
		2 rtf_row_end			= c5
		2 rtf_table_end			= c10
		2 rtf_cell_begin		= c7
		2 rtf_cell_end			= c6
		2 rtf_grid_row_begin	= vc
		2 rtrow_begin			= vc
		2 rtrow_begin_center	= vc
		2 rtrow_brdr_l			= vc
		2 rtrow_brdr_b			= vc
		2 rtrow_brdr_r			= vc
		2 rtrow_brdr_t			= vc
		2 rtcell_brdr			= c87
		2 rtcell_brdr_no_l		= c66
		2 rtcell_brdr_no_r		= c66
		2 rtborder				= vc
		2 rtcell_end			= c6
		2 rtrow_end				= c5
		2 rtend					= c5
		2 rtcel1				= vc
		2 rtcel2				= vc
		2 rtcel3				= vc
		2 rtcel4				= vc
		2 rtcel5				= vc
		2 rtcel6				= vc
		2 rtcel7				= vc
		2 rtcel8				= vc
		2 rtcel9				= vc
	) with persist
	
	set rtf_definitions->st.rhead				= concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}"
													,"{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134")
	set rtf_definitions->st.rh2r				= "\plain \f0 \fs18 \cb2 \pard\sl0 "
	set rtf_definitions->st.rh2b 				= "\plain \f0 \fs24 \b \cb2 \pard\sl0 "
	set rtf_definitions->st.rh2bu				= "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
	set rtf_definitions->st.rh2u				= "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
	set rtf_definitions->st.rh2i				= "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
	set rtf_definitions->st.reol				= "\par "
	set rtf_definitions->st.rtab				= "\tab "
	set rtf_definitions->st.wr		 			= "\plain \f0 \fs20 \cb2 "
	set rtf_definitions->st.center	 			= "\qc"
	set rtf_definitions->st.wb		 			= "\plain \f0 \fs20 \b \cb2 "
	set rtf_definitions->st.wb_end				= "\b0 "
	set rtf_definitions->st.wu		 			= "\plain \f0 \fs18 \ul \cb2 "
	set rtf_definitions->st.wi		 			= "\plain \f0 \fs18 \i \cb2 "
	set rtf_definitions->st.wbi				= "\plain \f0 \fs18 \b \i \cb2 "
	set rtf_definitions->st.wiu				= "\plain \f0 \fs18 \i \ul \cb2 "
	set rtf_definitions->st.wbiu				= "\plain \f0 \fs18 \b \ul \i \cb2 "
	set rtf_definitions->st.wbu				= "\plain \f0 \fs18 \b \ul \cb2 "
	set rtf_definitions->st.sb					= "\plain \f0 \fs12 \b \cb2 "
	set rtf_definitions->st.sr					= "\plain \f0 \fs12 \cb2 "
	set rtf_definitions->st.su					= "\plain \f0 \fs12 \ul \cb2 "
	set rtf_definitions->st.si					= "\plain \f0 \fs12 \i \cb2 "
	set rtf_definitions->st.sbi				= "\plain \f0 \fs12 \b \i \cb2 "
	set rtf_definitions->st.siu				= "\plain \f0 \fs12 \i \ul \cb2 "
	set rtf_definitions->st.sbiu				= "\plain \f0 \fs12 \b \ul \i \cb2 "
	set rtf_definitions->st.sbu				= "\plain \f0 \fs12 \b \ul \cb2 "
	set rtf_definitions->st.rtfeof				= "}"
	set rtf_definitions->st.rtf_row_end		= "\row "
	set rtf_definitions->st.rtf_table_end		= "\row\pard "
	set rtf_definitions->st.rtf_cell_begin		= "\intbl "
	set rtf_definitions->st.rtf_cell_end		= "\cell "
	set rtf_definitions->st.rtrow_begin		= "\trowd \trgaph180\intbl "
	set rtf_definitions->st.rtrow_begin_center	= "\trowd \trqc\trautofit1\intbl "
	set rtf_definitions->st.rtrow_brdr_l		= "\clbrdrl\brdrw15\brdrs "
	set rtf_definitions->st.rtrow_brdr_b		= "\clbrdrb\brdrw15\brdrs "
	set rtf_definitions->st.rtrow_brdr_r		= "\clbrdrr\brdrw15\brdrs "
	set rtf_definitions->st.rtrow_brdr_t		= "\clbrdrt\brdrw15\brdrs "
	set rtf_definitions->st.rtcell_brdr		= "\clbrdrl\brdrw1\brdrs\clbrdrt\brdrw1\brdrs\clbrdrr\brdrw1\brdrs\clbrdrb\brdrw1\brdrs\"
	set rtf_definitions->st.rtcell_brdr_no_l	= "\clbrdrt\brdrw1\brdrs\clbrdrr\brdrw1\brdrs\clbrdrb\brdrw1\brdrs\"
	set rtf_definitions->st.rtcell_brdr_no_r	= "\clbrdrt\brdrw1\brdrs\clbrdrl\brdrw1\brdrs\clbrdrb\brdrw1\brdrs\"
	set rtf_definitions->st.rtborder			= "\brdrw15\brdrs\clbrdrr\brdrw15\brdrs "
	set rtf_definitions->st.rtcell_end			= "\cell "
	set rtf_definitions->st.rtrow_end			= "\row "
	set rtf_definitions->st.rtend				= "\par "
	
	return(cnvtrectojson(rtf_definitions))
	
end



/**********************************************************************************************************************
** Function SET_RTFREPLY(string)
** ---------------------------------------------------------------------------------------
** Adds the defined string to the REPLY->TEXT field.  Also sets the start_ind and end_ind in RTF_DEFINITIONS
** Returns TRUE or FALSE if the REPLY-TEXT was updated
**********************************************************************************************************************/
declare    Set_RTFReply(str=vc) = i2 with persist, copy
subroutine Set_RTFReply(str)

	call SubroutineLog(build2('start Set_RTFReply("',str,'")'))
	
	declare vReturnRTFReply = i2 with noconstant(FALSE)

	;if (not(validate(reply->text)))
	;	call SubroutineLog(build2('->reply->text not defined'))
	;	return (vReturnRTFReply)
	;endif

	if (not(validate(rtf_definitions)))
		set stat = cnvtjsontorec(get_rtf_definitions(null),8)
	endif
	
	if (rtf_definitions->start_ind = 0)
		call SubroutineLog(build2('->starting rtf_definitions->start_ind'))
		set reply->text 			= str
		;set reply_rtf				= str
		set rtf_definitions->start_ind = 1
	elseif ((rtf_definitions->start_ind = 1) and (rtf_definitions->end_ind = 1))
		call SubroutineLog(build2('->finishing rtf_definitions->start_ind'))
		set reply->text 			= reply_rtf
		call echorecord(reply)
	else
		call SubroutineLog(build2('->adding to reply text'))
		set reply->text = concat(reply->text,str)
		;set reply_rtf 	= concat(reply_rtf,str)
	endif
	
	set vReturnRTFReply = TRUE
	
	return (vReturnRTFReply)
end	;Set_RTFReply(str)
 

call echo(build2("finishing ",trim(cnvtlower(curprog))))
 
end go
