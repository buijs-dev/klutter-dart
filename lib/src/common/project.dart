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
import "shared.dart";

/// Create and/or append the .klutter-plugins file to register a Klutter plugin.
void registerPlugin({
  required String pathToRoot,
  required String pluginName,
  required String pluginLocation,
}) =>
    createRegistry(pathToRoot).append(pluginName, pluginLocation);

/// Create registry file .klutter-plugins.
File createRegistry(String pathToRoot) =>
    pathToRoot.verifyExists.toKlutterPlugins;

/// Find package name in root/pubspec.yaml.
///
/// Returns value of element flutter:plugin:platforms:android:package.
String findPackageName(String pathToRoot) =>
    pathToRoot.verifyExists.toPubspecYaml.packageName;

/// Find plugin name in root/pubspec.yaml.
///
/// Returns value of element name.
String findPluginName(String pathToRoot) =>
    pathToRoot.verifyExists.toPubspecYaml.pluginName;

/// Find plugin name in root/pubspec.yaml.
///
/// Returns value of element version.
String findPluginVersion(String pathToRoot) =>
    pathToRoot.verifyExists.toPubspecYaml.pluginVersion;

/// Get the relative path of a plugin dependency.
///
/// Given a pubspec.yaml in folder /foo/bar with the following local dependency:
///
/// ```
/// dependencies:
///
///   awesome_plugin:
///     path: ../
///
/// ```
///
/// Will return absolute path: foo/awesome_plugin
///
///
/// When the dependency name and root folder name do not match, then the folder name specified in the path will be used.
/// Given a pubspec.yaml in folder /foo/bar with the following local dependency:
///
/// ```
/// dependencies:
///
///   awesome_plugin:
///     path: ../awesome
///
/// ```
///
/// Will return absolute path: foo/awesome
///
/// When the dependency is not local then the path to the flutter cache folder is returned.
String findDependencyPath({
  required String pathToSDK,
  required String pathToRoot,
  required String pluginName,
}) {
  // Default path where dependencies retrieved from pub are stored.
  final cachePath = ""
      "$pathToSDK/.pub-cache/hosted/pub.dartlang.org/"
      "$pluginName/android/klutter";

  // Local path pointing to a (relative) folder.
  final localPath = "dependencies[\\w\\W]+?$pluginName:\n.+?path:(.+)";

  // Read the pubspec.yaml and remove all comments.
  final pubspecYaml = pathToRoot.verifyExists.toPubspecYaml
      .readAsLinesSync()
      .map((line) => line.trim().startsWith("#") ? null : line)
      .whereType<String>()
      .join("\n");

  // Try to find a local path in the pubspec.yaml.
  final pathToPlugin = RegExp(localPath).firstMatch(pubspecYaml);

  /// Create an absolute path to a locally stored dependency.
  if (pathToPlugin != null) {
    final relativeToRoot = pathToPlugin.group(1)!;
    return Directory(pathToRoot)
        .resolveFolder(relativeToRoot)
        .resolveFolder("android/klutter")
        .path;
  }

  /// Create an absolute path to the the default pub-cache folder.
  return cachePath.normalize;
}

extension on String {
  /// Create a path to the root-project/.klutter-plugins file.
  /// If the file does not exist create it.
  File get toKlutterPlugins => File("${this}/.klutter-plugins").normalizeToFile
    ..ifNotExists((file) => file.normalizeToFile.createSync());

  /// Create a path to the root-project/pubspec.yaml file.
  File get toPubspecYaml => File("${this}/pubspec.yaml").normalizeToFile
    ..ifNotExists((_) =>
        throw KlutterException("Missing pubspec.yaml file in folder: ${this}"));
}

extension on File {
  /// Write the plugin name and location to the .klutter-plugins file.
  ///
  /// If there already is a plugin registered with the given name
  /// then the location is updated.
  void append(String name, String location) {
    // Will be set to true if a registry for the given name is found.
    var hasKey = false;

    final lines = readAsLinesSync().map((line) {
      // Split 'key=value' and compare key with given name.
      final key = line.substring(0, line.indexOf("=")).trim();

      if (key == name.trim()) {
        // Set new location for the library name.
        hasKey = true;
        return "$name=$location";
      } else {
        // Return the registry as-is.
        return line;
      }
    }).toList();

    // If true then registry is already updated for given name.
    if (!hasKey) {
      lines.add("$name=$location");
    }

    writeAsStringSync(lines.join("\n"));
  }

  /// Get value of tag 'flutter:plugin:platforms:android:package' from pubspec.yaml.
  String get packageName {
    final content = readAsStringSync().replaceAll(" ", "").replaceAll("\n", "");
    final startIndex = content.indexOf("android:package:");
    final endIndex = content.indexOf("pluginClass:");

    if (startIndex == -1 || endIndex == -1) {
      throw KlutterException(
        "Failed to find tag plugin:platforms:android:package in pubspec.yaml",
      );
    }

    return content.substring(startIndex + 16, endIndex).trim();
  }

  /// Get value of tag 'name' from pubspec.yaml.
  String get pluginName => _pub("name");

  /// Get value of tag 'version' from pubspec.yaml.
  String get pluginVersion => _pub("version");

  /// Read the pubspec.yaml and return value for [tag].
  String _pub(String tag) {
    return readAsLinesSync()
        .map((line) => line.split(":"))
        .where((line) => line.length == 2)
        .firstWhere((line) => line[0] == tag,
            orElse: () => throw KlutterException(
                  "Failed to find tag '$tag' in pubspec.yaml.",
                ))[1]
        .trim();
  }
}
