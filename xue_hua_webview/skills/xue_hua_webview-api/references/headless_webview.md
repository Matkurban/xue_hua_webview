# HeadlessWebView

Import: `package:xue_hua_webview/xue_hua_webview.dart`.

A WebView that can load pages and run JavaScript without a `WebViewWidget`. Use it for long-lived JS runtimes that never need to be shown.

| Platform | Support |
| --- | --- |
| Android, iOS, macOS, Windows | Full |
| Linux | Full; offscreen GtkWindow when no overlay |
| Web | Full; hidden iframe |

## Constructors

### `HeadlessWebView({void Function(WebViewPermissionRequest request)? onPermissionRequest})`

Creates an offscreen WebView and a `WebViewController`. Same permission-callback rules as `WebViewController`: answer with `grant()` or `deny()`.

### `HeadlessWebView.fromPlatformCreationParams(PlatformHeadlessWebViewCreationParams params, {void Function(WebViewPermissionRequest request)? onPermissionRequest})`

Uses platform-specific headless params.

### `HeadlessWebView.fromPlatform(PlatformHeadlessWebView platform, {void Function(WebViewPermissionRequest request)? onPermissionRequest})`

Wraps an existing platform headless WebView. Builds `controller` with `WebViewController.fromPlatform(platform.controller, onPermissionRequest: ...)`.

## Properties

### `final PlatformHeadlessWebView platform`

Underlying platform implementation.

### `final WebViewController controller`

The controller that drives this headless WebView. Use the same loading, JS, and navigation APIs as a visible WebView.

### `bool get isRunning`

`true` after `run()` has completed and before `dispose()` is called.

## Methods

### `Future<void> run()`

Starts the native WebView so it can load content without a widget. Call this **before** `controller.loadRequest`.

### `Future<void> dispose()`

Releases native resources owned by this headless WebView. Also available on `WebViewController`; disposing the headless wrapper is the usual path.

## Example

```dart
final HeadlessWebView headless = HeadlessWebView();
await headless.controller.setJavaScriptMode(JavaScriptMode.unrestricted);
await headless.run();
await headless.controller.loadRequest(Uri.parse('https://example.com'));
final JavaScriptAsyncResult result = await headless.controller
    .runJavaScriptAsync('return await Promise.resolve(1 + 1);');
await headless.dispose();
```

## Anti-patterns

* Do not call `loadRequest` before `run()`.
* Do not reuse a headless instance after `dispose()`.
