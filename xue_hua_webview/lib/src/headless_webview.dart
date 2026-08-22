// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'webview_controller.dart';

/// A WebView that can load pages and run JavaScript without a [WebViewWidget].
///
/// Use this for long-lived JS runtimes that never need to be shown.
///
/// ```dart
/// final HeadlessWebView headless = HeadlessWebView();
/// await headless.controller.setJavaScriptMode(JavaScriptMode.unrestricted);
/// await headless.run();
/// await headless.controller.loadRequest(Uri.parse('https://example.com'));
/// final JavaScriptAsyncResult result = await headless.controller
///     .runJavaScriptAsync('return await Promise.resolve(1 + 1);');
/// await headless.dispose();
/// ```
class HeadlessWebView {
  /// Constructs a [HeadlessWebView].
  ///
  /// See [HeadlessWebView.fromPlatformCreationParams] for setting parameters
  /// for a specific platform.
  HeadlessWebView({
    void Function(WebViewPermissionRequest request)? onPermissionRequest,
  }) : this.fromPlatformCreationParams(
         const PlatformHeadlessWebViewCreationParams(),
         onPermissionRequest: onPermissionRequest,
       );

  /// Constructs a [HeadlessWebView] from creation params for a specific
  /// platform.
  HeadlessWebView.fromPlatformCreationParams(
    PlatformHeadlessWebViewCreationParams params, {
    void Function(WebViewPermissionRequest request)? onPermissionRequest,
  }) : this.fromPlatform(
         PlatformHeadlessWebView(params),
         onPermissionRequest: onPermissionRequest,
       );

  /// Constructs a [HeadlessWebView] from a specific platform implementation.
  HeadlessWebView.fromPlatform(
    this.platform, {
    void Function(WebViewPermissionRequest request)? onPermissionRequest,
  }) : controller = WebViewController.fromPlatform(
         platform.controller,
         onPermissionRequest: onPermissionRequest,
       );

  /// Implementation of [PlatformHeadlessWebView] for the current platform.
  final PlatformHeadlessWebView platform;

  /// The controller that drives this headless WebView.
  final WebViewController controller;

  /// Whether [run] has completed and [dispose] has not been called.
  bool get isRunning => platform.isRunning;

  /// Starts the native WebView so it can load content without a widget.
  Future<void> run() => platform.run();

  /// Releases native resources owned by this headless WebView.
  Future<void> dispose() => platform.dispose();
}
