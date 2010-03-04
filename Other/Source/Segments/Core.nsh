${SegmentFile}

Var LauncherFile

${Segment.onInit}
	StrCpy $0 $EXEDIR 2
	${If} $0 == "\\"
		; UNC path; may occur in the inner instance with RunAsAdmin
		ClearErrors
		${!IfDebug}
			StrCpy $0 $EXEDIR
		!endif
		ReadEnvStr $EXEDIR PAL:PackageDir
		${If} ${Errors}
			MessageBox MB_OK|MB_ICONSTOP "$(LauncherNoUNCSupport)"
			Abort
		${EndIf}
		${DebugMsg} "$$EXEDIR ($0) was a UNC path (due to the UAC plug-in), set $$EXEDIR to %PAL:PackageDir% which is $EXEDIR."
	${Else}
		${SetEnvironmentVariable} PAL:PackageDir $EXEDIR
	${EndIf}
!macroend

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

	${GetBaseName} $EXEFILE $0
	StrCpy $LauncherFile $EXEDIR\App\AppInfo\launcher-$0.ini
	${IfNotThen} ${FileExists} $LauncherFile ${|} StrCpy $LauncherFile $EXEDIR\App\AppInfo\launcher.ini ${|}

	${ReadLauncherConfig} $ProgramExecutable Launch ProgramExecutable

	${If} ${Errors}
		;=== Launcher file missing or missing crucial details
		StrCpy $MissingFileOrPath $LauncherFile
		MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
		Abort
	${EndIf}
!macroend

${SegmentUnload}
	Delete $DataDirectory\PortableApps.comLauncherRuntimeData.ini
	System::Free 0
!macroend
