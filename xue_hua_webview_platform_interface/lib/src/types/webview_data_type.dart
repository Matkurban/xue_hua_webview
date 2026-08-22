// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Kinds of website data that [PlatformWebViewStorageManager.removeData] can
/// wipe.
enum WebViewDataType {
  /// HTTP cookies.
  cookies,

  /// HTTP disk and memory caches.
  httpCache,

  /// `window.localStorage`.
  localStorage,

  /// `window.sessionStorage`.
  sessionStorage,

  /// IndexedDB databases.
  indexedDb,

  /// WebSQL databases.
  webSql,

  /// Every website data type the current platform can clear.
  all,
}
