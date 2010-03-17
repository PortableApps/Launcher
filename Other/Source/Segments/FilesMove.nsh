${SegmentFile}

${SegmentPrePrimary}
	${ForEachINIPair} FilesMove $0 $1
		${ParseLocations} $1

		${GetFileName} $0 $2

		StrCpy $0 $DataDirectory\$0
		StrCpy $1 $1\$2

		;=== Backup data from a local installation
		${IfNot} ${FileExists} $1-BackupBy$AppID
		${AndIf} ${FileExists} $1
			${DebugMsg} "Backing up $1 to $1-BackupBy$AppID"
			Rename $1 $1-BackupBy$AppID
		${EndIf}
		${If} ${FileExists} $0
			${DebugMsg} "Copying $0 to $1"
			${GetRoot} $0 $2 ; compare
			${GetRoot} $1 $3 ; drive
			${If} $2 == $3   ; letters
				Rename $0 $1 ; same volume, rename OK
			${Else}
				${GetParent} $1 $1
				${IfNot} ${FileExists} $1
					CreateDirectory $1
					WriteINIStr $DataDirectory\PortableApps.comLauncherRuntimeData.ini FilesMove RemoveIfEmpty:$1 true
				${EndIf}
				CopyFiles /SILENT $0 $1
			${EndIf}
		${EndIf}
	${NextINIPair}
!macroend

${SegmentPostPrimary}
	${ForEachINIPair} FilesMove $0 $1
		${ParseLocations} $1
		${GetFileName} $0 $2
		StrCpy $0 $DataDirectory\$0
		StrCpy $4 $1
		StrCpy $1 $1\$2

		${If} $RunLocally != true
			${DebugMsg} "Copying file from $1 to $DataDirectory\$0"
			${GetRoot} $0 $2 ; compare
			${GetRoot} $1 $3 ; drive
			${If} $2 == $3   ; letters
				Rename $1 $0 ; same volume, rename OK
			${ElseIf} ${FileExists} $1
				Delete $0
				${GetParent} $0 $0
				CopyFiles /SILENT $1 $0
			${EndIf}
		${EndIf}
		${DebugMsg} "Removing portable settings file $1 from run location."
		Delete $1

		ReadINIStr $2 $DataDirectory\PortableApps.comLauncherRuntimeData.ini FilesMove RemoveIfEmpty:$4
		${If} $2 == true
			RMDir $4
		${EndIf}

		${If} ${FileExists} $1-BackupBy$AppID
			${DebugMsg} "Moving local settings file from $1-BackupBy$AppID to $1"
			Rename $1-BackupBy$AppID $1
		${EndIf}
	${NextINIPair}
!macroend
