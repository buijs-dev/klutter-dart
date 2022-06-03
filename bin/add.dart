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

import "package:klutter/src/common/exception.dart";
import "package:klutter/src/common/project.dart";
import "package:klutter/src/common/shared.dart";
import "package:klutter/src/consumer/android.dart";

/// Enable the usage of Klutter made plugins in a Flutter project.
Future<void> main(List<String> args) async {
  """
  ════════════════════════════════════════════
     KLUTTER (v0.1.0)                               
  ════════════════════════════════════════════
  """
      .ok;

  switch (args.length) {
    case 0:
      return "Missing plugin name.".invalid;
    case 1:
      return register(args[0]);
    default:
      return "Too many arguments supplied.".invalid;
  }
}

void register(String plugin) {
  final root = Directory.current.absolutePath;

  final location = findDependencyPath(
    pathToSDK: findFlutterSDK("$root/android".normalize),
    pathToRoot: root,
    pluginName: plugin,
  );

  try {
    registerPlugin(
      pathToRoot: root,
      pluginName: ":klutter:$plugin",
      pluginLocation: location,
    );
  } on KlutterException catch (e) {
    return "KLUTTER: $e.cause".format.nok;
  }

  "KLUTTER: Successfully added plugin '$plugin'.".ok;
}

extension on String {
  void get ok => print("\x1B[32m${this}");
  void get nok => print("\x1B[31m${this}");
  void get invalid => print(
        "\x1B[31mKLUTTER: ${this} Example usage: 'flutter pub run klutter:add awesome_plugin'",
      );
}
