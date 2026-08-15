//
//  MessageHeaderServicing.swift
//
//  A thin seam over the non-hermetic SDK call used by MessageHeaderViewModel.
//  MessageHeader is almost entirely pure handler logic — the only request/response
//  style dependency is the logged-in user consulted by the group scope-change
//  handler. Listeners are NOT part of this seam — tests avoid them by using the
//  `internal init(service:)` (which registers no listeners; the view calls
//  `connect()` separately) and invoking the public handler methods directly.
//
//  This type is `internal` and reached from tests via `@testable import`.
//

import Foundation
import CometChatSDK

/// Abstraction over the SDK request/response calls that MessageHeaderViewModel depends on.
/// Kept intentionally small so a hand-written fake in the test target is trivial.
protocol MessageHeaderServicing {

    /// The currently logged-in user, if any.
    func loggedInUser() -> User?
}

/// Production implementation backed directly by the SDK.
final class LiveMessageHeaderService: MessageHeaderServicing {

    func loggedInUser() -> User? {
        return CometChat.getLoggedInUser()
    }
}
