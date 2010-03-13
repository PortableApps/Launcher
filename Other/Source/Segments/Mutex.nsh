${SegmentFile}

Var SecondaryLaunch

${SegmentInit}
	;=== Check if launcher already running
	System::Call 'kernel32::CreateMutex(i0,i0,t"PortableApps.comLauncher$AppID-$BaseName")?e'
	Pop $0
	${IfNot} $0 = 0
		${ReadLauncherConfig} $0 Launch SinglePortableAppInstance
		${If} $0 == true
			${DebugMsg} "Launcher already running and [Launch]->SingleInstance=true: aborting."
			Abort
		${EndIf}
		${DebugMsg} "Launcher already running: secondary launch."
		StrCpy $SecondaryLaunch true
		StrCpy $DisableSplashScreen true
	${EndIf}
!macroend
