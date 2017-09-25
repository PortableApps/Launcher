!ifndef SHCNE_ASSOCCHANGED
	!define SHCNE_ASSOCCHANGED 0x08000000
!endif
!ifndef SHCNF_IDLIST
	!define SHCNF_IDLIST 0
!endif
${SegmentFile}
${SegmentPreExec}
	${ReadLauncherConfig} $0 Launch RefreshShellIcons
	StrCmp $0 before +2
	StrCmp $0 both 0 +2
	System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (${SHCNE_ASSOCCHANGED}, ${SHCNF_IDLIST}, 0, 0)'
!macroend
${SegmentPost}
	${ReadLauncherConfig} $0 Launch RefreshShellIcons
	StrCmp $0 after +2
	StrCmp $0 both 0 +2
	System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (${SHCNE_ASSOCCHANGED}, ${SHCNF_IDLIST}, 0, 0)'
!macroend
