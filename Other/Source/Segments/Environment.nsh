${SegmentFile}

${SegmentPre}
	${ForEachINIPair} Environment $0 $1
		${ParseLocations} $1
		${DebugMsg} "Setting environment variable $0 to $1"
		System::Call Kernel32::SetEnvironmentVariable(tr0,tr1)
	${NextINIPair}
!macroend
