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

// ignore_for_file: avoid_print

import "dart:io";

import "../common/common.dart";
import "../consumer/android.dart";
import "../consumer/consumer.dart";
import "../producer/android.dart";
import "../producer/gradle.dart";
import "../producer/ios.dart";
import "../producer/kradle.dart";
import "../producer/platform.dart";
import "../producer/project.dart";
import "cli.dart";
import "context.dart";

const _resourceZipUrl =
    "https://github.com/buijs-dev/klutter-dart/raw/develop/resources.zip";

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
    print("initializing klutter project: $pathToRoot");
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
      print("initializing klutter project as producer");
      final bom = options[TaskOption.bom];
      final flutter = options[TaskOption.flutter] as VerifiedFlutterVersion;
      await _producerInit(pathToRoot, bom, flutter);
      _consumerInit("$pathToRoot/example".normalize);
    } else {
      print("initializing klutter project as consumer");
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
  final resources = await _downloadResourcesZipOrThrow(pathToRoot);
  final producer = _Producer(
      resourcesDirectory: resources,
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

/// Download [_resourceZipUrl] and return the unzipped directory.
Future<Directory> _downloadResourcesZipOrThrow(String pathToRoot) async {
  final cache = Directory(pathToRoot.normalize).kradleCache..maybeCreate;
  final target = cache.resolveDirectory("init.resources");
  final zip = target.resolveFile("resources.zip")
    ..maybeDelete
    ..createSync(recursive: true);
  await downloadOrThrow(_resourceZipUrl, zip, target);

  if (!target.existsSync()) {
    throw const KlutterException("Failed to download resources.zip");
  }

  if (target.isEmpty) {
    throw const KlutterException(
        "Failed to download resources (no content found)");
  }

  return target;
}

/// Download the flutter sdk or throw [KlutterException] on failure.
Future<void> downloadOrThrow(
    String endpoint, File zip, Directory target) async {
  print("resources download started: $endpoint");
  await download(endpoint, zip);
  if (zip.existsSync()) {
    await unzip(zip, target..maybeCreate);
    zip.deleteSync();
  }

  if (!target.existsSync()) {
    throw const KlutterException("Failed to download resources");
  }

  print("resources download finished: ${target.absolutePath}");
}

class _Producer {
  _Producer(
      {required this.resourcesDirectory,
      required this.bomVersion,
      required this.flutterVersion,
      required this.pathToRoot});

  final Directory resourcesDirectory;
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
    final gradle = Gradle(pathToRoot, resourcesDirectory);
    await Future.wait([
      gradle.copyToRoot,
      gradle.copyToAndroid,
    ]);
  }

  Future<void> get addKradle async {
    await Future.wait([Kradle(pathToRoot, resourcesDirectory).copyToRoot]);
  }
}
