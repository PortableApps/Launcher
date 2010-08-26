${SegmentFile}

!macro _DirectoriesMove_Start
	${IfThen} $0 != - ${|} StrCpy $0 $DataDirectory\$0 ${|}
	${ParseLocations} $1
!macroend

${SegmentPrePrimary}
	${ForEachINIPair} DirectoriesMove $0 $1
		!insertmacro _DirectoriesMove_Start

		; Backup data from a local installation
		${ForEachDirectory} $5 $4 $1
			${DebugMsg} "Backing up $5\$4 to $5\$4.BackupBy$AppID"
			Rename $5\$4 $5\$4.BackupBy$AppID
		${NextDirectory}

		; See if the parent local directory exists. If not, create it and
		; note down to delete it at the end if it's empty.
		${IfNot} ${FileExists} $5
			CreateDirectory $5
			WriteINIStr $DataDirectory\PortableApps.comLauncherRuntimeData-$BaseName.ini DirectoriesMove RemoveIfEmpty:$5 true
		${EndIf}

		; If the key is -, don't move/copy to the target directory.
		; If portable data exists move/copy it to the target directory.
		${If} $0 == -
			${IfNot} ${WildCardFlag} ; can not create folders with wild-cards (obviously)
				CreateDirectory $1
				${DebugMsg} "DirectoriesMove key -, so only creating the directory $1 (no file copy)."
			${EndIf}
		${Else}
			${ForEachDirectory} $3 $2 $0
				${If} ${WildCardFlag}
					StrCpy $4 $2 ;if wildcards are used then inherit the filename
				${Else}
					${GetFileName} $1 $4
				${EndIf}
				${GetRoot} $0 $6 ; compare
				${GetRoot} $1 $7 ; drive
				${If} $6 == $7   ; letters
					${DebugMsg} "Renaming directory $3\$2 to $5\$4"
					Rename $3\$2 $5\$4 ; same volume, rename OK
				${Else}
					${DebugMsg} "Copying $3\$2\*.* to $5\$4\*.*"
					CreateDirectory $5\$4
					CopyFiles /SILENT $3\$2\*.* $5\$4
				${EndIf}
			${NextDirectory}
			${If} ${Errors}
				${IfNot} ${WildCardFlag} ; can not create folders with wild-cards (obviously)
					; Nothing to copy, so just create the directory, ready for use.
					CreateDirectory $1
				${EndIf}
				${DebugMsg} "$0\*.* does not exist, so not copying it to $1.$\r$\n(Note for developers: if you want default data, remember to put files in App\DefaultData\$0)"
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
		${ForEachDirectory} $5 $4 $1
			${If} ${WildCardFlag}
				StrCpy $2 $4 ;if wildcards are used then inherit the filename
			${Else}
				${GetFileName} $0 $2
			${EndIf}
			${If} $0 == -
				${DebugMsg} "DirectoriesMove key -, so not keeping data from $1."
			${ElseIf} $RunLocally != true
				${GetRoot} $0 $6 ; compare
				${GetRoot} $1 $7 ; drive
				${If} $6 == $7   ; letters
					${DebugMsg} "Renaming directory $5\$4 to $3\$2"
					Rename $5\$4 $3\$2 ; same volume, rename OK
				${Else}
					${DebugMsg} "Copying $5\$4\*.* to $3\$2\*.*"
					RMDir /R $3\$2
					CreateDirectory $3\$2
					CopyFiles /SILENT $5\$4\*.* $3\$2
				${EndIf}
			${EndIf}
			; And then remove it from the runtime location
			${DebugMsg} "Removing portable settings directory from run location ($5\$4)."
			RMDir /R $5\$4
		${NextDirectory}

		; If the parent directory we put the directory in locally didn't exist
		; before, delete it if it's empty.
		ReadINIStr $6 $DataDirectory\PortableApps.comLauncherRuntimeData-$BaseName.ini DirectoriesMove RemoveIfEmpty:$5
		${If} $6 == true
			RMDir $5
		${EndIf}

		; And move that backup of any local data from earlier if it exists.
		StrLen $3 .BackupBy$AppID
		${ForEachDirectory} $5 $4 $1.BackupBy$AppID
			StrCpy $1 $4 -$3
			${DebugMsg} "Moving local settings from $5\$4 to $5\$1."
			Rename $5\$4 $5\$1
		${NextDirectory}
	${NextINIPair}
!macroend
