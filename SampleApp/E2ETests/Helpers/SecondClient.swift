import Foundation
import CometChatSDK

/// A live second CometChat client (User B) in the runner process, for producing real incoming typing/calls
/// that REST can't. Its singleton can't collide with the app's User A (separate process). `actor` for the SDK's background callbacks.
actor SecondClient {

    static let shared = SecondClient()

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

    /// Idempotent: init the SDK if needed, then ensure User B is the logged-in user.
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

    func startTyping(toUser uid: String) {
        let indicator = TypingIndicator(receiverID: uid, receiverType: .user)
        activeIndicator = indicator
        CometChat.startTyping(indicator: indicator)
    }

    func startTyping(toGroup guid: String) {
        let indicator = TypingIndicator(receiverID: guid, receiverType: .group)
        activeIndicator = indicator
        CometChat.startTyping(indicator: indicator)
    }

    func endTyping() {
        guard let indicator = activeIndicator else { return }
        CometChat.endTyping(indicator: indicator)
        activeIndicator = nil
    }

    /// Join/leave have no REST contract — only a live SDK client can fire the action messages.
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

    private var activeCallSessionID: String?

    /// Places a real call to A. Whether A shows an incoming surface depends on `inAppIncomingCall` (OFF in sample app).
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

    /// Best-effort end of B's active call — never throws, safe in teardown. No-op if none active.
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

    /// Take B offline without ending its session. Prefer over `logout()` for presence: sync and callback-free,
    /// whereas `CometChat.logout` can fire neither callback and hang.
    func disconnect() {
        CometChat.disconnect()
    }

    /// Bring B back online after `disconnect()`.
    func reconnect() {
        CometChat.connect()
    }

    /// Release B's socket session so it can't race REST-driven B tests; ends any active call first.
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
