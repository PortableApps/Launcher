!ifndef _CompilerUtils_Included
	!define _CompilerUtils_Included

	!macro !macrodef _MACRO
		!define ${_MACRO} "!insertmacro ${_MACRO}"
	!macroend
	!insertmacro !macrodef !macrodef

	!macro !redef _VAR _VALUE
		!define !redef_tmp `${_VALUE}`
		!ifdef ${_VAR}
			!undef ${_VAR}
		!endif}
		!define ${_VAR} `${!redef_tmp}`
	!macroend
	${!macrodef} !redef

	!macro !redefwithdefault _VAR _VALUE _DEFAULT
		!ifdef ${_VAR}
			${!redef} ${_VAR} `${_VALUE}`
		!else
			!define ${_VAR} `${_DEFAULT}`
		!endif
	!macroend
	${!macrodef} !redefwithdefault

	!macro !ifndefdefdo _VAR
		!ifndef ${_VAR}
			!define ${_VAR}
	!macroend
	${!macrodef} !ifndefdefdo

	!macro !ifndefdef _VAR _VALUE
		!ifndef ${_VAR}
			!define ${_VAR} `${_VALUE}`
		!endif
	!macroend
	${!macrodef} !ifndefdef

	!macro ifdefundef _VAR
		!ifdef ${_VAR}
			!undef ${_VAR}
		!endif
	!macroend
	${!macrodef} !ifdefundef

	!macro _!ifexist _FILE_NAME _NOT
		!tempfile _TEMPFILE
		!system `if ${_NOT} exist "${_FILE_NAME}" echo !define _FILE_EXISTS > "${_TEMPFILE}"`
		!include `${_TEMPFILE}`
		!delfile `${_TEMPFILE}`
		!undef _TEMPFILE
		!ifdef _FILE_EXISTS
			!undef _FILE_EXISTS
	!macroend

	!macro !ifexist _FILE_NAME
		!insertmacro _!ifexist "${_FILE_NAME}" ""
	!macroend
	${!macrodef} !ifexist

	!macro !ifnexist _FILE_NAME
		!insertmacro _!ifexist "${_FILE_NAME}" not
	!macroend
	${!macrodef} !ifnexist
!endif
