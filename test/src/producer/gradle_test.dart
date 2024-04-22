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
import "package:klutter/src/producer/gradle.dart";
import "package:test/test.dart";

void main() {
  final s = Platform.pathSeparator;

  test("Verify exception is thrown if root does not exist", () {
    expect(
        () => Gradle("fake").copyToRoot,
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith("Path does not exist:") &&
            e.cause.endsWith("fake"))));
  });

  test("Verify Gradle files are copied to the root folder", () async {
    final root = Directory("${Directory.systemTemp.path}${s}gradle10")
      ..createSync(recursive: true);

    await Gradle(root.normalizeToDirectory.absolutePath).copyToRoot;

    final properties = File("${root.path}/gradle.properties").normalizeToFile;
    final wrapperJar =
        File("${root.path}/gradle/wrapper/gradle-wrapper.jar").normalizeToFile;
    final wrapperProperties =
        File("${root.path}/gradle/wrapper/gradle-wrapper.properties")
            .normalizeToFile;
    final wrapperSh = File("${root.path}/gradlew").normalizeToFile;
    final wrapperBat = File("${root.path}/gradlew.bat").normalizeToFile;

    expect(properties.existsSync(), true,
        reason: "gradle.properties should exist");
    expect(wrapperJar.existsSync(), true,
        reason: "gradle-wrapper.jar should exist");
    expect(wrapperProperties.existsSync(), true,
        reason: "gradle-wrapper.properties should exist");
    expect(wrapperSh.existsSync(), true, reason: "gradlew should exist");
    expect(wrapperBat.existsSync(), true, reason: "gradlew.bat should exist");

    root.deleteSync(recursive: true);
  });

  test("Verify exception is thrown if root does not exist", () {
    expect(
        () => Gradle("fake").copyToAndroid,
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith("Path does not exist:") &&
            e.cause.endsWith("fake"))));
  });

  test("Verify exception is thrown if root/android does not exist", () {
    final root = Directory("${Directory.systemTemp.path}${s}gradle20")
      ..createSync(recursive: true);

    expect(
        () => Gradle(root.path).copyToAndroid,
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith("Path does not exist:"))));

    root.deleteSync(recursive: true);
  });

  test("Verify Gradle files are copied to the root/android folder", () async {
    final root = Directory("${Directory.systemTemp.path}${s}gradle30")
      ..createSync(recursive: true);

    final android = Directory("${root.path}/android".normalize)
      ..createSync(recursive: true);

    await Gradle(root.path).copyToAndroid;

    final properties =
        File("${android.path}/gradle.properties").normalizeToFile;
    final wrapperJar = File("${android.path}/gradle/wrapper/gradle-wrapper.jar")
        .normalizeToFile;
    final wrapperProperties =
        File("${android.path}/gradle/wrapper/gradle-wrapper.properties")
            .normalizeToFile;
    final warpperSh = File("${android.path}/gradlew").normalizeToFile;
    final wrapperBat = File("${android.path}/gradlew.bat").normalizeToFile;

    expect(properties.existsSync(), true,
        reason: "gradle.properties should exist");
    expect(wrapperJar.existsSync(), true,
        reason: "gradle-wrapper.jar should exist");
    expect(wrapperProperties.existsSync(), true,
        reason: "gradle-wrapper.properties should exist");
    expect(warpperSh.existsSync(), true, reason: "gradlew should exist");
    expect(wrapperBat.existsSync(), true, reason: "gradlew.bat should exist");

    root.deleteSync(recursive: true);
  });
}
