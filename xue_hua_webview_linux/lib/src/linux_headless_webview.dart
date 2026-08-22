import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'linux_webview_controller.dart';

class LinuxHeadlessWebViewCreationParams
    extends PlatformHeadlessWebViewCreationParams {
  const LinuxHeadlessWebViewCreationParams({super.controllerParams});

  LinuxHeadlessWebViewCreationParams.fromPlatformHeadlessWebViewCreationParams(
    PlatformHeadlessWebViewCreationParams params,
  ) : super(controllerParams: params.controllerParams);
}

class LinuxHeadlessWebView extends PlatformHeadlessWebView {
  LinuxHeadlessWebView(PlatformHeadlessWebViewCreationParams params)
    : controller = LinuxWebViewController(params.controllerParams),
      super.implementation(
        params is LinuxHeadlessWebViewCreationParams
            ? params
            : LinuxHeadlessWebViewCreationParams.fromPlatformHeadlessWebViewCreationParams(
                params,
              ),
      );

  @override
  final LinuxWebViewController controller;

  bool _running = false;
  bool _disposed = false;

  @override
  bool get isRunning => _running && !_disposed;

  @override
  Future<void> run() async {
    if (_disposed) {
      throw StateError('This headless WebView has already been disposed.');
    }
    _running = true;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _running = false;
    await controller.dispose();
  }
}
