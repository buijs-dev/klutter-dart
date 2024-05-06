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
  test("GetFlutterSDK downloads latest compatible if version is not set",
      () async {
    final task = GetFlutterSDK();
    final result = await task.execute(context({TaskOption.dryRun: "true"}));
    expect(result.isOk, true);
  });

  test("GetFlutterSDK fails when Flutter SDK is incorrect", () async {
    final result = await GetFlutterSDK().execute(
        context({TaskOption.flutter: "0.0.0", TaskOption.dryRun: "true"}));

    expect(result.isOk, false);
    expect(result.message,
        "unable to run task get because: [invalid value for option flutter: invalid flutter version (supported versions are: (3.0.5, 3.3.10, 3.7.12, 3.10.6)): 0.0.0]");
  });

  test("GetFlutterSDK uses OS from version if present in version String",
      () async {
    final task = GetFlutterSDK();
    final root = Directory.systemTemp;
    root.resolveFile("kradle.env")
      ..createSync()
      ..writeAsStringSync("cache=${root.absolutePath}");
    final result = await task.execute(context({
      TaskOption.flutter: "3.3.10.linux.x64",
      TaskOption.dryRun: "true",
      TaskOption.root: root.absolutePath,
    }));
    expect(result.isOk, true, reason: result.message ?? "");
  });

  test("Verify skipDownload", () async {
    platform = PlatformWrapper()
      ..environmentMap = {"GET_FLUTTER_SDK_SKIP": "SKIPPIE"};
    final task = GetFlutterSDK();
    expect(task.skipDownload(true), true);
    expect(task.skipDownload(false), true);
    platform = PlatformWrapper();
    expect(task.skipDownload(true), true);
    expect(task.skipDownload(false), false);
  });

  test("Verify requiresDownload", () async {
    final task = GetFlutterSDK();
    final fakeDirectory = Directory("fake");
    final realDirectory = Directory.current;
    expect(task.requiresDownload(fakeDirectory, false), true);
    expect(task.requiresDownload(fakeDirectory, true), true);
    expect(task.requiresDownload(realDirectory, false), false);
    expect(task.requiresDownload(realDirectory, true), true);
  });

  test(
      "Verify toFlutterDistributionOrThrow throws exception for unsupported platform",
      () {
    expect(
        () => toFlutterDistributionOrThrow(
            platformWrapper: UnknownPlatform(),
            pathToRoot: Directory.systemTemp.resolveFolder("foo").absolutePath,
            version: const VerifiedFlutterVersion(
                Version(major: 1, minor: 1, patch: 1))),
        throwsA(predicate((e) => e is KlutterException)));
  });
}

Context context(Map<TaskOption, String> options) => Context(
    taskName: TaskName.get,
    workingDirectory: Directory.current,
    taskOptions: options);

class UnknownPlatform extends PlatformWrapper {
  @override
  bool get isWindows => false;

  @override
  bool get isMacos => false;

  @override
  bool get isLinux => false;
}
