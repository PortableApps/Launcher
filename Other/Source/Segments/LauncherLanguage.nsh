${SegmentFile}

${Segment.onInit}
	ReadEnvStr $0 PortableApps.comLocaleID
	${Switch} $0
		${Case} 1033 ; English
		${Case} 1036 ; French
		${Case} 1031 ; German
		${Case} 1040 ; Italian
		${Case} 1041 ; Japanese
		${Case} 2052 ; SimpChinese
			${DebugMsg} "Setting language code to $0"
			StrCpy $LANGUAGE $0
			${Break}
	${EndSwitch}
!macroend
