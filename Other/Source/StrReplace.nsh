; StrReplace
; Replaces all ocurrences of a given needle within a haystack with another string
; Written by dandaman32
; Optimised by Afrow UK (v4)
; Extraneous ${VarN} defs removed and "V4" branding removed by Chris Morgan of PortableApps.com
 
Function StrReplace
	Exch $R0 #in
	Exch 1
	Exch $R1 #with
	Exch 2
	Exch $R2 #replace
	Push $R3
	Push $R4
	Push $R5
	Push $R6
	Push $R7
	Push $R8

		StrCpy $R3 -1
		StrLen $R5 $R0
		StrLen $R6 $R1
		StrLen $R7 $R2
		Loop:
			IntOp $R3 $R3 + 1
			StrCpy $R4 $R0 $R7 $R3
			StrCmp $R3 $R5 End
			StrCmp $R4 $R2 0 Loop

				StrCpy $R4 $R0 $R3
				IntOp $R8 $R3 + $R7
				StrCpy $R8 $R0 "" $R8
				StrCpy $R0 $R4$R1$R8
				IntOp $R3 $R3 + $R6
				IntOp $R3 $R3 - 1
				IntOp $R5 $R5 - $R7
				IntOp $R5 $R5 + $R6

		Goto Loop
		End:

	Pop $R8
	Pop $R7
	Pop $R6
	Pop $R5
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
	Exch $R0 #out
FunctionEnd

!macro StrReplace Var Replace With In
	Push $R1
	Push $R2
	Push `${Replace}`
	Push `${With}`
	Push `${In}`
	Call StrReplace
	Pop `${Var}`
	Pop $R2
	Pop $R1
!macroend

!define StrReplace `!insertmacro StrReplace`
