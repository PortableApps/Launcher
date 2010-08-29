${SegmentFile}

!macro _DirectoriesMove_Start
	${IfThen} $0 != - ${|} StrCpy $0 $DataDirectory\$0 ${|}
	${ParseLocations} $1
!macroend

${SegmentPrePrimary}
	${ForEachINIPair} DirectoriesMove $0 $1
		!insertmacro _DirectoriesMove_Start

		; Backup data from a local installation
		${ForEachDirectory} $4 $3 $1
			${DebugMsg} "Backing up $4 to $4.BackupBy$AppID"
			Rename $4 $4.BackupBy$AppID
		${NextDirectory}

		; If the key is -, don't move/copy to the target directory.
		; If portable data exists move/copy it to the target directory.
		${If} $0 == -
			${IfNot} ${WildCardFlag} ; can not create folders with wild-cards (obviously)
				CreateDirectory $1
				${DebugMsg} "DirectoriesMove key -, so only creating the directory $1 (no file copy)."
			${EndIf}
		${Else}
			; See if the parent local directory exists. If not, create it and
			; note down to delete it at the end if it's empty.
			${GetParent} $1 $4
			${IfNot} ${FileExists} $4
				CreateDirectory $4
				WriteINIStr $DataDirectory\PortableApps.comLauncherRuntimeData-$BaseName.ini DirectoriesMove RemoveIfEmpty:$4 true
			${EndIf}

			${ForEachDirectory} $3 $2 $0
				${IfNotThen} ${WildCardFlag} ${|} ${GetFileName} $1 $2 ${|} ; do not inherit the filename
				${GetRoot} $0 $5 ; compare
				${GetRoot} $1 $6 ; drive
				${If} $5 == $6   ; letters
					${DebugMsg} "Renaming directory $3 to $4\$2"
					Rename $3 $4\$2 ; same volume, rename OK
				${Else}
					${DebugMsg} "Copying $3\*.* to $4\$2\*.*"
					CreateDirectory $4\$2
					CopyFiles /SILENT $3\*.* $4\$2
				${EndIf}
			${NextDirectory}
			${If} ${Errors}
				${IfNotThen} ${WildCardFlag} ${|} CreateDirectory $1 ${|}
				; Nothing to copy, so just create the directory, ready for use.
${!getdebug}
!ifdef DEBUG
				StrLen $2 "$DataDirectory\"
				StrCpy $0 $0 "" $2
				${DebugMsg} "$DataDirectory\$0\*.* does not exist, so not copying it to $1.$\r$\n(Note for developers: if you want default data, remember to put files in App\DefaultData\$0)"
!endif
			${EndIf}
		${EndIf}
	${NextINIPair}
!macroend

${SegmentPostPrimary}
	${ForEachINIPair} DirectoriesMove $0 $1
		!insertmacro _DirectoriesMove_Start

		; If the key is "-", don't copy it back
		; Also if not in Live mode, copy the data back to the Data directory.
		${GetParent} $0 $3
		${ForEachDirectory} $4 $2 $1
			${IfNotThen} ${WildCardFlag} ${|} ${GetFileName} $0 $2 ${|} ; do not inherit the filename
			${If} $0 == -
				${DebugMsg} "DirectoriesMove key -, so not keeping data from $1."
			${ElseIf} $RunLocally != true
				${GetRoot} $0 $5 ; compare
				${GetRoot} $1 $6 ; drive
				${If} $5 == $6   ; letters
					${DebugMsg} "Renaming directory $4 to $3\$2"
					Rename $4 $3\$2 ; same volume, rename OK
				${Else}
					${DebugMsg} "Copying $4\*.* to $3\$2\*.*"
					RMDir /R $3\$2
					CreateDirectory $3\$2
					CopyFiles /SILENT $4\*.* $3\$2
				${EndIf}
			${EndIf}
			; And then remove it from the runtime location
			${DebugMsg} "Removing portable settings directory from run location ($4)."
			RMDir /R $4
		${NextDirectory}

		; If the parent directory we put the directory in locally didn't exist
		; before, delete it if it's empty.
		${GetParent} $1 $4
		ReadINIStr $2 $DataDirectory\PortableApps.comLauncherRuntimeData-$BaseName.ini DirectoriesMove RemoveIfEmpty:$4
		${If} $2 == true
			RMDir $4
		${EndIf}

		; And move that backup of any local data from earlier if it exists.
		${ForEachDirectory} $3 $2 $1.BackupBy$AppID
			${GetBaseName} $2 $2
			${DebugMsg} "Moving local settings from $3 to $4\$2"
			Rename $3 $4\$2
		${NextDirectory}
	${NextINIPair}
!macroend
