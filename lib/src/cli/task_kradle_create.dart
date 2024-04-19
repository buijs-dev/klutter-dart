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

/// Task
class CreateProject extends Task {
  /// Create new Task.
  CreateProject({Executor? executor})
      : super(ScriptName.kradle, TaskName.create) {
    _executor = executor ?? Executor();
  }

  late final Executor _executor;

  @override
  Future<void> toBeExecuted(String pathToRoot) async {
    final workingDirectory = _rootOrNull ?? Directory(pathToRoot);
    final name = _pluginName;
    final group = _groupName;
    final flutterVersion = _flutterVersion;

    final dist = toFlutterDistributionOrThrow(
        version: flutterVersion, pathToRoot: pathToRoot);
    final flutter = Directory(pathToRoot.normalize)
        .kradleCache
        .resolveFolder("${dist.folderNameString}")
        .resolveFile("flutter/bin/flutter".normalize)
        .absolutePath;

    final root = Directory(pathToRoot.normalize).resolveFolder(name);

    _executor
      ..executable = flutter
      ..workingDirectory = workingDirectory
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

    final bomVersion = _klutterGradleVersion;
    final klutterVersion = _klutterPubVersion;
    final klutterUIVersion = _klutteruiPubVersion;
    final squintVersion = _squintPubVersion;

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
        "klutter:producer",
        "init",
        "bom=$bomVersion",
        "flutter=$flutterSDK"
      ]
      ..run()
      ..workingDirectory = exampleFolder
      ..arguments = ["pub", "run", "klutter:consumer", "init"]
      ..run()
      ..arguments = ["pub", "run", "klutter:consumer", "add", "lib=$name"]
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

  VerifiedFlutterVersion get _flutterVersion {
    final flutter = options[ScriptOption.flutter] ?? "3.10.6";
    return flutter.verifyFlutterVersion ??
        (throw KlutterException(
            "Invalid Flutter version (supported versions are: ${supportedFlutterVersions.keys}): $flutter"));
  }

  Directory? get _rootOrNull {
    final opt = options[ScriptOption.root];
    if (opt == null) {
      return null;
    }

    return Directory(opt.normalize)..verifyFolderExists;
  }

  String get _pluginName {
    final opt = options[ScriptOption.name] ?? "my_plugin";

    if (!RegExp(r"""^[a-z][a-z0-9_]+$""").hasMatch(opt)) {
      throw KlutterException("PluginName error: Should only contain"
          " lowercase alphabetic, numeric and or _ characters"
          " and start with an alphabetic character ('my_plugin').");
    }

    return opt;
  }

  String get _groupName {
    final opt = options[ScriptOption.group] ?? "dev.buijs.klutter.example";

    if (!opt.contains(".")) {
      throw KlutterException(
          "GroupName error: Should contain at least 2 parts ('com.example').");
    }

    if (opt.contains("_.")) {
      throw KlutterException(
          "GroupName error: Characters . and _ can not precede each other.");
    }

    if (opt.contains("._")) {
      throw KlutterException(
          "GroupName error: Characters . and _ can not precede each other.");
    }

    if (!RegExp(r"""^[a-z][a-z0-9._]+[a-z]$""").hasMatch(opt)) {
      throw KlutterException(
          "GroupName error: Should be lowercase alphabetic separated by dots ('com.example').");
    }

    return opt;
  }

  String get _klutterPubVersion =>
      options[ScriptOption.klutter] ?? klutterPubVersion;

  String get _klutteruiPubVersion =>
      options[ScriptOption.klutterui] ?? klutterUIPubVersion;

  String get _squintPubVersion =>
      options[ScriptOption.squint] ?? squintPubVersion;

  String get _klutterGradleVersion =>
      options[ScriptOption.bom] ?? klutterGradleVersion;

  @override
  List<String> exampleCommands() => [
        "kradle create",
        "kradle create name=my_plugin group=dev.buijs.klutter.example flutter=3.10.6",
        "kradle create name=my_plugin group=dev.buijs.klutter.example flutter=3.10.6 config=./foo/bar/kradle.yaml",
        "kradle create name=my_plugin group=dev.buijs.klutter.example flutter=3.10.6 config=./foo/bar/kradle.yaml root=./foo/bar/directory",
      ];

  @override
  List<Task> dependsOn() => [GetFlutterSDK()];
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
