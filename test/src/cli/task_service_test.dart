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
import "package:klutter/src/common/common.dart";
import "package:test/test.dart";

void main() {
  final pathToRoot = Directory("${Directory.systemTemp.path}/tst1".normalize)
    ..maybeCreate;

  final service = TaskService();

  group("Test allTasks", () {
    test("Verify allTasks returns 7 tasks", () {
      final tasks = service.allTasks();

      expect(tasks.length, 6);

      expect(
        tasks.getTask(TaskName.add).toString(),
        "add\n  lib               (Required) name of the library to add.\n"
        "  root              (Optional) klutter project root directory. Defaults to \'current working directory\'.\n",
      );

      expect(
        tasks.getTask(TaskName.init).toString(),
        "init\n  bom               (Optional) klutter gradle version. Defaults to '2024.1.1.beta'.\n  flutter           (Optional) flutter sdk version in format major.minor.patch. Defaults to '3.10.6'.\n  root              (Optional) klutter project root directory. Defaults to \'current working directory\'.\n  ios               (Optional) ios version. Defaults to \'13.0\'.\n",
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

  test("Verify displayKradlewHelpText output", () {
    final help = service.displayKradlewHelpText;
    const expected = "Manage your klutter project."
        "\n"
        "\n"
        "Usage: kradlew <command> [option=value]\n"
        "\n"
        "add\n"
        "  lib               (Required) name of the library to add.\n"
        "  root              (Optional) klutter project root directory. Defaults to 'current working directory'.\n"
        "\n"
        "init\n"
        "  bom               (Optional) klutter gradle version. Defaults to '2024.1.1.beta'.\n"
        "  flutter           (Optional) flutter sdk version in format major.minor.patch. Defaults to '3.10.6'.\n"
        "  root              (Optional) klutter project root directory. Defaults to 'current working directory'.\n"
        "  ios               (Optional) ios version. Defaults to \'13.0\'.\n"
        "\n"
        "get\n"
        "  flutter           (Optional) flutter sdk version in format major.minor.patch. Defaults to '3.10.6'.\n"
        "  overwrite         (Optional) overwrite existing distribution when found. Defaults to 'false'.\n"
        "  dryRun            (Optional) skip downloading of libraries. Defaults to 'false'.\n"
        "  root              (Optional) klutter project root directory. Defaults to 'current working directory'.\n"
        "\n"
        "create\n"
        "  name              (Optional) plugin name. Defaults to 'my_plugin'.\n"
        "  group             (Optional) plugin group name. Defaults to 'dev.buijs.klutter.example'.\n"
        "  flutter           (Optional) flutter sdk version in format major.minor.patch. Defaults to '3.10.6'.\n"
        "  root              (Optional) klutter project root directory. Defaults to 'current working directory'.\n"
        "  klutter           (Optional) klutter pub version. Defaults to '3.0.0'.\n"
        "  klutterui         (Optional) klutter_ui pub version. Defaults to '1.1.0'.\n"
        "  bom               (Optional) klutter gradle version. Defaults to '2024.1.1.beta'.\n"
        "  squint            (Optional) squint_json pub version. Defaults to '0.1.2'.\n"
        "\n"
        "build\n"
        "  root              (Optional) klutter project root directory. Defaults to 'current working directory'.\n"
        "\n"
        "clean\n"
        "  root              (Optional) klutter project root directory. Defaults to 'current working directory'.\n"
        "\n"
        "";
    expect(help, expected);
  });
  tearDownAll(() => pathToRoot.deleteSync(recursive: true));
}

extension on Set<Task> {
  Task getTask(TaskName taskName) => firstWhere((task) {
        return task.taskName == taskName;
      });
}
