---
title: Android
description: Android WebView 实现、API 和限制。
---

Android 由 `xue_hua_webview_android ^1.1.0` 提供，`xue_hua_webview` 将它注册为默认 Android 实现。

| 项 | 值 |
| --- | --- |
| 平台包 | `xue_hua_webview_android` |
| Controller | `AndroidWebViewController` |
| Widget | `AndroidWebViewWidget` |
| Delegate | `AndroidNavigationDelegate` |
| Cookie manager | `AndroidWebViewCookieManager` |
| 引擎 | Android `WebView` |
| 最低要求 | API 24+ |

## 主要 API

| API | 作用 |
| --- | --- |
| `AndroidWebViewController.enableDebugging` | 全局启用 WebView 调试。 |
| `setAllowFileAccess` | 控制 file URL 访问。 |
| `setMediaPlaybackRequiresUserGesture` | 控制媒体自动播放。 |
| `setTextZoom` | 设置文字缩放百分比。 |
| `setUseWideViewPort` | 启用 viewport meta/wide viewport。 |
| `setAllowContentAccess` | 控制 `content://` 访问。 |
| `setGeolocationEnabled` | 启用定位。 |
| `setOnShowFileSelector` | 可选覆盖 `<input type="file">`。未设置时走内置选择器。 |
| `setGeolocationPermissionsPromptCallbacks` | 处理 Geolocation API 提示。 |
| `setCustomWidgetCallbacks` | 处理视频等全屏 custom view。 |
| `setMixedContentMode` | 控制 HTTPS 页面加载 HTTP 内容。 |
| `isWebViewFeatureSupported` | 查询 AndroidX WebView 功能。 |
| `setWebAuthenticationSupport` | 为已关联应用或具备资格的浏览器应用启用 WebAuthn。 |
| `setPaymentRequestEnabled` | 开启 Payment Request API。 |
| `setInsetsForWebContentToIgnore` | 控制传给网页的 window insets。 |

## Mixed Content

```dart
await (controller.platform as AndroidWebViewController)
    .setMixedContentMode(MixedContentMode.neverAllow);
```

`neverAllow` 是生产环境推荐值。

## WebAuthn 与 Passkey

Android WebView 默认关闭 WebAuthn。启用前必须先检查当前设备与
WebView 版本是否支持：

```dart
final android = controller.platform as AndroidWebViewController;

if (await android.isWebViewFeatureSupported(
  WebViewFeatureType.webAuthentication,
)) {
  await android.setWebAuthenticationSupport(
    WebAuthenticationSupport.forApp,
  );
}
```

`forApp` 是普通应用应使用的模式，并且必须通过
[Digital Asset Links](https://developers.google.com/digital-asset-links)
关联应用与 relying-party 域名。`forBrowser` 只适用于经凭据提供方
批准、可代表第三方站点请求凭据的特权浏览器应用，普通应用不应使用它绕过
域名关联。`none` 用于关闭功能，也是 AndroidX WebKit 的默认值。

## 文件选择

未设置 `setOnShowFileSelector` 时，`<input type="file">` 使用内置选择器：

- 图片或视频 accept 类型走 Android Photo Picker（无需存储权限）。
- 其他 MIME 走 `ACTION_GET_CONTENT`。
- `capture` 在获得运行时 `CAMERA` 后打开相机。
- 多选遵循 `FileSelectorMode.openMultiple`。
- 取消、权限拒绝和失败都会对 `filePathCallback` 传入 `null`。

可选覆盖：

```dart
await (controller.platform as AndroidWebViewController)
    .setOnShowFileSelector((FileSelectorParams params) async {
  return <String>['content://media/picker/0'];
});
```

返回 `content://...` 等文件 URI 字符串。空列表表示取消。
`FileSelectorMode` 包括 `open`、`openMultiple` 和 `save`。

相机直连需在宿主 manifest 声明 `CAMERA`。除非自定义回调直接读 MediaStore，否则不要添加 `READ_MEDIA_*`。

## 打开外部 App

页面里的自定义 scheme（`bilibili://`、`weixin://`、`intent://`、`mailto:`、
`tel:`）会用 `ACTION_VIEW` 交给系统，而不会在 WebView 中加载。Chrome
`intent://` 使用 `Intent.parseUri`；若 App 未安装且带有
`S.browser_fallback_url` 的 http/https 地址，则回落到 WebView 加载。
`startActivity` 不需要在 `<queries>` 里声明这些 scheme。未安装时静默失败。

`onNavigationRequest` 仍会收到该 URL。返回 `prevent` 可拦住拉起。

## Cookie 与 native 访问

`getCookies` 先按分号拆分，再只按每条 Cookie 的第一个等号拆分，因此能保留
值中的 `=` 和编码内容。非法百分号编码会按原文返回，不会让整次查询失败；结果
使用请求 URL 的 host 和 `/`。

Android native 代码可通过 `WebViewFlutterAndroidExternalApi` 的
`FlutterPluginBinding` 入口获取插件持有的 `WebView`；旧
`FlutterEngine` 重载保留但已弃用。binding 入口使用 engine plugin registry
实现，因此仍兼容 Flutter 3.35。

## 平台限制

- Android WebView `postUrl` 不支持 POST 自定义 headers。
- `grant()` WebView 权限不等于系统运行时权限，宿主应用仍需自己请求。
- Payment Request 取决于 AndroidX WebKit、系统 WebView/Chrome 版本和 manifest queries。
- WebAuthn 取决于 AndroidX WebKit、系统 WebView 版本和正确的应用-站点关联；
  未通过功能检查就调用设置接口可能产生不支持错误。
- Android 插件会根据宿主工程的 Android Gradle Plugin 选择 Kotlin 集成方式：
  AGP 8 及以下使用 Kotlin Gradle Plugin，AGP 9 及以上使用 Built-in Kotlin，
  从而兼容旧版 Flutter 工程并避免与新版 Android 构建冲突。
- `UserScript` document-start 在 WebView 91+ 使用
  `WebViewCompat.addDocumentStartJavaScript`；更早版本降级为 `onPageStarted`
  注入。`forMainFrameOnly` 在 Android 上是尽力而为。
- `runJavaScriptAsync` 通过内部 helper 通道回传结果；JS 异常写入
  `JavaScriptAsyncResult.error`。
- `WebViewStorageManager` 清理 HTTP cache 时会临时创建一个不上屏的 `WebView`。
- 无头 WebView 在创建 controller 时即实例化原生 `WebView`，`dispose()` 调用
  `WebView.destroy()`。
