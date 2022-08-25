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

import "dart:io";

import "package:klutter/src/cli/cli.dart";
import "package:klutter/src/cli/task_service.dart" as service;
import "package:klutter/src/common/common.dart";
import "package:test/test.dart";

void main() {
  final pathToRoot = Directory("${Directory.systemTemp.path}/tst1".normalize)
    ..maybeCreate;

  group("Test allTasks", () {
    test("Verify allTasks returns 4 tasks", () {
      final tasks = service.allTasks();

      // There should be 4 Tasks.
      expect(tasks.length, 4);

      expect(
        tasks.getTask(ScriptName.consumer, TaskName.add).toString(),
        "Instance of Task: ScriptName.consumer | TaskName.add | DependsOn: [Instance of Task: ScriptName.consumer | TaskName.init | DependsOn: []]",
      );

      expect(
        tasks.getTask(ScriptName.consumer, TaskName.init).toString(),
        "Instance of Task: ScriptName.consumer | TaskName.init | DependsOn: []",
      );

      expect(
        tasks.getTask(ScriptName.producer, TaskName.init).toString(),
        "Instance of Task: ScriptName.producer | TaskName.init | DependsOn: []",
      );

      expect(
        tasks.getTask(ScriptName.producer, TaskName.install).toString(),
        "Instance of Task: ScriptName.producer | TaskName.install | DependsOn: []",
      );
    });

    test(
        "Verify identical TaskNames are ignored when the ScriptName is different",
        () {
      final dummy1 = _DummyTask(
        taskName: TaskName.install,
        scriptName: ScriptName.consumer,
      );

      final dummy2 = _DummyTask(
        taskName: TaskName.install,
        scriptName: ScriptName.producer,
        dependsOnList: [dummy1],
      );

      final tasks = [dummy1, dummy2];

      expect(service.allTasks(tasks).length, 2);
    });

    test("Verify exception is thrown if duplicate tasks are found", () {
      final duplicateTasks = [
        ConsumerInit(),
        ConsumerInit(),
      ];

      expect(
          () => service.allTasks(duplicateTasks),
          throwsA(predicate((e) =>
              e is KlutterException &&
              e.cause.startsWith("TaskService configuration failure.") &&
              e.cause.contains("Invalid or duplicate TaskName encountered."))));
    });

    test("Verify exception is thrown if tasks have circular dependencies", () {
      final roundAndRoundWeGo = [_SelfDependingTask()];

      expect(
          () => service.allTasks(roundAndRoundWeGo),
          throwsA(predicate((e) =>
              e is KlutterException &&
              e.cause.startsWith("TaskService configuration failure.") &&
              e.cause.contains("Found circular dependency."))));
    });
  });

  group("Test tasksOrEmptyList", () {
    test(
        "Verify tasksOrEmptyList returns normalized list of requested Task and all dependents",
        () {
      const command = Command(
        scriptName: ScriptName.consumer,
        taskName: TaskName.add,
        option: "platform",
      );

      final tasks = service.tasksOrEmptyList(command);

      // Install Task depends on Init task so there should be 2 tasks.
      expect(tasks.length, 2);

      // Install depends on init so init should be the first task.
      expect(tasks.first.taskName, TaskName.init);

      // Install should be the final task.
      expect(tasks.last.taskName, TaskName.add);
    });
  });

  group("Test TaskComparator", () {
    test("When task1 depends on task2, then t2 has higher priority", () {
      final task2 = _DummyTask(
        taskName: TaskName.init,
      );

      final task1 = _DummyTask(
        taskName: TaskName.install,
        dependsOnList: [task2],
      );

      final tasks = [task1, task2]..sort(compareByDependsOn);

      expect(tasks.first, task2);
    });

    test("When task2 depends on task1, then t1 has higher priority", () {
      final task1 = _DummyTask(
        taskName: TaskName.install,
      );

      final task2 = _DummyTask(
        taskName: TaskName.init,
        dependsOnList: [task1],
      );

      final tasks = [task1, task2]..sort(compareByDependsOn);

      expect(tasks.first, task1);
    });

    test("When both tasks depend on other tasks then t1 takes priority", () {
      final taskNotInList = _DummyTask();

      final task1 = _DummyTask(
          taskName: TaskName.install, dependsOnList: [taskNotInList]);

      final task2 =
          _DummyTask(taskName: TaskName.init, dependsOnList: [taskNotInList]);

      final tasks = [task1, task2]..sort(compareByDependsOn);
      expect(tasks.first, task1);

      final reversed = [task2, task1]..sort(compareByDependsOn);
      expect(reversed.first, task2);
    });

    test("When both tasks depend on nothing then t1 takes priority", () {
      final task1 = _DummyTask(taskName: TaskName.install, dependsOnList: []);

      final task2 = _DummyTask(taskName: TaskName.init, dependsOnList: []);

      final tasks = [task1, task2]..sort(compareByDependsOn);
      expect(tasks.first, task1);

      final reversed = [task2, task1]..sort(compareByDependsOn);
      expect(reversed.first, task2);
    });

    test(
        "When task1 depends on other tasks and task2 depends on nothing, then t2 takes priority",
        () {
      final taskNotInList = _DummyTask();

      final task1 = _DummyTask(
          taskName: TaskName.install, dependsOnList: [taskNotInList]);

      final task2 = _DummyTask(taskName: TaskName.init, dependsOnList: []);

      final tasks = [task1, task2]..sort(compareByDependsOn);
      expect(tasks.first, task2);

      final reversed = [task2, task1]..sort(compareByDependsOn);
      expect(reversed.first, task2);
    });

    test(
        "When task2 depends on other tasks and task1 depends on nothing, then t1 takes priority",
        () {
      final taskNotInList = _DummyTask();

      final task1 = _DummyTask(taskName: TaskName.install, dependsOnList: []);

      final task2 =
          _DummyTask(taskName: TaskName.init, dependsOnList: [taskNotInList]);

      final tasks = [task1, task2]..sort(compareByDependsOn);
      expect(tasks.first, task1);

      final reversed = [task2, task1]..sort(compareByDependsOn);
      expect(reversed.first, task1);
    });

    test("Verify printTasksAsCommands outputs a readable overview", () {
      expect(
          printTasksAsCommands.replaceAll(" ", ""),
          """
          The following commands are valid:
          flutter pub run klutter:consumer add=<name_of_plugin_to_add>
          flutter pub run klutter:consumer init
          flutter pub run klutter:consumer init=android
          flutter pub run klutter:consumer init=ios
          flutter pub run klutter:producer init
          flutter pub run klutter:producer install=platform
          flutter pub run klutter:producer install=library"""
              .replaceAll(" ", ""));
    });
  });

  tearDownAll(() => pathToRoot.deleteSync(recursive: true));
}

class _DummyTask extends Task {
  _DummyTask({
    ScriptName scriptName = ScriptName.producer,
    TaskName taskName = TaskName.add,
    this.dependsOnList = const [],
  }) : super(scriptName, taskName);

  List<Task> dependsOnList;

  @override
  List<Task> dependsOn() => dependsOnList;

  @override
  void toBeExecuted(String pathToRoot) {}
}

class _SelfDependingTask extends _DummyTask {
  _SelfDependingTask() : super();

  @override
  List<Task> dependsOn() => [_SelfDependingTask()];
}

extension on Set<Task> {
  Task getTask(ScriptName scriptName, TaskName taskName) => firstWhere((task) {
        return task.scriptName == scriptName && task.taskName == taskName;
      });
}
