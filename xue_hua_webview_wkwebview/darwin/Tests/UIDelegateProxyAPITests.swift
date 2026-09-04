// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

#if os(macOS)
    import AppKit
#endif

@testable import xue_hua_webview_wkwebview

class UIDelegateProxyAPITests: XCTestCase {
    func testPigeonDefaultConstructor() {
        let registrar = TestProxyApiRegistrar()
        let api = registrar.apiDelegate.pigeonApiWKUIDelegate(registrar)

        let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
        XCTAssertNotNil(instance)
    }

    @MainActor func testOnCreateWebView() {
        let api = TestDelegateApi()
        let registrar = TestProxyApiRegistrar()
        let instance = UIDelegateImpl(api: api, registrar: registrar)
        let webView = WKWebView(frame: .zero)
        let configuration = WKWebViewConfiguration()
        let navigationAction = TestNavigationAction()

        let result = instance.webView(
            webView, createWebViewWith: configuration, for: navigationAction,
            windowFeatures: WKWindowFeatures()
        )

        XCTAssertEqual(api.onCreateWebViewArgs, [webView, configuration, navigationAction])
        XCTAssertNil(result)
    }

    @available(iOS 15.0, macOS 12.0, *)
    @MainActor func testRequestMediaCapturePermission() {
        let api = TestDelegateApi()
        let registrar = TestProxyApiRegistrar()
        let instance = UIDelegateImpl(api: api, registrar: registrar)
        let webView = WKWebView(frame: .zero)
        let origin = SecurityOriginProxyAPITests.testSecurityOrigin
        let frame = TestFrameInfo.instance
        let type: WKMediaCaptureType = .camera

        var resultDecision: WKPermissionDecision?
        let callbackExpectation = expectation(description: "Wait for callback.")
        instance.webView(
            webView, requestMediaCapturePermissionFor: origin, initiatedByFrame: frame, type: type
        ) { decision in
            resultDecision = decision
            callbackExpectation.fulfill()
        }

        wait(for: [callbackExpectation], timeout: 1.0)

        XCTAssertEqual(
            api.requestMediaCapturePermissionArgs, [webView, origin, frame, MediaCaptureType.camera]
        )
        XCTAssertEqual(resultDecision, .prompt)
    }

    @MainActor func testRunJavaScriptAlertPanel() {
        let api = TestDelegateApi()
        let registrar = TestProxyApiRegistrar()
        let instance = UIDelegateImpl(api: api, registrar: registrar)
        let webView = WKWebView(frame: .zero)
        let message = "myString"
        let frame = TestFrameInfo.instance

        instance.webView(webView, runJavaScriptAlertPanelWithMessage: message, initiatedByFrame: frame) {}

        XCTAssertEqual(api.runJavaScriptAlertPanelArgs, [webView, message, frame])
    }

    @MainActor func testRunJavaScriptConfirmPanel() {
        let api = TestDelegateApi()
        let registrar = TestProxyApiRegistrar()
        let instance = UIDelegateImpl(api: api, registrar: registrar)
        let webView = WKWebView(frame: .zero)
        let message = "myString"
        let frame = TestFrameInfo.instance

        var confirmedResult: Bool?
        let callbackExpectation = expectation(description: "Wait for callback.")
        instance.webView(
            webView, runJavaScriptConfirmPanelWithMessage: message, initiatedByFrame: frame
        ) { confirmed in
            confirmedResult = confirmed
            callbackExpectation.fulfill()
        }

        wait(for: [callbackExpectation], timeout: 1.0)

        XCTAssertEqual(api.runJavaScriptConfirmPanelArgs, [webView, message, frame])
        XCTAssertEqual(confirmedResult, true)
    }

    @MainActor func testRunJavaScriptTextInputPanel() {
        let api = TestDelegateApi()
        let registrar = TestProxyApiRegistrar()
        let instance = UIDelegateImpl(api: api, registrar: registrar)
        let webView = WKWebView(frame: .zero)
        let prompt = "myString"
        let defaultText = "myString3"
        let frame = TestFrameInfo.instance

        var inputResult: String?
        let callbackExpectation = expectation(description: "Wait for callback.")
        instance.webView(
            webView, runJavaScriptTextInputPanelWithPrompt: prompt, defaultText: defaultText,
            initiatedByFrame: frame
        ) { input in
            inputResult = input
            callbackExpectation.fulfill()
        }

        wait(for: [callbackExpectation], timeout: 1.0)

        XCTAssertEqual(api.runJavaScriptTextInputPanelArgs, [webView, prompt, defaultText, frame])
        XCTAssertEqual(inputResult, "myString2")
    }

    #if os(macOS)
        @MainActor func testFileOpenPanelCoordinatorCancelCompletesNil() {
            let coordinator = FileOpenPanelCoordinator()
            var received: [URL]??
            coordinator.setPendingForTesting { urls in
                received = urls
            }
            XCTAssertTrue(coordinator.hasPendingCompletion)
            coordinator.cancelPending()
            XCTAssertNil(received)
            XCTAssertFalse(coordinator.hasPendingCompletion)
        }

        @MainActor func testFileOpenPanelCoordinatorReplaceCancelsPrevious() {
            let coordinator = FileOpenPanelCoordinator()
            var first: [URL]??
            var second: [URL]??
            coordinator.setPendingForTesting { first = $0 }
            coordinator.setPendingForTesting { second = $0 }
            XCTAssertNil(first)
            XCTAssertNil(second)
            coordinator.cancelPending()
            XCTAssertNil(second)
        }

        @MainActor func testFileOpenPanelCoordinatorStalePanelDoesNotCompleteNewHandler() {
            let coordinator = FileOpenPanelCoordinator()
            let oldPanel = NSOpenPanel()
            var first: [URL]??
            var second: [URL]??
            coordinator.setPendingForTesting { first = $0 }
            coordinator.attachPanelForTesting(oldPanel)
            coordinator.setPendingForTesting { second = $0 }
            XCTAssertNil(first)
            coordinator.completePanelForTesting(
                oldPanel, urls: [URL(fileURLWithPath: "/tmp/stale")]
            )
            XCTAssertNil(second)
            coordinator.cancelPending()
            XCTAssertNil(second)
        }
    #endif
}

class TestDelegateApi: PigeonApiProtocolWKUIDelegate {
    var onCreateWebViewArgs: [AnyHashable?]?
    var requestMediaCapturePermissionArgs: [AnyHashable?]?
    var runJavaScriptAlertPanelArgs: [AnyHashable?]?
    var runJavaScriptConfirmPanelArgs: [AnyHashable?]?
    var runJavaScriptTextInputPanelArgs: [AnyHashable?]?

    func onCreateWebView(
        pigeonInstance _: WKUIDelegate, webView webViewArg: WKWebView,
        configuration configurationArg: WKWebViewConfiguration,
        navigationAction navigationActionArg: WKNavigationAction,
        completion _: @escaping (Result<Void, PigeonError>) -> Void
    ) {
        onCreateWebViewArgs = [webViewArg, configurationArg, navigationActionArg]
    }

    func requestMediaCapturePermission(
        pigeonInstance _: WKUIDelegate, webView webViewArg: WKWebView,
        origin originArg: WKSecurityOrigin, frame frameArg: WKFrameInfo, type typeArg: MediaCaptureType,
        completion: @escaping (Result<PermissionDecision, PigeonError>) -> Void
    ) {
        requestMediaCapturePermissionArgs = [webViewArg, originArg, frameArg, typeArg]
        completion(.success(.prompt))
    }

    func runJavaScriptAlertPanel(
        pigeonInstance _: WKUIDelegate, webView webViewArg: WKWebView,
        message messageArg: String, frame frameArg: WKFrameInfo,
        completion _: @escaping (Result<Void, PigeonError>) -> Void
    ) {
        runJavaScriptAlertPanelArgs = [webViewArg, messageArg, frameArg]
    }

    func runJavaScriptConfirmPanel(
        pigeonInstance _: WKUIDelegate, webView webViewArg: WKWebView,
        message messageArg: String, frame frameArg: WKFrameInfo,
        completion: @escaping (Result<Bool, PigeonError>) -> Void
    ) {
        runJavaScriptConfirmPanelArgs = [webViewArg, messageArg, frameArg]
        completion(.success(true))
    }

    func runJavaScriptTextInputPanel(
        pigeonInstance _: WKUIDelegate, webView webViewArg: WKWebView,
        prompt promptArg: String, defaultText defaultTextArg: String?, frame frameArg: WKFrameInfo,
        completion: @escaping (Result<String?, PigeonError>) -> Void
    ) {
        runJavaScriptTextInputPanelArgs = [webViewArg, promptArg, defaultTextArg, frameArg]
        completion(.success("myString2"))
    }
}
