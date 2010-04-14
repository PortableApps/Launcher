${SegmentFile}

Var UsingJavaExecutable
Var JavaMode
Var JavaDirectory

${SegmentInit}
	;=== Search for Java: PortableApps.com CommonFiles, registry, %JAVA_HOME%, SearchPath, %WINDIR%\Java
	${ReadLauncherConfig} $JavaMode Activate Java
	${If} $JavaMode == find
	${OrIf} $JavaMode == require
		StrCpy $JavaDirectory $PortableAppsDirectory\CommonFiles\Java
		${IfNot} ${FileExists} $JavaDirectory
			ClearErrors
			ReadRegStr $0 HKLM "Software\JavaSoft\Java Runtime Environment" CurrentVersion
			ReadRegStr $JavaDirectory HKLM "Software\JavaSoft\Java Runtime Environment\$0" JavaHome
			${If} ${Errors}
			${OrIfNot} ${FileExists} $JavaDirectory\bin\java.exe
				ClearErrors
				ReadEnvStr $JavaDirectory JAVA_HOME
				${If} ${Errors}
				${OrIfNot} ${FileExists} $JavaDirectory\bin\java.exe
					ClearErrors
					SearchPath $JavaDirectory java.exe
					${IfNot} ${Errors}
						${GetParent} $JavaDirectory $JavaDirectory
						${GetParent} $JavaDirectory $JavaDirectory
					${Else}
						StrCpy $JavaDirectory $WINDIR\Java
						${IfNot} ${FileExists} $JavaDirectory\bin\java.exe
							StrCpy $JavaDirectory $PortableAppsDirectory\CommonFiles\Java
							${DebugMsg} "Unable to find Java installation."
						${EndIf}
					${EndIf}
				${EndIf}
			${EndIf}
		${EndIf}

		${DebugMsg} "Selected Java path: $JavaDirectory"
		${SetEnvironmentVariablesPath} JAVA_HOME $JavaDirectory

		${If} $JavaMode == require
			${IfNot} ${FileExists} $JavaDirectory
				;=== Java Portable is missing
				StrCpy $MissingFileOrPath Java
				MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
				Abort
			${EndIf}
			${IfThen} $ProgramExecutable == java.exe ${|} StrCpy $UsingJavaExecutable true ${|}
			${IfThen} $ProgramExecutable == javaw.exe ${|} StrCpy $UsingJavaExecutable true ${|}
		${EndIf}
	${EndIf}
!macroend
