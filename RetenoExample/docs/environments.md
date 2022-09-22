# Application Environments

## Overview

Application has 3 environments in which it can be built:

- `Development` - points to the development / local server, is used for developing of new features or bug fixes, has dev tools.
- `Staging` - points to the staging / production server, is used for testing new bunch of functionality before release, has dev tools.
- `Production` - points to the production server, is used for AppStore release.

## Build Configuration

Each environment assotiated with 2 build configurations: `Debug` and `Release`. It's needed to give an ability to build project with specific environment in debug configiration or archive release configuration.

**Environments and assotiated Build Configurations**:

- `Development`: `Debug`, `Release` (original build configurations)
- `Staging`: `Staging-Debug`, `Staging-Release` (copied from original configurations)
- `Production`: `Production-Debug`, `Production-Release` (copied from original configurations)

## Environment's App Configuration

Each environment has an app configuration - set of available in runtime values related to the corresponding environment. 	

Its purpose is to provide variables and settings specific to the environment (api host, enabled and disabled features, etc.).

These values are represented in `plist` file in `./Environment/` directory. 
To access them in the code, use `Environment` struct (`Environment.default`) from the `Core` framework.

#### Add Environment's App Configuration to the app

For safety reasons, all environment's app configurations (`plist` files) are **NOT** in the bundle of the project, to prevent access in the Production app to values from the other environments' `plist` files.

So, we have a script that copies the runtime-accessible settings of our environment (needed `plist` file) into the bundle at build time. Script is located in `./scripts/copy-environment-config.sh`.

## Schemes

Each environment has assotiated build configurations. To build project with chosen environment, need to choose assotiated build configuration. It's not comfortable to choose needed build configuration in scheme settings every time before building the project or archiving a build.

So, to simplify creating of builds, were created schemes (from original `ProjectTemplate` scheme), which are assotiated with environments: `ProjectTemplate-Development`, `ProjectTemplate-Staging`, `ProjectTemplate-Production`. To build or archive project in a specific evironment need just to choose sheme from the list.

For each scheme was set up correct build configuration in scheme settings:

|         | Development | Staging         | Production         |
|---------|-------------|-----------------|--------------------|
| Run     | Debug       | Staging-Debug   | Production-Debug   |
| Test    | Debug       | Staging-Debug   | Production-Debug   |
| Profile | Release     | Staging-Release | Production-Release |
| Analyze | Debug       | Staging-Debug   | Production-Debug   |
| Archive | Release     | Staging-Release | Production-Release |

## .xcconfig

Each build configuration in app is copied from original `Debug` and `Release` build configurations. But all of them differ by assotiated `.xcconfig`s located in `./EnvironmentConfig/xcconfig/` directory

`.xcconfig` - set of available in build time values which we can use to configure build settings in Xcode. By using `.xcconfig` we can set different environments in app.

*Tip:*

To set `.xcconfig` to the specific build configuration, it should be set to the **Project** value in the build configurations list.

#### BUILD_ENV

The environment's app configuration makes it convenient to set up the environment, but in addition to it, `.xcconfig` declares special environment variables with which we can add or remove parts of the code through the swift preprocessor.
These variables look like `BUILD_ENV _ $ {BUILD_ENV}`. So, for each environment, they unfold in `BUILD_ENV_DEVELOPMENT`, `BUILD_ENV_STAGING`, and `BUILD_ENV_PRODUCTION`, respectively.

Usage example (disabling IAP for internal testing):
```
func purchaseItem(_ item: Item) -> PurchaseResult {
#if !BUILD_ENV_PRODUCTION
  return .purchased
#else
  // do some IAP real logic
#endif
}
```
This approach is pretty safe, because the test code is cut out from the release build.

## Cocoapods

When new build configurations added, it's needed to specify for CocoaPods configs that should be built in `debug`. Otherwise, during debugging, `lldb` will complain about missing characters due to code compiled with optimizations. And debugging itself will be difficult.

It is done in the `Podfile` - specified which build configurations refer to the debug configuration.