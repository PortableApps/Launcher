; Macro: check if in debug mode for the current section {{{1
!macro !getdebug
	!ifdef DEBUG
		!undef DEBUG
	!endif
	!ifdef DEBUG_ALL
		!define DEBUG
	!else
		!ifdef Segment
			!ifdef DEBUG_SEGMENT_${Segment}
				!define DEBUG
			!endif
		!else ifdef DEBUG_GLOBAL
			!define DEBUG
		!endif
	!endif
!macroend
!define !getdebug "!insertmacro !getdebug"

; Macro: print a debug message {{{1
!macro DebugMsg _MSG
	${!getdebug}
	!ifdef DEBUG
		!ifdef Segment
			!define _DebugMsg_Seg "$\n$\nSegment: ${Segment}$\nHook: ${__FUNCTION__}"
		!else
			!define _DebugMsg_Seg ""
		!endif
		; ${__FILE__} is useless, always PortableApps.comLauncher.nsi
		MessageBox MB_OKCANCEL|MB_ICONINFORMATION "Debug message at line ${__LINE__}${_DebugMsg_Seg}$\n____________________$\n$\n${_MSG}" IDOK +2
			Abort
		!undef _DebugMsg_Seg
	!endif
!macroend
!define DebugMsg "!insertmacro DebugMsg"

; If you want to debug this, create PortableApps.comLauncherDebug.nsh in the
; package's Other\Source directory. It should then have lines like these:
; · Debug everything
;     !define DEBUG_ALL
;   · This leaves out the "about to execute segment" and "finished executing
;     segment" messages unless you put this line in:
;       !define DEBUG_SEGWRAP
; · Debug just certain portions
;   · Debug outside any segments
;       !define DEBUG_GLOBAL
;   · Debug a given segment or segments
;       !define DEBUG_SEGMENT_[SegmentName]
!include /NONFATAL "${PACKAGE}\Other\Source\PortableApps.comLauncherDebug.nsh"
