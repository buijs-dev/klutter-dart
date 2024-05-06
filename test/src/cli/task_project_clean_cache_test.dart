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

import "package:klutter/klutter.dart";
import "package:klutter/src/cli/context.dart";
import "package:meta/meta.dart";
import "package:test/test.dart";

void main() {
  Future<TaskResult> runTest(
      Directory workingDirectory, Directory cachingDirectory,
      [CleanCache? cc]) {
    final task = cc ?? CleanCache();

    final context = Context(workingDirectory, {});

    workingDirectory
        .resolveFile("kradle.env")
        .writeAsStringSync("cache=${cachingDirectory.absolutePath}");

    return task.execute(context);
  }

  test("Verify clean cache is successful when cache contains nothing",
      () async {
    final workingDirectory = Directory.systemTemp.resolveFolder("foo1")
      ..maybeCreate;
    final cachingDirectory =
        Directory.systemTemp.resolveFolder("foo1/.kradle/cache")..maybeCreate;
    expect(cachingDirectory.isEmpty, true);
    final result = await runTest(workingDirectory, cachingDirectory);
    expect(result.isOk, true);
    expect(cachingDirectory.isEmpty, true);
  });

  test("Verify clean cache deletes all cache entries", () async {
    final workingDirectory = Directory.systemTemp.resolveFolder("foo1")
      ..maybeCreate;
    final cachingDirectory =
        Directory.systemTemp.resolveFolder("foo1/.kradle/cache")..maybeCreate;
    cachingDirectory.resolveFolder("3.10.6.linux.arm").createSync();
    expect(cachingDirectory.isEmpty, false);
    final result = await runTest(workingDirectory, cachingDirectory);
    expect(result.isOk, true);
    expect(cachingDirectory.isEmpty, true);
    final CleanCachResult ccr = result.output;
    expect(ccr.deleted.length, 1);
    expect(ccr.notDeletedByError.isEmpty, true);
  });

  test("Verify exceptions are caught when deleting entities", () async {
    final workingDirectory = Directory.systemTemp.resolveFolder("foo2")
      ..maybeCreate;
    final cachingDirectory = DirectoryStub();
    expect(cachingDirectory.isEmpty, false);
    final cacheProvider = CacheProviderStub();
    final cleanCache = CleanCache(cacheProvider);
    final result =
        await runTest(workingDirectory, cachingDirectory, cleanCache);
    expect(result.isOk, true);
    expect(cachingDirectory.isEmpty, false);
    final CleanCachResult ccr = result.output;
    expect(ccr.deleted.length, 0);
    expect(ccr.notDeletedByError.isNotEmpty, true);
    expect(ccr.notDeletedByError[DirectoryStub()],
        "KlutterException with cause: 'BOOM!'");
  });
}

class CacheProviderStub extends CacheProvider {
  @override
  List<FileSystemEntity> getCacheContent(
    Context context,
    Map<TaskOption, dynamic> options,
  ) =>
      [DirectoryStub()];
}

@immutable
class DirectoryStub implements Directory {
  @override
  bool operator ==(Object other) => true;

  @override
  int get hashCode => 1;

  @override
  Directory get absolute => DirectoryStub();

  @override
  Future<Directory> create({bool recursive = false}) {
    throw UnimplementedError();
  }

  @override
  void createSync({bool recursive = false}) {}

  @override
  Future<Directory> createTemp([String? prefix]) {
    throw UnimplementedError();
  }

  @override
  Directory createTempSync([String? prefix]) {
    throw UnimplementedError();
  }

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) {
    throw KlutterException("BOOM!");
  }

  @override
  void deleteSync({bool recursive = false}) {
    throw KlutterException("BOOM!");
  }

  @override
  Future<bool> exists() => Future.value(true);

  @override
  bool existsSync() => true;

  @override
  bool get isAbsolute => throw UnimplementedError();

  @override
  Stream<FileSystemEntity> list(
          {bool recursive = false, bool followLinks = true}) =>
      Stream.value(DirectoryStub());

  @override
  List<FileSystemEntity> listSync(
          {bool recursive = false, bool followLinks = true}) =>
      [DirectoryStub()];

  @override
  Directory get parent => throw UnimplementedError();

  @override
  String get path => Directory.systemTemp.resolveFolder("stub").absolutePath;

  @override
  Future<Directory> rename(String newPath) {
    throw UnimplementedError();
  }

  @override
  Directory renameSync(String newPath) {
    throw UnimplementedError();
  }

  @override
  Future<String> resolveSymbolicLinks() {
    throw UnimplementedError();
  }

  @override
  String resolveSymbolicLinksSync() {
    throw UnimplementedError();
  }

  @override
  Future<FileStat> stat() {
    throw UnimplementedError();
  }

  @override
  FileStat statSync() {
    throw UnimplementedError();
  }

  @override
  Uri get uri => throw UnimplementedError();

  @override
  Stream<FileSystemEvent> watch(
      {int events = FileSystemEvent.all, bool recursive = false}) {
    throw UnimplementedError();
  }
}
