---
title: iOS and macOS
description: WKWebView implementation, WebKit APIs, and Apple platform differences.
---

iOS and macOS are provided by `xue_hua_webview_wkwebview ^1.1.0`. `xue_hua_webview` registers it as the default implementation for both Apple platforms.

## Engine

| Item | Value |
| --- | --- |
| Package | `xue_hua_webview_wkwebview` |
| Main platform class | `WebKitWebViewPlatform` |
| Controller | `WebKitWebViewController` |
| Widget | `WebKitWebViewWidget` |
| Navigation delegate | `WebKitNavigationDelegate` |
| Cookie manager | `WebKitWebViewCookieManager` |
| Engine | `WKWebView` |
| Minimum iOS | 13.0+ |
| Minimum macOS | 10.15+ |

## Creation Params

```dart
final params = WebKitWebViewControllerCreationParams(
  allowsInlineMediaPlayback: true,
  mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
  limitsNavigationsToAppBoundDomains: false,
  javaScriptCanOpenWindowsAutomatically: true,
);

final controller = WebViewController.fromPlatformCreationParams(params);
```

| Param | Meaning |
| --- | --- |
| `mediaTypesRequiringUserAction` | Set of `PlaybackMediaTypes.audio` and `PlaybackMediaTypes.video` that require user gesture. Empty set allows autoplay. |
| `allowsInlineMediaPlayback` | Allows inline HTML5 video playback instead of fullscreen-only playback. |
| `limitsNavigationsToAppBoundDomains` | Enables App-Bound Domains on iOS 14+ and macOS 11+. Earlier systems log the requirement and keep the native default. |
| `javaScriptCanOpenWindowsAutomatically` | Controls JavaScript popup permission. `null` uses the native default. |

## Controller API

| API | Purpose |
| --- | --- |
| `setAllowsBackForwardNavigationGestures(bool enabled)` | Enables swipe navigation gestures. |
| `setAllowsLinkPreview(bool allow)` | Enables or disables link previews where supported. |
| `setOnCanGoBackChange(callback)` | Receives `canGoBack` state changes. |
| `setInspectable(bool inspectable)` | Enables WebKit inspection on iOS 16.4+ and macOS 13.3+. Earlier systems log the requirement and safely ignore the call. |
| `loadFileWithParams(WebKitLoadFileParams params)` | Loads a local file with an explicit read access scope. |

## Local Files

```dart
await (controller.platform as WebKitWebViewController).loadFileWithParams(
  WebKitLoadFileParams(
    absoluteFilePath: '/Users/me/site/index.html',
    readAccessPath: '/Users/me/site',
  ),
);
```

`readAccessPath` must include any local resources referenced by the loaded page.

## JavaScript Channels

Use `WebKitJavaScriptChannelParams` when constructing platform-specific channel params directly:

```dart
await controller.platform.addJavaScriptChannel(
  WebKitJavaScriptChannelParams(
    name: 'Host',
    onMessageReceived: (JavaScriptMessage message) {},
  ),
);
```

The common `WebViewController.addJavaScriptChannel` automatically converts common params to WebKit params.

## Permissions

`WebKitWebViewPermissionRequest` supports:

| Method | Meaning |
| --- | --- |
| `grant()` | Approves the resource request. |
| `deny()` | Denies the resource request. |
| `prompt()` | Lets the system prompt the user where supported. |

Your app still needs the corresponding `Info.plist` privacy description keys.

## File Selector

iOS uses WKWebView's built-in picker for `<input type="file">`. There is no
`WKUIDelegate.runOpenPanel` hook. Add `NSCameraUsageDescription` for `capture`
and `NSPhotoLibraryUsageDescription` when older photo-library flows can appear.

macOS implements `webView(_:runOpenPanelWith:initiatedByFrame:completionHandler:)`
with `NSOpenPanel`. Multiple selection and directory choice follow
`WKOpenPanelParameters`. Cancel or a missing window calls `completionHandler(nil)`.
Sandboxed apps need `com.apple.security.files.user-selected.read-only`.

On macOS, a new WKWebView appends a Safari-compatible
`applicationNameForUserAgent` suffix (`Version/x.0 Safari/605.1.15`) when the
configuration still uses the system default app name. Sites that reject a bare
AppleWebKit user agent can load without a Dart override. `setUserAgent` still
replaces the full string.

## External App URLs

Custom schemes from page content are opened with `UIApplication` / `NSWorkspace`
and the navigation is cancelled so WKWebView does not try to load them.
`onNavigationRequest` still receives the URL; `prevent` skips the system open.

The plugin does not add `LSApplicationQueriesSchemes`. Direct `open` does not
need that list. Declare schemes in the host `Info.plist` only if the app itself
calls `canOpenURL`.

## Web Authentication and Passkeys

`WKWebView` handles WebAuthn challenges through WebKit, so there is no Android-
style enable switch and `xue_hua_webview` does not add one. To use passkeys, add
the relying-party domain to the host app's Associated Domains configuration
and configure the website-side association described by
[Apple's passkey documentation](https://developer.apple.com/documentation/authenticationservices/supporting-passkeys).

Associated Domains for passkeys are separate from
`limitsNavigationsToAppBoundDomains`; enabling App-Bound Domains does not
configure passkey access. Actual authenticator and conditional-mediation
availability depends on the OS and installed credential providers. The page
should use the standard `PublicKeyCredential` availability checks and provide
another sign-in method when they report that no authenticator is available.

## macOS Differences

The same Dart package targets iOS and macOS. macOS support uses public native
WebKit APIs with runtime availability checks; it does not inject JavaScript to
emulate missing view APIs.

| Area | macOS limit |
| --- | --- |
| Scroll position and callbacks | macOS `WKWebView` does not publicly expose its internal scroll view. Calls log the limitation and safely no-op; reads return `Offset.zero`. |
| Scrollbar visibility and overscroll | No public macOS `WKWebView` API is available. Calls log the limitation and safely no-op. |
| Background color | Uses native `underPageBackgroundColor` on macOS 12+. Earlier versions log the requirement and safely no-op. |
| Zoom | Uses native `allowsMagnification`; no JavaScript fallback is used. |
| Inspection | Requires macOS 13.3+. Earlier versions log the requirement and safely no-op. |
| Link preview | Availability depends on platform support. |

These compatibility decisions are handled by `xue_hua_webview_wkwebview`, not by
the main `xue_hua_webview` controller.

## Engine Shutdown

The child plugin performs idempotent teardown when the iOS application
terminates or the Flutter engine detaches: calls to Dart are disabled and
Pigeon handlers and instances are cleared. Repeated lifecycle callbacks are
harmless. A scene disconnect does not tear down a still-running engine,
because `FlutterSceneDelegate` can report disconnect while the binary
messenger is still alive. macOS continues to use Flutter's engine-detach
callback.

Scene lifecycle registration is enabled automatically when the Flutter engine
exposes the public scene protocol. The iOS native `WKWebView` accessor also
accepts a `FlutterPluginRegistrar`: it uses Flutter's registrar lookup when
available and an engine-isolated compatibility lookup on earlier supported
Flutter versions. No host application changes are required.

## Known Limits

- WebKit may reject JavaScript return values that cannot be bridged to Dart.
- App-Bound Domains require host app configuration and iOS 14+ or macOS 11+.
- Passkeys require the relying-party domain to be configured as an Associated
  Domain and remain subject to OS and credential-provider availability.
- Permission handling still depends on OS privacy entitlements and user decisions.
- `runJavaScriptAsync` requires iOS 14 or macOS 11 (`callAsyncJavaScript`).
  Earlier systems return `JavaScriptAsyncResult.error`.
- `addUserScript` maps to `WKUserScript`. `removeAllUserScripts` removes every
  script on the content controller, then re-injects internal channel, console,
  and zoom scripts plus remaining user scripts.
- `WebViewStorageManager` uses `WKWebsiteDataStore.defaultDataStore` and does
  not need a live WebView.
- Headless WKWebView instances are created with the controller; `dispose()`
  releases Dart-side native references.
