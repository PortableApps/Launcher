/***************************************************
*** Notes ***

Valid wildcards:
  ? matches a single character
  * matches any number of characters

File extensions may not containing wildcards.  If a wildcard extension is
needed, end the path name with * and leave the extension out.
Example: $INSTDIR\met*

Paths may not contain wildcards in the parent directory.
Example: $INSTDIR\met*\file.txt is invalid.

${ForEachFile/Directory} sets the error flag if no matching file/directory
could be found.

***************************************************/
Var _FEP_FindHandle
Var _FEP_Directory
Var _FEP_FoundName
Var _FEP_Extension

!macro ForEachPath TYPE FOUND_DIR FOUND_NAME SEARCH_PATH
	!if ${TYPE} != FILES && ${TYPE} != DIRECTORIES
		!error "Please use ForEachFile or ForEachDirectory rather than using ForEachPath directly."
	!endif
	!ifdef _ForEachPath_Open
		!error "There is already a ForEachPath clause open!"
	!endif
	!define _ForEachPath_Open
	${IfNotThen} ${WildCardExists} "${SEARCH_PATH}" ${|} ${SetWildCardFlag} ${|}
	${GetFileExt} "${SEARCH_PATH}" $_FEP_Extension
	${GetParent} "${SEARCH_PATH}" $_FEP_Directory
	StrCpy ${FOUND_NAME} ''
	${Do}
		ClearErrors
		${IfNot} ${WildCardFlag}
			${If} ${FileExists} "${SEARCH_PATH}"
				${GetFileName} "${SEARCH_PATH}" $_FEP_FoundName
			${Else}
				SetErrors
			${EndIf}
		${Else}
			${If} $_FEP_FindHandle == ''
				FindFirst $_FEP_FindHandle $_FEP_FoundName "${SEARCH_PATH}"
			${Else}
				FindNext $_FEP_FindHandle $_FEP_FoundName
			${EndIf}
		${EndIf}
		StrCpy ${FOUND_DIR} $_FEP_Directory
		${If} ${Errors}
			${IfThen} ${FOUND_NAME} == '' ${|} SetErrors ${|}
			${ExitDo}
		${EndIf}
!if ${TYPE} == FILES
		${IfNot} ${FileExists} ${FOUND_DIR}\$_FEP_FoundName\*.*
!else if ${TYPE} == DIRECTORIES
		${If} ${FileExists} ${FOUND_DIR}\$_FEP_FoundName\*.*
		${AndIf} $_FEP_FoundName != .
		${AndIf} $_FEP_FoundName != ..
!endif
			Push $0
			${GetFileExt} $_FEP_FoundName $0
			${If} $_FEP_Extension == ''
			${AndIf} $0 != BackupBy$AppID
			${OrIf} $_FEP_Extension == $0
				Pop $0
				StrCpy ${FOUND_NAME} $_FEP_FoundName
!macroend

!macro NextPath
	!ifndef _ForEachPath_Open
		!error "There isn't a ForEachPath clause open!"
	!endif
	!undef _ForEachPath_Open
			${Else}
				Pop $0
			${EndIf}
		${EndIf}
	${LoopWhile} ${WildCardFlag}
	${If} $_FEP_FindHandle <> 0
		FindClose $_FEP_FindHandle
		StrCpy $_FEP_FindHandle ''
	${EndIf}
!macroend

!define ForEachFile '!insertmacro ForEachPath FILES'
!define NextFile '!insertmacro NextPath'

!define ForEachDirectory '!insertmacro ForEachPath DIRECTORIES'
!define NextDirectory '!insertmacro NextPath'

!define WildCardFlag '$_FEP_FindHandle != 0'
!define SetWildCardFlag 'StrCpy $_FEP_FindHandle 0'

!macro _WildCardExists _a _b _t _f
	!verbose push
	!insertmacro _LOGICLIB_TEMP
	Push `${_b}`
	${CallArtificialFunction} LLWildCardExists_
	Pop $_LOGICLIB_TEMP
	IntCmpU $_LOGICLIB_TEMP 1 `${_t}` `${_f}`
	!verbose pop
!macroend
!define WildCardExists `"" WildCardExists`

!macro LLWildCardExists_
	Exch $0
	Push $1
	Push $2
		StrCpy $1 0
	_WildCard_Loop:
		IntOp $1 $1 - 1
		StrCpy $2 $0 1 $1
		StrCmpS $2 ? _WildCard_Found
		StrCmpS $2 * _WildCard_Found
		StrCmpS $2 '\' _WildCard_NotFound
		StrCmpS $2 '' 0 _WildCard_Loop
	_WildCard_NotFound:
		StrCpy $1 0
		Goto +2
	_WildCard_Found:
		StrCpy $1 1
	Pop $2
	Exch
	Pop $0
	Exch $1
!macroend
