---
title: Permissions
description: Handle camera, microphone, geolocation, media, and file selector permission flows.
---

Web content permission flow has two layers:

1. The app must have the operating system permission.
2. The WebView must approve the web page request.

`WebViewController(onPermissionRequest: ...)` or `setOnPlatformPermissionRequest` handles the WebView layer.

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

Call `grant()` or `deny()` once. Platform request objects ignore duplicate decisions where possible.

## Common Resource Types

| Type | Meaning |
| --- | --- |
| `WebViewPermissionResourceType.camera` | Camera capture. |
| `WebViewPermissionResourceType.microphone` | Audio capture. |

## Platform-Specific Resource Types

| Platform | Type | Meaning |
| --- | --- | --- |
| Android | `AndroidWebViewPermissionResourceType.midiSysex` | MIDI sysex access. |
| Android | `AndroidWebViewPermissionResourceType.protectedMediaId` | Protected media identifier. |

## Geolocation

```dart
final android = controller.platform as AndroidWebViewController;

await android.setGeolocationPermissionsPromptCallbacks(
  onShowPrompt: (GeolocationPermissionsRequestParams request) async {
    return const GeolocationPermissionsResponse(
      allow: true,
      retain: false,
    );
  },
  onHidePrompt: () {
    debugPrint('Geolocation prompt hidden');
  },
);
```

```dart
  onShowPrompt: (request) async {
    return const GeolocationPermissionsResponse(
      allow: true,
      retain: false,
    );
  },
);
```

Geolocation generally requires secure origins (`https`) in modern engines.

## File Selector

`<input type="file">` works without a Dart callback:

| Platform | Behavior |
| --- | --- |
| Android | Built-in Photo Picker for image/video, `ACTION_GET_CONTENT` for other MIME types, camera when `capture` is set. |
| iOS | WKWebView system picker (PHPicker / document picker). |
| macOS | `WKUIDelegate.runOpenPanel` presents `NSOpenPanel`. |
| Windows / Linux / Web | Engine or browser dialog. Engine-owned; no common Dart callback. |

Cancel, permission denial, and errors complete the native callback with `null` so the input can be used again.

Android Photo Picker and SAF do **not** need `READ_MEDIA_*` or `READ_EXTERNAL_STORAGE`. Camera capture requests `CAMERA` at runtime. Declare `CAMERA` in the host `AndroidManifest.xml`. iOS pages that use `capture` or a photo library picker need `NSCameraUsageDescription` and usually `NSPhotoLibraryUsageDescription` in `Info.plist`. Missing usage strings can crash the app.

Optional Android override:

```dart
await (controller.platform as AndroidWebViewController)
    .setOnShowFileSelector((FileSelectorParams params) async {
  debugPrint('accept=${params.acceptTypes}');
  return <String>['content://media/picker/0'];
});
```

Return an empty list to cancel. `FileSelectorParams` includes:

| Field | Meaning |
| --- | --- |
| `isCaptureEnabled` | The page prefers live capture such as camera or microphone. |
| `acceptTypes` | MIME types accepted by the page. |
| `filenameHint` | Suggested filename when the mode allows saving. |
| `mode` | `open`, `openMultiple`, or `save`. |

Add `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` (API 33+) or `READ_EXTERNAL_STORAGE` (API 32 and below) only if this custom callback reads the MediaStore directly.

## Fullscreen Custom Widgets

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

## Web Permissions

The web implementation can mediate `navigator.mediaDevices.getUserMedia` for
same-origin content and plugin-managed isolated HTML by wrapping the page API.
It can report camera and microphone requests to `onPermissionRequest`.

The browser still owns the final permission prompt. `request.grant()` only allows the page call to continue to the browser permission layer.
