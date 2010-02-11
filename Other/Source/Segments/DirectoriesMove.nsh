${SegmentFile}

${SegmentPrePrimary}
	${ForEachINIPair} DirectoriesMove $0 $1
		${ParseLocations} $1

		;=== Backup data from a local installation
		${If} ${FileExists} $1
			${DebugMsg} "Backing up $1 to $1-BackupBy$AppID"
			Rename $1 $1-BackupBy$AppID
		${EndIf}
		CreateDirectory $1
		${If} ${FileExists} $DATADIRECTORY\$0\*.*
			${DebugMsg} "Copying $DATADIRECTORY\$0\*.* to $1\*.*"
			CopyFiles /SILENT $DATADIRECTORY\$0\*.* $1
		${Else}
			${DebugMsg} "$DATADIRECTORY\$0\*.* does not exist, so not copying it to $1.$\n(Note for developers: if you want default data, remember to put files in App\DefaultData\$0)"
		${EndIf}
	${NextINIPair}
!macroend

${SegmentPostPrimary}
	${ForEachINIPair} DirectoriesMove $0 $1
		${ParseLocations} $1

		${If} $RunLocally != true
			${DebugMsg} "Copying settings from $1\*.* to $DATADIRECTORY\$0."
			RMDir /R $DATADIRECTORY\$0
			CreateDirectory $DATADIRECTORY\$0
			CopyFiles /SILENT $1\*.* $DATADIRECTORY\$0
		${EndIf}
		${DebugMsg} "Removing portable settings directory from run location ($1)."
		RMDir /R $1

		${If} ${FileExists} $1-BackupBy$AppID
			${DebugMsg} "Moving local settings from $1-BackupBy$AppID to $1."
			Rename $1-BackupBy$AppID $1
		${EndIf}
	${NextINIPair}
!macroend
