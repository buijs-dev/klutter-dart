// Copyright (c) 2021 - 2023 Buijs Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import "dart:io";

import "../common/config.dart";
import "../common/utilities.dart";

/// Generate the settings.gradle.kts file in the root folder.
///
/// The settings file includes 2 modules:
/// - root/android
/// - root/klutter/<plugin-name>
///
/// The root/klutter/<plugin-name> module contains the platform module
/// with the plugin implementation code.
///
/// {@category producer}
/// {@category gradle}
void writeRootSettingsGradleFile({
  required String pathToRoot,
  required String pluginName,
}) =>
    pathToRoot.verifyExists.createRootSettingsGradleFile
        .writeSettingsGradleContent(pluginName);

/// Generate the build.gradle.kts file in the root folder.
///
/// The build file applies the Klutter Gradle plugin.
///
/// {@category producer}
/// {@category gradle}
void writeRootBuildGradleFile({
  required String pathToRoot,
  required String pluginName,
  required String klutterBomVersion,
}) =>
    pathToRoot.verifyExists.createRootBuildGradleFile
        .writeRootBuildGradleContent(pluginName, klutterBomVersion);

/// Generate the Kotlin Multiplatform module.
///
/// The klutter folder contains 2 folders:
/// - android
/// - <plugin-name>
///
/// The android folder contains the .aar artifact.
///
/// The <plugin-name> folder contains the Kotlin Multiplatform module.
///
/// {@category producer}
void createPlatformModule({
  required String pathToRoot,
  required String pluginName,
  required String packageName,
}) =>
    PlatformModule.fromRoot(
      pathToRoot: pathToRoot,
      pluginName: pluginName,
      packageName: packageName,
    )
      ..createPlatformGradleFile
      ..createPlatformSourceFolders
      ..createAndroidManifest
      ..createAndroidPlatformClass
      ..createCommonGreetingClass
      ..createCommonPlatformClass
      ..createIosPlatformClass;

/// Generate the build.gradle.kts file in the root folder.
///
/// The build file applies the Klutter Gradle plugin.
///
/// {@category producer}
/// {@category gradle}
void writeGradleProperties(String pathToRoot) => pathToRoot
    .verifyExists.createRootGradlePropertiesFile.writeGradlePropertiesContent;

extension on String {
  /// Create a settings.gradle.kts in the root folder.
  File get createRootSettingsGradleFile =>
      File("$this/settings.gradle.kts").normalizeToFile
        ..ifNotExists((folder) => File(folder.absolutePath).createSync());

  /// Create a build.gradle.kts in the root folder.
  File get createRootBuildGradleFile =>
      File("$this/build.gradle.kts").normalizeToFile
        ..ifNotExists((folder) => File(folder.absolutePath).createSync());

  /// Create a build.gradle.kts in the root folder.
  File get createRootGradlePropertiesFile =>
      File("$this/gradle.properties").normalizeToFile
        ..ifNotExists((folder) => File(folder.absolutePath).createSync());
}

extension on File {
  /// Write the content of the settings.gradle.kts of a Klutter plugin.
  void writeSettingsGradleContent(String pluginName) {
    writeAsStringSync('''
            // Copyright (c) 2021 - 2022 Buijs Software
            |//
            |// Permission is hereby granted, free of charge, to any person obtaining a copy
            |// of this software and associated documentation files (the "Software"), to deal
            |// in the Software without restriction, including without limitation the rights
            |// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
            |// copies of the Software, and to permit persons to whom the Software is
            |// furnished to do so, subject to the following conditions:
            |//
            |// The above copyright notice and this permission notice shall be included in all
            |// copies or substantial portions of the Software.
            |//
            |// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
            |// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
            |// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
            |// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
            |// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
            |// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
            |// SOFTWARE.
            |include(":klutter:$pluginName")
            |project(":klutter:$pluginName").projectDir = File("platform")
            |include(":android")'''
        .format);
  }

  /// Write the content of the build.gradle.kts of a Klutter plugin.
  void writeRootBuildGradleContent(
      String pluginName, String klutterBomVersion) {
    writeAsStringSync('''
          buildscript {
          |    repositories {
          |        gradlePluginPortal()
          |        google()
          |        mavenCentral()
          |        mavenLocal()
          |        maven { url = uri("https://repsy.io/mvn/buijs-dev/klutter") }
          |    }
          |    dependencies {
          |        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.6.10")
          |        classpath("com.android.tools.build:gradle:7.0.4")
          |        classpath(platform("dev.buijs.klutter:bom:$klutterBomVersion"))
          |        classpath("dev.buijs.klutter:gradle")
          |    }
          |}
          |'''
        .format);
  }

  /// Write the content of gradle.properties.
  void get writeGradlePropertiesContent {
    writeAsStringSync('''
        #Gradle
        |org.gradle.jvmargs=-Xmx2048M -Dkotlin.daemon.jvm.options="-Xmx2048M"
        | 
        |#Kotlin
        |kotlin.code.style=official
        |
        |#Android
        |android.useAndroidX=true
        | 
        |#MPP
        |kotlin.mpp.enableCInteropCommonization=true
        |kotlin.mpp.stability.nowarn=true'''
        .format);
  }
}

/// The root/platform module containing the Kotlin Multiplatform sourcecode.
class PlatformModule {
  /// Create a PlatformModule.
  const PlatformModule({
    required this.root,
    required this.pluginName,
    required this.packageName,
    required this.androidMain,
    required this.commonMain,
    required this.iosMain,
  });

  /// Create a PlatformModule based of a root path.
  factory PlatformModule.fromRoot({
    required String pathToRoot,
    required String pluginName,
    required String packageName,
  }) {
    final root = Directory("$pathToRoot/platform".normalize)
      ..ifNotExists((folder) => Directory(folder.absolutePath).createSync());

    final kotlinSource = "kotlin/${packageName.replaceAll(".", "/")}/platform";
    final androidMain = root.resolveFolder("src/androidMain/$kotlinSource");
    final commonMain = root.resolveFolder("src/commonMain/$kotlinSource");
    final iosMain = root.resolveFolder("src/iosMain/$kotlinSource");

    return PlatformModule(
      root: root,
      pluginName: pluginName,
      packageName: packageName,
      androidMain: androidMain,
      commonMain: commonMain,
      iosMain: iosMain,
    );
  }

  /// The root/platform folder.
  final Directory root;

  /// The name of the plugin as defined in the pubspec.yaml 'name:' tag.
  final String pluginName;

  /// The android package name being.
  final String packageName;

  /// The root/platform/src/androidMain/kotlin/<organisation>/platform/ folder.
  final Directory androidMain;

  /// The root/platform/src/commonMain/kotlin/<organisation>/platform/ folder.
  final Directory commonMain;

  /// The root/platform/src/iosMain/kotlin/<organisation>/platform/ folder.
  final Directory iosMain;

  /// Create the source folders:
  /// - androidMain
  /// - commonMain
  /// - iosMain
  void get createPlatformSourceFolders {
    androidMain.maybeCreate;
    commonMain.maybeCreate;
    iosMain.maybeCreate;
  }

  /// Create the build.gradle.kts file in the platform module.
  ///
  /// This build.gradle.kts file applies the Klutter Gradle plugin.
  void get createPlatformGradleFile {
    File("${root.absolute.path}/build.gradle.kts".normalize)
      ..maybeCreate
      ..writeAsStringSync("""
      import dev.buijs.klutter.gradle.dsl.embedded
      |import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework
      |
      |plugins {
      |    id("com.android.library")
      |    id("dev.buijs.klutter")
      |    kotlin("multiplatform")
      |    kotlin("plugin.serialization") version "1.6.10"
      |}
      |
      |version = "1.0"
      |
      |klutter {
      |    root = rootProject.rootDir
      |
      |    plugin { 
      |       name = "$pluginName"
      |    }
      |
      |    include("bill-of-materials")
      |}
      |    
      |ksp {
      |    arg("klutterScanFolder", project.buildDir.absolutePath)
      |    arg("klutterOutputFolder", project.projectDir.parentFile.absolutePath)
      |    arg("klutterGenerateAdapters", "true")
      |    arg("intelMac", "false") // Set to "true" if you're building on an Intel Mac!
      |}
      |
      |kotlin {
      |
      |    android()
      |
      |    val xcfName = "Platform"
      |    val xcFramework = XCFramework(xcfName)
      |
      |    ios { 
      |       binaries.framework { 
      |            baseName = xcfName         
      |            xcFramework.add(this)
      |            export("dev.buijs.klutter:flutter-engine:2023.1.1.beta")
      |        }
      |    }
      |
      |    iosSimulatorArm64 {
      |        binaries.framework {
      |            baseName = xcfName
      |            xcFramework.add(this)
      |            export("dev.buijs.klutter:flutter-engine-iosSimulatorArm64:2023.1.1.beta")
      |        }
      |    }    
      |
      |    sourceSets {
      |
      |        val commonMain by getting {
      |            dependencies {
      |                implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.5.0")
      |                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.0")
      |            }
      |        }
      |
      |        val commonTest by getting {
      |            dependencies {
      |                implementation(kotlin("test-common"))
      |                implementation(kotlin("test-annotations-common"))
      |                implementation(kotlin("test-junit"))
      |                implementation("junit:junit:4.13.2")
      |                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.6.4")
      |            }
      |        }
      |
      |        val androidMain by getting {
      |            dependencies {
      |                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4")
      |                embedded("dev.buijs.klutter:flutter-engine-kmp-android:2023.1.1.beta")
      |            }
      |        }
      |
      |        val androidTest by getting {
      |            dependencies {
      |                implementation(kotlin("test-junit"))
      |                implementation("junit:junit:4.13.2")
      |            }
      |        }
      |
      |        val iosMain by getting
      |        val iosSimulatorArm64Main by getting {
      |           dependsOn(iosMain)
      |           dependencies {
      |             api("dev.buijs.klutter:flutter-engine-iosSimulatorArm64:2023.1.1.beta")
      |           }
      |        }
      |        
      |        val iosTest by getting
      |        val iosSimulatorArm64Test by getting {
      |           dependsOn(iosTest)
      |        }
      |    }
      |}
      |
      |android {
      |    compileSdk = $androidCompileSdk
      |    sourceSets["main"].manifest.srcFile("src/androidMain/AndroidManifest.xml")
      |    sourceSets["main"].kotlin { srcDirs("src/androidMain/kotlin") }
      |    defaultConfig {
      |        minSdk = $androidMinSdk
      |        targetSdk = $androidTargetSdk
      |    }
      |}
      |
      |tasks.build.get()
      |    .setFinalizedBy(listOf(
      |        tasks.getByName("assemblePlatformReleaseXCFramework"),
      |        tasks.getByName("klutterCopyAarFile")))
      |
      |tasks.getByName("assemblePlatformReleaseXCFramework")
      |    .setFinalizedBy(listOf(tasks.getByName("klutterCopyFramework")))
      |"""
          .format);
  }

  /// Create the AndroidManifest.xml file.
  ///
  /// Will create a new file if it does not exist
  /// or overwrite the current AndroidManifest.xml
  /// if it already exists.
  void get createAndroidManifest {
    root.resolveFile("src/androidMain/AndroidManifest.xml").normalizeToFile
      ..maybeCreate
      ..writeAsStringSync(
        """
        <?xml version="1.0" encoding="utf-8"?>
        |<manifest package="$packageName.platform" />
        """
            .format,
      );
  }

  /// Create Platform.kt (Kotlin) class file
  /// in android package with example Kotlin code.
  void get createAndroidPlatformClass {
    androidMain.resolveFile("Platform.kt").normalizeToFile
      ..maybeCreate
      ..writeAsStringSync("""
      package $packageName.platform
      |
      |actual class Platform actual constructor() {
      |    actual val platform: String = "Android \${android.os.Build.VERSION.SDK_INT}"
      |}
      """
          .format);
  }

  /// Create Greeting.kt (Kotlin) class file
  /// in common package with example Kotlin code.
  void get createCommonGreetingClass {
    commonMain.resolveFile("Greeting.kt").normalizeToFile
      ..maybeCreate
      ..writeAsStringSync("""
      package $packageName.platform
      |
      |import dev.buijs.klutter.annotations.Controller
      |import dev.buijs.klutter.annotations.Event
      |
      |@Controller
      |class Greeting {
      |
      |    @Event(name = "greeting")
      |    fun greeting(): String {
      |       return "Hello, \${Platform().platform}!"
      |    }
      |
      |}"""
          .format);
  }

  /// Create Platform.kt (Kotlin) class file
  /// in common package with example Kotlin code.
  void get createCommonPlatformClass {
    commonMain.resolveFile("Platform.kt").normalizeToFile
      ..maybeCreate
      ..writeAsStringSync("""
      package $packageName.platform
      |
      |expect class Platform() {
      |    val platform: String
      |}"""
          .format);
  }

  /// Create Platform.kt (Kotlin) class file
  /// in ios package with example Kotlin code.
  void get createIosPlatformClass {
    iosMain.resolveFile("Platform.kt").normalizeToFile
      ..maybeCreate
      ..writeAsStringSync("""
      package $packageName.platform
      |
      |import platform.UIKit.UIDevice
      |
      |actual class Platform actual constructor() {
      |    actual val platform: String = UIDevice.currentDevice.systemName() + " " + UIDevice.currentDevice.systemVersion
      |}
      """
          .format);
  }
}
