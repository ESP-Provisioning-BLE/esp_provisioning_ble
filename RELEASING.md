# Releasing

Maintainer guide for cutting a release of `esp_provisioning_ble` and publishing it to pub.dev.

Publishing is automated: pushing a version tag to GitHub triggers a workflow that publishes to pub.dev over OIDC. There are no stored tokens, and manual publishing from a local machine is disabled.

## One-time setup (already configured)

- **pub.dev** (package admin, Automated publishing): publishing from GitHub Actions is enabled for this repository with tag pattern `v{{version}}`, push events on, `workflow_dispatch` off, and a required environment named `pub.dev`.
- **GitHub environment `pub.dev`**: requires a maintainer's approval before a deployment proceeds, admin bypass disabled, limited to `v*` tags.
- **Tag ruleset**: creating `v*` tags is restricted to administrators.
- **Branch ruleset "Protect main"**: applies to `main` and to every `release/**` branch. It blocks deleting the branch and force-pushing to it, and requires the `package` and `example` CI checks before a merge. It has no bypass, so a new `release/*` branch is protected from the moment it is created.
- **Workflow**: [`.github/workflows/publish.yml`](.github/workflows/publish.yml) runs on `v[0-9]+.[0-9]+.[0-9]+` and `v[0-9]+.[0-9]+.[0-9]+-*` tags. Its `branch-check` job only lets a stable tag (`vX.Y.Z`) publish from a commit on `main`, and a pre-release tag (`vX.Y.Z-dev.N`, `vX.Y.Z-rc.N`) from a commit on a `release/**` branch.

## Release lines and branches

Until 2.0.0 is out there are two lines:

- **1.x** is released from `main`, as stable versions only, following the release steps below.
- **2.0** is developed on `release/v2.0.0` and published from it as pre-releases: `2.0.0-dev.N` while the API is still changing, then `2.0.0-rc.N` once it is frozen.

The order of branches and tags is:

1. Create `release/v2.0.0` from `main`, right after a 1.x release tag (`vX.Y.Z`).
2. Keep releasing 1.x from `main` as needed. Everything that lands on `main` is then merged or cherry-picked into `release/v2.0.0`, so 2.0 does not lose it.
   - `release/v2.0.0` uses the Dart 3.7 formatter style and `main` still uses the older one, so code merged from `main` arrives unformatted or conflicts on formatting. Run `dart format lib test` on the merge itself and include the result in the merge commit.
   - `CHANGELOG.md` conflicts too, because both branches add sections at the top. Keep the 2.0 sections (`## [Unreleased]` and the `## [2.0.0-dev.N]` ones) first, and put the 1.x section that comes from `main` below them, above the previous 1.x release.
3. Publish pre-releases from `release/v2.0.0`, following the pre-release steps below. Each one needs its own version and tag; a published version can never be reused.
4. To release 2.0.0, merge `release/v2.0.0` into `main` through a PR, set the version to `2.0.0`, and tag `v2.0.0` on `main` as a normal stable release. Before deleting `release/v2.0.0` afterwards, exclude it from the "Protect main" ruleset: the ruleset blocks deleting it and has no bypass.
5. If 1.x needs a release after 2.0.0, create `release/v1.x` from the last `v1.*` tag and publish from it. Its copy of `publish.yml` must allow stable tags on that branch (`STABLE_BRANCHES` in the `branch-check` job): GitHub runs the workflow as it is in the tagged commit, so the change only affects tags on that branch.

On pub.dev, a pre-release never becomes the latest version, and neither does a 1.x version published after 2.0.0: users get them only if their constraints ask for them.

## Release steps

1. **Prepare a release PR**:
   - Bump `version` in `pubspec.yaml` to the new `X.Y.Z` (use the merged PRs' `bump/*` labels to decide the increment).
   - Update the `description` in `pubspec.yaml` if the canonical wording changed.
   - In `CHANGELOG.md`, rename `## [Unreleased]` to `## [X.Y.Z] - <date>` and add a fresh empty `## [Unreleased]` above it.
   - Run `dart pub publish --dry-run` and confirm no warnings.
2. **Merge** the release PR to `main`.
3. **Tag the release** (administrators only), from `main`, matching the pubspec version exactly. Release tags are annotated and signed:
   ```sh
   git tag -s vX.Y.Z -m "esp_provisioning_ble X.Y.Z"
   git push origin vX.Y.Z
   ```
4. **Approve the deployment**: the publish workflow starts and pauses on the `pub.dev` environment. Approve it from the workflow run. If the web or the mobile app cannot show the approval, approve it with the GitHub CLI, using the ID of the paused run (`gh run list --workflow publish.yml --limit 1` shows it):
   ```sh
   ENV_ID=$(gh api repos/ESP-Provisioning-BLE/esp_provisioning_ble/environments/pub.dev --jq .id)
   gh api -X POST repos/ESP-Provisioning-BLE/esp_provisioning_ble/actions/runs/<run-id>/pending_deployments \
     -F "environment_ids[]=$ENV_ID" -f state=approved -f comment="Publish vX.Y.Z"
   ```
5. The workflow verifies the tag matches the pubspec version and publishes over OIDC. Confirm the new version on [pub.dev](https://pub.dev/packages/esp_provisioning_ble).
6. **(Optional)** Create a GitHub Release from the tag, using the CHANGELOG entry as the notes.

## Pre-release steps

1. **Prepare a pre-release PR** into `release/v2.0.0`: set `version` in `pubspec.yaml` to `2.0.0-dev.N` (or `2.0.0-rc.N`), rename `## [Unreleased]` in `CHANGELOG.md` to `## [2.0.0-dev.N] - <date>` with a fresh `## [Unreleased]` above it, and run `dart pub publish --dry-run`.
2. **Merge** it into `release/v2.0.0`.
3. **Tag** the commit that the merge left on `release/v2.0.0` (administrators only):
   ```sh
   git tag -s v2.0.0-dev.N -m "esp_provisioning_ble 2.0.0-dev.N"
   git push origin v2.0.0-dev.N
   ```
4. **Approve the deployment**, as for a stable release.

## Notes

- The tag must match the `pubspec.yaml` version; both the workflow and pub.dev's `v{{version}}` pattern enforce it, and a mismatch aborts the publish.
- A tag on the wrong branch (a stable tag on `release/v2.0.0`, or a pre-release tag on `main`) fails in the `branch-check` job, before the deployment asks for approval. Delete the tag and tag the right commit.
- If a publish fails, fix the cause and re-run the same workflow run (no need to re-tag).
- A release needs both an admin-created tag and an explicit environment approval.
