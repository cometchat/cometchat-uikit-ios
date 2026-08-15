//
//  IncomingCallServicing.swift
//
//  A thin seam over the non-hermetic SDK calls used by IncomingCallViewModel.
//  Only request/response style calls are abstracted here (accept / reject).
//  Listeners are NOT part of this seam — tests avoid them by simply not calling
//  `connect()` and instead invoking the delegate handlers directly.
//
//  This type is `internal` and reached from tests via `@testable import`.
//

import Foundation
import CometChatSDK

/// Abstraction over the SDK request/response calls that IncomingCallViewModel depends on.
/// Kept intentionally small so a hand-written fake in the test target is trivial.
protocol IncomingCallServicing {

    /// Accept the call for the given session.
    func acceptCall(
        sessionID: String,
        onSuccess: @escaping (Call?) -> Void,
        onError: @escaping (CometChatException?) -> Void
    )

    /// Reject the call for the given session.
    func rejectCall(
        sessionID: String,
        status: CometChat.callStatus,
        onSuccess: @escaping (Call?) -> Void,
        onError: @escaping (CometChatException?) -> Void
    )
}

/// Production implementation backed directly by the SDK.
final class LiveIncomingCallService: IncomingCallServicing {

    func acceptCall(
        sessionID: String,
        onSuccess: @escaping (Call?) -> Void,
        onError: @escaping (CometChatException?) -> Void
    ) {
        CometChat.acceptCall(sessionID: sessionID, onSuccess: onSuccess, onError: onError)
    }

    func rejectCall(
        sessionID: String,
        status: CometChat.callStatus,
        onSuccess: @escaping (Call?) -> Void,
        onError: @escaping (CometChatException?) -> Void
    ) {
        CometChat.rejectCall(sessionID: sessionID, status: status, onSuccess: onSuccess, onError: onError)
    }
}
