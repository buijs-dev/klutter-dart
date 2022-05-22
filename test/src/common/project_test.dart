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

import "dart:io";

import "package:klutter/src/common/exception.dart";
import "package:klutter/src/common/project.dart";
import "package:klutter/src/common/shared.dart";
import "package:test/test.dart";

void main() {

  final s = Platform.pathSeparator;
  late final Directory root;
  late final File registry;

  setUpAll(() {

    root = Directory("${Directory.systemTemp.path}${s}regtest")
      ..createSync();

    //Will be created during test!
    registry = File("${root.absolute.path}$s.klutter-plugins");

  });

  test("Verify exception is thrown if root does not exist", () {
    expect(() => registerPlugin(
      pathToRoot: "fake",
      pluginName: "some_plugin",
      pluginLocation: "foo/bar/cache/some_plugin",
    ), throwsA(predicate((e) =>
        e is KlutterException &&
        e.cause.startsWith("Path does not exist:") &&
        e.cause.endsWith("/fake"))));
  });

  test("Verify .klutter-plugins file is created if it does not exist", () {

    // Given the registry does not exist
    expect(registry.existsSync(), false);

    // When registerPlugin is used
    registerPlugin(
      pathToRoot: root.path,
      pluginName: "some_plugin",
      pluginLocation: "foo/bar/cache/some_plugin",
    );

    // Then the registry does exist
    expect(registry.existsSync(), true);

    // And contains the plugin
    expect(registry.readAsStringSync(), "some_plugin=foo/bar/cache/some_plugin");

  });

  test("Verify content is appended to .klutter-plugins file", () {

    // Given the registry exists
    expect(registry.existsSync(), true);

    // When registerPlugin is used
    registerPlugin(
      pathToRoot: root.path,
      pluginName: "some_plugin",
      pluginLocation: "foo/bar/cache/new_location",
    );

    // Then the content is updated
    final content = registry.readAsStringSync();
    expect(content.contains("some_plugin=foo/bar/cache/new_location"), true, reason: "contains updated location");
    expect(content.contains("some_plugin=foo/bar/cache/some_plugin"), false, reason: "does not contains old location");

  });

  test("Verify exception is thrown if pubspec.yaml is not found", () {

    expect(() => findPackageName(root.path), throwsA(predicate((e) =>
        e is KlutterException &&
        e.cause.startsWith("Missing pubspec.yaml file in folder:"))));

  });

  test("Verify exception is thrown if pubspec.yaml does not contain the requested tag", () {

    File("${root.path}/pubspec.yaml".normalize).createSync();

    expect(() => findPackageName(root.path), throwsA(predicate((e) =>
    e is KlutterException &&
        e.cause.startsWith("Failed to find tag plugin:platforms:android:package in pubspec.yaml"))));

  });

  test("Verify exception is thrown if pubspec.yaml does not contain the requested tag", () {

    File("${root.path}/pubspec.yaml".normalize).createSync();

    expect(() => findPluginName(root.path), throwsA(predicate((e) =>
    e is KlutterException &&
        e.cause.startsWith("Failed to find tag 'name' in pubspec.yaml."))));

  });

  test("Verify correct tag values are returned from pubspec.yaml", () {

    File("${root.path}/pubspec.yaml".normalize)
      ..createSync()
      ..writeAsStringSync("""
            |name: super_awesome
            |description: A new flutter plugin project.
            |version: 0.0.1
            |homepage:
            |
            |environment:
            |  sdk: ">=2.16.1 <3.0.0"
            |  flutter: ">=2.5.0"
            | 
            |flutter:
            |  plugin:
            |    platforms:
            |      android:
            |        package: com.example.super_awesome
            |        pluginClass: SuperAwesomePlugin
            |      ios:
            |        pluginClass: SuperAwesomePlugin
      """.format);

    expect(findPluginName(root.path), "super_awesome");
    expect(findPluginVersion(root.path), "0.0.1");
    expect(findPackageName(root.path), "com.example.super_awesome");

  });

  tearDownAll(() => root.deleteSync(recursive: true));

}