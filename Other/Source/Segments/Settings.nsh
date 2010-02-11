${SegmentFile}

${SegmentPrePrimary}
	; Check for settings
	${IfNot} ${FileExists} $DATADIRECTORY\settings
		${DebugMsg} "$DATADIRECTORY\settings does not exist. Creating it."
		CreateDirectory $DATADIRECTORY\settings
		${If} ${FileExists} $EXEDIR\App\DefaultData\*.*
			${DebugMsg} "Copying default data from $EXEDIR\App\DefaultData to $DATADIRECTORY."
			CopyFiles /SILENT $EXEDIR\App\DefaultData\*.* $DATADIRECTORY
		${EndIf}
	${EndIf}
!macroend
