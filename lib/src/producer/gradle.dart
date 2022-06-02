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
import "dart:isolate";

import "../common/shared.dart";

/// Copy Gradle files to root and root/android folders to enable the usage of Gradle.
///
/// Copies the following files to both root and root/android:
/// - gradlew
/// - gradlew.bat
/// - gradle.properties
/// - gradle/wrapper/gradle-wrapper.jar
/// - gradle/wrapper/gradle-wrapper.properties
class Gradle {
  /// Create a Gradle instance based of the Flutter project root folder.
  Gradle(this.pathToRoot);

  /// The Flutter project root folder.
  final String pathToRoot;

  late final _GradleResource _gradlew;
  late final _GradleResource _gradlewBat;
  late final _GradleResource _gradlewJar;
  late final _GradleResource _gradlewProperties;
  late final _GradleResource _gradleProperties;

  late final Future<bool> _isInitialized =
      Future.wait([_init]).then((_) => true);

  /// Read all resources from the klutter package lib/res folder.
  Future<void> get _init async {
    await Future.wait([
      _loadGradlew,
      _loadGradlewBat,
      _loadGradlewJar,
      _loadGradlewProperties,
      _loadGradleProperties,
    ]);
  }

  Future<void> get _loadGradlew async {
    _gradlew = await loadResource(
      uri: "package:klutter/res/gradlew".toUri,
      targetRelativeToRoot: "",
      filename: "gradlew",
    );
  }

  Future<void> get _loadGradlewBat async {
    _gradlewBat = await loadResource(
      uri: "package:klutter/res/gradlew.bat".toUri,
      targetRelativeToRoot: "",
      filename: "gradlew.bat",
    );
  }

  Future<void> get _loadGradlewJar async {
    _gradlewJar = await loadResource(
      uri: "package:klutter/res/gradle-wrapper.jar".toUri,
      targetRelativeToRoot: "gradle/wrapper".normalize,
      filename: "gradle-wrapper.jar",
    );
  }

  Future<void> get _loadGradlewProperties async {
    _gradlewProperties = await loadResource(
      uri: "package:klutter/res/gradle-wrapper.properties".toUri,
      targetRelativeToRoot: "gradle/wrapper".normalize,
      filename: "gradle-wrapper.properties",
    );
  }

  Future<void> get _loadGradleProperties async {
    _gradleProperties = await loadResource(
      uri: "package:klutter/res/gradle.properties".toUri,
      targetRelativeToRoot: "",
      filename: "gradle.properties",
    );
  }

  /// Copy Gradle files to the project root folder.
  ///
  /// Copies the following files:
  /// - gradlew
  /// - gradlew.bat
  /// - gradle.properties
  /// - gradle/wrapper/gradle-wrapper.jar
  /// - gradle/wrapper/gradle-wrapper.properties
  Future<void> get copyToRoot async {
    await _isInitialized;
    pathToRoot.verifyExists.rootFolder.copyFiles([
      _gradlewBat,
      _gradlew,
      _gradleProperties,
      _gradlewJar,
      _gradlewProperties,
    ]);
  }

  /// Copy Gradle files to the project root/android folder.
  ///
  /// Copies the following files:
  /// - gradlew
  /// - gradlew.bat
  /// - gradle.properties
  /// - gradle/wrapper/gradle-wrapper.jar
  /// - gradle/wrapper/gradle-wrapper.properties
  Future<void> get copyToAndroid async {
    await _isInitialized;
    pathToRoot.verifyExists.androidFolder.copyFiles([
      _gradlewBat,
      _gradlew,
      _gradleProperties,
      _gradlewJar,
      _gradlewProperties,
    ]);
  }
}

extension on String {
  Uri get toUri => Uri.parse(this);

  Directory get rootFolder => Directory(this);

  Directory get androidFolder =>
      Directory("${this}/android".normalize)..absolutePath.verifyExists;
}

extension on Directory {
  void copyFiles(List<_GradleResource> resources) {
    for (final resource in resources) {
      final from = File(resource.pathToSource.verifyExists);
      final pathTo = Directory(
        "$absolutePath/${resource.targetRelativeToRoot}".normalize,
      ).maybeCreate;

      from.copySync(pathTo.resolveFile(resource.filename).absolutePath);
    }
  }
}

class _GradleResource {
  const _GradleResource({
    required this.pathToSource,
    required this.filename,
    required this.targetRelativeToRoot,
  });

  final String filename;
  final String targetRelativeToRoot;
  final String pathToSource;
}

/// Load resource files from lib/res folder.
Future<_GradleResource> loadResource({
  required Uri uri,
  required String filename,
  required String targetRelativeToRoot,
}) =>
    Isolate.resolvePackageUri(uri).then((pathToSource) {
      return _GradleResource(
        pathToSource: pathToSource!.path,
        filename: filename,
        targetRelativeToRoot: targetRelativeToRoot,
      );
    });
