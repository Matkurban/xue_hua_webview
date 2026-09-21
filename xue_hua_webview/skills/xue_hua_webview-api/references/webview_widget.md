# WebViewWidget

Import: `package:xue_hua_webview/xue_hua_webview.dart`.

`StatelessWidget` that displays the native WebView. Supported on Android, iOS, macOS, Windows, Linux, and Web.

## Constructors

### `WebViewWidget({Key? key, required WebViewController controller, TextDirection layoutDirection = TextDirection.ltr, Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{}})`

Builds the current platform WebView.

* `controller` (required): the controller created earlier. One controller may be attached to only one widget at a time.
* `layoutDirection`: defaults to `TextDirection.ltr`.
* `gestureRecognizers`: gestures the WebView should claim. Empty (default) means the WebView only handles pointer events not claimed by another recognizer. Use this when the WebView sits inside a `ListView` that would otherwise steal vertical drags.

### `WebViewWidget.fromPlatformCreationParams({Key? key, required PlatformWebViewWidgetCreationParams params})`

Builds with platform-specific widget params (for example `AndroidWebViewWidgetCreationParams` or `WindowsWebViewWidgetCreationParams`).

`PlatformWebViewWidgetCreationParams` fields:

* `Key? key`
* `required PlatformWebViewController controller` — pass `controller.platform`, not the app-facing controller
* `TextDirection layoutDirection` (default `ltr`)
* `Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers` (default empty)

```dart
PlatformWebViewWidgetCreationParams params = PlatformWebViewWidgetCreationParams(
  controller: controller.platform,
  layoutDirection: TextDirection.ltr,
  gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
);

if (WebViewPlatform.instance is AndroidWebViewPlatform) {
  params = AndroidWebViewWidgetCreationParams
      .fromPlatformWebViewWidgetCreationParams(params);
}

final WebViewWidget widget = WebViewWidget.fromPlatformCreationParams(
  params: params,
);
```

### `WebViewWidget.fromPlatform({Key? key, required PlatformWebViewWidget platform})`

Wraps an existing `PlatformWebViewWidget`.

## Properties

### `final PlatformWebViewWidget platform`

Underlying platform widget. Cast after `is` checks (`WebKitWebViewWidget`, `AndroidWebViewWidget`, …).

### `late final TextDirection layoutDirection`

From `platform.params.layoutDirection`.

### `late final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers`

From `platform.params.gestureRecognizers`.

## Methods

### `Widget build(BuildContext context)`

Delegates to `platform.build(context)`. Do not call this yourself; Flutter does.

## Notes

* Create the `WebViewController` in `State.initState`, not in `build`.
* Unmounting the widget does not dispose the controller.
