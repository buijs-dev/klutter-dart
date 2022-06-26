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
import "../common/shared.dart";
import "../consumer/android.dart";
import "library.dart";

/// Task to add a Klutter-made Flutter plugin to a Flutter project.
class ConsumerAdd extends Task {
  /// Create new Task based of the root folder.
  ConsumerAdd() : super(ScriptName.consumer, TaskName.add);

  @override
  void toBeExecuted(String pathToRoot) {
    if (option == "") {
      throw KlutterException(
        "Name of Flutter plugin to add not specified.",
      );
    }

    final location = findDependencyPath(
      pathToRoot: pathToRoot,
      pluginName: option,
      pathToSDK: findFlutterSDK(
        "$pathToRoot/android".normalize,
      ),
    );

    registerPlugin(
      pathToRoot: pathToRoot,
      pluginName: ":klutter:$option",
      pluginLocation: location,
    );
  }

  @override
  List<Task> dependsOn() => [ConsumerInit()];

  @override
  List<String> optionValues() => ["<name_of_plugin_to_add>"];
}
