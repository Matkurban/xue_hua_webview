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

If you move or rename the checkout, run `flutter clean` in
`xue_hua_webview/example` before the next macOS build. Xcode may still print
`Stale file ... is located outside of the allowed root paths` from Flutter's
`example/build/macos` output list; ignore it when the build ends with
`Built .../example.app`.
