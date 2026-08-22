---
title: 平台专属接口
description: xue_hua_webview 及注册平台包暴露的专属 API。
---

平台 API 通过 creation params 和 `platform` 字段访问：

```dart
final controller = WebViewController();

if (controller.platform is WindowsWebViewController) {
  await (controller.platform as WindowsWebViewController).openDevTools();
}
```

## Android

包：`xue_hua_webview_android`。

主要类型：`AndroidWebViewController`、`AndroidWebViewWidget`、`AndroidNavigationDelegate`、`AndroidWebViewCookieManager`、`AndroidLoadFileParams`、`AndroidJavaScriptChannelParams`、`AndroidWebViewPermissionRequest`、`AndroidWebViewPermissionResourceType`、`AndroidSslAuthError`、`AndroidWebResourceError`、`AndroidUrlChange`、`FileSelectorParams`。

重要 API：debugging、file/content access、media gesture、text zoom、wide viewport、geolocation、file selector、custom fullscreen widget、console、JS dialogs、scrollbars、overscroll、mixed content、WebAuthn/Passkey、Payment Request、window insets。

## iOS/macOS

包：`xue_hua_webview_wkwebview`。

主要类型：`WebKitWebViewController`、`WebKitWebViewWidget`、`WebKitNavigationDelegate`、`WebKitWebViewCookieManager`、`WebKitLoadFileParams`、`WebKitJavaScriptChannelParams`、`WebKitWebViewPermissionRequest`、`WebKitSslAuthError`、`WebKitWebResourceError`。

重要 API：inline media、media gesture、App-Bound Domains、JavaScript popup policy、back/forward gestures、link preview、inspectable、WebKit 本地文件 read access、permission prompt。

## Windows

包：`xue_hua_webview_windows`。

主要类型：`WindowsWebViewController`、`WindowsWebViewWidget`、`WindowsNavigationDelegate`、`WindowsWebViewCookieManager`、`WindowsWebViewCookie`、`WindowsPlatformSslAuthError`、`WindowsWebResourceRequest`、`WindowsWebResourceResponse`、`WindowsWebResourceError`。

重要 API：`initializeEnvironment`、`getWebViewVersion`、`openDevTools`、`suspend`、`resume`、`setPopupWindowPolicy`、`setZoomFactor`、`setCacheDisabled`、Windows 专属的确定性 `dispose`、完整 cookie 设置/查询/删除。移除组件不会销毁仍可复用的 controller；仅在其所有者确认不再使用时调用 `dispose`。

## Linux

包：`xue_hua_webview_linux`。

主要类型：`LinuxWebViewController`、`LinuxWebViewWidget`、`LinuxNavigationDelegate`、`LinuxWebViewCookieManager`、`LinuxWebResourceRequest`、`LinuxWebResourceResponse`、`LinuxWebResourceError`、`LinuxPlatformWebViewPermissionRequest`、`LinuxPlatformSslAuthError`。

重要 API：WebKitGTK developer extras、Inspector、JS popup、media settings、page cache、file URL access、font size、zoom factor，以及可选提前释放资源的既有 Linux 专属 `dispose()`。正常生命周期由 finalizer 自动清理，没有给公共 controller 增加生命周期 API。

## Web

包：`xue_hua_webview_web`。

主要类型：`WebWebViewController`、`WebWebViewWidget`、`WebNavigationDelegate`、`WebWebViewCookieManager`、`WebWebResourceRequest`、`WebWebResourceResponse`、`WebWebViewPermissionRequest`、`WebPlatformSslAuthError`、`HttpRequestFactory`、`ContentType`。

重要 API：`setIFrameAttribute`、`setIFrameAllow`、`setIFrameSandbox`、`setIFrameReferrerPolicy`、fetch-backed request。
