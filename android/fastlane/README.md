fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android keystore

```sh
[bundle exec] fastlane android keystore
```

Download and decrypt the JKS

### android build

```sh
[bundle exec] fastlane android build
```

Create an android release build

### android upload

```sh
[bundle exec] fastlane android upload
```

Deliver android app to beta or production

### android promote

```sh
[bundle exec] fastlane android promote
```

Promote the android app from beta to production

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
