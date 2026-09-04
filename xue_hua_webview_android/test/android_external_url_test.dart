// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:xue_hua_webview_android/src/android_external_url.dart';

void main() {
  test('web-loadable schemes are not external', () {
    expect(isExternalUrl('https://www.bilibili.com'), isFalse);
    expect(isExternalUrl('http://example.com'), isFalse);
    expect(isExternalUrl('about:blank'), isFalse);
    expect(isExternalUrl('data:text/html,hi'), isFalse);
    expect(isExternalUrl('blob:https://example.com/1'), isFalse);
    expect(isExternalUrl('file:///tmp/a.html'), isFalse);
    expect(isExternalUrl('content://media/1'), isFalse);
    expect(isExternalUrl('javascript:alert(1)'), isFalse);
    expect(isExternalUrl('not a url'), isFalse);
  });

  test('custom schemes are external', () {
    expect(isExternalUrl('bilibili://root'), isTrue);
    expect(isExternalUrl('weixin://dl/business'), isTrue);
    expect(isExternalUrl('intent://scan/#Intent;end'), isTrue);
    expect(isExternalUrl('mailto:a@b.com'), isTrue);
    expect(isExternalUrl('tel:+123'), isTrue);
  });
}
