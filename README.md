![B90/DIE GRÜNEN](android/app/src/main/res/mipmap-hdpi/ic_launcher.png)

# B90/DIE GRÜNEN App

## Contents

- [Setup](#setup)
- [Initial Setup](#initial-setup)
- [Run the App](#run-the-app)
- [Release Workflow](docs/release-workflow.md)
- [Conventions](docs/conventions.md)
- [CI/CD](docs/cicd.md)

## Setup

### Initial Setup

1. Install the Android SDK via
   the [Android plugin](https://www.jetbrains.com/help/idea/create-your-first-android-application.html#754fd) or Android
   Studio
2. Install [fvm](https://fvm.app/documentation/getting-started/installation) (flutter version manager)
3. Install flutter

``` shell
fvm install
```

4. [Optional] Open IntelliJ settings and
  - Install the Android plugin and set the Android SDK path
  - Install the Dart plugin and set the Dart SDK path
  - Install the Flutter plugin and set the Flutter SDK path

#### API Setup

There are two options to connect your app to the Grüne API for development:

- [Connect to the staging Grüne API using an access token](#staging-grüne-api-setup)
- [Connect to the locally running Grüne API](#local-grüne-api-setup)

##### Staging Grüne API Setup

1. Generate an access token for the staging Grüne API
2. Copy staging environment

``` shell
cp .env.staging .env
```

3. Add your `GRUENE_API_ACCESS_TOKEN` to `.env`

##### Local Grüne API Setup

0. Make sure the Grüne API is setup and running. For documentation on the necessary steps, refer to
   the [Grüne API README](https://github.com/verdigado/gruene-api).
1. Configure local environment

``` shell
cp .env.dev .env
```

### Run the App

1. Update translations

``` shell
fvm dart run slang
```

2. Run build runner to update API definitions

``` shell
fvm dart run build_runner build
```

3. [Optional] If you are running the app on a real device and use a local Grüne API, you need to expose the ports:

``` shell
adb reverse tcp:8080 tcp:8080 && adb reverse tcp:5000 tcp:5000
```

4. Run the app (`development`)
