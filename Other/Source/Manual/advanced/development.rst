.. _development-builds:

================================================================
Working with development builds of the PortableApps.com Launcher
================================================================

If you want to test features of the PortableApps.com Launcher, or get
development builds in between releases, you'll need to get it and compile the
Generator. Here's how.

.. _src:

The PortableApps.com Launcher source repository
===============================================

Development of the PortableApps.com Launcher takes place in a Git_ repository
at GitHub_. The URL is https://github.com/PortableApps/Launcher.git. To check
out ("clone") a copy of the repository, you will need Git_ or TortoiseGit_.

To clone the repository with Git,

.. code-block:: bash

   git clone https://github.com/PortableApps/Launcher.git
   cd Launcher

(To use a different directory name, put the directory name at the end of the
``git clone`` line after a space.)

To clone the repository with TortoiseGit, create a directory, right click on it
in Explorer and find the TortoiseGit "Clone..." option. Specify the path to
clone as ``https://github.com/PortableApps/Launcher.git``.

You can also get a copy of the latest version in this repository without
Git in the zip_ or gzip_ formats.

.. _Git: http://git-scm.com
.. _GitHub: http://github.com
.. _TortoiseGit: http://tortoisegit.org
.. _zip: http://github.com/PortableApps/Launcher/archive/master.zip
.. _gzip: http://github.com/PortableApps/Launcher/archive/master.tar.gz

.. _compile-pal-generator:

Compiling the PortableApps.com Launcher Generator
=================================================

The PortableApps.com Launcher Generator is written in :term:`NSIS` and so you
will need NSIS Portable to compile it (it has the necessary plug-ins included).

1. :ref:`Install the PortableApps.com Launcher <install-launcher>`. Instead of
   installing the PortableApps.com Launcher package, you can get a copy of the
   :ref:`source repository <src>`.

2. Run NSIS Portable and compile ``Other\Source\GeneratorWizard.nsi``
   from the PortableApps.com Launcher source.

3. Upon success, the PortableApps.com Launcher Generator will be at
   ``PortableApps.comLauncherGenerator.exe``.

After that you can run the PortableApps.com Launcher Generator as normal.  If
the PortableApps.com Launcher Generator says that it can't find NSIS, edit
``Data\settings.ini`` to specify the path to makensis.exe.
