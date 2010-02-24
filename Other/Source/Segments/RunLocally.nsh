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
				${DebugMsg} "Live mode: copying $EXEDIR\App to $TEMP\$AppIDLive\App"
				CreateDirectory $TEMP\$AppIDLive
				CopyFiles /SILENT $EXEDIR\App $TEMP\$AppIDLive
			${EndIf}
			StrCpy $AppDirectory $TEMP\$AppIDLive\App
		${EndIf}
		#For the time being at least, I've disabled the option of not copying Data, as it makes file moving etc. from %DataDirectory% break
		#${ReadLauncherConfig} $0 LiveMode CopyData
		${If} $0 != false
			${If} $SecondaryLaunch != true
				${DebugMsg} "Live mode: copying $EXEDIR\Data to $TEMP\$AppIDLive\Data"
				CreateDirectory $TEMP\$AppIDLive
				CopyFiles /SILENT $EXEDIR\Data $TEMP\$AppIDLive
			${EndIf}
			StrCpy $DataDirectory $TEMP\$AppIDLive\Data
		${EndIf}
		${If} ${FileExists} $TEMP\$AppIDLive
			${SetFileAttributesDirectoryNormal} $TEMP\$AppIDLive
		${EndIf}
	${Else}
		StrCpy $AppDirectory $EXEDIR\App
		StrCpy $DataDirectory $EXEDIR\Data
	${EndIf}

	${SetEnvironmentVariablesPath} PAL:AppDir $AppDirectory
	${SetEnvironmentVariablesPath} PAL:DataDir $DataDirectory
!macroend

${SegmentPostPrimary}
	${If} $RunLocally == true
		${DebugMsg} "Removing Live mode directory $TEMP\$AppIDLive."
		RMDir /r $TEMP\$AppIDLive
	${EndIf}
!macroend
