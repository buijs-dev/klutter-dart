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

import "../common/exception.dart";
import "../common/utilities.dart";

/// Overwrite the build.gradle file in the root/android folder.
///
/// {@category producer}
void createIosKlutterFolder(String pathToIos) => pathToIos.verifyExists
  ..createKlutterFolder
  ..createKlutterReadmeFile;

/// Edit the root/ios/<plugin-name>.podspec file to depend on the
/// fat-framework build by the platform module.
///
/// The generated framework will be copied to the root/ios/Klutter folder.
///
/// {@category producer}
void addFrameworkToPodspec({
  required String pathToIos,
  required String pluginName,
}) =>
    pathToIos.verifyExists.toPodspec(pluginName).addFramework;

extension on String {
  void get createKlutterFolder {
    Directory("$this/Klutter").normalizeToFolder.maybeCreate;
  }

  void get createKlutterReadmeFile {
    File("$this/Klutter/klutter.md").normalizeToFile.maybeCreate;
  }

  File toPodspec(String pluginName) =>
      File("$this/$pluginName.podspec").normalizeToFile
        ..ifNotExists((file) {
          throw KlutterException("Missing podspec file: ${file.path}");
        });
}

extension on File {
  void get addFramework {
    final regex = RegExp("Pod::Spec.new.+?do.+?.([^|]+?).");

    /// Check the prefix used in the podspec or default to 's'.
    ///
    /// By default the podspec file uses 's' as prefix.
    /// In case a podspec does not use this default,
    /// this regex will find the custom prefix.
    ///
    /// If not found then 's' is used.
    final prefix = regex.firstMatch(readAsStringSync())?.group(1) ?? "s";

    // INPUT
    final lines = readAsLinesSync();

    // OUTPUT
    final newLines = <String>[];

    // Used to check if adding framework is done.
    var hasAdded = false;

    for (final line in lines) {
      newLines.add(line);

      // Check if line contains Flutter dependency (which should always be present).
      // If so then add the vendored framework dependency.
      // This is done so the line is added at a fixed point in the podspec.
      if (line.replaceAll(" ", "").contains("$prefix.dependency'Flutter'")) {
        newLines.add(
          """  $prefix.ios.vendored_frameworks = "Klutter/Platform.xcframework" """,
        );

        hasAdded = true;
      }
    }

    if (!hasAdded) {
      throw KlutterException(
        """
        |Failed to add Platform.framework to ios folder.
        |
        |Unable to find the following line in file $path:
        |- '$prefix.dependency 'Flutter''
        |
        |"""
            .format,
      );
    }

    // Write the editted line to the podspec file.
    writeAsStringSync(newLines.join("\n"));
  }
}
