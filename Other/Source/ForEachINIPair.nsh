!include NullByte.nsh

Var _FEIP_Buffer
Var _FEIP_CharNum
Var _FEIP_Char

; At points I reuse variables as temporary variables:
; {VALUE}       = line contents
; {KEY}         = GetPrivateProfileSection buffer length
; _FEIP_CharNum = first char (in the quoted
; _FEIP_Char    = last char   string check)

!macro ForEachINIPair SECTION KEY VALUE
	!ifdef _ForEachINIPair_Open
		!error "There is already a ForEachINIPair clause open!"
	!endif
	!define _ForEachINIPair_Open

	${CreateHandle} $_FEIP_Buffer
	System::Call "kernel32::GetPrivateProfileSection(t'${SECTION}',i$_FEIP_Buffer,i${NSIS_MAX_STRLEN},t'$LauncherFile')i.s"
	Pop ${KEY}
	IntOp $_FEIP_Char 2 * ${NSIS_CHAR_SIZE}
	IntOp ${KEY} ${KEY} + $_FEIP_Char

	; Just to make sure
	${If} ${KEY} = ${NSIS_MAX_STRLEN}
		MessageBox MB_ICONSTOP "$LauncherFile section ${SECTION} is too long to read!  Please contact Chris Morgan to explain your situation and ask for help."
	${EndIf}

	${ForEachValueInNullSeparatedString} $_FEIP_Buffer ${VALUE}
		; GetPrivateProfileSection guarrantees there will be an = on each line
		StrCpy $_FEIP_CharNum 0
		${Do}
			StrCpy $_FEIP_Char ${VALUE} 1 $_FEIP_CharNum
			${IfThen} $_FEIP_Char == '=' ${|} ${ExitDo} ${|}
			IntOp $_FEIP_CharNum $_FEIP_CharNum + 1
		${Loop}

		StrCpy ${KEY} ${VALUE} $_FEIP_CharNum
		IntOp $_FEIP_CharNum $_FEIP_CharNum + 1
		StrCpy ${VALUE} ${VALUE} "" $_FEIP_CharNum

		; Get rid of quotes on a quoted string
		StrCpy $_FEIP_CharNum ${VALUE} 1
		StrCpy $_FEIP_Char ${VALUE} "" -1
		${If} $_FEIP_CharNum == $_FEIP_Char
			${If} $_FEIP_Char == "'"
			${OrIf} $_FEIP_Char == '"'
				StrCpy ${VALUE} ${VALUE} -2 1
			${EndIf}
		${EndIf}

!macroend


!macro NextINIPair
	!ifndef _ForEachINIPair_Open
		!error "There isn't a ForEachINIPair clause open!"
	!endif
	!undef _ForEachINIPair_Open
	${NextValueInNullSeparatedString}
	${FreeHandle} $_FEIP_Buffer
!macroend

!define ForEachINIPair '!insertmacro ForEachINIPair'
!define NextINIPair '!insertmacro NextINIPair'
