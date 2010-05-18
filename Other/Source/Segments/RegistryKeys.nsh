${SegmentFile}

${SegmentPrePrimary}
	${If} $UsesRegistry == true
		${ForEachINIPair} RegistryKeys $0 $1
			;=== Backup the registry
			${ValidateRegistryKey} $1
			${IfNot} ${RegistryKeyExists} HKEY_CURRENT_USER\Software\PortableApps.com\Keys\$1
				${If} ${RegistryKeyExists} $1
					${DebugMsg} "Backing up registry key $1 to HKEY_CURRENT_USER\Software\PortableApps.com\Keys\$1"
					${registry::MoveKey} $1 HKEY_CURRENT_USER\Software\PortableApps.com\Keys\$1 $R9
				${EndIf}
			${EndIf}

			${If} $0 == -
				${DebugMsg} "File name -, not data to import."
			${ElseIf} ${FileExists} $DataDirectory\settings\$0.reg
				StrCpy $R9 1 ; 1 = didn't import, 0 = success
				${DebugMsg} "Loading $DataDirectory\settings\$0.reg into the registry."
				${If} ${FileExists} $WINDIR\system32\reg.exe
					ExecDos::Exec `"$WINDIR\system32\reg.exe" import "$DataDirectory\settings\$0.reg"` "" ""
					Pop $R9
				${EndIf}

				${If} $R9 != 0 ; Failed with reg.exe (with it an error code of 0 is success)
					${registry::RestoreKey} $DataDirectory\settings\$0.reg $R9
					${If} $R9 != 0
						WriteINIStr $DataDirectory\PortableApps.comLauncherRuntimeData-$BaseName.ini FailedRegistryKeys $0 true
						${DebugMsg} "Failed to load $DataDirectory\settings\$0.reg into the registry."
					${EndIf}
				${EndIf}
			${Else}
				${DebugMsg} "File $DataDirectory\settings\$0.reg doesn't exist, not loaded into the registry."
			${EndIf}
		${NextINIPair}
	${EndIf}
!macroend

${SegmentPostPrimary}
	${If} $UsesRegistry == true
		${ForEachINIPair} RegistryKeys $0 $1
			${ValidateRegistryKey} $1
			${If} $0 == -
				${DebugMsg} "Registry key $1 will not be saved."
			${Else}
				ClearErrors
				ReadINIStr $R9 $DataDirectory\PortableApps.comLauncherRuntimeData-$BaseName.ini FailedRegistryKeys $0
				${If} ${Errors} ; didn't fail
				${AndIf} $RunLocally != true
					${DebugMsg} "Saving registry key $1 to $DataDirectory\settings\$0.reg."
					${registry::SaveKey} $1 $DataDirectory\settings\$0.reg "" $R9
				${EndIf}
			${EndIf}

			${DebugMsg} "Deleting registry key $1."
			${registry::DeleteKey} $1 $R9
			${If} ${RegistryKeyExists} HKEY_CURRENT_USER\Software\PortableApps.com\Keys\$1
				${DebugMsg} "Moving registry key HKEY_CURRENT_USER\Software\PortableApps.com\Keys\$1 to $1."
				${registry::MoveKey} HKEY_CURRENT_USER\Software\PortableApps.com\Keys\$1 $1 $R9
				${Do}
					${GetParent} $1 $1
					${registry::DeleteKeyEmpty} HKEY_CURRENT_USER\Software\PortableApps.com\Keys\$1 $R9
				${LoopUntil} $1 == ""
			${EndIf}
		${NextINIPair}
		${registry::DeleteKeyEmpty} HKEY_CURRENT_USER\Software\PortableApps.com $R9
	${EndIf}
!macroend
