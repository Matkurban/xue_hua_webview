# Xue Hua WebView

[Documentation](https://matkurban.github.io/xue_hua_webview) | [中文文档](https://matkurban.github.io/xue_hua_webview/zh)

支持所有 Flutter 平台的 WebView 组件，兼容[webview_flutter](https://pub.dev/packages/webview_flutter)接口。

|     系统     | **支持情况** | **技术实现** |
|-------------|--------------|--------------|
|Android|API 24+|[WebView](https://developer.android.com/reference/android/webkit/WebView)|
|iOS|13.0+|[WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)|
|macOS|10.15+|[WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)|
|Windows|Win10 1809+|[WebView2](https://developer.microsoft.com/microsoft-edge/webview2)|
|Linux|webkit2gtk-4.1|[WebKitGTK](https://webkitgtk.org)|
|Web|Any|[js-interop](https://dart.dev/interop/js-interop)|

## 快速入门

1. 实例化一个 `WebViewController`:

```dart
controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..loadRequest(Uri.parse('https://flutter.dev'));
```

2. 将 controller 传给 `WebViewWidget`:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Flutter Simple Example')),
    body: WebViewWidget(controller: controller),
  );
}
```

更详细的用法、接口覆盖和平台限制请参考[中文文档](https://matkurban.github.io/xue_hua_webview/zh)。

## 文件选择与权限

各端 `<input type="file">` 无需 Dart 回调即可使用。Android 使用内置 Photo
Picker / `ACTION_GET_CONTENT` / 相机；iOS 使用 WKWebView 系统选择器；macOS
使用 `NSOpenPanel`；Windows、Linux 和 Web 使用引擎或浏览器对话框。

宿主应用必须自行声明相机、麦克风等系统权限。插件**不会**合并
`READ_MEDIA_*` 或 `READ_EXTERNAL_STORAGE`；Photo Picker 与 SAF 不需要这些权限。

### Android `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET" />
<!-- <input type="file" capture> 与 getUserMedia 相机需要 -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

仅当应用用自定义 `setOnShowFileSelector` 直接读 MediaStore 时，才需要自行声明
API 33+ 的 `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO`，或 API 32 及以下的
`READ_EXTERNAL_STORAGE`。

可选覆盖：

```dart
await (controller.platform as AndroidWebViewController)
    .setOnShowFileSelector((FileSelectorParams params) async {
  return <String>['content://...'];
});
```

### iOS `Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>允许网页在你同意后使用相机。</string>
<key>NSMicrophoneUsageDescription</key>
<string>允许网页在你同意后使用麦克风。</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>允许网页在你同意后选择照片或视频。</string>
```

缺少相机或相册用途说明时，页面使用 `capture` 或旧版相册选择器可能崩溃。

### macOS entitlements

沙盒应用弹出文件对话框需要：

```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

## 贡献

请阅读[贡献与规范](https://matkurban.github.io/xue_hua_webview/zh/release/contributing/)和
[CONTRIBUTING-ZH.md](https://github.com/Matkurban/xue_hua_webview/blob/main/CONTRIBUTING-ZH.md)。

仓库搬家后，先在 `xue_hua_webview/example` 执行 `flutter clean` 再编 macOS。
构建成功（`Built .../example.app`）时仍可能刷 `Stale file ... allowed root
paths`，可以忽略。
