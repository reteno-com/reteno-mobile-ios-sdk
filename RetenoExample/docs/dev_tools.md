# DevTools

## Overview

As auxiliary tools for development were used Yalantis' dev tools and they integrated via Cocoapods (private remote pods).

If it's needed to add some custom / specific / local dev tool to the project, it should be located in the `./DevTools/` directory and intergated to the project through the `Cocoapods` too (as local pods).

However, they are available only in the necessary environments (`Development`, `Staging`) and will not get into the AppStore (`Production` environment). This is implemented via `Podfile` in the `pod_dev_tools` function.

So, to add new utility, need to specify `podspec` for it (if it local custom pod), add it to the `pod_dev_tools` function in the `Podfile` and execute `pod install`.

## Usage

To use development tool in the project correctly, need to check on its existence in the build configuration.

For example:

```
// ...

#if canImport(BuildInfo)
import BuildInfo
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // rest of the code

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // ...

        #if canImport(BuildInfo)
        BuildInfo.shared.activate(with: window!)
        #endif

        // ...

        return true
    }
}
```