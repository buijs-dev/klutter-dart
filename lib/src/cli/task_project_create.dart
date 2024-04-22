// Copyright (c) 2021 - 2024 Buijs Software
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
import "cli.dart";
import "context.dart";

/// Task
class CreateProject extends Task {
  /// Create new Task.
  CreateProject({Executor? executor})
      : super(TaskName.create, {
          TaskOption.name: const PluginNameOption(),
          TaskOption.group: GroupNameOption(),
          TaskOption.flutter: FlutterVersionOption(),
          TaskOption.root: RootDirectoryInput(),
          TaskOption.klutter: const KlutterPubVersion(),
          TaskOption.klutterui: const KlutteruiPubVersion(),
          TaskOption.bom: const KlutterGradleVersionOption(),
          TaskOption.squint: const SquintPubVersion(),
        }) {
    _executor = executor ?? Executor();
  }

  late final Executor _executor;

  @override
  Future<void> toBeExecuted(
      Context context, Map<TaskOption, dynamic> options) async {
    final pathToRoot = findPathToRoot(context, options);
    final name = options[TaskOption.name];
    final group = options[TaskOption.group];
    final flutterVersion =
        options[TaskOption.flutter] as VerifiedFlutterVersion;

    final dist = toFlutterDistributionOrThrow(
        version: flutterVersion, pathToRoot: pathToRoot);

    final flutterFromCache = Directory(pathToRoot.normalize)
        .kradleCache
        .resolveFolder("${dist.folderNameString}")
        .resolveFile("flutter/bin/flutter".normalize);

    if(!flutterFromCache.existsSync()) {
      final task = GetFlutterSDK();
      final taskResult = await task.execute(context);
      if(!taskResult.isOk) {
        throw KlutterException(taskResult.message ?? "failed to get flutter sdk");
      }
    }

    final flutter = flutterFromCache.absolutePath;
    final root = Directory(pathToRoot.normalize).resolveFolder(name);

    _executor
      ..executable = flutter
      ..workingDirectory = Directory(pathToRoot)
      ..arguments = [
        "create",
        name,
        "--org",
        group,
        "--template=plugin",
        "--platforms=android,ios",
      ]
      ..run();

    root.verifyFolderExists;

    final rootPubspecFile = root.resolveFile("pubspec.yaml")..verifyExists;

    final exampleFolder = root.resolveFolder("example")..verifyFolderExists;

    final examplePubspecFile = exampleFolder.resolveFile("pubspec.yaml")
      ..verifyExists;

    final flutterSDK = dist.folderNameString.source;

    final bomVersion = options[TaskOption.bom];
    final klutterVersion = options[TaskOption.klutter];
    final klutterUIVersion = options[TaskOption.klutterui];
    final squintVersion = options[TaskOption.squint];

    rootPubspecFile.writeRootPubspecYaml(
      pluginName: name,
      androidPluginPackage: "$group.$name",
      androidPluginClass: toPluginClassName(name, postfixWithPlugin: true),
      iosPluginClass: toPluginClassName(name, postfixWithPlugin: true),
      squintVersion: squintVersion,
      klutterUiVersion: klutterUIVersion,
      klutterVersion: klutterVersion,
    );

    examplePubspecFile.writeExamplePubspecYaml(
      pluginName: name,
      squintVersion: squintVersion,
      klutterUiVersion: klutterUIVersion,
      klutterVersion: klutterVersion,
    );

    root
      ..deleteTestFolder
      ..clearLibFolder
      ..overwriteReadmeFile(name)
      ..copyLocalProperties;

    _executor
      ..executable = flutter
      ..workingDirectory = root
      ..arguments = ["pub", "get"]
      ..run()
      ..workingDirectory = exampleFolder
      ..run()
      ..workingDirectory = root
      ..arguments = [
        "pub",
        "run",
        "klutter:kradle",
        "init",
        "bom=$bomVersion",
        "flutter=$flutterSDK"
      ]
      ..run()
      ..workingDirectory = exampleFolder
      ..arguments = ["pub", "run", "klutter:kradle", "init"]
      ..run()
      ..arguments = ["pub", "run", "klutter:kradle", "add", "lib=$name"]
      ..run();

    exampleFolder
      ..deleteTestFolder
      ..deleteIntegrationTestFolder;

    if (platform.isMacos) {
      exampleFolder
        ..deleteIosPodfileLock
        ..deleteIosPods
        ..deleteRunnerXCWorkspace;

      final iosWorkingDirectory = root
          .resolveFolder("example")
          .resolveFolder("ios")
        ..verifyFolderExists;

      for (final step in ["install", "update"]) {
        _executor
          ..executable = "pod"
          ..workingDirectory = iosWorkingDirectory
          ..arguments = [step]
          ..run();
      }
    }
  }
}

extension on File {
  void writeRootPubspecYaml({
    required String pluginName,
    required String squintVersion,
    required String klutterUiVersion,
    required String klutterVersion,
    required String androidPluginPackage,
    required String androidPluginClass,
    required String iosPluginClass,
  }) {
    if (existsSync()) {
      deleteSync();
    }

    createSync();
    writeAsStringSync("""
name: $pluginName
|description: A new klutter plugin project.
|version: 0.0.1
|
|environment:
|  sdk: '>=2.17.6 <4.0.0'
|  flutter: ">=2.5.0"
|
|dependencies:
|  flutter:
|    sdk: flutter
|
${_toDependencyNotation(squintVersion, "squint_json")}
|
${_toDependencyNotation(klutterUiVersion, "klutter_ui")}
|
|  protobuf: ^3.1.0
|
|dev_dependencies:
${_toDependencyNotation(klutterVersion, "klutter")}
|
|flutter:
|  plugin:
|    platforms:
|      android:
|        package: $androidPluginPackage
|        pluginClass: $androidPluginClass
|      ios:
|        pluginClass: $iosPluginClass
"""
        .format);
  }

  void writeExamplePubspecYaml({
    required String pluginName,
    required String squintVersion,
    required String klutterUiVersion,
    required String klutterVersion,
  }) {
    if (existsSync()) {
      deleteSync();
    }

    createSync();
    writeAsStringSync("""
name: ${pluginName}_example
|description: Demonstrates how to use the $pluginName plugin
|publish_to: 'none' # Remove this line if you wish to publish to pub.dev
|environment:
|  sdk: '>=2.17.6 <4.0.0'
|
|dependencies:
|  flutter:
|    sdk: flutter
|  $pluginName:
|    path: ../
|
${_toDependencyNotation(squintVersion, "squint_json")}
|
${_toDependencyNotation(klutterUiVersion, "klutter_ui")}
|
|dev_dependencies:
|  flutter_test:
|    sdk: flutter
|
${_toDependencyNotation(klutterVersion, "klutter")}
|
|flutter:
|  uses-material-design: true
"""
        .format);
  }
}

/// Pattern used to get a pubspec dependency from Git.
///
/// This pattern should be used in the kradle.yaml file.
///
/// Example notation: 'https://github.com/your-repo.git@develop'.
RegExp _gitDependencyRegex = RegExp(r"""^(https:..github.com.+?git)@(.+$)""");

/// Pattern used to get a pubspec dependency from local path.
///
/// This pattern should be used in the kradle.yaml file.
///
/// Example notation: 'local@foo/bar/dependency-name'.
RegExp _pathDependencyRegex = RegExp(r"""(^local)@(.+$)""");

String _toDependencyNotation(String dependency, String name) {
  if (_gitDependencyRegex.hasMatch(dependency)) {
    return _toGitDependencyNotation(dependency, name);
  } else if (_pathDependencyRegex.hasMatch(dependency)) {
    return _toPathDependencyNotation(dependency, name);
  } else {
    return "|  $name: ^$dependency";
  }
}

String _toGitDependencyNotation(String dependency, String name) {
  final splitted = dependency.split("@");
  return """
|  $name:
|    git:
|      url: ${splitted[0]}
|      ref: ${splitted[1]}
""";
}

String _toPathDependencyNotation(String dependency, String name) {
  final splitted = dependency.split("@");
  return """
|  $name:
|    path: ${splitted[1]}
""";
}

extension on Directory {
  void get deleteTestFolder {
    resolveFolder("test").deleteSync(recursive: true);
  }

  void get deleteIntegrationTestFolder {
    resolveFolder("integration_test").deleteSync(recursive: true);
  }

  void get clearLibFolder {
    resolveFolder("lib").listSync(recursive: true).forEach((fse) {
      if (fse is File) {
        fse.deleteSync();
      }
    });
  }

  void get deleteIosPodfileLock {
    resolveFolder("ios").resolveFile("Podfile.lock").maybeDelete;
  }

  void get deleteIosPods {
    resolveFolder("ios").resolveFolder("Pods").maybeDelete;
  }

  void get deleteRunnerXCWorkspace {
    resolveFolder("ios").resolveFolder("Runner.xcworkspace").maybeDelete;
  }

  void overwriteReadmeFile(String pluginName) {
    final readme = resolveFile("README.md");

    // Seems redundant to delete and then recreate the README.md file.
    // However, the project is created by invoking the Flutter version
    // installed by the end-user. Future versions of Flutter might not
    // Create a README.md file but a readme.md, PLEASE_README.md or not
    // a readme file at all!
    //
    // In that case this code won't try to delete a file that does not
    // exist and only create a new file. We do NOT want the task to fail
    // because of a README.md file. :-)
    if (readme.existsSync()) {
      readme.deleteSync();
    }

    readme
      ..createSync()
      ..writeAsStringSync("""
                |# $pluginName
                |A new Klutter plugin project.
                |Klutter is a framework which interconnects Flutter and Kotlin Multiplatform.
                |
                |## Getting Started
                |This project is a starting point for a Klutter
                |[plug-in package](https://github.com/buijs-dev/klutter),
                |a specialized package that includes platform-specific implementation code for
                |Android and/or iOS.
                |
                |This platform-specific code is written in Kotlin programming language by using
                |Kotlin Multiplatform.
            """
          .format);
  }

  void get copyLocalProperties {
    final properties = resolveFile("local.properties");
    if (!properties.existsSync()) {
      resolveFile("android/local.properties".normalize)
          .copySync(properties.absolutePath);
    }
  }
}
