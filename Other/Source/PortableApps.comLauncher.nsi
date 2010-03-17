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
Icon ..\..\App\AppInfo\appicon.ico

;=== Languages {{{1
${!echo} "Loading language strings..."
!macro IncludeLang _LANG
	LoadLanguageFile "${NSISDIR}\Contrib\Language files\${_LANG}.nlf"
	!insertmacro LANGFILE_INCLUDE_WITHDEFAULT Languages\${_LANG}.nsh Languages\English.nsh
!macroend
!define IncludeLang "!insertmacro IncludeLang"
${IncludeLang} English
${IncludeLang} Dutch
${IncludeLang} French
${IncludeLang} German
${IncludeLang} Italian
${IncludeLang} Japanese
${IncludeLang} SimpChinese

;=== Variables {{{1
${!echo} "Initialising variables and macros..."
Var AppID
Var BaseName
Var MissingFileOrPath
Var AppNamePortable
Var AppName
Var ProgramExecutable

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
			!define _DebugMsg_Seg "$\n$\nSegment: ${Segment}$\nHook: ${Hook}"
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

Function .onInit ;{{{1
	${RunSegment} Core .onInit
	${RunSegment} Temp .onInit
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
	${RunSegment} WorkingDirectory PreExec
	${If} $SecondaryLaunch != true
		;=== Run PreExecPrimary segments
		${RunSegment} SplashScreen PreExecPrimary
	${Else}
		;=== Run PreExecSecondary segments
		;${RunSegment} * PreExecSecondary
	${EndIf}
SectionEnd

Section Execute  ;{{{1
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
