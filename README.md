[![GitHub license](https://img.shields.io/github/license/buijs-dev/klutter-dart?style=for-the-badge)](https://github.com/buijs-dev/klutter-dart/blob/main/LICENSE)
[![Codecov](https://img.shields.io/codecov/c/github/buijs-dev/klutter-dart?style=for-the-badge)](https://app.codecov.io/gh/buijs-dev/klutter-dart)

The Klutter Framework makes it possible to write a Flutter plugin for both Android and iOS using [Kotlin Multiplatform](https://kotlinlang.org/docs/multiplatform.html).
Instead of writing platform specific code twice in 2 languages (Swift + Kotlin), it can be written
once in Kotlin and used as a Flutter plugin.

<B>Important</B>: Klutter is in alpha.

## Getting started
Add klutter to your pubspec.yaml:

```yaml
dev_dependencies:
  klutter: ^0.1.0
```

Run:

``` shell
flutter pub get
```

## Usage
- [Use plugins](#Use%20plugins)
- [Create plugins](#Create%20plugins)


#### Use plugins

Run:
``` shell
flutter pub klutter:android
```

This task will do 3 things for your Flutter project:
- Create a .klutter-plugins file in the root folder.
- Create a new Gradle file in the flutter/packages/flutter_tools/gradle.
- Update the android/settings.gradle file to apply the newly generated Gradle file.

The .klutter-plugins file will register all Klutter made plugins used in your project.
The created Gradle file in the flutter_tools manages the plugins and enables them to
be found by the Flutter project.

#### Create plugins
TODO not yet implemented