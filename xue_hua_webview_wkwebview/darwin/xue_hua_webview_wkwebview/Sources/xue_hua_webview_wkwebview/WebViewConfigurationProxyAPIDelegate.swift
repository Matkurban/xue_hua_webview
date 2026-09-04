// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// ProxyApi implementation for `WKWebViewConfiguration`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class WebViewConfigurationProxyAPIDelegate: PigeonApiDelegateWKWebViewConfiguration {
    func pigeonDefaultConstructor(pigeonApi _: PigeonApiWKWebViewConfiguration) throws
        -> WKWebViewConfiguration
    {
        return WKWebViewConfiguration()
    }

    func setUserContentController(
        pigeonApi _: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration,
        controller: WKUserContentController
    ) throws {
        pigeonInstance.userContentController = controller
    }

    func getUserContentController(
        pigeonApi _: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration
    ) throws -> WKUserContentController {
        return pigeonInstance.userContentController
    }

    func setWebsiteDataStore(
        pigeonApi _: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration,
        dataStore: WKWebsiteDataStore
    ) throws {
        pigeonInstance.websiteDataStore = dataStore
    }

    func getWebsiteDataStore(
        pigeonApi _: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration
    ) throws -> WKWebsiteDataStore {
        return pigeonInstance.websiteDataStore
    }

    func setPreferences(
        pigeonApi _: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration,
        preferences: WKPreferences
    ) throws {
        pigeonInstance.preferences = preferences
    }

    func getPreferences(
        pigeonApi _: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration
    ) throws -> WKPreferences {
        return pigeonInstance.preferences
    }

    func setAllowsInlineMediaPlayback(
        pigeonApi _: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration, allow: Bool
    ) throws {
        #if !os(macOS)
            pigeonInstance.allowsInlineMediaPlayback = allow
        #endif
        // No-op, rather than error out, on macOS, since it's not a meaningful option on macOS and it's
        // easier for clients if it's just ignored.
    }

    func setLimitsNavigationsToAppBoundDomains(
        pigeonApi _: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration, limit: Bool
    ) throws -> Bool {
        if #available(iOS 14.0, macOS 11.0, *) {
            pigeonInstance.limitsNavigationsToAppBoundDomains = limit
            return true
        } else {
            return false
        }
    }

    func setMediaTypesRequiringUserActionForPlayback(
        pigeonApi _: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration,
        type: AudiovisualMediaType
    ) throws {
        switch type {
        case .none:
            pigeonInstance.mediaTypesRequiringUserActionForPlayback = []
        case .audio:
            pigeonInstance.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.audio
        case .video:
            pigeonInstance.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.video
        case .all:
            pigeonInstance.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.all
        }
    }

    func getDefaultWebpagePreferences(
        pigeonApi _: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration
    ) throws -> WKWebpagePreferences {
        return pigeonInstance.defaultWebpagePreferences
    }
}
