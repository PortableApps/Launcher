.. _advanced-segments:

Segments
========

The PortableApps.com Launcher source code is divided up into lots of "segments",
each of which can run a number of "hooks". This aids with code separation of
different pieces of functionality, by grouping code by what it does rather than
when it executes, providing a synergistically value-adding, mutually-beneficial
strategic partnership between the developer and... and... well, whatever's left.
(A more useful workflow anyway. I'll leave the marketing talk to the marketers.)

.. admonition:: Why did you write that nonsense?

   A few proposals have been put forward about such things as this, but as usual
   analysts have been unable to agree on the issue.
   
   The simple answer is that we software developers have a quirky sense of
   humour.  How else could you explain things like the recursive acronyms that
   all developers so love? At times it can get dull, just writing a program
   which does what it's meant to do and that's all, and so developers make time
   to put in what are commonly known as "easter eggs": hidden functionality
   which they generally find amusing and which break the monotony of writing
   good software.
   
   In particular here the point is writing documentation. Writing this
   documentation for the PortableApps.com Launcher is taking far longer than the
   actual writing of the code did in the first place (orders of magnitude
   longer). And so at times I decide to put strange things in for the fun of it.

   It's just one of those illogicalities of software developers.

.. _advanced-segments-hooks:

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

.. _advanced-segments-custom:

Writing a custom segment
------------------------

If there is something which you need to do in a launcher which is not possible
in the PortableApps.com Launcher, you can write :term:`NSIS` code for it
yourself but still use the general framework and power of the PortableApps.com
Launcher by writing a custom segment.

To write a custom segment for your application, create a file
``PortableApps.comLauncherCustom.nsh`` in the ``Other\Source`` directory of your
application package. You can look at other segments for guidance on how to write
a segment. This is the general structure for a segment:

::

   ${SegmentFile}

   Var [variables]

   ${Segment[hook]}
      ...
   !macroend

   ${Segment[hook]}
      ...
   !macroend

   ...

1. The first line of the file is ``${SegmentFile}``.

2. Next comes any variables which may be required. Normally no variables will be
   required but some segments need variables.

2. After this comes the hooks. Each hook is implemented like this:

   ::

      ${Segment[hook]}
         [segment contents]
      !macroend

   A list of available hooks is available :ref:`above
   <advanced-segments-hooks>`.

3. A segment can use custom macros and Functions if it is desired, but they
   should be clearly identified as part of the segment. The general convention
   is to prefix a segment-specific macro or function with *_segment name_* so
   that the macro "Start" in the segment FilesMove became ``_FilesMove_Start``.
   Such macros and functions as these should come above the variable
   definitions, immediately after the ``${SegmentFile}`` line.

.. _advanced-segments-disable:

Disabling hooks and segments and overriding the execute step
------------------------------------------------------------

If you ever need to disable a segment or hook, you can do so. In general though
if you can possibly avoid doing it you should; you can very easily break the
PortableApps.com Launcher by disabling certain things. In general I would
recommend that you :ref:`ask <ask>` before doing it to see if there is a better
way.

All of these changes apply to :ref:`PortableApps.comLauncherCustom.nsh
<advanced-segments-custom>`.

* Disable inbuilt segment-hooks::

     ${DisableHook} Segment Hook

* Disable all hooks in an inbuilt segment::

     ${DisableSegment} Segment

* To override the Execute function completely, do this::

     ${OverrideExecute}
         ...
     !macroend

  You would be well advised to take a look at the Execute function in
  PortableApps.comLauncher.nsi before doing this.

.. _advanced-segments-list:

List of core segments
---------------------

Here is the current list of segments included in the PortableApps.com Launcher:

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
* Qt
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
