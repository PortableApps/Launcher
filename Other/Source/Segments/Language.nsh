${SegmentFile}

${Segment.onInit}
	; Try to autoselect the launcher language for message boxes
	ReadEnvStr $0 PortableApps.comLocaleID
	${Switch} $0
		; Specifies Case statements for all languages the Launcher is in.
		; See ../Languages.nsi for those languages.
		!insertmacro LanguageCases
			${DebugMsg} "Setting language code to $0"
			StrCpy $LANGUAGE $0
			${Break}
	${EndSwitch}
!macroend

${SegmentInit}
	; Detect to see if the language code is coming from the PortableApps.com Platform.
	ReadEnvStr $0 PortableApps.comLanguageCode
	${If} $0 == ""
		${DebugMsg} "PortableApps.com Platform language variables are missing."
		StrCpy $9 pap-missing
	${EndIf}

	; Set languages variables; fallback to U.S. English if not launched from the PortableApps.com Platform.
	${SetEnvironmentVariableFromEnvironmentVariableWithDefault} PAL:LanguageCode  PortableApps.comLanguageCode  en
	${SetEnvironmentVariableFromEnvironmentVariableWithDefault} PAL:LanguageCode2 PortableApps.comLocaleCode2   en
	${SetEnvironmentVariableFromEnvironmentVariableWithDefault} PAL:LanguageCode3 PortableApps.comLocaleCode3   eng
	${SetEnvironmentVariableFromEnvironmentVariableWithDefault} PAL:LocaleGlibc   PortableApps.comLocaleglibc   en_US
	${SetEnvironmentVariableFromEnvironmentVariableWithDefault} PAL:LocaleID      PortableApps.comLocaleID      1033
	${SetEnvironmentVariableFromEnvironmentVariableWithDefault} PAL:LocaleNSIS    PortableApps.comLocaleWinName LANG_ENGLISH

	; LocaleName: added in Platform 2.0 Beta 5.
	; It's a mixed-case variant of LocaleWinName minus the LANG_.
	; If it's not set (1.6 - 2.0b4) it's worked out from that.
	; There's then no need for a table to fix the case, all operations I can
	; think of are case-insensitive.
	ReadEnvStr $0 PAL:LocaleName
	${If} $0 == ""
		ReadEnvStr $0 PAL:LocaleNSIS
		StrCpy $0 $0 "" 5 ; Chop off the LANG_
		${SetEnvironmentVariable} PAL:LocaleName $0
	${EndIf}

	; Now we can consider what to do next: was this launched from the
	; PortableApps.com Platform? If yes, then we go ahead with making
	; PAL:LanguageCustom, otherwise we look to read it from a config file first
	; (user-specified).
	${If} $9 == pap-missing
		; TODO: registry.

		; This code is taken largely from FileWrite segment as it shares the
		; format and a lot of the method.
		ClearErrors
		${ReadLauncherConfig} $9 Language SaveLanguage
		${IfNot} ${Errors}
		${AndIf} $9 == true
			StrCpy $1 $EXEDIR\Data\settings\$AppIDSettings.ini
		${Else}
			ClearErrors
			${ReadLauncherConfig} $0 LanguageFile Type
			${ReadLauncherConfig} $1 LanguageFile File
			${ParseLocations} $1
		${EndIf}
		${IfNot} ${Errors}
		${AndIf} ${FileExists} $1
			; The custom language is read into $8
			StrCpy $8 ""
			${If} $9 == true
				${DebugMsg} "Reading saved language from $1, section `$AppIDSettings`, key `Language`, with ReadINIStr."
				ReadINIStr $8 $1 $AppIDSettings Language
			${ElseIf} $0 == ConfigRead
				${ReadLauncherConfig} $2 LanguageFile Entry
				${IfNot} ${Errors}
					${ReadLauncherConfig} $4 LanguageFile CaseSensitive
					${If} ${FileExists} $1
						${If} $4 == true
							${DebugMsg} "Reading the language from $1, entry `$2`, with ConfigReadS."
							${ConfigReadS} $1 $2 $8
						${Else}
							${If} $4 != false
							${AndIfNot} ${Errors}
								${InvalidValueError} [LanguageFile]:CaseSensitive $4
							${EndIf}
							${DebugMsg} "Reading the language from $1, entry `$2`, with ConfigRead."
							${ConfigRead} $1 $2 $8
						${EndIf}
					${EndIf}
				${EndIf}
			${ElseIf} $0 == INI
				${ReadLauncherConfig} $2 LanguageFile Section
				${ReadLauncherConfig} $3 LanguageFile Key
				${IfNot} ${Errors}
					${DebugMsg} "Reading the language from $1, section `$2`, key `$3`, with ReadINIStr."
					ReadINIStr $8 $1 $2 $3
				${EndIf}
!ifdef XML_ENABLED
			${ElseIf} $0 == "XML attribute"
				${ReadLauncherConfig} $2 LanguageFile XPath
				${ReadLauncherConfig} $3 LanguageFile Attribute
				${IfNot} ${Errors}
					${If} ${FileExists} $1
						${DebugMsg} "Reading the language from $1, XPath `$2`, Attribute `$3` with XMLReadAttrib."
						${XMLReadAttrib} $1 $2 $3 $8
;						${IfThen} ${Errors} ${|} ${DebugMsg} "XMLReadAttrib XPath error" ${|}
					${EndIf}
				${EndIf}
			${ElseIf} $0 == "XML text"
				${ReadLauncherConfig} $2 LanguageFile XPath
				${If} ${FileExists} $1
					${DebugMsg} "Reading the language from $1, XPath `$2`, with XMLReadText."
					${XMLReadText} $1 $2 $8
;					${IfThen} ${Errors} ${|} ${DebugMsg} "XMLReadText XPath error" ${|}
				${EndIf}
!else
			${ElseIf} $0 == "XML attribute"
			${OrIf} $0 == "XML text"
				!insertmacro XML_WarnNotActivated [LanguageFile]
!endif
			${Else}
				${InvalidValueError} [LanguageFile]:Type $0
			${EndIf}

			${If} $8 == ""
				${DebugMsg} "Unable to read language from file."
			${Else}
				; We found a language value. Now we can set PAL:LanguageCustom

				; First, though, see if we want to cut anything off at the
				; right. This is useful for e.g. a </config> XML tag, or
				; closing quotation marks, or something similar.
				ClearErrors
				${ReadLauncherConfig} $0 LanguageFile TrimRight
				${IfNot} ${Errors}
					; See if it ends with this string.
					StrLen $1 $0
					StrCpy $2 $8 "" -$1
					${If} $2 == $0       ; yes, it does,
						StrCpy $8 $8 -$1 ; so cut it off
					${EndIf}
				${EndIf}

				; Also, see if we want to cut anything off at the left.
				; This could potentially be useful for some types.
				ClearErrors
				${ReadLauncherConfig} $0 LanguageFile TrimLeft
				${IfNot} ${Errors}
					; See if it ends with this string.
					StrLen $1 $0
					StrCpy $2 $8 $1
					${If} $2 == $0         ; yes, it does,
						StrCpy $8 $8 "" $1 ; so cut it off
					${EndIf}
				${EndIf}

				; Now we're all done, let's set the environment variable.
				${DebugMsg} "Setting PAL:LanguageCustom to $8 based on the [LanguageFile] section."
				${SetEnvironmentVariable} PAL:LanguageCustom $8
			${EndIf}
		${EndIf}
	${EndIf}

	; If PAL:LanguageCustom is set above when the PortableApps.com Platform is
	; missing, we won't use the [Language] section. If that bit above failed to
	; get a value, we'll get here even if the Platform isn't running.
	ClearErrors
	ReadEnvStr $8 PAL:LanguageCustom
	${If} ${Errors}
		; See topics/langauges in the Manual for an explanation of this code
		; and a diagram to illustrate how it works.
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
					${DebugMsg} "Setting PAL:LanguageCustom to $1 based on the [Language] section."
					${SetEnvironmentVariable} PAL:LanguageCustom $1
				${EndIf}
			${EndIf}
		${EndIf}
	${EndIf}


	; Write the language back, if desired; this is basically a copy-paste of the previous section.
	ClearErrors
	${ReadLauncherConfig} $9 Language SaveLanguage
	${IfNot} ${Errors}
	${AndIf} $9 == true
		StrCpy $1 $EXEDIR\Data\settings\$AppIDSettings.ini
		StrCpy $8 %PAL:LanguageCustom%
	${Else}
		ClearErrors
		${ReadLauncherConfig} $0 LanguageFile Type
		${ReadLauncherConfig} $1 LanguageFile File
		${ReadLauncherConfig} $8 LanguageFile SaveAs
		${ParseLocations} $1
	${EndIf}
	${ParseLocations} $8
	${IfNot} ${Errors}
		${If} $9 == true
			${DebugMsg} "Writing the language ($8) to $1, section `$AppIDSettings`, key `Language`."
			WriteINIStr $1 $AppIDSettings Language $8
		${ElseIf} $0 == ConfigRead
			${ReadLauncherConfig} $2 LanguageFile Entry
			${IfNot} ${Errors}
				${ReadLauncherConfig} $4 LanguageFile CaseSensitive
				${If} $4 == true
					${DebugMsg} "Writing the language ($8) to $1, entry `$2`, with ConfigWriteS."
					${ConfigWriteS} $1 $2 $8 $R9
				${ElseIf} $4 != false
					${DebugMsg} "Writing the language ($8) to $1, entry `$2`, with ConfigWrite."
					${ConfigWrite} $1 $2 $8 $R9
				${ElseIfNot} ${Errors}
					${InvalidValueError} [LanguageFile]:CaseSensitive $4
				${EndIf}
			${EndIf}
		${ElseIf} $0 == INI
			${ReadLauncherConfig} $2 LanguageFile Section
			${ReadLauncherConfig} $3 LanguageFile Key
			${IfNot} ${Errors}
				${DebugMsg} "Writing the language ($8) to $1, section `$2`, key `$3`, with WriteINIStr."
				WriteINIStr $1 $2 $3 $8
			${EndIf}
!ifdef XML_ENABLED
		${ElseIf} $0 == "XML attribute"
			${ReadLauncherConfig} $2 LanguageFile XPath
			${ReadLauncherConfig} $3 LanguageFile Attribute
			${IfNot} ${Errors}
				${DebugMsg} "Writing the language ($8) to $1, XPath `$2`, Attribute `$3` with XMLWriteAttrib."
				${XMLWriteAttrib} $1 $2 $3 $8
;				${IfThen} ${Errors} ${|} ${DebugMsg} "XMLWriteAttrib XPath error" ${|}
			${EndIf}
		${ElseIf} $0 == "XML text"
			${ReadLauncherConfig} $2 LanguageFile XPath
			${IfNot} ${Errors}
				${DebugMsg} "Writing the language to $1, XPath `$2`, with XMLWriteText."
				${XMLWriteText} $1 $2 $8
;				${IfThen} ${Errors} ${|} ${DebugMsg} "XMLReadText XPath error" ${|}
			${EndIf}
!else
		${ElseIf} $0 == "XML attribute"
		${OrIf} $0 == "XML text"
			!insertmacro XML_WarnNotActivated [LanguageFile]
!endif
		${Else}
			${InvalidValueError} [LanguageFile]:Type $0
		${EndIf}
	${EndIf}
!macroend
