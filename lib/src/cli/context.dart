import "dart:io";

import "../common/common.dart";
import "task.dart";

/// The context in which a command should be executed.
class Context {
  ///
  const Context({
    required this.workingDirectory,
    required this.taskName,
    required this.taskOptions,
  });

  ///
  final Directory workingDirectory;

  ///
  final TaskName taskName;

  ///
  final Map<TaskOption, String> taskOptions;
}

/// Parse user input and return the [Context] or null if input is invalid.
Context? toContextOrNull(Directory workingDirectory, List<String> arguments) {
  if (arguments.isEmpty) {
    return null;
  }

  final taskName = arguments.removeAt(0).toTaskNameOrNull;
  if (taskName == null) {
    return null;
  }

  final taskOptions = toTaskOptionsOrNull(arguments);
  if (taskOptions == null) {
    return null;
  }

  return Context(
      workingDirectory: workingDirectory,
      taskName: taskName,
      taskOptions: taskOptions);
}

/// Parse the arguments to map of [TaskOption] or null if input is invalid.
Map<TaskOption, String>? toTaskOptionsOrNull(List<String> arguments) {
  final options = <TaskOption, String>{};
  for (final argument in arguments) {
    if (!argument.contains("=")) {
      return null;
    }

    final key = argument.substring(0, argument.indexOf("="));
    final option = key.toTaskOptionOrNull;
    if (option == null) {
      return null;
    }

    final value =
        argument.substring(argument.indexOf("=") + 1, argument.length).trim();
    if (value.isEmpty) {
      return null;
    }
    options[option] = value;
  }

  return options;
}

/// Return the absolute path specified by [TaskOption.root]
/// or [Context.workingDirectory] if option is not present.
String findPathToRoot(Context context, Map<TaskOption, dynamic> options) {
  final Directory Function(Context)? workingDirectorySupplier =
      options[TaskOption.root];
  final workingDirectory = workingDirectorySupplier != null
      ? workingDirectorySupplier(context)
      : context.workingDirectory;
  return workingDirectory.absolutePath;
}
