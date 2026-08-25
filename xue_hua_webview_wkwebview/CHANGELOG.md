## 1.0.3

* Fix iOS and macOS HTTPS loads that failed after a `NavigationDelegate` was set, because TLS server-trust challenges were cancelled when the Dart round trip failed.
* Use uppercase HTTP methods (`GET` / `POST`) for WKWebView `loadRequest`.

## 1.0.1

* Fix a WKWebView Swift compile error in `callAsyncJavaScript` by using WebKit's single-argument `Result` completion handler.

## 1.0.0

* Initial release of `xue_hua_webview` (renamed from `webview_all` / `webview_platform_interface` / `webview_all_*`). Update pubspec dependencies and `package:` imports; public widget and controller APIs are unchanged.
* Add `WebViewController.runJavaScriptAsync` to await JavaScript Promises and return `JavaScriptAsyncResult`.
* Add `UserScript` injection at document-start and document-end through `addUserScript` / `removeAllUserScripts`.
* Add `WebViewStorageManager` to clear cookies, HTTP cache, and DOM storage without a live WebView.
* Add `HeadlessWebView` for offscreen WebView runtimes, plus `WebViewController.dispose`.
* Add Android WebAuthn and passkey configuration through `setWebAuthenticationSupport` for associated apps and eligible browser apps.
* Fix a Windows issue where WebView2 could continue intercepting desktop clicks after the application window was minimized or the WebView was hidden or removed.
* Improve Windows WebView display and rendering recovery across application lifecycle changes, WebView visibility changes, window movement, display changes, and DPI changes.
* Add deterministic Windows WebView2 cleanup through `WindowsWebViewController.dispose()`, including safe disposal during initialization and automatic fallback cleanup.
