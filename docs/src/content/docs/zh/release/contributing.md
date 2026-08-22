---
title: 贡献与规范
description: xue_hua_webview 的仓库结构、编码约定、Native 桥、测试和文档同步规范。
---

`xue_hua_webview` 是 **federated Flutter 插件 monorepo**，不是业务 App，也不使用
Melos 或 pub workspace。沿用现有插件分层，不要引入 Riverpod、Bloc、Provider、
signals 等应用级状态管理。

GitHub 入口是 [`CONTRIBUTING.md`](https://github.com/Matkurban/xue_hua_webview/blob/main/CONTRIBUTING.md)
和 [`CONTRIBUTING-ZH.md`](https://github.com/Matkurban/xue_hua_webview/blob/main/CONTRIBUTING-ZH.md)。
本页是完整项目规范。

## 仓库地图

| 路径 | 职责 |
| --- | --- |
| `xue_hua_webview/` | 面向应用的 API（`WebViewController`、`WebViewWidget`、`NavigationDelegate`、`WebViewCookieManager`） |
| `xue_hua_webview_platform_interface/` | 平台抽象与共享类型 |
| `xue_hua_webview_android/` | Android WebView（Pigeon） |
| `xue_hua_webview_wkwebview/` | iOS / macOS WKWebView（Pigeon，Darwin 共享源码） |
| `xue_hua_webview_web/` | Web iframe（`dart:js_interop`） |
| `xue_hua_webview_windows/` | Windows WebView2（Pigeon） |
| `xue_hua_webview_linux/` | Linux WebKitGTK（MethodChannel） |
| `xue_hua_webview/example/` | 精简演示 |
| `examples/platform/` | 全功能演示与集成测试 |
| `docs/` | Starlight 文档站 |
| `SYNC.md` | README / CHANGELOG 同步与上游对齐 |

各包独立发布。本地和 CI 用 `pubspec_overrides.yaml` 的 path 依赖串联，不用
workspace。

```text
应用代码
  -> xue_hua_webview
    -> xue_hua_webview_platform_interface
        -> native / JS interop
```

## 分层与扩展方式

平台实现必须 **`extends`** `PlatformWebViewController` 等接口类型，禁止
`implements`。接口新增方法对沿用默认 `UnimplementedError` 的子类不算破坏性变更。

公共 API 加在 `xue_hua_webview` 与 `xue_hua_webview_platform_interface`。平台专属能力放在
`AndroidWebViewController`、`WebKitWebViewControllerCreationParams` 这类类型上。
调用方用 `WebViewPlatform.instance is XxxWebViewPlatform` 判断，再转换
`controller.platform`。

仅供平台包使用的构造函数是 `PlatformWebViewController.implementation`（以及
对应的 widget / delegate / cookie manager 构造函数）。

### 新增 API 落地顺序

1. 在 platform interface 增加方法，默认抛 `UnimplementedError`。
2. 若是面向应用的共享 API，在 `xue_hua_webview` 转发。
3. 在每一个平台包里显式实现。
4. 引擎提供能力时优先做真实 native 实现。
5. 引擎做不到时抛 `UnsupportedError`。
6. 只有已有能力检查保护的注册型 API 才允许 no-op。
7. 更新[能力矩阵](/xue_hua_webview/zh/platforms/capability-matrix/)和
   [平台专属接口](/xue_hua_webview/zh/reference/platform-specific-api/)文档。
8. 补单元测试；用户可见行为再补 `examples/platform` 集成测试。
9. 发布前跑 format、`flutter analyze --fatal-infos` 和测试。

版本基线与发布顺序见[兼容性](/xue_hua_webview/zh/release/compatibility/)。

## Dart 约定

- 库结构：`lib/<包名>.dart` 桶文件 + `lib/src/` 实现。
- 文件名：`snake_case.dart`。
- 类型名：`{Platform}WebViewPlatform`、`{Platform}WebViewController`、
  `{Platform}WebViewWidget`、`{Platform}NavigationDelegate`、
  `{Platform}WebViewCookieManager`、`{Platform}*CreationParams`。
- 字符串：单引号（`prefer_single_quotes`）。
- import 顺序：`dart:*`，然后 `package:flutter/*`，然后其他包，然后相对
  `src/`。禁止相对 `lib/` import。
- Pigeon 生成的 Dart 用前缀导入，例如
  `android_webkit.g.dart as android_webview`。
- 公共 API 写 `///` dartdoc，已有 `{@template}` / `{@macro}` 的地方继续用。
- 从官方 fork 的 Dart 文件保留 Flutter Authors 版权头。各包 `LICENSE` 为 MIT
  （Abandoft）。除非任务明确是许可证，否则不要混改这两套声明。

插件包以仓库根目录 `analysis_options.yaml` 为准。示例应用使用
`package:flutter_lints/flutter.yaml`。

### Widget

库代码和**新增** UI 必须使用 Widget 类。可复用或非平凡的子树抽成私有 `_Foo`
组件。禁止用方法返回组件。

```dart
// 错误
Widget favoriteButton() {
  return FloatingActionButton(onPressed: () {}, child: const Icon(Icons.favorite));
}

// 正确
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.favorite),
    );
  }
}
```

`examples/platform/lib/main.dart` 里仍有上游 demo 遗留的 `favoriteButton()`
等方法。不要再增加这类写法。除非当前任务必须改这个文件，否则不要批量重构。

### 错误与日志

| 场景 | 类型 |
| --- | --- |
| 参数不合法 | `ArgumentError` |
| 接口方法未被覆盖 | `UnimplementedError` |
| 引擎无法提供该能力 | `UnsupportedError` |

日志使用 `debugPrint('xue_hua_webview_{platform}: ...')`。不要用 `print` 或第三方
logging 包。

## Native 桥

| 平台 | 桥接 | Native |
| --- | --- | --- |
| Android | Pigeon | Java / Kotlin `*ProxyApi` |
| iOS / macOS | Pigeon | `darwin/` 下的 Swift / ObjC |
| Windows | Pigeon | C++ WebView2 |
| Linux | MethodChannel | C++ WebKitGTK |
| Web | `dart:js_interop` + `package:web` | 无 |

插件代码不要引入 `dart:ffi`。不要手改生成的 `*.g.dart`、`*.g.kt`、
`windows_webview_api.g.{h,cpp}`。改 Pigeon 定义后重新生成。

## 测试

| 范围 | 位置 |
| --- | --- |
| 单元 / Widget 测试 | 各包 `test/` |
| `xue_hua_webview` | 手写 fake，不用 Mockito |
| android / wkwebview / web / interface | Mockito + `build_runner` |
| 集成测试 | `examples/platform/integration_test/` |
| Web 单元测试 | 在 `xue_hua_webview_web` 执行 `flutter test --platform chrome` |
| Android native | Gradle `:xue_hua_webview_android:testDebugUnitTest` |
| Darwin Swift | `xue_hua_webview_wkwebview/darwin/Tests/` |

提交前在对应包目录执行：

```sh
flutter pub get
flutter analyze --fatal-infos
flutter test
```

Web 包测试：

```sh
flutter test --platform chrome
```

CI 细节见 [CI 和 Pages](/xue_hua_webview/zh/release/ci-and-deployment/)。

## 文档与同步

README 和 CHANGELOG 只在 `xue_hua_webview/` 维护，再按
[`SYNC.md`](https://github.com/Matkurban/xue_hua_webview/blob/main/SYNC.md) 覆盖：

1. `xue_hua_webview` 的中英文 README 覆盖仓库根目录 README。
2. `xue_hua_webview` 的中英文 CHANGELOG 覆盖各个子插件 CHANGELOG。

文档站在 `docs/`（Starlight，pnpm）。英文与简体中文页面保持同步。

被文档站引用的示例含 `// #docregion` / `// #enddocregion` 标记。改这些文件时
保持标记完整。

## CI 与版本

新增或重命名 Dart 包时，同步更新 `.github/workflows/ci.yml` 的 `packages` 列表

各包版本保持对齐。先发子包再发 `xue_hua_webview`，顺序见
[兼容性](/xue_hua_webview/zh/release/compatibility/)。
