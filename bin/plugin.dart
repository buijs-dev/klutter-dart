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

import 'dart:io';

import 'package:klutter/src/producer/platform.dart' as platform;
import 'package:klutter/src/producer/android.dart' as android;
import 'package:klutter/src/common/shared.dart';
import 'package:klutter/src/common/exception.dart';
import 'package:klutter/src/common/project.dart';
import 'package:klutter/src/producer/binaries.dart';

/// Enable the usage of Klutter made plugins in a Flutter project.
///
///[Author] Gillian Buijs.
Future<void> main(List<String> args) async {
  """
  ════════════════════════════════════════════
     KLUTTER (v0.1.0)                               
  ════════════════════════════════════════════
  """
      .ok;

  switch (args.length) {
    case 0:
      return "Missing task argument. Specify which task to run: [create]."
          .invalid;
    case 1:
      return run(args[0].toUpperCase());
    default:
      return "Too many arguments supplied.".invalid;
  }
}

void run(String task) {
  if (task == "CREATE") {
    create();
  } else {
    "Unknown task argument. Specify which task to run: [create].".invalid;
  }
}

//TODO setup iOS
void create() {
  final pathToRoot = Directory.current.absolutePath;
  final pathToAndroid = "$pathToRoot/android".normalize;
  final pluginName = findPluginName(pathToRoot);
  final packageName = findPackageName(pathToRoot);
  final pluginVersion = findPluginVersion(pathToRoot);

  <String, List<int>>{
    "gradlew": gradlewSh,
    "gradlew.bat": gradlewBat,
  }.forEach((filename, filecontent) => pathToRoot.toFile.child(filename)
    ..createSync()
    ..writeAsBytesSync(filecontent));

  try {
    platform.writeSettingsGradleFile(pathToRoot, pluginName);
    platform.writeBuildGradleFile(pathToRoot);
    platform.writeGradleProperties(pathToRoot);
    android.writeBuildGradleFile(
      pathToAndroid: pathToAndroid,
      packageName: packageName,
      pluginVersion: pluginVersion,
    );
    android.writeAndroidPlugin(
      pathToAndroid: pathToAndroid,
      packageName: packageName,
    );
  } on KlutterException catch (e) {
    return "KLUTTER: $e.cause".format.nok;
  }

  "KLUTTER: Plugin setup complete!".ok;
}

extension on String {
  void get ok => print('\x1B[32m${this}');

  void get nok => print('\x1B[31m${this}');

  void get invalid => print(
        "\x1B[31mKLUTTER: ${this} Example usage: 'flutter pub run klutter:plugin create'",
      );

  File get toFile => File(this);
}

extension on File {
  File child(String child) =>
      File("$absolutePath${Platform.pathSeparator}$child");
}