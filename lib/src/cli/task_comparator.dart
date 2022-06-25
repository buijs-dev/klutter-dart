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

import "cli.dart";

/// Comparator function to sort Tasks based on their dependencies.
///
/// Example
///
/// Given:
/// - Task A depends on Task B
/// - Task B depends on Task C
/// - Task D depends on nothing
///
/// Result:
/// Sorted set in order: Task D, Task C, Task B, Task A.
int dependsOnComparator(Task t1, Task t2) {
  /// True if Task t1 depends on Task t2.
  final t1DependsOnT2 = t1.dependsOn().map((e) {
    return e.taskName == t2.taskName && e.scriptName == t2.scriptName;
  }).contains(true);

  /// True if Task t2 depends on Task t1.
  final t2DependsOnT1 = t2.dependsOn().map((e) {
    return e.taskName == t1.taskName && e.scriptName == t1.scriptName;
  }).contains(true);

  /// If Task t1 depends on Task t2, Task t2 has higher priority.
  if (t1DependsOnT2) {
    return 1;
  }

  /// If Task t2 depends on Task t1, Task t1 has higher priority.
  if (t2DependsOnT1) {
    return -1;
  }

  /// If Task t1 has no dependencies then it has higher priority.
  if (t1.dependsOn().isEmpty) {
    return -1;
  }

  /// If Task t2 has no dependencies then it has higher priority
  if (t2.dependsOn().isEmpty) {
    return 1;
  }

  /// Keep the current order intact.
  return -1;
}
