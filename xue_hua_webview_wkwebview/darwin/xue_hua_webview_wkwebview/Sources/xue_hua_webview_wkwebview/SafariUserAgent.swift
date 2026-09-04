// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import WebKit

/// Builds a Safari-compatible `applicationNameForUserAgent` suffix for macOS WKWebView.
enum SafariUserAgent {
    static func compatibilityApplicationName(osMajorVersion: Int) -> String {
        let safariMajor = max(osMajorVersion, 18)
        return "Version/\(safariMajor).0 Safari/605.1.15"
    }

    static func shouldReplaceApplicationName(
        _ current: String?, bundleName: String?, bundleVersion: String?
    ) -> Bool {
        guard let current, !current.isEmpty else {
            return true
        }
        if let bundleName, current == bundleName {
            return true
        }
        if let bundleName, current.hasPrefix("\(bundleName)/") {
            return true
        }
        if let bundleName, let bundleVersion, current == "\(bundleName)/\(bundleVersion)" {
            return true
        }
        return false
    }

    #if os(macOS)
        static func applyCompatibilityNameIfNeeded(to configuration: WKWebViewConfiguration) {
            let bundle = Bundle.main
            let name =
                bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                    ?? bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            let version =
                bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                    ?? bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            if shouldReplaceApplicationName(
                configuration.applicationNameForUserAgent,
                bundleName: name,
                bundleVersion: version
            ) {
                configuration.applicationNameForUserAgent = compatibilityApplicationName(
                    osMajorVersion: ProcessInfo.processInfo.operatingSystemVersion.majorVersion
                )
            }
        }
    #endif
}
