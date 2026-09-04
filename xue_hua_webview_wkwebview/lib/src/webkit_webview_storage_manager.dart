// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'common/web_kit.g.dart';

/// Creation parameters for [WebKitWebViewStorageManager].
class WebKitWebViewStorageManagerCreationParams
    extends PlatformWebViewStorageManagerCreationParams {
  /// Constructs a [WebKitWebViewStorageManagerCreationParams].
  const WebKitWebViewStorageManagerCreationParams();

  /// Constructs a [WebKitWebViewStorageManagerCreationParams] using a
  /// [PlatformWebViewStorageManagerCreationParams].
  const WebKitWebViewStorageManagerCreationParams.fromPlatformWebViewStorageManagerCreationParams(
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewStorageManagerCreationParams params,
  );
}

/// Clears WKWebsiteDataStore data without a live WebView.
class WebKitWebViewStorageManager extends PlatformWebViewStorageManager {
  /// Constructs a [WebKitWebViewStorageManager].
  WebKitWebViewStorageManager(
    PlatformWebViewStorageManagerCreationParams params,
  ) : super.implementation(
        params is WebKitWebViewStorageManagerCreationParams
            ? params
            : const WebKitWebViewStorageManagerCreationParams(),
      );

  WKWebsiteDataStore get _dataStore => WKWebsiteDataStore.defaultDataStore;

  @override
  Future<void> removeData({
    Set<WebViewDataType> dataTypes = const <WebViewDataType>{
      WebViewDataType.all,
    },
    DateTime? since,
  }) {
    final double modificationTime =
        (since ?? DateTime.fromMillisecondsSinceEpoch(0))
            .millisecondsSinceEpoch /
        1000;
    return _dataStore.removeDataOfTypes(
      _toWebsiteDataTypes(dataTypes),
      modificationTime,
    );
  }

  List<WebsiteDataType> _toWebsiteDataTypes(Set<WebViewDataType> dataTypes) {
    if (dataTypes.contains(WebViewDataType.all)) {
      return <WebsiteDataType>[
        WebsiteDataType.cookies,
        WebsiteDataType.memoryCache,
        WebsiteDataType.diskCache,
        WebsiteDataType.offlineWebApplicationCache,
        WebsiteDataType.localStorage,
        WebsiteDataType.sessionStorage,
        WebsiteDataType.webSQLDatabases,
        WebsiteDataType.indexedDBDatabases,
      ];
    }

    final List<WebsiteDataType> types = <WebsiteDataType>[];
    for (final WebViewDataType type in dataTypes) {
      switch (type) {
        case WebViewDataType.cookies:
          types.add(WebsiteDataType.cookies);
        case WebViewDataType.httpCache:
          types.addAll(<WebsiteDataType>[
            WebsiteDataType.memoryCache,
            WebsiteDataType.diskCache,
            WebsiteDataType.offlineWebApplicationCache,
          ]);
        case WebViewDataType.localStorage:
          types.add(WebsiteDataType.localStorage);
        case WebViewDataType.sessionStorage:
          types.add(WebsiteDataType.sessionStorage);
        case WebViewDataType.indexedDb:
          types.add(WebsiteDataType.indexedDBDatabases);
        case WebViewDataType.webSql:
          types.add(WebsiteDataType.webSQLDatabases);
        case WebViewDataType.all:
          break;
      }
    }
    return types;
  }
}
