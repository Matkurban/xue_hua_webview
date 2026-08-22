// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

/// Clears cookies, HTTP cache, and DOM storage for the whole app process.
///
/// Unlike [WebViewController.clearCache], this API can run when no WebView is
/// currently mounted.
class WebViewStorageManager {
  /// Constructs a [WebViewStorageManager].
  WebViewStorageManager()
    : this.fromPlatformCreationParams(
        const PlatformWebViewStorageManagerCreationParams(),
      );

  /// Constructs a [WebViewStorageManager] from creation params for a specific
  /// platform.
  WebViewStorageManager.fromPlatformCreationParams(
    PlatformWebViewStorageManagerCreationParams params,
  ) : this.fromPlatform(PlatformWebViewStorageManager(params));

  /// Constructs a [WebViewStorageManager] from a specific platform
  /// implementation.
  WebViewStorageManager.fromPlatform(this.platform);

  /// Implementation of [PlatformWebViewStorageManager] for the current
  /// platform.
  final PlatformWebViewStorageManager platform;

  /// Removes website data of the given [dataTypes] modified after [since].
  ///
  /// Defaults to wiping every type the current platform can clear.
  Future<void> removeData({
    Set<WebViewDataType> dataTypes = const <WebViewDataType>{
      WebViewDataType.all,
    },
    DateTime? since,
  }) {
    return platform.removeData(dataTypes: dataTypes, since: since);
  }
}
