; First, declare that this is a segment file.
${SegmentFile}


; Next, restore the saved values before [Environment] is parsed.
${SegmentPre}
	; Read the keys from launcher.ini, not from $AppIDSettings.ini; this will allow the developer to update the loaded variables.
	${ForEachINIPair} PersistentData $0 $1
		ClearErrors
		ReadINIStr $1 $DataDirectory\settings\$AppIDSettings.ini PersistentData $0
		${IfNot} ${Errors}
			${DebugMsg} "Restoring persistent environment variable $0; last value was `$1`"
			System::Call Kernel32::SetEnvironmentVariable(tr0,tr1)
		${EndIf}
	${NextINIPair}
!macroend


; And finally, save the persistent data after [Environment] is processed.
${SegmentPreExecPrimary}
	${ForEachINIPair} PersistentData $0 $1
		${ParseLocations} $1
		${DebugMsg} "Saving persistent environment variable $0 with value `$1`"
		WriteINIStr $DataDirectory\settings\$AppIDSettings.ini PersistentData $0 $1
	${NextINIPair}
!macroend


; Also provide a way for custom code to get and set persistent variables
!macro ReadPersistentData out var
	${DebugMsg} "Reading persistent environment variable ${var} into ${out}"
	ReadINIStr ${out} $DataDirectory\settings\$AppIDSettings.ini PersistentData `${var}`
!macroend
!macro WritePersistentData var value
	Push $R0
	ExpandEnvStrings $R0 `${value}`
	${DebugMsg} "Environment variable expansion on $$R0:$\r$\nBefore: `${value}`$\r$\nAfter: `$R0`"
	${DebugMsg} "Saving persistent environment variable ${var} with value `$R0`"
	WriteINIStr $DataDirectory\settings\$AppIDSettings.ini PersistentData `${var}` $R0
	Pop $R0
!macroend
