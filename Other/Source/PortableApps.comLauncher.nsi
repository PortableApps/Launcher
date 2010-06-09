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

!verbose 3

!ifndef PACKAGE
	!define PACKAGE ..\..
!endif

!macro !echo msg
	!verbose push
	!verbose 4
	!echo "${msg}"
	!verbose pop
!macroend
!define !echo "!insertmacro !echo"

;=== Require at least Unicode NSIS 2.46 {{{1
!ifndef NSIS_UNICODE
	!error "You must compile the PortableApps.com Launcher with Unicode NSIS."
!endif

!if ${NSIS_VERSION} == v2.45
	!error "The PortableApps.com Launcher requires Unicode NSIS 2.46 or later."
!else
	${!echo} "(If you get a compile error with !searchparse, please upgrade to Unicode NSIS 2.46 or later and try again.)"
!endif
!searchparse ${NSIS_VERSION} "v" V
!if ${V} < 2.46
	!error "You only have Unicode NSIS ${V}, but Unicode NSIS 2.46 or later is required for proper Windows 7 support. Please upgrade to Unicode NSIS 2.46 or later and try again."
!endif
!undef V

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
!include NewTextReplace.nsh
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

;=== Languages {{{1
${!echo} "Loading language strings..."
!include Languages.nsh

;=== Variables {{{1
${!echo} "Initialising variables and macros..."
Var AppID
Var BaseName
Var MissingFileOrPath
Var AppNamePortable
Var AppName
Var ProgramExecutable
Var WaitForProgram

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
	;ReadINIStr ${_OUTPUT} $EXEDIR\$BaseName.ini $BaseName ${_VALUE}
	${ConfigRead} $EXEDIR\$BaseName.ini ${_VALUE}= ${_OUTPUT}
!macroend
!define ReadUserOverrideConfig "!insertmacro ReadUserOverrideConfig"

; Load the segments {{{1
${!echo} "Loading segments..."
!include Segments.nsh

;=== Debugging {{{1
!include Debug.nsh

;=== Program Details {{{1
${!echo} "Specifying program details and setting options..."

!ifndef Version
	!searchparse /noerrors /file ..\..\App\AppInfo\appinfo.ini "PackageVersion=" Version
	!ifndef Version
		!define Version 1.9.90.2
		!ifndef NSIS_UNICODE
		!warning "Unable to get PortableApps.com Launcher version number from appinfo.ini; it should have a line PackageVersion=X.X.X.X in it. Used value ${Version} instead."
		!endif
	!endif
!endif

!ifndef AppID
	!searchparse /noerrors /file ${PACKAGE}\App\AppInfo\appinfo.ini "AppID=" AppID
	!ifndef AppID
		!define AppID PortableApps.comLauncher
		!warning "Unable to get AppID from appinfo.ini; it should have a line AppID=AppNamePortable in it. Used value ${AppID} instead."
	!endif
!endif

!ifndef Name
	!searchparse /noerrors /file ${PACKAGE}\App\AppInfo\appinfo.ini "Name=" Name
	!ifndef Name
		!define Name "PortableApps.com Launcher"
		!warning "Unable to get Name from appinfo.ini; it should have a line Name=App Name Portable in it. Used value ${Name} instead."
	!endif
!endif

!if "${Name}" == "PortableApps.com Launcher"
	!define Comments ""
!else
	!define Comments "  This is a custom build for ${Name} with Name and icon and possibly custom code."
!endif

Name "PortableApps.com Launcher"
OutFile "${PACKAGE}\${AppID}.exe"
Icon "${PACKAGE}\App\AppInfo\appicon.ico"
Caption "PortableApps.com Launcher"
VIProductVersion ${Version}
VIAddVersionKey ProductName "${Name}"
VIAddVersionKey Comments "A universal launcher for PortableApps.com applications, allowing applications to be run from a removable drive.${Comments}  For additional details, visit PortableApps.com"
VIAddVersionKey CompanyName PortableApps.com
VIAddVersionKey LegalCopyright PortableApps.com
VIAddVersionKey FileDescription "PortableApps.com Launcher"
VIAddVersionKey FileVersion ${Version}
VIAddVersionKey ProductVersion ${Version}
VIAddVersionKey InternalName "PortableApps.com Launcher"
VIAddVersionKey LegalTrademarks "PortableApps.com is a Trademark of Rare Ideas, LLC."
VIAddVersionKey OriginalFilename "${AppID}.exe"

!verbose 4

Function .onInit          ;{{{1
	${RunSegment} PortableApps.comLauncherCustom
	${RunSegment} Core
	${RunSegment} Temp
	${RunSegment} Language
	${RunSegment} RunAsAdmin
FunctionEnd

Function Init             ;{{{1
	${RunSegment} PortableApps.comLauncherCustom
	${RunSegment} Core
	${RunSegment} DriveLetter
	${RunSegment} Variables
	${RunSegment} Language
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
	; Users can override this function in PortableApps.comLauncherCustom.nsh
	; like this (see Segments.nsh for the OverrideExecute define):
	;
	;   ${OverrideExecute}
	;       [code to replace this function]
	;   !macroend

	!ifmacrodef OverrideExecuteFunction
		!insertmacro OverrideExecuteFunction
	!else
	${!getdebug}
	!ifdef DEBUG
		${If} $WaitForProgram != false
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
	${ElseIf} $WaitForProgram != false
		ExecWait $ExecString
	${Else}
		Exec $ExecString
	${EndIf}
	${DebugMsg} "$ExecString has finished."

	${If} $WaitForProgram != false
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
	!endif
FunctionEnd

Function PostPrimary      ;{{{1
	${RunSegment} Temp ; OK anywhere
	${RunSegment} Services
	${RunSegment} RegistryValueBackupDelete
	${RunSegment} RegistryKeys
	${RunSegment} RegistryCleanup
	${RunSegment} Qt
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
	ReadINIStr $R9 $EXEDIR\Data\PortableApps.comLauncherRuntimeData-$BaseName.ini PortableApps.comLauncher Status
	${If} $R9 != running
	${OrIf} $SecondaryLaunch == true
		${CallPS} Pre +
		${CallPS} PreExec +
		${If} $WaitForProgram != false
			WriteINIStr $DataDirectory\PortableApps.comLauncherRuntimeData-$BaseName.ini PortableApps.comLauncher Status running
		${EndIf}
		; File gets deleted in segment Core, hook Unload, so it'll only be "running"
		; in case of power-outage, disk removal while running or something like that.
		Call Execute
	${EndIf}
	${If} $WaitForProgram != false
		${CallPS} Post -
	${EndIf}
	Call Unload
SectionEnd

Function .onInstFailed ;{{{1
	; If Abort is called
	Call Unload
FunctionEnd ;}}}1

; This file has been optimised for use in Vim with folding.
; (If you can't cope, :set nofoldenable) vim:foldenable:foldmethod=marker
