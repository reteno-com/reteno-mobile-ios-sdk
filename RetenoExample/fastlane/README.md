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

### ios add_cocoapods_keys

```sh
[bundle exec] fastlane ios add_cocoapods_keys
```

Add keys to the repository. example: 'key1:value1 key2:value2 key3:' will add key1 and key2 and remove key3

### ios sync_cocoapods_keys

```sh
[bundle exec] fastlane ios sync_cocoapods_keys
```

Synchronize your keychain with private keys

### ios known_flags

```sh
[bundle exec] fastlane ios known_flags
```



### ios sync_certs

```sh
[bundle exec] fastlane ios sync_certs
```

Sync development, adhoc and appstore certificates or the one, provided by MATCH_TYPE environment variable

### ios make_certs

```sh
[bundle exec] fastlane ios make_certs
```

Make development, adhoc and appstore certificates or the one, provided by MATCH_TYPE environment variable

### ios drop_certs

```sh
[bundle exec] fastlane ios drop_certs
```

Drop development, adhoc and appstore certificates or the one, provided by MATCH_TYPE environment variable

### ios deploy

```sh
[bundle exec] fastlane ios deploy
```

Make a build, export it into an archive and upload to the Crashlytics

### ios bump_version

```sh
[bundle exec] fastlane ios bump_version
```

Bump type to be used to increment version. Available values are: 'major', 'minor', patch. Default is 'patch'

### ios bump_build_number

```sh
[bundle exec] fastlane ios bump_build_number
```

Bump build number to current + 1

### ios upload_symbols

```sh
[bundle exec] fastlane ios upload_symbols
```

Download symbols from the AppStore and upload to the Crashlytics

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
