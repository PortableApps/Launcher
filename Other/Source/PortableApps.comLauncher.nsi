/* Copyright 2004-2010 PortableApps.com
 * Website: http://portableapps.com/development
 * Main developer and contact: Chris Morgan
 *
 * This software is OSI Certified Open Source Software.
 * OSI Certified is a certification mark of the Open Source Initiative.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

;=== Program Details {{{1
;!define DEBUG
!define LAUNCHERDIR "Launcher"
!define VER "0.9.9.1"
Name "PortableApps.com Launcher"
OutFile "..\..\PortableApps.comLauncher.exe"
Caption "PortableApps.com Launcher"
VIProductVersion "${VER}"
VIAddVersionKey ProductName "PortableApps.com Launcher"
VIAddVersionKey Comments "A universal launcher for PortableApps.com applications, allowing applications to be run from a removable drive.  For additional details, visit PortableApps.com"
VIAddVersionKey CompanyName "PortableApps.com"
VIAddVersionKey LegalCopyright "PortableApps.com"
VIAddVersionKey FileDescription "PortableApps.com Launcher"
VIAddVersionKey FileVersion "${VER}"
VIAddVersionKey ProductVersion "${VER}"
VIAddVersionKey InternalName "PortableApps.com Launcher"
VIAddVersionKey LegalTrademarks "PortableApps.com is a Trademark of Rare Ideas, LLC."
VIAddVersionKey OriginalFilename "PortableApps.comLauncher.exe"
!undef VER

;=== Runtime Switches {{{1
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True
RequestExecutionLevel user
SetCompressor /SOLID lzma
SetCompressorDictSize 32

;=== Include {{{1
;(Standard NSIS) {{{2
!include LangFile.nsh
!include LogicLib.nsh
!include FileFunc.nsh
!include TextFunc.nsh
!insertmacro TrimNewLines
!insertmacro ConfigWrite

;(NSIS Plugins) {{{2
!include TextReplace.nsh
!include Registry.nsh
!include UAC.nsh
!addplugindir Plugins

;(Custom) {{{2
!include ReplaceInFileWithTextReplace.nsh
!include StrReplace.nsh
!include ForEachINIPair.nsh
!include SetFileAttributesDirectoryNormal.nsh
!include CompilerUtils.nsh
!include NewServiceLib.nsh

;=== Program Icon {{{1
Icon "..\..\App\AppInfo\appicon.ico"

;=== Languages {{{1
!macro IncludeLang _LANG
	LoadLanguageFile "${NSISDIR}\Contrib\Language files\${_LANG}.nlf"
	!insertmacro LANGFILE_INCLUDE_WITHDEFAULT Languages\${_LANG}.nsh Languages\English.nsh
!macroend
${!macrodef} IncludeLang
${IncludeLang} English
${IncludeLang} French
${IncludeLang} German
${IncludeLang} Italian
${IncludeLang} Japanese
${IncludeLang} SimpChinese

;=== Variables {{{1
Var RUNASADMIN
Var RUNNINGASADMIN
Var AppID
Var EXECSTRING
Var LASTDRIVE
Var CURRENTDRIVE
Var SECONDARYLAUNCH ; also handles "don't wait for program"
Var MISSINGFILEORPATH
Var PORTABLEAPPNAME
Var APPNAME
Var PROGRAMEXECUTABLE
Var USINGJAVAEXECUTABLE
Var RUNLOCALLY

Var USESCONTAINEDTEMPDIRECTORY
Var DISABLESPLASHSCREEN

Var USESREGISTRY
Var JAVAMODE

Var APPDIRECTORY
Var DATADIRECTORY
Var JAVADIRECTORY
Var ALLUSERSPROFILE
Var TEMPDIRECTORY
Var PORTABLEAPPSDOCUMENTSDIRECTORY
Var PORTABLEAPPSPICTURESDIRECTORY
Var PORTABLEAPPSMUSICDIRECTORY
Var PORTABLEAPPSVIDEOSDIRECTORY
Var PORTABLEAPPSDIRECTORY

!macro Var_ReplaceVar _VAR
Var REPLACEVAR_FS_${_VAR}
Var REPLACEVAR_DBS_${_VAR}
Var REPLACEVAR_JUP_${_VAR}
!macroend

!insertmacro Var_ReplaceVar APPDIRECTORY
!insertmacro Var_ReplaceVar DATADIRECTORY
!insertmacro Var_ReplaceVar JAVADIRECTORY
!insertmacro Var_ReplaceVar ALLUSERSPROFILE
!insertmacro Var_ReplaceVar LOCALAPPDATA
!insertmacro Var_ReplaceVar APPDATA
!insertmacro Var_ReplaceVar DOCUMENTS
!insertmacro Var_ReplaceVar TEMPDIRECTORY
!insertmacro Var_ReplaceVar PORTABLEAPPSDOCUMENTSDIRECTORY
!insertmacro Var_ReplaceVar PORTABLEAPPSPICTURESDIRECTORY
!insertmacro Var_ReplaceVar PORTABLEAPPSMUSICDIRECTORY
!insertmacro Var_ReplaceVar PORTABLEAPPSVIDEOSDIRECTORY
!insertmacro Var_ReplaceVar PORTABLEAPPSDIRECTORY

Var PORTABLEAPPSLANGUAGECODE
Var PORTABLEAPPSLOCALECODE2
Var PORTABLEAPPSLOCALECODE3
Var PORTABLEAPPSLOCALEGLIBC
Var PORTABLEAPPSLOCALEID
Var PORTABLEAPPSLOCALEWINNAME

; Macro: Make java.util.prefs path {{{1
!macro MakeJavaUtilPrefsPath VARIABLE
	;$R0=pos,$R1=char
	Push $R0 ; len
	Push $R1 ; pos
	Push $R2 ; char
	StrLen $R0 $REPLACEVAR_FS_${VARIABLE}
	IntOp $R0 $R0 - 1 ; base 0
	${For} $R1 0 $R0
		StrCpy $R2 $REPLACEVAR_FS_${VARIABLE} 1 $R1
		${If} $R2 == "a"
		${OrIf} $R2 == "b"
		${OrIf} $R2 == "c"
		${OrIf} $R2 == "d"
		${OrIf} $R2 == "e"
		${OrIf} $R2 == "f"
		${OrIf} $R2 == "g"
		${OrIf} $R2 == "h"
		${OrIf} $R2 == "i"
		${OrIf} $R2 == "j"
		${OrIf} $R2 == "k"
		${OrIf} $R2 == "l"
		${OrIf} $R2 == "m"
		${OrIf} $R2 == "n"
		${OrIf} $R2 == "o"
		${OrIf} $R2 == "p"
		${OrIf} $R2 == "q"
		${OrIf} $R2 == "r"
		${OrIf} $R2 == "s"
		${OrIf} $R2 == "t"
		${OrIf} $R2 == "u"
		${OrIf} $R2 == "v"
		${OrIf} $R2 == "w"
		${OrIf} $R2 == "x"
		${OrIf} $R2 == "y"
		${OrIf} $R2 == "z"
		${OrIf} $R2 == ":"
			StrCpy $REPLACEVAR_JUP_${VARIABLE} "$REPLACEVAR_JUP_${VARIABLE}$R2"
		${Else}
			StrCpy $REPLACEVAR_JUP_${VARIABLE} "$REPLACEVAR_JUP_${VARIABLE}/$R2"
		${EndIf}
	${Next}
	Pop $R2
	Pop $R1
	Pop $R0
!macroend
${!macrodef} MakeJavaUtilPrefsPath

; Macro: generate strings for ParseLocations {{{1
!macro ParseLocations_SlashType VAR SLASHTYPE VARIABLEAPPENDAGE
	${StrReplace} "${VAR}" "%${SLASHTYPE}APPDIR%" "$${VARIABLEAPPENDAGE}APPDIRECTORY" "${VAR}"
	${StrReplace} "${VAR}" "%${SLASHTYPE}DATADIR%" "$${VARIABLEAPPENDAGE}DATADIRECTORY" "${VAR}"
	${If} $JAVAMODE == "find"
	${OrIf} $JAVAMODE == "require"
		${StrReplace} "${VAR}" "%${SLASHTYPE}JAVADIR%" "$${VARIABLEAPPENDAGE}JAVADIRECTORY" "${VAR}"
	${EndIf}
	${StrReplace} "${VAR}" "%${SLASHTYPE}ALLUSERSPROFILE%" "$${VARIABLEAPPENDAGE}ALLUSERSPROFILE" "${VAR}"
	${StrReplace} "${VAR}" "%${SLASHTYPE}LOCALAPPDATA%" "$${VARIABLEAPPENDAGE}LOCALAPPDATA" "${VAR}"
	${StrReplace} "${VAR}" "%${SLASHTYPE}APPDATA%" "$${VARIABLEAPPENDAGE}APPDATA" "${VAR}"
	${StrReplace} "${VAR}" "%${SLASHTYPE}DOCUMENTS%" "$${VARIABLEAPPENDAGE}DOCUMENTS" "${VAR}"
	${StrReplace} "${VAR}" "%${SLASHTYPE}TEMP%" "$${VARIABLEAPPENDAGE}TEMPDIRECTORY" "${VAR}"
	${StrReplace} "${VAR}" "%${SLASHTYPE}PORTABLEAPPSDOCUMENTSDIR%" "$${VARIABLEAPPENDAGE}PORTABLEAPPSDOCUMENTSDIRECTORY" "${VAR}"
	${StrReplace} "${VAR}" "%${SLASHTYPE}PORTABLEAPPSPICTURESDIR%" "$${VARIABLEAPPENDAGE}PORTABLEAPPSPICTURESDIRECTORY" "${VAR}"
	${StrReplace} "${VAR}" "%${SLASHTYPE}PORTABLEAPPSMUSICDIR%" "$${VARIABLEAPPENDAGE}PORTABLEAPPSMUSICDIRECTORY" "${VAR}"
	${StrReplace} "${VAR}" "%${SLASHTYPE}PORTABLEAPPSVIDEOSDIR%" "$${VARIABLEAPPENDAGE}PORTABLEAPPSVIDEOSDIRECTORY" "${VAR}"
	${StrReplace} "${VAR}" "%${SLASHTYPE}PORTABLEAPPSDIR%" "$${VARIABLEAPPENDAGE}PORTABLEAPPSDIRECTORY" "${VAR}"
!macroend

; Macro: parse directory locations in a string {{{1
!macro ParseLocations VAR
	${DebugMsg} "Before location parsing, $${VAR} = `${VAR}`"
	;===Paths {{{2
		${StrReplace} "${VAR}" "%DRIVE%" $CURRENTDRIVE "${VAR}"
		!insertmacro ParseLocations_SlashType "${VAR}" "" ""
		!insertmacro ParseLocations_SlashType "${VAR}" "/" "REPLACEVAR_FS_"
		!insertmacro ParseLocations_SlashType "${VAR}" "\\" "REPLACEVAR_DBS_"
		${If} $JAVAMODE == "find"
		${OrIf} $JAVAMODE == "require"
			!insertmacro ParseLocations_SlashType "${VAR}" "java.util.prefs:" "REPLACEVAR_JUP_"
		${EndIf}

	;===Languages {{{2
		${StrReplace} "${VAR}" "%LANGCODE%" $PORTABLEAPPSLANGUAGECODE "${VAR}"
		${StrReplace} "${VAR}" "%LANGCODE2%" $PORTABLEAPPSLOCALECODE2 "${VAR}"
		${StrReplace} "${VAR}" "%LANGCODE3%" $PORTABLEAPPSLOCALECODE3 "${VAR}"
		${StrReplace} "${VAR}" "%LANGGLIBC%" $PORTABLEAPPSLOCALEGLIBC "${VAR}"
		${StrReplace} "${VAR}" "%LANGID%" $PORTABLEAPPSLOCALEID "${VAR}"
		${StrReplace} "${VAR}" "%LANGWINNAME%" $PORTABLEAPPSLOCALEWINNAME "${VAR}"
	${DebugMsg} "After location parsing, $${VAR} = `${VAR}`"
!macroend
${!macrodef} ParseLocations

; Macro: print a debug message {{{1
!macro DebugMsg _MSG
	!ifdef DEBUG
		MessageBox MB_OKCANCEL|MB_ICONINFORMATION "Debug message (line ${__LINE__}):$\n$\n${_MSG}" IDOK +2
			Abort ; not using IfCmd as it causes trouble with ' in _MSG
	!endif
!macroend
${!macrodef} DebugMsg

; Macro: read a value from the launcher configuration file {{{1
!macro ReadLauncherConfig _OUTPUT _SECTION _VALUE
	ReadINIStr ${_OUTPUT} $EXEDIR\App\AppInfo\launcher.ini ${_SECTION} ${_VALUE}
!macroend
${!macrodef} ReadLauncherConfig

!macro ReadLauncherConfigWithDefault _OUTPUT _SECTION _VALUE _DEFAULT
	ClearErrors
	${ReadLauncherConfig} ${_OUTPUT} `${_SECTION}` `${_VALUE}`
	${IfThen} ${Errors} ${|} StrCpy ${_OUTPUT} `${_DEFAULT}` ${|}
!macroend
${!macrodef} ReadLauncherConfigWithDefault


; UAC elevation function {{{1
Function UAC_Elevate
	; Macro for producing the right message box based on the error code {{{2
	!macro CaseUACCodeAlert CODE FORCEMESSAGE TRYMESSAGE
		!if "${CODE}" == ""
			${Default}
		!else
			${Case} "${CODE}"
		!endif
			${If} $RUNASADMIN == "force"
				MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST|MB_SETFOREGROUND "${FORCEMESSAGE}"
				Abort
			${ElseIf} $RUNASADMIN == "try"
				MessageBox MB_OK|MB_ICONINFORMATION|MB_TOPMOST|MB_SETFOREGROUND "${TRYMESSAGE}"
			${EndIf}
			${Break}
	!macroend
	${!macrodef} CaseUACCodeAlert

	Elevate: ; Attempt to elevate to admin {{{2
		!insertmacro UAC_RunElevated
		${Switch} $0
			; Success in changing credentials in some way {{{3
			${Case} 0
				${IfThen} $1 = 1 ${|} Abort ${|} ; This is the user-level process and the admin-level process has finished successfully.
				${If} $3 <> 0 ; This is the admin-level process: great!
					StrCpy $RUNNINGASADMIN true
					Return
				${EndIf}
				${If} $1 = 3 ; RunAs completed successfully, but with a non-admin user
					${If} $RUNASADMIN == "force"
						MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION|MB_TOPMOST|MB_SETFOREGROUND "$(LauncherRequiresAdmin)$\r$\n$\r$\n$(LauncherNotAdminTryAgain)" IDRETRY Elevate IDCANCEL Fail
					${ElseIf} $RUNASADMIN == "try"
						MessageBox MB_ABORTRETRYIGNORE|MB_ICONEXCLAMATION|MB_TOPMOST|MB_SETFOREGROUND "$(LauncherNotAdminLimitedFunctionality)$\r$\n$\r$\n$(LauncherNotAdminLimitedFunctionalityTryAgain)" IDABORT Fail IDRETRY Elevate
						Return ; Ignore
					${EndIf}
				${EndIf}
				; If we're still here, we'll fall through as there's no ${Break}
			; Explicitly failed to get admin {{{3
			${CaseUACCodeAlert} 1233 \
				"$(LauncherRequiresAdmin)" \
				"$(LauncherNotAdminLimitedFunctionality)"
			; Windows logon service unavailable {{{3
			${CaseUACCodeAlert} 1062 \
				"$(LauncherAdminLogonServiceNotRunning)" \
				"$(LauncherNotAdminLimitedFunctionality)"
			; Other error, not sure what {{{3
			${CaseUACCodeAlert} "" \
				"$(LauncherAdminError)$\r$\n$(LauncherNotAdminLimitedFunctionality)" \
				"$(LauncherAdminError)$\r$\n$(LauncherNotAdminLimitedFunctionality)"
		${EndSwitch}
		Return

	Fail:    ; Failed to elevate to admin, either as required (force), or the user wants to give up (try) {{{2
		Abort
FunctionEnd

; onInit: set the language and run as admin if needed {{{1
Function .onInit
	; Set the language for message boxes, based on what the Platform has set {{{2
	ReadEnvStr $0 "PortableApps.comLocaleID"
	${Switch} $0
		${Case} 1033 ; English
		${Case} 1036 ; French
		${Case} 1031 ; German
		${Case} 1040 ; Italian
		${Case} 1041 ; Japanese
		${Case} 2052 ; SimpChinese
			StrCpy $LANGUAGE $0
			${Break}
	${EndSwitch}

	; Run as admin if needed {{{2
	${ReadLauncherConfig} $RUNASADMIN Launch RunAsAdmin
	${If} $RUNASADMIN == force
	${OrIf} $RUNASADMIN == try
		Call UAC_Elevate
	${EndIf}
FunctionEnd

; Now for the Section which does everything {{{1
Section
	ReadINIStr $AppID $EXEDIR\App\AppInfo\appinfo.ini Details AppID
	${DebugMsg} "Launcher INI file is $EXEDIR\App\AppInfo\launcher.ini.$\nUser INI overrides are in $EXEDIR\PortableApps.comLauncher.ini."

	;=== Fail for UNC paths {{{2
		StrCpy $0 $EXEDIR 2
		${If} $0 == "\\"
			MessageBox MB_OK|MB_ICONSTOP "$(LauncherNoUNCSupport)"
			Abort
		${EndIf}

	;=== Initialise variables {{{2
		; NOTE: CURRENTDRIVE has an issue; it may need to refer to the app, data
		; or file locations; these could be two different drives in Live mode.
		; Which drive letter should we use?  Working on the running device, as
		; file locations (e.g. for MRU) seems most likely.
		ReadINIStr $LASTDRIVE "$EXEDIR\Data\settings\$AppIDSettings.ini" "$AppIDSettings" "LastDrive"
		${GetRoot} $EXEDIR $CURRENTDRIVE
		${GetParent} $EXEDIR $PORTABLEAPPSDIRECTORY

		ReadEnvStr $PORTABLEAPPSDOCUMENTSDIRECTORY PortableApps.comDocuments
		${IfNotThen} ${FileExists} $PORTABLEAPPSDOCUMENTSDIRECTORY ${|} StrCpy $PORTABLEAPPSDOCUMENTSDIRECTORY "$CURRENTDRIVE\Documents" ${|}

		ReadEnvStr $PORTABLEAPPSPICTURESDIRECTORY PortableApps.comPictures
		${IfNotThen} ${FileExists} $PORTABLEAPPSPICTURESDIRECTORY ${|} StrCpy $PORTABLEAPPSPICTURESDIRECTORY "$PORTABLEAPPSDOCUMENTSDIRECTORY\Pictures" ${|}

		ReadEnvStr $PORTABLEAPPSMUSICDIRECTORY PortableApps.comMusic
		${IfNotThen} ${FileExists} $PORTABLEAPPSMUSICDIRECTORY ${|} StrCpy $PORTABLEAPPSMUSICDIRECTORY "$PORTABLEAPPSDOCUMENTSDIRECTORY\Music" ${|}

		ReadEnvStr $PORTABLEAPPSVIDEOSDIRECTORY PortableApps.comVideos
		${IfNotThen} ${FileExists} $PORTABLEAPPSVIDEOSDIRECTORY ${|} StrCpy $PORTABLEAPPSVIDEOSDIRECTORY "$PORTABLEAPPSDOCUMENTSDIRECTORY\Videos" ${|}

		ReadEnvStr $PORTABLEAPPSLANGUAGECODE PortableApps.comLanguageCode
		${IfThen} $PORTABLEAPPSLANGUAGECODE == "" ${|} StrCpy $PORTABLEAPPSLANGUAGECODE "en-us" ${|}
		ReadEnvStr $PORTABLEAPPSLOCALECODE2 PortableApps.comLocaleCode2
		${IfThen} $PORTABLEAPPSLOCALECODE2 == "" ${|} StrCpy $PORTABLEAPPSLOCALECODE2 "en" ${|}
		ReadEnvStr $PORTABLEAPPSLOCALECODE3 PortableApps.comLocaleCode3
		${IfThen} $PORTABLEAPPSLOCALECODE3 == "" ${|} StrCpy $PORTABLEAPPSLOCALECODE3 "eng" ${|}
		ReadEnvStr $PORTABLEAPPSLOCALEGLIBC PortableApps.comLocaleglibc
		${IfThen} $PORTABLEAPPSLOCALEGLIBC == "" ${|} StrCpy $PORTABLEAPPSLOCALEGLIBC "en_US" ${|}
		ReadEnvStr $PORTABLEAPPSLOCALEID PortableApps.comLocaleID
		${IfThen} $PORTABLEAPPSLOCALEID == "" ${|} StrCpy $PORTABLEAPPSLOCALEID "1033" ${|}
		ReadEnvStr $PORTABLEAPPSLOCALEWINNAME PortableApps.comLocaleWinName
		${IfThen} $PORTABLEAPPSLOCALEWINNAME == "" ${|} StrCpy $PORTABLEAPPSLOCALEWINNAME "LANG_ENGLISH" ${|}

		ReadEnvStr $ALLUSERSPROFILE ALLUSERSPROFILE

	;=== Make forward slash and double backslash versions {{{2
		${StrReplace} $REPLACEVAR_FS_ALLUSERSPROFILE "\" "/" $ALLUSERSPROFILE
		${StrReplace} $REPLACEVAR_DBS_ALLUSERSPROFILE "/" "\\" $REPLACEVAR_FS_ALLUSERSPROFILE
		${StrReplace} $REPLACEVAR_FS_LOCALAPPDATA "\" "/" $LOCALAPPDATA
		${StrReplace} $REPLACEVAR_DBS_LOCALAPPDATA "/" "\\" $REPLACEVAR_FS_LOCALAPPDATA
		${StrReplace} $REPLACEVAR_FS_APPDATA "\" "/" $APPDATA
		${StrReplace} $REPLACEVAR_DBS_APPDATA "/" "\\" $REPLACEVAR_FS_APPDATA
		${StrReplace} $REPLACEVAR_FS_DOCUMENTS "\" "/" $DOCUMENTS
		${StrReplace} $REPLACEVAR_DBS_DOCUMENTS "/" "\\" $REPLACEVAR_FS_DOCUMENTS
		${StrReplace} $REPLACEVAR_FS_PORTABLEAPPSDOCUMENTSDIRECTORY "\" "/" $PORTABLEAPPSDOCUMENTSDIRECTORY
		${StrReplace} $REPLACEVAR_DBS_PORTABLEAPPSDOCUMENTSDIRECTORY "/" "\\" $REPLACEVAR_FS_PORTABLEAPPSDOCUMENTSDIRECTORY
		${StrReplace} $REPLACEVAR_FS_PORTABLEAPPSPICTURESDIRECTORY "\" "/" $PORTABLEAPPSPICTURESDIRECTORY
		${StrReplace} $REPLACEVAR_DBS_PORTABLEAPPSPICTURESDIRECTORY "/" "\\" $REPLACEVAR_FS_PORTABLEAPPSPICTURESDIRECTORY
		${StrReplace} $REPLACEVAR_FS_PORTABLEAPPSMUSICDIRECTORY "\" "/" $PORTABLEAPPSMUSICDIRECTORY
		${StrReplace} $REPLACEVAR_DBS_PORTABLEAPPSMUSICDIRECTORY "/" "\\" $REPLACEVAR_FS_PORTABLEAPPSMUSICDIRECTORY
		${StrReplace} $REPLACEVAR_FS_PORTABLEAPPSVIDEOSDIRECTORY "\" "/" $PORTABLEAPPSVIDEOSDIRECTORY
		${StrReplace} $REPLACEVAR_DBS_PORTABLEAPPSVIDEOSDIRECTORY "/" "\\" $REPLACEVAR_FS_PORTABLEAPPSVIDEOSDIRECTORY
		${StrReplace} $REPLACEVAR_FS_PORTABLEAPPSDIRECTORY "\" "/" $PORTABLEAPPSDIRECTORY
		${StrReplace} $REPLACEVAR_DBS_PORTABLEAPPSDIRECTORY "/" "\\" $REPLACEVAR_FS_PORTABLEAPPSDIRECTORY

	;=== Load launcher details {{{2
		ClearErrors
		ReadINIStr $PORTABLEAPPNAME $EXEDIR\App\AppInfo\appinfo.ini Details Name
		${ReadLauncherConfig} $PROGRAMEXECUTABLE Launch ProgramExecutable

		${If} ${Errors}
			;=== Launcher file missing or missing crucial details
			StrCpy $PORTABLEAPPNAME "PortableApps.com Launcher"
			StrCpy $MISSINGFILEORPATH launcher.ini
			MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
			Abort
		${EndIf}

	;=== Search for Java: PortableApps.com CommonFiles, registry, %JAVA_HOME%, SearchPath, %WINDIR%\Java {{{2
		${ReadLauncherConfig} $USESREGISTRY Activate Registry
		${ReadLauncherConfig} $JAVAMODE Activate Java
		${If} $JAVAMODE == "find"
		${OrIf} $JAVAMODE == "require"
			StrCpy $JAVADIRECTORY "$PORTABLEAPPSDIRECTORY\CommonFiles\Java"
			${IfNot} ${FileExists} $JAVADIRECTORY
				ClearErrors
				ReadRegStr $JAVADIRECTORY HKLM "Software\JavaSoft\Java Runtime Environment" "CurrentVersion"
				ReadRegStr $JAVADIRECTORY HKLM "Software\JavaSoft\Java Runtime Environment\$JAVADIRECTORY" "JavaHome"
				${If} ${Errors}
				${OrIfNot} ${FileExists} $JAVADIRECTORY\bin\java.exe
					ClearErrors
					ReadEnvStr $JAVADIRECTORY JAVA_HOME
					${If} ${Errors}
					${OrIfNot} ${FileExists} $JAVADIRECTORY\bin\java.exe
						ClearErrors
						SearchPath $JAVADIRECTORY "java.exe"
						${IfNot} ${Errors}
							${GetParent} $JAVADIRECTORY $JAVADIRECTORY
							${GetParent} $JAVADIRECTORY $JAVADIRECTORY
						${Else}
							StrCpy $JAVADIRECTORY "$WINDIR\Java"
							${IfNot} ${FileExists} $JAVADIRECTORY\bin\java.exe
								StrCpy $JAVADIRECTORY "$PORTABLEAPPSDIRECTORY\CommonFiles\Java"
							${EndIf}
						${EndIf}
					${EndIf}
				${EndIf}
			${EndIf}

			${StrReplace} $REPLACEVAR_FS_JAVADIRECTORY "\" "/" $JAVADIRECTORY
			${StrReplace} $REPLACEVAR_DBS_JAVADIRECTORY "/" "\\" $REPLACEVAR_FS_JAVADIRECTORY

			${If} $JAVAMODE == "require"
				${IfNot} ${FileExists} $JAVADIRECTORY
					;=== Java Portable is missing
					StrCpy $MISSINGFILEORPATH "Java"
					MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
					Abort
				${EndIf}
				${IfThen} $PROGRAMEXECUTABLE == "java.exe" ${|} StrCpy $USINGJAVAEXECUTABLE "true" ${|}
				${IfThen} $PROGRAMEXECUTABLE == "javaw.exe" ${|} StrCpy $USINGJAVAEXECUTABLE "true" ${|}
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

	;=== Check if launcher already running {{{2
		System::Call 'kernel32::CreateMutexA(i 0, i 0, t "PortableApps.comLauncher$AppID") i .r1 ?e'
		Pop $0
		${IfNot} $0 = 0
			${ReadLauncherConfig} $0 Launch SinglePortableAppInstance
			${If} $0 == "true"
				${DebugMsg} "Launcher already running and [Launch]->SingleInstance=true: aborting."
				Abort
			${EndIf}
			${DebugMsg} "Launcher already running: secondary launch."
			StrCpy $SECONDARYLAUNCH "true"
		${EndIf}

	;=== Read the user customisations INI file {{{2
		ReadINIStr $RUNLOCALLY "$EXEDIR\PortableApps.comLauncher.ini" "PortableApps.comLauncher" "RunLocally"

		${IfNot} ${FileExists} "$EXEDIR\App\$PROGRAMEXECUTABLE"
		${AndIfNot} $USINGJAVAEXECUTABLE == "true"
			;=== Program executable not where expected
			StrCpy $MISSINGFILEORPATH App\$PROGRAMEXECUTABLE
			MessageBox MB_OK|MB_ICONSTOP `$(LauncherFileNotFound)`
			Abort
		${EndIf}

	;=== Check if application already running {{{2
		!macro AbortAlreadyRunning _EXECUTABLE_NAME
			FindProcDLL::FindProc "${_EXECUTABLE_NAME}"
			${If} $SECONDARYLAUNCH != "true"
			${AndIf} $R0 = 1
				${ReadLauncherConfig} $APPNAME Launch AppName
				${If} $APPNAME == ""
					; Calculate the application name - non-portable version
					StrCpy $0 $PORTABLEAPPNAME "" -9
					${If} $0 == " Portable"
						StrCpy $APPNAME $PORTABLEAPPNAME -9
					${Else}
						StrCpy $1 $PORTABLEAPPNAME "" -18
						${If} $0 == ", Portable Edition"
							StrCpy $APPNAME $PORTABLEAPPNAME -18
						${Else}
							StrCpy $APPNAME $PORTABLEAPPNAME
						${EndIf}
					${EndIf}
				${EndIf}
				MessageBox MB_OK|MB_ICONSTOP `$(LauncherAlreadyRunning)`
				Abort
			${EndIf}
		!macroend
		${ReadLauncherConfig} $0 Launch SingleAppInstance
		${If} $0 != "false"
		${AndIfNot} $USINGJAVAEXECUTABLE == "true"
			${GetFileName} $PROGRAMEXECUTABLE $0
			!insertmacro AbortAlreadyRunning $0
		${EndIf}

		ClearErrors
		${ReadLauncherConfig} $0 Launch CloseEXE
		${IfNot} ${Errors}
			!insertmacro AbortAlreadyRunning $0
		${EndIf}

	;=== Display splash screen {{{2
		ReadINIStr $DISABLESPLASHSCREEN "$EXEDIR\PortableApps.comLauncher.ini" PortableApps.comLauncher "DisableSplashScreen"
		${IfNotThen} ${FileExists} $EXEDIR\App\AppInfo\splash.jpg ${|} StrCpy $DISABLESPLASHSCREEN "true" ${|}
		${If} $DISABLESPLASHSCREEN != "true"
			;=== Show the splash screen before processing the files
			newadvsplash::show /NOUNLOAD 1500 200 0 -1 /L $EXEDIR\App\AppInfo\splash.jpg
		${EndIf}

	;=== Wait for program?  *ONLY USE THIS IF THERE'LL BE NOTHING TO DO AFTERWARDS! {{{2
	; TODO: automatically work something out about this
		${ReadLauncherConfig} $0 Launch WaitForProgram
		${If} $0 == "false"
			${DebugMsg} "WaitForProgram is set to false: SECONDARYLAUNCH set to true."
			StrCpy $SECONDARYLAUNCH "true"
		${EndIf}

	;=== Handle Live mode (run locally) {{{2
		${If} $RUNLOCALLY == "true"
			${DebugMsg} "Live mode enabled"
			${ReadLauncherConfig} $0 LiveMode CopyApp
			${If} $0 != "false"
				${If} $SECONDARYLAUNCH != "true"
					${DebugMsg} "Live mode: copying $EXEDIR\App to $TEMP\$AppIDLive\App"
					CreateDirectory $TEMP\$AppIDLive
					CopyFiles /SILENT $EXEDIR\App $TEMP\$AppIDLive
				${EndIf}
				StrCpy $APPDIRECTORY "$TEMP\$AppIDLive\App"
			${EndIf}
			#For the time being at least, I've disabled the option of not copying Data, as it makes file moving etc. from %DATADIRECTORY% break
			#${ReadLauncherConfig} $0 LiveMode CopyData
			${If} $0 != "false"
				${If} $SECONDARYLAUNCH != "true"
					${DebugMsg} "Live mode: copying $EXEDIR\Data to $TEMP\$AppIDLive\Data"
					CreateDirectory $TEMP\$AppIDLive
					CopyFiles /SILENT $EXEDIR\Data $TEMP\$AppIDLive
				${EndIf}
				StrCpy $DATADIRECTORY "$TEMP\$AppIDLive\Data"
			${EndIf}
			${If} ${FileExists} "$TEMP\$AppIDLive"
				${SetFileAttributesDirectoryNormal} "$TEMP\$AppIDLive"
			${EndIf}
		${Else}
			StrCpy $APPDIRECTORY "$EXEDIR\App"
			StrCpy $DATADIRECTORY "$EXEDIR\Data"
		${EndIf}

		${StrReplace} $REPLACEVAR_FS_APPDIRECTORY "\" "/" $APPDIRECTORY
		${StrReplace} $REPLACEVAR_DBS_APPDIRECTORY "/" "\\" $REPLACEVAR_FS_APPDIRECTORY
		${MakeJavaUtilPrefsPath} APPDIRECTORY
		${StrReplace} $REPLACEVAR_FS_DATADIRECTORY "\" "/" $DATADIRECTORY
		${StrReplace} $REPLACEVAR_DBS_DATADIRECTORY "/" "\\" $REPLACEVAR_FS_DATADIRECTORY
		${MakeJavaUtilPrefsPath} DATADIRECTORY

	;=== Handle TEMP directory {{{2
		${ReadLauncherConfig} $USESCONTAINEDTEMPDIRECTORY Launch AssignContainedTempDirectory
		${If} $USESCONTAINEDTEMPDIRECTORY != "false"
			${ReadLauncherConfig} $0 Launch WaitForProgram
			${If} $0 == "false"
				StrCpy $TEMPDIRECTORY "$DATADIRECTORY\Temp"
			${Else}
				StrCpy $TEMPDIRECTORY "$TEMP\$AppIDTemp"
			${EndIf}
			${DebugMsg} "Creating temporary directory $TEMPDIRECTORY"
			${If} ${FileExists} $TEMPDIRECTORY
				RMDir /r $TEMPDIRECTORY
			${EndIf}
			CreateDirectory $TEMPDIRECTORY
		${Else}
			StrCpy $TEMPDIRECTORY $TEMP
		${EndIf}

		${DebugMsg} "Setting %TEMP% and %TMP% to $TEMPDIRECTORY"
		System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("TEMP", "$TEMPDIRECTORY").n'
		System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("TMP", "$TEMPDIRECTORY").n'
		${StrReplace} $REPLACEVAR_FS_TEMPDIRECTORY "\" "/" $TEMPDIRECTORY
		${StrReplace} $REPLACEVAR_DBS_TEMPDIRECTORY "/" "\\" $REPLACEVAR_FS_TEMPDIRECTORY
		${MakeJavaUtilPrefsPath} TEMPDIRECTORY

	;=== Check for settings {{{2
		${IfNot} ${FileExists} "$DATADIRECTORY\settings"
			${DebugMsg} "$DATADIRECTORY\settings does not exist. Creating it."
			CreateDirectory "$DATADIRECTORY\settings"
			${If} ${FileExists} $EXEDIR\App\DefaultData\*.*
				${DebugMsg} "Copying default data from $EXEDIR\App\DefaultData to $DATADIRECTORY."
				CopyFiles /SILENT $EXEDIR\App\DefaultData\*.* $DATADIRECTORY
			${EndIf}
		${EndIf}

	;=== Update the drive letter in files {{{2
		${If} $LASTDRIVE != $CURRENTDRIVE
			;=== Backslash {{{3
			StrCpy $0 1
			${Do}
				ClearErrors
				${ReadLauncherConfig} $1 FileDriveLetterUpdate Backslash$0
				${If} ${Errors}
					${ExitDo}
				${EndIf}
				${ParseLocations} $1
				${If} ${FileExists} $1
					${DebugMsg} "Updating drive letter from $LASTDRIVE to $CURRENTDRIVE in $1; using backslashes"
					${ReplaceInFile} $1 "$LASTDRIVE\" "$CURRENTDRIVE\"
				${EndIf}
				IntOp $0 $0 + 1
			${Loop}

			;=== Forwardslash {{{3
			StrCpy $0 1
			${Do}
				ClearErrors
				${ReadLauncherConfig} $1 FileDriveLetterUpdate Forwardslash$0
				${If} ${Errors}
					${ExitDo}
				${EndIf}
				${ParseLocations} $1
				${If} ${FileExists} $1
					${DebugMsg} "Updating drive letter from $LASTDRIVE to $CURRENTDRIVE in $1; using forward slashes"
					${ReplaceInFile} $1 "$LASTDRIVE/" "$CURRENTDRIVE/"
				${EndIf}
				IntOp $0 $0 + 1
			${Loop}

			;=== Save drive letter {{{3
			WriteINIStr "$DATADIRECTORY\settings\$AppIDSettings.ini" "$AppIDSettings" "LastDrive" $CURRENTDRIVE
		${EndIf}

	;=== Write configuration values with ConfigWrite {{{2
		StrCpy $0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $1 FileWriteConfigWrite $0File
			${ReadLauncherConfig} $2 FileWriteConfigWrite $0Entry
			${ReadLauncherConfig} $3 FileWriteConfigWrite $0Value
			${If} ${Errors}
				${ExitDo}
			${EndIf}
			${ParseLocations} $1
			${ParseLocations} $3
			${If} ${FileExists} $1
				${DebugMsg} "Writing configuration to a file with ConfigWrite.$\nFile: $1$\nEntry: `$2`$\nValue: `$3`"
				${ConfigWrite} $1 $2 $3 $R0
			${EndIf}
			IntOp $0 $0 + 1
		${Loop}

	;=== Write configuration values with WriteINIStr {{{2
		StrCpy $0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $1 FileWriteINI $0File
			${ReadLauncherConfig} $2 FileWriteINI $0Section
			${ReadLauncherConfig} $3 FileWriteINI $0Key
			${ReadLauncherConfig} $4 FileWriteINI $0Value
			${If} ${Errors}
				${ExitDo}
			${EndIf}
			${ParseLocations} $1
			${ParseLocations} $4
			${If} ${FileExists} $1
				${DebugMsg} "Writing INI configuration to a file.$\nFile: $1$\nSection: `$2`$\nKey: `$3`$\nValue: `$4`"
				WriteINIStr $1 $2 $3 $4
			${EndIf}
			IntOp $0 $0 + 1
		${Loop}

	;=== Construct the execution string {{{2
		${DebugMsg} "Constructing execution string"
		${If} $USINGJAVAEXECUTABLE != "true"
			StrCpy $EXECSTRING `"$APPDIRECTORY\$PROGRAMEXECUTABLE"`
		${Else}
			StrCpy $EXECSTRING `"$JAVADIRECTORY\bin\$PROGRAMEXECUTABLE"`
		${EndIf}
		${DebugMsg} "Execution string is $EXECSTRING"

		;=== Get any default parameters {{{3
		ClearErrors
		${ReadLauncherConfig} $0 Launch DefaultCommandLineArguments
		${IfNot} ${Errors}
			${DebugMsg} "There are default command line arguments ($0).  Adding them to execution string after parsing."
			${ParseLocations} $0
			StrCpy $EXECSTRING "$EXECSTRING $0"
		${EndIf}

		;=== Get any passed parameters {{{3
		${GetParameters} $0
		${If} $0 != ""
			${DebugMsg} "Parameters were passed ($0).  Adding them to execution string."
			StrCpy $EXECSTRING "$EXECSTRING $0"
		${EndIf}

	;=== Get additional parameters from user INI file {{{2
		ReadINIStr $0 "$EXEDIR\PortableApps.comLauncher.ini" PortableApps.comLauncher "AdditionalParameters"
		${If} $0 != ""
			${DebugMsg} "The user has specified additional command line arguments ($0).  Adding them to execution string."
			StrCpy $EXECSTRING "$EXECSTRING $0"
		${EndIf}

		${DebugMsg} "Finished working with execution string: final value is $EXECSTRING"

	;=== Set up environment variables {{{2
		${ForEachINIPair} "Environment" $0 $1
			${ParseLocations} $1
			;=== Now see if we need to prepend, append or change.
			StrCpy $2 $1 3 ; first three characters
			${If} $2 == "{&}" ; append
				ReadEnvStr $2 $0
				StrCpy $1 $1 "" 3
				StrCpy $1 $2$1
			${Else}
				StrCpy $2 $1 "" -3 ; last three characters
				${If} $2 == "{&}" ; prepend
					ReadEnvStr $2 $0
					StrCpy $1 $1 -3
					StrCpy $1 $1$2
				${EndIf}
			${EndIf}
			${DebugMsg} "Changing environment variable $0 to $1"
			System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i(r0, r1).n'
		${EndForEachINIPair}

	;=== If primary instance: make it portable {{{2
		${If} $SECONDARYLAUNCH != "true"
			;=== Backup local files and insert portable data {{{3
				${ForEachINIPair} "FilesMove" $0 $1 ; {{{4
					${ParseLocations} $1

					${GetFileName} $0 $2

					StrCpy $1 $1\$2

					;=== Backup data from a local installation
					${IfNot} ${FileExists} "$1-BackupBy$AppID"
					${AndIf} ${FileExists} $1
						${DebugMsg} "Backing up $1 to $1-BackupBy$AppID"
						Rename $1 "$1-BackupBy$AppID"
					${EndIf}
					${If} ${FileExists} "$DATADIRECTORY\$0"
						${DebugMsg} "Copying $DATADIRECTORY\$0 to $1"
						CopyFiles /SILENT "$DATADIRECTORY\$0" $1
					${EndIf}
				${EndForEachINIPair}

				${ForEachINIPair} "DirectoriesMove" $0 $1 ; {{{4
					${ParseLocations} $1

					;=== Backup data from a local installation
					${If} ${FileExists} $1
						${DebugMsg} "Backing up $1 to $1-BackupBy$AppID"
						Rename $1 "$1-BackupBy$AppID"
					${EndIf}
					CreateDirectory $1
					${If} ${FileExists} "$DATADIRECTORY\$0\*.*"
						${DebugMsg} "Copying $DATADIRECTORY\$0\*.* to $1\*.*"
						CopyFiles /SILENT "$DATADIRECTORY\$0\*.*" $1
					${Else}
						${DebugMsg} "$DATADIRECTORY\$0\*.* does not exist, so not copying it to $1.$\n(Note for developers: if you want default data, remember to put files in App\DefaultData\$0)"
					${EndIf}
				${EndForEachINIPair}

			;=== Backup registry and insert portable data {{{3
			${If} $USESREGISTRY == "true"
				;=== RegistryKeys {{{4
				${ForEachINIPair} "RegistryKeys" $0 $1
					;=== Backup the registry
					${registry::KeyExists} "HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Keys\$0" $R0
					${If} $R0 != "0"
						${registry::KeyExists} $1 $R0
						${If} $R0 != "-1"
							${DebugMsg} "Backing up registry key $1 to HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Keys\$0"
							${registry::MoveKey} $1 "HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Keys\$0" $R0
						${EndIf}
					${EndIf}

					${If} ${FileExists} "$DATADIRECTORY\settings\$0.reg"
						SetErrors
						${DebugMsg} "Loading $DATADIRECTORY\settings\$0.reg into the registry."
						${If} ${FileExists} "$WINDIR\system32\reg.exe"
							nsExec::Exec `"$WINDIR\system32\reg.exe" import "$DATADIRECTORY\settings\$0.reg"`
							Pop $R0
							${IfThen} $R0 = 0 ${|} ClearErrors ${|}
						${EndIf}

						${If} ${Errors}
							${registry::RestoreKey} "$DATADIRECTORY\settings\$0.reg" $R0
							${If} $R0 != 0
								WriteINIStr "$DATADIRECTORY\_FailedRegistryKeys.ini" "FailedRegistryKeys" $0 "true"
								${DebugMsg} "Failed to load $DATADIRECTORY\settings\$0.reg into the registry."
							${EndIf}
						${EndIf}
					${EndIf}
				${EndForEachINIPair}

				;=== RegistryValueBackupDelete {{{4
				StrCpy $0 1
				${Do}
					ClearErrors
					${ReadLauncherConfig} $1 RegistryValueBackupDelete $0
					${IfThen} ${Errors} ${|} ${ExitDo} ${|}
					${DebugMsg} "Backing up registry value $1\$2 to HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Values\$2"
					${GetParent} $0 $1
					${GetFilename} $0 $2
					${registry::MoveValue} $1 $2 "HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Values" $2 $R0
					IntOp $0 $0 + 1
				${Loop}

				;=== RegistryValueWrite {{{4
				${ForEachINIPair} "RegistryValueWrite" $0 $1
					${GetParent} $0 $2 ; key
					${GetFileName} $0 $3 ; item

					StrLen $4 $1
					StrCpy $5 "0"
					${Do}
						StrCpy $6 $1 1 $5
						${IfThen} $6 == ":" ${|} ${ExitDo} ${|}
						IntOp $5 $5 + 1
					${LoopUntil} $5 > $4

					${If} $6 == ":"
						StrCpy $4 $1 $5 ; type (e.g. REG_DWORD)
						IntOp $5 $5 + 1
						StrCpy $1 $1 "" $5 ; value
					${Else}
						StrCpy $4 "REG_SZ"
					${EndIf}

					${ParseLocations} $1

					${DebugMsg} "Writing '$1' (type '$4') to key '$2', value '$3'$\n(Short form: $2\$3=$4:$1)"
					; key item value type return
					${registry::Write} $2 $3 $1 $4 $R0
				${EndForEachINIPair}
			${EndIf}

		;=== Handle working directory {{{3
			ClearErrors
			${ReadLauncherConfig} $0 Launch SetOutPath
			${IfNot} ${Errors}
				${ParseLocations} $0
				${DebugMsg} "Setting working directory to $0."
				SetOutPath $0
			${EndIf}

		;=== Run it! {{{3
			${ReadLauncherConfig} $0 Launch RefreshShellIcons
			${If} $0 == "before"
			${OrIf} $0 == "both"
				${RefreshShellIcons}
			${EndIf}
			${DebugMsg} "About to execute the following string and wait till it's done: $EXECSTRING"
			${ReadLauncherConfig} $0 Launch HideCommandLineWindow
			${If} $0 == "true"
				ExecDos::exec $EXECSTRING
				Pop $0
			${Else}
				ExecWait $EXECSTRING
			${EndIf}
			${DebugMsg} "$EXECSTRING has finished."

		;=== Wait till it's done {{{3
			${ReadLauncherConfig} $0 Launch WaitForOtherInstances
			${If} $0 != "false"
				${DebugMsg} "Waiting till any other instances of $PROGRAMEXECUTABLE are finished."
				${Do}
					Sleep 1000
					FindProcDLL::FindProc $PROGRAMEXECUTABLE
				${LoopWhile} $R0 = 1
				${DebugMsg} "All instances of $PROGRAMEXECUTABLE are finished."
			${EndIf}

		;=== Remove custom TEMP directory {{{3
			${If} $USESCONTAINEDTEMPDIRECTORY != "false"
				${DebugMsg} "Removing contained temporary directory $TEMPDIRECTORY."
				RMDir /r $TEMPDIRECTORY
			${EndIf}

		;=== Remove Live TEMP directory (run locally) {{{3
			${If} $RUNLOCALLY == "true"
				${DebugMsg} "Removing Live mode directory $TEMP\$AppIDLive."
				RMDir /r $TEMP\$AppIDLive
			${EndIf}

		;=== Save portable files and restore any backed up files {{{3
			;=== FilesMove {{{4
			${ForEachINIPair} "FilesMove" $0 $1
				${ParseLocations} $1
				${GetFileName} $0 $2
				StrCpy $1 $1\$2

				${If} $RUNLOCALLY != "true"
					${DebugMsg} "Copying file from $1 to $DATADIRECTORY\$0"
					Delete "$DATADIRECTORY\$0"
					CopyFiles /SILENT $1 "$DATADIRECTORY\$0"
				${EndIf}
				${DebugMsg} "Removing portable settings file $1 from run location."
				Delete $1

				${IfNot} ${FileExists} "$1-BackupBy$AppID"
					${DebugMsg} "Moving local settings file from $1-BackupBy$AppID to $1"
					Rename "$1-BackupBy$AppID" $1
				${EndIf}
			${EndForEachINIPair}

			;=== DirectoriesMove {{{4
			${ForEachINIPair} "DirectoriesMove" $0 $1
				${ParseLocations} $1

				${If} $RUNLOCALLY != "true"
					${DebugMsg} "Copying settings from $1\*.* to $DATADIRECTORY\$0."
					RMDir /R "$DATADIRECTORY\$0"
					CreateDirectory $DATADIRECTORY\$0
					CopyFiles /SILENT "$1\*.*" "$DATADIRECTORY\$0"
				${EndIf}
				${DebugMsg} "Removing portable settings directory from run location ($1)."
				RMDir /R $1

				${If} ${FileExists} "$1-BackupBy$AppID"
					${DebugMsg} "Moving local settings from $1-BackupBy$AppID to $1."
					Rename "$1-BackupBy$AppID" $1
				${EndIf}
			${EndForEachINIPair}

			;=== DirectoriesCleanupIfEmpty {{{4
			StrCpy $0 1
			${Do}
				ClearErrors
				${ReadLauncherConfig} $1 DirectoriesCleanupIfEmpty $0
				${If} ${Errors}
					${ExitDo}
				${EndIf}
				${ParseLocations} $1
				${DebugMsg} "Cleaning up $1 if it is empty."
				RMDir $1
				IntOp $0 $0 + 1
			${Loop}

			;=== DirectoriesCleanupForce {{{4
			StrCpy $0 1
			${Do}
				ClearErrors
				${ReadLauncherConfig} $1 DirectoriesCleanupForce $0
				${If} ${Errors}
					${ExitDo}
				${EndIf}
				${ParseLocations} $1
				${DebugMsg} "Removing directory $1."
				RMDir /r $1
				IntOp $0 $0 + 1
			${Loop}

			;=== Save portable registry data and restore any backed up data {{{3
			${If} $USESREGISTRY == "true"
				;=== RegistryKeys {{{4
				${ForEachINIPair} "RegistryKeys" $0 $1
					ClearErrors
					ReadINIStr $R0 "$DATADIRECTORY\_FailedRegistryKeys.ini" "FailedRegistryKeys" $0
					${If} ${Errors} ; didn't fail
					${AndIf} $RUNLOCALLY != "true"
						${DebugMsg} "Saving registry key $1 to $DATADIRECTORY\settings\$0.reg."
						${registry::SaveKey} $1 "$DATADIRECTORY\settings\$0.reg" "" $R0
					${EndIf}

					${DebugMsg} "Deleting registry key $1."
					${registry::DeleteKey} $1 $R0
					${registry::KeyExists} "HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Keys\$0" $R0
					${If} $R0 != "-1"
						${DebugMsg} "Moving registry key HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Keys\$0 to $1."
						${registry::MoveKey} "HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Keys\$0" $1 $R0
						${registry::DeleteKeyEmpty} "HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Keys" $R0
						${registry::DeleteKeyEmpty} "HKEY_CURRENT_USER\Software\PortableApps.com\$AppID" $R0
						${registry::DeleteKeyEmpty} "HKEY_CURRENT_USER\Software\PortableApps.com" $R0
					${EndIf}
				${EndForEachINIPair}
				Delete "$DATADIRECTORY\_FailedRegistryKeys.ini"

				;=== RegistryValueBackupDelete {{{4
				StrCpy $0 1
				${Do}
					ClearErrors
					${ReadLauncherConfig} $1 RegistryValueBackupDelete $0
					${If} ${Errors}
						${ExitDo}
					${EndIf}
					${DebugMsg} "Deleting registry value $1\$2, then restoring from HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Values\$2"
					${GetParent} $0 $1
					${GetFilename} $0 $2
					${registry::DeleteValue} $1 $2 $R0
					${registry::MoveValue} "HKEY_CURRENT_USER\Software\PortableApps.com\$AppID\Values" $2 $1 $2 $R0
					IntOp $0 $0 + 1
				${Loop}

				;=== RegistryCleanupIfEmpty {{{4
				StrCpy $0 1
				${Do}
					ClearErrors
					${ReadLauncherConfig} $1 RegistryCleanupIfEmpty $0
					${If} ${Errors}
						${ExitDo}
					${EndIf}
					${DebugMsg} "Deleting registry key $1 if it is empty."
					${registry::DeleteKeyEmpty} $1 $R0
					IntOp $0 $0 + 1
				${Loop}

				;=== RegistryCleanupForce {{{4
				StrCpy $0 1
				${Do}
					ClearErrors
					${ReadLauncherConfig} $1 RegistryCleanupForce $0
					${If} ${Errors}
						${ExitDo}
					${EndIf}
					${DebugMsg} "Deleting registry key $1."
					${registry::DeleteKey} $1 $R0
					IntOp $0 $0 + 1
				${Loop}
			${EndIf}

			;=== RefreshShellIcons {{{3
			${ReadLauncherConfig} $0 Launch RefreshShellIcons
			${If} $0 == "after"
			${OrIf} $0 == "both"
				${RefreshShellIcons}
			${EndIf}
	;=== If secondary instance: launch and exit (existing launcher will clear up) {{{2
		${Else}
			ClearErrors
			${ReadLauncherConfig} $0 Launch SetOutPath
			${IfNot} ${Errors}
				${ParseLocations} $0
				${DebugMsg} "Setting working directory to $0."
				SetOutPath $0
			${EndIf}
			${DebugMsg} "About to execute the following string and finish: $EXECSTRING"
			Exec $EXECSTRING
		${EndIf}

	;=== Unload plug-ins {{{2
		${IfThen} $USESREGISTRY == "true" ${|} ${registry::Unload} ${|}

		${If} $DISABLESPLASHSCREEN != "true"
			newadvsplash::stop /WAIT
		${EndIf}
		; UAC.dll appears to no longer have Unload... but then we don't use /NOUNLOAD so it should be fine.
		;${IfThen} $RUNASADMIN == "true" ${|} UAC::Unload ${|}
SectionEnd ;}}}1

; This note is just as something out of interest.  With a SetOutDir directive, it could be worth while examining each command-line argument and turning relative paths into absolute paths, probably with the PathCombine call.  I've used an AutoHotkey implementation of it, but we'd need an NSIS one here.
;To combine paths $0 and $1: System::Call 'Shlwapi.dll::PathCombineA(t r0, t r1) t ."$DEST"'???
;PathCombine(dir, file) { ; Function taken from http://www.autohotkey.com/forum/topic19489-30.html#124252
;	VarSetCapacity(dest, 260, 1) ; MAX_PATH
;	DllCall("Shlwapi.dll\PathCombineA", "UInt", &dest, "UInt", &dir, "UInt", &file)
;	Return, dest
;}


; This file has been optimised for use in Vim with folding.
; (If you can't cope, :set nofoldenable) vim:foldenable:foldmethod=marker
