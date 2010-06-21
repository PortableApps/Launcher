.. ini-section:: [FilesMove]

[FilesMove]
===========

These are files for which to manage portability. They come in the form ``[file
name]=[target directory]``.

The *file name* is the location of the place where it is saved, relative to the
portable data directory (AppNamePortable\\Data).

The *target directory* is the full path to the directory the file is copied to
during the program execution. Do not include the file name. |envsub|

If the target directory already exists at the start of the process, it will be
backed up (to *target directory*\ \\\ *file name*-BackupBy\ *AppID*) and
restored at the end.

Wildcards are not yet supported.

**Example:** ``settings\file.txt=%PAL:AppDir%\AppName``

.. ini-section:: [DirectoriesMove]

[DirectoriesMove]
=================

These are directories for which to manage portability. They come in the form
``[directory]=[target location]``.

The *directory* is the location of the source directory, relative to the
portable data directory (AppNamePortable\\Data).

The *target location* includes the directory you want it to go to, so
``%PAL:DataDir%\[directory]\*.*`` gets copied to ``[target location]\*.*``.
|envsub|

If the target directory already exists at the start of the process, it will be
backed up (to *target location*-BackupBy\ *AppID*) and restored at the end.

If you do not wish to save the data but only want to keep a local version safe
and throw away any changes, set the source directory to ``-``, so you end up
with ``-=[target location]``. If you don't wish to back up local data, you can
use :ini-section:`[DirectoriesCleanupForce]`.

Wildcards are not yet supported.

**Example:** ``settings=%APPDATA%\Pub\lisher\AppName``

.. ini-section:: [DirectoriesCleanupIfEmpty]

[DirectoriesCleanupIfEmpty]
===========================

|inikeyint|

|envsub|

Wildcards are not supported.

----

These are directories which get cleaned up after the application has run if they
are empty. This is useful if there is a tree which will be left behind, for
example, if something stores to ``%APPDATA%\Publisher\AppName``, when
``AppName`` is saved, ``Publisher`` will still be left, empty. Remove it with a
line in here.

**Example:** ``1=%APPDATA%\Publisher``

.. ini-section:: [DirectoriesCleanupForce]

[DirectoriesCleanupForce]
=========================

|inikeyint|

|envsub|

Wildcards are not supported.

----

These are directories which get removed after the application has run. This is
useful if there is a tree which will be left behind, for example, if something
stores temporary data which can be safely deleted in ``%APPDATA%\AppName\Temp``.
Remove it with a line in here.

If you need to back up the local directory so that it will not be ruined, you
can use :ini-section:`[DirectoriesMove]` with a key name of ``-``.

**Example:** ``1=%APPDATA%\Publisher``
