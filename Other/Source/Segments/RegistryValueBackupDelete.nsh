${SegmentFile}

${SegmentPrePrimary}
	${If} $UsesRegistry == true
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $1 RegistryValueBackupDelete $R0
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${GetParent} $1 $2
			${GetFilename} $1 $3
			${DebugMsg} "Backing up registry value $1 to HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Values\$1"
			${registry::MoveValue} $2 $3 HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Values $1 $R9
			IntOp $R0 $R0 + 1
		${Loop}
	${EndIf}
!macroend

${SegmentPostPrimary}
	${If} $UsesRegistry == true
		; RegistryValueBackupDelete
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $1 RegistryValueBackupDelete $R0
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${GetParent} $1 $2
			${GetFilename} $1 $3
			${DebugMsg} "Deleting registry value $1, then restoring from HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Values\$2"
			${registry::DeleteValue} $2 $3 $R9
			${registry::MoveValue} HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Values $1 $2 $3 $R9
			IntOp $R0 $R0 + 1
		${Loop}
	${EndIf}
!macroend
