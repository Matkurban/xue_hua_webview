// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
    import Flutter
#elseif os(macOS)
    import FlutterMacOS
#else
    #error("Unsupported platform.")
#endif

class TestBinaryMessenger: NSObject, FlutterBinaryMessenger {
    func send(onChannel _: String, message _: Data?) {}

    func send(
        onChannel _: String, message _: Data?, binaryReply _: FlutterBinaryReply? = nil
    ) {}

    func setMessageHandlerOnChannel(
        _: String, binaryMessageHandler _: FlutterBinaryMessageHandler? = nil
    ) -> FlutterBinaryMessengerConnection {
        return 0
    }

    func cleanUpConnection(_: FlutterBinaryMessengerConnection) {}
}
