!include ${NSISDIR}\Include\Registry.nsh


!undef registry::MoveKey
!undef registry::RestoreKey

!define registry::MoveKey `!insertmacro PAL::registry::MoveKey`
!define registry::RestoreKey `!insertmacro PAL::registry::RestoreKey`


!macro PAL::registry::MoveKey _PATH_SOURCE _PATH_TARGET _ERR
	; FIX for when trying to move from HKLM to HK(C)U without the required privileges.
	; Was just copying then not deleting, now fail hard.
	!ifndef REGISTRY_NSH_VARIABLE
		!define REGISTRY_NSH_VARIABLE
		Var /GLOBAL REGISTRY_NSH_VARIABLE
	!endif
	registry::_KeyExists /NOUNLOAD `${_PATH_SOURCE}`
	Pop ${_ERR}
	IntCmp ${_ERR} -1 +15
	registry::_Read /NOUNLOAD `${_PATH_SOURCE}` ``
	Pop $REGISTRY_NSH_VARIABLE
	Pop ${_ERR}
	StrCmp ${_ERR} "" 0 +6
	registry::_Write /NOUNLOAD `${_PATH_SOURCE}` `` `` `REG_SZ`
	Pop ${_ERR}
	registry::_DeleteValue /NOUNLOAD `${_PATH_SOURCE}` ``
	Pop ${_ERR}
	IntCmp ${_ERR} -1 +6 '' +4
	registry::_Write /NOUNLOAD `${_PATH_SOURCE}` `` `$REGISTRY_NSH_VARIABLE` `${_ERR}`
	Pop ${_ERR}
	IntCmp ${_ERR} -1 +3
	; End of HKLM->HKU fix
	registry::_MoveKey /NOUNLOAD `${_PATH_SOURCE}` `${_PATH_TARGET}`
	Pop ${_ERR}
!macroend

!macro PAL::registry::RestoreKey _FILE _ERR
	registry::_RestoreKey /NOUNLOAD `${_FILE}`
	Pop ${_ERR}
	${If} ${_ERR} <= -2
		${If} ${FileExists} $SYSDIR\reg.exe
			ExecDos::Exec `"$SYSDIR\reg.exe" import "${_FILE}"` `` ``
			Pop ${_ERR}
		${EndIf}

		${If} ${_ERR} != 0
		${AndIf} ${FileExists} $WINDIR\regedit.exe
			ExecWait `"$WINDIR\regedit.exe" /s "${_FILE}"` ${_ERR}
			${IfThen} ${Errors} ${|} StrCpy ${_ERR} -1 ${|}
		${EndIf}
	${EndIf}
!macroend
