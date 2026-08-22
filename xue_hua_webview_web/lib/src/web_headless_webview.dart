// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'web_webview_controller.dart';

/// Creation parameters for [WebHeadlessWebView].
class WebHeadlessWebViewCreationParams
    extends PlatformHeadlessWebViewCreationParams {
  /// Constructs a [WebHeadlessWebViewCreationParams].
  const WebHeadlessWebViewCreationParams({super.controllerParams});

  /// Constructs a [WebHeadlessWebViewCreationParams] using a
  /// [PlatformHeadlessWebViewCreationParams].
  WebHeadlessWebViewCreationParams.fromPlatformHeadlessWebViewCreationParams(
    PlatformHeadlessWebViewCreationParams params,
  ) : super(controllerParams: params.controllerParams);
}

/// A hidden iframe WebView that can load content without a [WebWebViewWidget].
class WebHeadlessWebView extends PlatformHeadlessWebView {
  /// Constructs a [WebHeadlessWebView].
  WebHeadlessWebView(PlatformHeadlessWebViewCreationParams params)
    : controller = WebWebViewController(params.controllerParams),
      super.implementation(
        params is WebHeadlessWebViewCreationParams
            ? params
            : WebHeadlessWebViewCreationParams.fromPlatformHeadlessWebViewCreationParams(
                params,
              ),
      );

  @override
  final WebWebViewController controller;

  bool _running = false;
  bool _disposed = false;

  @override
  bool get isRunning => _running && !_disposed;

  @override
  Future<void> run() async {
    if (_disposed) {
      throw StateError('This headless WebView has already been disposed.');
    }
    controller.attachOffscreen();
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
