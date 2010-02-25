${SegmentFile}

Var ExecString

${SegmentPre}
	${DebugMsg} "Constructing execution string"
	${If} $UsingJavaExecutable != true
		StrCpy $ExecString `"$AppDirectory\$ProgramExecutable"`
	${Else}
		StrCpy $ExecString `"$JavaDirectory\bin\$ProgramExecutable"`
	${EndIf}
	${DebugMsg} "Execution string is $ExecString"

	;=== Get any default parameters
	ClearErrors
	${ReadLauncherConfig} $0 Launch CommandLineArguments
	${IfNot} ${Errors}
		${DebugMsg} "There are default command line arguments ($0).  Adding them to execution string after parsing."
		${ParseLocations} $0
		StrCpy $ExecString "$ExecString $0"
	${EndIf}

	;=== Get any passed parameters
	${GetParameters} $0
	${If} $0 != ""
		${DebugMsg} "Parameters were passed ($0).  Adding them to execution string."
		ClearErrors
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

	;=== Get additional parameters from user INI file
	${ReadUserOverrideConfig} $0 AdditionalParameters
	${If} $0 != ""
		${DebugMsg} "The user has specified additional command line arguments ($0).  Adding them to execution string."
		StrCpy $ExecString "$ExecString $0"
	${EndIf}

	${DebugMsg} "Finished working with execution string: final value is $ExecString"
!macroend
