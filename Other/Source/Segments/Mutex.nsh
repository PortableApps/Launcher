${SegmentFile}

Var SecondaryLaunch

${SegmentInit}
	; Check if launcher already running
	System::Call 'kernel32::CreateMutex(i0,i0,t"PortableApps.comLauncher$AppID-$BaseName")?e'
	Pop $0

	; It's already running
	${IfNot} $0 = 0
		; Is a second portable instance disallowed?
		${ReadLauncherConfig} $0 Launch SinglePortableAppInstance
		${If} $0 == true
			${DebugMsg} "Launcher already running and [Launch]:SinglePortableAppInstance=true: aborting."
			Quit
		${EndIf}
		; Set it up for a secondary launch.
		${DebugMsg} "Launcher already running: secondary launch."
		StrCpy $SecondaryLaunch true
		StrCpy $WaitForProgram false
		StrCpy $DisableSplashScreen true
	${EndIf}
!macroend
