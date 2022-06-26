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

import "cli.dart";

/// Object to store parsed user input.
class Command {
  /// Create a Command object which should always
  /// contain a [TaskName]  and [ScriptName].
  ///
  /// Option value is optional but might be required by a Task.
  const Command({
    required this.taskName,
    required this.scriptName,
    this.option,
  });

  /// Name of Task to be executed.
  final TaskName taskName;

  /// Optional value which may or may not be used by the Task.
  final String? option;

  /// Name of script which should contain a Task with [TaskName].
  final ScriptName scriptName;

  /// Parse a received command and return the command data.
  ///
  /// Takes the CLI arguments list prefixed with the script name
  /// and returns a [Command] object which can be mapped to a Task
  /// or null if the command (user input) is invalid.
  static Command? from({
    required ScriptName script,
    required String task,
  }) {
    /// Regex to parse the CLI arguments.
    final taskRegex = RegExp(
      r"^\s*(init|add|install)\s*=*\s*([^\s]+|$)",
    );

    final match = taskRegex.firstMatch(task);

    if (match == null) {
      return null;
    }

    final taskName = match.group(1).toTaskNameOrNull;

    if (taskName == null) {
      return null;
    }

    return Command(
      option: match.group(2),
      taskName: taskName,
      scriptName: script,
    );
  }
}
