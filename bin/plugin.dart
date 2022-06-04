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
import "package:klutter/src/producer/android.dart" as android;
import "package:klutter/src/producer/gradle.dart";
import "package:klutter/src/producer/ios.dart" as ios;
import "package:klutter/src/producer/platform.dart" as platform;
import "package:klutter/src/producer/project.dart" as example;

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
      return "Missing task argument. "
              "Specify which task to run: [create]."
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

Future<void> create() async {
  try {
    final pathToRoot = Directory.current.absolutePath
      ..setupRoot
      ..setupAndroid
      ..setupIOS
      ..setupPlatform
      ..setupExample;

    await pathToRoot.addGradle;
  } on KlutterException catch (e) {
    return "KLUTTER: ${e.cause}".format.nok;
  }

  "KLUTTER: Plugin setup complete!".ok;
}

extension on String {
  void get ok => print('\x1B[32m${this}');

  void get nok => print('\x1B[31m${this}');

  void get invalid => print(
        "\x1B[31mKLUTTER: ${this} Example usage: 'flutter pub run klutter:plugin create'",
      );

  void get setupRoot {
    final name = findPluginName(this);
    platform.writeGradleProperties(this);
    platform.writeRootBuildGradleFile(this);
    platform.writeRootSettingsGradleFile(
      pathToRoot: this,
      pluginName: name,
    );
  }

  void get setupAndroid {
    final packageName = findPackageName(this);
    final pluginVersion = findPluginVersion(this);
    final pathToAndroid = "${this}/android".normalize;

    android.writeBuildGradleFile(
      pathToAndroid: pathToAndroid,
      packageName: packageName,
      pluginVersion: pluginVersion,
    );

    android.writeAndroidPlugin(
      pathToAndroid: pathToAndroid,
      packageName: packageName,
    );

    android.writeKlutterGradleFile(pathToAndroid);
  }

  void get setupPlatform {
    platform.createPlatformModule(
      pathToRoot: this,
      pluginName: findPluginName(this),
      packageName: findPackageName(this),
    );
  }

  void get setupExample {
    example.writeExampleMainDartFile(
      pathToExample: "${this}/example".normalize,
      pluginName: findPluginName(this),
    );
  }

  void get setupIOS {
    ios.createIosKlutterFolder("${this}/ios");
  }

  Future<void> get addGradle async {
    final gradle = Gradle(this);
    await Future.wait([
      gradle.copyToRoot,
      gradle.copyToAndroid,
    ]);
  }
}
