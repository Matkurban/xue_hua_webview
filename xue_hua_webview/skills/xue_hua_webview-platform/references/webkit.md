# iOS / macOS WebKit extra APIs

Package: `xue_hua_webview_wkwebview`. Add it as a direct dependency. Import `package:xue_hua_webview_wkwebview/xue_hua_webview_wkwebview.dart`.

Cast `controller.platform as WebKitWebViewController` only after an `is` check. Do not use Pigeon types from `web_kit.g.dart`.

macOS file inputs use `WKUIDelegate.runOpenPanel` (`NSOpenPanel`). Cancel and a missing window call `completionHandler(nil)`. Sandboxed macOS apps need `com.apple.security.files.user-selected.read-only`.

## PlaybackMediaTypes

* `audio`
* `video`

## WebKitWebViewControllerCreationParams

Extends `PlatformWebViewControllerCreationParams`.

```dart
WebKitWebViewControllerCreationParams({
  Set<PlaybackMediaTypes> mediaTypesRequiringUserAction =
      const <PlaybackMediaTypes>{
        PlaybackMediaTypes.audio,
        PlaybackMediaTypes.video,
      },
  bool allowsInlineMediaPlayback = false,
  bool limitsNavigationsToAppBoundDomains = false,
  bool? javaScriptCanOpenWindowsAutomatically,
})
```

Factory: `WebKitWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(PlatformWebViewControllerCreationParams params, {same named args})`.

Fields:

* `mediaTypesRequiringUserAction` — types that need a user gesture to play. Empty set means none. Both audio and video maps to WebKit "all".
* `allowsInlineMediaPlayback` — inline HTML5 video. Default `false`.
* `limitsNavigationsToAppBoundDomains` — App-Bound Domains (iOS 14+ / macOS 11+). Default `false`. On older OS versions the setting is logged and ignored; controller creation still succeeds.
* `javaScriptCanOpenWindowsAutomatically` — when `null`, native default is used (`false` on iOS, `true` on macOS).

```dart
final WebViewController controller = WebViewController.fromPlatformCreationParams(
  WebKitWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
    const PlatformWebViewControllerCreationParams(),
    allowsInlineMediaPlayback: true,
    mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
  ),
);
```

## WebKitLoadFileParams

Extends `LoadFileParams`.

```dart
WebKitLoadFileParams({
  required String absoluteFilePath,
  String? readAccessPath,
})
factory WebKitLoadFileParams.fromLoadFileParams(
  LoadFileParams params, {
  String? readAccessPath,
})
```

`readAccessPath` is the directory WebKit may read. Default: parent directory of `absoluteFilePath`. It must include resources (images, scripts) referenced by the HTML. Common `loadFile` already uses `WebKitLoadFileParams` with that default.

## WebKitWebViewController extras

### `int get webViewIdentifier`

Identifier for the native `WKWebView` in `FWFInstanceManager` (`FLTWebViewFlutterPlugin:webViewForIdentifier:withPluginRegistry`).

### `Future<void> setAllowsBackForwardNavigationGestures(bool enabled)`

Whether horizontal swipe gestures trigger page navigation.

### `Future<void> setAllowsLinkPreview(bool allow)`

Previews for link destinations and detected data (addresses, phone numbers). Available on devices that support 3D Touch. Defaults to `true`.

### `Future<void> setOnCanGoBackChange(void Function(bool) onCanGoBackChangeCallback)`

Listener for `canGoBack` changes.

### `Future<void> setInspectable(bool inspectable)`

Debugging tools for this WKWebView. Must be enabled per WebView.

From macOS 13.3, iOS 16.4, and tvOS 16.4 the OS default is `false` (previously `true`). If the OS is too old, the call is logged and ignored (`macOS 13.3+` or `iOS 16.4+`).

## Console override

`setOnConsoleMessage` (common API) injects a `WKUserScript` that overrides `console.debug`, `console.error`, `console.info`, `console.log`, and `console.warn` and forwards them through a JavaScript channel. The channel name is internal (`fltConsoleMessage`).

## WebKitWebViewPermissionRequest

Extends `PlatformWebViewPermissionRequest`.

* `Future<void> grant()`
* `Future<void> deny()`
* `Future<void> prompt()` — ask the user via the system prompt (`WKPermissionDecision.prompt`)

Cast `request.platform as WebKitWebViewPermissionRequest` after confirming WebKit.

## WebKit cookie manager

`setCookie` throws `ArgumentError` if `cookie.path` is not a legal RFC6265bis path. `setCookie` is a no-op on iOS below 11 (common API contract). `getCookies` matches cookies using RFC 6265 domain matching against `url.host`.

## macOS scroll / chrome limits

On macOS, `scrollTo` / `scrollBy` / `getScrollPosition` / scroll callbacks / scrollbar visibility log and no-op (scroll read returns zero). `setOverScrollMode` logs and no-op. `setBackgroundColor` requires macOS 12+.

macOS WKWebView appends a Safari-compatible `applicationNameForUserAgent` suffix so sites that reject a bare AppleWebKit UA can load. `setUserAgent` still overrides the full string.
