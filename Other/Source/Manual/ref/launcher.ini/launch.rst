.. ini-section:: [Launch]

[Launch]
========

This document covers all the launcher.ini values in the :ini-section:`![Launch]` section.

The :ini-section:`![Launch]` section provides details regarding the launching of the application and surrounding details.

.. ini-key:: [Launch]:AppName

AppName
-------

| Value: ``App Name``
| Deprecated.

----

Specify the application name (non-portable version) here, for displaying in the
"already running" error box. If this is not specified, the value will be
obtained from the ``Name`` field in appinfo.ini, minus ``Portable`` or ``,
Portable Edition``. Please consider using the standard portable application
naming scheme ("*AppName* Portable") instead of specifying this value.

**Example:** for the program "App Name", this value would be ``App Name``
(though it should be unset and ``Name`` in AppInfo.ini should be set to ``App
Name Portable`` or ``App Name, Portable Edition``.) 

.. ini-key:: [Launch]:ProgramExecutable

ProgramExecutable
-----------------

| Mandatory.
| |envsub|

----

Specify the program to be launched by the PortableApps.com Launcher here,
relative to the App directory of the portable application.

There is a special case for Java applications; after specifying
:ini-key:`[Activate]:Java`\ ``=require`` they can specify a value of
``java.exe`` or ``javaw.exe`` and it will be interpreted into the path to that
executable in the Java Runtime Environment.

**Example:** inside the portable application package, the executable to run is
at App\AppName\AppName.exe, so, after removing the App,
:ini-key:`ProgramExecutable <[Launch]:ProgramExecutable>`\
``=AppName\AppName.exe``

.. ini-key:: [Launch]:CommandLineArguments

CommandLineArguments
--------------------

| Optional.
| |envsub|

----

If you need to pass any command line arguments to :ini-key:`ProgramExecutable
<[Launch]:ProgramExecutable>` to make it run or make it portable, specify them
here. Remember that if your program is running from a path with spaces, you may
need to put double quotation marks around the value, e.g. ``-d
"%PAL:DataDir%\settings"``. If you do so, you should put *single* quotation
marks around the whole string, like this: :ini-key:`CommandLineArguments
<[Launch]:CommandLineArguments>`\ ``='-d "%PAL:DataDir%\settings"'``.

For Java applications, you will almost always need to specify parameters here.
See :ref:`topics-java` for more information.

**Example:** the application being made portable accepts a
``--data-directory=`` command line argument to make it portable, but it does
*not* require the string to be quoted:
:ini-key:`CommandLineArguments <[Launch]:CommandLineArguments>`\
``=--data-directory=%PAL:DataDir%\settings``

.. ini-key:: [Launch]:WorkingDirectory

WorkingDirectory
----------------

| Optional.
| |envsub|

----

If the application must be run from a certain working directory, either to
store its settings there or so that it can find certain files critical to it,
set it here. If the reason is so that it can find files, you may be able to
circumvent this by placing the application's directory in the ``PATH``.  See
:ini-section:`[Environment]` for details on that technique.  If possible, avoid
using this as it will make relative files passed through the command line fail
unless it is only a single file given (which will be automatically corrected).

**Example:** ``%PAL:AppDir%\AppName``

.. ini-key:: [Launch]:RunAsAdmin

RunAsAdmin
----------

| Values: ``force`` / ``try`` / none
| Default: none
| Optional.

----

.. ini-key:: [Launch]:CleanTemp

CleanTemp
---------

| Values: ``true`` / ``false``
| Default: ``true``
| Optional.

----

.. ini-key:: [Launch]:SinglePortableAppInstance

SinglePortableAppInstance
-------------------------

| Values: ``true`` / ``false``
| Default: ``false``
| Optional.

----

.. ini-key:: [Launch]:SingleAppInstance

SingleAppInstance
-----------------

| Values: ``true`` / ``false``
| Default: ``true``
| Optional.

----

.. ini-key:: [Launch]:CloseEXE

CloseEXE
--------

| Values: ``another_optional_app.exe``
| Optional.

----

.. ini-key:: [Launch]:LaunchAfterSplashScreen

LaunchAfterSplashScreen
-----------------------

| Values: ``true`` / ``false``
| Default: ``false``
| Optional.

----

.. ini-key:: [Launch]:WaitForProgram

WaitForProgram
--------------

| Values: ``true`` / ``false``
| Default: ``true``
| Optional.

----

.. ini-key:: [Launch]:WaitForOtherInstances

WaitForOtherInstances
---------------------

| Values: ``true`` / ``false``
| Default: ``true``
| Optional.

----

.. ini-key:: [Launch]:WaitForEXE

WaitForEXE
----------

| Value: ``another_optional_app.exe``
| Optional.

----

.. ini-key:: [Launch]:RefreshShellIcons

RefreshShellIcons
-----------------

| Values: ``before`` / ``after`` / ``both`` / none
| Default: none
| Optional.

----

.. ini-key:: [Launch]:HideCommandLineWindow

HideCommandLineWindow
---------------------

| Values: ``true`` / ``false``
| Default: ``false``
| Optional.

----


