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

import "package:klutter/src/common/exception.dart";
import "package:klutter/src/producer/platform.dart";
import "package:test/test.dart";

void main() {

  final s = Platform.pathSeparator;

  const pluginName = "some_plugin";

  test("Verify exception is thrown if root does not exist", () {
    expect(() => writeSettingsGradleFile(
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

    writeSettingsGradleFile(
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
            include(":android")""".replaceAll(" ", ""));

    root.deleteSync(recursive: true);

  });

  test("Verify root/settings.gradle.kts is overwritten if it exists", () {

    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wsg2")
      ..createSync(recursive: true);

    final settingsGradle = File("${root.path}${s}settings.gradle.kts")
      ..writeAsStringSync("nonsense");

    writeSettingsGradleFile(
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
            include(":android")""".replaceAll(" ", ""));

    root.deleteSync(recursive: true);

  });

  test("Verify exception is thrown if root does not exist", () {
    expect(() => writeBuildGradleFile("fake"), throwsA(predicate((e) =>
    e is KlutterException &&
        e.cause.startsWith("Path does not exist:") &&
        e.cause.endsWith("/fake"))));
  });

  test("Verify root/settings.gradle.kts is created if it does not exist", () {

    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wsg1")
      ..createSync(recursive: true);

    final buildGradle = File("${root.path}${s}build.gradle.kts");

    writeBuildGradleFile(root.path);

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
                  classpath("dev.buijs.klutter:core:2022-alpha-1")
                  classpath("dev.buijs.klutter.gradle:dev.buijs.klutter.gradle.gradle.plugin:2022-alpha-1")
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
          }""".replaceAll(" ", ""));

    root.deleteSync(recursive: true);

  });

  test("Verify root/build.gradle.kts is overwritten if it exists", () {

    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wsg1")
      ..createSync(recursive: true);

    final buildGradle = File("${root.path}${s}build.gradle.kts")
      ..writeAsStringSync("more nonsense");

    writeBuildGradleFile(root.path);

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
                  classpath("dev.buijs.klutter:core:2022-alpha-1")
                  classpath("dev.buijs.klutter.gradle:dev.buijs.klutter.gradle.gradle.plugin:2022-alpha-1")
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

}