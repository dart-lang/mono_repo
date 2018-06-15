// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawConfig _$RawConfigFromJson(Map json) {
  return $checkedNew('RawConfig', json, () {
    $checkKeys(json, allowedKeys: const ['dart', 'stages']);
    var val = new RawConfig(
        $checkedConvert(json, 'dart',
            (v) => (v as List)?.map((e) => e as String)?.toList()),
        $checkedConvert(
            json,
            'stages',
            (v) => (v as List)
                ?.map((e) => e == null ? null : new RawStage.fromJson(e as Map))
                ?.toList()));
    return val;
  }, fieldKeyMap: const {'sdks': 'dart'});
}
