fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios build

```sh
[bundle exec] fastlane ios build
```

Create an ios release build

### ios beta_upload

```sh
[bundle exec] fastlane ios beta_upload
```

Deliver ios app to beta (testflight)

### ios production_upload

```sh
[bundle exec] fastlane ios production_upload
```

Deliver ios app to production

### ios promote

```sh
[bundle exec] fastlane ios promote
```

Promote the ios app from beta (testflight) to production

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
