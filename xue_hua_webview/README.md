# Xue Hua WebView

[Documentation](https://matkurban.github.io/xue_hua_webview) | [中文文档](https://matkurban.github.io/xue_hua_webview/zh)

A WebView component for all Flutter platforms, compatible with the
[webview_flutter](https://pub.dev/packages/webview_flutter) API.

|     Platform     | **Support** | **Implementation** |
|-------------|--------------|--------------|
|Android|API 24+|[WebView](https://developer.android.com/reference/android/webkit/WebView)|
|iOS|13.0+|[WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)|
|macOS|10.15+|[WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)|
|Windows|Win10 1809+|[WebView2](https://developer.microsoft.com/microsoft-edge/webview2)|
|Linux|webkit2gtk-4.1|[WebKitGTK](https://webkitgtk.org)|
|Web|Any|[js-interop](https://dart.dev/interop/js-interop)|

## Quick Start

1. Instantiate a `WebViewController`:

```dart
controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..loadRequest(Uri.parse('https://flutter.dev'));
```

2. Pass `controller` to `WebViewWidget`:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Flutter Simple Example')),
    body: WebViewWidget(controller: controller),
  );
}
```

For detailed usage, API coverage, and platform limits, see the [Documentation](https://matkurban.github.io/xue_hua_webview).

## File inputs and permissions

`<input type="file">` works without a Dart callback on every platform. Android
uses a built-in Photo Picker / `ACTION_GET_CONTENT` / camera flow. iOS uses
WKWebView's system picker. macOS uses `NSOpenPanel`. Windows, Linux, and Web
use the engine or browser dialog.

The host app must declare the OS permissions that capture or media pages need.
The plugin does **not** merge `READ_MEDIA_*` or `READ_EXTERNAL_STORAGE`; Photo
Picker and the Storage Access Framework do not require them.

### Android `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET" />
<!-- Required for <input type="file" capture> and getUserMedia camera. -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

Add `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` (API 33+) or
`READ_EXTERNAL_STORAGE` (API 32 and below) only if the app implements a custom
`setOnShowFileSelector` that reads the MediaStore directly.

Optional override:

```dart
await (controller.platform as AndroidWebViewController)
    .setOnShowFileSelector((FileSelectorParams params) async {
  return <String>['content://...'];
});
```

### iOS `Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>This app allows pages to use the camera after you approve the request.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app allows pages to use the microphone after you approve the request.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app allows pages to pick photos or videos after you approve the request.</string>
```

Missing camera or photo-library usage strings can crash when a page uses
`capture` or an older photo picker.

### macOS entitlements

Sandboxed apps that show the file dialog need:

```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

## Contributing

See [Contributing](https://matkurban.github.io/xue_hua_webview/release/contributing/)
and [CONTRIBUTING.md](https://github.com/Matkurban/xue_hua_webview/blob/main/CONTRIBUTING.md).

After moving the repository, run `flutter clean` in `xue_hua_webview/example`
before the next macOS build. Harmless `Stale file ... allowed root paths`
warnings can appear even after a successful `Built .../example.app`.
