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

import "package:klutter/src/common/common.dart";
import "package:klutter/src/producer/project.dart";
import "package:test/test.dart";

void main() {
  const pluginName = "impressive_dependency";

  test("Verify example/lib/main.dart is created if it does not exist", () {
    final example = Directory("${Directory.systemTemp.path}/wem1".normalize)
      ..createSync(recursive: true);

    final mainDart = File("${example.path}/lib/main.dart".normalize);

    writeExampleMainDartFile(
      pathToExample: example.path,
      pluginName: pluginName,
    );

    expect(
        mainDart.readAsStringSync().replaceAll(" ", ""),
        """
            import 'package:flutter/material.dart';

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
              String _greeting = "There shall be no greeting for now!";

              @override
              void initState() {
                super.initState();
                greeting(
                    state: this,
                    onComplete: (_) => setState(() {}),
                    onSuccess: (value) => _greeting = value,
                    onFailure: (message) => _greeting = "He did not want to say Hi..."
                );
              }

              @override
              Widget build(BuildContext context) {
                return MaterialApp(
                  home: Scaffold(
                    appBar: AppBar(
                      title: const Text('Plugin example app'),
                    ),
                    body: Center(
                      child: Text(_greeting),
                    ),
                  ),
                );
              }
            }"""
            .replaceAll(" ", ""));

    example.deleteSync(recursive: true);
  });
}
