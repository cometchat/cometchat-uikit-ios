import Foundation
import CometChatSDK

/// A live second CometChat client hosted INSIDE the XCUITest runner process, logged in as User B.
///
/// Everywhere else the peer is driven over REST (`PeerActions`, `onBehalfOf`). REST has no
/// "start typing" endpoint, so a real incoming typing indicator can only be produced by a live SDK
/// client calling `CometChat.startTyping`. `CometChat` is a process-level singleton (login/logout/
/// startTyping are static, one logged-in user per process) — but the app-under-test runs in a
/// SEPARATE process from this test runner, so its singleton (User A) and ours (User B) never collide.
/// That process separation is the whole reason this works; do not consolidate this with the app's client.
///
/// An `actor` because the SDK's callbacks fire on background threads — the actor gives a clean await
/// boundary and serializes the singleton lifecycle (init once, login once).
actor SecondClient {

    static let shared = SecondClient()

    /// The last typing indicator sent, so `endTyping` can target the same receiver.
    private var activeIndicator: TypingIndicator?

    enum ClientError: Error, CustomStringConvertible {
        case initFailed(String)
        case loginFailed(String)
        case groupActionFailed(String)
        case callActionFailed(String)

        var description: String {
            switch self {
            case let .initFailed(m):  return "SecondClient init failed: \(m)"
            case let .loginFailed(m): return "SecondClient login failed: \(m)"
            case let .groupActionFailed(m): return "SecondClient group action failed: \(m)"
            case let .callActionFailed(m): return "SecondClient call action failed: \(m)"
            }
        }
    }

    // MARK: - Bring-up

    /// Idempotent: init the SDK if needed, then ensure User B is the logged-in user. Safe to call from
    /// every test — reuses an existing B session, logs out any other leftover user first.
    func ensureLoggedInAsUserB() async throws {
        if !CometChat.isInitialised {
            try await initSDK()
        }
        if CometChat.getLoggedInUser()?.uid == TestConfig.userBUid {
            return
        }
        if CometChat.getLoggedInUser() != nil {
            await logout()
        }
        try await loginUserB()
    }

    private func initSDK() async throws {
        let settings = AppSettings.AppSettingsBuilder()
            .setRegion(region: TestConfig.region)
            .subscribePresenceForAllUsers()
            .autoEstablishSocketConnection(true)
            .build()

        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            var resumed = false
            _ = CometChat(appId: TestConfig.appId, appSettings: settings, onSuccess: { _ in
                guard !resumed else { return }; resumed = true
                cont.resume()
            }, onError: { error in
                guard !resumed else { return }; resumed = true
                cont.resume(throwing: ClientError.initFailed(error.errorDescription))
            })
        }
    }

    private func loginUserB() async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            var resumed = false
            CometChat.login(UID: TestConfig.userBUid, authKey: TestConfig.authKey, onSuccess: { _ in
                guard !resumed else { return }; resumed = true
                cont.resume()
            }, onError: { error in
                guard !resumed else { return }; resumed = true
                cont.resume(throwing: ClientError.loginFailed(error.errorDescription))
            })
        }
    }

    // MARK: - Typing

    /// User B types to User A in a 1:1. `receiverID` is A (B is typing TO A), receiverType `.user`.
    func startTyping(toUser uid: String) {
        let indicator = TypingIndicator(receiverID: uid, receiverType: .user)
        activeIndicator = indicator
        CometChat.startTyping(indicator: indicator)
    }

    /// User B types in a group. `receiverID` is the group guid, receiverType `.group`.
    func startTyping(toGroup guid: String) {
        let indicator = TypingIndicator(receiverID: guid, receiverType: .group)
        activeIndicator = indicator
        CometChat.startTyping(indicator: indicator)
    }

    /// Stop the active typing indicator. Best-effort — a no-op if nothing is active.
    func endTyping() {
        guard let indicator = activeIndicator else { return }
        CometChat.endTyping(indicator: indicator)
        activeIndicator = nil
    }

    // MARK: - Group membership

    /// Join/leave have no REST contract — only a live SDK client can fire them, so these are the
    /// single source of the "joined"/"left" action messages the app renders.

    /// User B leaves the group.
    func leaveGroup(guid: String) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            var resumed = false
            CometChat.leaveGroup(GUID: guid, onSuccess: { _ in
                guard !resumed else { return }; resumed = true
                cont.resume()
            }, onError: { error in
                guard !resumed else { return }; resumed = true
                cont.resume(throwing: ClientError.groupActionFailed(error?.errorDescription ?? "leaveGroup(\(guid))"))
            })
        }
    }

    /// User B joins a public group.
    func joinGroup(guid: String) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            var resumed = false
            CometChat.joinGroup(GUID: guid, groupType: .public, password: nil, onSuccess: { _ in
                guard !resumed else { return }; resumed = true
                cont.resume()
            }, onError: { error in
                guard !resumed else { return }; resumed = true
                cont.resume(throwing: ClientError.groupActionFailed(error?.errorDescription ?? "joinGroup(\(guid))"))
            })
        }
    }

    // MARK: - Calls

    /// The session id of B's last initiated call, so `cancelActiveCall` can end exactly that call.
    private var activeCallSessionID: String?

    /// User B places a real call to User A. This fires `onIncomingCallReceived` on A's SDK; whether A's
    /// app presents an incoming-call surface depends on the app's `inAppIncomingCall` setting (the sample
    /// app ships it OFF, so this is used with an "overlay OR stable" assertion, matching the Flutter suite).
    /// `initiateCall` and the `Call` type are on the base `CometChatSDK` — no Calls SDK required here.
    /// Returns the session id (nil if the backend didn't return one).
    @discardableResult
    func initiateCall(toUser uid: String, video: Bool) async throws -> String? {
        let call = Call(receiverId: uid, callType: video ? .video : .audio, receiverType: .user)
        let session: String? = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<String?, Error>) in
            var resumed = false
            CometChat.initiateCall(call: call, onSuccess: { initiated in
                guard !resumed else { return }; resumed = true
                cont.resume(returning: initiated?.sessionID)
            }, onError: { error in
                guard !resumed else { return }; resumed = true
                cont.resume(throwing: ClientError.callActionFailed(error?.errorDescription ?? "initiateCall(\(uid))"))
            })
        }
        activeCallSessionID = session
        return session
    }

    /// End B's active call (models "caller cancels" / "call ended"). Best-effort — never throws, so it's
    /// safe in teardown and after an assertion. No-op if there's no active call.
    func cancelActiveCall() async {
        guard let session = activeCallSessionID else { return }
        activeCallSessionID = nil
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            var resumed = false
            CometChat.endCall(sessionID: session, onSuccess: { _ in
                guard !resumed else { return }; resumed = true
                cont.resume()
            }, onError: { _ in
                guard !resumed else { return }; resumed = true
                cont.resume()
            })
        }
    }

    // MARK: - Teardown

    /// Release B's socket session so it can't race REST-driven B tests (`goOnline`/`goOffline`).
    /// Never throws — teardown must not mask the test result. Ends any active call first so a ringing
    /// call can't leak into a later test.
    func logout() async {
        await cancelActiveCall()
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            var resumed = false
            CometChat.logout(onSuccess: { _ in
                guard !resumed else { return }; resumed = true
                cont.resume()
            }, onError: { _ in
                guard !resumed else { return }; resumed = true
                cont.resume()
            })
        }
    }
}
