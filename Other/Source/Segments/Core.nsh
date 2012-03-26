${SegmentFile}

Var LauncherFile
Var Bits

${Segment.onInit}
	StrCpy $0 $EXEDIR 2
	${If} $0 == "\\"
		; UNC path; may occur in the inner instance with RunAsAdmin?
		; I'm not sure if this is actually true or whether it was some other
		; issue, but I'm leaving the code in until I can be sure.

		; Store the value of $EXEDIR for debug builds for the message.
		${!getdebug}
		!ifdef DEBUG
			StrCpy $0 $EXEDIR
		!endif
		ClearErrors
		ReadEnvStr $EXEDIR _PAL:EXEDIR
		${If} ${Errors}
			MessageBox MB_OK|MB_ICONSTOP "$(LauncherNoUNCSupport)"
			Quit
		${EndIf}
		${DebugMsg} "$$EXEDIR ($0) was a UNC path (due to the UAC plug-in), set $$EXEDIR to %_PAL:EXEDIR% which is $EXEDIR."
	${Else}
		${SetEnvironmentVariable} _PAL:EXEDIR $EXEDIR
	${EndIf}

	; We don't permit running from PROGRAMFILES at all; the Installer will take
	; care of most people (same restrictions), but some may shift it back in
	; there... so, we offer the nice and verbose environment variable (but
	; don't tell them about it normally) if they *really* want to void the
	; warranty they don't have under the GPL.

	; Fear not, $PROGRAMFILES64 == $PROGRAMFILES32 on a 32-bit machine
	${If} $EXEDIR startswith $PROGRAMFILES32
		StrCpy $0 $PROGRAMFILES32
	${ElseIf} $EXEDIR startswith $PROGRAMFILES64
		StrCpy $0 $PROGRAMFILES64
	${Else}
		StrCpy $0 ""
	${EndIf}

	${If} $0 != ""
		; We had fun deciding on these.
		ReadEnvStr $1 IPromiseNotToComplainWhenPortableAppsDontWorkRightInProgramFiles
		${If} $1 == "I understand that this may not work and that I can not ask for help with any of my apps when operating in this fashion."
			${DebugMsg} "You're making me sad by the way you voided your warranty, running in Program Files."
		${Else}
			; This string doesn't let on about the disable switch (by design)
			MessageBox MB_OK|MB_ICONSTOP `$(LauncherProgramFiles)`
			Quit
		${EndIf}
	${EndIf}

	; These may be needed with RunAsAdmin so they can't go in Init.

	${GetBaseName} $EXEFILE $BaseName
	StrCpy $LauncherFile $EXEDIR\App\AppInfo\Launcher\$BaseName.ini

	ClearErrors
	ReadINIStr $AppID $EXEDIR\App\AppInfo\appinfo.ini Details AppID
	ReadINIStr $AppNamePortable $EXEDIR\App\AppInfo\appinfo.ini Details Name
	${If} ${Errors}
		;=== Launcher file missing or missing crucial details
		StrCpy $AppNamePortable "PortableApps.com Launcher"
		StrCpy $MissingFileOrPath $EXEDIR\App\AppInfo\appinfo.ini
		MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
		Quit
	${EndIf}

	${ReadLauncherConfig} $AppName Launch AppName
	${If} $AppName == ""
		; Calculate the application name - non-portable version
		StrCpy $0 $AppNamePortable "" -9
		${If} $0 == " Portable"
			StrCpy $AppName $AppNamePortable -9
		${Else}
			StrCpy $1 $AppNamePortable "" -18
			${If} $0 == ", Portable Edition"
				StrCpy $AppName $AppNamePortable -18
			${Else}
				StrCpy $AppName $AppNamePortable
			${EndIf}
		${EndIf}
	${EndIf}

	; Work out if it's 64-bit or 32-bit
	System::Call kernel32::GetCurrentProcess()i.s
	System::Call kernel32::IsWow64Process(is,*i.r0)
	${If} $0 == 0
		StrCpy $Bits 32
	${Else}
		StrCpy $Bits 64
	${EndIf}

!macroend

${SegmentInit}
	; Copy the launcher INI file to $PLUGINSDIR so that it doesn't go splurk if
	; the disk is pulled out and can clean up.
	StrCpy $LauncherFile $EXEDIR\App\AppInfo\Launcher\$BaseName.ini
	${If} ${FileExists} $LauncherFile
		InitPluginsDir
		CopyFiles /SILENT $LauncherFile $PLUGINSDIR\launcher.ini
		StrCpy $LauncherFile $PLUGINSDIR\launcher.ini
	${Else}
		StrCpy $MissingFileOrPath $LauncherFile
		MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
		Quit
	${EndIf}

	; If there are command line arguments, we use
	; [Launch]:ProgramExecutableWhenParameters if it exists, falling back to
	; the normal [Launch]ProgramExecutable if it's not set or if there aren't
	; arguments.
	${GetParameters} $0
	StrCpy $ProgramExecutable ""

	${If} $Bits = 64
		${If} $0 != ""
			${ReadLauncherConfig} $ProgramExecutable Launch ProgramExecutableWhenParameters64
		${EndIf}
		${If} $ProgramExecutable == ""
			${ReadLauncherConfig} $ProgramExecutable Launch ProgramExecutable64
		${EndIf}
	${EndIf}

	${If} $0 != ""
	${AndIf} $ProgramExecutable == ""
		${ReadLauncherConfig} $ProgramExecutable Launch ProgramExecutableWhenParameters
	${EndIf}

	${If} $ProgramExecutable == ""
		${ReadLauncherConfig} $ProgramExecutable Launch ProgramExecutable
	${EndIf}

	${If} $ProgramExecutable == ""
		; Launcher file missing or missing crucial details (what am I to launch?)
		MessageBox MB_OK|MB_ICONSTOP `$EXEDIR\App\AppInfo\Launcher\$BaseName.ini is missing [Launch]:ProgramExecutable - what am I to launch?`
		Quit
	${EndIf}

	; Is it allowable to have spaces in the path?
	ClearErrors
	${ReadLauncherConfig} $0 Launch NoSpacesInPath
	${If} $0 == true
		${WordFind} $EXEDIR ` ` E+1 $R9
		${IfNot} ${Errors} ; errors = space not found, no errors means space in path
			MessageBox MB_OK|MB_ICONSTOP `$(LauncherNoSpaces)`
			Quit
		${EndIf}
	${ElseIf} $0 != false
	${AndIfNot} ${Errors}
		${InvalidValueError} [Launch]:NoSpacesInPath $0
	${EndIf}
!macroend

${SegmentPreExecPrimary}
	; Save the $PLUGINSDIR so that in case of crash it can still be cleaned up next time
	${WriteRuntimeData} PortableApps.comLauncher PluginsDir $PLUGINSDIR
!macroend

${SegmentUnload}
	; Clear up $PLUGINSDIR, the runtime data which says we're running, and the
	; $PLUGINSDIR from before the hypothetical power failure.
	FileClose $_FEIP_FileHandle
	Delete $PLUGINSDIR\launcher.ini
	${If} $SecondaryLaunch != true
		${ReadRuntimeData} $0 PortableApps.comLauncher PluginsDir
		${If}    $0 != ""
		${AndIf} $0 != $PLUGINSDIR
			RMDir /r $0
		${EndIf}
		Delete $DataDirectory\PortableApps.comLauncherRuntimeData-$BaseName.ini
	${EndIf}
	Delete $PLUGINSDIR\runtimedata.ini
	; Unload the system plug-in (if it's still there?)
	System::Free 0
!macroend
