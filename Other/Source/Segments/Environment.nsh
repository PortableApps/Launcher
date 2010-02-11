${SegmentFile}

${SegmentPre}
	${ForEachINIPair} Environment $0 $1
		${ParseLocations} $1
		;=== Now see if we need to prepend, append or change.
		StrCpy $2 $1 3 ; first three characters
		${If} $2 == "{&}" ; append
			ReadEnvStr $2 $0
			StrCpy $1 $1 "" 3
			StrCpy $1 $2$1
		${Else}
			StrCpy $2 $1 "" -3 ; last three characters
			${If} $2 == "{&}" ; prepend
				ReadEnvStr $2 $0
				StrCpy $1 $1 -3
				StrCpy $1 $1$2
			${EndIf}
		${EndIf}
		${DebugMsg} "Changing environment variable $0 to $1"
		System::Call 'Kernel32::SetEnvironmentVariable(tr0,tr1)'
	${NextINIPair}
!macroend
