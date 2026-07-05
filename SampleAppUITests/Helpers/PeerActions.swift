import Foundation

/// Drives the peer ("User B") via the CometChat REST API, removing the need for a second simulator.
/// Every write carries the `onBehalfOf` header to impersonate a user without their auth token.
/// `URLSession.dataTask` + continuation rather than `data(for:)` for the iOS 13 deployment target.
enum PeerActions {
    
    private static var baseURL: String {
        "https://\(TestConfig.appId).api-\(TestConfig.region).cometchat.io/v3"
    }
    
    private static var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "apiKey": TestConfig.restApiKey,
            "appId": TestConfig.appId,
        ]
    }
    
    enum PeerError: Error, CustomStringConvertible {
        case badURL(String)
        case http(operation: String, status: Int, body: String)
        case missingMessageID(body: String)
        
        var description: String {
            switch self {
            case let .badURL(url):
                return "PeerActions: malformed URL \(url)"
            case let .http(operation, status, body):
                return "PeerActions.\(operation) failed: \(status) \(body)"
            case let .missingMessageID(body):
                return "PeerActions: response had no message id: \(body)"
            }
        }
    }
    
    @discardableResult
    static func sendTextMessage(_ text: String) async throws -> Int {
        try await sendMessage(receiver: TestConfig.userAUid,
                              receiverType: "user",
                              text: text,
                              onBehalfOf: TestConfig.userBUid,
                              operation: "sendTextMessage")
    }
    
    @discardableResult
    static func sendGroupTextMessage(_ text: String, groupId: String? = nil) async throws -> Int {
        try await sendMessage(
            receiver: groupId ?? TestConfig.groupGuid,
            receiverType: "group",
            text: text,
            onBehalfOf: TestConfig.userBUid,
            operation: "sendGroupTextMessage"
        )
    }
    
    /// Per-message timestamp token keeps assertions exact and avoids cross-run collisions.
    @discardableResult
    static func sendMultipleMessages(_ count: Int,
                                     prefix: String = "E2E msg",
                                     delayBetween: TimeInterval = 0.2) async throws -> [Int] {
        var ids: [Int] = []
        let stamp = ISO8601DateFormatter().string(from: Date())
        for i in 1...max(count, 0) {
            let id = try await sendTextMessage("\(prefix) #\(i) - \(stamp)")
            ids.append(id)
            if i < count {
                try await Task.sleep(nanoseconds: UInt64(delayBetween * 1_000_000_000))
            }
        }
        return ids
    }
    
    static func deleteMessage(_ messageId: Int) async throws {
        guard let url = URL(string: "\(baseURL)/messages/\(messageId)") else {
            throw PeerError.badURL("\(baseURL)/messages/\(messageId)")
        }
        _ = try await send(url: url, method: "DELETE", body: nil,
                           onBehalfOf: TestConfig.userBUid, operation: "deleteMessage")
    }
    
    static func editMessage(_ messageId: Int, newText: String) async throws {
        guard let url = URL(string: "\(baseURL)/messages/\(messageId)") else {
            throw PeerError.badURL("\(baseURL)/messages/\(messageId)")
        }
        let body = try JSONSerialization.data(withJSONObject: ["data": ["text": newText]])
        _ = try await send(url: url, method: "PUT", body: body,
                           onBehalfOf: TestConfig.userBUid, operation: "editMessage")
    }
    
    static func ensureConversationExists() async throws {
        let stamp = ISO8601DateFormatter().string(from: Date())
        try await sendTextMessage("E2E seed message \(stamp)")
    }
    
    static func deleteConversation() async {
        let path = "\(baseURL)/users/\(TestConfig.userAUid)/conversation/user_\(TestConfig.userBUid)"
        guard let url = URL(string: path) else { return }
        _ = try? await send(url: url, method: "DELETE", body: nil,
                            onBehalfOf: TestConfig.userAUid, operation: "deleteConversation")
    }
    
    /// Whether the A↔B conversation still exists on the backend. A 404 (conversation deleted) — or any
    /// non-2xx — reads as `false`. Lets a delete test assert on the server instead of counting cells,
    /// which hangs the a11y bridge on this heavy list.
    ///
    /// Note the asymmetry: the conversation is *deleted* via `DELETE /users/{A}/conversation/user_{B}`,
    /// but that path is NOT valid for GET (`ERR_API_NOT_FOUND`). Existence is read via
    /// `GET /conversations/{conversationId}`, where the 1:1 id is `{A}_user_{B}`.
    static func userConversationExists() async -> Bool {
        let conversationId = "\(TestConfig.userAUid)_user_\(TestConfig.userBUid)"
        guard let url = URL(string: "\(baseURL)/conversations/\(conversationId)") else { return false }
        let data = try? await send(url: url, method: "GET", body: nil,
                                   onBehalfOf: TestConfig.userAUid, operation: "userConversationExists")
        return data != nil
    }
    
    /// The text of the A↔B conversation's most recent message, as the backend records it — the same
    /// `lastMessage` the Chats-list preview renders. Read from `GET /users/{A}/conversations` (the
    /// conversation LIST; the single `GET /conversations/{id}` returns an empty body for a 1:1 here), keyed
    /// by `conversationWith.uid == B`. Lets a preview test assert on the server's last-message value instead
    /// of polling the heavy Chats list, which stalls the a11y bridge. nil if the conversation/text is absent.
    static func lastConversationMessageText(with uid: String = TestConfig.userBUid) async -> String? {
        guard let url = URL(string: "\(baseURL)/users/\(TestConfig.userAUid)/conversations?conversationType=user&perPage=50") else {
            return nil
        }
        guard let data = try? await send(url: url, method: "GET", body: nil,
                                         onBehalfOf: nil, operation: "lastConversationMessageText"),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let list = root["data"] as? [[String: Any]]
        else { return nil }
        let match = list.first {
            (($0["conversationWith"] as? [String: Any])?["uid"] as? String) == uid
        }
        let lastMessage = match?["lastMessage"] as? [String: Any]
        return (lastMessage?["data"] as? [String: Any])?["text"] as? String
    }

    // MARK: - Block / unblock (User A blocks/unblocks User B)
    
    /// Block User B on behalf of User A. Lets a block test confirm the action reached the backend,
    /// independent of the UI list refreshing. Non-fatal — the block UI flow is the load-bearing
    /// assertion; this is corroboration.
    static func blockUser(_ uid: String = TestConfig.userBUid) async {
        guard let url = URL(string: "\(baseURL)/users/\(TestConfig.userAUid)/blockedusers") else { return }
        let body = try? JSONSerialization.data(withJSONObject: ["blockedUids": [uid]])
        _ = try? await send(url: url, method: "POST", body: body,
                            onBehalfOf: TestConfig.userAUid, operation: "blockUser")
    }
    
    /// Unblock User B on behalf of User A — used in teardown so a block test never leaves B blocked
    /// for the next run. Best-effort. NOTE: unblock is `DELETE /users/{A}/blockedusers` with a
    /// `{"blockedUids":[uid]}` BODY (the path form `.../blockedusers/{uid}` returns ERR_API_NOT_FOUND).
    static func unblockUser(_ uid: String = TestConfig.userBUid) async {
        guard let url = URL(string: "\(baseURL)/users/\(TestConfig.userAUid)/blockedusers") else { return }
        let body = try? JSONSerialization.data(withJSONObject: ["blockedUids": [uid]])
        _ = try? await send(url: url, method: "DELETE", body: body,
                            onBehalfOf: TestConfig.userAUid, operation: "unblockUser")
    }
    
    /// Whether User A currently blocks `uid`. Reads `GET /users/{A}/blockedusers` and looks for the uid.
    /// Returns false on any error so a flaky endpoint can't fail an otherwise-passing UI assertion.
    static func isBlocked(_ uid: String = TestConfig.userBUid) async -> Bool {
        guard let url = URL(string: "\(baseURL)/users/\(TestConfig.userAUid)/blockedusers?perPage=100") else {
            return false
        }
        guard let data = try? await send(url: url, method: "GET", body: nil,
                                         onBehalfOf: TestConfig.userAUid, operation: "isBlocked"),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let list = root["data"] as? [[String: Any]]
        else { return false }
        return list.contains { ($0["uid"] as? String) == uid }
    }
    
    // MARK: - Reactions (User B reacts to a message)
    
    /// Add a reaction on behalf of User B. The emoji is percent-encoded into the PATH (not the body) and
    /// the body is an empty object — `POST /messages/{id}/reactions/{emoji}`. Best-effort: the rendered
    /// reaction badge is the load-bearing UI assertion, this only fires the event.
    static func addReaction(_ messageId: Int, _ emoji: String = "🔥", asUserA: Bool = false) async {
        guard let enc = emoji.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let url = URL(string: "\(baseURL)/messages/\(messageId)/reactions/\(enc)") else { return }
        let body = try? JSONSerialization.data(withJSONObject: [:] as [String: Any])
        _ = try? await send(url: url, method: "POST", body: body,
                            onBehalfOf: asUserA ? TestConfig.userAUid : TestConfig.userBUid,
                            operation: "addReaction")
    }
    
    /// Remove a reaction on behalf of User B — `DELETE /messages/{id}/reactions/{emoji}`, no body.
    static func removeReaction(_ messageId: Int, _ emoji: String = "🔥", asUserA: Bool = false) async {
        guard let enc = emoji.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let url = URL(string: "\(baseURL)/messages/\(messageId)/reactions/\(enc)") else { return }
        _ = try? await send(url: url, method: "DELETE", body: nil,
                            onBehalfOf: asUserA ? TestConfig.userAUid : TestConfig.userBUid,
                            operation: "removeReaction")
    }
    
    // MARK: - Thread replies (User B replies in a thread)
    
    /// Send a thread reply under `parentId` on behalf of User B — `POST /messages/{parentId}/thread` with
    /// the full message envelope. Thread replies carry a parentMessageId so they are filtered OUT of the
    /// main message list. Returns the reply's message id.
    @discardableResult
    static func sendThreadReply(parentId: Int,
                                text: String,
                                receiver: String = TestConfig.userAUid,
                                receiverType: String = "user") async throws -> Int {
        guard let url = URL(string: "\(baseURL)/messages/\(parentId)/thread") else {
            throw PeerError.badURL("\(baseURL)/messages/\(parentId)/thread")
        }
        let payload: [String: Any] = [
            "receiver": receiver,
            "receiverType": receiverType,
            "category": "message",
            "type": "text",
            "data": ["text": text],
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let data = try await send(url: url, method: "POST", body: body,
                                  onBehalfOf: TestConfig.userBUid, operation: "sendThreadReply")
        return try parseMessageID(from: data)
    }
    
    /// Several thread replies with unique per-run tokens — for "parent shows reply count" cases.
    @discardableResult
    static func sendMultipleThreadReplies(parentId: Int,
                                          count: Int,
                                          prefix: String = "E2E reply",
                                          receiver: String = TestConfig.userAUid,
                                          receiverType: String = "user") async throws -> [Int] {
        var ids: [Int] = []
        let stamp = ISO8601DateFormatter().string(from: Date())
        for i in 1...max(count, 0) {
            let id = try await sendThreadReply(parentId: parentId,
                                               text: "\(prefix) #\(i) - \(stamp)",
                                               receiver: receiver, receiverType: receiverType)
            ids.append(id)
        }
        return ids
    }
    
    // MARK: - Media messages (User B sends media by hosted URL — no multipart upload)
    
    /// Default public media URLs the reference suite uses (no upload — the message references a hosted URL).
    enum MediaURL {
        static let image = "https://www.gstatic.com/webp/gallery/1.png"
        static let video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        static let audio = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
        static let pdf = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
    }
    
    /// Send a media message (image/video/audio/file) referencing a hosted URL. `data.url` + a single
    /// `attachments` entry, matching the reference suite. onBehalfOf = User B.
    @discardableResult
    private static func sendMediaMessage(type: String,
                                 url mediaURL: String,
                                 mimeType: String,
                                 name: String,
                                 ext: String,
                                 receiver: String = TestConfig.userAUid,
                                 receiverType: String = "user") async throws -> Int {
        guard let endpoint = URL(string: "\(baseURL)/messages") else {
            throw PeerError.badURL("\(baseURL)/messages")
        }
        let payload: [String: Any] = [
            "receiver": receiver,
            "receiverType": receiverType,
            "category": "message",
            "type": type,
            "data": [
                "url": mediaURL,
                "attachments": [[
                    "url": mediaURL, "mimeType": mimeType, "name": name, "extension": ext,
                ]],
            ],
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let data = try await send(url: endpoint, method: "POST", body: body,
                                  onBehalfOf: TestConfig.userBUid, operation: "sendMediaMessage")
        return try parseMessageID(from: data)
    }
    
    /// Convenience: User B sends an image to a 1:1 (or a group when `receiverType: "group"`).
    @discardableResult
    static func sendImageToA(receiver: String = TestConfig.userAUid,
                             receiverType: String = "user") async throws -> Int {
        try await sendMediaMessage(type: "image", url: MediaURL.image,
                                   mimeType: "image/png", name: "test_image.png", ext: "png",
                                   receiver: receiver, receiverType: receiverType)
    }
    
    /// Convenience: User B sends a PDF file (the reference suite asserts the filename "test_document.pdf").
    @discardableResult
    static func sendFileToA(receiver: String = TestConfig.userAUid,
                            receiverType: String = "user") async throws -> Int {
        try await sendMediaMessage(type: "file", url: MediaURL.pdf,
                                   mimeType: "application/pdf", name: "test_document.pdf", ext: "pdf",
                                   receiver: receiver, receiverType: receiverType)
    }

    /// Convenience: User B sends a video (hosted URL, no upload). For the receive-side media cases.
    @discardableResult
    static func sendVideoToA(receiver: String = TestConfig.userAUid,
                             receiverType: String = "user") async throws -> Int {
        try await sendMediaMessage(type: "video", url: MediaURL.video,
                                   mimeType: "video/mp4", name: "test_video.mp4", ext: "mp4",
                                   receiver: receiver, receiverType: receiverType)
    }

    /// Convenience: User B sends an audio message (hosted URL, no upload).
    @discardableResult
    static func sendAudioToA(receiver: String = TestConfig.userAUid,
                             receiverType: String = "user") async throws -> Int {
        try await sendMediaMessage(type: "audio", url: MediaURL.audio,
                                   mimeType: "audio/mpeg", name: "test_audio.mp3", ext: "mp3",
                                   receiver: receiver, receiverType: receiverType)
    }
    
    // MARK: - Presence (drive User B's session — fires onUserOnline / onUserOffline)
    
    /// Bring User B online by creating an auth token (`POST /users/{B}/auth_tokens`). NO `onBehalfOf` —
    /// session management uses apiKey/appId only. Best-effort: presence rendering is non-deterministic, so
    /// presence cases assert screen-stability, not the live status text.
    static func goOnline(_ uid: String = TestConfig.userBUid) async {
        guard let url = URL(string: "\(baseURL)/users/\(uid)/auth_tokens") else { return }
        _ = try? await send(url: url, method: "POST", body: nil, onBehalfOf: nil, operation: "goOnline")
    }
    
    /// Take User B offline by deleting auth tokens (`DELETE /users/{B}/auth_tokens`). NO `onBehalfOf`.
    static func goOffline(_ uid: String = TestConfig.userBUid) async {
        guard let url = URL(string: "\(baseURL)/users/\(uid)/auth_tokens") else { return }
        _ = try? await send(url: url, method: "DELETE", body: nil, onBehalfOf: nil, operation: "goOffline")
    }
    
    // MARK: - Group management (throwaway per-run groups)
    
    /// Create a group owned by `owner` (via `onBehalfOf`, default User A so the UI shows admin/owner
    /// affordances). Use a unique per-run `guid` so runs never collide and never touch the shared
    /// `supergroup`. `password` is required only for `type: "password"` groups. `participants` join at
    /// creation time via the REST `members` field — saves a second `POST /members` round-trip.
    static func createGroup(guid: String,
                            name: String,
                            type: String = "public",
                            password: String? = nil,
                            owner: String = TestConfig.userAUid,
                            participants: [String] = []) async throws {
        guard let url = URL(string: "\(baseURL)/groups") else {
            throw PeerError.badURL("\(baseURL)/groups")
        }
        var payload: [String: Any] = ["guid": guid, "name": name, "type": type]
        if let password { payload["password"] = password }
        if !participants.isEmpty { payload["members"] = ["participants": participants] }
        let body = try JSONSerialization.data(withJSONObject: payload)
        _ = try await send(url: url, method: "POST", body: body,
                           onBehalfOf: owner, operation: "createGroup")
    }

    /// Add members to a group (as `by`, default the owner User A). `uids` join as participants.
    /// Re-adding a banned uid also UNBANS them (verified live) — this is the unban path.
    static func addGroupMembers(guid: String, uids: [String], by: String = TestConfig.userAUid) async throws {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)/members") else {
            throw PeerError.badURL("\(baseURL)/groups/\(guid)/members")
        }
        let payload: [String: Any] = ["participants": uids]
        let body = try JSONSerialization.data(withJSONObject: payload)
        _ = try await send(url: url, method: "POST", body: body,
                           onBehalfOf: by, operation: "addGroupMembers")
    }

    /// Ban a member via REST — `POST /members` with `{"usersToBan":[uid]}` (as `by`, default owner A).
    /// Used to pre-seed a banned member so the Banned-Members UI screen has a row to show.
    /// NOTE: a banned uid is STILL returned by `GET /members` on this backend, so a ban must be asserted
    /// via `isGroupMemberBanned` (the ERR_BANNED_GROUPMEMBER probe), not by membership absence.
    static func banGroupMember(guid: String, uid: String, by: String = TestConfig.userAUid) async throws {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)/members") else {
            throw PeerError.badURL("\(baseURL)/groups/\(guid)/members")
        }
        let body = try JSONSerialization.data(withJSONObject: ["usersToBan": [uid]])
        _ = try await send(url: url, method: "POST", body: body,
                           onBehalfOf: by, operation: "banGroupMember")
    }

    /// Unban a member via REST. There is no dedicated unban endpoint — re-adding via `{"participants"}`
    /// both re-adds AND clears the ban (verified live). Best-effort, non-throwing (used in teardown).
    static func unbanGroupMember(guid: String, uid: String, by: String = TestConfig.userAUid) async {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)/members") else { return }
        let body = try? JSONSerialization.data(withJSONObject: ["participants": [uid]])
        _ = try? await send(url: url, method: "POST", body: body,
                            onBehalfOf: by, operation: "unbanGroupMember")
    }

    /// Whether `uid` is banned from the group. There is NO readable banned-members list via REST, so the
    /// authoritative signal is: attempt to kick the member (`DELETE /members/{uid}`); a banned member
    /// returns `ERR_BANNED_GROUPMEMBER`, an active/absent member kicks cleanly. This is a MUTATING probe
    /// (it kicks a non-banned member), so call it only when a follow-up kick is harmless — i.e. to assert a
    /// member IS banned, or that a previously-banned member is no longer banned.
    static func isGroupMemberBanned(guid: String, uid: String, by: String = TestConfig.userAUid) async -> Bool {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)/members/\(uid)") else { return false }
        do {
            _ = try await send(url: url, method: "DELETE", body: nil, onBehalfOf: by, operation: "isGroupMemberBanned")
            return false // kick succeeded → not banned
        } catch let PeerError.http(_, _, body) {
            return body.contains("ERR_BANNED_GROUPMEMBER")
        } catch {
            return false
        }
    }

    /// Change a member's scope/role — `PUT /members/{uid}` with `{"scope": ...}` (as `by`, default owner
    /// A). Used to set up an actor's role (e.g. promote A to moderator for the "moderator deletes another's
    /// message" permission case).
    static func setMemberScope(guid: String, uid: String, scope: String, by: String = TestConfig.userAUid) async throws {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)/members/\(uid)") else {
            throw PeerError.badURL("\(baseURL)/groups/\(guid)/members/\(uid)")
        }
        let body = try JSONSerialization.data(withJSONObject: ["scope": scope])
        _ = try await send(url: url, method: "PUT", body: body,
                           onBehalfOf: by, operation: "setMemberScope")
    }

    /// Best-effort group teardown — never throws so a failed cleanup can't mask the test result.
    static func deleteGroup(guid: String, owner: String = TestConfig.userAUid) async {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)") else { return }
        _ = try? await send(url: url, method: "DELETE", body: nil,
                            onBehalfOf: owner, operation: "deleteGroup")
    }

    /// Whether a group still exists — GET `/groups/{guid}` (admin read). A deleted group 404s, which `send`
    /// surfaces as `PeerError.http(status: 404)`; this returns `false` for it (and any non-2xx) and `true`
    /// on success. Used to assert a UI "Delete and Exit" actually removed the group on the backend.
    static func groupExists(guid: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)") else { return false }
        do {
            _ = try await send(url: url, method: "GET", body: nil, onBehalfOf: nil, operation: "groupExists")
            return true
        } catch {
            return false
        }
    }

    /// The member UIDs of a group. NOTE: on this backend a BANNED member is still returned here — so this
    /// reflects add/remove/leave, but NOT ban (use `isGroupMemberBanned` for ban state).
    /// `reader` is the `onBehalfOf` actor; pass `nil` (admin read) to read a group the actor has LEFT —
    /// reading `onBehalfOf` a non-member returns `ERR_GROUP_NOT_JOINED`, so leave/transfer assertions
    /// (where the reader just departed) must read as admin.
    static func groupMemberUIDs(guid: String, as reader: String? = TestConfig.userAUid) async throws -> [String] {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)/members?perPage=100") else {
            throw PeerError.badURL("\(baseURL)/groups/\(guid)/members")
        }
        let data = try await send(url: url, method: "GET", body: nil,
                                  onBehalfOf: reader, operation: "groupMemberUIDs")
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let list = root["data"] as? [[String: Any]]
        else { return [] }
        return list.compactMap { $0["uid"] as? String }
    }

    /// A member's scope/role in a group (e.g. "admin"/"moderator"/"participant"), or nil if not a member.
    /// `reader` is the `onBehalfOf` actor; pass `nil` (admin read) when the reader may have left the group
    /// (e.g. after an ownership transfer where the old owner departs).
    static func memberScope(guid: String, uid: String, as reader: String? = TestConfig.userAUid) async throws -> String? {
        let url = URL(string: "\(baseURL)/groups/\(guid)/members?perPage=100")
        guard let url else { throw PeerError.badURL("\(baseURL)/groups/\(guid)/members") }
        let data = try await send(url: url, method: "GET", body: nil,
                                  onBehalfOf: reader, operation: "memberScope")
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let list = root["data"] as? [[String: Any]]
        else { return nil }
        return list.first { ($0["uid"] as? String) == uid }?["scope"] as? String
    }
    
    /// Non-fatal: receipt endpoints differ across SDK versions.
    static func markAsRead(_ messageId: Int) async {
        guard let url = URL(string: "\(baseURL)/messages/\(messageId)/read") else { return }
        _ = try? await send(url: url, method: "PUT", body: nil,
                            onBehalfOf: TestConfig.userBUid, operation: "markAsRead")
    }
    
    /// Non-fatal: receipt endpoints differ across SDK versions.
    static func markAsDelivered(_ messageId: Int) async {
        guard let url = URL(string: "\(baseURL)/messages/\(messageId)/delivered") else { return }
        _ = try? await send(url: url, method: "PUT", body: nil,
                            onBehalfOf: TestConfig.userBUid, operation: "markAsDelivered")
    }
    
    private static func sendMessage(
        receiver: String,
        receiverType: String,
        text: String,
        onBehalfOf: String,
        operation: String) async throws -> Int {
            guard let url = URL(string: "\(baseURL)/messages") else {
                throw PeerError.badURL("\(baseURL)/messages")
            }
            let payload: [String: Any] = [
                "receiver": receiver,
                "receiverType": receiverType,
                "category": "message",
                "type": "text",
                "data": ["text": text],
            ]
            let body = try JSONSerialization.data(withJSONObject: payload)
            let data = try await send(url: url, method: "POST", body: body,
                                      onBehalfOf: onBehalfOf, operation: operation)
            return try parseMessageID(from: data)
        }
    
    /// `/messages` returns `data.id` as a String; coerce to Int.
    private static func parseMessageID(from data: Data) throws -> Int {
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let payload = root["data"] as? [String: Any]
        else {
            throw PeerError.missingMessageID(body: String(data: data, encoding: .utf8) ?? "<binary>")
        }
        if let id = payload["id"] as? Int { return id }
        if let idString = payload["id"] as? String, let id = Int(idString) { return id }
        throw PeerError.missingMessageID(body: String(data: data, encoding: .utf8) ?? "<binary>")
    }
    
    /// Retries transient network failures (connection-lost / timeout / DNS blips) — the sim's network
    /// stack and the shared backend occasionally drop a request, which otherwise cascades a real test into
    /// a false failure. HTTP errors (4xx/5xx) are NOT retried — those are deterministic.
    @discardableResult
    private static func send(url: URL,
                             method: String,
                             body: Data?,
                             onBehalfOf: String?,
                             operation: String) async throws -> Data {
        var lastError: Error = PeerError.badURL(url.absoluteString)
        for attempt in 0..<3 {
            do {
                return try await sendOnce(url: url, method: method, body: body,
                                          onBehalfOf: onBehalfOf, operation: operation)
            } catch let error as URLError where isTransient(error) {
                lastError = error
                // Brief backoff before retrying a transient network blip.
                try? await Task.sleep(nanoseconds: UInt64((attempt + 1)) * 500_000_000)
            }
        }
        throw lastError
    }
    
    private static func isTransient(_ error: URLError) -> Bool {
        switch error.code {
        case .networkConnectionLost, .timedOut, .cannotConnectToHost,
                .notConnectedToInternet, .dnsLookupFailed, .cannotFindHost:
            return true
        default:
            return false
        }
    }
    
    @discardableResult
    private static func sendOnce(url: URL,
                                 method: String,
                                 body: Data?,
                                 onBehalfOf: String?,
                                 operation: String) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        for (k, v) in headers { request.setValue(v, forHTTPHeaderField: k) }
        // Session management (auth_tokens) is keyed only by apiKey/appId — no impersonation header.
        if let onBehalfOf { request.setValue(onBehalfOf, forHTTPHeaderField: "onBehalfOf") }
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let data = data ?? Data()
                let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                guard (200..<300).contains(status) else {
                    let bodyText = String(data: data, encoding: .utf8) ?? "<binary>"
                    continuation.resume(throwing: PeerError.http(operation: operation,
                                                                 status: status,
                                                                 body: bodyText))
                    return
                }
                continuation.resume(returning: data)
            }.resume()
        }
    }
}
