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

import "../common/utilities.dart";
import "resource.dart";

/// Copy Gradle files to root and root/android folders to enable the usage of Gradle.
///
/// Copies the following files to both root and root/android:
/// - gradlew
/// - gradlew.bat
/// - gradle.properties
/// - gradle/wrapper/gradle-wrapper.jar
/// - gradle/wrapper/gradle-wrapper.properties
///
/// {@category producer}
/// {@category gradle}
class Gradle {
  /// Create a Gradle instance based of the Flutter project root folder.
  Gradle(this.pathToRoot, this.resourcesDirectory) {
    _gradleProperties = LocalResource(
        pathToSource:
            resourcesDirectory.resolveFile("gradle.properties").absolutePath,
        filename: "gradle.properties",
        targetRelativeToRoot: "");
    _gradlew = LocalResource(
        pathToSource: resourcesDirectory.resolveFile("gradlew").absolutePath,
        filename: "gradlew",
        targetRelativeToRoot: "");
    _gradlewBat = LocalResource(
        pathToSource:
            resourcesDirectory.resolveFile("gradlew.bat").absolutePath,
        filename: "gradlew.bat",
        targetRelativeToRoot: "");
    _gradlewJar = LocalResource(
        pathToSource:
            resourcesDirectory.resolveFile("gradle-wrapper.jar").absolutePath,
        filename: "gradle-wrapper.jar",
        targetRelativeToRoot: "gradle/wrapper".normalize);
    _gradlewProperties = LocalResource(
        pathToSource: resourcesDirectory
            .resolveFile("gradle-wrapper.properties")
            .absolutePath,
        filename: "gradle-wrapper.properties",
        targetRelativeToRoot: "gradle/wrapper".normalize);
  }

  /// The Flutter project root folder.
  final String pathToRoot;

  /// The directory containing the gradle-wrapper files.
  final Directory resourcesDirectory;

  late final LocalResource _gradlew;
  late final LocalResource _gradlewBat;
  late final LocalResource _gradlewJar;
  late final LocalResource _gradlewProperties;
  late final LocalResource _gradleProperties;

  /// Copy Gradle files to the project root folder.
  ///
  /// Copies the following files:
  /// - gradlew
  /// - gradlew.bat
  /// - gradle.properties
  /// - gradle/wrapper/gradle-wrapper.jar
  /// - gradle/wrapper/gradle-wrapper.properties
  Future<void> get copyToRoot async {
    pathToRoot.verifyExists.rootFolder.copyFiles([
      _gradlew,
      _gradlewBat,
      _gradlewJar,
      _gradleProperties,
      _gradlewProperties
    ]);
  }

  /// Copy Gradle files to the project root/android folder.
  ///
  /// Copies the following files:
  /// - gradlew
  /// - gradlew.bat
  /// - gradle.properties
  /// - gradle/wrapper/gradle-wrapper.jar
  /// - gradle/wrapper/gradle-wrapper.properties
  Future<void> get copyToAndroid async {
    pathToRoot.verifyExists.androidFolder.copyFiles([
      _gradlewBat,
      _gradlew,
      _gradleProperties,
      _gradlewJar,
      _gradlewProperties,
    ]);
  }
}

extension on String {
  Directory get rootFolder => Directory(this);

  Directory get androidFolder =>
      Directory("$this/android".normalize)..absolutePath.verifyExists;
}
