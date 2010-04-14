${SegmentFile}

${SegmentPrePrimary}
	${ForEachINIPair} DirectoriesMove $0 $1
		StrCpy $0 $DataDirectory\$0
		${ParseLocations} $1

		;=== Backup data from a local installation
		${If} ${FileExists} $1
			${DebugMsg} "Backing up $1 to $1-BackupBy$AppID"
			Rename $1 $1-BackupBy$AppID
		${EndIf}
		${If} ${FileExists} $0\*.*
			${GetRoot} $0 $2 ; compare
			${GetRoot} $1 $3 ; drive
			${If} $2 == $3   ; letters
				${DebugMsg} "Renaming directory $0 to $1"
				Rename $0 $1 ; same volume, rename OK
			${Else}
				${DebugMsg} "Copying $0\*.* to $1\*.*"
				CreateDirectory $1
				CopyFiles /SILENT $0\*.* $1
			${EndIf}
		${Else}
			CreateDirectory $1
			${DebugMsg} "$DataDirectory\$0\*.* does not exist, so not copying it to $1.$\n(Note for developers: if you want default data, remember to put files in App\DefaultData\$0)"
		${EndIf}
	${NextINIPair}
!macroend

${SegmentPostPrimary}
	${ForEachINIPair} DirectoriesMove $0 $1
		StrCpy $0 $DataDirectory\$0
		${ParseLocations} $1

		${If} $RunLocally != true
			${GetRoot} $0 $2 ; compare
			${GetRoot} $1 $3 ; drive
			${If} $2 == $3   ; letters
				${DebugMsg} "Renaming directory $1 to $0"
				Rename $1 $0 ; same volume, rename OK
			${ElseIf} ${FileExists} $1
				${DebugMsg} "Copying $1\*.* to $0\*.*"
				RMDir /R $0
				CreateDirectory $0
				CopyFiles /SILENT $1\*.* $0
			${EndIf}
		${EndIf}
		${DebugMsg} "Removing portable settings directory from run location ($1)."
		RMDir /R $1

		${If} ${FileExists} $1-BackupBy$AppID
			${DebugMsg} "Moving local settings from $1-BackupBy$AppID to $1."
			Rename $1-BackupBy$AppID $1
		${EndIf}
	${NextINIPair}
!macroend
