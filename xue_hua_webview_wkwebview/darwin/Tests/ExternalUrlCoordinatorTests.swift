// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
@testable import xue_hua_webview_wkwebview

class ExternalUrlCoordinatorTests: XCTestCase {
    func testWebLoadableSchemesAreNotExternal() {
        XCTAssertFalse(ExternalUrlCoordinator.isExternal("https://www.bilibili.com"))
        XCTAssertFalse(ExternalUrlCoordinator.isExternal(URL(string: "https://www.bilibili.com")))
        XCTAssertFalse(ExternalUrlCoordinator.isExternal("http://example.com"))
        XCTAssertFalse(ExternalUrlCoordinator.isExternal("about:blank"))
        XCTAssertFalse(ExternalUrlCoordinator.isExternal("data:text/html,hi"))
        XCTAssertFalse(ExternalUrlCoordinator.isExternal("blob:https://example.com/1"))
        XCTAssertFalse(ExternalUrlCoordinator.isExternal("file:///tmp/a.html"))
        XCTAssertFalse(ExternalUrlCoordinator.isExternal("content://media/1"))
        XCTAssertFalse(ExternalUrlCoordinator.isExternal("javascript:alert(1)"))
        XCTAssertFalse(ExternalUrlCoordinator.isExternal("applewebdata://uuid/index.html"))
        XCTAssertFalse(ExternalUrlCoordinator.isExternal(nil as String?))
        XCTAssertFalse(ExternalUrlCoordinator.isExternal("not-a-url"))
    }

    func testCustomSchemesAreExternal() {
        XCTAssertTrue(ExternalUrlCoordinator.isExternal("bilibili://root"))
        XCTAssertTrue(ExternalUrlCoordinator.isExternal(URL(string: "bilibili://root")))
        XCTAssertTrue(ExternalUrlCoordinator.isExternal("weixin://dl/business"))
        XCTAssertTrue(ExternalUrlCoordinator.isExternal("mailto:a@b.com"))
        XCTAssertTrue(ExternalUrlCoordinator.isExternal("tel:+123"))
        XCTAssertTrue(ExternalUrlCoordinator.isExternal("intent://scan/#Intent;end"))
    }

    func testOpenHandlerReceivesExternalUrl() {
        var opened: [String] = []
        ExternalUrlCoordinator.openHandler = { url in
            opened.append(url.absoluteString)
            return true
        }
        defer { ExternalUrlCoordinator.openHandler = nil }

        XCTAssertTrue(ExternalUrlCoordinator.open(URL(string: "bilibili://root")))
        XCTAssertFalse(ExternalUrlCoordinator.open(URL(string: "https://www.bilibili.com")))
        XCTAssertEqual(opened, ["bilibili://root"])
    }
}
