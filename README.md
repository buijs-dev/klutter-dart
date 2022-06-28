[<img src="https://github.com/buijs-dev/klutter-dart/blob/main/logo_animated.gif?raw=true" width="300" alt="buijs software logo" />](https://github.com/buijs-dev)

# Klutter
[![GitHub license](https://img.shields.io/github/license/buijs-dev/klutter-dart?color=black&logoColor=black&style=for-the-badge)](https://github.com/buijs-dev/klutter-dart/blob/main/LICENSE)
[![pub](https://img.shields.io/pub/v/klutter?style=for-the-badge)](https://pub.dev/packages/klutter)
[![codecov](https://img.shields.io/codecov/c/github/buijs-dev/klutter-dart?logo=codecov&style=for-the-badge)](https://codecov.io/gh/buijs-dev/klutter-dart)
[![CodeScene Code Health](https://img.shields.io/badge/CODESCENE-10-brightgreen?style=for-the-badge)](https://codescene.io/projects/27237)

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
1. Installation.
3. Initialization.
4. Add dependencies.

Install Klutter as dev_dependency as described [here](#Installation).

Initialize Klutter in your project by running:

```shell  
flutter pub run klutter:consumer init
```  

The init task will setup Klutter for both Android and iOS.
Alternatively you can setup Android and IOS separately.

Setup Android by running:  
  
```shell  
flutter pub run klutter:consumer init=android
```  

Setup IOS by running:

```shell  
flutter pub run klutter:consumer init=ios
```  

Finally Klutter plugins can be added by running the add command.

<B>Example</B>:</br> Add the library 'awesome_plugin' to your project:

```shell  
flutter pub run klutter:consumer add=awesome_plugin 
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
2. [Installation](#Installation).
3. Initialization.
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
flutter pub run klutter:producer init  
```  

Build the platform module by running the following in the root folder (takes a few minutes!):

```shell
flutter pub run klutter:producer install=platform 
```

Generate the plugin Dart code:

```shell
flutter pub run klutter:producer install=library  
```

Now test the plugin by following the steps outlined [here](#Usage) in the root/example project. 
When done you can run the example project from the root/example/lib folder and see your first plugin in action!