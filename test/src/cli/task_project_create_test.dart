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
import "package:klutter/src/cli/context.dart";
import "package:test/test.dart";

void main() {
  test("Verify a git path is converted to correct yaml dependency", () async {
    const git = "https://github.com/foo.git@develop";
    const expected = "|  foobar:\n"
        "|    git:\n"
        "|      url: https://github.com/foo.git\n"
        "|      ref: develop\n"
        "";
    final yaml = toDependencyNotation(git, "foobar");
    expect(yaml, expected);
  });

  test("Verify a version path is converted to correct yaml dependency",
      () async {
    const version = "2.4.8";
    const expected = "|  foobar: ^2.4.8";
    final yaml = toDependencyNotation(version, "foobar");
    expect(yaml, expected);
  });

  test("Verify an exception is thrown if the dependency notation is invalid",
      () async {
    const notation = "1.2.beta";
    expect(
        () => toDependencyNotation(notation, "foobar"),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause == "invalid dependency notations: 1.2.beta")));
  });

  test("Verify an exception is thrown if flutter sdk is not found", () async {
    final getFlutterTask = NoFlutterSDK();
    final task = CreateProject(getFlutterSDK: getFlutterTask);
    final result = await task.execute(Context(
      workingDirectory: Directory.systemTemp,
      taskName: TaskName.create,
      taskOptions: {},
    ));

    expect(result.isOk, false);
    expect(result.message, "BOOM!");
  });

}

class NoFlutterSDK extends GetFlutterSDK {
  @override
  Future<TaskResult<Directory>> execute(Context context) async {
    return const TaskResult(isOk: false, message: "BOOM!");
  }
}