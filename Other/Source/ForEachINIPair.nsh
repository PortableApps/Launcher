Var LAUNCHERFILEHANDLE
Var _FEIP1 ; current line
Var _FEIP2 ; length of line
Var _FEIP3 ; character number in line
Var _FEIP4 ; character

!macro ForEachINIPair SECTION KEY VALUE
	${If} $LAUNCHERFILEHANDLE == ""
		FileOpen $LAUNCHERFILEHANDLE $EXEDIR\App\AppInfo\launcher.ini r
	${Else}
		FileSeek $LAUNCHERFILEHANDLE 0
	${EndIf}
	${Do}
		ClearErrors
		FileRead $LAUNCHERFILEHANDLE $_FEIP1
		${TrimNewLines} $_FEIP1 $_FEIP1
		${If} ${Errors} ; end of file
		${OrIf} $_FEIP1 == "[${SECTION}]" ; right section
			${ExitDo}
		${EndIf}
	${Loop}

	${IfNot} ${Errors} ; right section
		${Do}
			FileRead $LAUNCHERFILEHANDLE $_FEIP1

			StrCpy $_FEIP2 $_FEIP1 1
			${If} ${Errors} ; end of file
			${OrIf} $_FEIP2 == '[' ; new section
				${ExitDo} ; finished
			${EndIf}

			${If} $_FEIP2 == ';' ; a comment line
				${Continue}
			${EndIf}

			StrLen $_FEIP2 $_FEIP1
			StrCpy $_FEIP3 '0'
			${Do}
				StrCpy $_FEIP4 $_FEIP1 1 $_FEIP3
				${IfThen} $_FEIP4 == '=' ${|} ${ExitDo} ${|}
				IntOp $_FEIP3 $_FEIP3 + 1
			${LoopUntil} $_FEIP3 > $_FEIP2

			${TrimNewLines} $_FEIP1 $_FEIP1

			${If} $_FEIP4 == '='
				StrCpy ${KEY} $_FEIP1 $_FEIP3
				IntOp $_FEIP3 $_FEIP3 + 1
				StrCpy ${VALUE} $_FEIP1 "" $_FEIP3
!macroend

!macro EndForEachINIPair
			${EndIf}
		${Loop}
	${EndIf}
	;FileClose $LAUNCHERFILEHANDLE
!macroend

!define ForEachINIPair '!insertmacro ForEachINIPair'
!define EndForEachINIPair '!insertmacro EndForEachINIPair'
