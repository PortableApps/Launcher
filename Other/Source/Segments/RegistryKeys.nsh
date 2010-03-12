${SegmentFile}

${SegmentPrePrimary}
	${If} $UsesRegistry == true
		${ForEachINIPair} RegistryKeys $0 $1
			;=== Backup the registry
			${ValidateRegistryKey} $1
			${registry::KeyExists} HKEY_CURRENT_USER\Software\PortableApps.com\Keys\$1 $R9
			${If} $R9 != 0
				${registry::KeyExists} $1 $R9
				${If} $R9 != -1
					${DebugMsg} "Backing up registry key $1 to HKEY_CURRENT_USER\Software\PortableApps.com\Keys\$1"
					${registry::MoveKey} $1 HKEY_CURRENT_USER\Software\PortableApps.com\Keys\$1 $R9
				${EndIf}
			${EndIf}

			${If} ${FileExists} $DataDirectory\settings\$0.reg
				SetErrors
				${DebugMsg} "Loading $DataDirectory\settings\$0.reg into the registry."
				${If} ${FileExists} $WINDIR\system32\reg.exe
					nsExec::Exec `"$WINDIR\system32\reg.exe" import "$DataDirectory\settings\$0.reg"`
					Pop $R9
					${IfThen} $R9 = 0 ${|} ClearErrors ${|}
				${EndIf}

				${If} ${Errors}
					${registry::RestoreKey} $DataDirectory\settings\$0.reg $R9
					${If} $R9 != 0
						WriteINIStr $DataDirectory\PortableApps.comLauncherRuntimeData.ini FailedRegistryKeys $0 true
						${DebugMsg} "Failed to load $DataDirectory\settings\$0.reg into the registry."
					${EndIf}
				${EndIf}
			${EndIf}
		${NextINIPair}
	${EndIf}
!macroend

${SegmentPostPrimary}
	${If} $UsesRegistry == true
		${ForEachINIPair} RegistryKeys $0 $1
			${ValidateRegistryKey} $1
			ClearErrors
			ReadINIStr $R9 $DataDirectory\PortableApps.comLauncherRuntimeData.ini FailedRegistryKeys $0
			${If} ${Errors} ; didn't fail
			${AndIf} $RunLocally != true
				${DebugMsg} "Saving registry key $1 to $DataDirectory\settings\$0.reg."
				${registry::SaveKey} $1 $DataDirectory\settings\$0.reg "" $R9
			${EndIf}

			${DebugMsg} "Deleting registry key $1."
			${registry::DeleteKey} $1 $R9
			${registry::KeyExists} HKEY_CURRENT_USER\Software\PortableApps.com\Keys\$1 $R9
			${If} $R9 != -1
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
