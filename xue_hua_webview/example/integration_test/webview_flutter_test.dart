// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:xue_hua_webview/xue_hua_webview.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('UserScript runs at document-start', (WidgetTester tester) async {
    final Completer<void> pageFinished = Completer<void>();
    final WebViewController controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) {
          if (!pageFinished.isCompleted) {
            pageFinished.complete();
          }
        },
      ),
    );
    await controller.addUserScript(
      const UserScript(
        source: 'window.__xueHuaUserScript = 42;',
        injectionTime: UserScriptInjectionTime.documentStart,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: WebViewWidget(controller: controller)),
    );
    await controller.loadHtmlString(
      '<!DOCTYPE html><html><body>ok</body></html>',
    );
    await pageFinished.future.timeout(const Duration(seconds: 20));

    final Object flag = await controller.runJavaScriptReturningResult(
      'window.__xueHuaUserScript',
    );
    expect(flag.toString(), contains('42'));
  });

  testWidgets('runJavaScriptAsync awaits a Promise', (
    WidgetTester tester,
  ) async {
    final Completer<void> pageFinished = Completer<void>();
    final WebViewController controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) {
          if (!pageFinished.isCompleted) {
            pageFinished.complete();
          }
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: WebViewWidget(controller: controller)),
    );
    await controller.loadHtmlString(
      '<!DOCTYPE html><html><body>async</body></html>',
    );
    await pageFinished.future.timeout(const Duration(seconds: 20));

    final JavaScriptAsyncResult result = await controller.runJavaScriptAsync(
      'return await Promise.resolve(n + 1);',
      arguments: const <String, Object?>{'n': 20},
    );
    expect(result.hasError, isFalse, reason: result.error);
    expect(result.value.toString(), contains('21'));
  });

  testWidgets('WebViewStorageManager.removeData does not throw', (
    WidgetTester tester,
  ) async {
    await WebViewStorageManager().removeData(
      dataTypes: const <WebViewDataType>{WebViewDataType.all},
    );
  });

  testWidgets('HeadlessWebView loads HTML and disposes', (
    WidgetTester tester,
  ) async {
    final Completer<void> pageFinished = Completer<void>();
    final HeadlessWebView headless = HeadlessWebView();
    await headless.controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await headless.controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) {
          if (!pageFinished.isCompleted) {
            pageFinished.complete();
          }
        },
      ),
    );
    await headless.run();
    expect(headless.isRunning, isTrue);

    await headless.controller.loadHtmlString(
      '<!DOCTYPE html><html><body>headless</body></html>',
    );
    await pageFinished.future.timeout(const Duration(seconds: 20));

    final Object title = await headless.controller.runJavaScriptReturningResult(
      'document.body.innerText',
    );
    expect(title.toString().toLowerCase(), contains('headless'));

    await headless.dispose();
    expect(headless.isRunning, isFalse);
  });
}
