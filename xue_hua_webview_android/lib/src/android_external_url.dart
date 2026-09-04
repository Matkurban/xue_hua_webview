// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

const Set<String> _webViewSchemes = <String>{
  'http',
  'https',
  'about',
  'data',
  'blob',
  'file',
  'content',
};

/// Whether [url] should be handed to the OS instead of loaded in Android WebView.
bool isExternalUrl(String url) {
  final Uri? uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) {
    return false;
  }
  final String scheme = uri.scheme.toLowerCase();
  if (scheme == 'javascript') {
    return false;
  }
  return !_webViewSchemes.contains(scheme);
}

/// Opens an external URL through the Android plugin MethodChannel.
class ExternalUrlClient {
  /// Creates a client. [openUrl] replaces the channel in tests.
  const ExternalUrlClient({
    Future<String?> Function(String url)? openUrl,
    MethodChannel channel = const MethodChannel(
      'dev.flutter.xue_hua_webview_android/external_url',
    ),
  }) : _openUrl = openUrl,
       _channel = channel;

  final Future<String?> Function(String url)? _openUrl;
  final MethodChannel _channel;

  /// Asks the plugin to open [url]. Returns an https fallback when present.
  Future<String?> open(String url) {
    if (_openUrl != null) {
      return _openUrl(url);
    }
    return _channel.invokeMethod<String>('open', <String, Object>{'url': url});
  }
}
