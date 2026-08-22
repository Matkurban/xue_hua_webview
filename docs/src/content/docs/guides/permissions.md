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

```dart
await (controller.platform as AndroidWebViewController)
    .setOnShowFileSelector((FileSelectorParams params) async {
  debugPrint('accept=${params.acceptTypes}');
  return <String>['/path/to/file.png'];
});
```

`FileSelectorParams` includes:

| Field | Meaning |
| --- | --- |
| `isCaptureEnabled` | The page prefers live capture such as camera or microphone. |
| `acceptTypes` | MIME types accepted by the page. |
| `filenameHint` | Suggested filename when the mode allows saving. |
| `mode` | `open`, `openMultiple`, or `save`. |

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
