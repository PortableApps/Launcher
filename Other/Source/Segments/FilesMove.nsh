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
		${IfNot} ${FileExists} $1-BackupBy$AppID
		${AndIf} ${FileExists} $1
			${DebugMsg} "Backing up $1 to $1-BackupBy$AppID"
			Rename $1 $1-BackupBy$AppID
		${EndIf}

		; If portable data exists move/copy it to the target directory.  If the
		; target directory doesn't exist, note down for the end to remove it
		; again if it's empty.
		${If} ${FileExists} $0
			${DebugMsg} "Copying $0 to $1"
			${IfNot} ${FileExists} $4
				CreateDirectory $4
				WriteINIStr $DataDirectory\PortableApps.comLauncherRuntimeData-$BaseName.ini FilesMove RemoveIfEmpty:$4 true
			${EndIf}
			${GetRoot} $0 $2 ; compare
			${GetRoot} $1 $3 ; drive
			${If} $2 == $3   ; letters
				Rename $0 $1 ; same volume, rename OK
			${Else}
				CopyFiles /SILENT $0 $1
			${EndIf}
		${EndIf}
	${NextINIPair}
!macroend

${SegmentPostPrimary}
	${ForEachINIPair} FilesMove $0 $1
		!insertmacro _FilesMove_Start

		; If not in Live mode, copy the data back to the Data directory.
		${If} $RunLocally != true
			${DebugMsg} "Copying file from $1 to $0"
			${GetRoot} $0 $2 ; compare
			${GetRoot} $1 $3 ; drive
			${If} $2 == $3   ; letters
				Rename $1 $0 ; same volume, rename OK
			${ElseIf} ${FileExists} $1
				Delete $0
				;${GetParent} $0 $0
				CopyFiles /SILENT $1 $0
			${EndIf}
		${EndIf}
		; And then remove it from the runtime location
		${DebugMsg} "Removing portable settings file $1 from run location."
		Delete $1

		; If the local directory we put it in didn't exist before, delete it if
		; it's empty.
		ReadINIStr $2 $DataDirectory\PortableApps.comLauncherRuntimeData-$BaseName.ini FilesMove RemoveIfEmpty:$4
		${If} $2 == true
			RMDir $4
		${EndIf}

		; And move that backup of any local data from earlier if it exists.
		${If} ${FileExists} $1-BackupBy$AppID
			${DebugMsg} "Moving local settings file from $1-BackupBy$AppID to $1"
			Rename $1-BackupBy$AppID $1
		${EndIf}
	${NextINIPair}
!macroend
