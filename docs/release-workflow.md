# Release Workflow

For releases of the app to the Apple App Store and Google Play Store the corresponding CI workflows should always be used.

## Standard Release Workflow

New releases should always be thoroughly tested manually on both Android and iOS (ideally on multiple devices each).
For this purpose, releases should first **only be delivered to beta** (iOS: Testflight).
Ideally, beta releases are done well in advance of the actual production release date
to ensure sufficient time for manual testing and fixing possible problems.

The steps of the standard release workflow are as follows:
1. Devs trigger the `beta_delivery` workflow in the [CI](cicd.md#creating-a-new-release-or-promotion)
2. Testing the new release on Android and iOS
3. [Optional]: If problems are found, devs fix them and start over with 1.
4. Devs trigger the `promotion` workflow
5. PO adjusts the release notes in the stores and publishes the new release manually

## Hotfix Release Workflow

In case of critical bugs or urgent features,
the process of creating a new release can be sped up by directly delivering to production.
In this case, the workflow is as follows:

1. Devs trigger the `production_delivery` workflow in the [CI](cicd.md#creating-a-new-release-or-promotion)
2. PO adjusts the release notes in the stores and publishes the new release manually

Note: *As mistakes during development can and do happen,
this approach should be avoided if possible in favor of the [standard release workflow](#standard-release-workflow).*

## General Information on the Release Workflows

- New releases are automatically added for review both for Android and iOS.
This usually takes anywhere from a few hours to a day. In some cases, it may take several days.
- Both workflows currently require manual publishing before they are visible to users in the stores.
While this is currently intended to allow for release-specific release notes and control over the release date,
this could be changed.
See properties `release_status` (Android) and `automatic_release` (iOS) in the corresponding `Fastfile`.
Apart from setting adjusting these properties, the release notes would need to be supplied automatically.
