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

import "package:klutter/src/common/common.dart";
import "package:klutter/src/producer/platform.dart";
import "package:test/test.dart";

void main() {

  final s = Platform.pathSeparator;

  const pluginName = "some_plugin";

  test("Verify exception is thrown if root does not exist", () {
    expect(() => writeRootSettingsGradleFile(
      pathToRoot: "fake",
      pluginName: pluginName,
    ), throwsA(predicate((e) =>
        e is KlutterException &&
        e.cause.startsWith("Path does not exist:") &&
        e.cause.endsWith("/fake"))));
  });

  test("Verify root/settings.gradle.kts is created if it does not exist", () {

    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wsg1")
      ..createSync(recursive: true);

    final settingsGradle = File("${root.path}${s}settings.gradle.kts");

    writeRootSettingsGradleFile(
      pathToRoot: root.path,
      pluginName: pluginName,
    );

    expect(settingsGradle.readAsStringSync().replaceAll(" ", ""), """
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
            include(":klutter:some_plugin")
            project(":klutter:some_plugin").projectDir = File("platform")
            include(":android")""".replaceAll(" ", ""));

    root.deleteSync(recursive: true);

  });

  test("Verify root/settings.gradle.kts is overwritten if it exists", () {

    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wsg2")
      ..createSync(recursive: true);

    final settingsGradle = File("${root.path}${s}settings.gradle.kts")
      ..writeAsStringSync("nonsense");

    writeRootSettingsGradleFile(
      pathToRoot: root.path,
      pluginName: pluginName,
    );

    expect(settingsGradle.readAsStringSync().replaceAll(" ", ""), """
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
            include(":klutter:some_plugin")
            project(":klutter:some_plugin").projectDir = File("platform")
            include(":android")""".replaceAll(" ", ""));

    root.deleteSync(recursive: true);

  });

  test("Verify exception is thrown if root does not exist", () {
    expect(() => writeRootBuildGradleFile(
      pathToRoot: "fake",
      pluginName: "some_plugin",
    ), throwsA(predicate((e) =>
    e is KlutterException &&
        e.cause.startsWith("Path does not exist:") &&
        e.cause.endsWith("/fake"))));
  });

  test("Verify root/build.gradle.kts is created if it does not exist", () {

    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wsg1")
      ..createSync(recursive: true);

    final buildGradle = File("${root.path}${s}build.gradle.kts");

    writeRootBuildGradleFile(
      pathToRoot: root.path,
      pluginName: "some_plugin",
    );

    expect(buildGradle.readAsStringSync().replaceAll(" ", ""), """
          buildscript {
              repositories {
                  gradlePluginPortal()
                  google()
                  mavenCentral()
                  maven { url = uri("https://repsy.io/mvn/buijs-dev/klutter") }
              }
              dependencies {
                  classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.6.10")
                  classpath("com.android.tools.build:gradle:7.0.4")
                  classpath("dev.buijs.klutter:core:$klutterGradleVersion")
                  classpath("dev.buijs.klutter.gradle:dev.buijs.klutter.gradle.gradle.plugin:$klutterGradleVersion")
              }
          }
          
          repositories {
              google()
              gradlePluginPortal()
              mavenCentral()
              maven { url = uri("https://repsy.io/mvn/buijs-dev/klutter") }
          }
          
          allprojects {
              repositories {
                  google()
                  gradlePluginPortal()
                  mavenCentral()
                  maven {
                      url = uri("https://repsy.io/mvn/buijs-dev/klutter")
                  }
              }
          
          }
          
          tasks.register("clean", Delete::class) {
              delete(rootProject.buildDir)
          }
          
          tasks.register("klutterInstallPlatform", Exec::class) {
              commandLine("bash", "./gradlew", "clean", "build", "-p", "platform")
              finalizedBy("klutterCopyAarFile", "klutterCopyFramework")
          }
          
          tasks.register("klutterCopyAarFile", Copy::class) {
              from("platform/build/outputs/aar/some_plugin-release.aar")
              into("android/klutter")
              rename { fileName ->
                  fileName.replace("some_plugin-release", "platform")
              }
          }
          
          tasks.register("klutterCopyFramework", Copy::class) {
              from("platform/build/fat-framework/release")
              into("ios/Klutter")
          }""".replaceAll(" ", ""));

    root.deleteSync(recursive: true);

  });

  test("Verify root/build.gradle.kts is overwritten if it exists", () {

    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wsg1")
      ..createSync(recursive: true);

    final buildGradle = File("${root.path}${s}build.gradle.kts")
      ..writeAsStringSync("more nonsense");

    writeRootBuildGradleFile(
      pathToRoot: root.path,
      pluginName: "some_plugin",
    );

    expect(buildGradle.readAsStringSync().replaceAll(" ", ""), """
          buildscript {
              repositories {
                  gradlePluginPortal()
                  google()
                  mavenCentral()
                  maven { url = uri("https://repsy.io/mvn/buijs-dev/klutter") }
              }
              dependencies {
                  classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.6.10")
                  classpath("com.android.tools.build:gradle:7.0.4")
                  classpath("dev.buijs.klutter:core:$klutterGradleVersion")
                  classpath("dev.buijs.klutter.gradle:dev.buijs.klutter.gradle.gradle.plugin:$klutterGradleVersion")
              }
          }
          
          repositories {
              google()
              gradlePluginPortal()
              mavenCentral()
              maven { url = uri("https://repsy.io/mvn/buijs-dev/klutter") }
          }
          
          allprojects {
              repositories {
                  google()
                  gradlePluginPortal()
                  mavenCentral()
                  maven {
                      url = uri("https://repsy.io/mvn/buijs-dev/klutter")
                  }
              }
          
          }
          
          tasks.register("clean", Delete::class) {
              delete(rootProject.buildDir)
          }
          
          tasks.register("klutterInstallPlatform", Exec::class) {
              commandLine("bash", "./gradlew", "clean", "build", "-p", "platform")
              finalizedBy("klutterCopyAarFile", "klutterCopyFramework")
          }
          
          tasks.register("klutterCopyAarFile", Copy::class) {
              from("platform/build/outputs/aar/some_plugin-release.aar")
              into("android/klutter")
              rename { fileName ->
                  fileName.replace("some_plugin-release", "platform")
              }
          }
          
          tasks.register("klutterCopyFramework", Copy::class) {
              from("platform/build/fat-framework/release")
              into("ios/Klutter")
          }""".replaceAll(" ", ""));

    root.deleteSync(recursive: true);

  });

  test("Verify exception is thrown if root does not exist", () {
    expect(() => writeGradleProperties("fake"), throwsA(predicate((e) =>
    e is KlutterException &&
        e.cause.startsWith("Path does not exist:") &&
        e.cause.endsWith("/fake"))));
  });

  test("Verify root/gradle.properties is created if it does not exist", () {

    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wsg1")
      ..createSync(recursive: true);

    final properties = File("${root.path}${s}gradle.properties");

    writeGradleProperties(root.path);

    expect(properties.readAsStringSync().replaceAll(" ", ""), """
       #Gradle
       org.gradle.jvmargs=-Xmx2048M -Dkotlin.daemon.jvm.options="-Xmx2048M"
        
       #Kotlin
       kotlin.code.style=official
       
       #Android
       android.useAndroidX=true
        
       #MPP
       kotlin.mpp.enableGranularSourceSetsMetadata=true
       kotlin.native.enableDependencyPropagation=false
       kotlin.mpp.enableCInteropCommonization=true""".replaceAll(" ", ""));

    root.deleteSync(recursive: true);

  });

  test("Verify root/gradle.properties is overwritten if it exists", () {

    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wsg1")
      ..createSync(recursive: true);

    final properties = File("${root.path}${s}gradle.properties")
      ..writeAsStringSync("props=nada");

    writeGradleProperties(root.path);

    expect(properties.readAsStringSync().replaceAll(" ", ""), """
       #Gradle
       org.gradle.jvmargs=-Xmx2048M -Dkotlin.daemon.jvm.options="-Xmx2048M"
        
       #Kotlin
       kotlin.code.style=official
       
       #Android
       android.useAndroidX=true
        
       #MPP
       kotlin.mpp.enableGranularSourceSetsMetadata=true
       kotlin.native.enableDependencyPropagation=false
       kotlin.mpp.enableCInteropCommonization=true""".replaceAll(" ", ""));

    root.deleteSync(recursive: true);

  });

  test("Verify a root/platform module is created", () {

    final root = Directory("${Directory.systemTemp.path}${s}wsg7")
      ..createSync(recursive: true);

    createPlatformModule(
        pathToRoot: root.path,
        pluginName: "nigulp",
        packageName: "com.organisation.nigulp",
    );

    final platform =  Directory("${root.path}/platform".normalize);

    expect(true, platform.existsSync(),
      reason: "root/platform should be created",
    );

    final platformBuildGradle = File("${platform.path}/build.gradle.kts".normalize);

    expect(true, platformBuildGradle.existsSync(),
      reason: "root/platform/build.gradle.kts should be created",
    );

    expect("""
     plugins {
          id("com.android.library")
          id("dev.buijs.klutter.gradle")
          kotlin("multiplatform")
          kotlin("native.cocoapods")
          kotlin("plugin.serialization") version "1.6.10"
      }
      
      version = "1.0"
      
      klutter {
          root = rootProject.rootDir
          plugin { 
             name = "nigulp"
          }
      }
      
      kotlin {
          android()
          iosX64()
          iosArm64()
      
          cocoapods {
              summary = "Some description for the Shared Module"
              homepage = "Link to the Shared Module homepage"
              ios.deploymentTarget = "14.1"
              framework {
                  baseName = "Platform"
              }
          }
          
          sourceSets {
      
              val commonMain by getting {
                  dependencies {
                      api("org.jetbrains.kotlinx:kotlinx-serialization-json:1.3.2")
                      api("dev.buijs.klutter:annotations-kmp:$klutterGradleVersion")
                  }
              }
      
              val commonTest by getting {
                  dependencies {
                      implementation(kotlin("test-common"))
                      implementation(kotlin("test-annotations-common"))
                      implementation(kotlin("test-junit"))
                      implementation("junit:junit:4.13.2")
                      implementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.6.0")
                  }
              }
      
              val androidMain by getting {
                  dependencies {
                      implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.0")
                  }
              }
      
              val androidTest by getting {
                  dependencies {
                      implementation(kotlin("test-junit"))
                      implementation("junit:junit:4.13.2")
                  }
              }
      
              val iosX64Main by getting
              val iosArm64Main by getting
              val iosMain by creating {
                  dependsOn(commonMain)
                  iosX64Main.dependsOn(this)
                  iosArm64Main.dependsOn(this)
                  dependencies {}
              }
      
              val iosX64Test by getting
              val iosArm64Test by getting
              val iosTest by creating {
                  dependsOn(commonTest)
                  iosX64Test.dependsOn(this)
                  iosArm64Test.dependsOn(this)
              }
          }
      }
      
      android {
          compileSdk = 31
          sourceSets["main"].manifest.srcFile("src/androidMain/AndroidManifest.xml")
          defaultConfig {
              minSdk = 21
              targetSdk = 31
          }
      }""".replaceAll(" ", ""),
      platformBuildGradle.readAsStringSync().replaceAll(" ", ""),
    );

    final androidMain =  Directory("${platform.path}/src/androidMain/kotlin/com/organisation/nigulp/platform".normalize);

    expect(true, androidMain.existsSync(),
      reason: "root/klutter/nigulp/src/androidMain/kotlin/com/organisation/nigulp/platform should be created",
    );

    final commonMain =  Directory("${platform.path}/src/commonMain/kotlin/com/organisation/nigulp/platform".normalize);

    expect(true, commonMain.existsSync(),
      reason: "root/klutter/nigulp/src/commonMain/kotlin/com/organisation/nigulp/platform should be created",
    );

    final iosMain =  Directory("${platform.path}/src/iosMain/kotlin/com/organisation/nigulp/platform".normalize);

    expect(true, iosMain.existsSync(),
      reason: "root/klutter/nigulp/src/iosMain/kotlin/com/organisation/nigulp/platform should be created",
    );

    final androidManifest =  File("${platform.path}/src/androidMain/AndroidManifest.xml".normalize);

    expect(true, androidManifest.existsSync(),
      reason: "root/klutter/nigulp/src/androidMain/AndroidManifest.xml should be created",
    );

    expect( """
        <?xml version="1.0" encoding="utf-8"?>
        <manifest package="com.organisation.nigulp.platform" />
        """.replaceAll(" ", ""),
      androidManifest.readAsStringSync().replaceAll(" ", ""),
    );

    final androidPlatformClass =  File("${androidMain.path}/Platform.kt".normalize);

    expect(true, androidPlatformClass.existsSync(),
      reason: "root/klutter/nigulp/src/androidMain/kotlin/com/organisation/nigulp/platform/Platform.kt should be created",
    );

    expect(r"""
      package com.organisation.nigulp.platform
      
      actual class Platform actual constructor() {
          actual val platform: String = "Android ${android.os.Build.VERSION.SDK_INT}"
      }
      """.replaceAll(" ", ""),
      androidPlatformClass.readAsStringSync().replaceAll(" ", ""),
    );

    final commonGreetingClass =  File("${commonMain.path}/Greeting.kt".normalize);

    expect(true, commonGreetingClass.existsSync(),
      reason: "root/klutter/nigulp/src/commonMain/kotlin/com/organisation/nigulp/platform/Greeting.kt should be created",
    );

    expect(r"""
      package com.organisation.nigulp.platform
      
      import dev.buijs.klutter.annotations.kmp.KlutterAdaptee
      
      class Greeting {
      
          @KlutterAdaptee(name = "greeting")
          fun greeting(): String {
             return "Hello, ${Platform().platform}!"
          }
      
      }""".replaceAll(" ", ""),
      commonGreetingClass.readAsStringSync().replaceAll(" ", ""),
    );

    final commonPlatformClass =  File("${commonMain.path}/Platform.kt".normalize);

    expect(true, commonPlatformClass.existsSync(),
      reason: "root/klutter/nigulp/src/commonMain/kotlin/com/organisation/nigulp/platform/Platform.kt should be created",
    );

    expect("""
      package com.organisation.nigulp.platform
      
      expect class Platform() {
          val platform: String
      }""".replaceAll(" ", ""),
      commonPlatformClass.readAsStringSync().replaceAll(" ", ""),
    );

    final iosPlatformClass =  File("${iosMain.path}/Platform.kt".normalize);

    expect(true, iosPlatformClass.existsSync(),
      reason: "root/klutter/nigulp/src/iosMain/kotlin/com/organisation/nigulp/platform/Platform.kt should be created",
    );

    expect("""
      package com.organisation.nigulp.platform
      
      import platform.UIKit.UIDevice
      
      actual class Platform actual constructor() {
          actual val platform: String = UIDevice.currentDevice.systemName() + " " + UIDevice.currentDevice.systemVersion
      }
      """.replaceAll(" ", ""),
      iosPlatformClass.readAsStringSync().replaceAll(" ", ""),
    );

    root.deleteSync(recursive: true);

  });

}