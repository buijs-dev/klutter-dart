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

import "package:klutter/src/common/exception.dart";
import "package:klutter/src/consumer/android.dart";
import "package:test/test.dart";

void main() {
  final s = Platform.pathSeparator;

  test("Verify exception is thrown if root/android does not exist", () {
    expect(
        () => findFlutterSDK("fake"),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith("Path does not exist:") &&
            e.cause.endsWith("fake"))));
  });

  test(
      "Verify exception is thrown if root/android/local.properties does not exist",
      () {
    final root = Directory("${Directory.systemTemp.path}${s}plt1")
      ..createSync();

    final android = Directory("${root.absolute.path}${s}android")..createSync();

    expect(
        () => findFlutterSDK(android.path),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause ==
                "Missing local.properties file in folder: ${android.absolute.path}")));

    root.deleteSync(recursive: true);
  });

  test("Verify exception is thrown if property key does not exists", () {
    final root = Directory("${Directory.systemTemp.path}${s}plt2")
      ..createSync();

    final android = Directory("${root.absolute.path}${s}android")..createSync();

    File("${android.absolute.path}${s}local.properties").createSync();

    // An exception is thrown
    expect(
        () => findFlutterSDK(android.path),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause ==
                "Missing property 'flutter.sdk' in local.properties file.")));

    root.deleteSync(recursive: true);
  });

  test("Verify property value is returned if property key exists", () {
    final root = Directory("${Directory.systemTemp.path}${s}plt3")
      ..createSync();

    final android = Directory("${root.absolute.path}${s}android")..createSync();

    File("${android.absolute.path}${s}local.properties")
      ..createSync()
      ..writeAsStringSync("""
          sdk.dir=/Users/chewbacca/Library/Android/sdk
          flutter.sdk=/Users/chewbacca/tools/flutter
          flutter.versionName=1.0.0
          flutter.versionCode=1
          foo
          bar=""");

    expect(findFlutterSDK(android.path), "/Users/chewbacca/tools/flutter");

    root.deleteSync(recursive: true);
  });

  test("Verify exception is thrown if root does not exist", () {
    expect(
        () => writePluginLoaderGradleFile("fake"),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith("Path does not exist:") &&
            e.cause.endsWith("fake"))));
  });

  test("Verify a new Gradle file is created if it does not exist", () {
    final root = Directory("${Directory.systemTemp.path}${s}sgt1")
      ..createSync();

    final pluginLoader = File("${root.absolute.path}"
        "${s}packages${s}flutter_tools${s}gradle${s}klutter_plugin_loader.gradle.kts");

    if (pluginLoader.existsSync()) {
      pluginLoader.deleteSync();
      expect(pluginLoader.existsSync(), false, reason: "file should not exist");
    }

    writePluginLoaderGradleFile(root.path);

    expect(
        pluginLoader.readAsStringSync().replaceAll(" ", ""),
        r'''
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
            
            import java.io.File
            
            val flutterProjectRoot = rootProject.projectDir.parentFile
            val pluginsFile = File("$flutterProjectRoot/.klutter-plugins")
            if (pluginsFile.exists()) {
              pluginsFile.readLines().forEach { line ->
                val plugin = line.split("=").also {
                  if(it.size != 2) throw GradleException("""
                    Invalid Klutter plugin config.
                    Check the .klutter-plugins file in the project root folder.
                    Required format is: ':klutter:libraryname=local/path/to/flutter/cache/library/artifacts/android'
                  """.trimIndent())
                }
            
                var pluginPath = plugin[1]
                if(pluginPath.startsWith("${'$'}root")) {
                   pluginPath = pluginPath.replace("${'$'}root", "$flutterProjectRoot")
                }
                       
                val pluginDirectory = File(pluginPath).also {
                    if(!it.exists()) throw GradleException("""
                         Invalid path for Klutter plugin: '$it'.
                         Check the .klutter-plugins file in the project root folder.
                     """.trimIndent())
                }
            
                include(plugin[0])
                project(plugin[0]).projectDir = pluginDirectory
              }
            }'''
            .replaceAll(" ", ""));

    root.deleteSync(recursive: true);
  });

  test("Verify content is overwritten if the Gradle file already exists", () {
    final root = Directory("${Directory.systemTemp.path}${s}sgt2")
      ..createSync(recursive: true);

    final pluginLoader = File("${root.absolute.path}"
        "${s}packages${s}flutter_tools${s}gradle${s}klutter_plugin_loader.gradle.kts")
      ..createSync(recursive: true)
      ..writeAsStringSync("some nonsense");

    // Run test
    writePluginLoaderGradleFile(root.path);

    // Content should be overwritten
    expect(
        pluginLoader.readAsStringSync().replaceAll(" ", ""),
        r'''
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

        import java.io.File

          val flutterProjectRoot = rootProject.projectDir.parentFile
          val pluginsFile = File("$flutterProjectRoot/.klutter-plugins")
          if (pluginsFile.exists()) {
            pluginsFile.readLines().forEach { line ->
              val plugin = line.split("=").also {
              if(it.size != 2) throw GradleException("""
                                Invalid Klutter plugin config.
                                Check the .klutter-plugins file in the project root folder.
                                Required format is: ':klutter:libraryname=local/path/to/flutter/cache/library/artifacts/android'
                              """.trimIndent())
              }
            
              var pluginPath = plugin[1]
              if(pluginPath.startsWith("${'$'}root")) {
              pluginPath = pluginPath.replace("${'$'}root", "$flutterProjectRoot")
              }
            
              val pluginDirectory = File(pluginPath).also {
              if(!it.exists()) throw GradleException("""
                                     Invalid path for Klutter plugin: '$it'.
                                     Check the .klutter-plugins file in the project root folder.
                                 """.trimIndent())
              }
            
              include(plugin[0])
              project(plugin[0]).projectDir = pluginDirectory
              }
              }'''
            .replaceAll(" ", ""));

    root.deleteSync(recursive: true);
  });

  test(
      "Verify exception is thrown if root/android/settings.gradle does not exist",
      () {
    final root = Directory("${Directory.systemTemp.path}${s}apl1")
      ..createSync();

    final android = Directory("${root.path}${s}android")..createSync();

    expect(
        () => applyPluginLoader(android.path),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.contains("Missing settings.gradle file in folder"))));

    root.deleteSync(recursive: true);
  });

  test("Verify exception is thrown if settings.gradle misses app_plugin_loader",
      () {
    // Given an empty settings.gradle file
    final root = Directory("${Directory.systemTemp.path}${s}apl2")
      ..createSync();
    final android = Directory("${root.path}${s}android");
    File("${android.absolute.path}${s}settings.gradle")
        .createSync(recursive: true);

    // An exception is thrown
    expect(
        () => applyPluginLoader(android.path),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.contains("Failed to apply Klutter plugin loader."))));

    root.deleteSync(recursive: true);
  });

  test("Verify line is added to standard Flutter settings.gradle file", () {
    final root = Directory("${Directory.systemTemp.path}${s}apl3")
      ..createSync();
    final android = Directory("${root.path}${s}sgv2${s}android");
    final settingsGradle = File("${android.absolute.path}${s}settings.gradle")
      ..createSync(recursive: true)
      ..writeAsStringSync(r'''
        include ':app'

        def localPropertiesFile = new File(rootProject.projectDir, "local.properties")
        def properties = new Properties()
        
        assert localPropertiesFile.exists()
        localPropertiesFile.withReader("UTF-8") { reader -> properties.load(reader) }
        
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        
        apply from: "\$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"
    ''');

    // When the visitor has done it's magic.
    applyPluginLoader(android.path);

    // Then a new line applying the klutter_plugin_loader.gradle.kts is added.
    expect(
        settingsGradle.readAsStringSync().replaceAll(" ", ""),
        r'''
        include ':app'

        def localPropertiesFile = new File(rootProject.projectDir, "local.properties")
        def properties = new Properties()
        
        assert localPropertiesFile.exists()
        localPropertiesFile.withReader("UTF-8") { reader -> properties.load(reader) }
        
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        
        apply from: "\$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"
        apply from: "\$flutterSdkPath/packages/flutter_tools/gradle/klutter_plugin_loader.gradle.kts"
    '''
            .replaceAll(" ", ""));

    root.deleteSync(recursive: true);
  });

  test("Verify line is added to customized settings.gradle file", () {
    final root = Directory("${Directory.systemTemp.path}${s}apl4")
      ..createSync();

    final android = Directory("${root.path}${s}sgv3${s}android");
    final settingsGradle = File("${android.absolute.path}${s}settings.gradle")
      ..createSync(recursive: true)
      ..writeAsStringSync("""
          include ':app'
          apply from: 'Users/foo/some/bar/folder/packages/flutter_tools/gradle/app_plugin_loader.gradle'
        """);

    // When the visitor has done it's magic.
    applyPluginLoader(android.path);

    // Then a new line applying the klutter_plugin_loader.gradle.kts is added.
    expect(
        settingsGradle.readAsStringSync().replaceAll(" ", ""),
        """
          include ':app'
          apply from: 'Users/foo/some/bar/folder/packages/flutter_tools/gradle/app_plugin_loader.gradle'
          apply from: 'Users/foo/some/bar/folder/packages/flutter_tools/gradle/klutter_plugin_loader.gradle.kts'
        """
            .replaceAll(" ", ""));

    root.deleteSync(recursive: true);
  });

  test("Verify min and compile SDK are updated in build.gradle file",
      () {
    final root = Directory("${Directory.systemTemp.path}${s}apl5")
      ..createSync();

    final android = Directory("${root.path}${s}android");

    File("${android.absolute.path}${s}build.gradle")
        .createSync(recursive: true);

    // An exception is thrown
    expect(
        () => setAndroidSdkConstraints(android.path),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.contains(
                "Failed to set 'compileSdk' in the root/android/build.gradle file")
        )));

    root.deleteSync(recursive: true);
  });

  test(
      "Verify exception is thrown if build.gradle does not exist when setting android SDK settings",
          () {
        final root = Directory("${Directory.systemTemp.path}${s}apl10")
          ..createSync();

        final android = Directory("${root.path}${s}android")..createSync();

        expect(
                () => setAndroidSdkConstraints(android.absolute.path),
            throwsA(predicate((e) =>
            e is KlutterException &&
                e.cause.startsWith("Missing build.gradle file in folder"))));

        root.deleteSync(recursive: true);
      });

  test(
      "Verify exception is thrown if root/android/app/build.gradle does not exist",
      () {
    final root = Directory("${Directory.systemTemp.path}${s}apl10")
      ..createSync();

    final android = Directory("${root.path}${s}android")..createSync();

    expect(() => writeAndroidAppBuildGradleFile(
            pathToAndroid: android.absolute.path,
            packageName: "",
            pluginName: ""),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith("Missing app/build.gradle file in folder"))));

    root.deleteSync(recursive: true);
  });
}
