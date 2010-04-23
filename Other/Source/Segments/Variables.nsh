${SegmentFile}

; Macros {{{1
!define SetEnvironmentVariablesPath "!insertmacro SetEnvironmentVariablesPathCall"
!macro SetEnvironmentVariablesPathCall _VARIABLE_NAME _PATH
	Push "${_VARIABLE_NAME}"
	Push "${_PATH}"
	${CallArtificialFunction2} SetEnvironmentVariablesPath_
!macroend

!macro SetEnvironmentVariablesPath_
	/* This function sets environment variables with different formats for paths.
	 * For example:
	 *   ${SetEnvironmentVariablesPath} PortableApps.comAppDirectory $EXEDIR\App
	 * Will produce the following environment variables:
	 *   %PAL:AppDir%                 = X:\PortableApps\AppNamePortable\App
	 *   %PAL:AppDir:Forwardslash%    = X:/PortableApps/AppNamePortable/App
	 *   %PAL:AppDir:DoubleBackslash% = X:\\PortableApps\\AppNamePortable\\App
	 *   %PAL:AppDir:java.util.prefs% = /X:///Portable/Apps///App/Name/Portable///App
	 */
	Exch $R0 ; path
	Exch
	Exch $R1 ; variable name

	Push $R2 ; forwardslash
	Push $R3 ; double backslash, java.util.prefs
	Push $R7 ; jup len
	Push $R8 ; jup pos
	Push $R9 ; jup char
	;=== Set the backslashes path as given (e.g. X:\PortableApps\AppNamePortable)
	${SetEnvironmentVariable} $R1 $R0
	;=== Make the forwardslashes path (e.g. X:/PortableApps/AppNamePortable)
	${WordReplace} $R0 \ / + $R2
	${SetEnvironmentVariable} "$R1:Forwardslash" $R2
	;=== Make the double backslashes path (e.g. X:\\PortableApps\\AppNamePortable)
	${WordReplace} $R0 \ \\ + $R3
	${SetEnvironmentVariable} "$R1:DoubleBackslash" $R3
	;=== Make the java.util.prefs path
	; Based on the forwardslashes path, s/[^a-z:]/\/&/g
	StrCpy $R3 ""
	StrLen $R7 $R7
	IntOp $R7 $R7 - 1 ; base 0
	${For} $R8 0 $R7
		StrCpy $R9 $R7 1 $R8
		${If}   $R9 == a
		${OrIf} $R9 == b
		${OrIf} $R9 == c
		${OrIf} $R9 == d
		${OrIf} $R9 == e
		${OrIf} $R9 == f
		${OrIf} $R9 == g
		${OrIf} $R9 == h
		${OrIf} $R9 == i
		${OrIf} $R9 == j
		${OrIf} $R9 == k
		${OrIf} $R9 == l
		${OrIf} $R9 == m
		${OrIf} $R9 == n
		${OrIf} $R9 == o
		${OrIf} $R9 == p
		${OrIf} $R9 == q
		${OrIf} $R9 == r
		${OrIf} $R9 == s
		${OrIf} $R9 == t
		${OrIf} $R9 == u
		${OrIf} $R9 == v
		${OrIf} $R9 == w
		${OrIf} $R9 == x
		${OrIf} $R9 == y
		${OrIf} $R9 == z
		${OrIf} $R9 == :
			StrCpy $R3 $R3$R9
		${Else}
			StrCpy $R3 $R3/$R9
		${EndIf}
	${Next}
	${SetEnvironmentVariable} "$R1:java.util.prefs" $R3
	Pop $R9
	Pop $R8
	Pop $R7
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
!macroend

!macro SetEnvironmentVariablesPathFromEnvironmentVariable _VARIABLE_NAME
	Push $R0
	ReadEnvStr $R0 "${_VARIABLE_NAME}"
	${SetEnvironmentVariablesPath} "${_VARIABLE_NAME}" $R0
	Pop $R0
!macroend
!define SetEnvironmentVariablesPathFromEnvironmentVariable "!insertmacro SetEnvironmentVariablesPathFromEnvironmentVariable"

!macro ParseLocations VAR ;{{{2
	${!getdebug}
	!ifdef DEBUG
		!ifndef _ParseLocations_Before
			Var /GLOBAL _ParseLocations_Before
			!define _ParseLocations_Before
		!endif
	!endif
		
	!ifdef DEBUG
		StrCpy $_ParseLocations_Before ${VAR}
	!endif
	ExpandEnvStrings ${VAR} ${VAR}
	${DebugMsg} "Environment variable expansion on $${VAR}:$\r$\nBefore: `$_ParseLocations_Before`$\r$\nAfter: `${VAR}`"
!macroend
!define ParseLocations "!insertmacro ParseLocations"

; Variables {{{1
Var AppDirectory
Var DataDirectory
Var PortableAppsDirectory

; Segments {{{1
${SegmentInit}
	;=== Initialise variables
	StrCpy $0 $CurrentDrive 1
	StrCpy $1 $LastDrive 1
	${SetEnvironmentVariable} PAL:Drive $CurrentDrive
	${SetEnvironmentVariable} PAL:LastDrive $LastDrive
	${SetEnvironmentVariable} PAL:DriveLetter $0
	${SetEnvironmentVariable} PAL:LastDriveLetter $1

	StrCpy $AppDirectory  $EXEDIR\App
	StrCpy $DataDirectory $EXEDIR\Data
	${SetEnvironmentVariablesPath} PAL:AppDir  $AppDirectory
	${SetEnvironmentVariablesPath} PAL:DataDir $DataDirectory
	; These may be changed in the RunLocally segment's Pre hook.

	${GetParent} $EXEDIR $PortableAppsDirectory
	${SetEnvironmentVariablesPath} PAL:PortableAppsDir $PortableAppsDirectory

	ReadEnvStr $0 PortableApps.comDocuments
	${If} $0 == ""
	${OrIfNot} ${FileExists} $0
		StrCpy $0 $CurrentDrive\Documents
	${EndIf}
	${SetEnvironmentVariablesPath} PortableApps.comDocuments $0

	ReadEnvStr $1 PortableApps.comPictures
	${If} $1 == ""
	${OrIfNot} ${FileExists} $1
		StrCpy $1 $0\Pictures
	${EndIf}
	${SetEnvironmentVariablesPath} PortableApps.comPictures $1

	ReadEnvStr $1 PortableApps.comMusic
	${If} $1 == ""
	${OrIfNot} ${FileExists} $1
		StrCpy $1 $0\Music
	${EndIf}
	${SetEnvironmentVariablesPath} PortableApps.comMusic $1

	ReadEnvStr $1 PortableApps.comVideos
	${If} $1 == ""
	${OrIfNot} ${FileExists} $1
		StrCpy $1 $0\Videos
	${EndIf}
	${SetEnvironmentVariablesPath} PortableApps.comVideos $1

	; Language variables are in the Language segment

	${SetEnvironmentVariablesPathFromEnvironmentVariable} ALLUSERSPROFILE
	${SetEnvironmentVariablesPathFromEnvironmentVariable} USERPROFILE
	${SetEnvironmentVariablesPath} LOCALAPPDATA $LOCALAPPDATA
	${SetEnvironmentVariablesPath} APPDATA $APPDATA
	${SetEnvironmentVariablesPath} DOCUMENTS $DOCUMENTS
!macroend
