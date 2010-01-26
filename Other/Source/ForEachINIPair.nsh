; Copyright (C) 2009 Chris Morgan of PortableApps.com.

Var LAUNCHERFILEHANDLE

!macro ForEachINIPair SECTION KEY VALUE
	Push $R1 ; current line
	Push $R2 ; length of line
	Push $R3 ; character number in line
	Push $R4 ; character
	${If} $LAUNCHERFILEHANDLE == ""
		FileOpen $LAUNCHERFILEHANDLE $EXEDIR\App\Launcher\launcher.ini r
	${Else}
		FileSeek $LAUNCHERFILEHANDLE 0
	${EndIf}
	${Do}
		FileRead $LAUNCHERFILEHANDLE $R1
		${TrimNewLines} $R1 $R1
		${If} ${Errors} ; end of file
		${OrIf} $R1 == "[${SECTION}]" ; right section
			${ExitDo}
		${EndIf}
	${Loop}

	${IfNot} ${Errors} ; right section
		${Do}
			FileRead $LAUNCHERFILEHANDLE $R1

			StrCpy $R2 $R1 1
			${If} ${Errors} ; end of file
			${OrIf} $R2 == '[' ; new section
				${ExitDo} ; finished
			${EndIf}

			${If} $R2 == ';' ; a comment line
				${Continue}
			${EndIf}

			StrLen $R2 $R1
			StrCpy $R3 '0'
			${Do}
				StrCpy $R4 $R1 1 $R3
				${IfThen} $R4 == '=' ${|} ${ExitDo} ${|}
				IntOp $R3 $R3 + 1
			${LoopUntil} $R3 > $R2

			${TrimNewLines} $R1 $R1

			${If} $R4 == '='
				StrCpy ${KEY} $R1 $R3
				IntOp $R3 $R3 + 1
				StrCpy ${VALUE} $R1 "" $R3
				Pop $R4
				Pop $R3
				Pop $R2
				Pop $R1
!macroend

!macro EndForEachINIPair
				Push $R1
				Push $R2
				Push $R3
				Push $R4
			${EndIf}
		${Loop}
	${EndIf}
	;FileClose $LAUNCHERFILEHANDLE
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
!macroend

!define ForEachINIPair '!insertmacro ForEachINIPair'
!define EndForEachINIPair '!insertmacro EndForEachINIPair'
