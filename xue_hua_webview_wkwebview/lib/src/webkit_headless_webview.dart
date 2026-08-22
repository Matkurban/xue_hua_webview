// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'webkit_webview_controller.dart';

/// Creation parameters for [WebKitHeadlessWebView].
class WebKitHeadlessWebViewCreationParams
    extends PlatformHeadlessWebViewCreationParams {
  /// Constructs a [WebKitHeadlessWebViewCreationParams].
  const WebKitHeadlessWebViewCreationParams({super.controllerParams});

  /// Constructs a [WebKitHeadlessWebViewCreationParams] using a
  /// [PlatformHeadlessWebViewCreationParams].
  WebKitHeadlessWebViewCreationParams.fromPlatformHeadlessWebViewCreationParams(
    PlatformHeadlessWebViewCreationParams params,
  ) : super(controllerParams: params.controllerParams);
}

/// A WKWebView that can load content without a [WebKitWebViewWidget].
class WebKitHeadlessWebView extends PlatformHeadlessWebView {
  /// Constructs a [WebKitHeadlessWebView].
  WebKitHeadlessWebView(PlatformHeadlessWebViewCreationParams params)
    : controller = WebKitWebViewController(
        params is WebKitHeadlessWebViewCreationParams
            ? params.controllerParams
            : params.controllerParams,
      ),
      super.implementation(
        params is WebKitHeadlessWebViewCreationParams
            ? params
            : WebKitHeadlessWebViewCreationParams.fromPlatformHeadlessWebViewCreationParams(
                params,
              ),
      );

  @override
  final WebKitWebViewController controller;

  bool _running = false;
  bool _disposed = false;

  @override
  bool get isRunning => _running && !_disposed;

  @override
  Future<void> run() async {
    if (_disposed) {
      throw StateError('This headless WebView has already been disposed.');
    }
    _running = true;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _running = false;
    await controller.dispose();
  }
}
