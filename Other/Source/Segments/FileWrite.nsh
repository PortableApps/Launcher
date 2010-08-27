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
			${If} ${FileExists} $1
				${ParseLocations} $3
				ClearErrors
				${ReadLauncherConfig} $4 FileWrite$R0 CaseSensitive
				${If} $4 == true
					${DebugMsg} "Writing configuration to a file with ConfigWriteS.$\r$\nFile: $1$\r$\nEntry: `$2`$\r$\nValue: `$3`"
					${ConfigWriteS} $1 $2 $3 $R9
				${ElseIf} $4 == false
				${OrIf} ${Errors}
					${DebugMsg} "Writing configuration to a file with ConfigWrite.$\r$\nFile: $1$\r$\nEntry: `$2`$\r$\nValue: `$3`"
					${ConfigWrite} $1 $2 $3 $R9
				${Else}
					${InvalidValueError} [FileWrite$R0]:CaseSensitive $4
				${EndIf}
			${EndIf}
		${ElseIf} $0 == INI
			${ReadLauncherConfig} $2 FileWrite$R0 Section
			${ReadLauncherConfig} $3 FileWrite$R0 Key
			${ReadLauncherConfig} $4 FileWrite$R0 Value
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${If} ${FileExists} $1
				${ParseLocations} $4
				${DebugMsg} "Writing INI configuration to a file.$\r$\nFile: $1$\r$\nSection: `$2`$\r$\nKey: `$3`$\r$\nValue: `$4`"
				WriteINIStr $1 $2 $3 $4
			${EndIf}
!ifdef XML_ENABLED
		${ElseIf} $0 == "XML attribute"
			${ReadLauncherConfig} $2 FileWrite$R0 XPath
			${ReadLauncherConfig} $3 FileWrite$R0 Attribute
			${ReadLauncherConfig} $4 FileWrite$R0 Value
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${If} ${FileExists} $1
				${ParseLocations} $4
				${DebugMsg} "Writing configuration to a file with XMLWriteAttrib.$\r$\nFile: $1$\r$\nXPath: `$2`$\r$\nAttrib: `$3`$\r$\nValue: `$4`"
				${XMLWriteAttrib} $1 $2 $3 $4
				${IfThen} ${Errors} ${|} ${DebugMsg} "XMLWriteAttrib XPath error" ${|}
			${EndIf}
		${ElseIf} $0 == "XML text"
			${ReadLauncherConfig} $2 FileWrite$R0 XPath
			${ReadLauncherConfig} $3 FileWrite$R0 Value
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${If} ${FileExists} $1
				${ParseLocations} $3
				${DebugMsg} "Writing configuration to a file with XMLWriteText.$\r$\nFile: $1$\r$\nXPath: `$2`$\r$\n$\r$\nValue: `$3`"
				${XMLWriteText} $1 $2 $3
				${IfThen} ${Errors} ${|} ${DebugMsg} "XMLWriteText XPath error" ${|}
			${EndIf}
!else
		${ElseIf} $0 == "XML attribute"
		${OrIf} $0 == "XML text"
			!insertmacro XML_WarnNotActivated [FileWrite$R0]
!endif
		${ElseIf} $0 == Replace
			${ReadLauncherConfig} $2 FileWrite$R0 Find
			${ReadLauncherConfig} $3 FileWrite$R0 Replace
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $2
			${ParseLocations} $3

			ClearErrors
			${ReadLauncherConfig} $4 FileWrite$R0 CaseSensitive

			StrCpy $5 skip ; $5 = "Do we need to replace?"
			${If} $4 == true   ; case sensitive
				${If} $2 S!= $3 ; find != replace?
					StrCpy $5 replace
				${EndIf}
			${Else} ; case sensitive
				${If} $4 != false     ; "false" is valid
				${AndIfNot} ${Errors} ; not set is valid
					${InvalidValueError} [FileWrite$R0]:CaseSensitive $4
				${EndIf}
				${If} $2 != $3 ; find != replace?
					StrCpy $5 replace
				${EndIf}
			${EndIf}

			StrCpy $7 $1 ; copy for input to avoid potential confusion/mess
			${ForEachFile} $1 $R4 $7
				StrCpy $1 $1\$R4
				${If} $5 == replace ; not skip, find != replace (as discovered above)
					ClearErrors
					${ReadLauncherConfig} $5 FileWrite$R0 Encoding
					${If} ${Errors}
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
					${ElseIf} $5 != UTF-16LE
					${AndIf} $5 != ANSI
						${InvalidValueError} [FileWrite$R0]:Encoding $5
					${EndIf}
					${!getdebug}
					!ifdef DEBUG
						${IfThen} $5 == UTF-16LE ${|} StrCpy $R8 "a UTF-16LE" ${|}
						${IfThen} $5 != UTF-16LE ${|} StrCpy $R8 "an ANSI" ${|}
						StrCpy $R9 ``
						${IfThen} $4 != true ${|} StrCpy $R9 in ${|}
					!endif
					${DebugMsg} "Finding and replacing in $R8 file (case $R9sensitive).$\r$\nFile: $1$\r$\nFind: `$2`$\r$\nReplace: `$3`"
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
			${NextDirectory}
			;${If} ${Errors}
				;${DebugMsg} File didn't exist
			;${EndIf}
		${Else}
			${InvalidValueError} [FileWrite$R0]:Type $0
		${EndIf}
		IntOp $R0 $R0 + 1
	${Loop}
!macroend
