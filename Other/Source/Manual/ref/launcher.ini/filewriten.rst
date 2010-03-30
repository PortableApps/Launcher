.. ini-section:: [FileWriteN]

[FileWrite\ *N*]
================

For writing data to files. The values which must be set depend on the :ini-key:`Type <[FileWriteN]:Type>` specified below.

.. ini-key:: [FileWriteN]:Type

Type
----

| Values: ``ConfigWrite``, ``INI``, ``Replace``
| Mandatory.

----

Specify the type of file writing which is to be used:

* ``ConfigWrite``: write arbitrary data to a file, the line on which to write
  being selected as one starting with the :ini-key:`Entry <[FileWriteN]:Entry>`.

* ``INI``: write a string to an INI file.

* ``Replace``: search for a string and replace it with another string in a file.
  This is particularly useful for updating drive letters and configuration paths
  (using :env:`%PAL:Drive% <PAL:Drive>` and :env:`%PAL:LastDrive%
  <PAL:LastDrive>`)

.. ini-key:: [FileWriteN]:File

File
----

| Mandatory.
| |envsub|

----

Specify the file in which the modification will be made.

.. ini-key:: [FileWriteN]:Entry

Entry
-----

| Mandatory for :ini-key:`Type <[FileWriteN]:Type>`\ =\ ``ConfigWrite``.

----

The :ini-key:`Value <[FileWriteN]:Value>` will be written to a line starting
with this value, or if it is not found, at the end of the file. This should be
set to the text to search for at the start of a line. In an INI-style file, this
would be ``key=``, and in an XML file it might be ``'     <config
id="something">'``; note that you **must** include any leading
whitespace which will be in the file, and if there is any leading or trailing
whitespace you must quote the string with single (``'``) or double (``"``)
quotes.

.. ini-key:: [FileWriteN]:Section

Section
-------

| Mandatory for :ini-key:`Type <[FileWriteN]:Type>`\ =\ ``ConfigWrite``.

----

The INI section to write the value to.

.. ini-key:: [FileWriteN]:Key

Key
---

| Mandatory for :ini-key:`Type <[FileWriteN]:Type>`\ =\ ``ConfigWrite``.

----

The INI key to write the value to.

.. ini-key:: [FileWriteN]:Value

Value
-----

| Mandatory for :ini-key:`Type <[FileWriteN]:Type>`\ =\ ``ConfigWrite``, ``INI``.
| |envsub|

----

The value which will be written to the file. If dealing with :ini-key:`Type <[FileWriteN]:Type>`\ =` ``ConfigWrite``, you should remember with things like XML files that you will normally need to close the tag, for example ``%PAL:DataDir%\settings</config>``.

.. ini-key:: [FileWriteN]:Find

Find
----

| Mandatory for :ini-key:`Type <[FileWriteN]:Type>`\ =\ ``ConfigWrite``.
| |envsub|

----

The string to search for.

.. ini-key:: [FileWriteN]:Replace

Replace
-------

| Mandatory for :ini-key:`Type <[FileWriteN]:Type>`\ =\ ``Replace``.
| |envsub|

----

The string to replace the search string with. If, after environment variable
replacement, this is the same as the :ini-key:`Find <[FileWriteN]:Find>` string,
the replacement will be skipped (e.g. if you use it to update drive letters and
it's on the same letter).

.. ini-key:: [FileWriteN]:CaseSensitive

CaseSensitive
-------------

| Values: ``true`` / ``false``
| Default: ``false``
| Applies for :ini-key:`Type <[FileWriteN]:Type>`\ =\ ``ConfigWrite``, ``Replace``.
| Optional.

----

Case sensitive searches are somewhat faster than case-insensitive searches. If
you can do a case-sensitive ConfigWrite or find and replace, do.

Concerning drive letter updates, you can't guarrantee what case the drive letter
will be and so it will not normally be practical to do a case sensitive
replacement for drive letters.

.. ini-key:: [FileWriteN]:Encoding

Encoding
--------

| Values: ``ANSI`` / ``UTF16-LE``
| Default: ``ANSI``
| Applies to :ini-key:`Type <[FileWriteN]:Type>`\ =\ ``Replace``.
| Optional.

----

If you need to find and replace in a Unicode (UTF16-LE) file, set the encoding
here as UTF-16LE; otherwise don't include this value.
