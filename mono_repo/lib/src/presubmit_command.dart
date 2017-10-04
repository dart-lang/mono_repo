import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
// import 'package:yaml/yaml.dart' as y;

// import 'package_config.dart';
// import 'pubspec.dart';
import 'travis_config.dart';
import 'utils.dart';

class PresubmitCommand extends Command {
  @override
  String get name => 'presubmit';

  @override
  String get description => 'Run the travis presubmits locally.';

  PresubmitCommand() {
    argParser.addOption('package',
        help: 'The package(s) to run on, defaults to all packages',
        allowMultiple: true,
        abbr: 'p');
    argParser.addOption('task',
        help: 'The task(s) to run, defaults to all tasks',
        allowMultiple: true,
        abbr: 't');
    argParser.addOption('sdk',
        help: 'Which sdk to use for match tasks, defaults to current sdk',
        allowMultiple: false,
        defaultsTo: _currentSdk,
        allowed: ['dev', 'stable']);
  }

  @override
  Future run() async {
    var passed = await presubmit(
        packages: argResults['package'] as List<String>,
        tasks: argResults['task'] as List<String>,
        sdkToRun: argResults['sdk'] as String);

    // Set a bad exit code if it failed.
    if (!passed) exitCode = 1;
  }
}

final _currentSdk =
    new Version.parse(Platform.version.split(' ').first).isPreRelease
        ? 'dev'
        : 'stable';

/// A temp dir to dump logs to for errors.
Directory __tmpDir;
Directory get _tmpDir => __tmpDir ??= Directory.systemTemp.createTempSync();

Future<bool> presubmit(
    {Iterable<String> packages,
    Iterable<String> tasks,
    String sdkToRun,
    String rootDirectory}) async {
  packages ??= <String>[];
  tasks ??= <String>[];
  sdkToRun ??= _currentSdk;

  if (!new File(travisShPath).existsSync()) {
    throw new UserException(
        'No $travisShPath file found, please run the `travis` command first.');
  }

  var configs = getTravisConfigs(rootDirectory: rootDirectory);
  // By default, run on all packages.
  if (packages.isEmpty) packages = configs.keys;
  packages = packages.toList()..sort();

  // By default run all tasks.
  var allKnownTasks = configs.values.fold(new Set<String>(),
      (Set<String> exising, TravisConfig config) {
    return exising..addAll(config.tasks.map((task) => task.name));
  });
  if (tasks.isEmpty) tasks = allKnownTasks;
  var unrecognizedTasks = tasks.where((task) => !allKnownTasks.contains(task));
  if (unrecognizedTasks.isNotEmpty) {
    throw new UserException(
        'Found ${unrecognizedTasks.length} unrecognized tasks:\n'
        '${unrecognizedTasks.map((task) => '  $task').join('\n')}\n\n'
        'Known tasks are:\n'
        '${allKnownTasks.map((task) => '  $task').join('\n')}');
  }

  // Status of the presubmit.
  var passed = true;
  for (var package in packages) {
    var config = configs[package];
    if (config == null) {
      throw new UserException(
          'Unrecognized package `$package`, known packages are:\n'
          '${configs.keys.map((pkg) => '  $pkg').join('\n')}');
    }

    stderr.writeln(styleBold.wrap(package));
    for (var job in config.travisJobs) {
      var sdk = job.sdk;
      var task = job.task;
      // Skip tasks that weren't specified
      if (!tasks.contains(task.name)) continue;

      stderr.write(
          '  Running task ${styleBold.wrap(white.wrap('${task.name}:$sdk'))} ');
      if (sdk != sdkToRun) {
        stderr.writeln(yellow.wrap('(skipped, mismatched sdk)'));
        continue;
      }
      var result = await Process.run(travisShPath, [],
          environment: {'TASK': job.task.name, 'PKG': package});
      if (result.exitCode == 0) {
        stderr.writeln(green.wrap('(success)'));
      } else {
        var file = new File(
            p.join(_tmpDir.path, '${package}_${job.task.name}_${job.sdk}.txt'));
        await file.create(recursive: true);
        await file.writeAsString(result.stdout as String);
        stderr.writeln(red.wrap('(failure, ${file.path})'));
        passed = false;
      }
    }
  }
  return passed;
}
