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

import "dart:ffi";
import "dart:io";

import "package:meta/meta.dart";

import "../common/common.dart";
import "../producer/kradle.dart";
import "cli.dart";
import "context.dart";

/// Clean the kradle cache by deleting contents recursively.
class CleanCache extends Task {
  /// Create new Task.
  CleanCache()
      : super(TaskName.clean, {
          TaskOption.root: RootDirectoryInput(),
        });

  @override
  Future<void> toBeExecuted(
      Context context, Map<TaskOption, dynamic> options) async {
    void deleteIfExists(FileSystemEntity entity) {
      if (entity.existsSync()) {
        try {
          entity.deleteSync();
        } on Exception {
          // ignore
        }
      }
    }

    final cache = Directory(findPathToRoot(context, options)).kradleCache;
    cache.listSync(recursive: true).forEach(deleteIfExists);
  }
}
