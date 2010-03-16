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

	${GetBaseName} $EXEFILE $BaseName
	InitPluginsDir
	CopyFiles /SILENT $EXEDIR\App\AppInfo\Launcher\$BaseName.ini $PLUGINSDIR\launcher.ini
	StrCpy $LauncherFile $PLUGINSDIR\launcher.ini

	${GetParameters} $0
	${IfThen} $0				 != "" ${|} ${ReadLauncherConfig} $ProgramExecutable Launch ProgramExecutableWhenParameters	${|}
	ClearErrors
	${IfThen} $ProgramExecutable == "" ${|} ${ReadLauncherConfig} $ProgramExecutable Launch ProgramExecutable				${|}

	${If} ${Errors}
		;=== Launcher file missing or missing crucial details
		StrCpy $MissingFileOrPath $LauncherFile
		MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
		Abort
	${EndIf}
	${ReadLauncherConfig} $0 Launch NoSpacesInPath
	${If} $0 == true
		${WordFind} $EXEDIR ` ` E+1 $R9
		${IfNot} ${Errors} ; errors = space not found, no errors means space in path
			MessageBox MB_OK|MB_ICONSTOP `$(LauncherNoSpaces)`
			Abort
		${EndIf}
	${EndIf}
!macroend

${SegmentPreExecPrimary}
	WriteINIStr $DataDirectory\PortableApps.comLauncherRuntimeData.ini PortableApps.comLauncher PluginsDir $PLUGINSDIR
!macroend

${SegmentUnload}
	Delete $PLUGINSDIR\launcher.ini
	ReadINIStr $0 $DataDirectory\PortableApps.comLauncherRuntimeData.ini PortableApps.comLauncher PluginsDir
	${If}    $0 != ""
	${AndIf} $0 != $PLUGINSDIR
		RMDir /r $0
	${EndIf}
	Delete $DataDirectory\PortableApps.comLauncherRuntimeData.ini
	System::Free 0
!macroend
