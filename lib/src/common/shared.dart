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

import "exception.dart";

/// The plugin ClassName which is equal to the library name
/// converted to camelcase + 'Plugin' postfix.
///
/// Example:
/// Given [pluginName] 'super_awesome'
/// will return SuperAwesomePlugin.
///
/// Example:
/// Given [pluginName] 'super_awesome_plugin'
/// will return SuperAwesomePlugin.
String toPluginClassName(String pluginName) => pluginName
    .split("_")
    .map((e) => "${e[0].toUpperCase()}${e.substring(1, e.length)}")
    .join();

/// File management utilities.
extension FileUtil on FileSystemEntity {
  /// Execute a fallback function if FileSystemEntity does not exist.
  void ifNotExists(void Function(FileSystemEntity file) doElse) {
    if (!existsSync()) {
      doElse.call(this);
    }
  }

  /// Return FileSystemEntity or execute a fallback function if it does not exist.
  FileSystemEntity orElse(void Function(FileSystemEntity file) doElse) {
    ifNotExists(doElse);
    return this;
  }

  /// Check if the Directory exists and if not create it recursively.
  FileSystemEntity get maybeCreate {
    ifNotExists((fse) {
      if (fse is Directory) {
        fse.createSync(recursive: true);
      }
    });
    return this;
  }

  /// Return absolute path of current File or Folder as String.
  String get absolutePath => absolute.path;

  /// Return absolute path of current File or Directory with all
  /// forward slashes ('/') replaced for the platform specific separator.
  File get normalizeToFile => File(_substitute);

  /// Return absolute path of current File or Directory with all
  /// forward slashes ('/') replaced for the platform specific separator.
  Directory get normalizeToFolder => Directory(_substitute);

  /// Return a normalized path of this folder to the given filename.
  File resolveFile(String filename) =>
      File("$absolutePath/$filename").normalizeToFile;

  /// Return a normalized path of this folder to the given filename.
  Directory resolveFolder(String folder) =>
      Directory("$absolutePath/$folder").normalizeToFolder;

  /// Convert a path String by removing all '..' and moving up a folder for each.
  String get _substitute {
    final normalized = <String>[];

    for (final part in absolute.path.split("/")
      ..removeWhere((e) => e.isEmpty)) {
      if (part.trim() == "..") {
        normalized.removeLast();
      } else {
        normalized.add(part);
      }
    }

    final path = normalized.join(Platform.pathSeparator);
    return path.startsWith(Platform.pathSeparator)
        ? path
        : Platform.pathSeparator + path;
  }
}

/// Utils for easier String manipulation.
extension StringUtil on String {
  /// Create an absolute path to the given file or folder.
  ///
  /// If the path does not exist throw a [KlutterException].
  String get verifyExists => Directory(this)

      // If not a Directory check if it is an existing File.
      .orElse((folder) => File(this)

          // If not a File then forget about it.
          .orElse((file) => throw KlutterException(
                "Path does not exist: ${file.absolute.path}",
              )))
      .absolutePath;

  /// Utility to print templated Strings.
  ///
  /// Example:
  ///
  /// Given a templated String:
  /// ```
  /// final String foo = """|A multi-line message
  ///                       |is a message
  ///                       |that exists of
  ///                       |multiple lines.
  ///                       |
  ///                       |True story"""";
  /// ```
  ///
  /// Will produce a multi-line String:
  ///
  /// 'A multi-line message
  /// is a message
  /// that exists of
  /// multiple lines.
  ///
  /// True story'
  String get format => replaceAllMapped(
          // Find all '|' char including preceding whitespaces.
          RegExp(r"(\s+?\|)"),
          // Replace them with a single linebreak.
          (_) => "\n")
      .replaceAll(RegExp(r"(!?,)\|"), "")
      .trimLeft()
      .replaceAll(",|", "|");

  /// Return current String value as being a path to a File or Directory
  /// with forward slashes ('/') replaced for the platform specific separator.
  String get normalize => replaceAll("/", Platform.pathSeparator);
}
