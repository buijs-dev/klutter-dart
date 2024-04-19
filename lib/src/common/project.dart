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

import "dart:ffi";
import "dart:io";

import "../../klutter.dart";
import "environment.dart";
import "exception.dart";
import "utilities.dart";

/// Create and/or append the .klutter-plugins file to register a Klutter plugin.
///
/// {@category consumer}
void registerPlugin({
  required String pathToRoot,
  required String pluginName,
  required String pluginLocation,
}) =>
    createRegistry(pathToRoot).append(pluginName, pluginLocation);

/// Create registry file .klutter-plugins.
///
/// {@category consumer}
File createRegistry(String pathToRoot) =>
    pathToRoot.verifyExists.toKlutterPlugins;

/// Find package name in root/pubspec.yaml.
///
/// Returns value of element flutter:plugin:platforms:android:package.
///
/// {@category consumer}
/// {@category producer}
String findPackageName(String pathToRoot) =>
    pathToRoot.verifyExists.toPubspecYaml.packageName;

/// Find plugin name in root/pubspec.yaml.
///
/// Returns value of element name.
///
/// {@category consumer}
/// {@category producer}
String findPluginName(String pathToRoot) =>
    pathToRoot.verifyExists.toPubspecYaml.pluginName;

/// Find plugin name in root/pubspec.yaml.
///
/// Returns value of element version.
///
/// {@category consumer}
/// {@category producer}
String findPluginVersion(String pathToRoot) =>
    pathToRoot.verifyExists.toPubspecYaml.pluginVersion;

/// Find the version of klutter bill-of-materials in root/kradle.yaml or return null.
///
/// {@category consumer}
/// {@category producer}
String? findKlutterBomVersion(String pathToRoot) =>
    pathToRoot.verifyExists.klutterBomVersionOrNull;

/// The plugin ClassName which is equal to the library name
/// converted to camelcase + 'Plugin' postfix if [postfixWithPlugin] is set to true.
///
/// Example:
/// Given [pluginName] 'super_awesome'
/// will return SuperAwesomePlugin.
///
/// Example:
/// Given [pluginName] 'super_awesome_plugin'
/// will return SuperAwesomePlugin.
///
/// {@category consumer}
/// {@category producer}
String toPluginClassName(String pluginName, {bool postfixWithPlugin = false}) {
  final className = pluginName
      .split("_")
      .map((e) => "${e[0].toUpperCase()}${e.substring(1, e.length)}")
      .join();

  return postfixWithPlugin ? className.postfixedWithPlugin : className;
}

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
///
/// {@category consumer}
/// {@category producer}
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
    return "\$root${Platform.pathSeparator}${relativeToRoot.trim()}${Platform.pathSeparator}android${Platform.pathSeparator}klutter";
  }

  /// Create an absolute path to the the default pub-cache folder.
  return cachePath.normalize;
}

/// Find applicable [FlutterDistribution] for the current
/// [OperatingSystem] and [Architecture] or throw [KlutterException].
FlutterDistribution toFlutterDistributionOrThrow({
  required VerifiedFlutterVersion version,
  required String pathToRoot,
}) {
  OperatingSystem? platform;

  if (version.os != null) {
    platform = version.os;
  } else if (Platform.isWindows) {
    platform = OperatingSystem.windows;
  } else if (Platform.isMacOS) {
    platform = OperatingSystem.macos;
  } else if (Platform.isLinux) {
    platform = OperatingSystem.linux;
  } else {
    throw KlutterException(
        "Current OS is not supported (supported: macos, windows or linux): ${Platform.operatingSystem}");
  }

  final arch = version.arch ??
      (Abi.current().toString().contains("arm")
          ? Architecture.arm64
          : Architecture.x64);

  return FlutterDistribution(
      version: version.version, os: platform!, arch: arch);
}

extension on String {
  /// Create a path to the root-project/.klutter-plugins file.
  /// If the file does not exist create it.
  File get toKlutterPlugins => File("$this/.klutter-plugins").normalizeToFile
    ..ifNotExists((file) => file.normalizeToFile.createSync());

  /// Create a path to the root-project/pubspec.yaml file.
  File get toPubspecYaml => File("$this/pubspec.yaml").normalizeToFile
    ..ifNotExists((_) =>
        throw KlutterException("Missing pubspec.yaml file in folder: $this"));

  String? get klutterBomVersionOrNull {
    final file = File("$this/kradle.yaml").normalizeToFile;
    if (!file.existsSync()) {
      return null;
    }

    final possibleKlutterBomVersion = file
        .readAsLinesSync()
        .map((line) => line.split(":"))
        .where((line) => line.length == 2)
        .firstWhere((line) => line[0].trim() == "bom-version",
            orElse: () => []);

    if (possibleKlutterBomVersion.length == 2) {
      return possibleKlutterBomVersion[1].trim().replaceAll("'", "");
    }

    return null;
  }
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
    final content = readAsStringSync().replaceAll(RegExp(r"\s+"), "");
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

/// Property used in kradle.env to retrieve the user home directory.
const kradleEnvPropertyUserHome = "{{system.user.home}}";

/// Helper methods to find configuration files used by kradle.
extension ProjectFile on Directory {
  /// Find the cache folder.
  ///
  /// Get cache property from [kradleEnv] file or default to {{system.user.home}}/.kradle/cache (see [kradleEnvPropertyUserHome]).
  Directory get kradleCache {
    final envFile = kradleEnv;

    if (!envFile.existsSync()) {
      return defaultKradleCache;
    }

    final cacheProperty = envFile.findCacheProperty;

    return cacheProperty == null
        ? envFile.defaultKradleCache
        : envFile.configuredKradleCache(cacheProperty);
  }

  /// File kradle.yaml which contains klutter project data.
  File get kradleYaml => resolveFile("kradle.yaml");

  /// File kradle.env which contains user-specific klutter project data.
  File get kradleEnv => resolveFile("kradle.env");
}

/// Error message indicating the user home directory could not be determined
/// by [_userHomeOrError] and no kradle.env file is found.
String _defaultKradleCacheErrorMessage(String pathToRoot, String envError) =>
    "Unable to determine kradle cache directory, because "
    "$envError and there is no kradle.env in $pathToRoot. "
    "Fix this issue by creating a kradle.env file in "
    "$pathToRoot with property 'cache=/path/to/your/cache/folder'";

/// Error message indicating the user home directory could not be determined
/// by [_userHomeOrError] and the kradle.env file does not have the cache property.
String _defaultKradleCacheBecauseCachePropertyNotFoundErrorMessage(
        String pathToRoot, String envError) =>
    "Unable to determine kradle cache directory, because "
    "property 'cache' is not found in $pathToRoot and $envError. "
    "Fix this issue by adding property "
    "'cache=/path/to/your/cache/folder' to $pathToRoot";

/// Error message indicating the user home directory could not be determined
/// by [_userHomeOrError] and the kradle.env has a cache property which points
/// to the user home directory.
String _configuredKradleHomeErrorMessage(String pathToRoot, String envError) =>
    "Unable to determine kradle cache directory, because "
    "property 'cache' in $pathToRoot "
    "contains system.user.home variable "
    "and $envError. Fix this issue by "
    "replacing $kradleEnvPropertyUserHome variable with "
    "an absolute path in $pathToRoot";

extension on Directory {
  /// Get the default kradle home directory
  /// which is the user home [_userHomeOrError]
  /// directory resolved by .kradle.
  ///
  /// Throws [KlutterException] if the directory
  /// is not resolved or does not exist.
  Directory get defaultKradleCache {
    final userHome = _userHomeOrError;

    final kradleHome = _kradleCacheFromEnvironmentPropertyOrNull(
      userHome.userHome,
    );

    final errorMessage = _defaultKradleCacheErrorMessage(
      absolutePath,
      userHome.error,
    );

    return _kradleCacheDirectoryOrThrow(
        kradleHome, () => throw KlutterException(errorMessage));
  }
}

extension on File {
  /// Get the default kradle home directory
  /// which is the user home [_userHomeOrError]
  /// directory resolved by .kradle, because
  /// the kradle.env file does not contain a
  /// cache property.
  ///
  /// Throws [KlutterException] if the directory
  /// is not resolved or does not exist.
  Directory get defaultKradleCache {
    final userHome = _userHomeOrError;
    return _kradleCacheDirectoryOrThrow(
        _kradleCacheFromEnvironmentPropertyOrNull(userHome.userHome), () {
      throw KlutterException(
          _defaultKradleCacheBecauseCachePropertyNotFoundErrorMessage(
              absolutePath, userHome.error));
    });
  }

  /// Get the kradle home directory from the kradle.env
  /// file and resolve {{user.home}} variable with [_userHomeOrError].
  ///
  ///
  /// Throws [KlutterException] if the directory
  /// is not resolved or does not exist.
  Directory configuredKradleCache(String cacheProperty) {
    if (cacheProperty.contains(kradleEnvPropertyUserHome)) {
      final userHome = _userHomeOrError;
      final cachePropertyResolved = userHome.userHome != null
          ? cacheProperty.replaceAll(
              kradleEnvPropertyUserHome, userHome.userHome!)
          : null;

      return _kradleCacheDirectoryOrThrow(
        cachePropertyResolved,
        () => throw KlutterException(
          _configuredKradleHomeErrorMessage(
            absolutePath,
            userHome.error,
          ),
        ),
      );
    }

    return _kradleCacheDirectoryOrThrow(cacheProperty, () {});
  }

  /// Return value of property cache or null.
  String? get findCacheProperty {
    final properties =
        readAsLinesSync().where(_startsWithCache).map(_extractPropertyValue);
    return properties.isEmpty ? null : properties.first;
  }
}

bool _startsWithCache(String test) => test.startsWith("cache=");

String _extractPropertyValue(String line) =>
    line.substring(line.indexOf("=") + 1, line.length).trim();

String? _kradleCacheFromEnvironmentPropertyOrNull(String? userHomeOrNull) =>
    userHomeOrNull == null ? null : "$userHomeOrNull/.kradle/cache".normalize;

/// Returns the kradle cache directory or throws a [KlutterException]
/// if the directory could not be determined or if it does not exist.
Directory _kradleCacheDirectoryOrThrow(
  String? pathToKradleCache,
  void Function() onNullValue,
) {
  if (pathToKradleCache == null) {
    onNullValue();
  }

  return Directory(pathToKradleCache!.normalize).normalizeToFolder
    ..verifyFolderExists;
}

/// Determine the user home directory by checking environment variables.
///
/// For linux and macos the value of 'HOME' is returned.
/// For windows the value of 'USERPROFILE' is returned.
/// Will return an error message if
/// the operating systems is unsupported
/// or if the mentioned variables are not set.
_UserHomeResult get _userHomeOrError {
  switch (platform.operatingSystem) {
    case "linux":
    case "macos":
      return _UserHomeResult(platform.environment["HOME"],
          "environment variable 'HOME' is not defined");
    case "windows":
      return _UserHomeResult(platform.environment["USERPROFILE"],
          "environment variable 'USERPROFILE' is not defined");
    default:
      return _UserHomeResult(null,
          "method 'userHome' is not supported on ${platform.operatingSystem}");
  }
}

class _UserHomeResult {
  const _UserHomeResult(this.userHome, this.error);

  final String? userHome;

  final String error;
}
