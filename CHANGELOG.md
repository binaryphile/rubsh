Change Log
==========

The format is based on [Keep a Changelog] and this project adheres to
[Semantic Versioning], with the exception that v10 is version 0 in
semver parlance.

[Unreleased]
------------

### Changed

-   restarted object model from scratch

[v10.10.11] - 2017-04-07
------------------------

### Added

-   Travis CI compatibility

### Refactored

-   cleaned up \_\_dispatch - removed anonymous variable detection, made
    independent of class.

[v10.10.10] - 2017-04-05
------------------------

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

-   String\#upcase and String\#upcase!

-   return types on everything but File\#each

-   basic method chaining

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

-   untested methods/classes

-   globbing

### Documented

-   added changelog

-   revisited readme

  [Keep a Changelog]: http://keepachangelog.com/
  [Semantic Versioning]: http://semver.org/
  [Unreleased]: https://github.com/binaryphile/rubsh/compare/v10.10.11...v11.10
  [v10.10.11]: https://github.com/binaryphile/rubsh/compare/v10.10.10...v10.10.11
  [v10.10.10]: https://github.com/binaryphile/rubsh/compare/v0.6.3...v10.10.10
