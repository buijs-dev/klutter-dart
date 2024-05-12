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

import "package:klutter/klutter.dart";
import "package:test/test.dart";

void main() {
  test("Verify InputException toString", () {
    expect(InputException("splash!").toString(),
        "InputException with cause: 'splash!'");
  });

  test("Verify SquintPubVersion returns input as-is", () {
    expect(const SquintPubVersion().convertOrThrow("1.2.3"), "1.2.3");
  });

  test("Verify KlutteruiPubVersion returns input as-is", () {
    expect(const KlutteruiPubVersion().convertOrThrow("1.2.3"), "1.2.3");
  });

  test("Verify KlutterGradleVersionOption returns input if it is valid", () {
    expect(const KlutterGradleVersionOption().convertOrThrow("2025.1.1.beta"),
        "2025.1.1.beta");
  });

  test("KlutterGradleVersionOption throws exception if input is invalid", () {
    expect(
        () => const KlutterGradleVersionOption().convertOrThrow("spidey.2099"),
        throwsA(predicate((e) =>
            e is InputException &&
            e.cause == "not a valid bom version: spidey.2099")));
  });

  test("PluginNameOption throws exception if input is invalid", () {
    expect(
        () => const PluginNameOption().convertOrThrow("spidey.2099"),
        throwsA(predicate((e) =>
            e is InputException &&
            e.cause.contains("pluginName error: Should only contain"
                " lowercase alphabetic, numeric and or _ characters"
                " and start with an alphabetic character ('my_plugin')."))));
  });

  group("GroupNameOption throws exception if input is not a bool", () {
    final option = GroupNameOption();
    void testThrowing(String groupName, String message) {
      test("$groupName throws $message", () {
        expect(
            () => option.convertOrThrow(groupName),
            throwsA(
                predicate((e) => e is InputException && e.cause == message)));
      });
    }

    testThrowing("mac",
        "GroupName error: Should contain at least 2 parts ('com.example').");
    testThrowing("mac_.d",
        "GroupName error: Characters . and _ can not precede each other.");
    testThrowing("9mac.d2",
        "GroupName error: Should be lowercase alphabetic separated by dots ('com.example').");
  });

  test("GroupNameOption throws exception if input is not a bool", () {
    expect(
        () => const UserInputBooleanOrDefault("foo", false)
            .convertOrThrow("vrooooom!"),
        throwsA(predicate((e) =>
            e is InputException &&
            e.cause == "expected a bool value but received: vrooooom!")));
  });

  test("UserInputBooleanOrDefault throws exception if input is not a bool", () {
    expect(
        () => const UserInputBooleanOrDefault("foo", false)
            .convertOrThrow("vrooooom!"),
        throwsA(predicate((e) =>
            e is InputException &&
            e.cause == "expected a bool value but received: vrooooom!")));
  });
}
