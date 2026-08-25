// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// Implementation of `WKNavigationDelegate` that calls to Dart in callback methods.
public class NavigationDelegateImpl: NSObject, WKNavigationDelegate {
  let api: PigeonApiProtocolWKNavigationDelegate
  unowned let registrar: ProxyAPIRegistrar
  var handlesHttpAuthRequest = false
  var handlesSslAuthError = false

  init(api: PigeonApiProtocolWKNavigationDelegate, registrar: ProxyAPIRegistrar) {
    self.api = api
    self.registrar = registrar
  }

  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    registrar.dispatchOnMainThread { onFailure in
      self.api.didFinishNavigation(
        pigeonInstance: self, webView: webView, url: webView.url?.absoluteString
      ) { result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.didFinishNavigation", error)
        }
      }
    }
  }

  public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
  {
    registrar.dispatchOnMainThread { onFailure in
      self.api.didStartProvisionalNavigation(
        pigeonInstance: self, webView: webView, url: webView.url?.absoluteString
      ) { result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.didStartProvisionalNavigation", error)
        }
      }
    }
  }

  public func webView(
    _ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error
  ) {
    registrar.dispatchOnMainThread { onFailure in
      self.api.didFailNavigation(pigeonInstance: self, webView: webView, error: error as NSError) {
        result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.didFailNavigation", error)
        }
      }
    }
  }

  public func webView(
    _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
    withError error: Error
  ) {
    registrar.dispatchOnMainThread { onFailure in
      self.api.didFailProvisionalNavigation(
        pigeonInstance: self, webView: webView, error: error as NSError
      ) { result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.didFailProvisionalNavigation", error)
        }
      }
    }
  }

  public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    registrar.dispatchOnMainThread { onFailure in
      self.api.webViewWebContentProcessDidTerminate(pigeonInstance: self, webView: webView) {
        result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.webViewWebContentProcessDidTerminate", error)
        }
      }
    }
  }

  #if compiler(>=6.0)
    public func webView(
      _ webView: WKWebView, decidePolicyFor navigationAction: WebKit.WKNavigationAction,
      decisionHandler: @escaping @MainActor (WebKit.WKNavigationActionPolicy) -> Void
    ) {
      decidePolicy(for: navigationAction, webView: webView, decisionHandler: decisionHandler)
    }
  #else
    public func webView(
      _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
      decidePolicy(for: navigationAction, webView: webView, decisionHandler: decisionHandler)
    }
  #endif

  #if compiler(>=6.0)
    public func webView(
      _ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
      decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void
    ) {
      decidePolicy(for: navigationResponse, webView: webView, decisionHandler: decisionHandler)
    }
  #else
    public func webView(
      _ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
      decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
      decidePolicy(for: navigationResponse, webView: webView, decisionHandler: decisionHandler)
    }
  #endif

  #if compiler(>=6.0)
    public func webView(
      _ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
      completionHandler:
        @escaping @MainActor (URLSession.AuthChallengeDisposition, URLCredential?) ->
        Void
    ) {
      handle(challenge, webView: webView, completionHandler: completionHandler)
    }
  #else
    public func webView(
      _ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
      completionHandler:
        @escaping (URLSession.AuthChallengeDisposition, URLCredential?) ->
        Void
    ) {
      handle(challenge, webView: webView, completionHandler: completionHandler)
    }
  #endif

  private func decidePolicy(
    for navigationAction: WKNavigationAction,
    webView: WKWebView,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    registrar.dispatchOnMainThread { onFailure in
      self.api.decidePolicyForNavigationAction(
        pigeonInstance: self, webView: webView, navigationAction: navigationAction
      ) { result in
        DispatchQueue.main.async {
          switch result {
          case .success(let policy):
            decisionHandler(self.nativeNavigationActionPolicy(policy))
          case .failure(let error):
            // Fail open so a broken Dart round trip cannot block HTTPS loads.
            decisionHandler(.allow)
            onFailure("WKNavigationDelegate.decidePolicyForNavigationAction", error)
          }
        }
      }
    }
  }

  private func decidePolicy(
    for navigationResponse: WKNavigationResponse,
    webView: WKWebView,
    decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
  ) {
    registrar.dispatchOnMainThread { onFailure in
      self.api.decidePolicyForNavigationResponse(
        pigeonInstance: self, webView: webView, navigationResponse: navigationResponse
      ) { result in
        DispatchQueue.main.async {
          switch result {
          case .success(let policy):
            decisionHandler(self.nativeNavigationResponsePolicy(policy))
          case .failure(let error):
            decisionHandler(.allow)
            onFailure("WKNavigationDelegate.decidePolicyForNavigationResponse", error)
          }
        }
      }
    }
  }

  private func handle(
    _ challenge: URLAuthenticationChallenge,
    webView: WKWebView,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {
    if !shouldForwardAuthenticationChallenge(challenge) {
      completionHandler(.performDefaultHandling, nil)
      return
    }

    registrar.dispatchOnMainThread { onFailure in
      self.api.didReceiveAuthenticationChallenge(
        pigeonInstance: self, webView: webView, challenge: challenge
      ) { result in
        DispatchQueue.main.async {
          switch result {
          case .success(let values):
            completionHandler(
              self.nativeAuthChallengeDisposition(from: values),
              self.nativeAuthChallengeCredential(from: values))
          case .failure(let error):
            // Cancelling here rejects TLS for every HTTPS page.
            completionHandler(.performDefaultHandling, nil)
            onFailure("WKNavigationDelegate.didReceiveAuthenticationChallenge", error)
          }
        }
      }
    }
  }

  func shouldForwardAuthenticationChallenge(_ challenge: URLAuthenticationChallenge) -> Bool {
    switch challenge.protectionSpace.authenticationMethod {
    case NSURLAuthenticationMethodServerTrust:
      return handlesSslAuthError
    case NSURLAuthenticationMethodHTTPBasic, NSURLAuthenticationMethodNTLM:
      return handlesHttpAuthRequest
    default:
      return false
    }
  }

  private func nativeNavigationActionPolicy(_ policy: NavigationActionPolicy)
    -> WKNavigationActionPolicy
  {
    switch policy {
    case .allow:
      return .allow
    case .cancel:
      return .cancel
    case .download:
      if #available(iOS 14.5, macOS 11.3, *) {
        return .download
      } else {
        assertionFailure(
          registrar.createUnsupportedVersionMessage(
            "WKNavigationActionPolicy.download",
            versionRequirements: "iOS 14.5, macOS 11.3"
          ))
        return .cancel
      }
    }
  }

  private func nativeNavigationResponsePolicy(_ policy: NavigationResponsePolicy)
    -> WKNavigationResponsePolicy
  {
    switch policy {
    case .allow:
      return .allow
    case .cancel:
      return .cancel
    case .download:
      if #available(iOS 14.5, macOS 11.3, *) {
        return .download
      } else {
        assertionFailure(
          registrar.createUnsupportedVersionMessage(
            "WKNavigationResponsePolicy.download",
            versionRequirements: "iOS 14.5, macOS 11.3"
          ))
        return .cancel
      }
    }
  }

  private func nativeAuthChallengeDisposition(from values: [Any?])
    -> URLSession.AuthChallengeDisposition
  {
    guard let disposition = values.first as? UrlSessionAuthChallengeDisposition else {
      return .performDefaultHandling
    }
    switch disposition {
    case .useCredential:
      return .useCredential
    case .performDefaultHandling:
      return .performDefaultHandling
    case .cancelAuthenticationChallenge:
      return .cancelAuthenticationChallenge
    case .rejectProtectionSpace:
      return .rejectProtectionSpace
    case .unknown:
      return .performDefaultHandling
    }
  }

  private func nativeAuthChallengeCredential(from values: [Any?]) -> URLCredential? {
    guard values.count > 1 else {
      return nil
    }
    return values[1] as? URLCredential
  }
}

/// ProxyApi implementation for `WKNavigationDelegate`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class NavigationDelegateProxyAPIDelegate: PigeonApiDelegateWKNavigationDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiWKNavigationDelegate) throws
    -> WKNavigationDelegate
  {
    return NavigationDelegateImpl(
      api: pigeonApi, registrar: pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar)
  }

  func setChallengeHandling(
    pigeonApi: PigeonApiWKNavigationDelegate, pigeonInstance: WKNavigationDelegate,
    handlesHttpAuthRequest: Bool, handlesSslAuthError: Bool
  ) throws {
    guard let impl = pigeonInstance as? NavigationDelegateImpl else {
      return
    }
    impl.handlesHttpAuthRequest = handlesHttpAuthRequest
    impl.handlesSslAuthError = handlesSslAuthError
  }
}
