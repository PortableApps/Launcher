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
	ReadEnvStr $0 PortableApps.comLanguageCode
	${IfThen} $0 == "" ${|} ${SetEnvironmentVariable} PortableApps.comLanguageCode en ${|}
	ReadEnvStr $0 PortableApps.comLocaleCode2
	${IfThen} $0 == "" ${|} ${SetEnvironmentVariable} PortableApps.comLocaleCode2 en ${|}
	ReadEnvStr $0 PortableApps.comLocaleCode3
	${IfThen} $0 == "" ${|} ${SetEnvironmentVariable} PortableApps.comLocaleCode3 eng ${|}
	ReadEnvStr $0 PortableApps.comLocaleglibc
	${IfThen} $0 == "" ${|} ${SetEnvironmentVariable} PortableApps.comLocaleglibc en_US ${|}
	ReadEnvStr $0 PortableApps.comLocaleID
	${IfThen} $0 == "" ${|} ${SetEnvironmentVariable} PortableApps.comLocaleID 1033 ${|}
	ReadEnvStr $0 PortableApps.comLocaleWinName
	${IfThen} $0 == "" ${|} ${SetEnvironmentVariable} PortableApps.comLocaleWinName LANG_ENGLISH ${|}
	ReadEnvStr $0 PortableApps.comLocaleName
	${If} $0 == ""
		ReadEnvStr $0 PortableApps.comLocaleWinName
		StrCpy $0 $0 "" 5
		${SetEnvironmentVariable} PortableApps.comLocaleName $0
	${EndIf}

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
