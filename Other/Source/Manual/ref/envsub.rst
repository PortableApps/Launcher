.. _ref-envsub:

================================
Environment variable substitions
================================

This document covers environment variable substition.

Many of the values in :ref:`launcher.ini <ref-launcher.ini>` are subject to
environment variable substitions. This works by taking the input string and
parsing environment variables, so that a chunk like ``%TEMP%`` will become
something like ``C:\Users\user\AppData\Roaming\Temp``. To make this more useful
in making applications portable, a number of extra environment variables are
provided. This document is primarily here to describe those values.

For the purposes of this page, the portable application in question is
installed to ``X:\PortableApps\AppNamePortable`` and last ran from the drive
``W:``.

Directory variables
===================

Each variable fitting into this category gets several extra environment
variables generated for it, for different forms they may be needed. For
example, when dealing directly with Windows paths must be separated by a
backslash (``\``), while with various other applications, for example
applications ported from Linux, a forward slash (``/``) is often needed, or
even a double backslash (``\\``), or something else.

One complex example is with Java applications that use ``java.util.prefs`` to
store their settings; ``java.util.prefs`` stores settings in the registry, but
its path storage mechanism is unusual. The path gets stored with a forward
slash as the separator, and then all characters *other* than a colon and
lower-case letters are escaped with a slash (including the path separator), so
that a Windows path like ``X:\PortableApps\AppNamePortable`` will become
``/X:///Portable/Apps///App/Name/Portable``.

Each environment variable listed in this section is currently available in four
forms. For the environment variable listed as ``VARIABLE``, here are the
environment variables which will be available:

* ``%VARIABLE%`` -- directory separator is a backslash (``\``).
* ``%VARIABLE:ForwardSlash%`` -- directory separator is a forward slash (``/``).
* ``%VARIABLE:DoubleBackslash%`` -- directory separator is a double backslash (``\\``).
* ``%VARIABLE:java.util.prefs%`` -- path is in a format for reading with ``java.util.prefs`` (see above).

So, for the environment variable :env:`PAL:AppDir` with the value
``X:\PortableApps\AppNamePortable\App``, the following environment variables
will be available:

* ``%VARIABLE%`` -- ``X:\PortableApps\AppNamePortable\App``
* ``%VARIABLE:ForwardSlash%`` -- ``X:/PortableApps/AppNamePortable/App``
* ``%VARIABLE:DoubleBackslash%`` -- ``X:\\PortableApps\\AppNamePortable\\App``
* ``%VARIABLE:java.util.prefs%`` -- ``/X:///Portable/Apps///App/Name/Portable///App``

Now on to the environment variables themselves.

.. env:: PAL:AppDir

PAL:AppDir
----------

:env:`PAL:AppDir` is set to the App directory which contains the
application.

When Live mode is not enabled, this will be
``X:\PortableApps\AppNamePortable\App`` and when Live mode is enabled it will
be ``%TEMP%\AppNamePortableLive\App`` unless :ini-key:`[LiveMode]:CopyApp` is
set to ``false``.
