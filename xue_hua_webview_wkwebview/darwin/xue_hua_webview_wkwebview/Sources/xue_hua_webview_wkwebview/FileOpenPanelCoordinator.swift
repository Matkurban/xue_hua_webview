// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(macOS)
    import AppKit
    import WebKit

    /// Presents `NSOpenPanel` for WKWebView file inputs and completes exactly once.
    final class FileOpenPanelCoordinator {
        private var pendingCompletion: (([URL]?) -> Void)?
        private var panel: NSOpenPanel?

        func present(
            allowsMultipleSelection: Bool,
            allowsDirectories: Bool,
            completionHandler: @escaping ([URL]?) -> Void
        ) {
            dismissOpenPanel()
            finishPending(nil)
            pendingCompletion = completionHandler

            guard
                let window = NSApp.keyWindow ?? NSApp.mainWindow
                ?? NSApp.windows.first(where: { $0.isVisible })
            else {
                finishPending(nil)
                return
            }

            let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = allowsMultipleSelection
            openPanel.canChooseDirectories = allowsDirectories
            openPanel.canChooseFiles = true
            openPanel.canCreateDirectories = false
            openPanel.resolvesAliases = true
            panel = openPanel

            openPanel.beginSheetModal(for: window) { [weak self] response in
                guard let self else { return }
                guard self.panel === openPanel else { return }
                self.panel = nil
                if response == .OK {
                    self.finishPending(openPanel.urls)
                } else {
                    self.finishPending(nil)
                }
            }
        }

        func cancelPending() {
            dismissOpenPanel()
            finishPending(nil)
        }

        /// Test hook: install a pending completion without showing a panel.
        func setPendingForTesting(_ completion: @escaping ([URL]?) -> Void) {
            dismissOpenPanel()
            finishPending(nil)
            pendingCompletion = completion
        }

        /// Test hook: attach a panel identity used by stale-completion checks.
        func attachPanelForTesting(_ openPanel: NSOpenPanel) {
            panel = openPanel
        }

        /// Test hook: simulate a sheet completion for `openPanel`.
        func completePanelForTesting(_ openPanel: NSOpenPanel, urls: [URL]?) {
            guard panel === openPanel else { return }
            panel = nil
            finishPending(urls)
        }

        var hasPendingCompletion: Bool {
            pendingCompletion != nil
        }

        private func dismissOpenPanel() {
            if let panel {
                self.panel = nil
                panel.close()
            }
        }

        private func finishPending(_ urls: [URL]?) {
            let completion = pendingCompletion
            pendingCompletion = nil
            completion?(urls)
        }
    }
#endif
