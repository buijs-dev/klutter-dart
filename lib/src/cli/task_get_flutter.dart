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

import "dart:ffi";
import "dart:io";

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
    final skip = Platform.environment["GET_FLUTTER_SDK_SKIP"] != null;
    if (skip) {
      return;
    }

    final validFlutterVersionOrNull =
        options[ScriptOption.flutter]?.verifyFlutterVersion;

    if (validFlutterVersionOrNull == null) {
      throw KlutterException(
          "Invalid Flutter version (supported versions are: $supportedFlutterVersions): $this");
    }

    _OperatingSystem? platform;

    if (Platform.isWindows) {
      platform = _OperatingSystem.windows;
    } else if (Platform.isMacOS) {
      platform = _OperatingSystem.macos;
    } else if (Platform.isLinux) {
      platform = _OperatingSystem.linux;
    } else {
      throw KlutterException(
          "Current OS is not supported (supported: macos, windows or linux): ${Platform.operatingSystem}");
    }

    final cache = defaultKradleCacheFolder..maybeCreate;
    final arch = Abi.current().toString().contains("arm")
        ? _Architecture.arm64
        : _Architecture.x64;
    final prettyPrintedSdk =
        "$validFlutterVersionOrNull.${platform.name}.${arch.name}"
            .toLowerCase();
    final cachedSDK = cache.resolveFolder(prettyPrintedSdk);

    if (!cachedSDK.resolveFolder("flutter").existsSync()) {
      cachedSDK.createSync();
      final dist = _FlutterDistribution(
          version: validFlutterVersionOrNull, os: platform, arch: arch);
      final url = _compatibleFlutterVersions[dist];

      if (url == null) {
        throw KlutterException(
            "Failed to determine download URL for Flutter SDK: $validFlutterVersionOrNull $platform $arch");
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
        "producer get flutter=<version> (one of versions: $supportedFlutterVersions)",
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

class _FlutterDistribution {
  const _FlutterDistribution({
    required this.version,
    required this.os,
    required this.arch,
  });
  final String version;
  final _OperatingSystem os;
  final _Architecture arch;

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

enum _OperatingSystem {
  windows,
  macos,
  linux;
}

enum _Architecture {
  x64,
  arm64,
}

MapEntry<_FlutterDistribution, String> _windows(String path, String version) =>
    MapEntry(
        _FlutterDistribution(
            os: _OperatingSystem.windows,
            arch: _Architecture.x64,
            version: version),
        path);

MapEntry<_FlutterDistribution, String> _linux(String path, String version) =>
    MapEntry(
        _FlutterDistribution(
            os: _OperatingSystem.linux,
            arch: _Architecture.x64,
            version: version),
        path);

MapEntry<_FlutterDistribution, String> _macosX64(String path, String version) =>
    MapEntry(
        _FlutterDistribution(
            os: _OperatingSystem.macos,
            arch: _Architecture.x64,
            version: version),
        path);

MapEntry<_FlutterDistribution, String> _macosArm64(
        String path, String version) =>
    MapEntry(
        _FlutterDistribution(
            os: _OperatingSystem.macos,
            arch: _Architecture.arm64,
            version: version),
        path);
