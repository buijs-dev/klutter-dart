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
import "package:klutter/src/common/shared.dart";
import "package:klutter/src/producer/project.dart";
import "package:test/test.dart";

void main() {

  const pluginName = "impressive_dependency";

  test("Verify exception is thrown if example folder does not exist", () {
    expect(() => writeExampleMainDartFile(
      pathToExample: "fake",
      pluginName: pluginName,
    ), throwsA(predicate((e) =>
        e is KlutterException &&
        e.cause.startsWith("Path does not exist:") &&
        e.cause.endsWith("/fake"))));
  });

  test("Verify example/lib/main.dart is created if it does not exist", () {

    final example = Directory("${Directory.systemTemp.path}/wem1".normalize)
      ..createSync(recursive: true);

    final mainDart = File("${example.path}/lib/main.dart".normalize);

    writeExampleMainDartFile(
      pathToExample: example.path,
      pluginName: pluginName,
    );

    expect(mainDart.readAsStringSync().replaceAll(" ", ""), r"""
            import 'package:flutter/material.dart';
            import 'dart:async';
            
            import 'package:impressive_dependency/impressive_dependency.dart';
            
            void main() {
              runApp(const MyApp());
            }
            
            class MyApp extends StatefulWidget {
              const MyApp({Key? key}) : super(key: key);
            
              @override
              State<MyApp> createState() => _MyAppState();
            }
            
            class _MyAppState extends State<MyApp> {
              String _platformVersion = 'Unknown';
            
              @override
              void initState() {
                super.initState();
                initPlatformState();
              }
            
              // Platform messages are asynchronous, so we initialize in an async method.
              Future<void> initPlatformState() async {
                // Klutter generated Adapters don't throw exceptions but always return a
                // response object. No need for try-catch here. Do or do not. There is no try.
                await ImpressiveDependency.greeting.then((response) {
                  String platformVersion = response.isSuccess()
                      ? response.object
                      : response.exception.toString();
            
                  // If the widget was removed from the tree while the asynchronous platform
                  // message was in flight, we want to discard the reply rather than calling
                  // setState to update our non-existent appearance.
                  if (!mounted) return;
            
                  setState(() {
                    _platformVersion = platformVersion;
                  });
                });
              }
            
              @override
              Widget build(BuildContext context) {
                return MaterialApp(
                  home: Scaffold(
                    appBar: AppBar(
                      title: const Text('Plugin example app'),
                    ),
                    body: Center(
                      child: Text('Running on: $_platformVersion'),
                    ),
                  ),
                );
              }
            }""".replaceAll(" ", ""));

    example.deleteSync(recursive: true);

  });

}