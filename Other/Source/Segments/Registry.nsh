${SegmentFile}

!include Registry.nsh

Var UsesRegistry

${SegmentInit}
	${ReadLauncherConfig} $UsesRegistry Activate Registry
	${DebugMsg} "Registry sections enabled."
!macroend

${SegmentUnload}
	${IfThen} $UsesRegistry == true ${|} ${registry::Unload} ${|}
!macroend
