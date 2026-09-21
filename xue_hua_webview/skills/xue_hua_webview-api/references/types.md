# Exported types

All of these are exported from `package:xue_hua_webview/xue_hua_webview.dart`. Do not import `xue_hua_webview_platform_interface` in app code for these types.

`LoadRequestParams` and `LoadFileParams` are **not** re-exported by the app-facing library. Use `WebViewController.loadRequest` / `loadFile`, or platform-specific `loadFileWithParams` after importing a platform package.

## Enums

### `JavaScriptMode`

* `disabled` — JavaScript execution is disabled.
* `unrestricted` — JavaScript execution is not restricted.

### `LoadRequestMethod`

* `get` — HTTP GET.
* `post` — HTTP POST.

Extension `LoadRequestMethodExtensions.serialize()` returns `'get'` or `'post'`. App code normally passes the enum to `loadRequest`, not `serialize()`.

### `NavigationDecision`

* `prevent` — block the navigation.
* `navigate` — allow the navigation.

### `UserScriptInjectionTime`

* `documentStart` — after the document element is created, before other content.
* `documentEnd` — after the document finishes loading, before subresources.

### `WebViewOverScrollMode`

* `always` — always allow over-scroll.
* `ifContentScrolls` — only if content is larger than the viewport.
* `never` — never allow over-scroll.

### `WebViewDataType`

Used by `WebViewStorageManager.removeData`:

* `cookies`, `httpCache`, `localStorage`, `sessionStorage`, `indexedDb`, `webSql`, `all`

### `JavaScriptLogLevel`

* `error` — `console.error` / error event
* `warning` — `console.warning`
* `debug` — `console.debug`
* `info` — `console.info`
* `log` — `console.log`

### `WebResourceErrorType`

`authentication`, `badUrl`, `connect`, `failedSslHandshake`, `file`, `fileNotFound`, `hostLookup`, `io`, `proxyAuthentication`, `redirectLoop`, `timeout`, `tooManyRequests`, `unknown`, `unsafeResource`, `unsupportedAuthScheme`, `unsupportedScheme`, `webContentProcessTerminated`, `webViewInvalidated`, `javaScriptExceptionOccurred`, `javaScriptResultTypeIsUnsupported`.

## Classes

### `JavaScriptMessage`

`const JavaScriptMessage({required String message})`  
`final String message`

### `JavaScriptConsoleMessage`

`const JavaScriptConsoleMessage({required JavaScriptLogLevel level, required String message})`  
`final JavaScriptLogLevel level`  
`final String message`

### `JavaScriptAlertDialogRequest`

`const JavaScriptAlertDialogRequest({required String message, required String url})`

### `JavaScriptConfirmDialogRequest`

`const JavaScriptConfirmDialogRequest({required String message, required String url})`

### `JavaScriptTextInputDialogRequest`

`const JavaScriptTextInputDialogRequest({required String message, required String url, required String? defaultText})`

### `JavaScriptAsyncResult`

`const JavaScriptAsyncResult({Object? value, String? error})`  
`final Object? value` — decoded JSON on success  
`final String? error` — JS/engine/timeout message; `null` on success  
`bool get hasError` — `error != null`

### `UserScript`

`const UserScript({required String source, UserScriptInjectionTime injectionTime = UserScriptInjectionTime.documentStart, bool forMainFrameOnly = true})`

On Android, `forMainFrameOnly` is best-effort because document-start injection uses origin rules.

### `NavigationRequest`

`const NavigationRequest({required String url, required bool isMainFrame})`

### `UrlChange`

`const UrlChange({required String? url})`

### `ScrollPositionChange`

`const ScrollPositionChange(double x, double y)` — origin is top-left of the WebView.

### `WebViewCookie`

`const WebViewCookie({required String name, required String value, required String domain, String path = '/'})`

### `WebViewCredential`

`const WebViewCredential({required String user, required String password})`

### `HttpAuthRequest`

`const HttpAuthRequest({required void Function(WebViewCredential credential) onProceed, required void Function() onCancel, required String host, String? realm})`

Call `onProceed` or `onCancel` exactly as the platform expects for that challenge.

### `WebResourceError`

`const WebResourceError({required int errorCode, required String description, WebResourceErrorType? errorType, bool? isForMainFrame, String? url})`

### `WebResourceRequest`

`const WebResourceRequest({required Uri uri})`

### `WebResourceResponse`

`const WebResourceResponse({required Uri? uri, required int statusCode, Map<String, String> headers = const <String, String>{}})`

### `HttpResponseError`

`const HttpResponseError({WebResourceRequest? request, WebResourceResponse? response})`

### `X509Certificate`

`const X509Certificate({Uint8List? data})` — DER bytes when provided.

### `WebViewPermissionResourceType`

Do not construct this in app code (`@protected` constructor). Use:

* `WebViewPermissionResourceType.camera`
* `WebViewPermissionResourceType.microphone`

Android adds `AndroidWebViewPermissionResourceType.midiSysex` and `protectedMediaId`.

`final String name` is the unique type name.

### `PlatformWebViewPermissionRequest`

Abstract. `grant()` / `deny()` plus `final Set<WebViewPermissionResourceType> types`. App code uses `WebViewPermissionRequest` from the controller callback.

### Creation params (empty / marker types)

Construct with the const constructor when you do not need platform fields:

* `const PlatformWebViewControllerCreationParams()`
* `const PlatformNavigationDelegateCreationParams()`
* `const PlatformWebViewCookieManagerCreationParams()`
* `const PlatformWebViewStorageManagerCreationParams()`
* `const PlatformHeadlessWebViewCreationParams()`

`PlatformWebViewWidgetCreationParams({Key? key, required PlatformWebViewController controller, TextDirection layoutDirection = TextDirection.ltr, Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{}})`

### `WebViewPlatform`

Federated plugin registry. Apps read `WebViewPlatform.instance` for `is` checks (`AndroidWebViewPlatform`, `WebKitWebViewPlatform`, …). Setting `instance` to `null` throws `AssertionError`. `createPlatform*` factories are for the app-facing package, not application code.

## Typedefs

* `NavigationRequestCallback` = `FutureOr<NavigationDecision> Function(NavigationRequest)`
* `PageEventCallback` = `void Function(String url)`
* `ProgressCallback` = `void Function(int progress)`
* `HttpResponseErrorCallback` = `void Function(HttpResponseError error)`
* `WebResourceErrorCallback` = `void Function(WebResourceError error)`
