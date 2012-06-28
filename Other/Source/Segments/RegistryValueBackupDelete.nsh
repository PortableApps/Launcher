${SegmentFile}

${SegmentPrePrimary}
	${If} $UsesRegistry == true
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $1 RegistryValueBackupDelete $R0
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ValidateRegistryKey} $1
			StrCpy $2 $1 "" -1
			${If} $2 == "\"
				StrCpy $2 $1 -1
				StrCpy $3 "" ; default value
			${Else}
				${GetParent} $1 $2 ; key
				${GetFileName} $1 $3 ; item
			${EndIf}
			${DebugMsg} "Backing up registry value $1 to HKEY_CURRENT_USER\Software\PortableApps.com\Values\$1"
			${registry::MoveValue} $2 $3 HKEY_CURRENT_USER\Software\PortableApps.com\Values $1 $R9
			IntOp $R0 $R0 + 1
		${Loop}
	${EndIf}
!macroend

${SegmentPostPrimary}
	${If} $UsesRegistry == true
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $1 RegistryValueBackupDelete $R0
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ValidateRegistryKey} $1
			StrCpy $2 $1 "" -1
			${If} $2 == "\"
				StrCpy $2 $1 -1
				StrCpy $3 "" ; default value
			${Else}
				${GetParent} $1 $2 ; key
				${GetFileName} $1 $3 ; item
			${EndIf}
			${DebugMsg} "Deleting registry value $1, then restoring from HKEY_CURRENT_USER\Software\PortableApps.com\Values\$2"
			${registry::DeleteValue} $2 $3 $R9
			${registry::MoveValue} HKEY_CURRENT_USER\Software\PortableApps.com\Values $1 $2 $3 $R9
			IntOp $R0 $R0 + 1
		${Loop}
		${If} $R0 > 1
			${registry::DeleteKeyEmpty} HKEY_CURRENT_USER\Software\PortableApps.com\Values $R9
			${registry::DeleteKeyEmpty} HKEY_CURRENT_USER\Software\PortableApps.com $R9
		${EndIf}
	${EndIf}
!macroend
