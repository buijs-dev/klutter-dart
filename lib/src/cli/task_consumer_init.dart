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

import "../common/exception.dart";
import "../common/project.dart";
import "../common/utilities.dart";
import "../consumer/android.dart";
import "cli.dart";

/// Task to prepare a Flutter project for using Klutter-made plugins.
///
/// {@category consumer}
class ConsumerInit extends Task {
  /// Create new Task based of the root folder.
  ConsumerInit() : super(ScriptName.consumer, TaskName.init);

  @override
  void toBeExecuted(String pathToRoot) {
    switch (option) {
      case "android":
      case "":
        _executeInitAndroid(pathToRoot);
        break;
      default:
        throw KlutterException("Invalid option value: '$option'");
    }
  }

  @override
  List<String> optionValues() => ["", "android"];
}

void _executeInitAndroid(String pathToRoot) {
  final pathToAndroid = "$pathToRoot/android".normalize;
  final sdk = findFlutterSDK(pathToAndroid);
  final app = "$pathToAndroid/app".normalize;

  writePluginLoaderGradleFile(sdk);
  createRegistry(pathToRoot);
  applyPluginLoader(pathToAndroid);
  setAndroidSdkConstraints(app);
  setKotlinVersionInBuildGradle(pathToAndroid);
}