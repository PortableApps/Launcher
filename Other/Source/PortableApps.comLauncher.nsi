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
!define VER "0.9.9.2"
Name "PortableApps.com Launcher"
OutFile ..\..\PortableApps.comLauncher.exe
Caption "PortableApps.com Launcher"
VIProductVersion ${VER}
VIAddVersionKey ProductName "PortableApps.com Launcher"
VIAddVersionKey Comments "A universal launcher for PortableApps.com applications, allowing applications to be run from a removable drive.  For additional details, visit PortableApps.com"
VIAddVersionKey CompanyName PortableApps.com
VIAddVersionKey LegalCopyright PortableApps.com
VIAddVersionKey FileDescription "PortableApps.com Launcher"
VIAddVersionKey FileVersion ${VER}
VIAddVersionKey ProductVersion ${VER}
VIAddVersionKey InternalName "PortableApps.com Launcher"
VIAddVersionKey LegalTrademarks "PortableApps.com is a Trademark of Rare Ideas, LLC."
VIAddVersionKey OriginalFilename PortableApps.comLauncher.exe
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
!addplugindir Plugins

;(Custom) {{{2
!include ReplaceInFileWithTextReplace.nsh
!include StrReplace.nsh
!include ForEachINIPair.nsh
!include SetFileAttributesDirectoryNormal.nsh
!include ProcFunc.nsh
!include EmptyWorkingSet.nsh

;=== Program Icon {{{1
Icon ..\..\App\AppInfo\appicon.ico

;=== Languages {{{1
!macro IncludeLang _LANG
	LoadLanguageFile "${NSISDIR}\Contrib\Language files\${_LANG}.nlf"
	!insertmacro LANGFILE_INCLUDE_WITHDEFAULT Languages\${_LANG}.nsh Languages\English.nsh
!macroend
!define IncludeLang "!insertmacro IncludeLang"
${IncludeLang} English
${IncludeLang} French
${IncludeLang} German
${IncludeLang} Italian
${IncludeLang} Japanese
${IncludeLang} SimpChinese

;=== Variables {{{1
Var AppID
Var MissingFileOrPath
Var AppNamePortable
Var AppName
Var ProgramExecutable

; Macro: generate strings for ParseLocations {{{1
!macro ParseLocations_SlashType VAR SLASHTYPE VARIABLEAPPENDAGE
	${StrReplace} "${VAR}" "%${SLASHTYPE}APPDIR%" "$${VARIABLEAPPENDAGE}APPDIRECTORY" "${VAR}"
	${StrReplace} "${VAR}" "%${SLASHTYPE}DATADIR%" "$${VARIABLEAPPENDAGE}DATADIRECTORY" "${VAR}"
	${If} $JavaMode == find
	${OrIf} $JavaMode == require
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
		${StrReplace} "${VAR}" %DRIVE% $CurrentDrive "${VAR}"
		!insertmacro ParseLocations_SlashType "${VAR}" "" ""
		!insertmacro ParseLocations_SlashType "${VAR}" / REPLACEVAR_FS_
		!insertmacro ParseLocations_SlashType "${VAR}" \\ REPLACEVAR_DBS_
		${If} $JavaMode == find
		${OrIf} $JavaMode == require
			!insertmacro ParseLocations_SlashType "${VAR}" java.util.prefs: REPLACEVAR_JUP_
		${EndIf}

	;===Languages {{{2
		${StrReplace} "${VAR}" %LANGCODE% $PORTABLEAPPSLANGUAGECODE "${VAR}"
		${StrReplace} "${VAR}" %LANGCODE2% $PORTABLEAPPSLOCALECODE2 "${VAR}"
		${StrReplace} "${VAR}" %LANGCODE3% $PORTABLEAPPSLOCALECODE3 "${VAR}"
		${StrReplace} "${VAR}" %LANGGLIBC% $PORTABLEAPPSLOCALEGLIBC "${VAR}"
		${StrReplace} "${VAR}" %LANGID% $PORTABLEAPPSLOCALEID "${VAR}"
		${StrReplace} "${VAR}" %LANGWINNAME% $PORTABLEAPPSLOCALEWINNAME "${VAR}"
	${DebugMsg} "After location parsing, $${VAR} = `${VAR}`"
!macroend
!define ParseLocations "!insertmacro ParseLocations"

; Macro: print a debug message {{{1
!macro DebugMsg _MSG
	!ifdef DEBUG
		MessageBox MB_OKCANCEL|MB_ICONINFORMATION "Debug message in ${__FILE__} line ${__LINE__}:$\n$\n${_MSG}" IDOK +2
			Abort ; not using IfCmd as it causes trouble with ' in _MSG
	!endif
!macroend
!define DebugMsg "!insertmacro DebugMsg"

; Macro: read a value from the launcher configuration file {{{1
!macro ReadLauncherConfig _OUTPUT _SECTION _VALUE
	ReadINIStr ${_OUTPUT} $EXEDIR\App\AppInfo\launcher.ini ${_SECTION} ${_VALUE}
!macroend
!define ReadLauncherConfig "!insertmacro ReadLauncherConfig"

!macro ReadLauncherConfigWithDefault _OUTPUT _SECTION _VALUE _DEFAULT
	ClearErrors
	${ReadLauncherConfig} ${_OUTPUT} `${_SECTION}` `${_VALUE}`
	${IfThen} ${Errors} ${|} StrCpy ${_OUTPUT} `${_DEFAULT}` ${|}
!macroend
!define ReadLauncherConfigWithDefault "!insertmacro ReadLauncherConfigWithDefault"

!macro ReadUserOverrideConfig _OUTPUT _VALUE
	ReadINIStr ${_OUTPUT} $EXEDIR\$AppID.ini PortableApps.comLauncher ${_VALUE}
!macroend
!define ReadUserOverrideConfig "!insertmacro ReadUserOverrideConfig"

!include Segments.nsh ;{{{1 Include all the code }}}

Function .onInit ;{{{1
	!insertmacro LauncherLanguage_.onInit
	!insertmacro RunAsAdmin_.onInit
FunctionEnd

Section Init     ;{{{1
	!insertmacro Core_Init
	!insertmacro DriveLetter_Init
	!insertmacro Variables_Init
	!insertmacro Registry_Init
	!insertmacro Java_Init
	!insertmacro Mutex_Init
	!insertmacro RunLocally_Init
	!insertmacro Temp_Init
	!insertmacro InstanceManagement_Init
	!insertmacro SplashScreen_Init
	!insertmacro RefreshShellIcons_Init
SectionEnd

Section Pre      ;{{{1
	!insertmacro RunLocally_Pre
	!insertmacro Temp_Pre
	!insertmacro Environment_Pre
	!insertmacro ExecString_Pre
	${If} $SecondaryLaunch != true
		;=== Run PrePrimary segments
		!insertmacro Settings_PrePrimary
		!insertmacro DriveLetter_PrePrimary
		!insertmacro FileWrite_PrePrimary
		!insertmacro FilesMove_PrePrimary
		!insertmacro DirectoriesMove_PrePrimary
		!insertmacro RegistryKeys_PrePrimary
		!insertmacro RegistryValueBackupDelete_PrePrimary
		!insertmacro RegistryValueWrite_PrePrimary
		!insertmacro Services_PrePrimary
	${Else}
		;=== Run PreSecondary segments
		;!insertmacro *_PreSecondary
	${EndIf}
SectionEnd

Section PreExec  ;{{{1
	!insertmacro RefreshShellIcons_PreExec
	!insertmacro SetOutPath_PreExec
	${If} $SecondaryLaunch != true
		;=== Run PreExecPrimary segments
		!insertmacro SplashScreen_PreExecPrimary
	${Else}
		;=== Run PreExecSecondary segments
		;!insertmacro *_PreExecSecondary
	${EndIf}
SectionEnd

Section Execute  ;{{{1
	!ifdef DEBUG
		${If} $SecondaryLaunch != true
			${DebugMsg} "About to execute the following string and wait till it's done: $ExecString"
		${Else}
			${DebugMsg} "About to execute the following string and finish: $ExecString"
		${EndIf}
	!endif
	${EmptyWorkingSet}
	${ReadLauncherConfig} $0 Launch HideCommandLineWindow
	${If} $0 == true
		; TODO: do this without a plug-in or at least some way it won't wait with secondary
		ExecDos::exec $ExecString
		Pop $0
	${ElseIf} $SecondaryLaunch != true
		ExecWait $ExecString
	${Else}
		Exec $ExecString
	${EndIf}
	${DebugMsg} "$ExecString has finished."

	${If} $SecondaryLaunch != true
		; Wait till it's done
		${ReadLauncherConfig} $0 Launch WaitForOtherInstances
		${If} $0 != false
			${ReadLauncherConfig} $0 Launch WaitForEXE
			${GetFileName} $ProgramExecutable $1
			${If} $0 != ""
				${DebugMsg} "Waiting till any other instances of $1 and $0 are finished."
			${Else}
				${DebugMsg} "Waiting till any other instances of $1 are finished."
			${EndIf}
			${EmptyWorkingSet}
			${Do}
				${If} ${ProcessExists} $0
					${ProcessWaitClose} $0 -1 $R9
				${ElseIf} ${ProcessExists} $1
					${ProcessWaitClose} $1 -1 $R9
				${Else}
					${Break}
				${EndIf}
			${Loop}
			${DebugMsg} "All instances are finished."
		${EndIf}
	${EndIf}
SectionEnd

Section Post     ;{{{1
	${If} $SecondaryLaunch != true
		;=== Run PostPrimary segments
		!insertmacro Temp_PostPrimary ; OK anywhere
		!insertmacro Services_PostPrimary
		!insertmacro RegistryValueBackupDelete_PostPrimary
		!insertmacro RegistryKeys_PostPrimary
		!insertmacro RegistryCleanup_PostPrimary
		!insertmacro DirectoriesMove_PostPrimary
		!insertmacro FilesMove_PostPrimary
		!insertmacro DirectoriesCleanup_PostPrimary
		!insertmacro RunLocally_PostPrimary
	${Else}
		;=== Run PostSecondary segments
		;!insertmacro *_PostSecondary
	${EndIf}
	!insertmacro RefreshShellIcons_Post
SectionEnd

Section Unload ;{{{1
	Call Unload
SectionEnd

Function .onInstFailed ;{{{1
	; If Abort is called
	Call Unload
FunctionEnd

Function Unload   ;{{{1
		!insertmacro Registry_Unload
		!insertmacro SplashScreen_Unload
		!insertmacro Core_Unload
FunctionEnd ;}}}1

; This file has been optimised for use in Vim with folding.
; (If you can't cope, :set nofoldenable) vim:foldenable:foldmethod=marker
