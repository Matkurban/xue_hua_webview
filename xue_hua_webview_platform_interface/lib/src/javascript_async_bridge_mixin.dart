// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'javascript_async_bridge.dart';
import 'platform_webview_controller.dart';
import 'types/types.dart';

/// Mixin that implements [PlatformWebViewController.runJavaScriptAsync] with a
/// JavaScript channel plus Completer, for engines without native Promise-await.
mixin JavaScriptAsyncBridgeMixin on PlatformWebViewController {
  final Map<String, Completer<JavaScriptAsyncResult>> _javaScriptAsyncPending =
      <String, Completer<JavaScriptAsyncResult>>{};
  int _javaScriptAsyncCallId = 0;
  bool _javaScriptAsyncBridgeReady = false;
  Future<void>? _javaScriptAsyncBridgeInstall;

  /// Installs the helper user script and JavaScript channel.
  ///
  /// Safe to call more than once. Also re-runs the helper with [runJavaScript]
  /// so an already-loaded document picks it up immediately.
  Future<void> installJavaScriptAsyncBridge() {
    return _javaScriptAsyncBridgeInstall ??= _installJavaScriptAsyncBridge();
  }

  Future<void> _installJavaScriptAsyncBridge() async {
    await addJavaScriptChannel(
      JavaScriptChannelParams(
        name: JavaScriptAsyncBridge.channelName,
        onMessageReceived: _onJavaScriptAsyncBridgeMessage,
      ),
    );
    await addUserScript(
      UserScript(
        source: JavaScriptAsyncBridge.helperScript(
          channelName: JavaScriptAsyncBridge.channelName,
        ),
        injectionTime: UserScriptInjectionTime.documentStart,
        forMainFrameOnly: false,
      ),
    );
    try {
      await runJavaScript(
        JavaScriptAsyncBridge.helperScript(
          channelName: JavaScriptAsyncBridge.channelName,
        ),
      );
    } catch (_) {
      // The document may not exist yet; the user script covers later loads.
    }
    _javaScriptAsyncBridgeReady = true;
  }

  /// Runs [functionBody] through the injected helper and waits for the result.
  Future<JavaScriptAsyncResult> runJavaScriptAsyncViaBridge(
    String functionBody, {
    Map<String, Object?> arguments = const <String, Object?>{},
    Duration? timeout,
  }) async {
    try {
      jsonEncode(arguments);
    } on Object catch (error) {
      throw ArgumentError.value(
        arguments,
        'arguments',
        'JavaScript async arguments must be JSON-serializable: $error',
      );
    }

    await installJavaScriptAsyncBridge();
    final String callId = '${_javaScriptAsyncCallId++}';
    final Completer<JavaScriptAsyncResult> completer =
        Completer<JavaScriptAsyncResult>();
    _javaScriptAsyncPending[callId] = completer;

    try {
      await runJavaScript(
        JavaScriptAsyncBridge.invocationScript(
          callId: callId,
          functionBody: functionBody,
          arguments: arguments,
        ),
      );
    } on Object catch (error) {
      _javaScriptAsyncPending.remove(callId);
      return JavaScriptAsyncResult(error: error.toString());
    }

    final Future<JavaScriptAsyncResult> future = completer.future;
    if (timeout == null) {
      return future;
    }
    return future.timeout(
      timeout,
      onTimeout: () {
        _javaScriptAsyncPending.remove(callId);
        return JavaScriptAsyncResult(
          error:
              'The JavaScript async call timed out after ${timeout.inMilliseconds}ms.',
        );
      },
    );
  }

  void _onJavaScriptAsyncBridgeMessage(JavaScriptMessage message) {
    final Object? decoded = jsonDecode(message.message);
    if (decoded is! Map) {
      return;
    }
    final Object? id = decoded['id'];
    if (id is! String) {
      return;
    }
    final Completer<JavaScriptAsyncResult>? completer =
        _javaScriptAsyncPending.remove(id);
    if (completer == null || completer.isCompleted) {
      return;
    }
    final Object? error = decoded['error'];
    if (error != null) {
      completer.complete(JavaScriptAsyncResult(error: error.toString()));
      return;
    }
    completer.complete(JavaScriptAsyncResult(value: decoded['value']));
  }

  /// Whether the async JS helper channel has been installed.
  bool get javaScriptAsyncBridgeReady => _javaScriptAsyncBridgeReady;
}
