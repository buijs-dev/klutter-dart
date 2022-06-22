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
import "../common/shared.dart";

const _klutterPluginLoaderGradleFile = "klutter_plugin_loader.gradle.kts";

/// Get the path to the local Flutter SDK installation
/// as configured in the root-project/android/local.properties folder.
///
/// Either:
/// - throws [KlutterException] if unsuccessful or
/// - returns [String] path to Flutter SDK installation.
String findFlutterSDK(String pathToAndroid) =>
    pathToAndroid.verifyExists.toPropertiesFile.read.property("flutter.sdk");

/// Generate a new gradle file in the flutter/tools/gradle folder
/// which will apply Klutter plugins to a Flutter project.
void writePluginLoaderGradleFile(String pathToFlutterSDK) => pathToFlutterSDK
    .verifyExists
    .createFlutterToolsFolder
    .absolutePath
    .createPluginLoaderGradleFile
    .writeGradleContent;

/// Update Android SDK version constraints in the root/android/build.gradle file.
///
/// Sets the following properties in the build.gradle android DSL block:
///
/// - compileSdkVersion to [androidCompileSdk]
/// - minSdkVersion to [androidMinSdk]
/// - targetSdkVersion to [androidTargetSdk]
void setAndroidSdkConstraints(String pathToAndroid) =>
    pathToAndroid.verifyExists.toBuildGradleFile.setAndroidSdkVersions;

/// Add apply plugin line to android/settings.gradle file.
void applyPluginLoader(String pathToAndroid) =>
    pathToAndroid.verifyExists.toSettingsGradleFile.appendSettingsGradle;

extension on String {
  /// Create a path to the root-project/android/local.properties file.
  /// If the file does not exist throw a [KlutterException].
  File get toPropertiesFile => File("${this}/local.properties").normalizeToFile
    ..ifNotExists((_) => throw KlutterException(
        "Missing local.properties file in folder: ${this}"));

  /// Create a path to the settings.gradle file.
  /// If the file does not exist throw a [KlutterException].
  File get toSettingsGradleFile => File("${this}/settings.gradle".normalize)
    ..ifNotExists((_) => throw KlutterException(
        "Missing settings.gradle file in folder: ${this}"));

  /// Create a path to the build.gradle file.
  /// If the file does not exist throw a [KlutterException].
  File get toBuildGradleFile => File("${this}/build.gradle".normalize)
    ..ifNotExists((_) =>
        throw KlutterException("Missing build.gradle file in folder: ${this}"));

  /// Create a path to the flutter/tools/gradle/klutter_plugin_loader.gradle.kts file.
  /// If the file does not exist create it.
  File get createPluginLoaderGradleFile =>
      File("${this}/$_klutterPluginLoaderGradleFile").normalizeToFile
        ..ifNotExists((file) => File(file.absolutePath).createSync());

  /// Create a path to flutter/tools/gradle folder.
  /// If the folder does not exist create it.
  Directory get createFlutterToolsFolder =>
      Directory("${this}/packages/flutter_tools/gradle".normalize)
        ..ifNotExists((folder) =>
            Directory(folder.absolutePath).createSync(recursive: true));

  String setAndroidSdkVersion(String versionType, int version) {
    final newContent = replaceAllMapped(RegExp("($versionType.+)"), (match) {
      return "$versionType $version";
    });

    if (newContent.contains("$versionType $version")) {
      return newContent;
    }

    throw KlutterException(
      """
          |Failed to set '$versionType' in the root/android/build.gradle file.
          |Check if the android DSL block in root/android/build.gradle file contains the following lines:
          |
          |compileSdkVersion $androidCompileSdk
          |
          |defaultConfig {
          |   ...
          |   minSdkVersion $androidMinSdk
          |   targetSdkVersion $androidTargetSdk
          |   ...
          |}
          """
          .format,
    );
  }
}

extension on File {
  /// Read the content of a properties File and
  /// return a Map<String, String> with property key and property value.
  Map<String, String> get read => readAsLinesSync()
      .map((line) => line.split("="))
      .where((line) => line.length == 2)
      .map((line) => line.map((e) => e.trim()).toList())
      .fold({}, (properties, line) => properties..addAll({line[0]: line[1]}));

  /// Write the content of the [_klutterPluginLoaderGradleFile] which configures
  /// the Klutter made plugins in a Flutter project.
  void get writeGradleContent {
    writeAsStringSync(r'''
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
            |
            |import java.io.File
            |
            |val flutterProjectRoot = rootProject.projectDir.parentFile
            |val pluginsFile = File("$flutterProjectRoot/.klutter-plugins")
            |if (pluginsFile.exists()) {
            |  val plugins = pluginsFile.readLines().forEach { line ->
            |    val plugin = line.split("=").also {
            |      if(it.size != 2) throw GradleException("""
            |        Invalid Klutter plugin config.
            |        Check the .klutter-plugins file in the project root folder.
            |        Required format is: ':klutter:libraryname=local/path/to/flutter/cache/library/artifacts/android'
            |      """.trimIndent())
            |    }
            |
            |    val pluginDirectory = File(plugin[1]).also {
            |      if(!it.exists()) throw GradleException("""
            |        Invalid path for Klutter plugin: '$it'.
            |        Check the .klutter-plugins file in the project root folder.
            |      """.trimIndent())
            |    }
            |
            |    include(plugin[0])
            |    project(plugin[0]).projectDir = pluginDirectory
            |
            |  }
            |}'''
        .format);
  }

  /// Add the following line to the settings.gradle file if not present:
  /// ```
  ///   apply from: "$flutterSdkPath/packages/flutter_tools/gradle/klutter_plugin_loader.gradle.kts"
  /// ```
  ///
  /// The flutterSdkPath variable is based of line generated by Flutter:
  /// ```
  /// apply from: "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"
  /// ```
  ///
  ///
  /// For example given this line in the settings.gradle file:
  /// ```
  /// apply from: "$someothervar/app_plugin_loader.gradle"
  /// ```
  ///
  /// Then this line will be added:
  /// ```
  /// apply from: "$someothervar/klutter_plugin_loader.gradle"
  /// ```
  void get appendSettingsGradle {
    // Do nothing if the plugin is already applied.
    if (readAsStringSync().contains(_klutterPluginLoaderGradleFile)) {
      return;
    }

    // Will be set to true if a line containing
    // 'app_plugin_loader.gradle' and keyword 'apply' is found.
    var hasLoader = false;

    final lines = readAsLinesSync().map((line) {
      final hasPluginLoader =
          line.contains("apply") && line.contains("app_plugin_loader.gradle");

      if (hasPluginLoader) {
        hasLoader = true;
        return "$line\n${line.replaceAll('app_plugin_loader.gradle', _klutterPluginLoaderGradleFile)}";
      } else {
        return line;
      }
    }).toList();

    if (!hasLoader) {
      // If the klutter_plugin_loader.gradle.kts is not applied
      // then throw exception because
      // no plugin made with Klutter will work without it.
      throw KlutterException(
        r'''
        |Failed to apply Klutter plugin loader.
        |Check if the root/android/settings.gradle file contains the following line:
        |'apply from: "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"'
        |     
        |Either add the line and retry or manually add the following line:
        |'apply from: "$flutterSdkPath/packages/flutter_tools/gradle/$_klutterPluginLoaderGradleFile"'
        '''
            .format,
      );
    }

    writeAsStringSync(lines.join("\n"));
  }

  /// Update Android SDK version constraints in the root/android/build.gradle file.
  ///
  /// Sets the following properties in the build.gradle android DSL block:
  ///
  /// - compileSdkVersion to [androidCompileSdk]
  /// - minSdkVersion to [androidMinSdk]
  /// - targetSdkVersion to [androidTargetSdk]
  void get setAndroidSdkVersions {
    final buildGradleText = readAsStringSync()
        .setAndroidSdkVersion("compileSdkVersion", androidCompileSdk)
        .setAndroidSdkVersion("minSdkVersion", androidMinSdk)
        .setAndroidSdkVersion("targetSdkVersion", androidTargetSdk);

    deleteSync();
    createSync();
    writeAsStringSync(buildGradleText);
  }
}

extension on Map<String, String> {
  /// Get property (uppercase) from key-value map or throw [KlutterException] if not present.
  String property(String key) => containsKey(key)
      ? this[key]!
      : throw KlutterException(
          "Missing property '$key' in local.properties file.",
        );
}
