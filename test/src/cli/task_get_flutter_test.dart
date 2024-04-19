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
import "package:test/test.dart";

void main() {

  test("GetFlutterSDK fails when Flutter SDK is not set", () async {
    final task = GetFlutterSDK();
    final result = await task.execute("");
    expect(result.isOk, false);
    expect(result.message, "Invalid Flutter version (supported versions are: (3.0.5, 3.3.10, 3.7.12, 3.10.6)): null");
  });

  test("GetFlutterSDK uses OS from version if present in version String", () async {
    final task = GetFlutterSDK()
      ..options = {
      ScriptOption.flutter : "3.3.10.linux.x64",
      ScriptOption.dryRun : "true"
    };

    final root = Directory.systemTemp;
    root.resolveFile("kradle.env")
      ..createSync()
      ..writeAsStringSync("cache=${root.absolutePath}");
    final result = await task.execute(root.absolutePath);
    expect(result.isOk, true);
  });
}
