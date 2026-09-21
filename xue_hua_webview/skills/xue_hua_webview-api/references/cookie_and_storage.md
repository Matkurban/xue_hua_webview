# Cookies and storage

Import: `package:xue_hua_webview/xue_hua_webview.dart`.

# WebViewCookieManager

Manages cookies for all WebViews in the app.

`setCookie` is a no-op on iOS versions below 11. Cookie `path` must be a legal RFC6265bis path; Android, WebKit, Linux, and Windows throw `ArgumentError` when it is not. Linux and Windows also require a non-empty path to start with `/`.

`getCookies` URL requirements differ by platform. Pass a `Uri` for the domain you care about.

## Constructors

### `WebViewCookieManager()`

Creates the current platform cookie manager.

### `WebViewCookieManager.fromPlatformCreationParams(PlatformWebViewCookieManagerCreationParams params)`

Uses platform cookie params.

### `WebViewCookieManager.fromPlatform(PlatformWebViewCookieManager platform)`

Wraps an existing platform cookie manager.

## Properties

### `final PlatformWebViewCookieManager platform`

Cast after `is` (`AndroidWebViewCookieManager`, `WebKitWebViewCookieManager`, `WindowsWebViewCookieManager`, …).

## Methods

### `Future<bool> clearCookies()`

Clears all cookies for all WebViews. Returns `true` if cookies were present before clearing, otherwise `false`.

### `Future<void> setCookie(WebViewCookie cookie)`

Sets a cookie for all WebView instances.

`WebViewCookie`:

* `required String name`
* `required String value`
* `required String domain`
* `String path` (default `'/'`)

Values should match RFC6265bis cookie-name / cookie-value / domain-value / path-value.

### `Future<List<WebViewCookie>> getCookies({required Uri domain})`

Cookies visible for `domain` from all WebViews.

## Example

```dart
final WebViewCookieManager cookies = WebViewCookieManager();
await cookies.setCookie(
  const WebViewCookie(
    name: 'session',
    value: 'abc',
    domain: 'example.com',
    path: '/',
  ),
);
final List<WebViewCookie> list = await cookies.getCookies(
  domain: Uri.parse('https://example.com'),
);
await cookies.clearCookies();
```

Android extra: `AndroidWebViewCookieManager.setAcceptThirdPartyCookies`. Windows extras: `setWindowsCookie` / `getWindowsCookies` / delete helpers. See the platform skill.

# WebViewStorageManager

Clears cookies, HTTP cache, and DOM storage for the whole app process. Unlike `WebViewController.clearCache`, this can run when no WebView is mounted.

Web only clears the host origin.

## Constructors

### `WebViewStorageManager()`

Creates the current platform storage manager.

### `WebViewStorageManager.fromPlatformCreationParams(PlatformWebViewStorageManagerCreationParams params)`

### `WebViewStorageManager.fromPlatform(PlatformWebViewStorageManager platform)`

## Properties

### `final PlatformWebViewStorageManager platform`

## Methods

### `Future<void> removeData({Set<WebViewDataType> dataTypes = const <WebViewDataType>{WebViewDataType.all}, DateTime? since})`

Removes website data of the given types modified after `since`. Defaults to every type the current platform can clear.

`WebViewDataType` values:

* `cookies` — HTTP cookies
* `httpCache` — HTTP disk and memory caches
* `localStorage` — `window.localStorage`
* `sessionStorage` — `window.sessionStorage`
* `indexedDb` — IndexedDB databases
* `webSql` — WebSQL databases
* `all` — every type the current platform can clear

```dart
await WebViewStorageManager().removeData(
  dataTypes: <WebViewDataType>{
    WebViewDataType.cookies,
    WebViewDataType.httpCache,
  },
);
```

Supported on every platform; Web is limited to the host origin.
