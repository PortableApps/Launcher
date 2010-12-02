.. _examples:

Examples
========

Here are some fully worked examples for the PortableApps.com Launcher.

.. toctree::

   scribus
   7-zip

*More worked examples will be written some time. For the moment you can look at
applications which have been made portable with the PortableApps.com Launcher
and work out how they work manually.*

.. _apps-using-pal:

Apps using the PortableApps.com Launcher
========================================

When learning to use the PortableApps.com Launcher, referring to various
existing apps which already use the PortableApps.com Launcher can be very
helpful.

Here is a list of the apps which have been officially released at
PortableApps.com which use the PortableApps.com Launcher and notes on special
features that they use.

`AssaultCube <http://portableapps.com/apps/games/assaultcube_portable>`_
------------------------------------------------------------------------

* Running a batch file instead of an executable (including using
  :ini-key:`[Launch]:HideCommandLineWindow`)
* :ini-key:`[Launch]:LaunchAppAfterSplash`
* Waiting for multiple executables

`Audacity <http://portableapps.com/apps/music_video/audacity_portable>`_
------------------------------------------------------------------------

* Writing INI strings including using paths with double backslashes
* Updating drive letters
* Moving a directory
* Language switching including :ini-section:`[LanguageFile]` language
  preservation and :ini-section:`[LanguageStrings]` mappings
* Single portable app instance but multiple app instances

`gVim <http://portableapps.com/apps/development/gvim_portable>`_
----------------------------------------------------------------

* Allowing multiple instances of portable and non-portable to mix
* Not needing to wait for the program to finish
* Command line arguments
* Environment variables
* Language switching
* Updating drive letters

`NSIS <http://portableapps.com/apps/development/nsis_portable>`_
----------------------------------------------------------------

* Multiple executables (including
  :ini-key:`[Launch]:ProgramExecutableWhenParameters`)
* Registry key
* Updating drive letters

`Opera <http://portableapps.com/apps/internet/opera_portable>`_
---------------------------------------------------------------

* Registry key
* Writing INI strings
* Updating drive letters
* Moving a directory
* Language switching including :ini-section:`[LanguageFile]` language
  preservation and :ini-section:`[LanguageStrings]` mappings

`Paul's Extreme Sound Stretch`_
-------------------------------

* Working directory
* Moving a directory
* Updating drive letters

.. _Paul's Extreme Sound Stretch:
   http://portableapps.com/apps/music_video/paul_stretch_portable

`PChat <http://portableapps.com/apps/internet/pchat_portable>`_
---------------------------------------------------------------

* Language switching
* Environment variables
* Command line arguments

`SMPlayer <http://portableapps.com/apps/music_video/smplayer_portable>`_
------------------------------------------------------------------------

* Command line arguments
* Support enabled for :ini-key:`directory moving <[Launch]:DirectoryMoveOK>`
  (though not yet released)
* Writing INI strings
* Updating drive letters
* Moving a directory
* Language switching including :ini-section:`[LanguageFile]` language
  preservation and :ini-section:`[LanguageStrings]` mappings

`SQLite Database Browser`_
--------------------------

* Working directory (and that's all - a good example of keeping it simple)

.. _SQLite Database Browser:
   http://portableapps.com/apps/development/sqlite_database_browser_portable
