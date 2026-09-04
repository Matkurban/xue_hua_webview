// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package android.net;

import androidx.annotation.NonNull;

// Creates an implementation of Uri that can be used with unittests and the JVM. Typically
// android.net.Uri does nothing when not used with an Android environment.
public class Uri {
  private final String url;

  public static Uri parse(String url) {
    return new Uri(url);
  }

  private Uri(String url) {
    this.url = url;
  }

  public String getScheme() {
    final int colon = url.indexOf(':');
    if (colon <= 0) {
      return null;
    }
    return url.substring(0, colon);
  }

  @NonNull
  @Override
  public String toString() {
    return url;
  }
}
