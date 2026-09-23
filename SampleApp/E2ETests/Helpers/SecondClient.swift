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
        if CometChat.getLoggedInUser()?.uid != TestConfig.userBUid {
            if CometChat.getLoggedInUser() != nil {
                await logout()
            }
            try await loginUserB()
        }
        // A test that called `disconnect()` (the presence "goes offline" cases) leaves the SDK in
        // its manual-disconnect state, and it stays there across logout and re-login until
        // something calls `connect()`. Without this, every presence test that runs after one of
        // those finds B logged in but never online, and fails on "header did not show Online".
        // `connect()` is a no-op when the socket is already up.
        CometChat.connect()
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
    ///
    /// The calls B starts are never answered, so they are cancelled the way the kit cancels an
    /// unanswered outgoing call (`CometChatOutgoingCall`, `CallInitiator`): `rejectCall` with
    /// `.cancelled`. `endCall` is for a call that was joined; on an unanswered one it errors, the
    /// error was swallowed, and the call stayed "initiated" — so the next test's `initiateCall`
    /// failed as busy (also swallowed) and no call ever reached the app. `endCall` stays as the
    /// fallback for a call that did get joined.
    func cancelActiveCall() async {
        guard let session = activeCallSessionID else { return }
        activeCallSessionID = nil
        let cancelled = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            var resumed = false
            CometChat.rejectCall(sessionID: session, status: .cancelled, onSuccess: { _ in
                guard !resumed else { return }; resumed = true
                cont.resume(returning: true)
            }, onError: { _ in
                guard !resumed else { return }; resumed = true
                cont.resume(returning: false)
            })
        }
        guard !cancelled else { return }
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

    /// B deletes one of its own messages through its SDK session. REST `DELETE /messages/{id}`
    /// answers 403 for both users on this app (issue register D28), so a peer delete that must
    /// reach A live has to come from B's socket session — this is the only path that works.
    func deleteMessage(id: Int) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            var resumed = false
            CometChat.delete(messageId: id, onSuccess: { _ in
                guard !resumed else { return }; resumed = true
                cont.resume()
            }, onError: { error in
                guard !resumed else { return }; resumed = true
                cont.resume(throwing: ClientError.groupActionFailed(error.errorDescription))
            })
        }
    }

    /// B records a delivered (and optionally read) receipt for a message A sent, through B's own
    /// SDK session — the way a real device does it. REST `PUT /messages/{id}/delivered|read`
    /// `onBehalfOf` the receiver does not surface as `deliveredAt`/`readAt` on the sender's
    /// copy (the Message Info rows kept "---" after it), so the Info cases go through here.
    /// `groupGuid` nil means a 1:1 with A.
    func markReceived(messageId: Int, from senderUid: String = TestConfig.userAUid,
                      groupGuid: String? = nil, read: Bool) async throws {
        let receiverId = groupGuid ?? senderUid
        let receiverType: CometChat.ReceiverType = groupGuid == nil ? .user : .group
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            var resumed = false
            CometChat.markAsDelivered(messageId: messageId, receiverId: receiverId, receiverType: receiverType,
                                      messageSender: senderUid, onSuccess: {
                guard !resumed else { return }; resumed = true
                cont.resume()
            }, onError: { error in
                guard !resumed else { return }; resumed = true
                cont.resume(throwing: ClientError.groupActionFailed(error?.errorDescription ?? "markAsDelivered(\(messageId))"))
            })
        }
        guard read else { return }
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            var resumed = false
            CometChat.markAsRead(messageId: messageId, receiverId: receiverId, receiverType: receiverType,
                                 messageSender: senderUid, onSuccess: {
                guard !resumed else { return }; resumed = true
                cont.resume()
            }, onError: { error in
                guard !resumed else { return }; resumed = true
                cont.resume(throwing: ClientError.groupActionFailed(error?.errorDescription ?? "markAsRead(\(messageId))"))
            })
        }
    }

    /// B casts a vote on a poll through the Polls extension (`v2/vote`), the same call the kit's
    /// poll bubble makes when an option is tapped. `option` is the 1-based option index.
    func votePoll(id pollId: String, option: Int) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            var resumed = false
            CometChat.callExtension(slug: "polls", type: .post, endPoint: "v2/vote",
                                    body: ["vote": "\(option)", "id": pollId], onSuccess: { _ in
                guard !resumed else { return }; resumed = true
                cont.resume()
            }, onError: { error in
                guard !resumed else { return }; resumed = true
                cont.resume(throwing: ClientError.groupActionFailed(error?.errorDescription ?? "votePoll(\(pollId))"))
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
    /// A no-op when B was never brought up: `CometChat.logout` on an SDK that was never
    /// initialised (or has nobody logged in) fires neither callback, which left a tearDown
    /// that calls this unconditionally hanging for the full 60s and failing an otherwise
    /// green test.
    func logout() async {
        guard CometChat.isInitialised, CometChat.getLoggedInUser() != nil else { return }
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
