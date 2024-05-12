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

import "dart:io";
import "package:klutter/klutter.dart";
import "package:test/test.dart";

/// Wrapper for using the commandline.
class FakeExecutor extends Executor {
  FakeExecutor(
      {required this.expectedPathToWorkingDirectory,
      required this.expectedCommand});

  final String expectedPathToWorkingDirectory;

  final String expectedCommand;

  @override
  ProcessResult run() {
    final actualPathToWorkingDirectory = super.workingDirectory?.absolutePath;
    final actualCommand =
        """${super.executable} ${super.arguments.join(" ")}""";
    _assert(expectedPathToWorkingDirectory, actualPathToWorkingDirectory);
    _assert(expectedCommand, actualCommand);
    return ProcessResult(1234, 0, "Test OK!", "");
  }

  void _assert(String expected, String? actual) {
    assert(expected == actual,
        "Test NOK because values do not match:\nExpected: $expected\nActual:   $actual");
  }
}

void main() {
  test("Verify exception is thrown when executable is not set", () {
    expect(
        () => Executor().run(),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith("Executor field 'executable' is null"))));
  });

  test("Verify exception is thrown when workingDirectory is not set", () {
    expect(() {
      Executor()
        ..executable = "dart"
        ..run();
    },
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith("Executor field 'workingDirectory' is null"))));
  });

  test("Verify command is run successfully", () {
    final exec = Executor()
      ..executable = "dart"
      ..workingDirectory = Directory.current
      ..arguments = ["--version"];

    final version = exec.run();

    expect(version.stdout.toString().contains("Dart SDK version: "), true,
        reason: "stdout should contain the installed dart version");
  });
}
