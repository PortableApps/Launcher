.. _topics-install:

========================================
Installing the PortableApps.com Launcher
========================================

This document will get you up and running with the PortableApps.com Launcher.

.. _topics-install-download:

Download the PortableApps.com Launcher
======================================

If you only want to use the PortableApps.com Launcher, just download and
install the pre-compiled package from http://portableapps.com/development and
it will be ready.

If, however, you want to develop features or :ref:`debug <topics-debug>` the
PortableApps.com Launcher, you may wish to :ref:`compile the PortableApps.com
Launcher yourself <compile-pal>`.

.. _topics-install-download-source:

The PortableApps.com Launcher source repository
===============================================

Development of the PortableApps.com Launcher takes place in a Mercurial_
repository at SourceForge_. The URL is
http://portableapps.hg.sourceforge.net/hgweb/portableapps/launcher/. To check
out ("clone") a copy of the repository, you will need Mercurial_ or
TortoiseHg_.

To clone the repository with Mercurial,

.. code-block:: bash

   hg clone http://portableapps.hg.sourceforge.net/hgweb/portableapps/launcher
   cd launcher

(To use a different directory name, put the directory name at the end of the
``hg clone`` line after a space.)

To clone the repository with TortoiseHg, create a directory, right click on it
in Explorer and find the TortoiseHg "Clone" option. Specify the path to clone
as ``http://portableapps.hg.sourceforge.net/hgweb/portableapps/launcher/``.

.. _compile-pal:

Compiling the PortableApps.com Launcher
=======================================

The PortableApps.com Launcher is written in :term:`NSIS` and so you will need
NSIS to compile it. While you can use the standard build of NSIS, we recommend
that you use `NSIS Portable`_, as it comes bundled with all the plug-ins
needed.

1. Download and install `NSIS Portable`_

2. Get the PortableApps.com Launcher source by :ref:`downloading
   <topics-install-download>` the pre-compiled package or through the
   :ref:`source repository <topics-install-download-source>`

3. Run NSIS Portable and compile ``Other\Source\PortableApps.comLauncher.nsi``
   from the PortableApps.com Launcher source.

4. Your newly compiled PortableApps.com Launcher will be
   ``PortableApps.comLauncher.exe``.


.. _NSIS Portable: http://portableapps.com/development/nsis_portable
.. _Mercurial: http://mercurial.selenic.com
.. _SourceForge: http://sourceforge.net
.. _TortoiseHg: http://tortoisehg.bitbucket.org
