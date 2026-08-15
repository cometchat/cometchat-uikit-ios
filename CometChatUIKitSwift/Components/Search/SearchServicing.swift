//
//  SearchServicing.swift
//
//  A thin seam over the non-hermetic SDK state read by SearchViewModel's event
//  handlers. Only the logged-in user is abstracted: `CometChat.getLoggedInUser()`
//  returns nil without a live session, which would make the handler branches keyed
//  on it untestable. The search fetches are NOT part of this seam — they run behind
//  a debounce plus a DispatchGroup fan-out, so they are covered E2E rather than here.
//
//  Listeners are also excluded — tests avoid them by using the `internal init(service:)`
//  (which skips `connect()`) and invoking the public handler / mutation methods directly.
//
//  This type is `internal` and reached from tests via `@testable import`.
//

import Foundation
import CometChatSDK

/// Abstraction over the SDK session state that SearchViewModel depends on.
/// Kept intentionally small so a hand-written fake in the test target is trivial.
protocol SearchServicing {

    /// The currently logged-in user, if any.
    func loggedInUser() -> User?
}

/// Production implementation backed directly by the SDK.
final class LiveSearchService: SearchServicing {

    func loggedInUser() -> User? {
        return CometChat.getLoggedInUser()
    }
}
