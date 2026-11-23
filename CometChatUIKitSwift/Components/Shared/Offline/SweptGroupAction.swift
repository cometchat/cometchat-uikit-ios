//
//  SweptGroupAction.swift
//  CometChatUIKitSwift
//
//  A group action (kick, ban, unban, leave, join) the SDK's catch-up delivered through
//  `onMessageSyncCompleted` instead of the live group listener. It is replayed into the same
//  handlers a live one would reach (UIT-SYNC-13), so a screen needs no second code path.
//  No UIKit imports.
//

import Foundation
import CometChatSDK

internal enum SweptGroupAction {

    /// The group a swept `action` is about, if it is a membership action.
    static func group(of action: ActionMessage) -> Group? {
        return action.actionFor as? Group
    }

    /// Call the live handler on `delegate` that matches `action`. Returns whether one was called.
    @discardableResult
    static func dispatch(_ action: ActionMessage, to delegate: CometChatGroupDelegate) -> Bool {
        guard let group = group(of: action) else { return false }
        let by = action.actionBy as? User
        let on = action.actionOn as? User
        switch action.action {
        case .kicked?:
            guard let on = on, let by = by, let call = delegate.onGroupMemberKicked else { return false }
            call(action, on, by, group)
            return true
        case .banned?:
            guard let on = on, let by = by, let call = delegate.onGroupMemberBanned else { return false }
            call(action, on, by, group)
            return true
        case .unbanned?:
            guard let on = on, let by = by, let call = delegate.onGroupMemberUnbanned else { return false }
            call(action, on, by, group)
            return true
        case .left?:
            guard let who = by ?? on, let call = delegate.onGroupMemberLeft else { return false }
            call(action, who, group)
            return true
        case .joined?:
            guard let who = by ?? on, let call = delegate.onGroupMemberJoined else { return false }
            call(action, who, group)
            return true
        default:
            return false
        }
    }

    /// Replay every swept membership action, whatever group it is about, into `delegate`. For a list
    /// of groups, which is not about one group.
    static func replayAll(_ messages: [BaseMessage], to delegate: CometChatGroupDelegate) {
        for case let action as ActionMessage in messages {
            dispatch(action, to: delegate)
        }
    }

    /// Replay every swept action of `group` into `delegate`.
    static func replay(_ messages: [BaseMessage], forGroup guid: String?, to delegate: CometChatGroupDelegate) {
        guard let guid = guid else { return }
        for case let action as ActionMessage in messages {
            guard group(of: action)?.guid == guid else { continue }
            dispatch(action, to: delegate)
        }
    }
}
