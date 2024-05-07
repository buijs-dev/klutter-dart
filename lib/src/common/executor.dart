// Copyright (c) 2021 - 2024 Buijs Software
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

import "exception.dart";
import "utilities.dart";

/// Wrapper for using the commandline.
class Executor {
  /// The directory from which to execute the command.
  Directory? workingDirectory;

  /// The executable to run.
  ///
  /// For example: "flutter", "gradlew", etc.
  ///
  /// Can be relative to the [workingDirectory] or an absolute path.
  String? executable;

  /// An (optional) list of arguments.
  ///
  /// For example: ["clean", "build"] with [executable] "gradlew"
  /// would result in a gradlew clean build to be executed from the [workingDirectory].
  List<String> arguments = const [];

  /// Run the command.
  ///
  /// For example an [executable] 'gradlew'
  /// with [arguments] '["clean", "build", "-p", "platform"]'
  /// and [workingDirectory] './Users/Foo'
  /// would result in command "./Users/Foo/gradlew clean build -p platform".
  ProcessResult run() {
    if (executable == null) {
      throw const KlutterException("Executor field 'executable' is null");
    }

    if (workingDirectory == null) {
      throw const KlutterException("Executor field 'workingDirectory' is null");
    }

    final result = Process.runSync(
      executable!,
      arguments,
      runInShell: true,
      workingDirectory: workingDirectory!.absolutePath,
    );

    stdout.write(result.stdout);
    stderr.write(result.stderr);
    return result;
  }
}
