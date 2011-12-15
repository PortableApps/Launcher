${SegmentFile}

Var GSMode
Var GSDirectory
Var GSRegExists
Var GSExecutable

Function _Ghostscript_ValidateInstall
	; It seems that ${DebugMsg} doesn't compile inside functions, so let's store the messages
	; in $R8.  Maybe we could transform this into an artificial function?
	StrCpy $R8 ""

	${If} $Bits = 64
		${If} ${FileExists} $GSDirectory\bin\gswin64c.exe
			StrCpy $GSExecutable $GSDirectory\bin\gswin64c.exe
			StrCpy $R8 "Found valid 64-bit Ghostscript install at $GSDirectory."
			Push true
			Goto End
		${Else}
			StrCpy $R8 "64-bit Windows but gswin64c.exe not found; trying gswin32c.exe instead.$\r$\n"
		${EndIf}
	${EndIf}

	${IfNot} ${FileExists} $GSDirectory\bin\gswin32c.exe
		StrCpy $GSDirectory ""
		StrCpy $GSExecutable ""
		StrCpy $R8 "$R8No valid Ghostscript install found at $GSDirectory."
		Push false
		Goto End
	${EndIf}

	StrCpy $GSExecutable $GSDirectory\bin\gswin32c.exe
	StrCpy $R8 "$R8Found valid 32-bit Ghostscript install at $GSDirectory."
	Push true
	Goto End

	End:
FunctionEnd
!macro _Ghostscript_ValidateInstall _a _b _t _f
	!insertmacro _LOGICLIB_TEMP
	${DebugMsg} "Checking for Ghostscript in $GSDirectory..."
	Call _Ghostscript_ValidateInstall
	${DebugMsg} `$R8`
	Pop $_LOGICLIB_TEMP
	!insertmacro _== $_LOGICLIB_TEMP true `${_t}` `${_f}`
!macroend
!define IsValidGhostscriptInstall `"" Ghostscript_ValidateInstall ""`

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
		${IfNot} ${IsValidGhostscriptInstall}
			ReadEnvStr $GSDirectory GS_PROG
			${GetParent} $GSDirectory $GSDirectory
			${GetParent} $GSDirectory $GSDirectory
			${IfNot} ${IsValidGhostscriptInstall}
				ClearErrors
				SearchPath $GSDirectory gswin32c.exe
				${GetParent} $GSDirectory $GSDirectory
				${GetParent} $GSDirectory $GSDirectory
				${IfNot} ${IsValidGhostscriptInstall}
					; If not valid, ${IsValidGhostscriptInstall} will clear
					; $GSDirectory for us.
					Nop
				${EndIf}
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
