import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:io/ansi.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'package_config.dart';
import 'root_config.dart';
import 'version.dart';

final skipCreatedWithSentinel = Object();

String createdWith() => Zone.current[skipCreatedWithSentinel] == true
    ? ''
    : '# Created with package:mono_repo v$packageVersion\n';

class CIJobEntry {
  final CIJob job;
  final List<String> commands;
  final bool merge;

  CIJobEntry(this.job, this.commands, this.merge);

  String jobName(List<String> packages) {
    final pkgLabel = packages.length == 1 ? 'PKG' : 'PKGS';

    return 'SDK: ${job.sdk}; $pkgLabel: ${packages.join(', ')}; '
        'TASKS: ${job.name}';
  }

  @override
  bool operator ==(Object other) =>
      other is CIJobEntry &&
      _equality.equals(_identityItems, other._identityItems);

  @override
  int get hashCode => _equality.hash(_identityItems);

  List get _identityItems => [job.os, job.stageName, job.sdk, commands, merge];
}

void validateRootConfig(RootConfig rootConfig) {
  for (var config in rootConfig) {
    final sdkConstraint = config.pubspec.environment['sdk'];

    if (sdkConstraint == null) {
      continue;
    }

    final disallowedExplicitVersions = config.jobs
        .map((tj) => tj.explicitSdkVersion)
        .where((v) => v != null)
        .toSet()
        .where((v) => !sdkConstraint.allows(v))
        .toList()
          ..sort();

    if (disallowedExplicitVersions.isNotEmpty) {
      final disallowedString =
          disallowedExplicitVersions.map((v) => '`$v`').join(', ');
      print(
        yellow.wrap(
          '  There are jobs defined that are not compatible with '
          'the package SDK constraint ($sdkConstraint): $disallowedString.',
        ),
      );
    }
  }
}

void writeFile(
  String rootDirectory,
  String targetFilePath,
  String fileContent, {
  @required bool isScript,
}) {
  final fullPath = p.join(rootDirectory, targetFilePath);
  final scriptFile = File(fullPath);

  if (!scriptFile.existsSync()) {
    scriptFile.createSync(recursive: true);
    if (isScript) {
      for (var line in scriptLines(targetFilePath)) {
        print(yellow.wrap(line));
      }
    }
  }

  scriptFile.writeAsStringSync(fileContent);
  // TODO: be clever w/ `scriptFile.statSync().mode` to see if it's executable
  print(styleDim.wrap('Wrote `$fullPath`.'));
}

@visibleForTesting
List<String> scriptLines(String scriptPath) => [
      'Make sure to mark `$scriptPath` as executable.',
      '  chmod +x $scriptPath',
      if (Platform.isWindows) ...[
        'It appears you are using Windows, and may not have access to chmod.',
        'If you are using git, the following will emulate the Unix permissions '
            'change:',
        '  git update-index --add --chmod=+x $scriptPath'
      ],
    ];

/// Gives a map of command to unique task key for all [configs].
Map<String, String> extractCommands(Iterable<PackageConfig> configs) {
  _logPackages(configs);
  final commandsToKeys = <String, String>{};

  final tasksToConfigure = _travisTasks(configs);
  final taskNames = tasksToConfigure.map((task) => task.name).toSet();

  for (var taskName in taskNames) {
    final commands = tasksToConfigure
        .where((task) => task.name == taskName)
        .map((task) => task.command)
        .toSet();

    if (commands.length == 1) {
      commandsToKeys[commands.single] = taskName;
      continue;
    }

    // TODO: could likely use some clever `log` math here
    final paddingSize = (commands.length - 1).toString().length;

    var count = 0;
    for (var command in commands) {
      commandsToKeys[command] =
          '${taskName}_${count.toString().padLeft(paddingSize, '0')}';
      count++;
    }
  }

  return commandsToKeys;
}

void _logPackages(Iterable<PackageConfig> configs) {
  for (var pkg in configs) {
    print(styleBold.wrap('package:${pkg.relativePath}'));
    if (pkg.sdks != null && !pkg.dartSdkConfigUsed) {
      print(
        yellow.wrap(
          '  `dart` values (${pkg.sdks.join(', ')}) are not used '
          'and can be removed.',
        ),
      );
    }
    if (pkg.oses != null && !pkg.osConfigUsed) {
      print(
        yellow.wrap(
          '  `os` values (${pkg.oses.join(', ')}) are not used '
          'and can be removed.',
        ),
      );
    }
  }
}

List<Task> _travisTasks(Iterable<PackageConfig> configs) =>
    configs.expand((config) => config.jobs).expand((job) => job.tasks).toList();

const _equality = DeepCollectionEquality();
