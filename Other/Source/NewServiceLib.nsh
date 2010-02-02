/* NewServiceLib
 * This is a smaller, neater and newer version of ServiceLib 1.5.
 *
 * If you want to unload NewServiceLib before the conclusion of your script,
 *   ${NewServiceLib::Unload}
 *
 * Commands:
 *   ${Service}
 *
 * There are some changes in terminology from ServiceLib:
 * What follows is a mapping of ServiceLib parameters to NewServiceLib definitions:
 *  (path        -> ServicePath, mandatory so part of the macro definition)
 *   autostart   -> ServiceStartType
 *   interact    -> ServiceType
 *   depend      -> ServiceDepend
 *   user        -> ServiceUser
 *   password    -> ServicePassword
 *   display     -> ServiceDisplay
 *   description -> ServiceDescription
 *
 * Some more definitions have been provided for ease of use
 * ServiceType: ${NSL_TYPE_DRIVER}              = driver
 *              ${NSL_TYPE_SERVICE}             = service
 *              ${NSL_TYPE_SERVICE_INTERACTION} = service with desktop interaction
 *
 * ServiceStartType: ${NSL_START_DRIVER_BOOT}  = driver          boot stage
 *                   ${NSL_START_DRIVER_SSCM}  = driver          sscm stage
 *                   ${NSL_START_SERVICE_AUTO} = service         auto
 *                   ${NSL_START_MANUAL}       = driver/service, manual
 *
 * All macros accept one argument, service name.
 * ServiceCreate, DriverCreate and ServiceCreateAndStart accept a second argument, service path.
 * ServiceCreate
 * DriverCreate
 * ServiceDelete
 * ServiceStart
 * ServiceStop
 * ServiceCreateAndStart
 * ServiceStopAndDelete
 */

!include CompilerUtils.nsh
${!ifndefdefdo} _NewServiceLib_Included

	Var SCManager
	Var OpenServiceHandle
	Var OpenServiceName

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

	!macro NewServiceLib::Unload
		${!ifdefundef} NewServiceLibDoneInit
		${If} $SCManager != 0
		${AndIf} $SCManager != ""
			System::Call 'advapi32::CloseServiceHandle(i $SCManager) n'
		${EndIf}
	!macroend
	${!macrodef} NewServiceLib::Unload

	!macro _ServiceMacroInit
		Push $0 ; return value

		StrCpy $0 false
		${!ifndefdefdo} NewServiceLibDoneInit
			System::Call 'advapi32::OpenSCManagerA(n, n, i ${SC_MANAGER_ALL_ACCESS}) i.s'
			Pop $SCManager
		!endif
		${If} $SCManager != 0
			!ifndef _ServiceMacro_IsCreate
				${If} $OpenServiceName != "${ServiceName}"
			!endif
					; Close the last opened service handle
					${If} $OpenServiceHandle != 0
					${AndIf} $OpenServiceHandle != ""
						System::Call 'advapi32::CloseServiceHandle(i $OpenServiceHandle) n'
					${EndIf}
					; Now open the service in question
					StrCpy $OpenServiceName "${ServiceName}"
			!ifndef _ServiceMacro_IsCreate
					System::Call 'advapi32::OpenServiceA(i $SCManager, t "${ServiceName}", i ${SERVICE_ALL_ACCESS}) i.s'
					Pop $OpenServiceHandle
				${EndIf}
				${If} $OpenServiceHandle != 0
			!endif
	!macroend

	!macro _ServiceMacroEnd
			!ifdef _ServiceMacro_IsCreate
				!undef _ServiceMacro_IsCreate
			!else
				${EndIf}
			!endif
		${EndIf}
		Exch $0
	!macroend

	!macro ServiceCreate ServiceName ServicePath
		!define _ServiceMacro_IsCreate
		!insertmacro _ServiceMacroInit
		${!redefwithdefault} ServiceDepend      `t "${ServiceDepend}"`   n
		${!redefwithdefault} ServiceUser        `t "${ServiceUser}"`     n
		${!redefwithdefault} ServicePassword    `t "${ServicePassword}"` n
		${!ifndefdef}        ServiceType        ${NSL_TYPE_SERVICE}
		${!ifndefdef}        ServiceStartType   ${NSL_TYPE_MANUAL}
		${!ifndefdef}        ServiceDisplay     "${ServiceName}"
		${!ifndefdef}        ServiceDescription "${ServiceName}"

		System::Call 'advapi32::CreateServiceA(i $SCManager, t "${ServiceName}", t "${ServiceDisplay}", i ${SERVICE_ALL_ACCESS}, i ${ServiceType}, i ${ServiceStartType}, i 0, t ${ServicePath}, n, n, ${ServiceDepend}, ${ServiceUser}, ${ServicePath}) i.r0'
		WriteRegStr HKLM "SYSTEM\ControlSet001\Services\${ServiceName}" Description "${ServiceDescription}"
		${If} $0 = 0
			StrCpy $0 false
		${Else}
			StrCpy $0 true
		${EndIf}
		!insertmacro _ServiceMacroEnd
	!macroend
	${!macrodef} ServiceCreate

	!macro DriverCreate ServiceName ServicePath
		!define ServiceType ${NSL_TYPE_DRIVER}
		${ServiceCreate} "${ServiceName}" "${ServicePath}"
	!macroend
	${!macrodef} DriverCreate

	!macro ServiceDelete ServiceName
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

	!macro ServiceExists ServiceName
		!insertmacro _ServiceMacroInit
		StrCpy $0 true ; got here so it exists
		!insertmacro _ServiceMacroEnd
	!macroend
	${!macrodef} ServiceExists

	!macro ServiceStart ServiceName
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

	!macro ServiceStop ServiceName
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

	!macro ServiceCreateAndStart ServiceName ServicePath
		!insertmacro ServiceCreate "${ServiceName}" "${ServicePath}"
		!insertmacro ServiceStart "${ServiceName}"
	!macroend
	${!macrodef} ServiceCreateAndStart

	!macro DriverCreateAndStart ServiceName ServicePath
		!define ServiceType ${NSL_TYPE_DRIVER}
		${ServiceCreateAndStart} "${ServiceName}" "${ServicePath}"
	!macroend
	${!macrodef} DriverCreateAndStart

	!macro ServiceStopAndDelete ServiceName
		!insertmacro ServiceStop "${ServiceName}"
		!insertmacro ServiceDelete "${ServiceName}"
	!macroend
	${!macrodef} ServiceStopAndDelete
!endif
