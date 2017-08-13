# .NET Framework detection code
# Copyright © 2011 Aluísio Augusto Silva Gonçalves
# Copyright © 2017 PortableApps.com
#
# This software is provided 'as-is', without any express or implied warranty.  In no event will the
# authors be held liable for any damages arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose, including commercial
# applications, and to alter it and redistribute it freely, subject to the following restrictions:
#   1. The origin of this software must not be misrepresented; you must not claim that you wrote
#      the original software.  If you use this software in a product, an acknowledgment in the
#      product documentation would be appreciated but is not required.
#   2. Altered source versions must be plainly marked as such, and must not be misrepresented as
#      being the original software.
#   3. This notice may not be removed or altered from any source distribution.
#


#
# This module enables you to detect installed .NET Framework versions.
# Usage:
#     ${If} ${HasDotNetFramework} <version>
#         /* installed */
#     ${ElseIf} ${Errors}
#             /* invalid version */
#     ${Else}
#             /* not installed */
#     ${EndIf}
#
# Valid version numbers:
# 1.0, 1.0SP1, 1.0SP2, 1.0SP3
# 1.1, 1.1SP1
# 2.0, 2.0SP1, 2.0SP2
# 3.0, 3.0SP1, 3.0SP2
# 3.5, 3.5SP1
# 4.0C, 4.0F
# 4.5, 4.5.1, 4.5.2
# 4.6, 4.6.1, 4.6.2
# 4.7
#

!ifndef _<DotNet>_
!define _<DotNet>_


!include LogicLib.nsh
!include WinVer.nsh


Var _DotNet_ServicePack
Var _DotNet_Version
Var _DotNet_Temp
Var _DotNet_Profile

# Detect .Net 4.5+
#
# Parameters:
# ver:     reported Release Version of .Net Framework (378389 or none)
# fullver: requested .Net Franmework version
# _t:      label to which to go to if the required .Net version is installed
# _f:      label to which to go to if the required .Net version is not installed
!macro _DotNet_HasNET45 ver fullver _t _f
    ClearErrors
    ReadRegDWORD "$R0" HKLM "Software\Microsoft\Net Framework Setup\NDP\v4\Full" Release
    ${If} "$R0" == "378389"
        ${If} "${ver}" == "378389"
            Goto  `${_t}`
        ${EndIf}
    ${ElseIf} $R0 = 378675
        ${If} "${fullver}" == "4.5.1"
            Goto `${_t}`
        ${EndIf}
    ${ElseIf} $R0 = 378758"
        ${If} "${fullver}" == "4.5.1"
            Goto `${_t}`
        ${EndIf}
    ${ElseIf} $R0 = 379893
        ${If} "${fullver}" == "4.5.2"
            Goto `${_t}`
        ${EndIf}
    ${ElseIf} $R0 = 393295
        ${If} "${fullver}" == "4.6"
            Goto `${_t}`
        ${EndIf}
    ${ElseIf} $R0 = 393297
        ${If} "${fullver}" == "4.6"
            Goto `${_t}`
        ${EndIf}
    ${ElseIf} $R0 = 394254
        ${If} "${fullver}" == "4.6.1"
            Goto `${_t}`
        ${EndIf}
    ${ElseIf} $R0 = 394271
        ${If} "${fullver}" == "4.6.1"
            Goto `${_t}`
        ${EndIf}
    ${ElseIf} $R0 = 394802
        ${If} "${fullver}" == "4.6.2"
            Goto `${_t}`
        ${EndIf}
    ${ElseIf} $R0 = 394806
        ${If} "${fullver}" == "4.6.2"
            Goto `${_t}`
        ${EndIf}
    ${ElseIf} $R0 = 460798
        ${If} "${fullver}" == "4.7"
            Goto `${_t}`
        ${EndIf}
    ${ElseIf} $R0 = 460805
        ${If} "${fullver}" == "4.7"
            Goto `${_t}`
        ${EndIf}
    ${ElseIf} $R0 > 460805
        Goto `${_t}`
    ${ElseIf} $R0 == ""
        Goto `${_f}`
    ${EndIf}
!macroend

# Detect .NET 4.0, with an optional service pack
#
# Parameters:
#   sp:      service pack number (0 to none)
#   profile: install profile to detect (C for client, F for full)
#   _t:      label to which go to if the required .NET version is installed
#   _f:      label to which go to if the required .NET version is not installed
!macro _DotNet_HasNET40 sp profile _t _f
	ClearErrors
	${Select} `${profile}`
	${Case} C
		# Client install
		ReadRegDWORD $_DotNet_Temp HKLM "Software\Microsoft\NET Framework Setup\NDP\v4\Client" Install
	${Case} F
		# Full install
		ReadRegDWORD $_DotNet_Temp HKLM "Software\Microsoft\NET Framework Setup\NDP\v4\Full"   Install
	${CaseElse}
		Goto `${_f}`
	${EndSelect}
	IfErrors `${_f}`
	IntCmp $_DotNet_Temp 1 `${_t}` `${_f}` `${_f}`
!macroend

# Detect any version of .NET between 1.1 and 3.5, with an optional service pack
#
# Parameters:
#  ver: .NET version to detect
#   sp:  service pack number (0 to none)
#   _t:  label to which go to if the required .NET version is installed
#   _f:  label to which go to if the required .NET version is not installed
!macro _DotNet_HasNET ver sp _t _f
	ClearErrors
	${If} ${sp} = 0
		# No service pack required; check if installed
		ReadRegDWORD $_DotNet_Temp HKLM "Software\Microsoft\NET Framework Setup\NDP\v${ver}" Install
		IfErrors `${_f}`
		IntCmp $_DotNet_Temp 1 `${_t}` `${_f}` `${_f}`
	${Else}
		# Service pack required; check service pack version
		ReadRegDWORD $_DotNet_Temp HKLM "Software\Microsoft\NET Framework Setup\NDP\v${ver}" SP
		IfErrors `${_f}`
		IntCmp $_DotNet_Temp ${sp} `${_t}` `${_f}` `${_t}`
	${EndIf}
!macroend

# Detect .NET 1.0, with an optional service pack
#
# Parameters:
#   sp: service pack number (0 to none)
#   _t: label to which go to if the required .NET version is installed
#   _f: label to which go to if the required .NET version is not installed
!macro _DotNet_HasNET10 sp _t _f
	ClearErrors
	${If} ${sp} = 0
		# No service pack
		ReadRegStr $_DotNet_Temp HKLM "Software\Microsoft\.NET Framework\Policy\v1.0" 3705
		IfErrors `${_f}` `${_t}`
	${Else}
		# Service pack required
		${If} ${IsWinXP}
		${AndIf} ${OSHasMediaCenter}
		${OrIf} ${OSHasTabletSupport}
			# XP Media Center/Tablet Edition; different registry key
			ReadRegStr $_DotNet_Temp HKLM "Software\Microsoft\Active Setup\Installed Components\{FDC11A6F-17D1-48f9-9EA3-9051954BAA24}" Version
		${Else}
			# Normal install
			ReadRegStr $_DotNet_Temp HKLM "Software\Microsoft\Active Setup\Installed Components\{78705f0d-e8db-4b2d-8193-982bdda15ecd}" Version
		${EndIf}
		IfErrors `${_f}`
		StrCpy $_DotNet_Temp $_DotNet_Temp 1 -1
		IntCmp $_DotNet_Temp `${sp}` `${_t}` `${_f}` `${_t}`
	${EndIf}
!macroend


# Parse and validate a .NET Framework version
#
# Parameters:
#   - .NET version string to parse
#
# Return:
#   `true` if the string is a valid version string, `false` otherwise
#
# Side effects:
#   The module variables $Version, $ServicePack and $Profile are updated with the data of the
#   version string.  The content of these variables should not be relied upon unless the version
#   string has been sucessfully validated.
Function IsValidDotNetVersion
	Pop $_DotNet_Temp

	StrCpy $_DotNet_Version     $_DotNet_Temp 3
	StrCpy $_DotNet_ServicePack $_DotNet_Temp 1  5
	StrCpy $_DotNet_Profile     $_DotNet_Temp "" -1
	${IfThen} $_DotNet_ServicePack == "" ${|} StrCpy $_DotNet_ServicePack 0 ${|}

	${Select} $_DotNet_Version
	${Case} 1.0
		IntCmp $_DotNet_ServicePack 0 Valid Invalid
		IntCmp $_DotNet_ServicePack 3 Valid Valid Invalid
	${Case} 1.1
		IntCmp $_DotNet_ServicePack 0 Valid Invalid
		IntCmp $_DotNet_ServicePack 1 Valid Valid Invalid
	${Case} 2.0
		IntCmp $_DotNet_ServicePack 0 Valid Invalid
		IntCmp $_DotNet_ServicePack 2 Valid Valid Invalid
	${Case} 3.0
		IntCmp $_DotNet_ServicePack 0 Valid Invalid
		IntCmp $_DotNet_ServicePack 2 Valid Valid Invalid
	${Case} 3.5
		IntCmp $_DotNet_ServicePack 0 Valid Invalid
		IntCmp $_DotNet_ServicePack 1 Valid Valid Invalid
	${Case} 4.0
		IntCmp $_DotNet_ServicePack 0 "" Invalid Invalid
		StrCmp $_DotNet_Profile C Valid
		StrCmp $_DotNet_Profile F Valid
    ${Case} 4.5
        IntCmp $_DotNet_ServicePack 0 "" Invalid Invalid
        ${VersionCompare} "$_DotNet_Temp" "4.5" "$R0"
        ${If} "$R0" == 0 
            Goto Valid
        ${ElseIf} "$R0" == 2
        ${AndIf} $_DotNet_Temp == 4.5.1
        ${OrIf} $_DotNet_Temp == 4.5.2
            Goto Valid
        ${EndIf}
    ${Case} 4.6
        IntCmp $_DotNet_ServicePack 0 "" Invalid Invalid
        ${VersionCompare} "$_DotNet_Temp" "4.6" "$R0"
        ${If} "$R0" == 0 
            Goto Valid
        ${ElseIf} "$R0" == 2
        ${AndIf} $_DotNet_Temp == 4.6.1
        ${OrIf} $_DotNet_Temp == 4.6.2
            Goto Valid
        ${EndIf}
    ${Case} 4.7
        IntCmp $_DotNet_ServicePack 0 "" Invalid Invalid
        ${VersionCompare} "$_DotNet_Temp" "4.7" "$R0"
        ${If} "$R0" == 0
        ${OrIf} "$R0" == 2
            Goto Valid
        ${EndIf}
	${EndSelect}

	Valid:
		Push true
		Return
	Invalid:
		Push false
		Return
FunctionEnd
!macro _IsValidDotNetVersion _a _b _t _f
	!insertmacro _LOGICLIB_TEMP
	Push `${_b}`
	Call IsValidDotNetVersion
	Pop $_LOGICLIB_TEMP
	!insertmacro _== $_LOGICLIB_TEMP true `${_t}` `${_f}`
!macroend
!define IsValidDotNetVersion `"" IsValidDotNetVersion`

# Detect if a .NET Framework version is installed
#
# Parameters:
#   - .NET version to detect
#
# Return:
#   `true` if the string is a valid version string, `false` otherwise
Function HasDotNetFramework
	Pop $_DotNet_Temp

	ClearErrors
	${IfNot} ${IsValidDotNetVersion} $_DotNet_Temp
		SetErrors
		Goto NotFound
	${EndIf}

	${Select} $_DotNet_Version
	${Case} 1.0
		!insertmacro _DotNet_HasNET10 $_DotNet_ServicePack Found NotFound
	${Case} 1.1
		!insertmacro _DotNet_HasNET   1.1.4322 $_DotNet_ServicePack Found NotFound
	${Case} 2.0
		!insertmacro _DotNet_HasNET   2.0.50727 $_DotNet_ServicePack Found NotFound
	${Case} 4.0
		!insertmacro _DotNet_HasNET40 $_DotNet_ServicePack $_DotNet_Profile Found NotFound
    ${Case} 4.5
        ${VersionCompare} "$_DotNet_Temp" "4.5" "$R0"
        ${If} "$R0" == 0
            !insertmacro _DotNet_HasNET45 378389 "4.5" Found NotFound
        ${EndIf}
        ${If} "$R0" == 2
            !insertmacro _DotNet_HasNET45 "" "$_DotNet_Temp" Found NotFound
        ${EndIf}
    ${Case} 4.6
        ${VersionCompare} "$_DotNet_Temp" "4.6" "$R0"
        ${If} "$R0" == 0
        ${OrIf} "$R0" == 2
            !insertmacro _DotNet_HasNET45 "" "$_DotNet_Temp" Found NotFound
        ${EndIf}
    ${Case} 4.7
        ${VersionCompare} "$_DotNet_Temp" "4.7" "$R0"
        ${If} "$R0" == 0
        ${OrIf} "$R0" == 2
            !insertmacro _DotNet_HasNET45 "" "$_DotNet_Temp" Found NotFound
        ${EndIf}        
	${CaseElse}
		!insertmacro _DotNet_HasNET   $_DotNet_Version $_DotNet_ServicePack Found NotFound
	${EndSelect}

	Found:
		Push true
		Return
	NotFound:
		Push false
		Return
FunctionEnd
!macro _HasDotNetFramework _a _b _t _f
	!insertmacro _LOGICLIB_TEMP
	Push `${_b}`
	Call HasDotNetFramework
	Pop $_LOGICLIB_TEMP
	!insertmacro _== $_LOGICLIB_TEMP true `${_t}` `${_f}`
!macroend
!define HasDotNetFramework `"" HasDotNetFramework`


!endif # _<DotNet>_
