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
import "package:klutter/src/producer/android.dart";
import "package:test/test.dart";

void main() {

  final s = Platform.pathSeparator;

  const pluginVersion = "1.0.0";
  const packageName = "dev.buijs.klutter.example_plugin";

  test("Verify exception is thrown if root/android does not exist", () {
    expect(() => writeBuildGradleFile(
      pluginVersion: pluginVersion,
      packageName: packageName,
      pathToAndroid: "fake"
    ), throwsA(predicate((e) =>
        e is KlutterException &&
        e.cause.startsWith("Path does not exist:") &&
        e.cause.endsWith("/fake"))));
  });

  test("Verify exception is thrown if root/android/build.gradle does not exist", () {

    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wbf1")
      ..createSync(recursive: true);

    final android = Directory("${root.path}${s}android")
      ..createSync(recursive: true);

    expect(() => writeBuildGradleFile(
        pluginVersion: pluginVersion,
        packageName: packageName,
        pathToAndroid: android.path,
    ), throwsA(predicate((e) =>
        e is KlutterException &&
        e.cause.startsWith("Missing build.gradle file in folder:"))));

    root.deleteSync(recursive: true);

  });

  test("Verify build.gradle content is overwritten", () {

    // Create root/android otherwise path does not exist exception is thrown
    final root = Directory("${Directory.systemTemp.path}${s}wbf2")
      ..createSync(recursive: true);

    final android = Directory("${root.path}${s}android")
      ..createSync(recursive: true);

    final buildGradle = File("${android.path}${s}build.gradle")
      ..createSync()
      ..writeAsString("====");

    writeBuildGradleFile(
      pluginVersion: pluginVersion,
      packageName: packageName,
      pathToAndroid: android.path,
    );

    expect(buildGradle.readAsStringSync().replaceAll(" ", ""), '''
        group 'dev.buijs.klutter.example_plugin'
        version '1.0.0'
        
        buildscript {
        
            repositories {
                google()
                mavenCentral()
                maven { url = uri("https://repsy.io/mvn/buijs-dev/klutter") }
            }
        
            dependencies {
                classpath 'com.android.tools.build:gradle:7.0.4'
                classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.6.10"
                classpath "dev.buijs.klutter:core:2022-alpha-1"
            }
        }
        
        rootProject.allprojects {
            repositories {
                google()
                mavenCentral()
                maven { url = uri("https://repsy.io/mvn/buijs-dev/klutter") }
            }
        }
        
        apply plugin: 'com.android.library'
        apply plugin: 'kotlin-android'
        
        android {
            compileSdkVersion 31
        
            compileOptions {
                sourceCompatibility JavaVersion.VERSION_1_8
                targetCompatibility JavaVersion.VERSION_1_8
            }
        
            kotlinOptions {
                jvmTarget = '1.8'
            }
        
            sourceSets {
                main.java.srcDirs += 'src/main/kotlin'
            }
        
            defaultConfig {
                minSdkVersion 21
            }
        }
        
        dependencies {
            runtimeOnly "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.3.2"
            implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.6.10"
            implementation "dev.buijs.klutter:core:2022-alpha-1"
            implementation project(":klutter:example_plugin")
        }
        
        java {
            sourceCompatibility = JavaVersion.VERSION_1_8
            targetCompatibility = JavaVersion.VERSION_1_8
        }'''.replaceAll(" ", "")
    );

    root.deleteSync(recursive: true);

  });

  test("Verify exception is thrown if root/android does not exist", () {
    expect(() => writeAndroidPlugin(
        packageName: packageName,
        pathToAndroid: "fake"
    ), throwsA(predicate((e) =>
        e is KlutterException &&
        e.cause.startsWith("Path does not exist:") &&
        e.cause.endsWith("/fake"))));
  });

  test("Verify exception is thrown if root/android/src/main/kotlin does not exist", () {

    final root =  Directory("${Directory.systemTemp.path}${s}wag1")
      ..createSync(recursive: true);

    // Create root/android otherwise root/android path does not exist exception is thrown
    final android = Directory("${root.path}${s}android")
      ..createSync(recursive: true);

    expect(() => writeAndroidPlugin(
      packageName: packageName,
      pathToAndroid: android.path,
    ), throwsA(predicate((e) =>
        e is KlutterException &&
        e.cause.startsWith("Missing src/main/kotlin folder in:"))));

    root.deleteSync(recursive: true);
  });

  test("Verify exception is thrown if plugin folder does not exist", () {

    final root =  Directory("${Directory.systemTemp.path}${s}wag2")
      ..createSync(recursive: true);

    // Create root/android/src/main/kotlin otherwise
    // root/android/src/main/kotlin path does not exist exception is thrown
    final android = Directory("${root.path}${s}android")
      ..createSync(recursive: true);

    Directory("${android.path}/src/main/kotlin".replaceAll("/", s))
        .createSync(recursive: true);

    expect(() => writeAndroidPlugin(
      packageName: packageName,
      pathToAndroid: android.path,
    ), throwsA(predicate((e) =>
        e is KlutterException &&
        e.cause.startsWith("Missing Android plugin folder:"))));

    root.deleteSync(recursive: true);

  });

  test("Verify exception is thrown if plugin file does not exist", () {

    final root =  Directory("${Directory.systemTemp.path}${s}wag3")
      ..createSync(recursive: true);

    final android = Directory("${root.path}${s}android")
      ..createSync(recursive: true);

    Directory(
        "${android.path}/src/main/kotlin/dev/buijs/klutter/example_plugin"
            .replaceAll("/", s)
    ).createSync(recursive: true);

    expect(() => writeAndroidPlugin(
      packageName: packageName,
      pathToAndroid: android.path,
    ), throwsA(predicate((e) =>
    e is KlutterException &&
        e.cause.startsWith("Missing Android plugin file:"))));

    root.deleteSync(recursive: true);

  });

  test("Verify plugin class content is overwritten", () {

    final root =  Directory("${Directory.systemTemp.path}${s}wag4")
      ..createSync(recursive: true);

    final android = Directory("${root.path}${s}android")
      ..createSync(recursive: true);

    final pluginClass = File(
      "${android.path}/src/main/kotlin/dev/buijs/klutter/example_plugin/ExamplePluginPlugin"
          .replaceAll("/", s),
    )..createSync(recursive: true);

    writeAndroidPlugin(
      packageName: packageName,
      pathToAndroid: android.path,
    );

    expect(pluginClass.readAsStringSync().replaceAll(" ", ""), '''
        package dev.buijs.klutter.example_plugin
        
        import dev.buijs.klutter.template.Greeting
        import androidx.annotation.NonNull
        
        import io.flutter.embedding.engine.plugins.FlutterPlugin
        import io.flutter.plugin.common.MethodCall
        import io.flutter.plugin.common.MethodChannel
        import io.flutter.plugin.common.MethodChannel.MethodCallHandler
        import io.flutter.plugin.common.MethodChannel.Result
        import kotlinx.coroutines.CoroutineScope
        import kotlinx.coroutines.Dispatchers
        import kotlinx.coroutines.launch
        
        /** ExamplePluginPlugin */
        class ExamplePluginPlugin: FlutterPlugin, MethodCallHandler {
          // The MethodChannel that will the communication between Flutter and native Android
          //
          // This local reference serves to register the plugin with the Flutter Engine and unregister it
          // when the Flutter Engine is detached from the Activity
          private lateinit var channel : MethodChannel
           
          private val mainScope = CoroutineScope(Dispatchers.Main) 
           
          override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
            channel = MethodChannel(flutterPluginBinding.binaryMessenger, "example_plugin")
            channel.setMethodCallHandler(this)
          }
        
          override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
                mainScope.launch {
                 when (call.method) {
                   "greeting" -> {
                     result.success(Greeting().greeting())
                   } 
                   else -> result.notImplemented()
                   }
                }
          }
        
          override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
            channel.setMethodCallHandler(null)
          }
        }'''.replaceAll(" ", "")
    );

  });
}
