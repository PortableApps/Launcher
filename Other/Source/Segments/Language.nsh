${SegmentFile}

${Segment.onInit}
	ReadEnvStr $0 PortableApps.comLocaleID
	${Switch} $0
		${Case} 1033 ; English
		${Case} 1026 ; Bulgarian
		${Case} 1036 ; French
		${Case} 1030 ; Danish
		${Case} 1043 ; Dutch
		${Case} 1110 ; Galician
		${Case} 1031 ; German
		${Case} 1040 ; Italian
		${Case} 1041 ; Japanese
		${Case} 2052 ; SimpChinese
		${Case} 1034 ; Spanish
			${DebugMsg} "Setting language code to $0"
			StrCpy $LANGUAGE $0
			${Break}
	${EndSwitch}
!macroend

${SegmentInit}
	; Set the default values
	${SetEnvironmentVariableDefault} PortableApps.comLanguageCode en
	${SetEnvironmentVariableDefault} PortableApps.comLocaleCode2 en
	${SetEnvironmentVariableDefault} PortableApps.comLocaleCode3 eng
	${SetEnvironmentVariableDefault} PortableApps.comLocaleglibc en_US
	${SetEnvironmentVariableDefault} PortableApps.comLocaleID 1033
	${SetEnvironmentVariableDefault} PortableApps.comLocaleWinName LANG_ENGLISH

	; LocaleName: added in Platform 2.0 Beta 5.
	; It's a mixed-case variant of LocaleWinName minus the LANG_.
	; If it's not set (1.6 - 2.0b4) it's worked out from that.
	; There's then no need for a table to fix the case, all operations I can
	; think of are case-insensitive.

	ReadEnvStr $0 PortableApps.comLocaleName
	${If} $0 == ""
		ReadEnvStr $0 PortableApps.comLocaleWinName
		StrCpy $0 $0 "" 5 ; Chop off the LANG_
		${SetEnvironmentVariable} PortableApps.comLocaleName $0
	${EndIf}

	; See topics/langauges in the Manual for an explanation of this code and a
	; diagram to illustrate how it works.
	${ReadLauncherConfig} $0 Language Base
	${If} $0 != ""
		${ParseLocations} $0
		ClearErrors
		${ReadLauncherConfig} $1 LanguageStrings $0
		${If} ${Errors}
			ClearErrors
			${ReadLauncherConfig} $1 Language Default
			${IfNot} ${Errors}
				${ParseLocations} $1
			${Else}
				StrCpy $1 $0
			${EndIf}
		${EndIf}
		${SetEnvironmentVariable} PAL:LanguageCustom $1
		${ReadLauncherConfig} $2 Language CheckIfExists
		${If} $2 != ""
			${ParseLocations} $2
			${IfNot} ${FileExists} $2
				${ReadLauncherConfig} $1 Language DefaultIfNotExists
				${ParseLocations} $1
				${SetEnvironmentVariable} PAL:LanguageCustom $1
			${EndIf}
		${EndIf}
	${EndIf}
!macroend
