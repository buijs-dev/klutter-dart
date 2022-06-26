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

import "../common/exception.dart";
import "library.dart";

/// Interface to encapsulate CLI task functionality.
abstract class Task {
  /// Create a new CliTask.
  Task(this.scriptName, this.taskName);

  /// The name of this task.
  final TaskName taskName;

  /// The script the task belongs to.
  final ScriptName scriptName;

  /// The option value which configures the task.
  String? _option;

  /// Set option to be used for executing the task.
  set option(String? option) {
    _option = option;
  }

  /// Get the option value.
  String get option => (_option ?? "").trim().toLowerCase();

  /// Task logic implemented by the child class which will be executed.
  void toBeExecuted(String pathToRoot);

  /// Execute the task.
  TaskResult execute(String pathToRoot) {
    try {
      toBeExecuted(pathToRoot);
      return const TaskResult(isOk: true);
    } on KlutterException catch (e) {
      return TaskResult(isOk: false, message: e.cause);
    }
  }

  /// List of tasks that should be run before executing this task.
  List<Task> dependsOn() => [];

  /// List of options that can be passed to configure this task.
  List<String> optionValues() => [];

  @override
  String toString() {
    return "Instance of Task: $scriptName | $taskName | DependsOn: ${dependsOn().toString()}";
  }
}
