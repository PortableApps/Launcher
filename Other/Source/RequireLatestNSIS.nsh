!include WordFunc.nsh

Section
; Require at least NSIS 2.46
!if ${NSIS_VERSION} == v2.45
	!error "The PortableApps.com Launcher requires NSIS 2.46 or later."
!else
	!verbose push
	!verbose 4
	!echo "(If you get a compile error with !searchparse, please upgrade to NSIS 2.46 or later and try again.)"
	!verbose pop
!endif
!searchparse ${NSIS_VERSION} "v" V
${VersionCompare} ${V} "2.46" $R0
!if ${R0} == 1
	!error "You only have NSIS ${V}, but NSIS 2.46 or later is required for proper Windows support. Please upgrade to NSIS 2.46 or later and try again."
!endif
!undef V
SectionEnd