// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'windows_webview_native.dart' as native_webview;

/// Creation parameters for [WindowsWebViewStorageManager].
class WindowsWebViewStorageManagerCreationParams
    extends PlatformWebViewStorageManagerCreationParams {
  /// Constructs a [WindowsWebViewStorageManagerCreationParams].
  const WindowsWebViewStorageManagerCreationParams();

  /// Constructs a [WindowsWebViewStorageManagerCreationParams] using a
  /// [PlatformWebViewStorageManagerCreationParams].
  const WindowsWebViewStorageManagerCreationParams.fromPlatformWebViewStorageManagerCreationParams(
    PlatformWebViewStorageManagerCreationParams params,
  );
}

/// Clears WebView2 cookies, cache, and DOM storage without a visible widget.
class WindowsWebViewStorageManager extends PlatformWebViewStorageManager {
  /// Constructs a [WindowsWebViewStorageManager].
  WindowsWebViewStorageManager(
    PlatformWebViewStorageManagerCreationParams params,
  ) : super.implementation(
        params is WindowsWebViewStorageManagerCreationParams
            ? params
            : const WindowsWebViewStorageManagerCreationParams(),
      );

  @override
  Future<void> removeData({
    Set<WebViewDataType> dataTypes = const <WebViewDataType>{
      WebViewDataType.all,
    },
    DateTime? since,
  }) async {
    final native_webview.WebviewController controller =
        native_webview.WebviewController();
    await controller.initialize();
    try {
      final bool clearAll = dataTypes.contains(WebViewDataType.all);
      if (clearAll || dataTypes.contains(WebViewDataType.cookies)) {
        await controller.clearCookiesWithResult();
      }
      if (clearAll || dataTypes.contains(WebViewDataType.httpCache)) {
        await controller.clearCache();
      }
      if (clearAll ||
          dataTypes.contains(WebViewDataType.localStorage) ||
          dataTypes.contains(WebViewDataType.sessionStorage) ||
          dataTypes.contains(WebViewDataType.indexedDb) ||
          dataTypes.contains(WebViewDataType.webSql)) {
        await controller.clearLocalStorage();
      }
    } finally {
      await controller.dispose();
    }
  }
}
