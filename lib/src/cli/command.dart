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

import "../../klutter.dart";

/// Object to store parsed user input.
class Command {
  /// Create a Command object which should always
  /// contain a [TaskName]  and [ScriptName].
  ///
  /// Option value is optional but might be required by a Task.
  const Command({
    required this.taskName,
    required this.scriptName,
    this.options = const <ScriptOption, String>{},
  });

  /// Name of Task to be executed.
  final TaskName taskName;

  /// Optional values which may or may not be used by the Task.
  final Map<ScriptOption, String> options;

  /// Name of script which should contain a Task with [TaskName].
  final ScriptName scriptName;

  /// Parse a received command and return the command data.
  ///
  /// Takes the CLI arguments list prefixed with the script name
  /// and returns a [Command] object which can be mapped to a Task
  /// or null if the command (user input) is invalid.
  static Command? from({
    required ScriptName script,
    required List<String> arguments,
  }) {
    if (arguments.isEmpty) {
      return null;
    }

    final taskName = arguments.first.toTaskNameOrNull;

    if (taskName == null) {
      return null;
    }

    final args = arguments.sublist(1, arguments.length);

    if (script == ScriptName.consumer) {
      if (taskName == TaskName.init) {
        if (args.isEmpty) {
          return Command(taskName: taskName, scriptName: script);
        } else {
          return null;
        }
      }

      if (taskName == TaskName.add) {
        if (args.length != 1) {
          return null;
        }

        final option = args.first.split("=");

        if (option.length != 2) {
          return null;
        }

        if (option.first != ScriptOption.lib.name) {
          return null;
        }

        return Command(
            taskName: taskName,
            scriptName: script,
            options: {ScriptOption.lib: option[1]});
      }
    }

    if (script == ScriptName.producer) {
      if (taskName == TaskName.init) {
        if (args.length > 2) {
          return null;
        }

        final options = <ScriptOption, String>{};

        for (final arg in args) {
          final option = arg.split("=");

          if (option.length != 2) {
            return null;
          }

          if (option.first == ScriptOption.bom.name) {
            options[ScriptOption.bom] = option[1];
          } else if (option.first == ScriptOption.flutter.name) {
            options[ScriptOption.flutter] = option[1];
          } else {
            return null;
          }
        }

        if (!options.containsKey(ScriptOption.bom.name)) {
          options[ScriptOption.bom] = klutterGradleVersion;
        }

        if (!options.containsKey(ScriptOption.flutter.name)) {
          options[ScriptOption.flutter] = klutterFlutterVersion;
        }

        return Command(
            taskName: taskName, scriptName: script, options: options);
      }

      if (taskName == TaskName.get) {
        if (args.length != 1) {
          return null;
        }

        final option = args.first.split("=");

        if (option.length != 2) {
          return null;
        }

        if (option.first != ScriptOption.flutter.name) {
          return null;
        }

        final version = option[1].verifyFlutterVersion?.version;

        if (version == null) {
          return null;
        }

        return Command(
            taskName: taskName,
            scriptName: script,
            options: <ScriptOption, String>{ScriptOption.flutter: version});
      }
    }

    return null;
  }
}
