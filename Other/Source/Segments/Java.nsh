${SegmentFile}

Var UsingJavaExecutable
Var JavaMode
Var JavaDirectory

!macro _Java_CheckJavaInstall _t _f
	${IfNot} ${Errors}
	${AndIf} ${FileExists} $JavaDirectory\bin\java.exe
	${AndIf} ${FileExists} $JavaDirectory\bin\javaw.exe
		Goto `${_t}`
	${Else}
		Goto `${_f}`
	${EndIf}
!macroend
!macro _Java_FindJava
	ClearErrors
	StrCpy $JavaDirectory $PortableAppsDirectory\CommonFiles\Java
	!insertmacro _Java_CheckJavaInstall _Java_FindJava_Found 0

	ClearErrors
	ReadRegStr $0 HKLM "Software\JavaSoft\Java Runtime Environment" CurrentVersion
	ReadRegStr $JavaDirectory HKLM "Software\JavaSoft\Java Runtime Environment\$0" JavaHome
	!insertmacro _Java_CheckJavaInstall _Java_FindJava_Found 0

	ClearErrors
	ReadEnvStr $JavaDirectory JAVA_HOME
	!insertmacro _Java_CheckJavaInstall _Java_FindJava_Found 0

	ClearErrors
	SearchPath $JavaDirectory java.exe
	${GetParent} $JavaDirectory $JavaDirectory
	${GetParent} $JavaDirectory $JavaDirectory
	!insertmacro _Java_CheckJavaInstall _Java_FindJava_Found 0

	StrCpy $JavaDirectory $PortableAppsDirectory\CommonFiles\Java
	${DebugMsg} "Unable to find Java installation"

_Java_FindJava_Found:
!macroend

${SegmentInit}
	; If appinfo.ini\[Dependencies]:UsesJava=yes|optional, search for Java
	; in the following locations (in order):
	;
	;  - PortableApps.com CommonFiles (..\CommonFiles\Java)
	;  - Registry (HKLM\Software\JavaSoft\Java Runtime Environment)
	;  - %JAVA_HOME%
	;  - Anywhere in %PATH% (with SearchPath)
	;
	; If it's in none of those, give up. UsesJava=yes will then abort,
	; UsesJava=optional will set it to the non-existentCommonFiles
	; location. %JAVA_HOME% is then set to the location.
	;
	; Compatibility mappings:
	;   launcher.ini\[Activate]:Java=find         -> optional
	;   launcher.ini\[Activate]:Java=require      -> yes
	;   appinfo.ini\[Dependencies]:UsesJava=true  -> yes
	;   appinfo.ini\[Dependencies]:UsesJava=false -> no

	ClearErrors
	ReadINIStr $JavaMode $EXEDIR\App\AppInfo\appinfo.ini Dependencies UsesJava
	${If} $JavaMode == true
		StrCpy $JavaMode yes
	${ElseIf} $JavaMode == false
		StrCpy $JavaMode no
	${EndIf}
	${If} ${Errors}
		${ReadLauncherConfig} $JavaMode Activate Java
		${If} $JavaMode == require
			StrCpy $JavaMode yes
		${ElseIf} $JavaMode == find
			StrCpy $JavaMode optional
		${EndIf}
	${EndIf}
	

	${If}   $JavaMode == yes
	${OrIf} $JavaMode == optional
		!insertmacro _Java_FindJava

		; If Java is required and not found, quit; if it is, check if
		; [Launch]:ProgramExecutable is java.exe or javaw.exe.
		${If} $JavaMode == yes
			${IfNot} ${FileExists} $JavaDirectory
				;=== Java Portable is missing
				MessageBox MB_OK|MB_ICONSTOP `$(LauncherNoJava)`
				Quit
			${EndIf}
			${If}   $ProgramExecutable == java.exe
			${OrIf} $ProgramExecutable == javaw.exe
				StrCpy $UsingJavaExecutable true
				${IfNot} ${FileExists} $JavaDirectory\bin\$ProgramExecutable
					;=== The required Java binary (java.exe or javaw.exe) is missing.
					MessageBox MB_OK|MB_ICONSTOP `$(LauncherNoJava)`
					Quit
				${EndIf}
			${EndIf}
		${EndIf}

		; Now set %JAVA_HOME% to the path (still may not exist)
		${DebugMsg} "Selected Java path: $JavaDirectory"
		${SetEnvironmentVariablesPath} JAVA_HOME $JavaDirectory
	${ElseIfNot} $JavaMode != ""
		${InvalidValueError} [Activate]:Java $JavaMode
	${EndIf}
!macroend
