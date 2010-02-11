${SegmentFile}

!include Registry.nsh

Var UsesRegistry

${SegmentInit}
	${ReadLauncherConfig} $UsesRegistry Activate Registry
!macroend

${SegmentUnload}
	${IfThen} $UsesRegistry == true ${|} ${registry::Unload} ${|}
!macroend
