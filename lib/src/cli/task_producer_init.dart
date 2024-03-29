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

import "../common/common.dart";
import "../consumer/android.dart";
import "../producer/android.dart";
import "../producer/gradle.dart";
import "../producer/ios.dart";
import "../producer/kradle.dart";
import "../producer/platform.dart";
import "../producer/project.dart";
import "cli.dart";
import "task_get_flutter.dart";

/// Task to run project initialization (setup).
///
/// {@category producer}
class ProducerInit extends Task {
  /// Create new Task based of the root folder.
  ProducerInit() : super(ScriptName.producer, TaskName.init);

  @override
  Future<void> toBeExecuted(String pathToRoot) async {
    final validBomVersionOrNull = options[ScriptOption.bom]?.verifyBomVersion;

    if (validBomVersionOrNull == null) {
      throw KlutterException(
          "Invalid BOM version (example of correct version: $klutterGradleVersion): $validBomVersionOrNull");
    }

    final flutterVersion =
        options[ScriptOption.flutter]?.verifyFlutterVersion?.version;

    if (flutterVersion == null) {
      throw KlutterException(
          "Invalid Flutter version (supported versions are: $supportedFlutterVersions): $flutterVersion");
    }

    final producer = _Producer(
        pathToRoot: pathToRoot,
        bomVersion: validBomVersionOrNull,
        flutterVersion: flutterVersion);
    await producer.addGradle;
    await producer.addKradle;
    producer
      ..setupRoot
      ..setupAndroid
      ..setupIOS
      ..setupPlatform
      ..setupExample;
  }

  @override
  List<String> exampleCommands() => [
        "producer init",
        "producer init bom=<version> (default is $klutterGradleVersion)",
        "producer init flutter=<version> (default is $klutterFlutterVersion)",
        "producer init flutter=<version> bom=<version>",
      ];

  @override
  List<Task> dependsOn() => [GetFlutterSDK()];
}

class _Producer {
  _Producer(
      {required this.bomVersion,
      required this.flutterVersion,
      required this.pathToRoot});

  final String bomVersion;
  final String flutterVersion;
  final String pathToRoot;
}

extension on _Producer {
  void get setupRoot {
    Directory("$pathToRoot/lib".normalize)
      // Delete folder and all children if they exist.
      ..normalizeToFolder.maybeDelete
      // Create a new empty lib folder.
      ..maybeCreate;

    final name = findPluginName(pathToRoot);
    writeGradleProperties(pathToRoot);

    writeRootBuildGradleFile(
        pathToRoot: pathToRoot,
        pluginName: name,
        klutterBomVersion: bomVersion);

    writeRootSettingsGradleFile(
      pathToRoot: pathToRoot,
      pluginName: name,
    );
  }

  void get setupAndroid {
    final packageName = findPackageName(pathToRoot);
    final pluginVersion = findPluginVersion(pathToRoot);
    final pathToAndroid = "$pathToRoot/android".normalize;
    final pluginName = findPluginName(pathToRoot);

    writeBuildGradleFile(
        pluginName: pluginName,
        pathToAndroid: pathToAndroid,
        packageName: packageName,
        pluginVersion: pluginVersion,
        klutterBomVersion: bomVersion);

    writeAndroidPlugin(
      pathToAndroid: pathToAndroid,
      packageName: packageName,
      pluginName: pluginName,
    );

    writeKlutterGradleFile(pathToAndroid);
    setGradleWrapperVersion(pathToAndroid: pathToAndroid);
    deleteRootAndroidManifestFile(pathToAndroid: pathToAndroid);
  }

  void get setupPlatform {
    createPlatformModule(
      pathToRoot: pathToRoot,
      pluginName: findPluginName(pathToRoot),
      packageName: findPackageName(pathToRoot),
    );
  }

  void get setupExample {
    final packageName = findPackageName(pathToRoot);
    final pluginName = findPluginName(pathToRoot);
    final pathToAndroid = "$pathToRoot/example/android".normalize;

    writeExampleMainDartFile(
      pathToExample: "$pathToRoot/example".normalize,
      pluginName: pluginName,
    );

    writeAndroidAppBuildGradleFile(
        pathToAndroid: pathToAndroid,
        packageName: packageName,
        pluginName: pluginName);

    writeAndroidBuildGradleFile(
        pathToAndroid: pathToAndroid,
        packageName: packageName,
        pluginName: pluginName);

    setGradleWrapperVersion(pathToAndroid: pathToAndroid);
  }

  void get setupIOS {
    final pathToIos = "$pathToRoot/ios";
    createIosKlutterFolder(pathToIos);
    addFrameworkToPodspec(
      pathToIos: "$pathToRoot/ios",
      pluginName: findPluginName(pathToRoot),
    );
  }

  Future<void> get addGradle async {
    final gradle = Gradle(pathToRoot);
    await Future.wait([
      gradle.copyToRoot,
      gradle.copyToAndroid,
    ]);
  }

  Future<void> get addKradle async {
    await Future.wait([Kradle(pathToRoot).copyToRoot]);
  }
}
