${SegmentFile}

Var ExecString

${SegmentPre}
	${DebugMsg} "Constructing execution string"

	; If ProgramExecutable was java.exe or javaw.exe and
	; [Activate]:Java=require, we want to run Java from elsewhere (portable
	; CommonFiles or a local installation), not something in the current
	; directory tree.
	${If} $UsingJavaExecutable != true
		StrCpy $ExecString `"$AppDirectory\$ProgramExecutable"`
	${Else}
		StrCpy $ExecString `"$JavaDirectory\bin\$ProgramExecutable"`
	${EndIf}
	${DebugMsg} "Execution string is $ExecString"

	; Get command line arguments from the launcher INI file.
	ClearErrors
	${ReadLauncherConfig} $0 Launch CommandLineArguments
	${IfNot} ${Errors}
		${DebugMsg} "There are default command line arguments ($0).  Adding them to execution string after parsing."
		${ParseLocations} $0
		StrCpy $ExecString "$ExecString $0"
	${EndIf}

	; Get any user-passed command line arguments
	${GetParameters} $0
	${If} ${UAC_IsInnerInstance}
		; UAC plugin prepends "/UAC:ABCDE /NCRC " (for arbitrary hex
		; ABCDE) to the command line arguments

		; First get rid of /UAC...
		${WordFind} $0 " " "E+1" $1
		StrCpy $2 $1 5
		${If} $2 == "/UAC:"
			; The hexadecimal value doesn't have a fixed length,
			; so we get the length of the entire parameter plus
			; a space character, and trim that length from the
			; beginning of the command-line parameters.
			StrLen $1 $1
			IntOp $1 $1 + 1
			StrCpy $0 $0 "" $1
		${EndIf}
		; ...then of /NCRC. With /UAC removed, we don't need to search
		; for this.
		StrCpy $1 $0 5
		${If} $1 == "/NCRC"
			StrCpy $0 $0 "" 6
		${EndIf}
	${EndIf}
	${If} $0 != ""
		${DebugMsg} "Parameters were passed ($0).  Adding them to execution string."
		ClearErrors
		; If there is a single file name as an argument and we will change the
		; working directory, it's helpful to make relative paths absolute.
		${ReadLauncherConfig} $1 Launch WorkingDirectory
		${If} ${Errors}
			StrCpy $ExecString "$ExecString $0"
		${Else}
			; Make relative paths absolute so they work post-SetOutPath
			; TODO: examine string bit by bit rather than all at once
			ClearErrors
			GetFullPathName $1 $0
			${If} ${Errors}
				StrCpy $ExecString "$ExecString $0"
			${Else}
				${DebugMsg} "There is a WorkingDirectory directive, and the command line contained a path, $0, which has been rewritten to $1."
				StrCpy $ExecString "$ExecString $1"
			${EndIf}
		${EndIf}
	${EndIf}

	; Get additional parameters from user INI file
	${ReadUserConfig} $0 AdditionalParameters
	${If} $0 != ""
		${DebugMsg} "The user has specified additional command line arguments ($0).  Adding them to execution string after parsing."
		${ParseLocations} $0
		StrCpy $ExecString "$ExecString $0"
	${EndIf}

	${DebugMsg} "Finished working with execution string: final value is $ExecString"
!macroend
