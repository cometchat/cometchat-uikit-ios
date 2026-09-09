//
//  PinConversationErrorCodes.swift
//  CometChatUIKitSwift
//

import Foundation

/// Server error codes for pin conversation.
///
/// The SDK's own `CometChatConstants` is internal, so the UI Kit cannot reference it
/// directly — every existing error-matching site in this kit compares against a literal
/// string for the same reason (see `CometChatDialog`, `MessageComposerViewModel`). These are
/// collected here rather than inlined so a code correction is one edit.
///
/// Verified against the API reference published on ENG-37690 (2026-07-30) — these are the
/// codes the backend actually emits, not the design doc's `ERR_ACTION_NOT_ALLOWED` /
/// `ERR_MESSAGE_NOT_FOUND`, neither of which exist in the codebase.
public struct PinConversationErrorCodes {

    /// 400 — already at the per-user pinned-conversation cap. The real cap rides in
    /// `errorParams` and is never hard-coded — this code only selects the message.
    public static let limitExceeded = "ERR_PINNED_CONVERSATIONS_LIMIT_EXCEEDED"

    /// 404 — no conversation row yet (never messaged) or deleted-for-me. Known backend
    /// behaviour per `checkConversation` middleware, not a transient failure.
    public static let notAccessible = "ERR_CONVERSATION_NOT_ACCESSIBLE"

    /// 403 — RBAC denial. Carries params `{action, role, restrictionSource, guid, scope}`.
    /// Not yet enforced backend-side as of 2026-07-30, but the client should still handle it.
    public static let permissionDenied = "ERR_PERMISSION_DENIED"

    /// 400 — invalid `pinnedBy` filter value or malformed body.
    public static let badRequest = "ERR_BAD_REQUEST"
}
