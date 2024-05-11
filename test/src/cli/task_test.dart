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

import "package:klutter/klutter.dart";
import "package:klutter/src/cli/context.dart";
import "package:test/test.dart";

void main() {
  test("When a task fails with a KlutterException, it is caught", () async {
    final result =
        await _ExplodingTask().execute(Context(Directory.systemTemp, {}));
    expect(result.isOk, false);
    expect(result.message, "BOOM!");
  });

  test("An exception is thrown when an option value is invalid", () async {
    final result =
        await _InvalidTask().execute(Context(Directory.systemTemp, {}));
    expect(result.isOk, false);
    expect(result.message, "unsupported value: Instance of \'FakeInput\'");
  });

  test("An exception is thrown when unsupported options are present", () async {
    final result = await CreateProject().execute(
        Context(Directory.systemTemp, {TaskOption.overwrite: "false"}));
    expect(result.isOk, false);
    expect(result.message,
        "unable to run task create because: [option not supported for task create: overwrite]");
  });

  test("Verify toTaskOptionOrNull for valid options", () async {
    TaskOption.values.forEach((value) {
      expect(value.name.toTaskOptionOrNull, value, reason: "roundtrip $value");
    });
  });
}

class _ExplodingTask extends Task {
  _ExplodingTask() : super(TaskName.add, {});

  @override
  Future<void> toBeExecuted(Context context, Map<TaskOption, dynamic> options) {
    throw const KlutterException("BOOM!");
  }
}

class _InvalidTask extends Task {
  _InvalidTask() : super(TaskName.add, {TaskOption.group: FakeInput()});

  @override
  Future<String> toBeExecuted(
      Context context, Map<TaskOption, dynamic> options) {
    return Future.value("");
  }
}

class FakeInput extends Input<String> {
  @override
  String convertOrThrow(String value) => "bar";

  @override
  String get description => "foo";
}
