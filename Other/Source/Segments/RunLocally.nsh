${SegmentFile}

Var RunLocally

${SegmentInit}
	${ReadUserConfig} $RunLocally RunLocally
!macroend

${SegmentPre}
	${If} $RunLocally == true
		${DebugMsg} "Live mode enabled"
		ClearErrors
		${ReadLauncherConfig} $0 LiveMode CopyApp
		${If} $0 == true
		${OrIf} ${Errors}
			${If} $SecondaryLaunch != true
				${DebugMsg} "Live mode: copying $EXEDIR\App to $TMP\$AppIDLive\App"
				CreateDirectory $TMP\$AppIDLive
				CopyFiles /SILENT $EXEDIR\App $TMP\$AppIDLive
			${EndIf}
			StrCpy $AppDirectory $TMP\$AppIDLive\App
		${ElseIf} $0 != false
			${InvalidValueError} [LiveMode]:CopyApp $0
		${EndIf}
		;For the time being at least, I've disabled the option of not copying Data, as it makes file moving etc. from %DataDirectory% break
		;ClearErrors
		;${ReadLauncherConfig} $0 LiveMode CopyData
		;${If} $0 == true
		;${OrIf} ${Errors}
			${If} $SecondaryLaunch != true
				${DebugMsg} "Live mode: copying $EXEDIR\Data to $TMP\$AppIDLive\Data"
				CreateDirectory $TMP\$AppIDLive
				CopyFiles /SILENT $EXEDIR\Data $TMP\$AppIDLive
			${EndIf}
			; Keep track of the old value for moving runtime data below
			StrCpy $1 $DataDirectory
			StrCpy $DataDirectory $TMP\$AppIDLive\Data
		;${ElseIf} $0 != false
		;	${InvalidValueError} [LiveMode]:CopyData $0
		;${EndIf}
		${If} ${FileExists} $TMP\$AppIDLive
			${SetFileAttributesDirectoryNormal} $TMP\$AppIDLive
		${EndIf}

		${SetEnvironmentVariablesPath} PAL:AppDir $AppDirectory
		${SetEnvironmentVariablesPath} PAL:DataDir $DataDirectory

		; Keep the runtime data (when we switch to mutexes this will go)
		; Not entirely sound as it leaves a slight gap where the user could run
		; another copy while this is still starting and it would work when it
		; shouldn't, but better that way than what we had in 2.1.0.0 where it
		; would just get stuck in "starting".
		; Oh, and remember that this may fail from a read-only medium.
		; But you know what? I don't care. :-)
		CopyFiles /SILENT $1\PortableApps.comLauncherRuntimeData-$BaseName.ini $DataDirectory\PortableApps.comLauncherRuntimeData-$BaseName.ini
		Delete $1\PortableApps.comLauncherRuntimeData-$BaseName.ini
	${EndIf}

	CreateDirectory $DataDirectory
!macroend

${SegmentPostPrimary}
	${If} $RunLocally == true
		${DebugMsg} "Removing Live mode directory $TMP\$AppIDLive."
		RMDir /r $TMP\$AppIDLive
	${EndIf}
!macroend
