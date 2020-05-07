; RMDirIfNotJunction 1.1 (2020-04-29)
;
; Removes an empty directory if it is not a junction
;
; Usage: ${RMDirIfNotJunction} REMOVE_PATH
;
; Copyright © 2016-2020 John T. Haller

!include "FileFunc.nsh"

Function RMDirIfNotJunction
	;Start with a clean slate
	ClearErrors
	
	;Get our parameters
	Exch $0 ;REMOVE_PATH
	Push $1 ;TempVar
	
	;Determine if it is a junction
	${GetFileAttributes} "$0" "REPARSE_POINT" $1
	
	${If} $1 == 0
		;Not a junction, remove the directory if empty
		RMDir $0
	${EndIf}
	
	;Clear the stack
	Pop $1
	Pop $0
FunctionEnd

!macro RMDirIfNotJunction REMOVE_PATH
  Push `${REMOVE_PATH}`
  Call RMDirIfNotJunction
!macroend

!define RMDirIfNotJunction '!insertmacro "RMDirIfNotJunction"'