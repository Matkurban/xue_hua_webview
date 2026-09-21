# NavigationDelegate and errors

Import: `package:xue_hua_webview/xue_hua_webview.dart`.

Register with `WebViewController.setNavigationDelegate`.

## Constructors

### `NavigationDelegate({...})`

Named callback parameters (all optional):

* `FutureOr<NavigationDecision> Function(NavigationRequest request)? onNavigationRequest`
* `void Function(String url)? onPageStarted`
* `void Function(String url)? onPageFinished`
* `void Function(int progress)? onProgress`
* `void Function(WebResourceError error)? onWebResourceError`
* `void Function(UrlChange change)? onUrlChange`
* `void Function(HttpAuthRequest request)? onHttpAuthRequest`
* `void Function(HttpResponseError error)? onHttpError`
* `void Function(SslAuthError request)? onSslAuthError`

For `onSslAuthError`, the host **must** call `SslAuthError.cancel()` or `SslAuthError.proceed()`.

### `NavigationDelegate.fromPlatformCreationParams(PlatformNavigationDelegateCreationParams params, {...same callbacks})`

Uses platform-specific delegate params.

### `NavigationDelegate.fromPlatform(PlatformNavigationDelegate platform, {...})`

Wraps an existing platform delegate. `onUrlChange`, `onHttpAuthRequest`, `onHttpError`, and `onSslAuthError` are constructor-only (not stored as public fields). `onHttpAuthRequest` uses `HttpAuthRequestCallback`.

## Public fields

Stored on the Dart object:

* `final PlatformNavigationDelegate platform`
* `final NavigationRequestCallback? onNavigationRequest`
* `final PageEventCallback? onPageStarted`
* `final PageEventCallback? onPageFinished`
* `final ProgressCallback? onProgress`
* `final WebResourceErrorCallback? onWebResourceError`

## Callback semantics

### `onNavigationRequest`

Invoked when a navigation is pending (for example the user taps a link). Return `NavigationDecision.navigate` or `NavigationDecision.prevent`.

Some platforms also invoke this from `WebViewController.loadRequest`.

`NavigationRequest`:

* `final String url`
* `final bool isMainFrame`

On Android, iOS, and macOS, custom schemes (`bilibili://`, `weixin://`, `intent://`, `mailto:`, `tel:`) are opened in the matching system app. This callback still receives the URL; `prevent` blocks the handoff. Windows and Linux do not implement the handoff. Web is browser-owned.

| Platform | Support |
| --- | --- |
| Android, iOS, macOS, Windows, Linux | Full |
| Web | Limited: controller loads and observable iframe loads |

### `onPageStarted` / `onPageFinished`

Main-frame load started/finished. Argument is the URL `String`. Web: iframe load events.

### `onProgress`

Load progress `int` (typically 0–100). Web: synthetic `0`/`100` plus load event.

### `onWebResourceError`

Resource load failure. `WebResourceError`:

* `final int errorCode` — raw platform code
* `final String description`
* `final WebResourceErrorType? errorType`
* `final bool? isForMainFrame`
* `final String? url`

Web: fetch failures only for the custom request path.

### `onUrlChange`

`UrlChange.url` is `String?`. Web may report a logical URL.

### `onHttpAuthRequest`

HTTP authentication challenge. Not available as a browser iframe event on Web.

`HttpAuthRequest`:

* `final void Function(WebViewCredential credential) onProceed`
* `final void Function() onCancel`
* `final String host`
* `final String? realm`

```dart
onHttpAuthRequest: (HttpAuthRequest request) {
  request.onProceed(
    const WebViewCredential(user: 'user', password: 'secret'),
  );
},
```

`WebViewCredential` requires `user` and `password` (`String`).

### `onHttpError`

HTTP status error. `HttpResponseError`:

* `final WebResourceRequest? request` — `uri` (`Uri`)
* `final WebResourceResponse? response` — `uri` (`Uri?`), `statusCode` (`int`), `headers` (`Map<String, String>`)

Web: fetch-backed loads expose the response.

### `onSslAuthError`

Recoverable TLS certificate error. Not available as a browser iframe event on Web.

# SslAuthError

The host **must** call `cancel()` or `proceed()`. `proceed()` is for test environments; using it in production exposes users to security risks.

## Properties

* `final PlatformSslAuthError platform` — cast after `is` (`AndroidSslAuthError`, `WebKitSslAuthError`, …)
* `X509Certificate? get certificate` — `X509Certificate.data` is `Uint8List?` DER bytes when the engine provides a certificate

## Methods

### `Future<void> cancel()`

Terminate communication with the server. Default for production.

### `Future<void> proceed()`

Ignore the error and continue. Strongly discouraged in production.

```dart
NavigationDelegate(
  onSslAuthError: (SslAuthError error) async {
    await error.cancel();
  },
);
```
