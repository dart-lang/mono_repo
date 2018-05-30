// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mono_config.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

TravisJob _$TravisJobFromJson(Map json) => $checkedNew(
    'TravisJob',
    json,
    () => new TravisJob(
        $checkedConvert(json, 'package', (v) => v as String),
        $checkedConvert(json, 'sdk', (v) => v as String),
        $checkedConvert(json, 'stageName', (v) => v as String),
        $checkedConvert(
            json,
            'tasks',
            (v) => (v as List)
                ?.map((e) => e == null
                    ? null
                    : new Task.fromJson(e as Map<String, dynamic>))
                ?.toList())));

abstract class _$TravisJobSerializerMixin {
  String get package;
  String get sdk;
  String get stageName;
  List<Task> get tasks;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'package': package,
        'sdk': sdk,
        'stageName': stageName,
        'tasks': tasks
      };
}

Task _$TaskFromJson(Map json) => $checkedNew(
    'Task',
    json,
    () => new Task($checkedConvert(json, 'name', (v) => v as String),
        args: $checkedConvert(json, 'args', (v) => v as String),
        config: $checkedConvert(json, 'config',
            (v) => (v as Map)?.map((k, e) => new MapEntry(k as String, e)))));

abstract class _$TaskSerializerMixin {
  String get name;
  String get args;
  Map<String, dynamic> get config;
  Map<String, dynamic> toJson() {
    var val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('name', name);
    writeNotNull('args', args);
    writeNotNull('config', config);
    return val;
  }
}
