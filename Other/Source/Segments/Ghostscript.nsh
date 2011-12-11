${SegmentFile}

Var GSMode
Var GSDirectory
Var GSRegExists
Var GSExecutable

${SegmentInit}
	; If [Activate]:Ghostscript=find|require, search for Ghostscript in the
	; following locations (in order):
	;
	;  - PortableApps.com CommonFiles (..\CommonFiles\Ghostscript)
	;  - GS_PROG (which will be $GSDirectory\bin\gswin(32|64)c.exe)
	;  - Anywhere in %PATH% (with SearchPath)
	;
	; If it's in none of those, give up. [Activate]:Ghostscript=require will
	; then abort, [Activate]:Ghostscript=find will not set it.
	ClearErrors
	${ReadLauncherConfig} $GSMode Activate Ghostscript
	${If} $GSMode == find
	${OrIf} $GSMode == require
		StrCpy $GSDirectory $PortableAppsDirectory\CommonFiles\Ghostscript
		${IfNot} ${FileExists} $GSDirectory
			ReadEnvStr $GSDirectory GS_PROG
			${GetParent} $GSDirectory $GSDirectory
			${GetParent} $GSDirectory $GSDirectory
			${If} $GSDirectory != ""
				ClearErrors
				SearchPath $GSDirectory gswin32c.exe
				${IfNot} ${Errors}
					${GetParent} $GSDirectory $GSDirectory
					${GetParent} $GSDirectory $GSDirectory
				${Else}
					StrCpy $GSDirectory ""
					${DebugMsg} "Unable to find Ghostscript installation."
				${EndIf}
			${EndIf}
		${EndIf}

		; Make sure we can find gswin(32|64)c.exe
		${If} $GSDirectory != ""
			StrCpy $GSExecutable $GSDirectory\bin\gswin32c.exe
			${If} $Bits = 64
			${AndIf} ${FileExists} $GSDirectory\bin\gswin64c.exe
				StrCpy $GSExecutable $GSDirectory\bin\gswin64c.exe
${!getdebug}
!ifdef DEBUG
			${Else}
				${DebugMsg} "64-bit Windows but gswin64c.exe not found, trying gswin32c.exe instead."
!endif
			${EndIf}
			${IfNot} ${FileExists} $GSExecutable
				StrCpy $GSDirectory ""
				${DebugMsg} "Found Ghostscript directory but no gswin32c.exe."
			${EndIf}
		${EndIf}

		; If Ghostscript is required and not found, quit
		${If} $GSMode == require
		${AndIf} $GSDirectory == ""
			MessageBox MB_OK|MB_ICONSTOP `$(LauncherNoGhostscript)`
			Quit
		${EndIf}

		; This may be created; check if it exists before: 0 = exists
		${registry::KeyExists} "HKCU\Software\GPL Ghostscript" $GSRegExists

		${DebugMsg} "Selected Ghostscript path: $GSDirectory"
		${DebugMsg} "Selected Ghostscript executable: $GSExecutable"
		ReadEnvStr $0 PATH
		StrCpy $0 "$0;$GSDirectory\bin"
		${SetEnvironmentVariablesPath} PATH $0
		${SetEnvironmentVariablesPath} GS_PROG $GSExecutable
	${ElseIfNot} ${Errors}
		${InvalidValueError} [Activate]:Ghostscript $GSMode
	${EndIf}
!macroend

${SegmentPost}
	${If} $GSRegExists != 0  ; Didn't exist before
	${AndIf} ${RegistryKeyExists} "HKCU\Software\GPL Ghostscript"
		${registry::DeleteKey} "HKCU\Software\GPL Ghostscript" $R9
	${EndIf}
!macroend
