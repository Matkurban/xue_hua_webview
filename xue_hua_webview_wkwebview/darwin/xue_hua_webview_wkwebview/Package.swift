// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
    name: "xue_hua_webview_wkwebview",
    platforms: [
        .iOS("13.0"),
        .macOS("10.15"),
    ],
    products: [
        .library(name: "xue-hua-webview-wkwebview", targets: ["xue_hua_webview_wkwebview"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "xue_hua_webview_wkwebview",
            dependencies: [],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
