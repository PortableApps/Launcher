.. _topics-languages:

Languages
=========

The PortableApps.com Launcher supports automatic language switching of
applications when launched from the PortableApps.com Platform, by a series of
environment variables. This document discusses how to go about getting language
setting working for your application, and some quirks of the system.

The environment variables
-------------------------

:ref:`ref-envsub-language` covers the default variables which are available. If
those environment variables are enough for use in a :ini-section:`[FileWriteN]`
section, then you shouldn't need to go beyond here.

.. _topics-languages-custom:

Setting a custom language environment variable
----------------------------------------------

Constructing a custom language environment variable is done with the
:ini-section:`[Language]` and :ini-section:`[LanguageStrings]` sections, and
the final result is placed in :env:`%PAL:LanguageCustom% <PAL:LanguageCustom>`.
Here is the order in which things happen.

1. :ini-key:`[Language]:Base` is read and environment variables are parsed
   (this will normally be other :ref:`language variables
   <ref-envsub-language>`).

2. The key defined by that value is looked up in the section
   :ini-section:`[LanguageStrings]` (into a variable we'll call ``value``).
   
3. If that key did not exist (and so ``value`` is undefined), then
   :ini-key:`[Language]:Default` is read (with environment variable parsing)
   into ``value`` if it exists; if it doesn't exist then
   :ini-key:`[Language]:Base` (with environment variables parsed; the value we
   looked up in :ini-section:`[LanguageStrings]` before) is used.

4. ``%PAL:LanguageCustom%`` is set to ``value``.

5. Now we come to checking if a file exists. This is handy when you have a
   whole table of, for example, glibc-compliant names, but not all possible
   files are there and if an invalid language is specified the application will
   cause problems. It becomes convenient to check if a certain file exists, and
   if it doesn't, reverting to a default value.

6. If :ini-key:`[Language]:CheckIfExists` is not set, the final value is
   ``value`` (and this process stops).  Otherwise, it is read and environment
   variables are parsed.

7. That file is checked for existence: for example, you could have a value of
   ``%PAL:AppDir%\AppName\locales\%PAL:LanguageCustom%.mo``. You should have
   ``%PAL:LanguageCustom%`` at least once in this value (otherwise there
   wouldn't seem much point in it).

8. If this file does not exist, then :ini-key:`[Language]:DefaultIfNotExists`
   is read, environment variables parsed in it, and set as the value for
   ``%PAL:LanguageCustom%``.

**Note:** normally you will want to use only one of
:ini-key:`[Language]:Default` and :ini-key:`[Language]:DefaultIfNotExists`.

Here is a diagram of how it works:

.. image:: languages-custom.png

When the portable application is not launched from the PortableApps.com
Platform, to maintain the user's language setting, the custom language should
be read from a file with the aid of the :ini-section:`[LanguageFile]` section,
if this is possible.

Other ways
----------

If you really can't make language switching work as you need it to, you can
:ref:`write a custom segment <advanced-segments-custom>` to do what you need.
Remember then that you will need to compile this new code with the
PortableApps.com Launcher Generator (see :ref:`compile-pal` for details)
