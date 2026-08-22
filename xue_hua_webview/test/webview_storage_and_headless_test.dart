import 'package:flutter_test/flutter_test.dart';
import 'package:xue_hua_webview/xue_hua_webview.dart';
import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

void main() {
  test('WebViewStorageManager forwards removeData', () async {
    final fakeStorageManager = _FakePlatformWebViewStorageManager();
    WebViewPlatform.instance = _FakeWebViewPlatform(
      storageManager: fakeStorageManager,
    );

    final WebViewStorageManager manager = WebViewStorageManager();
    final DateTime since = DateTime.utc(2020);
    await manager.removeData(
      dataTypes: const <WebViewDataType>{WebViewDataType.cookies},
      since: since,
    );

    expect(fakeStorageManager.dataTypes, <WebViewDataType>{
      WebViewDataType.cookies,
    });
    expect(fakeStorageManager.since, since);
  });

  test('HeadlessWebView forwards run and dispose', () async {
    final fakeController = _FakePlatformWebViewController();
    final fakeHeadless = _FakePlatformHeadlessWebView(fakeController);
    WebViewPlatform.instance = _FakeWebViewPlatform(headless: fakeHeadless);

    final HeadlessWebView headless = HeadlessWebView();
    expect(headless.isRunning, isFalse);
    await headless.run();
    expect(headless.isRunning, isTrue);
    await headless.controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await headless.dispose();
    expect(fakeHeadless.disposed, isTrue);
    expect(fakeController.javaScriptMode, JavaScriptMode.unrestricted);
  });
}

class _FakeWebViewPlatform extends WebViewPlatform {
  _FakeWebViewPlatform({this.storageManager, this.headless});

  final _FakePlatformWebViewStorageManager? storageManager;
  final _FakePlatformHeadlessWebView? headless;

  @override
  PlatformWebViewStorageManager createPlatformStorageManager(
    PlatformWebViewStorageManagerCreationParams params,
  ) {
    return storageManager!;
  }

  @override
  PlatformHeadlessWebView createPlatformHeadlessWebView(
    PlatformHeadlessWebViewCreationParams params,
  ) {
    return headless!;
  }
}

class _FakePlatformWebViewStorageManager extends PlatformWebViewStorageManager {
  _FakePlatformWebViewStorageManager()
    : super.implementation(const PlatformWebViewStorageManagerCreationParams());

  Set<WebViewDataType>? dataTypes;
  DateTime? since;

  @override
  Future<void> removeData({
    Set<WebViewDataType> dataTypes = const <WebViewDataType>{
      WebViewDataType.all,
    },
    DateTime? since,
  }) async {
    this.dataTypes = dataTypes;
    this.since = since;
  }
}

class _FakePlatformHeadlessWebView extends PlatformHeadlessWebView {
  _FakePlatformHeadlessWebView(this._controller)
    : super.implementation(const PlatformHeadlessWebViewCreationParams());

  final PlatformWebViewController _controller;
  bool _running = false;
  bool disposed = false;

  @override
  PlatformWebViewController get controller => _controller;

  @override
  bool get isRunning => _running;

  @override
  Future<void> run() async {
    _running = true;
  }

  @override
  Future<void> dispose() async {
    _running = false;
    disposed = true;
  }
}

class _FakePlatformWebViewController extends PlatformWebViewController {
  _FakePlatformWebViewController()
    : super.implementation(const PlatformWebViewControllerCreationParams());

  JavaScriptMode? javaScriptMode;

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {
    this.javaScriptMode = javaScriptMode;
  }

  @override
  Future<void> setOnPlatformPermissionRequest(
    void Function(PlatformWebViewPermissionRequest request) onPermissionRequest,
  ) async {}
}
