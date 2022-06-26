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

import "../common/shared.dart";
import "command.dart";
import "script.dart";
import "task.dart";
import "task_service.dart" as service;

export "command.dart";
export "script.dart";
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

// It should print doh...
// ignore_for_file: avoid_print

///
Future<void> execute({
  required ScriptName script,
  required String pathToRoot,
  required List<String> arguments,
}) async {
  """
  ════════════════════════════════════════════
     KLUTTER (v0.1.0)                               
  ════════════════════════════════════════════
  """
      .ok;

  /// Parse user input to a Command.
  final command = Command.from(
    task: arguments.join(),
    script: script,
  );

  /// Retrieve all tasks for the specified command.
  ///
  /// Set is empty if command is null or task processing failed.
  final tasks = command == null ? <Task>{} : service.tasksOrEmptyList(command);

  /// When there are no tasks then the user input is incorrect.
  ///
  /// Stop processing and print list of available tasks.
  if (tasks.isEmpty) {
    """
    |KLUTTER: Received invalid command.
    |
    |${service.printTasksAsCommands}
    """
        .format
        .invalid;
  }

  /// Process all the given tasks.
  else {
    final s = command!.scriptName.name;
    final t = command.taskName.name;
    final o = command.option;

    for (final task in tasks) {
      final result = task.execute(pathToRoot);

      /// Stop executing tasks when one has failed.
      if (!result.isOk) {
        "KLUTTER: ${result.message}".format.nok;
        "KLUTTER: Task '$s $t $o' finished unsuccessfully.".format.nok;
        return;
      }
    }

    "KLUTTER: Task '$s $t $o' finished successful.".format.ok;
  }
}

extension on String {
  void get ok => print("\x1B[32m${this}");
  void get nok => print("\x1B[31m${this}");
  void get invalid => print("\x1B[31m${this}");
}
