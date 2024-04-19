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

/// List of available scripts.
///
/// Tasks are accessible through scripts.
///
/// There are 2 scripts:
/// - Consumer
/// - Producer
///
/// <B>Consumer:</B>
///
/// Tasks to be executed in a project that will use (consume)
/// libraries that are created with the use of Klutter.
///
/// <B>Producer:</B>
///
/// Tasks to be executed in a project that will use
/// Klutter to create (produce) a new Flutter library.
///
/// {@category consumer}
/// {@category producer}
enum ScriptName {
  /// Script containing tasks for projects
  /// that use libraries created with Klutter.
  consumer,

  /// Script containing tasks for projects
  /// that are being created with Klutter.
  producer,

  /// Script containing tasks to create and
  /// manage klutter projects.
  kradle,
}

/// List of available scripts options.
///
/// Tasks are accessible through scripts [ScriptName].
///
/// Each script has 0 or more compatible [ScriptOption].
///
/// {@category consumer}
/// {@category producer}
enum ScriptOption {
  /// The Klutter (Gradle) BOM version.
  ///
  /// Used by [ScriptName.producer] when creating a new project.
  bom,

  /// The Kradle cache directory.
  ///
  /// Used by [ScriptName.kradle] when deleting the cache content.
  cache,

  /// The Flutter SDK distribution in format
  /// major.minor.patch.platform.architecture
  /// or major.minor.patch.
  ///
  /// Example format:
  /// ```dart
  /// 3.10.6.macos.arm64.
  /// 3.10.6
  /// ```
  ///
  /// Used by [ScriptName.producer] when creating a new project.
  flutter,

  /// To overwrite existing entities or not.
  ///
  /// Used by [ScriptName.producer] when downloading a flutter distribution.
  overwrite,

  /// Name of library to add.
  ///
  /// Used by [ScriptName.consumer] when adding a Klutter Library as dependency.
  lib,

  /// For testing purposes.
  ///
  /// Skips downloading of libraries when set to true.
  dryRun,

  /// The klutter project root directory.
  ///
  /// Used by [ScriptName.kradle] when creating a new project.
  root,

  /// The klutter project name.
  ///
  /// Used by [ScriptName.kradle] when creating a new project.
  name,

  /// The klutter project group name.
  ///
  /// Used by [ScriptName.kradle] when creating a new project.
  group,

  /// The klutter pub version in format major.minor.patch.
  ///
  /// Used by [ScriptName.kradle] when creating a new project.
  klutter,

  /// The klutter-ui pub version in format major.minor.patch.
  ///
  /// Used by [ScriptName.kradle] when creating a new project.
  klutterui,

  /// The squint pub version in format major.minor.patch.
  ///
  /// Used by [ScriptName.kradle] when creating a new project.
  squint,
}

/// List of available tasks.
///
/// The task functionality depends on the calling script.
enum TaskName {
  /// Tasks which adds libraries.
  add,

  /// Tasks which gets dependencies (e.g. Flutter SDK).
  get,

  /// Tasks which does project initialization (setup).
  init,

  /// Clean one or more directories by deleting contents recursively.
  clean,

  /// Create a new klutter project.
  create,

  /// Build a klutter project.
  build
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
      case "BUILD":
        return TaskName.build;
      case "CLEAN":
        return TaskName.clean;
      case "CREATE":
        return TaskName.create;
      case "GET":
        return TaskName.get;
      case "INIT":
        return TaskName.init;
      default:
        return null;
    }
  }
}
