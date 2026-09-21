---
name: xue_hua_webview-setup
description: >-
  Use when adding xue_hua_webview, creating WebViewWidget or HeadlessWebView,
  configuring OS permissions, file inputs, or custom URL schemes. Ensures the
  federated plugin is set up with the correct controller, widget, and host-app
  manifest entries.
---

# xue_hua_webview setup

## Guidelines

* Depend on `xue_hua_webview`. Do not depend on `xue_hua_webview_platform_interface` in app code.
* Import `package:xue_hua_webview/xue_hua_webview.dart`. Add a platform package as a **direct** dependency only when casting `controller.platform`.
* Always create a `WebViewController` first, then pass it to `WebViewWidget(controller: controller)`.
* One `WebViewController` may be attached to only one `WebViewWidget` at a time.
* Removing `WebViewWidget` from the tree does **not** call `dispose()`. Call `controller.dispose()` only when that controller will never be reused.
* Call `setJavaScriptMode(JavaScriptMode.unrestricted)` before any JavaScript API if the page needs JS. The default is platform-dependent; do not assume JS is on.
* For `HeadlessWebView`, call `await headless.run()` before `loadRequest`. Check `isRunning` if needed. Call `headless.dispose()` when finished.
* Keep the controller in `State` (create it in `initState`, not in `build`).
* Do not introduce Riverpod, Bloc, Provider, or signals for this plugin.
* On Android, iOS, and macOS, navigations to custom schemes (`bilibili://`, `weixin://`, `intent://`, `mailto:`, `tel:`) open the matching system app. `onNavigationRequest` still receives the URL; return `NavigationDecision.prevent` to block the handoff. Windows, Linux, and Web do not implement this handoff.

## Install

```yaml
dependencies:
  xue_hua_webview: ^1.1.1
```

```sh
flutter pub get
```

Install these agent skills in a consuming app with:

```sh
dart run skills@ get
```

When using Android, WebKit, Windows, Linux, or Web extra APIs, add that platform package explicitly, then import it:

```yaml
dependencies:
  xue_hua_webview: ^1.1.1
  xue_hua_webview_android: ^1.1.0
  xue_hua_webview_wkwebview: ^1.1.0
```

## Widget setup

```dart
import 'package:flutter/material.dart';
import 'package:xue_hua_webview/xue_hua_webview.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({super.key});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}
```

## Headless setup

```dart
final HeadlessWebView headless = HeadlessWebView();
await headless.controller.setJavaScriptMode(JavaScriptMode.unrestricted);
await headless.run();
await headless.controller.loadRequest(Uri.parse('https://example.com'));
final JavaScriptAsyncResult result = await headless.controller
    .runJavaScriptAsync('return await Promise.resolve(1 + 1);');
await headless.dispose();
```

## File inputs

`<input type="file">` works without a Dart callback:

* Android: built-in Photo Picker for image/video, `ACTION_GET_CONTENT` for other MIME types, camera when `capture` is set. Optional override: `AndroidWebViewController.setOnShowFileSelector`.
* iOS: WKWebView system picker.
* macOS: `NSOpenPanel` via `WKUIDelegate.runOpenPanel`.
* Windows, Linux, Web: engine or browser dialog.

Do **not** add `READ_MEDIA_*` or `READ_EXTERNAL_STORAGE` unless a custom Android file selector reads MediaStore directly. Photo Picker and SAF do not need them.

## Host-app permissions

### Android `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### iOS `Info.plist`

Missing camera or photo-library usage strings can crash when a page uses `capture` or an older photo picker.

```xml
<key>NSCameraUsageDescription</key>
<string>This app allows pages to use the camera after you approve the request.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app allows pages to use the microphone after you approve the request.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app allows pages to pick photos or videos after you approve the request.</string>
```

### macOS entitlements

Sandboxed apps that show the file dialog need:

```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

## Permission requests from web content

Always answer with `grant()` or `deny()`. Most platforms also need the OS permission declared above.

```dart
final WebViewController controller = WebViewController(
  onPermissionRequest: (WebViewPermissionRequest request) async {
    if (request.types.contains(WebViewPermissionResourceType.camera) ||
        request.types.contains(WebViewPermissionResourceType.microphone)) {
      await request.grant();
    } else {
      await request.deny();
    }
  },
);
```

## Anti-patterns

* Do not construct `WebViewController` inside `build`.
* Do not call `loadRequest` with a `Uri` that has an empty scheme.
* Do not skip `run()` on `HeadlessWebView`.
* Do not `implements` platform interface classes; platform implementations `extends` them.
* Do not treat widget unmount as controller disposal.
