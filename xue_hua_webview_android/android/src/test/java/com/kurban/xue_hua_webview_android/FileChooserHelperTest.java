// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.kurban.xue_hua_webview_android;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient.FileChooserParams;
import com.kurban.xue_hua_webview_android.FileChooserHelper.Host;
import com.kurban.xue_hua_webview_android.FileChooserHelper.MediaKind;
import java.util.Arrays;
import java.util.Collections;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

public class FileChooserHelperTest {
  private FakeHost host;
  private FileChooserHelper helper;

  @Before
  public void setUp() {
    host = new FakeHost();
    helper = new FileChooserHelper(host);
  }

  @Test
  public void classifyAcceptTypes() {
    assertEquals(MediaKind.ANY, FileChooserHelper.classifyAcceptTypes(new String[] {}));
    assertEquals(MediaKind.ANY, FileChooserHelper.classifyAcceptTypes(new String[] {"", " "}));
    assertEquals(MediaKind.IMAGE, FileChooserHelper.classifyAcceptTypes(new String[] {"image/*"}));
    assertEquals(
        MediaKind.IMAGE, FileChooserHelper.classifyAcceptTypes(new String[] {"image/png"}));
    assertEquals(MediaKind.VIDEO, FileChooserHelper.classifyAcceptTypes(new String[] {"video/*"}));
    assertEquals(
        MediaKind.MEDIA,
        FileChooserHelper.classifyAcceptTypes(new String[] {"image/*", "video/*"}));
    assertEquals(
        MediaKind.ANY, FileChooserHelper.classifyAcceptTypes(new String[] {"application/pdf"}));
    assertEquals(
        MediaKind.ANY,
        FileChooserHelper.classifyAcceptTypes(new String[] {"image/*", "application/pdf"}));
  }

  @Test
  public void shouldUsePhotoPicker() {
    assertTrue(FileChooserHelper.shouldUsePhotoPicker(new String[] {"image/*"}));
    assertTrue(FileChooserHelper.shouldUsePhotoPicker(new String[] {"video/mp4"}));
    assertFalse(FileChooserHelper.shouldUsePhotoPicker(new String[] {}));
    assertFalse(FileChooserHelper.shouldUsePhotoPicker(new String[] {"*/*"}));
    assertFalse(FileChooserHelper.shouldUsePhotoPicker(new String[] {".pdf"}));
  }

  @Test
  public void isVideoCapture() {
    assertTrue(FileChooserHelper.isVideoCapture(new String[] {"video/*"}));
    assertFalse(FileChooserHelper.isVideoCapture(new String[] {"image/*"}));
    assertFalse(FileChooserHelper.isVideoCapture(new String[] {}));
  }

  @Test
  public void mimeTypesForGetContent() {
    assertArrayEquals(
        new String[] {"*/*"}, FileChooserHelper.mimeTypesForGetContent(new String[] {}));
    assertArrayEquals(
        new String[] {"application/pdf"},
        FileChooserHelper.mimeTypesForGetContent(new String[] {"application/pdf"}));
  }

  @Test
  public void getContentIntentTypeUsesWildcardForMultipleMimes() {
    assertEquals("*/*", FileChooserHelper.getContentIntentType(new String[] {}));
    assertEquals("application/pdf", FileChooserHelper.getContentIntentType(new String[] {"application/pdf"}));
    assertEquals(
        "*/*",
        FileChooserHelper.getContentIntentType(new String[] {"image/*", "application/pdf"}));
  }

  @Test
  public void parseActivityResultCancelReturnsNull() {
    assertNull(
        FileChooserHelper.parseActivityResult(Activity.RESULT_CANCELED, new Intent(), null));
  }

  @Test
  public void parseActivityResultSingleUri() {
    final Intent data = mock(Intent.class);
    final Uri uri = Uri.parse("content://media/1");
    when(data.getData()).thenReturn(uri);
    when(data.getClipData()).thenReturn(null);

    assertArrayEquals(
        new Uri[] {uri}, FileChooserHelper.parseActivityResult(Activity.RESULT_OK, data, null));
  }

  @Test
  public void parseActivityResultPrefersCaptureUri() {
    final Uri capture = Uri.parse("content://capture/1");
    assertArrayEquals(
        new Uri[] {capture},
        FileChooserHelper.parseActivityResult(Activity.RESULT_OK, null, capture));
  }

  @Test
  public void startWithoutActivityCompletesNull() {
    host.activity = null;
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    final FileChooserParams params = mock(FileChooserParams.class);
    when(params.getAcceptTypes()).thenReturn(new String[] {"image/*"});
    when(params.getMode()).thenReturn(FileChooserParams.MODE_OPEN);
    when(params.isCaptureEnabled()).thenReturn(false);

    helper.start(callback, params);

    verify(callback).onReceiveValue(null);
  }

  @Test
  public void startImageUsesPhotoPickerWhenAvailable() {
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    final FileChooserParams params = mock(FileChooserParams.class);
    when(params.getAcceptTypes()).thenReturn(new String[] {"image/*"});
    when(params.getMode()).thenReturn(FileChooserParams.MODE_OPEN);
    when(params.isCaptureEnabled()).thenReturn(false);

    helper.start(callback, params);

    assertEquals("photo:IMAGE:false", host.lastLaunch);
    verify(callback, never()).onReceiveValue(any());
  }

  @Test
  public void startMultipleImagesUsesPhotoPicker() {
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    final FileChooserParams params = mock(FileChooserParams.class);
    when(params.getAcceptTypes()).thenReturn(new String[] {"image/*"});
    when(params.getMode()).thenReturn(FileChooserParams.MODE_OPEN_MULTIPLE);
    when(params.isCaptureEnabled()).thenReturn(false);

    helper.start(callback, params);

    assertEquals("photo:IMAGE:true", host.lastLaunch);
  }

  @Test
  public void startPdfUsesGetContent() {
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    final FileChooserParams params = mock(FileChooserParams.class);
    when(params.getAcceptTypes()).thenReturn(new String[] {"application/pdf"});
    when(params.getMode()).thenReturn(FileChooserParams.MODE_OPEN);
    when(params.isCaptureEnabled()).thenReturn(false);

    helper.start(callback, params);

    assertEquals("content:application/pdf:false", host.lastLaunch);
    verify(callback, never()).onReceiveValue(any());
  }

  @Test
  public void startCaptureWithoutPermissionRequestsCamera() {
    host.hasCameraPermission = false;
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    final FileChooserParams params = mock(FileChooserParams.class);
    when(params.getAcceptTypes()).thenReturn(new String[] {"image/*"});
    when(params.getMode()).thenReturn(FileChooserParams.MODE_OPEN);
    when(params.isCaptureEnabled()).thenReturn(true);

    helper.start(callback, params);

    assertTrue(host.cameraPermissionRequested);
    verify(callback, never()).onReceiveValue(any());
  }

  @Test
  public void permissionDeniedCompletesNull() {
    host.hasCameraPermission = false;
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    final FileChooserParams params = mock(FileChooserParams.class);
    when(params.getAcceptTypes()).thenReturn(new String[] {"image/*"});
    when(params.getMode()).thenReturn(FileChooserParams.MODE_OPEN);
    when(params.isCaptureEnabled()).thenReturn(true);

    helper.start(callback, params);
    helper.onRequestPermissionsResult(
        helper.getInFlightPermissionCode(),
        new String[] {"android.permission.CAMERA"},
        new int[] {PackageManager.PERMISSION_DENIED});

    verify(callback).onReceiveValue(null);
  }

  @Test
  public void permissionGrantedLaunchesCamera() {
    host.hasCameraPermission = false;
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    final FileChooserParams params = mock(FileChooserParams.class);
    when(params.getAcceptTypes()).thenReturn(new String[] {"image/*"});
    when(params.getMode()).thenReturn(FileChooserParams.MODE_OPEN);
    when(params.isCaptureEnabled()).thenReturn(true);

    helper.start(callback, params);
    helper.onRequestPermissionsResult(
        helper.getInFlightPermissionCode(),
        new String[] {"android.permission.CAMERA"},
        new int[] {PackageManager.PERMISSION_GRANTED});

    assertEquals("camera:false", host.lastLaunch);
    verify(callback, never()).onReceiveValue(any());
  }

  @Test
  public void activityCancelCompletesNull() {
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    final FileChooserParams params = mock(FileChooserParams.class);
    when(params.getAcceptTypes()).thenReturn(new String[] {"image/*"});
    when(params.getMode()).thenReturn(FileChooserParams.MODE_OPEN);
    when(params.isCaptureEnabled()).thenReturn(false);

    helper.start(callback, params);
    helper.onActivityResult(
        helper.getInFlightChooserCode(), Activity.RESULT_CANCELED, null);

    verify(callback).onReceiveValue(null);
  }

  @Test
  public void replacePendingCancelsPreviousCallback() {
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> first = mock(ValueCallback.class);
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> second = mock(ValueCallback.class);

    helper.replacePendingCallback(first);
    helper.replacePendingCallback(second);

    verify(first).onReceiveValue(null);
    verify(second, never()).onReceiveValue(any());

    helper.completePending(null);
    verify(second).onReceiveValue(null);
  }

  @Test
  public void completePendingIsIdempotent() {
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    helper.replacePendingCallback(callback);
    helper.completePending(null);
    helper.completePending(new Uri[] {Uri.parse("content://x")});

    verify(callback, times(1)).onReceiveValue(null);
  }

  @Test
  public void completeFromDartStringsEmptyCancels() {
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    helper.replacePendingCallback(callback);
    helper.completeFromDartStrings(callback, Collections.emptyList());
    verify(callback).onReceiveValue(null);
  }

  @Test
  public void completeFromDartStringsParsesUris() {
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    helper.replacePendingCallback(callback);
    helper.completeFromDartStrings(callback, Arrays.asList("content://a", "content://b"));

    final ArgumentCaptor<Uri[]> captor = ArgumentCaptor.forClass(Uri[].class);
    verify(callback).onReceiveValue(captor.capture());
    assertEquals(2, captor.getValue().length);
    assertEquals("content://a", captor.getValue()[0].toString());
    assertEquals("content://b", captor.getValue()[1].toString());
  }

  @Test
  public void staleDartResultDoesNotCompleteNewCallback() {
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> first = mock(ValueCallback.class);
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> second = mock(ValueCallback.class);
    helper.replacePendingCallback(first);
    helper.replacePendingCallback(second);
    helper.completeFromDartStrings(first, Arrays.asList("content://old"));

    verify(first).onReceiveValue(null);
    verify(second, never()).onReceiveValue(any());
  }

  @Test
  public void detachCompletesNull() {
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    helper.replacePendingCallback(callback);
    helper.onActivityDetached();
    verify(callback).onReceiveValue(null);
  }

  @Test
  public void photoPickerUnavailableFallsBackToGetContent() {
    host.photoPickerAvailable = false;
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    final FileChooserParams params = mock(FileChooserParams.class);
    when(params.getAcceptTypes()).thenReturn(new String[] {"image/*"});
    when(params.getMode()).thenReturn(FileChooserParams.MODE_OPEN);
    when(params.isCaptureEnabled()).thenReturn(false);

    helper.start(callback, params);

    assertEquals("content:image/*:false", host.lastLaunch);
  }

  @Test
  public void staleChooserResultDoesNotCompleteNewCallback() {
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> first = mock(ValueCallback.class);
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> second = mock(ValueCallback.class);
    final FileChooserParams params = mock(FileChooserParams.class);
    when(params.getAcceptTypes()).thenReturn(new String[] {"image/*"});
    when(params.getMode()).thenReturn(FileChooserParams.MODE_OPEN);
    when(params.isCaptureEnabled()).thenReturn(false);

    helper.start(first, params);
    final int firstCode = helper.getInFlightChooserCode();
    helper.start(second, params);
    final int secondCode = helper.getInFlightChooserCode();

    verify(first).onReceiveValue(null);
    assertTrue(firstCode != secondCode);

    final Intent data = mock(Intent.class);
    when(data.getData()).thenReturn(Uri.parse("content://stale"));
    when(data.getClipData()).thenReturn(null);
    assertTrue(helper.onActivityResult(firstCode, Activity.RESULT_OK, data));
    verify(second, never()).onReceiveValue(any());

    assertTrue(helper.onActivityResult(secondCode, Activity.RESULT_CANCELED, null));
    verify(second).onReceiveValue(null);
  }

  @Test
  public void unrelatedRequestCodeIsIgnored() {
    @SuppressWarnings("unchecked")
    final ValueCallback<Uri[]> callback = mock(ValueCallback.class);
    final FileChooserParams params = mock(FileChooserParams.class);
    when(params.getAcceptTypes()).thenReturn(new String[] {"image/*"});
    when(params.getMode()).thenReturn(FileChooserParams.MODE_OPEN);
    when(params.isCaptureEnabled()).thenReturn(false);

    helper.start(callback, params);
    assertFalse(helper.onActivityResult(0x1234, Activity.RESULT_OK, new Intent()));
    verify(callback, never()).onReceiveValue(any());
  }

  private static final class FakeHost implements Host {
    Activity activity = mock(Activity.class);
    boolean photoPickerAvailable = true;
    boolean hasCameraPermission = true;
    boolean cameraPermissionRequested;
    String lastLaunch;

    @Override
    public Activity getActivity() {
      return activity;
    }

    @Override
    public boolean isPhotoPickerAvailable() {
      return photoPickerAvailable;
    }

    @Override
    public boolean hasCameraPermission() {
      return hasCameraPermission;
    }

    @Override
    public void requestCameraPermission() {
      cameraPermissionRequested = true;
    }

    @Override
    public boolean launchPhotoPicker(MediaKind kind, boolean multiple) {
      lastLaunch = "photo:" + kind + ":" + multiple;
      return true;
    }

    @Override
    public boolean launchGetContent(String[] mimeTypes, boolean multiple) {
      lastLaunch = "content:" + mimeTypes[0] + ":" + multiple;
      return true;
    }

    @Override
    public boolean launchCameraCapture(boolean video) {
      lastLaunch = "camera:" + video;
      return true;
    }
  }
}
