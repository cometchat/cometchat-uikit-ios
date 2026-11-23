//
//  ThreadReplyCounter.swift
//  CometChatUIKitSwift
//
//  The reply count a thread header shows on the offline (ON) path. No UIKit imports.
//
//  The SDK's parent `replyCount` already includes own unsent replies when it delivers the parent
//  (BEH-MUT-10). Between deliveries the header adds +1 per own pending reply (once per reply, by its
//  stable key), takes it back on DISCARDED, never counts the ack again, and lets a fresher parent
//  replace the value and clear the local adds. A reply received live counts into the base.
//

import Foundation
import CometChatSDK

internal struct ThreadReplyCounter {

    private(set) var base: Int
    private var pending = Set<String>()

    init(base: Int = 0) { self.base = base }

    var count: Int { return base + pending.count }

    /// Own reply went pending (or was retried). Returns whether the count changed.
    @discardableResult
    mutating func addPending(key: String) -> Bool {
        return pending.insert(key).inserted
    }

    /// Own reply was discarded. Returns whether the count changed.
    @discardableResult
    mutating func removePending(key: String) -> Bool {
        return pending.remove(key) != nil
    }

    /// Own reply was acked: it is not counted again. Its local add stays until a fresher parent,
    /// which already includes it.
    mutating func acked(key: String) {}

    /// A reply from someone else arrived live.
    mutating func receivedReply() { base += 1 }

    /// The SDK delivered a fresher parent: its value replaces ours and the local adds are cleared.
    mutating func replaceParent(replyCount: Int) {
        base = replyCount
        pending.removeAll()
    }

    /// The stable identity of an own reply: its muid (the same on the composer's object and the
    /// SDK's pending copy), else its local id.
    static func key(of message: BaseMessage) -> String? {
        return MessageIdentity.muid(message) ?? MessageIdentity.localId(message)
    }
}
