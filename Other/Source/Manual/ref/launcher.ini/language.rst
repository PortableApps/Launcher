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
:ref:`topics-languages-custom`.

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

.. ini-key:: [LanguageFile]:Type

For reading the custom language variable from a file for when the portable
application is not launched from the PortableApps.com Platform. The values
which must be set depend on the :ini-key:`Type <[LanguageFile]:Type>`
specified below.

.. ini-key:: [LanguageFile]:Type

Type
----

| Values: ``ConfigRead``, ``INI``
| Mandatory.

----

Specify the type of file reading which is to be used:

* ``ConfigRead``: read arbitrary data to a file, the line on which to read
  being selected as one starting with the :ini-key:`Entry <[LanguageFile]:Entry>`.

* ``INI``: read a string from an INI file.

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

----

The value will be written to a line starting with this value. This should be
set to the text to search for at the start of a line. In an INI-style file,
this would be ``key=``, and in an XML file it might be ``'     <config
id="something">'``; note that you **must** include any leading whitespace
which will be in the file, and if there is any leading or trailing whitespace
you must quote the string with single (``'``) or double (``"``) quotes.

Currently there is a shortcoming in this in that you cannot remove text from
the end of the value. This will be ammended shortly.

.. ini-key:: [LanguageFile]:Section

Section
-------

| Mandatory for :ini-key:`Type <[LanguageFile]:Type>`\ =\ ``INI``.

----

The INI section to read the value from.

.. ini-key:: [LanguageFile]:Key

Key
---

| Mandatory for :ini-key:`Type <[LanguageFile]:Type>`\ =\ ``INI``.

----

The INI key to read the value from.

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
