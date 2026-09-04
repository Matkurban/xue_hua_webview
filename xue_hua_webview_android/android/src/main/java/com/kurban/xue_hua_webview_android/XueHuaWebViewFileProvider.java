// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.kurban.xue_hua_webview_android;

import androidx.core.content.FileProvider;

/** Dedicated {@link FileProvider} so camera capture URIs do not collide with the host app. */
public class XueHuaWebViewFileProvider extends FileProvider {}
