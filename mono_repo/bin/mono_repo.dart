// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mono_repo/mono_repo.dart';
import 'package:io/ansi.dart' as ansi;
import 'package:io/io.dart';

main(List<String> arguments) async {
  try {
    await run(arguments);
  } on UserException catch (e) {
    stderr.writeln(ansi.red.wrap(e.message));
    exitCode = ExitCode.config.code;
  } on UsageException catch (e) {
    stderr.writeln(ansi.red.wrap(e.message));
    if (e.usage != null) {
      stderr.writeln('');
      stderr.writeln(e.usage);
    }
    exitCode = ExitCode.usage.code;
  }
}
