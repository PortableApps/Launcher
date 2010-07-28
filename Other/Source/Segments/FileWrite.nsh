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
					${DebugMsg} "Writing configuration to a file with ConfigWriteS.$\r$\nFile: $1$\r$\nEntry: `$2`$\r$\nValue: `$3`"
					${ConfigWriteS} $1 $2 $3 $R9
				${Else}
					${DebugMsg} "Writing configuration to a file with ConfigWrite.$\r$\nFile: $1$\r$\nEntry: `$2`$\r$\nValue: `$3`"
					${ConfigWrite} $1 $2 $3 $R9
				${EndIf}
			${EndIf}
		${ElseIf} $0 == INI
			${ReadLauncherConfig} $2 FileWrite$R0 Section
			${ReadLauncherConfig} $3 FileWrite$R0 Key
			${ReadLauncherConfig} $4 FileWrite$R0 Value
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $4
			${If} ${FileExists} $1
				${DebugMsg} "Writing INI configuration to a file.$\r$\nFile: $1$\r$\nSection: `$2`$\r$\nKey: `$3`$\r$\nValue: `$4`"
				WriteINIStr $1 $2 $3 $4
			${EndIf}
		${ElseIf} $0 == Replace
			${ReadLauncherConfig} $2 FileWrite$R0 Find
			${ReadLauncherConfig} $3 FileWrite$R0 Replace
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $2
			${ParseLocations} $3
			${If} ${FileExists} $1
				${ReadLauncherConfig} $4 FileWrite$R0 CaseSensitive
				${If} $4 == true     ; case sensitive
				${AndIf} $2 S!= $3   ; find != replace?
					StrCpy $5 true
				${ElseIf} $4 != true ; case insensitive
				${AndIf} $2 != $3    ; find != replace?
					StrCpy $5 true
				${Else}              ; find == replace, so Continue
					StrCpy $5 ""
				${EndIf}
				${If} $5 == true ; find != replace (as discovered above)
					${ReadLauncherConfig} $5 FileWrite$R0 Encoding
					${If} $5 == ""
						FileOpen $9 $1 r

						; Using FileReadWord would end up with 0xFEFF as it
						; flips everything back to front like a good little
						; endian parser. (Lilliput and Blefuscu really did
						; cause a lot of trouble!)

						FileReadByte $9 $5
						FileReadByte $9 $6
						IntOp $5 $5 << 8
						IntOp $5 $5 + $6

						${IfThen} $5 = 0xFFFE ${|} StrCpy $5 UTF-16LE ${|}
						FileClose $9
					${EndIf}
					${!getdebug}
					!ifdef DEBUG
						${IfThen} $5 == UTF-16LE ${|} StrCpy $8 "a UTF-16LE" ${|}
						${IfThen} $5 != UTF-16LE ${|} StrCpy $8 "an ANSI" ${|}
						StrCpy $9 ``
						${IfThen} $4 != true ${|} StrCpy $9 in ${|}
					!endif
					${DebugMsg} "Finding and replacing in $8 file (case $9sensitive).$\r$\nFile: $1$\r$\nFind: `$2`$\r$\nReplace: `$3`"
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
			;${Else}
				;${DebugMsg} File didn't exist
			${EndIf}
		${EndIf}
		IntOp $R0 $R0 + 1
	${Loop}
!macroend
