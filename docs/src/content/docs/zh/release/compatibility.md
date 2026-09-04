---
title: 兼容性
description: 版本基线、依赖基线和维护规则。
---

## 当前基线

| 包 | 版本 |
| --- | --- |
| `xue_hua_webview` | `1.1.0` |
| `xue_hua_webview_windows` | `1.0.2` |
| `xue_hua_webview_linux` | `1.0.1` |
| `xue_hua_webview_web` | `1.0.1` |
| `xue_hua_webview_platform_interface` | `1.0.1` |
| `xue_hua_webview_android` | `1.1.0` |
| `xue_hua_webview_wkwebview` | `1.1.0` |
| Flutter SDK | `>=3.35.0` |
| Dart SDK | `^3.9.0` |

## 平台基线

|     系统     | **支持情况** | **技术实现** |
|-------------|--------------|--------------|
|Android|API 24+|[WebView](https://developer.android.com/reference/android/webkit/WebView)|
|iOS|13.0+|[WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)|
|macOS|10.15+|[WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)|
|Windows|Win10 1809+|[WebView2](https://developer.microsoft.com/microsoft-edge/webview2)|
|Linux|webkit2gtk-4.1|[WebKitGTK](https://webkitgtk.org)|
|Web|Any|[js-interop](https://dart.dev/interop/js-interop)|

## 维护规则

新增或对齐 API（包括升级 `xue_hua_webview_platform_interface`）时，按
[贡献与规范](/xue_hua_webview/zh/release/contributing/#新增-api-落地顺序)
落地：各平台显式实现，引擎支持时优先真实 native，做不到抛 `UnsupportedError`，
只有已有能力检查保护的注册型 API 才允许 no-op。同步更新能力矩阵和平台 API
文档，发布前跑 format、analyze、tests 和 publish dry-run。

## 发布顺序

先发布各平台的子包，pub.dev 能解析后再发布主包：

1. `xue_hua_webview_platform_interface`
2. `xue_hua_webview_android`
3. `xue_hua_webview_wkwebview`
4. `xue_hua_webview_windows`
5. `xue_hua_webview_linux`
6. `xue_hua_webview_web`
7. `xue_hua_webview`
