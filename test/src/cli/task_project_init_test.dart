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
import "package:test/test.dart";

void main() {
  test("Verify init in consumer project skips producer init", () async {
    final pathToRoot =
        Directory("${Directory.systemTemp.absolute.path}/build_test".normalize)
          ..createSync();

    final project = await createFlutterProjectOrThrow(
      executor: Executor(),
      pathToFlutter: "flutter",
      pathToRoot: pathToRoot.absolutePath,
      name: "my_project",
      group: "my.org",
    );

    final pathToConsumer = project.resolveFolder("example");
    final task = ProjectInit();
    final context = Context(pathToConsumer, {});
    final result = await task.execute(context);
    expect(result.isOk, true);
    final file = pathToConsumer.resolveFile("/lib/main.dart");
    var reason = "example/lib/main.dart file should exist";
    expect(file.existsSync(), true, reason: reason);
    final registry = pathToConsumer.resolveFile(".klutter-plugins");
    reason = "klutter-plugins file should be created";
    expect(registry.existsSync(), true, reason: reason);
  });
}
