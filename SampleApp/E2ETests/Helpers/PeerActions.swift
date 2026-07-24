import Foundation

/// Drives the peer ("User B") over REST via the `onBehalfOf` header — no second simulator needed.
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
    
    /// Sends as User A (the app-under-test's own user) to the B conversation — simulates A sending from a
    /// SECOND device: A's app receives its own outbound message over its socket.
    @discardableResult
    static func sendTextMessageAsA(_ text: String) async throws -> Int {
        try await sendMessage(receiver: TestConfig.userBUid,
                              receiverType: "user",
                              text: text,
                              onBehalfOf: TestConfig.userAUid,
                              operation: "sendTextMessageAsA")
    }

    @discardableResult
    static func sendGroupTextMessage(_ text: String, groupId: String) async throws -> Int {
        try await sendMessage(
            receiver: groupId,
            receiverType: "group",
            text: text,
            onBehalfOf: TestConfig.userBUid,
            operation: "sendGroupTextMessage"
        )
    }
    
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
        _ = try? await send(
            url: url, method: "DELETE", body: nil,
            onBehalfOf: TestConfig.userAUid, operation: "deleteConversation"
        )
    }
    
    /// Matches on the peer's `uid` in A's conversation LIST — the app treats a 1:1 `conversationId` as an
    /// opaque SDK value, so string-joining UIDs (`A_user_B`) is wrong: the canonical id is sender-first
    /// (`B_user_A` after a B→A seed), and `GET /conversations/A_user_B` 403s `ERR_CONVERSATION_NOT_ACCESSIBLE`.
    static func userConversationExists() async -> Bool {
        guard let url = URL(string: "\(baseURL)/users/\(TestConfig.userAUid)/conversations?conversationType=user&perPage=50") else {
            return false
        }
        guard let data = try? await send(url: url, method: "GET", body: nil,
                                         onBehalfOf: nil, operation: "userConversationExists"),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let list = root["data"] as? [[String: Any]]
        else { return false }
        return list.contains {
            (($0["conversationWith"] as? [String: Any])?["uid"] as? String) == TestConfig.userBUid
        }
    }
    
    /// Backend `lastMessage` text — polling the Chats-list preview stalls the a11y bridge. Reads the
    /// conversation LIST; `GET /conversations/{id}` returns an empty body for a 1:1 here.
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

    /// True when `text` is the conversation's current backend `lastMessage` (the Chats-list preview
    /// source) — the preview itself is a11y-unassertable on the busy backend, so we poll this instead.
    static func previewShowsLiveMessage(_ text: String, with uid: String = TestConfig.userBUid) async -> Bool {
        await lastConversationMessageText(with: uid) == text
    }

    /// Group-conversation surfacing asserted here — the Groups/Chats a11y walk SIGKILLs on the busy backend.
    static func groupConversationExists(guid: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/users/\(TestConfig.userAUid)/conversations?conversationType=group&perPage=50") else {
            return false
        }
        guard let data = try? await send(url: url, method: "GET", body: nil,
                                         onBehalfOf: nil, operation: "groupConversationExists"),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let list = root["data"] as? [[String: Any]]
        else { return false }
        return list.contains {
            (($0["conversationWith"] as? [String: Any])?["guid"] as? String) == guid
        }
    }

    /// B blocks A (the inverse of `blockUser`) — drives the block event A's app must react to.
    static func blockUserA() async {
        guard let url = URL(string: "\(baseURL)/users/\(TestConfig.userBUid)/blockedusers") else { return }
        let body = try? JSONSerialization.data(withJSONObject: ["blockedUids": [TestConfig.userAUid]])
        _ = try? await send(url: url, method: "POST", body: body,
                            onBehalfOf: TestConfig.userBUid, operation: "blockUserA")
    }

    static func unblockUserA() async {
        guard let url = URL(string: "\(baseURL)/users/\(TestConfig.userBUid)/blockedusers") else { return }
        let body = try? JSONSerialization.data(withJSONObject: ["blockedUids": [TestConfig.userAUid]])
        _ = try? await send(url: url, method: "DELETE", body: body,
                            onBehalfOf: TestConfig.userBUid, operation: "unblockUserA")
    }

    static func blockUser(_ uid: String = TestConfig.userBUid) async {
        guard let url = URL(string: "\(baseURL)/users/\(TestConfig.userAUid)/blockedusers") else { return }
        let body = try? JSONSerialization.data(withJSONObject: ["blockedUids": [uid]])
        _ = try? await send(url: url, method: "POST", body: body,
                            onBehalfOf: TestConfig.userAUid, operation: "blockUser")
    }
    
    /// Unblock is `DELETE .../blockedusers` with a `{"blockedUids":[uid]}` BODY — the `/{uid}` path form 404s.
    static func unblockUser(_ uid: String = TestConfig.userBUid) async {
        guard let url = URL(string: "\(baseURL)/users/\(TestConfig.userAUid)/blockedusers") else { return }
        let body = try? JSONSerialization.data(withJSONObject: ["blockedUids": [uid]])
        _ = try? await send(
            url: url, method: "DELETE", body: body,
            onBehalfOf: TestConfig.userAUid, operation: "unblockUser"
        )
    }
    
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
    
    static func addReaction(_ messageId: Int, _ emoji: String = "🔥", asUserA: Bool = false) async {
        guard let enc = emoji.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let url = URL(string: "\(baseURL)/messages/\(messageId)/reactions/\(enc)") else { return }
        let body = try? JSONSerialization.data(withJSONObject: [:] as [String: Any])
        _ = try? await send(url: url, method: "POST", body: body,
                            onBehalfOf: asUserA ? TestConfig.userAUid : TestConfig.userBUid,
                            operation: "addReaction")
    }
    
    static func removeReaction(_ messageId: Int, _ emoji: String = "🔥", asUserA: Bool = false) async {
        guard let enc = emoji.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
              let url = URL(string: "\(baseURL)/messages/\(messageId)/reactions/\(enc)") else { return }
        _ = try? await send(url: url, method: "DELETE", body: nil,
                            onBehalfOf: asUserA ? TestConfig.userAUid : TestConfig.userBUid,
                            operation: "removeReaction")
    }
    
    /// Thread replies carry a parentMessageId, so they are filtered OUT of the main message list.
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

    /// Sends a developer card (category "card") — the path that renders via CometChatCardBubble.
    /// `card` is the card JSON schema; `data.text` is the conversation-list preview subtitle.
    /// Passing an empty `card` omits the card payload — the SDK's `getCard()` returns nil and the bubble
    /// renders `fallbackText` instead (the invalid-card path).
    @discardableResult
    static func sendCardMessage(text: String,
                                card: [String: Any],
                                fallbackText: String? = nil,
                                receiver: String = TestConfig.userAUid,
                                receiverType: String = "user") async throws -> Int {
        guard let url = URL(string: "\(baseURL)/messages") else {
            throw PeerError.badURL("\(baseURL)/messages")
        }
        var data: [String: Any] = ["text": text]
        if !card.isEmpty { data["card"] = card }
        if let fallbackText { data["fallbackText"] = fallbackText }
        let payload: [String: Any] = [
            "receiver": receiver,
            "receiverType": receiverType,
            "category": "card",
            "type": "card",
            "data": data,
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let out = try await send(url: url, method: "POST", body: body,
                                 onBehalfOf: TestConfig.userBUid, operation: "sendCardMessage")
        return try parseMessageID(from: out)
    }

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
    
    enum MediaURL {
        static let image = "https://www.gstatic.com/webp/gallery/1.png"
        static let video = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        static let audio = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
        static let pdf = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
    }
    
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
    
    @discardableResult
    static func sendImageToA(receiver: String = TestConfig.userAUid,
                             receiverType: String = "user") async throws -> Int {
        try await sendMediaMessage(type: "image", url: MediaURL.image,
                                   mimeType: "image/png", name: "test_image.png", ext: "png",
                                   receiver: receiver, receiverType: receiverType)
    }
    
    @discardableResult
    static func sendFileToA(receiver: String = TestConfig.userAUid,
                            receiverType: String = "user") async throws -> Int {
        try await sendMediaMessage(type: "file", url: MediaURL.pdf,
                                   mimeType: "application/pdf", name: "test_document.pdf", ext: "pdf",
                                   receiver: receiver, receiverType: receiverType)
    }

    @discardableResult
    static func sendVideoToA(receiver: String = TestConfig.userAUid,
                             receiverType: String = "user") async throws -> Int {
        try await sendMediaMessage(type: "video", url: MediaURL.video,
                                   mimeType: "video/mp4", name: "test_video.mp4", ext: "mp4",
                                   receiver: receiver, receiverType: receiverType)
    }

    @discardableResult
    static func sendAudioToA(receiver: String = TestConfig.userAUid,
                             receiverType: String = "user") async throws -> Int {
        try await sendMediaMessage(type: "audio", url: MediaURL.audio,
                                   mimeType: "audio/mpeg", name: "test_audio.mp3", ext: "mp3",
                                   receiver: receiver, receiverType: receiverType)
    }
    
    static func goOnline(_ uid: String = TestConfig.userBUid) async {
        guard let url = URL(string: "\(baseURL)/users/\(uid)/auth_tokens") else { return }
        _ = try? await send(url: url, method: "POST", body: nil, onBehalfOf: nil, operation: "goOnline")
    }
    
    static func goOffline(_ uid: String = TestConfig.userBUid) async {
        guard let url = URL(string: "\(baseURL)/users/\(uid)/auth_tokens") else { return }
        _ = try? await send(url: url, method: "DELETE", body: nil, onBehalfOf: nil, operation: "goOffline")
    }
    
    /// Owner defaults to User A so the UI shows admin/owner affordances. `participants` join at creation
    /// via the REST `members` field, saving a second `POST /members` round-trip.
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

    /// Re-adding a banned uid also UNBANS them — this is the unban path.
    static func addGroupMembers(guid: String, uids: [String], by: String = TestConfig.userAUid) async throws {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)/members") else {
            throw PeerError.badURL("\(baseURL)/groups/\(guid)/members")
        }
        let payload: [String: Any] = ["participants": uids]
        let body = try JSONSerialization.data(withJSONObject: payload)
        _ = try await send(url: url, method: "POST", body: body,
                           onBehalfOf: by, operation: "addGroupMembers")
    }

    /// A banned uid is STILL returned by `GET /members` here, so assert a ban via `isGroupMemberBanned`
    /// (the ERR_BANNED_GROUPMEMBER probe), not by membership absence.
    static func banGroupMember(guid: String, uid: String, by: String = TestConfig.userAUid) async throws {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)/members") else {
            throw PeerError.badURL("\(baseURL)/groups/\(guid)/members")
        }
        let body = try JSONSerialization.data(withJSONObject: ["usersToBan": [uid]])
        _ = try await send(url: url, method: "POST", body: body,
                           onBehalfOf: by, operation: "banGroupMember")
    }

    /// No dedicated unban endpoint — re-adding via `{"participants"}` both re-adds AND clears the ban.
    static func unbanGroupMember(guid: String, uid: String, by: String = TestConfig.userAUid) async {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)/members") else { return }
        let body = try? JSONSerialization.data(withJSONObject: ["participants": [uid]])
        _ = try? await send(url: url, method: "POST", body: body,
                            onBehalfOf: by, operation: "unbanGroupMember")
    }

    /// No readable banned-members list via REST: probe by kicking (`DELETE /members/{uid}`) — a banned
    /// member returns `ERR_BANNED_GROUPMEMBER`, others kick cleanly. MUTATING (it kicks a non-banned
    /// member), so call only where a follow-up kick is harmless.
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

    static func setMemberScope(guid: String, uid: String, scope: String, by: String = TestConfig.userAUid) async throws {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)/members/\(uid)") else {
            throw PeerError.badURL("\(baseURL)/groups/\(guid)/members/\(uid)")
        }
        let body = try JSONSerialization.data(withJSONObject: ["scope": scope])
        _ = try await send(url: url, method: "PUT", body: body,
                           onBehalfOf: by, operation: "setMemberScope")
    }

    static func deleteGroup(guid: String, owner: String = TestConfig.userAUid) async {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)") else { return }
        _ = try? await send(url: url, method: "DELETE", body: nil,
                            onBehalfOf: owner, operation: "deleteGroup")
    }

    /// A deleted group 404s (surfaced as `PeerError.http`) → `false`; success → `true`.
    static func groupExists(guid: String) async -> Bool {
        guard let url = URL(string: "\(baseURL)/groups/\(guid)") else { return false }
        do {
            _ = try await send(url: url, method: "GET", body: nil, onBehalfOf: nil, operation: "groupExists")
            return true
        } catch {
            return false
        }
    }

    /// Pass `reader: nil` (admin read) to read a group the actor has LEFT — reading `onBehalfOf` a
    /// non-member returns `ERR_GROUP_NOT_JOINED`. A BANNED member is still listed here.
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

    /// Pass `reader: nil` (admin read) when the reader may have left the group (e.g. after a transfer).
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
    
    static func markAsRead(_ messageId: Int) async {
        guard let url = URL(string: "\(baseURL)/messages/\(messageId)/read") else { return }
        _ = try? await send(url: url, method: "PUT", body: nil,
                            onBehalfOf: TestConfig.userBUid, operation: "markAsRead")
    }
    
    static func markAsDelivered(_ messageId: Int) async {
        guard let url = URL(string: "\(baseURL)/messages/\(messageId)/delivered") else { return }
        _ = try? await send(url: url, method: "PUT", body: nil,
                            onBehalfOf: TestConfig.userBUid, operation: "markAsDelivered")
    }
    
    /// Backend delivery state: `GET /messages/{id}` exposes `deliveredAt` once delivered. NOTE: `readAt`
    /// is NOT surfaced here for the sender, so read receipts stay backend-unassertable (tick is PNG-only).
    static func messageDeliveredAt(_ messageId: Int) async -> Int? {
        guard let url = URL(string: "\(baseURL)/messages/\(messageId)") else { return nil }
        guard let data = try? await send(url: url, method: "GET", body: nil,
                                         onBehalfOf: TestConfig.userBUid, operation: "messageDeliveredAt"),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let payload = root["data"] as? [String: Any]
        else { return nil }
        return payload["deliveredAt"] as? Int
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
    
    /// Retries transient network blips (the sim + shared backend occasionally drop a request); HTTP
    /// 4xx/5xx are deterministic and NOT retried.
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
