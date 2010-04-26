${SegmentFile}

!macro _InstanceManagement_QuitIfRunning
	${If} $SecondaryLaunch != true
	${AndIf} ${ProcessExists} $0
		MessageBox MB_OK|MB_ICONSTOP `$(LauncherAlreadyRunning)`
		Quit
	${EndIf}
!macroend

${SegmentInit}
	;=== Check that it exists
	${IfNot} ${FileExists} $EXEDIR\App\$ProgramExecutable
	${AndIfNot} $UsingJavaExecutable == true
		;=== Program executable not where expected
		StrCpy $MissingFileOrPath App\$ProgramExecutable
		MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
		Quit
	${EndIf}

	;=== Check if application already running
	${ReadLauncherConfig} $0 Launch SingleAppInstance
	${If} $0 != false
	${AndIfNot} $UsingJavaExecutable == true
		${GetFileName} $ProgramExecutable $0
		!insertmacro _InstanceManagement_QuitIfRunning
	${EndIf}

	ClearErrors
	${ReadLauncherConfig} $0 Launch CloseEXE
	${IfNot} ${Errors}
		!insertmacro _InstanceManagement_QuitIfRunning
	${EndIf}

	;=== Wait for program?
	; This should only EVER be used if there's no cleanup needed.
	; TODO: automatically work something out about this
	${ReadLauncherConfig} $WaitForProgram Launch WaitForProgram
!macroend
