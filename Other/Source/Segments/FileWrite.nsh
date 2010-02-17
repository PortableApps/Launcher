${SegmentFile}

${SegmentPrePrimary}
	StrCpy $R0 1
	${Do}
		ClearErrors
		${ReadLauncherConfig} $0 FileWrite$R0 Type
		${ReadLauncherConfig} $1 FileWrite$R0 File
		${ReadLauncherConfig} $4 FileWrite$R0 Value
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		${ParseLocations} $1
		${If} $0 == ConfigWrite
			${ReadLauncherConfig} $2 FileWrite$R0 Entry
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $4
			${If} ${FileExists} $1
				${DebugMsg} "Writing configuration to a file with ConfigWrite.$\nFile: $1$\nEntry: `$2`$\nValue: `$4`"
				${ConfigWrite} $1 $2 $4 $R0
			${EndIf}
		${ElseIf} $0 == INI
			${ReadLauncherConfig} $2 FileWrite$R0 Section
			${ReadLauncherConfig} $3 FileWrite$R0 Key
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $4
			${If} ${FileExists} $1
				${DebugMsg} "Writing INI configuration to a file.$\nFile: $1$\nSection: `$2`$\nKey: `$3`$\nValue: `$4`"
				WriteINIStr $1 $2 $3 $4
			${EndIf}
		${EndIf}
		IntOp $R0 $R0 + 1
	${Loop}
!macroend
