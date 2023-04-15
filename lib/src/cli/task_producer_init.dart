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
import "dart:isolate";

import "../common/common.dart";
import "../producer/android.dart";
import "../producer/gradle.dart";
import "../producer/ios.dart";
import "../producer/platform.dart";
import "../producer/project.dart";
import "cli.dart";

/// Task to run project initialization (setup).
///
/// {@category producer}
class ProducerInit extends Task {
  /// Create new Task based of the root folder.
  ProducerInit() : super(ScriptName.producer, TaskName.init);

  @override
  void toBeExecuted(String pathToRoot) => pathToRoot
    ..setupRoot
    ..setupAndroid
    ..setupIOS
    ..setupPlatform
    ..setupExample
    ..addGradle;
}

extension on String {
  void get setupRoot {
    Directory("$this/lib".normalize)
      // Delete folder and all children if they exist.
      ..normalizeToFolder.maybeDelete
      // Create a new empty lib folder.
      ..maybeCreate;

    final name = findPluginName(this);
    writeGradleProperties(this);

    writeRootBuildGradleFile(
      pathToRoot: this,
      pluginName: name,
    );

    writeRootSettingsGradleFile(
      pathToRoot: this,
      pluginName: name,
    );
  }

  void get setupAndroid {
    final packageName = findPackageName(this);
    final pluginVersion = findPluginVersion(this);
    final pathToAndroid = "$this/android".normalize;

    writeBuildGradleFile(
      pathToAndroid: pathToAndroid,
      packageName: packageName,
      pluginVersion: pluginVersion,
    );

    writeAndroidPlugin(
      pathToAndroid: pathToAndroid,
      packageName: packageName,
    );

    writeKlutterGradleFile(pathToAndroid);
  }

  void get setupPlatform {
    createPlatformModule(
      pathToRoot: this,
      pluginName: findPluginName(this),
      packageName: findPackageName(this),
    );
  }

  void get setupExample {
    writeExampleMainDartFile(
      pathToExample: "${this}/example".normalize,
      pluginName: findPluginName(this),
    );
  }

  void get setupIOS {
    final pathToIos = "$this/ios";
    createIosKlutterFolder(pathToIos);
    addFrameworkToPodspec(
      pathToIos: "$this/ios",
      pluginName: findPluginName(this),
    );
    addFlutterEngineXCFramework(pathToIos);
  }

  Future<void> get addGradle async {
    final gradle = Gradle(this);
    await Future.wait([
      gradle.copyToRoot,
      gradle.copyToAndroid,
    ]);
  }

  Future<void> addFlutterEngineXCFramework(String pathToIos) async {
    await Isolate.resolvePackageUri(Uri.parse("package:klutter/res/FlutterEngine.xcframework")).then((source) {
      if(source == null) {
        throw KlutterException("FlutterEngine.xcframework does not exist.");
      }

      final pathFrom = Directory(source.path);
      final pathTo = Directory("$pathToIos/Klutter/FlutterEngine.xcframework").maybeCreate;
      final result = Process.runSync("cp", ["-R", pathFrom.absolutePath, pathTo.absolutePath],);
      stdout.write(result.stdout);
      stderr.write(result.stderr);
    });
  }

}
