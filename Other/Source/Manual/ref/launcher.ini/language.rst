.. ini-section:: [Language]

[Language]
==========

Many applications need quite complex language handling with unique names for
languages, files which need checking, other validation and similar things. These
two sections are designed to aid you to do this. They take input from the
developer and manipulate values in the way specified to produce the environment
variable :env:`%PAL:LanguageCustom% <PAL:LanguageCustom>` in the end which can
be used in any values in the rest of the file marked "|envsub|".

Details on how this is constructed are available in the document
:ref:`languages-custom`.

.. ini-key:: [Language]:Base

Base
----

| Mandatory if section used.
| |envsub|

----

The base string upon which languages are based. This should contain (and
probably be) one of the :ref:`language environment variables
<ref-envsub-language>`.

.. ini-key:: [Language]:Default

Default
-------

| Optional.
| |envsub|

If the base value is not found in the :ini-section:`[LanguageStrings]` section,
it will be set to this value. If this value is not set it will fall back to the
base value.

.. ini-key:: [Language]:CheckIfExists

CheckIfExists
-------------

| Optional.
| |envsub|

----

Check if this file exists. To check for a directory add ``\*.*`` to the end. If
the file does not exist it will fall back to the :ini-key:`DefaultIfNotExists
<[Language]:DefaultIfNotExists>` value.

.. ini-key:: [Language]:DefaultIfNotExists

DefaultIfNotExists
------------------

| Optional.
| |envsub|

----

If the file in :ini-key:`CheckIfExists <[Language]:CheckIfExists>` did not
exist, the custom language variable will be set to this value.

.. ini-key:: [Language]:Save

Save
----

| Values: ``yes`` / ``no``
| Default: ``no``
| Optional.

.. versionadded:: 3.0

----

Save the custom language variable and restore it on startup. Setting this to
``yes`` is equivalent to the following code (for an appropriate value of
``AppNamePortable``):

.. code-block:: ini

    [LanguageFile]
    Type=INI
    File=%PAL:DataDir%\settings\AppNamePortableSettings.ini
    Section=AppNamePortableSettings
    Key=Language

    [FileWriteN]
    Type=INI
    File=%PAL:DataDir%\settings\AppNamePortableSettings.ini
    Section=AppNamePortableSettings
    Key=Language
    Value=%PAL:LanguageCustom%

If this option is enabled, the :ini-section:`[LanguageFile]` section, if
present, will be ignored. It should be used when an environment variable (like
``LANG``) is used to store the language.

.. ini-section:: [LanguageStrings]

[LanguageStrings]
=================

| Format: arbitrary INI pairs.
| |envsub|

----

Values in the :ini-key:`[Language]:Base` will be looked up here by key name and
the values returned after environment variable parsing.

.. ini-section:: [LanguageFile]

[LanguageFile]
==============

For reading the custom language variable from a file for when the portable
application is not launched from the PortableApps.com Platform. The values
which must be set depend on the :ini-key:`Type <[LanguageFile]:Type>`
specified below.

.. ini-key:: [LanguageFile]:Type

Type
----

| Values: ``ConfigRead``, ``INI``, ``XML attribute``, ``XML text``
| Mandatory.

----

Specify the type of file reading which is to be used:

* ``ConfigRead``: read arbitrary data to a file, the line on which to read
  being selected as one starting with the :ini-key:`Entry <[LanguageFile]:Entry>`.

* ``INI``: read a string from an INI file.

* ``XML attribute``: read the string from an attribute value in an XML file.

* ``XML text``: read the string from a text node in an XML file.

Both ``ConfigRead`` and ``INI`` are Unicode-compatible. The encoding (ANSI,
UTF-8 or UTF-16LE) will be detected automatically from the file's BOM.

.. versionchanged:: 2.1
   previously ``ConfigRead`` was not able to read from UTF-16LE files.

.. ini-key:: [LanguageFile]:File

File
----

| Mandatory.
| |envsub|

----

Specify the file which will the value will be read from.

.. ini-key:: [LanguageFile]:Entry

Entry
-----

| Mandatory for :ini-key:`Type <[LanguageFile]:Type>`\ =\ ``ConfigRead``.
| |envsub|

----

The value will be written to a line starting with this value. This should be
set to the text to search for at the start of a line. In an INI-style file,
this would be ``key=``, and in an XML file it might be ``'     <config
id="something">'``; note that you **must** include any leading whitespace
which will be in the file, and if there is any leading or trailing whitespace
you must quote the string with single (``'``) or double (``"``) quotes.

If you need to cut something off the start or end such as a quotation mark or a
closing XML tag, see :ini-key:`[LanguageFile]:TrimRight` and
:ini-key:`[LanguageFile]:TrimLeft`.

.. versionchanged:: 3.0
   added support for :ref:`ref-envsub`

.. ini-key:: [LanguageFile]:Section

Section
-------

| Mandatory for :ini-key:`Type <[LanguageFile]:Type>`\ =\ ``INI``.
| |envsub|

----

The INI section to read the value from.

.. versionchanged:: 3.0
   added support for :ref:`ref-envsub`

.. ini-key:: [LanguageFile]:Key

Key
---

| Mandatory for :ini-key:`Type <[LanguageFile]:Type>`\ =\ ``INI``.
| |envsub|

----

The INI key to read the value from.

.. versionchanged:: 3.0
   added support for :ref:`ref-envsub`

.. ini-key:: [LanguageFile]:Attribute

Attribute
---------

| Mandatory for :ini-key:`Type <[LanguageFile]:Type>`\ =\ ``XML attribute``
| |envsub|

----

The attribute to read the value from. See :ref:`xml` for more details.

.. ini-key:: [LanguageFile]:XPath

XPath
-----

| Mandatory for :ini-key:`Type <[LanguageFile]:Type>`\ =\ ``XML attribute``, ``XML text``.
| |envsub|

----

Specify the XPath_ to find the place to read from. It is a good idea to make
sure that you have a solid understanding of how XPaths work and how to use them
before writing one.

For information about what this should look like, see :ref:`xml`.

.. _XPath: http://en.wikipedia.org/wiki/XPath

.. versionchanged:: 3.0
   added support for :ref:`ref-envsub`

.. ini-key:: [LanguageFile]:CaseSensitive

CaseSensitive
-------------

| Values: ``true`` / ``false``
| Default: ``false``
| Applies for :ini-key:`Type <[LanguageFile]:Type>`\ =\ ``ConfigRead``.
| Optional.

----

Case sensitive searches are somewhat faster than case-insensitive searches. If
you can do a case-sensitive ConfigRead, do.

.. ini-key:: [LanguageFile]:TrimLeft

TrimLeft
--------

| Optional.
| |envsub|

.. versionadded:: 3.0

----

If you need to remove something from the left of a line which you have read,
for example if you want to get rid of an extra quotation mark or a directory
name or something like that, put the text in here and if it is at the start of
the string it will be removed. Remember the rule about whitespace and quotation
marks.

.. ini-key:: [LanguageFile]:TrimRight

TrimRight
---------

| Optional.
| |envsub|

----

If you need to remove something from the right of a line which you have read,
for example if you want to get rid of a file extension, a quotation mark, a
closing XML tag or similar, put the text in here and if it is at the end of
the string it will be removed. Remember the rule about whitespace and
quotation marks.

.. versionchanged:: 3.0
   added support for :ref:`ref-envsub`

.. ini-key:: [LanguageFile]:SaveAs

SaveAs
------

| Optional.
| |envsub|

.. versionadded:: 3.0

----

Write the language back, using the specified format. Setting this is equivalent
to a :ini-section:`[FileWriteN]` with the same fields, using the value of this
option as the value to be written. The rules for :ini-key:`[FileWriteN]:Value`
apply.
