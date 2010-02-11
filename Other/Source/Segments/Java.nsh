${SegmentFile}

Var UsingJavaExecutable
Var JavaMode
Var JAVADIRECTORY
Var REPLACEVAR_FS_JAVADIRECTORY
Var REPLACEVAR_DBS_JAVADIRECTORY
Var REPLACEVAR_JUP_JAVADIRECTORY

!macro MakeJavaUtilPrefsPath VARIABLE
	${If} $JavaMode == require
	${OrIf} $JavaMode == find
		;$R0=pos,$R1=char
		Push $R0 ; len
		Push $R1 ; pos
		Push $R2 ; char
		StrLen $R0 $REPLACEVAR_FS_${VARIABLE}
		IntOp $R0 $R0 - 1 ; base 0
		${For} $R1 0 $R0
			StrCpy $R2 $REPLACEVAR_FS_${VARIABLE} 1 $R1
			${If} $R2 ==   a
			${OrIf} $R2 == b
			${OrIf} $R2 == c
			${OrIf} $R2 == d
			${OrIf} $R2 == e
			${OrIf} $R2 == f
			${OrIf} $R2 == g
			${OrIf} $R2 == h
			${OrIf} $R2 == i
			${OrIf} $R2 == j
			${OrIf} $R2 == k
			${OrIf} $R2 == l
			${OrIf} $R2 == m
			${OrIf} $R2 == n
			${OrIf} $R2 == o
			${OrIf} $R2 == p
			${OrIf} $R2 == q
			${OrIf} $R2 == r
			${OrIf} $R2 == s
			${OrIf} $R2 == t
			${OrIf} $R2 == u
			${OrIf} $R2 == v
			${OrIf} $R2 == w
			${OrIf} $R2 == x
			${OrIf} $R2 == y
			${OrIf} $R2 == z
			${OrIf} $R2 == :
				StrCpy $REPLACEVAR_JUP_${VARIABLE} "$REPLACEVAR_JUP_${VARIABLE}$R2"
			${Else}
				StrCpy $REPLACEVAR_JUP_${VARIABLE} "$REPLACEVAR_JUP_${VARIABLE}/$R2"
			${EndIf}
		${Next}
		Pop $R2
		Pop $R1
		Pop $R0
	${EndIf}
!macroend
!define MakeJavaUtilPrefsPath "!insertmacro MakeJavaUtilPrefsPath"

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

		${StrReplace} $REPLACEVAR_FS_JAVADIRECTORY \ / $JAVADIRECTORY
		${StrReplace} $REPLACEVAR_DBS_JAVADIRECTORY / \\ $REPLACEVAR_FS_JAVADIRECTORY

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
		${MakeJavaUtilPrefsPath} JAVADIRECTORY
		${MakeJavaUtilPrefsPath} ALLUSERSPROFILE
		${MakeJavaUtilPrefsPath} LOCALAPPDATA
		${MakeJavaUtilPrefsPath} APPDATA
		${MakeJavaUtilPrefsPath} DOCUMENTS
		${MakeJavaUtilPrefsPath} PORTABLEAPPSDOCUMENTSDIRECTORY
		${MakeJavaUtilPrefsPath} PORTABLEAPPSPICTURESDIRECTORY
		${MakeJavaUtilPrefsPath} PORTABLEAPPSMUSICDIRECTORY
		${MakeJavaUtilPrefsPath} PORTABLEAPPSVIDEOSDIRECTORY
		${MakeJavaUtilPrefsPath} PORTABLEAPPSDIRECTORY
	${EndIf}
!macroend
