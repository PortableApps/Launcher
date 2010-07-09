.. ini-section:: [RegisterDLL]

[RegisterDLL]
=============

|inikeyint|

|envsub|

----

Some apps register DLLs on the host system. Put in the paths to any such DLLs
here.  Normally the value will start with :env:`%PAL:AppDir%`.

When a DLL server is registered, a key in ``HKLM\Software\Classes\CLSID`` is
created, with a name in the style ``XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX``,
where ``X`` is an upper case hexadecimal digit (0-9 or A-F). In this are
sub-keys like ``Control``, ``Implemented Categories``, ``InprocServer32``,
``ProgID``, ``Programmable``, ``TypeLib``, ``Version`` and
``VersionIndependentProgID``.

If a key like this is added, the file name of the registered DLL is stored in
the default value of the ``InprocServer32`` key.

Other keys may also be created by registering a DLL, in
``HKLM\Software\Classes``. These will tend to share name similarities with the
DLL, but may not. Thus, after inserting a line in this section, you are
recommended to try running the program again to see if any other keys in there
become no longer an issue due to unregistering.

To identify if the DllRegisterServer/DllUnregisterServer call is needed, observe the
key with a utility like Regshot (see :ref:`topics-registry-detecting-changes`).

**Example:** ``1=%PAL:AppDir%\AppName\foo.dll``
