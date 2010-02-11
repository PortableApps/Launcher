${SegmentFile}

${SegmentPrePrimary}
	; ConfigWrite
	StrCpy $R0 1
	${Do}
		ClearErrors
		${ReadLauncherConfig} $1 FileWriteConfigWrite $R0File
		${ReadLauncherConfig} $2 FileWriteConfigWrite $R0Entry
		${ReadLauncherConfig} $3 FileWriteConfigWrite $R0Value
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		${ParseLocations} $1
		${ParseLocations} $3
		${If} ${FileExists} $1
			${DebugMsg} "Writing configuration to a file with ConfigWrite.$\nFile: $1$\nEntry: `$2`$\nValue: `$3`"
			${ConfigWrite} $1 $2 $3 $R0
		${EndIf}
		IntOp $R0 $R0 + 1
	${Loop}

	; WriteINIStr
	StrCpy $R0 1
	${Do}
		ClearErrors
		${ReadLauncherConfig} $1 FileWriteINI $R0File
		${ReadLauncherConfig} $2 FileWriteINI $R0Section
		${ReadLauncherConfig} $3 FileWriteINI $R0Key
		${ReadLauncherConfig} $4 FileWriteINI $R0Value
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		${ParseLocations} $1
		${ParseLocations} $4
		${If} ${FileExists} $1
			${DebugMsg} "Writing INI configuration to a file.$\nFile: $1$\nSection: `$2`$\nKey: `$3`$\nValue: `$4`"
			WriteINIStr $1 $2 $3 $4
		${EndIf}
		IntOp $R0 $R0 + 1
	${Loop}
!macroend
