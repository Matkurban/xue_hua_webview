---
title: Platform Setup
---

Most platforms work after adding `xue_hua_webview`. Some engines need app-level
permissions or runtime components.

## Android

Set the minimum SDK to at least API 24. Add platform permissions when web content requests protected resources:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

If your WebView needs Material-styled input controls, use a Material Components compatible Android theme in the app module.

For file chooser or media capture flows, implement `AndroidWebViewController.setOnShowFileSelector` and grant runtime Android permissions in the app before calling `request.grant()`.

## iOS

Set the deployment target to iOS 13.0 or newer. Add `Info.plist` keys for any resource that web content can request:

```xml
<key>NSCameraUsageDescription</key>
<string>This app allows pages to use the camera after you approve the request.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app allows pages to use the microphone after you approve the request.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app allows pages to request your current location.</string>
```

HTTPS pages load without extra App Transport Security (ATS) exceptions. Cleartext HTTP is blocked by ATS unless the host app adds an exception in `Info.plist` (for example `NSExceptionDomains` for a specific host). Do not enable `NSAllowsArbitraryLoads` unless you accept the security trade-off.

For App-Bound Domains, configure the domains in the host app and construct the controller with `WebKitWebViewControllerCreationParams(limitsNavigationsToAppBoundDomains: true)`.

## macOS

Set the deployment target to macOS 10.15 or newer. For network access in a sandboxed app, enable the outgoing network entitlement:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

macOS uses the same `xue_hua_webview_wkwebview` package as iOS, but not every UIKit-backed WebKit property has a macOS equivalent. See [iOS and macOS](/xue_hua_webview/platforms/ios-macos/) for the exact limits.

## Windows

Windows uses WebView2 and requires the Microsoft Edge WebView2 Runtime on the target machine. `WindowsWebViewController.getWebViewVersion()` can be used at startup to verify that the runtime is present:

```dart
final version = await WindowsWebViewController.getWebViewVersion();
if (version == null) {
  // Show an installer or a support message.
}
```

Applications that need a custom user data directory or a fixed browser executable should initialize the shared environment before creating controllers:

```dart
await WindowsWebViewController.initializeEnvironment(
  userDataPath: 'C:\\Users\\Public\\MyApp\\WebView2',
  additionalArguments: '--disable-features=msSmartScreenProtection',
);
```

## Linux

Install WebKitGTK 4.1 development/runtime packages for your distribution. On Ubuntu-style systems:

```sh
sudo apt-get install libwebkit2gtk-4.1-dev
```

The Linux implementation positions a native WebKitGTK widget above the Flutter
view. The plugin installs the required `GtkOverlay` before the standard Flutter
runner realizes its `FlView`; applications do not need to modify
`linux/runner/my_application.cc`.

## Web

The web implementation renders an HTML `iframe`. It cannot bypass browser security boundaries:

- It cannot load arbitrary local files from the user's machine.
- It cannot execute JavaScript in cross-origin iframe content.
- It cannot intercept browser TLS certificate decisions.
- Cookies are scoped to `document.cookie` for the host origin.

Use `loadHtmlString`, same-origin URLs, or a server endpoint that sets correct
CORS headers when you need JavaScript control or fetch-backed custom requests.
Fetch-backed HTML and strictly sandboxed `loadHtmlString` content use an
isolated message bridge; direct cross-origin iframe URLs remain inaccessible.
