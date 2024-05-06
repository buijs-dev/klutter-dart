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

import "../common/common.dart";
import "context.dart";
import "task.dart";
import "task_service.dart";

export "flutter.dart";
export "option.dart";
export "runner.dart";
export "task.dart";
export "task_add.dart";
export "task_build.dart";
export "task_clean_cache.dart";
export "task_get_flutter.dart";
export "task_project_create.dart";
export "task_project_init.dart";
export "task_result.dart";
export "task_service.dart";

/// Main entrypoint for executing Klutter command line tasks.
Future<String> execute(TaskName taskName, Context context,
    [TaskService? taskService]) async {
  final service = taskService ?? TaskService();

  /// Retrieve all tasks for the specified command.
  ///
  /// Set is empty if command is null or task processing failed.
  final task = service.toTask(taskName);

  /// When there are no tasks then the user input is incorrect.
  ///
  /// Stop processing and print list of available tasks.
  if (task == null) {
    return """
    |KLUTTER: Received invalid command.
    |
    |${service.displayKradlewHelpText}
    """
        .format
        .nok;
  }

  final t = task.taskName;
  var o = "";

  context.taskOptions.forEach((key, value) {
    o += " ${key.name}=$value";
  });

  final result = await task.execute(context);
  final msgOk = "KLUTTER: Task '$t$o' finished successful.";
  final msgNok = """
        |KLUTTER: ${result.message}
        |KLUTTER: Task '$t$o' finished unsuccessfully.""";
  if (result.isOk) {
    return msgOk.format.ok;
  } else {
    return msgNok.format.nok;
  }
}

/// Output log message to console.
extension ColoredMessage on String {
  /// Log a green colored message.
  String get ok => "\x1B[32m$this";

  /// Log a red colored message.
  String get nok => "\x1B[31m$this";

  /// Default color (mostly whit(e/ish)).
  String get boring => "\x1B[49m$this";
}
