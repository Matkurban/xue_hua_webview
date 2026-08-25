// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import xue_hua_webview_wkwebview

class NavigationDelegateProxyAPITests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationDelegate(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    XCTAssertNotNil(instance)
  }

  @MainActor func testDidFinishNavigation() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = TestWebView(frame: .zero)

    instance.webView(webView, didFinish: nil)

    XCTAssertEqual(api.didFinishNavigationArgs, [webView, webView.url?.absoluteString])
  }

  @MainActor func testDidStartProvisionalNavigation() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = TestWebView(frame: .zero)
    instance.webView(webView, didStartProvisionalNavigation: nil)

    XCTAssertEqual(api.didStartProvisionalNavigationArgs, [webView, webView.url?.absoluteString])
  }

  @MainActor func testDecidePolicyForNavigationAction() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let navigationAction = TestNavigationAction()

    let callbackExpectation = expectation(description: "Wait for callback.")
    var result: WKNavigationActionPolicy?
    instance.webView(webView, decidePolicyFor: navigationAction) { policy in
      result = policy
      callbackExpectation.fulfill()
    }

    wait(for: [callbackExpectation], timeout: 1.0)

    XCTAssertEqual(api.decidePolicyForNavigationActionArgs, [webView, navigationAction])
    XCTAssertEqual(result, .allow)
  }

  @MainActor func testDecidePolicyForNavigationResponse() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let navigationResponse = TestNavigationResponse.instance

    var result: WKNavigationResponsePolicy?
    let callbackExpectation = expectation(description: "Wait for callback.")
    instance.webView(webView, decidePolicyFor: navigationResponse) { policy in
      result = policy
      callbackExpectation.fulfill()
    }

    wait(for: [callbackExpectation], timeout: 1.0)

    XCTAssertEqual(api.decidePolicyForNavigationResponseArgs, [webView, navigationResponse])
    XCTAssertEqual(result, .cancel)
  }

  @MainActor func testDidFailNavigation() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let error = NSError(domain: "", code: 12)
    instance.webView(webView, didFail: nil, withError: error)

    XCTAssertEqual(api.didFailNavigationArgs, [webView, error])
  }

  @MainActor func testDidFailProvisionalNavigation() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let error = NSError(domain: "", code: 12)
    instance.webView(webView, didFailProvisionalNavigation: nil, withError: error)

    XCTAssertEqual(api.didFailProvisionalNavigationArgs, [webView, error])
  }

  @MainActor func testWebViewWebContentProcessDidTerminate() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    instance.webViewWebContentProcessDidTerminate(webView)

    XCTAssertEqual(api.webViewWebContentProcessDidTerminateArgs, [webView])
  }

  @MainActor func testDidReceiveAuthenticationChallenge() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    instance.handlesHttpAuthRequest = true
    let webView = WKWebView(frame: .zero)
    let challenge = makeAuthenticationChallenge(
      authenticationMethod: NSURLAuthenticationMethodHTTPBasic)

    let (dispositionResult, credentialResult) = waitForAuthChallenge(
      instance: instance, webView: webView, challenge: challenge)

    XCTAssertEqual(api.didReceiveAuthenticationChallengeArgs, [webView, challenge])
    XCTAssertEqual(dispositionResult, .useCredential)
    XCTAssertEqual(credentialResult?.user, "user1")
    XCTAssertEqual(credentialResult?.password, "password1")
    XCTAssertEqual(credentialResult?.persistence, URLCredential.Persistence.none)
  }

  @MainActor func testServerTrustWithoutSslCallbackUsesDefaultHandling() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let challenge = makeAuthenticationChallenge(
      authenticationMethod: NSURLAuthenticationMethodServerTrust)

    let (dispositionResult, credentialResult) = waitForAuthChallenge(
      instance: instance, webView: webView, challenge: challenge)

    XCTAssertNil(api.didReceiveAuthenticationChallengeArgs)
    XCTAssertEqual(dispositionResult, .performDefaultHandling)
    XCTAssertNil(credentialResult)
  }

  @MainActor func testAuthenticationChallengeDartFailureUsesDefaultHandling() {
    let api = FailingNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    instance.handlesHttpAuthRequest = true
    let webView = WKWebView(frame: .zero)
    let challenge = makeAuthenticationChallenge(
      authenticationMethod: NSURLAuthenticationMethodHTTPBasic)

    let (dispositionResult, credentialResult) = waitForAuthChallenge(
      instance: instance, webView: webView, challenge: challenge)

    XCTAssertEqual(api.didReceiveAuthenticationChallengeArgs, [webView, challenge])
    XCTAssertEqual(dispositionResult, .performDefaultHandling)
    XCTAssertNil(credentialResult)
  }

  @MainActor func testDecidePolicyForNavigationActionDartFailureAllows() {
    let api = FailingNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let navigationAction = TestNavigationAction()

    var result: WKNavigationActionPolicy?
    let callbackExpectation = expectation(description: "Wait for callback.")
    instance.webView(webView, decidePolicyFor: navigationAction) { policy in
      result = policy
      callbackExpectation.fulfill()
    }

    wait(for: [callbackExpectation], timeout: 1.0)

    XCTAssertEqual(api.decidePolicyForNavigationActionArgs, [webView, navigationAction])
    XCTAssertEqual(result, .allow)
  }

  @MainActor func testDecidePolicyForNavigationResponseDartFailureAllows() {
    let api = FailingNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let navigationResponse = TestNavigationResponse.instance

    var result: WKNavigationResponsePolicy?
    let callbackExpectation = expectation(description: "Wait for callback.")
    instance.webView(webView, decidePolicyFor: navigationResponse) { policy in
      result = policy
      callbackExpectation.fulfill()
    }

    wait(for: [callbackExpectation], timeout: 1.0)

    XCTAssertEqual(api.decidePolicyForNavigationResponseArgs, [webView, navigationResponse])
    XCTAssertEqual(result, .allow)
  }

  func testSetChallengeHandling() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationDelegate(registrar)
    let instance =
      try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api) as? NavigationDelegateImpl
    XCTAssertNotNil(instance)

    try? api.pigeonDelegate.setChallengeHandling(
      pigeonApi: api, pigeonInstance: instance!, handlesHttpAuthRequest: true,
      handlesSslAuthError: true)

    XCTAssertEqual(instance?.handlesHttpAuthRequest, true)
    XCTAssertEqual(instance?.handlesSslAuthError, true)
  }

  @MainActor private func waitForAuthChallenge(
    instance: NavigationDelegateImpl, webView: WKWebView, challenge: URLAuthenticationChallenge
  ) -> (URLSession.AuthChallengeDisposition?, URLCredential?) {
    var dispositionResult: URLSession.AuthChallengeDisposition?
    var credentialResult: URLCredential?
    let callbackExpectation = expectation(description: "Wait for callback.")
    instance.webView(webView, didReceive: challenge) { disposition, credential in
      dispositionResult = disposition
      credentialResult = credential
      callbackExpectation.fulfill()
    }

    wait(for: [callbackExpectation], timeout: 1.0)
    return (dispositionResult, credentialResult)
  }

  private func makeAuthenticationChallenge(authenticationMethod: String) -> URLAuthenticationChallenge
  {
    let protectionSpace = URLProtectionSpace(
      host: "example.com", port: 443, protocol: NSURLProtectionSpaceHTTPS, realm: nil,
      authenticationMethod: authenticationMethod)
    return URLAuthenticationChallenge(
      protectionSpace: protectionSpace, proposedCredential: nil, previousFailureCount: 0,
      failureResponse: nil, error: nil, sender: TestURLAuthenticationChallengeSender())
  }
}

class TestNavigationDelegateApi: PigeonApiProtocolWKNavigationDelegate {
  var didFinishNavigationArgs: [AnyHashable?]? = nil
  var didStartProvisionalNavigationArgs: [AnyHashable?]? = nil
  var decidePolicyForNavigationActionArgs: [AnyHashable?]? = nil
  var decidePolicyForNavigationResponseArgs: [AnyHashable?]? = nil
  var didFailNavigationArgs: [AnyHashable?]? = nil
  var didFailProvisionalNavigationArgs: [AnyHashable?]? = nil
  var webViewWebContentProcessDidTerminateArgs: [AnyHashable?]? = nil
  var didReceiveAuthenticationChallengeArgs: [AnyHashable?]? = nil

  func registrar() -> ProxyAPIDelegate {
    return ProxyAPIDelegate()
  }

  func didFinishNavigation(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    url urlArg: String?,
    completion: @escaping (Result<Void, xue_hua_webview_wkwebview.PigeonError>) -> Void
  ) {
    didFinishNavigationArgs = [webViewArg, urlArg]
  }

  func didStartProvisionalNavigation(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    url urlArg: String?,
    completion: @escaping (Result<Void, xue_hua_webview_wkwebview.PigeonError>) -> Void
  ) {
    didStartProvisionalNavigationArgs = [webViewArg, urlArg]
  }

  func decidePolicyForNavigationAction(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    navigationAction navigationActionArg: WKNavigationAction,
    completion:
      @escaping (
        Result<
          xue_hua_webview_wkwebview.NavigationActionPolicy, xue_hua_webview_wkwebview.PigeonError
        >
      ) -> Void
  ) {
    decidePolicyForNavigationActionArgs = [webViewArg, navigationActionArg]
    completion(.success(.allow))
  }

  func decidePolicyForNavigationResponse(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    navigationResponse navigationResponseArg: WKNavigationResponse,
    completion:
      @escaping (
        Result<
          xue_hua_webview_wkwebview.NavigationResponsePolicy, xue_hua_webview_wkwebview.PigeonError
        >
      ) -> Void
  ) {
    decidePolicyForNavigationResponseArgs = [webViewArg, navigationResponseArg]
    completion(.success(.cancel))
  }

  func didFailNavigation(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    error errorArg: NSError,
    completion: @escaping (Result<Void, xue_hua_webview_wkwebview.PigeonError>) -> Void
  ) {
    didFailNavigationArgs = [webViewArg, errorArg]
  }

  func didFailProvisionalNavigation(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    error errorArg: NSError,
    completion: @escaping (Result<Void, xue_hua_webview_wkwebview.PigeonError>) -> Void
  ) {
    didFailProvisionalNavigationArgs = [webViewArg, errorArg]
  }

  func webViewWebContentProcessDidTerminate(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    completion: @escaping (Result<Void, xue_hua_webview_wkwebview.PigeonError>) -> Void
  ) {
    webViewWebContentProcessDidTerminateArgs = [webViewArg]
  }

  func didReceiveAuthenticationChallenge(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    challenge challengeArg: URLAuthenticationChallenge,
    completion: @escaping (Result<[Any?], xue_hua_webview_wkwebview.PigeonError>) -> Void
  ) {
    didReceiveAuthenticationChallengeArgs = [webViewArg, challengeArg]
    completion(
      .success([
        UrlSessionAuthChallengeDisposition.useCredential,
        URLCredential(user: "user1", password: "password1", persistence: .none),
      ]))
  }
}

class FailingNavigationDelegateApi: TestNavigationDelegateApi {
  override func decidePolicyForNavigationAction(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    navigationAction navigationActionArg: WKNavigationAction,
    completion:
      @escaping (
        Result<
          xue_hua_webview_wkwebview.NavigationActionPolicy, xue_hua_webview_wkwebview.PigeonError
        >
      ) -> Void
  ) {
    decidePolicyForNavigationActionArgs = [webViewArg, navigationActionArg]
    completion(
      .failure(PigeonError(code: "channel-error", message: "failed", details: nil)))
  }

  override func decidePolicyForNavigationResponse(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    navigationResponse navigationResponseArg: WKNavigationResponse,
    completion:
      @escaping (
        Result<
          xue_hua_webview_wkwebview.NavigationResponsePolicy, xue_hua_webview_wkwebview.PigeonError
        >
      ) -> Void
  ) {
    decidePolicyForNavigationResponseArgs = [webViewArg, navigationResponseArg]
    completion(
      .failure(PigeonError(code: "channel-error", message: "failed", details: nil)))
  }

  override func didReceiveAuthenticationChallenge(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    challenge challengeArg: URLAuthenticationChallenge,
    completion: @escaping (Result<[Any?], xue_hua_webview_wkwebview.PigeonError>) -> Void
  ) {
    didReceiveAuthenticationChallengeArgs = [webViewArg, challengeArg]
    completion(
      .failure(PigeonError(code: "channel-error", message: "failed", details: nil)))
  }
}

class TestWebView: WKWebView {
  override var url: URL? {
    return URL(string: "http://google.com")
  }
}

class TestURLAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender,
  @unchecked Sendable
{
  func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {

  }

  func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {

  }

  func cancel(_ challenge: URLAuthenticationChallenge) {

  }
}
