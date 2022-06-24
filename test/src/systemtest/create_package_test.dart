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

import "package:klutter/src/cli/cli.dart" as sut;
import "package:klutter/src/common/exception.dart";
import "package:klutter/src/common/shared.dart";
import "package:test/test.dart";

const organisation = "dev.buijs.integrationtest.example";

const pluginName = "ridiculous_awesome";

void main() {

  final pathToRoot = Directory(
      "${Directory.systemTemp.absolute.path}/createklutterpluginit".normalize
  )..createSync();

  group("end-to-end test", () {

    test("Verify producer tasks", () async {

      /// Create Flutter plugin project.
      await createFlutterPlugin(
        organisation: organisation,
        pluginName: pluginName,
        root: pathToRoot.absolute.path,
      );

      final plugin = Directory("${pathToRoot.absolute.path}/$pluginName".normalize);

      expect(plugin.existsSync(), true, reason: "Plugin should be created in: '${plugin.absolute.path}'");

      /// Add Klutter as dev_dependency.
      await addKlutterAsDevDependency(
        root: plugin.absolutePath,
      );

      /// Setup Klutter as dev_dependency.
      await sut.execute(
          pathToRoot: plugin.absolutePath,
          scriptName: sut.ScriptName.producer,
          args: ["init"],
      );

      /// Install KMP Platform module.
      await sut.execute(
        pathToRoot: plugin.absolutePath,
        scriptName: sut.ScriptName.producer,
        args: ["install=platform"],
      );

      /// Generate Dart service code.
      await sut.execute(
        pathToRoot: plugin.absolutePath,
        scriptName: sut.ScriptName.producer,
        args: ["install=library"],
      );

    });

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