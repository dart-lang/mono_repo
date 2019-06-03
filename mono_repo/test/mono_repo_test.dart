// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  test('running without arguments produces expected help output', () async {
    var process = await TestProcess.start('pub', ['run', 'mono_repo']);

    var output = await process.stdoutStream().join('\n');
    expect(output, _helpOutput);

    await process.shouldExit(0);
  });

  test('readme contains latest task output', () {
    var readme = File('README.md');

    expect(readme.readAsStringSync(), contains('```\n$_helpOutput\n```'));
  });
}

final _helpOutput = '''Manage multiple packages in one source repository.

Usage: mono_repo <command> [arguments]

Global options:
-h, --help              Print this usage information.
    --version           Prints the version of mono_repo.
    --[no-]recursive    Whether to recursively walk sub-directorys looking for packages.
                        (defaults to on)

Available commands:
  check       Check the state of the repository.
  help        Display help information for mono_repo.
  presubmit   Run the travis presubmits locally.
  pub         Run a `pub` command across all packages.
  travis      Configure Travis-CI for child packages.

Run "mono_repo help <command>" for more information about a command.''';
