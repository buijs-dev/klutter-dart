// Copyright (c) 2021 - 2022 Buijs Software
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

import "../common/shared.dart";

/// Generate the settings.gradle.kts file in the root folder.
///
/// The settings file includes 2 modules:
/// - root/android
/// - root/klutter/<plugin-name>
///
/// The root/klutter/<plugin-name> module contains the platform module
/// with the plugin implementation code.
void writeSettingsGradleFile({
  required String pathToRoot,
  required String pluginName,
}) =>
    pathToRoot.verifyExists.createSettingsGradleFile
        .writeSettingsGradleContent(pluginName);

/// Generate the build.gradle.kts file in the root folder.
///
/// The build file applies the Klutter Gradle plugin.
void writeBuildGradleFile(String pathToRoot) =>
    pathToRoot.verifyExists.createBuildGradleFile.writeBuildGradleContent;

/// Generate the build.gradle.kts file in the root folder.
///
/// The build file applies the Klutter Gradle plugin.
void writeGradleProperties(String pathToRoot) => pathToRoot
    .verifyExists.createGradlePropertiesFile.writeGradlePropertiesContent;

extension on String {
  /// Create a settings.gradle.kts in the root folder.
  File get createSettingsGradleFile =>
      File("${this}/settings.gradle.kts").normalize
        ..ifNotExists((folder) => File(folder.absolutePath).createSync());

  /// Create a build.gradle.kts in the root folder.
  File get createBuildGradleFile => File("${this}/build.gradle.kts").normalize
    ..ifNotExists((folder) => File(folder.absolutePath).createSync());

  /// Create a build.gradle.kts in the root folder.
  File get createGradlePropertiesFile =>
      File("${this}/gradle.properties").normalize
        ..ifNotExists((folder) => File(folder.absolutePath).createSync());
}

extension on File {
  /// Write the content of the the settings.gradle.kts of a Klutter plugin.
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
            |include(":android")'''
        .format);
  }

  /// Write the content of the the settings.gradle.kts of a Klutter plugin.
  void get writeBuildGradleContent {
    writeAsStringSync('''
          buildscript {
          |    repositories {
          |        gradlePluginPortal()
          |        google()
          |        mavenCentral()
          |        maven { url = uri("https://repsy.io/mvn/buijs-dev/klutter") }
          |    }
          |    dependencies {
          |        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.6.10")
          |        classpath("com.android.tools.build:gradle:7.0.4")
          |        classpath("dev.buijs.klutter:core:2022-alpha-1")
          |        classpath("dev.buijs.klutter.gradle:dev.buijs.klutter.gradle.gradle.plugin:2022-alpha-1")
          |    }
          |}
          |
          |repositories {
          |    google()
          |    gradlePluginPortal()
          |    mavenCentral()
          |    maven { url = uri("https://repsy.io/mvn/buijs-dev/klutter") }
          |}
          |
          |allprojects {
          |    repositories {
          |        google()
          |        gradlePluginPortal()
          |        mavenCentral()
          |        maven {
          |            url = uri("https://repsy.io/mvn/buijs-dev/klutter")
          |        }
          |    }
          |
          |}
          |
          |tasks.register("clean", Delete::class) {
          |    delete(rootProject.buildDir)
          |}'''
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
        |kotlin.mpp.enableGranularSourceSetsMetadata=true
        |kotlin.native.enableDependencyPropagation=false
        |kotlin.mpp.enableCInteropCommonization=true'''
        .format);
  }
}
