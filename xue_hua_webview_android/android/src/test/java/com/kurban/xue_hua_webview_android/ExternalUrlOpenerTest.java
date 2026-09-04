// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.kurban.xue_hua_webview_android;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import org.junit.Test;

public class ExternalUrlOpenerTest {
  @Test
  public void httpsIsNotExternal() {
    assertFalse(ExternalUrlOpener.isExternal("https://www.bilibili.com"));
    assertFalse(ExternalUrlOpener.isExternal(Uri.parse("https://www.bilibili.com")));
    assertFalse(ExternalUrlOpener.isExternal("http://example.com"));
    assertFalse(ExternalUrlOpener.isExternal("about:blank"));
    assertFalse(ExternalUrlOpener.isExternal("data:text/html,hi"));
    assertFalse(ExternalUrlOpener.isExternal("blob:https://example.com/1"));
    assertFalse(ExternalUrlOpener.isExternal("file:///tmp/a.html"));
    assertFalse(ExternalUrlOpener.isExternal("content://media/1"));
    assertFalse(ExternalUrlOpener.isExternal("javascript:alert(1)"));
    assertFalse(ExternalUrlOpener.isExternal((String) null));
    assertFalse(ExternalUrlOpener.isExternal((Uri) null));
    assertFalse(ExternalUrlOpener.isExternal("not-a-url"));
  }

  @Test
  public void customSchemesAreExternal() {
    assertTrue(ExternalUrlOpener.isExternal("bilibili://root"));
    assertTrue(ExternalUrlOpener.isExternal(Uri.parse("bilibili://root")));
    assertTrue(ExternalUrlOpener.isExternal("weixin://dl/business"));
    assertTrue(ExternalUrlOpener.isExternal("alipays://platformapi/startapp"));
    assertTrue(ExternalUrlOpener.isExternal("mailto:a@b.com"));
    assertTrue(ExternalUrlOpener.isExternal("tel:+123"));
    assertTrue(ExternalUrlOpener.isExternal("intent://scan/#Intent;scheme=zxing;end"));
  }

  @Test
  public void browserFallbackUrl() {
    final String intentUrl =
        "intent://host/#Intent;scheme=bilibili;S.browser_fallback_url=https%3A%2F%2Fexample.com%2Fapp;end";
    assertEquals("https://example.com/app", ExternalUrlOpener.browserFallbackUrl(intentUrl));
    assertNull(ExternalUrlOpener.browserFallbackUrl("bilibili://root"));
    assertNull(ExternalUrlOpener.browserFallbackUrl(null));
  }

  @Test
  public void openStartsViewActivity() {
    final Context context = mock(Context.class);
    assertNull(ExternalUrlOpener.open(context, Uri.parse("bilibili://root")));
    verify(context).startActivity(any(Intent.class));
  }

  @Test
  public void openReturnsHttpsFallbackWhenAppMissing() {
    final Context context = mock(Context.class);
    doThrow(new ActivityNotFoundException()).when(context).startActivity(any(Intent.class));
    final String intentUrl =
        "intent://host/#Intent;scheme=bilibili;S.browser_fallback_url=https%3A%2F%2Fexample.com%2Fapp;end";
    assertEquals("https://example.com/app", ExternalUrlOpener.open(context, Uri.parse(intentUrl)));
  }

  @Test
  public void openIgnoresExternalFallback() {
    final Context context = mock(Context.class);
    doThrow(new ActivityNotFoundException()).when(context).startActivity(any(Intent.class));
    final String intentUrl =
        "intent://host/#Intent;scheme=bilibili;S.browser_fallback_url=bilibili%3A%2F%2Froot;end";
    assertNull(ExternalUrlOpener.open(context, Uri.parse(intentUrl)));
  }
}
