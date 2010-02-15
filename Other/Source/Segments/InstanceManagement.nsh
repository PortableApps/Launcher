${SegmentFile}

!macro _InstanceManagement_AbortIfRunning
	${If} $SecondaryLaunch != true
	${AndIf} ${ProcessExists} $0
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
		MessageBox MB_OK|MB_ICONSTOP `$(LauncherAlreadyRunning)`
		Abort
	${EndIf}
!macroend

${SegmentInit}
	;=== Check that it exists
	${IfNot} ${FileExists} $EXEDIR\App\$ProgramExecutable
	${AndIfNot} $UsingJavaExecutable == true
		;=== Program executable not where expected
		StrCpy $MissingFileOrPath App\$ProgramExecutable
		MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
		Abort
	${EndIf}

	;=== Check if application already running
	${ReadLauncherConfig} $0 Launch SingleAppInstance
	${If} $0 != false
	${AndIfNot} $UsingJavaExecutable == true
		${GetFileName} $ProgramExecutable $0
		!insertmacro _InstanceManagement_AbortIfRunning
	${EndIf}

	ClearErrors
	${ReadLauncherConfig} $0 Launch CloseEXE
	${IfNot} ${Errors}
		!insertmacro _InstanceManagement_AbortIfRunning
	${EndIf}

	;=== Wait for program?
	; This should only EVER be used if there's no cleanup needed.
	; TODO: automatically work something out about this
	${ReadLauncherConfig} $0 Launch WaitForProgram
	${If} $0 == false
		${DebugMsg} "WaitForProgram is set to false: SecondaryLaunch set to true."
		StrCpy $SecondaryLaunch true
	${EndIf}
!macroend
