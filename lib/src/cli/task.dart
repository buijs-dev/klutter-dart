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

import "../common/exception.dart";
import "cli.dart";
import "context.dart";

/// Interface to encapsulate CLI task functionality.
abstract class Task<T> {
  /// Create a new [Task].
  Task(this.taskName, this.taskOptions);

  /// The name of this task.
  final TaskName taskName;

  /// All acceptable options for this [taskName].
  final Map<TaskOption, Input> taskOptions;

  /// Task logic implemented by the child class which will be executed.
  Future<T> toBeExecuted(Context context, Map<TaskOption, dynamic> options);

  /// Execute the task.
  Future<TaskResult<T>> execute(Context context) async {
    try {
      final output = await toBeExecuted(context, _getOptions(context));
      return TaskResult(isOk: true, output: output);
    } on KlutterException catch (e) {
      return TaskResult(isOk: false, message: e.cause);
    }
  }

  /// The validated options.
  ///
  /// Returns a map with each option having a value either
  /// as given by the user of a default value.
  ///
  /// When value is required and is not given by the user
  /// then a [KlutterException] is thrown.
  Map<TaskOption, dynamic> _getOptions(Context context) {
    final optionsInputCopy = context.taskOptions;
    final options = <TaskOption, dynamic>{};
    final inputMissing = <TaskOption>[];
    final inputInvalid = <TaskOption, String>{};
    final inputUnsupported = <TaskOption>[...optionsInputCopy.keys];

    taskOptions.forEach((key, value) {
      final hasUserInput = optionsInputCopy.containsKey(key);
      inputUnsupported.remove(key);

      if (hasUserInput) {
        final inputValue = optionsInputCopy.remove(key)!;
        try {
          options[key] = value.convertOrThrow(inputValue);
        } on InputException catch (e) {
          inputInvalid[key] = e.cause;
        }
      } else if (value is RequiredUserInput) {
        inputMissing.add(key);
      } else if (value is UserInputOrDefault) {
        options[key] = value.defaultValue;
      } else {
        throw InputException("unsupported value: $value");
      }
    });

    final inputErrors = [
      ...inputMissing.map((opt) => "missing value for option: ${opt.name}"),
      ...inputUnsupported.map((opt) =>
          "option not supported for task ${taskName.name}: ${opt.name}")
    ];

    inputInvalid.forEach((opt, msg) {
      inputErrors.add("invalid value for option ${opt.name}: $msg");
    });

    if (inputErrors.isNotEmpty) {
      throw KlutterException(
          "unable to run task ${taskName.name} because: $inputErrors");
    }

    return options;
  }

  @override
  String toString() {
    final buffer = StringBuffer()..writeln(taskName.name);
    taskOptions.forEach((option, input) {
      buffer.write("  ${option.name}".padRight(20));
      if (input is RequiredUserInput) {
        buffer.write("(Required) ${input.description}.\n");
      } else if (input is UserInputOrDefault) {
        buffer.write(
            "(Optional) ${input.description}. Defaults to '${input.defaultValueToString}'.\n");
      }
    });
    return buffer.toString();
  }
}

/// List of available tasks.
///
/// The task functionality depends on the calling script.
enum TaskName {
  /// Tasks which adds libraries.
  add,

  /// Tasks which gets dependencies (e.g. Flutter SDK).
  get,

  /// Tasks which does project initialization (setup).
  init,

  /// Clean one or more directories by deleting contents recursively.
  clean,

  /// Create a new klutter project.
  create,

  /// Build a klutter project.
  build,

  /// Run flutter commands using the cached flutter distribution.
  flutter,

  /// Run gradle commands using the local gradlew distribution.
  gradle,
}

/// Convert a String value to a [TaskName].
extension TaskNameParser on String? {
  /// Find a [TaskName] that matches the current
  /// (trimmed) String value or return null.
  TaskName? get toTaskNameOrNull {
    if (this == null) {
      return null;
    }

    switch (this!.trim().toUpperCase()) {
      case "ADD":
        return TaskName.add;
      case "BUILD":
        return TaskName.build;
      case "CLEAN":
        return TaskName.clean;
      case "CREATE":
        return TaskName.create;
      case "GET":
        return TaskName.get;
      case "INIT":
        return TaskName.init;
      case "GRADLE":
        return TaskName.gradle;
      case "FLUTTER":
        return TaskName.flutter;
      default:
        return null;
    }
  }
}

/// List of available scripts options.
///
/// Each task [TaskName] has 0 or more compatible [TaskOption].
///
/// {@category consumer}
/// {@category producer}
enum TaskOption {
  /// The Klutter (Gradle) BOM version.
  bom,

  /// The Kradle cache directory.
  cache,

  /// For testing purposes.
  ///
  /// Skips downloading of libraries when set to true.
  dryRun,

  /// The Flutter SDK distribution in format
  /// major.minor.patch.platform.architecture
  /// or major.minor.patch.
  ///
  /// Example format:
  /// ```dart
  /// 3.10.6.macos.arm64.
  /// 3.10.6
  /// ```
  flutter,

  /// The klutter project group name.
  group,

  /// The klutter pub version in format major.minor.patch.
  klutter,

  /// The klutter-ui pub version in format major.minor.patch.
  klutterui,

  /// Name of library to add.
  ///
  /// Used when adding a Klutter Library as dependency.
  lib,

  /// The klutter project name.
  name,

  /// To overwrite existing entities or not.
  overwrite,

  /// The klutter project root directory.
  root,

  /// The squint pub version in format major.minor.patch.
  squint,
}

/// Convert a String value to a [TaskName].
extension TaskOptionParser on String? {
  /// Find a [TaskName] that matches the current
  /// (trimmed) String value or return null.
  TaskOption? get toTaskOptionOrNull {
    if (this == null) {
      return null;
    }

    switch (this!.trim().toUpperCase()) {
      case "BOM":
        return TaskOption.bom;
      case "CACHE":
        return TaskOption.cache;
      case "DRYRUN":
        return TaskOption.dryRun;
      case "FLUTTER":
        return TaskOption.flutter;
      case "GROUP":
        return TaskOption.group;
      case "KLUTTER":
        return TaskOption.klutter;
      case "KLUTTERUI":
        return TaskOption.klutterui;
      case "LIB":
        return TaskOption.lib;
      case "NAME":
        return TaskOption.name;
      case "OVERWRITE":
        return TaskOption.overwrite;
      case "ROOT":
        return TaskOption.root;
      case "SQUINT":
        return TaskOption.squint;
      default:
        return null;
    }
  }
}
