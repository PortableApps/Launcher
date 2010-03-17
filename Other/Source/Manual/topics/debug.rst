.. _topics-debug:

Debugging the PortableApps.com Launcher
=======================================

To debug the PortableApps.com Launcher, you will need to be able to compile the
PortableApps.com Launcher. See :ref:`compile-pal` for details on that process.

Once you have a compile environment set up for the PortableApps.com Launcher,
you can recompile it with debugging flags turned on. There are two ways to turn
on debugging.

1. Command line arguments to ``makensis``: each flag to be turned on will get
   ``-D`` put just before it, like this:

   .. code-block:: bash

      makensis -DDEBUG_ALL PortableApps.comLauncher.nsi

2. Create a file ``PortableApps.comLauncherDebug.nsh`` next to
   ``PortableApps.comLauncher.nsi`` and put lines like this in it:

   .. TODO - create an "nsis" lexer for Pygments

   ::

      !define DEBUG_ALL

   When using this method, remember to clear the file out when doing release
   builds, or else people will end up with a build with debugging enabled, which
   is unlikely to be what you wanted. 

Debug flags
-----------

Here is a list of the debug flags available. See above for how to enable them.

``DEBUG_ALL``
   Debug (almost) everything. For the sake of verbosity, the "About to execute
   segment" and "Finished executing segment" debug messages are not shown unless
   ``DEBUG_SEGWRAP`` is turned on.  This is equivalent to ``DEBUG_GLOBAL`` and
   ``DEBUG_SEGMENT_*``.

``DEBUG_SEGWRAP``
   Show debug messages to announce when a :ref:`segment <topics-segments>` is about to
   be executed and when it has finished.

To debug only certain :ref:`segments <topics-segments>`, there are more flags:

``DEBUG_GLOBAL``
   Debug outside all segments.

``DEBUG_SEGMENT_[segment name]``
   Debug the segment given by ``[segment name]``, e.g.
   ``DEBUG_SEGMENT_RunAsAdmin`` to debug the RunAsAdmin segment.
