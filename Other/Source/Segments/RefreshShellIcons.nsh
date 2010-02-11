${SegmentFile}

Var RefreshShellIcons

${SegmentInit}
	${ReadLauncherConfig} $RefreshShellIcons Launch RefreshShellIcons
!macroend

${SegmentPreExec}
	${If} $RefreshShellIcons == before
	${OrIf} $RefreshShellIcons == both
		${RefreshShellIcons}
	${EndIf}
!macroend

${SegmentPost}
	${If} $RefreshShellIcons == after
	${OrIf} $RefreshShellIcons == both
		${RefreshShellIcons}
	${EndIf}
!macroend
