## 1.0.0
* Uses Klutter Gradle v2023.1.2.beta.
* Uses klutter_ui 1.0.0.
* Added support for windows development ([ticket](https://github.com/buijs-dev/klutter-dart/issues/3)).

## 0.3.0
* Uses Klutter Gradle v2023.1.1.beta.
* Removed producer install tasks because Klutter Gradle v2023.1.1.beta does the installation during gradle build.
* Remove widgets in order to scope klutter-dart to dev_dependency (widgets are now found in [klutter-dart-ui](https://github.com/buijs-dev/klutter-dart-ui).
* Embedded gradle-wrapper bumped to version 7.2.
* Removed consumer init ios task because no longer required.
* Consumer add uses $root variable in local paths in .klutter-plugins file.
* Add logic to klutter_plugin_loaders.gradle.kts to replace $root variable with local path (backwards compatible).

## 0.2.4
* Documentation update to point-out the Android Studio and Intellij IDE plugins.

## 0.2.3
* Uses Klutter Gradle v2022.r6-9.alpha.

## 0.2.1
* Changed gradle plugin id to dev.buijs.klutter

## 0.2.0
* Uses Klutter Gradle v2022.r6-8.alpha.
* New project template uses Klutter DSL to apply Klutter dependencies.
* Flutter generated files are removed from lib folder after klutter init.
* Moved task klutterInstallPlatform from generated build.gradle.kts to Gradle plugin.
* Renamed task klutterInstallPlatfrom to klutterBuild.
* Moved task klutterCopyAarFile from generated build.gradle.kts to Gradle plugin.
* Moved task klutterIosFramework from generated build.gradle.kts to Gradle plugin.
* Changed platform build.gradle.kts to create an XCFramework instead of fat framework for iOS.
* [Bugfix](https://github.com/buijs-dev/klutter/issues/4) App does not work on Mac M1.

## 0.1.3
* Uses Klutter Gradle v2022.r6-7.alpha.

## 0.1.2
* Uses Klutter Gradle v2022.r6-6.alpha.
* Added adapter library with improved AdapterResponse class.
* As of 0.1.2 Klutter is required as dependency instead of dev_dependency.

## 0.1.1
* Producer Install task no longer depends on Init task.
* Formatting fixes in documentation.

## 0.1.0
* Uses Klutter Gradle v2022.r6.alpha.
* Initial version with iOS and Android support.
* Contains the tasks:
  * klutter:consumer init
  * klutter:consumer init=android
  * klutter:consumer init=android,ios
  * klutter:producer init
  * klutter:producer install=platform
  * klutter:producer install=library