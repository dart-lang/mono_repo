// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

import '../../package_config.dart';

/// Used as a place-holder so we can treat all jobs the same in certain
/// workflows.
class SelfValidateJob implements CIJob {
  @override
  final String stageName;

  SelfValidateJob(this.stageName);

  @override
  String get description => throw UnsupportedError('Should never be called');

  @override
  Version get explicitSdkVersion =>
      throw UnsupportedError('Should never be called');

  @override
  String get name => throw UnsupportedError('Should never be called');

  @override
  String get os => throw UnsupportedError('Should never be called');

  @override
  String get package => throw UnsupportedError('Should never be called');

  @override
  String get sdk => throw UnsupportedError('Should never be called');

  @override
  List<Task> get tasks => throw UnsupportedError('Should never be called');

  @override
  Map<String, dynamic> toJson() =>
      throw UnsupportedError('Should never be called');
}
