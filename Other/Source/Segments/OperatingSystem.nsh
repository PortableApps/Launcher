${SegmentFile}

!include WinVer.nsh

!macro _OperatingSystem_CheckOS Check Value
	${ReadLauncherConfig} $0 Launch ${Value}
	${Select} $0
		${Case} 2000
			${IfNotThen} ${At${Check}Win2000}   ${|} StrCpy $1 bad-os ${|}
		${Case} XP
			${IfNotThen} ${At${Check}WinXP}     ${|} StrCpy $1 bad-os ${|}
		${Case} 2003
			${IfNotThen} ${At${Check}Win2003}   ${|} StrCpy $1 bad-os ${|}
		${Case} Vista
			${IfNotThen} ${At${Check}WinVista}  ${|} StrCpy $1 bad-os ${|}
		${Case} 2008
			${IfNotThen} ${At${Check}Win2008}   ${|} StrCpy $1 bad-os ${|}
		${Case} 7
			${IfNotThen} ${At${Check}Win7}      ${|} StrCpy $1 bad-os ${|}
		${Case} "2008 R2"
			${IfNotThen} ${At${Check}Win2008R2} ${|} StrCpy $1 bad-os ${|}
		${Case} ""
			; Do nothing for an empty string (probably value not defined)
		${Default}
			MessageBox MB_OK|MB_ICONSTOP "Error: [Launch]:${Value} should be 2000, XP, 2003, Vista, 2008, 7 or 2008 R2, not $1. The launcher will continue to run, but you must fix this."
	${EndSelect}

	${If} $1 == bad-os
		MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST|MB_SETFOREGROUND "$(LauncherIncompatibleOS)"
		Quit
	${EndIf}
!macroend

${Segment.onInit}
	!insertmacro _OperatingSystem_CheckOS Least MinOS
	!insertmacro _OperatingSystem_CheckOS Most MaxOS
!macroend
