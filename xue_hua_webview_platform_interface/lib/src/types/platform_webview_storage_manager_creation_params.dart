// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Object specifying creation parameters for creating a
/// [PlatformWebViewStorageManager].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// When extending [PlatformWebViewStorageManagerCreationParams] additional
/// parameters should always accept `null` or have a default value to prevent
/// breaking changes.
@immutable
class PlatformWebViewStorageManagerCreationParams {
  /// Used by the platform implementation to create a new storage manager.
  const PlatformWebViewStorageManagerCreationParams();
}
