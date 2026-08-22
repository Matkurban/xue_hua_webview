# Contributing

This repository is a federated Flutter plugin monorepo. The full project
standard lives in the documentation:

- English: https://matkurban.github.io/xue_hua_webview/release/contributing/
- 简体中文: https://matkurban.github.io/xue_hua_webview/zh/release/contributing/

README and CHANGELOG files are maintained only in `xue_hua_webview/`. Copy them
with the steps in [SYNC.md](SYNC.md).

## Local checks

From a package directory:

```sh
flutter pub get
flutter analyze --fatal-infos
flutter test
```

Web package tests:

```sh
cd xue_hua_webview_web
flutter test --platform chrome
```

Documentation site:

```sh
cd docs
pnpm install
pnpm dev
```
