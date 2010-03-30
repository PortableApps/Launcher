.. ini-section:: [Language]

[Language]
==========

Many applications need quite complex language handling with unique names for
languages, files which need checking, other validation and similar things. These
two sections are designed to aid you to do this. They take input from the
developer and manipulate values in the way specified to produce the environment
variable :env:`%PAL:LanguageCustom% <PAL:LanguageCustom>` in the end which can
be used in any values in the rest of the file marked "|envsub|".

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
