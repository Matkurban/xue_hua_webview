import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'linux_navigation_delegate.dart';
import 'linux_webview_controller.dart';
import 'linux_webview_cookie_manager.dart';
import 'linux_headless_webview.dart';
import 'linux_webview_storage_manager.dart';
import 'linux_webview_widget.dart';

class LinuxWebViewPlatform extends WebViewPlatform {
  static void registerWith() {
    WebViewPlatform.instance = LinuxWebViewPlatform();
  }

  @override
  LinuxWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return LinuxWebViewController(params);
  }

  @override
  LinuxNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return LinuxNavigationDelegate(params);
  }

  @override
  LinuxWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return LinuxWebViewWidget(params);
  }

  @override
  LinuxWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    return LinuxWebViewCookieManager(params);
  }

  @override
  LinuxWebViewStorageManager createPlatformStorageManager(
    PlatformWebViewStorageManagerCreationParams params,
  ) {
    return LinuxWebViewStorageManager(params);
  }

  @override
  LinuxHeadlessWebView createPlatformHeadlessWebView(
    PlatformHeadlessWebViewCreationParams params,
  ) {
    return LinuxHeadlessWebView(params);
  }
}
