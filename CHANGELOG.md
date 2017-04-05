Change Log
==========

The format is based on [Keep a Changelog] and this project adheres to
[Semantic Versioning].

[Unreleased]
------------

### Changed

-   allow reassignment of an existing object variable

-   String\#set changed to String\#=, allow bare =

-   renamed \_\_to\_str to \_\_inspect

-   made String the default super

-   eliminated all existing work and started from scratch

-   made methods start with .

-   default method changed from \#to\_s to \#inspect

-   puts calls to\_s on an object

### Added

-   basic parameters with braces

-   Hash\#inspect method

-   Array\#inspect method

-   Object\#inspect method

-   resolution of method as value argument with Class\#new

-   Class\#new assignment syntax with =

-   Class\#declare declarations, with =^ syntax as well

-   basic Array, Hash, String, Path and File classes

-   class function declares Classes

-   def function creates instance methods on Classes

-   tests

### Removed

-   globbing

### Documented

-   added changelog

-   revisited readme

### Todo

-   \#method\_missing

-   method chaining

  [Keep a Changelog]: http://keepachangelog.com/
  [Semantic Versioning]: http://semver.org/
  [Unreleased]: https://github.com/binaryphile/rubsh/compare/v0.6.3...v10.10
