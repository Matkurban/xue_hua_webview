---
title: CI and Pages
description: How code is validated and documentation is deployed to GitHub Pages.
---

The documentation site lives in `docs/` and uses Starlight with pnpm.

## Local Commands

```sh
cd docs
pnpm install
pnpm dev
pnpm build
```

The local preview path includes the base path:

```text
http://127.0.0.1:4321/xue_hua_webview
```

The Simplified Chinese documentation path is:

```text
http://127.0.0.1:4321/xue_hua_webview/zh
```

## Code CI

`.github/workflows/ci.yml` runs for pull requests and manual dispatch. Jobs use
the current minimum supported Flutter line and the current 3.44 stable line.

The workflow:

- analyzes and tests every Dart package on each supported Flutter line,
  including the example application;
- runs web tests in Chrome and builds the web example;
- runs Android native unit tests and builds an APK on both supported Flutter
  lines;
- compiles the iOS and macOS examples on both supported Flutter lines, and
  compiles the Linux and Windows examples on the minimum line, so native plugin
  code is validated on its host OS.

## GitHub Pages

`.github/workflows/deploy-web.yml` publishes the site on every push to `main`,
or by manual dispatch. `.github/workflows/docs.yml` only checks that the
documentation still builds.

Build flow:

1. Checks out the repository.
2. Installs pnpm 10.19.0 and Node 24, then builds `docs/`.
3. Installs Flutter 3.47 and analyzes `xue_hua_webview/example`.
4. Builds the web example with base href `/xue_hua_webview/demo/`.
5. Copies that build into `docs/dist/demo`.
6. Uploads `docs/dist` and deploys it with GitHub Pages Actions.

The example is published beside the documentation so a demo deploy does not
replace the docs site. One repository has one Pages site, so only
`deploy-web.yml` uploads the artifact.

## Production URL

Astro config:

```js
site: 'https://matkurban.github.io',
base: '/xue_hua_webview',
```

Deployed URL:

```text
https://matkurban.github.io/xue_hua_webview
```

Simplified Chinese URL:

```text
https://matkurban.github.io/xue_hua_webview/zh
```

Web example:

```text
https://matkurban.github.io/xue_hua_webview/demo/
```

In GitHub repository settings, Pages source must be set to `GitHub Actions`.
