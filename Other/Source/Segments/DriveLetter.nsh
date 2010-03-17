${SegmentFile}

Var LastDrive
Var CurrentDrive

; NOTE: (Last|Current)Drive refer to $EXEDIR, even with Live mode
; TODO: make it (Last|Current)(App|Data)?Drive

${SegmentInit}
	ReadINIStr $LastDrive $EXEDIR\Data\settings\$AppIDSettings.ini $AppIDSettings LastDrive
	${IfThen} $LastDrive == "" ${|} StrCpy $LastDrive NONE ${|}
	${GetRoot} $EXEDIR $CurrentDrive
	${DebugMsg} "Current drive is $CurrentDrive$\nLast drive is $LastDrive"
!macroend

${SegmentPrePrimary}
	; Past the possible abort stage
	WriteINIStr $DataDirectory\settings\$AppIDSettings.ini $AppIDSettings LastDrive $CurrentDrive
!macroend
