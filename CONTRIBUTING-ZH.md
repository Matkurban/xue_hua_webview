# 贡献指南

本仓库是 federated Flutter 插件 monorepo。完整项目规范在文档站：

- 简体中文：https://matkurban.github.io/xue_hua_webview/zh/release/contributing/
- English: https://matkurban.github.io/xue_hua_webview/release/contributing/

README 和 CHANGELOG 只在 `xue_hua_webview/` 维护，再按 [SYNC.md](SYNC.md) 覆盖到
根目录和各子插件。

## 本地检查

在对应包目录执行：

```sh
flutter pub get
flutter analyze --fatal-infos
flutter test
```

Web 包测试：

```sh
cd xue_hua_webview_web
flutter test --platform chrome
```

文档站：

```sh
cd docs
pnpm install
pnpm dev
```

搬家或改路径后，先在 `xue_hua_webview/example` 执行 `flutter clean` 再编
macOS。Xcode 仍可能因 Flutter 把产物写在 `example/build/macos` 而刷
`Stale file ... is located outside of the allowed root paths`；只要最后是
`Built .../example.app` 即可忽略。
