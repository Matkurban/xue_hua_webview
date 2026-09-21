---
name: xue_hua_webview-javascript
description: >-
  Use when calling xue_hua_webview JavaScript APIs: setJavaScriptMode,
  runJavaScript, runJavaScriptReturningResult, runJavaScriptAsync, JavaScript
  channels, UserScript, console messages, or alert/confirm/prompt dialogs.
---

# xue_hua_webview JavaScript

## Guidelines

* Always call `setJavaScriptMode(JavaScriptMode.unrestricted)` before running JavaScript, adding channels, or injecting user scripts if the page must execute JS.
* `JavaScriptMode` has only `disabled` and `unrestricted`. There is no "restricted" mode.
* `runJavaScript` does not return a value. Use `runJavaScriptReturningResult` for a synchronous expression result, or `runJavaScriptAsync` to await a Promise.
* `runJavaScriptReturningResult` completes with an error if JS throws, or if the result type is unsupported. On iOS, `undefined`/`null` fail on iOS 14+. Prefer JSON-serializable primitives and maps.
* `runJavaScriptAsync` takes a **function body** (not a full `function` declaration). Keys in `arguments` become local variables. Values must be JSON-serializable. Check `result.hasError` before using `result.value`.
* `addJavaScriptChannel` takes effect only after the **next page load**. Channel `name` must be non-empty and unique. JavaScript calls `Name.postMessage(string)`.
* `removeJavaScriptChannel` disables a previously added channel of that name.
* `UserScript` injects on every subsequent navigation. `documentStart` runs after the document element is created; `documentEnd` after the document finishes loading. `removeAllUserScripts` clears every script added with `addUserScript`.
* `setOnConsoleMessage` is not a 1:1 mapping of JS log levels. On iOS/macOS it injects a user script that overrides `console.debug/error/info/log/warn`.
* JS dialog callbacks: `setOnJavaScriptAlertDialog` must complete; `setOnJavaScriptConfirmDialog` must return `bool`; `setOnJavaScriptTextInputDialog` must return `String`.
* On Web, JS evaluation, channels, console, and title work for same-origin pages or managed isolated HTML. Cross-origin iframes cannot be scripted.
* `runJavaScriptAsync` support: Android (helper channel), iOS 14+, macOS 11+, Windows (helper channel), Linux (WebKitGTK 2.40+ or helper), Web (same-origin or managed HTML).

## Enable JavaScript

```dart
await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
```

## Run script

```dart
await controller.runJavaScript('document.body.style.background = "#fff";');

final Object title = await controller.runJavaScriptReturningResult(
  'document.title',
);
```

## Await a Promise

```dart
final JavaScriptAsyncResult result = await controller.runJavaScriptAsync(
  '''
    const price = await window.getIcpPrice();
    return { success: true, price };
  ''',
  arguments: <String, Object?>{'expectedPrincipal': principal},
  timeout: const Duration(seconds: 10),
);
if (result.hasError) {
  throw StateError(result.error!);
}
final Object? value = result.value;
```

`JavaScriptAsyncResult`:

* `value` (`Object?`): decoded JSON on success.
* `error` (`String?`): JS exception, engine error, or timeout message; `null` on success.
* `hasError`: `error != null`.

## JavaScript channel (JS → Dart)

```dart
await controller.addJavaScriptChannel(
  'Print',
  onMessageReceived: (JavaScriptMessage message) {
    debugPrint(message.message);
  },
);
await controller.loadRequest(Uri.parse('https://example.com'));
```

Page JS:

```javascript
Print.postMessage('Hello');
```

`JavaScriptMessage.message` is a `String`. Adding the channel before `loadRequest` so the next load installs it.

Remove with:

```dart
await controller.removeJavaScriptChannel('Print');
```

## User scripts

```dart
await controller.addUserScript(
  const UserScript(
    source: 'window.__app = true;',
    injectionTime: UserScriptInjectionTime.documentStart,
    forMainFrameOnly: true,
  ),
);
```

* `source` (required `String`): JavaScript to inject.
* `injectionTime`: `documentStart` (default) or `documentEnd`.
* `forMainFrameOnly`: default `true`. On Android this is best-effort because document-start uses origin rules.

Android document-start: full on WebView 91+; older versions fall back to `onPageStarted`. Document-end uses `onPageFinished`. Web injection is limited to srcdoc/same-origin.

Clear with `await controller.removeAllUserScripts();`.

## Console and JS dialogs

```dart
await controller.setOnConsoleMessage((JavaScriptConsoleMessage message) {
  debugPrint('${message.level.name}: ${message.message}');
});

await controller.setOnJavaScriptAlertDialog(
  (JavaScriptAlertDialogRequest request) async {},
);
await controller.setOnJavaScriptConfirmDialog(
  (JavaScriptConfirmDialogRequest request) async => true,
);
await controller.setOnJavaScriptTextInputDialog(
  (JavaScriptTextInputDialogRequest request) async =>
      request.defaultText ?? '',
);
```

Dialog request fields: `message` and `url` (`String`). Prompt also has `defaultText` (`String?`).

`JavaScriptLogLevel`: `error`, `warning`, `debug`, `info`, `log`.

On Web, `confirm`/`prompt` host callbacks are same-origin and synchronous; isolated managed HTML uses the browser dialog.

## Anti-patterns

* Do not wrap `runJavaScriptAsync` bodies in `async function () { ... }`. Pass only the inner statements plus `return`.
* Do not expect `addJavaScriptChannel` to work on the already-loaded page without a reload.
* Do not reuse the same channel name for two channels.
* Do not pass non-JSON values in `runJavaScriptAsync` `arguments`.
