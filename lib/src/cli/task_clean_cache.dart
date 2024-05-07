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

// ignore_for_file: avoid_print

import "dart:io";

import "../common/common.dart";
import "cli.dart";
import "context.dart";

/// Clean the kradle cache by deleting contents recursively.
class CleanCache extends Task {
  /// Create new Task.
  CleanCache([CacheProvider? cacheProvider])
      : super(TaskName.clean, {
          TaskOption.root: RootDirectoryInput(),
        }) {
    _cacheProvider = cacheProvider ?? CacheProvider();
  }

  late final CacheProvider _cacheProvider;

  @override
  Future<CleanCacheResult> toBeExecuted(
      Context context, Map<TaskOption, dynamic> options) async {
    final deleted = <FileSystemEntity>[];
    final notDeletedByError = <FileSystemEntity, String>{};
    void deleteIfExists(FileSystemEntity entity) {
      if (entity.existsSync()) {
        try {
          entity.deleteSync(recursive: true);
          deleted.add(entity);
        } on Exception catch (e) {
          notDeletedByError[entity] = e.toString();
        }
      }
    }

    print("cleaning .kradle cache");
    _cacheProvider.getCacheContent(context, options).forEach(deleteIfExists);
    for (final element in deleted) {
      print("deleted: ${element.absolutePath}");
    }

    notDeletedByError.forEach((key, value) {
      print("failed to delete $key, because $value");
    });

    return CleanCacheResult(deleted, notDeletedByError);
  }
}

/// Result of task [CleanCache].
class CleanCacheResult {
  /// Create a new instance of [CleanCacheResult].
  const CleanCacheResult(this.deleted, this.notDeletedByError);

  /// List of deleted entities.
  final List<FileSystemEntity> deleted;

  /// Map of not deleted entities and the corresponding error message.
  final Map<FileSystemEntity, String> notDeletedByError;
}

/// Wrapper to provide the kradle cache directory
/// based on [Context] and [TaskOption] input.
class CacheProvider {
  /// Return the files and directory in the kradle cache directory.
  List<FileSystemEntity> getCacheContent(
      Context context, Map<TaskOption, dynamic> options) {
    final cache = Directory(findPathToRoot(context, options)).kradleCache;
    return cache.listSync(recursive: true);
  }
}
