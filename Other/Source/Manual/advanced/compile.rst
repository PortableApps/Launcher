.. _advanced-compile:

========================================
Compiling the PortableApps.com Launcher
========================================

If you want to test features of the PortableApps.com Launcher, you'll need to
compile it. Here's how.

.. _hg:

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

1. Download and install `Unicode NSIS Portable`_ (`NSIS Portable`_ is also
   currently supported, but not recommended).

2. Get the PortableApps.com Launcher source by :ref:`downloading
   <topics-install-download>` the pre-compiled package or through the
   :ref:`source repository <hg>`

3. Run Unicode NSIS Portable and compile ``Other\Source\GeneratorWizard.nsi``
   from the PortableApps.com Launcher source.

4. Upon success, the PortableApps.com Launcher Generator will be at
   ``PortableApps.comLauncherGenerator.exe``.

5. Run the PortableApps.com Launcher Generator and select the portable app
   directory which you wish to use the PortableApps.com Launcher in.

6. If the PortableApps.com Launcher Generator says that it can't find NSIS, edit
   ``Data\settings.ini`` to specify the path to makensis.exe.


.. _Unicode NSIS Portable: http://portableapps.com/node/21879
.. _NSIS Portable: http://portableapps.com/apps/development/nsis_portable
.. _Mercurial: http://mercurial.selenic.com
.. _SourceForge: http://sourceforge.net
.. _TortoiseHg: http://tortoisehg.bitbucket.org
