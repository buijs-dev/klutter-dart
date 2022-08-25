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

import "dart:io";

import "package:klutter/src/common/exception.dart";
import "package:klutter/src/consumer/ios.dart";
import "package:test/test.dart";

void main() {
  final s = Platform.pathSeparator;

  test("Verify exception is thrown if root/ios does not exist", () {
    expect(
        () => excludeArm64FromPodfile("fake"),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith("Path does not exist:") &&
            e.cause.endsWith("/fake"))));
  });

  test("Verify no  exception is thrown if root/ios/Podfile does not exist", () {
    final root = Directory("${Directory.systemTemp.path}${s}plt1")
      ..createSync();

    Directory("${root.absolute.path}${s}ios").createSync();

    root.deleteSync(recursive: true);
  });

  test("Verify exception is thrown if post_install block is not found", () {
    final root = Directory("${Directory.systemTemp.path}${s}plt2")
      ..createSync();

    final ios = Directory("${root.absolute.path}${s}ios")..createSync();

    File("${ios.absolute.path}${s}Podfile").createSync();

    // An exception is thrown
    expect(
        () => excludeArm64FromPodfile(ios.path),
        throwsA(predicate((e) =>
            e is KlutterException &&
            e.cause.startsWith("Failed to add exclusions for arm64."))));

    root.deleteSync(recursive: true);
  });

  test("Verify exclusions are added properly", () {
    final root = Directory("${Directory.systemTemp.path}${s}plt3")
      ..createSync();

    final ios = Directory("${root.absolute.path}${s}ios")..createSync();

    final podfile = File("${ios.absolute.path}${s}Podfile")
      ..createSync()
      ..writeAsStringSync("""
        post_install do |installer|
          installer.pods_project.targets.each do |target|
            flutter_additional_ios_build_settings(target)
          end
        end""");

    // when:
    excludeArm64FromPodfile(ios.path);

    // then:
    expect(
        podfile.readAsStringSync().replaceAll(" ", "").contains("""
      target.build_configurations.each do |bc|
          bc.build_settings['ARCHS[sdk=iphonesimulator*]'] =  `uname -m`
       end
      """
            .replaceAll(" ", "")),
        true,
        reason: "Exclusions lines should be added.");

    root.deleteSync(recursive: true);
  });
}
