// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

import 'webview_platform_test.mocks.dart';

void main() {
  setUp(() {
    WebViewPlatform.instance = MockWebViewPlatformWithMixin();
  });

  test('Cannot be implemented with `implements`', () {
    when(
      (WebViewPlatform.instance! as MockWebViewPlatform)
          .createPlatformHeadlessWebView(any),
    ).thenReturn(ImplementsPlatformHeadlessWebView());

    expect(() {
      PlatformHeadlessWebView(const PlatformHeadlessWebViewCreationParams());
    }, throwsA(anything));
  });

  test('Can be extended', () {
    const params = PlatformHeadlessWebViewCreationParams();
    when(
      (WebViewPlatform.instance! as MockWebViewPlatform)
          .createPlatformHeadlessWebView(any),
    ).thenReturn(ExtendsPlatformHeadlessWebView(params));

    expect(PlatformHeadlessWebView(params), isNotNull);
  });

  test('Can be mocked with `implements`', () {
    when(
      (WebViewPlatform.instance! as MockWebViewPlatform)
          .createPlatformHeadlessWebView(any),
    ).thenReturn(MockHeadlessWebViewDelegate());

    expect(
      PlatformHeadlessWebView(const PlatformHeadlessWebViewCreationParams()),
      isNotNull,
    );
  });

  test(
    'Default implementation of controller should throw unimplemented error',
    () {
      final PlatformHeadlessWebView headless = ExtendsPlatformHeadlessWebView(
        const PlatformHeadlessWebViewCreationParams(),
      );

      expect(() => headless.controller, throwsUnimplementedError);
    },
  );

  test(
    'Default implementation of isRunning should throw unimplemented error',
    () {
      final PlatformHeadlessWebView headless = ExtendsPlatformHeadlessWebView(
        const PlatformHeadlessWebViewCreationParams(),
      );

      expect(() => headless.isRunning, throwsUnimplementedError);
    },
  );

  test('Default implementation of run should throw unimplemented error', () {
    final PlatformHeadlessWebView headless = ExtendsPlatformHeadlessWebView(
      const PlatformHeadlessWebViewCreationParams(),
    );

    expect(headless.run, throwsUnimplementedError);
  });

  test(
    'Default implementation of dispose should throw unimplemented error',
    () {
      final PlatformHeadlessWebView headless = ExtendsPlatformHeadlessWebView(
        const PlatformHeadlessWebViewCreationParams(),
      );

      expect(headless.dispose, throwsUnimplementedError);
    },
  );
}

class MockWebViewPlatformWithMixin extends MockWebViewPlatform
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin {}

class ImplementsPlatformHeadlessWebView implements PlatformHeadlessWebView {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHeadlessWebViewDelegate extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements PlatformHeadlessWebView {}

class ExtendsPlatformHeadlessWebView extends PlatformHeadlessWebView {
  ExtendsPlatformHeadlessWebView(super.params) : super.implementation();
}
