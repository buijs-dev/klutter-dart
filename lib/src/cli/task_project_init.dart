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

import '../common/common.dart';
import '../consumer/consumer.dart';
import "../common/exception.dart";
import "../common/project.dart";
import "cli.dart";
import "dart:io";

import "../consumer/android.dart";
import "../producer/android.dart";
import "../producer/gradle.dart";
import "../producer/ios.dart";
import "../producer/kradle.dart";
import "../producer/platform.dart";
import "../producer/project.dart";
import "context.dart";

/// Task to prepare a flutter project for using klutter plugins.
///
/// {@category consumer}
/// {@category producer}
class ProjectInit extends Task {
  /// Create new Task based of the root folder.
  ProjectInit()
      : super(TaskName.init, {
          TaskOption.bom: const KlutterGradleVersionOption(),
          TaskOption.flutter: FlutterVersionOption(),
          TaskOption.root: RootDirectoryInput(),
        });

  @override
  Future<void> toBeExecuted(
      Context context, Map<TaskOption, dynamic> options) async {
    final pathToRoot = findPathToRoot(context, options);
    bool isProducerProject;
    try {
      // will throw exception if unable to find
      // the package name which means this is not
      // a producer project.
      findPackageName(pathToRoot);
      isProducerProject = true;
    } on KlutterException {
      isProducerProject = false;
    }

    if (isProducerProject) {
      final bom = options[TaskOption.bom];
      final flutter = options[TaskOption.flutter] as VerifiedFlutterVersion;
      await _producerInit(pathToRoot, bom, flutter);
      _consumerInit("$pathToRoot/example".normalize);
    } else {
      _consumerInit(pathToRoot);
    }
  }
}

void _consumerInit(String pathToRoot) {
  final pathToAndroid = "$pathToRoot/android".normalize;
  final sdk = findFlutterSDK(pathToAndroid);
  final app = "$pathToAndroid/app".normalize;
  writePluginLoaderGradleFile(sdk);
  createRegistry(pathToRoot);
  applyPluginLoader(pathToAndroid);
  setAndroidSdkConstraints(app);
  setKotlinVersionInBuildGradle(pathToAndroid);
}

Future<void> _producerInit(
    String pathToRoot, String bom, VerifiedFlutterVersion flutter) async {
  final producer = _Producer(
      pathToRoot: pathToRoot,
      bomVersion: bom,
      flutterVersion: flutter.version.prettyPrint);
  await producer.addGradle;
  await producer.addKradle;
  producer
    ..setupRoot
    ..setupAndroid
    ..setupIOS
    ..setupPlatform
    ..setupExample;
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
      ..normalizeToDirectory.maybeDelete
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
