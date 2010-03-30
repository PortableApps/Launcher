.. _advanced-debug:

Debugging the PortableApps.com Launcher
=======================================

To debug the PortableApps.com Launcher, you will need to be able to compile the
PortableApps.com Launcher. See :ref:`compile-pal` for details on that process.

Once you have a compile environment set up for the PortableApps.com Launcher,
you can recompile it with debugging flags turned on. To do this, create a file
``PortableApps.comLauncherDebug.nsh`` in the ``Other\Source`` directory of the
package you are dealing with. This file should contain :ref:`debug flags
<advanced-debug-flags>` as listed below, like this:

::

   !define DEBUG_ALL

When you compile the Launcher with the Generator, it will find this file and
turn on debugging.

Remember to remove the debug file when doing release builds, or else people will
end up with a build with debugging enabled, which is unlikely to be what you
wanted. 

.. _advanced-debug-flags:

Debug flags
-----------

Here is a list of the debug flags available. See above for how to enable them.

``DEBUG_ALL``
   Debug (almost) everything. For the sake of verbosity, the "About to execute
   segment" and "Finished executing segment" debug messages are not shown unless
   ``DEBUG_SEGWRAP`` is turned on.
   
   This is equivalent to ``DEBUG_GLOBAL`` and all
   ``DEBUG_SEGMENT_[segment name]`` flags being turned on.

``DEBUG_SEGWRAP``
   Show debug messages to announce when a :ref:`segment <advanced-segments>` is
   about to be executed and when it has finished.

To debug only certain :ref:`segments <advanced-segments>`, there are more flags:

``DEBUG_GLOBAL``
   Debug outside all segments.

``DEBUG_SEGMENT_[segment name]``
   Debug the segment given by ``[segment name]``, e.g.
   ``DEBUG_SEGMENT_RunAsAdmin`` to debug the RunAsAdmin segment.
