${SegmentFile}

Var LauncherFile

${Segment.onInit}
	StrCpy $0 $EXEDIR 2
	${If} $0 == "\\"
		; UNC path; may occur in the inner instance with RunAsAdmin
		ClearErrors
		${!getdebug}
		!ifdef DEBUG
			StrCpy $0 $EXEDIR
		!endif
		ReadEnvStr $EXEDIR PAL:PackageDir
		${If} ${Errors}
			MessageBox MB_OK|MB_ICONSTOP "$(LauncherNoUNCSupport)"
			Quit
		${EndIf}
		${DebugMsg} "$$EXEDIR ($0) was a UNC path (due to the UAC plug-in), set $$EXEDIR to %PAL:PackageDir% which is $EXEDIR."
	${Else}
		${SetEnvironmentVariable} PAL:PackageDir $EXEDIR
	${EndIf}

	; These may be needed with RunAsAdmin so they can't go in Init.

	${GetBaseName} $EXEFILE $BaseName
	StrCpy $LauncherFile $EXEDIR\App\AppInfo\Launcher\$BaseName.ini

	ClearErrors
	ReadINIStr $AppID $EXEDIR\App\AppInfo\appinfo.ini Details AppID
	ReadINIStr $AppNamePortable $EXEDIR\App\AppInfo\appinfo.ini Details Name
	${If} ${Errors}
		;=== Launcher file missing or missing crucial details
		StrCpy $AppNamePortable "PortableApps.com Launcher"
		StrCpy $MissingFileOrPath $EXEDIR\App\AppInfo\appinfo.ini
		MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
		Quit
	${EndIf}

	${ReadLauncherConfig} $AppName Launch AppName
	${If} $AppName == ""
		; Calculate the application name - non-portable version
		StrCpy $0 $AppNamePortable "" -9
		${If} $0 == " Portable"
			StrCpy $AppName $AppNamePortable -9
		${Else}
			StrCpy $1 $AppNamePortable "" -18
			${If} $0 == ", Portable Edition"
				StrCpy $AppName $AppNamePortable -18
			${Else}
				StrCpy $AppName $AppNamePortable
			${EndIf}
		${EndIf}
	${EndIf}
!macroend

${SegmentInit}
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
		Quit
	${EndIf}
	${ReadLauncherConfig} $0 Launch NoSpacesInPath
	${If} $0 == true
		${WordFind} $EXEDIR ` ` E+1 $R9
		${IfNot} ${Errors} ; errors = space not found, no errors means space in path
			MessageBox MB_OK|MB_ICONSTOP `$(LauncherNoSpaces)`
			Quit
		${EndIf}
	${EndIf}
!macroend

${SegmentPreExecPrimary}
	WriteINIStr $DataDirectory\PortableApps.comLauncherRuntimeData.ini PortableApps.comLauncher PluginsDir $PLUGINSDIR
!macroend

${SegmentUnload}
	Delete $PLUGINSDIR\launcher.ini
	${If} $SecondaryLaunch != true
		ReadINIStr $0 $DataDirectory\PortableApps.comLauncherRuntimeData.ini PortableApps.comLauncher PluginsDir
		${If}    $0 != ""
		${AndIf} $0 != $PLUGINSDIR
			RMDir /r $0
		${EndIf}
		Delete $DataDirectory\PortableApps.comLauncherRuntimeData.ini
	${EndIf}
	System::Free 0
!macroend
