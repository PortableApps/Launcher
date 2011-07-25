; Internal PortableApps.com Launcher languages for message boxes etc.
; The language is set in Segments/Language.nsh (but all the addition of
; languages is done in this file).

!tempfile LangAutoDetectFile
!macro IncludeLang _LANG
	LoadLanguageFile "${NSISDIR}\Contrib\Language files\${_LANG}.nlf"
	!insertmacro LANGFILE_INCLUDE_WITHDEFAULT Languages\${_LANG}.nsh Languages\English.nsh
	!appendfile "${LangAutoDetectFile}" "${Case} ${LANG_${_LANG}}$\n"
!macroend
!define IncludeLang "!insertmacro IncludeLang"
${IncludeLang} English
${IncludeLang} Bulgarian
${IncludeLang} Danish
${IncludeLang} Dutch
${IncludeLang} Estonian
${IncludeLang} Finnish
${IncludeLang} French
${IncludeLang} Galician
${IncludeLang} German
${IncludeLang} Hebrew
${IncludeLang} Hungarian
${IncludeLang} Indonesian
${IncludeLang} Italian
${IncludeLang} Japanese
${IncludeLang} Polish
${IncludeLang} Portuguese
${IncludeLang} PortugueseBR
${IncludeLang} SimpChinese
${IncludeLang} Slovenian
${IncludeLang} Spanish
${IncludeLang} Swedish
${IncludeLang} Thai
${IncludeLang} TradChinese
${IncludeLang} Turkish

; Use the Case statements formed above.
; Used in Segments/Language.nsh
!macro LanguageCases
	!include "${LangAutoDetectFile}"
	!delfile "${LangAutoDetectFile}"
	!undef LangAutoDetectFile
!macroend
