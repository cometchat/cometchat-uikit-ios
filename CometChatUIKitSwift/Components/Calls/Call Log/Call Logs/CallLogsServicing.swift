//
//  CallLogsServicing.swift
//
//  A thin seam over the one non-hermetic call `CallLogsViewModel` makes: fetching a page
//  of call logs. `CallLogsRequest` is `@objc final public` and is built inside the view
//  model, so without this protocol `fetchNext()` — and with it the pagination, refresh and
//  error paths — cannot be reached from a test.
//
//  The seam is deliberately one method, mirroring the Android UI Kit's `CallLogsDataSource`
//  (`suspend fun fetchCallLogs(request): Result<List<CallLog>>`), which exists for the same
//  reason. As there, the production implementation is a pass-through to the SDK and is left
//  untested: the tested surface is the view model's own logic, not the SDK's.
//
//  This type is `internal` and reached from tests via `@testable import`.
//

import Foundation
#if canImport(CometChatCallsSDK)
import CometChatCallsSDK

/// Abstraction over the SDK fetch that `CallLogsViewModel` depends on.
/// Kept intentionally small so a hand-written fake in the test target is trivial.
protocol CallLogsServicing {

    /// Fetch the next page for the given request.
    ///
    /// The request is passed through untouched — the seam exists to intercept the call,
    /// not to reinterpret it, so a fake is free to ignore it and return canned pages.
    func fetchNext(
        request: CometChatCallsSDK.CallLogsRequest,
        onSuccess: @escaping ([CometChatCallsSDK.CallLog]) -> Void,
        onError: @escaping (CometChatCallsSDK.CometChatCallException?) -> Void
    )
}

/// Production implementation backed directly by the SDK.
final class LiveCallLogsService: CallLogsServicing {

    func fetchNext(
        request: CometChatCallsSDK.CallLogsRequest,
        onSuccess: @escaping ([CometChatCallsSDK.CallLog]) -> Void,
        onError: @escaping (CometChatCallsSDK.CometChatCallException?) -> Void
    ) {
        request.fetchNext(onSuccess: onSuccess, onError: onError)
    }
}

#endif
