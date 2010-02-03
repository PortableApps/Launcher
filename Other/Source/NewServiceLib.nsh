/* NewServiceLib
 * This is a smaller, neater and newer version of ServiceLib 1.5.
 *
 * If you want to unload NewServiceLib before the conclusion of your script,
 *
 * Commands:
 *   ${NewServiceLib::Unload}
 *     Unload NewServiceLib (frees up memory). This happens automatically
 *     at program completion, so you shouldn't need to use this normally.
 *   ${ServiceCreate} "parameters" user_var(success)
 *     Create a service or driver.
 *
 *     There are some changes in terminology from ServiceLib:
 *     What follows is a mapping of ServiceLib parameters to NewServiceLib definitions:
 *       (name)      -> name
 *       display     -> display
 *       autostart   -> start
 *       interact    -> type
 *       depend      -> depends
 *       path        -> path
 *       user        -> user
 *       password    -> password
 *       description -> description
 *
 *     The value input format for type and start type is also a lot friendlier:
 *       /type=(driver|service|service-interaction)          (default: service)
 *       /start=(boot|sscm|auto|manual)                      (default: manual)
 *     The start values "boot" and "sscm" are only valid for drivers.
 *     The start value "auto" is only valid for services.
 * 
 *     The parameters should be specified in GetOptions style.
 *       ${ServiceCreate} "/name=Foo /path=$EXEDIR\bar.exe /start=auto
 *
 *     Some more definitions have been provided for ease of use
 *     Type: ${NSL_TYPE_DRIVER}              = driver
 *           ${NSL_TYPE_SERVICE}             = service
 *           ${NSL_TYPE_SERVICE_INTERACTION} = service with desktop interaction
 *
 *     Start type: ${NSL_START_DRIVER_BOOT}  = driver          boot stage
 *                 ${NSL_START_DRIVER_SSCM}  = driver          sscm stage
 *                 ${NSL_START_SERVICE_AUTO} = service         auto
 *                 ${NSL_START_MANUAL}       = driver/service, manual
 *
 *   ${ServiceDelete} "[service name]" user_var(success)
 *     Delete the specified service or driver.
 *
 *   ${ServiceExists} "[service name]" user_var(success)
 *     Does the specified service or driver exist?
 *
 *   ${ServiceStart}  "[service name]" user_var(success)
 *     Start the specified service or driver.
 *
 *   ${ServiceStop}   "[service name]" user_var(success)
 *     Stop the specified service or driver.
 */

${!ifndefdefdo} _NewServiceLib_Included

	; Variables {{{1
	Var SCManager
	Var OpenServiceHandle
	Var OpenServiceName

	; Value definitions {{{1
	!define SC_MANAGER_ALL_ACCESS    0x3F
	!define SERVICE_ALL_ACCESS       0xF01FF

	!define SERVICE_CONTROL_STOP     1
	!define SERVICE_CONTROL_PAUSE    2
	!define SERVICE_CONTROL_CONTINUE 3

	!define SERVICE_STOPPED          0x1
	!define SERVICE_START_PENDING    0x2
	!define SERVICE_STOP_PENDING     0x3
	!define SERVICE_RUNNING          0x4
	!define SERVICE_CONTINUE_PENDING 0x5
	!define SERVICE_PAUSE_PENDING    0x6
	!define SERVICE_PAUSED           0x7

	!define NSL_TYPE_DRIVER              1
	!define NSL_TYPE_SERVICE             16
	!define NSL_TYPE_SERVICE_INTERACTION 272

	!define NSL_START_DRIVER_BOOT  0
	!define NSL_START_DRIVER_SSCM  1
	!define NSL_START_SERVICE_AUTO 2
	!define NSL_START_MANUAL       3

	!macro NewServiceLib::Unload ; {{{1
		${!ifdefundef} NewServiceLibDoneInit
		${If} $SCManager != 0
		${AndIf} $SCManager != ""
			System::Call 'advapi32::CloseServiceHandle(i $SCManager) n'
		${EndIf}
	!macroend
	${!macrodef} NewServiceLib::Unload

	!macro _ServiceMacroInit ; {{{1
		Push $0 ; return value
		Push $1 ; service name

		StrCpy $0 false
		${!ifndefdefdo} NewServiceLibDoneInit
			${If} $SCManager == ""
				System::Call 'advapi32::OpenSCManagerA(n, n, i ${SC_MANAGER_ALL_ACCESS}) i.s'
				Pop $SCManager
			${EndIf}
		!endif
		${If} $SCManager != 0
			!ifndef _ServiceMacro_IsCreate
				StrCpy $1 "${ServiceName}"
				${If} $OpenServiceName != $1
			!endif
					; Close the last opened service handle
					${If} $OpenServiceHandle != 0
					${AndIf} $OpenServiceHandle != ""
						System::Call 'advapi32::CloseServiceHandle(i $OpenServiceHandle) n'
					${EndIf}
					; Now open the service in question
					StrCpy $OpenServiceName $1
			!ifndef _ServiceMacro_IsCreate
					System::Call 'advapi32::OpenServiceA(i $SCManager, t r1, i ${SERVICE_ALL_ACCESS}) i.s'
					Pop $OpenServiceHandle
				${EndIf}
				${If} $OpenServiceHandle != 0
			!endif
	!macroend

	!macro _ServiceMacroEnd ; {{{1
			!ifdef _ServiceMacro_IsCreate
				!undef _ServiceMacro_IsCreate
			!else
				${EndIf}
			!endif
		${EndIf}
		Pop $1
		Exch $0
		Pop ${_OUT}
	!macroend

	!macro ServiceCreate Parameters  _OUT ; {{{1
		; Push everything out of the way {{{2
		!define _ServiceMacro_IsCreate
		!insertmacro _ServiceMacroInit
		;Push $1
		Push $2
		Push $3
		Push $4
		Push $5
		Push $6
		Push $7
		Push $8
		Push $9

		; $1: Service name {{{2
		${GetOptions} `${_Parameters}` `/name=` $1
		${IfThen} $1 == "" ${|} StrCpy $0 "false" ${|}

		; $2: Display name {{{2
		${GetOptions} `${_Parameters}` `/display=` $2
		${If} $2 == ""
			StrCpy $2 $1
		${EndIf}

		; $3: Type (driver/service/service-interaction) {{{2
		${GetOptions} `${_Parameters}` `/type=` $3
		${Select} $3
			${Case2} "driver" ${NSL_TYPE_DRIVER}
				StrCpy $3 ${NSL_TYPE_DRIVER}
			${Case2} "service-interaction" ${NSL_TYPE_SERVICE_INTERACTION}
				StrCpy $3 ${NSL_TYPE_SERVICE_INTERACTION}
			${Default}
				StrCpy $3 ${NSL_TYPE_SERVICE}
		${EndSelect}

		; $4: Start (driver:boot, driver:sscm, service:auto, manual) {{{2
		${GetOptions} `${_Parameters}` `/start=` $4
		${If} $3 == ${NSL_TYPE_DRIVER}
			${Select} $4
				${Case2} boot ${NSL_START_DRIVER_BOOT}
					StrCpy $4 ${NSL_START_DRIVER_BOOT}
				${Case2} sscm ${NSL_START_DRIVER_SSCM}
					StrCpy $4 ${NSL_START_DRIVER_SSCM}
				${Default}
					StrCpy $4 ${NSL_START_MANUAL}
			${EndSelect}
		${Else}
			${Select} $4
				${Case2} auto ${NSL_START_SERVICE_AUTO}
					StrCpy $4 ${NSL_START_SERVICE_AUTO}
				${Default}
					StrCpy $4 ${NSL_START_MANUAL}
			${EndSelect}
		${EndIf}

		; $5: Service path {{{2
		${GetOptions} `${_Parameters}` `/path=` $5
		${IfThen} $5 == "" ${|} StrCpy $0 "false" ${|}

		; $6: Dependencies {{{2
		${GetOptions} `${_Parameters}` `/depends=` $6
		${If} $6 == ""
			StrCpy $6 n
		${Else}
			StrCpy $6 `t "$6"`
		${EndIf}

		; $7: Username {{{2
		${GetOptions} `${_Parameters}` `/user=` $7
		${If} $7 == ""
			StrCpy $7 n
		${Else}
			StrCpy $7 `t "$7"`
		${EndIf}

		; $8: Password {{{2
		${GetOptions} `${_Parameters}` `/password=` $8
		${If} $8 == ""
			StrCpy $8 n
		${Else}
			StrCpy $8 `t "$8"`
		${EndIf}

		; $9: Description {{{2
		${GetOptions} `${_Parameters}` `/description=` $9
		${If} $9 == ""
			StrCpy $9 $1
		${EndIf}

		; Create the service {{{2
		System::Call 'advapi32::CreateServiceA(i $SCManager, t r1, t r2, i ${SERVICE_ALL_ACCESS}, i r3, i r4, i 0, t r5, n, n, $6, $7, $8) i.s'
		Pop $OpenServiceHandle
		WriteRegStr HKLM "SYSTEM\ControlSet001\Services\$1" Description $9
		; Give the response; did it work? {{{2
		${If} $OpenServiceHandle = 0
			StrCpy $0 false
		${Else}
			StrCpy $0 true
		${EndIf}
		; Pop goes the weasel {{{2
		Pop $9
		Pop $8
		Pop $7
		Pop $6
		Pop $5
		Pop $4
		Pop $3
		Pop $2
		;Pop $1
		!insertmacro _ServiceMacroEnd ; }}}
	!macroend
	${!macrodef} ServiceCreate

	!macro ServiceDelete ServiceName _OUT ; {{{1
		!insertmacro _ServiceMacroInit
		System::Call 'advapi32::DeleteService(i $OpenServiceHandle) i.r0'
		${If} $0 = 0
			StrCpy $0 false
		${Else}
			StrCpy $0 true
		${EndIf}
		!insertmacro _ServiceMacroEnd
	!macroend
	${!macrodef} ServiceDelete

	!macro ServiceExists ServiceName _OUT ; {{{1
		!insertmacro _ServiceMacroInit
		StrCpy $0 true ; got here so it exists
		!insertmacro _ServiceMacroEnd
	!macroend
	${!macrodef} ServiceExists

	!macro ServiceStart  ServiceName _OUT ; {{{1
		!insertmacro _ServiceMacroInit
		System::Call 'advapi32::StartServiceA(i $OpenServiceHandle, i 0, i 0) i.r0'
		${If} $0 = 0
			StrCpy $0 false
		${Else}
			StrCpy $0 true
		${EndIf}
		!insertmacro _ServiceMacroEnd
	!macroend
	${!macrodef} ServiceStart

	!macro ServiceStop   ServiceName _OUT ; {{{1
		!insertmacro _ServiceMacroInit
		Push $1
		System::Call '*(i,i,i,i,i,i,i) i.r1'
		System::Call 'advapi32::ControlService(i $OpenServiceHandle, i ${SERVICE_CONTROL_STOP}, i r1) i'
		System::Free $1
		Pop $1
		StrCpy $0 true
		!insertmacro _ServiceMacroEnd
	!macroend
	${!macrodef} ServiceStop
!endif
