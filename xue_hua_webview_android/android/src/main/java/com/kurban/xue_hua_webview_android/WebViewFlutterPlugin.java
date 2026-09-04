// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.kurban.xue_hua_webview_android;

import android.content.Context;
import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;

/**
 * Java platform implementation of the xue_hua_webview plugin.
 *
 * <p>Register this in an add to app scenario to gracefully handle activity and context changes.
 */
public class WebViewFlutterPlugin implements FlutterPlugin, ActivityAware {
  static final String EXTERNAL_URL_CHANNEL =
      "dev.flutter.xue_hua_webview_android/external_url";

  private FlutterPluginBinding pluginBinding;
  private ProxyApiRegistrar proxyApiRegistrar;
  @Nullable private ActivityPluginBinding activityBinding;
  @Nullable private MethodChannel externalUrlChannel;

  /**
   * Add an instance of this to {@link io.flutter.embedding.engine.plugins.PluginRegistry} to
   * register this plugin.
   *
   * <p>Registration should eventually be handled automatically by v2 of the
   * GeneratedPluginRegistrant. https://github.com/flutter/flutter/issues/42694
   */
  public WebViewFlutterPlugin() {}

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    pluginBinding = binding;

    proxyApiRegistrar =
        new ProxyApiRegistrar(
            binding.getBinaryMessenger(),
            binding.getApplicationContext(),
            new FlutterAssetManager.PluginBindingFlutterAssetManager(
                binding.getApplicationContext().getAssets(), binding.getFlutterAssets()));

    binding
        .getPlatformViewRegistry()
        .registerViewFactory(
            "plugins.flutter.io/webview",
            new FlutterViewFactory(proxyApiRegistrar.getInstanceManager()));

    proxyApiRegistrar.setUp();
    externalUrlChannel = new MethodChannel(binding.getBinaryMessenger(), EXTERNAL_URL_CHANNEL);
    externalUrlChannel.setMethodCallHandler(
        (call, result) -> {
          if (!"open".equals(call.method)) {
            result.notImplemented();
            return;
          }
          final String url = call.argument("url");
          if (url == null) {
            result.success(null);
            return;
          }
          result.success(ExternalUrlOpener.open(currentContext(), Uri.parse(url)));
        });
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (externalUrlChannel != null) {
      externalUrlChannel.setMethodCallHandler(null);
      externalUrlChannel = null;
    }
    detachActivity(/* cancelPending= */ true);
    if (proxyApiRegistrar != null) {
      proxyApiRegistrar.tearDown();
      proxyApiRegistrar.getInstanceManager().stopFinalizationListener();
      proxyApiRegistrar = null;
    }
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    attachActivity(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    detachActivity(/* cancelPending= */ false);
    if (proxyApiRegistrar != null && pluginBinding != null) {
      proxyApiRegistrar.setContext(pluginBinding.getApplicationContext());
    }
  }

  @Override
  public void onReattachedToActivityForConfigChanges(
      @NonNull ActivityPluginBinding activityPluginBinding) {
    attachActivity(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivity() {
    detachActivity(/* cancelPending= */ true);
    if (proxyApiRegistrar != null && pluginBinding != null) {
      proxyApiRegistrar.setContext(pluginBinding.getApplicationContext());
    }
  }

  private void attachActivity(@NonNull ActivityPluginBinding binding) {
    detachActivity(/* cancelPending= */ false);
    activityBinding = binding;
    if (proxyApiRegistrar != null) {
      final FileChooserHelper helper = proxyApiRegistrar.getFileChooserHelper();
      helper.setActivity(binding.getActivity());
      binding.addActivityResultListener(helper);
      binding.addRequestPermissionsResultListener(helper);
      proxyApiRegistrar.setContext(binding.getActivity());
    }
  }

  private void detachActivity(boolean cancelPending) {
    if (activityBinding != null && proxyApiRegistrar != null) {
      final FileChooserHelper helper = proxyApiRegistrar.getFileChooserHelper();
      activityBinding.removeActivityResultListener(helper);
      activityBinding.removeRequestPermissionsResultListener(helper);
      if (cancelPending) {
        helper.onActivityDetached();
      } else {
        helper.setActivity(null);
      }
    }
    activityBinding = null;
  }

  @Nullable
  private Context currentContext() {
    if (activityBinding != null) {
      return activityBinding.getActivity();
    }
    if (pluginBinding != null) {
      return pluginBinding.getApplicationContext();
    }
    return null;
  }

  /** Maintains instances used to communicate with the corresponding objects in Dart. */
  @Nullable
  public AndroidWebkitLibraryPigeonInstanceManager getInstanceManager() {
    return proxyApiRegistrar.getInstanceManager();
  }
}
