!include ${NSISDIR}\Include\Registry.nsh


!undef registry::MoveKey
!define registry::MoveKey `!insertmacro PAL::registry::MoveKey`

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
