---
name: xue_hua_webview-api
description: >-
  Use when calling xue_hua_webview app-facing APIs: WebViewController,
  WebViewWidget, NavigationDelegate, SslAuthError, WebViewCookieManager,
  WebViewStorageManager, HeadlessWebView, WebViewPermissionRequest, and
  exported types. Read the matching references file before generating code.
---

# xue_hua_webview API

## Guidelines

* Generate only APIs that exist on the app-facing types. Do not invent methods from `webview_flutter` that this package does not export.
* Import `package:xue_hua_webview/xue_hua_webview.dart`.
* `loadRequest` requires a `Uri` with a non-empty scheme or it throws `ArgumentError`.
* Default HTTP method is `LoadRequestMethod.get`. `LoadRequestMethod` has only `get` and `post`.
* Android does **not** apply POST headers on `loadRequest`. iOS, macOS, Windows, Linux do. Web POST/headers are limited by CORS/fetch.
* `loadFile` is unsupported on Web. `loadFlutterAsset` and `loadHtmlString` work on every platform.
* macOS: `scrollTo`, `scrollBy`, `getScrollPosition`, scroll callbacks, and scrollbar visibility log and no-op (scroll read returns zero). Background color requires macOS 12+.
* Web: `setUserAgent` with a non-null value is ignored (logged). History, reload, cache, and storage are limited as documented in [references/webview_controller.md](references/webview_controller.md).
* `onSslAuthError`: the app **must** call `SslAuthError.cancel()` or `proceed()`. Use `cancel()` in production.
* `onPermissionRequest`: the app **must** call `grant()` or `deny()`.
* `onHttpAuthRequest`: call `request.onProceed(WebViewCredential(...))` or `request.onCancel()`.
* `WebViewStorageManager.removeData` clears process-wide website data and does not need a mounted WebView. Web only clears the host origin.
* Cookie `path` must be a legal RFC6265bis path. Android/WebKit/Linux/Windows throw `ArgumentError` for an illegal path. `setCookie` is a no-op on iOS below 11.

## Read before coding

* Controller, loading, history, view state, dispose: [references/webview_controller.md](references/webview_controller.md)
* Widget: [references/webview_widget.md](references/webview_widget.md)
* Navigation, SSL, HTTP auth, resource errors: [references/navigation_delegate.md](references/navigation_delegate.md)
* Cookies and storage: [references/cookie_and_storage.md](references/cookie_and_storage.md)
* Headless: [references/headless_webview.md](references/headless_webview.md)
* Exported enums, classes, typedefs: [references/types.md](references/types.md)

## Minimal load

```dart
import 'package:xue_hua_webview/xue_hua_webview.dart';

final WebViewController controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..loadRequest(Uri.parse('https://flutter.dev'));

// In build:
WebViewWidget(controller: controller);
```
