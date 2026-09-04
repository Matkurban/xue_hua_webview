import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'package:example/main.dart';

void main() {
  setUpAll(() {
    WebViewPlatform.instance = _TestWebViewPlatform();
  });

  testWidgets('home offers local HTML and Bilibili demos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('选择测试'), findsOneWidget);
    expect(find.text('本地 HTML（文件选择）'), findsOneWidget);
    expect(find.text('哔哩哔哩'), findsOneWidget);
  });

  testWidgets('opens the Bilibili demo', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.tap(find.text('哔哩哔哩'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, '哔哩哔哩'), findsOneWidget);
  });

  testWidgets('opens the local file-chooser demo', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.tap(find.text('本地 HTML（文件选择）'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, '文件选择'), findsOneWidget);
  });
}

class _TestWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return _TestWebViewController(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return _TestNavigationDelegate(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return _TestWebViewWidget(params);
  }
}

class _TestWebViewController extends PlatformWebViewController {
  _TestWebViewController(super.params) : super.implementation();

  @override
  Future<void> loadRequest(LoadRequestParams params) async {}

  @override
  Future<void> loadFlutterAsset(String key) async {}

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<bool> canGoBack() async => false;

  @override
  Future<bool> canGoForward() async => false;
}

class _TestNavigationDelegate extends PlatformNavigationDelegate {
  _TestNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {}
}

class _TestWebViewWidget extends PlatformWebViewWidget {
  _TestWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}
