${SegmentFile}

${SegmentPostPrimary}
	;=== DirectoriesCleanupIfEmpty
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $1 DirectoriesCleanupIfEmpty $R0
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $1
			${DebugMsg} "Cleaning up $1 if it is empty."
			RMDir $1
			IntOp $R0 $R0 + 1
		${Loop}

	;=== DirectoriesCleanupForce
		StrCpy $R0 1
		${Do}
			ClearErrors
			${ReadLauncherConfig} $1 DirectoriesCleanupForce $R0
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${ParseLocations} $1
			${DebugMsg} "Removing directory $1."
			RMDir /r $1
			IntOp $R0 $R0 + 1
		${Loop}
!macroend
