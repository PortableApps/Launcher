${SegmentFile}

Var UsingJavaExecutable
Var JavaMode
Var JAVADIRECTORY

${SegmentInit}
	;=== Search for Java: PortableApps.com CommonFiles, registry, %JAVA_HOME%, SearchPath, %WINDIR%\Java
	${ReadLauncherConfig} $JavaMode Activate Java
	${If} $JavaMode == find
	${OrIf} $JavaMode == require
		StrCpy $JAVADIRECTORY $PORTABLEAPPSDIRECTORY\CommonFiles\Java
		${IfNot} ${FileExists} $JAVADIRECTORY
			ClearErrors
			ReadRegStr $JAVADIRECTORY HKLM "Software\JavaSoft\Java Runtime Environment" CurrentVersion
			ReadRegStr $JAVADIRECTORY HKLM "Software\JavaSoft\Java Runtime Environment\$JAVADIRECTORY" JavaHome
			${If} ${Errors}
			${OrIfNot} ${FileExists} $JAVADIRECTORY\bin\java.exe
				ClearErrors
				ReadEnvStr $JAVADIRECTORY JAVA_HOME
				${If} ${Errors}
				${OrIfNot} ${FileExists} $JAVADIRECTORY\bin\java.exe
					ClearErrors
					SearchPath $JAVADIRECTORY java.exe
					${IfNot} ${Errors}
						${GetParent} $JAVADIRECTORY $JAVADIRECTORY
						${GetParent} $JAVADIRECTORY $JAVADIRECTORY
					${Else}
						StrCpy $JAVADIRECTORY $WINDIR\Java
						${IfNot} ${FileExists} $JAVADIRECTORY\bin\java.exe
							StrCpy $JAVADIRECTORY $PORTABLEAPPSDIRECTORY\CommonFiles\Java
						${EndIf}
					${EndIf}
				${EndIf}
			${EndIf}
		${EndIf}

		${SetEnvironmentVariablesPath} JAVA_HOME $JAVADIRECTORY

		${If} $JavaMode == require
			${IfNot} ${FileExists} $JAVADIRECTORY
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
