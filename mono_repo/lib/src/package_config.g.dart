// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: prefer_expression_function_bodies

part of 'package_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CIJob _$CIJobFromJson(Map json) {
  return $checkedNew('CIJob', json, () {
    final val = CIJob(
      $checkedConvert(json, 'os', (v) => v as String),
      $checkedConvert(json, 'package', (v) => v as String),
      $checkedConvert(json, 'sdk', (v) => v as String),
      $checkedConvert(json, 'stageName', (v) => v as String),
      $checkedConvert(
          json,
          'tasks',
          (v) => (v as List<dynamic>)
              .map((e) => Task.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()),
      description: $checkedConvert(json, 'description', (v) => v as String?),
    );
    return val;
  });
}

Map<String, dynamic> _$CIJobToJson(CIJob instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  val['os'] = instance.os;
  val['package'] = instance.package;
  val['sdk'] = instance.sdk;
  val['stageName'] = instance.stageName;
  val['tasks'] = instance.tasks.map((e) => e.toJson()).toList();
  return val;
}

Task _$TaskFromJson(Map json) {
  return $checkedNew('Task', json, () {
    final val = Task(
      $checkedConvert(json, 'name', (v) => v as String),
      args: $checkedConvert(json, 'args', (v) => v as String?),
    );
    return val;
  });
}

Map<String, dynamic> _$TaskToJson(Task instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('args', instance.args);
  return val;
}
