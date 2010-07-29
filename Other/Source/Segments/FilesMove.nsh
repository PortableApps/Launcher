${SegmentFile}

!macro _FilesMove_Start
	; By the end:
	; $0 = full path to source
	; $1 = full path to target
	; $2 = file name (only used as a temporary variable)
	; $4 = target directory
	${ParseLocations} $1
	${GetFileName} $0 $2
	StrCpy $0 $DataDirectory\$0
	StrCpy $4 $1
	StrCpy $1 $1\$2
!macroend

${SegmentPrePrimary}
	${ForEachINIPair} FilesMove $0 $1
		!insertmacro _FilesMove_Start

		; Backup data from a local installation
		${ForEachFile} $4 $2 $1
			${IfNot} ${FileExists} $4\$2.BackupBy$AppID 
				${DebugMsg} "Backing up $4\$2 to $4\$2.BackupBy$AppID"
				Rename $4\$2 $4\$2.BackupBy$AppID
			${EndIf}
		${NextFile}

		; See if the parent local directory exists. If not, create it and
		; note down to delete it at the end if it's empty.
		${IfNot} ${FileExists} $4
			CreateDirectory $4
			WriteINIStr $DataDirectory\PortableApps.comLauncherRuntimeData-$BaseName.ini FilesMove RemoveIfEmpty:$4 true
		${EndIf}
		; If portable data exists move/copy it to the target directory.  If the
		; target directory doesn't exist, note down for the end to remove it
		; again if it's empty.
		${ForEachFile} $3 $2 $0
			${DebugMsg} "Copying $3\$2 to $4\$2"
			${GetRoot} $0 $5 ; compare
			${GetRoot} $4 $6 ; drive
			${If} $5 == $6   ; letters
				Rename $3\$2 $4\$2 ; same volume, rename OK
			${Else}
				CopyFiles /SILENT $3\$2 $4\$2
			${EndIf}
		${NextFile}
	${NextINIPair}
!macroend

${SegmentPostPrimary}
	${ForEachINIPair} FilesMove $0 $1
		!insertmacro _FilesMove_Start

		; If not in Live mode, copy the data back to the Data directory.
		${GetParent} $0 $3
		${ForEachFile} $4 $2 $1
			${If} $RunLocally != true
				${GetRoot} $0 $5 ; compare
				${GetRoot} $1 $6 ; drive
				${If} $5 == $6   ; letters
					${DebugMsg} "Renaming file from $4\$2 to $3\$2"
					Rename $4\$2 $3\$2 ; same volume, rename OK
				${Else}
					${DebugMsg} "Copying file from $4\$2 to $3\$2"
					Delete $3\$2
					CopyFiles /SILENT $4\$2 $3\$2
				${EndIf}
			${EndIf}
			; And then remove it from the runtime location
			${DebugMsg} "Removing portable settings file $4\$2 from run location."
			Delete $4\$2
		${NextFile}

		; If the local directory we put it in didn't exist before, delete it if
		; it's empty.
		ReadINIStr $2 $DataDirectory\PortableApps.comLauncherRuntimeData-$BaseName.ini FilesMove RemoveIfEmpty:$4
		${If} $2 == true
			RMDir $4
		${EndIf}

		; And move that backup of any local data from earlier if it exists.
		StrLen $3 .BackupBy$AppID
		${ForEachFile} $4 $2 $1.BackupBy$AppID
			StrCpy $1 $2 -$3
			${DebugMsg} "Moving local settings file from $4\$2 to $4\$1"
			Rename $4\$2 $4\$1
		${NextFile}
	${NextINIPair}
!macroend
