// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'platform_webview_controller_creation_params.dart';

/// Object specifying creation parameters for creating a
/// [PlatformHeadlessWebView].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// When extending [PlatformHeadlessWebViewCreationParams] additional
/// parameters should always accept `null` or have a default value to prevent
/// breaking changes.
@immutable
class PlatformHeadlessWebViewCreationParams {
  /// Used by the platform implementation to create a new headless WebView.
  const PlatformHeadlessWebViewCreationParams({
    this.controllerParams = const PlatformWebViewControllerCreationParams(),
  });

  /// Parameters used to construct the underlying [PlatformWebViewController].
  final PlatformWebViewControllerCreationParams controllerParams;
}
