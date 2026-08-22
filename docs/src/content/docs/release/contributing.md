---
title: Contributing
description: Repository layout, coding standards, native bridges, tests, and docs sync for xue_hua_webview.
---

`xue_hua_webview` is a **federated Flutter plugin monorepo**. It is not an application
and does not use Melos or a pub workspace. Follow the existing plugin layers.
Do not introduce app-style state management such as Riverpod, Bloc, Provider, or
signals.

The GitHub entry points are [`CONTRIBUTING.md`](https://github.com/Matkurban/xue_hua_webview/blob/main/CONTRIBUTING.md)
and [`CONTRIBUTING-ZH.md`](https://github.com/Matkurban/xue_hua_webview/blob/main/CONTRIBUTING-ZH.md).
This page is the full project standard.

## Repository map

| Path | Role |
| --- | --- |
| `xue_hua_webview/` | App-facing API (`WebViewController`, `WebViewWidget`, `NavigationDelegate`, `WebViewCookieManager`) |
| `xue_hua_webview_platform_interface/` | Platform abstractions and shared types |
| `xue_hua_webview_android/` | Android WebView (Pigeon) |
| `xue_hua_webview_wkwebview/` | iOS and macOS WKWebView (Pigeon, shared Darwin source) |
| `xue_hua_webview_web/` | Web iframe (`dart:js_interop`) |
| `xue_hua_webview_windows/` | Windows WebView2 (Pigeon) |
| `xue_hua_webview_linux/` | Linux WebKitGTK (MethodChannel) |
| `xue_hua_webview/example/` | Minimal demo |
| `examples/platform/` | Full-feature demo and integration tests |
| `docs/` | Starlight documentation site |
| `SYNC.md` | README / CHANGELOG sync and upstream alignment |

Packages are published independently. Local and CI wiring uses
`pubspec_overrides.yaml` path dependencies, not a workspace.

```text
app code
  -> xue_hua_webview
    -> xue_hua_webview_platform_interface
        -> native / JS interop
```

## Layers and how to extend them

Platform implementations **must `extends`** interface types such as
`PlatformWebViewController`. Do **not** `implements` them. Newly added interface
methods are not breaking for subclasses that extend the default
`UnimplementedError` implementations.

Public APIs belong in `xue_hua_webview` plus `xue_hua_webview_platform_interface`.
Platform-only features live on types such as `AndroidWebViewController` and
`WebKitWebViewControllerCreationParams`. Callers detect the platform with
`WebViewPlatform.instance is XxxWebViewPlatform`, then cast
`controller.platform`.

Interface constructors that only platform packages should use are
`PlatformWebViewController.implementation` (and the matching widget / delegate /
cookie manager constructors).

### Adding an API

1. Add the method on the platform interface with a default `UnimplementedError`.
2. If it is a shared app-facing API, forward it from `xue_hua_webview`.
3. Implement it in every platform package.
4. Prefer a real native implementation when the engine exposes one.
5. Throw `UnsupportedError` when the engine cannot provide the feature.
6. Use a no-op only for registration-style APIs that are already guarded by
   capability checks.
7. Update the [capability matrix](/xue_hua_webview/platforms/capability-matrix/)
   and [platform API](/xue_hua_webview/reference/platform-specific-api/) docs.
8. Add unit tests, and integration coverage in `examples/platform` when the
   behavior is user-visible.
9. Run format, `flutter analyze --fatal-infos`, and tests before release.

Version baselines and publish order stay on
[Compatibility](/xue_hua_webview/release/compatibility/).

## Dart conventions

- Library layout: `lib/<package_name>.dart` barrel plus `lib/src/` implementation.
- File names: `snake_case.dart`.
- Types: `{Platform}WebViewPlatform`, `{Platform}WebViewController`,
  `{Platform}WebViewWidget`, `{Platform}NavigationDelegate`,
  `{Platform}WebViewCookieManager`, `{Platform}*CreationParams`.
- Strings: single quotes (`prefer_single_quotes`).
- Import order: `dart:*`, then `package:flutter/*`, then other packages, then
  relative `src/` imports. Do not use relative `lib/` imports.
- Generated Pigeon Dart is imported with a prefix, for example
  `android_webkit.g.dart as android_webview`.
- Public APIs need `///` dartdoc, including `{@template}` / `{@macro}` where
  the existing files already do.
- Keep the existing Flutter Authors copyright headers on forked Dart files.
  Package `LICENSE` files are MIT (Abandoft). Do not mix or rewrite those two
  lineages unless the task is explicitly about licensing.

Plugin packages include the repo-root `analysis_options.yaml`. Example apps use
`package:flutter_lints/flutter.yaml`.

### Widgets

Library code and **new** UI must use a `Widget` class. Extract a private
`_Foo` widget when the subtree is reused or non-trivial. Do not return widgets
from methods.

```dart
// Bad
Widget favoriteButton() {
  return FloatingActionButton(onPressed: () {}, child: const Icon(Icons.favorite));
}

// Good
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

`examples/platform/lib/main.dart` still has methods such as `favoriteButton()`
from the upstream demo. Do not add more. Do not mass-refactor that file unless
the change is required for the task.

### Errors and logging

| Case | Type |
| --- | --- |
| Invalid arguments | `ArgumentError` |
| Interface method not overridden | `UnimplementedError` |
| Engine cannot support the feature | `UnsupportedError` |

Log with `debugPrint('xue_hua_webview_{platform}: ...')`. Do not use `print` or a
logging package.

## Native bridges

| Platform | Bridge | Native |
| --- | --- | --- |
| Android | Pigeon | Java / Kotlin `*ProxyApi` |
| iOS / macOS | Pigeon | Swift / ObjC under `darwin/` |
| Windows | Pigeon | C++ WebView2 |
| Linux | MethodChannel | C++ WebKitGTK |
| Web | `dart:js_interop` + `package:web` | none |

Do not introduce `dart:ffi` in plugin code. Do not hand-edit generated
`*.g.dart`, `*.g.kt`, or `windows_webview_api.g.{h,cpp}` files. Change the
Pigeon definition and regenerate.

## Tests

| Area | Location |
| --- | --- |
| Unit / widget tests | each package `test/` |
| `xue_hua_webview` | handwritten fakes, no Mockito |
| android / wkwebview / web / interface | Mockito + `build_runner` |
| Integration | `examples/platform/integration_test/` |
| Web unit tests | `flutter test --platform chrome` in `xue_hua_webview_web` |
| Android native | Gradle `:xue_hua_webview_android:testDebugUnitTest` |
| Darwin Swift | `xue_hua_webview_wkwebview/darwin/Tests/` |

Before a pull request, from the package directory:

```sh
flutter pub get
flutter analyze --fatal-infos
flutter test
```

Web package tests:

```sh
flutter test --platform chrome
```

CI details are on [CI and Pages](/xue_hua_webview/release/ci-and-deployment/).

## Documentation and sync

Maintain README and CHANGELOG only under `xue_hua_webview/`, then copy them as
described in [`SYNC.md`](https://github.com/Matkurban/xue_hua_webview/blob/main/SYNC.md):

1. `xue_hua_webview` README files overwrite the repository root README files.
2. `xue_hua_webview` CHANGELOG files overwrite every child plugin CHANGELOG.

Docs live in `docs/` (Starlight, pnpm). Keep English and Simplified Chinese
pages in sync.

Examples used by the docs site contain `// #docregion` / `// #enddocregion`
markers. Preserve them when editing those files.

## CI and versions

When adding or renaming a Dart package, update `.github/workflows/ci.yml`:

Keep package versions aligned. Publish child packages first, then `xue_hua_webview`,
in the order listed on [Compatibility](/xue_hua_webview/release/compatibility/).
