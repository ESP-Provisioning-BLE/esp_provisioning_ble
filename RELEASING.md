# Releasing

Maintainer guide for cutting a release of `esp_provisioning_ble` and publishing it to pub.dev.

Publishing is automated: pushing a version tag to GitHub triggers a workflow that publishes to pub.dev over OIDC. There are no stored tokens, and manual publishing from a local machine is disabled.

## One-time setup (already configured)

- **pub.dev** (package admin, Automated publishing): publishing from GitHub Actions is enabled for this repository with tag pattern `v{{version}}`, push events on, `workflow_dispatch` off, and a required environment named `pub.dev`.
- **GitHub environment `pub.dev`**: requires a maintainer's approval before a deployment proceeds, admin bypass disabled, limited to `v*` tags.
- **Tag ruleset**: creating `v*` tags is restricted to administrators.
- **Workflow**: [`.github/workflows/publish.yml`](.github/workflows/publish.yml) runs on `v[0-9]+.[0-9]+.[0-9]+` tags.

## Release steps

1. **Prepare a release PR**:
   - Bump `version` in `pubspec.yaml` to the new `X.Y.Z` (use the merged PRs' `bump/*` labels to decide the increment).
   - Update the `description` in `pubspec.yaml` if the canonical wording changed.
   - In `CHANGELOG.md`, rename `## [Unreleased]` to `## [X.Y.Z] - <date>` and add a fresh empty `## [Unreleased]` above it.
   - Run `dart pub publish --dry-run` and confirm no warnings.
2. **Merge** the release PR to `main`.
3. **Tag the release** (administrators only), from `main`, matching the pubspec version exactly:
   ```sh
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```
4. **Approve the deployment**: the publish workflow starts and pauses on the `pub.dev` environment. Approve it from the workflow run.
5. The workflow verifies the tag matches the pubspec version and publishes over OIDC. Confirm the new version on [pub.dev](https://pub.dev/packages/esp_provisioning_ble).
6. **(Optional)** Create a GitHub Release from the tag, using the CHANGELOG entry as the notes.

## Notes

- The tag must match the `pubspec.yaml` version; both the workflow and pub.dev's `v{{version}}` pattern enforce it, and a mismatch aborts the publish.
- If a publish fails, fix the cause and re-run the same workflow run (no need to re-tag).
- A release needs both an admin-created tag and an explicit environment approval.
