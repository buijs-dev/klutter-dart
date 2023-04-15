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

import "../common/exception.dart";
import "../common/utilities.dart";

/// Add lines to the post_install block in the Podfile
/// to exclude iphone simulator architectures.
///
/// Without doing this the app won't start on a simulator.
///
/// This function assumes the following post_install block:
///
/// ```
/// post_install do |installer|
///   installer.pods_project.targets.each do |target|
///     flutter_additional_ios_build_settings(target)
///   end
/// end
/// ```
///
/// Will produce the following post_install when done:
///
/// ```
/// post_install do |installer|
///   installer.pods_project.targets.each do |target|
///     flutter_additional_ios_build_settings(target)
///     target.build_configurations.each do |bc|
///         bc.build_settings['ARCHS[sdk=iphonesimulator*]'] =  `uname -m`
///      end
///   end
/// end
/// ```
///
/// Throws [KlutterException] if adding exclusion lines has failed.
///
/// {@category consumer}
void excludeArm64FromPodfile(String pathToIos) =>
    pathToIos.verifyExists.toPodfile.writeExclusionLines;

extension on String {
  /// Return File path to the ios/Podfile.
  File get toPodfile {
    return File("$this/Podfile".normalize);
  }
}

extension on File {
  /// Add lines to the post_install block in the Podfile
  /// to exclude iphone simulator architectures.
  ///
  /// Without doing this the app won't start on a simulator.
  void get writeExclusionLines {
    if (!existsSync()) {
      return;
    }

    const linesToAdd = [
      "             target.build_configurations.each do |bc|",
      "               bc.build_settings['ARCHS[sdk=iphonesimulator*]'] =  `uname -m`",
      "            end"
    ];

    // If lines are added then do NOT add them again.
    final text = readAsStringSync();
    final containsAllLines = <bool>[];

    for (final line in linesToAdd) {
      containsAllLines.add(text.contains(line));
    }

    if (containsAllLines.every((hasLine) => hasLine)) {
      return;
    }

    // Used to check if adding exclusion lines is done.
    var hasAdded = false;

    const line1 = "post_install do |installer|";
    const line2 = "installer.pods_project.targets.each do |target|";
    const line3 = "flutter_additional_ios_build_settings(target)";

    var hasLine1 = false;
    var hasLine2 = false;
    var hasLine3 = false;

    // INPUT
    final lines = readAsLinesSync();

    // OUTPUT
    final output = <String>[];

    for (final line in lines) {
      output.add(line);

      if (!hasAdded) {
        if (line.contains(line1)) {
          hasLine1 = true;
        }

        if (line.contains(line2)) {
          hasLine2 = true;
        }

        if (line.contains(line3)) {
          hasLine3 = true;
        }

        if (hasLine1 && hasLine2 && hasLine3) {
          hasAdded = true;
          output.addAll([
            "             target.build_configurations.each do |bc|",
            "               bc.build_settings['ARCHS[sdk=iphonesimulator*]'] =  `uname -m`",
            "            end"
          ]);
        }
      }
    }

    if (!hasAdded) {
      throw KlutterException(
        """
          |Failed to add exclusions for arm64.
          |
          |Unable to find the following lines in file $path:
          |
          |```
          |post_install do ,|installer,|
          |  installer.pods_project.targets.each do ,|target,|
          |    flutter_additional_ios_build_settings(target)
          |  end
          |end
          |```
          |
          |"""
            .format,
      );
    }

    writeAsStringSync(output.join("\n"));
  }
}
