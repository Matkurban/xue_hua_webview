// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'platform_headless_webview.dart';
import 'platform_navigation_delegate.dart';
import 'platform_webview_controller.dart';
import 'platform_webview_cookie_manager.dart';
import 'platform_webview_storage_manager.dart';
import 'platform_webview_widget.dart';
import 'types/types.dart';

// TODO(bparrishMines): This should be removed once xue_hua_webview_android and
// xue_hua_webview_wkwebview no longer depend on this file in tests.
export 'types/types.dart';

/// Interface for a platform implementation of a WebView.
abstract class WebViewPlatform extends PlatformInterface {
  /// Creates a new [WebViewPlatform].
  WebViewPlatform() : super(token: _token);

  static final Object _token = Object();

  static WebViewPlatform? _instance;

  /// The instance of [WebViewPlatform] to use.
  static WebViewPlatform? get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [WebViewPlatform] when they register themselves.
  static set instance(WebViewPlatform? instance) {
    if (instance == null) {
      throw AssertionError(
        'Platform interfaces can only be set to a non-null instance',
      );
    }

    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Creates a new [PlatformWebViewCookieManager].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewCookieManager] in `xue_hua_webview` instead.
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformCookieManager is not implemented on the current platform.',
    );
  }

  /// Creates a new [PlatformNavigationDelegate].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [NavigationDelegate] in `xue_hua_webview` instead.
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformNavigationDelegate is not implemented on the current platform.',
    );
  }

  /// Create a new [PlatformWebViewController].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewController] in `xue_hua_webview` instead.
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformWebViewController is not implemented on the current platform.',
    );
  }

  /// Create a new [PlatformWebViewWidget].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewWidget] in `xue_hua_webview` instead.
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformWebViewWidget is not implemented on the current platform.',
    );
  }

  /// Create a new [PlatformWebViewStorageManager].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [WebViewStorageManager] in `xue_hua_webview` instead.
  PlatformWebViewStorageManager createPlatformStorageManager(
    PlatformWebViewStorageManagerCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformStorageManager is not implemented on the current platform.',
    );
  }

  /// Create a new [PlatformHeadlessWebView].
  ///
  /// This function should only be called by the app-facing package.
  /// Look at using [HeadlessWebView] in `xue_hua_webview` instead.
  PlatformHeadlessWebView createPlatformHeadlessWebView(
    PlatformHeadlessWebViewCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformHeadlessWebView is not implemented on the current platform.',
    );
  }
}
