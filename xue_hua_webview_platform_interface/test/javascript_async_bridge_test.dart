// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:xue_hua_webview_platform_interface/xue_hua_webview_platform_interface.dart';

void main() {
  test('helperScript installs the async function and channel', () {
    const String channel = '__XueHuaJavaScriptAsync';
    final String script = JavaScriptAsyncBridge.helperScript(
      channelName: channel,
    );

    expect(script, contains(JavaScriptAsyncBridge.functionName));
    expect(script, contains(channel));
    expect(script, contains('Promise.resolve'));
  });

  test('invocationScript encodes the call id and arguments', () {
    final String script = JavaScriptAsyncBridge.invocationScript(
      callId: '42',
      functionBody: 'return value;',
      arguments: const <String, Object?>{'value': 7},
    );

    expect(script, contains('"42"'));
    expect(script, contains('return value;'));
    expect(script, contains(JavaScriptAsyncBridge.functionName));
  });
}
