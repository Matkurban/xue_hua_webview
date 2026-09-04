// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest
@testable import xue_hua_webview_wkwebview

class NavigationActionProxyAPITests: XCTestCase {
    @MainActor func testRequest() throws {
        let registrar = TestProxyApiRegistrar()
        let api = registrar.apiDelegate.pigeonApiWKNavigationAction(registrar)

        let instance: TestNavigationAction? = TestNavigationAction()
        let value = try? api.pigeonDelegate.request(pigeonApi: api, pigeonInstance: try XCTUnwrap(instance))

        XCTAssertEqual(value?.value, instance?.request)
    }

    @MainActor func testTargetFrame() throws {
        let registrar = TestProxyApiRegistrar()
        let api = registrar.apiDelegate.pigeonApiWKNavigationAction(registrar)

        let instance: TestNavigationAction? = TestNavigationAction()
        let value = try? api.pigeonDelegate.targetFrame(pigeonApi: api, pigeonInstance: try XCTUnwrap(instance))

        XCTAssertEqual(value, instance?.targetFrame)
    }

    @MainActor func testNavigationType() throws {
        let registrar = TestProxyApiRegistrar()
        let api = registrar.apiDelegate.pigeonApiWKNavigationAction(registrar)

        let instance: TestNavigationAction? = TestNavigationAction()
        let value = try? api.pigeonDelegate.navigationType(pigeonApi: api, pigeonInstance: try XCTUnwrap(instance))

        XCTAssertEqual(value, .formSubmitted)
    }
}

class TestNavigationAction: WKNavigationAction {
    let internalTargetFrame = TestFrameInfo.instance

    override var request: URLRequest {
        return URLRequest(url: URL(string: "http://google.com")!)
    }

    override var targetFrame: WKFrameInfo? {
        return internalTargetFrame
    }

    override var navigationType: WKNavigationType {
        return .formSubmitted
    }
}
