// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'package:mono_repo/src/package_config.dart';

import 'shared.dart';

// TODO(kevmoo): validate `mono_repo --help` output, too!

void main() {
  test('validate readme content', () {
    var readmeContent = File('README.md').readAsStringSync();
    expect(readmeContent, contains(_pkgConfig));
  });

  test('validate readme example output', () async {
    await d.dir('sub_pkg', [
      d.file(monoPkgFileName, _pkgConfig),
      d.file('pubspec.yaml', '''
name: sub_pkg
''')
    ]).create();

    testGenerateTravisConfig();

    await d.dir('.', [
      d.file(travisFileName, _travisYml),
      d.file(travisShPath, _travisSh)
    ]).validate();
  });
}

final _pkgConfig = r'''
# This key is required. It specifies the Dart SDKs your tests will run under
# You can provide one or more value.
# See https://docs.travis-ci.com/user/languages/dart#choosing-dart-versions-to-test-against
# for valid values
dart:
 - dev

stages:
  # Register two jobs to run under the `analyze` stage.
  - analyze:
    - dartanalyzer
    - dartfmt
  - unit_test:
    - test
''';

final _travisYml = r'''
# Created with package:mono_repo v1.2.3
language: dart

jobs:
  include:
    - stage: analyze
      name: "SDK: dev; PKG: sub_pkg; TASKS: `dartanalyzer .`"
      dart: dev
      env: PKGS="sub_pkg"
      script: ./tool/travis.sh dartanalyzer
    - stage: analyze
      name: "SDK: dev; PKG: sub_pkg; TASKS: `dartfmt -n --set-exit-if-changed .`"
      dart: dev
      env: PKGS="sub_pkg"
      script: ./tool/travis.sh dartfmt
    - stage: unit_test
      name: "SDK: dev; PKG: sub_pkg; TASKS: `pub run test`"
      dart: dev
      env: PKGS="sub_pkg"
      script: ./tool/travis.sh test

stages:
  - analyze
  - unit_test

# Only building master means that we don't run two builds for each pull request.
branches:
  only:
    - master

cache:
  directories:
    - "$HOME/.pub-cache"
''';

final _travisSh = r'''
#!/bin/bash
# Created with package:mono_repo v1.2.3

if [[ -z ${PKGS} ]]; then
  echo -e '\033[31mPKGS environment variable must be set!\033[0m'
  exit 1
fi

if [[ "$#" == "0" ]]; then
  echo -e '\033[31mAt least one task argument must be provided!\033[0m'
  exit 1
fi

EXIT_CODE=0

for PKG in ${PKGS}; do
  echo -e "\033[1mPKG: ${PKG}\033[22m"
  pushd "${PKG}" || exit $?
  pub upgrade --no-precompile || exit $?

  for TASK in "$@"; do
    echo
    echo -e "\033[1mPKG: ${PKG}; TASK: ${TASK}\033[22m"
    case ${TASK} in
    dartanalyzer)
      echo 'dartanalyzer .'
      dartanalyzer . || EXIT_CODE=$?
      ;;
    dartfmt)
      echo 'dartfmt -n --set-exit-if-changed .'
      dartfmt -n --set-exit-if-changed . || EXIT_CODE=$?
      ;;
    test)
      echo 'pub run test'
      pub run test || EXIT_CODE=$?
      ;;
    *)
      echo -e "\033[31mNot expecting TASK '${TASK}'. Error!\033[0m"
      EXIT_CODE=1
      ;;
    esac
  done

  popd
done

exit ${EXIT_CODE}
''';
