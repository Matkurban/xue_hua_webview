// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

/// Hands page-initiated custom schemes to the system instead of loading them in WKWebView.
enum ExternalUrlCoordinator {
    private static let webViewSchemes: Set<String> = [
        "http", "https", "about", "data", "blob", "file", "content", "applewebdata",
    ]

    /// Test hook. When set, system `open` is skipped.
    static var openHandler: ((URL) -> Bool)?

    static func isExternal(_ url: URL?) -> Bool {
        guard let url else {
            return false
        }
        return isExternal(url.absoluteString)
    }

    static func isExternal(_ urlString: String?) -> Bool {
        guard let urlString, let scheme = scheme(of: urlString) else {
            return false
        }
        if scheme == "javascript" {
            return false
        }
        return !webViewSchemes.contains(scheme)
    }

    @discardableResult
    static func open(_ url: URL?) -> Bool {
        guard let url, isExternal(url) else {
            return false
        }
        if let openHandler {
            return openHandler(url)
        }
        #if os(iOS)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        #elseif os(macOS)
            return NSWorkspace.shared.open(url)
        #else
            return false
        #endif
    }

    static func scheme(of urlString: String) -> String? {
        guard let colon = urlString.firstIndex(of: ":") else {
            return nil
        }
        let scheme = String(urlString[..<colon])
        return scheme.isEmpty ? nil : scheme.lowercased()
    }
}
