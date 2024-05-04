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
  test("Valid Flutter versions are returned as VerifiedFlutterVersion", () {
    for (final version in supportedFlutterVersions.keys) {
      expect(version.verifyFlutterVersion != null, true,
          reason: "Version should be valid: $version");
      expect("$version.windows.x64".verifyFlutterVersion != null, true,
          reason: "Version should be valid: $version.windows.x64");
      expect("$version.macos.x64".verifyFlutterVersion != null, true,
          reason: "Version should be valid: $version.macos.x64");
      expect("$version.linux.x64".verifyFlutterVersion != null, true,
          reason: "Version should be valid: $version.linux.x64");
      expect("$version.windows.arm64".verifyFlutterVersion != null, true,
          reason: "Version should be valid: $version.windows.arm64");
      expect("$version.macos.arm64".verifyFlutterVersion != null, true,
          reason: "Version should be valid: $version.macos.arm64");
      expect("$version.linux.arm64".verifyFlutterVersion != null, true,
          reason: "Version should be valid: $version.linux.arm64");
    }
  });

  test("Invalid Flutter versions are returned as null", () {
    expect("thisIsNotAFlutterVersion".verifyFlutterVersion == null, true);
  });

  group("Verify version sort order is descending by default", () {
    void testSorting(String a, String b, List<String> expected) {
      test("$a > $b", () {
        final sortedList = [a.toVersion, b.toVersion]..sort();
        expect(sortedList.map((e) => e.prettyPrint).toList(), expected);
      });
    }

    testSorting("1.0.0", "1.0.0", ["1.0.0", "1.0.0"]);
    testSorting("1.0.0", "1.1.0", ["1.1.0", "1.0.0"]);
    testSorting("1.0.0", "1.0.1", ["1.0.1", "1.0.0"]);
    testSorting("0.1.0", "0.0.1", ["0.1.0", "0.0.1"]);
  });
}

extension on String {
  Version get toVersion {
    final splitted = split(".");
    return Version(
      major: int.parse(splitted[0]),
      minor: int.parse(splitted[1]),
      patch: int.parse(splitted[2]),
    );
  }
}
