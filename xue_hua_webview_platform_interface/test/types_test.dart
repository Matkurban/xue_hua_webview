// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:xue_hua_webview_platform_interface/src/types/types.dart';

void main() {
  group('types', () {
    test('WebResourceRequest', () {
      final Uri uri = Uri.parse('https://www.google.com');
      final request = WebResourceRequest(uri: uri);
      expect(request.uri, uri);
    });

    test('WebResourceResponse', () {
      final Uri uri = Uri.parse('https://www.google.com');
      const statusCode = 404;
      const headers = <String, String>{'a': 'header'};

      final response = WebResourceResponse(
        uri: uri,
        statusCode: statusCode,
        headers: headers,
      );

      expect(response.uri, uri);
      expect(response.statusCode, statusCode);
      expect(response.headers, headers);
    });

    test('UserScript', () {
      const script = UserScript(
        source: 'window.ready = true;',
        injectionTime: UserScriptInjectionTime.documentStart,
        forMainFrameOnly: false,
      );
      expect(script.source, 'window.ready = true;');
      expect(script.injectionTime, UserScriptInjectionTime.documentStart);
      expect(script.forMainFrameOnly, isFalse);
    });

    test('JavaScriptAsyncResult', () {
      const success = JavaScriptAsyncResult(
        value: <String, Object?>{'ok': true},
      );
      expect(success.hasError, isFalse);
      expect(success.value, <String, Object?>{'ok': true});

      const failure = JavaScriptAsyncResult(error: 'boom');
      expect(failure.hasError, isTrue);
      expect(failure.error, 'boom');
    });

    test('WebViewDataType contains storage kinds', () {
      expect(WebViewDataType.values, contains(WebViewDataType.cookies));
      expect(WebViewDataType.values, contains(WebViewDataType.indexedDb));
      expect(WebViewDataType.values, contains(WebViewDataType.all));
    });
  });
}
