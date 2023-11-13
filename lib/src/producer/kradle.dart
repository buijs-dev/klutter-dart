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

import "dart:io";

import "../common/utilities.dart";
import "resource.dart";

/// Path to Kradle cache folder which defaults to <user.home>/.kradle/cache.
///
/// Cache Path can be overwritten in the project-root/kradle.env File.
Directory get defaultKradleCacheFolder =>
    Directory("${Platform.environment["HOME"]}/.kradle/cache")
        .normalizeToFolder;

/// Copy Kradle files to root.
///
/// Copies the following files:
/// - kradlew
/// - kradlew.bat
/// - kradle.env
/// - kradle.yaml
/// - kradle/kradle-wrapper.jar
///
/// {@category producer}
class Kradle {
  /// Create a Kradle instance based of the Flutter project root folder.
  Kradle(this.pathToRoot);

  /// The Flutter project root folder.
  final String pathToRoot;

  late final LocalResource _kradleEnv;

  late final LocalResource _kradleYaml;

  late final Future<bool> _isInitialized =
      Future.wait([_init]).then((_) => true);

  /// Read all resources from the klutter package lib/res folder.
  Future<void> get _init async {
    await Future.wait([
      _loadKradleEnv,
      _loadKradleYaml,
    ]);
  }

  Future<void> get _loadKradleEnv async {
    _kradleEnv = await loadResource(
      uri: "package:klutter/res/kradle.env".toUri,
      targetRelativeToRoot: "".normalize,
      filename: "kradle.env",
    );
  }

  Future<void> get _loadKradleYaml async {
    _kradleYaml = await loadResource(
      uri: "package:klutter/res/kradle.yaml".toUri,
      targetRelativeToRoot: "".normalize,
      filename: "kradle.yaml",
    );
  }

  /// Copy Kradlew files to the project root folder.
  ///
  /// Copies the following files:
  /// - kradle.yaml
  /// - kradlew
  /// - kradlew.bat
  /// - kradle.env
  /// - kradle/kradle-wrapper.jar
  Future<void> get copyToRoot async {
    await _isInitialized;
    pathToRoot.verifyExists.rootFolder.copyFiles([
      _kradleYaml,
      _kradleEnv,
    ]);
  }
}

extension on String {
  Uri get toUri => Uri.parse(this);

  Directory get rootFolder => Directory(this);
}
