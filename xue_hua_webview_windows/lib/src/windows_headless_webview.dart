// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'windows_webview_controller.dart';

/// Creation parameters for [WindowsHeadlessWebView].
class WindowsHeadlessWebViewCreationParams
    extends PlatformHeadlessWebViewCreationParams {
  /// Constructs a [WindowsHeadlessWebViewCreationParams].
  const WindowsHeadlessWebViewCreationParams({super.controllerParams});

  /// Constructs a [WindowsHeadlessWebViewCreationParams] using a
  /// [PlatformHeadlessWebViewCreationParams].
  WindowsHeadlessWebViewCreationParams.fromPlatformHeadlessWebViewCreationParams(
    PlatformHeadlessWebViewCreationParams params,
  ) : super(controllerParams: params.controllerParams);
}

/// A WebView2 instance that can load content without a [WindowsWebViewWidget].
class WindowsHeadlessWebView extends PlatformHeadlessWebView {
  /// Constructs a [WindowsHeadlessWebView].
  WindowsHeadlessWebView(PlatformHeadlessWebViewCreationParams params)
    : controller = WindowsWebViewController(params.controllerParams),
      super.implementation(
        params is WindowsHeadlessWebViewCreationParams
            ? params
            : WindowsHeadlessWebViewCreationParams.fromPlatformHeadlessWebViewCreationParams(
                params,
              ),
      );

  @override
  final WindowsWebViewController controller;

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
