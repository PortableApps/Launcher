${SegmentFile}

${SegmentPrePrimary}
	${If} $UsesRegistry == true
		${ForEachINIPair} RegistryValueWrite $0 $1
			${ValidateRegistryKey} $0
			StrCpy $2 $0 "" -1
			${If} $2 == "\"
				StrCpy $2 $0 -1
				StrCpy $3 "" ; default value
			${Else}
				${GetParent} $0 $2 ; key
				${GetFileName} $0 $3 ; item
			${EndIf}

			StrLen $4 $1
			StrCpy $5 0
			${Do}
				StrCpy $6 $1 1 $5
				${IfThen} $6 == : ${|} ${ExitDo} ${|}
				IntOp $5 $5 + 1
			${LoopUntil} $5 > $4

			${If} $6 == :
				StrCpy $4 $1 $5 ; type (e.g. REG_DWORD)
				IntOp $5 $5 + 1
				StrCpy $1 $1 "" $5 ; value
			${Else}
				StrCpy $4 REG_SZ
			${EndIf}

			${ParseLocations} $1

			${DebugMsg} "Writing '$1' (type '$4') to key '$2', value '$3'$\n(Short form: $2\$3=$4:$1)"
			; key item value type return
			${registry::Write} $2 $3 $1 $4 $R9
		${NextINIPair}
	${EndIf}
!macroend
