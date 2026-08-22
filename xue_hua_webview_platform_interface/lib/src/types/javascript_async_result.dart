// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Result of [PlatformWebViewController.runJavaScriptAsync].
@immutable
class JavaScriptAsyncResult {
  /// Creates a [JavaScriptAsyncResult].
  const JavaScriptAsyncResult({this.value, this.error});

  /// Decoded JSON value returned by the script when it settled successfully.
  final Object? value;

  /// JavaScript exception, engine error, or timeout message.
  ///
  /// `null` when [value] was produced successfully.
  final String? error;

  /// Whether the async JavaScript call failed.
  bool get hasError => error != null;
}
