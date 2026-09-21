# Windows WebView2 extra APIs

Package: `xue_hua_webview_windows`. Add it as a direct dependency. Import `package:xue_hua_webview_windows/xue_hua_webview_windows.dart`.

Cast `controller.platform as WindowsWebViewController` only after an `is` check.

Removing `WebViewWidget` does not dispose a reusable controller. Call `dispose` only when its owner will never use it again. `WindowsWebViewController.dispose()` is deterministic, including during initialization, with automatic fallback cleanup.

## WindowsPopupWindowPolicy

* `allow` — popups open separate windows
* `deny` — suppress popup windows
* `sameWindow` — open popup content in the current window (creation-params default)

## WindowsWebViewControllerCreationParams

```dart
const WindowsWebViewControllerCreationParams({
  WindowsPopupWindowPolicy popupWindowPolicy =
      WindowsPopupWindowPolicy.sameWindow,
})
const WindowsWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
  PlatformWebViewControllerCreationParams params, {
  WindowsPopupWindowPolicy popupWindowPolicy =
      WindowsPopupWindowPolicy.sameWindow,
})
```

`popupWindowPolicy` — how popup windows are handled.

## WindowsWebViewWidgetCreationParams

```dart
const WindowsWebViewWidgetCreationParams({
  Key? key,
  required PlatformWebViewController controller,
  TextDirection layoutDirection,
  Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
  double? scaleFactor,
  FilterQuality filterQuality = FilterQuality.none,
})
```

* `scaleFactor` — optional rasterization scale
* `filterQuality` — filter quality for the underlying texture (default `FilterQuality.none`)

## WindowsWebViewController extras

### `static Future<void> initializeEnvironment({String? userDataPath, String? browserExePath, String? additionalArguments})`

Initializes the **shared** WebView2 environment. Call at most once, **before** any WebView is created. Throws `PlatformException` if the environment was already initialized.

* `userDataPath` — optional user-data directory
* `browserExePath` — optional browser executable
* `additionalArguments` — optional Chromium command-line arguments

### `static Future<String?> getWebViewVersion()`

Installed WebView2 runtime version, including channel name when it is not the WebView2 Runtime. Returns `null` if the runtime is not installed.

### `Future<void> openDevTools()`

Opens browser DevTools for this WebView.

### `Future<void> suspend()` / `Future<void> resume()`

Suspend or resume the WebView.

### `Future<void> setPopupWindowPolicy(WindowsPopupWindowPolicy policy)`

Updates popup handling after creation.

### `Future<void> setZoomFactor(double zoomFactor)`

WebView2 zoom factor.

### `Future<void> setCacheDisabled(bool disabled)`

When `true`, cache is ignored for each request.

Virtual host mapping exists internally for asset loads; it is not a public instance method.

## WindowsWebViewCookieManager extras

`setCookie` / `setWindowsCookie` validate name/domain/path and throw `ArgumentError` for empty names, illegal characters, paths that do not start with `/` (when non-empty), or illegal RFC6265bis paths.

### `Future<void> setWindowsCookie(WindowsWebViewCookie cookie)`

Sets a full WebView2 cookie (expiry, httpOnly, secure, SameSite).

### `Future<List<WindowsWebViewCookie>> getWindowsCookies(Uri url)`

Full cookies visible for `url`.

### `Future<void> deleteWindowsCookie(WindowsWebViewCookie cookie)`

Deletes by native cookie identity.

### `Future<void> deleteCookiesWithNameAndUrl({required String name, required Uri url})`

### `Future<void> deleteCookiesWithNameDomainAndPath({required String name, required String domain, required String path})`

## WindowsWebViewCookie

```dart
const WindowsWebViewCookie({
  required String name,
  required String value,
  required String domain,
  required String path,
  DateTime? expires,
  bool? isHttpOnly,
  bool? isSecure,
  WindowsWebViewCookieSameSite? sameSite,
  bool? isSession,
})
```

`expires` `null` leaves the native default. `isSession` is returned by WebView2.

### `WindowsWebViewCookieSameSite`

* `none` — all contexts
* `lax` — withheld on cross-site subrequests
* `strict` — same-site only

## Notes

WebView2 continues not to intercept desktop clicks after the window is minimized or the WebView is hidden or removed. Display recovery covers lifecycle, visibility, movement, display, and DPI changes. Custom URL-scheme handoff is **not** implemented on Windows.
