// Copyright (c) 2021 - 2024 Buijs Software
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

import "../common/common.dart";
import "context.dart";

/// An option containing a String value which should be declared by the user.
///
/// For this option no defaults can be set.
class RequiredUserInputString extends RequiredUserInput<String> {
  /// Construct a new [RequiredUserInputString] instance.
  const RequiredUserInputString(this.description);

  @override
  final String description;

  @override
  String convertOrThrow(String value) => value;
}

/// An option containing a bool value which has a default value.
class UserInputBooleanOrDefault extends UserInputOrDefault<bool> {
  /// Construct a new [RequiredUserInputString] instance.
  const UserInputBooleanOrDefault(this.description, super.defaultValue);

  @override
  final String description;

  static const _map = {"TRUE": true, "FALSE": false};

  @override
  bool convertOrThrow(String value) =>
      _map[value.trim().toUpperCase()] ??
      (throw InputException("expected a bool value but received: $value"));
}

/// An option containing a value which should be declared by the user.
///
/// For this option no defaults can be set.
abstract class RequiredUserInput<T> extends Input<T> {
  /// Construct a new [RequiredUserInput] instance.
  const RequiredUserInput();
}

/// An option containing a [T] value which has a default value.
abstract class UserInputOrDefault<T> extends Input<T> {
  /// Construct a new [UserInputOrDefault] instance.
  const UserInputOrDefault(this.defaultValue);

  /// Default value [T] which is returned when user did not specify the option.
  final T defaultValue;

  /// Get the [T] defaultValue as String.
  ///
  /// Can be overwritten by extending class to apply custom serialization.
  String get defaultValueToString => defaultValue.toString();
}

/// An option containing a [T] value.
abstract class Input<T> {
  /// Construct a new [Input] instance.
  const Input();

  /// Convert a String value to type [T] or throw [InputException].
  T convertOrThrow(String value);

  /// A description for this option.
  String get description;
}

/// Exception indicating an error in the user input.
///
/// This exception occurs when the user input can not be mapped to [Input].
class InputException extends KlutterException {
  /// Create instance of [InputException] with a message [cause].
  const InputException(super.cause);

  @override
  String toString() => "InputException with cause: '$cause'";
}

/// The root directory input option.
class RootDirectoryInput
    extends UserInputOrDefault<Directory Function(Context)> {
  /// Create a new [RootDirectoryInput] instance
  /// which uses the [Context.workingDirectory] as default value.
  RootDirectoryInput() : super((context) => context.workingDirectory);

  @override
  Directory Function(Context) convertOrThrow(String value) =>
      (context) => Directory(value).normalizeToDirectory;

  @override
  String get defaultValueToString => "current working directory";

  @override
  String get description => "klutter project root directory";
}

/// Option specifying the flutter version to use.
///
/// Containing a [VerifiedFlutterVersion] value which defaults to flutter 3.10.6.
class FlutterVersionOption extends UserInputOrDefault<VerifiedFlutterVersion> {
  /// Construct a new [FlutterVersionOption] instance with default value of 3.10.6.
  FlutterVersionOption() : super("3.10.6".verifyFlutterVersion!);

  @override
  String get description => "flutter sdk version in format major.minor.patch";

  @override
  String get defaultValueToString => defaultValue.version.prettyPrint;

  @override
  VerifiedFlutterVersion convertOrThrow(String value) =>
      value.verifyFlutterVersion ??
      (throw InputException(
          "invalid flutter version (supported versions are: ${supportedFlutterVersions.keys}): $value"));
}

/// Option to allow overwriting existing entities which defaults to false.
class OverwriteOption extends UserInputBooleanOrDefault {
  /// Construct a new [OverwriteOption] instance.
  OverwriteOption()
      : super("overwrite existing distribution when found", false);
}

/// Option to skip download actions which defaults to false.
///
/// This options is used for testing download actions.
class DryRunOption extends UserInputBooleanOrDefault {
  /// Construct a new [DryRunOption] instance.
  DryRunOption() : super("skip downloading of libraries", false);
}

/// Option to specify a klutter library name which has no default.
class LibraryName extends RequiredUserInputString {
  /// Construct a new [LibraryName] instance.
  const LibraryName() : super("name of the library to add");
}

/// Option to specify squint_json version which defaults to [squintPubVersion].
class SquintPubVersion extends UserInputOrDefault<String> {
  /// Construct a new [SquintPubVersion] instance with default value [squintPubVersion].
  const SquintPubVersion() : super(squintPubVersion);

  @override
  String get description => "squint_json pub version";

  @override
  String convertOrThrow(String value) => value;
}

/// Option to specify klutter (dart) version which defaults to [klutterPubVersion].
class KlutterPubVersion extends UserInputOrDefault<String> {
  /// Construct a new [KlutterPubVersion] instance with default value [klutterPubVersion].
  const KlutterPubVersion() : super(klutterPubVersion);

  @override
  String get description => "klutter pub version";

  @override
  String convertOrThrow(String value) => value;
}

/// Option to specify klutter_ui (dart) version which defaults to [klutterUIPubVersion].
class KlutteruiPubVersion extends UserInputOrDefault<String> {
  /// Construct a new [KlutteruiPubVersion] instance with default value [klutterUIPubVersion].
  const KlutteruiPubVersion() : super(klutterUIPubVersion);

  @override
  String get description => "klutter_ui pub version";

  @override
  String convertOrThrow(String value) => value;
}

/// Option to specify klutter (gradle) version which defaults to [klutterGradleVersion].
class KlutterGradleVersionOption extends UserInputOrDefault<String> {
  /// Construct a new [KlutterGradleVersionOption] instance with default value [klutterGradleVersion].
  const KlutterGradleVersionOption() : super(klutterGradleVersion);

  @override
  String get description => "klutter gradle version";

  @override
  String convertOrThrow(String value) =>
      value.verifyBomVersion ??
      (throw InputException("not a valid bom version: $value"));
}

/// Option to specify plugin_name which defaults to my_plugin.
class PluginNameOption extends UserInputOrDefault<String> {
  /// Construct a new [PluginNameOption] instance with default value my_plugin.
  const PluginNameOption() : super("my_plugin");

  @override
  String get description => "plugin name";

  @override
  String convertOrThrow(String value) {
    if (!RegExp(r"""^[a-z][a-z0-9_]+$""").hasMatch(value)) {
      throw const InputException("pluginName error: Should only contain"
          " lowercase alphabetic, numeric and or _ characters"
          " and start with an alphabetic character ('my_plugin').");
    }
    return value;
  }
}

/// Option to specify group_name which defaults to dev.buijs.klutter.example.
class GroupNameOption extends UserInputOrDefault<String> {
  /// Construct a new [GroupNameOption] instance with default value dev.buijs.klutter.example.
  const GroupNameOption() : super("dev.buijs.klutter.example");

  @override
  String get description => "plugin group name";

  @override
  String convertOrThrow(String value) {
    if (!value.contains(".")) {
      throw const InputException(
          "GroupName error: Should contain at least 2 parts ('com.example').");
    }

    if (value.contains("_.")) {
      throw const InputException(
          "GroupName error: Characters . and _ can not precede each other.");
    }

    if (value.contains("._")) {
      throw const InputException(
          "GroupName error: Characters . and _ can not precede each other.");
    }

    if (!RegExp(r"""^[a-z][a-z0-9._]+[a-z]$""").hasMatch(value)) {
      throw const InputException(
          "GroupName error: Should be lowercase alphabetic separated by dots ('com.example').");
    }

    return value;
  }
}
