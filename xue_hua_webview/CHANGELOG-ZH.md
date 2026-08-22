## 1.0.0

* 首次发布 `xue_hua_webview`（由 `webview_all` / `webview_platform_interface` / `webview_all_*` 重命名而来）。请更新 pubspec 依赖和 `package:` import；公开的 Widget 与 Controller API 保持不变。
* 新增 `WebViewController.runJavaScriptAsync`，可等待 JavaScript Promise，并返回 `JavaScriptAsyncResult`。
* 新增 `UserScript`，可通过 `addUserScript` / `removeAllUserScripts` 在 document-start 和 document-end 注入脚本。
* 新增 `WebViewStorageManager`，无需活 WebView 即可清理 cookie、HTTP cache 和 DOM storage。
* 新增 `HeadlessWebView` 用于离屏运行 WebView，并补充 `WebViewController.dispose`。
* Android 新增 WebAuthn（Passkey）配置，可通过 `setWebAuthenticationSupport` 为已关联应用或具备资格的浏览器应用启用。
* 修复 Windows 应用窗口最小化，或 WebView 被隐藏、移除后，WebView2 仍可能拦截桌面点击的问题。
* 完善 Windows WebView 在应用前后台切换、WebView 显隐、窗口移动、显示器及缩放变化时的显示和渲染恢复。
* 新增 `WindowsWebViewController.dispose()`，可确定性释放 WebView2 资源，并支持初始化期间安全释放和自动兜底清理。
