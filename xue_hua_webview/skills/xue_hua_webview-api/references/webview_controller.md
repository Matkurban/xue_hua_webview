# WebViewController

Import: `package:xue_hua_webview/xue_hua_webview.dart`.

Controls a host-platform WebView. Pass it to `WebViewWidget`. A controller can be used by only one `WebViewWidget` at a time.

## Constructors

### `WebViewController({void Function(WebViewPermissionRequest request)? onPermissionRequest})`

Creates a controller with default `PlatformWebViewControllerCreationParams`.

`onPermissionRequest` runs when web content asks for protected resources (camera, microphone, and platform-specific types). Most platforms also need matching OS permissions in the host app. A response **must** be provided with `grant()`, `deny()`, or a method on `request.platform`.

### `WebViewController.fromPlatformCreationParams(PlatformWebViewControllerCreationParams params, {void Function(WebViewPermissionRequest request)? onPermissionRequest})`

Creates a controller with platform-specific creation params (for example `WebKitWebViewControllerCreationParams` or `AndroidWebViewControllerCreationParams`).

```dart
PlatformWebViewControllerCreationParams params =
    const PlatformWebViewControllerCreationParams();

if (WebViewPlatform.instance is WebKitWebViewPlatform) {
  params = WebKitWebViewControllerCreationParams
      .fromPlatformWebViewControllerCreationParams(params);
} else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
  params = AndroidWebViewControllerCreationParams
      .fromPlatformWebViewControllerCreationParams(params);
}

final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
```

Add the platform package as a direct dependency before importing it.

### `WebViewController.fromPlatform(PlatformWebViewController platform, {void Function(WebViewPermissionRequest request)? onPermissionRequest})`

Wraps an existing `PlatformWebViewController`. Used by `HeadlessWebView` and tests.

## Properties

### `final PlatformWebViewController platform`

Underlying platform controller. Cast only after `is` checks.

## Loading

### `Future<void> loadFile(String absoluteFilePath)`

Loads a file from an absolute device path such as `/Users/username/Documents/www/index.html`.

Throws a `PlatformException` if the path does not exist.

| Platform | Support |
| --- | --- |
| Android, iOS, macOS, Windows, Linux | Full |
| Web | No |

### `Future<void> loadFlutterAsset(String key)`

Loads an asset listed in the host app `pubspec.yaml`. `key` must be non-empty (`assert`). Throws `PlatformException` (or `ArgumentError` on Android when the asset file is missing) if `key` is not a declared asset.

Supported on every platform.

### `Future<void> loadHtmlString(String html, {String? baseUrl})`

Loads in-memory HTML. `html` must be non-empty (`assert`). `baseUrl` is used to resolve relative URLs inside the HTML.

Supported on every platform.

### `Future<void> loadRequest(Uri uri, {LoadRequestMethod method = LoadRequestMethod.get, Map<String, String> headers = const <String, String>{}, Uint8List? body})`

Loads an HTTP request.

Throws `ArgumentError('Missing scheme in uri: $uri')` when `uri.scheme` is empty.

`method` must be `LoadRequestMethod.get` or `LoadRequestMethod.post`. Non-empty `headers` are sent as request headers. Non-null `body` is sent as the request body.

| Feature | Android | iOS | macOS | Windows | Linux | Web |
| --- | --- | --- | --- | --- | --- | --- |
| GET | Full | Full | Full | Full | Full | Full |
| GET headers | Full | Full | Full | Full | Full | Limited, CORS/fetch |
| POST body | Full | Full | Full | Full | Full | Limited, CORS/fetch |
| POST headers | No | Full | Full | Full | Full | Limited, CORS/fetch |

## History and URL

### `Future<String?> currentUrl()`

Current URL, or `null` if none was ever loaded. Web may report a logical URL for synthetic loads.

### `Future<bool> canGoBack()` / `Future<bool> canGoForward()`

Whether a back/forward history item exists. Web uses controller-managed history.

### `Future<void> goBack()` / `Future<void> goForward()`

Step history. No-op when there is no item.

### `Future<void> reload()`

Reloads the current URL. Web reloads the last controller load.

### `Future<void> setNavigationDelegate(NavigationDelegate delegate)`

Registers navigation, error, and progress callbacks. See [navigation_delegate.md](navigation_delegate.md).

## Storage on this WebView

### `Future<void> clearCache()`

Clears HTTP cache, Cache API caches (service workers tend to use this), and application cache. Web is limited to host-origin cache storage.

### `Future<void> clearLocalStorage()`

Clears local storage used by this WebView. Web is limited to host-origin storage.

For process-wide wipes without a live WebView, use `WebViewStorageManager`.

## JavaScript

See also the `xue_hua_webview-javascript` skill.

### `Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode)`

`JavaScriptMode.disabled` or `JavaScriptMode.unrestricted`. Web applies this through the iframe sandbox.

### `Future<void> runJavaScript(String javaScript)`

Runs JS in the current page. Completes with an error if JS throws. Web: same-origin or managed isolated HTML.

### `Future<Object> runJavaScriptReturningResult(String javaScript)`

Runs JS and returns the result. Completes with an error if JS throws or the result type is unsupported. Unsupported values include certain non-primitive types on iOS, and `undefined` or `null` on iOS 14+. Web results must be JSON-serializable.

### `Future<JavaScriptAsyncResult> runJavaScriptAsync(String functionBody, {Map<String, Object?> arguments = const <String, Object?>{}, Duration? timeout})`

Runs `functionBody` as an async function and waits for a returned Promise. Keys in `arguments` become local variables. Values must be JSON-serializable.

| Platform | Support |
| --- | --- |
| Android | Full, helper channel |
| iOS | Full, iOS 14+ |
| macOS | Full, macOS 11+ |
| Windows | Full, helper channel |
| Linux | Full, WebKitGTK 2.40+ or helper |
| Web | Limited, same-origin or managed HTML |

### `Future<void> addJavaScriptChannel(String name, {required void Function(JavaScriptMessage) onMessageReceived})`

Enables a JS object named `name` with `postMessage`. `name` must be non-empty (`assert`) and unique. Takes effect after the **next** page load.

### `Future<void> removeJavaScriptChannel(String javaScriptChannelName)`

Removes a channel previously added with `addJavaScriptChannel`.

### `Future<void> addUserScript(UserScript userScript)`

Injects `userScript` into every subsequent navigation at document start or document end.

Android document-start: full on WebView 91+; older `onPageStarted` fallback. Document-end: `onPageFinished`. Web: srcdoc/same-origin.

### `Future<void> removeAllUserScripts()`

Removes every script added with `addUserScript`.

### `Future<void> setOnConsoleMessage(void Function(JavaScriptConsoleMessage message) onConsoleMessage)`

Receives JS console messages. Platforms may not preserve a 1:1 log-level mapping. On iOS/macOS this injects a `WKUserScript` that overrides `console.debug`, `console.error`, `console.info`, `console.log`, and `console.warning`.

### `Future<void> setOnJavaScriptAlertDialog(Future<void> Function(JavaScriptAlertDialogRequest request) onJavaScriptAlertDialog)`

Called for `alert()`. Complete the future after the UI is dismissed.

### `Future<void> setOnJavaScriptConfirmDialog(Future<bool> Function(JavaScriptConfirmDialogRequest request) onJavaScriptConfirmDialog)`

Called for `confirm()`. Return `true` / `false`. Web same-origin uses a synchronous callback; isolated HTML uses the browser dialog.

### `Future<void> setOnJavaScriptTextInputDialog(Future<String> Function(JavaScriptTextInputDialogRequest request) onJavaScriptTextInputDialog)`

Called for `prompt()`. Return the string the page should receive. Web same-origin uses a synchronous callback; isolated HTML uses the browser dialog.

## View state

### `Future<String?> getTitle()`

Title of the currently loaded page. Web: same-origin or managed isolated HTML.

### `Future<void> scrollTo(int x, int y)`

Scrolls to `(x, y)` in WebView pixels. macOS: logs and no-op.

### `Future<void> scrollBy(int x, int y)`

Scrolls by `(x, y)` WebView pixels. macOS: logs and no-op.

### `Future<Offset> getScrollPosition()`

Scroll offset from the top left. macOS: logs and returns zero.

### `Future<void> setOnScrollPositionChange(void Function(ScrollPositionChange change)? onScrollPositionChange)`

Pass `null` to clear. macOS: logs and no-op.

### `Future<void> setVerticalScrollBarEnabled(bool enabled)` / `Future<void> setHorizontalScrollBarEnabled(bool enabled)`

Show or hide scrollbars. macOS: logs and no-op. Windows and Web inject CSS.

### `Future<bool> supportsSetScrollBarsEnabled()`

Whether the current platform can change scrollbar visibility.

### `Future<void> enableZoom(bool enabled)`

On-screen zoom controls and gestures. Web: limited (iframe touch action).

### `Future<void> setBackgroundColor(Color color)`

Background color. macOS 12+; earlier macOS logs and no-op. Web sets iframe CSS.

### `Future<void> setUserAgent(String? userAgent)`

HTTP `User-Agent` header. Web: logs and ignores a non-null override. macOS appends a Safari-compatible `applicationNameForUserAgent` suffix by default; `setUserAgent` still overrides the full string.

### `Future<String?> getUserAgent()`

Current User-Agent string. On Web, non-null `setUserAgent` is ignored, so this returns the browser user agent.

### `Future<void> setOverScrollMode(WebViewOverScrollMode mode)`

`always`, `ifContentScrolls`, or `never`. Default is platform dependent. iOS: limited. macOS: logs and no-op. Windows/Web: CSS injection.

### `Future<void> dispose()`

Releases native resources. A disposed controller cannot be reused. Removing `WebViewWidget` does **not** call this.

# WebViewPermissionRequest

Immutable request when web content asks for protected resources. A response **MUST** be provided by `grant()`, `deny()`, or a method on `platform`.

Cast `platform` after checking `WebViewPlatform.instance` / `controller.platform` type. Android adds `midiSysex` and `protectedMediaId`. WebKit adds `prompt()`.

## Properties

* `final Set<WebViewPermissionResourceType> types` — requested resources. Common values: `camera`, `microphone`.
* `final PlatformWebViewPermissionRequest platform` — platform implementation.

## Methods

### `Future<void> grant()`

Grant the requested resource(s).

### `Future<void> deny()`

Deny the requested resource(s).
