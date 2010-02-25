${SegmentFile}

${SegmentInit}
	ClearErrors
	ReadINIStr $AppID $EXEDIR\App\AppInfo\appinfo.ini Details AppID
	ReadINIStr $AppNamePortable $EXEDIR\App\AppInfo\appinfo.ini Details Name
	${If} ${Errors}
		;=== Launcher file missing or missing crucial details
		StrCpy $AppNamePortable "PortableApps.com Launcher"
		StrCpy $MissingFileOrPath $EXEDIR\App\AppInfo\appinfo.ini
		MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
		Abort
	${EndIf}
	${ReadLauncherConfig} $ProgramExecutable Launch ProgramExecutable

	${If} ${Errors}
		;=== Launcher file missing or missing crucial details
		StrCpy $MissingFileOrPath $EXEDIR\App\AppInfo\launcher.ini
		MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
		Abort
	${EndIf}

	StrCpy $0 $EXEDIR 2
	${If} $0 == "\\"
		MessageBox MB_OK|MB_ICONSTOP "$(LauncherNoUNCSupport)"
		Abort
	${EndIf}
!macroend

${SegmentUnload}
	Delete $DataDirectory\PortableApps.comLauncherRuntimeData.ini
	System::Free 0
!macroend
