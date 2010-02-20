${SegmentFile}

Var LastDrive
Var CurrentDrive

; NOTE: (Last|Current)Drive refer to $EXEDIR, even with Live mode
; TODO: make it (Last|Current)(App|Data)?Drive

${SegmentInit}
	ReadINIStr $LastDrive $EXEDIR\Data\settings\$AppIDSettings.ini $AppIDSettings LastDrive
	${IfThen} $LastDrive == "" ${|} StrCpy $LastDrive NONE ${|}
	${GetRoot} $EXEDIR $CurrentDrive
!macroend

${SegmentPrePrimary}
	; Past the possible abort stage
	WriteINIStr $DATADIRECTORY\settings\$AppIDSettings.ini $AppIDSettings LastDrive $CurrentDrive
!macroend
