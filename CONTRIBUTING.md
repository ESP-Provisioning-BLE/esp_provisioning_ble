# Contributing to esp_provisioning_ble

Thanks for your interest in improving `esp_provisioning_ble`. This guide covers how to set the project up, the workflow we follow, and the checks every change must pass.

By participating you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## Getting set up

You need the Flutter SDK on the stable channel; the package targets Dart `>=3.1.0`.

```sh
git clone https://github.com/ESP-Provisioning-BLE/esp_provisioning_ble.git
cd esp_provisioning_ble
flutter pub get
```

The example app under `example/` has its own dependencies:

```sh
cd example
flutter pub get
```

## Workflow

- Open an issue first for anything large or potentially breaking, so the approach can be agreed before you invest time.
- Create a branch named after the change type: `feat/...`, `fix/...`, `docs/...`, `chore/...`, `test/...`. Maintainers with push access branch directly in this repository; external contributors fork and open a pull request from their fork.
- Keep each pull request focused on a single change.
- Rebase is disabled on this repository; pull requests land as a merge commit or a squash.

## Commits

- Follow [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): summary`, where `type` is `feat`, `fix`, `docs`, `chore`, `test`, `refactor`, and so on.
- Signing your commits (`git commit -S`) is strongly encouraged, so GitHub marks them as **Verified**, but it is not required: pull requests land as a signed merge or squash commit either way.

## Checks every pull request must pass

CI runs two required jobs, `package` (the repository root) and `example` (the `example/` app). Both must be green before a pull request can be merged. Run the same checks locally first:

```sh
# package job (repository root)
dart format lib test
flutter analyze
flutter test --coverage

# example job
cd example
dart format lib test
flutter analyze
flutter test
```

- **Formatting**: CI runs `dart format --output=none --set-exit-if-changed lib test`, so format before you commit.
- **Analysis**: `flutter analyze` must report no issues.
- **Tests and coverage**: run `flutter test --coverage`. Coverage, excluding the generated protobuf files under `*/generated/*`, must stay at or above **60%**. New code should come with tests.
- **Publishability**: CI runs `dart pub publish --dry-run`; keep it clean.

Pull requests opened from a fork cannot post the automated coverage comment, because GitHub gives fork workflows a read-only token; a maintainer will confirm coverage in that case.

Testing the Security 1 handshake without physical hardware is tracked in #28 (a device-simulator approach). See that issue if your change touches the handshake.

## Changelog

Add an entry under the `## [Unreleased]` section of [CHANGELOG.md](CHANGELOG.md), which follows the [Keep a Changelog](https://keepachangelog.com/) format. Maintainers rename `[Unreleased]` to the release version at publish time.

## Versioning

The project follows semantic versioning. Maintainers label each pull request with its semver impact: `bump/patch`, `bump/minor`, `bump/major`, or `bump/not-required` for docs, metadata, or CI-only changes.

## License

By contributing to `esp_provisioning_ble`, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).
