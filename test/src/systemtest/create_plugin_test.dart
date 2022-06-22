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

import "package:klutter/src/common/exception.dart";
import "package:test/test.dart";

final s = Platform.pathSeparator;

const organisation = "dev.buijs.integrationtest.example";

const pluginName = "ridiculous_awesome";

void main() {

  final root = Directory("/Users/buijs/repos/klutter-dart/example");

  //Directory("${Directory.systemTemp.absolute.path}${s}createklutterpluginit")
    //..createSync();

  group("end-to-end test", () {

    test("Verify setting up a new Klutter project", () async {

      /// Create Flutter plugin project.
      await createFlutterPlugin(
        organisation: organisation,
        pluginName: pluginName,
        root: root.absolute.path,
      );

      final plugin = Directory("${root.absolute.path}$s$pluginName");

      expect(plugin.existsSync(), true, reason: "Plugin should be created in: '${plugin.absolute.path}'");

      /// Add Klutter as dev_dependency.
      await addKlutterAsDevDependency(
        root: plugin.absolute.path,
      );

      /// Setup Klutter as dev_dependency.
      await setupKlutter(
        root: plugin.absolute.path,
      );

      /// Install KMP Platform module.
      await gradlewInstallPlatform(
        root: plugin.absolute.path,
      );

      /// Generate Dart service code.
      await gradlewGenerateAdapters(
        root: plugin.absolute.path,
      );
    });

  });

  tearDownAll(() => root.deleteSync(recursive: true));

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

  final pubspec = File("$root${s}pubspec.yaml");

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

Future<void> setupKlutter({
  required String root,
}) async {

  await Process.run("flutter", ["pub", "run", "klutter:plugin", "create"], workingDirectory: root)
      .then((result) {
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });

}

Future<void> gradlewInstallPlatform({
  required String root,
}) async {

  await Process.run("./gradlew", ["klutterInstallPlatform"], workingDirectory: root)
      .then((result) {
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });

}

Future<void> gradlewGenerateAdapters({
  required String root,
}) async {

  await Process.run("./gradlew", ["klutterGenerateAdapters"], workingDirectory: root)
      .then((result) {
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });

}