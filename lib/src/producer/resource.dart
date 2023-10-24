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

import "../common/utilities.dart";

/// Utility to copy Files from lib/res folder to project.
extension ResourceCopy on Directory {
  /// Copy a File from lib/res folder to a project folder.
  void copyFiles(List<LocalResource> resources) {
    for (final resource in resources) {
      final from = File(resource.pathToSource.verifyExists);
      final pathTo = Directory(
        "$absolutePath/${resource.targetRelativeToRoot}".normalize,
      ).maybeCreate;
      final to = pathTo.resolveFile(resource.filename);
      from.copySync(to.absolutePath);
      Process.runSync("chmod", runInShell: true, ["755", to.absolutePath]);
    }
  }
}

/// Representation of a Gradle file which
/// should be copied to a Klutter project.
class LocalResource {
  /// Create a new [LocalResource] instance.
  const LocalResource({
    required this.pathToSource,
    required this.filename,
    required this.targetRelativeToRoot,
  });

  /// Name of File to be copied.
  final String filename;

  /// Target path relative to the project root folder where to copy the File.
  final String targetRelativeToRoot;

  /// Path to the source File.
  final String pathToSource;
}

/// Load resource files from lib/res folder.
Future<LocalResource> loadResource({
  required Uri uri,
  required String filename,
  required String targetRelativeToRoot,
}) =>
    Isolate.resolvePackageUri(uri).then((pathToSource) {
      return LocalResource(
        pathToSource: Platform.isWindows
            ? pathToSource!.path.replaceFirst("/", "")
            : pathToSource!.path,
        filename: filename,
        targetRelativeToRoot: targetRelativeToRoot,
      );
    });
