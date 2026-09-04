// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:web/web.dart' as web;
import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'web_webview_cookie_manager.dart';

/// Creation parameters for [WebWebViewStorageManager].
class WebWebViewStorageManagerCreationParams
    extends PlatformWebViewStorageManagerCreationParams {
  /// Constructs a [WebWebViewStorageManagerCreationParams].
  const WebWebViewStorageManagerCreationParams();

  /// Constructs a [WebWebViewStorageManagerCreationParams] using a
  /// [PlatformWebViewStorageManagerCreationParams].
  const WebWebViewStorageManagerCreationParams.fromPlatformWebViewStorageManagerCreationParams(
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewStorageManagerCreationParams params,
  );
}

/// Clears host-origin cookies, cache, and DOM storage in the browser.
///
/// Cross-origin iframe storage is not reachable from the Flutter host page.
class WebWebViewStorageManager extends PlatformWebViewStorageManager {
  /// Constructs a [WebWebViewStorageManager].
  WebWebViewStorageManager(PlatformWebViewStorageManagerCreationParams params)
    : super.implementation(
        params is WebWebViewStorageManagerCreationParams
            ? params
            : const WebWebViewStorageManagerCreationParams(),
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
      await WebWebViewCookieManager(
        const WebWebViewCookieManagerCreationParams(),
      ).clearCookies();
    }
    if (clearAll || dataTypes.contains(WebViewDataType.localStorage)) {
      web.window.localStorage.clear();
    }
    if (clearAll || dataTypes.contains(WebViewDataType.sessionStorage)) {
      web.window.sessionStorage.clear();
    }
    if (clearAll || dataTypes.contains(WebViewDataType.httpCache)) {
      await _clearHttpCache();
    }
    if (clearAll ||
        dataTypes.contains(WebViewDataType.indexedDb) ||
        dataTypes.contains(WebViewDataType.webSql)) {
      await _clearIndexedDb();
    }
  }

  Future<void> _clearHttpCache() async {
    try {
      final web.CacheStorage caches = web.window.caches;
      final List<String> keys = (await caches.keys().toDart).toDart
          .map((JSString key) => key.toDart)
          .toList();
      for (final String key in keys) {
        await caches.delete(key).toDart;
      }
    } catch (_) {
      // Cache Storage may be unavailable in private browsing or tests.
    }
  }

  Future<void> _clearIndexedDb() async {
    try {
      final web.IDBFactory factory = web.window.indexedDB;
      final JSArray<web.IDBDatabaseInfo> databases = await factory
          .databases()
          .toDart;
      for (final web.IDBDatabaseInfo info in databases.toDart) {
        final String name = info.name;
        if (name.isNotEmpty) {
          factory.deleteDatabase(name);
        }
      }
    } catch (_) {
      // `indexedDB.databases()` is not available in every browser.
    }
  }
}
