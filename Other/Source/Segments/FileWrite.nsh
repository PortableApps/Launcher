${SegmentFile}

${SegmentPrePrimary}
	StrCpy $R0 1
	${Do}
		ClearErrors
		${ReadLauncherConfig} $0 FileWrite$R0 Type
		${ReadLauncherConfig} $1 FileWrite$R0 File
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		${ParseLocations} $1
		${If} $0 == ConfigWrite
			${ReadLauncherConfig} $2 FileWrite$R0 Entry
			${ReadLauncherConfig} $3 FileWrite$R0 Value
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $3
			${If} ${FileExists} $1
				${DebugMsg} "Writing configuration to a file with ConfigWrite.$\nFile: $1$\nEntry: `$2`$\nValue: `$3`"
				${ConfigWrite} $1 $2 $3 $R0
			${EndIf}
		${ElseIf} $0 == INI
			${ReadLauncherConfig} $2 FileWrite$R0 Section
			${ReadLauncherConfig} $3 FileWrite$R0 Key
			${ReadLauncherConfig} $4 FileWrite$R0 Value
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $4
			${If} ${FileExists} $1
				${DebugMsg} "Writing INI configuration to a file.$\nFile: $1$\nSection: `$2`$\nKey: `$3`$\nValue: `$4`"
				WriteINIStr $1 $2 $3 $4
			${EndIf}
		${ElseIf} $0 == Replace
			${ReadLauncherConfig} $2 FileWrite$R0 Find
			${ReadLauncherConfig} $3 FileWrite$R0 Replace
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $2
			${ParseLocations} $3
			${If} $2 != $3
			${AndIf} ${FileExists} $1
				${DebugMsg} "Finding and replacing in a file.$\nFile: $1$\nFind: `$2`$\nReplace: `$3`"
				${ReplaceInFile} $1 $2 $3
			${EndIf}
		${EndIf}
		IntOp $R0 $R0 + 1
	${Loop}
!macroend
