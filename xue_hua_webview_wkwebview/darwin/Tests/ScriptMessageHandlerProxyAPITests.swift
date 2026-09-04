// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest
@testable import xue_hua_webview_wkwebview

class ScriptMessageHandlerProxyAPITests: XCTestCase {
    func testPigeonDefaultConstructor() {
        let registrar = TestProxyApiRegistrar()
        let api = registrar.apiDelegate.pigeonApiWKScriptMessageHandler(registrar)

        let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
        XCTAssertNotNil(instance)
    }

    @MainActor func testDidReceiveScriptMessage() {
        let api = TestScriptMessageHandlerApi()
        let registrar = TestProxyApiRegistrar()
        let instance = ScriptMessageHandlerImpl(api: api, registrar: registrar)
        let controller = WKUserContentController()
        let message = WKScriptMessage()

        instance.userContentController(controller, didReceive: message)

        XCTAssertEqual(api.didReceiveScriptMessageArgs, [controller, message])
    }
}

class TestScriptMessageHandlerApi: PigeonApiProtocolWKScriptMessageHandler {
    var didReceiveScriptMessageArgs: [AnyHashable?]?

    func didReceiveScriptMessage(
        pigeonInstance _: WKScriptMessageHandler,
        controller controllerArg: WKUserContentController, message messageArg: WKScriptMessage,
        completion _: @escaping (Result<Void, PigeonError>) -> Void
    ) {
        didReceiveScriptMessageArgs = [controllerArg, messageArg]
    }
}
