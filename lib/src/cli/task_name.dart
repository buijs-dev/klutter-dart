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

/// List of available tasks.
///
/// The task functionality depends on the calling script.
enum TaskName {
  /// Tasks which add libraries.
  add,

  /// Tasks which do project initialization (setup).
  init,

  /// Tasks which do project installation (code or artifact generation).
  install,
}

/// Convert a String value to a [TaskName].
extension TaskNameParser on String? {
  /// Find a [TaskName] that matches the current
  /// (trimmed) String value or return null.
  TaskName? get toTaskNameOrNull {
    if (this == null) {
      return null;
    }

    switch (this!.trim().toUpperCase()) {
      case "ADD":
        return TaskName.add;
      case "INIT":
        return TaskName.init;
      case "INSTALL":
        return TaskName.install;
      default:
        return null;
    }
  }
}
