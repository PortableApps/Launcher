${SegmentFile}

!include DotNet.nsh


${SegmentInit}
	; If appinfo.ini\[Dependencies]:UsesDotNetVersion is not empty, search
	; for a .NET Framework install of the specified version. Valid version
	; numbers are:
	;
	;  - (1.0|1.1|2.0|3.0|3.5)[SP<n>]
	;  - 4.0[SP<n>][C|F]

	ReadINIStr $0 $EXEDIR\App\AppInfo\appinfo.ini Dependencies UsesDotNetVersion
	${If} $0 != ""
		${IfThen} $0 == 4.0 ${|} StrCpy $0 4.0C ${|}
		${If} ${HasDotNetFramework} $0
			; Required .NET version found
			${DebugMsg} ".NET Framework $0 found"
		${ElseIf} ${Errors}
			; Invalid .NET version
			${InvalidValueError} [Dependencies]:UsesDotNetVersion $0
		${Else}
			; Required .NET version not found
			${DebugMsg} "Unable to find .NET Framework $0"
			MessageBox MB_OK|MB_ICONSTOP `$(LauncherNoDotNet)`
			Quit
		${EndIf}
	${EndIf}
!macroend
