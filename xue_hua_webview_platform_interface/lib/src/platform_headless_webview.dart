// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'platform_webview_controller.dart';
import 'types/types.dart';
import 'webview_platform.dart' show WebViewPlatform;

/// Interface for a platform implementation of a headless (offscreen) WebView.
///
/// A headless WebView can load URLs, run JavaScript, and receive navigation
/// callbacks without inserting a [PlatformWebViewWidget] into the Flutter tree.
///
/// Platform implementations should extend this class rather than implement it
/// as `xue_hua_webview` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [PlatformHeadlessWebView] methods.
abstract class PlatformHeadlessWebView extends PlatformInterface {
  /// Creates a new [PlatformHeadlessWebView].
  factory PlatformHeadlessWebView(
    PlatformHeadlessWebViewCreationParams params,
  ) {
    assert(
      WebViewPlatform.instance != null,
      'A platform implementation for `xue_hua_webview` has not been set. Please '
      'ensure that an implementation of `WebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformHeadlessWebView headlessDelegate = WebViewPlatform.instance!
        .createPlatformHeadlessWebView(params);
    PlatformInterface.verify(headlessDelegate, _token);
    return headlessDelegate;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformHeadlessWebView].
  @protected
  PlatformHeadlessWebView.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformHeadlessWebView].
  final PlatformHeadlessWebViewCreationParams params;

  /// The controller that drives this headless WebView.
  PlatformWebViewController get controller {
    throw UnimplementedError(
      'controller is not implemented on the current platform',
    );
  }

  /// Whether [run] has completed and [dispose] has not been called.
  bool get isRunning {
    throw UnimplementedError(
      'isRunning is not implemented on the current platform',
    );
  }

  /// Starts the native WebView so it can load content without a widget.
  Future<void> run() {
    throw UnimplementedError(
      'run is not implemented on the current platform',
    );
  }

  /// Releases native resources owned by this headless WebView.
  Future<void> dispose() {
    throw UnimplementedError(
      'dispose is not implemented on the current platform',
    );
  }
}
