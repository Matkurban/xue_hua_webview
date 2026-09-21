# Web iframe extra APIs

Package: `xue_hua_webview_web`. Add it as a direct dependency. Import `package:xue_hua_webview_web/xue_hua_webview_web.dart`.

Cast `controller.platform as WebWebViewController` only after an `is` check.

The Web implementation is an iframe plus optional fetch-backed loads. JavaScript, channels, console, title, and scroll require a same-origin document or managed isolated HTML. Cross-origin pages cannot be scripted. HTTP auth and recoverable SSL callbacks are not available as browser iframe events. `loadFile` is unsupported. `setUserAgent` with a non-null value is logged and ignored.

## WebWebViewControllerCreationParams

```dart
WebWebViewControllerCreationParams({
  @visibleForTesting HttpRequestFactory httpRequestFactory = const HttpRequestFactory(),
  String? iFrameAllow,
  String? iFrameSandbox,
  String? iFrameReferrerPolicy,
  Map<String, String?> iFrameAttributes = const <String, String?>{},
})
```

Factory: `fromPlatformWebViewControllerCreationParams` with the same named arguments.

* `httpRequestFactory` — `@visibleForTesting` fetch factory; app code should use the default.
* `iFrameAllow` — iframe `allow` attribute.
* `iFrameSandbox` — iframe `sandbox` while JavaScript is unrestricted.
* `iFrameReferrerPolicy` — iframe `referrerpolicy` attribute.
* `iFrameAttributes` — extra attributes. Values override `iFrameAllow` / `iFrameSandbox` / `iFrameReferrerPolicy` when the same name is present.

Do not set `id`, `src`, or `srcdoc` through `iFrameAttributes`; those names are reserved.

## WebWebViewController extras

### `Future<void> setIFrameAttribute(String name, String? value)`

Sets or removes an attribute on the iframe. Passing `null` removes it.

When `name` is `sandbox` (case-insensitive), the value is stored as the unrestricted-mode sandbox and restored when `setJavaScriptMode` switches back to `unrestricted`. While JS is `disabled`, the iframe uses an internal sandbox that disallows scripts.

Throws `ArgumentError` when:

* `name` is empty (after trim)
* `name` contains characters that are not valid in HTML (`[\x00-\x20"'/>=]`)
* `name` is a reserved attribute: `id`, `src`, or `srcdoc`

### `Future<void> setIFrameAllow(String? allow)`

Sets or removes `allow`. Delegates to `setIFrameAttribute('allow', allow)`.

### `Future<void> setIFrameSandbox(String? sandbox)`

Sets or removes `sandbox`. Delegates to `setIFrameAttribute('sandbox', sandbox)`.

### `Future<void> setIFrameReferrerPolicy(String? referrerPolicy)`

Sets or removes `referrerpolicy`. Delegates to `setIFrameAttribute('referrerpolicy', referrerPolicy)`.

```dart
if (controller.platform is WebWebViewController) {
  final WebWebViewController web =
      controller.platform as WebWebViewController;
  await web.setIFrameAllow('camera; microphone');
  await web.setIFrameReferrerPolicy('strict-origin-when-cross-origin');
}
```

## HttpRequestFactory and ContentType

Exported by the web package for tests and advanced fetch customization. `HttpRequestFactory.request` sends URL requests used by fetch-backed loads. `ContentType.parse(String header)` parses a `Content-Type` header (`mimeType`, `charset`, `boundary`). Application code normally does not construct these.

## Limits (common APIs on Web)

* History back/forward is controller-managed.
* `reload` reloads the last controller load.
* `clearCache` / `clearLocalStorage` / `WebViewStorageManager.removeData` affect the host origin.
* `onNavigationRequest` covers controller loads and observable iframe loads.
* `onProgress` is synthetic `0`/`100` plus load event.
* `confirm` / `prompt` host callbacks are same-origin and synchronous; isolated managed HTML uses the browser dialog.
* File selector is browser-owned.
