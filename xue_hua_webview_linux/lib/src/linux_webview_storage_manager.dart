import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'linux_webview_controller.dart';

class LinuxWebViewStorageManagerCreationParams
    extends PlatformWebViewStorageManagerCreationParams {
  const LinuxWebViewStorageManagerCreationParams();

  const LinuxWebViewStorageManagerCreationParams.fromPlatformWebViewStorageManagerCreationParams(
    PlatformWebViewStorageManagerCreationParams params,
  );
}

class LinuxWebViewStorageManager extends PlatformWebViewStorageManager {
  LinuxWebViewStorageManager(PlatformWebViewStorageManagerCreationParams params)
    : super.implementation(
        params is LinuxWebViewStorageManagerCreationParams
            ? params
            : const LinuxWebViewStorageManagerCreationParams(),
      );

  @override
  Future<void> removeData({
    Set<WebViewDataType> dataTypes = const <WebViewDataType>{
      WebViewDataType.all,
    },
    DateTime? since,
  }) {
    return LinuxWebViewController.rootChannel
        .invokeMethod<void>('clearWebsiteData', <String, Object?>{
          'dataTypes': dataTypes
              .map((WebViewDataType type) => type.name)
              .toList(),
          if (since != null) 'sinceMilliseconds': since.millisecondsSinceEpoch,
        });
  }
}
