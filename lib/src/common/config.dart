import "../cli/task_get_flutter.dart";

/// The version of the Klutter Pub Plugin.
const klutterPubVersion = "2.0.0";

/// The version of the Klutter Gradle Plugin.
const klutterGradleVersion = "2023.3.1.beta";

/// The default Flutter version to be used in the Klutter project.
const klutterFlutterVersion = "3.10.6";

/// The version of Kotlin to be used.
const kotlinVersion = "1.8.20";

/// The minimum SDK version for Android.
const androidMinSdk = 24;

/// The compile SDK version for Android.
const androidCompileSdk = 33;

/// Flutter SDK versions which can be used for a Producer project.
const supportedFlutterVersions = {"3.0.5", "3.3.10", "3.7.12", "3.10.6"};

/// Verify if version input is valid.
extension VersionVerifier on String {
  /// Verify if the version matches:
  /// 4 digits dot 1 or 2 digits dot 1 or 2 digits and optionally  a dot plus postfix.
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

  /// Verify if the version matches:
  /// 1 or 2 digits dot 1 or 2 digits dot 1 or 2 digits.
  ///
  /// Examples:
  /// - 3.10.6
  /// - 2.16.77
  VerifiedFlutterVersion? get verifyFlutterVersion {
    if (supportedFlutterVersions.contains(this)) {
      return VerifiedFlutterVersion(this);
    }

    for (final os in OperatingSystem.values) {
      for (final arch in Architecture.values) {
        for (final version in supportedFlutterVersions) {
          if (this == "$version.${os.name}.${arch.name}") {
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
  final String version;

  /// The OperatingSystem extracted from the version String.
  final OperatingSystem? os;

  /// The Architecture extracted from the version String.
  final Architecture? arch;
}
