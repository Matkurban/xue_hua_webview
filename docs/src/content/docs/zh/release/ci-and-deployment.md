---
title: CI 和 Pages
description: 代码如何验证，以及文档如何部署到 GitHub Pages。
---

文档站点位于 `docs/`，使用 Starlight 和 pnpm。

## 本地命令

```sh
cd docs
pnpm install
pnpm dev
pnpm build
```

本地预览路径包含 base path：

```text
http://127.0.0.1:4321/xue_hua_webview
```

中文文档路径：

```text
http://127.0.0.1:4321/xue_hua_webview/zh
```

## 代码 CI

`.github/workflows/ci.yml` 会在 pull request 和手动触发时运行。任务使用当前最低
支持的 Flutter 版本线，以及当前 3.44 稳定线。

workflow 会：

- 在每条 Flutter 版本线上分析并测试所有 Dart 包，以及示例应用；
- 在 Chrome 运行 Web 测试并构建 Web 示例；
- 在两条 Flutter 版本线上运行 Android native unit test 并构建 APK；
- 在两条 Flutter 版本线上编译 iOS、macOS 示例，并在最低版本线上编译
  Linux、Windows 示例，从而在对应 runner 验证 native 插件代码。

## GitHub Pages

`.github/workflows/deploy-web.yml` 在每次 push 到 `main` 时发布站点，也可以手动触发。
`.github/workflows/docs.yml` 只检查文档能否构建。

构建流程：

1. checkout 代码。
2. 安装 pnpm 10.19.0 与 Node 24，然后构建 `docs/`。
3. 安装 Flutter 3.47，并分析 `xue_hua_webview/example`。
4. 以 base href `/xue_hua_webview/demo/` 构建 Web 示例。
5. 把构建结果复制到 `docs/dist/demo`。
6. 上传 `docs/dist`，并用 GitHub Pages Actions 部署。

示例和文档放在同一站点里，避免示例部署覆盖文档。一个仓库只有一个 Pages
站点，因此只有 `deploy-web.yml` 上传产物。

## 线上地址

Astro 配置：

```js
site: 'https://matkurban.github.io',
base: '/xue_hua_webview',
```

部署后地址：

```text
https://matkurban.github.io/xue_hua_webview
```

中文地址：

```text
https://matkurban.github.io/xue_hua_webview/zh
```

Web 示例：

```text
https://matkurban.github.io/xue_hua_webview/demo/
```

GitHub 仓库设置中 Pages source 需要选择 `GitHub Actions`。
