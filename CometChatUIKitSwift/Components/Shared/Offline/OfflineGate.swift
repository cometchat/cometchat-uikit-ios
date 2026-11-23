//
//  OfflineGate.swift
//  CometChatUIKitSwift
//
//  Single call site for the offline feature flag.
//  Every conditional branch that leads to offline-ON behaviour MUST call isOn() at runtime,
//  once per operation, before taking that branch.  Never cache the result.
//

import Foundation
import CometChatSDK

/// Read-only gate for the offline feature.
///
/// Usage:
/// ```swift
/// guard OfflineGate.isOn() else {
///     // run today's code unchanged
///     return
/// }
/// // offline-aware code here
/// ```
internal enum OfflineGate {

    /// `true` when the Chat SDK has offline support enabled for the current session.
    ///
    /// Safe to call on SDK ≥ 4.2.1.  Returns `false` while no user is logged in.
    static func isOn() -> Bool {
        let on = CometChat.isOfflineEnabled()
        // Not a cache: the hub only learns that this session put offline data on screen, so a
        // logout clears it (UIK-LIFE-01) while an offline-OFF session is left untouched (P1).
        if on { OfflineHub.shared.noteOfflineUsed() }
        return on
    }
}

/// Presence while the SDK is not connected (offline ON only).
///
/// A cached user's presence is not live while the SDK is disconnected or connecting, so the kit
/// shows none: no online dot in a list, no "Online" / "last seen" subtitle in the message header.
/// On reconnect the kit's re-fetch of the user or the list restores it. Offline OFF: never hides.
internal enum OfflinePresence {

    static func isHidden() -> Bool {
        return isHidden(offlineOn: OfflineGate.isOn(), connected: CometChat.getConnectionStatus == .connected)
    }

    static func isHidden(offlineOn: Bool, connected: Bool) -> Bool {
        return offlineOn && !connected
    }
}

/// Error classification shared by the offline screens.
internal enum OfflineErrors {

    /// The SDK could not reach the server: "not connected". With rows on screen they stay and nothing
    /// is reported (D84 rule 2). With nothing on screen it is the kit's offline state, "Connect to
    /// load ..." or, for a keyword search, "Connect to search" (`OfflineReadFailure`); the list reads
    /// once more when the connection returns (`OfflineListError`).
    static func isNotConnected(code: String?) -> Bool {
        guard let code = code else { return false }
        return code == "ERROR_INTERNET_UNAVAILABLE" || code == "ERROR_NOT_CONNECTED" || code == "NO_WEBSOCKET_CONNECTION"
    }
}

/// Offline ON: what the error view a list shows over nothing is waiting for (D83).
///
/// A list that shows its error view because the device was not connected reads once by itself when the
/// connection returns; one that shows it for any other error does not. The list sets this when a load it
/// started fails with nothing on screen, and clears it when its next read starts.
internal enum OfflineListError: Equatable {
    /// No error view is waiting on a reconnect decision (today's reconnect refresh applies).
    case none
    /// The error view is for a not-connected error: the reconnect reads again, once.
    case notConnected
    /// The error view is for another error: the reconnect does not read again.
    case other

    /// The state after a failed first-page load. Rows on screen leave no error view, so `none`.
    static func afterFailure(_ error: CometChatException?, rowsShown: Bool) -> OfflineListError {
        guard !rowsShown else { return .none }
        return OfflineErrors.isNotConnected(code: error?.errorCode) ? .notConnected : .other
    }

    /// Whether a reconnect leaves the list alone: it shows an error view for a non-network error.
    var skipsReconnectReload: Bool { return self == .other }
}

/// Offline ON, D84: what a failed list read leaves on screen and whether it reaches `onError`.
///
/// One decision for every list, so the rules cannot drift apart:
/// - rows on screen: they stay. A not-connected failure reports nothing (rule 2). Any other error
///   reports once if the user or app started the load, and nothing if the kit did (rule 5).
/// - nothing on screen and not connected: the kit's offline state (rule 3), `onError` once. For a
///   keyword search it is "Connect to search" instead (rule 7), and no `onError`.
/// - nothing on screen and any other error: the error view and `onError` (rule 4).
///
/// "Keyword search" means a read whose request carries a non-empty search keyword: the search box, or
/// a list opened with a keyword. A list opened with only a filter (online users, tags) is a plain
/// list (addition B), so it reads "Connect to load ...".
internal struct OfflineReadFailure: Equatable {

    enum Screen: Equatable {
        /// Rows are on screen and stay; no error view.
        case rowsKept
        /// "Connect to load ..." (the app's error view, if it set one, shows instead).
        case connectToLoad
        /// "Connect to search" and its second line.
        case connectToSearch
        /// The error view, with Retry.
        case errorView
    }

    let screen: Screen
    /// Whether `onError` fires for this failure.
    let reportsError: Bool

    static func evaluate(_ error: CometChatException?, rowsShown: Bool, keywordSearch: Bool, kitStarted: Bool) -> OfflineReadFailure {
        let notConnected = OfflineErrors.isNotConnected(code: error?.errorCode)
        if rowsShown {
            return OfflineReadFailure(screen: .rowsKept, reportsError: !notConnected && !kitStarted)
        }
        if notConnected {
            return keywordSearch ? OfflineReadFailure(screen: .connectToSearch, reportsError: false)
                                 : OfflineReadFailure(screen: .connectToLoad, reportsError: true)
        }
        return OfflineReadFailure(screen: .errorView, reportsError: true)
    }

    /// A keyword the list's own request or the search box carries. Whitespace alone is no keyword.
    static func isKeyword(_ keyword: String?) -> Bool {
        return !(keyword ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

/// Offline ON, D84 rule 7 for the Search screen: what a finished search leaves on screen, whether `onError`
/// fires, and whether the search runs again when the connection returns. The same decision as Android's
/// `CometChatSearchViewModel.updateFinalStateIfCompleted`:
/// - "Connect to search" (the empty state, no `onError`) when nothing is shown, no request failed with an
///   error other than not-connected, and a keyword request failed for want of a connection or both the
///   conversation and the message request failed. A search with only a filter counts when both ran.
/// - both requests failed otherwise: the error view and `onError` (once).
/// - one request failed and nothing is shown: the plain empty state, no `onError`, no re-run.
/// - results on screen: they stay; an online failure reports once, unless the kit started the search.
internal struct OfflineSearchOutcome: Equatable {

    enum Screen: Equatable {
        /// Results are on screen.
        case results
        /// The screen's own "no results" state.
        case empty
        /// "Connect to search" and its second line.
        case connectToSearch
        /// The error view, with Retry.
        case errorView
    }

    let screen: Screen
    /// Whether `onError` fires for this search.
    let reportsError: Bool
    /// Whether the search runs again, once, when the connection returns (rule 8).
    let runsAgainOnReconnect: Bool

    static func evaluate(nothingShown: Bool, conversationFailed: Bool, messageFailed: Bool, failedOnline: Bool,
                         keywordFailedNotConnected: Bool, lastErrorNotConnected: Bool, rowsKeptError: Bool,
                         quiet: Bool) -> OfflineSearchOutcome {
        let bothFailed = conversationFailed && messageFailed
        if nothingShown && !failedOnline && (keywordFailedNotConnected || bothFailed) {
            return OfflineSearchOutcome(screen: .connectToSearch, reportsError: false, runsAgainOnReconnect: true)
        }
        if bothFailed {
            return OfflineSearchOutcome(screen: .errorView, reportsError: true, runsAgainOnReconnect: lastErrorNotConnected)
        }
        if nothingShown {
            return OfflineSearchOutcome(screen: .empty, reportsError: false, runsAgainOnReconnect: false)
        }
        return OfflineSearchOutcome(screen: .results, reportsError: rowsKeptError && !quiet, runsAgainOnReconnect: false)
    }
}
