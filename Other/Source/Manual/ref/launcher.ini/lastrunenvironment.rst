.. ini-section:: [LastRunEnvironment]

[LastRunEnvironment]
====================

**Format:** arbitrary pairs

|envsub|

.. versionadded:: 3.0

----

This section can be used to keep values between launches. The key names are
environment variables, and the values are the values which are assigned to them.

There are no fixed values which must go in here; all data is in arbitrary INI
pairs.

All values are saved and restored in the order they are come across, and the
restoration is done before the :ini-section:`[Environment]` section is parsed,
thus you can, in a way, store a variable if you want to, for use in later
``[LastRunEnvironment]`` pairs or in another section such as
:ini-section:`[FileWriteN]`. Also, the values are saved after
:ini-section:`[Environment]` is parsed , so you can change the saved data in
there:

.. code-block:: ini

   [Environment]
   HOME=%PAL:DataDir%

   [LastRunEnvironment]
   OldHome=%HOME%

   [FileWrite1]
   Type=Replace
   File=%PAL:DataDir%\AppName.ini
   Find=%OldHome%
   Replace=%HOME%

Here, if there are any previously saved values of ``OldHome``, they will be
restored. Then, the ``HOME`` environment variable is set with the value of the
:env:`PAL:DataDir` environment variable. The ``[FileWrite1]`` section is
executed using the saved value of ``OldHome`` and only then ``OldHome`` is saved
with the current value of ``HOME``.

If a key name has a ``~`` appended to it, it will be processed as a
:ref:`directory variable <ref-envsub-directory>`, therefore getting the same
additional variables:

.. code-block:: ini

   [Environment]
   Home~=%PAL:DataDir%\AppHome

This code will make available the following environment variables:

* ``%Home%`` -- ``X:\PortableApps\AppNamePortable\Data\AppHome``
* ``%Home:ForwardSlash%`` -- ``X:/PortableApps/AppNamePortable/Data/AppHome``
* ``%Home:DoubleBackslash%`` -- ``X:\\PortableApps\\AppNamePortable\\Data\\AppHome``
* ``%Home:java.util.prefs%`` -- ``/X:///Portable/Apps///App/Name/Portable///Data///AppHome``
