.. _topics-registry:

=========================
Dealing with the registry
=========================

Many applications store their data in the registry; when making such an
application portable this data must be preserved.

Hives
=====

The registry is divided up into "hives" for storing data. Here is a list of the
hives supported by the PortableApps.com Launcher:

* **HKEY_LOCAL_MACHINE** (**HKLM**) -- settings shared between users; requires
  administrative privileges to write to it
* **HKEY_CURRENT_USER** (**HKCU**) -- settings for the current user; requires no
  special permissions to write to it, but on restricted accounts certain methods
  of writing to it will not work.
* **HKEY_CLASSES_ROOT** (**HKCR**) -- a virtual hive constructed of an
  amalgamation of ``HKEY_LOCAL_MACHINE\Classes`` and
  ``HKEY_CURRENT_USER\Classes`` (``HKEY_CURRENT_USER\Classes`` takes
  precedence). In your launcher configuration you should use ``HKCU\Classes``
  for this value instead.

The official format for hives is the four-letter abbreviation (``HKLM`` or
``HKCU``) instead of the long name.

**A note on HKEY_USERS (HKU)**: programs like Regshot use the full path to
HKEY_CURRENT_USER, which includes the user ID. This means that anything like
``HKU\S-?-?-??-?????????-?????????-?????????-????`` (each ``?`` is a number)
should be used as ``HKCU``. There is also ``HKU\.DEFAULT`` which is the same as
far as portability is concerned.

Keys and values to ignore
=========================

Lots of cache-type data is stored in the registry and other Windows settings
which can be safely ignored when making a portable application. This section
will gradually grow with lists of such values which you can ignore when making
an application portable or when testing an application.

These keys are in HKCU:

* ``SessionInformation\ProgramCount``
* ``Software\Microsoft\Cryptography\RNG\Seed``
* ``Software\Microsoft\DirectDraw\MostRecentApplication``
* ``Software\Microsoft\DirectInput\MostRecentApplication``
* ``Software\Microsoft\SchedulingAgent``
* ``Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedMRU``
* ``Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedMRU``
* ``Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSaveMRU``
* ``Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts``
* ``Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist``
* ``Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist``
* ``Software\Microsoft\Windows\CurrentVersion\Group Policy``
* ``Software\Microsoft\Windows\ShellNoRoam\BagMRU``
* ``Software\Microsoft\Windows\ShellNoRoam\Bags``
* ``Software\Microsoft\Windows\ShellNoRoam\MUICache``

These keys are in HKLM:

* ``Software\Microsoft\Windows\CurrentVersion\Reliability``
* ``System\ControlSet001`` (equivalent to ``System\CurrentControlSet``)
* ``System\CurrentControlSet\Control\DeviceClasses``
* ``System\CurrentControlSet\Services\*\Enum``
* ``System\CurrentControlSet\Services\SharedAccess``
* ``System\CurrentControlSet\Services\swmidi``

If you come up with more keys that can be ignored, please :ref:`contact Chris
Morgan <ask>`.

Specific registry keys
======================

Some registry keys have particular ways of dealing with them. These are listed
here.

``HKCU\Software\JavaSoft\Prefs``
--------------------------------

Keys in here are from Java applications which use
:ref:`topics-java-java.util.prefs`. See that page for tips on dealing with those
registry keys.

``HKCU\Software\Trolltech``
---------------------------

Keys in this key are from Qt applications. See :ref:`topics-qt` for details on
what to do about them.

General handling of registry keys
=================================

The normal way of dealing with registry keys in the launcher configuration file
is with the
:ini-section:`[RegistryKeys]`,
:ini-section:`[RegistryValueWrite]`,
:ini-section:`[RegistryCleanupIfEmpty]`,
:ini-section:`[RegistryCleanupForce]` and
:ini-section:`[RegistryValueBackupDelete]` sections.

*This document is not complete*
