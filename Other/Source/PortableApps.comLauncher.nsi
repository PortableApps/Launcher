;Copyright 2004-2009 John T. Haller of PortableApps.com
;Copyright 2009 Chris Morgan of PortableApps.com

;Website: http://PortableApps.com

;This software is OSI Certified Open Source Software.
;OSI Certified is a certification mark of the Open Source Initiative.

;This program is free software; you can redistribute it and/or
;modify it under the terms of the GNU General Public License
;as published by the Free Software Foundation; either version 2
;of the License, or (at your option) any later version.

;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.

;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

;=== Program Details
!define VER "1.9.9.1"
Name "PortableApps.com Launcher"
OutFile "..\..\PortableApps.comLauncher.exe"
Caption "PortableApps.com Launcher"
VIProductVersion "${VER}"
VIAddVersionKey ProductName "PortableApps.com Launcher"
VIAddVersionKey Comments "A generic launcher for PortableApps.com applications, allowing applications to be run from a removable drive.  For additional details, visit PortableApps.com"
VIAddVersionKey CompanyName "PortableApps.com"
VIAddVersionKey LegalCopyright "PortableApps.com"
VIAddVersionKey FileDescription "PortableApps.com Launcher"
VIAddVersionKey FileVersion "${VER}"
VIAddVersionKey ProductVersion "${VER}"
VIAddVersionKey InternalName "PortableApps.com Launcher"
VIAddVersionKey LegalTrademarks "PortableApps.com is a Trademark of Rare Ideas, LLC."
VIAddVersionKey OriginalFilename "PortableApps.comLauncher.exe"
;VIAddVersionKey PrivateBuild ""
;VIAddVersionKey SpecialBuild ""
!undef VER

;=== Runtime Switches
CRCCheck On
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True
RequestExecutionLevel user

; Best Compression
SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On

;=== Include
;(Standard NSIS)
!include Registry.nsh
!include LogicLib.nsh
!include FileFunc.nsh
!insertmacro GetParameters
!insertmacro GetRoot
!include TextFunc.nsh
!insertmacro TrimNewLines

;(NSIS Plugins)
!include TextReplace.nsh

;(Custom)
!include ReplaceInFileWithTextReplace.nsh
!include ReadINIStrWithDefault.nsh
!include StrReplace.nsh

;=== Program Icon
Icon "..\..\App\AppInfo\appicon.ico"

;=== Languages
!define LAUNCHERLANGUAGE "English"

LoadLanguageFile "${NSISDIR}\Contrib\Language files\${LAUNCHERLANGUAGE}.nlf"
!include PortableApps.comLauncherLANG_${LAUNCHERLANGUAGE}.nsh

Var ADDITIONALPARAMETERS
Var EXECSTRING
Var DISABLESPLASHSCREEN
Var LASTDRIVE
Var CURRENTDRIVE
Var SECONDARYLAUNCH
Var FAILEDTORESTOREKEY
Var MISSINGFILEORPATH
Var INDEX
Var NAME
Var PORTABLEAPPNAME
Var APPNAME
Var PROGRAMDIRECTORY
Var PROGRAMEXECUTABLE
Var PORTABLEAPPSDOCUMENTSDIRECTORY
Var PORTABLEAPPSPICTURESDIRECTORY
Var PORTABLEAPPSMUSICDIRECTORY
Var PORTABLEAPPSVIDEOSDIRECTORY

!macro ParseLocations VAR
	${StrReplace} "${VAR}" "$$DATADIR" "$EXEDIR\Data" "${VAR}"
	${StrReplace} "${VAR}" "$$PROGRAMDIR" "$EXEDIR\App\$PROGRAMDIRECTORY" "${VAR}"
	${StrReplace} "${VAR}" "$$APPDATA" "$APPDATA" "${VAR}"
	${StrReplace} "${VAR}" "$$DRIVE" "$CURRENTDRIVE" "${VAR}"
	${StrReplace} "${VAR}" "$$PORTABLEAPPSDOCUMENTSDIR" "$PORTABLEAPPSDOCUMENTSDIRECTORY" "${VAR}"
	${StrReplace} "${VAR}" "$$PORTABLEAPPSPICTURESDIR" "$PORTABLEAPPSPICTURESDIRECTORY" "${VAR}"
	${StrReplace} "${VAR}" "$$PORTABLEAPPSMUSICDIR" "$PORTABLEAPPSMUSICDIRECTORY" "${VAR}"
	${StrReplace} "${VAR}" "$$PORTABLEAPPSVIDEOSDIR" "$PORTABLEAPPSVIDEOSDIRECTORY" "${VAR}"
!macroend

!define ParseLocations "!insertmacro ParseLocations"

Section "Main"
	;=== Prepare variables for ParseLocations and other usage
		;=== Get the current drive
		${GetRoot} $EXEDIR $CURRENTDRIVE

		ReadEnvStr $PORTABLEAPPSDOCUMENTSDIRECTORY PortableApps.comDocuments
		${IfNotThen} ${FileExists} $PORTABLEAPPSDOCUMENTSDIRECTORY ${|} StrCpy $PORTABLEAPPSDOCUMENTSDIRECTORY "$CURRENTDRIVE\Documents" ${|}

		ReadEnvStr $PORTABLEAPPSPICTURESDIRECTORY PortableApps.comPictures
		${IfNotThen} ${FileExists} $PORTABLEAPPSPICTURESDIRECTORY ${|} StrCpy $PORTABLEAPPSPICTURESDIRECTORY "$PORTABLEAPPSDOCUMENTSDIRECTORY\Pictures" ${|}

		ReadEnvStr $PORTABLEAPPSMUSICDIRECTORY PortableApps.comMusic
		${IfNotThen} ${FileExists} $PORTABLEAPPSMUSICDIRECTORY ${|} StrCpy $PORTABLEAPPSMUSICDIRECTORY "$PORTABLEAPPSDOCUMENTSDIRECTORY\Music" ${|}

		ReadEnvStr $PORTABLEAPPSVIDEOSDIRECTORY PortableApps.comVideos
		${IfNotThen} ${FileExists} $PORTABLEAPPSVIDEOSDIRECTORY ${|} StrCpy $PORTABLEAPPSVIDEOSDIRECTORY "$PORTABLEAPPSDOCUMENTSDIRECTORY\Videos" ${|}

	;=== Load launcher details
	ClearErrors
	ReadINIStr $NAME "$EXEDIR\App\Launcher\launcher.ini" "AppDetails" "PortableAppShortName"
	ReadINIStr $PORTABLEAPPNAME "$EXEDIR\App\AppInfo\appinfo.ini" "Details" "Name"
	ReadINIStr $APPNAME "$EXEDIR\App\Launcher\launcher.ini" "AppDetails" "AppLongName" ; for $(LauncherAlreadyRunning)
	ReadINIStr $PROGRAMDIRECTORY "$EXEDIR\App\Launcher\launcher.ini" "AppDetails" "ProgramDirectory"
	ReadINIStr $PROGRAMEXECUTABLE "$EXEDIR\App\Launcher\launcher.ini" "AppDetails" "ProgramExecutable"

	${If} ${Errors}
		;=== Launcher file missing or missing crucial details
		StrCpy $PORTABLEAPPNAME "PortableApps.com Launcher"
		StrCpy $MISSINGFILEORPATH "App\Launcher\launcher.ini"
		MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherFileNotFound)`
		Abort
	${EndIf}

	;=== Set up environment variables
		; $0 = file handle
		; $1 = line
		; $2 = length of line
		; $3 = character number of line
		; $4 = character
		; $5 = environment variable name
		; $6 = environment variable value
		FileOpen $0 $EXEDIR\App\Launcher\launcher.ini r
		${Do}
			FileRead $0 $1
			${TrimNewLines} $1 $1
			${If} ${Errors} ; end of file
			${OrIf} $1 == "[Environment]" ; right section
				${ExitDo}
			${EndIf}
		${Loop}

		${IfNot} ${Errors} ; right section
			${Do}
				FileRead $0 $1

				StrCpy $2 $1 1
				${If} ${Errors} ; end of file
				${OrIf} $2 == '[' ; new section
					${ExitDo} ; finished
				${EndIf}

				StrLen $2 $1
				StrCpy $3 '0'
				${Do}
					StrCpy $4 $1 1 $3
					${IfThen} $4 == '=' ${|} ${ExitDo} ${|}
					IntOp $3 $3 + 1
				${LoopUntil} $3 > $2

				${TrimNewLines} $1 $1

				${If} $4 == '='
					StrCpy $5 $1 $3
					IntOp $3 $3 + 1
					StrCpy $6 $1 "" $3
					${ParseLocations} $6

					;=== Now see if we need to prepend, append or change.
					StrCpy $7 $6 3 ; first three characters
					${If} $7 == "{&}" ; append
						ReadEnvStr $7 $5
						StrCpy $6 $6 "" 3
						System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i(r5, "$7$6").n'
					${Else}
						StrCpy $7 $6 "" -3 ; last three characters
						${If} $7 == "{&}" ; prepend
							ReadEnvStr $7 $5
							StrCpy $6 $6 -3
							System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i(r5, "$6$7").n'
						${Else} ; change
							System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i(r5, r6).n'
						${EndIf}
					${EndIf}
					ReadEnvStr $9 $5
				${EndIf}
			${Loop}
		${EndIf}
		FileClose $0

	;=== Check if already running
	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "$0") i .r1 ?e'
	Pop $0
	${IfNotThen} $0 = 0 ${|} StrCpy $SECONDARYLAUNCH "true" ${|}

	;=== Read the user customisations INI file
		${ReadINIStrWithDefault} $ADDITIONALPARAMETERS "$EXEDIR\$NAME.ini" "$NAME" "AdditionalParameters" ""
		${ReadINIStrWithDefault} $DISABLESPLASHSCREEN "$EXEDIR\$NAME.ini" "$NAME" "DisableSplashScreen" "false"

		${IfNot} ${FileExists} "$EXEDIR\App\$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE"
			;=== Program executable not where expected
			StrCpy $MISSINGFILEORPATH $PROGRAMEXECUTABLE
			MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherFileNotFound)`
			Abort
		${EndIf}

	;=== Check if already running
		FindProcDLL::FindProc "$PROGRAMEXECUTABLE"
		${If} $SECONDARYLAUNCH != "true"
		${AndIf} $R0 = 1
			MessageBox MB_OK|MB_ICONINFORMATION `$(LauncherAlreadyRunning)`
			Abort
		${EndIf}

	;=== Check for settings
		${IfNot} ${FileExists} "$EXEDIR\Data\settings\*.*"
			CreateDirectory "$EXEDIR\Data"
			${IfNot} ${FileExists} $EXEDIR\App\DefaultData\*.*
				CopyFiles /SILENT $EXEDIR\App\DefaultData\*.* $EXEDIR\Data
			${EndIf}
		${EndIf}

	;=== Update the drive letter in files
		ReadINIStr $LASTDRIVE "$EXEDIR\Data\settings\$NAMESettings.ini" "$NAMESettings" "LastDrive"
		${If} $LASTDRIVE != $CURRENTDRIVE
			StrCpy $INDEX 1
			${Do}
				ClearErrors
				ReadINIStr $1 "$EXEDIR\App\Launcher\launcher.ini" "DriveLetterUpdate" "File$INDEX"
				${If} ${Errors}
					${ExitDo}
				${EndIf}
				${ParseLocations} $1
				${If} ${FileExists} "$EXEDIR\Data\settings\$1"
				${AndIf} $LASTDRIVE != $CURRENTDRIVE
					${ReplaceInFile} "$EXEDIR\Data\settings\$1" "$LASTDRIVE\" "$CURRENTDRIVE\"
					Delete "$EXEDIR\Data\settings\$1.oldReplaceInFile"
				${EndIf}
				IntOp $INDEX $INDEX + 1
			${Loop}

			StrCpy $INDEX 1
			${Do}
				ClearErrors
				ReadINIStr $1 "$EXEDIR\App\Launcher\launcher.ini" "Registry" "Key$INDEX"
				${If} ${Errors}
					${ExitDo}
				${EndIf}

				${ReadINIStrWithDefault} $2 "$EXEDIR\App\Launcher\launcher.ini" "Registry" "Key$INDEXFilename" "$NAME.$INDEX"

				${IfNot} ${FileExists} "$EXEDIR\Data\settings\$2.reg"
				${AndIf} $LASTDRIVE != $CURRENTDRIVE
					${ReplaceInFile} "$EXEDIR\Data\settings\$2.reg" "$LASTDRIVE\" "$CURRENTDRIVE\"
					Delete "$EXEDIR\Data\settings\$2.reg.oldReplaceInFile"
				${EndIf}

				IntOp $INDEX $INDEX + 1
			${Loop}

			WriteINIStr "$EXEDIR\Data\settings\$NAMESettings.ini" "$NAMESettings" "LastDrive" "$CURRENTDRIVE"
		${EndIf}

	;=== Display splash screen
		${If} $DISABLESPLASHSCREEN != "true"
			;=== Show the splash screen before processing the files
			newadvsplash::show /NOUNLOAD 1500 200 0 -1 /L $EXEDIR\App\Launcher\splash.jpg
		${EndIf}

	;=== Construct the execution string
		StrCpy $EXECSTRING `"$EXEDIR\App\$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE"$0`

		;=== Get any default parameters
		ClearErrors
		ReadINIStr $0 "$EXEDIR\App\Launcher\launcher.ini" "LaunchDetails" "DefaultCommandLineArguments"
		${IfNot} ${Errors}
			${ParseLocations} $0
			StrCpy $EXECSTRING "$EXECSTRING $0"
		${EndIf}

		;=== Get any passed parameters
		${GetParameters} $0
		${If} $0 != ""
			StrCpy $EXECSTRING "$EXECSTRING $0"
		${EndIf}

	;=== Get additional parameters from user INI file
		${If} $ADDITIONALPARAMETERS != ""
			;=== Additional Parameters
			StrCpy $EXECSTRING "$EXECSTRING $ADDITIONALPARAMETERS"
		${EndIf}

	;=== Backup local data and insert portable data
		${If} $SECONDARYLAUNCH != "true"
			StrCpy $INDEX 1
			${Do}
				ClearErrors
				ReadINIStr $1 "$EXEDIR\App\Launcher\launcher.ini" "LocalFiles" "SourceDirectory$INDEX"
				ReadINIStr $2 "$EXEDIR\App\Launcher\launcher.ini" "LocalFiles" "TargetDirectory$INDEX"
				${If} ${Errors}
					${ExitDo}
				${EndIf}
				${ParseLocations} $2

				;=== Backup data from a local installation
				${IfNot} ${FileExists} "$2\$1-BackupBy$NAME"
					${If} ${FileExists} "$2\$1"
						Rename "$2\$1" "$2\$1-BackupBy$NAME"
						Sleep 100
					${EndIf}
				${EndIf}
				CreateDirectory $2
				${If} ${FileExists} "$EXEDIR\Data\$1\*.*"
					CopyFiles /SILENT "$EXEDIR\Data\$1" $2
				${EndIf}
				IntOp $INDEX $INDEX + 1
			${Loop}

			StrCpy $INDEX 1
			${Do}
				ClearErrors
				ReadINIStr $1 "$EXEDIR\App\Launcher\launcher.ini" "Registry" "Key$INDEX"
				${If} ${Errors}
					${ExitDo}
				${EndIf}

				${ReadINIStrWithDefault} $2 "$EXEDIR\App\Launcher\launcher.ini" "Registry" "Key$INDEXFilename" "$NAME.$INDEX"

				;=== Backup the registry
				${registry::KeyExists} "$1-BackupBy$NAME" $R0
				${If} $R0 != "0"
					${registry::KeyExists} "$1" $R0
					${If} $R0 != "-1"
						${registry::MoveKey} "$1" "$1-BackupBy$NAME" $R0
						Sleep 100
					${EndIf}
				${EndIf}

				${If} ${FileExists} "$EXEDIR\Data\settings\$2.reg"
					SetErrors
					${If} ${FileExists} "$WINDIR\system32\reg.exe"
						nsExec::ExecToStack `"$WINDIR\system32\reg.exe" import "$EXEDIR\Data\settings\$2.reg"`
						Pop $R0
						${IfThen} $R0 = 0 ${|} ClearErrors ${|}
					${EndIf}

					${If} ${Errors}
						${registry::RestoreKey} "$EXEDIR\Data\settings\$2.reg" $R0
						${IfThen} $R0 != 0 ${|} StrCpy $FAILEDTORESTOREKEY "true" ${|}
					${EndIf}
				${EndIf}

				IntOp $INDEX $INDEX + 1
			${Loop}

		;=== Run it!
			ClearErrors
			ReadINIStr $0 "$EXEDIR\App\Launcher\launcher.ini" "LaunchDetails" "SetOutPath"
			${IfNot} ${Errors}
				${ParseLocations} $0
				SetOutPath $0
			${EndIf}
			${ReadINIStrWithDefault} $0 "$EXEDIR\App\Launcher\launcher.ini" "LaunchDetails" "AssignContainedTempDirectory" "false"
			${If} $0 == "true"
				${If} ${FileExists} $TEMP\$NAMETemp
					RMDir /r $TEMP\$NAMETemp
				${EndIf}
				CreateDirectory $TEMP\$NAMETemp
				System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("TEMP", "$TEMP\$NAMETemp").n'
				System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("TMP", "$TEMP\$NAMETemp").n'
			${EndIf}
			ExecWait $EXECSTRING

		;=== Wait till it's done
			${Do}
				Sleep 1000
				FindProcDLL::FindProc "$PROGRAMEXECUTABLE"
			${LoopWhile} $R0 = 1

		;=== Remove custom TEMP directory
			${ReadINIStrWithDefault} $0 "$EXEDIR\App\Launcher\launcher.ini" "LaunchDetails" "AssignContainedTempDirectory" "false"
			${If} $0 == "true"
				RMDir /r $TEMP\$NAMETemp
			${EndIf}

		;=== Save portable settings and restore any backed up settings
		StrCpy $INDEX 1
		${Do}
			ClearErrors
			ReadINIStr $1 "$EXEDIR\App\Launcher\launcher.ini" "LocalFiles" "SourceDirectory$INDEX"
			ReadINIStr $2 "$EXEDIR\App\Launcher\launcher.ini" "LocalFiles" "TargetDirectory$INDEX"
			${If} ${Errors}
				${ExitDo}
			${EndIf}
			${ParseLocations} $2

			RMDir /R "$EXEDIR\Data\$1"
			CreateDirectory $EXEDIR\Data\$1
			CopyFiles /SILENT "$2\$1" "$EXEDIR\Data"
			RMDir /R $2
			Sleep 100

			${If} ${FileExists} "$2\$1-BackupBy$NAME"
				Rename "$2\$1-BackupBy$NAME" "$2\$1"
			${EndIf}

			IntOp $INDEX $INDEX + 1
		${Loop}

		StrCpy $INDEX 1
		${Do}
			ClearErrors
			ReadINIStr $1 "$EXEDIR\App\Launcher\launcher.ini" "LocalFiles" "Cleanup$INDEX"
			${If} ${Errors}
				${ExitDo}
			${EndIf}
			${ParseLocations} $1
			RMDir $INDEX
			IntOp $INDEX $INDEX + 1
		${Loop}

		StrCpy $INDEX 1
		${Do}
			ClearErrors
			ReadINIStr $1 "$EXEDIR\App\Launcher\launcher.ini" "Registry" "Key$INDEX"
			${If} ${Errors}
				${ExitDo}
			${EndIf}

			${ReadINIStrWithDefault} $2 "$EXEDIR\App\Launcher\launcher.ini" "Registry" "Key$INDEXFilename" "$NAME.$INDEX"

			${If} $FAILEDTORESTOREKEY != "true"
				${registry::SaveKey} $1 "$EXEDIR\Data\settings\$2.reg" "" $R0
				Sleep 100
			${EndIf}

			${registry::DeleteKey} $1 $R0
			${registry::KeyExists} "$1-BackupBy$NAME" $R0
			${If} $R0 != "-1"
				${registry::MoveKey} "$1-BackupBy$NAME" $1 $R0
				Sleep 100
			${EndIf}

			IntOp $INDEX $INDEX + 1
		${Loop}

		StrCpy $INDEX 1
		${Do}
			ClearErrors
			ReadINIStr $1 "$EXEDIR\App\Launcher\launcher.ini" "Registry" "Cleanup$INDEX"
			${If} ${Errors}
				${ExitDo}
			${EndIf}
			${registry::DeleteKeyEmpty} $INDEX $R0
			IntOp $INDEX $INDEX + 1
		${Loop}

		${registry::Unload}
		newadvsplash::stop /WAIT
		;=== Done!
	${Else}
		;=== Already running: launch and exit (existing launcher will clear up)
		ClearErrors
		ReadINIStr $0 "$EXEDIR\App\Launcher\launcher.ini" "LaunchDetails" "SetOutPath"
		${IfNot} ${Errors}
			${ParseLocations} $0
			SetOutPath $0
		${EndIf}
		Exec $EXECSTRING
	${EndIf}
SectionEnd
