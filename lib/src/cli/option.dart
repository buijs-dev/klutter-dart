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

import "../common/common.dart";
import "context.dart";

class RequiredUserInputString extends RequiredUserInput<String> {
  const RequiredUserInputString(this.description);

  final String description;

  String convertOrThrow(String value) => value;
}

class UserInputBooleanOrDefault extends UserInputOrDefault<bool> {
  const UserInputBooleanOrDefault(this.description, super.defaultValue);

  final String description;

  bool convertOrThrow(String value) {
    switch (value.trim().toUpperCase()) {
      case "TRUE":
        return true;
      case "FALSE":
        return false;
      default:
        throw InputException("expected a bool value but received: $value");
    }
  }
}

abstract class RequiredUserInput<T> extends Input<T> {
  const RequiredUserInput();
}

abstract class UserInputOrDefault<T> extends Input<T> {
  const UserInputOrDefault(this.defaultValue);

  final T defaultValue;

  String get defaultValueToString => defaultValue.toString();
}

abstract class Input<T> {
  const Input();

  /// Throws [InputException].
  T convertOrThrow(String value);

  String get description;
}

class InputException implements Exception {
  /// Create instance of [InputException] with a message [cause].
  InputException(this.cause);

  /// Message explaining the cause of the exception.
  String cause;

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
  String get description => "the klutter project root directory";
}

class FlutterVersionOption extends UserInputOrDefault<VerifiedFlutterVersion> {
  FlutterVersionOption() : super("3.10.6".verifyFlutterVersion!);

  @override
  String get description =>
      "the flutter sdk version in format major.minor.patch";

  @override
  String get defaultValueToString => defaultValue.version.prettyPrint;

  @override
  VerifiedFlutterVersion convertOrThrow(String value) =>
      value.verifyFlutterVersion ??
      (throw InputException(
          "invalid flutter version (supported versions are: ${supportedFlutterVersions.keys}): $value"));
}

class OverwriteOption extends UserInputBooleanOrDefault {
  OverwriteOption()
      : super("overwrite existing distribution when found", false);
}

class DryRunOption extends UserInputBooleanOrDefault {
  DryRunOption() : super("skip downloading of libraries", false);
}

class LibraryName extends RequiredUserInputString {
  const LibraryName() : super("name of the library to add");
}

class SquintPubVersion extends UserInputOrDefault<String> {
  const SquintPubVersion() : super(squintPubVersion);

  @override
  String get description => "the squint_json pub version";

  @override
  String convertOrThrow(String value) => value;
}

class KlutterPubVersion extends UserInputOrDefault<String> {
  const KlutterPubVersion() : super(klutterPubVersion);

  @override
  String get description => "the klutter pub version";

  @override
  String convertOrThrow(String value) => value;
}

class KlutteruiPubVersion extends UserInputOrDefault<String> {
  const KlutteruiPubVersion() : super(klutterUIPubVersion);

  @override
  String get description => "the klutter_ui pub version";

  @override
  String convertOrThrow(String value) => value;
}

class KlutterGradleVersionOption extends UserInputOrDefault<String> {
  const KlutterGradleVersionOption() : super(klutterGradleVersion);

  @override
  String get description => "the klutter gradle version";

  @override
  String convertOrThrow(String value) =>
      value.verifyBomVersion ??
      (throw InputException("not a valid bom version: $value"));
}

class PluginNameOption extends UserInputOrDefault<String> {
  const PluginNameOption() : super("my_plugin");

  @override
  String get description => "the plugin name";

  @override
  String convertOrThrow(String value) {
    if (!RegExp(r"""^[a-z][a-z0-9_]+$""").hasMatch(value)) {
      throw KlutterException("pluginName error: Should only contain"
          " lowercase alphabetic, numeric and or _ characters"
          " and start with an alphabetic character ('my_plugin').");
    }
    return value;
  }
}

class GroupNameOption extends UserInputOrDefault<String> {
  GroupNameOption() : super("dev.buijs.klutter.example");

  @override
  String get description => "the plugin group name";

  @override
  String convertOrThrow(String value) {
    if (!value.contains(".")) {
      throw InputException(
          "GroupName error: Should contain at least 2 parts ('com.example').");
    }

    if (value.contains("_.")) {
      throw InputException(
          "GroupName error: Characters . and _ can not precede each other.");
    }

    if (value.contains("._")) {
      throw InputException(
          "GroupName error: Characters . and _ can not precede each other.");
    }

    if (!RegExp(r"""^[a-z][a-z0-9._]+[a-z]$""").hasMatch(value)) {
      throw InputException(
          "GroupName error: Should be lowercase alphabetic separated by dots ('com.example').");
    }

    return value;
  }
}
