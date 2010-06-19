${SegmentFile}

Var DisableSplashScreen

${SegmentInit}
	${If} $DisableSplashScreen != true
		${ReadUserOverrideConfig} $DisableSplashScreen DisableSplashScreen
		${ReadLauncherConfig} $0 Launch SplashTime
		${IfNotThen} ${FileExists} $EXEDIR\App\AppInfo\Launcher\splash.jpg ${|} StrCpy $DisableSplashScreen true ${|}
		${CheckForPlatformSplashDisable} $DisableSplashScreen
		${If} $DisableSplashScreen != true
			${IfThen} $0 = 0 ${|} StrCpy $0 1500 ${|}
			newadvsplash::show /NOUNLOAD $0 0 0 -1 /L $EXEDIR\App\AppInfo\Launcher\splash.jpg
		${EndIf}
	${EndIf}
!macroend

${SegmentPreExecPrimary}
	${ReadLauncherConfig} $DisableSplashScreen Launch LaunchAppAfterSplash
	${If} $DisableSplashScreen == true
		newadvsplash::stop /WAIT
	${EndIf}
!macroend

${SegmentUnload}
	${If} $DisableSplashScreen != true
		newadvsplash::stop /WAIT
	${EndIf}
!macroend
