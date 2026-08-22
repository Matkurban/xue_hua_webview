---
title: 迁移
description: 从 webview_flutter 或旧版 xue_hua_webview 迁移。
---

`xue_hua_webview` 的顶层 API 与 `webview_flutter` 的接口兼容。多数代码可以先替换 import，再按需处理平台差异。

## 从 webview_all 迁移

`1.0.0` 将本仓库中的全部包重命名。`WebViewController`、`WebViewWidget` 等公开 API 不变，只需改包名和 import。

| 旧包名 | 新包名 |
| --- | --- |
| `webview_all` | `xue_hua_webview` |
| `webview_platform_interface` | `xue_hua_webview_platform_interface` |
| `webview_all_android` | `xue_hua_webview_android` |
| `webview_all_wkwebview` | `xue_hua_webview_wkwebview` |
| `webview_all_web` | `xue_hua_webview_web` |
| `webview_all_windows` | `xue_hua_webview_windows` |
| `webview_all_linux` | `xue_hua_webview_linux` |

将：

```yaml
dependencies:
  webview_all: ^1.0.0
```

改为：

```yaml
dependencies:
  xue_hua_webview: ^1.0.0
```

以及：

```dart
import 'package:webview_all/webview_all.dart';
```

改为：

```dart
import 'package:xue_hua_webview/xue_hua_webview.dart';
```

## 从 webview_flutter 迁移

替换：

```dart
import 'package:webview_flutter/webview_flutter.dart';
```

为：

```dart
import 'package:xue_hua_webview/xue_hua_webview.dart';
```

通常可继续使用：

- `WebViewController`
- `WebViewWidget`
- `NavigationDelegate`
- `WebViewCookieManager`
- `NavigationDecision`
- `JavaScriptMode`
- `WebViewCookie`

## 平台 import

Android/iOS/macOS 使用仓库内的 fork 包。原先导入
`webview_flutter_android` 或 `webview_flutter_wkwebview` 的平台特性代码，
应改为：

```dart
import 'package:xue_hua_webview_android/xue_hua_webview_android.dart';
import 'package:xue_hua_webview_wkwebview/xue_hua_webview_wkwebview.dart';
```

```dart
import 'package:xue_hua_webview_windows/xue_hua_webview_windows.dart';
import 'package:xue_hua_webview_linux/xue_hua_webview_linux.dart';
import 'package:xue_hua_webview_web/xue_hua_webview_web.dart';
```

Linux 不要求修改应用 runner，可以将 `linux/runner/my_application.cc`
恢复为 Flutter 默认实现。已经手动添加的 `GtkOverlay` 仍然兼容，也可以保留。

## 迁移时重点检查

| 区域 | 需要确认 |
| --- | --- |
| JavaScript | Web 可直接控制同源内容，并通过消息桥控制插件管理的隔离 HTML；直接跨域 iframe URL 仍由浏览器隔离。 |
| Cookie | Web Cookie 读取要求当前宿主文档的精确 URL，写入不能指定外域。 |
| TLS | Web 无法暴露可恢复证书错误决策。 |
| macOS | 部分 UIKit 风格 WebKit 属性没有 macOS bridge。 |
| Linux | 需要 WebKitGTK 4.1；标准 Flutter runner 无需修改源码。 |
