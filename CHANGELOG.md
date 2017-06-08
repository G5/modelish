# CHANGELOG

## 0.4.0 (2017-06-08)

* Relax dependency on hashie
* Ensure compatibility with ruby 2.x

## 0.3.0 (2013-7-8)

* Upgrade hashie dependency to v2.0.x

## 0.2.4 (2012-8-23)

* Make modelish compatible with hashie v1.x, instead of pinning to hashie v1.0.0.

## 0.2.3 (2012-8-17)

* Tweak implementation of validate! method to call validate method, replacing a parallel
  implementation that called individual property validators.

## 0.2.2 (2012-3-8)

* Minor bug fix in Modelish::Base#initialize to prevent modification of argument hash

## 0.2.1 (2012-3-8)

* Bug fix to make behavior predictable for translated properties when both the property
  name and the translated property name are present in an initiali23zation hash (issue #5).
* Modelish::Base#to_hash now processes the contents of Array-typed properties.

## 0.2.0 (2012-1-16)

* Added support for mapping the same input property name to multiple outputs. This means that
  Modelish::Base#translations is now a Hash instead of an Array.
* Bug fix for Modelish::Base#to_hash to return typed property values

## 0.1.3 (2011-10-25)

* Added configuration option to ignore unknown properties. The default behavior continues
  to be raising an error when an unknown property name is encountered in an initialization
  hash.

## 0.1.2 (2011-03-31)

* Fixed SystemStackError when a typed property with the same name is defined multiple times.
* Use explicit path when loading modelish classes.

## 0.1.1 (2011-03-28)

* Add DateTime to standard supported property types.

## 0.1.0 (2011-03-28)

* Initial release, extending hashie to add property types and validations.
