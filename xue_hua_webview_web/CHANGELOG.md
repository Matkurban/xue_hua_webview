## 1.1.0

- Add a built-in Android file chooser for `<input type="file">`. Image and video accept types use the system Photo Picker, other MIME types use `ACTION_GET_CONTENT`, multiple selection is supported, and `capture` opens the camera after a `CAMERA` permission grant. Cancel, permission denial, Dart override failure, and activity detach always complete `filePathCallback` with `null` so the input does not freeze.
- Keep `AndroidWebViewController.setOnShowFileSelector` as an optional override. When it is unset, the built-in picker runs automatically.
- Implement macOS `WKUIDelegate.runOpenPanel` with `NSOpenPanel` so file inputs show a system dialog. Cancel and a missing window always call `completionHandler(nil)`.
- Document host-app AndroidManifest and Info.plist requirements for camera, microphone, and photo library usage. Photo Picker and SAF do not need `READ_MEDIA_*` or `READ_EXTERNAL_STORAGE`.
- Isolate Android file-chooser Activity results with incrementing request codes so a superseded picker cannot complete a newer WebView callback. Keep an in-flight chooser across Activity configuration changes.
- Close an in-flight macOS `NSOpenPanel` before starting another so the old sheet cannot complete the new handler.
- Append a Safari-compatible `applicationNameForUserAgent` suffix on macOS WKWebView so sites that reject a bare AppleWebKit user agent can load. `setUserAgent` still overrides the full string.
- Open Android, iOS, and macOS page navigations to custom URL schemes (`bilibili://`, `weixin://`, `intent://`, `mailto:`, `tel:`) with the matching system app instead of loading them in the WebView. `onNavigationRequest` still receives the URL; `prevent` blocks the handoff.
- Bump Dart dependencies: `meta` `1.18.3` (via `dependency_overrides` on Flutter 3.44), `plugin_platform_interface` `^2.1.8`, `path` `^1.9.1`, `pigeon` `^28.0.0`, `mockito` `^5.8.1`, and `build_runner` `^2.16.1`.
- Point the federated packages at `xue_hua_webview_platform_interface` `^1.0.2`, `xue_hua_webview_web` `^1.0.2`, `xue_hua_webview_windows` `^1.0.3`, and `xue_hua_webview_linux` `^1.0.2`.

## 1.0.3

- Fix iOS and macOS HTTPS loads that failed after a `NavigationDelegate` was set, because TLS server-trust challenges were cancelled when the Dart round trip failed.
- Use uppercase HTTP methods (`GET` / `POST`) for WKWebView `loadRequest`.

## 1.0.2

- Fix a Windows MSVC 14.51 (VS 18) build failure (STL1011) by silencing C++/WinRT's deprecated `<experimental/coroutine>` include.

## 1.0.1

- Fix a WKWebView Swift compile error in `callAsyncJavaScript` by using WebKit's single-argument `Result` completion handler.

## 1.0.0

- Initial release of `xue_hua_webview` (renamed from `webview_all` / `webview_platform_interface` / `webview_all_*`). Update pubspec dependencies and `package:` imports; public widget and controller APIs are unchanged.
- Add `WebViewController.runJavaScriptAsync` to await JavaScript Promises and return `JavaScriptAsyncResult`.
- Add `UserScript` injection at document-start and document-end through `addUserScript` / `removeAllUserScripts`.
- Add `WebViewStorageManager` to clear cookies, HTTP cache, and DOM storage without a live WebView.
- Add `HeadlessWebView` for offscreen WebView runtimes, plus `WebViewController.dispose`.
- Add Android WebAuthn and passkey configuration through `setWebAuthenticationSupport` for associated apps and eligible browser apps.
- Fix a Windows issue where WebView2 could continue intercepting desktop clicks after the application window was minimized or the WebView was hidden or removed.
- Improve Windows WebView display and rendering recovery across application lifecycle changes, WebView visibility changes, window movement, display changes, and DPI changes.
- Add deterministic Windows WebView2 cleanup through `WindowsWebViewController.dispose()`, including safe disposal during initialization and automatic fallback cleanup.
