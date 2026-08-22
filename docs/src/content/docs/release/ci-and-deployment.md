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

The workflow file is `.github/workflows/docs.yml`. It runs on a push to `main`
only when a file under `docs/` changes, or by manual dispatch.

Build flow:

1. Checks out the repository.
2. Installs pnpm 10.19.0.
3. Installs Node 24 with pnpm caching enabled.
4. Runs `pnpm install --frozen-lockfile` in `docs/`.
5. Runs `pnpm build`.
6. Uploads `docs/dist`.
7. Deploys with GitHub Pages Actions.

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

In GitHub repository settings, Pages source must be set to `GitHub Actions`.
