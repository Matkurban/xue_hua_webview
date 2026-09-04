---
title: Installation
description: Add xue_hua_webview and prepare platform packages.
---

Add the app-facing package:

```yaml
dependencies:
  xue_hua_webview: ^1.1.0
```

Run:

```sh
flutter pub get
```

The main package registers platform implementations through Flutter's federated plugin mechanism:

```yaml
flutter:
  plugin:
    platforms:
      android:
        default_package: xue_hua_webview_android
      ios:
        default_package: xue_hua_webview_wkwebview
      macos:
        default_package: xue_hua_webview_wkwebview
      linux:
        default_package: xue_hua_webview_linux
      windows:
        default_package: xue_hua_webview_windows
      web:
        default_package: xue_hua_webview_web
```

## When to Add Platform Packages Directly

If your app only uses the common API, `xue_hua_webview` is enough.

If you cast to a platform implementation, add that package explicitly so the import is available to your app:

```yaml
dependencies:
  xue_hua_webview: ^1.1.0
  xue_hua_webview_windows: ^1.0.0
  xue_hua_webview_linux: ^1.0.0
  xue_hua_webview_web: ^1.0.0
  xue_hua_webview_android: ^1.1.0
  xue_hua_webview_wkwebview: ^1.1.0
```

Then import only the packages you need:

```dart
import 'package:xue_hua_webview/xue_hua_webview.dart';
import 'package:xue_hua_webview_windows/xue_hua_webview_windows.dart';
import 'package:xue_hua_webview_linux/xue_hua_webview_linux.dart';
import 'package:xue_hua_webview_web/xue_hua_webview_web.dart';
import 'package:xue_hua_webview_android/xue_hua_webview_android.dart';
import 'package:xue_hua_webview_wkwebview/xue_hua_webview_wkwebview.dart';
```

## Version Contract

The `1.1.0` release updates `xue_hua_webview`, `xue_hua_webview_android`, and
`xue_hua_webview_wkwebview`. The wrapper depends on
`xue_hua_webview_platform_interface ^1.0.0`, `xue_hua_webview_android ^1.1.0`, and
`xue_hua_webview_wkwebview ^1.1.0`.

Keep the platform packages on the same minor line as the wrapper unless you are intentionally testing a platform package in isolation.
