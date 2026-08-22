---
title: Migration
description: Move from webview_flutter or older xue_hua_webview versions.
---

`xue_hua_webview` keeps the public wrapper shape close to `webview_flutter`: a controller, a widget, a navigation delegate, and a cookie manager. Most app code can switch imports first, then add platform-specific casts only where needed.

## From webview_all

The `1.0.0` line renames every package in this repository. Public APIs such as `WebViewController` and `WebViewWidget` stay the same; only package names and import URIs change.

| Old package | New package |
| --- | --- |
| `webview_all` | `xue_hua_webview` |
| `webview_platform_interface` | `xue_hua_webview_platform_interface` |
| `webview_all_android` | `xue_hua_webview_android` |
| `webview_all_wkwebview` | `xue_hua_webview_wkwebview` |
| `webview_all_web` | `xue_hua_webview_web` |
| `webview_all_windows` | `xue_hua_webview_windows` |
| `webview_all_linux` | `xue_hua_webview_linux` |

Replace:

```yaml
dependencies:
  webview_all: ^1.0.0
```

with:

```yaml
dependencies:
  xue_hua_webview: ^1.0.0
```

And:

```dart
import 'package:webview_all/webview_all.dart';
```

with:

```dart
import 'package:xue_hua_webview/xue_hua_webview.dart';
```

## From webview_flutter

Replace:

```dart
import 'package:webview_flutter/webview_flutter.dart';
```

with:

```dart
import 'package:xue_hua_webview/xue_hua_webview.dart';
```

Keep existing code that uses:

- `WebViewController`
- `WebViewWidget`
- `NavigationDelegate`
- `WebViewCookieManager`
- `NavigationDecision`
- `JavaScriptMode`
- `WebViewCookie`

## Platform-Specific Imports

If your old code imported `webview_flutter_android` or
`webview_flutter_wkwebview`, replace those imports with `xue_hua_webview_android`
and `xue_hua_webview_wkwebview`. Android, iOS, and macOS use the forked
implementations in this repository.

```dart
import 'package:xue_hua_webview_windows/xue_hua_webview_windows.dart';
import 'package:xue_hua_webview_linux/xue_hua_webview_linux.dart';
import 'package:xue_hua_webview_web/xue_hua_webview_web.dart';
```

Linux does not require application runner changes. You may restore
`linux/runner/my_application.cc` to the Flutter default. An existing
`GtkOverlay` wrapper remains compatible and can also be kept.

## Behavioral Differences to Audit

Audit these areas during migration:

| Area | What to check |
| --- | --- |
| JavaScript | Web controls same-origin content directly and plugin-managed isolated HTML through a message bridge. Direct cross-origin iframe URLs remain browser-isolated. |
| Cookies | Web cookie reads require the exact current host-document URL; writes cannot target a foreign domain. Windows offers additional native metadata through `WindowsWebViewCookie`. |
| TLS | Web cannot expose recoverable TLS decisions. Native engines can report SSL auth callbacks when their engine exposes them. |
| macOS | Some UIKit-style WebKit properties have no macOS implementation. |
| Linux | WebKitGTK 4.1 is required; the standard Flutter runner needs no source changes. |
