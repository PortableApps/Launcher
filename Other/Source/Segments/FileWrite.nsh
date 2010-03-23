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
			${ReadLauncherConfig} $4 FileWrite$R0 CaseSensitive
			${If} ${FileExists} $1
				${If} $4 == true
					${DebugMsg} "Writing configuration to a file with ConfigWriteS.$\nFile: $1$\nEntry: `$2`$\nValue: `$3`"
					${ConfigWriteS} $1 $2 $3 $R0
				${Else}
					${DebugMsg} "Writing configuration to a file with ConfigWrite.$\nFile: $1$\nEntry: `$2`$\nValue: `$3`"
					${ConfigWrite} $1 $2 $3 $R0
				${EndIf}
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
				${ReadLauncherConfig} $4 FileWrite$R0 CaseSensitive
				${ReadLauncherConfig} $5 FileWrite$R0 Encoding
				${!getdebug}
				!ifdef DEBUG
					${IfThen} $5 == UTF-16LE ${|} StrCpy $8 "a UTF-16LE" ${|}
					${IfThen} $5 != UTF-16LE ${|} StrCpy $8 "an ANSI" ${|}
					StrCpy $9 ``
					${IfThen} $4 == true ${|} StrCpy $9 in ${|}
				!endif
				${DebugMsg} "Finding and replacing in $8 file (case $9sensitive).$\nFile: $1$\nFind: `$2`$\nReplace: `$3`"
				${If} $5 == UTF-16LE
					${If} $4 == true
						${ReplaceInFileUTF16LECS} $1 $2 $3
					${Else}
						${ReplaceInFileUTF16LE} $1 $2 $3
					${EndIf}
				${Else}
					${If} $4 == true
						${ReplaceInFileCS} $1 $2 $3
					${Else}
						${ReplaceInFile} $1 $2 $3
					${EndIf}
				${EndIf}
			${EndIf}
		${EndIf}
		IntOp $R0 $R0 + 1
	${Loop}
!macroend
