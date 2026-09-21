---
name: xue_hua_webview-platform
description: >-
  Use when the user needs Android, iOS, macOS, Windows, Linux, or Web extra
  APIs on xue_hua_webview: AndroidWebViewController, WebKitWebViewController,
  WindowsWebViewController, LinuxWebViewController, WebWebViewController, or
  platform cookie/file/debug helpers. Do not use for the common
  WebViewController API.
---

# xue_hua_webview platform APIs

## Guidelines

* Use the common `WebViewController` API unless the feature exists only on one engine.
* Add the platform package as a **direct** pub dependency before importing it.
* Detect with `is`, then `as`. Never `as` without a type check.

```dart
import 'package:xue_hua_webview/xue_hua_webview.dart';
import 'package:xue_hua_webview_android/xue_hua_webview_android.dart';
import 'package:xue_hua_webview_wkwebview/xue_hua_webview_wkwebview.dart';

final WebViewController controller = WebViewController();

if (controller.platform is AndroidWebViewController) {
  final AndroidWebViewController android =
      controller.platform as AndroidWebViewController;
  await AndroidWebViewController.enableDebugging(true);
} else if (controller.platform is WebKitWebViewController) {
  final WebKitWebViewController webKit =
      controller.platform as WebKitWebViewController;
  await webKit.setInspectable(true);
}
```

Equivalent checks: `WebViewPlatform.instance is AndroidWebViewPlatform` / `WebKitWebViewPlatform`.

* Platform implementations `extends` interface classes. Never `implements PlatformWebViewController`.
* For creation-time options, build platform `CreationParams`, then `WebViewController.fromPlatformCreationParams(params)`.
* Do not document or call Pigeon-generated types (`android_webkit.g.dart`, `web_kit.g.dart`).
* Android file chooser: leave `setOnShowFileSelector` unset to use the built-in picker. A custom callback must return `content://` (or file) URI strings, or an empty list to cancel.
* Android `setWebAuthenticationSupport` / `setPaymentRequestEnabled`: call `isWebViewFeatureSupported` first; AndroidX throws if the installed WebView lacks the feature. WebAuthn is off by default.
* macOS `setInspectable` requires 13.3+; iOS 16.4+. Unsupported calls are logged and ignored.
* Web `setIFrameAttribute`: `id`, `src`, and `srcdoc` are reserved and throw `ArgumentError`. Empty or illegal attribute names throw `ArgumentError`.
* Windows `initializeEnvironment` must run before any WebView is created, and only once. Removing the widget does not dispose a reusable controller.

## References

* Android: [references/android.md](references/android.md)
* iOS/macOS WebKit: [references/webkit.md](references/webkit.md)
* Windows WebView2: [references/windows.md](references/windows.md)
* Linux WebKitGTK: [references/linux.md](references/linux.md)
* Web iframe: [references/web.md](references/web.md)
