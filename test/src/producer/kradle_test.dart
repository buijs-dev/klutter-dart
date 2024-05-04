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

import "package:klutter/src/common/common.dart";
import "package:klutter/src/producer/kradle.dart";
import "package:test/test.dart";

void main() {
  final s = Platform.pathSeparator;

  test("Verify exception is thrown if root does not exist", () {
    expect(
        () => Kradle("fake").copyToRoot,
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith("Path does not exist:") &&
            e.cause.endsWith("fake"))));
  });

  test("Verify Kradle files are copied to the root folder", () async {
    final root = Directory("${Directory.systemTemp.path}${s}kradle10")
      ..createSync(recursive: true);

    await Kradle(root.normalizeToDirectory.absolutePath).copyToRoot;

    final env = File("${root.path}/kradle.env").normalizeToFile;
    final yaml = File("${root.path}/kradle.yaml").normalizeToFile;

    expect(env.existsSync(), true, reason: "kradle.env should exist");
    expect(yaml.existsSync(), true, reason: "kradle.yaml should exist");

    root.deleteSync(recursive: true);
  });
}
