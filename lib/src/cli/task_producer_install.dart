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

import "package:dart_style/dart_style.dart";

import "../common/exception.dart";
import "../common/project.dart";
import "../common/utilities.dart";
import "../consumer/android.dart";
import "cli.dart";

/// Tasks do perform project installation (code or artifact generation).
///
/// {@category producer}
class ProducerInstall extends Task {
  /// Create new Task based of the root folder.
  ProducerInstall() : super(ScriptName.producer, TaskName.install);

  /// Run a task depending on the given option value.
  ///
  /// Valid options:
  /// - platform
  /// - library
  ///
  /// Throws [KlutterException] if option is null or invalid.
  @override
  void toBeExecuted(String pathToRoot) {
    switch (option) {
      case "platform":
        _installPlatform(pathToRoot);
        break;
      case "library":
        _installLibrary(pathToRoot);
        break;
      case "":
        throw KlutterException("Missing option value for task 'install'");
      default:
        throw KlutterException("Invalid option value: '$option'");
    }
  }

  @override
  List<String> optionValues() => ["platform", "library"];
}

/// Run Gradle task klutterGenerateAdapters
/// which creates dart code in the lib folder.
void _installLibrary(String pathToRoot) {
  final pathToLib = Directory("$pathToRoot${Platform.pathSeparator}lib")
      .absolutePath
      .verifyExists;

  final pluginName = findPluginName(pathToRoot);

  final result = Process.runSync(
    "./gradlew",
    ["klutterGenerateAdapters"],
    workingDirectory: pathToRoot,
  );

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  final pluginFile = File("$pathToLib/$pluginName.dart").verifyExists;
  final formatted = DartFormatter().format(pluginFile.readAsStringSync());
  pluginFile.writeAsString(formatted);
}

/// Run Gradle task klutterInstallPlatform
/// which compiles the Kotlin Multiplatform module
/// and copies artifacts for iOS and Android
/// to the Flutter plugin project.
void _installPlatform(String pathToRoot) {
  final pathToAndroid = "$pathToRoot/android".normalize;

  final androidSdkLocation = findAndroidSDK(pathToAndroid);

  final result = Process.runSync(
    "./gradlew",
    ["klutterInstallPlatform"],
    workingDirectory: pathToRoot,
    environment: {"ANDROID_SDK_ROOT": androidSdkLocation},
  );

  stdout.write(result.stdout);
  stderr.write(result.stderr);
}
