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

import "package:klutter/src/cli/cli.dart";
import "package:test/test.dart";

void main() {
  test("Verify TaskNameParser", () {
    <String?, TaskName?>{
      "add": TaskName.add,
      " add ": TaskName.add,
      "build": TaskName.build,
      "clean": TaskName.clean,
      "create": TaskName.create,
      "get": TaskName.get,
      "gradle": TaskName.gradle,
      "flutter": TaskName.flutter,
      " init": TaskName.init,
      "INIT": TaskName.init,
      "i n i t": null,
      "destroyAllHumans!": null,
      null: null,
      "": null,
      "   ": null,
    }.forEach((input, taskName) {
      expect(input.toTaskNameOrNull, taskName,
          reason: "Expected '$input' to be converted to '$taskName' ");
    });
  });
}
