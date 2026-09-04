// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'types/types.dart';
import 'webview_platform.dart' show WebViewPlatform;

/// Interface for a platform implementation of a website-data manager.
///
/// Unlike per-controller [PlatformWebViewController.clearCache], this API can
/// run when no WebView is currently mounted.
///
/// Platform implementations should extend this class rather than implement it
/// as `xue_hua_webview` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [PlatformWebViewStorageManager] methods.
abstract class PlatformWebViewStorageManager extends PlatformInterface {
  /// Creates a new [PlatformWebViewStorageManager].
  factory PlatformWebViewStorageManager(
    PlatformWebViewStorageManagerCreationParams params,
  ) {
    assert(
      WebViewPlatform.instance != null,
      'A platform implementation for `xue_hua_webview` has not been set. Please '
      'ensure that an implementation of `WebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebViewStorageManager storageManagerDelegate = WebViewPlatform
        .instance!
        .createPlatformStorageManager(params);
    PlatformInterface.verify(storageManagerDelegate, _token);
    return storageManagerDelegate;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformWebViewStorageManager].
  @protected
  PlatformWebViewStorageManager.implementation(this.params)
    : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformWebViewStorageManager].
  final PlatformWebViewStorageManagerCreationParams params;

  /// Removes website data of the given [dataTypes] that was modified after
  /// [since].
  ///
  /// When [dataTypes] contains [WebViewDataType.all], every type the current
  /// platform can wipe is cleared.
  Future<void> removeData({
    Set<WebViewDataType> dataTypes = const <WebViewDataType>{
      WebViewDataType.all,
    },
    DateTime? since,
  }) {
    throw UnimplementedError(
      'removeData is not implemented on the current platform',
    );
  }
}
