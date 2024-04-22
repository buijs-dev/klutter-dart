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

import "package:args/command_runner.dart";
import "package:klutter/klutter.dart";
import "package:klutter/src/cli/context.dart";

/// Run kradle tasks.
Future<void> main(List<String> args) async {
  print("""
  ════════════════════════════════════════════
     KRADLE (v$klutterPubVersion)                               
  ════════════════════════════════════════════
  """
      .ok);

  if (args.isEmpty) {
    // TODO start interactive mode
    return;
  }

  final arguments = [...args];
  final firstArgument = arguments.removeAt(0);
  final taskName = firstArgument.toTaskNameOrNull;
  final taskOptions = toTaskOptionsOrNull(arguments);
  if (firstArgument.toLowerCase() == "help") {
    print(displayKradlewHelpText);
  } else if (taskName == null) {
    print("received unknown task name: $firstArgument");
    print("use kradlew help for more information");
  } else if (taskOptions == null) {
    print("received invalid task options: $args");
    print("use kradlew help for more information");
  } else {
    print(await execute(Context(
      workingDirectory: Directory.current,
      taskName: taskName,
      taskOptions: taskOptions,
    )));
  }
}
