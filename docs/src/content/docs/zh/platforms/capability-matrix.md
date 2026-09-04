---
title: 能力矩阵
description: xue_hua_webview 1.1.0 的跨平台能力覆盖。
---

标记说明：

| 标记 | 含义 |
| --- | --- |
| 完整 | 由平台引擎或强类型桥完整实现。 |
| 有限制 | 已实现，但有明确浏览器、系统或引擎限制。 |
| 不支持 | 当前不可用，通常会抛错或按文档 no-op。 |

## 核心能力

| 能力 | Android | iOS | macOS | Windows | Linux | Web |
| --- | --- | --- | --- | --- | --- | --- |
| `WebViewWidget` | 完整 | 完整 | 完整 | 完整 | 完整 | 完整 |
| `loadRequest` GET | 完整 | 完整 | 完整 | 完整 | 完整 | 完整 |
| GET headers | 完整 | 完整 | 完整 | 完整 | 完整 | 有限制，CORS/fetch |
| POST body | 完整 | 完整 | 完整 | 完整 | 完整 | 有限制，CORS/fetch |
| POST 自定义 headers | 不支持 | 完整 | 完整 | 完整 | 完整 | 有限制，CORS/fetch |
| `loadFile` | 完整 | 完整 | 完整 | 完整 | 完整 | 不支持 |
| `loadFlutterAsset` | 完整 | 完整 | 完整 | 完整 | 完整 | 完整 |
| `loadHtmlString` | 完整 | 完整 | 完整 | 完整 | 完整 | 完整 |
| 历史前进/后退 | 完整 | 完整 | 完整 | 完整 | 完整 | 有限制，controller 维护逻辑历史 |

## 导航和错误

| 能力 | Android | iOS | macOS | Windows | Linux | Web |
| --- | --- | --- | --- | --- | --- | --- |
| `onNavigationRequest` | 完整 | 完整 | 完整 | 完整 | 完整 | 有限制 |
| 页面开始/完成 | 完整 | 完整 | 完整 | 完整 | 完整 | iframe load 限制 |
| 进度 | 完整 | 完整 | 完整 | 完整 | 完整 | 合成 0/100 |
| URL 变化 | 完整 | 完整 | 完整 | 完整 | 完整 | 逻辑 URL |
| 资源错误 | 完整 | 完整 | 完整 | 完整 | 完整 | fetch 失败可见 |
| HTTP 错误 | 完整 | 完整 | 完整 | 完整 | 完整 | fetch-backed load 可见 |
| HTTP auth | 完整 | 完整 | 完整 | 完整 | 完整 | 浏览器 iframe 不暴露 |
| SSL auth | 完整 | 完整 | 完整 | 完整 | 完整 | 浏览器 iframe 不暴露 |
| 外部 App URL / 自定义 scheme | 完整 | 完整 | 完整 | 不支持 | 不支持 | 浏览器接管 |

## JavaScript、UI 和权限

| 能力 | Android | iOS | macOS | Windows | Linux | Web |
| --- | --- | --- | --- | --- | --- | --- |
| JS 开关 | 完整 | 完整 | 完整 | 完整 | 完整 | iframe sandbox |
| 执行 JS | 完整 | 完整 | 完整 | 完整 | 完整 | 同源或插件管理的隔离 HTML |
| JS 返回值 | 完整 | 完整 | 完整 | 完整 | 完整 | 同源或隔离 bridge，且需可序列化 |
| JS channel | 完整 | 完整 | 完整 | 完整 | 完整 | 同源或插件管理的隔离 HTML |
| Console | 完整 | 完整 | 完整 | 完整 | 完整 | 同源或插件管理的隔离 HTML |
| JS dialog | 完整 | 完整 | 完整 | 完整 | 完整 | alert 可走 bridge；隔离 HTML 的 confirm/prompt 由浏览器处理 |
| 权限请求 | 完整 | 完整 | 完整 | 完整 | 完整 | 可控制 HTML 媒体 hook + 浏览器提示 |
| WebAuthn/Passkey | 有限制，显式启用且关联应用 | 有限制，取决于系统与 Associated Domains | 有限制，取决于系统与 Associated Domains | 有限制，取决于 Runtime/系统/凭据提供方 | 不支持，WebKitGTK port 缺失 | 有限制，取决于浏览器与 iframe 策略 |
| 文件选择 | 完整，内置选择器加可选回调 | 引擎回落 | 完整，WKUIDelegate 弹出 NSOpenPanel | 引擎回落 | 引擎回落 | 浏览器接管 |
| 定位提示 | 完整 | 无平台 API | 无平台 API | 引擎/浏览器接管 | 引擎/浏览器接管 | 浏览器接管 |

## 视图状态

| 能力 | Android | iOS | macOS | Windows | Linux | Web |
| --- | --- | --- | --- | --- | --- | --- |
| 标题 | 完整 | 完整 | 完整 | 完整 | 完整 | 同源或插件管理的隔离 HTML |
| 滚动位置读取 | 完整 | 完整 | 不支持，打印信息并返回零 | 完整 | 完整 | 同源或插件管理的隔离 HTML |
| 滚动位置回调 | 完整 | 完整 | 不支持，打印信息并忽略 | 完整 | 完整 | 同源或插件管理的隔离 HTML |
| `scrollTo`/`scrollBy` | 完整 | 完整 | 不支持，打印信息并忽略 | 完整 | 完整 | 同源或插件管理的隔离 HTML |
| 滚动条 | 完整 | 完整 | 不支持，打印信息并忽略 | CSS 实现 | 完整 | CSS 实现 |
| 背景色 | 完整 | 完整 | macOS 12+；更早版本打印信息并忽略 | 完整 | 完整 | iframe CSS |
| 缩放 | 完整 | 完整 | 完整 | 完整 | 完整 | touch-action 限制 |
| UA override | 完整 | 完整 | 完整 | 完整 | 完整 | 非空 override 不支持 |
| Overscroll | 完整 | 有限制 | 不支持，打印信息并忽略 | CSS 实现 | 完整 | iframe CSS |

## 异步 JS、UserScript、存储和无头

| 能力 | Android | iOS | macOS | Windows | Linux | Web |
| --- | --- | --- | --- | --- | --- | --- |
| `runJavaScriptAsync` | 完整，内部通道 | 完整，iOS 14+ | 完整，macOS 11+ | 完整，内部通道 | 完整，WebKitGTK 2.40+ 或内部通道 | 有限制，同源或插件管理 HTML |
| `addUserScript` document-start | 完整，WebView 91+；更早版本 `onPageStarted` 降级 | 完整 | 完整 | 完整 | 完整 | 有限制，srcdoc/同源 |
| `addUserScript` document-end | 完整，`onPageFinished` | 完整 | 完整 | 完整 | 完整 | 有限制，srcdoc/同源 |
| `WebViewStorageManager.removeData` | 完整 | 完整 | 完整 | 完整 | 完整 | 有限制，仅宿主 origin |
| `HeadlessWebView` | 完整 | 完整 | 完整 | 完整 | 完整，无 overlay 时用 offscreen 窗口 | 完整，隐藏 iframe |
| `WebViewController.dispose` | 完整 | 完整 | 完整 | 完整 | 完整 | 完整 |
