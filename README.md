[![](https://img.shields.io/badge/Buijs-Software-blue)](https://pub.dev/publishers/buijs.dev/packages)
[![GitHub license](https://img.shields.io/github/license/buijs-dev/klutter-dart?color=black&logoColor=black)](https://github.com/buijs-dev/klutter-dart/blob/main/LICENSE)
[![pub](https://img.shields.io/pub/v/klutter)](https://pub.dev/packages/klutter)
[![codecov](https://img.shields.io/codecov/c/github/buijs-dev/klutter-dart?logo=codecov)](https://codecov.io/gh/buijs-dev/klutter-dart)
[![CodeScene Code Health](https://codescene.io/projects/27237/status-badges/code-health)](https://codescene.io/projects/27237)


<br>

<img src="https://github.com/buijs-dev/klutter/blob/develop/.github/assets/metadata/icon/klutter_logo.png?raw=true" alt="buijs software logo" />

The Klutter Framework makes it possible to write a Flutter plugin for both Android
and iOS using [Kotlin Multiplatform](https://kotlinlang.org/docs/multiplatform.html).
Instead of writing platform specific code twice in 2 languages (Swift + Kotlin),
it can be written once in Kotlin and used as a Flutter plugin.

# Features

Use this plugin if you want to:

* Write platform-specific code only once for both Android and IOS in Kotlin.
* Use Kotlin Multiplatform libraries in your Flutter app.
* Depend on other plugins made with Klutter.
* Auto-generate Dart code for your (native) Platform library.

# Getting started
1. [Installation](#Installation)
2. [Using plugins](#Usage)
3. [Creating plugins](#Creation)
4. [FAQ](#Faq)

- Start a new project with the
  - [Intellij](https://buijs.dev/klutter-3/) plugin
  - [Android Studio](https://buijs.dev/klutter-4/) plugin
  - [Kradle](https://buijs.dev/kradle-1/) cli tool
- For a step-by-step guide (doing everything manually), see the battery app with Klutter [tutorial](https://buijs.dev/klutter-2/).

Using the IDE plugins or interactive kradle tool are the 
preferred options to create projects, as opposed
to doing everything manually. You can install
the kradle tool from git or pub:

```shell
## Get from pub 
dart pub global activate klutter

## Get from git
dart pub global activate --source git https://github.com/buijs-dev/klutter-dart.git

## Use it globally
dart pub global run klutter:kradle
```

A native kradle executable is added to the project workspace, 
when creating a new project using an IDE plugin.

See the kradle [tutorial](https://buijs.dev/kradle-1/) for usage instructions.

# Installation
<b>What's the point?</b></br>
Plugins build with the Klutter Framework work slightly different from regular plugins. 
The Klutter dependency is a requirement for both using and creating plugins with Klutter.

<b>Steps:</b></br>
Add the Klutter library to dependencies in the pubspec.yaml:

```yaml  
dev_dependencies:  
 klutter: ^3.0.1
```

Then run:  
  
```shell  
flutter pub get
```

# Usage
<b>What's the point?</b></br>
Plugins build with the Klutter Framework work slightly different from regular plugins. 
The following tasks help Flutter to locate Klutter plugins 
and ensure compatibility between Flutter Android/IOS configuration and Klutter plugin Android/IOS configuration.

<b>Steps:</b></br>
1. Installation.
2. Initialization.
3. Add dependencies.

Install Klutter as dependency as described [here](#Installation).

Initialize Klutter in your project by running:

```shell  
dart run klutter:kradle init
```  

The init task will set up Klutter for both Android and iOS.
Klutter plugins can be added by running the add command.

<B>Example</B>:</br> Add the library 'awesome_plugin' to your project:

```shell  
dart run klutter:kradle add lib=awesome_plugin 
```  

<b>Background</b></br>
The consumer init task will configure your Flutter project in:
1. [IOS](#ios)
2. [Android](#android)

<b>IOS</b></br>
The Podfile has to be editted to be able to run the app on an iPhone simulator.
Klutter will look for the following code block in the Podfile:

```
 post_install do |installer|
   installer.pods_project.targets.each do |target|
     flutter_additional_ios_build_settings(target)
   end
 end
```

Then it will be updated to the following code:

```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |bc|
        bc.build_settings['ARCHS[sdk=iphonesimulator*]'] =  `uname -m`
     end
  end
end
```


<b>Android</b></br>
The consumer init task will do the following for Android in your Flutter project:  
 1. Create a .klutter-plugins file in the root folder.  
 2. Create a new Gradle file in the flutter/packages/flutter_tools/gradle.  
 3. Update the android/settings.gradle file to apply the newly generated Gradle file.  
 4. Update the min/target SDK versions to 24/33 in the android/app/build.gradle file.
 5. Update the Android Gradle Plugin to 8.0.2 and gradle-wrapper to Gradle 8+.

The .klutter-plugins file will register all Klutter made plugins used in your project. 
The created Gradle file in the flutter_tools manages the plugins 
and enables them to be found by the Flutter project.  

The task klutter:add registers a Klutter plugin in the .klutter-plugins file. 
This is then used by the Android Gradle file to find the plugin location 
and add the generated artifacts to your build.

# Creation
<b>What's the point?</b></br>
The starting point of a Klutter plugins is a regular Flutter plugin project. 
The following steps describe how to create a Flutter plugin project and initialize Klutter in it.

<b>Steps:</b></br>
1. Create Flutter plugin project.
2. [Installation](#Installation).
3. Initialization.
4. Build Platform module and generate Dart code.
5. Verify your plugin.

Run the following to create a new Flutter plugin, 
substituting 'org.example' with your organisation name 
and 'plugin_name' with your plugin name:

```shell  
flutter create --org com.example --template=plugin --platforms=android,ios -a kotlin -i swift plugin_name
```  

Install the Klutter Framework as dependency and then run:

```shell  
dart run kradle:init  
```  

Build the platform module by running the following in the root folder (takes a few minutes):

```shell
dart run klutter:kradle build
```

Alternatively use gradle directly with the following command:

```shell
./gradlew clean build -p "platform"
```

Now test the plugin by following the steps outlined [here](#Usage) in the root/example project. 
When done you can run the example project from the root/example/lib folder and see your first plugin in action!

# Faq
1. [App won't start on...](#App%20won't%20start)
2. [Build fails](#build-fails)

## App won't start
Make sure you have followed all the following steps:
- flutter create <your_plugin_name> --org <your_organisation> --template=plugin --platforms=android,ios -a kotlin -i swift.
- [klutter](https://pub.dev/packages/klutter) is added to the dependencies in your pubspec.yaml 
(both the plugin and plugin/example for testing).
- do flutter pub get in both root and root/example folder.
- do flutter pub run klutter:kradle init in the root folder.
- do ./gradlew clean build -p "platform" in the root folder.
- do flutter pub run klutter:kradle init in the root/example folder.
- do flutter pub run klutter:kradle add lib=<your_plugin_name> in the root/example folder.

### For Android emulator:
There should be a .klutter-plugins file in the root/example folder containing an entry for your plugin.
If not then do flutter pub run klutter:consumer add=<your_plugin_name> in the root/example folder again.

There should be a platform.aar file in the root/android/klutter folder. 
If not then do ./gradlew clean build -p "platform" from the root folder.

### For iOS simulator:
There should be a Platform.xcframework folder in root/ios/Klutter.
If not then do ./gradlew clean build -p "platform" from the root folder.

If there's an error message saying unable to find plugin or similar then run pod update
(or for Mac M1 users you might have to do: arch -x86_64 pod install) in the root/example/ios
folder.

If there's an error message saying something similiar to '...example/ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks.sh: Permission denied' 
then try one of:
- delete the Podfile.lock and run pod install in root/example/ios folder.
- run pod deintegrate and then pod install in root/example/ios folder.

## Build fails
1. [Java toolchain error](#java-toolchain-error)

### Java toolchain error
When you get an error like below, indicating no compatible Java version is detected, make sure you 
have the same Java version installed as required by the klutter project. 

```shell
* What went wrong:
  Could not determine the dependencies of task ':klutter:hello_world:compileDebugKotlinAndroid'.
> No matching toolchains found for requested specification: {languageVersion=17, vendor=any, implementation=vendor-specific}.
> No locally installed toolchains match ...
```

You might also have to add the following plugin to the settings.gradle(.kts) files:

```kotlin
plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "0.4.0"
}
```