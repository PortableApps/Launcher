${SegmentFile}

Var UsesContainedTempDirectory
Var TempDirectory

${SegmentInit}
	${ReadLauncherConfig} $UsesContainedTempDirectory Launch AssignContainedTempDirectory
!macroend

${SegmentPre}
	${If} $UsesContainedTempDirectory != false
		${ReadLauncherConfig} $0 Launch WaitForProgram
		${If} $0 == false
			StrCpy $TempDirectory $DataDirectory\Temp
		${Else}
			StrCpy $TempDirectory $TEMP\$AppIDTemp
		${EndIf}
		${DebugMsg} "Creating temporary directory $TempDirectory"
		${If} ${FileExists} $TempDirectory
			RMDir /r $TempDirectory
		${EndIf}
		CreateDirectory $TempDirectory
	${Else}
		StrCpy $TempDirectory $TEMP
	${EndIf}

	${DebugMsg} "Setting %TEMP% to $TempDirectory"
	${SetEnvironmentVariablesPath} TEMP $TempDirectory
!macroend

${SegmentPostPrimary}
	${If} $UsesContainedTempDirectory != false
		${DebugMsg} "Removing contained temporary directory $TempDirectory."
		RMDir /r $TempDirectory
	${EndIf}
!macroend
