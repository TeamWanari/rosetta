# v0.2.3

## Improvements:
* Update dart sdk to support newly supported platforms

# v0.2.2+1

## Improvements:
* Revert minimum SDK version back to 2.6.0

# v0.2.2

## Improvements:
* Update dependencies to support newer versions of Flutter

# v0.2.1

## Improvements:
* Optimize the generator to generate a stricter code, matching stricter analysis option
* fix: implicit-dynamic warnings in the generated code
* fix: use final instead of vars
* add: more typings where finals replace vars
* fix: avoid using this where the resolve method is called
* change: use static const instead of static final props for the generated Enum class for Keys
* add: typed MapEntry

# v0.2.0

## Improvements:
* Update versions

# v0.1.3

## Improvements:
* Add support for `Rosetta`'s grouping attribute
* Changed analyzer dependency version
* Code quality improvements

# v0.1.2

## Improvements:
* Add generator logic for `Stone.package` attribute to enabled support for multi-package projects

# v0.1.1

## Improvements:
* Add generator logic for `@Intercept` annotations
* Add validation logic for annotations and for their parameters
* Improved generator error messages 

## Fixes:
* `build_runner` watch will now detect correctly the referred JSON file changes

# First release version

* Add generator logic for `@Stone` annotation
