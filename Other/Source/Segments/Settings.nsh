${SegmentFile}

${SegmentPrePrimary}
	; Check for settings
	${IfNot} ${FileExists} $DataDirectory\settings
		${DebugMsg} "$DataDirectory\settings does not exist. Creating it."
		CreateDirectory $DataDirectory\settings
		${If} ${FileExists} $EXEDIR\App\DefaultData\*.*
			${DebugMsg} "Copying default data from $EXEDIR\App\DefaultData to $DataDirectory."
			CopyFiles /SILENT $EXEDIR\App\DefaultData\*.* $DataDirectory
		${EndIf}
	${EndIf}
!macroend
