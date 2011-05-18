${SegmentFile}

!macro _RunBeforeAfter_Contents Time
	StrCpy $R0 1
	${Do}
		ClearErrors
		${ReadLauncherConfig} $1 Launch Run${Time}$R0
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		${ParseLocations} $1

		; Safety check so paths with spaces work
		StrCpy $R1 $1 1
		${If} $R1 != '"'
			MessageBox MB_ICONEXCLAMATION `[Launch]:Run${Time}$R0 doesn't have the path quoted, which is against the rules (remember to have a line like Run${Time}$R0='"$1"').`
		${EndIf}

		ExecWait $1
		IntOp $R0 $R0 + 1
	${Loop}
!macroend

${SegmentPreExec}
	!insertmacro _RunBeforeAfter_Contents Before
!macroend

${SegmentPostExec}
	!insertmacro _RunBeforeAfter_Contents After
!macroend
