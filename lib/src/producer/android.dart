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

import "../common/config.dart";
import "../common/exception.dart";
import "../common/project.dart";
import "../common/utilities.dart";

/// Overwrite the build.gradle file in the root/android folder.
///
/// {@category producer}
void writeBuildGradleFile({
  required String pathToAndroid,
  required String packageName,
  required String pluginVersion,
}) =>
    pathToAndroid.verifyExists.toBuildGradleFile.configure
      ..packageName = packageName
      ..version = pluginVersion
      ..writeBuildGradleContent;

/// Overwrite the method channel Kotlin Class in src/main/kotlin.
///
/// {@category producer}
void writeAndroidPlugin({
  required String pathToAndroid,
  required String packageName,
}) =>
    pathToAndroid.verifyExists.toKotlinSourcePackage.configure
      ..packageName = packageName
      ..writePluginContent;

/// Create the android/klutter folder if it does not exist.
///
/// {@category producer}
void writeKlutterGradleFile(String pathToAndroid) =>
    pathToAndroid.verifyExists.toKlutterFolder..writeAndroidGradleFile;

extension on FileSystemEntity {
  _Configuration get configure => _Configuration(this);
}

extension on String {
  /// Create a path to the settings.gradle file.
  /// If the file does not exist throw a [KlutterException].
  File get toBuildGradleFile => File("${this}/build.gradle".normalize)
    ..ifNotExists((_) =>
        throw KlutterException("Missing build.gradle file in folder: ${this}"));

  /// Create a path to the src/main/kotlin folder.
  /// If the file does not exist throw a [KlutterException].
  Directory get toKotlinSourcePackage => Directory(
      "${this}/src/main/kotlin".normalize)
    ..ifNotExists((_) =>
        throw KlutterException("Missing src/main/kotlin folder in: ${this}"));

  /// Create a path to the android/klutter folder.
  /// If the file does not exist then create it.
  Directory get toKlutterFolder =>
      Directory("${this}/klutter".normalize)..maybeCreate;
}

extension on Directory {
  /// Create build.gradle.kts file in the android folder.
  void get writeAndroidGradleFile {
    File("${absolute.path}/build.gradle.kts".normalize)
      ..maybeCreate
      ..writeAsStringSync("""
          configurations.maybeCreate("default")
          |artifacts.add("default", file("platform.aar"))
      """
          .format);
  }
}

class _Configuration {
  _Configuration(this.file);

  final FileSystemEntity file;

  late final String packageName;

  late final String version;

  /// Write the boilerplate code in
  /// root/android/src/main/kotlin/<package>/<PackageNamePlugin>.
  void get writePluginContent {
    final pluginPath = Directory(
        "${file.absolutePath}/${packageName.replaceAll(".", "/")}".normalize)
      ..ifNotExists((folder) => throw KlutterException(
          "Missing Android plugin folder: ${folder.absolutePath}"));

    /// The method channel name which is equal to the library name.
    ///
    /// Example:
    /// Given [packageName] 'com.example.super_awesome'
    /// will return [channelName] 'super_awesome'.
    final channelName = packageName.substring(packageName.lastIndexOf(".") + 1);

    /// The Kotlin plugin ClassName which is equal to the library name
    /// converted to camelcase + 'Plugin' postfix.
    final className = toPluginClassName(channelName, postfixWithPlugin: true);

    File("${pluginPath.absolutePath}/$className.kt").normalizeToFile
      ..ifNotExists((file) {
        throw KlutterException(
          "Missing Android plugin file: ${file.absolutePath}",
        );
      })
      ..writeAsStringSync('''
        package $packageName
        |
        |import dev.buijs.klutter.template.Greeting
        |import androidx.annotation.NonNull
        |
        |import io.flutter.embedding.engine.plugins.FlutterPlugin
        |import io.flutter.plugin.common.MethodCall
        |import io.flutter.plugin.common.MethodChannel
        |import io.flutter.plugin.common.MethodChannel.MethodCallHandler
        |import io.flutter.plugin.common.MethodChannel.Result
        |import kotlinx.coroutines.CoroutineScope
        |import kotlinx.coroutines.Dispatchers
        |import kotlinx.coroutines.launch
        |
        |/** $className */
        |class $className: FlutterPlugin, MethodCallHandler {
        |  // The MethodChannel that will the communication between Flutter and native Android
        |  //
        |  // This local reference serves to register the plugin with the Flutter Engine and unregister it
        |  // when the Flutter Engine is detached from the Activity
        |  private lateinit var channel : MethodChannel
        |   
        |  private val mainScope = CoroutineScope(Dispatchers.Main) 
        |   
        |  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        |    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "$channelName")
        |    channel.setMethodCallHandler(this)
        |  }
        |
        |  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        |        mainScope.launch {
        |         when (call.method) {
        |           "greeting" -> {
        |             result.success(Greeting().greeting())
        |           } 
        |           else -> result.notImplemented()
        |           }
        |        }
        |  }
        |
        |  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        |    channel.setMethodCallHandler(null)
        |  }
        |}'''
          .format);
  }

  /// Write the content of the root/android/build.gradle file.
  ///
  /// The settings file will include the platform project module
  /// and retrieve the required (Klutter) dependencies.
  void get writeBuildGradleContent {
    File(file.path).writeAsStringSync('''
        group '$packageName'
        |version '$version'
        |
        |buildscript {
        |
        |    repositories {
        |        google()
        |        mavenCentral()
        |        maven { url = uri("https://repsy.io/mvn/buijs-dev/klutter") }
        |    }
        |
        |    dependencies {
        |        classpath 'com.android.tools.build:gradle:7.0.4'
        |        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.6.10"
        |        classpath "dev.buijs.klutter:core:$klutterGradleVersion"
        |    }
        |}
        |
        |rootProject.allprojects {
        |    repositories {
        |        google()
        |        mavenCentral()
        |        maven { url = uri("https://repsy.io/mvn/buijs-dev/klutter") }
        |    }
        |}
        |
        |apply plugin: 'com.android.library'
        |apply plugin: 'kotlin-android'
        |
        |android {
        |    compileSdkVersion $androidCompileSdk
        |
        |    compileOptions {
        |        sourceCompatibility JavaVersion.VERSION_1_8
        |        targetCompatibility JavaVersion.VERSION_1_8
        |    }
        |
        |    kotlinOptions {
        |        jvmTarget = '1.8'
        |    }
        |
        |    sourceSets {
        |        main.java.srcDirs += 'src/main/kotlin'
        |    }
        |
        |    defaultConfig {
        |        minSdkVersion $androidMinSdk
        |    }
        |}
        |
        |dependencies {
        |    runtimeOnly "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.3.2"
        |    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.6.10"
        |    implementation "dev.buijs.klutter:core:$klutterGradleVersion"
        |    implementation project(":klutter:${packageName.substring(1 + packageName.lastIndexOf("."))}")
        |}
        |
        |java {
        |    sourceCompatibility = JavaVersion.VERSION_1_8
        |    targetCompatibility = JavaVersion.VERSION_1_8
        |}'''
        .format);
  }
}
