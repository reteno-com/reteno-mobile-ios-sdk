# Getting started with Reteno SDK for iOS

The Reteno iOS SDK for Mobile Customer Engagement and Analytics solutions

[Documentation](https://docs.reteno.com/reference/ios-sdk)

## Overview

`Reteno` is a lightweight SDK for iOS that helps mobile teams integrate Reteno into their mobile apps. The server-side library makes it easy to call the `Reteno API`.

##### The SDK supports:

- Swift projects
- iOS 12.0 or later

##### To get started with the  Reteno SDK:

1. Download and install SDK via **CocoaPods** or **Swift Package Manager**.

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Reteno into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'Reteno', '2.0.12'
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding Reteno as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/reteno-com/reteno-mobile-ios-sdk.git", .upToNextMajor(from: "2.0.12"))
]
```

2. Configure the **Reteno SDK for iOS**. See the [installation guide](https://docs.reteno.com/reference/ios#setting-up-the-sdk).

##### License

`Reteno iOS SDK` is released under the MIT license. See [LICENSE](https://github.com/reteno-com/reteno-mobile-ios-sdk/blob/main/LICENSE) for details.
