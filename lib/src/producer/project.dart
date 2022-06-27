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

import "../common/project.dart";
import "../common/utilities.dart";

/// Generate the main.dart file in the root/example/lib folder.
///
/// This generated main.dart file uses the example Klutter platform module.
///
/// {@category producer}
void writeExampleMainDartFile({
  required String pathToExample,
  required String pluginName,
}) =>
    pathToExample.verifyExists.createMainDartFile.writeMainContent(pluginName);

extension on String {
  /// Create main.dart file in the example/lib folder.
  File get createMainDartFile {
    Directory("${this}/lib").normalizeToFolder.maybeCreate;
    return File("${this}/lib/main.dart").normalizeToFile
      ..ifNotExists((folder) => File(folder.absolutePath).createSync());
  }
}

extension on File {
  /// Write the content of the the settings.gradle.kts of a Klutter plugin.
  void writeMainContent(String pluginName) {
    final className = toPluginClassName(pluginName);

    writeAsStringSync("""
          import 'package:flutter/material.dart';
          |import 'dart:async';
          |
          |import 'package:$pluginName/$pluginName.dart';
          |
          |void main() {
          |  runApp(const MyApp());
          |}
          |
          |class MyApp extends StatefulWidget {
          |  const MyApp({Key? key}) : super(key: key);
          |
          |  @override
          |  State<MyApp> createState() => _MyAppState();
          |}
          |
          |class _MyAppState extends State<MyApp> {
          |  String _platformVersion = 'Unknown';
          |
          |  @override
          |  void initState() {
          |    super.initState();
          |    initPlatformState();
          |  }
          |
          |  // Platform messages are asynchronous, so we initialize in an async method.
          |  Future<void> initPlatformState() async {
          |    // Klutter generated Adapters don't throw exceptions but always return a
          |    // response object. No need for try-catch here. Do or do not. There is no try.
          |    await $className.greeting.then((response) {
          |      String platformVersion = response.isSuccess()
          |          ? response.object
          |          : response.exception.toString();
          |
          |      // If the widget was removed from the tree while the asynchronous platform
          |      // message was in flight, we want to discard the reply rather than calling
          |      // setState to update our non-existent appearance.
          |      if (!mounted) return;
          |
          |     setState(() {
          |        _platformVersion = platformVersion;
          |     });
          |    });
          |  }
          |
          |  @override
          |  Widget build(BuildContext context) {
          |    return MaterialApp(
          |      home: Scaffold(
          |        appBar: AppBar(
          |          title: const Text('Plugin example app'),
          |        ),
          |        body: Center(
          |          child: Text('Running on: \$_platformVersion'),
          |        ),
          |      ),
          |    );
          |  }
          |}"""
        .format);
  }
}
