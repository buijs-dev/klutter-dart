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

import "package:meta/meta.dart";

import "../common/common.dart";
import "cli.dart";
import "context.dart";

/// Task to download a Flutter SDK to Klutter cache.
///
/// {@category consumer}
/// {@category producer}
class GetFlutterSDK extends Task {
  /// Create new Task.
  GetFlutterSDK()
      : super(TaskName.get, {
          TaskOption.flutter: FlutterVersionOption(),
          TaskOption.overwrite: OverwriteOption(),
          TaskOption.dryRun: DryRunOption(),
          TaskOption.root: RootDirectoryInput(),
        });

  @override
  Future<void> toBeExecuted(
      Context context, Map<TaskOption, dynamic> options) async {
    final pathToRoot = findPathToRoot(context, options);
    final flutterVersion =
        options[TaskOption.flutter] as VerifiedFlutterVersion;
    final overwrite = options[TaskOption.overwrite] as bool;
    final dist = toFlutterDistributionOrThrow(
        version: flutterVersion, pathToRoot: pathToRoot);
    final cache = Directory(pathToRoot.normalize).kradleCache..maybeCreate;
    final target = cache.resolveFolder("${dist.folderNameString}");
    if (requiresDownload(target, overwrite)) {
      final endpoint = downloadEndpointOrThrow(dist);
      if (!skipDownload(options[TaskOption.dryRun])) {
        final zip = target.resolveFile("flutter.zip")
          ..maybeDelete
          ..createSync();
        await downloadOrThrow(endpoint, zip, target);
      }
    }
  }

  /// Skip downloading the flutter sdk if true.
  ///
  /// Is true when:
  /// - environment contains property GET_FLUTTER_SDK_SKIP
  /// - context [Context] contains [TaskOption.dryRun] with value true
  ///
  /// Defaults to false and will download flutter sdk.
  bool skipDownload(dynamic dryRun) =>
      Platform.environment["GET_FLUTTER_SDK_SKIP"] != null || dryRun == true;

  /// Downloading the sdk is not required when the sdk
  /// already exists and [TaskOption.overwrite] is false.
  bool requiresDownload(Directory directory, bool overwrite) =>
      !directory.existsSync() || overwrite;

  /// Download the flutter sdk or throw [KlutterException] on failure.
  Future<void> downloadOrThrow(
      String endpoint, File zip, Directory target) async {
    await download(endpoint, zip);
    if (zip.existsSync()) {
      await unzip(zip, target..maybeCreate);
      zip.deleteSync();
    }

    if (!target.existsSync()) {
      throw KlutterException("Failed to download Flutter SDK");
    }
  }

  /// Get url to the flutter distribution or throw [KlutterException].
  String downloadEndpointOrThrow(FlutterDistribution dist) =>
      _compatibleFlutterVersions[dist] ??
      (throw KlutterException(
          "Failed to determine download URL for Flutter SDK: ${dist.prettyPrintedString}"));
}

Map<FlutterDistribution, String> get _compatibleFlutterVersions {
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

  final versions = <FlutterDistribution, String>{};

  for (final entry in dist) {
    versions[entry.key] = entry.value;
  }

  return versions;
}

/// A flutter distribution which is compatible with klutter.
@immutable
class FlutterDistribution {
  /// Create a new [FlutterDistribution] instance.
  const FlutterDistribution({
    required this.version,
    required this.os,
    required this.arch,
  });

  /// The version in format major.minor.patch.
  final Version version;

  /// The operating system.
  final OperatingSystem os;

  /// The architecture.
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
    if (other is! FlutterDistribution) {
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

MapEntry<FlutterDistribution, String> _windows(String path, String version) =>
    MapEntry(
        FlutterDistribution(
            os: OperatingSystem.windows,
            arch: Architecture.x64,
            version: Version.fromString(version)),
        path);

MapEntry<FlutterDistribution, String> _linux(String path, String version) =>
    MapEntry(
        FlutterDistribution(
            os: OperatingSystem.linux,
            arch: Architecture.x64,
            version: Version.fromString(version)),
        path);

MapEntry<FlutterDistribution, String> _macosX64(String path, String version) =>
    MapEntry(
        FlutterDistribution(
            os: OperatingSystem.macos,
            arch: Architecture.x64,
            version: Version.fromString(version)),
        path);

MapEntry<FlutterDistribution, String> _macosArm64(
        String path, String version) =>
    MapEntry(
        FlutterDistribution(
            os: OperatingSystem.macos,
            arch: Architecture.arm64,
            version: Version.fromString(version)),
        path);
