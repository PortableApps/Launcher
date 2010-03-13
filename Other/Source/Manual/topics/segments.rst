.. _topics-segments:

Segments
========

The PortableApps.com Launcher source code is divided up into lots of "segments",
each of which can run a number of "hooks". This aids with code separation of
different pieces of functionality, by grouping code by what it does rather than
when it executes. Here is the current list of segments:

* Core
* DirectoriesCleanup
* DirectoriesMove
* DriveLetter
* Environment
* ExecString
* FileWrite
* FilesMove
* InstanceManagement
* Java
* LauncherLanguage
* Mutex
* RefreshShellIcons
* Registry
* RegistryCleanup
* RegistryKeys
* RegistryValueBackupDelete
* RegistryValueWrite
* RunAsAdmin
* RunLocally
* Services
* Settings
* SplashScreen
* Temp
* Variables
* WorkingDirectory

*Descriptions of what each segment does is coming*

Hooks
-----

Here is a list of the hooks which can be executed:

* ``.onInit``: things which must go in the NSIS ``.onInit`` function (see the
  `NSIS documentation`_ for details about ``.onInit``)
* ``Init``: load data into variables, abort the launcher if necessary, and do
  anything else of a "starting up" nature".
* ``Pre``: do things to make the application portable which must always be
  done, whether the launcher is dealing with a primary or secondary instance of
  the application.
* ``PrePrimary``: actions to make the application portable which should only be
  run with a primary instance of an application.
* ``PreSecondary``:  actions to make the application portable which should only
  be run with a secondary or subsequent instance of an application. I haven't
  yet thought of an instance when this would be useful but there could be.
* ``PreExec``: just before the program gets executed, there's an opportunity to
  do something here. Try to use the ``Pre`` hook instead.
* ``PreExecPrimary``: ``PreExec`` for primary instances.
* ``PreExecSecondary``: ``PreExec`` for secondary and subsequent instances.
* ``Post``: clean up the application and handle restoration of settings and
  related things in here.
* ``PostPrimary``: ``Post`` for primary instances.
* ``PostSecondary``: ``Post`` for secondary and subsequent instances.
* ``Unload``: unload plug-ins and clean up traces from the launcher itself.

.. _`NSIS documentation`: http://nsis.sourceforge.net/Docs/Chapter4.html#4.7.2.1.2
