${SegmentFile}

!macro _InstanceManagement_AbortIfRunning
	${If} $SecondaryLaunch != true
	${AndIf} ${ProcessExists} $0
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
