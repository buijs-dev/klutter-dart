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

/// Library containing all Klutter tasks available through the command line.
///
/// Domain specific language used throughout this library:
/// - <B>Command</B>: User input as received through the cli.
/// - <B>ScriptName</B>: The name of a script being either <i>consumer</i> or <i>producer</i>.
/// A script has one or more tasks.
/// - <B>TaskName</B>: The name of a task belonging to a script.
/// - <B>Task</B>: The actual task containing all functionality.
/// - <B>Option</B>: Extra user input which configures a task.
/// An option can be optional or required depending on the task.
/// - <B>TaskResult</B>: The result of task execution.
/// A result is either OK or not.
/// If a result is not OK then a message is given describing the problem.
///
/// Example
///
/// Given this command:
///
/// ```shell
/// flutter pub run klutter:consumer init=android
/// ```
///
/// Expect the following:
/// - Command: <I>consumer init=android</I>
/// - ScriptName: <I>consumer</I>
/// - TaskName: <I>init</I>
/// - Task: <I>ConsumerInitAndroid</I> class
/// - Option: <I>android</I>
library cli;

import "dart:io";

import "../common/shared.dart";
import "task_name.dart";
import "task_service.dart" as service;

export "task.dart";
export "task_comparator.dart";
export "task_comparator.dart";
export "task_consumer_add.dart";
export "task_consumer_init.dart";
export "task_name.dart";
export "task_producer_init.dart";
export "task_producer_install.dart";
export "task_result.dart";
export "task_service.dart";

///
Future<void> execute(ScriptName scriptName, List<String> args) async {
  """
  ════════════════════════════════════════════
     KLUTTER (v0.1.0)                               
  ════════════════════════════════════════════
  """
      .ok;

  final command = scriptName.parseCommand(args.join());

  if (command == null) {
    return _fail;
  }

  final tasks = service.tasksOrEmptyList(command);

  if (tasks.isEmpty) {
    return _fail;
  }

  for (final task in tasks) {
    final pathToRoot = Directory.current.absolutePath;
    final result = task.execute(
      pathToRoot: pathToRoot,
      option: command.option,
    );

    if (!result.isOk) {
      "KLUTTER: ${result.message}".format.nok;
      return;
    }

    "KLUTTER: Task finished successful.".format.ok;
  }
}

void get _fail => """
    |KLUTTER: Received invalid command.
    |
    |${service.printTasksAsCommands}
    """
    .format
    .invalid;

extension on String {
  void get ok => print("\x1B[32m${this}");
  void get nok => print("\x1B[31m${this}");
  void get invalid => print("\x1B[31m${this}");
}

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
}

/// Parse a received command and return the command data.
extension CommandParser on ScriptName {
  /// Takes the CLI arguments list prefixed with the script name
  /// and returns a [Command] object which can be mapped to a Task
  /// or null if the command (user input) is invalid.
  Command? parseCommand(String args) {
    /// Regex to parse the CLI arguments.
    final taskRegex = RegExp(
      r"^\s*(<task>init|add|install)\s*=*\s*(<option>\S+)",
    );

    final match = taskRegex.firstMatch(args);

    if (match == null) {
      return null;
    }

    final taskName = match.namedGroup("task").toTaskNameOrNull;

    if (taskName == null) {
      return null;
    }

    return Command(
      option: match.namedGroup("option"),
      taskName: taskName,
      scriptName: this,
    );
  }
}

/// List of available scripts.
///
/// Tasks are accessible through scripts.
/// There are 2 scripts:
/// - Consumer
/// - Producer
///
/// <B>Consumer:</B>
///
/// Tasks to be executed in a project that will use (consume)
/// libraries that are created with the use of Klutter.
///
/// <B>Producer:</B>
///
/// Tasks to be executed in a project that will use
/// Klutter to create (produce) a new Flutter library.
enum ScriptName {
  /// Script containing tasks for projects
  /// that use libraries created with Klutter.
  consumer,

  /// Script containing tasks for projects
  /// that are being created with Klutter.
  producer,
}
