// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mono_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TravisJob _$TravisJobFromJson(Map json) {
  return $checkedNew('TravisJob', json, () {
    var val = new TravisJob(
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
                ?.toList()),
        description: $checkedConvert(json, 'description', (v) => v as String));
    return val;
  });
}

Map<String, dynamic> _$TravisJobToJson(TravisJob instance) {
  var val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  val['package'] = instance.package;
  val['sdk'] = instance.sdk;
  val['stageName'] = instance.stageName;
  val['tasks'] = instance.tasks;
  return val;
}

Task _$TaskFromJson(Map json) {
  return $checkedNew('Task', json, () {
    var val = new Task($checkedConvert(json, 'name', (v) => v as String),
        args: $checkedConvert(json, 'args', (v) => v as String),
        config: $checkedConvert(json, 'config',
            (v) => (v as Map)?.map((k, e) => new MapEntry(k as String, e))));
    return val;
  });
}

Map<String, dynamic> _$TaskToJson(Task instance) {
  var val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('args', instance.args);
  writeNotNull('config', instance.config);
  return val;
}
