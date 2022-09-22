# ``Reteno``

The Reteno iOS SDK for Mobile Customer Engagement and Analytics solutions

## Overview

Reteno is a ligtweight iOS SDK that helps mobile teams integrate Reteno into their mobile apps. The server-side library make it easy to call the Reteno API.

##### Supports:

- Swift projects
- iOS 12.0 or later

##### Installation

- CocoaPods

##### Licence

Reteno iOS SDK is released under the MIT license. See LICENSE for details.


## Setting up the SDK

Follow our setup guide to integrate the Reteno SDK with your app.

#### Step 1: Add a Notification Service Extension

The `NotificationServiceExtension` allows your iOS application to receive rich notifications with image. It's also required for Reteno's analytics features.

**1.1**  In Xcode Select `File > New > Target...`

**1.2**  Select `Notification Service Extension` then press `Next`.

<p align="center">
  <img src="../../Reteno/Reteno.docc/Resources/create_notification_service_extension.png" width = "50%"/>
</p>

**1.3**  Enter the product name as `NotificationServiceExtension` and press `Finish`.

Do not select `Activate` on the dialog that is shown after selecting `Finish`.

<p align="center">
  <img src="../../Reteno/Reteno.docc/Resources/choose_options_for_extension.png" width = "50%"/>
</p>

**1.4**  Press `Cancel` on the Activate scheme prompt.

By canceling, you are keeping Xcode debugging your app, instead of the extension you just created.

If you activated by accident, you can switch back to debug your app within Xcode (next to the play button).

**1.5**  In the project navigator, select project directory and select the `NotificationServiceExtension` target in the targets list.

Check that the Deployment Target is set to the same value as your Main Application Target. Note that iOS versions under 10 will not be able to get Rich Media.

<p align="center">
  <img src="../../Reteno/Reteno.docc/Resources/configure_target.png" width = "50%"/>
</p>

**1.6**  In the project navigator, select the `NotificationServiceExtension` folder and open the `NotificationService.swift` and replace the whole file's contents with the following code. Ignore any build errors at this point. We will import Reteno module which will resolve any errors.

```swift
import UserNotifications
import Reteno

class NotificationService: RetenoNotificationServiceExtension {}
```
More about Notification Service Extension [Modifying Content in Newly Delivered Notifications](https://developer.apple.com/documentation/usernotifications/modifying_content_in_newly_delivered_notifications)

#### Step 2: Install the SDK

**2.1**  If you don't already have CocoaPods installed and a Podfile in your project, run the following script in Terminal
`sudo gem install cocoapods`

**2.2**  Run `pod init` from the terminal in your project directory.

**2.3**  Open the newly created `Podfile` with your favorite code editor.

**2.4**  Add the `Reteno` dependency under your project name target as well as
`NotificationServiceExtension` target like below.

```swift
platform :ios, '14.0'

target 'RetenoExample' do
  use_frameworks!

  pod 'Reteno'
  
  target 'NotificationServiceExtension' do
    use_frameworks!

    pod 'Reteno'

  end

end
```
**2.5**  Run the following commands in your terminal in your project directory `pod install`

**2.6**  Open the newly created `<project-name>.xcworkspace` file.

#### Step 3: Import Reteno into your App Delegate

##### Method 1: Storyboard

If using the Storyboard, navigate to your AppDelegate file and add the `Reteno` initialization code to `didFinishLaunchingWithOptions` method.
Make sure to import the `Reteno` module `import Reteno`

```swift
import UIKit
import Reteno

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Reteno initialization
        Reteno.start()
      
        // Register for receiving push notifications
        // registerForRemoteNotifications will show the native iOS notification permission prompt
        // Provide UNAuthorizationOptions or use default
        Reteno.userNotificationService.registerForRemoteNotifications(with: [.sound, .alert, .badge], application: application)

        return true
    }
  
    // Remaining contents of your AppDelegate Class...
}
```

##### Method 2: SwiftUI

If using SwiftUI, update your main 'APP_NAME'App.swift file and use the code below. Make sure to replace 'YOURAPP_NAME' with your app name.

```swift
import SwiftUI
import Reteno

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Reteno initialization
        Reteno.start()

        // Register for receiving push notifications
        // registerForRemoteNotifications will show the native iOS notification permission prompt
        // Provide UNAuthorizationOptions or use default
        Reteno.userNotificationService.registerForRemoteNotifications(with: [.sound, .alert, .badge], application: application)

        return true
    }

}
```
```swift
import SwiftUI
import Reteno

@main
struct YOURAPP_NAME: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

If you want to add custom behaviour in `UNUserNotificationCenterDelegate` methods provide your implementation in the appropriate closure:

```swift
Reteno.userNotificationService.willPresentNotificationHandler = { notification in
    // The closure will be called only if the application is in the foreground. 
    // You can choose to have the notification presented as a sound, badge, alert and/or in the notification list.
    // This decision should be based on whether the information in the notification is otherwise visible to the user.

    let authOptions: UNNotificationPresentationOptions
    if #available(iOS 14.0, *) {
        authOptions = [.badge, .sound, .banner]
    } else {
        authOptions = [.badge, .sound, .alert]
    }
    return authOptions
}
```

```swift
Reteno.userNotificationService.didReceiveNotificationResponseHandler = { notification in
    // Add your code here.
    // The closure will be called when the user responded to the notification by opening the application, 
    // dismissing the notification or choosing a UNNotificationAction.
}
```
Do it in the App Delegate `didFinishLaunchingWithOptions` method after configuring Reteno SDK.

#### Step 4: Add App Groups

**4.1**  In your Main app target got to **"Signing & Capabilities"** > **"All"**

**4.2**  Click **"+ Capability"** if you do not have App Groups in your app yet.

<p align="center">
  <img src="../../Reteno/Reteno.docc/Resources/add_group_main_target.png" width = "50%"/>
</p>

**4.3**  Select App Groups.

<p align="center">
  <img src="../../Reteno/Reteno.docc/Resources/app_groups_capability.png" width = "50%"/>
</p>

**4.4**  Under App Groups click the **"+"** button.

**4.5**  Fill the **"App Groups"** container as `group.{bundle_id}.reteno-local-storage` where `bundle_id` is the same as **"Bundle Identifier"** off your app (in the main target) and press `OK`.

**4.6**  In the `NotificationServiceExtension` target and repeat steps **4.2** - **4.5** for extension target

<p align="center">
  <img src="../../Reteno/Reteno.docc/Resources/add_group_in_extension.png" width = "50%"/>
</p>

Note that group name structure should be `group.{bundle_id}.reteno-local-storage` where `bundle_id` is the same as your **Main App target** "Bundle Identifier". **Do Not Include** NotificationServiceExtension.

For more information visit [Configuring App Groups](https://developer.apple.com/documentation/xcode/configuring-app-groups)

#### Step 5: Run your App and send yourself a notification

Run your app on a physical iOS device to make sure it builds correctly. Note that the iOS Simulator does not support receiving remote push notifications.
You should be prompted to subscribe to push notifications.
