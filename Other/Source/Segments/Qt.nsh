${SegmentFile}

${SegmentPostPrimary}
	StrCpy $R0 1
	${Do}
		ClearErrors
		${ReadLauncherConfig} $0 QtKeysCleanup $R0
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		StrCpy $1 Software\Trolltech\OrganizationDefaults\$0\$AppDirectory
		DeleteRegKey HKCU $1
		${Do}
			${GetParent} $1 $1
			DeleteRegKey /ifempty HKCU $1
		${LoopUntil} $1 == "Software\Trolltech"

		IntOp $R0 $R0 + 1
	${Loop}
	${IfThen} $R0 > 1 ${|} StrCpy $UsesRegistry true ${|}
!macroend
