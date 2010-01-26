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
;!define DEBUG
!define VER "1.9.9.2"
Name "Chris's PortableApps.com Launcher Test"
OutFile "..\..\ChrisPortableApps.comLauncherTest.exe"
Caption "Chris's PortableApps.com Launcher Test"
VIProductVersion "${VER}"
VIAddVersionKey ProductName "Chris's PortableApps.com Launcher Test"
VIAddVersionKey Comments "A generic launcher for PortableApps.com applications, allowing applications to be run from a removable drive.  For additional details, read help.html or visit PortableApps.com"
VIAddVersionKey CompanyName "PortableApps.com"
VIAddVersionKey LegalCopyright "PortableApps.com"
VIAddVersionKey FileDescription "Chris's PortableApps.com Launcher Test"
VIAddVersionKey FileVersion "${VER}"
VIAddVersionKey ProductVersion "${VER}"
VIAddVersionKey InternalName "Chris's PortableApps.com Launcher Test"
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
!insertmacro ConfigWrite

;(NSIS Plugins)
!include TextReplace.nsh

;(Custom)
!include ReplaceInFileWithTextReplace.nsh
;!include ReadINIStrWithDefault.nsh
!include StrReplace.nsh
!include ForEachINIPair.nsh

;=== Program Icon
Icon "..\..\App\AppInfo\appicon.ico"

;=== Languages
!define LAUNCHERLANGUAGE "English"

LoadLanguageFile "${NSISDIR}\Contrib\Language files\${LAUNCHERLANGUAGE}.nlf"
!include PortableApps.comLauncherLANG_${LAUNCHERLANGUAGE}.nsh

Var EXECSTRING
Var LASTDRIVE
Var CURRENTDRIVE
Var SECONDARYLAUNCH ; also handles "don't wait for program"
Var MISSINGFILEORPATH
Var NAME
Var PORTABLEAPPNAME
Var APPNAME
Var PROGRAMDIRECTORY
Var PROGRAMEXECUTABLE
Var USINGJAVAEXECUTABLE
Var RUNLOCALLY
Var LAUNCHERINI

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

Var REPLACEVAR_FS_APPDIRECTORY
Var REPLACEVAR_FS_DATADIRECTORY
Var REPLACEVAR_FS_JAVADIRECTORY
Var REPLACEVAR_FS_ALLUSERSPROFILE
Var REPLACEVAR_FS_LOCALAPPDATA
Var REPLACEVAR_FS_APPDATA
Var REPLACEVAR_FS_DOCUMENTS
Var REPLACEVAR_FS_TEMPDIRECTORY
Var REPLACEVAR_FS_PORTABLEAPPSDOCUMENTSDIRECTORY
Var REPLACEVAR_FS_PORTABLEAPPSPICTURESDIRECTORY
Var REPLACEVAR_FS_PORTABLEAPPSMUSICDIRECTORY
Var REPLACEVAR_FS_PORTABLEAPPSVIDEOSDIRECTORY
Var REPLACEVAR_FS_PORTABLEAPPSDIRECTORY

Var REPLACEVAR_DBS_APPDIRECTORY
Var REPLACEVAR_DBS_DATADIRECTORY
Var REPLACEVAR_DBS_JAVADIRECTORY
Var REPLACEVAR_DBS_ALLUSERSPROFILE
Var REPLACEVAR_DBS_LOCALAPPDATA
Var REPLACEVAR_DBS_APPDATA
Var REPLACEVAR_DBS_DOCUMENTS
Var REPLACEVAR_DBS_TEMPDIRECTORY
Var REPLACEVAR_DBS_PORTABLEAPPSDOCUMENTSDIRECTORY
Var REPLACEVAR_DBS_PORTABLEAPPSPICTURESDIRECTORY
Var REPLACEVAR_DBS_PORTABLEAPPSMUSICDIRECTORY
Var REPLACEVAR_DBS_PORTABLEAPPSVIDEOSDIRECTORY
Var REPLACEVAR_DBS_PORTABLEAPPSDIRECTORY

!macro ParseLocations_SlashType VAR SLASHTYPE VARIABLEAPPENDAGE
	${StrReplace} "${VAR}" "%${SLASHTYPE}APPDIR%" "$${VARIABLEAPPENDAGE}APPDIRECTORY" "${VAR}"
	${StrReplace} "${VAR}" "%${SLASHTYPE}DATADIR%" "$${VARIABLEAPPENDAGE}DATADIRECTORY" "${VAR}"
	${StrReplace} "${VAR}" "%${SLASHTYPE}JAVADIR%" "$${VARIABLEAPPENDAGE}JAVADIRECTORY" "${VAR}"
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

!macro ParseLocations VAR
	${DebugMsg} "Before location parsing, $${VAR} = `${VAR}`"
	${StrReplace} "${VAR}" "$$DRIVE" "$CURRENTDRIVE" "${VAR}"
	!insertmacro ParseLocations_SlashType "${VAR}" "" ""
	!insertmacro ParseLocations_SlashType "${VAR}" "/" "REPLACEVAR_FS_"
	!insertmacro ParseLocations_SlashType "${VAR}" "\\" "REPLACEVAR_DBS_"
	${DebugMsg} "After location parsing, $${VAR} = `${VAR}`"
!macroend

!define ParseLocations "!insertmacro ParseLocations"

!macro DebugMsg _MSG
	!ifdef DEBUG
		MessageBox MB_OKCANCEL|MB_ICONINFORMATION "Debug message (line ${__LINE__}):$\n$\n${_MSG}" IDOK +2
			Abort ; not using IfCmd as it causes trouble with ' in _MSG
	!endif
!macroend

!define DebugMsg "!insertmacro DebugMsg"

Section "Main"
	${GetBaseName} $EXEFILE $NAME
	StrCpy $LAUNCHERINI "$EXEDIR\App\ChrisLauncher\$NAME.ini"
	${DebugMsg} "Launcher INI file is $LAUNCHERINI.$\nUser INI overrides are in $EXEDIR\$NAME.ini."
	;=== Initialise variables
		; NOTE: CURRENTDRIVE has an issue; it may need to refer to the app, data
		; or file locations; these could be two different drives in Live mode.
		; Which drive letter should we use?  Working on the running device, as
		; file locations (e.g. for MRU) seems most likely.
		ReadINIStr $LASTDRIVE "$EXEDIR\Data\settings\$NAMESettings.ini" "$NAMESettings" "LastDrive"
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

		ReadEnvStr $ALLUSERSPROFILE ALLUSERSPROFILE

	;=== Make forward slash and double backslash versions
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

	;=== Load launcher details
		ClearErrors
		ReadINIStr $PORTABLEAPPNAME $LAUNCHERINI "AppDetails" "PortableAppLongName"
		ReadINIStr $APPNAME $LAUNCHERINI "AppDetails" "AppLongName"
		ReadINIStr $PROGRAMDIRECTORY $LAUNCHERINI "AppDetails" "ProgramDirectory"
		ReadINIStr $PROGRAMEXECUTABLE $LAUNCHERINI "AppDetails" "ProgramExecutable"

		${If} ${Errors}
			;=== Launcher file missing or missing crucial details
			StrCpy $PORTABLEAPPNAME "Chris's PortableApps.com Launcher Test"
			StrCpy $MISSINGFILEORPATH $LAUNCHERINI
			MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherFileNotFound)`
			Abort
		${EndIf}

		StrCpy $JAVADIRECTORY "$PORTABLEAPPSDIRECTORY\CommonFiles\Java"
		${StrReplace} $REPLACEVAR_FS_JAVADIRECTORY "\" "/" $JAVADIRECTORY
		${StrReplace} $REPLACEVAR_DBS_JAVADIRECTORY "/" "\\" $REPLACEVAR_FS_JAVADIRECTORY
		${IfThen} $PROGRAMEXECUTABLE == "java.exe" ${|} StrCpy $USINGJAVAEXECUTABLE "true" ${|}
		${IfThen} $PROGRAMEXECUTABLE == "javaw.exe" ${|} StrCpy $USINGJAVAEXECUTABLE "true" ${|}

		ReadINIStr $0 $LAUNCHERINI "LaunchDetails" "RequiresJava"
		${If} $0 == "true"
		${AndIfNot} ${FileExists} $JAVADIRECTORY
			;=== Java Portable is missing - TODO support a local Java installation in some way
			StrCpy $MISSINGFILEORPATH "Java Portable"
			MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherFileNotFound)`
			Abort
		${EndIf}

	;=== Check if already running
		System::Call 'kernel32::CreateMutexA(i 0, i 0, t "$NAME") i .r1 ?e'
		Pop $0
		${IfNot} $0 = 0
			ReadINIStr $0 $LAUNCHERINI "LaunchDetails" "SinglePortableAppInstance"
			${If} $0 == "true"
				${DebugMsg} "Launcher already running and [LaunchDetails]->SingleInstance=true: aborting."
				Abort
			${EndIf}
			${DebugMsg} "Launcher already running: secondary launch."
			StrCpy $SECONDARYLAUNCH "true"
		${EndIf}

	;=== Read the user customisations INI file
		ReadINIStr $RUNLOCALLY "$EXEDIR\$NAME.ini" "$NAME" "RunLocally"

		${IfNot} ${FileExists} "$EXEDIR\App\$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE"
		${AndIfNot} $USINGJAVAEXECUTABLE == "true"
			;=== Program executable not where expected
			StrCpy $MISSINGFILEORPATH $PROGRAMEXECUTABLE
			MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherFileNotFound)`
			Abort
		${EndIf}

	;=== Check if already running
		ReadINIStr $0 $LAUNCHERINI "LaunchDetails" "SingleAppInstance"
		${If} $0 != "false"
		${AndIfNot} $USINGJAVAEXECUTABLE == "true"
			FindProcDLL::FindProc "$PROGRAMEXECUTABLE"
			${If} $SECONDARYLAUNCH != "true"
			${AndIf} $R0 = 1
				MessageBox MB_OK|MB_ICONINFORMATION `$(LauncherAlreadyRunning)`
				Abort
			${EndIf}
		${EndIf}

		ClearErrors
		ReadINIStr $0 $LAUNCHERINI "LaunchDetails" "CloseEXE"
		${IfNot} ${Errors}
			FindProcDLL::FindProc $0
			${If} $SECONDARYLAUNCH != "true"
			${AndIf} $R0 = 1
				MessageBox MB_OK|MB_ICONINFORMATION `$(LauncherAlreadyRunning)`
				Abort
			${EndIf}
		${EndIf}

	;=== Display splash screen
		ReadINIStr $0 "$EXEDIR\$NAME.ini" "$NAME" "DisableSplashScreen"
		${If} $0 != "true"
			;=== Show the splash screen before processing the files
			newadvsplash::show /NOUNLOAD 1500 200 0 -1 /L $EXEDIR\App\ChrisLauncher\$NAME.jpg
		${EndIf}

	;=== Wait for program?  *ONLY USE THIS IF THERE'LL BE NOTHING TO DO AFTERWARDS!
	; TODO: automatically work something out about this
		ReadINIStr $0 $LAUNCHERINI "LaunchDetails" "WaitForProgram"
		${If} $0 == "false"
			${DebugMsg} "WaitForProgram is set to false: SECONDARYLAUNCH set to true."
			StrCpy $SECONDARYLAUNCH "true"
		${EndIf}

	;=== Handle Live mode (run locally)
		${If} $RUNLOCALLY == "true"
			${DebugMsg} "Live mode enabled"
			ReadINIStr $0 $LAUNCHERINI "LiveMode" "CopyApp"
			${If} $0 != "false"
				${If} $SECONDARYLAUNCH != "true"
					${DebugMsg} "Live mode: copying $EXEDIR\App to $TEMP\$NAMELive\App"
					CreateDirectory $TEMP\$NAMELive
					CopyFiles /SILENT $EXEDIR\App $TEMP\$NAMELive
				${EndIf}
				StrCpy $APPDIRECTORY "$TEMP\$NAMELive\App"
			${EndIf}
			ReadINIStr $0 $LAUNCHERINI "LiveMode" "CopyData"
			${If} $0 != "false"
				${If} $SECONDARYLAUNCH != "true"
					${DebugMsg} "Live mode: copying $EXEDIR\Data to $TEMP\$NAMELive\Data"
					CreateDirectory $TEMP\$NAMELive
					CopyFiles /SILENT $EXEDIR\Data $TEMP\$NAMELive
				${EndIf}
				StrCpy $DATADIRECTORY "$TEMP\$NAMELive\Data"
			${EndIf}
		${Else}
			StrCpy $APPDIRECTORY "$EXEDIR\App"
			StrCpy $DATADIRECTORY "$EXEDIR\Data"
		${EndIf}

		${StrReplace} $REPLACEVAR_FS_APPDIRECTORY "\" "/" $APPDIRECTORY
		${StrReplace} $REPLACEVAR_DBS_APPDIRECTORY "/" "\\" $REPLACEVAR_FS_APPDIRECTORY
		${StrReplace} $REPLACEVAR_FS_DATADIRECTORY "\" "/" $DATADIRECTORY
		${StrReplace} $REPLACEVAR_DBS_DATADIRECTORY "/" "\\" $REPLACEVAR_FS_DATADIRECTORY

	;=== Check for settings
		${IfNot} ${FileExists} "$DATADIRECTORY\settings"
			${DebugMsg} "$DATADIRECTORY\settings does not exist. Creating it."
			CreateDirectory "$DATADIRECTORY\settings"
			${If} ${FileExists} $EXEDIR\App\DefaultData\*.*
				${DebugMsg} "Copying default data from $EXEDIR\App\DefaultData to $DATADIRECTORY."
				CopyFiles /SILENT $EXEDIR\App\DefaultData\*.* $DATADIRECTORY
			${EndIf}
		${EndIf}

	;=== Update the drive letter in files
		${If} $LASTDRIVE != $CURRENTDRIVE
			StrCpy $0 1
			${Do}
				ClearErrors
				ReadINIStr $1 $LAUNCHERINI "FileDriveLetterUpdate" "Backslash$0"
				${If} ${Errors}
					${ExitDo}
				${EndIf}
				${ParseLocations} $1
				${If} ${FileExists} $1
					${DebugMsg} "Updating drive letter from $LASTDRIVE to $CURRENTDRIVE in $1; using backslashes"
					${ReplaceInFile} "$DATADIRECTORY\$1" "$LASTDRIVE\" "$CURRENTDRIVE\"
					Delete "$1.oldReplaceInFile"
				${EndIf}
				IntOp $0 $0 + 1
			${Loop}

			${ForEachINIPair} "RegistryKeys" $0 $1
				${IfNot} ${FileExists} "$DATADIRECTORY\settings\$0.reg"
					${DebugMsg} "Updating drive letter from $LASTDRIVE to $CURRENTDRIVE in $DATADIRECTORY\settings\$1.reg"
					${ReplaceInFile} "$DATADIRECTORY\settings\$0.reg" "$LASTDRIVE\" "$CURRENTDRIVE\"
					Delete "$DATADIRECTORY\settings\$0.reg.oldReplaceInFile"
				${EndIf}
			${EndForEachINIPair}

			WriteINIStr "$DATADIRECTORY\settings\$NAMESettings.ini" "$NAMESettings" "LastDrive" "$CURRENTDRIVE"
		${EndIf}

	;=== Update the drive letter in files
		${If} $LASTDRIVE != $CURRENTDRIVE
			StrCpy $0 1
			${Do}
				ClearErrors
				ReadINIStr $1 $LAUNCHERINI "FileDriveLetterUpdate" "Forwardslash$0"
				${If} ${Errors}
					${ExitDo}
				${EndIf}
				${ParseLocations} $1
				${If} ${FileExists} $1
					${DebugMsg} "Updating drive letter from $LASTDRIVE to $CURRENTDRIVE in $1; using forward slashes"
					${ReplaceInFile} "$DATADIRECTORY\$1" "$LASTDRIVE/" "$CURRENTDRIVE/"
					Delete "$1.oldReplaceInFile"
				${EndIf}
				IntOp $0 $0 + 1
			${Loop}

			${ForEachINIPair} "RegistryKeys" $0 $1
				${IfNot} ${FileExists} "$DATADIRECTORY\settings\$0.reg"
					${DebugMsg} "Updating drive letter from $LASTDRIVE to $CURRENTDRIVE in $DATADIRECTORY\settings\$1.reg"
					${ReplaceInFile} "$DATADIRECTORY\settings\$0.reg" "$LASTDRIVE\" "$CURRENTDRIVE\"
					Delete "$DATADIRECTORY\settings\$0.reg.oldReplaceInFile"
				${EndIf}
			${EndForEachINIPair}

			WriteINIStr "$DATADIRECTORY\settings\$NAMESettings.ini" "$NAMESettings" "LastDrive" "$CURRENTDRIVE"
		${EndIf}

	;=== Write configuration values with ConfigWrite
		StrCpy $0 1
		${Do}
			ClearErrors
			ReadINIStr $1 $LAUNCHERINI "FileWriteConfigWrite" "$0File"
			ReadINIStr $2 $LAUNCHERINI "FileWriteConfigWrite" "$0Entry"
			ReadINIStr $3 $LAUNCHERINI "FileWriteConfigWrite" "$0Value"
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

	;=== Write configuration values with WriteINIStr
		StrCpy $0 1
		${Do}
			ClearErrors
			ReadINIStr $1 $LAUNCHERINI "FileWriteINI" "$0File"
			ReadINIStr $2 $LAUNCHERINI "FileWriteINI" "$0Section"
			ReadINIStr $3 $LAUNCHERINI "FileWriteINI" "$0Key"
			ReadINIStr $4 $LAUNCHERINI "FileWriteINI" "$0Value"
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

	;=== Construct the execution string
		${DebugMsg} "Constructing execution string"
		${If} $USINGJAVAEXECUTABLE != "true"
			StrCpy $EXECSTRING `"$APPDIRECTORY\$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE"`
		${Else}
			StrCpy $EXECSTRING `"$JAVADIRECTORY\bin\$PROGRAMEXECUTABLE"`
		${EndIf}
		${DebugMsg} "Execution string is $EXECSTRING"

		;=== Get any default parameters
		ClearErrors
		ReadINIStr $0 $LAUNCHERINI "LaunchDetails" "DefaultCommandLineArguments"
		${IfNot} ${Errors}
			${DebugMsg} "There are default command line arguments ($0).  Adding them to execution string after parsing."
			${ParseLocations} $0
			StrCpy $EXECSTRING "$EXECSTRING $0"
		${EndIf}

		;=== Get any passed parameters
		${GetParameters} $0
		${If} $0 != ""
			${DebugMsg} "Parameters were passed ($0).  Adding them to execution string."
			StrCpy $EXECSTRING "$EXECSTRING $0"
		${EndIf}

	;=== Get additional parameters from user INI file
		ReadINIStr $0 "$EXEDIR\$NAME.ini" "$NAME" "AdditionalParameters"
		${If} $0 != ""
			${DebugMsg} "The user has specified additional command line arguments ($0).  Adding them to execution string."
			StrCpy $EXECSTRING "$EXECSTRING $0"
		${EndIf}

		${DebugMsg} "Finished working with execution string: final value is $EXECSTRING"

	;=== Set up environment variables
		;Read INI pairs:   Section,    Key,Value
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
				;${Else} ; change
				${EndIf}
			${EndIf}
			${DebugMsg} "Changing environment variable $0 to $1"
			System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i(r0, r1).n'
		${EndForEachINIPair}

	;=== Backup local data and insert portable data
		${If} $SECONDARYLAUNCH != "true"
			${ForEachINIPair} "FilesMove" $0 $1
				${ParseLocations} $1

				${GetFileName} $0 $2

				StrCpy $1 $1\$2

				;=== Backup data from a local installation
				${IfNot} ${FileExists} "$1-BackupBy$NAME"
				${AndIf} ${FileExists} $1
					${DebugMsg} "Backing up $1 to $1-BackupBy$NAME"
					Rename $1 "$1-BackupBy$NAME"
				${EndIf}
				${If} ${FileExists} "$DATADIRECTORY\$0"
					${DebugMsg} "Copying $DATADIRECTORY\$0 to $1"
					CopyFiles /SILENT "$DATADIRECTORY\$0" $1
				${EndIf}
			${EndForEachINIPair}

			${ForEachINIPair} "DirectoriesMove" $0 $1
				${ParseLocations} $1

				;=== Backup data from a local installation
				${IfNot} ${FileExists} "$1-BackupBy$NAME"
				${AndIf} ${FileExists} "$1"
					${DebugMsg} "Backing up $1 to $1-BackupBy$NAME"
					Rename $1 "$1-BackupBy$NAME"
				${EndIf}
				CreateDirectory $1
				${If} ${FileExists} "$DATADIRECTORY\$0\*.*"
					${DebugMsg} "Copying $DATADIRECTORY\$0\*.* to $1\*.*"
					CopyFiles /SILENT "$DATADIRECTORY\$0\*.*" $1
				${Else}
					${DebugMsg} "$DATADIRECTORY\$0\*.* does not exist, so not copying it to $1.$\n(Note for developers: if you want default data, rememberto put files in App\DefaultData\$0)"
				${EndIf}
			${EndForEachINIPair}

			${ForEachINIPair} "RegistryKeys" $0 $1
				;=== Backup the registry
				${registry::KeyExists} "HKEY_CURRENT_USER\Software\PortableApps.com\$NAME\$0" $R0
				${If} $R0 != "0"
					${registry::KeyExists} $1 $R0
					${If} $R0 != "-1"
						${DebugMsg} "Backing up registry key $1 to HKEY_CURRENT_USER\Software\PortableApps.com\$NAME\$0"
						${registry::MoveKey} $1 "HKEY_CURRENT_USER\Software\PortableApps.com\$NAME\$0" $R0
					${EndIf}
				${EndIf}

				${If} ${FileExists} "$DATADIRECTORY\settings\$0.reg"
					SetErrors
					${DebugMsg} "Loading $DATADIRECTORY\settings\$0.reg into the registry."
					${If} ${FileExists} "$WINDIR\system32\reg.exe"
						;TODO: Check this works (should): old form: nsExec::ExecToStack `"$WINDIR\system32\reg.exe" import "$DATADIRECTORY\settings\$0.reg"`
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

			${ForEachINIPair} "RegistryKeyWrite" $0 $1
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


		;=== Run it!
			ClearErrors
			ReadINIStr $0 $LAUNCHERINI "LaunchDetails" "SetOutPath"
			${IfNot} ${Errors}
				${ParseLocations} $0
				${DebugMsg} "Setting working directory to $0."
				SetOutPath $0
			${EndIf}
			ReadINIStr $0 $LAUNCHERINI "LaunchDetails" "AssignContainedTempDirectory"
			${If} $0 == "true"
				${DebugMsg} "Creating contained temporary directory at $TEMP\$NAMETemp and setting environment variables $$TEMP and $$TMP to it."
				StrCpy $TEMPDIRECTORY "$TEMP\$NAMETemp"
				${If} ${FileExists} $TEMPDIRECTORY
					RMDir /r $TEMPDIRECTORY
				${EndIf}
				CreateDirectory $TEMPDIRECTORY
				System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("TEMP", "$TEMPDIRECTORY").n'
				System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("TMP", "$TEMPDIRECTORY").n'
			${Else}
				StrCpy $TEMPDIRECTORY $TEMP
			${EndIf}

			${StrReplace} $REPLACEVAR_FS_TEMPDIRECTORY "\" "/" $TEMPDIRECTORY
			${StrReplace} $REPLACEVAR_DBS_TEMPDIRECTORY "/" "\\" $REPLACEVAR_FS_TEMPDIRECTORY

			${DebugMsg} "About to execute the following string and wait till it's done: $EXECSTRING"
			ExecWait $EXECSTRING
			${DebugMsg} "$EXECSTRING has finished. Waiting till any other instances of $PROGRAMEXECUTABLE are finished."

		;=== Wait till it's done
			; TODO This won't work properly for Java applications...
			; I think we really need to have Java => !WaitForExecutable
			${Do}
				Sleep 1000
				FindProcDLL::FindProc "$PROGRAMEXECUTABLE"
			${LoopWhile} $R0 = 1

			${DebugMsg} "All instances of $PROGRAMEXECUTABLE are finished."

		;=== Remove custom TEMP directory
			ReadINIStr $0 $LAUNCHERINI "LaunchDetails" "AssignContainedTempDirectory"
			${If} $0 == "true"
				${DebugMsg} "Removing contained temporary directory $TEMPDIRECTORY."
				RMDir /r $TEMPDIRECTORY
			${EndIf}

		;=== Remove Live TEMP directory (run locally)
			${If} $RUNLOCALLY == "true"
				${DebugMsg} "Removing Live mode directory $TEMP\$NAMELive."
				RMDir /r $TEMP\$NAMELive
			${EndIf}

		;=== Save portable settings and restore any backed up settings
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

				${IfNot} ${FileExists} "$1-BackupBy$NAME"
					${DebugMsg} "Moving local settings file from $1-BackupBy$NAME to $1"
					Rename "$1-BackupBy$NAME" $1
				${EndIf}
			${EndForEachINIPair}

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

				${If} ${FileExists} "$1-BackupBy$NAME"
					${DebugMsg} "Moving local settings from $1-BackupBy$NAME to $1."
					Rename "$1-BackupBy$NAME" $1
				${EndIf}
			${EndForEachINIPair}

			StrCpy $0 1
			${Do}
				ClearErrors
				ReadINIStr $1 $LAUNCHERINI "DirectoriesCleanupIfEmpty" $0
				${If} ${Errors}
					${ExitDo}
				${EndIf}
				${ParseLocations} $1
				${DebugMsg} "Cleaning up $1 if it is empty."
				RMDir $1
				IntOp $0 $0 + 1
			${Loop}

			StrCpy $0 1
			${Do}
				ClearErrors
				ReadINIStr $1 $LAUNCHERINI "DirectoriesCleanupForce" $0
				${If} ${Errors}
					${ExitDo}
				${EndIf}
				${ParseLocations} $1
				${DebugMsg} "Removing directory $1."
				RMDir /r $1
				IntOp $0 $0 + 1
			${Loop}

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
				${registry::KeyExists} "HKEY_CURRENT_USER\Software\PortableApps.com\$NAME\$0" $R0
				${If} $R0 != "-1"
					${DebugMsg} "Moving registry key HKEY_CURRENT_USER\Software\PortableApps.com\$NAME\$0 to $1."
					${registry::MoveKey} "HKEY_CURRENT_USER\Software\PortableApps.com\$NAME\$0" $1 $R0
				${EndIf}
			${EndForEachINIPair}
			Delete "$DATADIRECTORY\_FailedRegistryKeys.ini"

			StrCpy $0 1
			${Do}
				ClearErrors
				ReadINIStr $1 $LAUNCHERINI "RegistryCleanupIfEmpty" $0
				${If} ${Errors}
					${ExitDo}
				${EndIf}
				${DebugMsg} "Deleting registry key $1 if it is empty."
				${registry::DeleteKeyEmpty} $1 $R0
				IntOp $0 $0 + 1
			${Loop}

			StrCpy $0 1
			${Do}
				ClearErrors
				ReadINIStr $1 $LAUNCHERINI "RegistryCleanupForce" $0
				${If} ${Errors}
					${ExitDo}
				${EndIf}
				${DebugMsg} "Deleting registry key $1."
				${registry::DeleteKey} $1 $R0
				IntOp $0 $0 + 1
			${Loop}

			${registry::Unload}
			newadvsplash::stop /WAIT
			${DebugMsg} "Finished."
			;=== Done!
		${Else}
			;=== Already running: launch and exit (existing launcher will clear up)
			ClearErrors
			ReadINIStr $0 $LAUNCHERINI "LaunchDetails" "SetOutPath"
			${IfNot} ${Errors}
				${ParseLocations} $0
				${DebugMsg} "Setting working directory to $0."
				SetOutPath $0
			${EndIf}
			${DebugMsg} "About to execute the following string and finish: $EXECSTRING"
			Exec $EXECSTRING
		${EndIf}
SectionEnd

; This note is just as something out of interest.  With a SetOutDir directive, it could be worth while examining each command-line argument and turning relative paths into absolute paths, probably with the PathCombine call.  I've used an AutoHotkey implementation of it, but we'd need an NSIS one here.
;To combine paths $0 and $1: System::Call 'Shlwapi.dll::PathCombineA([i "$dest", ]i r0, i r1) i ."$DEST"'???
;PathCombine(dir, file) { ; Function taken from http://www.autohotkey.com/forum/topic19489-30.html#124252
;	VarSetCapacity(dest, 260, 1) ; MAX_PATH
;	DllCall("Shlwapi.dll\PathCombineA", "UInt", &dest, "UInt", &dir, "UInt", &file)
;	Return, dest
;}
