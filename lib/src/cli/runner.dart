// Copyright (c) 2021 - 2024 Buijs Software
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

// ignore_for_file: avoid_print

import "dart:io";

import "../common/common.dart";
import "cli.dart";
import "context.dart";

/// Run the user command.
Future<String> run(
  List<String> args, {
  Directory? workingDirectoryOrNull,
  TaskService? taskServiceOrNull,
  Executor? executor,
  GetFlutterSDK? getFlutterSDK,
}) async {
  final arguments = [...args];
  final firstArgument = arguments.removeAt(0);
  final taskName = firstArgument.toTaskNameOrNull;
  final workingDirectory = workingDirectoryOrNull ?? Directory.current;
  if (taskName == TaskName.gradle) {
    print("executing gradle task...");
    final gradlew =
        workingDirectory.resolveFile("gradlew").verifyFileExists.absolutePath;
    (executor ?? Executor())
      ..workingDirectory = workingDirectory
      ..arguments = arguments
      ..executable = gradlew
      ..run();
    return "finished executing gradle task";
  }

  if (taskName == TaskName.flutter) {
    print("executing flutter task...");
    final flutterTask = getFlutterSDK ?? GetFlutterSDK();
    final flutterResult =
        await flutterTask.executeOrThrow(Context(workingDirectory, {}));
    final flutter =
        flutterResult.resolveFile("flutter/bin/flutter".normalize).absolutePath;
    (executor ?? Executor())
      ..workingDirectory = workingDirectory
      ..arguments = arguments
      ..executable = flutter
      ..run();
    return "finished executing flutter task";
  }

  final context = toContextOrNull(workingDirectory, arguments);
  final taskService = taskServiceOrNull ?? TaskService();
  if (firstArgument.toLowerCase() == "help") {
    return taskService.displayKradlewHelpText;
  } else if (taskName == null) {
    return "received unknown task name: $firstArgument\nuse kradle help for more information";
  } else if (context == null) {
    final arguments = args.sublist(1, args.length);
    return "received invalid task options: $arguments\nuse kradle help for more information";
  } else {
    return execute(taskName, context, taskService);
  }
}
