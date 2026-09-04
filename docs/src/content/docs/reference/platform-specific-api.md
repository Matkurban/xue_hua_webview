---
title: Platform API
description: Platform-specific public APIs exposed by xue_hua_webview and its registered platform packages.
---

Access platform APIs through creation params and the `platform` field:

```dart
final controller = WebViewController();

if (controller.platform is WindowsWebViewController) {
  await (controller.platform as WindowsWebViewController).openDevTools();
}
```

## Android

Package: `xue_hua_webview_android`.

Main types: `AndroidWebViewController`, `AndroidWebViewWidget`, `AndroidNavigationDelegate`, `AndroidWebViewCookieManager`, `AndroidLoadFileParams`, `AndroidJavaScriptChannelParams`, `AndroidWebViewPermissionRequest`, `AndroidWebViewPermissionResourceType`, `AndroidSslAuthError`, `AndroidWebResourceError`, `AndroidUrlChange`, `FileSelectorParams`.

Important APIs: debugging, file/content access, media gesture, text zoom, wide viewport, geolocation, built-in file selector plus optional `setOnShowFileSelector`, custom fullscreen widget, console, JS dialogs, scrollbars, overscroll, mixed content, WebAuthn/passkeys, Payment Request, window insets.

## iOS/macOS

Package: `xue_hua_webview_wkwebview`.

Main types: `WebKitWebViewController`, `WebKitWebViewWidget`, `WebKitNavigationDelegate`, `WebKitWebViewCookieManager`, `WebKitLoadFileParams`, `WebKitJavaScriptChannelParams`, `WebKitWebViewPermissionRequest`, `WebKitSslAuthError`, `WebKitWebResourceError`.

Important APIs: inline media, media gesture, App-Bound Domains, JavaScript popup policy, back/forward gestures, link preview, inspectable, WebKit local file read access, permission prompt, macOS `runOpenPanel` file inputs.

## Windows

Package: `xue_hua_webview_windows`.

Main types: `WindowsWebViewController`, `WindowsWebViewWidget`, `WindowsNavigationDelegate`, `WindowsWebViewCookieManager`, `WindowsWebViewCookie`, `WindowsPlatformSslAuthError`, `WindowsWebResourceRequest`, `WindowsWebResourceResponse`, `WindowsWebResourceError`.

Important APIs: `initializeEnvironment`, `getWebViewVersion`, `openDevTools`, `suspend`, `resume`, `setPopupWindowPolicy`, `setZoomFactor`, `setCacheDisabled`, Windows-specific deterministic `dispose`, full cookie set/query/delete. Removing the widget does not dispose a reusable controller; call `dispose` only when its owner will never use it again.

## Linux

Package: `xue_hua_webview_linux`.

Main types: `LinuxWebViewController`, `LinuxWebViewWidget`, `LinuxNavigationDelegate`, `LinuxWebViewCookieManager`, `LinuxWebResourceRequest`, `LinuxWebResourceResponse`, `LinuxWebResourceError`, `LinuxPlatformWebViewPermissionRequest`, `LinuxPlatformSslAuthError`.

Important APIs: WebKitGTK developer extras, Inspector, JS popup, media settings, page cache, file URL access, font size, zoom factor, and the pre-existing Linux-specific `dispose()` for optional early release. Normal cleanup is automatic through its finalizer; no common controller lifecycle API is added.

## Web

Package: `xue_hua_webview_web`.

Main types: `WebWebViewController`, `WebWebViewWidget`, `WebNavigationDelegate`, `WebWebViewCookieManager`, `WebWebResourceRequest`, `WebWebResourceResponse`, `WebWebViewPermissionRequest`, `WebPlatformSslAuthError`, `HttpRequestFactory`, `ContentType`.

Important APIs: `setIFrameAttribute`, `setIFrameAllow`, `setIFrameSandbox`, `setIFrameReferrerPolicy`, fetch-backed request.
