Manage multiple [Dart packages] within a single repository.

### Installation

```console
> pub global activate mono_repo
```

### Usage

```
Manage multiple packages in one source repository.

Usage: mono_repo <command> [arguments]

Global options:
-h, --help              Print this usage information.
    --[no-]recursive    Whether to recursively walk sub-directorys looking for packages.

Available commands:
  check       Check the state of the repository.
  help        Display help information for mono_repo.
  presubmit   Run the travis presubmits locally.
  pub         Run `pub get` or `pub upgrade` against all packages.
  travis      Configure Travis-CI for child packages.

Run "mono_repo help <command>" for more information about a command.
```

[Dart packages]: https://www.dartlang.org/guides/libraries/create-library-packages
