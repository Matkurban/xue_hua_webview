// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.kurban.xue_hua_webview_android;

import android.Manifest;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.ClipData;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient.FileChooserParams;
import android.webkit.MimeTypeMap;
import androidx.activity.result.PickVisualMediaRequest;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;
import io.flutter.plugin.common.PluginRegistry;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

/**
 * Built-in Android file chooser for {@code <input type="file">}.
 *
 * <p>Always completes the WebView {@link ValueCallback} exactly once. Cancel, permission
 * denial, activity detach, and launch failures call {@code onReceiveValue(null)} so the input
 * can be used again.
 */
public class FileChooserHelper
    implements PluginRegistry.ActivityResultListener,
        PluginRegistry.RequestPermissionsResultListener {
  static final int REQUEST_CODE_FILE_CHOOSER_BASE = 0x5848;
  static final int REQUEST_CODE_CAMERA_PERMISSION_BASE = 0x5948;
  static final int REQUEST_CODE_GENERATION_MASK = 0xFF;
  static final int REQUEST_CODE_FILE_CHOOSER = REQUEST_CODE_FILE_CHOOSER_BASE;
  static final int REQUEST_CODE_CAMERA_PERMISSION = REQUEST_CODE_CAMERA_PERMISSION_BASE;
  static final int NO_REQUEST_CODE = 0;

  enum MediaKind {
    IMAGE,
    VIDEO,
    MEDIA,
    ANY
  }

  interface Host {
    @Nullable
    Activity getActivity();

    boolean isPhotoPickerAvailable();

    boolean hasCameraPermission();

    void requestCameraPermission();

    boolean launchPhotoPicker(@NonNull MediaKind kind, boolean multiple);

    boolean launchGetContent(@NonNull String[] mimeTypes, boolean multiple);

    boolean launchCameraCapture(boolean video);
  }

  @NonNull private Host host;
  @Nullable private Activity activity;
  @Nullable private ValueCallback<Uri[]> pendingCallback;
  @Nullable private Uri pendingCaptureUri;
  private boolean awaitingCameraPermission;
  private boolean pendingCaptureIsVideo;
  private int chooserGeneration;
  private int permissionGeneration;
  private int inFlightChooserCode = NO_REQUEST_CODE;
  private int inFlightPermissionCode = NO_REQUEST_CODE;

  public FileChooserHelper() {
    this.host = new DefaultHost();
  }

  @VisibleForTesting
  FileChooserHelper(@NonNull Host host) {
    this.host = host;
  }

  @VisibleForTesting
  void setHost(@NonNull Host host) {
    this.host = host;
  }

  void setActivity(@Nullable Activity activity) {
    this.activity = activity;
  }

  void onActivityDetached() {
    this.activity = null;
    completePending(null);
  }

  void replacePendingCallback(@NonNull ValueCallback<Uri[]> callback) {
    completePending(null);
    pendingCallback = callback;
  }

  void completePending(@Nullable Uri[] uris) {
    final ValueCallback<Uri[]> callback = pendingCallback;
    pendingCallback = null;
    pendingCaptureUri = null;
    awaitingCameraPermission = false;
    inFlightChooserCode = NO_REQUEST_CODE;
    inFlightPermissionCode = NO_REQUEST_CODE;
    if (callback != null) {
      callback.onReceiveValue(uris);
    }
  }

  void completeIfCurrent(@NonNull ValueCallback<Uri[]> expected, @Nullable Uri[] uris) {
    if (pendingCallback == expected) {
      completePending(uris);
    }
  }

  void completeFromDartStrings(
      @NonNull ValueCallback<Uri[]> expected, @Nullable List<String> value) {
    if (value == null || value.isEmpty()) {
      completeIfCurrent(expected, null);
      return;
    }
    final Uri[] filePaths = new Uri[value.size()];
    for (int i = 0; i < value.size(); i++) {
      filePaths[i] = Uri.parse(value.get(i));
    }
    completeIfCurrent(expected, filePaths);
  }

  void start(@NonNull ValueCallback<Uri[]> callback, @NonNull FileChooserParams params) {
    replacePendingCallback(callback);
    if (host.getActivity() == null) {
      completePending(null);
      return;
    }

    final String[] acceptTypes = params.getAcceptTypes();
    final boolean multiple = isMultiple(params.getMode());

    if (params.isCaptureEnabled()) {
      pendingCaptureIsVideo = isVideoCapture(acceptTypes);
      launchCapture(pendingCaptureIsVideo);
      return;
    }

    beginChooserRequest();
    final MediaKind kind = classifyAcceptTypes(acceptTypes);
    if (shouldUsePhotoPicker(acceptTypes) && host.isPhotoPickerAvailable()) {
      if (host.launchPhotoPicker(kind, multiple)) {
        return;
      }
    }

    if (!host.launchGetContent(mimeTypesForGetContent(acceptTypes), multiple)) {
      completePending(null);
    }
  }

  private void launchCapture(boolean video) {
    if (!host.hasCameraPermission()) {
      awaitingCameraPermission = true;
      beginPermissionRequest();
      host.requestCameraPermission();
      return;
    }
    beginChooserRequest();
    if (!host.launchCameraCapture(video)) {
      completePending(null);
    }
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
    if (!isChooserRequestCode(requestCode)) {
      return false;
    }
    if (requestCode != inFlightChooserCode) {
      return true;
    }
    completePending(parseActivityResult(resultCode, data, pendingCaptureUri));
    return true;
  }

  @Override
  public boolean onRequestPermissionsResult(
      int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    if (!isPermissionRequestCode(requestCode)) {
      return false;
    }
    if (requestCode != inFlightPermissionCode) {
      return true;
    }
    if (!awaitingCameraPermission) {
      return true;
    }
    awaitingCameraPermission = false;
    inFlightPermissionCode = NO_REQUEST_CODE;
    if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
      beginChooserRequest();
      if (!host.launchCameraCapture(pendingCaptureIsVideo)) {
        completePending(null);
      }
    } else {
      completePending(null);
    }
    return true;
  }

  private void beginChooserRequest() {
    chooserGeneration = (chooserGeneration + 1) & REQUEST_CODE_GENERATION_MASK;
    inFlightChooserCode = REQUEST_CODE_FILE_CHOOSER_BASE + chooserGeneration;
  }

  private void beginPermissionRequest() {
    permissionGeneration = (permissionGeneration + 1) & REQUEST_CODE_GENERATION_MASK;
    inFlightPermissionCode = REQUEST_CODE_CAMERA_PERMISSION_BASE + permissionGeneration;
  }

  static boolean isChooserRequestCode(int requestCode) {
    final int offset = requestCode - REQUEST_CODE_FILE_CHOOSER_BASE;
    return offset >= 0 && offset <= REQUEST_CODE_GENERATION_MASK;
  }

  static boolean isPermissionRequestCode(int requestCode) {
    final int offset = requestCode - REQUEST_CODE_CAMERA_PERMISSION_BASE;
    return offset >= 0 && offset <= REQUEST_CODE_GENERATION_MASK;
  }

  @VisibleForTesting
  int getInFlightChooserCode() {
    return inFlightChooserCode;
  }

  @VisibleForTesting
  int getInFlightPermissionCode() {
    return inFlightPermissionCode;
  }

  static boolean isMultiple(int mode) {
    return mode == FileChooserParams.MODE_OPEN_MULTIPLE;
  }

  @NonNull
  static List<String> normalizeAcceptTypes(@Nullable String[] acceptTypes) {
    if (acceptTypes == null || acceptTypes.length == 0) {
      return Collections.emptyList();
    }
    final List<String> result = new ArrayList<>();
    for (String raw : acceptTypes) {
      if (raw == null) {
        continue;
      }
      final String trimmed = raw.trim();
      if (!trimmed.isEmpty()) {
        result.add(trimmed);
      }
    }
    return result;
  }

  static boolean isImageType(@NonNull String type) {
    final String lower = type.toLowerCase(Locale.US);
    return lower.equals("image/*") || lower.startsWith("image/");
  }

  static boolean isVideoType(@NonNull String type) {
    final String lower = type.toLowerCase(Locale.US);
    return lower.equals("video/*") || lower.startsWith("video/");
  }

  @NonNull
  static MediaKind classifyAcceptTypes(@Nullable String[] acceptTypes) {
    final List<String> types = normalizeAcceptTypes(acceptTypes);
    if (types.isEmpty()) {
      return MediaKind.ANY;
    }
    boolean image = false;
    boolean video = false;
    boolean other = false;
    for (String type : types) {
      if (isImageType(type)) {
        image = true;
      } else if (isVideoType(type)) {
        video = true;
      } else {
        other = true;
      }
    }
    if (other) {
      return MediaKind.ANY;
    }
    if (image && video) {
      return MediaKind.MEDIA;
    }
    if (video) {
      return MediaKind.VIDEO;
    }
    if (image) {
      return MediaKind.IMAGE;
    }
    return MediaKind.ANY;
  }

  static boolean shouldUsePhotoPicker(@Nullable String[] acceptTypes) {
    final MediaKind kind = classifyAcceptTypes(acceptTypes);
    return kind == MediaKind.IMAGE || kind == MediaKind.VIDEO || kind == MediaKind.MEDIA;
  }

  static boolean isVideoCapture(@Nullable String[] acceptTypes) {
    return classifyAcceptTypes(acceptTypes) == MediaKind.VIDEO;
  }

  @NonNull
  static String[] mimeTypesForGetContent(@Nullable String[] acceptTypes) {
    final List<String> types = normalizeAcceptTypes(acceptTypes);
    if (types.isEmpty()) {
      return new String[] {"*/*"};
    }
    final List<String> mimes = new ArrayList<>();
    for (String type : types) {
      if (type.startsWith(".")) {
        final String fromExt =
            MimeTypeMap.getSingleton().getMimeTypeFromExtension(type.substring(1));
        mimes.add(fromExt != null ? fromExt : "*/*");
      } else {
        mimes.add(type);
      }
    }
    return mimes.toArray(new String[0]);
  }

  @NonNull
  static String getContentIntentType(@NonNull String[] mimeTypes) {
    if (mimeTypes.length != 1) {
      return "*/*";
    }
    return mimeTypes[0];
  }

  @Nullable
  static Uri[] parseActivityResult(
      int resultCode, @Nullable Intent data, @Nullable Uri captureUri) {
    if (resultCode != Activity.RESULT_OK) {
      return null;
    }
    if (captureUri != null) {
      return new Uri[] {captureUri};
    }
    if (data == null) {
      return null;
    }
    final List<Uri> uris = new ArrayList<>();
    final ClipData clip = data.getClipData();
    if (clip != null) {
      for (int i = 0; i < clip.getItemCount(); i++) {
        final Uri uri = clip.getItemAt(i).getUri();
        if (uri != null) {
          uris.add(uri);
        }
      }
    } else if (data.getData() != null) {
      uris.add(data.getData());
    }
    if (uris.isEmpty()) {
      return null;
    }
    return uris.toArray(new Uri[0]);
  }

  private class DefaultHost implements Host {
    @Nullable
    @Override
    public Activity getActivity() {
      return activity;
    }

    @Override
    public boolean isPhotoPickerAvailable() {
      final Activity current = activity;
      return current != null
          && ActivityResultContracts.PickVisualMedia.isPhotoPickerAvailable(current);
    }

    @Override
    public boolean hasCameraPermission() {
      final Activity current = activity;
      return current != null
          && ContextCompat.checkSelfPermission(current, Manifest.permission.CAMERA)
              == PackageManager.PERMISSION_GRANTED;
    }

    @Override
    public void requestCameraPermission() {
      final Activity current = activity;
      if (current == null) {
        completePending(null);
        return;
      }
      ActivityCompat.requestPermissions(
          current,
          new String[] {Manifest.permission.CAMERA},
          inFlightPermissionCode);
    }

    @Override
    public boolean launchPhotoPicker(@NonNull MediaKind kind, boolean multiple) {
      final Activity current = activity;
      if (current == null) {
        return false;
      }
      final ActivityResultContracts.PickVisualMedia.VisualMediaType mediaType;
      switch (kind) {
        case IMAGE:
          mediaType = ActivityResultContracts.PickVisualMedia.ImageOnly.INSTANCE;
          break;
        case VIDEO:
          mediaType = ActivityResultContracts.PickVisualMedia.VideoOnly.INSTANCE;
          break;
        default:
          mediaType = ActivityResultContracts.PickVisualMedia.ImageAndVideo.INSTANCE;
          break;
      }
      final PickVisualMediaRequest request =
          new PickVisualMediaRequest.Builder().setMediaType(mediaType).build();
      try {
        final Intent intent;
        if (multiple) {
          intent =
              new ActivityResultContracts.PickMultipleVisualMedia()
                  .createIntent(current, request);
        } else {
          intent = new ActivityResultContracts.PickVisualMedia().createIntent(current, request);
        }
        current.startActivityForResult(intent, inFlightChooserCode);
        return true;
      } catch (RuntimeException exception) {
        return false;
      }
    }

    @Override
    public boolean launchGetContent(@NonNull String[] mimeTypes, boolean multiple) {
      final Activity current = activity;
      if (current == null) {
        return false;
      }
      final Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
      intent.addCategory(Intent.CATEGORY_OPENABLE);
      intent.setType(getContentIntentType(mimeTypes));
      if (mimeTypes.length > 1) {
        intent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes);
      }
      if (multiple) {
        intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
      }
      try {
        current.startActivityForResult(
            Intent.createChooser(intent, null), inFlightChooserCode);
        return true;
      } catch (ActivityNotFoundException exception) {
        return false;
      }
    }

    @Override
    public boolean launchCameraCapture(boolean video) {
      final Activity current = activity;
      if (current == null) {
        return false;
      }
      final Uri output = createCaptureOutputUri(current, video);
      if (output == null) {
        return false;
      }
      pendingCaptureUri = output;
      final Intent intent =
          new Intent(
              video ? MediaStore.ACTION_VIDEO_CAPTURE : MediaStore.ACTION_IMAGE_CAPTURE);
      intent.putExtra(MediaStore.EXTRA_OUTPUT, output);
      intent.addFlags(
          Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
      grantUriPermissions(current, intent, output);
      try {
        current.startActivityForResult(intent, inFlightChooserCode);
        return true;
      } catch (ActivityNotFoundException exception) {
        pendingCaptureUri = null;
        return false;
      }
    }

    @Nullable
    private Uri createCaptureOutputUri(@NonNull Activity current, boolean video) {
      final File dir = new File(current.getCacheDir(), "xue_hua_webview_capture");
      if (!dir.exists() && !dir.mkdirs()) {
        return null;
      }
      try {
        final File file =
            File.createTempFile("capture_", video ? ".mp4" : ".jpg", dir);
        return FileProvider.getUriForFile(
            current,
            current.getPackageName() + ".xue_hua_webview_android.fileprovider",
            file);
      } catch (IOException | IllegalArgumentException exception) {
        return null;
      }
    }

    private void grantUriPermissions(
        @NonNull Activity current, @NonNull Intent intent, @NonNull Uri uri) {
      final PackageManager packageManager = current.getPackageManager();
      final List<ResolveInfo> matches;
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        matches =
            packageManager.queryIntentActivities(
                intent, PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_DEFAULT_ONLY));
      } else {
        matches = packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);
      }
      final int flags =
          Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION;
      for (ResolveInfo resolveInfo : matches) {
        current.grantUriPermission(resolveInfo.activityInfo.packageName, uri, flags);
      }
    }
  }
}
