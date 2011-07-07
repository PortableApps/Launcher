.. ini-section:: [PersistentData]

[PersistentData]
================

**Format:** arbitrary pairs

|envsub|

----

This section can be used to keep values between launches. The key names are
environment variables, and the values are the values which are assigned to them.

There are no fixed values which must go in here; all data is in arbitrary INI
pairs.

All values are saved and restored in the order they are come across, and the
restoration is done before the :ini-section:`[Environment]` section is parsed,
thus you can, in a way, store a variable if you want to, for use in later
``[PersistentData]`` pairs or in another section such as
:ini-section:`[FileWriteN]`. Also, the values are saved after
:ini-section:`[Environment]` is parsed , so you can change the saved data in
there:

.. code-block:: ini

   [Environment]
   HOME=%PAL:DataDir%

   [PersistentData]
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
