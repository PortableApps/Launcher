${SegmentFile}

Var LastDrive
Var CurrentDrive

; NOTE: (Last|Current)Drive refer to $EXEDIR, even with Live mode
; TODO: make it (Last|Current)(App|Data)?Drive

${SegmentInit}
	ReadINIStr $LastDrive $EXEDIR\Data\settings\$AppIDSettings.ini $AppIDSettings LastDrive
	${GetRoot} $EXEDIR $CurrentDrive
!macroend

${SegmentPrePrimary}
	${If} $LastDrive != ""
	${AndIf} $LastDrive != $CurrentDrive
		;=== Backslash {{{1
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $1 FileDriveLetterUpdate Backslash$R0
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $1
			${If} ${FileExists} $1
				${DebugMsg} "Updating drive letter from $LastDrive to $CurrentDrive in $1; using backslashes"
				${ReplaceInFile} $1 $LastDrive\ "$CurrentDrive\"
			${EndIf}
			IntOp $R0 $R0 + 1
		${Loop}

		;=== Forwardslash {{{1
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $1 FileDriveLetterUpdate Forwardslash$R0
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $1
			${If} ${FileExists} $1
				${DebugMsg} "Updating drive letter from $LastDrive to $CurrentDrive in $1; using forward slashes"
				${ReplaceInFile} $1 $LastDrive/ $CurrentDrive/
			${EndIf}
			IntOp $R0 $R0 + 1
		${Loop}
	${EndIf}

	;=== Save drive letter {{{1
	WriteINIStr $DATADIRECTORY\settings\$AppIDSettings.ini $AppIDSettings LastDrive $CurrentDrive
!macroend
