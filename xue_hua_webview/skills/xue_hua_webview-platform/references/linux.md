# Linux WebKitGTK extra APIs

Package: `xue_hua_webview_linux`. Add it as a direct dependency. Import `package:xue_hua_webview_linux/xue_hua_webview_linux.dart`.

Cast `controller.platform as LinuxWebViewController` only after an `is` check.

Normal cleanup is automatic through a finalizer. `dispose()` is available for optional early release. Custom URL-scheme handoff is **not** implemented on Linux. WebAuthn is not available on this WebKitGTK port.

## LinuxWebViewControllerCreationParams

All fields are optional (`null` leaves the native default):

```dart
const LinuxWebViewControllerCreationParams({
  bool? developerExtrasEnabled,
  bool? javascriptCanOpenWindowsAutomatically,
  bool? mediaPlaybackRequiresUserGesture,
  bool? mediaPlaybackAllowsInline,
  bool? pageCacheEnabled,
  bool? allowFileAccessFromFileUrls,
  bool? allowUniversalAccessFromFileUrls,
  bool? zoomTextOnly,
  int? defaultFontSize,
  int? defaultMonospaceFontSize,
  int? minimumFontSize,
  double? zoomFactor,
})
```

Factory: `LinuxWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(...)` with the same named arguments.

## LinuxWebViewController extras

### `Future<void> setFrame(Rect rect, {required bool visible})`

Sets the native view frame and visibility. Used by the platform widget; app code rarely needs this.

### `Future<void> setDeveloperExtrasEnabled(bool enabled)`

Enables WebKitGTK developer extras for this WebView.

### `Future<void> openDevTools()`

Opens the WebKitGTK web inspector.

### `Future<void> setJavaScriptCanOpenWindowsAutomatically(bool enabled)`

Whether JavaScript may open windows automatically.

### `Future<void> setMediaPlaybackRequiresUserGesture(bool require)`

Whether media playback requires a user gesture.

### `Future<void> setMediaPlaybackAllowsInline(bool allow)`

Whether inline media playback is allowed.

### `Future<void> setPageCacheEnabled(bool enabled)`

Enables or disables WebKitGTK's page cache.

### `Future<void> setAllowFileAccessFromFileUrls(bool allow)`

Whether file URLs can read other file URLs.

### `Future<void> setAllowUniversalAccessFromFileUrls(bool allow)`

Whether file URLs can access all origins.

### `Future<void> setZoomTextOnly(bool enabled)`

Whether zooming affects only text.

### `Future<void> setDefaultFontSize(int fontSize)`

Default proportional font size in CSS pixels.

### `Future<void> setDefaultMonospaceFontSize(int fontSize)`

Default monospace font size in CSS pixels.

### `Future<void> setMinimumFontSize(int fontSize)`

Minimum font size in CSS pixels.

### `Future<void> setZoomFactor(double zoomFactor)`

Page zoom factor.

### `Future<void> dispose()`

Optional early release of native resources. Safe to call more than once; subsequent calls await the same future.

## Cookies

`LinuxWebViewCookieManager.setCookie` throws `ArgumentError` if the name is empty or contains rejected characters, if a non-empty path does not start with `/`, or if the path is not a legal RFC6265bis path.

## Headless

`HeadlessWebView` is full on Linux (offscreen GtkWindow when no overlay).
