${SegmentFile}

; A simple macro to avoid code duplication
!macro _InstanceManagement_QuitIfRunning
	${If} $SecondaryLaunch != true
	${AndIf} ${ProcessExists} $0
		MessageBox MB_OK|MB_ICONSTOP `$(LauncherAlreadyRunning)`
		Quit
	${EndIf}
!macroend

${SegmentInit}
	; Check that what we're going to execute exists (it'd be a pretty poor
	; party if it didn't)
	${IfNot} ${FileExists} $EXEDIR\App\$ProgramExecutable
	${AndIfNot} $UsingJavaExecutable == true
		;=== Program executable not where expected
		StrCpy $MissingFileOrPath App\$ProgramExecutable
		MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
		Quit
	${EndIf}

	; Check if the application (portable or not) is already running
	${ReadLauncherConfig} $0 Launch SingleAppInstance
	${If} $0 != false
	${AndIfNot} $UsingJavaExecutable == true
		${GetFileName} $ProgramExecutable $0
		!insertmacro _InstanceManagement_QuitIfRunning
	${EndIf}

	; Check to make sure the value in [Launch]:CloseEXE isn't running
	ClearErrors
	${ReadLauncherConfig} $0 Launch CloseEXE
	${IfNot} ${Errors}
		!insertmacro _InstanceManagement_QuitIfRunning
	${EndIf}

	; Will we need to wait for the program?  This should only EVER be used if
	; there's no cleanup needed.  In the (very distant) future it might be
	; possible to automatically calculate this value.
	;
	; WaitForProgram may have already been set to false in Mutex; we don't want
	; to mess that up, so check if it's already set.
	${If} $WaitForProgram == ""
		${ReadLauncherConfig} $WaitForProgram Launch WaitForProgram
	${EndIf}
!macroend
