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

import "package:meta/meta.dart";

import "../common/common.dart";
import "../producer/kradle.dart";
import "cli.dart";

/// Task to download a Flutter SDK to Klutter cache.
///
/// {@category consumer}
/// {@category producer}
class GetFlutterSDK extends Task {
  /// Create new Task.
  GetFlutterSDK() : super(ScriptName.producer, TaskName.get);

  @override
  Future<void> toBeExecuted(String pathToRoot) async {
    final flutterVersion = options[ScriptOption.flutter]?.verifyFlutterVersion;

    if (flutterVersion == null) {
      throw KlutterException(
          "Invalid Flutter version (supported versions are: ${supportedFlutterVersions.keys}): $flutterVersion");
    }

    OperatingSystem? platform;

    if (flutterVersion.os != null) {
      platform = flutterVersion.os;
    } else if (Platform.isWindows) {
      platform = OperatingSystem.windows;
    } else if (Platform.isMacOS) {
      platform = OperatingSystem.macos;
    } else if (Platform.isLinux) {
      platform = OperatingSystem.linux;
    }

    if (platform == null) {
      throw KlutterException(
          "Current OS is not supported (supported: macos, windows or linux): ${Platform.operatingSystem}");
    }

    final cache = defaultKradleCacheFolder..maybeCreate;
    final arch = flutterVersion.arch ??
        (Abi.current().toString().contains("arm")
            ? Architecture.arm64
            : Architecture.x64);

    final dist = _FlutterDistribution(
        version: flutterVersion.version, os: platform, arch: arch);

    final cachedSDK = cache.resolveFolder("${dist.folderNameString}");

    if (!cachedSDK.resolveFolder("flutter").existsSync()) {
      cachedSDK.createSync();

      final url = _compatibleFlutterVersions[dist];

      if (url == null) {
        throw KlutterException(
            "Failed to determine download URL for Flutter SDK: ${dist.prettyPrintedString}");
      }

      final skip = Platform.environment["GET_FLUTTER_SDK_SKIP"] != null ||
          options[ScriptOption.dryRun] == "true";

      if (skip) {
        return;
      }

      final zip = cachedSDK.resolveFile("flutter.zip")
        ..maybeDelete
        ..createSync();

      await download(url, zip);
      if (zip.existsSync()) {
        await unzip(zip, cachedSDK);
        zip.deleteSync();
      }
    }

    if (!cachedSDK.existsSync()) {
      throw KlutterException("Failed to download Flutter SDK");
    }
  }

  @override
  List<String> exampleCommands() => [
        "producer get flutter=<version> (one of versions: ${supportedFlutterVersions.keys})",
      ];
}

Map<_FlutterDistribution, String> get _compatibleFlutterVersions {
  final dist = [
    _windows(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.0.5-stable.zip",
        "3.0.5"),
    _windows(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.3.10-stable.zip",
        "3.3.10"),
    _windows(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.7.12-stable.zip",
        "3.7.12"),
    _windows(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.10.6-stable.zip",
        "3.10.6"),
    _linux(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.0.5-stable.tar.xz",
        "3.0.5"),
    _linux(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.3.10-stable.tar.xz",
        "3.3.10"),
    _linux(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.7.12-stable.tar.xz",
        "3.7.12"),
    _linux(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.6-stable.tar.xz",
        "3.10.6"),
    _macosX64(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.0.5-stable.zip",
        "3.0.5"),
    _macosX64(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.3.10-stable.zip",
        "3.3.10"),
    _macosX64(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.7.12-stable.zip",
        "3.7.12"),
    _macosX64(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.10.6-stable.zip",
        "3.10.6"),
    _macosArm64(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.0.5-stable.zip",
        "3.0.5"),
    _macosArm64(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.3.10-stable.zip",
        "3.3.10"),
    _macosArm64(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.7.12-stable.zip",
        "3.7.12"),
    _macosArm64(
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.10.6-stable.zip",
        "3.10.6"),
  ];

  final versions = <_FlutterDistribution, String>{};
  for (final entry in dist) {
    versions[entry.key] = entry.value;
  }

  return versions;
}

@immutable
class _FlutterDistribution {
  const _FlutterDistribution({
    required this.version,
    required this.os,
    required this.arch,
  });

  final Version version;
  final OperatingSystem os;
  final Architecture arch;

  @override
  String toString() => "FlutterDistribution $prettyPrintedString";

  /// Generate a unique display name for this Flutter configuration.
  ///
  /// Example: "3.0.5 (MACOS ARM64)".
  PrettyPrintedFlutterDistribution get prettyPrintedString =>
      PrettyPrintedFlutterDistribution(
          "${version.prettyPrint} (${os.name} ${arch.name})");

  /// Generate a unique folder name for this Flutter configuration.
  ///
  /// Example: "3.0.5.macos.arm64".
  FlutterDistributionFolderName get folderNameString =>
      FlutterDistributionFolderName(
          "${version.prettyPrint}.${os.name}.${arch.name}");

  @override
  bool operator ==(Object other) {
    if (other is! _FlutterDistribution) {
      return false;
    }

    if (other.version != version) {
      return false;
    }

    if (other.os.name != os.name) {
      return false;
    }

    if (other.arch.name != arch.name) {
      return false;
    }

    return true;
  }

  @override
  int get hashCode => version.hashCode + os.index + arch.index;
}

///The full Flutter distribution version in format major.minor.patch (platform architecture).
///
/// Example: 3.0.5 MACOS (ARM64).
@immutable
class PrettyPrintedFlutterDistribution {
  /// Create a new [PrettyPrintedFlutterDistribution] instance.
  const PrettyPrintedFlutterDistribution(this.source);

  /// The formatted string representation for a specific distribution.
  ///
  /// Example: 3.0.5 MACOS (ARM64).
  final String source;

  @override
  String toString() => source;
}

/// The full Flutter distribution version in format major.minor.patch.platform.architecture.
///
/// Example: 3.0.5.windows.x64.
@immutable
class FlutterDistributionFolderName {
  /// Create a new [FlutterDistributionFolderName] instance.
  const FlutterDistributionFolderName(this.source);

  /// The formatted string representation for a specific distribution.
  ///
  /// To be used as folder name.
  ///
  /// Example: 3.0.5 MACOS (ARM64).
  final String source;

  @override
  String toString() => source;
}

/// The operating system compatible with Klutter.
enum OperatingSystem {
  /// Microsoft Windows.
  windows,

  /// Apple Mac OS.
  macos,

  /// Our favorite penguin.
  linux;
}

/// The CPU instruction set.
enum Architecture {
  /// AMD/Intel.
  x64,

  /// ARM based architecture (Apple M2).
  arm64,
}

MapEntry<_FlutterDistribution, String> _windows(String path, String version) =>
    MapEntry(
        _FlutterDistribution(
            os: OperatingSystem.windows,
            arch: Architecture.x64,
            version: Version.fromString(version)),
        path);

MapEntry<_FlutterDistribution, String> _linux(String path, String version) =>
    MapEntry(
        _FlutterDistribution(
            os: OperatingSystem.linux,
            arch: Architecture.x64,
            version: Version.fromString(version)),
        path);

MapEntry<_FlutterDistribution, String> _macosX64(String path, String version) =>
    MapEntry(
        _FlutterDistribution(
            os: OperatingSystem.macos,
            arch: Architecture.x64,
            version: Version.fromString(version)),
        path);

MapEntry<_FlutterDistribution, String> _macosArm64(
        String path, String version) =>
    MapEntry(
        _FlutterDistribution(
            os: OperatingSystem.macos,
            arch: Architecture.arm64,
            version: Version.fromString(version)),
        path);
