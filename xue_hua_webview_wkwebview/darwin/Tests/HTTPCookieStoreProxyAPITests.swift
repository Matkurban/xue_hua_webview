// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest
@testable import xue_hua_webview_wkwebview

class HTTPCookieStoreProxyAPITests: XCTestCase {
    @MainActor func testSetCookie() throws {
        let registrar = TestProxyApiRegistrar()
        let api = registrar.apiDelegate.pigeonApiWKHTTPCookieStore(registrar)

        let instance: TestCookieStore? = TestCookieStore.customInit()
        let cookie = try XCTUnwrap(HTTPCookie(properties: [
            .name: "foo", .value: "bar", .domain: "http://google.com",
            .path: "/anything",
        ]))

        let expect = expectation(description: "Wait for setCookie.")
        try api.pigeonDelegate.setCookie(
            pigeonApi: api,
            pigeonInstance: XCTUnwrap(instance),
            cookie: cookie
        ) {
            result in
            switch result {
            case .success:
                XCTAssertEqual(instance!.setCookieArg, cookie)
            case let .failure(error):
                XCTFail("\(error)")
            }
            expect.fulfill()
        }

        wait(for: [expect], timeout: 1.0)
    }

    @MainActor func testGetCookies() throws {
        let registrar = TestProxyApiRegistrar()
        let api = registrar.apiDelegate.pigeonApiWKHTTPCookieStore(registrar)

        let cookie1 = try XCTUnwrap(HTTPCookie(properties: [
            .name: "foo", .value: "bar", .domain: "google.com", .path: "/",
        ]))
        let cookie2 = try XCTUnwrap(HTTPCookie(properties: [
            .name: "baz", .value: "qux", .domain: "example.com", .path: "/",
        ]))

        let instance: TestCookieStore? = TestCookieStore.customInit()
        instance?.allCookies = [cookie1, cookie2]

        // Test fetching all cookies
        let expectAll = expectation(description: "Wait for getAllCookies.")
        try api.pigeonDelegate.getAllCookies(
            pigeonApi: api,
            pigeonInstance: XCTUnwrap(instance)
        ) { result in
            switch result {
            case let .success(cookies):
                XCTAssertEqual(cookies.count, 2)
                XCTAssertTrue(cookies.contains(cookie1))
                XCTAssertTrue(cookies.contains(cookie2))
            case let .failure(error):
                XCTFail("\(error)")
            }
            expectAll.fulfill()
        }

        wait(for: [expectAll], timeout: 1.0)
    }
}

class TestCookieStore: WKHTTPCookieStore {
    var setCookieArg: HTTPCookie?
    var allCookies: [HTTPCookie] = []

    /// Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
    static func customInit() -> TestCookieStore {
        return TestCookieStore.perform(NSSelectorFromString("new"))
            .takeRetainedValue() as! TestCookieStore
    }

    #if compiler(>=6.0)
        override func setCookie(
            _ cookie: HTTPCookie,
            completionHandler: (@MainActor () -> Void)? = nil
        ) {
            setCookieArg = cookie
            DispatchQueue.main.async {
                completionHandler?()
            }
        }
    #else
        override func setCookie(
            _ cookie: HTTPCookie,
            completionHandler: (() -> Void)? = nil
        ) {
            setCookieArg = cookie
            DispatchQueue.main.async {
                completionHandler?()
            }
        }
    #endif

    override func getAllCookies(
        _ completionHandler: @escaping @MainActor ([HTTPCookie]) -> Void
    ) {
        DispatchQueue.main.async {
            completionHandler(self.allCookies)
        }
    }
}
