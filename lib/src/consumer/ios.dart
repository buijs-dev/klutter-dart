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

import "../common/common.dart";

/// Create the root/ios/Klutter directory and add a readme file.
///
/// {@category consumer}
void setIosVersionInPodFile(Directory iosDirectory) =>
    iosDirectory.resolveFile("Podfile")
      ..verifyFileExists
      ..setIosVersion;

extension on File {
  void get setIosVersion {
    // INPUT
    final lines = readAsLinesSync();

    // OUTPUT
    final newLines = <String>[];

    // Used to check if adding framework is done.
    var hasExplicitPlatformVersion = false;

    for (final line in lines) {
      final trimmed = line.replaceAll(" ", "");
      // Check if line sets ios platform version
      // and if so then update the version.
      if (trimmed.contains("platform:ios,")) {
        newLines.add("platform :ios, '$iosVersion'");
        hasExplicitPlatformVersion = true;
      } else {
        newLines.add(line);
      }
    }

    if (!hasExplicitPlatformVersion) {
      throw const KlutterException("Failed to set ios version in Podfile.");
    }

    // Write the editted line to the podspec file.
    writeAsStringSync(newLines.join("\n"));
  }
}
