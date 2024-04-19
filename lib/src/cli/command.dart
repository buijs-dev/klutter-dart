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

import "../../klutter.dart";

/// Object to store parsed user input.
class Command {
  /// Create a Command object which should always
  /// contain a [TaskName]  and [ScriptName].
  ///
  /// Option value is optional but might be required by a Task.
  const Command({
    required this.taskName,
    required this.scriptName,
    this.options = const <ScriptOption, String>{},
  });

  /// Name of Task to be executed.
  final TaskName taskName;

  /// Optional values which may or may not be used by the Task.
  final Map<ScriptOption, String> options;

  /// Name of script which should contain a Task with [TaskName].
  final ScriptName scriptName;

  /// Parse a received command and return the command data.
  ///
  /// Takes the CLI arguments list prefixed with the script name
  /// and returns a [Command] object which can be mapped to a Task
  /// or null if the command (user input) is invalid.
  static Command? from({
    required ScriptName script,
    required List<String> arguments,
  }) {
    final parserMap = {
      ScriptName.consumer: {
        TaskName.init: _consumerInit,
        TaskName.add: _consumerAdd,
      },
      ScriptName.producer: {
        TaskName.init: _producerInit,
        TaskName.get: _producerGet,
      },
      ScriptName.kradle: {
        TaskName.add: _consumerAdd,
        TaskName.build: _kradleBuild,
        TaskName.clean: _kradleClean,
        TaskName.create: _kradleCreate,
        TaskName.get: _producerGet,
      },
    };

    if (!parserMap.containsKey(script)) {
      return null;
    }

    if (arguments.isEmpty) {
      return null;
    }

    final taskName = arguments.first.toTaskNameOrNull;
    if (taskName == null) {
      return null;
    }

    final taskMap = parserMap[script]!;
    if (!taskMap.containsKey(taskName)) {
      return null;
    }

    return taskMap[taskName]!.call(arguments.sublist(1, arguments.length));
  }

  @override
  String toString() =>
      "Command(task=${taskName.name}, script=${scriptName.name}, options=$options)";
}

Command? _consumerInit(List<String> arguments) => arguments.isEmpty
    ? const Command(taskName: TaskName.init, scriptName: ScriptName.consumer)
    : null;

Command? _consumerAdd(List<String> arguments) {
  if (arguments.length != 1) {
    return null;
  }

  final option = arguments.first.split("=");

  if (option.length != 2) {
    return null;
  }

  if (option.first != ScriptOption.lib.name) {
    return null;
  }

  return Command(
      taskName: TaskName.add,
      scriptName: ScriptName.consumer,
      options: {ScriptOption.lib: option[1]});
}

Command? _producerInit(List<String> arguments) {
  if (arguments.length > 2) {
    return null;
  }

  final options = <ScriptOption, String>{};

  for (final arg in arguments) {
    final option = arg.split("=");

    if (option.length != 2) {
      return null;
    }

    if (option.first == ScriptOption.bom.name) {
      options[ScriptOption.bom] = option[1];
    } else if (option.first == ScriptOption.flutter.name) {
      options[ScriptOption.flutter] = option[1];
    } else {
      return null;
    }
  }

  if (!options.containsKey(ScriptOption.bom)) {
    options[ScriptOption.bom] = klutterGradleVersion;
  }

  if (!options.containsKey(ScriptOption.flutter)) {
    options[ScriptOption.flutter] = klutterFlutterVersion;
  }

  return Command(
      taskName: TaskName.init,
      scriptName: ScriptName.producer,
      options: options);
}

Command? _producerGet(List<String> arguments) {
  if (arguments.length > 2) {
    return null;
  }

  final options = <ScriptOption, String>{};

  for (final arg in arguments) {
    final option = arg.split("=");

    if (option.length != 2) {
      return null;
    }

    if (option.first == ScriptOption.overwrite.name) {
      final boolean = option[1].toLowerCase();
      if (boolean == "true") {
        options[ScriptOption.overwrite] = "true";
      } else if (boolean == "false") {
        options[ScriptOption.overwrite] = "false";
      } else {
        return null;
      }
    } else if (option.first == ScriptOption.flutter.name) {
      final version = option[1];
      if (version.verifyFlutterVersion != null) {
        options[ScriptOption.flutter] = version;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  if (!options.containsKey(ScriptOption.overwrite)) {
    options[ScriptOption.overwrite] = "false";
  }

  if (!options.containsKey(ScriptOption.flutter)) {
    options[ScriptOption.flutter] = klutterFlutterVersion;
  }

  return Command(
      taskName: TaskName.get,
      scriptName: ScriptName.producer,
      options: options);
}

Command? _kradleBuild(List<String> arguments) => arguments.isEmpty
    ? const Command(taskName: TaskName.build, scriptName: ScriptName.kradle)
    : null;

Command? _kradleCreate(List<String> arguments) {
  final options = <ScriptOption, String>{};

  for (final arg in arguments) {
    final option = arg.split("=");

    if (option.length != 2) {
      return null;
    }

    final key = option.first;
    if (key == ScriptOption.klutter.name) {
      options[ScriptOption.klutter] = option[1];
    } else if (key == ScriptOption.klutterui.name) {
      options[ScriptOption.klutterui] = option[1];
    } else if (key == ScriptOption.squint.name) {
      options[ScriptOption.squint] = option[1];
    } else if (key == ScriptOption.group.name) {
      options[ScriptOption.group] = option[1];
    } else if (key == ScriptOption.bom.name) {
      options[ScriptOption.bom] = option[1];
    } else if (key == ScriptOption.name.name) {
      options[ScriptOption.name] = option[1];
    } else if (key == ScriptOption.root.name) {
      options[ScriptOption.root] = option[1];
    } else if (key == ScriptOption.flutter.name) {
      final version = option[1];
      if (version.verifyFlutterVersion != null) {
        options[ScriptOption.flutter] = version;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  if (!options.containsKey(ScriptOption.flutter)) {
    options[ScriptOption.flutter] = klutterFlutterVersion;
  }

  return Command(
      taskName: TaskName.create,
      scriptName: ScriptName.kradle,
      options: options);
}

Command? _kradleClean(List<String> arguments) {
  if (arguments.length > 1) {
    return null;
  }

  final option = arguments[0].split("=");

  if (option.length != 1) {
    return null;
  }

  if (option.first != ScriptOption.cache.name) {
    return null;
  }

  return const Command(
      taskName: TaskName.clean,
      scriptName: ScriptName.kradle,
      options: {ScriptOption.cache: ""});
}
