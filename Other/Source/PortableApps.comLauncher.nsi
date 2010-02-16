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
;!define DEBUG_ALL ; Debug all segments
;!define DEBUG_SEGMENT_[SegmentName] ; debug this segment
!searchparse /file ..\..\App\AppInfo\appinfo.ini "PackageVersion=" VER
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
!include WordFunc.nsh

;(NSIS Plugins) {{{2
!include TextReplace.nsh
!addplugindir Plugins

;(Custom) {{{2
!include ReplaceInFileWithTextReplace.nsh
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

; Macro: print a debug message {{{1
!macro DebugMsg _MSG
	!ifdef DEBUG_ALL
		!define _DebugMsg_DEBUG
	!else
		!ifdef Segment
			!ifdef DEBUG_SEGMENT_${Segment}
				!define _DebugMsg_DEBUG
			!endif
		!else
			!define _DebugMsg_DEBUG
		!endif
	!endif
	!ifdef _DebugMsg_DEBUG
		MessageBox MB_OKCANCEL|MB_ICONINFORMATION "Debug message in ${__FILE__} line ${__LINE__}:$\n$\n${_MSG}" IDOK +2
			Abort ; not using IfCmd as it causes trouble with ' in _MSG
		!undef _DebugMsg_DEBUG
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
	${RunSegment} LauncherLanguage .onInit
	${RunSegment} RunAsAdmin .onInit
FunctionEnd

Section Init     ;{{{1
	${RunSegment} Core Init
	${RunSegment} DriveLetter Init
	${RunSegment} Variables Init
	${RunSegment} Registry Init
	${RunSegment} Java Init
	${RunSegment} Mutex Init
	${RunSegment} RunLocally Init
	${RunSegment} Temp Init
	${RunSegment} InstanceManagement Init
	${RunSegment} SplashScreen Init
	${RunSegment} RefreshShellIcons Init
SectionEnd

Section Pre      ;{{{1
	${RunSegment} RunLocally Pre
	${RunSegment} Temp Pre
	${RunSegment} Environment Pre
	${RunSegment} ExecString Pre
	${If} $SecondaryLaunch != true
		;=== Run PrePrimary segments
		${RunSegment} Settings PrePrimary
		${RunSegment} DriveLetter PrePrimary
		${RunSegment} FileWrite PrePrimary
		${RunSegment} FilesMove PrePrimary
		${RunSegment} DirectoriesMove PrePrimary
		${RunSegment} RegistryKeys PrePrimary
		${RunSegment} RegistryValueBackupDelete PrePrimary
		${RunSegment} RegistryValueWrite PrePrimary
		${RunSegment} Services PrePrimary
	${Else}
		;=== Run PreSecondary segments
		;${RunSegment} * PreSecondary
	${EndIf}
SectionEnd

Section PreExec  ;{{{1
	${RunSegment} RefreshShellIcons PreExec
	${RunSegment} SetOutPath PreExec
	${If} $SecondaryLaunch != true
		;=== Run PreExecPrimary segments
		${RunSegment} SplashScreen PreExecPrimary
	${Else}
		;=== Run PreExecSecondary segments
		;${RunSegment} * PreExecSecondary
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
				${If} $0 != ""
				${AndIf} ${ProcessExists} $0
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
		${RunSegment} Temp PostPrimary ; OK anywhere
		${RunSegment} Services PostPrimary
		${RunSegment} RegistryValueBackupDelete PostPrimary
		${RunSegment} RegistryKeys PostPrimary
		${RunSegment} RegistryCleanup PostPrimary
		${RunSegment} DirectoriesMove PostPrimary
		${RunSegment} FilesMove PostPrimary
		${RunSegment} DirectoriesCleanup PostPrimary
		${RunSegment} RunLocally PostPrimary
	${Else}
		;=== Run PostSecondary segments
		;${RunSegment} * PostSecondary
	${EndIf}
	${RunSegment} RefreshShellIcons Post
SectionEnd

Section Unload ;{{{1
	Call Unload
SectionEnd

Function .onInstFailed ;{{{1
	; If Abort is called
	Call Unload
FunctionEnd

Function Unload   ;{{{1
		${RunSegment} Registry Unload
		${RunSegment} SplashScreen Unload
		${RunSegment} Core Unload
FunctionEnd ;}}}1

; This file has been optimised for use in Vim with folding.
; (If you can't cope, :set nofoldenable) vim:foldenable:foldmethod=marker
