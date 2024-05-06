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

// ignore_for_file: avoid_print

import "dart:io";

import "package:interact/interact.dart" as interact;
import "package:interact/interact.dart";
import "package:klutter/klutter.dart";

/// Run kradle tasks.
Future<void> main(List<String> args) async {
  print("""
  ════════════════════════════════════════════
     KRADLE (v$klutterPubVersion)                               
  ════════════════════════════════════════════
  """
      .ok);

  if (args.isNotEmpty) {
    print(await run(args));
    return;
  } else {
    await interactiveMode();
  }
}

const addLibrary = "add library";
const getFlutter = "get flutter";
const cleanCache = "clean cache";
const projectBuild = "project build";
const projectCreate = "project create";
const projectInit = "project init";
const quit = "quit";
final tasks = [
  addLibrary,
  getFlutter,
  cleanCache,
  projectBuild,
  projectCreate,
  projectInit,
  quit,
];

Future<void> interactiveMode() async {
  final prompt = Select(prompt: "choose task", options: tasks).interact();
  final selection = tasks[prompt];
  if (selection == addLibrary) {
    final name = interact.Input(prompt: "library name").interact();
    await runTaskWithSpinner(TaskName.add, {TaskOption.name: name});
  } else if (selection == getFlutter) {
    final version = askForFlutterVersion();
    final overwrite = askConfirmation("overwrite existing distribution?");
    await runTaskWithSpinner(TaskName.get, {
      TaskOption.flutter: version,
      TaskOption.overwrite: "$overwrite",
    });
  } else if (selection == cleanCache) {
    await runTaskWithSpinner(TaskName.clean, {});
  } else if (selection == projectBuild) {
    await runTaskWithSpinner(TaskName.build, {});
  } else if (selection == projectCreate) {
    final pluginName = askForUserInputOrDefault(const PluginNameOption());
    final groupName = askForUserInputOrDefault(const GroupNameOption());
    final flutterVersion = askForFlutterVersion();
    final klutterGradle =
        askForUserInputOrDefault(const KlutterGradleVersionOption());
    final klutterPub = askForKlutterPubVersion();
    final klutteruiPub = askForKlutteruiPubVersion();
    final squint = askForSquintPubVersion();
    final workingDirectory =
        askConfirmation("create in current directory?", true)
            ? Directory.current.absolutePath
            : interact.Input(prompt: "working directory").interact();
    await runTaskWithSpinner(TaskName.create, {
      TaskOption.name: pluginName,
      TaskOption.group: groupName,
      TaskOption.flutter: flutterVersion,
      TaskOption.root: workingDirectory,
      TaskOption.klutter: klutterPub,
      TaskOption.klutterui: klutteruiPub,
      TaskOption.bom: klutterGradle,
      TaskOption.squint: squint,
    });
  } else if (selection == projectInit) {
    final gradleVersion =
        askForUserInputOrDefault(const KlutterGradleVersionOption());
    final flutterVersion = askForFlutterVersion();
    await runTaskWithSpinner(TaskName.init, {
      TaskOption.flutter: flutterVersion,
      TaskOption.klutter: gradleVersion,
    });
  } else if (selection == quit) {
    return;
  } else {
    print("oops... something went wrong");
  }

  await interactiveMode();
}

String askForFlutterVersion() {
  final option = FlutterVersionOption();
  final versions = supportedFlutterVersions.values
      .toSet()
      .map((e) => e.prettyPrint)
      .toList();
  final promptVersion =
      Select(prompt: option.description, options: versions).interact();
  return versions[promptVersion];
}

String askForUserInputOrDefault(UserInputOrDefault option) {
  return interact.Input(
          prompt: option.description, defaultValue: option.defaultValue)
      .interact();
}

String askForKlutterPubVersion() {
  final sources = ["git", "pub", "local"];
  final prompt =
      Select(prompt: "select klutter (dart) source", options: sources)
          .interact();
  final source = sources[prompt];

  if (source == "git") {
    return "https://github.com/buijs-dev/klutter-dart.git@develop";
  }

  if (source == "pub") {
    return interact.Input(
            prompt: "klutter (dart) version", defaultValue: klutterPubVersion)
        .interact();
  }

  final path =
      interact.Input(prompt: "path to local klutter (dart)").interact();
  return "local@$path";
}

String askForKlutteruiPubVersion() {
  final sources = ["git", "pub", "local"];
  final prompt =
      Select(prompt: "select klutter_ui (dart) source", options: sources)
          .interact();
  final source = sources[prompt];

  if (source == "git") {
    return "https://github.com/buijs-dev/klutter-dart-ui.git@develop";
  }

  if (source == "pub") {
    return interact.Input(
            prompt: "klutter_ui (dart) version",
            defaultValue: klutterUIPubVersion)
        .interact();
  }

  final path =
      interact.Input(prompt: "path to local klutter_ui (dart)").interact();
  return "local@$path";
}

String askForSquintPubVersion() {
  final sources = ["git", "pub", "local"];
  final prompt = Select(prompt: "select squint (dart) source", options: sources)
      .interact();
  final source = sources[prompt];

  if (source == "git") {
    return "https://github.com/buijs-dev/squint.git@develop";
  }

  if (source == "pub") {
    return interact.Input(
            prompt: "squint_json (dart) version",
            defaultValue: squintPubVersion)
        .interact();
  }

  final path =
      interact.Input(prompt: "path to local squint_json (dart)").interact();
  return "local@$path";
}

bool askConfirmation(String prompt, [bool? defaultValue]) => Confirm(
      prompt: prompt,
      defaultValue: defaultValue ?? false,
      waitForNewLine: true,
    ).interact();

Future<void> runTaskWithSpinner(
    TaskName taskName, Map<TaskOption, String> options) async {
  final loading = Spinner(icon: "..").interact();
  final args = [taskName.name];
  options.forEach((key, value) {
    args.add("${key.name}=$value");
  });
  print(await run(args));
  loading.done();
}
