---
title: iOS 和 macOS
description: WKWebView 实现、WebKit API 和 Apple 平台差异。
---

iOS 和 macOS 由 `xue_hua_webview_wkwebview ^1.1.0` 提供。

| 项             | 值                           |
| -------------- | ---------------------------- |
| 平台包         | `xue_hua_webview_wkwebview`  |
| Controller     | `WebKitWebViewController`    |
| Widget         | `WebKitWebViewWidget`        |
| Delegate       | `WebKitNavigationDelegate`   |
| Cookie manager | `WebKitWebViewCookieManager` |
| 引擎           | `WKWebView`                  |
| 最低 iOS       | 13.0+                        |
| 最低 macOS     | 10.15+                       |

## 创建参数

```dart
final params = WebKitWebViewControllerCreationParams(
  allowsInlineMediaPlayback: true,
  mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
  limitsNavigationsToAppBoundDomains: false,
  javaScriptCanOpenWindowsAutomatically: true,
);
```

| 参数                                    | 作用                                                                             |
| --------------------------------------- | -------------------------------------------------------------------------------- |
| `mediaTypesRequiringUserAction`         | 哪些媒体类型需要用户手势。                                                       |
| `allowsInlineMediaPlayback`             | 允许 HTML5 视频内联播放。                                                        |
| `limitsNavigationsToAppBoundDomains`    | 在 iOS 14+、macOS 11+ 启用 App-Bound Domains；更早系统打印版本要求并保留默认值。 |
| `javaScriptCanOpenWindowsAutomatically` | 控制 JS 自动打开窗口。                                                           |

## 主要 API

| API                                        | 作用                                                                            |
| ------------------------------------------ | ------------------------------------------------------------------------------- |
| `setAllowsBackForwardNavigationGestures`   | 启用滑动前进/后退。                                                             |
| `setAllowsLinkPreview`                     | 控制 link preview。                                                             |
| `setOnCanGoBackChange`                     | 监听 `canGoBack` 变化。                                                         |
| `setInspectable`                           | 在 iOS 16.4+、macOS 13.3+ 启用 WebKit inspect；更早系统打印版本要求并安全忽略。 |
| `loadFileWithParams(WebKitLoadFileParams)` | 加载本地文件并设置可读范围。                                                    |

## 本地文件

```dart
await (controller.platform as WebKitWebViewController).loadFileWithParams(
  WebKitLoadFileParams(
    absoluteFilePath: '/Users/me/site/index.html',
    readAccessPath: '/Users/me/site',
  ),
);
```

`readAccessPath` 必须覆盖 HTML 引用的本地资源。

## 文件选择

iOS 的 `<input type="file">` 使用 WKWebView 内置选择器，没有
`WKUIDelegate.runOpenPanel` 钩子。`capture` 需要 `NSCameraUsageDescription`；
旧版相册流程还需要 `NSPhotoLibraryUsageDescription`。

macOS 通过 `webView(_:runOpenPanelWith:initiatedByFrame:completionHandler:)`
弹出 `NSOpenPanel`。多选和目录选择遵循 `WKOpenPanelParameters`。取消或没有窗口时
调用 `completionHandler(nil)`。沙盒应用需要
`com.apple.security.files.user-selected.read-only`。

macOS 新建 WKWebView 时，若 configuration 仍是系统默认应用名，会补上 Safari
兼容的 `applicationNameForUserAgent` 后缀（`Version/x.0 Safari/605.1.15`），
避免站点因裸 AppleWebKit UA 提示浏览器过旧。`setUserAgent` 仍可整串覆盖。

## 打开外部 App

页面里的自定义 scheme 会通过 `UIApplication` / `NSWorkspace` 打开，并
`cancel` 导航，避免 WKWebView 继续加载。`onNavigationRequest` 仍会收到该 URL；
返回 `prevent` 则只取消、不拉起 App。

插件不会写入 `LSApplicationQueriesSchemes`。直接 `open` 不需要该列表。只有宿主
自己调用 `canOpenURL` 时，才需要在 Info.plist 声明对应 scheme。

## WebAuthn 与 Passkey

`WKWebView` 会由 WebKit 自动处理 WebAuthn 请求，因此没有 Android 式的
启用开关，`xue_hua_webview` 也不增加这种伪统一接口。使用 Passkey 时，需要在
宿主应用的 Associated Domains 中配置 relying-party 域名，并按
[Apple Passkey 文档](https://developer.apple.com/documentation/authenticationservices/supporting-passkeys)
完成网站端关联。

Passkey 使用的 Associated Domains 与
`limitsNavigationsToAppBoundDomains` 不是同一项配置；启用 App-Bound
Domains 不会自动开通 Passkey。实际能力还取决于系统版本和已安装的
凭据提供方，网页应使用标准 `PublicKeyCredential` 能力检测，并在不可用时
提供其他登录方式。

`runJavaScriptAsync` 需要 iOS 14 / macOS 11。`addUserScript` 映射到
`WKUserScript`；`removeAllUserScripts` 会先清空再重放内部脚本。
`WebViewStorageManager` 使用 `WKWebsiteDataStore.default`，无需活 WebView。
无头 WKWebView 在创建 controller 时即存在，`dispose()` 释放 Dart 侧引用。

## macOS 差异

macOS 与 iOS 共用 Dart 包。macOS 端只使用公开原生 WebKit API，并在运行时判断系统版本；不会通过注入 JavaScript 模拟缺失的视图 API。

| 区域                | 限制                                                                                           |
| ------------------- | ---------------------------------------------------------------------------------------------- |
| 滚动位置与回调      | macOS `WKWebView` 没有公开内部 scroll view；调用会打印说明并安全忽略，读取返回 `Offset.zero`。 |
| 滚动条与 overscroll | macOS 没有对应公开 API；调用会打印说明并安全忽略。                                             |
| 背景色              | macOS 12+ 使用原生 `underPageBackgroundColor`；更早系统打印版本要求并安全忽略。                |
| 缩放                | 使用原生 `allowsMagnification`，不使用 JavaScript 兜底。                                       |
| inspect             | 需要 macOS 13.3+；更早系统打印版本要求并安全忽略。                                             |
| link preview        | 取决于系统支持。                                                                               |

这些兼容逻辑由 `xue_hua_webview_wkwebview` 子插件负责，主 `xue_hua_webview` Controller 不再包含 macOS 特判。

## Engine 关闭

子插件会在 iOS application termination 或 Flutter engine detach 时进行幂等清理：
停止向 Dart 发消息，并移除 Pigeon handler 和 instance；生命周期回调重复到达也
不会出错。scene disconnect 不会拆除仍在运行的 engine，因为 `FlutterSceneDelegate`
可能在 binary messenger 仍存活时转发 disconnect。macOS 继续使用 Flutter 的
engine detach 回调。

当 Flutter engine 提供公开 scene 协议时，插件会自动注册 scene 生命周期。
iOS 原生 `WKWebView` 访问入口也支持传入 `FlutterPluginRegistrar`：可用时使用
Flutter 官方 registrar 查询，较早的受支持 Flutter 版本使用按 engine 隔离的兼容
查询，无需修改宿主应用。
