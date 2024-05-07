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

import "../common/project.dart";
import "../common/utilities.dart";
import "../consumer/android.dart";
import "context.dart";
import "option.dart";
import "task.dart";

/// Task to add a Klutter-made Flutter plugin to a Flutter project.
///
/// {@category consumer}
class AddLibrary extends Task {
  /// Create new Task based of the root folder.
  AddLibrary()
      : super(TaskName.add, {
          TaskOption.lib: const LibraryName(),
          TaskOption.root: RootDirectoryInput(),
        });

  @override
  Future<void> toBeExecuted(
      Context context, Map<TaskOption, dynamic> options) async {
    final pathToRoot = findPathToRoot(context, options);
    final pluginName = options[TaskOption.lib];
    final location = findDependencyPath(
      pathToRoot: pathToRoot,
      pluginName: pluginName,
      pathToSDK: findFlutterSDK("$pathToRoot/android".normalize),
    );

    // ignore: avoid_print
    print("adding klutter library: $pluginName");
    registerPlugin(
      pathToRoot: pathToRoot,
      pluginName: ":klutter:$pluginName",
      pluginLocation: location,
    );
  }
}
