---
title: 权限
description: 处理摄像头、麦克风、定位、媒体和文件选择权限。
---

Web 内容权限有两层：

1. 宿主应用必须拥有系统权限。
2. WebView 必须批准网页请求。

```dart
final controller = WebViewController(
  onPermissionRequest: (WebViewPermissionRequest request) async {
    if (request.types.contains(WebViewPermissionResourceType.camera)) {
      await request.grant();
    } else {
      await request.deny();
    }
  },
);
```

同一个 request 只应调用一次 `grant()` 或 `deny()`。

## 通用资源

| 类型 | 含义 |
| --- | --- |
| `WebViewPermissionResourceType.camera` | 摄像头。 |
| `WebViewPermissionResourceType.microphone` | 麦克风。 |

## 平台扩展资源

| 平台 | 类型 | 含义 |
| --- | --- | --- |
| Android | `AndroidWebViewPermissionResourceType.midiSysex` | MIDI sysex。 |
| Android | `AndroidWebViewPermissionResourceType.protectedMediaId` | 受保护媒体 ID。 |

## 定位权限

```dart
await (controller.platform as AndroidWebViewController)
    .setGeolocationPermissionsPromptCallbacks(
  onShowPrompt: (request) async {
    return const GeolocationPermissionsResponse(
      allow: true,
      retain: false,
    );
  },
);
```

现代 WebView 通常要求定位请求来自 `https` 等安全 origin。

## 文件选择

`<input type="file">` 无需 Dart 回调即可使用：

| 平台 | 行为 |
| --- | --- |
| Android | 图片/视频走 Photo Picker，其他 MIME 走 `ACTION_GET_CONTENT`，`capture` 打开相机。 |
| iOS | WKWebView 系统选择器（PHPicker / 文档选择器）。 |
| macOS | `WKUIDelegate.runOpenPanel` 弹出 `NSOpenPanel`。 |
| Windows / Linux / Web | 引擎或浏览器对话框。引擎回落，无公共 Dart 回调。 |

取消、权限拒绝和失败都会用 `null` 完成原生回调，避免输入框假死。

Android Photo Picker 与 SAF **不需要** `READ_MEDIA_*` 或 `READ_EXTERNAL_STORAGE`。相机直连会在运行时申请 `CAMERA`，宿主需在 `AndroidManifest.xml` 声明该权限。iOS 页面使用 `capture` 或相册选择时，需要在 `Info.plist` 声明 `NSCameraUsageDescription`，通常还要 `NSPhotoLibraryUsageDescription`。缺少用途说明可能导致崩溃。

可选的 Android 覆盖：

```dart
await (controller.platform as AndroidWebViewController)
    .setOnShowFileSelector((FileSelectorParams params) async {
  debugPrint('accept=${params.acceptTypes}');
  return <String>['content://media/picker/0'];
});
```

返回空列表表示取消。`FileSelectorParams` 包含 `isCaptureEnabled`、`acceptTypes`、`filenameHint` 和 `mode`。

仅当该自定义回调直接读取 MediaStore 时，才需要自行声明 API 33+ 的 `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO`，或 API 32 及以下的 `READ_EXTERNAL_STORAGE`。

## 全屏 custom widget

```dart
await (controller.platform as AndroidWebViewController)
    .setCustomWidgetCallbacks(
  onShowCustomWidget: (Widget widget, VoidCallback onHidden) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => widget,
      ),
    );
  },
  onHideCustomWidget: () {
    Navigator.of(context).pop();
  },
);
```

## Web 权限

Web 实现会在同源内容和插件管理的隔离 HTML 中包装
`navigator.mediaDevices.getUserMedia`，并把 camera/microphone 请求转发给
`onPermissionRequest`。即使应用调用 `grant()`，浏览器仍可能继续显示自己的
权限提示。
