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

;=== Debugging {{{1
; If you want to debug this, create PortableApps.comLauncherDebug.nsh.
; It should then have lines like these:
; · Debug everything
;     !define DEBUG_ALL
;   · This leaves out the "about to execute segment" and "finished executing
;     segment" messages unless you put this line in:
;       !define DEBUG_SEGWRAP
; · Debug just certain portions
;   · Debug outside any segments
;       !define DEBUG_GLOBAL
;   · Debug a given segment or segments
;       !define DEBUG_SEGMENT_[SegmentName]
!include /NONFATAL PortableApps.comLauncherDebug.nsh

;=== Program Details {{{1
!verbose 3
!macro !echo msg
	!verbose push
	!verbose 4
	!echo "${msg}"
	!verbose pop
!macroend
!define !echo "!insertmacro !echo"
${!echo} "Specifying program details and setting options..."
!searchparse /noerrors /file ..\..\App\AppInfo\appinfo.ini "PackageVersion=" VER
!ifndef VER
	!define VER 1.0.0.0
	!warning "Unable to get version number from appinfo.ini; it should have a line PackageVersion=X.X.X.X in it. Used value 1.0.0.0 instead."
!endif

!searchparse /noerrors /file ..\..\App\AppInfo\appinfo.ini "AppID=" AppID
!ifndef AppID
	!define AppID PortableApps.comLauncher
	!warning "Unable to get AppID from appinfo.ini; it should have a line AppID=AppNamePortable in it. Used value PortableApps.comLauncher instead."
!endif

!ifdef PACKAGE
	!define ROOT "${PACKAGE}"
!else
	!define ROOT ..\..
!else

Name "PortableApps.com Launcher"
OutFile ${ROOT}\${AppID}.exe
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
VIAddVersionKey OriginalFilename ${AppID}.exe
!undef VER

;=== Runtime Switches {{{1
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True
RequestExecutionLevel user
SetCompressor /SOLID lzma
SetCompressorDictSize 32

;=== Include {{{1
${!echo} "Including required files..."
;(Standard NSIS) {{{2
!include LangFile.nsh
!include LogicLib.nsh
!include FileFunc.nsh
!include TextFunc.nsh
!include WordFunc.nsh

;(NSIS Plugins) {{{2
!include TextReplace.nsh
!ifdef NSIS_UNICODE
	!addplugindir Plugins\U
!else
	!addplugindir Plugins\A
!endif

;(Custom) {{{2
!include ReplaceInFileWithTextReplace.nsh
!include ForEachINIPair.nsh
!include SetFileAttributesDirectoryNormal.nsh
!include ProcFunc.nsh
!include EmptyWorkingSet.nsh
!include SetEnvironmentVariable.nsh

;=== Program Icon {{{1
Icon ${ROOT}\App\AppInfo\appicon.ico

;=== Languages {{{1
${!echo} "Loading language strings..."
!ifdef NSIS_UNICODE
	!define LANG_DIR Languages\U
!else
	!define LANG_DIR Languages\A
!endif
!macro IncludeLang _LANG
	LoadLanguageFile "${NSISDIR}\Contrib\Language files\${_LANG}.nlf"
	!insertmacro LANGFILE_INCLUDE_WITHDEFAULT ${LANG_DIR}\${_LANG}.nsh ${LANG_DIR}\English.nsh
!macroend
!define IncludeLang "!insertmacro IncludeLang"
${IncludeLang} English
${IncludeLang} Dutch
${IncludeLang} French
${IncludeLang} German
${IncludeLang} Italian
${IncludeLang} Japanese
${IncludeLang} SimpChinese
!undef LANG_DIR

;=== Variables {{{1
${!echo} "Initialising variables and macros..."
Var AppID
Var BaseName
Var MissingFileOrPath
Var AppNamePortable
Var AppName
Var ProgramExecutable
Var Status

; Macro: check if in debug mode for the current section {{{1
!macro !IfDebug
	!ifdef DEBUG_ALL
		!define _!IfDebug_DEBUG
	!else
		!ifdef Segment
			!ifdef DEBUG_SEGMENT_${Segment}
				!define _!IfDebug_DEBUG
			!endif
		!else ifdef DEBUG_GLOBAL
			!define _!IfDebug_DEBUG
		!endif
	!endif
	!ifdef _!IfDebug_DEBUG
		!undef _!IfDebug_DEBUG
!macroend
!define !IfDebug "!insertmacro !IfDebug"

; Macro: print a debug message {{{1
!macro DebugMsg _MSG
	${!IfDebug}
		!ifdef Segment
			!define _DebugMsg_Seg "$\n$\nSegment: ${Segment}$\nHook: ${__FUNCTION__}"
		!else
			!define _DebugMsg_Seg ""
		!endif
		; ${__FILE__} is useless, always PortableApps.comLauncher.nsi
		MessageBox MB_OKCANCEL|MB_ICONINFORMATION "Debug message at line ${__LINE__}${_DebugMsg_Seg}$\n____________________$\n$\n${_MSG}" IDOK +2
			Abort
		!undef _DebugMsg_Seg
	!endif
!macroend
!define DebugMsg "!insertmacro DebugMsg"

; Macro: read a value from the launcher configuration file {{{1
!macro ReadLauncherConfig _OUTPUT _SECTION _VALUE
	ReadINIStr ${_OUTPUT} $LauncherFile ${_SECTION} ${_VALUE}
!macroend
!define ReadLauncherConfig "!insertmacro ReadLauncherConfig"

!macro ReadLauncherConfigWithDefault _OUTPUT _SECTION _VALUE _DEFAULT
	ClearErrors
	${ReadLauncherConfig} ${_OUTPUT} `${_SECTION}` `${_VALUE}`
	${IfThen} ${Errors} ${|} StrCpy ${_OUTPUT} `${_DEFAULT}` ${|}
!macroend
!define ReadLauncherConfigWithDefault "!insertmacro ReadLauncherConfigWithDefault"

!macro ReadUserOverrideConfig _OUTPUT _VALUE
	ReadINIStr ${_OUTPUT} $EXEDIR\$BaseName.ini $BaseName ${_VALUE}
!macroend
!define ReadUserOverrideConfig "!insertmacro ReadUserOverrideConfig"

${!echo} "Loading segments..."
!include Segments.nsh ;{{{1 Include all the code }}}
!verbose 4

Function .onInit          ;{{{1
	${RunSegment} PortableApps.comLauncherCustom
	${RunSegment} Core
	${RunSegment} Temp
	${RunSegment} LauncherLanguage
	${RunSegment} RunAsAdmin
FunctionEnd

Function Init             ;{{{1
	${RunSegment} PortableApps.comLauncherCustom
	${RunSegment} Core
	${RunSegment} DriveLetter
	${RunSegment} Variables
	${RunSegment} Registry
	${RunSegment} Java
	${RunSegment} Mutex
	${RunSegment} RunLocally
	${RunSegment} Temp
	${RunSegment} InstanceManagement
	${RunSegment} SplashScreen
	${RunSegment} RefreshShellIcons
FunctionEnd

Function Pre              ;{{{1
	${RunSegment} PortableApps.comLauncherCustom
	${RunSegment} RunLocally
	${RunSegment} Temp
	${RunSegment} Environment
	${RunSegment} ExecString
FunctionEnd

Function PrePrimary       ;{{{1
	${RunSegment} PortableApps.comLauncherCustom
	${RunSegment} Settings
	${RunSegment} DriveLetter
	${RunSegment} FileWrite
	${RunSegment} FilesMove
	${RunSegment} DirectoriesMove
	${RunSegment} RegistryKeys
	${RunSegment} RegistryValueBackupDelete
	${RunSegment} RegistryValueWrite
	${RunSegment} Services
FunctionEnd

Function PreSecondary     ;{{{1
	${RunSegment} PortableApps.comLauncherCustom
	;${RunSegment} *
FunctionEnd

Function PreExec          ;{{{1
	${RunSegment} PortableApps.comLauncherCustom
	${RunSegment} RefreshShellIcons
	${RunSegment} WorkingDirectory
FunctionEnd

Function PreExecPrimary   ;{{{1
	${RunSegment} PortableApps.comLauncherCustom
	${RunSegment} Core
	${RunSegment} SplashScreen
FunctionEnd

Function PreExecSecondary ;{{{1
	${RunSegment} PortableApps.comLauncherCustom
	;${RunSegment} *
FunctionEnd

Function Execute          ;{{{1
	${!IfDebug}
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
			${GetFileName} $ProgramExecutable $1
			${DebugMsg} "Waiting till any other instances of $1 and any [Launch]:WaitForEXE[N] values are finished."
			${EmptyWorkingSet}
			${Do}
				${ProcessWaitClose} $1 -1 $R9
				${IfThen} $R9 > 0 ${|} ${Continue} ${|}
				StrCpy $0 1
				${Do}
					ClearErrors
					${ReadLauncherConfig} $2 Launch WaitForEXE$0
					${IfThen} ${Errors} ${|} ${ExitDo} ${|}
					${ProcessWaitClose} $2 -1 $R9
					${IfThen} $R9 > 0 ${|} ${ExitDo} ${|}
					IntOp $0 $0 + 1
				${Loop}
			${LoopWhile} $R9 > 0
			${DebugMsg} "All instances are finished."
		${EndIf}
	${EndIf}
FunctionEnd

Function PostPrimary      ;{{{1
	${RunSegment} Temp ; OK anywhere
	${RunSegment} Services
	${RunSegment} RegistryValueBackupDelete
	${RunSegment} RegistryKeys
	${RunSegment} RegistryCleanup
	${RunSegment} DirectoriesMove
	${RunSegment} FilesMove
	${RunSegment} DirectoriesCleanup
	${RunSegment} RunLocally
	${RunSegment} PortableApps.comLauncherCustom
FunctionEnd

Function PostSecondary    ;{{{1
	;${RunSegment} *
	${RunSegment} PortableApps.comLauncherCustom
FunctionEnd

Function Post             ;{{{1
	${RunSegment} RefreshShellIcons
	${RunSegment} PortableApps.comLauncherCustom
FunctionEnd

Function Unload           ;{{{1
	${RunSegment} Registry
	${RunSegment} SplashScreen
	${RunSegment} Core
	${RunSegment} PortableApps.comLauncherCustom
FunctionEnd

; Call a segment-calling function with primary/secondary variants as well {{{1
!macro CallPS _func _rev
	!if ${_rev} == +
		Call ${_func}
	!endif
	${If} $SecondaryLaunch == true
		Call ${_func}Secondary
	${Else}
		Call ${_func}Primary
	${EndIf}
	!if ${_rev} != +
		Call ${_func}
	!endif
!macroend
!define CallPS `!insertmacro CallPS`

Section           ;{{{1
	Call Init
	ReadINIStr $Status $EXEDIR\Data\PortableApps.comLauncherRuntimeData.ini PortableApps.comLauncher Status
	${If} $Status != running
		${CallPS} Pre +
		${CallPS} PreExec +
		WriteINIStr $DataDirectory\PortableApps.comLauncherRuntimeData.ini PortableApps.comLauncher Status running
		; File gets deleted in segment Core, hook Unload, so it'll only be "running"
		; in case of power-outage, disk removal while running or something like that.
		Call Execute
	${EndIf}
	${CallPS} Post -
	Call Unload
SectionEnd

Function .onInstFailed ;{{{1
	; If Abort is called
	Call Unload
FunctionEnd ;}}}1

; This file has been optimised for use in Vim with folding.
; (If you can't cope, :set nofoldenable) vim:foldenable:foldmethod=marker
