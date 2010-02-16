${SegmentFile}

Var UsesContainedTempDirectory

${SegmentInit}
	${ReadLauncherConfig} $UsesContainedTempDirectory Launch AssignContainedTempDirectory
!macroend

${SegmentPre}
	${If} $UsesContainedTempDirectory != false
		${ReadLauncherConfig} $0 Launch WaitForProgram
		${If} $0 == false
			StrCpy $TEMPDIRECTORY $DATADIRECTORY\Temp
		${Else}
			StrCpy $TEMPDIRECTORY $TEMP\$AppIDTemp
		${EndIf}
		${DebugMsg} "Creating temporary directory $TEMPDIRECTORY"
		${If} ${FileExists} $TEMPDIRECTORY
			RMDir /r $TEMPDIRECTORY
		${EndIf}
		CreateDirectory $TEMPDIRECTORY
	${Else}
		StrCpy $TEMPDIRECTORY $TEMP
	${EndIf}

	${DebugMsg} "Setting %TEMP% to $TEMPDIRECTORY"
	${SetEnvironmentVariablesPath} TEMP $TEMPDIRECTORY
!macroend

${SegmentPostPrimary}
	${If} $UsesContainedTempDirectory != false
		${DebugMsg} "Removing contained temporary directory $TEMPDIRECTORY."
		RMDir /r $TEMPDIRECTORY
	${EndIf}
!macroend
