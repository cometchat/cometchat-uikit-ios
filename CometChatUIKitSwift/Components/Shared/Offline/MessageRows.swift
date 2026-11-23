//
//  MessageRows.swift
//  CometChatUIKitSwift
//
//  Pure list operations for the offline (ON) path over the message list's date-sectioned model:
//  sorted upsert by identity, the windowed reconcile of a server page against its cached page,
//  and the held-receipt map. Nothing here runs with offline off.
//
//  Model: `[(date, messages)]`, sections newest day first, rows newest first inside a section
//  (the list is drawn upside down). Order inside a section is `(sentAt, id)` descending, with
//  rows that have no server id above (newer than) every sent row, by compose time (BEH-READ-10).
//  A row without a server id is never removed by a read (BEH-READ-30).
//

import Foundation
import CometChatSDK

internal typealias MessageSections = [(date: Date, messages: [BaseMessage])]

/// `localMessageId -> server id`, filled when an ack replaces a pending row, so a late event
/// carrying either identity lands on the same row.
internal struct MessageAliasMap {
    private(set) var serverIdByLocalId: [String: Int] = [:]

    mutating func record(localId: String, serverId: Int) {
        guard serverId > 0, !localId.isEmpty else { return }
        serverIdByLocalId[localId] = serverId
    }

    func serverId(forLocalId localId: String) -> Int? {
        return serverIdByLocalId[localId]
    }

    mutating func removeAll() {
        serverIdByLocalId.removeAll()
    }
}

internal enum MessageRows {

    struct UpsertResult {
        var changed = false
        /// Server ids that rows acquired (an ack replacing a pending row), for held receipts.
        var acquiredServerIds: [Int] = []
    }

    // MARK: Ordering

    /// `true` when `a` belongs before `b` in a section (that is, `a` is newer).
    static func isNewer(_ a: BaseMessage, than b: BaseMessage) -> Bool {
        let aSent = MessageIdentity.serverId(a) > 0
        let bSent = MessageIdentity.serverId(b) > 0
        if aSent != bSent { return !aSent }   // unsent rows sit above sent ones
        if !aSent {
            return MessageIdentity.composeTime(a) > MessageIdentity.composeTime(b)
        }
        if a.sentAt != b.sentAt { return a.sentAt > b.sentAt }
        return a.id > b.id
    }

    /// The instant a message is placed by: sent time, else compose time.
    static func placementDate(_ message: BaseMessage) -> Date {
        let sent = TimeInterval(message.sentAt)
        if MessageIdentity.serverId(message) > 0 && sent > 0 { return Date(timeIntervalSince1970: sent) }
        let compose = MessageIdentity.composeTime(message)
        return Date(timeIntervalSince1970: compose > 0 ? compose : Date().timeIntervalSince1970)
    }

    // MARK: Lookup

    /// The `(section, row)` that is the same message as `message`: server id first, then the local
    /// handle (also through the alias map), then the own muid.
    static func locate(_ message: BaseMessage,
                       in sections: MessageSections,
                       aliases: MessageAliasMap) -> (section: Int, row: Int)? {
        let id = MessageIdentity.serverId(message)
        let local = MessageIdentity.localId(message)
        var aliasId = 0
        if id == 0, let local = local, let mapped = aliases.serverId(forLocalId: local) { aliasId = mapped }
        let wantedId = id > 0 ? id : aliasId

        if wantedId > 0 {
            for (s, section) in sections.enumerated() {
                if let r = section.messages.firstIndex(where: { $0.id == wantedId }) { return (s, r) }
            }
        }
        if let local = local {
            for (s, section) in sections.enumerated() {
                if let r = section.messages.firstIndex(where: { MessageIdentity.localId($0) == local }) { return (s, r) }
            }
        }
        if let muid = MessageIdentity.muid(message) {
            for (s, section) in sections.enumerated() {
                let r = section.messages.firstIndex(where: {
                    guard MessageIdentity.muid($0) == muid else { return false }
                    let rowId = MessageIdentity.serverId($0)
                    return rowId == 0 || id == 0 || rowId == id
                })
                if let r = r { return (s, r) }
            }
        }
        return nil
    }

    // MARK: Mutation

    private static func sectionIndex(for date: Date, in sections: inout MessageSections) -> Int {
        let calendar = Calendar.current
        if let existing = sections.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            return existing
        }
        let day = calendar.startOfDay(for: date)
        let at = sections.firstIndex(where: { $0.date < day }) ?? sections.count
        sections.insert((date: day, messages: []), at: at)
        return at
    }

    private static func insertSorted(_ message: BaseMessage, into sections: inout MessageSections) {
        let s = sectionIndex(for: placementDate(message), in: &sections)
        let rows = sections[s].messages
        let at = rows.firstIndex(where: { isNewer(message, than: $0) }) ?? rows.count
        sections[s].messages.insert(message, at: at)
    }

    @discardableResult
    static func remove(at position: (section: Int, row: Int), from sections: inout MessageSections) -> BaseMessage {
        let removed = sections[position.section].messages.remove(at: position.row)
        if sections[position.section].messages.isEmpty { sections.remove(at: position.section) }
        return removed
    }

    /// Upsert `incoming` by identity, each into its sorted place. For the same server id the copy
    /// with the newer `updatedAt` wins, so a read never reverts a live edit. With
    /// `insertIfMissing == false` only rows already shown are replaced (BEH-INV-11).
    @discardableResult
    static func upsert(_ incoming: [BaseMessage],
                       into sections: inout MessageSections,
                       aliases: inout MessageAliasMap,
                       insertIfMissing: Bool = true) -> UpsertResult {
        var result = UpsertResult()
        for message in incoming {
            if let found = locate(message, in: sections, aliases: aliases) {
                let existing = sections[found.section].messages[found.row]
                if existing === message { continue }
                let existingId = MessageIdentity.serverId(existing)
                let newId = MessageIdentity.serverId(message)
                if existingId > 0 && existingId == newId && existing.updatedAt > message.updatedAt { continue }
                // An older, unsent copy never replaces a sent one (a late pending after the ack).
                if existingId > 0 && newId == 0 { continue }
                if existingId == 0 && newId > 0 {
                    result.acquiredServerIds.append(newId)
                    if let local = MessageIdentity.localId(existing) ?? MessageIdentity.localId(message) {
                        aliases.record(localId: local, serverId: newId)
                    }
                }
                if message.quotedMessage == nil, let oldQuoted = existing.quotedMessage {
                    message.quotedMessage = oldQuoted
                }
                // A receipt is never taken back: a copy of the same message that was read before the
                // receipt reached it (a cache row, an ack that raced it) keeps the ticks the row has
                // (ENG-41193).
                if existingId > 0 && existingId == newId {
                    if message.deliveredAt == 0, existing.deliveredAt > 0 { message.deliveredAt = existing.deliveredAt }
                    if message.readAt == 0, existing.readAt > 0 { message.readAt = existing.readAt }
                }
                remove(at: found, from: &sections)
                insertSorted(message, into: &sections)
                result.changed = true
            } else if insertIfMissing {
                if MessageIdentity.serverId(message) > 0, let local = MessageIdentity.localId(message) {
                    aliases.record(localId: local, serverId: message.id)
                }
                insertSorted(message, into: &sections)
                result.changed = true
            }
        }
        return result
    }

    /// What `dropShown` did, with the work it did, so a test can check it stays linear.
    struct DropShownResult {
        /// The incoming rows that are not shown yet, in their order.
        var kept: [BaseMessage] = []
        /// Shown rows replaced in place by a re-delivered copy that is not older.
        var replaced = 0
        /// Rows indexed (one pass over the shown rows) and rows looked up (one per incoming row).
        var rowsIndexed = 0
        var lookups = 0
    }

    /// A page that re-delivers rows already shown (a reconnect fetch, a forward page, an agent thread
    /// that re-includes its parent) adds each message once. The shown server ids are indexed once, so
    /// the cost is the shown rows plus the incoming rows, not their product. As in `upsert` and the
    /// Android kit's reconcile, the copy with the newer `updatedAt` wins (a tie goes to the incoming
    /// copy), so a read never reverts a live edit: a not-older copy replaces the shown row where it
    /// stands (same id, same place), an older one is dropped. A receipt is never taken back. Rows
    /// without a server id are never dropped here.
    static func dropShown(_ incoming: [BaseMessage], from sections: inout MessageSections) -> DropShownResult {
        var result = DropShownResult()
        guard !incoming.isEmpty else { return result }
        var shown: [Int: (section: Int, row: Int)] = [:]
        for (s, section) in sections.enumerated() {
            for (r, row) in section.messages.enumerated() where row.id > 0 {
                shown[row.id] = (s, r)
                result.rowsIndexed += 1
            }
        }
        for message in incoming {
            result.lookups += 1
            guard message.id > 0, let at = shown[message.id] else { result.kept.append(message); continue }
            let existing = sections[at.section].messages[at.row]
            if existing === message || existing.updatedAt > message.updatedAt { continue }
            if message.quotedMessage == nil, let oldQuoted = existing.quotedMessage { message.quotedMessage = oldQuoted }
            if message.deliveredAt == 0, existing.deliveredAt > 0 { message.deliveredAt = existing.deliveredAt }
            if message.readAt == 0, existing.readAt > 0 { message.readAt = existing.readAt }
            sections[at.section].messages[at.row] = message
            result.replaced += 1
        }
        return result
    }

    /// Remove the row that is `message`, by identity. Returns whether a row was removed.
    @discardableResult
    static func remove(_ message: BaseMessage,
                       from sections: inout MessageSections,
                       aliases: MessageAliasMap) -> Bool {
        guard let found = locate(message, in: sections, aliases: aliases) else { return false }
        remove(at: found, from: &sections)
        return true
    }

    // MARK: Reconcile

    /// Server ids of the rows a cached page showed.
    static func cachedKeys(of messages: [BaseMessage]) -> Set<Int> {
        return Set(messages.compactMap { MessageIdentity.serverId($0) > 0 ? $0.id : nil })
    }

    /// Apply a server page: upsert it, then remove rows its cached page showed that the server no
    /// longer has, but only inside the server page's id range (a proven omission). Rows without a
    /// server id are never removed.
    @discardableResult
    static func reconcileServerPage(_ serverPage: [BaseMessage],
                                    cachedKeys: Set<Int>,
                                    into sections: inout MessageSections,
                                    aliases: inout MessageAliasMap) -> UpsertResult {
        var result = upsert(serverPage, into: &sections, aliases: &aliases)
        let serverIds = serverPage.map { MessageIdentity.serverId($0) }.filter { $0 > 0 }
        guard let minId = serverIds.min(), let maxId = serverIds.max(), !cachedKeys.isEmpty else { return result }
        let present = Set(serverIds)
        for s in sections.indices.reversed() {
            let before = sections[s].messages.count
            sections[s].messages.removeAll { row in
                let id = MessageIdentity.serverId(row)
                guard id > 0, cachedKeys.contains(id), !present.contains(id) else { return false }
                return id >= minId && id <= maxId
            }
            if sections[s].messages.count != before { result.changed = true }
            if sections[s].messages.isEmpty { sections.remove(at: s) }
        }
        return result
    }

    /// Which end of the list a page read extends.
    enum PageEnd { case older, newer }

    /// D13-R2: a cached page is kept only when it joins the server page that answered the same read
    /// (they share a server id; rows the kit filtered out count, so pass the raw pages). One that does
    /// not join is stale: more arrived than one page holds. The rows it painted beyond the server
    /// page's far end (older for an older read, newer for a newer read) are removed, not stitched to
    /// the server page over a hidden gap; the next page reads them again from the server page's edge.
    /// Never removed: rows without a server id, rows listed before the cached page painted (they are
    /// not in `paintedKeys`), and anything when the server page is empty. Returns whether a row went.
    @discardableResult
    static func dropUnjoinedCachedPage(paintedKeys: Set<Int>,
                                       rawCachedKeys: Set<Int>,
                                       rawServerPage: [BaseMessage],
                                       end: PageEnd,
                                       from sections: inout MessageSections) -> Bool {
        let serverKeys = cachedKeys(of: rawServerPage)
        guard !paintedKeys.isEmpty, let minId = serverKeys.min(), let maxId = serverKeys.max(),
              rawCachedKeys.isDisjoint(with: serverKeys) else { return false }
        var removed = false
        for s in sections.indices.reversed() {
            let before = sections[s].messages.count
            sections[s].messages.removeAll { row in
                let id = MessageIdentity.serverId(row)
                guard id > 0, paintedKeys.contains(id) else { return false }
                return end == .older ? id <= minId : id >= maxId
            }
            if sections[s].messages.count != before { removed = true }
            if sections[s].messages.isEmpty { sections.remove(at: s) }
        }
        return removed
    }

    // MARK: Cumulative read

    /// Whether to send the one cumulative read receipt for the newest incoming message of the open
    /// chat (README 3.6). `trigger` is what just happened.
    enum ReadTrigger { case initialRead, olderPage, syncCompleted }

    /// An older page never marks (the newest was marked when the chat opened); a sweep marks only
    /// when the user is at the bottom, so unread messages above the fold are not read for them.
    static func shouldMarkNewestRead(_ trigger: ReadTrigger, isAtBottom: Bool) -> Bool {
        switch trigger {
        case .olderPage: return false
        case .initialRead: return isAtBottom
        case .syncCompleted: return isAtBottom
        }
    }

    // MARK: Newest-window refresh

    enum WindowRefreshPlan: Equatable {
        /// The server's newest page overlaps (or sits next to) what is shown: merge it in place.
        case merge
        /// More was missed than one page: the shown rows and the newest page are not contiguous.
        /// Do not rebuild the list under the reader; offer "jump to latest" instead.
        case offerJumpToLatest
    }

    /// `shownNewest` is the newest server id shown (0 when none); `pageOldest` the oldest server id
    /// of the refreshed newest page.
    static func windowRefreshPlan(shownNewest: Int, pageOldest: Int) -> WindowRefreshPlan {
        return shownNewest > 0 && pageOldest > shownNewest ? .offerJumpToLatest : .merge
    }

    // MARK: Cursors

    /// Newest row that has a server id: the forward-cursor anchor (rows without one are skipped).
    static func newestServerId(_ sections: MessageSections) -> Int {
        return MessageListCursors.newestServerId(sections)
    }

    /// Oldest row that has a server id.
    static func oldestServerId(_ sections: MessageSections) -> Int {
        return MessageListCursors.oldestServerId(sections)
    }
}

/// Receipts for server ids the list does not show yet (their ack has not landed) are held here and
/// applied when a row acquires that id (BEH-SEND-32). Capped; cleared on a session change.
internal struct HeldReceipts {
    static let capacity = 200
    /// How long a receipt waits for its message's ack. A sweep no longer ends the wait: a media
    /// send's ack can land after the sweep (ENG-41193), and its delivered tick was lost.
    static let maxAge: TimeInterval = 120

    private var order: [Int] = []
    private var receipts: [Int: MessageReceipt] = [:]
    private var heldAt: [Int: Date] = [:]

    var count: Int { return receipts.count }

    mutating func hold(messageId: Int, receipt: MessageReceipt, now: Date = Date()) {
        guard messageId > 0 else { return }
        removeExpired(now: now)
        if receipts[messageId] != nil { order.removeAll { $0 == messageId } }
        receipts[messageId] = receipt
        heldAt[messageId] = now
        order.append(messageId)
        if order.count > Self.capacity, let oldest = order.first {
            order.removeFirst()
            receipts.removeValue(forKey: oldest)
            heldAt.removeValue(forKey: oldest)
        }
    }

    /// Remove and return the receipt held for `messageId`, if any.
    mutating func take(messageId: Int) -> MessageReceipt? {
        guard let receipt = receipts.removeValue(forKey: messageId) else { return nil }
        heldAt.removeValue(forKey: messageId)
        order.removeAll { $0 == messageId }
        return receipt
    }

    /// Drop the receipts held longer than `maxAge`: their ack never landed.
    mutating func removeExpired(now: Date = Date(), maxAge: TimeInterval = HeldReceipts.maxAge) {
        let expired = Set(heldAt.filter { now.timeIntervalSince($0.value) > maxAge }.keys)
        guard !expired.isEmpty else { return }
        order.removeAll { expired.contains($0) }
        for id in expired {
            receipts.removeValue(forKey: id)
            heldAt.removeValue(forKey: id)
        }
    }

    mutating func removeAll() {
        order.removeAll()
        receipts.removeAll()
        heldAt.removeAll()
    }
}
