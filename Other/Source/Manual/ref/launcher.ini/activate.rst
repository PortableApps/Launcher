.. ini-section:: [Activate]

[Activate]
==========

This section is for telling the launcher whether or not it should load certain
things, for example Java and registry support.

.. ini-key:: [Activate]:Registry

Registry
--------

| Values: ``true`` or ``false``
| Default: ``false``
| Optional.

----

If the base application uses the registry, set this to true. **You MUST set this
to true if you wish the registry sections to be parsed.** Otherwise they will
not be read at all.

.. ini-key:: [Activate]:Java

Java
----

| Values: none, ``find`` or ``require``
| Default: none
| Optional.

----

If the application can use Java but does not depend on its being available, set
this to ``find``, and a Java Runtime Environment (JRE) will be found if
available, and the environment variable :env:`%JAVA_HOME% <JAVA_HOME>` will
become available for use.

If the application is completely dependant on Java, set this to ``require``.
Then you may set :ini-key:`[Launch]:ProgramExecutable` to ``javaw.exe`` (normal
use) or ``java.exe`` (command line version which may be useful for testing and
debugging) and it will use Java.

**Caveat:** With ``require``, if you can possibly help it, set
:ini-key:`[Launch]:WaitForProgram` or :ini-key:`[Launch]:WaitForOtherInstances`
to false if you use java.exe or javaw.exe. Otherwise you'll run into problems
cleaning up if other Java applications get run, as it'll look for instances of
the application, and find javaw.exe, even though it's another application's
javaw.exe instance.

See :ref:`topics-java` for more discussion about Java apps.
