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

import "package:klutter/klutter.dart";
import "package:test/test.dart";

void main() {
  test("Verify parsing consumer init command", () {
    final command = Command.from(
        script: ScriptName.consumer,
        arguments: ["init"]);

    expect(command != null, true, reason: "command should not be null");
    expect(command!.scriptName, ScriptName.consumer);
    expect(command.taskName, TaskName.init);
  });

  test("Verify parsing get flutter command", () {
    final command = Command.from(
        script: ScriptName.producer,
        arguments: ["get", "flutter=3.10.6.macos.x64"]);

    expect(command != null, true);
  });

  test("Verify parsing producer init command", () {
    final command = Command.from(
        script: ScriptName.producer,
        arguments: ["init", "bom=2023.1.1.beta", "flutter=3.10.6.macos.arm64",]);

    expect(command != null, true);
    expect(command!.scriptName, ScriptName.producer);
    expect(command.taskName, TaskName.init);
    expect(command.options.isNotEmpty, true);
    expect(command.options[ScriptOption.bom], "2023.1.1.beta");
    expect(command.options[ScriptOption.flutter], "3.10.6.macos.arm64");
  });

  test("When more than 2 arguments are supplied then command is null", () {
    final command = Command.from(
        script: ScriptName.producer,
        arguments: ["init", "bom=2023.1.1.beta", "flutter=3.10.6.macos.arm64", "x=y"]);

    expect(command == null, true, reason: "command should be null because too many arguments");
  });

  test("When an argument has more than one '=' then command is null", () {
    final command = Command.from(
        script: ScriptName.producer,
        arguments: ["init", "bom=2023.1.1.beta=woot", "flutter=3.10.6.macos.arm64",]);

    expect(command == null, true, reason: "command should be null argument is invalid");
  });

  test("When an argument is not a valid option value then command is null", () {
    final command = Command.from(
        script: ScriptName.producer,
        arguments: ["init", "woot=2023.1.1.beta", "flutter=3.10.6.macos.arm64",]);

    expect(command == null, true, reason: "command should be null because argument is invalid");
  });

  test("When get command has more than 1 argument, command is null", () {
    final command = Command.from(
        script: ScriptName.producer,
        arguments: ["get", "this", "and" ]);

    expect(command == null, true, reason: "command should be null because get can only have one argument");
  });

  test("When get command option is invalid, command is null", () {
    final command = Command.from(
        script: ScriptName.producer,
        arguments: ["get", "flutter=this=that"]);

    expect(command, null);
  });

  test("When get command option is not named flutter, command is null", () {
    final command = Command.from(
        script: ScriptName.producer,
        arguments: ["get", "not=flutter"]);

    expect(command, null);
  });

  test("When get command option flutter is not a valid version, command is null", () {
    final command = Command.from(
        script: ScriptName.producer,
        arguments: ["get", "flutter=not.really.flutterrrr", "overwrite=true"]);

    expect(command, null);
  });
}
