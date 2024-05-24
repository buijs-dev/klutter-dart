import "package:meta/meta.dart";

import "../../klutter.dart";

/// The version of the Klutter Pub Plugin.
const klutterPubVersion = "3.0.2";

/// The version of the Klutter UI Pub Plugin.
const klutterUIPubVersion = "1.1.0";

/// The version of the squint_json Pub Plugin.
const squintPubVersion = "0.1.2";

/// The version of the Klutter Gradle Plugin.
const klutterGradleVersion = "2024.1.3.beta";

/// The default Flutter version to be used in the Klutter project.
const klutterFlutterVersion = "3.10.6";

/// The version of Kotlin to be used.
const kotlinVersion = "1.9.10";

/// The minimum SDK version for Android.
const androidMinSdk = 24;

/// The compile SDK version for Android.
const androidCompileSdk = 33;

/// The minimum iOS version.
const iosVersion = 13.0;

/// Flutter SDK versions which can be used for a Producer project.
const supportedFlutterVersions = {
  "3.0.5": Version(major: 3, minor: 0, patch: 5),
  "3.3.10": Version(major: 3, minor: 3, patch: 10),
  "3.7.12": Version(major: 3, minor: 7, patch: 12),
  "3.10.6": Version(major: 3, minor: 10, patch: 6),
};

/// Verify if version input is valid.
extension VersionVerifier on String {
  /// Verify if the version matches:
  /// 4 digits dot 1 or 2 digits dot 1 or 2 digits and optionally a dot plus postfix.
  ///
  /// Examples:
  /// - 2023.3.1.beta
  /// - 2024.2.15
  String? get verifyBomVersion {
    final regex =
        RegExp(r"""([0-9]){4}[\\.][0-9]{1,2}[\\.][0-9]{1,2}([\\.]\w+|)$""");
    if (regex.firstMatch(this) == null) {
      return null;
    } else {
      return this;
    }
  }

  /// Verify if the version is in format
  /// major.minor.patch or
  /// major.minor.patch.os.arch.
  ///
  /// Examples:
  /// - 3.10.6
  /// - 2.16.77
  /// - 2.16.77.windows.x64
  VerifiedFlutterVersion? get verifyFlutterVersion {
    final version = supportedFlutterVersions[this];
    if (version != null) {
      return VerifiedFlutterVersion(version);
    }

    for (final os in OperatingSystem.values) {
      for (final arch in Architecture.values) {
        for (final version in supportedFlutterVersions.values) {
          if (this == "${version.prettyPrint}.${os.name}.${arch.name}") {
            return VerifiedFlutterVersion(version, os: os, arch: arch);
          }
        }
      }
    }

    return null;
  }
}

/// Wrapper for [VersionVerifier.verifyFlutterVersion] result.
class VerifiedFlutterVersion {
  /// Construct a new instance of [VerifiedFlutterVersion].
  const VerifiedFlutterVersion(this.version, {this.os, this.arch});

  /// The Flutter version in format major.minor.patch.
  final Version version;

  /// The OperatingSystem extracted from the version String.
  final OperatingSystem? os;

  /// The Architecture extracted from the version String.
  final Architecture? arch;

  @override
  String toString() => "VerifiedFlutterVersion($version, $os, $arch)";
}

/// Version data class.
@immutable
class Version implements Comparable<Version> {
  /// Create a new [Version] instance.
  const Version({
    required this.major,
    required this.minor,
    required this.patch,
  });

  /// Create a new [Version] instance from a [prettyPrint] String.
  factory Version.fromString(String prettyPrintedString) {
    final regex = RegExp(r"^(\d+[.]\d+[.]\d+$)");
    if (!regex.hasMatch(prettyPrintedString)) {
      throw KlutterException(
          "String is not formatted as expected (major.minor.patch.os.arch): $prettyPrintedString");
    }

    final data = prettyPrintedString.split(".");
    return Version(
        major: int.parse(data[0]),
        minor: int.parse(data[1]),
        patch: int.parse(data[2]));
  }

  /// Major version which is the first part of a version.
  ///
  /// A major version change indicates breaking changes.
  final int major;

  /// Minor version which is the middle part of a version.
  ///
  /// A minor version change indicates backwards-compatible features added.
  final int minor;

  /// Path version which is the last part of a version.
  ///
  /// A patch version change indicates technical changes or bug fixes.
  final int patch;

  /// Return formatted version string.
  String get prettyPrint => "$major.$minor.$patch";

  @override
  String toString() => "Version($prettyPrint)";

  @override
  bool operator ==(Object other) {
    if (other is! Version) {
      return false;
    }

    if (other.major != major) {
      return false;
    }

    if (other.minor != minor) {
      return false;
    }

    return other.patch == patch;
  }

  @override
  int get hashCode => major;

  @override
  int compareTo(Version other) {
    if (major != other.major) {
      return other.major.compareTo(major);
    }

    if (minor != other.minor) {
      return other.minor.compareTo(minor);
    }

    return other.patch.compareTo(patch);
  }
}
