${SegmentFile}

Var UsesContainedTempDirectory
Var TempDirectory
Var TMP ; $TEMP is read-only but may be "wrong", as we see it, after launcher nesting

${Segment.onInit}
	ClearErrors
	ReadEnvStr $TMP PAL:_TEMP
	${If} ${Errors}
		StrCpy $TMP $TEMP
	${Else}
		${SetEnvironmentVariable} TEMP $TMP
		${SetEnvironmentVariable} TMP $TMP
	${EndIf}
!macroend

${SegmentInit}
	${ReadLauncherConfig} $UsesContainedTempDirectory Launch CleanTemp
!macroend

${SegmentPre}
	${If} $UsesContainedTempDirectory != false
		${ReadLauncherConfig} $0 Launch WaitForProgram
		${If} $0 == false
			StrCpy $TempDirectory $DataDirectory\Temp
		${Else}
			StrCpy $TempDirectory $TMP\$AppIDTemp
		${EndIf}
		${DebugMsg} "Creating temporary directory $TempDirectory"
		${If} ${FileExists} $TempDirectory
			RMDir /r $TempDirectory
		${EndIf}
		CreateDirectory $TempDirectory
	${Else}
		StrCpy $TempDirectory $TMP
	${EndIf}

	${DebugMsg} "Setting %TEMP% and %TMP% to $TempDirectory"
	${SetEnvironmentVariablesPath} TEMP $TempDirectory
	${SetEnvironmentVariable} TMP $TempDirectory
	${SetEnvironmentVariable} PAL:_TEMP $TMP
!macroend

${SegmentPostPrimary}
	${If} $UsesContainedTempDirectory != false
		${DebugMsg} "Removing contained temporary directory $TempDirectory."
		RMDir /r $TempDirectory
	${EndIf}
!macroend
