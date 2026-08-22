// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'android_webkit.g.dart';

/// Creation parameters for [AndroidWebViewStorageManager].
class AndroidWebViewStorageManagerCreationParams
    extends PlatformWebViewStorageManagerCreationParams {
  /// Constructs a [AndroidWebViewStorageManagerCreationParams].
  const AndroidWebViewStorageManagerCreationParams();

  /// Constructs a [AndroidWebViewStorageManagerCreationParams] using a
  /// [PlatformWebViewStorageManagerCreationParams].
  const AndroidWebViewStorageManagerCreationParams.fromPlatformWebViewStorageManagerCreationParams(
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewStorageManagerCreationParams params,
  );
}

/// Clears Android WebView cookies, HTTP cache, and JavaScript storage.
class AndroidWebViewStorageManager extends PlatformWebViewStorageManager {
  /// Constructs a [AndroidWebViewStorageManager].
  AndroidWebViewStorageManager(PlatformWebViewStorageManagerCreationParams params)
    : super.implementation(
        params is AndroidWebViewStorageManagerCreationParams
            ? params
            : const AndroidWebViewStorageManagerCreationParams(),
      );

  @override
  Future<void> removeData({
    Set<WebViewDataType> dataTypes = const <WebViewDataType>{
      WebViewDataType.all,
    },
    DateTime? since,
  }) async {
    final bool clearAll = dataTypes.contains(WebViewDataType.all);
    if (clearAll || dataTypes.contains(WebViewDataType.cookies)) {
      await CookieManager.instance.removeAllCookies();
    }
    if (clearAll ||
        dataTypes.contains(WebViewDataType.localStorage) ||
        dataTypes.contains(WebViewDataType.sessionStorage) ||
        dataTypes.contains(WebViewDataType.indexedDb) ||
        dataTypes.contains(WebViewDataType.webSql)) {
      await WebStorage.instance.deleteAllData();
    }
    if (clearAll || dataTypes.contains(WebViewDataType.httpCache)) {
      await WebView.clearHttpCache();
    }
  }
}
