// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest
@testable import xue_hua_webview_wkwebview

#if os(iOS)
    import Flutter
#elseif os(macOS)
    import FlutterMacOS
#else
    #error("Unsupported platform.")
#endif

class FWFWebViewFlutterWKWebViewExternalAPITests: XCTestCase {
    @MainActor func testWebViewForIdentifier() throws {
        let registry = TestRegistry()

        #if os(iOS)
            let registrar = try XCTUnwrap(registry.registrar(forPlugin: ""))
        #elseif os(macOS)
            let registrar = registry.registrar(forPlugin: "")
        #endif

        WebViewFlutterPlugin.register(with: registrar)

        let plugin = registry.registrar.plugin

        let webView = WKWebView(frame: .zero)
        let webViewIdentifier = 0
        plugin?.proxyApiRegistrar?.instanceManager.addDartCreatedInstance(
            webView, withIdentifier: Int64(webViewIdentifier)
        )

        let result = FWFWebViewFlutterWKWebViewExternalAPI.webView(
            forIdentifier: Int64(webViewIdentifier), withPluginRegistry: registry
        )
        XCTAssertEqual(result, webView)
    }

    @MainActor func testWebViewForIdentifierHandlesIncorrectRegistry() {
        let registry = TestRegistry(publishedValue: false)
        // Ensure that passing an empty registry, such as the FlutterAppDelegate
        // in an app that has adopted UIScene, gracefully returns nil.
        let result = FWFWebViewFlutterWKWebViewExternalAPI.webView(
            forIdentifier: 0, withPluginRegistry: registry
        )
        XCTAssertEqual(result, nil)
    }

    #if os(iOS)
        @MainActor func testWebViewForIdentifierFromRegistrarUsesOfficialLookup() throws {
            let registry = TestRegistry()
            let registrar = try XCTUnwrap(registry.registrar(forPlugin: ""))

            WebViewFlutterPlugin.register(with: registrar)

            let plugin = try XCTUnwrap(registry.registrar.plugin)
            let webView = WKWebView(frame: .zero)
            let webViewIdentifier = 1
            plugin.proxyApiRegistrar?.instanceManager.addDartCreatedInstance(
                webView, withIdentifier: Int64(webViewIdentifier)
            )

            // Prove this path does not depend on the compatibility lookup.
            WebViewFlutterPluginLookup.unregister(
                plugin, for: registry.registrar.testBinaryMessenger
            )

            let result = FWFWebViewFlutterWKWebViewExternalAPI.webView(
                forIdentifier: Int64(webViewIdentifier), withPluginRegistrar: registrar
            )
            XCTAssertEqual(result, webView)
        }

        @MainActor func testWebViewForIdentifierFromRegistrarUsesLegacyLookup() throws {
            let registry = TestRegistry()
            registry.registrar.supportsOfficialPublishedValueLookup = false
            let registrar = try XCTUnwrap(registry.registrar(forPlugin: ""))

            WebViewFlutterPlugin.register(with: registrar)

            let plugin = try XCTUnwrap(registry.registrar.plugin)
            let webView = WKWebView(frame: .zero)
            let webViewIdentifier = 2
            plugin.proxyApiRegistrar?.instanceManager.addDartCreatedInstance(
                webView, withIdentifier: Int64(webViewIdentifier)
            )

            let result = FWFWebViewFlutterWKWebViewExternalAPI.webView(
                forIdentifier: Int64(webViewIdentifier), withPluginRegistrar: registrar
            )
            XCTAssertEqual(result, webView)
        }

        @MainActor func testWebViewForIdentifierFromRegistrarIsEngineScoped() throws {
            let registry = TestRegistry()
            registry.registrar.supportsOfficialPublishedValueLookup = false
            try WebViewFlutterPlugin.register(with: XCTUnwrap(registry.registrar(forPlugin: "")))

            let unrelatedRegistrar = TestFlutterPluginRegistrar()
            unrelatedRegistrar.supportsOfficialPublishedValueLookup = false
            let result = FWFWebViewFlutterWKWebViewExternalAPI.webView(
                forIdentifier: 0, withPluginRegistrar: unrelatedRegistrar
            )
            XCTAssertNil(result)
        }

        @MainActor func testLegacyRegistrarLookupIsRemovedDuringTeardown() throws {
            let registry = TestRegistry()
            registry.registrar.supportsOfficialPublishedValueLookup = false
            let registrar = try XCTUnwrap(registry.registrar(forPlugin: ""))
            WebViewFlutterPlugin.register(with: registrar)

            let plugin = try XCTUnwrap(registry.registrar.plugin)
            plugin.detachFromEngine(for: registrar)

            XCTAssertNil(WebViewFlutterPluginLookup.plugin(publishedBy: registrar))
        }
    #endif
}

class TestRegistry: NSObject, FlutterPluginRegistry {
    let registrar = TestFlutterPluginRegistrar()
    let publishedValue: Bool

    init(publishedValue: Bool) {
        self.publishedValue = publishedValue
    }

    override convenience init() {
        self.init(publishedValue: true)
    }

    #if os(iOS)
        func registrar(forPlugin _: String) -> FlutterPluginRegistrar? {
            return registrar
        }
    #elseif os(macOS)
        func registrar(forPlugin _: String) -> FlutterPluginRegistrar {
            return registrar
        }
    #endif

    func hasPlugin(_: String) -> Bool {
        return true
    }

    func valuePublished(byPlugin pluginKey: String) -> NSObject? {
        if publishedValue, pluginKey == "WebViewFlutterPlugin" {
            return registrar.plugin
        }
        return nil
    }
}

class TestFlutterTextureRegistry: NSObject, FlutterTextureRegistry {
    func register(_: FlutterTexture) -> Int64 {
        return 0
    }

    func textureFrameAvailable(_: Int64) {}

    func unregisterTexture(_: Int64) {}
}

class TestFlutterPluginRegistrar: NSObject, FlutterPluginRegistrar {
    let testBinaryMessenger = TestBinaryMessenger()
    var publishedValue: NSObject?
    var supportsOfficialPublishedValueLookup = true
    var plugin: WebViewFlutterPlugin? {
        return publishedValue as? WebViewFlutterPlugin
    }

    #if os(iOS)
        var viewController: UIViewController?
        var sceneDelegate: AnyObject?

        func messenger() -> FlutterBinaryMessenger {
            return testBinaryMessenger
        }

        func textures() -> FlutterTextureRegistry {
            return TestFlutterTextureRegistry()
        }

        func addApplicationDelegate(_: FlutterPlugin) {}

        func register(
            _: FlutterPlatformViewFactory, withId _: String,
            gestureRecognizersBlockingPolicy _: FlutterPlatformViewGestureRecognizersBlockingPolicy
        ) {}

        func addSceneDelegate(_ delegate: any FlutterSceneLifeCycleDelegate) {
            sceneDelegate = delegate as AnyObject
        }
    #elseif os(macOS)
        var view: NSView?
        var viewController: NSViewController?

        var messenger: FlutterBinaryMessenger {
            return testBinaryMessenger
        }

        var textures: FlutterTextureRegistry {
            return TestFlutterTextureRegistry()
        }

        func addApplicationDelegate(_: FlutterAppLifecycleDelegate) {}
    #endif

    func register(_: FlutterPlatformViewFactory, withId _: String) {}

    func publish(_ value: NSObject) {
        publishedValue = value
    }

    func addMethodCallDelegate(_: FlutterPlugin, channel _: FlutterMethodChannel) {}

    func lookupKey(forAsset _: String) -> String {
        return ""
    }

    func lookupKey(forAsset _: String, fromPackage _: String) -> String {
        return ""
    }

    func valuePublished(byPlugin pluginKey: String) -> NSObject? {
        if pluginKey == "WebViewFlutterPlugin" {
            return publishedValue
        }
        return nil
    }

    override func responds(to aSelector: Selector!) -> Bool {
        if !supportsOfficialPublishedValueLookup
            && aSelector == NSSelectorFromString("valuePublishedByPlugin:")
        {
            return false
        }
        return super.responds(to: aSelector)
    }
}
