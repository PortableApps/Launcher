${SegmentFile}

!include UAC.nsh

Var RunAsAdmin
Var RunningAsAdmin

; Macro for producing the right message box based on the error code {{{1
!macro CaseUACCodeAlert CODE FORCEMESSAGE TRYMESSAGE
	!if "${CODE}" == ""
		${Default}
	!else
		${Case} "${CODE}"
	!endif
		${If} $RunAsAdmin == force
			MessageBox MB_OK|MB_ICONSTOP|MB_TOPMOST|MB_SETFOREGROUND "${FORCEMESSAGE}"
			Abort
		${ElseIf} $RunAsAdmin == try
			MessageBox MB_OK|MB_ICONINFORMATION|MB_TOPMOST|MB_SETFOREGROUND "${TRYMESSAGE}"
		${EndIf}
		${Break}
!macroend
!define CaseUACCodeAlert "!insertmacro CaseUACCodeAlert"


${Segment.onInit} ; {{{1
	; Run as admin if needed {{{2
	${ReadLauncherConfig} $RunAsAdmin Launch RunAsAdmin
	${If} $RunAsAdmin == force
	${OrIf} $RunAsAdmin == try
		Elevate: ; Attempt to elevate to admin {{{2
			${DebugMsg} "Attempting to run as admin"
			!insertmacro UAC_RunElevated

			${!IfDebug}
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
					${Case} 1233
						StrCpy $R9 "Failed to elevate to admin (cancelled)."
					${Case} 1062
						StrCpy $R9 "Failed to elevate to admin (Windows logon service was unavailable)."
					${Default}
						StrCpy $R9 "Unknown error (code $0)."
				${EndSelect}
				${DebugMsg} "UAC_RunElevated return values:$\n$$0=$0$\n$$1=$1$\n$$2=$2$\n$$3=$3$\n$\n$R9"
			!endif

			${Switch} $0
				; Success in changing credentials in some way {{{3
				${Case} 0
					${IfThen} $1 = 1 ${|} Abort ${|} ; This is the user-level process and the admin-level process has finished successfully.
					${If} $3 <> 0 ; This is the admin-level process: great!
						StrCpy $RunningAsAdmin true
						${Break}
					${EndIf}
					${If} $1 = 3 ; RunAs completed successfully, but with a non-admin user
						${If} $RunAsAdmin == force
							MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION|MB_TOPMOST|MB_SETFOREGROUND "$(LauncherRequiresAdmin)$\r$\n$\r$\n$(LauncherNotAdminTryAgain)" IDRETRY Elevate
							Abort
						${ElseIf} $RunAsAdmin == try
							MessageBox MB_ABORTRETRYIGNORE|MB_ICONEXCLAMATION|MB_TOPMOST|MB_SETFOREGROUND "$(LauncherNotAdminLimitedFunctionality)$\r$\n$\r$\n$(LauncherNotAdminLimitedFunctionalityTryAgain)" IDRETRY Elevate IDIGNORE RunAsAdminEnd
							Abort
						${EndIf}
					${EndIf}
					; If we're still here, we'll fall through as there's no ${Break}
				; Explicitly failed to get admin {{{3
				${CaseUACCodeAlert} 1233 \
					"$(LauncherRequiresAdmin)" \
					"$(LauncherNotAdminLimitedFunctionality)"
				; Windows logon service unavailable {{{3
				${CaseUACCodeAlert} 1062 \
					"$(LauncherAdminLogonServiceNotRunning)" \
					"$(LauncherNotAdminLimitedFunctionality)"
				; Other error, not sure what {{{3
				${CaseUACCodeAlert} "" \
					"$(LauncherAdminError)$\r$\n$(LauncherNotAdminLimitedFunctionality)" \
					"$(LauncherAdminError)$\r$\n$(LauncherNotAdminLimitedFunctionality)"
			${EndSwitch}

		RunAsAdminEnd:
	${EndIf}
!macroend
