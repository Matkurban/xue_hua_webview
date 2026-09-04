// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.kurban.xue_hua_webview_android;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import java.net.URISyntaxException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;

/**
 * Opens page-initiated custom schemes ({@code bilibili://}, {@code intent://}, {@code mailto:})
 * with the system instead of loading them in WebView.
 */
public final class ExternalUrlOpener {
  private static final Set<String> WEB_VIEW_SCHEMES =
      new HashSet<>(
          Arrays.asList("http", "https", "about", "data", "blob", "file", "content"));
  private static final String INTENT_SCHEME = "intent";
  private static final String JAVASCRIPT_SCHEME = "javascript";
  private static final String FALLBACK_MARKER = "S.browser_fallback_url=";

  private ExternalUrlOpener() {}

  public static boolean isExternal(@Nullable Uri uri) {
    return uri != null && isExternal(uri.toString());
  }

  public static boolean isExternal(@Nullable String url) {
    final String scheme = schemeOf(url);
    if (scheme == null || scheme.isEmpty() || JAVASCRIPT_SCHEME.equals(scheme)) {
      return false;
    }
    return !WEB_VIEW_SCHEMES.contains(scheme);
  }

  /**
   * Starts the matching app. Returns an https/http fallback URL when the app is
   * missing and the {@code intent://} URI includes {@code S.browser_fallback_url}.
   */
  @Nullable
  public static String open(@Nullable Context context, @Nullable Uri uri) {
    if (context == null || uri == null || !isExternal(uri)) {
      return null;
    }
    final String url = uri.toString();
    try {
      final Intent intent = intentFor(url);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(intent);
      return null;
    } catch (Exception exception) {
      return fallbackIfWeb(url);
    }
  }

  @Nullable
  @VisibleForTesting
  static String browserFallbackUrl(@Nullable String url) {
    if (url == null) {
      return null;
    }
    final int marker = url.indexOf(FALLBACK_MARKER);
    if (marker < 0) {
      return null;
    }
    final int start = marker + FALLBACK_MARKER.length();
    int end = url.indexOf(';', start);
    if (end < 0) {
      end = url.length();
    }
    final String encoded = url.substring(start, end);
    try {
      return URLDecoder.decode(encoded, StandardCharsets.UTF_8.name());
    } catch (Exception exception) {
      return encoded;
    }
  }

  @Nullable
  static String schemeOf(@Nullable String url) {
    if (url == null) {
      return null;
    }
    final int colon = url.indexOf(':');
    if (colon <= 0) {
      return null;
    }
    return url.substring(0, colon).toLowerCase(Locale.US);
  }

  @NonNull
  private static Intent intentFor(@NonNull String url) throws URISyntaxException {
    if (INTENT_SCHEME.equals(schemeOf(url))) {
      return Intent.parseUri(url, Intent.URI_INTENT_SCHEME);
    }
    return new Intent(Intent.ACTION_VIEW, Uri.parse(url));
  }

  @Nullable
  private static String fallbackIfWeb(@NonNull String url) {
    final String fallback = browserFallbackUrl(url);
    if (fallback != null && !isExternal(fallback)) {
      return fallback;
    }
    return null;
  }
}
