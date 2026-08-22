// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// When a [UserScript] is injected into a page.
enum UserScriptInjectionTime {
  /// Inject after the document element is created, before any other content.
  documentStart,

  /// Inject after the document finishes loading, before subresources.
  documentEnd,
}

/// A script that is injected into every navigation of a WebView.
@immutable
class UserScript {
  /// Creates a [UserScript].
  const UserScript({
    required this.source,
    this.injectionTime = UserScriptInjectionTime.documentStart,
    this.forMainFrameOnly = true,
  });

  /// JavaScript source to inject.
  final String source;

  /// When the script is injected relative to document loading.
  final UserScriptInjectionTime injectionTime;

  /// Whether the script is injected only into the main frame.
  ///
  /// On Android this flag is best-effort because document-start injection uses
  /// origin rules rather than a main-frame-only option.
  final bool forMainFrameOnly;
}
