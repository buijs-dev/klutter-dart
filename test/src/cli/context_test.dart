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
  test("Verify parsing get flutter context", () {
    final context =
        toContextOrNull(Directory.current, ["flutter=3.10.6.macos.x64"]);
    expect(context != null, true);
  });

  test("Verify parsing producer init context", () {
    final context = toContextOrNull(Directory.current, [
      "bom=2023.1.1.beta",
      "flutter=3.10.6.macos.arm64",
    ]);

    expect(context != null, true);
    expect(context!.taskOptions.isNotEmpty, true);
    expect(context.taskOptions[TaskOption.bom], "2023.1.1.beta");
    expect(context.taskOptions[TaskOption.flutter], "3.10.6.macos.arm64");
  });

  test("When an argument is not a valid option value then context is null", () {
    final context = toContextOrNull(Directory.current, [
      "init",
      "woot=2023.1.1.beta",
      "flutter=3.10.6.macos.arm64",
    ]);

    expect(context == null, true,
        reason: "context should be null because argument is invalid");
  });

  test("When get context has more than 1 argument, context is null", () {
    final context = toContextOrNull(Directory.current, ["get", "this", "and"]);

    expect(context == null, true,
        reason:
            "context should be null because get can only have one argument");
  });

  for (final value in [
    "3.10=6=10",
    "'3.10=6=10'",
    '"3.10=6=10"',
    "    3.10  "
  ]) {
    test("Verify parsing options", () {
      final options = toTaskOptionsOrNull(["flutter=$value"]);
      expect(options != null, true,
          reason: "options should be parsed successfully");
      final flutter = options![TaskOption.flutter];
      expect(flutter, value.trim(), reason: "value should be stored");
    });
  }

  for (final value in ["", "    ", "=", "=    ", "   =  "]) {
    test("Verify parsing options fails on missing value", () {
      expect(toTaskOptionsOrNull(["flutter$value"]), null);
    });
  }

  test("When arguments are null then toContextOrNull has no options", () {
    final context = toContextOrNull(Directory.current, []);
    expect(context != null, true);
    expect(context!.taskOptions.isEmpty, true);
  });

  test("Verify copyWith merges options maps", () {
    final map1 = {TaskOption.bom: "da-bom", TaskOption.name: "name"};
    final map2 = {TaskOption.bom: "not-da-bom", TaskOption.klutterui: "union"};
    final context = Context(Directory(""), map1);
    final copied = context.copyWith(taskOptions: map2);
    final copiedMap = copied.taskOptions;
    expect(copiedMap.length, 3);
    expect(copiedMap[TaskOption.bom], map2[TaskOption.bom]);
    expect(copiedMap[TaskOption.name], map1[TaskOption.name]);
    expect(copiedMap[TaskOption.klutterui], map2[TaskOption.klutterui]);
  });
}
