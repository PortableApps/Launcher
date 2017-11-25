;=# 
; Services.nsh 1.1 (2017-11-24)
; Written by demon.devin
;
; NOTES:
; This file was created to replace the official services segment for the PortableApps.com Launcher
; This segment will enable support for handling Windows Services without the need for a plugin.
;
; USAGE:
; To make use of this segment, add the section [Service1] (numerical ordering) to the Launcher.ini file. 
; Each entry supports six keys which are as follows: 
;
; Name		-	The local/portable service name.
; Path		-	The path to the portable service executable. Supports environment variables.
; Type		-	Specify whether you are dealing with a service, a kernel driver or a file system driver, etc.
; 				Choose from: own, share, interact, kernel, filesys, rec
; Start		-	Specify when the service is supposed to start.
; 				Choose from: boot, system, auto, demand, disabled, delayed-auto
; Depend	-	List any dependencies here separated by / (forward slash).
; IfExists	-	If the service already exists, you can either skip it or replace it with the portable version of the service.
; 				Choose from: skip, replace
;
; EXAMPLE:
;
; [Service1]
; Name=ServiceName
; Path=%PAL:DataDir%\drivers\ElbyCDIO.sys
; Type=kernel
; Start=system
; Depend=
; IfExists=replace
;
; 
!ifndef LOGICLIB
	!include LogicLib.nsh
!endif
; 
; The following macros make use of the SC command line.
; 
; NOTE:
; For offical help with the SC command, open a command prompt 
; and enter "sc /?" or "sc /help" (i.e. sc create /?) and 
; you will be given support for the proper uses for each of
; the calls in the macros below.
;
; Define the path to sc.exe
;
!define SC `$SYSDIR\sc.exe`
;
; ${Service::Query} "NAME" /DISABLEFSR $0 $1
;
;    ::Query     = Queries a service to see if it exists. 
;    NAME        = The Service name
;    /DISABLEFSR = Disables redirection if x64. Use "" to skip.
;    $0          = Return after call | 1060 = Service not found.
;    $1          =   ''    ''    ''
;
!define Service::Query `!insertmacro Service::Query`
!macro Service::Query _SVC _FSR _ERR1 _ERR2
	StrCmpS $Bits 64 0 +4
	StrCmp "${_FSR}" /DISABLEFSR 0 +3
	ExecDos::Exec /TOSTACK /DISABLEFSR `"${SC}" query "${_SVC}"`
	Goto +2
	ExecDos::Exec /TOSTACK `"${SC}" query "${_SVC}"`
	Pop ${_ERR1}
	Pop ${_ERR2}
!macroend
;
; ${Service::Stop} "NAME" /DISABLEFSR $0 $1
;
;    ::Stop      = Sends a STOP control request to a service. 
;    NAME        = The Service name
;    /DISABLEFSR = Disables redirection if x64. Use "" to skip.
;    $0          = Return after call
;    $1          =   ''    ''    ''
;
!define Service::Stop `!insertmacro Service::Stop`
!macro Service::Stop _SVC _FSR _ERR1 _ERR2
	StrCmpS $Bits 64 0 +4
	StrCmp "${_FSR}" /DISABLEFSR 0 +3
	ExecDos::Exec /TOSTACK /DISABLEFSR `"${SC}" stop "${_SVC}"`
	Goto +2
	ExecDos::Exec /TOSTACK `"${SC}" stop "${_SVC}"`
	Pop ${_ERR1}
	Pop ${_ERR2}
!macroend
;
; ${Service::Start} "NAME" /DISABLEFSR $0 $1
;
;    ::Start     = Start a service. 
;    NAME        = The Service name
;    /DISABLEFSR = Disables redirection if x64. Use "" to skip.
;    $0          = Return after call
;    $1          =   ''    ''    ''
;
; $1 will now hold "1" if running or "0" if not
;
!define Service::Start `!insertmacro Service::Start`
!macro Service::Start _SVC _FSR _ERR1 _ERR2
	StrCmpS $Bits 64 0 +4
	StrCmp "${_FSR}" /DISABLEFSR 0 +3
	ExecDos::Exec /TOSTACK /DISABLEFSR `"${SC}" start "${_SVC}"`
	Goto +2
	ExecDos::Exec /TOSTACK `"${SC}" start "${_SVC}"`
	Pop ${_ERR1}
	Pop ${_ERR2}
!macroend
;
; ${Service::Delete} "NAME" /DISABLEFSR $0 $1
;
;    ::Delete    = Deletes a service entry from the registry. 
;    NAME        = The Service name
;    /DISABLEFSR = Disables redirection if x64. Use "" to skip.
;    $0          = Return after call
;    $1          =   ''    ''    ''
;
; Be sure to stop a service first if it's running.
;
!define Service::Delete `!insertmacro Service::Delete`
!macro Service::Delete _SVC _FSR _ERR1 _ERR2
	StrCmpS $Bits 64 0 +4
	StrCmp "${_FSR}" /DISABLEFSR 0 +3
	ExecDos::Exec /TOSTACK /DISABLEFSR `"${SC}" delete "${_SVC}"`
	Goto +2
	ExecDos::Exec /TOSTACK `"${SC}" delete "${_SVC}"`
	Pop ${_ERR1}
	Pop ${_ERR2}
!macroend
;
; ${Service::Create} "NAME" "PATH" "TYPE" "START" "DEPEND" /DISABLEFSR $0 $1
;
;    ::Create    = Creates a service entry in the registry and Service Database
;    NAME        = The Service name
;    PATH        = BinaryPathName to the .exe file
;    TYPE        = own|share|interact|kernel|filesys|rec
;    START       = boot|system|auto|demand|disabled|delayed-auto
;    DEPEND      = Dependencies (separated by "/" [forward slash w/o quotes])
;    /DISABLEFSR = Disables redirection if x64. Use "" to skip.
;    $0          = Return after call
;    $1          =   ''    ''    ''
;
!define Service::Create `!insertmacro Service::Create`
!macro Service::Create _SVC _PATH _TYPE _START _DEPEND _FSR _ERR1 _ERR2
	StrCmpS $Bits 64 0 +7
	StrCmp "${_FSR}" /DISABLEFSR 0 +6
	StrCmp "${_DEPEND}" "" 0 +3
	ExecDos::Exec /TOSTACK /DISABLEFSR `"${SC}" create "${_SVC}" binpath= "${_PATH}" type= "${_TYPE}" start= "${_START}"`
	Goto +7
	ExecDos::Exec /TOSTACK /DISABLEFSR `"${SC}" create "${_SVC}" binpath= "${_PATH}" type= "${_TYPE}" start= "${_START}" depend= ""${_DEPEND}""`
	Goto +5
	StrCmp "${_DEPEND}" "" 0 +3
	ExecDos::Exec /TOSTACK `"${SC}" create "${_SVC}" binpath= "${_PATH}" type= "${_TYPE}" start= "${_START}"`
	Goto +2
	ExecDos::Exec /TOSTACK `"${SC}" create "${_SVC}" binpath= "${_PATH}" type= "${_TYPE}" start= "${_START}" depend= ""${_DEPEND}""`
	Pop ${_ERR1}
	Pop ${_ERR2}
!macroend
; 
; ${Service::Description} "NAME" /DISABLEFSR $0 $1
;
;    ::Description = Sets the description string for a service.
;    NAME          = The Service name
;    /DISABLEFSR   = Disables redirection if x64. Use "" to skip.
;    $0            = Return after call
;    $1            =   ''    ''    ''
;
; Be sure to stop a service first if it's running.
;
!define Service::Description `!insertmacro Service::Description`
!macro Service::Description _SVC _DESCRIPTION _FSR _ERR1 _ERR2
	StrCmpS $Bits 64 0 +4
	StrCmp "${_FSR}" /DISABLEFSR 0 +3
	ExecDos::Exec /TOSTACK /DISABLEFSR `"${SC}" description "${_SVC}" "${_DESCRIPTION}"`
	Goto +2
	ExecDos::Exec /TOSTACK `"${SC}" description "${_SVC}" "${_DESCRIPTION}"`
	Pop ${_ERR1}
	Pop ${_ERR2}
!macroend
; 
; ${Service::Config} "NAME" /DISABLEFSR $0 $1
;
;    ::Config    = Modifies a service's start entry in the registry and Service Database.
;    NAME        = The Service name
;    /DISABLEFSR = Disables redirection if x64. Use "" to skip.
;    $0          = Return after call
;    $1          =   ''    ''    ''
;
; Be sure to stop a service first if it's running.
;
!define Service::Config `!insertmacro Service::Config`
!macro Service::Config _SVC _CONFIG _FSR _ERR1 _ERR2
	StrCmpS $Bits 64 0 +4
	; disabled, demand, auto
	StrCmp "${_FSR}" /DISABLEFSR 0 +3
	ExecDos::Exec /TOSTACK /DISABLEFSR `"${SC}" config "${_SVC}" start= "${_CONFIG}"`
	Goto +2
	ExecDos::Exec /TOSTACK `"${SC}" config "${_SVC}" start= "${_CONFIG}"`
	Pop ${_ERR1}
	Pop ${_ERR2}
!macroend
;
; ${Service::Status} "NAME" /DISABLEFSR $0 $1
;
;    ::Status    = The service's status is returned. 
;    NAME        = The Service name
;    /DISABLEFSR = Disables redirection if x64. Use "" to skip.
;    $0          = Return after call | 1 = success
;    $1          =   ''    ''    ''  | 1 = running
;
; $1 will now hold "1" if running or "0" if not
;
!define Service::Status `!insertmacro Service::Status`
!macro Service::Status _SVC _FSR _ERR1 _ERR2
	ReadEnvStr $R9 COMSPEC
	StrCmpS $Bits 64 0 +4
	StrCmp "${_FSR}" /DISABLEFSR 0 +3
	ExecDos::Exec /TOSTACK /DISABLEFSR `"$R9" /c "sc QUERY "${_SVC}" | FIND /C "RUNNING""`
	Goto +2
	ExecDos::Exec /TOSTACK `"${C}" /c "sc QUERY "${_SVC}" | FIND /C "RUNNING""`
	Pop ${_ERR1} ; 1 = success
	Pop ${_ERR2} ; 1 = running
	StrCmpS ${_ERR1} 1 0 +4
	StrCmpS ${_ERR2} 1 0 +3
	${WriteRuntimeData} PortableApps.comLauncher ${_SVC}_Status running
!macroend
; 
; The following macros make use of the ServiceLib.nsh header include file.
;
; NOTE:
; The following macros are not as reliable as the macros above for
; a couple of reasons but it's mostly due to the fact that ServiceLib.nsh 
; does not support adding multiple dependencies when creating a new service.
;
; For more information on the ServiceLib.nsh file, please visit:
; http://nsis.sourceforge.net/NSIS_Service_Lib
;
; These aren't being used.
; 
!define ServiceLib::Create `!insertmacro _ServiceLib::Create`
!macro _ServiceLib::Create _RETURN _NAME _PATH _TYPE _START _DEPEND
	Push "create"
	Push "${_NAME}"
	StrCmp "${_DEPEND}" "" 0 +3
	Push "path=${_PATH};servicetype=${_TYPE};starttype=${_START};"
	Goto +2
	Push "path=${_PATH};servicetype=${_TYPE};starttype=${_START};depend=${_DEPEND};"
	Call Service
	Pop ${_RETURN}
!macroend
!define ServiceLib::Start `!insertmacro _ServiceLib::Start`
!macro _ServiceLib::Start _RETURN _NAME
	Push "start"
	Push "${_NAME}"
	Push ""
	Call Service
	Pop ${_RETURN} ;= Returns true/false
!macroend
!define ServiceLib::Remove `!insertmacro _ServiceLib::Remove`
!macro _ServiceLib::Remove _RETURN _NAME
	Push "delete"
	Push "${_NAME}"
	Push ""
	Call Service
	Pop ${_RETURN} ;= Returns true/false
!macroend
!define ServiceLib::Stop `!insertmacro _ServiceLib::Stop`
!macro _ServiceLib::Stop _RETURN _NAME
	Push "stop"
	Push "${_NAME}"
	Push ""
	Call Service
	Pop ${_RETURN} ;= Returns true/false
!macroend
!define ServiceLib::Pause `!insertmacro _ServiceLib::Pause`
!macro _ServiceLib::Pause _RETURN _NAME
	Push "pause"
	Push "${_NAME}"
	Push ""
	Call Service
	Pop ${_RETURN} ;= Returns true/false
!macroend
!define ServiceLib::Continue `!insertmacro _ServiceLib::Continue`
!macro _ServiceLib::Continue _RETURN _NAME
	Push "continue"
	Push "${_NAME}"
	Push ""
	Call Service
	Pop ${_RETURN} ;= Returns true/false
!macroend
!define ServiceLib::Status `!insertmacro _ServiceLib::Status`
!macro _ServiceLib::Status _RETURN _NAME
	Push "status"
	Push "${_NAME}"
	Push ""
	Call Service
	Pop ${_RETURN} ;= Returns stopped/running/start_pending/stop_pending/continue_pending/pause_pending/pause/unknown
!macroend
${SegmentFile}

;= Enable the services segment
!define SERVICES_ENABLED

;= Uninstall Local Services
${SegmentPre}
	!ifdef SERVICES_ENABLED
		StrCpy $R0 1
		${Do}
			ClearErrors
			ReadINIStr $0 "$EXEDIR\App\AppInfo\Launcher\${AppID}.ini" "Service$R0" "Name"
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			ReadRegStr $1 HKLM "SYSTEM\CurrentControlSet\services\$0" ImagePath
			${IfNot} ${Errors}
				StrCpy $2 $1 4
				StrCmp $2 \??\ 0 +2
				StrCpy $1 $1 "" 4
				${WriteRuntimeData} "$0_Service" LocalService true
				${WriteRuntimeData} "$0_Service" LocalPath "$1"
				${DebugMsg} "Checking and logging state of local instance of $0 service."
				ReadRegStr $0 HKLM "SYSTEM\CurrentControlSet\services\$0" Start
				${WriteRuntimeData} "$0_Service" LocalState $0
				ReadINIStr $3 "$EXEDIR\App\AppInfo\Launcher\${AppID}.ini" "Service$R0" "IfExists"
				${If} $3 == replace
					${DebugMsg} "Preparing portable service of $0; removing local instance."
					${Service::Stop} "$0" /DISABLEFSR $8 $9
					${Service::Delete} "$0" /DISABLEFSR $8 $9
				${ElseIf} $3 == skip
					${DebugMsg} "Local service of $0 already exists; not preparing for a portable instance."
				${EndIf}
			${EndIf}
			IntOp $R0 $R0 + 1
		${Loop}
	!endif
!macroend
;= Install Portable Services
${SegmentPrePrimary}
	!ifdef SERVICES_ENABLED
		StrCpy $R0 1
		${Do}
			${ReadLauncherConfig} $0 Service$R0 Name
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ReadLauncherConfig} $1 Service$R0 IfExists
			${If} $1 == replace
				${DebugMsg} "Creating a portable instance of the $0 service."
				${ReadLauncherConfig} $2 Service$R0 Path
				${ParseLocations} $2
				${ReadLauncherConfig} $3 Service$R0 Type
				${ReadLauncherConfig} $4 Service$R0 Start
				${ReadLauncherConfig} $5 Service$R0 Depend
				${If} $5 != ""
					${Service::Create} "$0" "$2" "$3" "$4" "$5" /DISABLEFSR $8 $9
				${Else}
					${Service::Create} "$0" "$2" "$3" "$4" "" /DISABLEFSR $8 $9
				${EndIf}
				${Service::Start} "$0" /DISABLEFSR $8 $9
				ReadEnvStr $R9 COMSPEC
				${If} Bit == 64
					ExecDos::Exec /TOSTACK /DISABLEFSR `"$R9" /c "sc QUERY "$0" | FIND /C "RUNNING""`
				${Else}
					ExecDos::Exec /TOSTACK `"$R9" /c "sc QUERY "$0" | FIND /C "RUNNING""`
				${EndIf}
				Pop $R7 ;=== 1 = success
				Pop $R8 ;=== 1 = running
				${If} $R7 == 1
				${OrIf} $R8 == 1
					${DebugMsg} "The portable instance of the $0 service has been started."
				${Else}
					${DebugMsg} "The portable instance of the $0 service failed to start."
				${EndIf}
			${ElseIf} $1 == skip
				${DebugMsg} "Local service of $0 already exists; not creating a portable instance."
			${EndIf}
			IntOp $R0 $R0 + 1
		${Loop}
	!endif
!macroend
;= Uninstall Portable Services
${SegmentPostPrimary}
	!ifdef SERVICES_ENABLED
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $0 Service$R0 Name
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ReadLauncherConfig} $1 Service$R0 IfExists
			${If} $1 == replace
				${DebugMsg} "Removing portable service of $0 to prepare for reinstallation of the local instance."
				${ReadRuntimeData} $3 "$0_Service" LocalService
				${If} ${Errors}
					${Service::Stop} "$0" /DISABLEFSR $8 $9
					${Service::Delete} "$0" /DISABLEFSR $8 $9
				${Else}
					${Service::Stop} "$0" /DISABLEFSR $8 $9
				${EndIf}
			${ElseIf} $1 == skip 
				${DebugMsg} "Local service of $0 was already installed; no further action taken."
			${EndIf}
			IntOp $R0 $R0 + 1
		${Loop}
	!endif
!macroend
;= Restore Local Services
${SegmentUnload}
	!ifdef SERVICES_ENABLED
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $0 Service$R0 Name
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ReadLauncherConfig} $1 Service$R0 IfExists
			${If} $1 == replace
				${DebugMsg} "Reinstalling the local instance of the $0 service."
				${ReadRuntimeData} $2 "$0_Service" LocalService
				${IfNot} ${Errors}
					${ReadRuntimeData} $3 "$0_Service" LocalPath
					${ReadLauncherConfig} $4 Service$R0 Type
					${ReadLauncherConfig} $5 Service$R0 Start
					${ReadLauncherConfig} $6 Service$R0 Depend
					${If} $6 != ""
						${Service::Create} "$0" "$3" "$4" "$5" "$6" /DISABLEFSR $8 $9
					${Else}
						${Service::Create} "$0" "$3" "$4" "$5" "" /DISABLEFSR $8 $9
					${EndIf}
					${ReadRuntimeData} $7 "$0_Service" LocalState
					${If} $7 != 4
						${DebugMsg} "Restarting local instance of the $0 service."
						${Service::Start} "$0" /DISABLEFSR $8 $9
					${Else}
						${DebugMsg} "Local instance of the $0 service was not running before runtime; no further action required."
					${EndIf}
				${EndIf}
			${ElseIf} $1 == skip
				${DebugMsg} "Local service of $0 was already installed; no further action taken."
			${EndIf}
			IntOp $R0 $R0 + 1
		${Loop}
	!endif
!macroend
