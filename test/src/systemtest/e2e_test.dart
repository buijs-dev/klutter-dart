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

@Tags(["ST"])

import "dart:io";

import "package:klutter/src/cli/library.dart" as sut;
import "package:klutter/src/common/exception.dart";
import "package:klutter/src/common/shared.dart";
import "package:test/test.dart";

const organisation = "dev.buijs.integrationtest.example";

const pluginName = "ridiculous_awesome";

const appName = "my_flutter_app";

void main() {

  final pathToRoot = Directory(
      "${Directory.systemTemp.absolute.path}/createklutterpluginit".normalize
  )..createSync();

  final producerPlugin = Directory("${pathToRoot.absolute.path}/$pluginName".normalize);

  final consumerPlugin = Directory("${producerPlugin.absolute.path}/example".normalize);

  test("end-to-end test", () async {

    /// Create Flutter plugin project.
    await createFlutterPlugin(
      organisation: organisation,
      pluginName: pluginName,
      root: pathToRoot.absolute.path,
    );

    expect(producerPlugin.existsSync(), true, reason: "Plugin should be created in: '${producerPlugin.absolute.path}'");

    /// Add Klutter as dev_dependency.
    await addKlutterAsDevDependency(
      root: producerPlugin.absolutePath,
    );

    /// Setup Klutter as dev_dependency.
    await sut.execute(
        pathToRoot: producerPlugin.absolutePath,
        script: sut.ScriptName.producer,
        arguments: ["init"],
    );

    /// Gradle files should be copied to root folder.
    expect(File("${producerPlugin.absolutePath}/gradlew".normalize).existsSync(), true,
        reason: "root/gradlew should exist");
    expect(File("${producerPlugin.absolutePath}/gradlew.bat".normalize).existsSync(), true,
        reason: "root/gradlew.bat should exist");
    expect(File("${producerPlugin.absolutePath}/gradle.properties".normalize).existsSync(), true,
        reason: "root/gradle.properties should exist");
    expect(File("${producerPlugin.absolutePath}/gradle/wrapper/gradle-wrapper.jar".normalize).existsSync(), true,
        reason: "root/gradle/wrapper/gradle-wrapper.jar should exist");
    expect(File("${producerPlugin.absolutePath}/gradle/wrapper/gradle-wrapper.properties".normalize).existsSync(), true,
        reason: "root/gradle/wrapper/gradle-wrapper.properties should exist");

    /// Gradle files should be copied to android folder.
    expect(File("${producerPlugin.absolutePath}/android/gradlew".normalize).existsSync(), true,
        reason: "root/gradlew should exist");
    expect(File("${producerPlugin.absolutePath}/android/gradlew.bat".normalize).existsSync(), true,
        reason: "root/gradlew.bat should exist");
    expect(File("${producerPlugin.absolutePath}/android/gradle.properties".normalize).existsSync(), true,
        reason: "root/gradle.properties should exist");
    expect(File("${producerPlugin.absolutePath}/android/gradle/wrapper/gradle-wrapper.jar".normalize).existsSync(), true,
        reason: "root/gradle/wrapper/gradle-wrapper.jar should exist");
    expect(File("${producerPlugin.absolutePath}/android/gradle/wrapper/gradle-wrapper.properties".normalize).existsSync(), true,
        reason: "root/gradle/wrapper/gradle-wrapper.properties should exist");

    /// Root build.gradle file should be created.
    expect(File("${producerPlugin.absolutePath}/build.gradle.kts".normalize).existsSync(), true,
        reason: "root/build.gradle.kts should exist");

    /// Root settings.gradle file should be created.
    expect(File("${producerPlugin.absolutePath}/settings.gradle.kts".normalize).existsSync(), true,
        reason: "root/settings.gradle.kts should exist");

    /// Android/Klutter build.gradle file should be created.
    expect(File("${producerPlugin.absolutePath}/android/klutter/build.gradle.kts".normalize).existsSync(), true,
        reason: "android/klutter/build.gradle.kts should exist");

    /// IOS/Klutter folder should be created.
    expect(Directory("${producerPlugin.absolutePath}/ios/Klutter".normalize).existsSync(), true,
        reason: "ios/Klutter should exist");

    /// Install KMP Platform module.
    await sut.execute(
      pathToRoot: producerPlugin.absolutePath,
      script: sut.ScriptName.producer,
      arguments: ["install=platform"],
    );

    /// Generate Dart service code.
    await sut.execute(
      pathToRoot: producerPlugin.absolutePath,
      script: sut.ScriptName.producer,
      arguments: ["install=library"],
    );

    expect(consumerPlugin.existsSync(), true,
        reason: "Plugin should be created in: '${producerPlugin.absolute.path}'");

    final podFile = File("${consumerPlugin.absolutePath}/ios/Podfile".normalize);
    expect(podFile.existsSync(), true, reason: "Podfile should exist");

    /// Add Klutter as dev_dependency.
    await addKlutterAsDevDependency(
      root: consumerPlugin.absolutePath,
    );

    /// Setup Klutter in consumer project.
    await sut.execute(
      pathToRoot: consumerPlugin.absolutePath,
      script: sut.ScriptName.consumer,
      arguments: ["init"],
    );

    var excludeArchsHasRun = podFile
        .readAsStringSync()
        .contains("bc.build_settings['ARCHS[sdk=iphonesimulator*]'] =  `uname -m`");

    expect(excludeArchsHasRun, true,
        reason: "IOS init should have visited the ios Podfile.");

    final registry = File("${consumerPlugin.absolutePath}/.klutter-plugins".normalize);

    expect(registry.existsSync(), true,
        reason: "klutter-plugins file should be created");

    /// Add plugin to consumer project.
    await sut.execute(
      pathToRoot: consumerPlugin.absolutePath,
      script: sut.ScriptName.consumer,
      arguments: ["add=$pluginName"],
    );

    final registryContainsPlugin = registry.readAsStringSync().contains(pluginName);

    expect(registryContainsPlugin, true,
        reason: "add task should have added plugin name to the .klutter-plugins file");

    /// Run only Android init, then iOS is skipped

    // Delete the exclusion which is added by iOS init
    podFile.writeAsStringSync(podFile.readAsStringSync().replaceAll("bc.build_settings['ARCHS[sdk=iphonesimulator*]'] =  `uname -m`", ""));

    excludeArchsHasRun = podFile
        .readAsStringSync()
        .contains("bc.build_settings['ARCHS[sdk=iphonesimulator*]'] =  `uname -m`");

    expect(excludeArchsHasRun, false);

    // Delete the klutter-plugins file which is added by Android init
    registry.deleteSync();
    expect(registry.existsSync(), false);

    await sut.execute(
      pathToRoot: consumerPlugin.absolutePath,
      script: sut.ScriptName.consumer,
      arguments: ["init=android"],
    );

    expect(excludeArchsHasRun, false, reason: "IOS init should not have been executed");
    expect(registry.existsSync(), true, reason: "klutter-plugins file should be created");

    /// Run only iOS init, then Android is skipped

    // Delete the exclusion which is added by iOS init
    podFile.writeAsStringSync(podFile.readAsStringSync().replaceAll("bc.build_settings['ARCHS[sdk=iphonesimulator*]'] =  `uname -m`", ""));

    excludeArchsHasRun = podFile
        .readAsStringSync()
        .contains("bc.build_settings['ARCHS[sdk=iphonesimulator*]'] =  `uname -m`");

    expect(excludeArchsHasRun, false);

    // Delete the klutter-plugins file which is added by Android init
    registry.deleteSync();
    expect(registry.existsSync(), false);

    await sut.execute(
      pathToRoot: consumerPlugin.absolutePath,
      script: sut.ScriptName.consumer,
      arguments: ["init=ios"],
    );

    excludeArchsHasRun = podFile
        .readAsStringSync()
        .contains("bc.build_settings['ARCHS[sdk=iphonesimulator*]'] =  `uname -m`");

    expect(excludeArchsHasRun, true, reason: "IOS init should have been executed");
    expect(registry.existsSync(), false, reason: "Android init should not have been executed");

  });

  tearDownAll(() => pathToRoot.deleteSync(recursive: true));

}

/// Create Flutter plugin project.
Future<void> createFlutterPlugin({
  required String organisation,
  required String pluginName,
  required String root,
}) async {

  await Process.run(
      "flutter",
      [
        "create",
        "--org", organisation,
        "--template=plugin",
        "--platforms=android,ios",
        pluginName,
      ],
      workingDirectory: root
  ).then((result) {
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });

}

Future<void> addKlutterAsDevDependency({
  required String root,
}) async {

  final pubspec = File("$root/pubspec.yaml".normalize);

  if(!pubspec.existsSync()) {
    throw KlutterException("Pubspec.yaml is not found!");
  }

  final lines = pubspec.readAsLinesSync();

  pubspec
    ..deleteSync()
    ..createSync();

  for(final line in lines){
    pubspec.writeAsStringSync("$line\n", mode: FileMode.append);

    if(line.startsWith("dev_dependencies:")) {
      pubspec
        ..writeAsStringSync("  klutter:\n", mode: FileMode.append)
        ..writeAsStringSync("    path: ${Directory.current.absolute.path}\n", mode: FileMode.append);
    }
  }

  await Process.run("flutter", ["pub", "get"], workingDirectory: root)
      .then((result) {
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });

}