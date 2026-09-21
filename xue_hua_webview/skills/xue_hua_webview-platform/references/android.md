# Android extra APIs

Package: `xue_hua_webview_android`. Add it as a direct dependency. Import `package:xue_hua_webview_android/xue_hua_webview_android.dart`.

Cast `controller.platform as AndroidWebViewController` only after `controller.platform is AndroidWebViewController` (or `WebViewPlatform.instance is AndroidWebViewPlatform`).

Do not use Pigeon types from `android_webkit.g.dart`.

## AndroidWebViewControllerCreationParams

Extends `PlatformWebViewControllerCreationParams`.

* `AndroidWebViewControllerCreationParams({@visibleForTesting WebStorage? androidWebStorage})`
* `factory AndroidWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(PlatformWebViewControllerCreationParams params, {@visibleForTesting WebStorage? androidWebStorage})`

`androidWebStorage` is `@visibleForTesting`. App code can use the default constructor / factory with no extra fields.

## AndroidLoadFileParams

Extends `LoadFileParams`. Use with `loadFileWithParams` on the Android controller.

```dart
AndroidLoadFileParams({
  required String absoluteFilePath,
  Map<String, String> headers = const <String, String>{},
})
factory AndroidLoadFileParams.fromLoadFileParams(
  LoadFileParams params, {
  Map<String, String> headers = const <String, String>{},
})
```

If `absoluteFilePath` does not start with `file://`, it is converted with `Uri.file`. `headers` are additional HTTP headers for the local-file load. `loadFile` on the common controller already routes to `AndroidLoadFileParams` without extra headers.

## AndroidWebViewController extras

Common `PlatformWebViewController` methods are used through `WebViewController`. The methods below are Android-only.

### `Future<void> setAllowFileAccess(bool allow)`

File-access permission for the WebView. Default is `true` for apps targeting API 29 and below, `false` when targeting API 30+.

### `static Future<void> enableDebugging(bool enabled)`

Enables the platform WebView content debugging tools. Defaults to `false`. Call on the class, not an instance:

```dart
await AndroidWebViewController.enableDebugging(true);
```

### `int get webViewIdentifier`

Identifier for the native `WebView` in the plugin `InstanceManager`. Used by other plugins (`WebViewFlutterPlugin.getWebView`).

### `Future<void> setMediaPlaybackRequiresUserGesture(bool require)`

Restrictions on automatic media playback.

### `Future<void> setTextZoom(int textZoom)`

Text zoom of the page in percent. Default `100`.

### `Future<void> setUseWideViewPort(bool use)`

Whether to honor the HTML `viewport` meta tag / use a wide viewport. Default `false`.

### `Future<void> setAllowContentAccess(bool enabled)`

Content URL access. Default `true`.

### `Future<void> setGeolocationEnabled(bool enabled)`

Whether Geolocation is enabled. Default `true`.

### `Future<void> setOnShowFileSelector(Future<List<String>> Function(FileSelectorParams params)? onShowFileSelector)`

When `null` (default), Android uses the plugin's built-in picker: Photo Picker for image and video accept types, `ACTION_GET_CONTENT` for other MIME types, and the camera when `FileSelectorParams.isCaptureEnabled` is true. Cancel, permission denial, and errors complete the WebView callback with `null` so the file input can be used again.

When non-null, the callback must return file URI strings (for example `content://...`). Return an empty list to cancel.

### `Future<void> setGeolocationPermissionsPromptCallbacks({OnGeolocationPermissionsShowPrompt? onShowPrompt, OnGeolocationPermissionsHidePrompt? onHidePrompt})`

* `onShowPrompt`: page from `origin` wants Geolocation and no permission is stored. Return `GeolocationPermissionsResponse`. Only called for secure origins (`https`); non-secure origins are denied automatically.
* `onHidePrompt`: previous prompt was canceled; hide related UI.

```dart
await android.setGeolocationPermissionsPromptCallbacks(
  onShowPrompt: (GeolocationPermissionsRequestParams request) async {
    return const GeolocationPermissionsResponse(allow: true, retain: false);
  },
);
```

### `Future<void> setCustomWidgetCallbacks({required OnShowCustomWidgetCallback? onShowCustomWidget, required OnHideCustomWidgetCallback? onHideCustomWidget})`

Fullscreen (commonly video). After `onShowCustomWidget`, content is rendered in the custom widget, not `WebViewWidget`. Call `onCustomWidgetHidden` to exit. `onHideCustomWidget` means remove the custom widget. If `null` when passed to an `AndroidWebViewWidget`, a default handler is set.

`OnShowCustomWidgetCallback` = `void Function(Widget widget, void Function() onCustomWidgetHidden)`  
`OnHideCustomWidgetCallback` = `void Function()`

### `Future<void> setMixedContentMode(MixedContentMode mode)`

* `alwaysAllow` — least secure; HTTPS may load HTTP.
* `compatibilityMode` — browser-like; exact rules can change with WebView releases.
* `neverAllow` — preferred default; HTTPS cannot load HTTP.

### `Future<bool> isWebViewFeatureSupported(WebViewFeatureType featureType)`

`WebViewFeatureType.paymentRequest` or `WebViewFeatureType.webAuthentication`. Check before `setPaymentRequestEnabled` / `setWebAuthenticationSupport`. AndroidX throws if the installed WebView lacks the feature.

### `Future<void> setWebAuthenticationSupport(WebAuthenticationSupport support)`

WebAuthn/passkeys. Disabled by default.

* `none` (0) — disable WebAuthn (AndroidX default)
* `forApp` (1) — relying parties associated with the app via Digital Asset Links
* `forBrowser` (2) — any website; only for privileged browser apps. Ordinary apps should use `forApp`.

### `Future<void> setPaymentRequestEnabled(bool enabled)`

Payment Request API. Requires `queries` in `AndroidManifest.xml` so WebView can find payment apps.

### `Future<void> setInsetsForWebContentToIgnore(List<AndroidWebViewInsets> insets)`

Insets the native view should prevent web content from receiving.

`AndroidWebViewInsets`: `systemBars`, `displayCutout`, `captionBar`, `ime`, `mandatorySystemGestures`, `navigationBars`, `statusBars`, `systemGestures`, `tappableElement`.

## File selector types

### `FileSelectorParams`

`const FileSelectorParams({required bool isCaptureEnabled, required List<String> acceptTypes, String? filenameHint, required FileSelectorMode mode})`

* `isCaptureEnabled` — live capture (camera/microphone) preferred
* `acceptTypes` — acceptable MIME types
* `filenameHint` — default name, or `null`
* `mode` — `FileSelectorMode.open`, `openMultiple`, or `save`

### `FileSelectorMode`

`open`, `openMultiple`, `save`.

## Permission extras

### `AndroidWebViewPermissionResourceType`

* `midiSysex` — MIDI sysex
* `protectedMediaId` — protected media identifier

Plus inherited `camera` and `microphone`.

### `AndroidWebViewPermissionRequest`

`grant()` / `deny()`. Granting an unknown `WebViewPermissionResourceType` throws `UnsupportedError`.

### Geolocation types

`GeolocationPermissionsRequestParams({required String origin})`  
`GeolocationPermissionsResponse({required bool allow, required bool retain})`  
`OnGeolocationPermissionsShowPrompt` / `OnGeolocationPermissionsHidePrompt`

## AndroidWebViewCookieManager extras

### `Future<void> setAcceptThirdPartyCookies(AndroidWebViewController controller, bool accept)`

Whether that WebView may set third-party cookies. Defaults to `false`.

`setCookie` throws `ArgumentError` if `cookie.path` is not a legal RFC6265bis path.

## Built-in file chooser (no Dart callback)

Image/video accept types use the system Photo Picker; other MIME types use `ACTION_GET_CONTENT`; `capture` opens the camera after a `CAMERA` grant. Multiple selection is supported. Cancel, permission denial, Dart override failure, and activity detach complete `filePathCallback` with `null`.
