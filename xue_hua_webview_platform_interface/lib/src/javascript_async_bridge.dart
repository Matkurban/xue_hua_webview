// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

/// Shared JavaScript used by platforms that do not expose a native
/// `callAsyncJavaScript` API.
class JavaScriptAsyncBridge {
  JavaScriptAsyncBridge._();

  /// JavaScript channel that receives `{id, value}` / `{id, error}` payloads.
  static const String channelName = '__XueHuaJavaScriptAsync';

  /// Global function installed by [helperScript].
  static const String functionName = '__xueHuaJavaScriptAsync';

  /// Document-start script that installs [functionName].
  static String helperScript({required String channelName}) {
    final String encodedChannel = jsonEncode(channelName);
    return '''
(function() {
  if (window.__xueHuaJavaScriptAsyncInstalled) {
    return;
  }
  window.__xueHuaJavaScriptAsyncInstalled = true;
  window.$functionName = function(callId, functionBody, argumentsJson) {
    var args = {};
    try {
      args = JSON.parse(argumentsJson);
    } catch (parseError) {
      window[$encodedChannel].postMessage(JSON.stringify({
        id: callId,
        error: String(parseError)
      }));
      return;
    }
    var names = Object.keys(args);
    var values = names.map(function(name) { return args[name]; });
    var asyncFn;
    try {
      asyncFn = Function.apply(
        null,
        names.concat(['return (async function() {\\n' + functionBody + '\\n})();'])
      );
    } catch (syntaxError) {
      window[$encodedChannel].postMessage(JSON.stringify({
        id: callId,
        error: String(syntaxError)
      }));
      return;
    }
    Promise.resolve().then(function() {
      return asyncFn.apply(null, values);
    }).then(function(value) {
      var payload;
      try {
        payload = JSON.stringify({id: callId, value: value});
      } catch (serializeError) {
        payload = JSON.stringify({
          id: callId,
          error: 'Result is not JSON-serializable: ' + String(serializeError)
        });
      }
      window[$encodedChannel].postMessage(payload);
    }, function(error) {
      window[$encodedChannel].postMessage(JSON.stringify({
        id: callId,
        error: String(error && error.stack ? error.stack : error)
      }));
    });
  };
})();
''';
  }

  /// JavaScript that invokes the installed helper.
  static String invocationScript({
    required String callId,
    required String functionBody,
    required Map<String, Object?> arguments,
  }) {
    return '$functionName(${jsonEncode(callId)}, ${jsonEncode(functionBody)}, ${jsonEncode(jsonEncode(arguments))});';
  }
}
