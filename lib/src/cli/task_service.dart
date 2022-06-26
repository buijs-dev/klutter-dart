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
import "../common/shared.dart";
import "library.dart";

const _prefix = "|flutter pub run klutter:";

/// List of all [Task] objects.
///
/// A task may contain one or more sub-task implementations.
Set<Task> allTasks(

    /// Injectable Task List for testing purposes.
    /// Any calling class should omit this parameter
    /// and let the function default to [allTasks].
    [List<Task>? tasks]) {
  final list = tasks ??
      [
        ConsumerAdd(),
        ConsumerInit(),
        ProducerInit(),
        ProducerInstall(),
      ]
    ..verifyNoDuplicates
    ..verifyNoCircularDependencies;
  return list.toSet();
}

/// Get the Task and all tasks it relies on
/// or return empty list if command is invalid.
Set<Task> tasksOrEmptyList(Command command,

    /// Injectable Task List for testing purposes.
    /// Any calling class should omit this parameter
    /// and let the function default to [allTasks].
    [Set<Task>? tasks]) {
  /// Get all Tasks for this ScriptName.
  final tasksForScript = (tasks ?? allTasks())
      .where((task) => task.scriptName == command.scriptName)
      .toList();

  /// Find TaskName or return emptyList if not present.
  ///
  /// If TaskName is not found then the command was invalid.
  final hasTask =
      tasksForScript.map((e) => e.taskName).contains(command.taskName);

  if (!hasTask) {
    return <Task>{};
  }

  /// Retrieve the Task which at this point always exists.
  final primaryTask = tasksForScript.firstWhere((task) {
    return task.taskName == command.taskName;
  })
    ..option = command.option;

  final taskList = [primaryTask];

  /// Find al dependencies and add them to the taskList.
  for (final task in primaryTask.dependsOn()) {
    if (!taskList.map((e) => e.taskName).contains(task.taskName)) {
      taskList.add(task);
    }
  }

  /// Sort the taskList to make sure the Tasks are executed in
  /// the correct order e.g. tasks without dependencies before
  /// those with dependencies.
  taskList.sort(compareByDependsOn);

  return taskList.toSet();
}

extension on List<Task> {
  /// Verify there are no overlapping tasks e.g.
  /// multiple tasks that have the same ScriptName
  /// and TaskName.
  ///
  /// ScriptName + TaskName should be unique.
  /// Any sub-tasks should be defined in the
  /// Task Class implementation.
  ///
  /// Throws [KlutterException] if duplicates are found.
  void get verifyNoDuplicates {
    final map = <ScriptName, List<TaskName>>{};

    for (final name in ScriptName.values) {
      map.putIfAbsent(name, () => TaskName.values.toList(growable: true));
    }

    for (final taskEntry in this) {
      final hasTask = map[taskEntry.scriptName]!.remove(taskEntry.taskName);

      if (!hasTask) {
        throw KlutterException(
          """
            |TaskService configuration failure.
            |Invalid or duplicate TaskName encountered. 
            |- ScriptName: '${taskEntry.scriptName}'
            |- TaskName: '${taskEntry.taskName}'
            """
              .format,
        );
      }
    }
  }

  /// Verify dependencies between tasks only go one way.
  ///
  /// Two individual tasks may not directly
  /// or indirectly depend to one another.
  ///
  /// Circular dependencies make it impossible
  /// to determine which task should be executed first.
  ///
  /// Throws [KlutterException] if there are circular dependencies.
  void get verifyNoCircularDependencies {
    for (final taskEntry in this) {
      final dependents = taskEntry.dependsOn();

      while (dependents.isNotEmpty) {
        if (dependents[0].scriptName != taskEntry.scriptName) {
          dependents.remove(dependents[0]);
          break;
        }

        if (dependents[0].taskName != taskEntry.taskName) {
          dependents.remove(dependents[0]);
          break;
        }

        /// Combination ScriptName + TaskName is unique
        /// which means at this point the found dependent
        /// is the same task.
        throw KlutterException(
          """
            |TaskService configuration failure.
            |Found circular dependency. 
            |- ScriptName: '${taskEntry.scriptName}'
            |- TaskName: '${taskEntry.taskName}'
            """
              .format,
        );
      }
    }
  }
}

/// Print all possible user input commands based of the available Tasks.
String get printTasksAsCommands {
  final output = <String>["The following commands are valid:"];

  for (final task in allTasks()) {
    final scriptName = task.scriptName.name;
    final taskName = task.taskName.name;

    if (task.optionValues().isEmpty) {
      output.append(scriptName, taskName);
    }

    for (final option in task.optionValues()) {
      if (option == "") {
        output.append(scriptName, taskName);
      } else {
        output.appendWithOption(scriptName, taskName, option);
      }
    }
  }

  return output.join("\n").format;
}

extension on List<String> {
  void append(String scriptName, String taskName) {
    add("$_prefix$scriptName $taskName");
  }

  void appendWithOption(String scriptName, String taskName, String option) {
    add("$_prefix$scriptName $taskName=$option");
  }
}
