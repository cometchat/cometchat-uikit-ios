//
//  ConversationRows.swift
//  CometChatUIKitSwift
//
//  Pure list operation for the conversation list on the offline (ON) path. No UIKit imports.
//

import Foundation
import CometChatSDK

internal enum ConversationRows {

    /// Whether the row's preview is an own message the server has not acked (BEH-CONV-06): such a
    /// row is never removed by a sync.
    static func hasUnsentPreview(_ conversation: Conversation) -> Bool {
        guard let last = conversation.lastMessage else { return false }
        return MessageIdentity.isUnsent(last)
    }

    /// Reconcile one sync page into `rows`: rows in the page are replaced or added in place; rows
    /// inside the page's range (newer than its oldest row) that the page no longer has are removed,
    /// except a row whose preview is an own unsent message; rows below the page are kept. The
    /// request cursor is not touched. Returns whether anything changed.
    @discardableResult
    static func reconcileSlice(_ rows: inout [Conversation], with page: [Conversation]) -> Bool {
        guard !page.isEmpty else { return false }
        var changed = false
        let pageIds = Set(page.compactMap { $0.conversationId })
        let oldestInPage = page.map { $0.updatedAt }.min() ?? 0

        // Remove proven omissions: inside the page's range and absent from it.
        let before = rows.count
        rows.removeAll { row in
            guard let id = row.conversationId, !pageIds.contains(id) else { return false }
            if hasUnsentPreview(row) { return false }
            return row.updatedAt >= oldestInPage
        }
        if rows.count != before { changed = true }

        for conversation in page {
            guard let id = conversation.conversationId else { continue }
            if let index = rows.firstIndex(where: { $0.conversationId == id }) {
                // Never move backwards: a newer local copy (an own pending send) wins.
                if rows[index].updatedAt > conversation.updatedAt && hasUnsentPreview(rows[index]) { continue }
                rows[index] = conversation
                changed = true
            } else {
                rows.append(conversation)
                changed = true
            }
        }
        if changed {
            // Server order is most recent first; pinned rows are re-ordered by the caller.
            rows = rows.enumerated().sorted { lhs, rhs in
                if lhs.element.updatedAt != rhs.element.updatedAt { return lhs.element.updatedAt > rhs.element.updatedAt }
                return lhs.offset < rhs.offset
            }.map { $0.element }
        }
        return changed
    }

    // MARK: Which list a request makes

    /// Whether a conversation request asks the server for something other than the plain list: a
    /// type other than both, tags, user or group tags, a search keyword, unread only, `pinnedBy`, or
    /// hide / only agentic. A builder that only sets a limit (or other options that do not narrow)
    /// is the plain list.
    static func requestNarrows(_ request: ConversationRequest?) -> Bool {
        guard let request = request else { return false }
        if let type = request.conversationType, type != .none { return true }
        return !request.tags.isEmpty
            || !request.userTags.isEmpty
            || !request.groupTags.isEmpty
            || !(request.searchKeyword ?? "").isEmpty
            || request.unread
            || !request.pinnedBy.isEmpty
            || request.hideAgentic
            || request.onlyAgentic
    }

    /// Oldest-first order of two rows by (when it last changed, id).
    private static func isOlder(_ a: Conversation, _ b: Conversation) -> Bool {
        if a.updatedAt != b.updatedAt { return a.updatedAt < b.updatedAt }
        return (a.conversationId ?? "") < (b.conversationId ?? "")
    }

    /// Merge the first page of a narrowed list's own re-read into `rows`: the page's rows are
    /// upserted and the list sits in recency order. A row is removed only if this read's cached
    /// phase delivered it (`cachedIds`), it lies inside the page's (last change, id) range, the page
    /// lacks it, and its preview is not an own unsent message. Rows the user paged in below the page
    /// stay. A page with no rows proves nothing gone and changes nothing (D17). Pass no `cachedIds`
    /// to fold in a cached page (upsert only). Returns whether anything changed.
    @discardableResult
    static func mergeFirstServerPage(_ rows: inout [Conversation], cachedIds: Set<String>, page: [Conversation]) -> Bool {
        guard let first = page.first else { return false }
        var low = first
        var high = first
        for row in page {
            if isOlder(row, low) { low = row }
            if isOlder(high, row) { high = row }
        }
        let pageIds = Set(page.compactMap { $0.conversationId })
        let shown = Dictionary(rows.compactMap { row in row.conversationId.map { ($0, row) } },
                               uniquingKeysWith: { first, _ in first })

        let upserted: [Conversation] = page.compactMap { incoming in
            guard let id = incoming.conversationId else { return nil }
            // An own unsent preview is newer than anything the server has.
            if let existing = shown[id], hasUnsentPreview(existing), existing.updatedAt >= incoming.updatedAt {
                return existing
            }
            return incoming
        }
        let kept = rows.filter { row in
            guard let id = row.conversationId else { return true }
            if pageIds.contains(id) { return false }
            if !cachedIds.contains(id) || hasUnsentPreview(row) { return true }
            return isOlder(row, low) || isOlder(high, row)
        }
        let merged = (upserted + kept).enumerated().sorted { lhs, rhs in
            if lhs.element.updatedAt != rhs.element.updatedAt { return lhs.element.updatedAt > rhs.element.updatedAt }
            return lhs.offset < rhs.offset
        }.map { $0.element }
        rows = merged
        return true
    }

    // MARK: Live-message decisions

    /// Whether a delivered message should raise the "new message" cue (sound). A message the SDK
    /// swept in on reconnect (SYNC source) is history, not news: no sound, however many there are
    /// (UIK-SYNC-02). `offlineOn` is the gate, read by the caller once for this operation.
    static func shouldCueNewMessage(offlineOn: Bool, _ message: BaseMessage) -> Bool {
        return !(offlineOn && MessageIdentity.isSyncDelivered(message))
    }

    /// The unread count of a conversation after a delivered message updates its preview.
    /// A swept message never adds one: the synced conversation already counts it (UIT-CONV-09:
    /// 5 missed messages leave the count at 5, not 10).
    static func unreadCount(existing: Int, isFromMe: Bool, isRead: Bool, countsAsUnread: Bool, isSync: Bool) -> Int {
        if isFromMe { return existing }
        if countsAsUnread && !isRead && !isSync { return existing + 1 }
        return existing
    }

    // MARK: Matching an event to a row

    /// `(type, with)` of a conversation, lowercased: ids are compared case-insensitively because the
    /// pin frame and the row can disagree on case (UIK-CONV-01).
    static func key(of conversation: Conversation) -> (type: String, with: String)? {
        if let user = conversation.conversationWith as? User, let uid = user.uid {
            return ("user", uid.lowercased())
        }
        if let group = conversation.conversationWith as? Group {
            return ("group", group.guid.lowercased())
        }
        return nil
    }

    /// Index of the row `event` is about, matched by `(type, with)`, never by object identity.
    static func index(of event: Conversation, in rows: [Conversation]) -> Int? {
        guard let wanted = key(of: event) else { return nil }
        return rows.firstIndex { row in
            guard let k = key(of: row) else { return false }
            return k.type == wanted.type && k.with == wanted.with
        }
    }

    enum PinEventAction: Equatable {
        /// Not about a chat this list can show (or about the user themself).
        case ignore
        /// Update the row at this index in place.
        case update(Int)
        /// Not on screen: fetch the conversation and insert it (ignore a failure).
        case fetchAndInsert
    }

    /// What a pin/unpin event does to a list. A 1:1 event whose peer is the logged-in user is
    /// ignored. A chat that is not shown is fetched and inserted, except in a filtered list, which
    /// only updates rows it already shows (it cannot know the chat matches its filter).
    static func pinEventAction(_ event: Conversation, rows: [Conversation], loggedInUid: String?, filtered: Bool) -> PinEventAction {
        guard let k = key(of: event) else { return .ignore }
        if k.type == "user", let me = loggedInUid?.lowercased(), k.with == me { return .ignore }
        if let index = index(of: event, in: rows) { return .update(index) }
        return filtered ? .ignore : .fetchAndInsert
    }

    // MARK: Own send previews

    /// Whether a `ccMessageSent` of an own send should move its chat to the top with that message
    /// as the preview: a send that has begun (pending) or failed (BEH-CONV-01). `.success` is
    /// handled as before.
    static func previewFollowsSend(offlineOn: Bool, status: MessageStatus) -> Bool {
        return offlineOn && (status == .inProgress || status == .error)
    }

    /// Whether two copies are the same message: the same object, server id, local handle or muid.
    /// Never by time: an ack sent after a reconnect carries the server's (later) `sentAt`.
    static func isSameMessage(_ a: BaseMessage, _ b: BaseMessage) -> Bool {
        if a === b { return true }
        if a.id > 0 && a.id == b.id { return true }
        if let la = MessageIdentity.localId(a), la == MessageIdentity.localId(b) { return true }
        if let ma = MessageIdentity.muid(a), ma == MessageIdentity.muid(b) { return true }
        return false
    }

    /// Whether the ack of an own send may become its chat's preview: only when the preview is that
    /// same message (its pending copy) or there is none. A newer message that arrived while the ack
    /// was late stays the preview.
    static func ackReplacesPreview(_ preview: BaseMessage?, ack: BaseMessage) -> Bool {
        guard let preview = preview else { return true }
        return isSameMessage(preview, ack)
    }

    /// The row a message belongs to, by its receiver: `(type, with)`, case-insensitive. The
    /// counterpart is the receiver for an own message.
    static func index(ofMessage message: BaseMessage, in rows: [Conversation]) -> Int? {
        let with = message.receiverUid.lowercased()
        let type = message.receiverType == .group ? "group" : "user"
        return rows.firstIndex { row in
            guard let k = key(of: row) else { return false }
            return k.type == type && k.with == with
        }
    }

    // MARK: Swept group actions

    /// The group a swept action message removes the logged-in user from (kicked, banned, or the
    /// user left), or `nil`. A swept action runs the same effect as the live one (UIT-SYNC-13).
    static func groupLostBy(_ action: ActionMessage, loggedInUid: String?) -> Group? {
        guard let me = loggedInUid?.lowercased(), let group = action.actionFor as? Group else { return nil }
        switch action.action {
        case .kicked?, .banned?:
            guard let on = action.actionOn as? User, on.uid?.lowercased() == me else { return nil }
            return group
        case .left?:
            let who = (action.actionBy as? User) ?? (action.actionOn as? User)
            return who?.uid?.lowercased() == me ? group : nil
        default:
            return nil
        }
    }
}
