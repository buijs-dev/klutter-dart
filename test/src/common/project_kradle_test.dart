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
import "dart:math";
import "package:klutter/klutter.dart";
import "package:test/test.dart";

final _platform = FakePlatformWrapper();

Directory get _newProjectFolder => Directory.systemTemp
    .resolveDirectory("project_test${Random().nextInt(999999)}")
  ..createSync();

void setPlatform(String os, String homeKey, String homeValue) {
  _platform
    ..environment = {homeKey: homeValue}
    ..operatingSystem = os;
}

void setPlatformMacos(Directory rootDirectory) {
  setPlatform("macos", "HOME", rootDirectory.absolutePath);
}

void setPlatformLinux(Directory rootDirectory) {
  setPlatform("linux", "HOME", rootDirectory.absolutePath);
}

void setPlatformWindows(Directory rootDirectory) {
  setPlatform("windows", "USERPROFILE", rootDirectory.absolutePath);
}

void createCacheFolder(Directory rootDirectory) {
  rootDirectory.resolveDirectory(".kradle/cache".normalize).maybeCreate;
}

void createKradleEnv(Directory rootDirectory, {String? contents}) {
  rootDirectory.resolveFile("kradle.env")
    ..createSync()
    ..writeAsStringSync(contents ?? "");
}

void main() {
  setUpAll(() {
    platform = _platform;
  });

  group("Default cache is set to user.home/.kradle/cache", () {
    void testPlatform(void Function(Directory root) init, String platform) {
      test(platform, () {
        final rootDirectory = _newProjectFolder;
        init(rootDirectory);
        createCacheFolder(rootDirectory);
        final actual = rootDirectory.kradleCache.absolutePath;
        final expected =
            "${rootDirectory.absolutePath}/.kradle/cache".normalize;
        expect(actual, expected);
      });
    }

    testPlatform(setPlatformMacos, "macos");
    testPlatform(setPlatformLinux, "linux");
    testPlatform(setPlatformWindows, "windows");
  });

  group("Exception is thrown without kradle.env and user.home", () {
    void testPlatform(String platform, String expected) {
      test("$platform without user.home", () {
        setPlatform(platform, "", "");
        expect(
            () => _newProjectFolder.kradleCache,
            throwsA(predicate(
                (e) => e is KlutterException && e.cause.contains(expected))));
      });
    }

    testPlatform("macos", "environment variable 'HOME' is not defined");
    testPlatform("linux", "environment variable 'HOME' is not defined");
    testPlatform("windows", "environment variable 'USERPROFILE'");
    testPlatform("swodniw", "method 'userHome' is not supported on swodniw");
  });

  test(
      "When kradle.env does exist but does not contain cache property then kradleCache is set to HOME/.kradle/cache",
      () {
    final rootDirectory = _newProjectFolder;
    setPlatformMacos(rootDirectory);
    createKradleEnv(rootDirectory);
    createCacheFolder(rootDirectory);
    final actual = rootDirectory.kradleCache.absolutePath;
    final expected = "${rootDirectory.absolutePath}/.kradle/cache".normalize;
    expect(actual, expected);
  });

  group(
      "When kradle.env does exist but does not contain cache property and user.home is not defined then an exception is thrown",
      () {
    void testPlatform(String platform, String expected) {
      test(platform, () {
        final rootDirectory = _newProjectFolder;
        createKradleEnv(rootDirectory);
        setPlatform(platform, "", "");
        expect(
            () => rootDirectory.kradleCache,
            throwsA(predicate(
                (e) => e is KlutterException && e.cause.contains(expected))));
      });
    }

    testPlatform("macos", "environment variable 'HOME' is not defined");
    testPlatform("linux", "environment variable 'HOME' is not defined");
    testPlatform("windows", "environment variable 'USERPROFILE'");
    testPlatform("swodniw", "method 'userHome' is not supported on swodniw");
  });

  group(
      "When kradle.env contains cache property which has user.home variable but user.home is not defined then an exception is thrown",
      () {
    void testPlatform(String platform, String expected) {
      test(platform, () {
        final rootDirectory = _newProjectFolder;

        createKradleEnv(
          rootDirectory,
          contents: "cache={{system.user.home}}/.kradle",
        );

        setPlatform(platform, "", "");

        expect(() => rootDirectory.kradleCache, throwsA(predicate((e) {
          return e is KlutterException &&
              e.cause.contains(expected) &&
              e.cause.contains(
                  "Unable to determine kradle cache directory, because "
                  "property 'cache' in ${rootDirectory.resolveFile("kradle.env").absolutePath} "
                  "contains system.user.home variable "
                  "and $expected. Fix this issue by "
                  "replacing $kradleEnvPropertyUserHome variable with "
                  "an absolute path in ");
        })));
      });
    }

    testPlatform("macos", "environment variable 'HOME' is not defined");
    testPlatform("linux", "environment variable 'HOME' is not defined");
    testPlatform(
        "windows", "environment variable 'USERPROFILE' is not defined");
    testPlatform("swodniw", "method 'userHome' is not supported on swodniw");
  });

  group(
      "When kradle.env contains cache property which has user.home variable then it is successfully replaced",
      () {
    void testPlatform(void Function(Directory root) init, String platform) {
      test(platform, () {
        final rootDirectory = _newProjectFolder;
        init(rootDirectory);
        createCacheFolder(rootDirectory);

        createKradleEnv(
          rootDirectory,
          contents: "cache={{system.user.home}}/.kradle/cache",
        );

        final actual = rootDirectory.kradleCache.absolutePath;
        final expected =
            "${rootDirectory.absolutePath}/.kradle/cache".normalize;
        expect(actual, expected);
      });
    }

    testPlatform(setPlatformMacos, "macos");
    testPlatform(setPlatformLinux, "linux");
    testPlatform(setPlatformWindows, "windows");
  });

  test(
      "When kradle.env contains cache property without user.home variable then it is used as-is",
      () {
    final rootDirectory = _newProjectFolder;
    setPlatformMacos(rootDirectory);
    createCacheFolder(rootDirectory);
    createKradleEnv(
      rootDirectory,
      contents: "cache=${rootDirectory.absolutePath}/.kradle/cache",
    );

    final actual = rootDirectory.kradleCache.absolutePath;
    final expected = "${rootDirectory.absolutePath}/.kradle/cache".normalize;
    expect(actual, expected);
  });

  test(
      "When kradle.env contains cache property and the directory is not found then it is created",
      () {
    final dotKradleDirectory = Directory.systemTemp.resolveDirectory(".kradle")
      ..createSync();
    final cacheDirectory =
        Directory("${dotKradleDirectory.absolutePath}/cache".normalize);
    final rootDirectory = _newProjectFolder;
    setPlatformMacos(rootDirectory);
    createCacheFolder(rootDirectory);
    createKradleEnv(
      rootDirectory,
      contents: "cache=${cacheDirectory.absolutePath}",
    );

    if (cacheDirectory.existsSync()) {
      cacheDirectory.deleteSync();
    }

    expect(cacheDirectory.existsSync(), false);

    // when
    rootDirectory.kradleCache;

    // then
    expect(cacheDirectory.existsSync(), true);
  });

  tearDownAll(() {
    platform = PlatformWrapper();
  });
}

class FakePlatformWrapper extends PlatformWrapper {
  String _os = Platform.operatingSystem;

  Map<String, String> _env = Platform.environment;

  @override
  String get operatingSystem => _os;

  set operatingSystem(String value) {
    _os = value;
  }

  @override
  Map<String, String> get environment => _env;

  set environment(Map<String, String> value) {
    _env = value;
  }
}
