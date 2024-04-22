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

import "dart:io";

import "package:klutter/src/cli/cli.dart";
import "package:klutter/src/cli/task_service.dart" as service;
import "package:klutter/src/common/common.dart";
import "package:test/test.dart";

void main() {
  final pathToRoot = Directory("${Directory.systemTemp.path}/tst1".normalize)
    ..maybeCreate;

  group("Test allTasks", () {
    test("Verify allTasks returns 7 tasks", () {
      final tasks = service.allTasks();

      expect(tasks.length, 6);

      expect(tasks.getTask(TaskName.add).toString(),
          "add\n  lib               (Required) name of the library to add.\n"
        "  root              (Optional) the klutter project root directory. Defaults to \'current working directory\'.\n",
      );

      expect(
        tasks.getTask(TaskName.init).toString(),
        "init\n  bom               (Optional) the klutter gradle version. Defaults to '2024.1.1.beta'.\n  flutter           (Optional) the flutter sdk version in format major.minor.patch. Defaults to '3.10.6'.\n  root              (Optional) the klutter project root directory. Defaults to \'current working directory\'.\n",
      );

    });

    test("Verify exception is thrown if duplicate tasks are found", () {
      final duplicateTasks = [
        ProjectInit(),
        ProjectInit(),
      ];

      expect(
          () => service.allTasks(duplicateTasks),
          throwsA(predicate((e) =>
              e is KlutterException &&
              e.cause.startsWith("TaskService configuration failure.") &&
              e.cause.contains("Invalid or duplicate TaskName encountered."))));
    });
  });

  tearDownAll(() => pathToRoot.deleteSync(recursive: true));
}


extension on Set<Task> {
  Task getTask(TaskName taskName) => firstWhere((task) {
        return task.taskName == taskName;
      });
}
