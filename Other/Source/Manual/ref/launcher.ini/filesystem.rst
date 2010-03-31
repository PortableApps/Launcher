.. ini-section:: [FilesMove]

[FilesMove]
===========

These are files for which to manage portability. They come in the form ``[file
name]=[target directory]``.

The *file name* is the location of the place where it is saved, relative to the
portable data directory (AppNamePortable\\Data).

The *target directory* is the full path to the directory the file is copied to
during the program execution. Do not include the file name. |envsub|

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

Wildcards are not yet supported.

**Example:** ``settings=%APPDATA%\Pub\lisher\AppName``

.. ini-section:: [DirectoriesCleanupIfEmpty]

[DirectoriesCleanupIfEmpty]
===========================

| |inikeyint|
| |envsub|
| Wildcards are not supported.

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

| |inikeyint|
| |envsub|
| Wildcards are not supported.

----

These are directories which get removed after the application has run. This is
useful if there is a tree which will be left behind, for example, if something
stores temporary data which can be safely deleted in ``%APPDATA%\AppName\Temp``.
Remove it with a line in here.

**Example:** ``1=%APPDATA%\Publisher``