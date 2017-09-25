!include UAC.nsh
Var RunAsAdmin
!macro CaseUACCodeAlert CODE FORCEMESSAGE TRYMESSAGE
	!if "${CODE}" == ""
		${Default}
	!else
		${Case} "${CODE}"
	!endif
		StrCmpS $RunAsAdmin force 0 +3
		MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST "${FORCEMESSAGE}"
		Quit
		MessageBox MB_OK|MB_ICONINFORMATION|MB_TOPMOST "${TRYMESSAGE}"
	${Break}
!macroend
!define CaseUACCodeAlert "!insertmacro CaseUACCodeAlert"
!macro RunAsAdmin_OSOverride OS
	${If} ${IsWin${OS}}
		ClearErrors
		${ReadLauncherConfig} $0 Launch RunAsAdmin${OS}
		${If} $0 == force
		${OrIf} $0 == try
			StrCpy $RunAsAdmin $0
		${ElseIfNot} ${Errors}
			${InvalidValueError} [Launch]:RunAsAdmin${OS} $0
		${EndIf}
	${EndIf}
!macroend
${SegmentFile}
${Segment.onInit} ; {{{1
	; Run as admin if needed {{{2
	ClearErrors
	${ReadLauncherConfig} $RunAsAdmin Launch RunAsAdmin
	!ifdef RUNASADMIN_COMPILEFORCE
		IfErrors +2
		StrCmpS $RunAsAdmin compile-force +2
		MessageBox MB_OK|MB_ICONSTOP "To turn off compile-time RunAsAdmin, you must regenerate the launcher."
	!else
		${IfNot} ${Errors}
		${AndIf} $RunAsAdmin != force
		${AndIf} $RunAsAdmin != try
			${If} $RunAsAdmin == compile-force
				MessageBox MB_OK|MB_ICONSTOP "To use [Launch]:RunAsAdmin=compile-force, you must regenerate the launcher. Continuing with 'force'."
				StrCpy $RunAsAdmin force
			${Else}
				${InvalidValueError} [Launch]:RunAsAdmin $RunAsAdmin
			${EndIf}
		${EndIf}
		!insertmacro RunAsAdmin_OSOverride 2000
		!insertmacro RunAsAdmin_OSOverride XP
		!insertmacro RunAsAdmin_OSOverride 2003
		!insertmacro RunAsAdmin_OSOverride Vista
		!insertmacro RunAsAdmin_OSOverride 2008
		!insertmacro RunAsAdmin_OSOverride 7
		!insertmacro RunAsAdmin_OSOverride 2008R2
		${If} $RunAsAdmin == force
		${OrIf} $RunAsAdmin == try
		${DebugMsg} "[Launch]:RunAsAdmin value is $RunAsAdmin"
			Elevate: ; Attempt to elevate to admin {{{2
			${DebugMsg} "Attempting to run as admin"
			!insertmacro UAC_RunElevated
			${!getdebug}
			!ifdef DEBUG
				${Select} $0
					${Case} 0
						${If} $1 = 1
							StrCpy $R9 "Changed credentials to admin: this is the user-level process, admin has finished."
						${ElseIf} $3 <> 0
							StrCpy $R9 "Changed credentials to admin: this is the admin process."
						${ElseIf} $1 = 3
							StrCpy $R9 "Changed credentials, but not to admin."
						${Else}
							StrCpy $R9 "Given 'changed credentials' status code but unknown values ($$2=$2, $$3=$3)"
						${EndIf}
					${Case} 1223
						StrCpy $R9 "Failed to elevate to admin (cancelled)."
					${Case} 1062
						StrCpy $R9 "Failed to elevate to admin (Windows logon service was unavailable)."
					${Default}
						StrCpy $R9 "Unknown error (code $0)."
				${EndSelect}
				${DebugMsg} "UAC_RunElevated return values: $$0=$0, $$1=$1, $$2=$2, $$3=$3; $R9"
			!endif
			${Switch} $0
				; Success in changing credentials in some way {{{3
				${Case} 0
					StrCmpS $1 1 0 +2 ; This is the user-level process and the admin-level process has finished successfully.
					Quit
					${If} $3 <> 0 ; This is the admin-level process: great!
						${Break}
					${EndIf}
					StrCmpS $1 3 0 +6 ; RunAs completed successfully, but with a non-admin user
					StrCmpS $RunAsAdmin force 0 +3
					MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION|MB_TOPMOST \ 
					"$(LauncherRequiresAdmin)$\r$\n$\r$\n$(LauncherNotAdminTryAgain)" IDRETRY Elevate
					Quit
					MessageBox MB_ABORTRETRYIGNORE|MB_ICONEXCLAMATION|MB_TOPMOST \ 
					"$(LauncherNotAdminLimitedFunctionality)$\r$\n$\r$\n$(LauncherNotAdminLimitedFunctionalityTryAgain)" \ 
					IDRETRY Elevate IDIGNORE RunAsAdminEnd
					Quit
				; Explicitly failed to get admin {{{3
				${CaseUACCodeAlert} 1223 \
					"$(LauncherRequiresAdmin)" \
					"$(LauncherNotAdminLimitedFunctionality)"
				; Windows logon service unavailable {{{3
				${CaseUACCodeAlert} 1062 \
					"$(LauncherAdminLogonServiceNotRunning)" \
					"$(LauncherNotAdminLimitedFunctionality)"
				; Other error, not sure what {{{3
				${CaseUACCodeAlert} "" \
					"$(LauncherAdminError)$\r$\n$(LauncherRequiresAdmin)" \
					"$(LauncherAdminError)$\r$\n$(LauncherNotAdminLimitedFunctionality)"
			${EndSwitch}
			RunAsAdminEnd:
		${EndIf}
	!endif
!macroend
