---
title: Compatibility
description: Version alignment, dependency baseline, and maintenance rules.
---

## Current Baseline

| Package | Version |
| --- | --- |
| `xue_hua_webview` | `1.0.1` |
| `xue_hua_webview_windows` | `1.0.1` |
| `xue_hua_webview_linux` | `1.0.1` |
| `xue_hua_webview_web` | `1.0.1` |
| `xue_hua_webview_platform_interface` | `1.0.1` |
| `xue_hua_webview_android` | `1.0.1` |
| `xue_hua_webview_wkwebview` | `1.0.1` |
| Flutter SDK | `>=3.35.0` |
| Dart SDK | `^3.9.0` |

## Platform Baseline

| Platform | Support | Implementation |
|-------------|--------------|--------------|
|Android|API 24+|[WebView](https://developer.android.com/reference/android/webkit/WebView)|
|iOS|13.0+|[WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)|
|macOS|10.15+|[WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)|
|Windows|Win10 1809+|[WebView2](https://developer.microsoft.com/microsoft-edge/webview2)|
|Linux|webkit2gtk-4.1|[WebKitGTK](https://webkitgtk.org)|
|Web|Any|[js-interop](https://dart.dev/interop/js-interop)|

## Maintenance Rules

When adding or aligning APIs (including upgrades of `xue_hua_webview_platform_interface`),
follow the landing order on [Contributing](/xue_hua_webview/release/contributing/#adding-an-api):
implement every platform explicitly, prefer a real native implementation, throw
`UnsupportedError` when the engine cannot provide the feature, and use no-op only
for registration-style APIs already guarded by capability checks. Update the
capability matrix and platform API docs, then run format, analyze, tests, and
publish dry-run before release.

## Release Order

Publish child platform packages first, then publish the main package after pub.dev can resolve them:

1. `xue_hua_webview_platform_interface`
2. `xue_hua_webview_android`
3. `xue_hua_webview_wkwebview`
4. `xue_hua_webview_windows`
5. `xue_hua_webview_linux`
6. `xue_hua_webview_web`
7. `xue_hua_webview`
