import 'dart:async';
import 'dart:io';

import 'package:io/ansi.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'package_config.dart';
import 'version.dart';

final skipCreatedWithSentinel = Object();

String createdWith() => Zone.current[skipCreatedWithSentinel] == true
    ? ''
    : '# Created with package:mono_repo v$packageVersion\n';

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

List<Task> _travisTasks(Iterable<PackageConfig> configs) =>
    configs.expand((config) => config.jobs).expand((job) => job.tasks).toList();
