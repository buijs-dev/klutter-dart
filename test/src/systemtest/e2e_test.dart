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

@Tags(["ST"])

import "dart:io";

import "package:klutter/klutter.dart";
import "package:klutter/src/cli/cli.dart" as sut;
import "package:klutter/src/cli/context.dart";
import "package:test/test.dart";

const organisation = "dev.buijs.integrationtest.example";

const pluginName = "ridiculous_awesome";

const appName = "my_flutter_app";

void main() {
  final pathToRoot = Directory(
      "${Directory.systemTemp.absolute.path}/createklutterpluginit".normalize)
    ..createSync();

  final producerPlugin =
      Directory("${pathToRoot.absolute.path}/$pluginName".normalize);

  final consumerPlugin =
      Directory("${producerPlugin.absolute.path}/example".normalize);

  try {
    test("end-to-end test", () async {
      /// Run a Klutter task without an existing Flutter project
      final result = await sut.execute(
          toContextOrNull(producerPlugin,["add", "lib=foo"])!);

      expect(
        result.contains("finished unsuccessfully"),
        true,
        reason: "can't run a task without a project",
      );

      /// Create Flutter plugin project.
      await createFlutterPlugin(
        organisation: organisation,
        pluginName: pluginName,
        root: Directory(pathToRoot.absolutePath).normalizeToDirectory.absolutePath,
      );

      expect(producerPlugin.existsSync(), true,
          reason:
              "Plugin should be created in: '${producerPlugin.absolute.path}'");

      /// Gradle files should be copied to root folder.
      expect(
          File("${producerPlugin.absolutePath}/gradlew".normalize).existsSync(),
          true,
          reason: "root/gradlew should exist");
      expect(
          File("${producerPlugin.absolutePath}/gradlew.bat".normalize)
              .existsSync(),
          true,
          reason: "root/gradlew.bat should exist");
      expect(
          File("${producerPlugin.absolutePath}/gradle.properties".normalize)
              .existsSync(),
          true,
          reason: "root/gradle.properties should exist");
      expect(
          File("${producerPlugin.absolutePath}/gradle/wrapper/gradle-wrapper.jar"
                  .normalize)
              .existsSync(),
          true,
          reason: "root/gradle/wrapper/gradle-wrapper.jar should exist");
      expect(
          File("${producerPlugin.absolutePath}/gradle/wrapper/gradle-wrapper.properties"
                  .normalize)
              .existsSync(),
          true,
          reason: "root/gradle/wrapper/gradle-wrapper.properties should exist");

      /// Gradle files should be copied to android folder.
      expect(
          File("${producerPlugin.absolutePath}/android/gradlew".normalize)
              .existsSync(),
          true,
          reason: "root/gradlew should exist");
      expect(
          File("${producerPlugin.absolutePath}/android/gradlew.bat".normalize)
              .existsSync(),
          true,
          reason: "root/gradlew.bat should exist");
      expect(
          File("${producerPlugin.absolutePath}/android/gradle.properties"
                  .normalize)
              .existsSync(),
          true,
          reason: "root/gradle.properties should exist");
      expect(
          File("${producerPlugin.absolutePath}/android/gradle/wrapper/gradle-wrapper.jar"
                  .normalize)
              .existsSync(),
          true,
          reason: "root/gradle/wrapper/gradle-wrapper.jar should exist");
      expect(
          File("${producerPlugin.absolutePath}/android/gradle/wrapper/gradle-wrapper.properties"
                  .normalize)
              .existsSync(),
          true,
          reason: "root/gradle/wrapper/gradle-wrapper.properties should exist");

      /// Root build.gradle file should be created.
      expect(
          File("${producerPlugin.absolutePath}/build.gradle.kts".normalize)
              .existsSync(),
          true,
          reason: "root/build.gradle.kts should exist");

      /// Root settings.gradle file should be created.
      expect(
          File("${producerPlugin.absolutePath}/settings.gradle.kts".normalize)
              .existsSync(),
          true,
          reason: "root/settings.gradle.kts should exist");

      /// Android/Klutter build.gradle file should be created.
      expect(
          File("${producerPlugin.absolutePath}/android/klutter/build.gradle.kts"
                  .normalize)
              .existsSync(),
          true,
          reason: "android/klutter/build.gradle.kts should exist");

      /// IOS/Klutter folder should be created.
      expect(
          Directory("${producerPlugin.absolutePath}/ios/Klutter".normalize)
              .existsSync(),
          true,
          reason: "ios/Klutter should exist");

      expect(consumerPlugin.existsSync(), true,
          reason:
              "Plugin should be created in: '${producerPlugin.absolute.path}'");

      /// Example/lib/main.dart file should be created.
      final mainDartFile =  File("${producerPlugin.absolutePath}/example/lib/main.dart"
          .normalize);
      expect(mainDartFile.existsSync(),
          true,
          reason: "example/lib/main.dart file should exist");

      expect(mainDartFile
          .readAsStringSync()
          .contains('String _greeting = "There shall be no greeting for now!";'),
          true,
      reason: "main.dart content is overwritten");

      final registry =
      File("${consumerPlugin.absolutePath}/.klutter-plugins".normalize);

      expect(registry.existsSync(), true,
          reason: "klutter-plugins file should be created");

      final registryContainsPlugin =
          registry.readAsStringSync().contains(pluginName);

      expect(registryContainsPlugin, true,
          reason:
              "add task should have added plugin name to the .klutter-plugins file: ${registry.readAsStringSync()}");
    });

  } catch (e, s) {
    print(s);
  }

  tearDownAll(() => pathToRoot.deleteSync(recursive: true));
}

/// Create Flutter plugin project.
Future<void> createFlutterPlugin({
  required String organisation,
  required String pluginName,
  required String root,
  String? config,
}) async {
  final context = Context(
    workingDirectory: Directory(root),
    taskName:  TaskName.create,
      taskOptions: {
    TaskOption.root:root,
    TaskOption.group:organisation,
    TaskOption.name:pluginName,
    TaskOption.flutter:"3.10.6",
    TaskOption.klutter:"local@${Directory.current.resolveFolder("./../".normalize).absolutePath}",
  });

  final res = await sut.toTask(context)!.execute(context);
  if(!res.isOk) {
     assert(res.isOk,res.message);
  }

}