[<img src="./logo_animated.gif" width="200" border="5" alt="buijs software logo" />](https://github.com/buijs-dev)

# Klutter
[![GitHub license](https://img.shields.io/github/license/buijs-dev/klutter-dart?color=black&logoColor=black&style=for-the-badge)](https://github.com/buijs-dev/klutter-dart/blob/main/LICENSE)
[![codecov](https://img.shields.io/codecov/c/github/buijs-dev/klutter-dart?logo=codecov&style=for-the-badge)](https://codecov.io/gh/buijs-dev/klutter-dart)
[![CodeScene Code Health](https://img.shields.io/badge/CODESCENE-10-brightgreen?style=for-the-badge)](https://codescene.io/projects/27237)

The Klutter Framework makes it possible to write a Flutter plugin for both Android
and iOS using [Kotlin Multiplatform](https://kotlinlang.org/docs/multiplatform.html).
Instead of writing platform specific code twice in 2 languages (Swift + Kotlin),
it can be written once in Kotlin and used as a Flutter plugin.

<B>Important</B>: Klutter is in alpha and not yet published to PUB.

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

# Installation
<b>What's the point?</b></br>
Plugins build with the Klutter Framework work slightly different than regular plugins. 
The Klutter dev dependency is a requirement for both using and creating plugins with Klutter.

<b>Steps:</b></br>
Add the Klutter library to dev_dependencies in the pubspec.yaml:

```yaml  
dev_dependencies:  
 klutter: ^0.1.0
 ```  
  
Then run:  
  
```shell  
flutter pub get
```

# Usage
<b>What's the point?</b></br>
Plugins build with the Klutter Framework work slightly different than regular plugins. 
The following tasks help Flutter to locate Klutter plugins 
and ensure compatibility between Flutter Android/IOS configuration and Klutter plugin Android/IOS configuration.

<b>Steps:</b></br>
1. [Install](#Installation) the dev dependency. 
2. Setup Android.
3. Setup IOS.
4. Add dependencies.

Setup Android by running:  
  
```shell  
flutter pub run klutter:android
```  

Setup IOS by running:

```shell  
flutter pub run klutter:ios
```  

Add Klutter plugins by running the add command.

<B>Example</B>: Add the library 'awesome_plugin' to your project:

```shell  
flutter pub run klutter:add awesome_plugin 
```  

<b>Background</b></br>
This task will do the following for your Flutter project:  
 1. Create a .klutter-plugins file in the root folder.  
 2. Create a new Gradle file in the flutter/packages/flutter_tools/gradle.  
 3. Update the android/settings.gradle file to apply the newly generated Gradle file.  
 4. Update the min/compile/target SDK versions to 21/31/31 in the android/app/build.gradle file. 
  
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
2. [Install](#Installation) the dev dependency.
3. Initialize Klutter in your project.
4. Build Platform module.
5. Generate Dart code.
6. Verify your plugin.

Run the following to create a new Flutter plugin, 
substituting 'org.example' with your organisation name 
and 'plugin_name' with your plugin name:

```shell  
flutter create --org com.example --template=plugin --platforms=android,ios plugin_name
```  

Install the Klutter Framework as dev_dependency and then run:

```shell  
flutter pub run klutter:plugin create  
```  

Build the platform module by running the following in the root folder:

```shell
 ./gradlew klutterInstallPlatform
```

Generate the plugin Dart code:

```shell
./gradlew klutterGenerateAdapters
```

Now test the plugin by following the steps outlined [here](#Usage) in the root/example project. 
When done you can run the example project from the root/example/lib folder and see your first plugin in action!
