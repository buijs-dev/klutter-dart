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

import "package:klutter/src/common/common.dart";
import "package:test/test.dart";

import "e2e_test.dart";

const organisation = "dev.buijs.integrationtest.example";

const pluginName = "ridiculous_awesome";

const appName = "my_flutter_app";

void main() {
  final pathToRoot = Directory(
      "${Directory.systemTemp.absolute.path}/createklutterpluginit2".normalize)
    ..maybeDelete
    ..createSync();

  final producerPlugin =
      Directory("${pathToRoot.absolute.path}/$pluginName".normalize);

  test("end-to-end test", () async {
    /// Create Flutter plugin project.
    await createKlutterPlugin(
      organisation: organisation,
      pluginName: pluginName,
      root: pathToRoot.absolute.path,
    );

    expect(producerPlugin.existsSync(), true,
        reason:
            "Plugin should be created in: '${producerPlugin.absolute.path}'");

    /// Add Klutter as dev_dependency.
    createConfigYaml(
      root: producerPlugin.absolutePath,
    );

    /// Root build.gradle file should be created.
    final rootBuildGradle =
        File("${producerPlugin.absolutePath}/build.gradle.kts".normalize);
    expect(rootBuildGradle.existsSync(), true,
        reason: "root/build.gradle.kts should exist");
    expect(rootBuildGradle.readAsStringSync().contains("bom:9999.1.1"), true,
        reason:
            "root/build.gradle.kts should contains BOM version from config.");

    /// Root settings.gradle file should be created.
    expect(
        File("${producerPlugin.absolutePath}/settings.gradle.kts".normalize)
            .existsSync(),
        true,
        reason: "root/settings.gradle.kts should exist");

    /// Android/Klutter build.gradle file should be created.
    final androidKlutterBuildGradle = File(
        "${producerPlugin.absolutePath}/android/klutter/build.gradle.kts"
            .normalize);
    expect(androidKlutterBuildGradle.existsSync(), true,
        reason: "android/klutter/build.gradle.kts should exist");

    /// Android/Klutter build.gradle file should be created.
    final androidBuildGradle =
        File("${producerPlugin.absolutePath}/android/build.gradle".normalize);
    expect(androidBuildGradle.existsSync(), true,
        reason: "android/build.gradle.kts should exist");
    expect(androidBuildGradle.readAsStringSync().contains("bom:9999.1.1"), true,
        reason: "android/build.gradle should contain BOM version from config.");
  });

  tearDownAll(() => pathToRoot.deleteSync(recursive: true));
}

/// Create Flutter plugin project.
void createConfigYaml({
  required String root,
}) {
  Directory(root).resolveFile("kradle.yaml")
    ..createSync()
    ..writeAsStringSync("""
    bom-version:9999.1.1
    """);
}
