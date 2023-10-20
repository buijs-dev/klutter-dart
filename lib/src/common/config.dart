/// The version of the Klutter Pub Plugin.
const klutterPubVersion = "2.0.0";

/// The version of the Klutter Gradle Plugin.
const klutterGradleVersion = "2023.3.1.beta";

/// The default Flutter version to be used in the Klutter project.
const klutterFlutterVersion = "3.10.6";

/// The version of Kotlin to be used.
const kotlinVersion = "1.8.20";

/// The minimum SDK version for Android.
const androidMinSdk = 21;

/// The target SDK version for Android.
const androidTargetSdk = 31;

/// The compile SDK version for Android.
const androidCompileSdk = 31;

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
  String? get verifyFlutterVersion {
    if (supportedFlutterVersions.contains(this)) {
      return this;
    } else {
      return null;
    }
  }
}
