// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:mono_repo/src/user_exception.dart';
import 'package:test/test.dart';

Matcher throwsUserExceptionWith(Object message, Object details) {
  var matcher = const TypeMatcher<UserException>()
      .having((e) => e.message, 'message', message);

  matcher = matcher.having((e) => e.details, 'details', details);

  return throwsA(matcher);
}

final testConfig1 = r'''
dart:
  - dev
  - stable
  - 1.23.0

stages:
  - analyze_and_format:
    - description: "dartanalyzer && dartfmt"
      group:
        - dartanalyzer: --fatal-infos --fatal-warnings .
        - dartfmt
      dart:
        - dev
    - dartanalyzer: --fatal-infos --fatal-warnings .
      dart:
        - 1.23.0
  - unit_test:
    - test: --platform chrome
      xvfb: true
    - test: --preset travis --total-shards 5 --shard-index 0
      xvfb: true
    - test: --preset travis --total-shards 5 --shard-index 1
    - test #no args
''';

final testConfig2 = r'''
dart:
 - dev
 - stable
 - 1.23.0

stages:
  - analyze:
    - group:
        - dartanalyzer
        - dartfmt
      dart:
        - dev
    - dartanalyzer:
      dart:
        - 1.23.0
  - unit_test:
    - description: "chrome tests"
      test: --platform chrome
    - test: --preset travis --total-shards 9 --shard-index 0
    - test: --preset travis --total-shards 9 --shard-index 1
    - test: --preset travis --total-shards 9 --shard-index 2
    - test: --preset travis --total-shards 9 --shard-index 3
    - test: --preset travis --total-shards 9 --shard-index 4
    - test: --preset travis --total-shards 9 --shard-index 5
    - test: --preset travis --total-shards 9 --shard-index 6
    - test: --preset travis --total-shards 9 --shard-index 7
    - test: --preset travis --total-shards 9 --shard-index 8
    - test
''';
