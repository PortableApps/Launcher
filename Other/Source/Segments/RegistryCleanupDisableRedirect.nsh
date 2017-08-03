${SegmentFile}

${SegmentPostPrimary}
    ${If} $PAL:Bits == 64
        SetRegView 64
        ${If} $UsesRegistry == true
            ; RegistryCleanupIfEmptyDisableRedirect
            StrCpy $R0 1
            ${Do}
                ClearErrors
                ${ReadLauncherConfig} $1 RegistryCleanupIfEmptyDisableRedirect $R0
                ${IfThen} ${Errors} ${|} ${ExitDo} ${|}
                ${ValidateRegistryKey} $1
                ${DebugMsg} "Deleting registry key $1 if it is empty."
                ${registry::DeleteKeyEmpty} $1 $R9
                IntOp $R0 $R0 + 1
            ${Loop}

            ; RegistryCleanupForceDisableRedirect
            StrCpy $R0 1
            ${Do}
                ClearErrors
                ${ReadLauncherConfig} $1 RegistryCleanupForceDisableRedirect $R0
                ${IfThen} ${Errors} ${|} ${ExitDo} ${|}
                ${ValidateRegistryKey} $1
                ${DebugMsg} "Deleting registry key $1."
                ${registry::DeleteKey} $1 $R9
                IntOp $R0 $R0 + 1
            ${Loop}
        ${EndIf}
        SetRegView 32
    ${EndIf}
!macroend
