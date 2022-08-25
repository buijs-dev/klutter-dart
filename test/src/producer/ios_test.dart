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

import "package:klutter/klutter.dart";
import "package:test/test.dart";

void main() {
  final temp = Directory.systemTemp..createTempSync();

  test("Verify exception is thrown if podspec file does not exist", () {
    final folder = Directory("${temp.absolutePath}/ios_test1".normalize)
      ..createSync();

    expect(
        () => addFrameworkToPodspec(
            pluginName: "some_plugin", pathToIos: folder.absolutePath),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith("Missing podspec file"))));
  });

  test("Verify exception is thrown if addFramework fails", () {
    final folder = Directory("${temp.absolutePath}/ios_test2".normalize)
      ..createSync();

    File("${folder.absolutePath}/some_plugin.podspec").createSync();

    expect(
        () => addFrameworkToPodspec(
            pluginName: "some_plugin", pathToIos: folder.absolutePath),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith(
                "Failed to add Platform.framework to ios folder."))));
  });
}
