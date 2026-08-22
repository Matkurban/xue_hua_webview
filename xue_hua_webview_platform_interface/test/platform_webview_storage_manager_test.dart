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
          .createPlatformStorageManager(any),
    ).thenReturn(ImplementsPlatformWebViewStorageManager());

    expect(() {
      PlatformWebViewStorageManager(
        const PlatformWebViewStorageManagerCreationParams(),
      );
    }, throwsA(anything));
  });

  test('Can be extended', () {
    const params = PlatformWebViewStorageManagerCreationParams();
    when(
      (WebViewPlatform.instance! as MockWebViewPlatform)
          .createPlatformStorageManager(any),
    ).thenReturn(ExtendsPlatformWebViewStorageManager(params));

    expect(PlatformWebViewStorageManager(params), isNotNull);
  });

  test('Can be mocked with `implements`', () {
    when(
      (WebViewPlatform.instance! as MockWebViewPlatform)
          .createPlatformStorageManager(any),
    ).thenReturn(MockWebViewStorageManagerDelegate());

    expect(
      PlatformWebViewStorageManager(
        const PlatformWebViewStorageManagerCreationParams(),
      ),
      isNotNull,
    );
  });

  test(
    'Default implementation of removeData should throw unimplemented error',
    () {
      final PlatformWebViewStorageManager storageManager =
          ExtendsPlatformWebViewStorageManager(
            const PlatformWebViewStorageManagerCreationParams(),
          );

      expect(storageManager.removeData, throwsUnimplementedError);
    },
  );
}

class MockWebViewPlatformWithMixin extends MockWebViewPlatform
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin {}

class ImplementsPlatformWebViewStorageManager
    implements PlatformWebViewStorageManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWebViewStorageManagerDelegate extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements PlatformWebViewStorageManager {}

class ExtendsPlatformWebViewStorageManager
    extends PlatformWebViewStorageManager {
  ExtendsPlatformWebViewStorageManager(super.params) : super.implementation();
}
