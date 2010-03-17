${SegmentFile}

Var RunLocally

${SegmentInit}
	${ReadUserOverrideConfig} $RunLocally RunLocally
!macroend

${SegmentPre}
	${If} $RunLocally == true
		${DebugMsg} "Live mode enabled"
		${ReadLauncherConfig} $0 LiveMode CopyApp
		${If} $0 != false
			${If} $SecondaryLaunch != true
				${DebugMsg} "Live mode: copying $EXEDIR\App to $TMP\$AppIDLive\App"
				CreateDirectory $TMP\$AppIDLive
				CopyFiles /SILENT $EXEDIR\App $TMP\$AppIDLive
			${EndIf}
			StrCpy $AppDirectory $TMP\$AppIDLive\App
		${EndIf}
		#For the time being at least, I've disabled the option of not copying Data, as it makes file moving etc. from %DataDirectory% break
		#${ReadLauncherConfig} $0 LiveMode CopyData
		#${If} $0 != false
			${If} $SecondaryLaunch != true
				${DebugMsg} "Live mode: copying $EXEDIR\Data to $TMP\$AppIDLive\Data"
				CreateDirectory $TMP\$AppIDLive
				CopyFiles /SILENT $EXEDIR\Data $TMP\$AppIDLive
			${EndIf}
			StrCpy $DataDirectory $TMP\$AppIDLive\Data
		#${EndIf}
		${If} ${FileExists} $TMP\$AppIDLive
			${SetFileAttributesDirectoryNormal} $TMP\$AppIDLive
		${EndIf}
	${Else}
		StrCpy $AppDirectory $EXEDIR\App
		StrCpy $DataDirectory $EXEDIR\Data
	${EndIf}

	CreateDirectory $DataDirectory

	${SetEnvironmentVariablesPath} PAL:AppDir $AppDirectory
	${SetEnvironmentVariablesPath} PAL:DataDir $DataDirectory
!macroend

${SegmentPostPrimary}
	${If} $RunLocally == true
		${DebugMsg} "Removing Live mode directory $TMP\$AppIDLive."
		RMDir /r $TMP\$AppIDLive
	${EndIf}
!macroend
