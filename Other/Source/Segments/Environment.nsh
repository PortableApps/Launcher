${SegmentFile}

${SegmentPre}
	${ForEachINIPair} Environment $0 $1
		${ParseLocations} $1

		; Check for a directory variable
		StrCpy $2 $0 1 -1
		${If} $2 == ~
			StrCpy $0 $0 -1 ; Strip the last character from the key
			${DebugMsg} "Setting environment variable $0 to $1"
			${SetEnvironmentVariablesPath} $0 $1
		${Else}
			${DebugMsg} "Setting environment variable $0 to $1"
			${SetEnvironmentVariable} $0 $1
		${EndIf}
	${NextINIPair}
!macroend
