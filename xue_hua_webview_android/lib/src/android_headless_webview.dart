// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'android_webview_controller.dart';

/// Creation parameters for [AndroidHeadlessWebView].
class AndroidHeadlessWebViewCreationParams
    extends PlatformHeadlessWebViewCreationParams {
  /// Constructs a [AndroidHeadlessWebViewCreationParams].
  const AndroidHeadlessWebViewCreationParams({super.controllerParams});

  /// Constructs a [AndroidHeadlessWebViewCreationParams] using a
  /// [PlatformHeadlessWebViewCreationParams].
  AndroidHeadlessWebViewCreationParams.fromPlatformHeadlessWebViewCreationParams(
    PlatformHeadlessWebViewCreationParams params,
  ) : super(controllerParams: params.controllerParams);
}

/// An Android WebView that can load content without a [AndroidWebViewWidget].
class AndroidHeadlessWebView extends PlatformHeadlessWebView {
  /// Constructs a [AndroidHeadlessWebView].
  AndroidHeadlessWebView(PlatformHeadlessWebViewCreationParams params)
    : controller = AndroidWebViewController(params.controllerParams),
      super.implementation(
        params is AndroidHeadlessWebViewCreationParams
            ? params
            : AndroidHeadlessWebViewCreationParams.fromPlatformHeadlessWebViewCreationParams(
                params,
              ),
      );

  @override
  final AndroidWebViewController controller;

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
