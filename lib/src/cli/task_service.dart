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
import "../common/utilities.dart";
import "task.dart";
import "task_add.dart";
import "task_build.dart";
import "task_clean_cache.dart";
import "task_get_flutter.dart";
import "task_project_create.dart";
import "task_project_init.dart";

/// Service for available tasks.
class TaskService {
  /// Get the [Task] with [TaskName] or null.
  Task? toTask(TaskName taskName) {
    final matching = allTasks().where((task) => task.taskName == taskName);
    return matching.isNotEmpty ? matching.first : null;
  }

  /// Output all tasks and options with descriptions.
  String get displayKradlewHelpText {
    final buffer = StringBuffer("""
  |Manage your klutter project.
  |
  |Usage: kradlew <command> [option=value]
  |
  |"""
        .format);

    for (final task in allTasks()) {
      buffer.writeln(task.toString());
    }

    return buffer.toString();
  }

  /// List of all [Task] objects.
  ///
  /// A task may contain one or more sub-task implementations.
  ///
  /// {@category producer}
  /// {@category consumer}
  Set<Task> allTasks(

      /// Injectable Task List for testing purposes.
      /// Any calling class should omit this parameter
      /// and let the function default to [allTasks].
      [List<Task>? tasks]) {
    final list = tasks ??
        [
          AddLibrary(),
          ProjectInit(),
          GetFlutterSDK(),
          CreateProject(),
          BuildProject(),
          CleanCache()
        ]
      ..verifyNoDuplicates;
    return list.toSet();
  }
}

extension on List<Task> {
  /// Verify there are no overlapping tasks e.g.
  /// multiple tasks that have the same TaskName.
  ///
  /// TaskName should be unique.
  /// Any sub-tasks should be defined in the
  /// Task Class implementation.
  ///
  /// Throws [KlutterException] if duplicates are found.
  void get verifyNoDuplicates {
    final tasks = TaskName.values.toList(growable: true);
    for (final taskEntry in this) {
      if (!tasks.remove(taskEntry.taskName)) {
        throw KlutterException(
          """
            |TaskService configuration failure.
            |Invalid or duplicate TaskName encountered. 
            |- TaskName: '${taskEntry.taskName}'
            """
              .format,
        );
      }
    }
  }
}
