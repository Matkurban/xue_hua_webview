---
title: 安装
description: 添加 xue_hua_webview，并在需要时显式依赖平台包。
---

添加主包：

```yaml
dependencies:
  xue_hua_webview: ^1.1.0
```

执行：

```sh
flutter pub get
```

## 显式添加平台包

如果只使用通用 API，只依赖 `xue_hua_webview` 即可。

如果要使用某个平台的专属 webview 接口，请显式添加对应包。例如：

```yaml
dependencies:
  xue_hua_webview: ^1.1.0
  xue_hua_webview_windows: ^1.0.3
  xue_hua_webview_linux: ^1.0.2
  xue_hua_webview_web: ^1.0.2
  xue_hua_webview_android: ^1.1.0
  xue_hua_webview_wkwebview: ^1.1.0
```

然后按需导入：

```dart
import 'package:xue_hua_webview/xue_hua_webview.dart';
import 'package:xue_hua_webview_windows/xue_hua_webview_windows.dart';
import 'package:xue_hua_webview_linux/xue_hua_webview_linux.dart';
import 'package:xue_hua_webview_web/xue_hua_webview_web.dart';
import 'package:xue_hua_webview_android/xue_hua_webview_android.dart';
import 'package:xue_hua_webview_wkwebview/xue_hua_webview_wkwebview.dart';
```
