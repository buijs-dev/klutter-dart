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

import "package:klutter/src/common/common.dart";
import "package:klutter/src/producer/platform.dart";
import "package:test/test.dart";

void main() {
  final s = Platform.pathSeparator;

  const pluginName = "some_plugin";

  test("Verify root/settings.gradle.kts is created if it does not exist", () {
    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wsg1")
      ..createSync(recursive: true);

    final settingsGradle = File("${root.path}${s}settings.gradle.kts");

    writeRootSettingsGradleFile(
      pathToRoot: root.path,
      pluginName: pluginName,
    );

    expect(
        settingsGradle.readAsStringSync().replaceAll(" ", ""),
        """
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
            include(":klutter:some_plugin")
            project(":klutter:some_plugin").projectDir = File("platform")
            include(":android")"""
            .replaceAll(" ", ""));

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

    expect(
        settingsGradle.readAsStringSync().replaceAll(" ", ""),
        """
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
            include(":klutter:some_plugin")
            project(":klutter:some_plugin").projectDir = File("platform")
            include(":android")"""
            .replaceAll(" ", ""));

    root.deleteSync(recursive: true);
  });

  test("Verify exception is thrown if root does not exist", () {
    expect(
        () => writeRootBuildGradleFile(
          pathToRoot: "fake",
          pluginName: "some_plugin",
          klutterBomVersion: "2023.3.1",),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith("Path does not exist:") &&
            e.cause.endsWith("fake"))));
  });

  test("Verify root/build.gradle.kts is created if it does not exist", () {
    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wsg1")
      ..createSync(recursive: true);

    final buildGradle = File("${root.path}${s}build.gradle.kts");

    writeRootBuildGradleFile(
      pathToRoot: root.path,
      pluginName: "some_plugin",
      klutterBomVersion: "2023.3.1",
    );

    expect(
        buildGradle.readAsStringSync().replaceAll(" ", ""),
        """
          buildscript {
              repositories {
                  gradlePluginPortal()
                  google()
                  mavenCentral()
                  mavenLocal()
                  maven { url = uri("https://repsy.io/mvn/buijs-dev/klutter") }
              }
              dependencies {
                  classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.10")
                  classpath("com.android.tools.build:gradle:8.0.2")
                  classpath(platform("dev.buijs.klutter:bom:2023.3.1"))
                  classpath("dev.buijs.klutter:gradle")
              }
          }
      """.replaceAll(" ", ""));

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
      klutterBomVersion: "2023.3.1",
    );

    expect(
        buildGradle.readAsStringSync().replaceAll(" ", ""),
        """
          buildscript {
              repositories {
                  gradlePluginPortal()
                  google()
                  mavenCentral()
                  mavenLocal()
                  maven { url = uri("https://repsy.io/mvn/buijs-dev/klutter") }
              }
              dependencies {
                  classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.10")
                  classpath("com.android.tools.build:gradle:8.0.2")
                  classpath(platform("dev.buijs.klutter:bom:2023.3.1"))
                  classpath("dev.buijs.klutter:gradle")
              }
          }
      """.replaceAll(" ", ""));

    root.deleteSync(recursive: true);
  });

  test("Verify root/gradle.properties is created if it does not exist", () {
    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wsg1")
      ..createSync(recursive: true);

    final properties = File("${root.path}${s}gradle.properties");

    writeGradleProperties(root.path);

    expect(
        properties.readAsStringSync().replaceAll(" ", ""),
        """
       #Gradle
       org.gradle.jvmargs=-Xmx2048M -Dkotlin.daemon.jvm.options="-Xmx2048M"
        
       #Kotlin
       kotlin.code.style=official
       
       #Android
       android.useAndroidX=true
        
       #MPP
       kotlin.mpp.stability.nowarn=true"""
            .replaceAll(" ", ""));

    root.deleteSync(recursive: true);
  });

  test("Verify root/gradle.properties is overwritten if it exists", () {
    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wsg1")
      ..createSync(recursive: true);

    final properties = File("${root.path}${s}gradle.properties")
      ..writeAsStringSync("props=nada");

    writeGradleProperties(root.path);

    expect(
        properties.readAsStringSync().replaceAll(" ", ""),
        """
       #Gradle
       org.gradle.jvmargs=-Xmx2048M -Dkotlin.daemon.jvm.options="-Xmx2048M"
        
       #Kotlin
       kotlin.code.style=official
       
       #Android
       android.useAndroidX=true
        
       #MPP
       kotlin.mpp.stability.nowarn=true"""
            .replaceAll(" ", ""));

    root.deleteSync(recursive: true);
  });

  test("Verify a root/platform module is created", () {
    final root = Directory("${Directory.systemTemp.path}${s}wsg7")
      ..createSync(recursive: true);

    root.resolveFile("kradle.yaml")
      ..maybeCreate
      ..writeAsStringSync("flutter-version: '3.0.5.macos.arm64'")
    ;

    createPlatformModule(
      pathToRoot: root.path,
      pluginName: "nigulp",
      packageName: "com.organisation.nigulp",
    );

    final platform = Directory("${root.path}/platform".normalize);

    expect(
      true,
      platform.existsSync(),
      reason: "root/platform should be created",
    );

    final platformBuildGradle =
        File("${platform.path}/build.gradle.kts".normalize);

    expect(
      true,
      platformBuildGradle.existsSync(),
      reason: "root/platform/build.gradle.kts should be created",
    );

    expect(
      """
     import dev.buijs.klutter.gradle.dsl.embedded
     import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework
     import dev.buijs.klutter.gradle.tasks.*
    
     plugins {
          id("com.android.library")
          id("dev.buijs.klutter")
          kotlin("multiplatform")
          kotlin("plugin.serialization") version "1.9.0"
      }
      
      version = "1.0"
      
      klutter {
          root = rootProject.rootDir
          
          plugin { 
             name = "nigulp"
          }
          
          include("bill-of-materials")
      }
      
      kotlin {
  
          jvmToolchain(17)
          androidTarget()
      
          val xcfName = "Platform"
          val xcFramework = XCFramework(xcfName)
      
          ios { 
             binaries.framework { 
                  baseName = xcfName         
                  xcFramework.add(this)
                  export("dev.buijs.klutter:flutter-engine:2024.1.1.beta")
              }
          }
      
          iosSimulatorArm64 {
              binaries.framework {
                  baseName = xcfName
                  xcFramework.add(this)
                  export("dev.buijs.klutter:flutter-engine-iosSimulatorArm64:2024.1.1.beta")
              }
          }    
      
          sourceSets {
      
              val commonMain by getting {
                  dependencies {
                      implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")
                      implementation("org.jetbrains.kotlinx:kotlinx-serialization-protobuf:1.6.3")
                      implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
                  }
              }
      
              val commonTest by getting {
                  dependencies {
                      implementation(kotlin("test-common"))
                      implementation(kotlin("test-annotations-common"))
                      implementation(kotlin("test-junit"))
                      implementation("junit:junit:4.13.2")
                      implementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
                  }
              }
      
              val androidMain by getting {
                  dependencies {
                      implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
                      embedded("dev.buijs.klutter:flutter-engine-kmp-android:2024.1.1.beta")
                  }
              }
      
              val androidUnitTest by getting {
                  dependencies {
                      implementation(kotlin("test-junit"))
                      implementation("junit:junit:4.13.2")
                  }
              }
      
              val iosMain by getting {
                  dependencies {
                      api("dev.buijs.klutter:flutter-engine:2024.1.1.beta")
                  }
              }
              
              val iosSimulatorArm64Main by getting {
                  dependsOn(iosMain)
                  dependencies {
                    api("dev.buijs.klutter:flutter-engine-iosSimulatorArm64:2024.1.1.beta")
                  }
              }
      
              val iosTest by getting
              val iosSimulatorArm64Test by getting {
                  dependsOn(iosTest)
              }
          }
      }
      
      android {
          namespace = "com.organisation.nigulp.platform"
          sourceSets["main"].kotlin { srcDirs("src/androidMain/kotlin") }
          
          compileOptions {
              sourceCompatibility = JavaVersion.VERSION_17
              targetCompatibility = JavaVersion.VERSION_17
          }
          
          defaultConfig {
              compileSdk = 33
              minSdk = 24
          }
          
          publishing {
             singleVariant("release") {
                  withSourcesJar()
                  withJavadocJar()
              }
      
              singleVariant("debug") {
                  withSourcesJar()
                  withJavadocJar()
              }
          }
      }
      
      val gradleBuildInstanceClassLoader: ClassLoader = this::class.java.classLoader
      tasks.register<GenerateProtoSchemasGradleTask>("klutterGenerateProtoSchemas") {
          classLoader = gradleBuildInstanceClassLoader
      }
    
      tasks.configureEach {
          if (name.startsWith("compile")) {
              mustRunAfter(tasks.named("kspCommonMainKotlinMetadata"))
          }
     }
      """.replaceAll(" ", ""),
      platformBuildGradle.readAsStringSync().replaceAll(" ", ""),
    );

    final androidMain = Directory(
        "${platform.path}/src/androidMain/kotlin/com/organisation/nigulp/platform"
            .normalize);

    expect(
      true,
      androidMain.existsSync(),
      reason:
          "root/klutter/nigulp/src/androidMain/kotlin/com/organisation/nigulp/platform should be created",
    );

    final commonMain = Directory(
        "${platform.path}/src/commonMain/kotlin/com/organisation/nigulp/platform"
            .normalize);

    expect(
      true,
      commonMain.existsSync(),
      reason:
          "root/klutter/nigulp/src/commonMain/kotlin/com/organisation/nigulp/platform should be created",
    );

    final iosMain = Directory(
        "${platform.path}/src/iosMain/kotlin/com/organisation/nigulp/platform"
            .normalize);

    expect(
      true,
      iosMain.existsSync(),
      reason:
          "root/klutter/nigulp/src/iosMain/kotlin/com/organisation/nigulp/platform should be created",
    );

    final androidPlatformClass =
        File("${androidMain.path}/Platform.kt".normalize);

    expect(
      true,
      androidPlatformClass.existsSync(),
      reason:
          "root/klutter/nigulp/src/androidMain/kotlin/com/organisation/nigulp/platform/Platform.kt should be created",
    );

    expect(
      r"""
      package com.organisation.nigulp.platform
      
      actual class Platform actual constructor() {
          actual val platform: String = "Android ${android.os.Build.VERSION.SDK_INT}"
      }
      """
          .replaceAll(" ", ""),
      androidPlatformClass.readAsStringSync().replaceAll(" ", ""),
    );

    final commonGreetingClass =
        File("${commonMain.path}/Greeting.kt".normalize);

    expect(
      true,
      commonGreetingClass.existsSync(),
      reason:
          "root/klutter/nigulp/src/commonMain/kotlin/com/organisation/nigulp/platform/Greeting.kt should be created",
    );

    expect(
      r"""
      package com.organisation.nigulp.platform
      
      import dev.buijs.klutter.annotations.Controller
      import dev.buijs.klutter.annotations.Event
      
      @Controller
      class Greeting {
      
          @Event(name = "greeting")
          fun greeting(): String {
             return "Hello, ${Platform().platform}!"
          }
      
      }"""
          .replaceAll(" ", ""),
      commonGreetingClass.readAsStringSync().replaceAll(" ", ""),
    );

    final commonPlatformClass =
        File("${commonMain.path}/Platform.kt".normalize);

    expect(
      true,
      commonPlatformClass.existsSync(),
      reason:
          "root/klutter/nigulp/src/commonMain/kotlin/com/organisation/nigulp/platform/Platform.kt should be created",
    );

    expect(
      """
      package com.organisation.nigulp.platform
      
      expect class Platform() {
          val platform: String
      }"""
          .replaceAll(" ", ""),
      commonPlatformClass.readAsStringSync().replaceAll(" ", ""),
    );

    final iosPlatformClass = File("${iosMain.path}/Platform.kt".normalize);

    expect(
      true,
      iosPlatformClass.existsSync(),
      reason:
          "root/klutter/nigulp/src/iosMain/kotlin/com/organisation/nigulp/platform/Platform.kt should be created",
    );

    expect(
      """
      package com.organisation.nigulp.platform
      
      import platform.UIKit.UIDevice
      
      actual class Platform actual constructor() {
          actual val platform: String = UIDevice.currentDevice.systemName() + " " + UIDevice.currentDevice.systemVersion
      }
      """
          .replaceAll(" ", ""),
      iosPlatformClass.readAsStringSync().replaceAll(" ", ""),
    );

    root.deleteSync(recursive: true);
  });
}
