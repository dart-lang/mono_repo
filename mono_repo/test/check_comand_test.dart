import 'package:test/test.dart';

import 'package:mono_repo/src/commands/check.dart' hide DependencyType;
import 'package:mono_repo/src/pubspec.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

main() {
  setUp(() async {
    await d.dir('foo', [
      d.file('pubspec.yaml', r'''
name: foo

dependencies:
  build: any
''')
    ]).create();

    await d.dir('bar', [
      d.file('pubspec.yaml', r'''
name: bar

dependencies:
  build:
    git:
      url: https://github.com/dart-lang/build.git
      path: build
      ref: hacking
''')
    ]).create();

    await d.dir('baz', [
      d.file('pubspec.yaml', r'''
name: baz

dependencies:
  build:
    git: https://github.com/dart-lang/build.git
'''),
      d.dir('recursive', [
        d.file('pubspec.yaml', r'''
name: baz.recursive

dependencies:
  baz: any
        '''),
      ]),
    ]).create();

    await d.dir('flutter', [
      // typical pubspec.yaml from flutter
      d.file('pubspec.yaml', r'''
name: flutter
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^0.1.0
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
  assets:
   - images/a_dot_burr.jpeg
  fonts:
    - family: Schyler
      fonts:
        - asset: fonts/Schyler-Regular.ttf
        - asset: fonts/Schyler-Italic.ttf
          style: italic
          weight: 700
''')
    ]).create();
  });

  test('check', () async {
    var reports = await getPackageReports(rootDirectory: d.sandbox);

    expect(reports, hasLength(4));

    var fooReport = reports['foo'];
    expect(fooReport.packageName, 'foo');
    expect(fooReport.published, isFalse);

    var barReport = reports['bar'];
    expect(barReport.packageName, 'bar');
    expect(barReport.published, isFalse);

    expect(barReport.pubspec.dependencies, hasLength(1));

    var gitDep = barReport.pubspec.dependencies['build'].data as GitData;
    expect(gitDep.url, Uri.parse('https://github.com/dart-lang/build.git'));
    expect(gitDep.path, 'build');
    expect(gitDep.ref, 'hacking');

    var bazReport = reports['baz'];
    expect(bazReport.packageName, 'baz');
    expect(bazReport.published, isFalse);

    expect(bazReport.pubspec.dependencies, hasLength(1));

    gitDep = bazReport.pubspec.dependencies['build'].data as GitData;
    expect(gitDep.url, Uri.parse('https://github.com/dart-lang/build.git'));
    expect(gitDep.path, isNull);
    expect(gitDep.ref, isNull);

    var flutterReport = reports['flutter'];
    expect(flutterReport.packageName, 'flutter');
    expect(flutterReport.published, isFalse);
    expect(flutterReport.pubspec.dependencies, hasLength(2));

    var sdkDep = flutterReport.pubspec.dependencies['flutter'].data as SdkData;
    expect(sdkDep.name, 'flutter');
    expect(sdkDep.type, DependencyType.sdk);
  });

  test('check recursive', () async {
    var reports =
        await getPackageReports(rootDirectory: d.sandbox, recursive: true);

    expect(reports, hasLength(5));

    var recursiveReport = reports['baz/recursive'];
    expect(recursiveReport.packageName, 'baz.recursive');
    expect(recursiveReport.published, isFalse);
    expect(recursiveReport.pubspec.dependencies, hasLength(1));
  });
}
