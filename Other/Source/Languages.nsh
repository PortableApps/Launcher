; Internal PortableApps.com Launcher languages for message boxes etc.
; The language is set in Segments/Language.nsh (but all the addition of
; languages is done in this file).

!ifdef NSIS_UNICODE
	!define LANG_DIR Languages\U
!else
	!define LANG_DIR Languages\A
!endif
!tempfile LangAutoDetectFile
!macro IncludeLang _LANG
	LoadLanguageFile "${NSISDIR}\Contrib\Language files\${_LANG}.nlf"
	!insertmacro LANGFILE_INCLUDE_WITHDEFAULT ${LANG_DIR}\${_LANG}.nsh ${LANG_DIR}\English.nsh
	!appendfile "${LangAutoDetectFile}" "${Case} ${LANG_${_LANG}}$\n"
!macroend
!define IncludeLang "!insertmacro IncludeLang"
${IncludeLang} English
${IncludeLang} Bulgarian
${IncludeLang} Danish
${IncludeLang} Dutch
${IncludeLang} French
${IncludeLang} Galician
${IncludeLang} German
${IncludeLang} Italian
${IncludeLang} Japanese
${IncludeLang} Polish
${IncludeLang} SimpChinese
${IncludeLang} Slovenian
${IncludeLang} Spanish
!undef LANG_DIR

; Use the Case statements formed above.
; Used in Segments/Language.nsh
!macro LanguageCases
	!include "${LangAutoDetectFile}"
	!delfile "${LangAutoDetectFile}"
	!undef LangAutoDetectFile
!macroend
