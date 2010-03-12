${SegmentFile}

!include Registry.nsh

Var UsesRegistry

${SegmentInit}
	${ReadLauncherConfig} $UsesRegistry Activate Registry
	${DebugMsg} "Registry sections enabled."
!macroend

${SegmentUnload}
	${IfThen} $UsesRegistry == true ${|} ${registry::Unload} ${|}
!macroend

!define ValidateRegistryKey `!insertmacro ValidateRegistryKeyCall`
!macro ValidateRegistryKeyCall KEY
	Push `${KEY}`
	${CallArtificialFunction} ValidateRegistryKey_
	Pop `${KEY}`
!macroend
!macro ValidateRegistryKey_
	; HKEY_CLASSES_ROOT  --> HKCU\Software\Classes
	; HKEY_CURRENT_USER  --> HKCU
	; HKEY_LOCAL_MACHINE --> HKLM
	; HKCR               --> HKCU\Software\Classes
	Exch $0
	Push $1
	StrCpy $1 $0 17
	${If} $1 == HKEY_CLASSES_ROOT
		StrCpy $0 $0 "" 17
		StrCpy $0 HKCU\Software\Classes$0
	${ElseIf} $1 == HKEY_CURRENT_USER
		StrCpy $0 $0 "" 17
		StrCpy $0 HKCU$0
	${Else}
		StrCpy $1 $0 18
		${If} $1 == HKEY_LOCAL_MACHINE
			StrCpy $0 $0 "" 17
			StrCpy $0 HKLM$0
		${Else}
			StrCpy $1 $0 4
			${If} $1 == HKCU
				StrCpy $0 $0 "" 4
				StrCpy $0 HKCU\Software\Classes$0
			${Else}
				MessageBox MB_OK|MB_ICONSTOP `Note to portable application developer: registry hive in key "$0" is bad, should start with HKCR, HKCU or HKLM. Please fix this. (The launcher will continue running.)`
			${EndIf}
		${EndIf}
	${EndIf}
	Pop $1
	Exch $0
!macroend
