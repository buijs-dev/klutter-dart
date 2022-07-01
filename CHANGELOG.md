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