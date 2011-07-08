${SegmentFile}

${SegmentPre}
	${ForEachINIPair} Environment $0 $1
		; Very simple, just parse the environment in the value and set it.
		${ParseLocations} $1
		${DebugMsg} "Setting environment variable $0 to $1"
		${SetEnvironmentVariable} $0 $1
	${NextINIPair}
!macroend
