// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:io/ansi.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart' as y;

import 'package_config.dart';
import 'pubspec.dart';
import 'utils.dart';

class CheckCommand extends Command {
  @override
  String get name => 'check';

  @override
  String get description => 'Check the state of the repository.';

  @override
  Future run() => check();
}

Future check({String rootDirectory}) async {
  var reports = await getPackageReports(rootDirectory: rootDirectory);

  print(styleBold.wrap('    ** REPORT **'));
  print('');

  reports.forEach((dir, report) {
    _print(dir, report);
  });
}

Future<Map<String, PackageReport>> getPackageReports(
    {String rootDirectory}) async {
  rootDirectory ??= p.current;
  var packages = getPackageConfig(rootDirectory: rootDirectory);

  var pubspecs = <String, Pubspec>{};
  packages.forEach((dir, config) {
    var pkgPath = p.join(rootDirectory, dir, 'pubspec.yaml');
    var pubspecContent = y.loadYaml(new File(pkgPath).readAsStringSync())
        as Map<String, dynamic>;

    var pubspec = new Pubspec.fromJson(pubspecContent);

    // TODO: should enforce that all "covered" pubspecs have different names
    // in their pubspec.yaml file? Certainly all published packages
    pubspecs[dir] = pubspec;
  });

  var pubspecValues = pubspecs.values.toSet();

  var reports = <String, PackageReport>{};

  packages.forEach((dir, config) {
    var report = new PackageReport.create(config, pubspecs[dir], pubspecValues);
    reports[dir] = report;
  });

  return reports;
}

void _print(String relativePath, PackageReport report) {
  print('$relativePath/');
  print('       name: ${report.packageName}');
  print('  published: ${report.published}');
  if (report.version != null) {
    var value = '    version: ${report.version}';
    if (report.version.isPreRelease) {
      value = yellow.wrap(value);
    }
    print(value);
  }
  if (report.siblings.isNotEmpty) {
    print('   siblings:');
    report.siblings.forEach((k, v) {
      var value = '     $k: $v';
      if (report.published && v.overrideData != null) {
        value = yellow.wrap(value);
      }
      print(value);
    });
  }
  print('');
}

class PackageReport {
  final PackageConfig config;
  final Pubspec pubspec;
  final Map<String, SiblingReference> siblings;

  bool get published => config.published;

  String get packageName => pubspec.name;
  Version get version => pubspec.version;

  PackageReport(this.config, this.pubspec, this.siblings);

  factory PackageReport.create(
      PackageConfig config, Pubspec pubspec, Set<Pubspec> siblings) {
    // TODO(kevmoo): check: if any dependency has a path dependency, it'd better
    // be a sibling – right?

    var sibs = <String, SiblingReference>{};
    for (var sib in siblings) {
      var ref = new SiblingReference.create(pubspec, sib);

      if (ref != null) {
        sibs[sib.name] = ref;
      }
    }

    return new PackageReport(config, pubspec, sibs);
  }
}

enum DependencyType { direct, dev, indirect }

class SiblingReference {
  final DependencyType type;
  final DependencyData normalData;
  final DependencyData overrideData;

  SiblingReference(this.type, this.normalData, this.overrideData);

  factory SiblingReference.create(Pubspec sourcePubspec, Pubspec sibling) {
    for (var dep in sourcePubspec.dependencies.values) {
      if (dep.name == sibling.name) {
        // a match!
        var override = sourcePubspec.dependencyOverrides.values
            .firstWhere((d) => d.name == dep.name, orElse: () => null);
        return new SiblingReference(
            DependencyType.direct, dep.data, override?.data);
      }
    }
    for (var dep in sourcePubspec.devDependencies.values) {
      if (dep.name == sibling.name) {
        // a match!
        var override = sourcePubspec.dependencyOverrides.values
            .firstWhere((d) => d.name == dep.name, orElse: () => null);
        return new SiblingReference(
            DependencyType.dev, dep.data, override?.data);
      }
    }
    for (var dep in sourcePubspec.dependencyOverrides.values) {
      if (dep.name == sibling.name) {
        return new SiblingReference(DependencyType.indirect, null, dep.data);
      }
    }
    return null;
  }

  @override
  String toString() {
    var items = [type.toString().split('.')[1]];

    if (overrideData != null) {
      items.add('overridden');
    }

    return items.join(', ');
  }
}
